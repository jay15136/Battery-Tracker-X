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
import 'package:battery_tracker/features/assignments/data/drift_assignment_repository.dart';
import 'package:battery_tracker/features/assignments/domain/assignment.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftBatteryRepository batteries;
  late DriftBatterySetRepository sets;
  late DriftDeviceRepository devices;
  late DriftAssignmentRepository repo;
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
    repo = DriftAssignmentRepository(db: db);
  }

  setUp(() => bind(AppDatabase.forTesting(NativeDatabase.memory())));
  tearDown(() => db.close());
  Future<BatteryRecord> battery(String id) =>
      batteries.save(BatteryDraft(userBatteryId: id));
  Future<DeviceRecord> device() =>
      devices.save(const DeviceDraft(name: 'Radio'));
  Future<void> accept(Future<void> Function(Set<String>) action) async {
    try {
      await action({});
    } on AssignmentWarnings catch (e) {
      await action(e.messages);
    }
  }

  test(
      'multi-Battery assignment and removal preserve UUID dates duration and separate notes',
      () async {
    final a = await battery('A'), b = await battery('B'), d = await device();
    final at = DateTime.now().toUtc().subtract(const Duration(days: 3));
    final removed = at.add(const Duration(days: 2));
    await repo.assign(
        deviceId: d.id,
        batteryIds: [a.id, b.id],
        assignedAt: at,
        notes: 'Installation');
    final original = await repo.list();
    expect(original, hasLength(2));
    expect((await batteries.get(a.id)).values.status, 'Assigned');
    await repo.remove(original.map((r) => r.id).toList(),
        removedAt: removed, notes: 'Removal');
    final history = await repo.list();
    expect(history.map((r) => r.id), original.map((r) => r.id));
    expect(
        history.every((r) =>
            r.assignedAt == at &&
            r.removedAt == removed &&
            r.notes == 'Installation' &&
            r.removalNotes == 'Removal'),
        isTrue);
    expect(history.first.durationAt(DateTime.now()), const Duration(days: 2));
    expect((await batteries.get(a.id)).values.status, 'Available');
    expect((await devices.get(d.id)).batteries, isEmpty);
  });
  test('failed second assignment rolls back records statuses and history',
      () async {
    final a = await battery('A'), b = await battery('B'), d = await device();
    final before = (await db.select(db.activityLog).get()).length;
    await db.customStatement(
        "CREATE TRIGGER reject_second BEFORE INSERT ON assignments WHEN (SELECT COUNT(*) FROM assignments)=1 BEGIN SELECT RAISE(ABORT, 'injected'); END");
    await expectLater(repo.assign(deviceId: d.id, batteryIds: [a.id, b.id]),
        throwsA(isA<Exception>()));
    expect(await repo.list(), isEmpty);
    expect((await batteries.get(a.id)).values.status, 'Available');
    expect((await db.select(db.activityLog).get()).length, before);
  });
  test('failed second removal rolls back every close and status update',
      () async {
    final a = await battery('A'), b = await battery('B'), d = await device();
    await repo.assign(deviceId: d.id, batteryIds: [a.id, b.id]);
    final rows = await repo.list();
    await db.customStatement(
        "CREATE TRIGGER reject_removal BEFORE UPDATE ON assignments WHEN (SELECT COUNT(*) FROM assignments WHERE removed_at IS NOT NULL)=1 BEGIN SELECT RAISE(ABORT, 'injected'); END");
    await expectLater(
        repo.remove(rows.map((r) => r.id).toList()), throwsA(isA<Exception>()));
    expect((await repo.list()).every((r) => r.removedAt == null), isTrue);
    expect((await batteries.get(a.id)).values.status, 'Assigned');
  });
  test(
      'duplicate selection existing assignment and retired inventory are rejected',
      () async {
    final a = await battery('A'), d = await device();
    await expectLater(repo.assign(deviceId: d.id, batteryIds: [a.id, a.id]),
        throwsA(isA<AssignmentValidationException>()));
    await repo.assign(deviceId: d.id, batteryIds: [a.id]);
    await expectLater(repo.assign(deviceId: d.id, batteryIds: [a.id]),
        throwsA(isA<AssignmentValidationException>()));
    final retired = await batteries
        .save(const BatteryDraft(userBatteryId: 'R', status: 'Retired'));
    await expectLater(repo.assign(deviceId: d.id, batteryIds: [retired.id]),
        throwsA(isA<AssignmentValidationException>()));
    expect(await repo.list(), hasLength(1));
  });
  test('dates reject future removal before installation and historical overlap',
      () async {
    final a = await battery('A'), d = await device();
    final now = DateTime.now().toUtc();
    await expectLater(
        repo.assign(
            deviceId: d.id,
            batteryIds: [a.id],
            assignedAt: now.add(const Duration(days: 1))),
        throwsA(isA<AssignmentValidationException>()));
    final at = now.subtract(const Duration(days: 5));
    await repo.assign(deviceId: d.id, batteryIds: [a.id], assignedAt: at);
    final id = (await repo.list()).single.id;
    await expectLater(
        repo.remove([id], removedAt: at.subtract(const Duration(seconds: 1))),
        throwsA(isA<AssignmentValidationException>()));
    final removed = at.add(const Duration(days: 1));
    await repo.remove([id], removedAt: removed);
    await expectLater(
        repo.assign(deviceId: d.id, batteryIds: [a.id], assignedAt: at),
        throwsA(isA<AssignmentValidationException>()));
    await repo.assign(deviceId: d.id, batteryIds: [a.id], assignedAt: removed);
    expect(await repo.list(), hasLength(2));
  });
  test(
      'partial Set removal blocked and whole Set removal preserves membership and unrelated occupant',
      () async {
    final a = await battery('A'), b = await battery('B'), d = await device();
    final s =
        await sets.save(const SetDraft(userSetId: 'SET-001', name: 'Pair'));
    await sets.addMember(s.id, a.id);
    await repo.assign(deviceId: d.id, setId: s.id);
    await accept((w) =>
        repo.assign(deviceId: d.id, batteryIds: [b.id], acceptedWarnings: w));
    final rows = await repo.list();
    final parent = rows.singleWhere((r) => r.setId != null),
        child = rows.singleWhere((r) => r.parentId != null);
    await expectLater(
        repo.remove([child.id]), throwsA(isA<AssignmentValidationException>()));
    await repo.remove([parent.id]);
    expect((await batteries.get(a.id)).values.status, 'In Set');
    expect((await batteries.get(b.id)).currentDevices, ['Radio']);
    expect((await sets.get(s.id)).members.single.id, a.id);
  });
  test(
      'requirements and individually selected Set membership need acknowledgment',
      () async {
    final a = await battery('A');
    final d = await devices
        .save(const DeviceDraft(name: 'Flash', quantity: 4, voltage: 1.2));
    final s =
        await sets.save(const SetDraft(userSetId: 'SET-001', name: 'Pair'));
    await sets.addMember(s.id, a.id);
    try {
      await repo.assign(deviceId: d.id, batteryIds: [a.id]);
      fail('Expected warning');
    } on AssignmentWarnings catch (e) {
      expect(e.messages.length, 3);
      expect(await repo.list(), isEmpty);
      await repo.assign(
          deviceId: d.id, batteryIds: [a.id], acceptedWarnings: e.messages);
    }
    expect((await repo.list()).single.overrideReason,
        contains('membership stays unchanged'));
    expect((await sets.get(s.id)).currentAssignment, isNull);
  });
  test('warning acknowledgment is revalidated if Device requirements change',
      () async {
    final a = await battery('A');
    final d = await devices.save(const DeviceDraft(name: 'Radio', quantity: 2));
    Set<String> old = {};
    try {
      await repo.assign(deviceId: d.id, batteryIds: [a.id]);
    } on AssignmentWarnings catch (e) {
      old = e.messages;
    }
    await devices.save(
        const DeviceDraft(name: 'Radio', quantity: 3, voltage: 1.2),
        id: d.id);
    await expectLater(
        repo.assign(deviceId: d.id, batteryIds: [a.id], acceptedWarnings: old),
        throwsA(isA<AssignmentWarnings>()));
    expect(await repo.list(), isEmpty);
  });
  test(
      'explicit Set dates propagate through compatibility wrapper and all members',
      () async {
    final a = await battery('A'), d = await device();
    final s =
        await sets.save(const SetDraft(userSetId: 'SET-001', name: 'Set'));
    await sets.addMember(s.id, a.id);
    final at = DateTime.now().toUtc().subtract(const Duration(days: 2));
    await sets.assign(s.id, d.id, assignedAt: at);
    expect((await repo.list()).every((r) => r.assignedAt == at), isTrue);
    await sets.unassign(s.id, removedAt: at.add(const Duration(days: 1)));
    expect(
        (await repo.list()).every(
            (r) => r.durationAt(DateTime.now()) == const Duration(days: 1)),
        isTrue);
  });
  test('mixed individual and Set bulk removal is atomic and keeps history',
      () async {
    final a = await battery('A'), b = await battery('B'), d = await device();
    final s =
        await sets.save(const SetDraft(userSetId: 'SET-001', name: 'Set'));
    await sets.addMember(s.id, a.id);
    await repo.assign(deviceId: d.id, setId: s.id);
    await accept((w) =>
        repo.assign(deviceId: d.id, batteryIds: [b.id], acceptedWarnings: w));
    await repo.remove((await repo.list())
        .where((r) => r.parentId == null)
        .map((r) => r.id)
        .toList());
    expect((await repo.list()).every((r) => r.removedAt != null), isTrue);
    expect(await repo.list(), hasLength(3));
  });
  test('file-backed restart preserves open and closed assignments', () async {
    await db.close();
    final root =
        await Directory.systemTemp.createTemp('assignment-persistence-');
    final file = File('${root.path}/data.sqlite');
    bind(AppDatabase.forTesting(NativeDatabase(file)));
    try {
      final a = await battery('A'), b = await battery('B'), d = await device();
      await repo.assign(
          deviceId: d.id, batteryIds: [a.id, b.id], notes: 'Installed');
      final rows = await repo.list();
      await repo.remove([rows.first.id], notes: 'Removed one');
      await db.close();
      bind(AppDatabase.forTesting(NativeDatabase(file)));
      final restored = await repo.list();
      expect(restored, hasLength(2));
      expect(restored.where((r) => r.removedAt == null), hasLength(1));
      expect(restored.where((r) => r.removedAt != null).single.removalNotes,
          'Removed one');
    } finally {
      await db.close();
      bind(AppDatabase.forTesting(NativeDatabase.memory()));
      await root.delete(recursive: true);
    }
  });
}
