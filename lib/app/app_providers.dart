import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/configuration/app_configuration.dart';
import '../core/database/database_service.dart';
import '../core/logging/app_log_service.dart';
import '../features/icons/application/icon_library_service.dart';
import '../features/icons/domain/icon_repository.dart';
import '../features/battery_types/domain/battery_type_repository.dart';
import '../features/settings/domain/app_settings_repository.dart';
import '../services/file_selection_service.dart';

final appConfigurationProvider = Provider<AppConfiguration>(
  (ref) => AppConfiguration.production,
);

final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => throw StateError('DatabaseService was not configured at startup.'),
);

final appLogServiceProvider = Provider<AppLogService>(
  (ref) => throw StateError('AppLogService was not configured at startup.'),
);

final appSettingsRepositoryProvider = Provider<AppSettingsRepository>(
  (ref) =>
      throw StateError('AppSettingsRepository was not configured at startup.'),
);

final applicationSupportRootProvider = Provider<Uri>(
  (ref) => throw StateError(
    'Application support storage was not configured at startup.',
  ),
);

final iconRepositoryProvider = Provider<IconRepository>(
  (ref) => throw StateError('IconRepository was not configured at startup.'),
);

final batteryTypeRepositoryProvider = Provider<BatteryTypeRepository>(
  (ref) =>
      throw StateError('BatteryTypeRepository was not configured at startup.'),
);

final iconLibraryServiceProvider = Provider<IconLibraryService>(
  (ref) => throw StateError(
    'IconLibraryService was not configured at startup.',
  ),
);

final fileSelectionServiceProvider = Provider<FileSelectionService>(
  (ref) => throw StateError(
    'FileSelectionService was not configured at startup.',
  ),
);
