import 'dart:io';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/features/batteries/data/drift_battery_repository.dart';
import 'package:battery_tracker/features/batteries/domain/battery.dart';
import 'package:battery_tracker/features/battery_sets/data/drift_battery_set_repository.dart';
import 'package:battery_tracker/features/battery_sets/domain/battery_set.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:battery_tracker/features/charging/data/drift_charge_repository.dart';
import 'package:battery_tracker/features/charging/domain/charge.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftBatteryRepository batteries;
  late DriftBatterySetRepository sets;
  late DriftChargeRepository repo;
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final icons = DriftIconRepository(
        database: db,
        idGenerator: const UuidV4PermanentIdGenerator(),
        builtInRegistry:
            IconRegistry(builtIns: BuiltInIconRegistry.definitions));
    batteries = DriftBatteryRepository(database: db, iconRepository: icons);
    sets =
        DriftBatterySetRepository(db: db, batteries: batteries, icons: icons);
    repo = DriftChargeRepository(db: db);
  });
  tearDown(() => db.close());
  test('charge UUID details and estimate survive SQLite restart', () async {
    final root = await Directory.systemTemp.createTemp('charge-restart-');
    final file = File('${root.path}/test.sqlite');
    var disk = AppDatabase.forTesting(NativeDatabase(file));
    try {
      final icons = DriftIconRepository(
          database: disk,
          idGenerator: const UuidV4PermanentIdGenerator(),
          builtInRegistry:
              IconRegistry(builtIns: BuiltInIconRegistry.definitions));
      final br = DriftBatteryRepository(database: disk, iconRepository: icons);
      final b = await br.save(const BatteryDraft(userBatteryId: 'Restart'));
      final cr = DriftChargeRepository(db: disk);
      await cr.record(
          ChargeDraft(
              chargedAt: DateTime.now(),
              endPercent: 88,
              charger: 'Dock',
              notes: 'Persistent',
              updateCurrentEstimate: true),
          batteryIds: [b.id]);
      final original = (await cr.list()).single;
      await disk.close();
      disk = AppDatabase.forTesting(NativeDatabase(file));
      final restored = (await DriftChargeRepository(db: disk).list()).single;
      expect(restored.id, original.id);
      expect(restored.batteryId, b.id);
      expect(restored.operationId, original.operationId);
      expect(restored.endPercent, 88);
      expect(restored.charger, 'Dock');
      expect(restored.notes, 'Persistent');
      expect(
          (await disk.select(disk.batteries).get())
              .single
              .estimatedChargePercent,
          88);
    } finally {
      await disk.close();
      await root.delete(recursive: true);
    }
  });
  Future<BatteryRecord> battery(String id) =>
      batteries.save(BatteryDraft(userBatteryId: id));
  ChargeDraft draft({int? end = 100, bool update = false}) => ChargeDraft(
      chargedAt: DateTime.now().toUtc(),
      endPercent: end,
      updateCurrentEstimate: update);
  test('individual details default ending percentage and count persist',
      () async {
    final b = await battery('A');
    final at = DateTime.now().toUtc();
    await repo.record(
        ChargeDraft(
            chargedAt: at,
            startPercent: 20,
            charger: ' Dock ',
            notes: ' Ready '),
        batteryIds: [b.id]);
    final r = (await repo.list(batteryId: b.id)).single;
    expect(r.chargedAt, at);
    expect(r.startPercent, 20);
    expect(r.endPercent, 100);
    expect(r.charger, 'Dock');
    expect(r.notes, 'Ready');
    final saved = await batteries.get(b.id);
    expect(saved.recordedCharges, 1);
    expect(saved.lastCharged, at);
    expect(saved.estimatedChargePercent, isNull);
  });
  test('backdated history retains latest date and current estimate', () async {
    final b = await battery('A');
    await repo.setEstimate(b.id, 35);
    final recent = DateTime.now().toUtc();
    await repo.record(ChargeDraft(chargedAt: recent), batteryIds: [b.id]);
    await repo.record(
        ChargeDraft(
            chargedAt: recent.subtract(const Duration(days: 4)),
            endPercent: 80),
        batteryIds: [b.id]);
    final saved = await batteries.get(b.id);
    expect(saved.recordedCharges, 2);
    expect(saved.lastCharged, recent);
    expect(saved.estimatedChargePercent, 35);
  });
  test('estimate clearing creates no charges and ordinary edits preserve it',
      () async {
    final b = await battery('A');
    await repo.setEstimate(b.id, 0);
    await batteries.save(const BatteryDraft(userBatteryId: 'Renamed'),
        id: b.id);
    expect((await batteries.get(b.id)).estimatedChargePercent, 0);
    await repo.setEstimate(b.id, null);
    expect((await batteries.get(b.id)).estimatedChargePercent, isNull);
    expect(await repo.list(), isEmpty);
  });
  test('selected charge explicitly updates estimates with shared operation',
      () async {
    final a = await battery('A'), b = await battery('B');
    await repo.record(draft(end: 90, update: true), batteryIds: [a.id, b.id]);
    final rows = await repo.list();
    expect(rows, hasLength(2));
    expect(rows.map((r) => r.operationId).toSet(), hasLength(1));
    expect((await batteries.get(a.id)).estimatedChargePercent, 90);
    expect((await batteries.get(b.id)).estimatedChargePercent, 90);
  });
  test('second insert failure rolls back records estimates and activity',
      () async {
    final a = await battery('A'), b = await battery('B');
    final before = (await db.select(db.activityLog).get()).length;
    await db.customStatement(
        "CREATE TRIGGER reject_second BEFORE INSERT ON charge_records WHEN (SELECT COUNT(*) FROM charge_records)=1 BEGIN SELECT RAISE(ABORT,'injected'); END");
    await expectLater(
        repo.record(draft(update: true), batteryIds: [a.id, b.id]),
        throwsA(isA<Exception>()));
    expect(await repo.list(), isEmpty);
    expect((await batteries.get(a.id)).estimatedChargePercent, isNull);
    expect((await db.select(db.activityLog).get()).length, before);
  });
  test('Set current members and earlier source history remain independent',
      () async {
    final a = await battery('A'), b = await battery('B');
    final s = await sets.save(const SetDraft(userSetId: 'S', name: 'Set'));
    await sets.addMember(s.id, a.id);
    await repo.record(draft(), setId: s.id);
    await sets.removeMember(s.id, a.id);
    await sets.addMember(s.id, b.id);
    await repo.record(draft(), setId: s.id);
    expect(await repo.list(setId: s.id), hasLength(2));
    expect((await batteries.get(a.id)).recordedCharges, 1);
    expect((await batteries.get(b.id)).recordedCharges, 1);
  });
  test('Set charge parent rolls back on child failure', () async {
    final a = await battery('A'), b = await battery('B');
    final s = await sets.save(const SetDraft(userSetId: 'S', name: 'Set'));
    await sets.addMember(s.id, a.id);
    await sets.addMember(s.id, b.id);
    await db.customStatement(
        "CREATE TRIGGER reject_second BEFORE INSERT ON charge_records WHEN (SELECT COUNT(*) FROM charge_records)=1 BEGIN SELECT RAISE(ABORT,'injected'); END");
    await expectLater(
        repo.record(draft(), setId: s.id), throwsA(isA<Exception>()));
    expect(await repo.list(), isEmpty);
    expect(await db.select(db.setChargeRecords).get(), isEmpty);
  });
  test('invalid selections dates percentages and estimates reject', () async {
    final a = await battery('A');
    for (final action in <Future<void> Function()>[
      () => repo.record(draft()),
      () => repo.record(draft(), batteryIds: [a.id, a.id]),
      () => repo.record(
          ChargeDraft(chargedAt: DateTime.now().add(const Duration(days: 1))),
          batteryIds: [a.id]),
      () => repo.record(draft(end: 101), batteryIds: [a.id]),
      () => repo.record(draft(end: null, update: true), batteryIds: [a.id]),
      () => repo.record(
          ChargeDraft(
              chargedAt: DateTime.now(), startPercent: 90, endPercent: 10),
          batteryIds: [a.id]),
      () => repo.setEstimate(a.id, -1),
    ]) {
      await expectLater(action(), throwsA(isA<ChargeValidationException>()));
    }
    expect(await repo.list(), isEmpty);
  });
  test('nonrechargeable and retired selections reject all records', () async {
    final a = await battery('A');
    final b = await batteries
        .save(const BatteryDraft(userBatteryId: 'B', rechargeable: false));
    await expectLater(repo.record(draft(), batteryIds: [a.id, b.id]),
        throwsA(isA<ChargeValidationException>()));
    final c = await batteries
        .save(const BatteryDraft(userBatteryId: 'C', status: 'Retired'));
    await expectLater(repo.record(draft(), batteryIds: [a.id, c.id]),
        throwsA(isA<ChargeValidationException>()));
    expect(await repo.list(), isEmpty);
  });
  test('optional percentages remain absent', () async {
    final a = await battery('A');
    await repo.record(draft(end: null), batteryIds: [a.id]);
    final r = (await repo.list()).single;
    expect(r.startPercent, isNull);
    expect(r.endPercent, isNull);
  });
  test('backdated charge preserves Charging and current charge completes it',
      () async {
    final a = await batteries
        .save(const BatteryDraft(userBatteryId: 'A', status: 'Charging'));
    await repo.record(
        ChargeDraft(
            chargedAt: DateTime.now().subtract(const Duration(days: 1))),
        batteryIds: [a.id]);
    expect((await batteries.get(a.id)).values.status, 'Charging');
    await repo.record(draft(), batteryIds: [a.id]);
    expect((await batteries.get(a.id)).values.status, 'Available');
  });
}
