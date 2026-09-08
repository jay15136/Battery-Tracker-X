import 'dart:io';
import 'package:battery_tracker/app/app_providers.dart';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/core/logging/app_log_service.dart';
import 'package:battery_tracker/features/batteries/data/drift_battery_repository.dart';
import 'package:battery_tracker/features/batteries/domain/battery.dart';
import 'package:battery_tracker/features/battery_sets/data/drift_battery_set_repository.dart';
import 'package:battery_tracker/features/battery_sets/domain/battery_set.dart';
import 'package:battery_tracker/features/battery_types/data/drift_battery_type_repository.dart';
import 'package:battery_tracker/features/devices/data/drift_device_repository.dart';
import 'package:battery_tracker/features/devices/domain/device.dart';
import 'package:battery_tracker/features/devices/presentation/devices_page.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:battery_tracker/features/photos/data/drift_photo_repository.dart';
import 'package:battery_tracker/features/photos/data/local_photo_storage.dart';
import 'package:battery_tracker/features/photos/application/photo_service.dart';
import 'package:battery_tracker/features/photos/domain/photo.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

void main() {
  late AppDatabase db;
  late Directory root;
  late DriftBatteryRepository batteries;
  late DriftBatterySetRepository sets;
  late DriftDeviceRepository devices;
  late DriftIconRepository icons;
  late DriftBatteryTypeRepository types;
  late PhotoService photos;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('device-ui-');
    db = AppDatabase.forTesting(NativeDatabase.memory());
    icons = DriftIconRepository(
        database: db,
        idGenerator: const UuidV4PermanentIdGenerator(),
        builtInRegistry:
            IconRegistry(builtIns: BuiltInIconRegistry.definitions));
    batteries = DriftBatteryRepository(database: db, iconRepository: icons);
    sets =
        DriftBatterySetRepository(db: db, batteries: batteries, icons: icons);
    devices = DriftDeviceRepository(db: db, batteries: batteries, icons: icons);
    types = DriftBatteryTypeRepository(
        database: db,
        idGenerator: const UuidV4PermanentIdGenerator(),
        iconRepository: icons);
    photos = PhotoService(
        repository: DriftPhotoRepository(db),
        storage: LocalPhotoStorage(root.uri),
        logger: Logger('test.photos'));
  });
  tearDown(() async {
    await db.close();
    await root.delete(recursive: true);
  });
  Future<void> pump(WidgetTester tester,
      {bool dark = false, Size size = const Size(1200, 1100)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
        overrides: [
          deviceRepositoryProvider.overrideWithValue(devices),
          batterySetRepositoryProvider.overrideWithValue(sets),
          batteryRepositoryProvider.overrideWithValue(batteries),
          batteryTypeRepositoryProvider.overrideWithValue(types),
          iconRepositoryProvider.overrideWithValue(icons),
          applicationSupportRootProvider.overrideWithValue(root.uri),
          photoServiceProvider.overrideWithValue(photos),
          appLogServiceProvider.overrideWithValue(_Logs())
        ],
        child: MaterialApp(
            theme: ThemeData(
                brightness: dark ? Brightness.dark : Brightness.light),
            home: const Scaffold(body: DevicesPage()))));
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label).last);
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, String field, String text) async {
    final target = find.byKey(ValueKey('device-$field'));
    await tester.ensureVisible(target);
    await tester.enterText(target, text);
    await tester.pump();
  }

  testWidgets('icon-only create edit custom category and search preserve UUID',
      (tester) async {
    await pump(tester);
    await tap(tester, 'Add Device');
    await enter(tester, 'Name', 'Patrol Radio');
    await enter(tester, 'Category', 'Patrol');
    await enter(tester, 'Location', 'Dispatch');
    await tap(tester, 'Save Device');
    final initial = (await devices.list()).single;
    expect(initial.values.icon.key, 'device_generic');
    expect(initial.photoPath, isNull);
    expect(find.textContaining(initial.id.value), findsOneWidget);
    await tap(tester, 'Edit Device');
    await enter(tester, 'Name', 'Spare Radio');
    await tap(tester, 'Save Device');
    expect((await devices.list()).single.id, initial.id);
    await tester
        .ensureVisible(find.widgetWithText(TextField, 'Search Devices'));
    await tester.enterText(
        find.widgetWithText(TextField, 'Search Devices'), 'missing');
    await tester.pumpAndSettle();
    expect(
        find.text(
            'No matching Devices. Add a Device with just a name and icon.'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('dark narrow form keeps numeric errors and unsaved fields',
      (tester) async {
    await pump(tester, dark: true, size: const Size(800, 700));
    await tap(tester, 'Add Device');
    await enter(tester, 'Name', 'Radio');
    await enter(tester, 'Required quantity', 'two');
    await tap(tester, 'Save Device');
    expect(find.text('Enter a whole number for Required quantity.'),
        findsOneWidget);
    expect(await devices.list(), isEmpty);
    await enter(tester, 'Required quantity', '2');
    await enter(tester, 'Required voltage', '1.2');
    await tap(tester, 'Save Device');
    expect((await devices.list()).single.values.name, 'Radio');
    expect((await devices.list()).single.values.quantity, 2);
    expect(tester.takeException(), isNull);
  });
  testWidgets('category selection never silently replaces the current icon',
      (tester) async {
    await pump(tester);
    await tap(tester, 'Add Device');
    await enter(tester, 'Name', 'Controller');
    await tap(tester, 'Gaming');
    await tap(tester, 'Save Device');
    expect((await devices.list()).single.values.icon.key, 'device_generic');
    await tap(tester, 'Edit Device');
    await tap(tester, 'Use suggested category icon and color');
    await tap(tester, 'Save Device');
    expect((await devices.list()).single.values.icon.key, 'device_controller');
  });
  testWidgets(
      'assignment warning cancel and override then removal preserve history',
      (tester) async {
    await devices.save(const DeviceDraft(name: 'Flash', quantity: 4));
    final s =
        await sets.save(const SetDraft(userSetId: 'SET-001', name: 'Pair'));
    final b = await batteries.save(const BatteryDraft(userBatteryId: 'A'));
    await sets.addMember(s.id, b.id);
    await pump(tester);
    await tap(tester, 'Flash');
    await tap(tester, 'Assign Battery Set');
    await tap(tester, 'SET-001 · Pair · 1 Batteries');
    await tap(tester, 'Confirm');
    expect(find.text('Review compatibility warnings'), findsOneWidget);
    await tap(tester, 'Cancel');
    expect((await devices.list()).single.isAssigned, isFalse);
    await tap(tester, 'Assign Battery Set');
    await tap(tester, 'SET-001 · Pair · 1 Batteries');
    await tap(tester, 'Confirm');
    await tap(tester, 'Confirm');
    expect((await devices.list()).single.batteries.single.id, b.id);
    await tap(tester, 'Remove Set');
    await tap(tester, 'Confirm');
    expect((await devices.list()).single.isAssigned, isFalse);
    expect((await devices.list()).single.assignments, hasLength(2));
    expect(tester.takeException(), isNull);
  });
  testWidgets('deactivate reactivate and delete require confirmation',
      (tester) async {
    final d = await devices.save(const DeviceDraft(name: 'Radio'));
    await pump(tester);
    await tap(tester, 'Radio');
    await tap(tester, 'Mark Inactive');
    await tap(tester, 'Cancel');
    expect((await devices.get(d.id)).active, isTrue);
    await tap(tester, 'Mark Inactive');
    await tap(tester, 'Confirm');
    expect((await devices.get(d.id)).active, isFalse);
    await tap(tester, 'Reactivate Device');
    await tap(tester, 'Confirm');
    expect((await devices.get(d.id)).active, isTrue);
    await tap(tester, 'Delete Device');
    await tap(tester, 'Cancel');
    expect(await devices.list(), hasLength(1));
    await tap(tester, 'Delete Device');
    await tap(tester, 'Confirm');
    expect(await devices.list(), isEmpty);
  });
  testWidgets(
      'missing primary Device photo falls back and gallery remains usable',
      (tester) async {
    final d = await devices.save(const DeviceDraft(name: 'Radio'));
    final owner = PhotoOwner(PhotoOwnerKind.device, d.id);
    await tester.runAsync(() async {
      await photos.add(
          owner,
          File('android/app/src/main/res/mipmap-mdpi/ic_launcher.png')
              .absolute
              .uri);
      final photo = (await photos.repository.gallery(owner)).photos.single;
      await photos.usePhoto(owner, photo);
      final r = await devices.get(d.id);
      await File.fromUri(root.uri.resolve(r.photoPath!.value)).delete();
    });
    await pump(tester);
    await tap(tester, 'Radio');
    expect(find.byType(Image), findsNothing);
    await tap(tester, 'Photographs');
    expect(find.text('Photographs'), findsWidgets);
    expect(find.text('Use Icon as Primary'), findsOneWidget);
    await tap(tester, 'Use Icon as Primary');
    expect((await photos.repository.gallery(owner)).preferPhoto, isFalse);
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
