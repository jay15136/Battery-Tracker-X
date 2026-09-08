import 'dart:async';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/features/history/data/drift_history_repository.dart';
import 'package:battery_tracker/features/history/domain/history.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftHistoryRepository repo;
  final now = DateTime.utc(2026, 9, 8, 12);
  String uuid() => const UuidV4PermanentIdGenerator().next().value;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DriftHistoryRepository(db);
  });
  tearDown(() => db.close());

  Future<int> battery(String id) => db
      .into(db.batteries)
      .insert(BatteriesCompanion.insert(uuid: uuid(), userBatteryId: id));
  Future<int> device(String name) => db
      .into(db.devices)
      .insert(DevicesCompanion.insert(uuid: uuid(), name: name));
  Future<int> set(String id) => db.into(db.batterySets).insert(
      BatterySetsCompanion.insert(uuid: uuid(), userSetId: id, name: id));

  Future<void> event(
          {required String entityType,
          required String entityUuid,
          String eventType = 'battery_updated',
          String summary = 'Event',
          DateTime? at,
          String? operationUuid}) =>
      db.into(db.activityLog).insert(ActivityLogCompanion.insert(
          uuid: uuid(),
          eventType: eventType,
          entityType: entityType,
          entityUuid: entityUuid,
          summary: summary,
          operationUuid: Value(operationUuid),
          occurredAt: Value(at ?? now)));

  test('empty database yields no entries and a zero total', () async {
    final result =
        await repo.query(const HistoryFilter(), limit: 25, offset: 0);
    expect(result.entries, isEmpty);
    expect(result.totalCount, 0);
  });

  test('date range bounds are inclusive on both ends', () async {
    final id = await battery('A');
    final row = await (db.select(db.batteries)..where((t) => t.id.equals(id)))
        .getSingle();
    await event(
        entityType: 'battery',
        entityUuid: row.uuid,
        summary: 'Before',
        at: now.subtract(const Duration(days: 2)));
    await event(
        entityType: 'battery',
        entityUuid: row.uuid,
        summary: 'On from',
        at: now);
    await event(
        entityType: 'battery',
        entityUuid: row.uuid,
        summary: 'On to',
        at: now.add(const Duration(days: 1)));
    await event(
        entityType: 'battery',
        entityUuid: row.uuid,
        summary: 'After',
        at: now.add(const Duration(days: 3)));
    final result = await repo.query(
        HistoryFilter(from: now, to: now.add(const Duration(days: 1))),
        limit: 25,
        offset: 0);
    expect(result.totalCount, 2);
    expect(result.entries.map((e) => e.summary).toSet(), {'On from', 'On to'});
  });

  test(
      'catalogued event types map to their category and unknown types fall back to Other',
      () async {
    final id = await battery('A');
    final row = await (db.select(db.batteries)..where((t) => t.id.equals(id)))
        .getSingle();
    await event(
        entityType: 'battery',
        entityUuid: row.uuid,
        eventType: 'battery_created');
    await event(
        entityType: 'battery',
        entityUuid: row.uuid,
        eventType: 'battery_charged');
    await event(
        entityType: 'battery',
        entityUuid: row.uuid,
        eventType: 'a_future_event_type');
    final additions = await repo.query(
        const HistoryFilter(category: HistoryCategory.additions),
        limit: 25,
        offset: 0);
    expect(additions.totalCount, 1);
    expect(additions.entries.single.eventType, 'battery_created');
    final other = await repo.query(
        const HistoryFilter(category: HistoryCategory.other),
        limit: 25,
        offset: 0);
    expect(other.totalCount, 1);
    expect(other.entries.single.eventType, 'a_future_event_type');
    expect(other.entries.single.category, HistoryCategory.other);
  });

  test(
      'entity filter is mutually exclusive between Battery, Set, and Device rows',
      () async {
    final batteryId = await battery('BAT-1');
    final b = await (db.select(db.batteries)
          ..where((t) => t.id.equals(batteryId)))
        .getSingle();
    final deviceId = await device('Radio');
    final d = await (db.select(db.devices)..where((t) => t.id.equals(deviceId)))
        .getSingle();
    await event(
        entityType: 'battery', entityUuid: b.uuid, summary: 'Battery event');
    await event(
        entityType: 'device', entityUuid: d.uuid, summary: 'Device event');
    final byBattery = await repo.query(
        HistoryFilter(
            entity: HistoryEntityFilter(
                type: HistoryEntityType.battery,
                id: PermanentId.parse(b.uuid),
                label: 'BAT-1')),
        limit: 25,
        offset: 0);
    expect(byBattery.entries.map((e) => e.summary), ['Battery event']);
    final byDevice = await repo.query(
        HistoryFilter(
            entity: HistoryEntityFilter(
                type: HistoryEntityType.device,
                id: PermanentId.parse(d.uuid),
                label: 'Radio')),
        limit: 25,
        offset: 0);
    expect(byDevice.entries.map((e) => e.summary), ['Device event']);
  });

  test('pagination reports the true total while limiting the current page',
      () async {
    for (var i = 0; i < 30; i++) {
      await event(
          entityType: 'battery',
          entityUuid: uuid(),
          summary: 'Event $i',
          at: now.add(Duration(minutes: i)));
    }
    final page = await repo.query(const HistoryFilter(), limit: 10, offset: 0);
    expect(page.totalCount, 30);
    expect(page.entries.length, 10);
    expect(page.entries.first.summary, 'Event 29');
    final nextPage =
        await repo.query(const HistoryFilter(), limit: 10, offset: 10);
    expect(nextPage.entries.first.summary, 'Event 19');
  });

  test('deleted records keep their historical text and are marked unavailable',
      () async {
    final id = await battery('Gone');
    final row = await (db.select(db.batteries)..where((t) => t.id.equals(id)))
        .getSingle();
    await event(
        entityType: 'battery',
        entityUuid: row.uuid,
        summary: 'Battery created.');
    var entry = (await repo.query(const HistoryFilter(), limit: 25, offset: 0))
        .entries
        .single;
    expect(entry.available, isTrue);
    expect(entry.entityLabel, 'Gone');
    await (db.update(db.batteries)..where((t) => t.id.equals(id)))
        .write(BatteriesCompanion(deletedAt: Value(now)));
    entry = (await repo.query(const HistoryFilter(), limit: 25, offset: 0))
        .entries
        .single;
    expect(entry.available, isFalse);
    expect(entry.summary, 'Battery created.');
  });

  test('entity options list active records sorted by label and exclude deleted',
      () async {
    await battery('B-002');
    await battery('B-001');
    final deleted = await battery('B-DELETED');
    await (db.update(db.batteries)..where((t) => t.id.equals(deleted)))
        .write(BatteriesCompanion(deletedAt: Value(now)));
    final options = await repo.entityOptions(HistoryEntityType.battery);
    expect(options.map((o) => o.label), ['B-001', 'B-002']);
  });

  test('watch emits an initial snapshot and reacts to newly recorded activity',
      () async {
    final stream =
        StreamIterator(repo.watch(const HistoryFilter(), limit: 25, offset: 0));
    try {
      expect(await stream.moveNext(), isTrue);
      expect(stream.current.totalCount, 0);
      await event(entityType: 'battery', entityUuid: uuid(), summary: 'New');
      expect(
          await stream.moveNext().timeout(const Duration(seconds: 3)), isTrue);
      expect(stream.current.totalCount, 1);
    } finally {
      await stream.cancel();
    }
  });

  test('Set membership rows resolve against the Set table independently',
      () async {
    final setId = await set('S-1');
    final s = await (db.select(db.batterySets)
          ..where((t) => t.id.equals(setId)))
        .getSingle();
    await event(
        entityType: 'battery_set',
        entityUuid: s.uuid,
        eventType: 'set_member_added',
        summary: 'Member added.');
    final result = await repo.query(
        const HistoryFilter(category: HistoryCategory.setMembership),
        limit: 25,
        offset: 0);
    expect(result.entries.single.entityLabel, 'S-1');
  });
}
