import 'dart:io';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/features/batteries/data/drift_battery_repository.dart';
import 'package:battery_tracker/features/batteries/domain/battery.dart';
import 'package:battery_tracker/features/battery_sets/data/drift_battery_set_repository.dart';
import 'package:battery_tracker/features/battery_sets/domain/battery_set.dart';
import 'package:battery_tracker/features/devices/data/drift_device_repository.dart';
import 'package:battery_tracker/features/devices/domain/device.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_selection.dart';
import 'package:battery_tracker/features/icons/domain/icon_definition.dart';
import 'package:battery_tracker/features/icons/domain/icon_color.dart';
import 'package:battery_tracker/features/photos/data/drift_photo_repository.dart';
import 'package:battery_tracker/features/photos/data/local_photo_storage.dart';
import 'package:battery_tracker/features/photos/application/photo_service.dart';
import 'package:battery_tracker/features/photos/domain/photo.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

void main() {
  late AppDatabase db;
  late DriftBatteryRepository batteries;
  late DriftBatterySetRepository sets;
  late DriftDeviceRepository devices;
  void bind(AppDatabase database) {
    db = database;
    final icons = DriftIconRepository(
        database: db,
        idGenerator: const UuidV4PermanentIdGenerator(),
        builtInRegistry:
            IconRegistry(builtIns: BuiltInIconRegistry.definitions));
    batteries = DriftBatteryRepository(database: db, iconRepository: icons);
    sets =
        DriftBatterySetRepository(db: db, batteries: batteries, icons: icons);
    devices = DriftDeviceRepository(db: db, batteries: batteries, icons: icons);
  }

  setUp(() => bind(AppDatabase.forTesting(NativeDatabase.memory())));
  tearDown(() => db.close());
  test('full Device CRUD preserves immutable UUID and custom category metadata',
      () async {
    final a = await devices.save(const DeviceDraft(
        name: ' Radio ',
        category: 'Patrol equipment',
        manufacturer: 'Acme',
        model: 'R1',
        serialNumber: '123',
        location: 'Dispatch',
        description: 'Spare radio',
        notes: 'Duty use',
        quantity: 2,
        voltage: 1.2,
        requirementNotes: 'Matched pair',
        icon: IconSelection(
            source: IconSource.builtin,
            key: 'device_radio',
            color: IconColor.orange)));
    final b = await devices.save(
        const DeviceDraft(name: 'Renamed', category: 'Custom category'),
        id: a.id);
    expect(b.id, a.id);
    expect(b.createdAt, a.createdAt);
    expect(b.values.category, 'Custom category');
    expect(b.values.quantity, isNull);
    expect(b.values.icon.key, 'device_generic');
    expect(a.values.name, 'Radio');
    expect(a.values.serialNumber, '123');
    expect(a.values.requirementNotes, 'Matched pair');
    expect(b.activity, hasLength(2));
  });
  test('minimal Phase 7 Device is editable without changing its UUID',
      () async {
    final old = await sets.createDevice('Controller', quantity: 2);
    final edited = await devices.save(
        const DeviceDraft(
            name: 'Controller edited', location: 'Living room', quantity: 4),
        id: old.id);
    expect(edited.id, old.id);
    expect((await sets.devices()).single.quantity, 4);
  });
  test(
      'active names conflict case-insensitively and reactivation preserves inactive data',
      () async {
    final a = await devices.save(const DeviceDraft(name: 'Radio'));
    await expectLater(devices.save(const DeviceDraft(name: ' radio ')),
        throwsA(isA<DeviceValidationException>()));
    await devices.setActive(a.id, false);
    await devices.save(const DeviceDraft(name: 'Radio'));
    await expectLater(devices.setActive(a.id, true),
        throwsA(isA<DeviceValidationException>()));
    expect((await devices.get(a.id)).active, isFalse);
    await devices.save(const DeviceDraft(name: 'Spare radio'), id: a.id);
    await devices.setActive(a.id, true);
    expect((await devices.get(a.id)).active, isTrue);
  });
  test('invalid numeric and required type inputs never persist', () async {
    for (final d in [
      const DeviceDraft(name: ''),
      const DeviceDraft(name: 'Radio', quantity: 0),
      const DeviceDraft(name: 'Radio', voltage: double.nan),
      const DeviceDraft(name: 'Radio', voltage: -1),
      DeviceDraft(
          name: 'Radio',
          requiredTypeId: const UuidV4PermanentIdGenerator().next())
    ]) {
      await expectLater(
          devices.save(d), throwsA(isA<DeviceValidationException>()));
    }
    expect(await devices.list(), isEmpty);
  });
  test(
      'inactive referenced type survives ordinary edits but cannot be newly selected',
      () async {
    final id = const UuidV4PermanentIdGenerator().next();
    await db
        .into(db.batteryTypes)
        .insert(BatteryTypesCompanion.insert(uuid: id.value, typeName: 'AA'));
    final d =
        await devices.save(DeviceDraft(name: 'Radio', requiredTypeId: id));
    await db.update(db.batteryTypes).write(
        BatteryTypesCompanion(deactivatedAt: Value(DateTime.now().toUtc())));
    await devices.save(DeviceDraft(name: 'Updated', requiredTypeId: id),
        id: d.id);
    expect((await devices.get(d.id)).typeName, 'AA');
    await expectLater(
        devices.save(DeviceDraft(name: 'New', requiredTypeId: id)),
        throwsA(isA<DeviceValidationException>()));
  });
  test('failure writing activity rolls back creates edits and lifecycle',
      () async {
    final d = await devices.save(const DeviceDraft(name: 'Original'));
    await db.customStatement(
        "CREATE TRIGGER fail_device_event BEFORE INSERT ON activity_log BEGIN SELECT RAISE(ABORT, 'injected'); END");
    await expectLater(devices.save(const DeviceDraft(name: 'New')),
        throwsA(isA<Exception>()));
    await expectLater(devices.save(const DeviceDraft(name: 'Edited'), id: d.id),
        throwsA(isA<Exception>()));
    await expectLater(
        devices.setActive(d.id, false), throwsA(isA<Exception>()));
    await expectLater(devices.delete(d.id), throwsA(isA<Exception>()));
    expect(await devices.list(), hasLength(1));
    expect((await devices.get(d.id)).values.name, 'Original');
    expect((await devices.get(d.id)).active, isTrue);
  });
  test(
      'assigned Device cannot be deleted or deactivated; history survives later deletion',
      () async {
    final s =
        await sets.save(const SetDraft(userSetId: 'SET-001', name: 'Pair'));
    final b = await batteries.save(const BatteryDraft(userBatteryId: 'A'));
    await sets.addMember(s.id, b.id);
    final d =
        await devices.save(const DeviceDraft(name: 'Controller', quantity: 1));
    await sets.assign(s.id, d.id, notes: 'Installed');
    final r = await devices.get(d.id);
    expect(r.currentSets.single.subjectId, s.id);
    expect(r.batteries.single.id, b.id);
    expect(r.values.assess(r.batteries), isEmpty);
    await expectLater(devices.setActive(d.id, false),
        throwsA(isA<DeviceValidationException>()));
    await expectLater(
        devices.delete(d.id), throwsA(isA<DeviceValidationException>()));
    await devices.save(
        const DeviceDraft(name: 'Renamed Controller', quantity: 4),
        id: d.id);
    expect((await batteries.get(b.id)).currentDevices, ['Renamed Controller']);
    expect((await devices.get(d.id)).values.assess(r.batteries), isNotEmpty);
    await sets.unassign(s.id);
    expect(
        (await devices.get(d.id))
            .assignments
            .every((a) => a.removedAt != null && a.notes == 'Installed'),
        isTrue);
    await devices.delete(d.id);
    expect(await devices.list(), isEmpty);
    expect(await db.select(db.assignments).get(), hasLength(2));
    expect(await batteries.list(), hasLength(1));
    expect(await sets.list(), hasLength(1));
  });
  test('Device requirements remain overridable for Set assignment', () async {
    final s =
        await sets.save(const SetDraft(userSetId: 'SET-001', name: 'Pair'));
    final b = await batteries
        .save(const BatteryDraft(userBatteryId: 'A', nominalVoltage: 1.2));
    await sets.addMember(s.id, b.id);
    final d = await devices
        .save(const DeviceDraft(name: 'Flash', quantity: 4, voltage: 3.7));
    try {
      await sets.assign(s.id, d.id);
      fail('Expected warnings');
    } on SetWarnings catch (e) {
      expect(e.messages.length, 2);
      await sets.assign(s.id, d.id, acceptedWarnings: e.messages);
    }
    expect((await devices.get(d.id)).batteries.single.id, b.id);
    expect((await devices.get(d.id)).values.assess([b]), hasLength(2));
  });
  test(
      'real SQLite restart restores all fields and explicit photograph preference',
      () async {
    await db.close();
    final root = await Directory.systemTemp.createTemp('device-persistence-');
    final file = File('${root.path}/inventory.sqlite');
    bind(AppDatabase.forTesting(NativeDatabase(file)));
    try {
      final d = await devices.save(const DeviceDraft(
          name: 'Radio',
          category: 'Custom',
          manufacturer: 'Maker',
          model: 'M1',
          serialNumber: 'serial',
          location: 'Shelf',
          description: 'Description',
          notes: 'Notes',
          quantity: 2,
          voltage: 1.2,
          requirementNotes: 'Pair',
          icon: IconSelection(
              source: IconSource.builtin,
              key: 'device_radio',
              color: IconColor.red)));
      final photoRepo = DriftPhotoRepository(db);
      final service = PhotoService(
          repository: photoRepo,
          storage: LocalPhotoStorage(root.uri),
          logger: Logger('test.devices'));
      final owner = PhotoOwner(PhotoOwnerKind.device, d.id);
      await service.add(
          owner,
          File('android/app/src/main/res/mipmap-mdpi/ic_launcher.png')
              .absolute
              .uri);
      expect((await devices.get(d.id)).photoPath, isNull);
      final photo = (await photoRepo.gallery(owner)).photos.single;
      await service.usePhoto(owner, photo);
      await devices.save(d.values, id: d.id);
      await db.close();
      bind(AppDatabase.forTesting(NativeDatabase(file)));
      final restored = await devices.get(d.id);
      expect(restored.values.location, 'Shelf');
      expect(restored.values.model, 'M1');
      expect(restored.values.manufacturer, 'Maker');
      expect(restored.values.serialNumber, 'serial');
      expect(restored.values.description, 'Description');
      expect(restored.values.notes, 'Notes');
      expect(restored.values.quantity, 2);
      expect(restored.values.voltage, 1.2);
      expect(restored.values.requirementNotes, 'Pair');
      expect(restored.photoPath, isNotNull);
      expect(restored.values.icon.color.value, '#F44336');
      expect(
          File.fromUri(root.uri.resolve(restored.photoPath!.value))
              .existsSync(),
          isTrue);
    } finally {
      await db.close();
      bind(AppDatabase.forTesting(NativeDatabase.memory()));
      await root.delete(recursive: true);
    }
  });
}
