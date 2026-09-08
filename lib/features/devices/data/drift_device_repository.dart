import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/identity/permanent_id.dart';
import '../../../core/storage/managed_relative_path.dart';
import '../../batteries/domain/battery.dart';
import '../../icons/domain/icon_color.dart';
import '../../icons/domain/icon_definition.dart';
import '../../icons/domain/icon_repository.dart';
import '../../icons/domain/icon_selection.dart';
import '../domain/device.dart';

final class DriftDeviceRepository implements DeviceRepository {
  DriftDeviceRepository(
      {required this.db,
      required this.icons,
      required this.batteries,
      this.ids = const UuidV4PermanentIdGenerator(),
      DateTime Function()? clock})
      : clock = clock ?? (() => DateTime.now().toUtc());
  final AppDatabase db;
  final IconRepository icons;
  final BatteryRepository batteries;
  final PermanentIdGenerator ids;
  final DateTime Function() clock;
  Future<Device> _row(PermanentId id) async {
    final row = await (db.select(db.devices)
          ..where((t) => t.uuid.equals(id.value) & t.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null)
      throw const DeviceValidationException(
          'This Device is no longer available.');
    return row;
  }

  @override
  Future<List<DeviceRecord>> list() async {
    final rows = await (db.select(db.devices)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name.lower())]))
        .get();
    return Future.wait(rows.map((r) => get(PermanentId.parse(r.uuid))));
  }

  @override
  Future<DeviceRecord> get(PermanentId id) async {
    final r = await _row(id);
    final type = r.requiredBatteryTypeId == null
        ? null
        : await (db.select(db.batteryTypes)
              ..where((t) => t.id.equals(r.requiredBatteryTypeId!)))
            .getSingleOrNull();
    final assignments = await db.customSelect(
        'SELECT a.*, b.uuid AS battery_uuid,b.user_battery_id,s.uuid AS set_uuid,s.user_set_id,s.name AS set_name FROM assignments a LEFT JOIN batteries b ON b.id=a.battery_id LEFT JOIN battery_sets s ON s.id=a.battery_set_id WHERE a.device_id=? ORDER BY a.assigned_at DESC,a.id DESC',
        variables: [Variable.withInt(r.id)]).get();
    final links = assignments
        .map((a) => DeviceAssignment(
            id: PermanentId.parse(a.read<String>('uuid')),
            subjectId: PermanentId.parse(
                a.readNullable<String>('battery_uuid') ??
                    a.read<String>('set_uuid')),
            label: a.readNullable<String>('user_battery_id') ??
                '${a.read<String>('user_set_id')} · ${a.read<String>('set_name')}',
            isSet: a.read<String>('subject_type') == 'battery_set',
            fromSet: a.readNullable<int>('source_set_assignment_id') != null,
            assignedAt: DateTime.parse(a.read<String>('assigned_at')),
            removedAt:
                DateTime.tryParse(a.readNullable<String>('removed_at') ?? ''),
            notes: a.readNullable<String>('notes')))
        .toList();
    final members = <BatteryRecord>[];
    for (final a in links.where((a) => !a.isSet && a.removedAt == null)) {
      members.add(await batteries.get(a.subjectId));
    }
    final photo = r.preferredPrimaryVisual != 'photo'
        ? null
        : await db.customSelect(
            'SELECT m.relative_path FROM device_photos p JOIN media_assets m ON m.id=p.media_asset_id WHERE p.device_id=? AND p.is_primary=1',
            variables: [Variable.withInt(r.id)]).getSingleOrNull();
    final activity = await (db.select(db.activityLog)
          ..where((t) =>
              t.entityType.equals('device') & t.entityUuid.equals(id.value))
          ..orderBy([
            (t) => OrderingTerm.desc(t.occurredAt),
            (t) => OrderingTerm.desc(t.id)
          ]))
        .get();
    return DeviceRecord(
        id: id,
        values: DeviceDraft(
            name: r.name,
            category: r.category,
            manufacturer: r.manufacturer,
            model: r.model,
            serialNumber: r.serialNumber,
            location: r.location,
            description: r.description,
            notes: r.notes,
            requiredTypeId: type == null ? null : PermanentId.parse(type.uuid),
            quantity: r.requiredBatteryQuantity,
            voltage: r.requiredVoltage,
            requirementNotes: r.requirementNotes,
            icon: IconSelection(
                source: IconSource.fromStorage(r.iconSource),
                key: r.iconKey,
                color: IconColor.parse(r.iconColor))),
        createdAt: r.createdAt,
        active: r.deactivatedAt == null,
        typeName: type?.typeName,
        photoPath: photo == null
            ? null
            : ManagedRelativePath.parse(photo.read<String>('relative_path')),
        assignments: List.unmodifiable(links),
        batteries: List.unmodifiable(members),
        activity: List.unmodifiable(
            activity.map((a) => '${a.occurredAt.toLocal()} · ${a.summary}')));
  }

  Future<void> _unique(String name, {PermanentId? except}) async {
    final matches = await (db.select(db.devices)
          ..where((t) =>
              t.name.lower().equals(name.trim().toLowerCase()) &
              t.deletedAt.isNull() &
              t.deactivatedAt.isNull() &
              (except == null
                  ? const Constant(true)
                  : t.uuid.equals(except.value).not())))
        .get();
    if (matches.isNotEmpty)
      throw const DeviceValidationException(
          'An active Device with that name already exists. Enter a different name.');
  }

  @override
  Future<DeviceRecord> save(DeviceDraft draft, {PermanentId? id}) async {
    draft.validate();
    return db.transaction(() async {
      final previous = id == null ? null : await _row(id);
      if (previous == null || previous.deactivatedAt == null)
        await _unique(draft.name, except: id);
      await icons.validateSelection(
          scopes: const {IconScope.device}, selection: draft.icon);
      int? typeId;
      if (draft.requiredTypeId != null) {
        final type = await (db.select(db.batteryTypes)
              ..where((t) => t.uuid.equals(draft.requiredTypeId!.value)))
            .getSingleOrNull();
        if (type == null ||
            (type.deactivatedAt != null &&
                type.id != previous?.requiredBatteryTypeId))
          throw const DeviceValidationException(
              'Choose an active Battery Type.');
        typeId = type.id;
      }
      final permanent = id ?? ids.next();
      final now = clock();
      final values = DevicesCompanion(
          name: Value(draft.name.trim()),
          category: Value(_optional(draft.category)),
          manufacturer: Value(_optional(draft.manufacturer)),
          model: Value(_optional(draft.model)),
          serialNumber: Value(_optional(draft.serialNumber)),
          location: Value(_optional(draft.location)),
          description: Value(_optional(draft.description)),
          notes: Value(_optional(draft.notes)),
          requiredBatteryTypeId: Value(typeId),
          requiredBatteryQuantity: Value(draft.quantity),
          requiredVoltage: Value(draft.voltage),
          requirementNotes: Value(_optional(draft.requirementNotes)),
          iconSource: Value(draft.icon.source.storageValue),
          iconKey: Value(draft.icon.key),
          iconColor: Value(draft.icon.color.value),
          modifiedAt: Value(now));
      if (previous == null) {
        await db.into(db.devices).insert(values.copyWith(
            uuid: Value(permanent.value), createdAt: Value(now)));
      } else {
        await (db.update(db.devices)..where((t) => t.id.equals(previous.id)))
            .write(values);
      }
      await _event(
          permanent,
          previous == null ? 'device_created' : 'device_updated',
          previous == null ? 'Device created.' : 'Device updated.', {
        'name': draft.name.trim(),
        'requirements': {
          'type_uuid': draft.requiredTypeId?.value,
          'quantity': draft.quantity,
          'voltage': draft.voltage
        }
      });
      return get(permanent);
    });
  }

  Future<void> _unassigned(int id) async {
    final rows = await (db.select(db.assignments)
          ..where((t) => t.deviceId.equals(id) & t.removedAt.isNull()))
        .get();
    if (rows.isNotEmpty)
      throw const DeviceValidationException(
          'Remove all Batteries and Sets from this Device before deactivating or deleting it. Assignment history will be retained.');
  }

  @override
  Future<void> setActive(PermanentId id, bool active) =>
      db.transaction(() async {
        final r = await _row(id);
        if (active)
          await _unique(r.name, except: id);
        else
          await _unassigned(r.id);
        if (active == (r.deactivatedAt == null)) return;
        await (db.update(db.devices)..where((t) => t.id.equals(r.id))).write(
            DevicesCompanion(
                deactivatedAt: Value(active ? null : clock()),
                modifiedAt: Value(clock())));
        await _event(
            id,
            active ? 'device_reactivated' : 'device_deactivated',
            active
                ? 'Device reactivated.'
                : 'Device deactivated; history retained.');
      });
  @override
  Future<void> delete(PermanentId id) => db.transaction(() async {
        final r = await _row(id);
        await _unassigned(r.id);
        final now = clock();
        await (db.update(db.devices)..where((t) => t.id.equals(r.id))).write(
            DevicesCompanion(
                deletedAt: Value(now),
                deactivatedAt: Value(now),
                modifiedAt: Value(now)));
        await _event(id, 'device_deleted',
            'Device deleted; history and inventory retained.');
      });
  Future<void> _event(PermanentId id, String type, String summary,
      [Map<String, Object?> metadata = const {}]) async {
    await db.into(db.activityLog).insert(ActivityLogCompanion.insert(
        uuid: ids.next().value,
        eventType: type,
        entityType: 'device',
        entityUuid: id.value,
        summary: summary,
        metadataJson: Value(jsonEncode(metadata)),
        occurredAt: Value(clock())));
  }
}

String? _optional(String? value) =>
    value == null || value.trim().isEmpty ? null : value.trim();
