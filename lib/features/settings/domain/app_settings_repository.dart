import 'theme_preference.dart';

abstract interface class AppSettingsRepository {
  Future<ThemePreference> loadThemePreference();

  Future<void> saveThemePreference(ThemePreference preference);
}
