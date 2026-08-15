enum ThemePreference {
  system,
  light,
  dark;

  String get storageValue => name;

  static ThemePreference fromStorage(String? value) {
    return switch (value) {
      'light' => ThemePreference.light,
      'dark' => ThemePreference.dark,
      _ => ThemePreference.system,
    };
  }
}
