import 'dart:io';

import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/core/storage/managed_relative_path.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/domain/icon_color.dart';
import 'package:battery_tracker/features/icons/domain/icon_definition.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_repository.dart';
import 'package:battery_tracker/features/icons/domain/icon_selection.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftIconRepository repository;
  late _SequenceIdGenerator idGenerator;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.customSelect('SELECT 1').getSingle();
    idGenerator = _SequenceIdGenerator();
    repository = _repository(database, idGenerator);
  });

  tearDown(() => database.close());

  test('validates Battery Type icon scope through the public boundary',
      () async {
    await repository.validateSelection(
      scopes: const {IconScope.battery},
      selection: const IconSelection(
        source: IconSource.builtin,
        key: 'battery_aa',
        color: IconColor.green,
      ),
    );
    await expectLater(
      repository.validateSelection(
        scopes: const {IconScope.battery},
        selection: const IconSelection(
          source: IconSource.builtin,
          key: 'device_radio',
          color: IconColor.blue,
        ),
      ),
      throwsA(isA<InvalidIconSelectionException>()),
    );
  });

  test('propagates database failures while resolving a custom icon', () async {
    await database.customStatement('DROP TABLE custom_icons');

    await expectLater(
      repository.validateSelection(
        scopes: const {IconScope.battery},
        selection: IconSelection(
          source: IconSource.custom,
          key: _id('20000000-0000-4000-8000-000000000099').value,
          color: IconColor.blue,
        ),
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('custom category and icon metadata survive database restart', () async {
    await database.close();
    final directory = await Directory.systemTemp.createTemp(
      'battery-tracker-icon-repository-',
    );
    final file = File('${directory.path}${Platform.pathSeparator}icons.sqlite');
    addTearDown(() => directory.delete(recursive: true));

    var diskDatabase = AppDatabase.forTesting(NativeDatabase(file));
    var diskRepository = _repository(diskDatabase, _SequenceIdGenerator());
    final category = await diskRepository.createCategory(
      id: _id('10000000-0000-4000-8000-000000000001'),
      name: 'Police Equipment',
      scope: IconScope.device,
    );
    await diskRepository.createCustomIcon(
      id: _id('20000000-0000-4000-8000-000000000001'),
      name: 'Portable Radio Crest',
      categoryId: category.id,
      relativePath: ManagedRelativePath.parse(
        'custom_icons/20000000-0000-4000-8000-000000000001/source.svg',
      ),
      fileType: IconFileType.svg,
      supportsColor: true,
    );
    await diskDatabase.close();

    diskDatabase = AppDatabase.forTesting(NativeDatabase(file));
    diskRepository = _repository(diskDatabase, _SequenceIdGenerator());
    final icons = await diskRepository.listCustomIcons();

    expect(icons, hasLength(1));
    expect(icons.single.id.value, '20000000-0000-4000-8000-000000000001');
    expect(icons.single.name, 'Portable Radio Crest');
    expect(icons.single.category.name, 'Police Equipment');
    expect(icons.single.scope, IconScope.device);
    expect(icons.single.relativePath.value, endsWith('/source.svg'));
    expect(icons.single.supportsColor, isTrue);
    await diskDatabase.close();
  });

  test('renames categories and changes custom icon metadata', () async {
    final first = await _createCategory(
      repository,
      id: '10000000-0000-4000-8000-000000000002',
      name: 'Work',
      scope: IconScope.general,
    );
    final second = await _createCategory(
      repository,
      id: '10000000-0000-4000-8000-000000000003',
      name: 'Electronics',
      scope: IconScope.general,
    );
    final icon = await _createIcon(
      repository,
      id: '20000000-0000-4000-8000-000000000002',
      categoryId: first.id,
    );

    await repository.renameCategory(first.id, 'Police Equipment');
    await repository.updateCustomIconMetadata(
      id: icon.id,
      name: 'Updated Crest',
      categoryId: second.id,
      supportsColor: false,
    );

    final updated = await repository.getCustomIcon(icon.id);
    expect(updated.name, 'Updated Crest');
    expect(updated.category.id, second.id);
    expect(updated.supportsColor, isFalse);
    expect(
      (await repository.listCategories())
          .firstWhere((category) => category.id == first.id)
          .name,
      'Police Equipment',
    );
  });

  test('persists selections and colors for Battery, Set, and Device', () async {
    final category = await _createCategory(
      repository,
      id: '10000000-0000-4000-8000-000000000004',
      name: 'Shared',
      scope: IconScope.general,
    );
    final icon = await _createIcon(
      repository,
      id: '20000000-0000-4000-8000-000000000003',
      categoryId: category.id,
    );
    final owners = await _seedOwners(database);

    await repository.saveOwnerSelection(
      owner: owners.battery,
      selection: _customSelection(icon.id, IconColor.red),
    );
    await repository.saveOwnerSelection(
      owner: owners.batterySet,
      selection: _customSelection(icon.id, IconColor.green),
    );
    await repository.saveOwnerSelection(
      owner: owners.device,
      selection: _customSelection(icon.id, IconColor.blue),
    );

    final battery = await database.select(database.batteries).getSingle();
    final batterySet = await database.select(database.batterySets).getSingle();
    final device = await database.select(database.devices).getSingle();
    expect([battery.iconSource, batterySet.iconSource, device.iconSource],
        everyElement('custom'));
    expect([battery.iconKey, batterySet.iconKey, device.iconKey],
        everyElement(icon.id.value));
    expect(battery.iconColor, '#F44336');
    expect(batterySet.iconColor, '#43A047');
    expect(device.iconColor, '#2196F3');

    final usage = await repository.usageCount(icon.id);
    expect(usage.batteries, 1);
    expect(usage.batterySets, 1);
    expect(usage.devices, 1);
    expect(usage.total, 3);
    final activities = await database.select(database.activityLog).get();
    expect(
      activities.where(
        (activity) => activity.eventType == 'icon_selection_changed',
      ),
      hasLength(3),
    );
  });

  test('keeps a bounded most-recent-first list without duplicate keys',
      () async {
    final owner = (await _seedOwners(database)).battery;
    final batteryDefinitions = BuiltInIconRegistry.definitions
        .where((definition) => definition.scope == IconScope.battery)
        .take(13)
        .toList();

    for (final definition in batteryDefinitions) {
      await repository.saveOwnerSelection(
        owner: owner,
        selection: IconSelection(
          source: IconSource.builtin,
          key: definition.key,
          color: IconColor.blue,
        ),
      );
    }
    await repository.saveOwnerSelection(
      owner: owner,
      selection: IconSelection(
        source: IconSource.builtin,
        key: batteryDefinitions[5].key,
        color: IconColor.orange,
      ),
    );

    final recent = await repository.recentSelections(IconScope.battery);
    expect(recent, hasLength(12));
    expect(recent.first.key, batteryDefinitions[5].key);
    expect(recent.first.color, IconColor.orange);
    expect(
      recent.where((selection) => selection.key == batteryDefinitions[5].key),
      hasLength(1),
    );
  });

  test('refuses to deactivate an in-use custom icon without replacement',
      () async {
    final setup = await _seedUsedIcon(database, repository);

    await expectLater(
      repository.deactivateCustomIcon(id: setup.icon.id),
      throwsA(
        isA<IconInUseException>().having(
          (error) => error.usage.total,
          'usage total',
          3,
        ),
      ),
    );

    expect((await repository.getCustomIcon(setup.icon.id)).isActive, isTrue);
    expect(
      (await database.select(database.batteries).getSingle()).iconKey,
      setup.icon.id.value,
    );
  });

  test('transactionally replaces every reference before deactivation',
      () async {
    final setup = await _seedUsedIcon(database, repository);
    final replacement = await _createIcon(
      repository,
      id: '20000000-0000-4000-8000-000000000005',
      categoryId: setup.category.id,
    );

    final removedPath = await repository.deactivateCustomIcon(
      id: setup.icon.id,
      replacement: _customSelection(replacement.id, IconColor.purple),
    );

    expect(removedPath, setup.icon.relativePath);
    expect((await repository.getCustomIcon(setup.icon.id)).isActive, isFalse);
    expect(
      (await database.select(database.batteries).getSingle()).iconKey,
      replacement.id.value,
    );
    expect(
      (await database.select(database.batterySets).getSingle()).iconKey,
      replacement.id.value,
    );
    expect(
      (await database.select(database.devices).getSingle()).iconKey,
      replacement.id.value,
    );
    expect((await repository.usageCount(setup.icon.id)).total, 0);
    expect((await repository.usageCount(replacement.id)).total, 3);
  });

  test('rejects replacing references with the icon being deleted', () async {
    final setup = await _seedUsedIcon(database, repository);

    await expectLater(
      repository.deactivateCustomIcon(
        id: setup.icon.id,
        replacement: _customSelection(setup.icon.id, IconColor.blue),
      ),
      throwsA(isA<InvalidIconSelectionException>()),
    );

    expect((await repository.getCustomIcon(setup.icon.id)).isActive, isTrue);
    expect((await repository.usageCount(setup.icon.id)).total, 3);
  });

  test('uses per-owner defaults when explicitly requested', () async {
    final setup = await _seedUsedIcon(database, repository);

    await repository.deactivateCustomIcon(
      id: setup.icon.id,
      replaceWithDefaults: true,
    );

    expect(
      (await database.select(database.batteries).getSingle()).iconKey,
      'battery_generic',
    );
    expect(
      (await database.select(database.batterySets).getSingle()).iconKey,
      'battery_set_generic',
    );
    expect(
      (await database.select(database.devices).getSingle()).iconKey,
      'device_generic',
    );
  });

  test('rolls back replacements and deactivation after a database failure',
      () async {
    final setup = await _seedUsedIcon(database, repository);
    await database.customStatement(
      "CREATE TRIGGER reject_device_icon_update BEFORE UPDATE OF icon_key "
      "ON devices BEGIN SELECT RAISE(ABORT, 'simulated failure'); END",
    );

    await expectLater(
      repository.deactivateCustomIcon(
        id: setup.icon.id,
        replaceWithDefaults: true,
      ),
      throwsA(isA<Exception>()),
    );

    expect((await repository.getCustomIcon(setup.icon.id)).isActive, isTrue);
    expect(
      (await database.select(database.batteries).getSingle()).iconKey,
      setup.icon.id.value,
    );
    expect(
      (await database.select(database.devices).getSingle()).iconKey,
      setup.icon.id.value,
    );
  });

  test('deactivates an unused icon without requiring a replacement', () async {
    final category = await _createCategory(
      repository,
      id: '10000000-0000-4000-8000-000000000006',
      name: 'Unused',
      scope: IconScope.device,
    );
    final icon = await _createIcon(
      repository,
      id: '20000000-0000-4000-8000-000000000006',
      categoryId: category.id,
    );

    await repository.deactivateCustomIcon(id: icon.id);

    expect((await repository.getCustomIcon(icon.id)).isActive, isFalse);
  });
}

DriftIconRepository _repository(
  AppDatabase database,
  PermanentIdGenerator generator,
) {
  return DriftIconRepository(
    database: database,
    idGenerator: generator,
    builtInRegistry: IconRegistry(
      builtIns: BuiltInIconRegistry.definitions,
    ),
    clock: () => DateTime.utc(2026, 8, 15, 12),
  );
}

Future<IconCategoryRecord> _createCategory(
  IconRepository repository, {
  required String id,
  required String name,
  required IconScope scope,
}) {
  return repository.createCategory(
    id: _id(id),
    name: name,
    scope: scope,
  );
}

Future<CustomIconRecord> _createIcon(
  IconRepository repository, {
  required String id,
  required PermanentId categoryId,
}) {
  return repository.createCustomIcon(
    id: _id(id),
    name: 'Custom Icon $id',
    categoryId: categoryId,
    relativePath: ManagedRelativePath.parse('custom_icons/$id/source.svg'),
    fileType: IconFileType.svg,
    supportsColor: true,
  );
}

Future<_Owners> _seedOwners(AppDatabase database) async {
  const batteryId = '30000000-0000-4000-8000-000000000001';
  const setId = '30000000-0000-4000-8000-000000000002';
  const deviceId = '30000000-0000-4000-8000-000000000003';
  if (await database
      .select(database.batteries)
      .get()
      .then((rows) => rows.isEmpty)) {
    await database.into(database.batteries).insert(
          BatteriesCompanion.insert(uuid: batteryId, userBatteryId: 'AA-001'),
        );
    await database.into(database.batterySets).insert(
          BatterySetsCompanion.insert(
            uuid: setId,
            userSetId: 'SET-001',
            name: 'Radio Pair',
          ),
        );
    await database.into(database.devices).insert(
          DevicesCompanion.insert(uuid: deviceId, name: 'Portable Radio 1'),
        );
  }
  return _Owners(
    battery: IconOwnerReference(
      type: IconOwnerType.battery,
      id: _id(batteryId),
    ),
    batterySet: IconOwnerReference(
      type: IconOwnerType.batterySet,
      id: _id(setId),
    ),
    device: IconOwnerReference(
      type: IconOwnerType.device,
      id: _id(deviceId),
    ),
  );
}

Future<_UsedIconSetup> _seedUsedIcon(
  AppDatabase database,
  IconRepository repository,
) async {
  final category = await _createCategory(
    repository,
    id: '10000000-0000-4000-8000-000000000005',
    name: 'Shared Equipment',
    scope: IconScope.general,
  );
  final icon = await _createIcon(
    repository,
    id: '20000000-0000-4000-8000-000000000004',
    categoryId: category.id,
  );
  final owners = await _seedOwners(database);
  for (final owner in [owners.battery, owners.batterySet, owners.device]) {
    await repository.saveOwnerSelection(
      owner: owner,
      selection: _customSelection(icon.id, IconColor.red),
    );
  }
  return _UsedIconSetup(category: category, icon: icon);
}

IconSelection _customSelection(PermanentId id, IconColor color) {
  return IconSelection(source: IconSource.custom, key: id.value, color: color);
}

PermanentId _id(String value) => PermanentId.parse(value);

final class _Owners {
  const _Owners({
    required this.battery,
    required this.batterySet,
    required this.device,
  });

  final IconOwnerReference battery;
  final IconOwnerReference batterySet;
  final IconOwnerReference device;
}

final class _UsedIconSetup {
  const _UsedIconSetup({required this.category, required this.icon});

  final IconCategoryRecord category;
  final CustomIconRecord icon;
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
