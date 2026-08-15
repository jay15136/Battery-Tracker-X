import 'dart:async';
import 'dart:io';

import 'package:battery_tracker/app/app_providers.dart';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/core/logging/app_log_service.dart';
import 'package:battery_tracker/core/storage/managed_relative_path.dart';
import 'package:battery_tracker/features/battery_types/presentation/battery_type_icon.dart';
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
  late DriftIconRepository repository;
  late _Ids ids;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('battery-type-icon-ui-');
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.customSelect('SELECT 1').getSingle();
    ids = _Ids();
    repository = DriftIconRepository(
      database: database,
      idGenerator: ids,
      builtInRegistry: IconRegistry(
        builtIns: BuiltInIconRegistry.definitions,
      ),
    );
  });

  tearDown(() async {
    await database.close();
    await root.delete(recursive: true);
  });

  testWidgets('renders a built-in Battery selection', (tester) async {
    await _pump(
      tester,
      root: root,
      repository: repository,
      selection: const IconSelection(
        source: IconSource.builtin,
        key: 'battery_aa',
        color: IconColor.green,
      ),
    );

    expect(find.bySemanticsLabel('AA Battery'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders an active file-backed custom Battery icon',
      (tester) async {
    final icon = await _createCustomIcon(
      repository,
      ids,
      relativePath: 'custom_icons/active/source.svg',
    );
    final file = File.fromUri(root.uri.resolve(icon.relativePath.value));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(_svg);

    await _pump(
      tester,
      root: root,
      repository: repository,
      selection: IconSelection(
        source: IconSource.custom,
        key: icon.id.value,
        color: IconColor.orange,
      ),
    );

    expect(find.bySemanticsLabel('Fleet Cell'), findsOneWidget);
    expect(find.bySemanticsLabel('Generic Battery'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'falls back for an inactive custom reference without changing its key',
      (tester) async {
    final logs = _LogService();
    addTearDown(logs.close);
    final icon = await _createCustomIcon(
      repository,
      ids,
      relativePath: 'custom_icons/inactive/source.svg',
    );
    await (database.update(database.customIcons)
          ..where((table) => table.uuid.equals(icon.id.value)))
        .write(
      CustomIconsCompanion(deactivatedAt: Value(DateTime.utc(2026, 8, 15))),
    );
    final selection = IconSelection(
      source: IconSource.custom,
      key: icon.id.value,
      color: IconColor.purple,
    );
    await database.into(database.batteryTypes).insert(
          BatteryTypesCompanion.insert(
            uuid: '94000000-0000-4000-8000-000000000001',
            typeName: 'Legacy Fleet Cell',
            suggestedIconSource: const Value('custom'),
            suggestedIconKey: Value(selection.key),
            suggestedIconColor: Value(selection.color.value),
          ),
        );

    await _pump(
      tester,
      root: root,
      repository: repository,
      selection: selection,
      logs: logs,
    );

    final stored = (await database.select(database.batteryTypes).get()).single;
    expect(stored.suggestedIconKey, icon.id.value);
    expect(find.bySemanticsLabel('Generic Battery'), findsOneWidget);
    expect(find.bySemanticsLabel('Fleet Cell'), findsNothing);
    expect(logs.severeRecords, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('malformed custom reference falls back without severe logging',
      (tester) async {
    final logs = _LogService();
    addTearDown(logs.close);

    await _pump(
      tester,
      root: root,
      repository: repository,
      selection: const IconSelection(
        source: IconSource.custom,
        key: 'not-a-permanent-uuid',
        color: IconColor.red,
      ),
      logs: logs,
    );

    expect(find.bySemanticsLabel('Generic Battery'), findsOneWidget);
    expect(logs.severeRecords, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing custom metadata falls back without severe logging',
      (tester) async {
    final logs = _LogService();
    addTearDown(logs.close);

    await _pump(
      tester,
      root: root,
      repository: repository,
      selection: const IconSelection(
        source: IconSource.custom,
        key: '95000000-0000-4000-8000-000000000001',
        color: IconColor.gray,
      ),
      logs: logs,
    );

    expect(find.bySemanticsLabel('Generic Battery'), findsOneWidget);
    expect(logs.severeRecords, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lets IconVisual fall back when an active custom file is missing',
      (tester) async {
    final logs = _LogService();
    addTearDown(logs.close);
    final icon = await _createCustomIcon(
      repository,
      ids,
      relativePath: 'custom_icons/missing/source.svg',
    );
    final selection = IconSelection(
      source: IconSource.custom,
      key: icon.id.value,
      color: IconColor.blue,
    );

    await _pump(
      tester,
      root: root,
      repository: repository,
      selection: selection,
      logs: logs,
    );

    expect(selection.key, icon.id.value);
    expect(find.bySemanticsLabel('Generic Battery'), findsOneWidget);
    expect(find.bySemanticsLabel('Fleet Cell'), findsNothing);
    expect(logs.severeRecords, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unexpected custom repository failure logs once and falls back',
      (tester) async {
    final logs = _LogService();
    addTearDown(logs.close);
    final icon = await _createCustomIcon(
      repository,
      ids,
      relativePath: 'custom_icons/database-failure/source.svg',
    );
    await database.customStatement(
      'ALTER TABLE custom_icons RENAME TO unavailable_custom_icons',
    );

    await _pump(
      tester,
      root: root,
      repository: repository,
      selection: IconSelection(
        source: IconSource.custom,
        key: icon.id.value,
        color: IconColor.brown,
      ),
      logs: logs,
    );

    expect(find.bySemanticsLabel('Generic Battery'), findsOneWidget);
    expect(find.textContaining('SqliteException'), findsNothing);
    expect(logs.severeRecords, hasLength(1));
    expect(logs.scopes, ['battery_types.ui']);
    expect(logs.severeRecords.single.message, 'Battery Type operation failed.');
    expect(logs.severeRecords.single.error, isNotNull);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(logs.severeRecords, hasLength(1));
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pump(
  WidgetTester tester, {
  required Directory root,
  required DriftIconRepository repository,
  required IconSelection selection,
  _LogService? logs,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        iconRepositoryProvider.overrideWithValue(repository),
        applicationSupportRootProvider.overrideWithValue(root.uri),
        appLogServiceProvider.overrideWithValue(logs ?? _LogService()),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: BatteryTypeIcon(selection: selection, size: 64),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
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

Future<dynamic> _createCustomIcon(
  DriftIconRepository repository,
  _Ids ids, {
  required String relativePath,
}) async {
  final category = await repository.createCategory(
    id: ids.next(),
    name: 'Battery markings ${relativePath.hashCode}',
    scope: IconScope.battery,
  );
  return repository.createCustomIcon(
    id: ids.next(),
    name: 'Fleet Cell',
    categoryId: category.id,
    relativePath: ManagedRelativePath.parse(relativePath),
    fileType: IconFileType.svg,
    supportsColor: true,
  );
}

const _svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">'
    '<path d="M8 8h40v48H8z" fill="#000000"/></svg>';

final class _Ids implements PermanentIdGenerator {
  var _next = 1;

  @override
  PermanentId next() {
    final tail = _next.toString().padLeft(12, '0');
    _next++;
    return PermanentId.parse('91000000-0000-4000-8000-$tail');
  }
}
