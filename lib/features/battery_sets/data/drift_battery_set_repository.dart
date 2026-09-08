import '../../charging/domain/charge.dart';
import '../../charging/data/drift_charge_repository.dart';
import '../../assignments/domain/assignment.dart';
import '../../assignments/data/drift_assignment_repository.dart';
import '../../devices/domain/device.dart';
import '../../devices/data/drift_device_repository.dart';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:sqlite3/sqlite3.dart';
import '../../../core/database/app_database.dart';
import '../../../core/identity/permanent_id.dart';
import '../../../core/storage/managed_relative_path.dart';
import '../../batteries/domain/battery.dart';
import '../../icons/domain/icon_color.dart';
import '../../icons/domain/icon_definition.dart';
import '../../icons/domain/icon_repository.dart';
import '../../icons/domain/icon_selection.dart';
import '../domain/battery_set.dart';

final class DriftBatterySetRepository implements BatterySetRepository {
  DriftBatterySetRepository(
      {required this.db,
      required this.batteries,
      required this.icons,
      this.ids = const UuidV4PermanentIdGenerator(),
      DateTime Function()? clock})
      : clock = clock ?? (() => DateTime.now().toUtc());
  final AppDatabase db;
  final BatteryRepository batteries;
  final IconRepository icons;
  final PermanentIdGenerator ids;
  final DateTime Function() clock;
  Future<BatterySet> _row(PermanentId id, {bool active = false}) async {
    final row = await (db.select(db.batterySets)
          ..where((t) => t.uuid.equals(id.value) & t.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null)
      throw const SetValidationException(
          'This Battery Set is no longer available.');
    if (active && row.deactivatedAt != null)
      throw const SetValidationException(
          'Reactivate this Set before changing membership, charging, or assigning it.');
    return row;
  }

  @override
  Future<List<SetRecord>> list() async {
    final rows = await (db.select(db.batterySets)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.userSetId.lower())]))
        .get();
    return Future.wait(rows.map((r) => get(PermanentId.parse(r.uuid))));
  }

  @override
  Future<SetRecord> get(PermanentId id) async {
    final r = await _row(id);
    final type = r.batteryTypeId == null
        ? null
        : await (db.select(db.batteryTypes)
              ..where((t) => t.id.equals(r.batteryTypeId!)))
            .getSingleOrNull();
    final links = await db.customSelect(
        'SELECT m.*,b.uuid AS battery_uuid,b.user_battery_id FROM battery_set_memberships m JOIN batteries b ON b.id=m.battery_id WHERE m.battery_set_id = ? ORDER BY m.added_at DESC,m.id DESC',
        variables: [Variable.withInt(r.id)]).get();
    final members = <BatteryRecord>[];
    for (final link in links) {
      if (link.readNullable<String>('removed_at') == null)
        members.add(await batteries
            .get(PermanentId.parse(link.read<String>('battery_uuid'))));
    }
    members.sort(
        (a, b) => a.values.userBatteryId.compareTo(b.values.userBatteryId));
    final assignments = await db.customSelect(
        'SELECT a.*,d.name FROM assignments a JOIN devices d ON d.id=a.device_id WHERE a.battery_set_id = ? ORDER BY a.assigned_at DESC,a.id DESC',
        variables: [Variable.withInt(r.id)]).get();
    final charges = await db.customSelect(
        'SELECT COUNT(*) AS count,MAX(charged_at) AS last FROM set_charge_records WHERE battery_set_id = ?',
        variables: [Variable.withInt(r.id)]).getSingle();
    final activity = await (db.select(db.activityLog)
          ..where((t) =>
              t.entityType.equals('battery_set') &
              t.entityUuid.equals(id.value))
          ..orderBy([
            (t) => OrderingTerm.desc(t.occurredAt),
            (t) => OrderingTerm.desc(t.id)
          ]))
        .get();
    final photo = r.preferredPrimaryVisual != 'photo'
        ? null
        : await db.customSelect(
            'SELECT m.relative_path FROM battery_set_photos p JOIN media_assets m ON m.id=p.media_asset_id WHERE p.battery_set_id = ? AND p.is_primary=1',
            variables: [Variable.withInt(r.id)]).getSingleOrNull();
    return SetRecord(
        id: id,
        typeName: type?.typeName,
        activityHistory: List.unmodifiable(activity.map((a) {
          final metadata = jsonDecode(a.metadataJson);
          final notes = metadata is Map ? metadata['notes'] : null;
          return '${a.occurredAt.toLocal()} · ${a.summary}${notes == null ? '' : '\nNotes: $notes'}';
        })),
        values: SetDraft(
            userSetId: r.userSetId,
            name: r.name,
            typeId: type == null ? null : PermanentId.parse(type.uuid),
            description: r.description,
            notes: r.notes,
            icon: IconSelection(
                source: IconSource.fromStorage(r.iconSource),
                key: r.iconKey,
                color: IconColor.parse(r.iconColor))),
        createdAt: r.createdAt,
        active: r.deactivatedAt == null,
        members: List.unmodifiable(members),
        membershipHistory: List.unmodifiable(links.map((m) => SetMembership(
            batteryId: PermanentId.parse(m.read<String>('battery_uuid')),
            batteryLabel: m.read<String>('user_battery_id'),
            addedAt: DateTime.parse(m.read<String>('added_at')),
            removedAt:
                DateTime.tryParse(m.readNullable<String>('removed_at') ?? ''),
            notes: m.readNullable<String>('notes')))),
        assignments: List.unmodifiable(assignments.map((a) => SetAssignment(
            deviceName: a.read<String>('name'),
            assignedAt: DateTime.parse(a.read<String>('assigned_at')),
            removedAt:
                DateTime.tryParse(a.readNullable<String>('removed_at') ?? ''),
            notes: a.readNullable<String>('notes')))),
        recordedCharges: charges.read<int>('count'),
        lastCharged:
            DateTime.tryParse(charges.readNullable<String>('last') ?? ''),
        primaryPhotoPath: photo == null
            ? null
            : ManagedRelativePath.parse(photo.read<String>('relative_path')));
  }

  @override
  Future<SetRecord> save(SetDraft draft, {PermanentId? id}) async {
    draft.validate();
    try {
      return await db.transaction(() async {
        final previous = id == null ? null : await _row(id);
        final collision = await (db.select(db.batterySets)
              ..where((t) =>
                  t.deletedAt.isNull() &
                  t.userSetId
                      .lower()
                      .equals(draft.userSetId.trim().toLowerCase()) &
                  (id == null
                      ? const Constant(true)
                      : t.uuid.equals(id.value).not())))
            .getSingleOrNull();
        if (collision != null)
          throw const SetValidationException(
              'This Set ID already exists. Enter a different Set ID.');
        await icons.validateSelection(
            scopes: const {IconScope.batterySet}, selection: draft.icon);
        int? typeId;
        if (draft.typeId != null) {
          final type = await (db.select(db.batteryTypes)
                ..where((t) => t.uuid.equals(draft.typeId!.value)))
              .getSingleOrNull();
          if (type == null ||
              (type.deactivatedAt != null &&
                  previous?.batteryTypeId != type.id))
            throw const SetValidationException(
                'Choose an active Battery Type.');
          typeId = type.id;
        }
        final permanent = id ?? ids.next();
        final now = clock();
        final values = BatterySetsCompanion(
            userSetId: Value(draft.userSetId.trim()),
            name: Value(draft.name.trim()),
            batteryTypeId: Value(typeId),
            description: Value(_optional(draft.description)),
            notes: Value(_optional(draft.notes)),
            iconSource: Value(draft.icon.source.storageValue),
            iconKey: Value(draft.icon.key),
            iconColor: Value(draft.icon.color.value),
            modifiedAt: Value(now));
        if (previous == null) {
          await db.into(db.batterySets).insert(values.copyWith(
              uuid: Value(permanent.value), createdAt: Value(now)));
        } else {
          await (db.update(db.batterySets)
                ..where((t) => t.id.equals(previous.id)))
              .write(values);
        }
        await _event(
            'battery_set',
            permanent,
            previous == null ? 'set_created' : 'set_updated',
            previous == null ? 'Battery Set created.' : 'Battery Set updated.');
        return get(permanent);
      });
    } on SqliteException catch (e) {
      if (e.message.contains('battery_sets_active_user_id_uq'))
        throw const SetValidationException(
            'This Set ID already exists. Enter a different Set ID.');
      rethrow;
    }
  }

  @override
  Future<String> suggestId({String prefix = 'SET', int start = 1}) async {
    if (start < 0)
      throw const SetValidationException(
          'Starting number must be zero or greater.');
    final rows = await db.select(db.batterySets).get();
    final used = rows.map((r) => r.userSetId.toLowerCase()).toSet();
    var next = start;
    while (true) {
      final candidate = '${prefix.trim()}-${next.toString().padLeft(3, '0')}';
      if (!used.contains(candidate.toLowerCase())) return candidate;
      next++;
    }
  }

  Future<void> _ensureUnassigned(int setId) async {
    final active = await (db.select(db.assignments)
          ..where((t) => t.batterySetId.equals(setId) & t.removedAt.isNull()))
        .get();
    if (active.isNotEmpty)
      throw const SetValidationException(
          'Remove this Set from its Device before changing membership or deactivating it.');
  }

  Future<List<Battery>> _members(int setId) async {
    final rows = await db.customSelect(
        'SELECT b.id FROM batteries b JOIN battery_set_memberships m ON m.battery_id=b.id WHERE m.battery_set_id=? AND m.removed_at IS NULL',
        variables: [Variable.withInt(setId)]).get();
    final result = <Battery>[];
    for (final r in rows) {
      result.add(await (db.select(db.batteries)
            ..where((t) => t.id.equals(r.read<int>('id'))))
          .getSingle());
    }
    return result;
  }

  Future<void> _syncStatus(Battery battery, {bool force = false}) async {
    if (!force && !['Available', 'Assigned', 'In Set'].contains(battery.status))
      return;
    final assigned = await (db.select(db.assignments)
          ..where((t) => t.batteryId.equals(battery.id) & t.removedAt.isNull()))
        .get();
    final membership = await db.customSelect(
        'SELECT m.id FROM battery_set_memberships m JOIN battery_sets s ON s.id=m.battery_set_id WHERE m.battery_id=? AND m.removed_at IS NULL AND s.deactivated_at IS NULL AND s.deleted_at IS NULL',
        variables: [Variable.withInt(battery.id)]).get();
    final status = assigned.isNotEmpty
        ? 'Assigned'
        : membership.isNotEmpty
            ? 'In Set'
            : 'Available';
    if (status == battery.status) return;
    await (db.update(db.batteries)..where((t) => t.id.equals(battery.id)))
        .write(BatteriesCompanion(
            status: Value(status), modifiedAt: Value(clock())));
    await _event('battery', PermanentId.parse(battery.uuid),
        'battery_status_changed', 'Status: ${battery.status} → $status.');
  }

  @override
  Future<void> setActive(PermanentId id, bool active) =>
      db.transaction(() async {
        final row = await _row(id);
        await _ensureUnassigned(row.id);
        await (db.update(db.batterySets)..where((t) => t.id.equals(row.id)))
            .write(BatterySetsCompanion(
                deactivatedAt: Value(active ? null : clock()),
                modifiedAt: Value(clock())));
        for (final b in await _members(row.id)) {
          await _syncStatus(b);
        }
        await _event(
            'battery_set',
            id,
            active ? 'set_reactivated' : 'set_deactivated',
            active
                ? 'Battery Set reactivated.'
                : 'Battery Set deactivated; membership history retained.');
      });
  @override
  Future<void> delete(PermanentId id) => db.transaction(() async {
        final row = await _row(id);
        await _ensureUnassigned(row.id);
        final members = await _members(row.id);
        final now = clock();
        await (db.update(db.batterySetMemberships)
              ..where(
                  (t) => t.batterySetId.equals(row.id) & t.removedAt.isNull()))
            .write(BatterySetMembershipsCompanion(removedAt: Value(now)));
        await (db.update(db.batterySets)..where((t) => t.id.equals(row.id)))
            .write(BatterySetsCompanion(
                deletedAt: Value(now),
                deactivatedAt: Value(now),
                modifiedAt: Value(now)));
        for (final b in members) {
          await _syncStatus(b);
          await _event(
              'battery',
              PermanentId.parse(b.uuid),
              'set_membership_removed',
              'Removed from deleted Set ${row.userSetId}.');
        }
        await _event('battery_set', id, 'set_deleted',
            'Battery Set deleted; all history retained.');
      });
  void _warnings(Set<String> warnings, Set<String> accepted) {
    if (!accepted.containsAll(warnings))
      throw SetWarnings(Set.unmodifiable(warnings));
  }

  @override
  Future<void> addMember(PermanentId setId, PermanentId batteryId,
          {MembershipAction action = MembershipAction.add,
          String? notes,
          Set<String> acceptedWarnings = const {}}) =>
      db.transaction(() async {
        final set = await _row(setId, active: true);
        await _ensureUnassigned(set.id);
        final battery = await (db.select(db.batteries)
              ..where(
                  (t) => t.uuid.equals(batteryId.value) & t.deletedAt.isNull()))
            .getSingleOrNull();
        if (battery == null)
          throw const SetValidationException(
              'This Battery is no longer available.');
        final current = await _members(set.id);
        if (current.any((b) => b.id == battery.id))
          throw const SetValidationException(
              'This Battery already belongs to this Set.');
        final other = await db.customSelect(
            'SELECT m.id,m.battery_set_id,s.user_set_id,s.uuid AS set_uuid FROM battery_set_memberships m JOIN battery_sets s ON s.id=m.battery_set_id WHERE m.battery_id=? AND m.removed_at IS NULL',
            variables: [Variable.withInt(battery.id)]).get();
        final warnings = <String>{};
        for (final link in other) {
          warnings.add(
              '${battery.userBatteryId} already belongs to ${link.read<String>('user_set_id')}. ${action == MembershipAction.move ? 'That membership will be closed.' : 'Both memberships will remain open.'}');
          if (action == MembershipAction.move)
            await _ensureUnassigned(link.read<int>('battery_set_id'));
        }
        if (set.batteryTypeId != null &&
            set.batteryTypeId != battery.batteryTypeId)
          warnings.add(
              '${battery.userBatteryId} differs from the Set Battery Type.');
        for (final peer in current) {
          if (peer.batteryTypeId != battery.batteryTypeId)
            warnings.add(
                '${battery.userBatteryId} has a different Battery Type from ${peer.userBatteryId}.');
          if (peer.chemistry?.toLowerCase() != battery.chemistry?.toLowerCase())
            warnings.add(
                '${battery.userBatteryId} has different chemistry from ${peer.userBatteryId}.');
          if (peer.nominalVoltage != battery.nominalVoltage)
            warnings.add(
                '${battery.userBatteryId} has different voltage from ${peer.userBatteryId}.');
          if (peer.capacity != battery.capacity ||
              peer.capacityUnit?.toLowerCase() !=
                  battery.capacityUnit?.toLowerCase())
            warnings.add(
                '${battery.userBatteryId} has different capacity from ${peer.userBatteryId}.');
        }
        if (['Retired', 'Damaged'].contains(battery.status) ||
            ['Retired', 'Damaged'].contains(battery.condition))
          warnings.add(
              '${battery.userBatteryId} is ${battery.status}/${battery.condition}.');
        _warnings(warnings, acceptedWarnings);
        final now = clock();
        final operation = ids.next().value;
        if (action == MembershipAction.move) {
          await (db.update(db.batterySetMemberships)
                ..where((t) =>
                    t.batteryId.equals(battery.id) & t.removedAt.isNull()))
              .write(BatterySetMembershipsCompanion(removedAt: Value(now)));
          for (final link in other) {
            await _event(
                'battery_set',
                PermanentId.parse(link.read<String>('set_uuid')),
                'set_member_removed',
                'Battery ${battery.userBatteryId} moved to ${set.userSetId}.',
                metadata: {
                  'notes': _optional(notes),
                  'operation_uuid': operation
                });
          }
        }
        await db.into(db.batterySetMemberships).insert(
            BatterySetMembershipsCompanion.insert(
                uuid: ids.next().value,
                batteryId: battery.id,
                batterySetId: set.id,
                addedAt: Value(now),
                notes: Value(_optional(notes)),
                operationUuid: operation));
        await _syncStatus(battery);
        await _event('battery', batteryId, 'set_membership_added',
            '${action == MembershipAction.move ? 'Moved' : 'Added'} to Set ${set.userSetId}.',
            metadata: {
              'set_uuid': setId.value,
              'warnings': warnings.toList(),
              'operation_uuid': operation
            });
        await _event('battery_set', setId, 'set_member_added',
            'Battery ${battery.userBatteryId} added.',
            metadata: {'notes': _optional(notes)});
      });
  @override
  Future<void> removeMember(PermanentId setId, PermanentId batteryId,
          {String? notes}) =>
      db.transaction(() async {
        final set = await _row(setId);
        await _ensureUnassigned(set.id);
        final members = await _members(set.id);
        final match = members.where((b) => b.uuid == batteryId.value).toList();
        if (match.isEmpty)
          throw const SetValidationException(
              'This Battery is no longer in the Set.');
        await (db.update(db.batterySetMemberships)
              ..where((t) =>
                  t.batterySetId.equals(set.id) &
                  t.batteryId.equals(match.single.id) &
                  t.removedAt.isNull()))
            .write(BatterySetMembershipsCompanion(removedAt: Value(clock())));
        await _syncStatus(match.single);
        await _event('battery', batteryId, 'set_membership_removed',
            'Removed from Set ${set.userSetId}.',
            metadata: {'notes': _optional(notes)});
        await _event('battery_set', setId, 'set_member_removed',
            'Battery ${match.single.userBatteryId} removed.',
            metadata: {'notes': _optional(notes)});
      });
  @override
  Future<void> markCharged(PermanentId id, {String? notes}) async {
    try {
      await DriftChargeRepository(db: db, ids: ids, clock: clock)
          .record(ChargeDraft(chargedAt: clock(), notes: notes), setId: id);
    } on ChargeValidationException catch (e) {
      throw SetValidationException(e.message);
    }
  }

  @override
  Future<List<SetDevice>> devices() async {
    final rows = await (db.select(db.devices)
          ..where((t) => t.deletedAt.isNull() & t.deactivatedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name.lower())]))
        .get();
    final result = <SetDevice>[];
    for (final r in rows) {
      final type = r.requiredBatteryTypeId == null
          ? null
          : await (db.select(db.batteryTypes)
                ..where((t) => t.id.equals(r.requiredBatteryTypeId!)))
              .getSingleOrNull();
      result.add(SetDevice(
          id: PermanentId.parse(r.uuid),
          name: r.name,
          requiredTypeId: type == null ? null : PermanentId.parse(type.uuid),
          quantity: r.requiredBatteryQuantity,
          voltage: r.requiredVoltage));
    }
    return result;
  }

  @override
  Future<SetDevice> createDevice(String name,
      {PermanentId? requiredTypeId, int? quantity, double? voltage}) async {
    try {
      final device = await DriftDeviceRepository(
              db: db,
              icons: icons,
              batteries: batteries,
              ids: ids,
              clock: clock)
          .save(DeviceDraft(
              name: name,
              requiredTypeId: requiredTypeId,
              quantity: quantity,
              voltage: voltage));
      return SetDevice(
          id: device.id,
          name: device.values.name,
          requiredTypeId: device.values.requiredTypeId,
          quantity: device.values.quantity,
          voltage: device.values.voltage);
    } on DeviceValidationException catch (error) {
      throw SetValidationException(error.message);
    }
  }

  @override
  Future<void> assign(PermanentId id, PermanentId deviceId,
      {DateTime? assignedAt,
      String? notes,
      Set<String> acceptedWarnings = const {}}) async {
    try {
      await DriftAssignmentRepository(db: db, ids: ids, clock: clock).assign(
          deviceId: deviceId,
          setId: id,
          assignedAt: assignedAt,
          notes: notes,
          acceptedWarnings: acceptedWarnings);
    } on AssignmentValidationException catch (e) {
      throw SetValidationException(e.message);
    } on AssignmentWarnings catch (e) {
      throw SetWarnings(e.messages);
    }
  }

  @override
  Future<void> unassign(PermanentId id,
      {DateTime? removedAt, String? notes}) async {
    try {
      await db.transaction(() async {
        final set = await _row(id);
        final parents = await (db.select(db.assignments)
              ..where(
                  (t) => t.batterySetId.equals(set.id) & t.removedAt.isNull()))
            .get();
        if (parents.isEmpty)
          throw const SetValidationException(
              'This Set is not currently assigned.');
        await DriftAssignmentRepository(db: db, ids: ids, clock: clock).remove(
            parents.map((p) => PermanentId.parse(p.uuid)).toList(),
            removedAt: removedAt,
            notes: notes);
      });
    } on AssignmentValidationException catch (e) {
      throw SetValidationException(e.message);
    }
  }

  Future<void> _event(
      String entity, PermanentId id, String type, String summary,
      {Map<String, Object?> metadata = const {}}) async {
    await db.into(db.activityLog).insert(ActivityLogCompanion.insert(
        uuid: ids.next().value,
        eventType: type,
        entityType: entity,
        entityUuid: id.value,
        summary: summary,
        metadataJson: Value(jsonEncode(metadata)),
        occurredAt: Value(clock())));
  }
}

String? _optional(String? value) =>
    value == null || value.trim().isEmpty ? null : value.trim();
