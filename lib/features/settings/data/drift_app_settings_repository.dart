import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/app_settings_repository.dart';
import '../domain/theme_preference.dart';

final class DriftAppSettingsRepository implements AppSettingsRepository {
  DriftAppSettingsRepository(this._database);

  static const _themePreferenceKey = 'appearance.theme_mode';

  final AppDatabase _database;

  @override
  Future<ThemePreference> loadThemePreference() async {
    final row = await (_database.select(_database.settings)
          ..where((table) => table.key.equals(_themePreferenceKey)))
        .getSingleOrNull();
    return ThemePreference.fromStorage(row?.value);
  }

  @override
  Future<void> saveThemePreference(ThemePreference preference) async {
    await _database.into(_database.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: _themePreferenceKey,
            value: preference.storageValue,
            valueType: 'string',
            modifiedAt: Value(DateTime.now().toUtc()),
          ),
        );
  }
}
