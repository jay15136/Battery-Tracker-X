import 'dart:io';

import 'package:battery_tracker/app/app_providers.dart';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/domain/icon_color.dart';
import 'package:battery_tracker/features/icons/domain/icon_definition.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_selection.dart';
import 'package:battery_tracker/features/icons/presentation/icon_color_picker.dart';
import 'package:battery_tracker/features/icons/presentation/icon_picker_dialog.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftIconRepository repository;
  late Directory root;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.customSelect('SELECT 1').getSingle();
    repository = DriftIconRepository(
      database: database,
      idGenerator: _Ids(),
      builtInRegistry: IconRegistry(
        builtIns: BuiltInIconRegistry.definitions,
      ),
    );
    root = await Directory.systemTemp.createTemp('battery-tracker-picker-');
  });

  tearDown(() async {
    await database.close();
    await root.delete(recursive: true);
  });

  testWidgets('searches, previews, colors, and confirms an icon selection',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_PickerHarness(repository: repository, root: root));

    await tester.tap(find.text('Open picker'));
    await tester.pumpAndSettle();
    expect(find.text('Choose Icon'), findsOneWidget);
    expect(find.text('Generic Battery'), findsWidgets);

    await tester.enterText(
      find.byKey(const ValueKey('icon-search-field')),
      'AAA Battery',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('icon-option-battery_aaa')),
    );
    await tester.tap(
      find.byKey(const ValueKey('icon-color-#FF9800')),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Choose'));
    await tester.pumpAndSettle();

    expect(find.text('battery_aaa|#FF9800'), findsOneWidget);
  });

  testWidgets('validates custom hex input before changing the color',
      (tester) async {
    IconColor selected = IconColor.blue;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => IconColorPicker(
              selected: selected,
              defaultColor: IconColor.defaultColor,
              onChanged: (color) => setState(() => selected = color),
            ),
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('custom-icon-color-field')),
      '#NOTHEX',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('Use six hexadecimal digits, such as #3F51B5.'),
        findsOneWidget);
    expect(selected, IconColor.blue);

    await tester.enterText(
      find.byKey(const ValueKey('custom-icon-color-field')),
      '#123abc',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(selected.value, '#123ABC');
    expect(find.text('Use six hexadecimal digits, such as #3F51B5.'),
        findsNothing);
  });

  testWidgets('reset actions restore the scope default icon and color',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _PickerHarness(
        repository: repository,
        root: root,
        initialSelection: const IconSelection(
          source: IconSource.builtin,
          key: 'battery_aa',
          color: IconColor.red,
        ),
      ),
    );

    await tester.tap(find.text('Open picker'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset to Default'));
    await tester.tap(find.widgetWithText(FilledButton, 'Choose'));
    await tester.pumpAndSettle();

    expect(find.text('battery_generic|#607D8B'), findsOneWidget);
  });

  testWidgets('cancel closes without returning a selection', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_PickerHarness(repository: repository, root: root));

    await tester.tap(find.text('Open picker'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('cancelled'), findsOneWidget);
  });
}

final class _PickerHarness extends StatefulWidget {
  const _PickerHarness({
    required this.repository,
    required this.root,
    this.initialSelection,
  });

  final DriftIconRepository repository;
  final Directory root;
  final IconSelection? initialSelection;

  @override
  State<_PickerHarness> createState() => _PickerHarnessState();
}

final class _PickerHarnessState extends State<_PickerHarness> {
  String _result = 'not opened';

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        iconRepositoryProvider.overrideWithValue(widget.repository),
        applicationSupportRootProvider.overrideWithValue(widget.root.uri),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Column(
              children: [
                FilledButton(
                  onPressed: () async {
                    final selection = await IconPickerDialog.show(
                      context,
                      scope: IconScope.battery,
                      initialSelection: widget.initialSelection,
                    );
                    if (mounted) {
                      setState(() {
                        _result = selection == null
                            ? 'cancelled'
                            : '${selection.key}|${selection.color.value}';
                      });
                    }
                  },
                  child: const Text('Open picker'),
                ),
                Text(_result),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _Ids implements PermanentIdGenerator {
  var _value = 1;

  @override
  PermanentId next() {
    final tail = _value.toString().padLeft(12, '0');
    _value++;
    return PermanentId.parse('90000000-0000-4000-8000-$tail');
  }
}
