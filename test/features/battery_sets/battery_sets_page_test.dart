import 'package:battery_tracker/features/charging/data/drift_charge_repository.dart';
import 'dart:io';
import 'package:battery_tracker/app/app_providers.dart';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/features/batteries/data/drift_battery_repository.dart';
import 'package:battery_tracker/features/batteries/domain/battery.dart';
import 'package:battery_tracker/features/battery_sets/data/drift_battery_set_repository.dart';
import 'package:battery_tracker/features/battery_sets/domain/battery_set.dart';
import 'package:battery_tracker/features/battery_sets/presentation/battery_sets_page.dart';
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
  late DriftBatteryRepository batteries;
  late DriftBatterySetRepository sets;
  late DriftIconRepository icons;
  late DriftBatteryTypeRepository types;
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
    types = DriftBatteryTypeRepository(
        database: db,
        idGenerator: const UuidV4PermanentIdGenerator(),
        iconRepository: icons);
  });
  tearDown(() => db.close());
  Future<void> pump(WidgetTester tester, {bool dark = false}) async {
    tester.view.physicalSize = const Size(1200, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
        overrides: [
          batterySetRepositoryProvider.overrideWithValue(sets),
          batteryRepositoryProvider.overrideWithValue(batteries),
          batteryTypeRepositoryProvider.overrideWithValue(types),
          chargeRepositoryProvider
              .overrideWithValue(DriftChargeRepository(db: db)),
          iconRepositoryProvider.overrideWithValue(icons),
          applicationSupportRootProvider
              .overrideWithValue(Directory.systemTemp.uri)
        ],
        child: MaterialApp(
            theme: ThemeData(
                brightness: dark ? Brightness.dark : Brightness.light),
            home: const Scaffold(body: BatterySetsPage()))));
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label).last);
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  testWidgets('create suggest rename and dark mode validation preserve UUID',
      (tester) async {
    await pump(tester, dark: true);
    await tap(tester, 'Add Set');
    await tap(tester, 'Save Set');
    expect(find.text('Enter a Set ID and name.'), findsOneWidget);
    await tap(tester, 'Suggest Set ID');
    await tester.enterText(
        find.byKey(const ValueKey('set-name')), 'Radio Spares');
    await tap(tester, 'Save Set');
    final initial = (await sets.list()).single;
    expect(initial.values.userSetId, 'SET-001');
    expect(find.textContaining(initial.id.value), findsOneWidget);
    await tap(tester, 'Edit Set');
    await tester.enterText(find.byKey(const ValueKey('set-id')), 'RADIO-001');
    await tap(tester, 'Save Set');
    expect((await sets.list()).single.id, initial.id);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'add member charge and remove create real history through dialogs',
      (tester) async {
    final s = await sets
        .save(const SetDraft(userSetId: 'SET-001', name: 'Controller'));
    final b = await batteries.save(const BatteryDraft(
        userBatteryId: 'AA-001',
        manufacturer: 'Acme',
        capacity: 2500,
        capacityUnit: 'mAh'));
    await pump(tester);
    await tap(tester, 'SET-001 · Controller');
    await tap(tester, 'Add / Move Battery');
    await tap(tester, 'Add Battery');
    expect((await sets.get(s.id)).members.single.id, b.id);
    expect(find.textContaining('Acme'), findsOneWidget);
    await tap(tester, 'Mark Entire Set Charged');
    await tap(tester, 'Confirm');
    expect((await batteries.get(b.id)).recordedCharges, 1);
    await tester.ensureVisible(find.byTooltip('Remove AA-001'));
    await tester.tap(find.byTooltip('Remove AA-001'));
    await tester.pumpAndSettle();
    await tap(tester, 'Confirm');
    expect((await sets.get(s.id)).members, isEmpty);
    expect(
        (await sets.get(s.id)).membershipHistory.single.removedAt, isNotNull);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'cancel compatibility warning writes nothing and acknowledgment adds member',
      (tester) async {
    final s =
        await sets.save(const SetDraft(userSetId: 'SET-001', name: 'Mixed'));
    final a = await batteries
        .save(const BatteryDraft(userBatteryId: 'A', nominalVoltage: 1.2));
    final b = await batteries
        .save(const BatteryDraft(userBatteryId: 'B', nominalVoltage: 3.7));
    await sets.addMember(s.id, a.id);
    await pump(tester);
    await tap(tester, 'SET-001 · Mixed');
    await tap(tester, 'Add / Move Battery');
    await tap(tester, 'Add Battery');
    expect(find.text('Review compatibility warnings'), findsOneWidget);
    await tap(tester, 'Cancel');
    expect((await sets.get(s.id)).members.length, 1);
    await tap(tester, 'Add / Move Battery');
    await tap(tester, 'Add Battery');
    await tap(tester, 'Confirm');
    expect((await sets.get(s.id)).members.map((m) => m.id), contains(b.id));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'matching assignment and removal update member Device with confirmations',
      (tester) async {
    final s = await sets
        .save(const SetDraft(userSetId: 'SET-001', name: 'Controller'));
    final b = await batteries.save(const BatteryDraft(userBatteryId: 'A'));
    await sets.addMember(s.id, b.id);
    await sets.createDevice('Gamepad', quantity: 1);
    await pump(tester);
    await tap(tester, 'SET-001 · Controller');
    await tap(tester, 'Assign Set to Device');
    await tap(tester, 'Gamepad');
    expect(find.textContaining('matches the configured Device requirements'),
        findsOneWidget);
    await tap(tester, 'Confirm');
    expect((await batteries.get(b.id)).currentDevices, ['Gamepad']);
    await tap(tester, 'Remove Set from Device');
    await tap(tester, 'Confirm');
    expect((await batteries.get(b.id)).currentDevices, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
