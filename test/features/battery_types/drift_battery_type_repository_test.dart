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
import 'package:drift/drift.dart';
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
}

BatteryTypeDraft validDraft({
  String typeName = 'AA NiMH',
  IconSelection? suggestedIcon,
}) {
  return BatteryTypeDraft(
    typeName: typeName,
    description: 'Rechargeable AA cells',
    chemistry: 'NiMH',
    defaultVoltage: 1.2,
    defaultCapacity: 2500,
    capacityUnit: 'mAh',
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
