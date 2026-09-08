import 'dart:async';
import 'dart:io';

import 'package:battery_tracker/app/app_providers.dart';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/core/logging/app_log_service.dart';
import 'package:battery_tracker/features/battery_types/domain/battery_type.dart';
import 'package:battery_tracker/features/battery_types/domain/battery_type_draft.dart';
import 'package:battery_tracker/features/battery_types/presentation/battery_type_form_dialog.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/domain/icon_color.dart';
import 'package:battery_tracker/features/icons/domain/icon_definition.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_selection.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

void main() {
  late AppDatabase database;
  late DriftIconRepository iconRepository;
  late Directory root;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.customSelect('SELECT 1').getSingle();
    iconRepository = DriftIconRepository(
      database: database,
      idGenerator: _Ids(),
      builtInRegistry: IconRegistry(
        builtIns: BuiltInIconRegistry.definitions,
      ),
    );
    root = await Directory.systemTemp.createTemp('battery-tracker-type-form-');
  });

  tearDown(() async {
    await database.close();
    await root.delete(recursive: true);
  });

  testWidgets('add mode shows every editable Battery Type field',
      (tester) async {
    await tester.pumpWidget(
      _FormHarness(iconRepository: iconRepository, root: root),
    );

    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();

    expect(find.text('Add Battery Type'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('battery-type-name-field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('battery-type-chemistry-field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('battery-type-voltage-field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('battery-type-capacity-field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('battery-type-capacity-unit-field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('battery-type-physical-size-field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('battery-type-description-field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('battery-type-notes-field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('battery-type-choose-icon')),
      findsOneWidget,
    );
  });

  testWidgets('custom chemistry and capacity unit round-trip exactly',
      (tester) async {
    await tester.pumpWidget(
      _FormHarness(iconRepository: iconRepository, root: root),
    );
    await _openForm(tester);

    await tester.enterText(_field('name'), 'AA Experimental');
    await tester.enterText(_field('chemistry'), 'Custom Zinc Hybrid');
    await tester.enterText(_field('capacity'), '1500');
    await tester.enterText(_field('capacity-unit'), 'cells');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Custom Zinc Hybrid|cells'), findsOneWidget);
  });

  testWidgets('keeps parse and validation errors on their numeric fields',
      (tester) async {
    await tester.pumpWidget(
      _FormHarness(iconRepository: iconRepository, root: root),
    );
    await _openForm(tester);

    await tester.enterText(_field('name'), 'AA NiMH');
    await tester.enterText(_field('voltage'), '0');
    await tester.enterText(_field('capacity'), 'invalid');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();

    expect(find.text('Voltage must be greater than zero.'), findsOneWidget);
    expect(find.text('Enter a valid capacity.'), findsOneWidget);
    expect(find.text('not saved'), findsOneWidget);
    expect(find.text('Add Battery Type'), findsOneWidget);
  });

  testWidgets('keeps a malformed capacity parse error when its unit is set',
      (tester) async {
    await tester.pumpWidget(
      _FormHarness(iconRepository: iconRepository, root: root),
    );
    await _openForm(tester);

    await tester.enterText(_field('name'), 'AA NiMH');
    await tester.enterText(_field('capacity'), 'invalid');
    await tester.enterText(_field('capacity-unit'), 'mAh');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();

    expect(find.text('Enter a valid capacity.'), findsOneWidget);
  });

  testWidgets('requires capacity and its unit together', (tester) async {
    await tester.pumpWidget(
      _FormHarness(iconRepository: iconRepository, root: root),
    );
    await _openForm(tester);

    await tester.enterText(_field('name'), 'AA NiMH');
    await tester.enterText(_field('capacity-unit'), 'mAh');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();

    expect(find.text('Enter a capacity for this unit.'), findsOneWidget);
    expect(find.text('not saved'), findsOneWidget);
  });

  testWidgets('edit mode initializes fields and returns edited values',
      (tester) async {
    await tester.pumpWidget(
      _FormHarness(
        iconRepository: iconRepository,
        root: root,
        record: _record(),
      ),
    );
    await _openForm(tester);

    expect(find.text('Edit Battery Type'), findsOneWidget);
    expect(_textOf(_field('name')), 'AA NiMH');
    expect(_textOf(_field('chemistry')), 'NiMH');
    expect(_textOf(_field('capacity-unit')), 'mAh');
    await tester.enterText(_field('name'), 'AA NiMH Fleet');
    await tester.tap(find.widgetWithText(FilledButton, 'Save changes'));
    await tester.pumpAndSettle();

    expect(find.textContaining('AA NiMH Fleet'), findsOneWidget);
  });

  testWidgets('cancel returns no draft', (tester) async {
    await tester.pumpWidget(
      _FormHarness(iconRepository: iconRepository, root: root),
    );
    await _openForm(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('cancelled'), findsOneWidget);
  });

  testWidgets('icon chooser overrides the suggested icon and color',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _FormHarness(iconRepository: iconRepository, root: root),
    );
    await _openForm(tester);

    final chooseIcon = find.byKey(const ValueKey('battery-type-choose-icon'));
    await tester.ensureVisible(chooseIcon);
    await tester.tap(chooseIcon);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('icon-option-battery_aaa')));
    await tester.tap(find.byKey(const ValueKey('icon-color-#FF9800')));
    await tester.tap(find.widgetWithText(FilledButton, 'Choose'));
    await tester.pumpAndSettle();
    await tester.enterText(_field('name'), 'AAA NiMH');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.textContaining('battery_aaa|#FF9800'), findsOneWidget);
  });

  testWidgets(
      'unexpected icon repository failure logs once and keeps fallback visible',
      (tester) async {
    final logs = _LogService();
    addTearDown(logs.close);
    await database.customStatement(
      'ALTER TABLE custom_icons RENAME TO unavailable_custom_icons',
    );
    await tester.pumpWidget(
      _FormHarness(
        iconRepository: iconRepository,
        root: root,
        logs: logs,
        record: _record(
          suggestedIcon: const IconSelection(
            source: IconSource.custom,
            key: '96000000-0000-4000-8000-000000000001',
            color: IconColor.brown,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Generic Battery'), findsOneWidget);
    expect(find.textContaining('SqliteException'), findsNothing);
    expect(logs.severeRecords, hasLength(1));
    expect(logs.scopes, ['icons.ui']);
    expect(
        logs.severeRecords.single.message, 'Inventory icon resolution failed.');
    expect(logs.severeRecords.single.error, isNotNull);
    await tester.pump(const Duration(milliseconds: 50));
    expect(logs.severeRecords, hasLength(1));
    expect(tester.takeException(), isNull);
  });
}

Finder _field(String name) => find.byKey(ValueKey('battery-type-$name-field'));

Future<void> _openForm(WidgetTester tester) async {
  await tester.tap(find.text('Open form'));
  await tester.pumpAndSettle();
}

String _textOf(Finder finder) =>
    finder.evaluate().single.widget is TextFormField
        ? (finder.evaluate().single.widget as TextFormField).controller!.text
        : throw StateError('Expected a TextFormField.');

BatteryTypeRecord _record({IconSelection? suggestedIcon}) => BatteryTypeRecord(
      id: PermanentId.parse('90000000-0000-4000-8000-000000000001'),
      typeName: 'AA NiMH',
      description: 'Rechargeable AA cells',
      chemistry: 'NiMH',
      defaultVoltage: 1.2,
      defaultCapacity: 2500,
      capacityUnit: 'mAh',
      physicalSize: 'AA',
      suggestedIcon: suggestedIcon ??
          const IconSelection(
            source: IconSource.builtin,
            key: 'battery_aa',
            color: IconColor.green,
          ),
      notes: 'Fleet stock',
      createdAt: DateTime.utc(2026),
      modifiedAt: DateTime.utc(2026),
      deactivatedAt: null,
    );

final class _FormHarness extends StatefulWidget {
  const _FormHarness({
    required this.iconRepository,
    required this.root,
    this.record,
    this.logs,
  });

  final DriftIconRepository iconRepository;
  final Directory root;
  final BatteryTypeRecord? record;
  final AppLogService? logs;

  @override
  State<_FormHarness> createState() => _FormHarnessState();
}

final class _FormHarnessState extends State<_FormHarness> {
  BatteryTypeDraft? _result;
  bool _cancelled = false;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        iconRepositoryProvider.overrideWithValue(widget.iconRepository),
        applicationSupportRootProvider.overrideWithValue(widget.root.uri),
        if (widget.logs != null)
          appLogServiceProvider.overrideWithValue(widget.logs!),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Column(
              children: [
                FilledButton(
                  onPressed: () async {
                    final result = await BatteryTypeFormDialog.show(
                      context,
                      record: widget.record,
                    );
                    if (!mounted) {
                      return;
                    }
                    setState(() {
                      _result = result;
                      _cancelled = result == null;
                    });
                  },
                  child: const Text('Open form'),
                ),
                Text(
                  _result == null
                      ? (_cancelled ? 'cancelled' : 'not saved')
                      : _result!.chemistry == 'Custom Zinc Hybrid'
                          ? '${_result!.chemistry}|${_result!.capacityUnit}'
                          : '${_result!.typeName}|${_result!.suggestedIcon.key}|${_result!.suggestedIcon.color.value}',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _LogService implements AppLogService {
  _LogService() {
    _subscription = _logger.onRecord.listen(records.add);
  }

  final Logger _logger = Logger.detached('test.battery_types.ui')
    ..level = Level.ALL;
  final List<LogRecord> records = [];
  final List<String> scopes = [];
  late final StreamSubscription<LogRecord> _subscription;

  List<LogRecord> get severeRecords =>
      records.where((record) => record.level == Level.SEVERE).toList();

  @override
  Future<void> close() => _subscription.cancel();

  @override
  Future<void> initialize() async {}

  @override
  Logger logger(String scope) {
    scopes.add(scope);
    return _logger;
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
