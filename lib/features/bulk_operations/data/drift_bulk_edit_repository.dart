import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/identity/permanent_id.dart';
import '../../batteries/domain/battery.dart';
import '../../battery_sets/domain/battery_set.dart';
import '../../icons/domain/icon_color.dart';
import '../../icons/domain/icon_definition.dart';
import '../../icons/domain/icon_repository.dart';
import '../../icons/domain/icon_selection.dart';
import '../domain/bulk_creation.dart';
import '../domain/bulk_edit.dart';

final class DriftBulkEditRepository implements BulkEditRepository {
  DriftBulkEditRepository(
      {required this.db,
      required this.batteries,
      required this.sets,
      required this.icons});
  final AppDatabase db;
  final BatteryRepository batteries;
  final BatterySetRepository sets;
  final IconRepository icons;
  static const columns = {
    BulkEditAction.type: 'battery_type_id',
    BulkEditAction.status: 'status',
    BulkEditAction.condition: 'condition',
    BulkEditAction.purchaseDate: 'purchase_date',
    BulkEditAction.purchaseLocation: 'purchase_location',
    BulkEditAction.purchasePrice: 'purchase_price',
    BulkEditAction.totalPackagePrice: 'total_package_price',
    BulkEditAction.perBatteryPrice: 'per_battery_price',
    BulkEditAction.warrantyExpiration: 'warranty_expiration'
  };
  Future<String> _signature(PermanentId id) async {
    final record = await db.customSelect('SELECT * FROM batteries WHERE uuid=?',
        variables: [Variable.withString(id.value)]).getSingle();
    final key = record.read<int>('id');
    final members = await db.customSelect(
        'SELECT * FROM battery_set_memberships WHERE battery_id=? ORDER BY id',
        variables: [Variable.withInt(key)]).get();
    final assignments = await db.customSelect(
        'SELECT * FROM assignments WHERE battery_id=? ORDER BY id',
        variables: [Variable.withInt(key)]).get();
    return jsonEncode([
      record.data,
      members.map((r) => r.data).toList(),
      assignments.map((r) => r.data).toList()
    ]);
  }

  Future<Object?> _value(BulkEditRequest r) async {
    final v = r.value;
    switch (r.action) {
      case BulkEditAction.type:
        if (v == null) return null;
        if (v is! PermanentId)
          throw const BulkValidationException('Choose a Battery Type.');
        final type = await (db.select(db.batteryTypes)
              ..where((t) => t.uuid.equals(v.value) & t.deactivatedAt.isNull()))
            .getSingleOrNull();
        if (type == null)
          throw const BulkValidationException('Choose an active Battery Type.');
        return type.id;
      case BulkEditAction.status:
        if (v is! String || !batteryStatuses.contains(v) || v == 'Retired')
          throw const BulkValidationException(
              'Choose a status; use Retire Selected Batteries for retirement.');
        return v;
      case BulkEditAction.condition:
        if (v is! String || !batteryConditions.contains(v) || v == 'Retired')
          throw const BulkValidationException(
              'Choose a condition; use Retire Selected Batteries for retirement.');
        return v;
      case BulkEditAction.icon:
        if (v is! IconSelection)
          throw const BulkValidationException('Choose an icon.');
        await icons
            .validateSelection(scopes: const {IconScope.battery}, selection: v);
        return v;
      case BulkEditAction.color:
        if (v is! IconColor)
          throw const BulkValidationException('Choose an icon color.');
        return v;
      case BulkEditAction.addSet:
      case BulkEditAction.removeSet:
        if (v is! PermanentId)
          throw const BulkValidationException('Choose a Battery Set.');
        final s = await sets.get(v);
        if ((r.action == BulkEditAction.addSet && !s.active) ||
            s.currentAssignment != null)
          throw const BulkValidationException(
              'Choose an active, unassigned Set.');
        return v;
      case BulkEditAction.note:
      case BulkEditAction.tag:
        if (v is! String || v.trim().isEmpty)
          throw const BulkValidationException('Enter text to append.');
        return v.trim();
      case BulkEditAction.retire:
        if (r.retirementDate == null ||
            r.retirementDate!.isAfter(DateTime.now().toUtc()) ||
            !retirementReasons.contains(r.reason))
          throw const BulkValidationException(
              'Choose a retirement reason and a date that is not in the future.');
        return r.reason;
      case BulkEditAction.purchaseDate:
      case BulkEditAction.warrantyExpiration:
        if (v != null && v is! DateTime)
          throw const BulkValidationException(
              'Enter a valid date or clear the value.');
        return (v as DateTime?)?.toUtc().toIso8601String();
      case BulkEditAction.purchasePrice:
      case BulkEditAction.totalPackagePrice:
      case BulkEditAction.perBatteryPrice:
        if (v != null && (v is! double || !v.isFinite || v < 0))
          throw const BulkValidationException(
              'Enter a nonnegative price or clear the value.');
        return v;
      case BulkEditAction.purchaseLocation:
        if (v != null && v is! String)
          throw const BulkValidationException('Enter a purchase location.');
        return (v as String?)?.trim();
    }
  }

  Future<BulkEditPreview> _preview(BulkEditRequest r) async {
    if (r.ids.isEmpty ||
        r.ids.length > 1000 ||
        r.ids.toSet().length != r.ids.length)
      throw const BulkValidationException('Select 1–1000 distinct Batteries.');
    await _value(r);
    final result = <BulkEditRow>[];
    for (final id in r.ids) {
      final b = await batteries.get(id);
      if (r.action == BulkEditAction.retire) {
        if (b.values.status == 'Retired')
          throw BulkValidationException(
              b.values.userBatteryId + ' is already retired.');
        if (b.currentDevices.isNotEmpty)
          throw BulkValidationException('Remove ' +
              b.values.userBatteryId +
              ' from its Device before retiring it.');
      }
      if (r.action == BulkEditAction.status) {
        if (r.value == 'Assigned' && b.currentDevices.isEmpty ||
            r.value == 'In Set' && b.currentSets.isEmpty ||
            r.value == 'Available' &&
                (b.currentDevices.isNotEmpty || b.currentSets.isNotEmpty))
          throw BulkValidationException(
              'Status conflicts with current Device or Set relationships for ' +
                  b.values.userBatteryId +
                  '. Change those relationships first.');
      }
      if (r.action == BulkEditAction.addSet ||
          r.action == BulkEditAction.removeSet) {
        final target = await sets.get(r.value as PermanentId);
        final member = target.members.any((m) => m.id == id);
        if (r.action == BulkEditAction.addSet && member ||
            r.action == BulkEditAction.removeSet && !member)
          throw BulkValidationException(b.values.userBatteryId +
              (member ? ' already belongs to ' : ' is not a member of ') +
              target.values.userSetId +
              '.');
      }
      final raw = await db.customSelect('SELECT * FROM batteries WHERE uuid=?',
          variables: [Variable.withString(id.value)]).getSingle();
      String before = '';
      String after = r.value?.toString() ?? 'Clear';
      switch (r.action) {
        case BulkEditAction.type:
          final typeId = raw.readNullable<int>('battery_type_id');
          before = typeId == null
              ? 'None'
              : (await (db.select(db.batteryTypes)
                        ..where((t) => t.id.equals(typeId)))
                      .getSingle())
                  .typeName;
          after = r.value == null
              ? 'None'
              : (await (db.select(db.batteryTypes)
                        ..where((t) =>
                            t.uuid.equals((r.value as PermanentId).value)))
                      .getSingle())
                  .typeName;
          break;
        case BulkEditAction.icon:
          before = b.values.icon.key + ' / ' + b.values.icon.color.value;
          final icon = r.value as IconSelection;
          after = icon.key + ' / ' + icon.color.value;
          break;
        case BulkEditAction.color:
          before = b.values.icon.color.value;
          break;
        case BulkEditAction.addSet:
        case BulkEditAction.removeSet:
          before = b.currentSets.join(', ');
          after =
              (r.action == BulkEditAction.addSet ? 'Add to ' : 'Remove from ') +
                  (await sets.get(r.value as PermanentId)).values.userSetId;
          break;
        case BulkEditAction.note:
          before = b.values.notes ?? '';
          after = [if (before.isNotEmpty) before, r.value].join('\n');
          break;
        case BulkEditAction.tag:
          final tags = await db.customSelect(
              'SELECT t.name FROM tags t JOIN battery_tags bt ON bt.tag_id=t.id WHERE bt.battery_id=? ORDER BY t.name',
              variables: [Variable.withInt(raw.read<int>('id'))]).get();
          before = tags.map((t) => t.read<String>('name')).join(', ');
          after = 'Add tag: ' + (r.value as String);
          break;
        case BulkEditAction.retire:
          before = b.values.status;
          after = 'Retired · ' +
              r.retirementDate!.toLocal().toString() +
              ' · ' +
              r.reason! +
              (b.currentSets.isEmpty ? '' : ' · Set membership retained');
          break;
        default:
          before = raw.data[columns[r.action]]?.toString() ?? 'Not entered';
      }
      result.add(BulkEditRow(
          battery: b,
          before: before,
          after: after,
          signature: await _signature(id)));
    }
    return BulkEditPreview(r, result);
  }

  @override
  Future<BulkEditPreview> preview(BulkEditRequest request) =>
      db.transaction(() => _preview(request));
  @override
  Future<void> apply(BulkEditPreview preview,
          {Set<String> acceptedWarnings = const {}}) =>
      db.transaction(() async {
        final r = preview.request;
        final fresh = await _preview(r);
        if (fresh.rows.length != preview.rows.length)
          throw const BulkValidationException(
              'Selection changed. Generate a new preview.');
        for (var i = 0; i < fresh.rows.length; i++) {
          if (fresh.rows[i].signature != preview.rows[i].signature ||
              fresh.rows[i].after != preview.rows[i].after ||
              fresh.rows[i].before != preview.rows[i].before)
            throw const BulkValidationException(
                'Inventory changed after preview. Generate a new preview before applying.');
        }
        if (r.action == BulkEditAction.type) {
          final warnings = fresh.rows
              .where((row) =>
                  row.battery.currentSets.isNotEmpty ||
                  row.battery.currentDevices.isNotEmpty)
              .map((row) =>
                  'Changing Battery Type for ' +
                  row.battery.values.userBatteryId +
                  ' retains current Set/Device links. Verify compatibility.')
              .toSet();
          if (!acceptedWarnings.containsAll(warnings))
            throw SetWarnings(warnings);
        }
        final v = await _value(r);
        final operation = const UuidV4PermanentIdGenerator().next().value;
        final now = DateTime.now().toUtc();
        for (final row in fresh.rows) {
          final b = row.battery;
          final id = b.id;
          Future<void> write(Map<String, Object?> fields) async {
            fields['modified_at'] = now.toIso8601String();
            await db.customStatement(
                'UPDATE batteries SET ' +
                    fields.keys.map((k) => k + '=?').join(', ') +
                    ' WHERE uuid=?',
                [...fields.values, id.value]);
          }

          switch (r.action) {
            case BulkEditAction.addSet:
              await sets.addMember(v as PermanentId, id,
                  acceptedWarnings: acceptedWarnings);
              break;
            case BulkEditAction.removeSet:
              await sets.removeMember(v as PermanentId, id,
                  notes: 'Bulk removal');
              break;
            case BulkEditAction.icon:
              final icon = v as IconSelection;
              await write({
                'icon_source': icon.source.storageValue,
                'icon_key': icon.key,
                'icon_color': icon.color.value
              });
              break;
            case BulkEditAction.color:
              final color = v as IconColor;
              await icons.validateSelection(
                  scopes: const {IconScope.battery},
                  selection: IconSelection(
                      source: b.values.icon.source,
                      key: b.values.icon.key,
                      color: color));
              await write({'icon_color': color.value});
              break;
            case BulkEditAction.note:
              await write({'notes': row.after});
              break;
            case BulkEditAction.tag:
              final old = await (db.select(db.tags)
                    ..where((t) =>
                        t.name.lower().equals((v as String).toLowerCase())))
                  .getSingleOrNull();
              final tagId = old?.id ??
                  await db.into(db.tags).insert(TagsCompanion.insert(
                      uuid: const UuidV4PermanentIdGenerator().next().value,
                      name: v as String));
              final record = await (db.select(db.batteries)
                    ..where((t) => t.uuid.equals(id.value)))
                  .getSingle();
              await db.into(db.batteryTags).insert(
                  BatteryTagsCompanion.insert(
                      batteryId: record.id, tagId: tagId),
                  mode: InsertMode.insertOrIgnore);
              await write({});
              break;
            case BulkEditAction.retire:
              await write({
                'status': 'Retired',
                'retired_at': r.retirementDate!.toUtc().toIso8601String(),
                'retirement_reason': r.reason
              });
              break;
            default:
              await write({
                columns[r.action]!: v,
                if (r.action == BulkEditAction.status &&
                    b.values.status == 'Retired')
                  'retired_at': null,
                if (r.action == BulkEditAction.status &&
                    b.values.status == 'Retired')
                  'retirement_reason': null
              });
          }
          await db.into(db.activityLog).insert(ActivityLogCompanion.insert(
              uuid: const UuidV4PermanentIdGenerator().next().value,
              eventType: r.action == BulkEditAction.retire
                  ? 'battery_retired'
                  : 'battery_bulk_updated',
              entityType: 'battery',
              entityUuid: id.value,
              summary: r.action.label + ': ' + row.before + ' → ' + row.after,
              metadataJson: Value(jsonEncode({
                'operation_uuid': operation,
                'action': r.action.name,
                'before': row.before,
                'after': row.after
              })),
              occurredAt: Value(now)));
        }
      });
}
