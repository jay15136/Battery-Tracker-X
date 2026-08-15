import 'package:battery_tracker/app/app_providers.dart';
import 'package:battery_tracker/app/battery_tracker_app.dart';
import 'package:battery_tracker/features/settings/domain/app_settings_repository.dart';
import 'package:battery_tracker/features/settings/domain/theme_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('application shell renders all primary destinations',
      (tester) async {
    await _useDesktopSurface(tester);
    final repository = _MemorySettingsRepository();

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Battery Tracker'), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Batteries'), findsOneWidget);
    expect(find.text('Battery Sets'), findsOneWidget);
    expect(find.text('Devices'), findsOneWidget);
    expect(find.text('Assignments'), findsOneWidget);
    expect(find.text('Battery Types'), findsOneWidget);
    expect(find.text('QR Labels'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('navigation rail changes the selected destination content',
      (tester) async {
    await _useDesktopSurface(tester);
    await tester.pumpWidget(_testApp(_MemorySettingsRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('destination-batteries')));
    await tester.pumpAndSettle();

    final title = tester.widget<Text>(
      find.byKey(const ValueKey('page-title')),
    );
    expect(title.data, 'Batteries');
    expect(find.byKey(const ValueKey('empty-state-panel')), findsOneWidget);
    expect(find.text('No batteries have been added yet.'), findsOneWidget);
  });

  testWidgets('appearance control persists and applies Dark mode',
      (tester) async {
    await _useDesktopSurface(tester);
    final repository = _MemorySettingsRepository();
    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('destination-settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(repository.savedPreferences, [ThemePreference.dark]);
  });
}

Future<void> _useDesktopSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1280, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _testApp(_MemorySettingsRepository repository) {
  return ProviderScope(
    overrides: [
      appSettingsRepositoryProvider.overrideWithValue(repository),
    ],
    child: const BatteryTrackerApp(),
  );
}

final class _MemorySettingsRepository implements AppSettingsRepository {
  ThemePreference preference = ThemePreference.system;
  final List<ThemePreference> savedPreferences = [];

  @override
  Future<ThemePreference> loadThemePreference() async => preference;

  @override
  Future<void> saveThemePreference(ThemePreference preference) async {
    savedPreferences.add(preference);
    this.preference = preference;
  }
}
