import 'dart:io';
import 'package:battery_tracker/app/app_providers.dart';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/features/batteries/data/drift_battery_repository.dart';
import 'package:battery_tracker/features/batteries/domain/battery.dart';
import 'package:battery_tracker/features/battery_sets/data/drift_battery_set_repository.dart';
import 'package:battery_tracker/features/bulk_operations/data/drift_bulk_creation_repository.dart';
import 'package:battery_tracker/features/bulk_operations/presentation/bulk_creation_dialog.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftBatteryRepository batteries;
  late DriftBatterySetRepository sets;
  late DriftBulkCreationRepository bulk;
  late DriftIconRepository icons;
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    icons = DriftIconRepository(
        database: db,
        idGenerator: const UuidV4PermanentIdGenerator(),
        builtInRegistry:
            IconRegistry(builtIns: BuiltInIconRegistry.definitions));
    batteries = DriftBatteryRepository(database: db, iconRepository: icons);
    sets =
        DriftBatterySetRepository(db: db, batteries: batteries, icons: icons);
    bulk =
        DriftBulkCreationRepository(db: db, batteries: batteries, sets: sets);
  });
  tearDown(() => db.close());
  Future<void> pump(WidgetTester t,
      {bool dark = false, double width = 1200}) async {
    t.view.physicalSize = Size(width, 1100);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(ProviderScope(
        overrides: [
          batteryRepositoryProvider.overrideWithValue(batteries),
          batterySetRepositoryProvider.overrideWithValue(sets),
          bulkCreationRepositoryProvider.overrideWithValue(bulk),
          iconRepositoryProvider.overrideWithValue(icons),
          applicationSupportRootProvider
              .overrideWithValue(Directory.systemTemp.uri)
        ],
        child: MaterialApp(
            theme: ThemeData(
                brightness: dark ? Brightness.dark : Brightness.light),
            home: const Scaffold(body: BulkCreationDialog(types: [])))));
    await t.pumpAndSettle();
  }

  Future<void> tap(WidgetTester t, String text) async {
    await t.ensureVisible(find.text(text).last);
    await t.tap(find.text(text).last);
    await t.pumpAndSettle();
  }

  testWidgets(
      'preview saves nothing until confirmation and row ID edit persists',
      (t) async {
    await pump(t);
    await tap(t, 'Generate preview');
    expect(await batteries.list(), isEmpty);
    await t.ensureVisible(find.byKey(const ValueKey('bulk-edit-0')));
    await t.tap(find.byKey(const ValueKey('bulk-edit-0')));
    await t.pumpAndSettle();
    await t.enterText(
        find.byKey(const ValueKey('battery-userBatteryId')), 'CUSTOM-1');
    await tap(t, 'Use these values');
    expect(await batteries.list(), isEmpty);
    await tap(t, 'Confirm preview and save');
    expect(await batteries.list(), hasLength(4));
    expect(
        (await batteries.list())
            .any((b) => b.values.userBatteryId == 'CUSTOM-1'),
        isTrue);
    expect(find.text('Created 4 Batteries and 0 Sets.'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets('duplicates are displayed and explicit skip reduces preview',
      (t) async {
    await batteries.save(const BatteryDraft(userBatteryId: 'AA-001'));
    await pump(t);
    await tap(t, 'Generate preview');
    expect(find.textContaining('Duplicate IDs:'), findsOneWidget);
    await tap(t, 'Skip Existing IDs');
    expect(find.text('Preview: 3 Batteries'), findsOneWidget);
    await tap(t, 'Confirm preview and save');
    expect(await batteries.list(), hasLength(4));
  });
  testWidgets(
      'next available preview and regeneration cancellation preserve edits',
      (t) async {
    await batteries.save(const BatteryDraft(userBatteryId: 'AA-001'));
    await pump(t);
    await tap(t, 'Use Next Available IDs');
    expect(find.text('AA-002'), findsOneWidget);
    await tap(t, 'Generate preview');
    await tap(t, 'Cancel');
    expect(find.text('AA-002'), findsOneWidget);
    expect(await batteries.list(), hasLength(1));
  });
  testWidgets('shared price Batch and new Set persist in dark narrow layout',
      (t) async {
    await pump(t, dark: true, width: 700);
    await tap(t, 'Edit shared fields, icon and color');
    await t.ensureVisible(find.byKey(const ValueKey('battery-batchCode')));
    await t.enterText(
        find.byKey(const ValueKey('battery-batchCode')), 'BATCH-1');
    await t.ensureVisible(find.byKey(const ValueKey('battery-purchasePrice')));
    await t.enterText(
        find.byKey(const ValueKey('battery-purchasePrice')), '20');
    await tap(t, 'Use these values');
    await tap(t, 'Purchase price is the total purchase price');
    await tap(t, 'Create Battery Set');
    await t.enterText(find.byKey(const ValueKey('bulk-set-id')), 'SET-001');
    await t.enterText(find.byKey(const ValueKey('bulk-set-name')), 'Radio');
    await tap(t, 'Add preview Set');
    await tap(t, 'Generate preview');
    await tap(t, 'Confirm preview and save');
    expect((await sets.list()).single.members, hasLength(4));
    for (final b in await batteries.list()) {
      expect(b.values.batchCode, 'BATCH-1');
      expect(b.values.perBatteryPrice, 5);
      expect(b.values.totalPackagePrice, 20);
    }
    expect(t.takeException(), isNull);
  });
  testWidgets(
      'collision after preview shows clear failure and preserves preview',
      (t) async {
    await pump(t);
    await tap(t, 'Generate preview');
    await batteries.save(const BatteryDraft(userBatteryId: 'AA-004'));
    await tap(t, 'Confirm preview and save');
    expect(find.textContaining('Battery IDs already exist'), findsOneWidget);
    expect(await batteries.list(), hasLength(1));
    expect(find.text('Preview: 4 Batteries'), findsOneWidget);
  });
}
