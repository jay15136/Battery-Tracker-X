import 'dart:io';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/features/batteries/data/drift_battery_repository.dart';
import 'package:battery_tracker/features/batteries/domain/battery.dart';
import 'package:battery_tracker/features/battery_sets/data/drift_battery_set_repository.dart';
import 'package:battery_tracker/features/battery_sets/domain/battery_set.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftBatteryRepository batteries;
  late DriftBatterySetRepository sets;
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
  }

  setUp(() => bind(AppDatabase.forTesting(NativeDatabase.memory())));
  tearDown(() => db.close());
  Future<SetRecord> create([String id = 'SET-001']) =>
      sets.save(SetDraft(userSetId: id, name: 'Test $id'));
  Future<BatteryRecord> battery(String id) =>
      batteries.save(BatteryDraft(userBatteryId: id));
  Future<void> accept(Future<void> Function(Set<String>) action) async {
    try {
      await action({});
    } on SetWarnings catch (e) {
      await action(e.messages);
    }
  }

  Future<int> count(String table) async =>
      (await db.customSelect('SELECT COUNT(*) AS n FROM $table').getSingle())
          .read<int>('n');
  test('Set create rename and sequential IDs preserve permanent identity',
      () async {
    final a = await create();
    await create('SET-003');
    expect(await sets.suggestId(), 'SET-002');
    expect(await sets.suggestId(prefix: 'RADIO', start: 40), 'RADIO-040');
    await expectLater(
        create('set-001'), throwsA(isA<SetValidationException>()));
    final renamed = await sets
        .save(const SetDraft(userSetId: 'CUSTOM', name: 'Radio'), id: a.id);
    expect(renamed.id, a.id);
    expect(renamed.createdAt, a.createdAt);
    expect(renamed.values.icon.key, 'battery_set_generic');
    expect(renamed.primaryPhotoPath, isNull);
  });
  test('master four-member Set scenario records four charges and assignments',
      () async {
    final s = await create();
    final members = <BatteryRecord>[];
    for (var n = 1; n <= 4; n++) {
      final b = await battery('AA-${n.toString().padLeft(3, '0')}');
      members.add(b);
      await sets.addMember(s.id, b.id);
    }
    await sets.removeMember(s.id, members.last.id);
    await sets.addMember(s.id, members.last.id);
    await sets.markCharged(s.id, notes: 'All four');
    expect(await count('charge_records'), 4);
    final device = await sets.createDevice('Four-cell Flash', quantity: 4);
    await sets.assign(s.id, device.id);
    for (final b in members) {
      expect((await batteries.get(b.id)).currentDevices, ['Four-cell Flash']);
    }
    await sets.unassign(s.id);
    expect((await sets.get(s.id)).assignments.single.removedAt, isNotNull);
    expect(
        (await sets.get(s.id)).activityHistory.join(' '), contains('All four'));
    await sets.delete(s.id);
    expect(await batteries.list(), hasLength(4));
    expect(await count('assignments'), 5);
    expect(await count('battery_set_memberships'), 5);
  });
  test('failed unassignment history write rolls back removal and statuses',
      () async {
    final s = await create(), b = await battery('A');
    await sets.addMember(s.id, b.id);
    final device = await sets.createDevice('Radio');
    await sets.assign(s.id, device.id);
    await db.customStatement(
        "CREATE TRIGGER fail_removal_history BEFORE INSERT ON activity_log BEGIN SELECT RAISE(ABORT, 'injected'); END");
    await expectLater(sets.unassign(s.id), throwsA(isA<Exception>()));
    expect(
        (await db.select(db.assignments).get())
            .every((a) => a.removedAt == null),
        isTrue);
    expect((await batteries.get(b.id)).values.status, 'Assigned');
  });
  test('add remove and readd retain immutable historical membership notes',
      () async {
    final s = await create(), b = await battery('AA-001');
    await sets.addMember(s.id, b.id, notes: 'Original addition');
    expect((await batteries.get(b.id)).values.status, 'In Set');
    await expectLater(
        sets.addMember(s.id, b.id), throwsA(isA<SetValidationException>()));
    await sets.removeMember(s.id, b.id, notes: 'Removal reason');
    await sets.addMember(s.id, b.id, notes: 'New addition');
    final r = await sets.get(s.id);
    expect(r.members.length, 1);
    expect(r.membershipHistory.length, 2);
    expect(r.membershipHistory.last.notes, 'Original addition');
    expect(r.membershipHistory.last.removedAt, isNotNull);
    expect(r.membershipHistory.first.notes, 'New addition');
  });
  test(
      'multiple membership needs explicit override and move closes prior links',
      () async {
    final a = await create(),
        b = await create('SET-002'),
        cell = await battery('AA-001');
    await sets.addMember(a.id, cell.id);
    await expectLater(
        sets.addMember(b.id, cell.id), throwsA(isA<SetWarnings>()));
    expect((await sets.get(b.id)).members, isEmpty);
    await accept((w) => sets.addMember(b.id, cell.id, acceptedWarnings: w));
    expect((await sets.get(a.id)).members.length, 1);
    await sets.removeMember(b.id, cell.id);
    await accept((w) => sets.addMember(b.id, cell.id,
        action: MembershipAction.move, acceptedWarnings: w));
    expect((await sets.get(a.id)).members, isEmpty);
    expect(
        (await sets.get(a.id)).membershipHistory.single.removedAt, isNotNull);
    expect((await sets.get(b.id)).members.single.id, cell.id);
  });
  test(
      'compatibility compares type chemistry voltage capacity with no writes before acknowledgment',
      () async {
    final type = const UuidV4PermanentIdGenerator().next();
    await db
        .into(db.batteryTypes)
        .insert(BatteryTypesCompanion.insert(uuid: type.value, typeName: 'AA'));
    final s = await create();
    final a = await batteries.save(BatteryDraft(
        userBatteryId: 'A',
        batteryTypeId: type,
        chemistry: 'NiMH',
        nominalVoltage: 1.2,
        capacity: 2000,
        capacityUnit: 'mAh'));
    final b = await batteries.save(const BatteryDraft(
        userBatteryId: 'B',
        chemistry: 'Li-ion',
        nominalVoltage: 3.7,
        capacity: 3000,
        capacityUnit: 'mAh'));
    await sets.addMember(s.id, a.id);
    final before = await count('activity_log');
    try {
      await sets.addMember(s.id, b.id);
      fail('Expected warnings');
    } on SetWarnings catch (e) {
      expect(e.messages.length, 4);
    }
    expect(await count('activity_log'), before);
    expect((await sets.get(s.id)).members.length, 1);
    await accept((w) => sets.addMember(s.id, b.id, acceptedWarnings: w));
    expect((await sets.get(s.id)).members.length, 2);
  });
  test(
      'charge affects only current members and preserves unequal lifetime counts',
      () async {
    final s = await create(), a = await battery('A'), b = await battery('B');
    await sets.addMember(s.id, a.id);
    await sets.markCharged(s.id);
    await sets.addMember(s.id, b.id);
    await sets.markCharged(s.id, notes: 'Together');
    expect((await batteries.get(a.id)).recordedCharges, 2);
    expect((await batteries.get(b.id)).recordedCharges, 1);
    expect((await sets.get(s.id)).recordedCharges, 2);
    await sets.removeMember(s.id, a.id);
    await sets.markCharged(s.id);
    expect((await batteries.get(a.id)).recordedCharges, 2);
    expect((await batteries.get(b.id)).recordedCharges, 2);
    final records = await db.select(db.chargeRecords).get();
    expect(records.every((r) => r.sourceSetChargeId != null), isTrue);
    expect((await sets.get(s.id)).lastCharged, isNotNull);
  });
  test('failure on second charge rolls back parent children and activity',
      () async {
    final s = await create(), a = await battery('A'), b = await battery('B');
    await sets.addMember(s.id, a.id);
    await sets.addMember(s.id, b.id);
    final before = await count('activity_log');
    await db.customStatement(
        "CREATE TRIGGER fail_second_charge BEFORE INSERT ON charge_records WHEN (SELECT COUNT(*) FROM charge_records) = 1 BEGIN SELECT RAISE(ABORT, 'injected'); END");
    await expectLater(sets.markCharged(s.id), throwsA(isA<Exception>()));
    expect(await count('charge_records'), 0);
    expect(await count('set_charge_records'), 0);
    expect(await count('activity_log'), before);
  });
  test('empty inactive and nonrechargeable Sets cannot be charged', () async {
    final s = await create();
    await expectLater(
        sets.markCharged(s.id), throwsA(isA<SetValidationException>()));
    final b = await batteries
        .save(const BatteryDraft(userBatteryId: 'A', rechargeable: false));
    await sets.addMember(s.id, b.id);
    await expectLater(
        sets.markCharged(s.id), throwsA(isA<SetValidationException>()));
    await sets.setActive(s.id, false);
    await expectLater(
        sets.markCharged(s.id), throwsA(isA<SetValidationException>()));
    expect(await count('charge_records'), 0);
  });
  test(
      'assignment creates stable parent child history and removal preserves original notes',
      () async {
    final s = await create(), a = await battery('A'), b = await battery('B');
    await sets.addMember(s.id, a.id);
    await sets.addMember(s.id, b.id);
    final d = await sets.createDevice('Controller', quantity: 2);
    await sets.assign(s.id, d.id, notes: 'Install');
    expect((await sets.get(s.id)).currentAssignment!.deviceName, 'Controller');
    expect((await batteries.get(a.id)).currentDevices, ['Controller']);
    expect((await batteries.get(b.id)).values.status, 'Assigned');
    final original = await db.select(db.assignments).get();
    expect(original.length, 3);
    expect(original.where((r) => r.sourceSetAssignmentId != null).length, 2);
    expect(original.map((r) => r.operationUuid).toSet().length, 1);
    await expectLater(
        sets.removeMember(s.id, a.id), throwsA(isA<SetValidationException>()));
    await expectLater(
        sets.delete(s.id), throwsA(isA<SetValidationException>()));
    await expectLater(
        sets.setActive(s.id, false), throwsA(isA<SetValidationException>()));
    await sets.unassign(s.id, notes: 'Remove');
    final closed = await db.select(db.assignments).get();
    expect(closed.map((r) => r.uuid), original.map((r) => r.uuid));
    expect(closed.every((r) => r.removedAt != null && r.notes == 'Install'),
        isTrue);
    expect((await batteries.get(a.id)).values.status, 'In Set');
    await sets.assign(s.id, d.id);
    expect((await sets.get(s.id)).assignments.length, 2);
  });
  test('assignment mismatch needs acknowledgment and saves override evidence',
      () async {
    final s = await create(), a = await battery('A');
    await sets.addMember(s.id, a.id);
    final d = await sets.createDevice('Flash', quantity: 4, voltage: 1.2);
    await expectLater(sets.assign(s.id, d.id), throwsA(isA<SetWarnings>()));
    expect(await count('assignments'), 0);
    await accept((w) => sets.assign(s.id, d.id, acceptedWarnings: w));
    final rows = await db.select(db.assignments).get();
    expect(rows.every((r) => r.overrideReason!.contains('requires 4')), isTrue);
  });
  test(
      'failure on second member assignment rolls back status history and parent',
      () async {
    final s = await create(), a = await battery('A'), b = await battery('B');
    await sets.addMember(s.id, a.id);
    await sets.addMember(s.id, b.id);
    final d = await sets.createDevice('Controller');
    final before = await count('activity_log');
    await db.customStatement(
        "CREATE TRIGGER fail_second_assignment BEFORE INSERT ON assignments WHEN (SELECT COUNT(*) FROM assignments WHERE subject_type='battery') = 1 BEGIN SELECT RAISE(ABORT, 'injected'); END");
    await expectLater(sets.assign(s.id, d.id), throwsA(isA<Exception>()));
    expect(await count('assignments'), 0);
    expect(await count('activity_log'), before);
    expect((await batteries.get(a.id)).values.status, 'In Set');
    expect((await batteries.get(b.id)).values.status, 'In Set');
  });
  test('unassignment does not close unrelated device occupants', () async {
    final s = await create(),
        a = await battery('A'),
        other = await battery('Other');
    await sets.addMember(s.id, a.id);
    final d = await sets.createDevice('Device');
    final deviceRow = (await db.select(db.devices).get()).single;
    final batteryRow = (await db.select(db.batteries).get())
        .firstWhere((r) => r.uuid == other.id.value);
    const ids = UuidV4PermanentIdGenerator();
    final unrelated = await db.into(db.assignments).insert(
        AssignmentsCompanion.insert(
            uuid: ids.next().value,
            subjectType: 'battery',
            batteryId: Value(batteryRow.id),
            deviceId: deviceRow.id,
            operationUuid: ids.next().value));
    await accept((w) => sets.assign(s.id, d.id, acceptedWarnings: w));
    await sets.unassign(s.id);
    final preserved = (await db.select(db.assignments).get())
        .firstWhere((r) => r.id == unrelated);
    expect(preserved.removedAt, isNull);
  });
  test('deactivation and deletion retain history and batteries', () async {
    final s = await create(), a = await battery('A');
    await sets.addMember(s.id, a.id);
    await sets.markCharged(s.id);
    await sets.setActive(s.id, false);
    expect((await sets.get(s.id)).members.length, 1);
    expect((await batteries.get(a.id)).values.status, 'Available');
    await sets.setActive(s.id, true);
    expect((await batteries.get(a.id)).values.status, 'In Set');
    await sets.delete(s.id);
    expect(await sets.list(), isEmpty);
    expect(await batteries.list(), hasLength(1));
    expect(await count('charge_records'), 1);
    expect((await db.select(db.batterySetMemberships).get()).single.removedAt,
        isNotNull);
    expect(await sets.suggestId(), 'SET-002');
  });
  test('move failure rolls back closed source membership', () async {
    final a = await create(),
        b = await create('SET-002'),
        cell = await battery('A');
    await sets.addMember(a.id, cell.id);
    Set<String> warnings = {};
    try {
      await sets.addMember(b.id, cell.id, action: MembershipAction.move);
    } on SetWarnings catch (e) {
      warnings = e.messages;
    }
    await db.customStatement(
        "CREATE TRIGGER fail_membership BEFORE INSERT ON battery_set_memberships BEGIN SELECT RAISE(ABORT, 'injected'); END");
    await expectLater(
        sets.addMember(b.id, cell.id,
            action: MembershipAction.move, acceptedWarnings: warnings),
        throwsA(isA<Exception>()));
    expect((await sets.get(a.id)).members.length, 1);
    expect((await sets.get(b.id)).members, isEmpty);
  });
  test('real SQLite reopen restores Set members charges and current assignment',
      () async {
    await db.close();
    final dir = await Directory.systemTemp.createTemp('set-persistence-');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/sets.sqlite');
    bind(AppDatabase.forTesting(NativeDatabase(file)));
    final s = await create(), b = await battery('A');
    await sets.addMember(s.id, b.id);
    await sets.markCharged(s.id);
    final d = await sets.createDevice('Radio');
    await sets.assign(s.id, d.id);
    await db.close();
    bind(AppDatabase.forTesting(NativeDatabase(file)));
    final restored = await sets.get(s.id);
    expect(restored.members.single.id, b.id);
    expect(restored.recordedCharges, 1);
    expect(restored.currentAssignment!.deviceName, 'Radio');
    await db.close();
    bind(AppDatabase.forTesting(NativeDatabase.memory()));
  });
}
