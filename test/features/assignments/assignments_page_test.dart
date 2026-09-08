import 'dart:io';
import 'package:battery_tracker/app/app_providers.dart';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/core/logging/app_log_service.dart';
import 'package:battery_tracker/features/batteries/data/drift_battery_repository.dart';
import 'package:battery_tracker/features/batteries/domain/battery.dart';
import 'package:battery_tracker/features/battery_sets/data/drift_battery_set_repository.dart';
import 'package:battery_tracker/features/battery_sets/domain/battery_set.dart';
import 'package:battery_tracker/features/devices/data/drift_device_repository.dart';
import 'package:battery_tracker/features/devices/domain/device.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:battery_tracker/features/assignments/data/drift_assignment_repository.dart';
import 'package:battery_tracker/features/assignments/presentation/assignments_page.dart';
import 'package:battery_tracker/features/assignments/presentation/assignment_date_field.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

void main() {
  late AppDatabase db;
  late DriftBatteryRepository batteries;
  late DriftBatterySetRepository sets;
  late DriftDeviceRepository devices;
  late DriftAssignmentRepository repo;
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final icons = DriftIconRepository(
        database: db,
        idGenerator: const UuidV4PermanentIdGenerator(),
        builtInRegistry:
            IconRegistry(builtIns: BuiltInIconRegistry.definitions));
    batteries = DriftBatteryRepository(database: db, iconRepository: icons);
    sets =
        DriftBatterySetRepository(db: db, batteries: batteries, icons: icons);
    devices = DriftDeviceRepository(db: db, batteries: batteries, icons: icons);
    repo = DriftAssignmentRepository(db: db);
  });
  tearDown(() => db.close());
  Future<void> pump(WidgetTester tester,
      {bool dark = false, PermanentId? deviceId}) async {
    tester.view.physicalSize = const Size(1050, 950);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
        overrides: [
          assignmentRepositoryProvider.overrideWithValue(repo),
          batteryRepositoryProvider.overrideWithValue(batteries),
          batterySetRepositoryProvider.overrideWithValue(sets),
          deviceRepositoryProvider.overrideWithValue(devices),
          applicationSupportRootProvider
              .overrideWithValue(Directory.systemTemp.uri),
          appLogServiceProvider.overrideWithValue(_Logs())
        ],
        child: MaterialApp(
            theme: ThemeData(
                brightness: dark ? Brightness.dark : Brightness.light),
            home: Scaffold(body: AssignmentsPage(deviceId: deviceId)))));
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label).last);
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  testWidgets(
      'select multiple Batteries backdate and remove with retained notes',
      (tester) async {
    await devices.save(const DeviceDraft(name: 'Radio', quantity: 2));
    await batteries.save(const BatteryDraft(userBatteryId: 'A'));
    await batteries.save(const BatteryDraft(userBatteryId: 'B'));
    await pump(tester);
    await tap(tester, 'New assignment');
    await tap(tester, 'A');
    await tap(tester, 'B');
    final date = DateTime.now().subtract(const Duration(days: 3));
    tester
        .widget<AssignmentDateField>(find.byType(AssignmentDateField))
        .onChanged(date);
    await tester.enterText(
        find.widgetWithText(TextField, 'Installation notes'), 'Installed pair');
    await tap(tester, 'Confirm assignment');
    expect(await repo.list(), hasLength(2));
    expect(
        (await repo.list()).every((r) => r.assignedAt == date.toUtc()), isTrue);
    final checks = find.byType(Checkbox);
    await tester.tap(checks.at(0));
    await tester.pump();
    await tester.tap(checks.at(1));
    await tester.pump();
    await tap(tester, 'Remove selected (2)');
    await tester.enterText(
        find.widgetWithText(TextField, 'Removal notes'), 'Removed pair');
    await tap(tester, 'Confirm removal');
    expect(
        (await repo.list()).every((r) =>
            r.removedAt != null &&
            r.notes == 'Installed pair' &&
            r.removalNotes == 'Removed pair'),
        isTrue);
    await tap(tester, 'Include history');
    expect(find.textContaining('Duration:'), findsNWidgets(2));
    expect(find.text('Removal notes: Removed pair'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'available filter show all and warning cancel preserve unsaved selection',
      (tester) async {
    await devices.save(const DeviceDraft(name: 'Radio'));
    await batteries.save(const BatteryDraft(userBatteryId: 'A'));
    await batteries
        .save(const BatteryDraft(userBatteryId: 'Stored', status: 'Storage'));
    await pump(tester, dark: true);
    await tap(tester, 'New assignment');
    expect(find.text('Stored'), findsNothing);
    await tap(tester, 'Show all Batteries');
    await tap(tester, 'Stored');
    await tap(tester, 'Confirm assignment');
    expect(find.text('Review compatibility warnings'), findsOneWidget);
    await tap(tester, 'Cancel');
    expect(await repo.list(), isEmpty);
    expect(find.text('1 selected'), findsOneWidget);
    await tap(tester, 'Confirm assignment');
    await tap(tester, 'Assign anyway');
    expect((await repo.list()).single.label, 'Stored');
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'Set selection creates linked rows and only whole Set is removable',
      (tester) async {
    await devices.save(const DeviceDraft(name: 'Radio'));
    final b = await batteries.save(const BatteryDraft(userBatteryId: 'A'));
    final s =
        await sets.save(const SetDraft(userSetId: 'SET-001', name: 'Pair'));
    await sets.addMember(s.id, b.id);
    await pump(tester);
    await tap(tester, 'New assignment');
    await tap(tester, 'Batteries');
    await tap(tester, 'Battery Set');
    await tester.tap(find.byType(DropdownButtonFormField<PermanentId>).last);
    await tester.pumpAndSettle();
    await tap(tester, 'SET-001 · Pair (1)');
    await tap(tester, 'Confirm assignment');
    expect(await repo.list(), hasLength(2));
    expect(find.text('Remove'), findsOneWidget);
    await tap(tester, 'Remove');
    await tap(tester, 'Cancel');
    expect((await repo.list()).every((r) => r.removedAt == null), isTrue);
    await tap(tester, 'Remove');
    await tap(tester, 'Confirm removal');
    expect((await repo.list()).every((r) => r.removedAt != null), isTrue);
    expect((await batteries.get(b.id)).values.status, 'In Set');
  });
  testWidgets(
      'invalid empty selection stays in editor and date controls are usable',
      (tester) async {
    await devices.save(const DeviceDraft(name: 'Radio'));
    await pump(tester);
    await tap(tester, 'New assignment');
    await tap(tester, 'Change date');
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tap(tester, 'Cancel');
    await tap(tester, 'Confirm assignment');
    expect(find.text('Choose Batteries or one Battery Set.'), findsOneWidget);
    expect(await repo.list(), isEmpty);
    expect(tester.takeException(), isNull);
  });
  testWidgets('inactive Device history context rejects new assignment clearly',
      (tester) async {
    final d = await devices.save(const DeviceDraft(name: 'Inactive'));
    await devices.setActive(d.id, false);
    await devices.save(const DeviceDraft(name: 'Active'));
    await pump(tester, deviceId: d.id);
    await tap(tester, 'New assignment');
    expect(find.text('Reactivate this Device before assigning inventory.'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _Logs implements AppLogService {
  @override
  Future<void> initialize() async {}
  @override
  Future<void> close() async {}
  @override
  Logger logger(String scope) => Logger('test.$scope');
}
