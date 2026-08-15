import 'dart:io';

import 'package:battery_tracker/app/app_providers.dart';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/core/logging/app_log_service.dart';
import 'package:battery_tracker/features/battery_types/data/drift_battery_type_repository.dart';
import 'package:battery_tracker/features/battery_types/domain/battery_type.dart';
import 'package:battery_tracker/features/battery_types/domain/battery_type_draft.dart';
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

  testWidgets('reactivation conflict shows concise copy without raw exception',
      (tester) async {
    final inactive = await repository.create(_draft(typeName: 'AA NiMH'));
    await repository.deactivate(inactive.id);
    await repository.create(_draft(typeName: 'AA NiMH'));
    await _pumpPage(tester, root: root, icons: icons, repository: repository);
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
  required DriftBatteryTypeRepository repository,
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
        appLogServiceProvider.overrideWithValue(_LogService()),
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
    return PermanentId.parse('92000000-0000-4000-8000-$tail');
  }
}
