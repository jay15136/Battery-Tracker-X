import 'dart:async';
import 'dart:io';

import 'package:battery_tracker/app/app_providers.dart';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/core/logging/app_log_service.dart';
import 'package:battery_tracker/features/battery_types/data/drift_battery_type_repository.dart';
import 'package:battery_tracker/features/battery_types/domain/battery_type.dart';
import 'package:battery_tracker/features/battery_types/domain/battery_type_draft.dart';
import 'package:battery_tracker/features/battery_types/domain/battery_type_repository.dart';
import 'package:battery_tracker/features/battery_types/presentation/battery_types_page.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/domain/icon_color.dart';
import 'package:battery_tracker/features/icons/domain/icon_definition.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_selection.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

void main() {
  late Directory root;
  late AppDatabase database;
  late DriftIconRepository icons;
  late DriftBatteryTypeRepository repository;
  late _Ids ids;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('battery-types-page-ui-');
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.customSelect('SELECT 1').getSingle();
    ids = _Ids();
    icons = DriftIconRepository(
      database: database,
      idGenerator: ids,
      builtInRegistry: IconRegistry(builtIns: BuiltInIconRegistry.definitions),
    );
    repository = DriftBatteryTypeRepository(
      database: database,
      idGenerator: ids,
      iconRepository: icons,
      clock: () => DateTime.utc(2026, 8, 15, 12),
    );
  });

  tearDown(() async {
    await database.close();
    await root.delete(recursive: true);
  });

  testWidgets('distinguishes database-empty and filtered-empty states',
      (tester) async {
    await _pumpPage(tester, root: root, icons: icons, repository: repository);

    expect(find.byKey(const ValueKey('battery-types-page')), findsOneWidget);
    expect(find.byKey(const ValueKey('battery-types-search')), findsOneWidget);
    expect(find.text('No Battery Types yet.'), findsOneWidget);

    await repository.create(_draft(typeName: 'AA NiMH'));
    await _pumpPage(tester, root: root, icons: icons, repository: repository);
    await tester.enterText(
      find.byKey(const ValueKey('battery-types-search')),
      'not-present',
    );
    await tester.pump();

    expect(
      find.text('No Battery Types match these filters.'),
      findsOneWidget,
    );
  });

  testWidgets('adds, edits, and preserves a Battery Type permanent UUID',
      (tester) async {
    await _pumpPage(tester, root: root, icons: icons, repository: repository);

    await tester.tap(find.byKey(const ValueKey('battery-types-add')));
    await tester.pumpAndSettle();
    await tester.enterText(_field('name'), '18650 Li-ion');
    await tester.enterText(_field('chemistry'), 'Li-ion');
    await tester.enterText(_field('physical-size'), '18 × 65 mm');
    await tester.enterText(_field('voltage'), '3.7');
    await tester.enterText(_field('capacity'), '3500');
    await tester.enterText(_field('capacity-unit'), 'mAh');
    await tester.pump();
    await tester.tap(find.text('mAh').last);
    await tester.pump();
    final save = find.widgetWithText(FilledButton, 'Save');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    final created = (await repository.list()).single;
    expect(find.text('18650 Li-ion'), findsWidgets);
    expect(find.text(created.id.value), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('battery-types-edit')));
    await tester.pumpAndSettle();
    await tester.enterText(_field('name'), '18650 High Drain');
    final saveChanges = find.widgetWithText(FilledButton, 'Save changes');
    await tester.ensureVisible(saveChanges);
    await tester.tap(saveChanges);
    await tester.pumpAndSettle();

    final updated = (await repository.list()).single;
    expect(updated.id, created.id);
    expect(updated.typeName, '18650 High Drain');
    expect(find.text('18650 High Drain'), findsWidgets);
    expect(find.text(created.id.value), findsOneWidget);
  });

  testWidgets('reports a saved create when its catalog reload fails',
      (tester) async {
    final logs = _LogService();
    addTearDown(logs.close);
    final failingRepository = _PostWriteListFailingRepository(repository);
    await _pumpPage(
      tester,
      root: root,
      icons: icons,
      repository: failingRepository,
      logs: logs,
    );

    await tester.tap(find.byKey(const ValueKey('battery-types-add')));
    await tester.pumpAndSettle();
    await tester.enterText(_field('name'), 'Saved create');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Saved create'), findsWidgets);
    expect(
      find.text(
        'Battery Type was added, but the list could not refresh.',
      ),
      findsOneWidget,
    );
    expect(find.text('Battery Type could not be added.'), findsNothing);
    _expectSingleRefreshLog(logs);
  });

  testWidgets('reports a saved update when its catalog reload fails',
      (tester) async {
    final logs = _LogService();
    addTearDown(logs.close);
    await repository.create(_draft(typeName: 'Before update'));
    final failingRepository = _PostWriteListFailingRepository(repository);
    await _pumpPage(
      tester,
      root: root,
      icons: icons,
      repository: failingRepository,
      logs: logs,
    );

    await tester.tap(find.byKey(const ValueKey('battery-types-edit')));
    await tester.pumpAndSettle();
    await tester.enterText(_field('name'), 'Saved update');
    await tester.tap(find.widgetWithText(FilledButton, 'Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('Saved update'), findsWidgets);
    expect(
      find.text(
        'Battery Type was updated, but the list could not refresh.',
      ),
      findsOneWidget,
    );
    expect(find.text('Battery Type could not be updated.'), findsNothing);
    _expectSingleRefreshLog(logs);
  });

  testWidgets('reports a saved deactivation when its catalog reload fails',
      (tester) async {
    final logs = _LogService();
    addTearDown(logs.close);
    final type = await repository.create(_draft(typeName: 'Saved deactivate'));
    final failingRepository = _PostWriteListFailingRepository(repository);
    await _pumpPage(
      tester,
      root: root,
      icons: icons,
      repository: failingRepository,
      logs: logs,
    );

    await tester.tap(find.byKey(const ValueKey('battery-types-deactivate')));
    await tester.pumpAndSettle();
    await tester.tap(_dialogAction('Deactivate'));
    await tester.pumpAndSettle();

    expect((await repository.get(type.id)).isActive, isFalse);
    expect(find.text('Saved deactivate'), findsOneWidget);
    expect(
      find.text(
        'Battery Type was deactivated, but the list could not refresh.',
      ),
      findsOneWidget,
    );
    expect(find.text('Battery Type could not be deactivated.'), findsNothing);
    _expectSingleRefreshLog(logs);
  });

  testWidgets('reports a saved reactivation when its catalog reload fails',
      (tester) async {
    final logs = _LogService();
    addTearDown(logs.close);
    final type = await repository.create(_draft(typeName: 'Saved reactivate'));
    await repository.deactivate(type.id);
    final failingRepository = _PostWriteListFailingRepository(repository);
    await _pumpPage(
      tester,
      root: root,
      icons: icons,
      repository: failingRepository,
      logs: logs,
    );
    await tester
        .tap(find.byKey(const ValueKey('battery-types-filter-inactive')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('battery-types-reactivate')));
    await tester.pumpAndSettle();
    await tester.tap(_dialogAction('Reactivate'));
    await tester.pumpAndSettle();

    expect((await repository.get(type.id)).isActive, isTrue);
    expect(find.text('Saved reactivate'), findsOneWidget);
    expect(
      find.text(
        'Battery Type was reactivated, but the list could not refresh.',
      ),
      findsOneWidget,
    );
    expect(find.text('Battery Type could not be reactivated.'), findsNothing);
    _expectSingleRefreshLog(logs);
  });

  testWidgets('searches chemistry and physical size and filters status',
      (tester) async {
    await repository.create(
      _draft(typeName: 'Radio Pack', chemistry: 'LiFePO4', size: 'Prismatic'),
    );
    final inactive = await repository.create(
      _draft(typeName: 'Retired AA', chemistry: 'NiMH', size: 'AA'),
    );
    await repository.deactivate(inactive.id);
    await _pumpPage(tester, root: root, icons: icons, repository: repository);

    await tester.enterText(
      find.byKey(const ValueKey('battery-types-search')),
      'lifepo4',
    );
    await tester.pump();
    expect(find.text('Radio Pack'), findsWidgets);
    expect(find.text('Retired AA'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('battery-types-search')),
      'prismatic',
    );
    await tester.pump();
    expect(find.text('Radio Pack'), findsWidgets);

    await tester.enterText(
      find.byKey(const ValueKey('battery-types-search')),
      '',
    );
    await tester
        .tap(find.byKey(const ValueKey('battery-types-filter-inactive')));
    await tester.pump();
    expect(find.text('Retired AA'), findsWidgets);
    expect(find.text('Radio Pack'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('battery-types-filter-all')));
    await tester.pump();
    expect(find.text('Retired AA'), findsWidgets);
    expect(find.text('Radio Pack'), findsWidgets);
  });

  testWidgets('details show complete defaults and exact usage counts',
      (tester) async {
    final type = await repository.create(_draft(typeName: 'AA NiMH'));
    await _seedUsage(database, type);
    await _pumpPage(tester, root: root, icons: icons, repository: repository);

    expect(find.text('NiMH • AA • 1.2 V • 2500 mAh'), findsOneWidget);
    await tester.tap(find.byKey(ValueKey('battery-type-row-${type.id.value}')));
    await tester.pumpAndSettle();

    expect(find.text('NiMH'), findsWidgets);
    expect(find.text('AA'), findsWidgets);
    expect(find.text('1.2 V'), findsOneWidget);
    expect(find.text('2500 mAh'), findsOneWidget);
    expect(find.text('Rechargeable cells'), findsOneWidget);
    expect(find.text('Standard issue'), findsOneWidget);
    expect(
      find.text('Used by 1 Battery, 1 Battery Set, and 1 Device.'),
      findsOneWidget,
    );
    expect(_detailValue(tester, 'Created'), matches(_timestampPattern));
    expect(_detailValue(tester, 'Modified'), matches(_timestampPattern));
    expect(_detailValue(tester, 'Deactivated'), 'Active — not deactivated');
  });

  testWidgets('inactive details show the deactivation timestamp',
      (tester) async {
    final type = await repository.create(_draft(typeName: 'Inactive type'));
    await repository.deactivate(type.id);
    await _pumpPage(tester, root: root, icons: icons, repository: repository);
    await tester
        .tap(find.byKey(const ValueKey('battery-types-filter-inactive')));
    await tester.pumpAndSettle();

    expect(_detailValue(tester, 'Created'), matches(_timestampPattern));
    expect(_detailValue(tester, 'Modified'), matches(_timestampPattern));
    expect(_detailValue(tester, 'Deactivated'), matches(_timestampPattern));
    expect(find.text('Active — not deactivated'), findsNothing);
  });

  testWidgets('deactivation confirmation requests fresh usage counts',
      (tester) async {
    final type = await repository.create(_draft(typeName: 'Fresh usage'));
    await _pumpPage(tester, root: root, icons: icons, repository: repository);
    expect(
      find.text('Used by 0 Batteries, 0 Battery Sets, and 0 Devices.'),
      findsOneWidget,
    );
    await _seedUsage(database, type);

    await tester.tap(find.byKey(const ValueKey('battery-types-deactivate')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Used by 1 Battery, 1 Battery Set, and 1 Device.'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
  });

  testWidgets(
      'deactivation reports usage, preserves references, and reactivates',
      (tester) async {
    final type = await repository.create(_draft(typeName: 'AA NiMH'));
    await _seedUsage(database, type);
    final rowIdsBefore = await _referencedRowIds(database);
    await _pumpPage(tester, root: root, icons: icons, repository: repository);

    await tester.tap(find.byKey(const ValueKey('battery-types-deactivate')));
    await tester.pumpAndSettle();
    expect(
      find.text('Used by 1 Battery, 1 Battery Set, and 1 Device.'),
      findsWidgets,
    );
    await tester.tap(_dialogAction('Deactivate'));
    await tester.pumpAndSettle();

    expect(
      find.text('No Battery Types match these filters.'),
      findsOneWidget,
    );
    expect(await _referencedRowIds(database), rowIdsBefore);
    await tester
        .tap(find.byKey(const ValueKey('battery-types-filter-inactive')));
    await tester.pumpAndSettle();
    expect(find.text('AA NiMH'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('battery-types-reactivate')));
    await tester.pumpAndSettle();
    await tester.tap(_dialogAction('Reactivate'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('battery-types-filter-active')));
    await tester.pumpAndSettle();
    expect(find.text('AA NiMH'), findsWidgets);
    expect((await repository.get(type.id)).isActive, isTrue);
  });

  testWidgets('duplicate name conflict is concise and not severely logged',
      (tester) async {
    final logs = _LogService();
    addTearDown(logs.close);
    await repository.create(_draft(typeName: 'AA NiMH'));
    await _pumpPage(
      tester,
      root: root,
      icons: icons,
      repository: repository,
      logs: logs,
    );

    await tester.tap(find.byKey(const ValueKey('battery-types-add')));
    await tester.pumpAndSettle();
    await tester.enterText(_field('name'), ' aa nimh ');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(
      find.text('An active Battery Type already uses this name.'),
      findsOneWidget,
    );
    expect(find.textContaining('Exception'), findsNothing);
    expect(logs.severeRecords, isEmpty);
    expect(find.text('AA NiMH'), findsWidgets);
  });

  testWidgets('stale lifecycle conflict refreshes without severe logging',
      (tester) async {
    final logs = _LogService();
    addTearDown(logs.close);
    final type = await repository.create(_draft(typeName: 'Concurrent state'));
    await _pumpPage(
      tester,
      root: root,
      icons: icons,
      repository: repository,
      logs: logs,
    );
    await repository.deactivate(type.id);

    await tester.tap(find.byKey(const ValueKey('battery-types-deactivate')));
    await tester.pumpAndSettle();
    await tester.tap(_dialogAction('Deactivate'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'This Battery Type changed before it could be deactivated. '
        'The list was refreshed.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Exception'), findsNothing);
    expect(logs.severeRecords, isEmpty);
    expect(
      find.text('No Battery Types match these filters.'),
      findsOneWidget,
    );
  });

  testWidgets('not-found conflict refreshes without severe logging',
      (tester) async {
    final logs = _LogService();
    addTearDown(logs.close);
    final type = await repository.create(_draft(typeName: 'Removed elsewhere'));
    await _pumpPage(
      tester,
      root: root,
      icons: icons,
      repository: repository,
      logs: logs,
    );
    await (database.delete(database.batteryTypes)
          ..where((table) => table.uuid.equals(type.id.value)))
        .go();

    await tester.tap(find.byKey(const ValueKey('battery-types-edit')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save changes'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'This Battery Type no longer exists. The list was refreshed.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Exception'), findsNothing);
    expect(logs.severeRecords, isEmpty);
    expect(find.text('No Battery Types yet.'), findsOneWidget);
  });

  testWidgets('reactivation conflict shows concise copy without raw exception',
      (tester) async {
    final logs = _LogService();
    addTearDown(logs.close);
    final inactive = await repository.create(_draft(typeName: 'AA NiMH'));
    await repository.deactivate(inactive.id);
    await repository.create(_draft(typeName: 'AA NiMH'));
    await _pumpPage(
      tester,
      root: root,
      icons: icons,
      repository: repository,
      logs: logs,
    );
    await tester
        .tap(find.byKey(const ValueKey('battery-types-filter-inactive')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('battery-types-reactivate')));
    await tester.pumpAndSettle();
    await tester.tap(_dialogAction('Reactivate'));
    await tester.pumpAndSettle();

    expect(
      find.text('A different active Battery Type already uses this name.'),
      findsOneWidget,
    );
    expect(find.textContaining('Exception'), findsNothing);
    expect(logs.severeRecords, isEmpty);
  });

  testWidgets('catalog load failure logs once and shows concise retry UI',
      (tester) async {
    final logs = _LogService();
    addTearDown(logs.close);
    await database.customStatement(
      'ALTER TABLE battery_types RENAME TO unavailable_battery_types',
    );

    await _pumpPage(
      tester,
      root: root,
      icons: icons,
      repository: repository,
      logs: logs,
    );

    expect(find.text('Battery Types could not be loaded.'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Retry'), findsOneWidget);
    expect(find.textContaining('SqliteException'), findsNothing);
    expect(logs.severeRecords, hasLength(1));
    expect(logs.scopes, ['battery_types.ui']);
    expect(logs.severeRecords.single.message, 'Battery Type operation failed.');
    expect(logs.severeRecords.single.error, isNotNull);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(logs.severeRecords, hasLength(1));
  });

  testWidgets('usage failure logs once and shows concise unavailable UI',
      (tester) async {
    final logs = _LogService();
    addTearDown(logs.close);
    await repository.create(_draft(typeName: 'AA NiMH'));
    await database.customStatement(
      'ALTER TABLE batteries RENAME TO unavailable_batteries',
    );

    await _pumpPage(
      tester,
      root: root,
      icons: icons,
      repository: repository,
      logs: logs,
    );

    expect(find.text('Usage counts are unavailable.'), findsOneWidget);
    expect(find.textContaining('SqliteException'), findsNothing);
    expect(logs.severeRecords, hasLength(1));
    expect(logs.scopes, ['battery_types.ui']);
    expect(logs.severeRecords.single.message, 'Battery Type operation failed.');

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(logs.severeRecords, hasLength(1));
  });

  for (final brightness in [Brightness.light, Brightness.dark]) {
    testWidgets('is bounded and overflow-free in ${brightness.name} mode',
        (tester) async {
      for (var index = 0; index < 16; index++) {
        await repository.create(_draft(typeName: 'Battery Type $index'));
      }
      await _pumpPage(
        tester,
        root: root,
        icons: icons,
        repository: repository,
        size: const Size(640, 760),
        brightness: brightness,
      );

      expect(find.byKey(const ValueKey('battery-types-page')), findsOneWidget);
      expect(
        find.bySemanticsLabel('Search Battery Types'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required Directory root,
  required DriftIconRepository icons,
  required BatteryTypeRepository repository,
  _LogService? logs,
  Size size = const Size(1280, 800),
  Brightness brightness = Brightness.light,
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        applicationSupportRootProvider.overrideWithValue(root.uri),
        iconRepositoryProvider.overrideWithValue(icons),
        batteryTypeRepositoryProvider.overrideWithValue(repository),
        appLogServiceProvider.overrideWithValue(logs ?? _LogService()),
      ],
      child: MaterialApp(
        theme: ThemeData(brightness: brightness, useMaterial3: true),
        home: const Scaffold(body: BatteryTypesPage()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _field(String name) => find.byKey(ValueKey('battery-type-$name-field'));

Finder _dialogAction(String label) => find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(FilledButton, label),
    );

final _timestampPattern = RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$');

String _detailValue(WidgetTester tester, String label) {
  final row =
      find.ancestor(of: find.text(label), matching: find.byType(Row)).first;
  final texts = tester
      .widgetList<Text>(find.descendant(of: row, matching: find.byType(Text)))
      .map((text) => text.data)
      .whereType<String>()
      .toList();
  expect(texts.first, label);
  return texts.last;
}

void _expectSingleRefreshLog(_LogService logs) {
  expect(logs.severeRecords, hasLength(1));
  expect(logs.scopes, ['battery_types.ui']);
  expect(
    logs.severeRecords.single.message,
    'Battery Type catalog refresh failed after a committed change.',
  );
  expect(logs.severeRecords.single.error, isA<StateError>());
}

BatteryTypeDraft _draft({
  required String typeName,
  String chemistry = 'NiMH',
  String size = 'AA',
}) =>
    BatteryTypeDraft(
      typeName: typeName,
      description: 'Rechargeable cells',
      chemistry: chemistry,
      defaultVoltage: 1.2,
      defaultCapacity: 2500,
      capacityUnit: 'mAh',
      physicalSize: size,
      notes: 'Standard issue',
      suggestedIcon: const IconSelection(
        source: IconSource.builtin,
        key: 'battery_aa',
        color: IconColor.green,
      ),
    );

Future<void> _seedUsage(
  AppDatabase database,
  BatteryTypeRecord type,
) async {
  final row = await (database.select(database.batteryTypes)
        ..where((table) => table.uuid.equals(type.id.value)))
      .getSingle();
  await database.into(database.batteries).insert(
        BatteriesCompanion.insert(
          uuid: '72000000-0000-4000-8000-000000000001',
          userBatteryId: 'AA-001',
          batteryTypeId: Value(row.id),
        ),
      );
  await database.into(database.batterySets).insert(
        BatterySetsCompanion.insert(
          uuid: '72000000-0000-4000-8000-000000000002',
          userSetId: 'SET-001',
          name: 'Radio pair',
          batteryTypeId: Value(row.id),
        ),
      );
  await database.into(database.devices).insert(
        DevicesCompanion.insert(
          uuid: '72000000-0000-4000-8000-000000000003',
          name: 'Portable Radio',
          requiredBatteryTypeId: Value(row.id),
        ),
      );
}

Future<({int? battery, int? batterySet, int? device})> _referencedRowIds(
  AppDatabase database,
) async {
  final batteries = await database.select(database.batteries).get();
  final sets = await database.select(database.batterySets).get();
  final devices = await database.select(database.devices).get();
  return (
    battery: batteries.single.batteryTypeId,
    batterySet: sets.single.batteryTypeId,
    device: devices.single.requiredBatteryTypeId,
  );
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

final class _PostWriteListFailingRepository implements BatteryTypeRepository {
  _PostWriteListFailingRepository(this._delegate);

  final BatteryTypeRepository _delegate;
  var _failNextList = false;

  @override
  Future<BatteryTypeRecord> create(BatteryTypeDraft draft) async {
    final record = await _delegate.create(draft);
    _failNextList = true;
    return record;
  }

  @override
  Future<BatteryTypeRecord> deactivate(PermanentId id) async {
    final record = await _delegate.deactivate(id);
    _failNextList = true;
    return record;
  }

  @override
  Future<BatteryTypeRecord> get(PermanentId id) => _delegate.get(id);

  @override
  Future<List<BatteryTypeRecord>> list({bool includeInactive = false}) {
    if (_failNextList) {
      _failNextList = false;
      throw StateError('simulated post-write list failure');
    }
    return _delegate.list(includeInactive: includeInactive);
  }

  @override
  Future<BatteryTypeRecord> reactivate(PermanentId id) async {
    final record = await _delegate.reactivate(id);
    _failNextList = true;
    return record;
  }

  @override
  Future<BatteryTypeRecord> update(
    PermanentId id,
    BatteryTypeDraft draft,
  ) async {
    final record = await _delegate.update(id, draft);
    _failNextList = true;
    return record;
  }

  @override
  Future<BatteryTypeUsage> usage(PermanentId id) => _delegate.usage(id);
}

final class _Ids implements PermanentIdGenerator {
  var _next = 1;

  @override
  PermanentId next() {
    final tail = _next.toString().padLeft(12, '0');
    _next++;
    return PermanentId.parse('92000000-0000-4000-8000-$tail');
  }
}
