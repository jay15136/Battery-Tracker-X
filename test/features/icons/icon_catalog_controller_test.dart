import 'package:battery_tracker/app/app_providers.dart';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/core/storage/managed_relative_path.dart';
import 'package:battery_tracker/features/icons/application/icon_catalog_controller.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/domain/icon_color.dart';
import 'package:battery_tracker/features/icons/domain/icon_definition.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_repository.dart';
import 'package:battery_tracker/features/icons/domain/icon_selection.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftIconRepository repository;
  late ProviderContainer container;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.customSelect('SELECT 1').getSingle();
    repository = DriftIconRepository(
      database: database,
      idGenerator: _Ids(),
      builtInRegistry: IconRegistry(
        builtIns: BuiltInIconRegistry.definitions,
      ),
      clock: () => DateTime.utc(2026, 8, 15, 12),
    );
    final batteryCategory = await repository.createCategory(
      id: _id('10000000-0000-4000-8000-000000000001'),
      name: 'Battery Artwork',
      scope: IconScope.battery,
    );
    final generalCategory = await repository.createCategory(
      id: _id('10000000-0000-4000-8000-000000000002'),
      name: 'Police Equipment',
      scope: IconScope.general,
    );
    await repository.createCustomIcon(
      id: _id('20000000-0000-4000-8000-000000000001'),
      name: 'AA Department Mark',
      categoryId: batteryCategory.id,
      relativePath: ManagedRelativePath.parse(
        'custom_icons/20000000-0000-4000-8000-000000000001/source.svg',
      ),
      fileType: IconFileType.svg,
      supportsColor: true,
    );
    final shared = await repository.createCustomIcon(
      id: _id('20000000-0000-4000-8000-000000000002'),
      name: 'Police Radio Crest',
      categoryId: generalCategory.id,
      relativePath: ManagedRelativePath.parse(
        'custom_icons/20000000-0000-4000-8000-000000000002/source.svg',
      ),
      fileType: IconFileType.svg,
      supportsColor: true,
    );
    const batteryId = '30000000-0000-4000-8000-000000000001';
    await database.into(database.batteries).insert(
          BatteriesCompanion.insert(
            uuid: batteryId,
            userBatteryId: 'AA-001',
          ),
        );
    await repository.saveOwnerSelection(
      owner: IconOwnerReference(
        type: IconOwnerType.battery,
        id: _id(batteryId),
      ),
      selection: IconSelection(
        source: IconSource.custom,
        key: shared.id.value,
        color: IconColor.red,
      ),
    );
    container = ProviderContainer(
      overrides: [iconRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test('filters the mixed catalog by query, source, category, and scope',
      () async {
    final initial = await container.read(iconCatalogProvider.future);
    expect(initial.scope, IconScope.battery);
    expect(initial.definitions.map((icon) => icon.key),
        contains('battery_generic'));
    expect(initial.definitions.map((icon) => icon.key),
        contains('20000000-0000-4000-8000-000000000001'));
    expect(initial.definitions.map((icon) => icon.key),
        contains('20000000-0000-4000-8000-000000000002'));

    container.read(iconCatalogProvider.notifier).setQuery('police radio');
    expect(
      container
          .read(iconCatalogProvider)
          .requireValue
          .definitions
          .map((icon) => icon.displayName),
      ['Police Radio Crest'],
    );

    container.read(iconCatalogProvider.notifier)
      ..setQuery('')
      ..setSourceFilter(IconCatalogSource.custom)
      ..setCategory('Battery Artwork');
    expect(
      container
          .read(iconCatalogProvider)
          .requireValue
          .definitions
          .map((icon) => icon.displayName),
      ['AA Department Mark'],
    );

    await container
        .read(iconCatalogProvider.notifier)
        .setScope(IconScope.device);
    final device = container.read(iconCatalogProvider).requireValue;
    expect(device.definitions.map((icon) => icon.displayName),
        isNot(contains('AA Department Mark')));
  });

  test('recent filter preserves persisted most-recent order and color',
      () async {
    await container.read(iconCatalogProvider.future);

    container
        .read(iconCatalogProvider.notifier)
        .setSourceFilter(IconCatalogSource.recent);
    final recent = container.read(iconCatalogProvider).requireValue;

    expect(recent.definitions, hasLength(1));
    expect(recent.definitions.single.displayName, 'Police Radio Crest');
    expect(recent.recentSelections.single.color, IconColor.red);
  });

  test('refresh exposes custom icons added after initial load', () async {
    await container.read(iconCatalogProvider.future);
    final category = (await repository.listCategories()).first;
    await repository.createCustomIcon(
      id: _id('20000000-0000-4000-8000-000000000003'),
      name: 'Fresh Custom Icon',
      categoryId: category.id,
      relativePath: ManagedRelativePath.parse(
        'custom_icons/20000000-0000-4000-8000-000000000003/source.svg',
      ),
      fileType: IconFileType.svg,
      supportsColor: false,
    );

    await container.read(iconCatalogProvider.notifier).refresh();

    expect(
      container
          .read(iconCatalogProvider)
          .requireValue
          .definitions
          .map((icon) => icon.displayName),
      contains('Fresh Custom Icon'),
    );
  });
}

PermanentId _id(String value) => PermanentId.parse(value);

final class _Ids implements PermanentIdGenerator {
  var _value = 1;

  @override
  PermanentId next() {
    final tail = _value.toString().padLeft(12, '0');
    _value++;
    return PermanentId.parse('90000000-0000-4000-8000-$tail');
  }
}
