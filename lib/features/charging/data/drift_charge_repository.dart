import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/identity/permanent_id.dart';
import '../domain/charge.dart';

final class DriftChargeRepository implements ChargeRepository {
  DriftChargeRepository(
      {required this.db,
      this.ids = const UuidV4PermanentIdGenerator(),
      DateTime Function()? clock})
      : clock = clock ?? (() => DateTime.now().toUtc());
  final AppDatabase db;
  final PermanentIdGenerator ids;
  final DateTime Function() clock;
  @override
  Future<List<RecordedCharge>> list(
      {PermanentId? batteryId, PermanentId? setId}) async {
    final filters = <String>[], variables = <Variable>[];
    if (batteryId != null) {
      filters.add('b.uuid=?');
      variables.add(Variable.withString(batteryId.value));
    }
    if (setId != null) {
      filters.add('s.uuid=?');
      variables.add(Variable.withString(setId.value));
    }
    final rows = await db
        .customSelect(
            'SELECT c.*,b.uuid AS battery_uuid,b.user_battery_id,s.uuid AS set_uuid,s.user_set_id FROM charge_records c JOIN batteries b ON b.id=c.battery_id LEFT JOIN set_charge_records sc ON sc.id=c.source_set_charge_id LEFT JOIN battery_sets s ON s.id=sc.battery_set_id ${filters.isEmpty ? '' : 'WHERE ${filters.join(' AND ')}'} ORDER BY c.charged_at DESC,c.id DESC',
            variables: variables)
        .get();
    return rows
        .map((r) => RecordedCharge(
            id: PermanentId.parse(r.read<String>('uuid')),
            batteryId: PermanentId.parse(r.read<String>('battery_uuid')),
            batteryLabel: r.read<String>('user_battery_id'),
            chargedAt: DateTime.parse(r.read<String>('charged_at')),
            startPercent: r.readNullable<int>('starting_charge_percent'),
            endPercent: r.readNullable<int>('ending_charge_percent'),
            charger: r.readNullable<String>('charger'),
            notes: r.readNullable<String>('notes'),
            setId: r.readNullable<String>('set_uuid') == null
                ? null
                : PermanentId.parse(r.read<String>('set_uuid')),
            setLabel: r.readNullable<String>('user_set_id'),
            operationId: r.readNullable<String>('bulk_operation_uuid')))
        .toList();
  }

  @override
  Future<void> record(ChargeDraft draft,
      {List<PermanentId> batteryIds = const [], PermanentId? setId}) async {
    draft.validate();
    await db.transaction(() async {
      final at = draft.chargedAt.toUtc();
      final now = clock();
      if (at.isAfter(now))
        throw const ChargeValidationException(
            'Charge date cannot be in the future.');
      if ((setId == null) == batteryIds.isEmpty)
        throw const ChargeValidationException(
            'Select Batteries or one Battery Set.');
      if (batteryIds.toSet().length != batteryIds.length)
        throw const ChargeValidationException('Select each Battery only once.');
      BatterySet? set;
      final members = <Battery>[];
      if (setId != null) {
        set = await (db.select(db.batterySets)
              ..where((t) =>
                  t.uuid.equals(setId.value) &
                  t.deletedAt.isNull() &
                  t.deactivatedAt.isNull()))
            .getSingleOrNull();
        if (set == null)
          throw const ChargeValidationException(
              'Choose an active Battery Set.');
        final links = await (db.select(db.batterySetMemberships)
              ..where(
                  (t) => t.batterySetId.equals(set!.id) & t.removedAt.isNull()))
            .get();
        for (final link in links) {
          members.add(await (db.select(db.batteries)
                ..where((t) => t.id.equals(link.batteryId)))
              .getSingle());
        }
      } else {
        for (final id in batteryIds) {
          final b = await (db.select(db.batteries)
                ..where((t) => t.uuid.equals(id.value)))
              .getSingleOrNull();
          if (b == null)
            throw const ChargeValidationException(
                'A selected Battery is no longer available.');
          members.add(b);
        }
      }
      if (members.isEmpty)
        throw const ChargeValidationException(
            'Select at least one Battery or a nonempty Set.');
      for (final b in members) {
        if (b.deletedAt != null ||
            b.retiredAt != null ||
            b.status == 'Retired' ||
            b.condition == 'Retired' ||
            !b.rechargeable)
          throw ChargeValidationException(
              '${b.userBatteryId} is retired, deleted, or non-rechargeable. Update the selection before recording a charge.');
      }
      final operation = ids.next().value;
      int? parent;
      if (set != null) {
        parent = await db.into(db.setChargeRecords).insert(
            SetChargeRecordsCompanion.insert(
                uuid: ids.next().value,
                batterySetId: set.id,
                chargedAt: Value(at),
                notes: Value(_optional(draft.notes)),
                createdAt: Value(now),
                operationUuid: operation));
      }
      for (final b in members) {
        await db.into(db.chargeRecords).insert(ChargeRecordsCompanion.insert(
            uuid: ids.next().value,
            batteryId: b.id,
            chargedAt: Value(at),
            startingChargePercent: Value(draft.startPercent),
            endingChargePercent: Value(draft.endPercent),
            charger: Value(_optional(draft.charger)),
            notes: Value(_optional(draft.notes)),
            sourceSetChargeId: Value(parent),
            bulkOperationUuid: Value(operation),
            createdAt: Value(now)));
        if (draft.updateCurrentEstimate)
          await _estimate(b, draft.endPercent, operation: operation);
        if (b.status == 'Charging' && !at.isBefore(b.modifiedAt)) {
          final assigned = await (db.select(db.assignments)
                ..where((t) => t.batteryId.equals(b.id) & t.removedAt.isNull()))
              .get();
          final membership = await db.customSelect(
              'SELECT m.id FROM battery_set_memberships m JOIN battery_sets s ON s.id=m.battery_set_id WHERE m.battery_id=? AND m.removed_at IS NULL AND s.deleted_at IS NULL AND s.deactivated_at IS NULL',
              variables: [Variable.withInt(b.id)]).get();
          final status = assigned.isNotEmpty
              ? 'Assigned'
              : membership.isNotEmpty
                  ? 'In Set'
                  : 'Available';
          await (db.update(db.batteries)..where((t) => t.id.equals(b.id)))
              .write(BatteriesCompanion(
                  status: Value(status), modifiedAt: Value(now)));
          await _event('battery', b.uuid, 'battery_status_changed',
              'Status: Charging → $status.');
        }
        await _event(
            'battery',
            b.uuid,
            'battery_charged',
            'Recorded charge${set == null ? '' : ' from Set ${set.userSetId}'}.',
            {
              'charged_at': at.toIso8601String(),
              'operation_uuid': operation,
              'start_percent': draft.startPercent,
              'end_percent': draft.endPercent,
              'charger': _optional(draft.charger),
              'notes': _optional(draft.notes)
            });
      }
      if (set != null)
        await _event('battery_set', set.uuid, 'set_charged',
            'Recorded charge for ${members.length} current Set members.', {
          'operation_uuid': operation,
          'member_count': members.length,
          'notes': _optional(draft.notes),
          'charged_at': at.toIso8601String()
        });
    });
  }

  @override
  Future<void> setEstimate(PermanentId batteryId, int? percent) =>
      db.transaction(() async {
        if (percent != null && (percent < 0 || percent > 100))
          throw const ChargeValidationException(
              'Current estimate must be a whole number from 0 to 100.');
        final b = await (db.select(db.batteries)
              ..where(
                  (t) => t.uuid.equals(batteryId.value) & t.deletedAt.isNull()))
            .getSingleOrNull();
        if (b == null)
          throw const ChargeValidationException(
              'This Battery is no longer available.');
        await _estimate(b, percent);
      });
  Future<void> _estimate(Battery b, int? percent, {String? operation}) async {
    await (db.update(db.batteries)..where((t) => t.id.equals(b.id))).write(
        BatteriesCompanion(
            estimatedChargePercent: Value(percent),
            modifiedAt: Value(clock())));
    await _event(
        'battery',
        b.uuid,
        'charge_estimate_updated',
        percent == null
            ? 'Manual current charge estimate cleared.'
            : 'Manual current charge estimate: $percent%.',
        {
          'previous_percent': b.estimatedChargePercent,
          'percent': percent,
          'operation_uuid': operation
        });
  }

  Future<void> _event(String entity, String id, String type, String summary,
      [Map<String, Object?> metadata = const {}]) async {
    await db.into(db.activityLog).insert(ActivityLogCompanion.insert(
        uuid: ids.next().value,
        eventType: type,
        entityType: entity,
        entityUuid: id,
        summary: summary,
        metadataJson: Value(jsonEncode(metadata)),
        occurredAt: Value(clock())));
  }
}

String? _optional(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
