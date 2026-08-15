import 'dart:convert';
import 'dart:io';

import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/core/storage/managed_relative_path.dart';
import 'package:battery_tracker/features/battery_types/data/drift_battery_type_repository.dart';
import 'package:battery_tracker/features/battery_types/domain/battery_type_draft.dart';
import 'package:battery_tracker/features/battery_types/domain/battery_type_repository.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/domain/icon_color.dart';
import 'package:battery_tracker/features/icons/domain/icon_definition.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_repository.dart';
import 'package:battery_tracker/features/icons/domain/icon_selection.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftIconRepository iconRepository;
  late DriftBatteryTypeRepository repository;
  late _SequenceIdGenerator idGenerator;
  late _SteppingClock clock;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.customSelect('SELECT 1').getSingle();
    idGenerator = _SequenceIdGenerator();
    clock = _SteppingClock();
    iconRepository = DriftIconRepository(
      database: database,
      idGenerator: idGenerator,
      builtInRegistry: IconRegistry(builtIns: BuiltInIconRegistry.definitions),
      clock: clock.call,
    );
    repository = DriftBatteryTypeRepository(
      database: database,
      idGenerator: idGenerator,
      iconRepository: iconRepository,
      clock: clock.call,
    );
  });

  tearDown(() => database.close());

  test('creates and retrieves a Battery Type by its permanent UUID', () async {
    final created = await repository.create(validDraft());

    final fetched = await repository.get(created.id);

    expect(fetched.id, created.id);
    expect(fetched.typeName, 'AA NiMH');
    expect(fetched.chemistry, 'NiMH');
    expect(fetched.defaultVoltage, 1.2);
    expect(fetched.defaultCapacity, 2500);
    expect(fetched.capacityUnit, 'mAh');
  });

  test('lists active Battery Types alphabetically', () async {
    await repository.create(validDraft(typeName: 'C NiMH'));
    final inactive = await repository.create(validDraft(typeName: 'D NiMH'));
    await repository.create(validDraft(typeName: 'AA NiMH'));
    await (database.update(database.batteryTypes)
          ..where((table) => table.uuid.equals(inactive.id.value)))
        .write(BatteryTypesCompanion(deactivatedAt: Value(clock.call())));

    final active = await repository.list();

    expect(active.map((type) => type.typeName), ['AA NiMH', 'C NiMH']);
  });

  test('creates a type with its selected custom icon and color', () async {
    final category = await iconRepository.createCategory(
      id: PermanentId.parse('10000000-0000-4000-8000-000000000001'),
      name: 'Battery labels',
      scope: IconScope.battery,
    );
    final icon = await iconRepository.createCustomIcon(
      id: PermanentId.parse('20000000-0000-4000-8000-000000000001'),
      name: 'AA label',
      categoryId: category.id,
      relativePath: ManagedRelativePath.parse('custom_icons/aa-label.svg'),
      fileType: IconFileType.svg,
      supportsColor: true,
    );

    final created = await repository.create(
      validDraft(
        suggestedIcon: IconSelection(
          source: IconSource.custom,
          key: icon.id.value,
          color: IconColor.orange,
        ),
      ),
    );

    expect(created.suggestedIcon.source, IconSource.custom);
    expect(created.suggestedIcon.key, icon.id.value);
    expect(created.suggestedIcon.color, IconColor.orange);
  });

  test('creates no row when a Battery Type draft is invalid', () async {
    await expectLater(
      repository.create(validDraft(typeName: '  ')),
      throwsA(isA<BatteryTypeValidationException>()),
    );

    expect(await database.select(database.batteryTypes).get(), isEmpty);
  });

  test('creates no row when its suggested icon is outside battery scope',
      () async {
    await expectLater(
      repository.create(
        validDraft(
          suggestedIcon: const IconSelection(
            source: IconSource.builtin,
            key: 'device_radio',
            color: IconColor.blue,
          ),
        ),
      ),
      throwsA(isA<InvalidIconSelectionException>()),
    );

    expect(await database.select(database.batteryTypes).get(), isEmpty);
  });

  test('creates and updates a type without changing its UUID', () async {
    final created = await repository.create(validDraft());
    final updated = await repository.update(
      created.id,
      validDraft(typeName: 'AA High Capacity'),
    );

    expect(updated.id, created.id);
    expect(updated.typeName, 'AA High Capacity');
    expect(updated.modifiedAt, isNot(created.modifiedAt));
  });

  test('records create and update activity in the same persisted history',
      () async {
    final created = await repository.create(validDraft());
    await repository.update(created.id, validDraft(typeName: 'AA Updated'));

    final activities = await database.select(database.activityLog).get();

    expect(
      activities
          .where((activity) => activity.entityUuid == created.id.value)
          .map((activity) => activity.eventType),
      ['battery_type_created', 'battery_type_updated'],
    );
  });

  test('rejects case-insensitive duplicate active names', () async {
    await repository.create(validDraft(typeName: 'AA NiMH'));

    await expectLater(
      repository.create(validDraft(typeName: ' aa nimh ')),
      throwsA(isA<BatteryTypeNameConflictException>()),
    );
  });

  test('deactivation preserves all references and reports exact usage',
      () async {
    final type = await repository.create(validDraft());
    await seedBatterySetAndDeviceReferences(database, type.id);

    final usage = await repository.usage(type.id);
    expect(usage.batteries, 1);
    expect(usage.batterySets, 1);
    expect(usage.devices, 1);

    final originalReferenceIds = await referencedBatteryTypeRowIds(database);
    final expectedTypeRowId = await batteryTypeRowId(database, type.id);
    expect(originalReferenceIds.battery, expectedTypeRowId);
    expect(originalReferenceIds.batterySet, expectedTypeRowId);
    expect(originalReferenceIds.device, expectedTypeRowId);

    final inactive = await repository.deactivate(type.id);

    expect(inactive.isActive, isFalse);
    final preservedReferenceIds = await referencedBatteryTypeRowIds(database);
    expect(preservedReferenceIds.battery, originalReferenceIds.battery);
    expect(preservedReferenceIds.batterySet, originalReferenceIds.batterySet);
    expect(preservedReferenceIds.device, originalReferenceIds.device);
    expect(await repository.list(), isEmpty);
    expect(await repository.list(includeInactive: true), hasLength(1));
  });

  test('allows an inactive name to be reused by a new active type', () async {
    final original = await repository.create(validDraft());
    await repository.deactivate(original.id);

    final replacement = await repository.create(validDraft());

    expect(replacement.id, isNot(original.id));
    expect(replacement.typeName, 'AA NiMH');
  });

  test(
      'rejects reactivation when its inactive name now belongs to an active type',
      () async {
    final original = await repository.create(validDraft());
    await repository.deactivate(original.id);
    await repository.create(validDraft());

    await expectLater(
      repository.reactivate(original.id),
      throwsA(
        isA<BatteryTypeReactivationConflictException>().having(
          (error) => error.id,
          'id',
          original.id,
        ),
      ),
    );
  });

  test('reactivates an inactive type and restores it to the active list',
      () async {
    final type = await repository.create(validDraft());
    await repository.deactivate(type.id);

    final reactivated = await repository.reactivate(type.id);

    expect(reactivated.id, type.id);
    expect(reactivated.isActive, isTrue);
    expect((await repository.list()).single.id, type.id);
  });

  test(
      'edits an inactive type without claiming an active name until reactivated',
      () async {
    final inactive = await repository.create(validDraft(typeName: 'AA NiMH'));
    await repository.deactivate(inactive.id);
    await repository.create(validDraft(typeName: 'AAA NiMH'));

    final edited = await repository.update(
      inactive.id,
      validDraft(typeName: 'AAA NiMH'),
    );

    expect(edited.typeName, 'AAA NiMH');
    expect(edited.isActive, isFalse);
    await expectLater(
      repository.reactivate(inactive.id),
      throwsA(isA<BatteryTypeReactivationConflictException>()),
    );
  });

  test('rejects repeated lifecycle actions with typed stale-state errors',
      () async {
    final type = await repository.create(validDraft());
    await repository.deactivate(type.id);

    await expectLater(
      repository.deactivate(type.id),
      throwsA(isA<BatteryTypeStateConflictException>()),
    );
    await repository.reactivate(type.id);
    await expectLater(
      repository.reactivate(type.id),
      throwsA(isA<BatteryTypeStateConflictException>()),
    );
  });

  test('reports missing UUIDs through the typed not-found error', () async {
    final missing = PermanentId.parse('11111111-1111-4111-8111-111111111111');

    for (final operation in [
      repository.usage(missing),
      repository.deactivate(missing),
      repository.reactivate(missing),
    ]) {
      await expectLater(
        operation,
        throwsA(isA<BatteryTypeNotFoundException>()),
      );
    }
  });

  test('rolls back deactivation when its activity record cannot be persisted',
      () async {
    final type = await repository.create(validDraft());
    await database.customStatement('''
      CREATE TRIGGER fail_battery_type_activity
      BEFORE INSERT ON activity_log
      WHEN NEW.event_type = 'battery_type_deactivated'
      BEGIN
        SELECT RAISE(ABORT, 'simulated activity failure');
      END;
    ''');

    await expectLater(repository.deactivate(type.id), throwsA(isA<Object>()));

    final current = await repository.get(type.id);
    expect(current.isActive, isTrue);
    expect(current.deactivatedAt, isNull);
  });

  test('records lifecycle activity with the type UUID and usage metadata',
      () async {
    final type = await repository.create(validDraft());
    await seedBatterySetAndDeviceReferences(database, type.id);

    await repository.deactivate(type.id);
    await repository.reactivate(type.id);

    final activity = await (database.select(database.activityLog)
          ..where((table) => table.entityUuid.equals(type.id.value)))
        .get();
    final deactivated = activity.singleWhere(
      (entry) => entry.eventType == 'battery_type_deactivated',
    );

    expect(
      activity.map((entry) => entry.eventType),
      containsAll(['battery_type_deactivated', 'battery_type_reactivated']),
    );
    expect(deactivated.entityType, 'battery_type');
    expect(deactivated.entityUuid, type.id.value);
    expect(
      jsonDecode(deactivated.metadataJson),
      {'batteries': 1, 'battery_sets': 1, 'devices': 1},
    );
  });

  test(
      'persists updated Battery Type fields and UUID after a file-backed restart',
      () async {
    final originalWarningSetting =
        driftRuntimeOptions.dontWarnAboutMultipleDatabases;
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    addTearDown(() {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases =
          originalWarningSetting;
    });
    final root = await Directory.systemTemp.createTemp('battery-type-restart-');
    final databaseFile =
        File.fromUri(root.uri.resolve('battery_tracker.sqlite'));
    addTearDown(() async {
      if (root.existsSync()) {
        await root.delete(recursive: true);
      }
    });

    final firstDatabase = AppDatabase.forTesting(NativeDatabase(databaseFile));
    await firstDatabase.customSelect('SELECT 1').getSingle();
    final firstRepository = createRepository(firstDatabase);
    final created = await firstRepository.create(
      validDraft(
        typeName: '18650 Li-ion',
        chemistry: 'Li-ion',
        capacityUnit: 'mWh',
        suggestedIcon: const IconSelection(
          source: IconSource.builtin,
          key: 'battery_18650',
          color: IconColor.orange,
        ),
      ),
    );
    final updated = await firstRepository.update(
      created.id,
      validDraft(
        typeName: '18650 Li-ion',
        chemistry: 'Lithium-ion custom',
        defaultVoltage: 3.7,
        defaultCapacity: 12000,
        capacityUnit: 'mWh',
        suggestedIcon: const IconSelection(
          source: IconSource.builtin,
          key: 'battery_18650',
          color: IconColor.purple,
        ),
      ),
    );
    await firstDatabase.close();

    final reopenedDatabase =
        AppDatabase.forTesting(NativeDatabase(databaseFile));
    await reopenedDatabase.customSelect('SELECT 1').getSingle();
    addTearDown(reopenedDatabase.close);
    final reopened = await createRepository(reopenedDatabase).get(created.id);

    expect(reopened.id, created.id);
    expect(reopened.id, updated.id);
    expect(reopened.typeName, '18650 Li-ion');
    expect(reopened.description, 'Rechargeable AA cells');
    expect(reopened.chemistry, 'Lithium-ion custom');
    expect(reopened.defaultVoltage, 3.7);
    expect(reopened.defaultCapacity, 12000);
    expect(reopened.capacityUnit, 'mWh');
    expect(reopened.physicalSize, 'AA');
    expect(reopened.suggestedIcon.source, IconSource.builtin);
    expect(reopened.suggestedIcon.key, 'battery_18650');
    expect(reopened.suggestedIcon.color, IconColor.purple);
    expect(reopened.notes, 'Standard issue');
    expect(reopened.createdAt, created.createdAt);
    expect(reopened.modifiedAt, updated.modifiedAt);
    expect(reopened.deactivatedAt, isNull);
  });
}

BatteryTypeDraft validDraft({
  String typeName = 'AA NiMH',
  String chemistry = 'NiMH',
  double defaultVoltage = 1.2,
  double defaultCapacity = 2500,
  String capacityUnit = 'mAh',
  IconSelection? suggestedIcon,
}) {
  return BatteryTypeDraft(
    typeName: typeName,
    description: 'Rechargeable AA cells',
    chemistry: chemistry,
    defaultVoltage: defaultVoltage,
    defaultCapacity: defaultCapacity,
    capacityUnit: capacityUnit,
    physicalSize: 'AA',
    notes: 'Standard issue',
    suggestedIcon: suggestedIcon ??
        const IconSelection(
          source: IconSource.builtin,
          key: 'battery_aa',
          color: IconColor.green,
        ),
  );
}

DriftBatteryTypeRepository createRepository(AppDatabase database) {
  final idGenerator = _SequenceIdGenerator();
  final clock = _SteppingClock();
  final iconRepository = DriftIconRepository(
    database: database,
    idGenerator: idGenerator,
    builtInRegistry: IconRegistry(builtIns: BuiltInIconRegistry.definitions),
    clock: clock.call,
  );
  return DriftBatteryTypeRepository(
    database: database,
    idGenerator: idGenerator,
    iconRepository: iconRepository,
    clock: clock.call,
  );
}

Future<void> seedBatterySetAndDeviceReferences(
  AppDatabase database,
  PermanentId typeId,
) async {
  final type = await (database.select(database.batteryTypes)
        ..where((table) => table.uuid.equals(typeId.value)))
      .getSingle();
  await database.into(database.batteries).insert(
        BatteriesCompanion.insert(
          uuid: '70000000-0000-4000-8000-000000000001',
          userBatteryId: 'AA-001',
          batteryTypeId: Value(type.id),
        ),
      );
  await database.into(database.batterySets).insert(
        BatterySetsCompanion.insert(
          uuid: '70000000-0000-4000-8000-000000000002',
          userSetId: 'SET-001',
          name: 'AA set',
          batteryTypeId: Value(type.id),
        ),
      );
  await database.into(database.devices).insert(
        DevicesCompanion.insert(
          uuid: '70000000-0000-4000-8000-000000000003',
          name: 'Radio',
          requiredBatteryTypeId: Value(type.id),
        ),
      );
}

Future<int> batteryTypeRowId(AppDatabase database, PermanentId typeId) async {
  final type = await (database.select(database.batteryTypes)
        ..where((table) => table.uuid.equals(typeId.value)))
      .getSingle();
  return type.id;
}

Future<({int? battery, int? batterySet, int? device})>
    referencedBatteryTypeRowIds(AppDatabase database) async {
  final batteries = await database.select(database.batteries).get();
  final batterySets = await database.select(database.batterySets).get();
  final devices = await database.select(database.devices).get();
  return (
    battery: batteries.single.batteryTypeId,
    batterySet: batterySets.single.batteryTypeId,
    device: devices.single.requiredBatteryTypeId,
  );
}

final class _SteppingClock {
  var _ticks = 0;

  DateTime call() => DateTime.utc(2026, 8, 15, 12).add(
        Duration(minutes: _ticks++),
      );
}

final class _SequenceIdGenerator implements PermanentIdGenerator {
  var _next = 1;

  @override
  PermanentId next() {
    final tail = _next.toString().padLeft(12, '0');
    _next++;
    return PermanentId.parse('90000000-0000-4000-8000-$tail');
  }
}
