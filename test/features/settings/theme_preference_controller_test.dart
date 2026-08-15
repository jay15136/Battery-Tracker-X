import 'package:battery_tracker/app/app_providers.dart';
import 'package:battery_tracker/features/settings/application/theme_preference_controller.dart';
import 'package:battery_tracker/features/settings/domain/app_settings_repository.dart';
import 'package:battery_tracker/features/settings/domain/theme_preference.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads the persisted theme preference at startup', () async {
    final repository = _MemorySettingsRepository(ThemePreference.light);
    final container = ProviderContainer(
      overrides: [
        appSettingsRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    expect(
      await container.read(themePreferenceProvider.future),
      ThemePreference.light,
    );
  });

  test('persists a theme change before exposing the new preference', () async {
    final repository = _MemorySettingsRepository(ThemePreference.system);
    final container = ProviderContainer(
      overrides: [
        appSettingsRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(themePreferenceProvider.future);

    await container
        .read(themePreferenceProvider.notifier)
        .setPreference(ThemePreference.dark);

    expect(repository.savedPreferences, [ThemePreference.dark]);
    expect(
      container.read(themePreferenceProvider).requireValue,
      ThemePreference.dark,
    );
  });
}

final class _MemorySettingsRepository implements AppSettingsRepository {
  _MemorySettingsRepository(this.preference);

  ThemePreference preference;
  final List<ThemePreference> savedPreferences = [];

  @override
  Future<ThemePreference> loadThemePreference() async => preference;

  @override
  Future<void> saveThemePreference(ThemePreference preference) async {
    savedPreferences.add(preference);
    this.preference = preference;
  }
}
