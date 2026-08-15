import 'package:battery_tracker/app/app_providers.dart';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/features/battery_types/application/battery_type_catalog_controller.dart';
import 'package:battery_tracker/features/battery_types/data/drift_battery_type_repository.dart';
import 'package:battery_tracker/features/battery_types/domain/battery_type.dart';
import 'package:battery_tracker/features/battery_types/domain/battery_type_draft.dart';
import 'package:battery_tracker/features/battery_types/domain/battery_type_repository.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/domain/icon_color.dart';
import 'package:battery_tracker/features/icons/domain/icon_definition.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_selection.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftBatteryTypeRepository repository;
  late ProviderContainer container;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.customSelect('SELECT 1').getSingle();
    final ids = _SequenceIdGenerator();
    final icons = DriftIconRepository(
      database: database,
      idGenerator: ids,
      builtInRegistry: IconRegistry(builtIns: BuiltInIconRegistry.definitions),
      clock: () => DateTime.utc(2026, 8, 15, 12),
    );
    repository = DriftBatteryTypeRepository(
      database: database,
      idGenerator: ids,
      iconRepository: icons,
      clock: () => DateTime.utc(2026, 8, 15, 12),
    );
    container = ProviderContainer(
      overrides: [batteryTypeRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test('filters by status and searchable specification text', () async {
    final aa = await repository.create(validDraft());
    await repository.create(
      validDraft(
        typeName: 'Radio Pack',
        chemistry: 'LiFePO4',
        physicalSize: 'Prismatic',
        description: 'Patrol radio reserve',
      ),
    );
    final inactive =
        await repository.create(validDraft(typeName: 'Retired AA'));
    await repository.deactivate(inactive.id);

    final initial = await container.read(batteryTypeCatalogProvider.future);
    expect(initial.visible.map((item) => item.typeName), contains(aa.typeName));

    container.read(batteryTypeCatalogProvider.notifier).setQuery('lifepo4');
    expect(
      container
          .read(batteryTypeCatalogProvider)
          .requireValue
          .visible
          .single
          .chemistry,
      'LiFePO4',
    );

    container.read(batteryTypeCatalogProvider.notifier).setQuery('');
    container
        .read(batteryTypeCatalogProvider.notifier)
        .setStatus(BatteryTypeStatusFilter.inactive);
    expect(
      container.read(batteryTypeCatalogProvider).requireValue.visible,
      everyElement(
        isA<BatteryTypeRecord>().having(
          (record) => record.isActive,
          'isActive',
          isFalse,
        ),
      ),
    );
  });

  test('retains the selected record while filters and catalog refresh change',
      () async {
    final aa = await repository.create(validDraft());
    await repository.create(validDraft(typeName: 'AAA NiMH'));
    await container.read(batteryTypeCatalogProvider.future);

    final controller = container.read(batteryTypeCatalogProvider.notifier);
    controller.select(aa.id);
    controller.setQuery('aaa');
    await controller.refresh();

    expect(
      container.read(batteryTypeCatalogProvider).requireValue.selectedId,
      aa.id,
    );
  });

  test('creates and updates through the catalog before publishing refreshes',
      () async {
    await container.read(batteryTypeCatalogProvider.future);
    final controller = container.read(batteryTypeCatalogProvider.notifier);

    final created =
        await controller.create(validDraft(typeName: '18650 Li-ion'));
    expect(
      container
          .read(batteryTypeCatalogProvider)
          .requireValue
          .records
          .map((record) => record.typeName),
      ['18650 Li-ion'],
    );

    await controller.updateBatteryType(
      created.id,
      validDraft(typeName: '18650 High Capacity Li-ion'),
    );
    expect(
      container
          .read(batteryTypeCatalogProvider)
          .requireValue
          .records
          .single
          .typeName,
      '18650 High Capacity Li-ion',
    );
    expect(
      container.read(batteryTypeCatalogProvider).requireValue.selectedId,
      created.id,
    );
  });

  test('deactivates and reactivates records using the default active view',
      () async {
    final type = await repository.create(validDraft());
    await container.read(batteryTypeCatalogProvider.future);
    final controller = container.read(batteryTypeCatalogProvider.notifier);

    await controller.deactivate(type.id);
    expect(container.read(batteryTypeCatalogProvider).requireValue.visible,
        isEmpty);

    await controller.reactivate(type.id);
    expect(
      container.read(batteryTypeCatalogProvider).requireValue.visible.single.id,
      type.id,
    );
  });

  test('keeps the persisted snapshot visible and rethrows a failed write',
      () async {
    await repository.create(validDraft());
    final initial = await container.read(batteryTypeCatalogProvider.future);
    await database.customStatement('''
      CREATE TRIGGER fail_battery_type_create_activity
      BEFORE INSERT ON activity_log
      WHEN NEW.event_type = 'battery_type_created'
      BEGIN
        SELECT RAISE(ABORT, 'simulated write failure');
      END;
    ''');

    await expectLater(
      container
          .read(batteryTypeCatalogProvider.notifier)
          .create(validDraft(typeName: 'Rejected type')),
      throwsA(isA<Object>()),
    );

    final state = container.read(batteryTypeCatalogProvider);
    expect(state, isA<AsyncData<BatteryTypeCatalogSnapshot>>());
    expect(state.requireValue.records.map((record) => record.id), [
      initial.records.single.id,
    ]);
    expect(state.requireValue.visible.map((record) => record.typeName),
        ['AA NiMH']);
  });

  test('retains the prior selection when a successful write cannot reload',
      () async {
    final original = await repository.create(validDraft());
    final failingRepository = _PostWriteListFailingRepository(repository);
    final failingContainer = ProviderContainer(
      overrides: [
        batteryTypeRepositoryProvider.overrideWithValue(failingRepository),
      ],
    );
    addTearDown(failingContainer.dispose);
    await failingContainer.read(batteryTypeCatalogProvider.future);
    final controller =
        failingContainer.read(batteryTypeCatalogProvider.notifier);
    controller.select(original.id);

    await expectLater(
      controller.create(validDraft(typeName: 'New persisted type')),
      throwsStateError,
    );

    final afterFailedRefresh =
        failingContainer.read(batteryTypeCatalogProvider).requireValue;
    expect(
        afterFailedRefresh.records.map((record) => record.id), [original.id]);
    expect(afterFailedRefresh.selectedId, original.id);

    controller.setStatus(BatteryTypeStatusFilter.all);
    expect(
      failingContainer.read(batteryTypeCatalogProvider).requireValue.selectedId,
      original.id,
    );
  });
}

BatteryTypeDraft validDraft({
  String typeName = 'AA NiMH',
  String chemistry = 'NiMH',
  String physicalSize = 'AA',
  String description = 'Rechargeable AA cells',
}) {
  return BatteryTypeDraft(
    typeName: typeName,
    description: description,
    chemistry: chemistry,
    defaultVoltage: 1.2,
    defaultCapacity: 2500,
    capacityUnit: 'mAh',
    physicalSize: physicalSize,
    notes: 'Standard issue',
    suggestedIcon: const IconSelection(
      source: IconSource.builtin,
      key: 'battery_aa',
      color: IconColor.green,
    ),
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

final class _PostWriteListFailingRepository implements BatteryTypeRepository {
  _PostWriteListFailingRepository(this._delegate);

  final BatteryTypeRepository _delegate;
  var _failNextList = false;

  @override
  Future<BatteryTypeRecord> create(BatteryTypeDraft draft) async {
    final created = await _delegate.create(draft);
    _failNextList = true;
    return created;
  }

  @override
  Future<BatteryTypeRecord> deactivate(PermanentId id) =>
      _delegate.deactivate(id);

  @override
  Future<BatteryTypeRecord> get(PermanentId id) => _delegate.get(id);

  @override
  Future<List<BatteryTypeRecord>> list({bool includeInactive = false}) {
    if (_failNextList) {
      _failNextList = false;
      throw StateError('simulated post-write list failure');
    }
    return _delegate.list(includeInactive: includeInactive);
  }

  @override
  Future<BatteryTypeRecord> reactivate(PermanentId id) =>
      _delegate.reactivate(id);

  @override
  Future<BatteryTypeRecord> update(PermanentId id, BatteryTypeDraft draft) =>
      _delegate.update(id, draft);

  @override
  Future<BatteryTypeUsage> usage(PermanentId id) => _delegate.usage(id);
}
