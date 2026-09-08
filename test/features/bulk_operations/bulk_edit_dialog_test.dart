import 'dart:io';
import 'package:battery_tracker/app/app_providers.dart';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/features/batteries/data/drift_battery_repository.dart';
import 'package:battery_tracker/features/batteries/domain/battery.dart';
import 'package:battery_tracker/features/batteries/presentation/batteries_page.dart';
import 'package:battery_tracker/features/battery_types/data/drift_battery_type_repository.dart';
import 'package:battery_tracker/features/battery_sets/data/drift_battery_set_repository.dart';
import 'package:battery_tracker/features/bulk_operations/data/drift_bulk_edit_repository.dart';
import 'package:battery_tracker/features/bulk_operations/domain/bulk_edit.dart';
import 'package:battery_tracker/features/bulk_operations/presentation/bulk_edit_dialog.dart';
import 'package:battery_tracker/features/charging/data/drift_charge_repository.dart';
import 'package:battery_tracker/features/assignments/presentation/assignment_date_field.dart';
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
  late DriftBulkEditRepository bulk;
  late DriftIconRepository icons;
  late DriftChargeRepository charges;
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
    bulk = DriftBulkEditRepository(
        db: db, batteries: batteries, sets: sets, icons: icons);
    charges = DriftChargeRepository(db: db);
  });
  tearDown(() => db.close());
  Future<void> pump(WidgetTester t,
      {List<PermanentId>? ids,
      BulkEditAction action = BulkEditAction.status,
      bool dark = false,
      double width = 1200}) async {
    t.view.physicalSize = Size(width, 1100);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(ProviderScope(
        overrides: [
          batteryRepositoryProvider.overrideWithValue(batteries),
          batterySetRepositoryProvider.overrideWithValue(sets),
          bulkEditRepositoryProvider.overrideWithValue(bulk),
          chargeRepositoryProvider.overrideWithValue(charges),
          batteryTypeRepositoryProvider.overrideWithValue(
              DriftBatteryTypeRepository(
                  database: db,
                  idGenerator: const UuidV4PermanentIdGenerator(),
                  iconRepository: icons)),
          iconRepositoryProvider.overrideWithValue(icons),
          applicationSupportRootProvider
              .overrideWithValue(Directory.systemTemp.uri)
        ],
        child: MaterialApp(
            theme: ThemeData(
                brightness: dark ? Brightness.dark : Brightness.light),
            home: Scaffold(
                body: ids == null
                    ? const BatteriesPage()
                    : BulkEditDialog(
                        ids: ids, types: const [], initialAction: action)))));
    await t.pumpAndSettle();
  }

  Future<void> tap(WidgetTester t, String text) async {
    await t.ensureVisible(find.text(text).last);
    await t.tap(find.text(text).last);
    await t.pumpAndSettle();
  }

  Future<BatteryRecord> battery(String id) =>
      batteries.save(BatteryDraft(userBatteryId: id, notes: 'Original'));
  testWidgets(
      'two-Battery preview displays old and new values before confirmation',
      (t) async {
    final a = await battery('A'), b = await battery('B');
    await pump(t, ids: [a.id, b.id]);
    await tap(t, 'Preview changes');
    expect(find.text('Before: Available'), findsNWidgets(2));
    expect(find.text('After: Storage'), findsNWidgets(2));
    expect((await batteries.get(a.id)).values.status, 'Available');
    await tap(t, 'Confirm changes');
    expect((await batteries.get(a.id)).values.status, 'Storage');
    expect((await batteries.get(b.id)).values.status, 'Storage');
    expect(find.text('All changes saved successfully.'), findsOneWidget);
  });
  testWidgets('back from preview keeps notes draft and writes nothing',
      (t) async {
    final a = await battery('A');
    await pump(t, ids: [a.id], action: BulkEditAction.note);
    await t.enterText(find.byKey(const ValueKey('bulk-edit-value')), 'Shared');
    await tap(t, 'Preview changes');
    expect(find.text('After: Original\nShared'), findsOneWidget);
    await tap(t, 'Back to changes');
    expect((await batteries.get(a.id)).values.notes, 'Original');
    expect(
        t
            .widget<TextField>(find.byKey(const ValueKey('bulk-edit-value')))
            .controller!
            .text,
        'Shared');
  });
  testWidgets(
      'invalid purchase price is rejected and clear only affects chosen field',
      (t) async {
    final a = await batteries.save(const BatteryDraft(
        userBatteryId: 'A', purchasePrice: 5, purchaseLocation: 'Store'));
    await pump(t, ids: [a.id], action: BulkEditAction.purchasePrice);
    await t.enterText(find.byKey(const ValueKey('bulk-edit-value')), '-1');
    await tap(t, 'Preview changes');
    expect(find.textContaining('nonnegative price'), findsOneWidget);
    await t.enterText(find.byKey(const ValueKey('bulk-edit-value')), '');
    await tap(t, 'Preview changes');
    await tap(t, 'Confirm changes');
    expect((await batteries.get(a.id)).values.purchasePrice, isNull);
    expect((await batteries.get(a.id)).values.purchaseLocation, 'Store');
  });
  testWidgets(
      'retirement reason and date survive confirmation in dark narrow view',
      (t) async {
    final a = await battery('A');
    await pump(t,
        ids: [a.id], action: BulkEditAction.retire, dark: true, width: 650);
    final date = DateTime.utc(2026, 8, 1);
    t
        .widget<AssignmentDateField>(find.byType(AssignmentDateField))
        .onChanged(date);
    await tap(t, 'Preview changes');
    expect((await batteries.get(a.id)).values.status, 'Available');
    await tap(t, 'Confirm changes');
    final r = await batteries.get(a.id);
    expect(r.retiredAt, date);
    expect(r.retirementReason, 'Capacity loss');
    expect(t.takeException(), isNull);
  });
  testWidgets(
      'filtered selection edits only selected records and selected charging works',
      (t) async {
    final a = await battery('AA-001'), b = await battery('BB-001');
    await pump(t);
    await t.enterText(
        find.widgetWithText(TextField, 'Search Batteries'), 'AA-');
    await t.pumpAndSettle();
    await tap(t, 'Select filtered');
    expect(find.text('1 selected'), findsOneWidget);
    await tap(t, 'Bulk Edit');
    await tap(t, 'Preview changes');
    await tap(t, 'Confirm changes');
    await tap(t, 'Done');
    expect((await batteries.get(a.id)).values.status, 'Storage');
    expect((await batteries.get(b.id)).values.status, 'Available');
    await tap(t, 'Mark Selected Charged');
    await tap(t, 'Confirm');
    expect((await batteries.get(a.id)).recordedCharges, 1);
    expect((await batteries.get(b.id)).recordedCharges, 0);
    expect(t.takeException(), isNull);
  });
  testWidgets('stale preview displays error and applies no edit', (t) async {
    final a = await battery('A');
    await pump(t, ids: [a.id]);
    await tap(t, 'Preview changes');
    await batteries.save(const BatteryDraft(userBatteryId: 'Changed'),
        id: a.id);
    await tap(t, 'Confirm changes');
    expect(
        find.textContaining('Inventory changed after preview'), findsOneWidget);
    expect((await batteries.get(a.id)).values.status, 'Available');
  });
}
