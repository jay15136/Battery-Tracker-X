import 'dart:io';

import 'package:drift/drift.dart';

import '../core/configuration/app_configuration.dart';
import '../core/database/app_database.dart';
import '../core/database/app_database_factory.dart';
import '../core/database/drift_database_service.dart';
import '../core/identity/permanent_id.dart';
import '../core/logging/app_log_service.dart';
import '../core/storage/managed_relative_path.dart';
import '../features/icons/application/icon_library_service.dart';
import '../features/icons/data/built_in_icon_registry.dart';
import '../features/icons/data/drift_icon_repository.dart';
import '../features/icons/data/local_custom_icon_storage.dart';
import '../features/icons/domain/icon_registry.dart';
import '../features/icons/domain/icon_repository.dart';
import '../features/settings/data/drift_app_settings_repository.dart';
import '../services/app_data_directory_service.dart';
import '../services/file_selection_service.dart';
import '../services/file_selector_file_selection_service.dart';

typedef DatabaseExecutorFactory = Future<QueryExecutor> Function({
  required Uri applicationSupportRoot,
  required AppConfiguration configuration,
});

abstract final class AppBootstrap {
  static Future<AppDependencies> start({
    required AppConfiguration configuration,
    required AppDataDirectoryService appDataDirectoryService,
    DatabaseExecutorFactory databaseExecutorFactory =
        createProductionDatabaseExecutor,
  }) async {
    configuration.validate();
    final configuredRoot =
        await appDataDirectoryService.getApplicationSupportRoot();
    final rootDirectory = Directory.fromUri(configuredRoot);
    await rootDirectory.create(recursive: true);
    final applicationSupportRoot = rootDirectory.uri;

    final logService = LocalFileLogService(
      applicationSupportRoot: applicationSupportRoot,
      logDirectory: ManagedRelativePath.parse(
        configuration.logDirectoryRelativePath,
      ),
      maxFileBytes: configuration.maxLogFileBytes,
      retainedFileCount: configuration.retainedLogFileCount,
    );
    await logService.initialize();

    AppDatabase? database;
    try {
      final executor = await databaseExecutorFactory(
        applicationSupportRoot: applicationSupportRoot,
        configuration: configuration,
      );
      database = AppDatabase(executor);
      final databaseService = DriftDatabaseService(database);
      await databaseService.initialize();
      final settingsRepository = DriftAppSettingsRepository(database);
      const idGenerator = UuidV4PermanentIdGenerator();
      final iconRepository = DriftIconRepository(
        database: database,
        idGenerator: idGenerator,
        builtInRegistry: IconRegistry(
          builtIns: BuiltInIconRegistry.definitions,
        ),
      );
      final iconLibraryService = IconLibraryService(
        repository: iconRepository,
        storage: LocalCustomIconStorage(
          applicationSupportRoot: applicationSupportRoot,
        ),
        idGenerator: idGenerator,
        logger: logService.logger('icons'),
      );
      await iconLibraryService.ensureDefaultCategories();

      logService.logger('bootstrap').info('Battery Tracker initialized.');
      return AppDependencies(
        configuration: configuration,
        applicationSupportRoot: applicationSupportRoot,
        databaseService: databaseService,
        logService: logService,
        settingsRepository: settingsRepository,
        iconRepository: iconRepository,
        iconLibraryService: iconLibraryService,
        fileSelectionService: const FileSelectorFileSelectionService(),
      );
    } on Object catch (error, stackTrace) {
      logService.logger('bootstrap').severe(
            'Battery Tracker initialization failed.',
            error,
            stackTrace,
          );
      if (database != null) {
        await database.close();
      }
      await logService.close();
      rethrow;
    }
  }
}

final class AppDependencies {
  AppDependencies({
    required this.configuration,
    required this.applicationSupportRoot,
    required this.databaseService,
    required this.logService,
    required this.settingsRepository,
    required this.iconRepository,
    required this.iconLibraryService,
    required this.fileSelectionService,
  });

  final AppConfiguration configuration;
  final Uri applicationSupportRoot;
  final DriftDatabaseService databaseService;
  final LocalFileLogService logService;
  final DriftAppSettingsRepository settingsRepository;
  final IconRepository iconRepository;
  final IconLibraryService iconLibraryService;
  final FileSelectionService fileSelectionService;
  bool _closed = false;

  Future<void> close() async {
    if (_closed) {
      return;
    }
    _closed = true;
    logService.logger('bootstrap').info('Battery Tracker is closing.');
    await databaseService.close();
    await logService.close();
  }
}
