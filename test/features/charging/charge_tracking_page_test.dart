import 'package:battery_tracker/app/app_providers.dart';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/features/batteries/data/drift_battery_repository.dart';
import 'package:battery_tracker/features/batteries/domain/battery.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:battery_tracker/features/charging/data/drift_charge_repository.dart';
import 'package:battery_tracker/features/charging/presentation/charge_tracking_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftBatteryRepository batteries;
  late DriftChargeRepository charges;
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final icons = DriftIconRepository(
        database: db,
        idGenerator: const UuidV4PermanentIdGenerator(),
        builtInRegistry:
            IconRegistry(builtIns: BuiltInIconRegistry.definitions));
    batteries = DriftBatteryRepository(database: db, iconRepository: icons);
    charges = DriftChargeRepository(db: db);
  });
  tearDown(() => db.close());
  Future<void> pump(WidgetTester t,
      {PermanentId? id, bool dark = false, double width = 1000}) async {
    t.view.physicalSize = Size(width, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(ProviderScope(
        overrides: [
          batteryRepositoryProvider.overrideWithValue(batteries),
          chargeRepositoryProvider.overrideWithValue(charges)
        ],
        child: MaterialApp(
            theme: ThemeData(
                brightness: dark ? Brightness.dark : Brightness.light),
            home: Scaffold(body: ChargeTrackingPage(batteryId: id)))));
    await t.pumpAndSettle();
  }

  Future<void> tap(WidgetTester t, String text) async {
    await t.ensureVisible(find.text(text).last);
    await t.tap(find.text(text).last);
    await t.pumpAndSettle();
  }

  testWidgets('selected charge records two Batteries and shows details',
      (t) async {
    final a = await batteries.save(const BatteryDraft(userBatteryId: 'A'));
    await batteries.save(const BatteryDraft(userBatteryId: 'B'));
    await pump(t);
    for (final f in find.byType(Checkbox).evaluate().toList()) {
      await t.tap(find.byWidget(f.widget));
      await t.pumpAndSettle();
    }
    await tap(t, 'Mark Selected Charged');
    await t.enterText(find.byKey(const ValueKey('charge-start')), '25');
    await t.enterText(
        find.byKey(const ValueKey('charge-charger')), 'Desk dock');
    await t.enterText(
        find.byKey(const ValueKey('charge-notes')), 'Ready for shift');
    await tap(t, 'Confirm');
    expect(await charges.list(), hasLength(2));
    expect((await batteries.get(a.id)).recordedCharges, 1);
    expect(find.textContaining('Desk dock'), findsNWidgets(2));
    expect(t.takeException(), isNull);
  });
  testWidgets('individual validation cancel and default charge in dark mode',
      (t) async {
    final a = await batteries.save(const BatteryDraft(userBatteryId: 'A'));
    await pump(t, id: a.id, dark: true, width: 650);
    await tap(t, 'Mark Charged');
    await t.enterText(find.byKey(const ValueKey('charge-end')), 'abc');
    await tap(t, 'Confirm');
    expect(find.textContaining('Percentages must'), findsOneWidget);
    expect(await charges.list(), isEmpty);
    await tap(t, 'Cancel');
    await tap(t, 'Mark Charged');
    await tap(t, 'Confirm');
    expect((await charges.list()).single.endPercent, 100);
    expect((await batteries.get(a.id)).estimatedChargePercent, isNull);
    expect(t.takeException(), isNull);
  });
  testWidgets('manual estimate validates and saves without a Recorded Charge',
      (t) async {
    final a = await batteries.save(const BatteryDraft(userBatteryId: 'A'));
    await pump(t, id: a.id);
    await tap(t, 'Edit estimate');
    await t.enterText(find.byType(TextFormField), '101');
    await tap(t, 'Save estimate');
    expect(find.textContaining('Current estimate must'), findsOneWidget);
    await t.enterText(find.byType(TextFormField), '42');
    await tap(t, 'Save estimate');
    expect((await batteries.get(a.id)).estimatedChargePercent, 42);
    expect(await charges.list(), isEmpty);
    expect(find.textContaining('42%'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
