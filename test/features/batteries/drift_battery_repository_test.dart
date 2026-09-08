import 'dart:io';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/features/batteries/data/drift_battery_repository.dart';
import 'package:battery_tracker/features/batteries/domain/battery.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftBatteryRepository repository;
  DriftBatteryRepository repo(AppDatabase database) => DriftBatteryRepository(
      database: database,
      iconRepository: DriftIconRepository(
          database: database,
          idGenerator: const UuidV4PermanentIdGenerator(),
          builtInRegistry:
              IconRegistry(builtIns: BuiltInIconRegistry.definitions)));
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = repo(db);
  });
  tearDown(() => db.close());
  test('icon-only create and edit preserve UUID and created date', () async {
    final a = await repository
        .save(const BatteryDraft(userBatteryId: ' AA-001 ', name: 'Spare'));
    final b = await repository.save(
        const BatteryDraft(userBatteryId: 'AA-RENAMED', status: 'Storage'),
        id: a.id);
    expect(b.id, a.id);
    expect(b.createdAt, a.createdAt);
    expect(b.values.userBatteryId, 'AA-RENAMED');
    expect(b.values.icon.key, 'battery_generic');
    final history = await repository.history(a.id);
    expect(history.length, 4);
    expect(history.join(' '), contains('Available → Storage'));
  });
  test('duplicate IDs are case insensitive and do not change preview',
      () async {
    await repository.save(const BatteryDraft(userBatteryId: 'AA-001'));
    await repository.save(const BatteryDraft(userBatteryId: 'AA-003'));
    expect(await repository.suggestId(prefix: 'AA'), 'AA-002');
    await expectLater(
        repository.save(const BatteryDraft(userBatteryId: ' aa-001 ')),
        throwsA(isA<BatteryValidationException>()));
    expect((await repository.list()).length, 2);
  });
  test('failed history write rolls back battery and newly created batch',
      () async {
    await db.customStatement(
        "CREATE TRIGGER reject_activity BEFORE INSERT ON activity_log BEGIN SELECT RAISE(ABORT, 'injected failure'); END");
    await expectLater(
        repository.save(const BatteryDraft(
            userBatteryId: 'AA-001', batchCode: 'Purchase 1')),
        throwsA(isA<Exception>()));
    expect(await repository.list(), isEmpty);
    expect(await db.select(db.batteryBatches).get(), isEmpty);
  });
  test('invalid numeric values and missing capacity unit are rejected',
      () async {
    for (final draft in [
      const BatteryDraft(userBatteryId: ''),
      const BatteryDraft(userBatteryId: 'A', capacity: 1),
      const BatteryDraft(userBatteryId: 'A', capacityUnit: 'mAh'),
      const BatteryDraft(userBatteryId: 'A', purchasePrice: -1),
      const BatteryDraft(userBatteryId: 'A', nominalVoltage: double.nan)
    ]) {
      await expectLater(
          repository.save(draft), throwsA(isA<BatteryValidationException>()));
    }
    expect(await repository.list(), isEmpty);
  });
  test('type defaults are not forced onto battery overrides', () async {
    final typeUuid = const UuidV4PermanentIdGenerator().next();
    await db.into(db.batteryTypes).insert(BatteryTypesCompanion.insert(
        uuid: typeUuid.value,
        typeName: 'AA',
        chemistry: const Value('NiMH'),
        defaultCapacity: const Value(2500)));
    final a = await repository.save(BatteryDraft(
        userBatteryId: 'AA-001',
        batteryTypeId: typeUuid,
        chemistry: 'Custom',
        capacity: 1900,
        capacityUnit: 'mAh'));
    expect(a.values.capacity, 1900);
    expect(a.values.chemistry, 'Custom');
    await (db.update(db.batteryTypes)
          ..where((t) => t.uuid.equals(typeUuid.value)))
        .write(BatteryTypesCompanion(
            deactivatedAt: Value(DateTime.now().toUtc())));
    await repository.save(a.values, id: a.id);
    await expectLater(
        repository.save(
            BatteryDraft(userBatteryId: 'AA-002', batteryTypeId: typeUuid)),
        throwsA(isA<BatteryValidationException>()));
  });
  test('reads current relationships and charges without rewriting history',
      () async {
    final record =
        await repository.save(const BatteryDraft(userBatteryId: 'AA-001'));
    final row = (await db.select(db.batteries).get()).single;
    const ids = UuidV4PermanentIdGenerator();
    final setId = await db.into(db.batterySets).insert(
        BatterySetsCompanion.insert(
            uuid: ids.next().value, userSetId: 'SET-001', name: 'Pair'));
    final deviceId = await db
        .into(db.devices)
        .insert(DevicesCompanion.insert(uuid: ids.next().value, name: 'Radio'));
    await db.into(db.batterySetMemberships).insert(
        BatterySetMembershipsCompanion.insert(
            uuid: ids.next().value,
            batteryId: row.id,
            batterySetId: setId,
            operationUuid: ids.next().value));
    await db.into(db.assignments).insert(AssignmentsCompanion.insert(
        uuid: ids.next().value,
        subjectType: 'battery',
        batteryId: Value(row.id),
        deviceId: deviceId,
        operationUuid: ids.next().value));
    await db.into(db.chargeRecords).insert(ChargeRecordsCompanion.insert(
        uuid: ids.next().value,
        batteryId: row.id,
        chargedAt: Value(DateTime.utc(2026, 9, 8))));
    final loaded = await repository.get(record.id);
    expect(loaded.currentSets, ['SET-001']);
    expect(loaded.currentDevices, ['Radio']);
    expect(loaded.recordedCharges, 1);
    expect(loaded.lastCharged, DateTime.utc(2026, 9, 8));
    await repository.save(const BatteryDraft(userBatteryId: 'RADIO-001'),
        id: record.id);
    expect((await db.select(db.assignments).get()).length, 1);
    expect((await db.select(db.batterySetMemberships).get()).length, 1);
    expect((await db.select(db.chargeRecords).get()).length, 1);
  });
  test('specifications purchase details and batch survive file restart',
      () async {
    final dir =
        await Directory.systemTemp.createTemp('battery-inventory-test-');
    final file = File('${dir.path}/inventory.sqlite');
    final first = AppDatabase.forTesting(NativeDatabase(file));
    final created = await repo(first).save(BatteryDraft(
        userBatteryId: 'CAM-001',
        batchCode: 'Camera purchase',
        manufacturer: 'Acme',
        serialNumber: 'S1',
        customLabel: 'Travel',
        chemistry: 'Li-ion',
        nominalVoltage: 7.2,
        capacity: 2000,
        capacityUnit: 'mAh',
        purchasePrice: 20,
        totalPackagePrice: 40,
        perBatteryPrice: 20,
        purchaseDate: DateTime.utc(2026, 9, 1),
        warrantyExpiration: DateTime.utc(2027, 9, 1),
        notes: 'Spare'));
    await first.close();
    final second = AppDatabase.forTesting(NativeDatabase(file));
    try {
      final restored = await repo(second).get(created.id);
      expect(restored.values.batchCode, 'Camera purchase');
      expect(restored.values.purchasePrice, 20);
      expect(restored.values.capacity, 2000);
      expect(restored.values.serialNumber, 'S1');
      expect(restored.values.purchaseDate, DateTime.utc(2026, 9, 1));
      expect((await repo(second).history(created.id)).length, 2);
    } finally {
      await second.close();
      await dir.delete(recursive: true);
    }
  });
}
