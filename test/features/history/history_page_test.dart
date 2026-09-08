import 'dart:io';
import 'package:battery_tracker/app/app_providers.dart';
import 'package:battery_tracker/app/navigation/app_shell.dart';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/features/battery_sets/data/drift_battery_set_repository.dart';
import 'package:battery_tracker/features/battery_types/data/drift_battery_type_repository.dart';
import 'package:battery_tracker/features/batteries/data/drift_battery_repository.dart';
import 'package:battery_tracker/features/batteries/domain/battery.dart';
import 'package:battery_tracker/features/dashboard/data/drift_dashboard_repository.dart';
import 'package:battery_tracker/features/history/data/drift_history_repository.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftHistoryRepository history;
  late DriftBatteryRepository batteries;
  late DriftIconRepository icons;
  String uuid() => const UuidV4PermanentIdGenerator().next().value;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    history = DriftHistoryRepository(db);
    icons = DriftIconRepository(
        database: db,
        idGenerator: const UuidV4PermanentIdGenerator(),
        builtInRegistry:
            IconRegistry(builtIns: BuiltInIconRegistry.definitions));
    batteries = DriftBatteryRepository(database: db, iconRepository: icons);
  });
  tearDown(() => db.close());

  Future<void> pump(WidgetTester t,
      {bool dark = false, double width = 1300}) async {
    t.view.physicalSize = Size(width, 1100);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(ProviderScope(
        overrides: [
          historyRepositoryProvider.overrideWithValue(history),
          dashboardRepositoryProvider
              .overrideWithValue(DriftDashboardRepository(db)),
          batteryRepositoryProvider.overrideWithValue(batteries),
          iconRepositoryProvider.overrideWithValue(icons),
          applicationSupportRootProvider
              .overrideWithValue(Directory.systemTemp.uri),
          batterySetRepositoryProvider.overrideWithValue(
              DriftBatterySetRepository(
                  db: db, batteries: batteries, icons: icons)),
          batteryTypeRepositoryProvider.overrideWithValue(
              DriftBatteryTypeRepository(
                  database: db,
                  idGenerator: const UuidV4PermanentIdGenerator(),
                  iconRepository: icons)),
        ],
        child: MaterialApp(
            theme: ThemeData(
                brightness: dark ? Brightness.dark : Brightness.light),
            home: const AppShell())));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('destination-history')));
    await t.pumpAndSettle();
  }

  Future<void> event(
          {required String entityType,
          required String entityUuid,
          required String eventType,
          required String summary,
          DateTime? at}) =>
      db.into(db.activityLog).insert(ActivityLogCompanion.insert(
          uuid: uuid(),
          eventType: eventType,
          entityType: entityType,
          entityUuid: entityUuid,
          summary: summary,
          occurredAt: Value(at ?? DateTime.utc(2026, 1, 1))));

  testWidgets('empty History shows a plain-language empty state', (t) async {
    await pump(t);
    expect(find.textContaining('No activity recorded yet.'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets(
      'recorded activity lists newest first and opens the related Battery',
      (t) async {
    final battery = await batteries
        .save(const BatteryDraft(userBatteryId: 'AA-001', name: 'Radio spare'));
    await event(
        entityType: 'battery',
        entityUuid: battery.id.value,
        eventType: 'battery_charged',
        summary: 'Charge recorded.',
        at: DateTime.utc(2026, 2, 1));
    await pump(t);
    expect(find.text('Battery created.'), findsOneWidget);
    expect(find.text('Charge recorded.'), findsOneWidget);
    expect(find.textContaining('Showing'), findsOneWidget);
    await t.tap(find.text('Charge recorded.'));
    await t.pumpAndSettle();
    expect(find.textContaining('AA-001'), findsWidgets);
    expect(t.takeException(), isNull);
  });

  testWidgets('Activity Type filter narrows the list and Clear restores it',
      (t) async {
    await event(
        entityType: 'battery',
        entityUuid: uuid(),
        eventType: 'battery_created',
        summary: 'Battery created.');
    await event(
        entityType: 'battery',
        entityUuid: uuid(),
        eventType: 'battery_charged',
        summary: 'Charge recorded.');
    await pump(t);
    expect(find.text('Battery created.'), findsOneWidget);
    expect(find.text('Charge recorded.'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('history-filter-category')));
    await t.pumpAndSettle();
    await t.tap(find.text('Charge History').last);
    await t.pumpAndSettle();
    expect(find.text('Charge recorded.'), findsOneWidget);
    expect(find.text('Battery created.'), findsNothing);
    await t.tap(find.text('Clear filters'));
    await t.pumpAndSettle();
    expect(find.text('Battery created.'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('deleted-record activity remains visible but is not tappable',
      (t) async {
    final battery =
        await batteries.save(const BatteryDraft(userBatteryId: 'Gone'));
    await (db.update(db.batteries)
          ..where((r) => r.uuid.equals(battery.id.value)))
        .write(BatteriesCompanion(deletedAt: Value(DateTime.now().toUtc())));
    await pump(t);
    final tile = t.widget<ListTile>(find.ancestor(
        of: find.text('Battery created.'), matching: find.byType(ListTile)));
    expect(tile.onTap, isNull);
    expect(t.takeException(), isNull);
  });

  testWidgets('dark narrow layout renders without exceptions', (t) async {
    await event(
        entityType: 'device',
        entityUuid: uuid(),
        eventType: 'device_created',
        summary: 'Device created.');
    await pump(t, dark: true, width: 800);
    expect(find.text('Device created.'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
