import 'dart:io';
import 'dart:ui' as ui;
import 'package:battery_tracker/app/app_providers.dart';
import 'package:battery_tracker/app/navigation/app_shell.dart';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/features/dashboard/data/drift_dashboard_repository.dart';
import 'package:battery_tracker/features/dashboard/domain/dashboard.dart';
import 'package:battery_tracker/features/batteries/data/drift_battery_repository.dart';
import 'package:battery_tracker/features/batteries/domain/battery.dart';
import 'package:battery_tracker/features/battery_sets/data/drift_battery_set_repository.dart';
import 'package:battery_tracker/features/battery_types/data/drift_battery_type_repository.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final path = Platform.environment['DASHBOARD_TEST_FONT'];
    if (path != null) {
      final loader = FontLoader('DashboardTest')
        ..addFont(
            File(path).readAsBytes().then((b) => ByteData.sublistView(b)));
      await loader.load();
      final material = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await material.load();
    }
  });
  late AppDatabase db;
  late DriftDashboardRepository repo;
  late DriftBatteryRepository batteries;
  late DriftIconRepository icons;
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DriftDashboardRepository(db);
    icons = DriftIconRepository(
        database: db,
        idGenerator: const UuidV4PermanentIdGenerator(),
        builtInRegistry:
            IconRegistry(builtIns: BuiltInIconRegistry.definitions));
    batteries = DriftBatteryRepository(database: db, iconRepository: icons);
  });
  tearDown(() => db.close());
  Future<void> pump(WidgetTester t,
      {bool dark = false,
      double width = 1300,
      DashboardRepository? repository}) async {
    t.view.physicalSize = Size(width, 1100);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(ProviderScope(
        overrides: [
          dashboardRepositoryProvider.overrideWithValue(repository ?? repo),
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
                  iconRepository: icons))
        ],
        child: MaterialApp(
            theme: ThemeData(
                brightness: dark ? Brightness.dark : Brightness.light,
                fontFamily: Platform.environment['DASHBOARD_TEST_FONT'] == null
                    ? null
                    : 'DashboardTest'),
            home: const RepaintBoundary(
                key: ValueKey('dashboard-image'), child: AppShell()))));
    await t.pumpAndSettle();
  }

  String count(WidgetTester t, String label) =>
      t.widget<Text>(find.byKey(ValueKey('dashboard-count-$label'))).data!;
  Future<void> tap(WidgetTester t, String label) async {
    await t.ensureVisible(find.text(label).last);
    await t.tap(find.text(label).last);
    await t.pumpAndSettle();
  }

  testWidgets(
      'empty dashboard has real zero cards and working inventory shortcut',
      (t) async {
    await pump(t);
    expect(count(t, 'Total Batteries'), '0');
    expect(find.text('No activity recorded yet.'), findsOneWidget);
    await tap(t, 'View Batteries');
    expect(find.text('Add your first Battery. A photograph is optional.'),
        findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets('live count and attention updates react to persisted edits',
      (t) async {
    await pump(t);
    final b = await batteries.save(const BatteryDraft(userBatteryId: 'Live'));
    await t.pumpAndSettle();
    expect(count(t, 'Total Batteries'), '1');
    expect(count(t, 'Batteries Needing Attention'), '0');
    await batteries.save(
        const BatteryDraft(userBatteryId: 'Live', condition: 'Poor'),
        id: b.id);
    await t.pumpAndSettle();
    expect(count(t, 'Batteries Needing Attention'), '1');
    expect(find.text('Condition: Poor'), findsOneWidget);
  });
  testWidgets(
      'attention record opens exact Battery details through navigation intent',
      (t) async {
    final b = await batteries
        .save(const BatteryDraft(userBatteryId: 'Inspect', condition: 'Poor'));
    await pump(t);
    await tap(t, 'Inspect');
    expect(find.text('Edit Battery'), findsOneWidget);
    expect(find.textContaining(b.id.value), findsWidgets);
    expect(t.takeException(), isNull);
  });
  testWidgets(
      'rules validate retain input and persist without changing inventory',
      (t) async {
    await pump(t);
    await tap(t, 'Attention rules');
    await t.enterText(find.byKey(const ValueKey('attention-rule-0')), '-1');
    await tap(t, 'Save rules');
    expect(find.textContaining('whole numbers from'), findsOneWidget);
    await t.enterText(find.byKey(const ValueKey('attention-rule-0')), '30');
    await t.enterText(find.byKey(const ValueKey('attention-rule-1')), '0');
    await tap(t, 'Save rules');
    expect((await repo.load()).policy.daysWithoutCharge, 30);
    expect((await repo.load()).policy.recordedChargeThreshold, 0);
    expect(await batteries.list(), isEmpty);
  });
  testWidgets('dark narrow layout filters retired and searches explanations',
      (t) async {
    await batteries.save(const BatteryDraft(
        userBatteryId: 'Damaged battery', condition: 'Damaged'));
    await batteries.save(const BatteryDraft(
        userBatteryId: 'Retired battery', status: 'Retired'));
    await pump(t, dark: true, width: 800);
    await tap(t, 'Include retired');
    expect(find.text('Retired battery'), findsNothing);
    await t.enterText(
        find.widgetWithText(TextField, 'Search attention list'), 'missing');
    await t.pumpAndSettle();
    expect(
        find.text('No attention records match these filters.'), findsOneWidget);
    expect(count(t, 'Batteries Needing Attention'), '2');
    expect(t.takeException(), isNull);
  });
  testWidgets(
      'query failure displays concise retry feedback without technical error',
      (t) async {
    await pump(t, repository: _Broken());
    expect(
        find.textContaining('Dashboard could not be loaded.'), findsOneWidget);
    expect(find.textContaining('private SQL details'), findsNothing);
    expect(find.byTooltip('Refresh dashboard'), findsOneWidget);
  });
  testWidgets('populated dashboard renders summary and optional review image',
      (t) async {
    await batteries
        .save(const BatteryDraft(userBatteryId: 'AA-001', name: 'Radio spare'));
    await batteries
        .save(const BatteryDraft(userBatteryId: 'AA-002', status: 'Charging'));
    await batteries
        .save(const BatteryDraft(userBatteryId: 'AA-003', condition: 'Poor'));
    await pump(t);
    expect(count(t, 'Total Batteries'), '3');
    expect(count(t, 'Batteries Charging'), '1');
    final path = Platform.environment['DASHBOARD_ARTIFACT'];
    if (path != null) {
      await t.runAsync(() async {
        final boundary = t.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('dashboard-image')));
        final image = await boundary.toImage();
        try {
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(path).writeAsBytes(bytes!.buffer.asUint8List());
        } finally {
          image.dispose();
        }
      });
    }
    expect(t.takeException(), isNull);
  });
}

class _Broken implements DashboardRepository {
  @override
  Future<DashboardSnapshot> load() =>
      Future.error(StateError('private SQL details'));
  @override
  Stream<DashboardSnapshot> watch() =>
      Stream.error(StateError('private SQL details'));
  @override
  Future<void> savePolicy(AttentionPolicy policy) async {}
}
