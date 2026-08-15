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

  group('committed mutations survive a failed authoritative reload', () {
    test('create publishes the saved record and selection', () async {
      final failingContainer = _containerFor(
        _PostWriteListFailingRepository(repository),
      );
      await failingContainer.read(batteryTypeCatalogProvider.future);
      final controller =
          failingContainer.read(batteryTypeCatalogProvider.notifier);

      await expectLater(
        controller.create(validDraft(typeName: 'New persisted type')),
        throwsA(isA<BatteryTypeCatalogRefreshWarning>()),
      );

      final snapshot =
          failingContainer.read(batteryTypeCatalogProvider).requireValue;
      expect(snapshot.records.map((record) => record.typeName), [
        'New persisted type',
      ]);
      expect(snapshot.selectedId, snapshot.records.single.id);
      expect((await repository.list()).single.id, snapshot.selectedId);
    });

    test('update publishes the saved record and selection', () async {
      final original = await repository.create(validDraft());
      final failingContainer = _containerFor(
        _PostWriteListFailingRepository(repository),
      );
      await failingContainer.read(batteryTypeCatalogProvider.future);

      await expectLater(
        failingContainer
            .read(batteryTypeCatalogProvider.notifier)
            .updateBatteryType(
              original.id,
              validDraft(typeName: 'Updated persisted type'),
            ),
        throwsA(isA<BatteryTypeCatalogRefreshWarning>()),
      );

      final snapshot =
          failingContainer.read(batteryTypeCatalogProvider).requireValue;
      expect(snapshot.records.single.typeName, 'Updated persisted type');
      expect(snapshot.selectedId, original.id);
      expect((await repository.get(original.id)).typeName,
          'Updated persisted type');
    });

    test('deactivate publishes the saved lifecycle status and selection',
        () async {
      final original = await repository.create(validDraft());
      final failingContainer = _containerFor(
        _PostWriteListFailingRepository(repository),
      );
      await failingContainer.read(batteryTypeCatalogProvider.future);
      final controller =
          failingContainer.read(batteryTypeCatalogProvider.notifier);
      controller.select(original.id);

      await expectLater(
        controller.deactivate(original.id),
        throwsA(isA<BatteryTypeCatalogRefreshWarning>()),
      );

      final snapshot =
          failingContainer.read(batteryTypeCatalogProvider).requireValue;
      expect(snapshot.records.single.isActive, isFalse);
      expect(snapshot.visible, isEmpty);
      expect(snapshot.selectedId, original.id);
      expect((await repository.get(original.id)).isActive, isFalse);
    });

    test('reactivate publishes the saved lifecycle status and selection',
        () async {
      final original = await repository.create(validDraft());
      await repository.deactivate(original.id);
      final failingContainer = _containerFor(
        _PostWriteListFailingRepository(repository),
      );
      await failingContainer.read(batteryTypeCatalogProvider.future);
      final controller =
          failingContainer.read(batteryTypeCatalogProvider.notifier);
      controller.select(original.id);

      await expectLater(
        controller.reactivate(original.id),
        throwsA(isA<BatteryTypeCatalogRefreshWarning>()),
      );

      final snapshot =
          failingContainer.read(batteryTypeCatalogProvider).requireValue;
      expect(snapshot.records.single.isActive, isTrue);
      expect(snapshot.visible.single.id, original.id);
      expect(snapshot.selectedId, original.id);
      expect((await repository.get(original.id)).isActive, isTrue);
    });
  });

  group('typed conflicts reconcile the catalog before being rethrown', () {
    test('duplicate name reloads a record created by another writer', () async {
      await repository.create(validDraft(typeName: 'Original'));
      await container.read(batteryTypeCatalogProvider.future);
      final concurrent =
          await repository.create(validDraft(typeName: 'Concurrent'));

      await expectLater(
        container
            .read(batteryTypeCatalogProvider.notifier)
            .create(validDraft(typeName: ' concurrent ')),
        throwsA(isA<BatteryTypeNameConflictException>()),
      );

      expect(
        container
            .read(batteryTypeCatalogProvider)
            .requireValue
            .records
            .map((record) => record.id),
        contains(concurrent.id),
      );
    });

    test('reactivation conflict reloads the active replacement', () async {
      final inactive = await repository.create(validDraft());
      await repository.deactivate(inactive.id);
      await container.read(batteryTypeCatalogProvider.future);
      final replacement = await repository.create(validDraft());

      await expectLater(
        container
            .read(batteryTypeCatalogProvider.notifier)
            .reactivate(inactive.id),
        throwsA(isA<BatteryTypeReactivationConflictException>()),
      );

      expect(
        container
            .read(batteryTypeCatalogProvider)
            .requireValue
            .records
            .map((record) => record.id),
        containsAll([inactive.id, replacement.id]),
      );
    });

    test('stale lifecycle state reloads the concurrent status', () async {
      final original = await repository.create(validDraft());
      await container.read(batteryTypeCatalogProvider.future);
      await repository.deactivate(original.id);

      await expectLater(
        container
            .read(batteryTypeCatalogProvider.notifier)
            .deactivate(original.id),
        throwsA(isA<BatteryTypeStateConflictException>()),
      );

      expect(
        container
            .read(batteryTypeCatalogProvider)
            .requireValue
            .records
            .single
            .isActive,
        isFalse,
      );
    });

    test('not found reloads the catalog without the missing record', () async {
      final original = await repository.create(validDraft());
      await container.read(batteryTypeCatalogProvider.future);
      await (database.delete(database.batteryTypes)
            ..where((table) => table.uuid.equals(original.id.value)))
          .go();

      await expectLater(
        container
            .read(batteryTypeCatalogProvider.notifier)
            .updateBatteryType(original.id, validDraft()),
        throwsA(isA<BatteryTypeNotFoundException>()),
      );

      expect(
        container.read(batteryTypeCatalogProvider).requireValue.records,
        isEmpty,
      );
    });

    test('a failed conflict reload preserves the original exception instance',
        () async {
      final conflict = BatteryTypeStateConflictException(
        PermanentId.parse('99000000-0000-4000-8000-000000000001'),
        'simulated stale state',
      );
      final failingContainer = _containerFor(
        _ConflictThenListFailingRepository(repository, conflict),
      );
      await failingContainer.read(batteryTypeCatalogProvider.future);

      await expectLater(
        failingContainer
            .read(batteryTypeCatalogProvider.notifier)
            .deactivate(conflict.id),
        throwsA(same(conflict)),
      );
      expect(
        failingContainer.read(batteryTypeCatalogProvider),
        isA<AsyncData<BatteryTypeCatalogSnapshot>>(),
      );
    });
  });
}

ProviderContainer _containerFor(BatteryTypeRepository override) {
  final scoped = ProviderContainer(
    overrides: [batteryTypeRepositoryProvider.overrideWithValue(override)],
  );
  addTearDown(scoped.dispose);
  return scoped;
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
  Future<BatteryTypeRecord> deactivate(PermanentId id) async {
    final record = await _delegate.deactivate(id);
    _failNextList = true;
    return record;
  }

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
  Future<BatteryTypeRecord> reactivate(PermanentId id) async {
    final record = await _delegate.reactivate(id);
    _failNextList = true;
    return record;
  }

  @override
  Future<BatteryTypeRecord> update(
    PermanentId id,
    BatteryTypeDraft draft,
  ) async {
    final record = await _delegate.update(id, draft);
    _failNextList = true;
    return record;
  }

  @override
  Future<BatteryTypeUsage> usage(PermanentId id) => _delegate.usage(id);
}

final class _ConflictThenListFailingRepository
    implements BatteryTypeRepository {
  _ConflictThenListFailingRepository(this._delegate, this.conflict);

  final BatteryTypeRepository _delegate;
  final BatteryTypeStateConflictException conflict;
  var _failNextList = false;

  @override
  Future<BatteryTypeRecord> create(BatteryTypeDraft draft) =>
      _delegate.create(draft);

  @override
  Future<BatteryTypeRecord> deactivate(PermanentId id) {
    _failNextList = true;
    throw conflict;
  }

  @override
  Future<BatteryTypeRecord> get(PermanentId id) => _delegate.get(id);

  @override
  Future<List<BatteryTypeRecord>> list({bool includeInactive = false}) {
    if (_failNextList) {
      _failNextList = false;
      throw StateError('simulated conflict reload failure');
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
