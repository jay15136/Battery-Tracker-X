import 'dart:io';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/features/batteries/data/drift_battery_repository.dart';
import 'package:battery_tracker/features/batteries/domain/battery.dart';
import 'package:battery_tracker/features/battery_sets/data/drift_battery_set_repository.dart';
import 'package:battery_tracker/features/battery_sets/domain/battery_set.dart';
import 'package:battery_tracker/features/bulk_operations/data/drift_bulk_edit_repository.dart';
import 'package:battery_tracker/features/bulk_operations/domain/bulk_creation.dart';
import 'package:battery_tracker/features/bulk_operations/domain/bulk_edit.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_selection.dart';
import 'package:battery_tracker/features/icons/domain/icon_definition.dart';
import 'package:battery_tracker/features/icons/domain/icon_color.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftBatteryRepository batteries;
  late DriftBatterySetRepository sets;
  late DriftBulkEditRepository repo;
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
    repo = DriftBulkEditRepository(
        db: db, batteries: batteries, sets: sets, icons: icons);
  }

  Future<BatteryRecord> battery(String id) => batteries.save(BatteryDraft(
      userBatteryId: id,
      name: 'Keep name',
      notes: 'Original',
      purchaseLocation: 'Store',
      purchasePrice: 10));
  Future<void> edit(
      List<PermanentId> ids, BulkEditAction action, Object? value) async {
    await repo.apply(await repo
        .preview(BulkEditRequest(ids: ids, action: action, value: value)));
  }

  setUp(() => bind(AppDatabase.forTesting(NativeDatabase.memory())));
  tearDown(() => db.close());
  test(
      'ordinary edits preserve retirement metadata and restoration clears current fields',
      () async {
    final a = await battery('A');
    await repo.apply(await repo.preview(BulkEditRequest(
        ids: [a.id],
        action: BulkEditAction.retire,
        reason: 'Age',
        retirementDate: DateTime.utc(2026, 8, 1))));
    await batteries.save(
        const BatteryDraft(
            userBatteryId: 'A', status: 'Retired', notes: 'Edited'),
        id: a.id);
    expect((await batteries.get(a.id)).retirementReason, 'Age');
    await batteries.save(
        const BatteryDraft(userBatteryId: 'A', status: 'Storage'),
        id: a.id);
    final restored = await batteries.get(a.id);
    expect(restored.retiredAt, isNull);
    expect(restored.retirementReason, isNull);
    expect(await batteries.history(a.id), contains(contains('Age')));
  });
  test('failed second Set removal reopens every membership through rollback',
      () async {
    final a = await battery('A'), b = await battery('B');
    final s = await sets.save(const SetDraft(userSetId: 'S', name: 'Set'));
    await sets.addMember(s.id, a.id);
    await sets.addMember(s.id, b.id);
    final p = await repo.preview(BulkEditRequest(
        ids: [a.id, b.id], action: BulkEditAction.removeSet, value: s.id));
    await db.customStatement(
        "CREATE TRIGGER fail_remove BEFORE UPDATE ON batteries WHEN OLD.user_battery_id='B' BEGIN SELECT RAISE(ABORT,'injected'); END");
    await expectLater(repo.apply(p), throwsA(isA<Exception>()));
    expect((await sets.get(s.id)).members, hasLength(2));
    expect(
        (await db.select(db.batterySetMemberships).get())
            .every((m) => m.removedAt == null),
        isTrue);
  });
  test('type edits change only type and can explicitly clear it', () async {
    final a = await battery('A');
    final type = const UuidV4PermanentIdGenerator().next();
    await db.into(db.batteryTypes).insert(
        BatteryTypesCompanion.insert(uuid: type.value, typeName: 'New Type'));
    await edit([a.id], BulkEditAction.type, type);
    expect((await batteries.get(a.id)).values.batteryTypeId, type);
    expect((await batteries.get(a.id)).values.nominalVoltage, isNull);
    await edit([a.id], BulkEditAction.type, null);
    expect((await batteries.get(a.id)).values.batteryTypeId, isNull);
  });
  test('type changes in a Set require compatibility acknowledgment', () async {
    final a = await battery('A');
    final s = await sets.save(const SetDraft(userSetId: 'S', name: 'Set'));
    await sets.addMember(s.id, a.id);
    final type = const UuidV4PermanentIdGenerator().next();
    await db.into(db.batteryTypes).insert(
        BatteryTypesCompanion.insert(uuid: type.value, typeName: 'Type'));
    final p = await repo.preview(
        BulkEditRequest(ids: [a.id], action: BulkEditAction.type, value: type));
    Set<String> warnings = {};
    try {
      await repo.apply(p);
      fail('Expected warning');
    } on SetWarnings catch (e) {
      warnings = e.messages;
    }
    expect((await batteries.get(a.id)).values.batteryTypeId, isNull);
    await repo.apply(p, acceptedWarnings: warnings);
    expect((await batteries.get(a.id)).values.batteryTypeId, type);
    expect((await sets.get(s.id)).members, hasLength(1));
  });
  test(
      'retirement failure rolls back dates reasons and statuses for all selected',
      () async {
    final a = await battery('A'), b = await battery('B');
    final p = await repo.preview(BulkEditRequest(
        ids: [a.id, b.id],
        action: BulkEditAction.retire,
        reason: 'Age',
        retirementDate: DateTime.utc(2026, 8, 1)));
    await db.customStatement(
        "CREATE TRIGGER fail_retirement BEFORE UPDATE ON batteries WHEN OLD.user_battery_id='B' BEGIN SELECT RAISE(ABORT,'injected'); END");
    await expectLater(repo.apply(p), throwsA(isA<Exception>()));
    for (final id in [a.id, b.id]) {
      final r = await batteries.get(id);
      expect(r.values.status, 'Available');
      expect(r.retiredAt, isNull);
      expect(r.retirementReason, isNull);
    }
  });
  test(
      'preview changes nothing and condition edit preserves identity and unrelated data',
      () async {
    final a = await battery('A'), b = await battery('B');
    final p = await repo.preview(BulkEditRequest(
        ids: [a.id, b.id], action: BulkEditAction.condition, value: 'Good'));
    expect(p.rows.map((r) => r.before), ['New', 'New']);
    expect((await batteries.get(a.id)).values.condition, 'New');
    await repo.apply(p);
    for (final id in [a.id, b.id]) {
      final r = await batteries.get(id);
      expect(r.values.condition, 'Good');
      expect(r.id, id);
      expect(r.values.name, 'Keep name');
      expect(r.values.purchasePrice, 10);
      expect(r.values.notes, 'Original');
      expect(await batteries.history(id),
          contains(contains('Condition: New → Good')));
    }
  });
  test('selected status update leaves unselected Batteries unchanged',
      () async {
    final a = await battery('A'), b = await battery('B');
    await edit([a.id], BulkEditAction.status, 'Storage');
    expect((await batteries.get(a.id)).values.status, 'Storage');
    expect((await batteries.get(b.id)).values.status, 'Available');
  });
  test(
      'shared note appends and tags preserve prior associations without duplication',
      () async {
    final a = await battery('A');
    await edit([a.id], BulkEditAction.note, 'Shared');
    expect((await batteries.get(a.id)).values.notes, 'Original\nShared');
    await edit([a.id], BulkEditAction.tag, 'Work');
    await edit([a.id], BulkEditAction.tag, 'work');
    await edit([a.id], BulkEditAction.tag, 'Spare');
    expect(await db.select(db.batteryTags).get(), hasLength(2));
  });
  test('icon color changes preserve distinct icon keys', () async {
    final a = await battery('A');
    final b = await batteries.save(const BatteryDraft(
        userBatteryId: 'B',
        icon: IconSelection(
            source: IconSource.builtin,
            key: 'battery_aa',
            color: IconColor.green)));
    await edit([a.id, b.id], BulkEditAction.color, IconColor.blue);
    expect((await batteries.get(a.id)).values.icon.key, 'battery_generic');
    expect((await batteries.get(b.id)).values.icon.key, 'battery_aa');
    expect((await batteries.get(b.id)).values.icon.color, IconColor.blue);
    const icon = IconSelection(
        source: IconSource.builtin, key: 'battery_aaa', color: IconColor.red);
    await edit([a.id, b.id], BulkEditAction.icon, icon);
    expect((await batteries.get(a.id)).values.icon, icon);
    expect((await batteries.get(b.id)).values.icon, icon);
  });
  test('purchase fields can be set and cleared independently', () async {
    final a = await battery('A');
    for (final entry in {
      BulkEditAction.purchaseDate: DateTime.utc(2026, 1, 1),
      BulkEditAction.warrantyExpiration: DateTime.utc(2028, 1, 1),
      BulkEditAction.purchasePrice: 20.0,
      BulkEditAction.totalPackagePrice: 80.0,
      BulkEditAction.perBatteryPrice: 20.0,
      BulkEditAction.purchaseLocation: 'New store'
    }.entries) {
      await edit([a.id], entry.key, entry.value);
    }
    var v = (await batteries.get(a.id)).values;
    expect(v.purchaseDate, DateTime.utc(2026, 1, 1));
    expect(v.warrantyExpiration, DateTime.utc(2028, 1, 1));
    expect(v.totalPackagePrice, 80);
    expect(v.perBatteryPrice, 20);
    await edit([a.id], BulkEditAction.purchasePrice, null);
    v = (await batteries.get(a.id)).values;
    expect(v.purchasePrice, isNull);
    expect(v.purchaseLocation, 'New store');
    expect(v.totalPackagePrice, 80);
  });
  test('add and remove Set membership preserves closed history', () async {
    final a = await battery('A'), b = await battery('B');
    final s = await sets.save(const SetDraft(userSetId: 'S', name: 'Set'));
    await edit([a.id, b.id], BulkEditAction.addSet, s.id);
    expect((await sets.get(s.id)).members, hasLength(2));
    await edit([a.id, b.id], BulkEditAction.removeSet, s.id);
    expect((await sets.get(s.id)).members, isEmpty);
    expect(
        (await db.select(db.batterySetMemberships).get())
            .every((m) => m.removedAt != null),
        isTrue);
  });
  test(
      'invalid selection value date and relationship status reject before writes',
      () async {
    final a = await battery('A');
    for (final r in [
      BulkEditRequest(ids: [], action: BulkEditAction.note, value: 'X'),
      BulkEditRequest(
          ids: [a.id, a.id], action: BulkEditAction.note, value: 'X'),
      BulkEditRequest(
          ids: [a.id], action: BulkEditAction.purchasePrice, value: -1.0),
      BulkEditRequest(
          ids: [a.id], action: BulkEditAction.status, value: 'Assigned'),
      BulkEditRequest(
          ids: [a.id], action: BulkEditAction.status, value: 'Retired'),
      BulkEditRequest(
          ids: [a.id],
          action: BulkEditAction.retire,
          reason: 'Age',
          retirementDate: DateTime.now().add(const Duration(days: 1)))
    ]) {
      await expectLater(
          repo.preview(r), throwsA(isA<BulkValidationException>()));
    }
    expect((await batteries.get(a.id)).values.status, 'Available');
  });
  test('retirement records supplied date reason and retains Set history',
      () async {
    final a = await battery('A');
    final s = await sets.save(const SetDraft(userSetId: 'S', name: 'Set'));
    await sets.addMember(s.id, a.id);
    final date = DateTime.utc(2026, 8, 1);
    await repo.apply(await repo.preview(BulkEditRequest(
        ids: [a.id],
        action: BulkEditAction.retire,
        reason: 'Age',
        retirementDate: date)));
    final r = await batteries.get(a.id);
    expect(r.values.status, 'Retired');
    expect(r.retiredAt, date);
    expect(r.retirementReason, 'Age');
    expect((await sets.get(s.id)).members, hasLength(1));
    expect(await batteries.history(a.id), contains(contains('Age')));
  });
  test('assigned Batteries cannot be retired and no assignments close',
      () async {
    final a = await battery('A');
    final s = await sets.save(const SetDraft(userSetId: 'S', name: 'Set'));
    await sets.addMember(s.id, a.id);
    final d = await sets.createDevice('Radio');
    await sets.assign(s.id, d.id);
    await expectLater(
        repo.preview(BulkEditRequest(
            ids: [a.id],
            action: BulkEditAction.retire,
            reason: 'Replaced',
            retirementDate: DateTime.now())),
        throwsA(isA<BulkValidationException>()));
    expect((await batteries.get(a.id)).currentDevices, isNotEmpty);
    expect(
        (await db.select(db.assignments).get())
            .every((a) => a.removedAt == null),
        isTrue);
  });
  test('stale preview rejects all edits after one Battery changes', () async {
    final a = await battery('A'), b = await battery('B');
    final p = await repo.preview(BulkEditRequest(
        ids: [a.id, b.id], action: BulkEditAction.condition, value: 'Good'));
    await batteries.save(const BatteryDraft(userBatteryId: 'Renamed'),
        id: b.id);
    await expectLater(repo.apply(p), throwsA(isA<BulkValidationException>()));
    expect((await batteries.get(a.id)).values.condition, 'New');
  });
  test('second update failure rolls back data and activity', () async {
    final a = await battery('A'), b = await battery('B');
    final before = (await db.select(db.activityLog).get()).length;
    final p = await repo.preview(BulkEditRequest(
        ids: [a.id, b.id], action: BulkEditAction.condition, value: 'Good'));
    await db.customStatement(
        "CREATE TRIGGER fail_second BEFORE UPDATE ON batteries WHEN OLD.user_battery_id='B' BEGIN SELECT RAISE(ABORT,'injected'); END");
    await expectLater(repo.apply(p), throwsA(isA<Exception>()));
    expect((await batteries.get(a.id)).values.condition, 'New');
    expect((await db.select(db.activityLog).get()).length, before);
  });
  test('membership failure rolls back every new link and activity', () async {
    final a = await battery('A'), b = await battery('B');
    final s = await sets.save(const SetDraft(userSetId: 'S', name: 'Set'));
    final p = await repo.preview(BulkEditRequest(
        ids: [a.id, b.id], action: BulkEditAction.addSet, value: s.id));
    await db.customStatement(
        "CREATE TRIGGER fail_second BEFORE INSERT ON battery_set_memberships WHEN (SELECT COUNT(*) FROM battery_set_memberships)=1 BEGIN SELECT RAISE(ABORT,'injected'); END");
    await expectLater(repo.apply(p), throwsA(isA<Exception>()));
    expect((await sets.get(s.id)).members, isEmpty);
    expect((await batteries.get(a.id)).values.status, 'Available');
  });
  test(
      'Set mismatch warning rolls back then acknowledgment applies exact selection',
      () async {
    final a = await battery('A');
    final old = await batteries.save(const BatteryDraft(
        userBatteryId: 'Old', capacity: 10, capacityUnit: 'mAh'));
    final s = await sets.save(const SetDraft(userSetId: 'S', name: 'Set'));
    await sets.addMember(s.id, old.id);
    final p = await repo.preview(BulkEditRequest(
        ids: [a.id], action: BulkEditAction.addSet, value: s.id));
    Set<String> warnings = {};
    try {
      await repo.apply(p);
      fail('Expected warnings');
    } on SetWarnings catch (e) {
      warnings = e.messages;
    }
    expect((await sets.get(s.id)).members, hasLength(1));
    await repo.apply(p, acceptedWarnings: warnings);
    expect((await sets.get(s.id)).members, hasLength(2));
  });
  test('retirement and appended note survive SQLite restart', () async {
    await db.close();
    final root = await Directory.systemTemp.createTemp('bulk-edit-restart-');
    final file = File(root.path + '/db.sqlite');
    try {
      bind(AppDatabase.forTesting(NativeDatabase(file)));
      final a = await battery('A');
      await edit([a.id], BulkEditAction.note, 'Persistent');
      final date = DateTime.utc(2026, 1, 1);
      await repo.apply(await repo.preview(BulkEditRequest(
          ids: [a.id],
          action: BulkEditAction.retire,
          reason: 'Lost',
          retirementDate: date)));
      await db.close();
      bind(AppDatabase.forTesting(NativeDatabase(file)));
      final r = await batteries.get(a.id);
      expect(r.retiredAt, date);
      expect(r.retirementReason, 'Lost');
      expect(r.values.notes, 'Original\nPersistent');
      expect(r.id, a.id);
    } finally {
      await db.close();
      bind(AppDatabase.forTesting(NativeDatabase.memory()));
      await root.delete(recursive: true);
    }
  });
}
