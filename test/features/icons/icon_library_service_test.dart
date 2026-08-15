import 'dart:io';

import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/core/storage/managed_relative_path.dart';
import 'package:battery_tracker/features/icons/application/icon_library_service.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/data/local_custom_icon_storage.dart';
import 'package:battery_tracker/features/icons/domain/icon_color.dart';
import 'package:battery_tracker/features/icons/domain/icon_definition.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_repository.dart';
import 'package:battery_tracker/features/icons/domain/icon_selection.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;
  late Directory sources;
  late AppDatabase database;
  late DriftIconRepository repository;
  late LocalCustomIconStorage storage;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('battery-tracker-library-');
    sources = await Directory.systemTemp.createTemp('battery-tracker-source-');
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.customSelect('SELECT 1').getSingle();
    repository = DriftIconRepository(
      database: database,
      idGenerator: _IncrementingIdGenerator(80000000),
      builtInRegistry: IconRegistry(
        builtIns: BuiltInIconRegistry.definitions,
      ),
      clock: () => DateTime.utc(2026, 8, 15, 12),
    );
    storage = LocalCustomIconStorage(applicationSupportRoot: root.uri);
  });

  tearDown(() async {
    await database.close();
    await root.delete(recursive: true);
    await sources.delete(recursive: true);
  });

  test('seeds the four standard custom categories idempotently', () async {
    final service = _service(
      repository,
      storage,
      _IncrementingIdGenerator(70000000),
    );

    await service.ensureDefaultCategories();
    await service.ensureDefaultCategories();

    final categories = await repository.listCategories();
    expect(categories, hasLength(4));
    expect(
      categories
          .map((category) => '${category.scope.storageValue}:${category.name}'),
      containsAll([
        'battery:Batteries',
        'battery_set:Battery Sets',
        'device:Devices',
        'general:General',
      ]),
    );
  });

  test('imports metadata and a managed copy, then survives source removal',
      () async {
    final category = await _category(repository);
    final source = await _svgSource(sources, 'radio.svg', 24);
    final service = _service(
      repository,
      storage,
      _QueuedIdGenerator([
        _id('20000000-0000-4000-8000-000000000001'),
        _id('21000000-0000-4000-8000-000000000001'),
      ]),
    );

    final icon = await service.importCustomIcon(
      source: source.uri,
      name: 'Radio Crest',
      categoryId: category.id,
      supportsColor: true,
    );
    await source.delete();

    expect(icon.id.value, '20000000-0000-4000-8000-000000000001');
    expect(icon.name, 'Radio Crest');
    expect(icon.fileType, IconFileType.svg);
    expect(await storage.exists(icon.relativePath), isTrue);
    expect((await repository.listCustomIcons()).single.id, icon.id);
  });

  test('removes a staged file when database insertion fails', () async {
    final category = await _category(repository);
    final duplicateId = _id('20000000-0000-4000-8000-000000000002');
    await repository.createCustomIcon(
      id: duplicateId,
      name: 'Existing',
      categoryId: category.id,
      relativePath: ManagedRelativePath.parse(
        'custom_icons/${duplicateId.value}/existing.svg',
      ),
      fileType: IconFileType.svg,
      supportsColor: true,
    );
    final revision = _id('21000000-0000-4000-8000-000000000002');
    final source = await _svgSource(sources, 'duplicate.svg', 28);
    final service = _service(
      repository,
      storage,
      _QueuedIdGenerator([duplicateId, revision]),
    );

    await expectLater(
      service.importCustomIcon(
        source: source.uri,
        name: 'Duplicate UUID',
        categoryId: category.id,
        supportsColor: true,
      ),
      throwsA(isA<Exception>()),
    );

    final staged = ManagedRelativePath.parse(
      'custom_icons/${duplicateId.value}/source-${revision.value}.svg',
    );
    expect(await storage.exists(staged), isFalse);
  });

  test('replaces source without changing the permanent icon UUID', () async {
    final category = await _category(repository);
    final firstSource = await _svgSource(sources, 'first.svg', 20);
    final secondSource = await _svgSource(sources, 'second.svg', 40);
    final service = _service(
      repository,
      storage,
      _QueuedIdGenerator([
        _id('20000000-0000-4000-8000-000000000003'),
        _id('21000000-0000-4000-8000-000000000003'),
        _id('21000000-0000-4000-8000-000000000004'),
      ]),
    );
    final original = await service.importCustomIcon(
      source: firstSource.uri,
      name: 'Replace Me',
      categoryId: category.id,
      supportsColor: true,
    );

    final updated = await service.replaceSource(
      id: original.id,
      source: secondSource.uri,
    );

    expect(updated.id, original.id);
    expect(updated.relativePath, isNot(original.relativePath));
    expect(await storage.exists(original.relativePath), isFalse);
    expect(await storage.exists(updated.relativePath), isTrue);
  });

  test('duplicates metadata and managed source with a new permanent UUID',
      () async {
    final category = await _category(repository);
    final source = await _svgSource(sources, 'original.svg', 24);
    final service = _service(
      repository,
      storage,
      _QueuedIdGenerator([
        _id('20000000-0000-4000-8000-000000000004'),
        _id('21000000-0000-4000-8000-000000000005'),
        _id('20000000-0000-4000-8000-000000000005'),
        _id('21000000-0000-4000-8000-000000000006'),
      ]),
    );
    final original = await service.importCustomIcon(
      source: source.uri,
      name: 'Original',
      categoryId: category.id,
      supportsColor: false,
    );

    final duplicate = await service.duplicate(original.id);

    expect(duplicate.id, isNot(original.id));
    expect(duplicate.name, 'Original Copy');
    expect(duplicate.category.id, original.category.id);
    expect(duplicate.supportsColor, isFalse);
    expect(await storage.exists(duplicate.relativePath), isTrue);
  });

  test('keeps an in-use file until transactional default replacement succeeds',
      () async {
    final category = await _category(repository);
    final source = await _svgSource(sources, 'used.svg', 24);
    final service = _service(
      repository,
      storage,
      _QueuedIdGenerator([
        _id('20000000-0000-4000-8000-000000000006'),
        _id('21000000-0000-4000-8000-000000000007'),
      ]),
    );
    final icon = await service.importCustomIcon(
      source: source.uri,
      name: 'In Use',
      categoryId: category.id,
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
        key: icon.id.value,
        color: IconColor.red,
      ),
    );

    await expectLater(
      service.delete(icon.id),
      throwsA(isA<IconInUseException>()),
    );
    expect(await storage.exists(icon.relativePath), isTrue);

    await service.delete(icon.id, replaceWithDefaults: true);

    expect(await storage.exists(icon.relativePath), isFalse);
    expect(
      (await database.select(database.batteries).getSingle()).iconKey,
      'battery_generic',
    );
  });
}

IconLibraryService _service(
  IconRepository repository,
  LocalCustomIconStorage storage,
  PermanentIdGenerator generator,
) {
  return IconLibraryService(
    repository: repository,
    storage: storage,
    idGenerator: generator,
  );
}

Future<IconCategoryRecord> _category(IconRepository repository) {
  return repository.createCategory(
    id: _id('10000000-0000-4000-8000-000000000001'),
    name: 'General',
    scope: IconScope.general,
  );
}

Future<File> _svgSource(Directory directory, String name, int width) async {
  final file = File('${directory.path}${Platform.pathSeparator}$name');
  await file.writeAsString(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">'
    '<path d="M8 8h${width}v24H8z" fill="#000000"/></svg>',
  );
  return file;
}

PermanentId _id(String value) => PermanentId.parse(value);

final class _QueuedIdGenerator implements PermanentIdGenerator {
  _QueuedIdGenerator(this.ids);

  final List<PermanentId> ids;
  var _index = 0;

  @override
  PermanentId next() => ids[_index++];
}

final class _IncrementingIdGenerator implements PermanentIdGenerator {
  _IncrementingIdGenerator(this.prefix);

  final int prefix;
  var _index = 1;

  @override
  PermanentId next() {
    final value = _index.toString().padLeft(12, '0');
    _index++;
    return PermanentId.parse('$prefix-0000-4000-8000-$value');
  }
}
