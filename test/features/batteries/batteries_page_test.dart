import 'dart:io';
import 'package:battery_tracker/app/app_providers.dart';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/features/batteries/data/drift_battery_repository.dart';
import 'package:battery_tracker/features/batteries/domain/battery.dart';
import 'package:battery_tracker/features/batteries/domain/battery_inventory_query.dart';
import 'package:battery_tracker/features/batteries/presentation/batteries_page.dart';
import 'package:battery_tracker/features/battery_types/data/drift_battery_type_repository.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftBatteryRepository repository;
  late DriftIconRepository icons;
  late DriftBatteryTypeRepository types;
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    icons = DriftIconRepository(
        database: db,
        idGenerator: const UuidV4PermanentIdGenerator(),
        builtInRegistry:
            IconRegistry(builtIns: BuiltInIconRegistry.definitions));
    repository = DriftBatteryRepository(database: db, iconRepository: icons);
    types = DriftBatteryTypeRepository(
        database: db,
        idGenerator: const UuidV4PermanentIdGenerator(),
        iconRepository: icons);
  });
  tearDown(() => db.close());
  Future<void> pump(WidgetTester tester, {bool dark = false}) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
        overrides: [
          batteryRepositoryProvider.overrideWithValue(repository),
          batteryTypeRepositoryProvider.overrideWithValue(types),
          iconRepositoryProvider.overrideWithValue(icons),
          applicationSupportRootProvider
              .overrideWithValue(Directory.systemTemp.uri)
        ],
        child: MaterialApp(
            theme: ThemeData(
                brightness: dark ? Brightness.dark : Brightness.light),
            home: const Scaffold(body: BatteriesPage()))));
    await tester.pumpAndSettle();
  }

  testWidgets('add edit table cards and search persist without photographs',
      (tester) async {
    await pump(tester);
    expect(find.text('Add your first Battery. A photograph is optional.'),
        findsOneWidget);
    await tester.tap(find.text('Add Battery'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const ValueKey('battery-userBatteryId')), 'AA-001');
    await tester.tap(find.text('Save Battery'));
    await tester.pumpAndSettle();
    final initial = (await repository.list()).single;
    await tester.ensureVisible(find.text('AA-001'));
    await tester.tap(find.text('AA-001'));
    await tester.pumpAndSettle();
    expect(find.textContaining(initial.id.value), findsOneWidget);
    await tester.tap(find.text('Edit Battery'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const ValueKey('battery-userBatteryId')), 'AA-002');
    await tester.tap(find.text('Save Battery'));
    await tester.pumpAndSettle();
    expect((await repository.list()).single.id, initial.id);
    await tester.ensureVisible(find.text('Cards'));
    await tester.tap(find.text('Cards'));
    await tester.pumpAndSettle();
    expect(find.text('View details'), findsOneWidget);
    await tester.enterText(
        find.widgetWithText(TextField, 'Search Batteries'), 'missing');
    await tester.pumpAndSettle();
    expect(find.text('No Batteries match these filters.'), findsOneWidget);
  });
  testWidgets('dark mode validation retains unsaved values', (tester) async {
    await pump(tester, dark: true);
    await tester.tap(find.text('Add Battery'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Battery'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a Battery ID.'), findsOneWidget);
    expect(await repository.list(), isEmpty);
  });
  test(
      'inventory query combines filters search and ordering without changing source',
      () async {
    final a = await repository.save(const BatteryDraft(
        userBatteryId: 'AA-002', manufacturer: 'Acme', status: 'Storage'));
    final b = await repository.save(
        const BatteryDraft(userBatteryId: 'AA-001', manufacturer: 'Acme'));
    final records = [a, b];
    expect(
        BatteryInventoryQuery.apply(records, [],
            search: 'acME', filters: {'Status': 'Storage'}).single.id,
        a.id);
    expect(BatteryInventoryQuery.apply(records, []).first.id, b.id);
    expect(BatteryInventoryQuery.apply(records, [], descending: true).first.id,
        a.id);
    expect(records.first.id, a.id);
    expect(
        BatteryInventoryQuery.apply(records, [], filters: {
          'Device Assignment': 'Unassigned',
          'Battery Set': 'No Set'
        }).length,
        2);
  });
  testWidgets(
      'a large inventory renders, searches, and paginates without failing',
      (tester) async {
    for (var i = 0; i < 500; i++) {
      await repository.save(BatteryDraft(
          userBatteryId: 'BULK-${i.toString().padLeft(4, '0')}',
          manufacturer: i.isEven ? 'Acme' : 'Contoso'));
    }
    await pump(tester);
    expect(find.textContaining('500'), findsWidgets);
    await tester.enterText(
        find.widgetWithText(TextField, 'Search Batteries'), 'BULK-0499');
    await tester.pumpAndSettle();
    expect(find.text('BULK-0499'), findsWidgets);
    expect(find.text('BULK-0000'), findsNothing);
    await tester.enterText(
        find.widgetWithText(TextField, 'Search Batteries'), '');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
