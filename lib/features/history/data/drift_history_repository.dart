import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/schema/utc_date_time_text_converter.dart';
import '../../../core/identity/permanent_id.dart';
import '../domain/history.dart';

const _dateConverter = UtcDateTimeTextConverter();

/// Reads the shared `activity_log` table for the unified History section.
///
/// History never writes activity; every feature repository already appends
/// its own events. This repository only filters, paginates, and resolves
/// current Battery/Battery Set/Device labels so deleted or deactivated
/// entities still show their historical text.
final class DriftHistoryRepository implements HistoryRepository {
  DriftHistoryRepository(this.db);
  final AppDatabase db;

  static final List<String> _catalogued = [
    for (final set in historyCategoryEventTypes.values) ...set
  ];

  Expression<bool> _where($ActivityLogTable t, HistoryFilter filter) {
    Expression<bool> where = const Constant(true);
    if (filter.from != null) {
      where = where &
          t.occurredAt.isBiggerOrEqualValue(_dateConverter.toSql(filter.from!));
    }
    if (filter.to != null) {
      where = where &
          t.occurredAt.isSmallerOrEqualValue(_dateConverter.toSql(filter.to!));
    }
    final category = filter.category;
    if (category != null) {
      final known = historyCategoryEventTypes[category];
      where = where &
          (known == null
              ? t.eventType.isNotIn(_catalogued)
              : t.eventType.isIn(known));
    }
    final entity = filter.entity;
    if (entity != null) {
      where = where &
          t.entityType.equals(entity.type.storage) &
          t.entityUuid.equals(entity.id.value);
    }
    return where;
  }

  @override
  Future<HistoryResult> query(HistoryFilter filter,
      {required int limit, required int offset}) async {
    final totalRow = await (db.selectOnly(db.activityLog)
          ..addColumns([db.activityLog.id.count()])
          ..where(_where(db.activityLog, filter)))
        .getSingle();
    final total = totalRow.read(db.activityLog.id.count()) ?? 0;
    final rows = await (db.select(db.activityLog)
          ..where((t) => _where(t, filter))
          ..orderBy([
            (t) => OrderingTerm.desc(t.occurredAt),
            (t) => OrderingTerm.desc(t.id)
          ])
          ..limit(limit, offset: offset))
        .get();
    final labels = await _currentLabels(rows);
    return HistoryResult(
        entries: rows
            .map((row) => _entry(row, labels[row.entityType] ?? const {}))
            .toList(),
        totalCount: total);
  }

  @override
  Stream<HistoryResult> watch(HistoryFilter filter,
      {required int limit, required int offset}) {
    return Stream.multi((controller) {
      var canceled = false;
      var pending = Future<void>.value();
      void reload() {
        pending = pending.then((_) async {
          if (canceled) return;
          try {
            final result = await query(filter, limit: limit, offset: offset);
            if (!canceled) controller.add(result);
          } on Object catch (error, stack) {
            if (!canceled) controller.addError(error, stack);
          }
        });
      }

      final subscription = db
          .tableUpdates(TableUpdateQuery.onAllTables(
              [db.activityLog, db.batteries, db.batterySets, db.devices]))
          .listen((_) => reload(), onError: controller.addError);
      reload();
      controller.onCancel = () async {
        canceled = true;
        await subscription.cancel();
      };
    });
  }

  @override
  Future<List<HistoryEntityOption>> entityOptions(
      HistoryEntityType type) async {
    switch (type) {
      case HistoryEntityType.battery:
        final rows = await (db.select(db.batteries)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.userBatteryId)]))
            .get();
        return [
          for (final r in rows)
            HistoryEntityOption(
                id: PermanentId.parse(r.uuid), label: r.userBatteryId)
        ];
      case HistoryEntityType.batterySet:
        final rows = await (db.select(db.batterySets)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.userSetId)]))
            .get();
        return [
          for (final r in rows)
            HistoryEntityOption(
                id: PermanentId.parse(r.uuid),
                label: '${r.userSetId} — ${r.name}')
        ];
      case HistoryEntityType.device:
        final rows = await (db.select(db.devices)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.name)]))
            .get();
        return [
          for (final r in rows)
            HistoryEntityOption(id: PermanentId.parse(r.uuid), label: r.name)
        ];
    }
  }

  Future<Map<String, Map<String, _Current>>> _currentLabels(
      List<ActivityLogData> rows) async {
    final byType = <String, Set<String>>{};
    for (final row in rows) {
      (byType[row.entityType] ??= {}).add(row.entityUuid);
    }
    final result = <String, Map<String, _Current>>{};
    final batteryIds = byType['battery'];
    if (batteryIds != null && batteryIds.isNotEmpty) {
      final rows = await (db.select(db.batteries)
            ..where((t) => t.uuid.isIn(batteryIds)))
          .get();
      result['battery'] = {
        for (final r in rows)
          r.uuid: _Current(label: r.userBatteryId, deleted: r.deletedAt != null)
      };
    }
    final setIds = byType['battery_set'];
    if (setIds != null && setIds.isNotEmpty) {
      final rows = await (db.select(db.batterySets)
            ..where((t) => t.uuid.isIn(setIds)))
          .get();
      result['battery_set'] = {
        for (final r in rows)
          r.uuid: _Current(label: r.userSetId, deleted: r.deletedAt != null)
      };
    }
    final deviceIds = byType['device'];
    if (deviceIds != null && deviceIds.isNotEmpty) {
      final rows = await (db.select(db.devices)
            ..where((t) => t.uuid.isIn(deviceIds)))
          .get();
      result['device'] = {
        for (final r in rows)
          r.uuid: _Current(label: r.name, deleted: r.deletedAt != null)
      };
    }
    return result;
  }

  HistoryEntry _entry(ActivityLogData row, Map<String, _Current> labels) {
    final current = labels[row.entityUuid];
    return HistoryEntry(
        uuid: row.uuid,
        eventType: row.eventType,
        entityType: row.entityType,
        entityUuid: row.entityUuid,
        summary: row.summary,
        occurredAt: row.occurredAt,
        available: current != null && !current.deleted,
        entityLabel: current?.label,
        operationUuid: row.operationUuid);
  }
}

final class _Current {
  const _Current({required this.label, required this.deleted});
  final String label;
  final bool deleted;
}
