import 'dart:io';

import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/database/drift_database_service.dart';
import 'package:battery_tracker/features/settings/data/drift_app_settings_repository.dart';
import 'package:battery_tracker/features/settings/domain/theme_preference.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temporaryRoot;
  late File databaseFile;

  setUp(() async {
    temporaryRoot = await Directory.systemTemp.createTemp(
      'battery-tracker-settings-test-',
    );
    databaseFile = File.fromUri(
      temporaryRoot.uri.resolve('battery_tracker.sqlite'),
    );
  });

  tearDown(() async {
    if (temporaryRoot.existsSync()) {
      await temporaryRoot.delete(recursive: true);
    }
  });

  test('defaults to the system theme when no appearance setting exists',
      () async {
    final database = AppDatabase.forTesting(NativeDatabase(databaseFile));
    final service = DriftDatabaseService(database);
    await service.initialize();
    final repository = DriftAppSettingsRepository(database);

    expect(await repository.loadThemePreference(), ThemePreference.system);

    await service.close();
  });

  test('theme choice survives closing and reopening the database', () async {
    final firstDatabase = AppDatabase.forTesting(NativeDatabase(databaseFile));
    final firstService = DriftDatabaseService(firstDatabase);
    await firstService.initialize();
    final firstRepository = DriftAppSettingsRepository(firstDatabase);

    await firstRepository.saveThemePreference(ThemePreference.dark);
    await firstService.close();

    final reopenedDatabase = AppDatabase.forTesting(
      NativeDatabase(databaseFile),
    );
    final reopenedService = DriftDatabaseService(reopenedDatabase);
    await reopenedService.initialize();
    final reopenedRepository = DriftAppSettingsRepository(reopenedDatabase);

    expect(
      await reopenedRepository.loadThemePreference(),
      ThemePreference.dark,
    );

    await reopenedService.close();
  });
}
