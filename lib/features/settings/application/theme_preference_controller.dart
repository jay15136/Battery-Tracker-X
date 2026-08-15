import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../domain/theme_preference.dart';

final themePreferenceProvider =
    AsyncNotifierProvider<ThemePreferenceController, ThemePreference>(
  ThemePreferenceController.new,
);

final class ThemePreferenceController extends AsyncNotifier<ThemePreference> {
  @override
  Future<ThemePreference> build() {
    return ref.watch(appSettingsRepositoryProvider).loadThemePreference();
  }

  Future<void> setPreference(ThemePreference preference) async {
    await ref
        .read(appSettingsRepositoryProvider)
        .saveThemePreference(preference);
    state = AsyncData(preference);
  }
}
