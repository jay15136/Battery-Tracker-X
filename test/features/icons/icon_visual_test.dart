import 'dart:io';

import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_color.dart';
import 'package:battery_tracker/features/icons/domain/icon_definition.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:battery_tracker/features/icons/presentation/icon_visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory supportDirectory;
  late IconRegistry registry;

  setUp(() async {
    supportDirectory = await Directory.systemTemp.createTemp(
      'battery-tracker-icon-visual-',
    );
    registry = IconRegistry(builtIns: BuiltInIconRegistry.definitions);
  });

  tearDown(() async {
    await supportDirectory.delete(recursive: true);
  });

  test('packages every built-in definition as a non-empty asset', () async {
    for (final definition in BuiltInIconRegistry.definitions) {
      final bytes = await rootBundle.load(definition.location);
      expect(bytes.lengthInBytes, greaterThan(100), reason: definition.key);
    }
  });

  for (final entry in {
    IconScope.battery: 'Generic Battery',
    IconScope.batterySet: 'Generic Battery Set',
    IconScope.device: 'Generic Electronic Device',
  }.entries) {
    testWidgets(
        'renders the ${entry.key.label} default in light and dark modes',
        (tester) async {
      final definition = registry.defaultFor(entry.key);

      for (final brightness in [Brightness.light, Brightness.dark]) {
        await tester.pumpWidget(
          _testApp(
            brightness: brightness,
            child: IconVisual(
              definition: definition,
              color: IconColor.blue,
              fallbackDefinition: definition,
              applicationSupportRoot: supportDirectory.uri,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel(entry.value), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('uses the owner default when a managed icon file is missing',
      (tester) async {
    final fallback = registry.defaultFor(IconScope.device);
    const missing = IconDefinition.custom(
      key: '11111111-1111-4111-8111-111111111111',
      displayName: 'Missing Radio Crest',
      scope: IconScope.device,
      category: 'Police Equipment',
      location: 'custom_icons/11111111-1111-4111-8111-111111111111/source.svg',
      fileType: IconFileType.svg,
      supportsColor: true,
    );

    await tester.pumpWidget(
      _testApp(
        brightness: Brightness.light,
        child: IconVisual(
          definition: missing,
          color: IconColor.red,
          fallbackDefinition: fallback,
          applicationSupportRoot: supportDirectory.uri,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Generic Electronic Device'), findsOneWidget);
    expect(find.bySemanticsLabel('Missing Radio Crest'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp({
  required Brightness brightness,
  required Widget child,
}) {
  return MaterialApp(
    theme: ThemeData(brightness: brightness),
    home: Scaffold(body: Center(child: child)),
  );
}
