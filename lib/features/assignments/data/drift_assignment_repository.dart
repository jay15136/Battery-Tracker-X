import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/identity/permanent_id.dart';
import '../domain/assignment.dart';

final class DriftAssignmentRepository implements AssignmentRepository {
  DriftAssignmentRepository(
      {required this.db,
      this.ids = const UuidV4PermanentIdGenerator(),
      DateTime Function()? clock})
      : clock = clock ?? (() => DateTime.now().toUtc());
  final AppDatabase db;
  final PermanentIdGenerator ids;
  final DateTime Function() clock;
  @override
  Future<List<AssignmentRecord>> list() async {
    final rows = await db
        .customSelect(
            'SELECT a.*,d.uuid AS device_uuid,d.name AS device_name,b.uuid AS battery_uuid,b.user_battery_id,s.uuid AS set_uuid,s.user_set_id,s.name AS set_name,p.uuid AS parent_uuid FROM assignments a JOIN devices d ON d.id=a.device_id LEFT JOIN batteries b ON b.id=a.battery_id LEFT JOIN battery_sets s ON s.id=a.battery_set_id LEFT JOIN assignments p ON p.id=a.source_set_assignment_id ORDER BY a.assigned_at DESC,a.id DESC')
        .get();
    final removals = await (db.select(db.activityLog)
          ..where((t) =>
              t.entityType.equals('assignment') &
              t.eventType.equals('assignment_removed')))
        .get();
    final removalNotes = <String, String?>{
      for (final a in removals)
        a.entityUuid: (jsonDecode(a.metadataJson)
            as Map<String, dynamic>)['notes'] as String?
    };
    return rows.map((r) {
      final uuid = r.read<String>('uuid');
      return AssignmentRecord(
          id: PermanentId.parse(uuid),
          deviceId: PermanentId.parse(r.read<String>('device_uuid')),
          deviceName: r.read<String>('device_name'),
          label: r.readNullable<String>('user_battery_id') ??
              '${r.read<String>('user_set_id')} · ${r.read<String>('set_name')}',
          batteryId: _id(r.readNullable<String>('battery_uuid')),
          setId: _id(r.readNullable<String>('set_uuid')),
          parentId: _id(r.readNullable<String>('parent_uuid')),
          assignedAt: DateTime.parse(r.read<String>('assigned_at')),
          removedAt:
              DateTime.tryParse(r.readNullable<String>('removed_at') ?? ''),
          notes: r.readNullable<String>('notes'),
          overrideReason: r.readNullable<String>('override_reason'),
          removalNotes: removalNotes[uuid],
          memberIds: rows
              .where((a) => a.readNullable<String>('parent_uuid') == uuid)
              .map((a) => PermanentId.parse(a.read<String>('battery_uuid')))
              .toList());
    }).toList();
  }

  void _date(DateTime at) {
    if (at.isAfter(clock()))
      throw const AssignmentValidationException(
          'Choose a date and time that is not in the future.');
  }

  Future<void> _timeline(
      List<Assignment> history, DateTime at, String label) async {
    if (history.any((a) => a.removedAt == null))
      throw AssignmentValidationException(
          'Remove $label from its current Device before assigning it again.');
    if (history.any((a) => a.removedAt!.isAfter(at)))
      throw AssignmentValidationException(
          'The assignment date overlaps recorded history for $label. Choose a date on or after its last removal.');
  }

  @override
  Future<void> assign(
          {required PermanentId deviceId,
          List<PermanentId> batteryIds = const [],
          PermanentId? setId,
          DateTime? assignedAt,
          String? notes,
          Set<String> acceptedWarnings = const {}}) =>
      db.transaction(() async {
        if ((setId == null) == batteryIds.isEmpty)
          throw const AssignmentValidationException(
              'Choose Batteries or one Battery Set.');
        if (batteryIds.toSet().length != batteryIds.length)
          throw const AssignmentValidationException(
              'Select each Battery only once.');
        final at = (assignedAt ?? clock()).toUtc();
        _date(at);
        final device = await (db.select(db.devices)
              ..where((t) =>
                  t.uuid.equals(deviceId.value) &
                  t.deletedAt.isNull() &
                  t.deactivatedAt.isNull()))
            .getSingleOrNull();
        if (device == null)
          throw const AssignmentValidationException('Choose an active Device.');
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
            throw const AssignmentValidationException(
                'Choose an active Battery Set.');
          await _timeline(
              await (db.select(db.assignments)
                    ..where((t) => t.batterySetId.equals(set!.id)))
                  .get(),
              at,
              set.userSetId);
          final links = await (db.select(db.batterySetMemberships)
                ..where((t) =>
                    t.batterySetId.equals(set!.id) & t.removedAt.isNull()))
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
              throw const AssignmentValidationException(
                  'A selected Battery is no longer available.');
            members.add(b);
          }
        }
        if (members.isEmpty)
          throw const AssignmentValidationException(
              'Select at least one Battery or a nonempty Set.');
        final warnings = <String>{};
        final occupants = await (db.select(db.assignments)
              ..where((t) =>
                  t.deviceId.equals(device.id) &
                  t.batteryId.isNotNull() &
                  t.removedAt.isNull()))
            .get();
        if (device.requiredBatteryQuantity != null &&
            device.requiredBatteryQuantity != members.length + occupants.length)
          warnings.add(
              '${device.name} requires ${device.requiredBatteryQuantity} Batteries; this assignment will leave ${members.length + occupants.length}.');
        if (occupants.isNotEmpty)
          warnings.add(
              '${device.name} already has ${occupants.length} assigned Batteries. These will remain assigned.');
        for (final b in members) {
          if (b.deletedAt != null ||
              b.retiredAt != null ||
              b.status == 'Retired' ||
              b.condition == 'Retired')
            throw AssignmentValidationException(
                '${b.userBatteryId} is retired or deleted. Choose another Battery.');
          await _timeline(
              await (db.select(db.assignments)
                    ..where((t) => t.batteryId.equals(b.id)))
                  .get(),
              at,
              b.userBatteryId);
          if (device.requiredBatteryTypeId != null &&
              device.requiredBatteryTypeId != b.batteryTypeId)
            warnings.add(
                '${b.userBatteryId} differs from the Device required Battery Type.');
          if (device.requiredVoltage != null &&
              device.requiredVoltage != b.nominalVoltage)
            warnings.add(
                '${b.userBatteryId} differs from the Device required voltage.');
          if (!['Available', 'In Set'].contains(b.status) ||
              b.condition == 'Damaged')
            warnings.add('${b.userBatteryId} is ${b.status}/${b.condition}.');
          if (set == null) {
            final links = await db.customSelect(
                'SELECT s.user_set_id FROM battery_set_memberships m JOIN battery_sets s ON s.id=m.battery_set_id WHERE m.battery_id=? AND m.removed_at IS NULL AND s.deleted_at IS NULL AND s.deactivated_at IS NULL',
                variables: [Variable.withInt(b.id)]).get();
            for (final l in links) {
              warnings.add(
                  '${b.userBatteryId} belongs to ${l.read<String>('user_set_id')}. Only this Battery will be assigned; membership stays unchanged.');
            }
          }
        }
        if (!acceptedWarnings.containsAll(warnings))
          throw AssignmentWarnings(Set.unmodifiable(warnings));
        final operation = ids.next().value;
        int? parent;
        if (set != null) {
          parent = await db.into(db.assignments).insert(
              AssignmentsCompanion.insert(
                  uuid: ids.next().value,
                  subjectType: 'battery_set',
                  batterySetId: Value(set.id),
                  deviceId: device.id,
                  operationUuid: operation,
                  assignedAt: Value(at),
                  notes: Value(_optional(notes)),
                  overrideReason:
                      Value(warnings.isEmpty ? null : warnings.join('\n'))));
          await _event('battery_set', set.uuid, 'set_assigned',
              'Set assigned to ${device.name}.', {
            'operation_uuid': operation,
            'assigned_at': at.toIso8601String(),
            'notes': _optional(notes)
          });
        }
        for (final b in members) {
          await db.into(db.assignments).insert(AssignmentsCompanion.insert(
              uuid: ids.next().value,
              subjectType: 'battery',
              batteryId: Value(b.id),
              deviceId: device.id,
              sourceSetAssignmentId: Value(parent),
              operationUuid: operation,
              assignedAt: Value(at),
              notes: Value(_optional(notes)),
              overrideReason:
                  Value(warnings.isEmpty ? null : warnings.join('\n'))));
          await _status(b, force: true);
          await _event(
              'battery',
              b.uuid,
              'battery_assigned',
              'Assigned to ${device.name}${set == null ? '' : ' through Set ${set.userSetId}'}.',
              {
                'operation_uuid': operation,
                'assigned_at': at.toIso8601String(),
                'notes': _optional(notes)
              });
        }
        await _event(
            'device',
            device.uuid,
            'inventory_assigned',
            '${members.length} Batteries assigned${set == null ? '' : ' through Set ${set.userSetId}'}.',
            {
              'operation_uuid': operation,
              'warnings': warnings.toList(),
              'assigned_at': at.toIso8601String(),
              'notes': _optional(notes)
            });
      });
  @override
  Future<void> remove(List<PermanentId> assignmentIds,
          {DateTime? removedAt, String? notes}) =>
      db.transaction(() async {
        if (assignmentIds.isEmpty)
          throw const AssignmentValidationException(
              'Select an assignment to remove.');
        final at = (removedAt ?? clock()).toUtc();
        _date(at);
        final targets = <int, Assignment>{};
        for (final id in assignmentIds.toSet()) {
          final row = await (db.select(db.assignments)
                ..where((t) => t.uuid.equals(id.value)))
              .getSingleOrNull();
          if (row == null || row.removedAt != null)
            throw const AssignmentValidationException(
                'An assignment is no longer current. Refresh and try again.');
          if (row.sourceSetAssignmentId != null)
            throw const AssignmentValidationException(
                'Remove the whole Set assignment to keep its member records consistent.');
          targets[row.id] = row;
          if (row.batterySetId != null) {
            for (final child in await (db.select(db.assignments)
                  ..where((t) =>
                      t.sourceSetAssignmentId.equals(row.id) &
                      t.removedAt.isNull()))
                .get()) {
              targets[child.id] = child;
            }
          }
        }
        if (targets.values.any((a) => at.isBefore(a.assignedAt)))
          throw const AssignmentValidationException(
              'Removal date cannot precede the assignment date.');
        for (final a in targets.values) {
          await (db.update(db.assignments)..where((t) => t.id.equals(a.id)))
              .write(AssignmentsCompanion(removedAt: Value(at)));
        }
        final operation = ids.next().value;
        for (final a in targets.values) {
          await _event('assignment', a.uuid, 'assignment_removed',
              'Assignment closed; original installation details retained.', {
            'notes': _optional(notes),
            'removed_at': at.toIso8601String(),
            'operation_uuid': operation
          });
          if (a.batteryId != null) {
            final b = await (db.select(db.batteries)
                  ..where((t) => t.id.equals(a.batteryId!)))
                .getSingle();
            await _status(b);
            await _event('battery', b.uuid, 'battery_removed_from_device',
                'Removed from Device.', {
              'notes': _optional(notes),
              'removed_at': at.toIso8601String(),
              'operation_uuid': operation
            });
          } else {
            final s = await (db.select(db.batterySets)
                  ..where((t) => t.id.equals(a.batterySetId!)))
                .getSingle();
            await _event('battery_set', s.uuid, 'set_removed_from_device',
                'Set removed from Device; assignment history retained.', {
              'notes': _optional(notes),
              'removed_at': at.toIso8601String(),
              'operation_uuid': operation
            });
          }
        }
        for (final deviceId in targets.values.map((a) => a.deviceId).toSet()) {
          final d = await (db.select(db.devices)
                ..where((t) => t.id.equals(deviceId)))
              .getSingle();
          await _event(
              'device',
              d.uuid,
              'inventory_removed',
              'Inventory removed; assignment history retained.',
              {'notes': _optional(notes), 'operation_uuid': operation});
        }
      });
  Future<void> _status(Battery b, {bool force = false}) async {
    if (!force && !['Available', 'Assigned', 'In Set'].contains(b.status))
      return;
    final assigned = await (db.select(db.assignments)
          ..where((t) => t.batteryId.equals(b.id) & t.removedAt.isNull()))
        .get();
    final member = await db.customSelect(
        'SELECT m.id FROM battery_set_memberships m JOIN battery_sets s ON s.id=m.battery_set_id WHERE m.battery_id=? AND m.removed_at IS NULL AND s.deleted_at IS NULL AND s.deactivated_at IS NULL',
        variables: [Variable.withInt(b.id)]).get();
    final status = assigned.isNotEmpty
        ? 'Assigned'
        : member.isNotEmpty
            ? 'In Set'
            : 'Available';
    if (status != b.status) {
      await (db.update(db.batteries)..where((t) => t.id.equals(b.id))).write(
          BatteriesCompanion(
              status: Value(status), modifiedAt: Value(clock())));
      await _event('battery', b.uuid, 'battery_status_changed',
          'Status: ${b.status} → $status.');
    }
  }

  Future<void> _event(String entity, String uuid, String type, String summary,
      [Map<String, Object?> metadata = const {}]) async {
    await db.into(db.activityLog).insert(ActivityLogCompanion.insert(
        uuid: ids.next().value,
        eventType: type,
        entityType: entity,
        entityUuid: uuid,
        summary: summary,
        metadataJson: Value(jsonEncode(metadata)),
        occurredAt: Value(clock())));
  }
}

PermanentId? _id(String? id) => id == null ? null : PermanentId.parse(id);
String? _optional(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
