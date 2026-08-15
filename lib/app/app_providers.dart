import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/configuration/app_configuration.dart';
import '../core/database/database_service.dart';
import '../core/logging/app_log_service.dart';
import '../features/settings/domain/app_settings_repository.dart';

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
