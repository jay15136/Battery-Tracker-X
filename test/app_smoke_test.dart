import 'dart:io';

import 'package:battery_tracker/app/app_providers.dart';
import 'package:battery_tracker/app/battery_tracker_app.dart';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/core/logging/app_log_service.dart';
import 'package:battery_tracker/features/battery_types/data/drift_battery_type_repository.dart';
import 'package:battery_tracker/features/battery_types/domain/battery_type_draft.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/domain/icon_color.dart';
import 'package:battery_tracker/features/icons/domain/icon_definition.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_selection.dart';
import 'package:battery_tracker/features/settings/domain/app_settings_repository.dart';
import 'package:battery_tracker/features/settings/domain/theme_preference.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

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

  testWidgets('Battery Types destination renders its management page',
      (tester) async {
    await _useDesktopSurface(tester);
    final fixture = await _AppFixture.create();
    addTearDown(fixture.close);
    await tester.pumpWidget(fixture.app);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('destination-batteryTypes')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('battery-types-page')), findsOneWidget);
    expect(find.text('No Battery Types yet.'), findsOneWidget);
    expect(find.byKey(const ValueKey('empty-state-panel')), findsNothing);
  });

  testWidgets('Battery Types search text follows its retained catalog query',
      (tester) async {
    await _useDesktopSurface(tester);
    final fixture = await _AppFixture.create();
    addTearDown(fixture.close);
    await fixture.types.create(_draft(typeName: 'AA NiMH', chemistry: 'NiMH'));
    await fixture.types.create(
      _draft(typeName: 'Radio Pack', chemistry: 'LiFePO4'),
    );
    await tester.pumpWidget(fixture.app);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('destination-batteryTypes')));
    await tester.pumpAndSettle();
    final search = find.byKey(const ValueKey('battery-types-search'));
    await tester.enterText(search, 'radio');
    await tester.pump();
    expect(find.text('Radio Pack'), findsWidgets);
    expect(find.text('AA NiMH'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('destination-settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('destination-batteryTypes')));
    await tester.pumpAndSettle();

    final editable = tester.widget<EditableText>(
      find.descendant(of: search, matching: find.byType(EditableText)),
    );
    expect(editable.controller.text, 'radio');
    expect(find.text('Radio Pack'), findsWidgets);
    expect(find.text('AA NiMH'), findsNothing);
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

final class _AppFixture {
  _AppFixture({
    required this.root,
    required this.database,
    required this.types,
    required this.app,
  });

  final Directory root;
  final AppDatabase database;
  final DriftBatteryTypeRepository types;
  final Widget app;

  static Future<_AppFixture> create() async {
    final root = Directory.systemTemp.createTempSync('battery-app-smoke-');
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.customSelect('SELECT 1').getSingle();
    final ids = _Ids();
    final icons = DriftIconRepository(
      database: database,
      idGenerator: ids,
      builtInRegistry: IconRegistry(builtIns: BuiltInIconRegistry.definitions),
    );
    final types = DriftBatteryTypeRepository(
      database: database,
      idGenerator: ids,
      iconRepository: icons,
    );
    return _AppFixture(
      root: root,
      database: database,
      types: types,
      app: ProviderScope(
        overrides: [
          appSettingsRepositoryProvider
              .overrideWithValue(_MemorySettingsRepository()),
          applicationSupportRootProvider.overrideWithValue(root.uri),
          iconRepositoryProvider.overrideWithValue(icons),
          batteryTypeRepositoryProvider.overrideWithValue(types),
          appLogServiceProvider.overrideWithValue(_LogService()),
        ],
        child: const BatteryTrackerApp(),
      ),
    );
  }

  Future<void> close() async {
    await database.close();
    await root.delete(recursive: true);
  }
}

BatteryTypeDraft _draft({
  required String typeName,
  required String chemistry,
}) =>
    BatteryTypeDraft(
      typeName: typeName,
      description: null,
      chemistry: chemistry,
      defaultVoltage: null,
      defaultCapacity: null,
      capacityUnit: null,
      physicalSize: null,
      notes: null,
      suggestedIcon: const IconSelection(
        source: IconSource.builtin,
        key: 'battery_generic',
        color: IconColor.defaultColor,
      ),
    );

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

final class _LogService implements AppLogService {
  @override
  Future<void> close() async {}

  @override
  Future<void> initialize() async {}

  @override
  Logger logger(String scope) => Logger('test.$scope');
}

final class _Ids implements PermanentIdGenerator {
  var _next = 1;

  @override
  PermanentId next() {
    final tail = _next.toString().padLeft(12, '0');
    _next++;
    return PermanentId.parse('93000000-0000-4000-8000-$tail');
  }
}
