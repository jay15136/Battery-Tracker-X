import 'dart:io';

import 'package:battery_tracker/app/app_providers.dart';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/core/logging/app_log_service.dart';
import 'package:battery_tracker/core/storage/managed_relative_path.dart';
import 'package:battery_tracker/features/icons/application/icon_library_service.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/domain/custom_icon_storage.dart';
import 'package:battery_tracker/features/icons/domain/icon_color.dart';
import 'package:battery_tracker/features/icons/domain/icon_definition.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_repository.dart';
import 'package:battery_tracker/features/icons/domain/icon_selection.dart';
import 'package:battery_tracker/features/icons/presentation/icon_library_page.dart';
import 'package:battery_tracker/features/settings/domain/app_settings_repository.dart';
import 'package:battery_tracker/features/settings/domain/theme_preference.dart';
import 'package:battery_tracker/features/settings/presentation/settings_page.dart';
import 'package:battery_tracker/services/file_selection_service.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

void main() {
  late Directory root;
  late Directory sources;
  late AppDatabase database;
  late DriftIconRepository repository;
  late CustomIconStorage storage;
  late IconLibraryService library;
  late _FileSelection fileSelection;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('battery-tracker-library-ui-');
    sources = await Directory.systemTemp.createTemp(
      'battery-tracker-library-sources-',
    );
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.customSelect('SELECT 1').getSingle();
    final ids = _Ids();
    repository = DriftIconRepository(
      database: database,
      idGenerator: ids,
      builtInRegistry: IconRegistry(
        builtIns: BuiltInIconRegistry.definitions,
      ),
    );
    storage = _Storage();
    library = IconLibraryService(
      repository: repository,
      storage: storage,
      idGenerator: ids,
    );
    await library.ensureDefaultCategories();
    fileSelection = _FileSelection();
  });

  tearDown(() async {
    await database.close();
    await root.delete(recursive: true);
    await sources.delete(recursive: true);
  });

  Future<void> pumpSettings(
    WidgetTester tester, {
    Size surfaceSize = const Size(1280, 800),
  }) async {
    await tester.binding.setSurfaceSize(surfaceSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsRepositoryProvider.overrideWithValue(_Settings()),
          applicationSupportRootProvider.overrideWithValue(root.uri),
          iconRepositoryProvider.overrideWithValue(repository),
          iconLibraryServiceProvider.overrideWithValue(library),
          fileSelectionServiceProvider.overrideWithValue(fileSelection),
          appLogServiceProvider.overrideWithValue(_LogService()),
        ],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpLibrary(
    WidgetTester tester, {
    required Size surfaceSize,
  }) async {
    await tester.binding.setSurfaceSize(surfaceSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          applicationSupportRootProvider.overrideWithValue(root.uri),
          iconRepositoryProvider.overrideWithValue(repository),
          iconLibraryServiceProvider.overrideWithValue(library),
          fileSelectionServiceProvider.overrideWithValue(fileSelection),
          appLogServiceProvider.overrideWithValue(_LogService()),
        ],
        child: const MaterialApp(home: IconLibraryPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  File svg(String name, int width) {
    final file = File('${sources.path}${Platform.pathSeparator}$name');
    file.writeAsStringSync(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">'
      '<path d="M8 8h${width}v24H8z" fill="#000000"/></svg>',
    );
    return file;
  }

  Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
    for (var attempt = 0; attempt < 50; attempt++) {
      await tester.pump(const Duration(milliseconds: 20));
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    fail('Timed out waiting for an expected icon-library widget.');
  }

  Finder libraryIconNamed(String name) => find.descendant(
        of: find.byType(GridView),
        matching: find.text(name),
      );

  testWidgets('Settings opens the searchable packaged Icon Library',
      (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Icon Library'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('icon-library-page')), findsOneWidget);
    expect(find.text('54 packaged icons'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('icon-library-search')),
      'Portable Radio',
    );
    await tester.pump();
    expect(find.text('Portable Radio'), findsOneWidget);
  });

  testWidgets('Icon Library remains usable in a narrow window', (tester) async {
    await pumpLibrary(tester, surfaceSize: const Size(640, 900));

    expect(tester.takeException(), isNull);
    expect(
      find.widgetWithText(FilledButton, 'Import Custom Icon'),
      findsOneWidget,
    );
  });

  testWidgets('imports, edits, replaces, duplicates, and deletes a custom icon',
      (tester) async {
    final first = svg('first.svg', 20);
    final replacement = svg('replacement.svg', 42);
    fileSelection.openFiles.addAll([first.uri, replacement.uri]);
    await pumpSettings(tester);
    await tester.tap(find.text('Icon Library'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Import Custom Icon'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('custom-icon-name-field')),
      'Radio Crest',
    );
    await tester.tap(find.byKey(const ValueKey('custom-icon-supports-color')));
    await tester.tap(find.widgetWithText(FilledButton, 'Save Icon'));
    await pumpUntilFound(tester, libraryIconNamed('Radio Crest'));

    expect(libraryIconNamed('Radio Crest'), findsOneWidget);
    await tester.tap(libraryIconNamed('Radio Crest'));
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Edit Details'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('custom-icon-name-field')),
      'Portable Radio Crest',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save Icon'));
    await pumpUntilFound(tester, libraryIconNamed('Portable Radio Crest'));
    expect(libraryIconNamed('Portable Radio Crest'), findsOneWidget);

    await tester.tap(libraryIconNamed('Portable Radio Crest'));
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Replace Source'));
    await tester.pumpAndSettle();
    final original = (await repository.listCustomIcons())
        .singleWhere((icon) => icon.name == 'Portable Radio Crest');
    expect(original.relativePath.value, contains('source-'));
    expect(await storage.exists(original.relativePath), isTrue);

    await tester.tap(libraryIconNamed('Portable Radio Crest'));
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Duplicate'));
    await pumpUntilFound(tester, libraryIconNamed('Portable Radio Crest Copy'));
    expect(libraryIconNamed('Portable Radio Crest Copy'), findsOneWidget);

    await tester.tap(libraryIconNamed('Portable Radio Crest'));
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete Icon'));
    await tester.pumpAndSettle();

    expect(
      (await repository.listCustomIcons())
          .where((icon) => icon.name == 'Portable Radio Crest'),
      isEmpty,
    );
    expect(libraryIconNamed('Portable Radio Crest Copy'), findsOneWidget);
  });

  testWidgets('creates a user category during custom icon import',
      (tester) async {
    final source = svg('category.svg', 28);
    fileSelection.openFiles.add(source.uri);
    await pumpSettings(tester);
    await tester.tap(find.text('Icon Library'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Import Custom Icon'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New Category'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('category-name-field')),
      'Police Equipment',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create Category'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('custom-icon-name-field')),
      'Police Mark',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save Icon'));
    await tester.pumpAndSettle();

    final icon = (await repository.listCustomIcons()).single;
    expect(icon.category.name, 'Police Equipment');
    expect(icon.category.scope, IconScope.battery);
  });

  testWidgets('warns with usage count and replaces defaults before deletion',
      (tester) async {
    final source = svg('used.svg', 32);
    final category = (await repository.listCategories())
        .firstWhere((category) => category.scope == IconScope.battery);
    final icon = await library.importCustomIcon(
      source: source.uri,
      name: 'In-Use Battery Mark',
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
        id: PermanentId.parse(batteryId),
      ),
      selection: IconSelection(
        source: IconSource.custom,
        key: icon.id.value,
        color: IconColor.blue,
      ),
    );
    await pumpSettings(tester);
    await tester.tap(find.text('Icon Library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom'));
    await tester.pump();
    await tester.tap(libraryIconNamed('In-Use Battery Mark'));
    await tester.pump();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(
        find.text('This icon is currently used by 1 record.'), findsOneWidget);
    await tester.tap(
      find.widgetWithText(FilledButton, 'Replace With Defaults and Delete'),
    );
    await tester.pumpAndSettle();

    expect(
      (await database.select(database.batteries).getSingle()).iconKey,
      'battery_generic',
    );
    expect(await storage.exists(icon.relativePath), isFalse);
  });
}

final class _FileSelection implements FileSelectionService {
  final List<Uri> openFiles = [];

  @override
  Future<Uri?> chooseOpenFile(
      {required List<FileTypeFilter> acceptedTypes}) async {
    return openFiles.isEmpty ? null : openFiles.removeAt(0);
  }

  @override
  Future<Uri?> chooseSaveLocation({required String suggestedFileName}) async {
    return null;
  }
}

final class _Storage implements CustomIconStorage {
  final Set<ManagedRelativePath> _files = {};

  @override
  Future<ManagedRelativePath> copyManaged({
    required ManagedRelativePath source,
    required PermanentId ownerId,
    required PermanentId revisionId,
  }) {
    return _copy(ownerId, revisionId);
  }

  @override
  Future<ManagedRelativePath> copySource({
    required Uri source,
    required PermanentId ownerId,
    required PermanentId revisionId,
  }) {
    return _copy(ownerId, revisionId);
  }

  @override
  Future<void> delete(ManagedRelativePath reference) {
    _files.remove(reference);
    return Future.value();
  }

  @override
  Future<bool> exists(ManagedRelativePath reference) =>
      Future.value(_files.contains(reference));

  @override
  Future<CustomIconInspection> inspect(Uri source) => Future.value(
        const CustomIconInspection(fileType: IconFileType.svg, byteSize: 128),
      );

  Future<ManagedRelativePath> _copy(
    PermanentId ownerId,
    PermanentId revisionId,
  ) {
    final reference = ManagedRelativePath.fromSegments([
      'custom_icons',
      ownerId.value,
      'source-${revisionId.value}.svg',
    ]);
    _files.add(reference);
    return Future.value(reference);
  }
}

final class _Settings implements AppSettingsRepository {
  @override
  Future<ThemePreference> loadThemePreference() async => ThemePreference.system;

  @override
  Future<void> saveThemePreference(ThemePreference preference) async {}
}

final class _LogService implements AppLogService {
  @override
  Future<void> close() async {}

  @override
  Future<void> initialize() async {}

  @override
  Logger logger(String scope) => Logger('test.$scope');
}

final class _Ids implements PermanentIdGenerator {
  var _value = 1;

  @override
  PermanentId next() {
    final tail = _value.toString().padLeft(12, '0');
    _value++;
    return PermanentId.parse('90000000-0000-4000-8000-$tail');
  }
}
