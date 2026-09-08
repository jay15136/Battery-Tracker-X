import 'dart:async';
import 'dart:io';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/features/dashboard/data/drift_dashboard_repository.dart';
import 'package:battery_tracker/features/dashboard/domain/dashboard.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftDashboardRepository repo;
  final now = DateTime.utc(2026, 9, 8, 12);
  String uuid() => const UuidV4PermanentIdGenerator().next().value;
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DriftDashboardRepository(db, now: () => now);
  });
  tearDown(() => db.close());
  Future<int> battery(String name,
          {String status = 'Available',
          String condition = 'Good',
          DateTime? created,
          bool rechargeable = true}) =>
      db.into(db.batteries).insert(BatteriesCompanion.insert(
          uuid: uuid(),
          userBatteryId: name,
          status: Value(status),
          condition: Value(condition),
          rechargeable: Value(rechargeable),
          createdAt: Value(created ?? now)));
  Future<void> charge(int id, DateTime at) =>
      db.into(db.chargeRecords).insert(ChargeRecordsCompanion.insert(
          uuid: uuid(), batteryId: id, chargedAt: Value(at)));
  test('empty database yields all nine zero counts and no invented activity',
      () async {
    final s = await repo.load();
    expect(s.counts.length, 9);
    expect(s.counts.values.every((v) => v == 0), isTrue);
    expect(s.activity, isEmpty);
    expect(s.attention, isEmpty);
  });
  test('activity identifies current records and retains text after deletion',
      () async {
    final id = await battery('Current label');
    final b = await (db.select(db.batteries)..where((t) => t.id.equals(id)))
        .getSingle();
    await db.into(db.activityLog).insert(ActivityLogCompanion.insert(
        uuid: uuid(),
        eventType: 'battery_created',
        entityType: 'battery',
        entityUuid: b.uuid,
        summary: 'Battery created.'));
    var a = (await repo.load()).activity.single;
    expect(a.entityLabel, 'Current label');
    expect(a.available, isTrue);
    expect(a.entityId!.value, b.uuid);
    await (db.update(db.batteries)..where((t) => t.id.equals(id)))
        .write(BatteriesCompanion(deletedAt: Value(now)));
    a = (await repo.load()).activity.single;
    expect(a.available, isFalse);
    expect(a.summary, 'Battery created.');
  });
  test(
      'current relationships count distinct batteries and closed rows do not count',
      () async {
    final a = await battery('A'),
        b = await battery('B'),
        c = await battery('C');
    await battery('Charging', status: 'Charging');
    await battery('Retired', status: 'Retired');
    final d = await db
        .into(db.devices)
        .insert(DevicesCompanion.insert(uuid: uuid(), name: 'Radio'));
    final set = await db.into(db.batterySets).insert(
        BatterySetsCompanion.insert(uuid: uuid(), userSetId: 'S', name: 'Set'));
    await db.into(db.batterySetMemberships).insert(
        BatterySetMembershipsCompanion.insert(
            operationUuid: uuid(),
            uuid: uuid(),
            batteryId: a,
            batterySetId: set));
    await db.into(db.batterySetMemberships).insert(
        BatterySetMembershipsCompanion.insert(
            operationUuid: uuid(),
            uuid: uuid(),
            batteryId: b,
            batterySetId: set,
            addedAt: Value(now.subtract(const Duration(days: 1))),
            removedAt: Value(now)));
    await db.into(db.assignments).insert(AssignmentsCompanion.insert(
        uuid: uuid(),
        subjectType: 'battery',
        batteryId: Value(a),
        deviceId: d,
        operationUuid: uuid()));
    await db.into(db.assignments).insert(AssignmentsCompanion.insert(
        uuid: uuid(),
        subjectType: 'battery',
        batteryId: Value(c),
        deviceId: d,
        operationUuid: uuid(),
        assignedAt: Value(now.subtract(const Duration(days: 1))),
        removedAt: Value(now)));
    final s = await repo.load();
    expect(s.counts, {
      'Total Batteries': 5,
      'Available Batteries': 2,
      'Batteries Assigned to Devices': 1,
      'Batteries in Sets': 1,
      'Battery Sets': 1,
      'Batteries Charging': 1,
      'Batteries Needing Attention': 1,
      'Retired Batteries': 1,
      'Total Devices': 1
    });
  });
  test(
      'poor damaged retired and explicit flags produce one attention row per Battery',
      () async {
    await battery('Poor', condition: 'Poor');
    await battery('Damaged', condition: 'Damaged', status: 'Needs Attention');
    await battery('Retired', condition: 'Retired');
    final s = await repo.load();
    expect(s.attention.length, 3);
    expect(s.counts['Retired Batteries'], 1);
    expect(s.attention.firstWhere((b) => b.label == 'Damaged').reasons,
        ['Status: Needs Attention', 'Marked Damaged']);
  });
  test(
      'recent-charge rule uses latest charge or creation and excludes primary cells',
      () async {
    final old = now.subtract(const Duration(days: 90));
    await battery('No record', created: old);
    final charged = await battery('Old charge');
    await charge(charged, old);
    await charge(charged, old.subtract(const Duration(days: 10)));
    final recent = await battery('Recent', created: old);
    await charge(recent, now.subtract(const Duration(days: 89)));
    await battery('Primary', created: old, rechargeable: false);
    final s = await repo.load();
    expect(
        s.attention.map((b) => b.label).toSet(), {'No record', 'Old charge'});
  });
  test(
      'configured charge threshold and Set difference use actual individual records',
      () async {
    final a = await battery('High'), b = await battery('Low');
    final set = await db.into(db.batterySets).insert(
        BatterySetsCompanion.insert(uuid: uuid(), userSetId: 'S', name: 'Set'));
    for (final id in [a, b]) {
      await db.into(db.batterySetMemberships).insert(
          BatterySetMembershipsCompanion.insert(
              operationUuid: uuid(),
              uuid: uuid(),
              batteryId: id,
              batterySetId: set));
    }
    for (var i = 0; i < 3; i++) {
      await charge(a, now);
    }
    await repo.savePolicy(const AttentionPolicy(
        daysWithoutCharge: 0,
        recordedChargeThreshold: 3,
        setChargeDifference: 3));
    var s = await repo.load();
    expect(s.attention.length, 2);
    expect(s.attention.firstWhere((b) => b.label == 'High').reasons.length, 2);
    await (db.update(db.batterySetMemberships)
          ..where((t) => t.batteryId.equals(b)))
        .write(BatterySetMembershipsCompanion(
            removedAt: Value(now.add(const Duration(days: 1)))));
    s = await repo.load();
    expect(s.attention.length, 1);
    expect(s.attention.single.reasons.single,
        contains('3 Recorded Charges (threshold 3)'));
    await repo.savePolicy(const AttentionPolicy(
        daysWithoutCharge: 0,
        recordedChargeThreshold: 0,
        setChargeDifference: 0));
    expect((await repo.load()).attention, isEmpty);
  });
  test(
      'deleted records are excluded and inactive Sets/Devices remain in totals',
      () async {
    final b = await battery('Deleted', condition: 'Poor');
    await (db.update(db.batteries)..where((t) => t.id.equals(b)))
        .write(BatteriesCompanion(deletedAt: Value(now)));
    await db.into(db.devices).insert(DevicesCompanion.insert(
        uuid: uuid(), name: 'Inactive', deactivatedAt: Value(now)));
    await db.into(db.devices).insert(DevicesCompanion.insert(
        uuid: uuid(), name: 'Deleted', deletedAt: Value(now)));
    final s = await repo.load();
    expect(s.counts['Total Batteries'], 0);
    expect(s.counts['Total Devices'], 1);
    expect(s.attention, isEmpty);
  });
  test(
      'recent activity is bounded ordered and retains unavailable historical entities',
      () async {
    for (var i = 0; i < 25; i++) {
      await db.into(db.activityLog).insert(ActivityLogCompanion.insert(
          uuid: uuid(),
          eventType: 'battery_updated',
          entityType: 'battery',
          entityUuid: uuid(),
          summary: 'Event $i',
          occurredAt: Value(now.add(Duration(minutes: i)))));
    }
    final s = await repo.load();
    expect(s.activity.length, 20);
    expect(s.activity.first.summary, 'Event 24');
    expect(s.activity.last.summary, 'Event 5');
    expect(s.activity.every((a) => !a.available), isTrue);
  });
  test(
      'watch refreshes when condition or settings change without count changes',
      () async {
    final id = await battery('A');
    final stream = StreamIterator(repo.watch());
    try {
      expect(await stream.moveNext(), isTrue);
      expect(stream.current.attention, isEmpty);
      await (db.update(db.batteries)..where((t) => t.id.equals(id)))
          .write(const BatteriesCompanion(condition: Value('Poor')));
      expect(
          await stream.moveNext().timeout(const Duration(seconds: 3)), isTrue);
      expect(stream.current.attention.length, 1);
      await repo.savePolicy(const AttentionPolicy(daysWithoutCharge: 10));
      expect(
          await stream.moveNext().timeout(const Duration(seconds: 3)), isTrue);
      expect(stream.current.policy.daysWithoutCharge, 10);
    } finally {
      await stream.cancel();
    }
  });
  test(
      'policy validation preserves prior settings and disk restart restores rules',
      () async {
    final root = await Directory.systemTemp.createTemp('dashboard-restart-');
    await db.close();
    var disk = AppDatabase.forTesting(
        NativeDatabase(File('${root.path}/state.sqlite')));
    try {
      var r = DriftDashboardRepository(disk);
      await r.savePolicy(const AttentionPolicy(
          daysWithoutCharge: 12,
          recordedChargeThreshold: 34,
          setChargeDifference: 5));
      await expectLater(
          r.savePolicy(const AttentionPolicy(daysWithoutCharge: -1)),
          throwsFormatException);
      await disk.close();
      disk = AppDatabase.forTesting(
          NativeDatabase(File('${root.path}/state.sqlite')));
      r = DriftDashboardRepository(disk);
      expect((await r.load()).policy.toJson(),
          {'days': 12, 'charges': 34, 'difference': 5});
    } finally {
      await disk.close();
      await root.delete(recursive: true);
      db = AppDatabase.forTesting(NativeDatabase.memory());
    }
  });
}
