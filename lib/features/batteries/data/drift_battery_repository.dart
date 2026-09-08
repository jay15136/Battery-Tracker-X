import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:sqlite3/sqlite3.dart';
import '../../../core/database/app_database.dart';
import '../../../core/identity/permanent_id.dart';
import '../../../core/storage/managed_relative_path.dart';
import '../../icons/domain/icon_color.dart';
import '../../icons/domain/icon_definition.dart';
import '../../icons/domain/icon_repository.dart';
import '../../icons/domain/icon_selection.dart';
import '../domain/battery.dart';

final class DriftBatteryRepository implements BatteryRepository {
  DriftBatteryRepository(
      {required this.database,
      required this.iconRepository,
      this.idGenerator = const UuidV4PermanentIdGenerator()});
  final AppDatabase database;
  final IconRepository iconRepository;
  final PermanentIdGenerator idGenerator;

  @override
  Future<List<BatteryRecord>> list() async {
    final rows = await (database.select(database.batteries)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.userBatteryId.lower())]))
        .get();
    return Future.wait(rows.map(_map));
  }

  @override
  Future<BatteryRecord> get(PermanentId id) async => _map(await _row(id));

  Future<Battery> _row(PermanentId id) async {
    final row = await (database.select(database.batteries)
          ..where((t) => t.uuid.equals(id.value) & t.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null)
      throw const BatteryValidationException(
          'This Battery is no longer available. Refresh the inventory.');
    return row;
  }

  @override
  Future<BatteryRecord> save(BatteryDraft draft, {PermanentId? id}) async {
    draft.validate();
    try {
      return await database.transaction(() async {
        final previous = id == null ? null : await _row(id);
        final duplicate = await (database.select(database.batteries)
              ..where((t) =>
                  t.deletedAt.isNull() &
                  t.userBatteryId
                      .lower()
                      .equals(draft.userBatteryId.trim().toLowerCase()) &
                  (id == null
                      ? const Constant(true)
                      : t.uuid.equals(id.value).not())))
            .getSingleOrNull();
        if (duplicate != null)
          throw const BatteryValidationException(
              'This Battery ID already exists. Enter a different ID.');
        await iconRepository.validateSelection(
            scopes: const {IconScope.battery}, selection: draft.icon);
        int? typeId;
        if (draft.batteryTypeId != null) {
          final type = await (database.select(database.batteryTypes)
                ..where((t) => t.uuid.equals(draft.batteryTypeId!.value)))
              .getSingleOrNull();
          if (type == null ||
              (type.deactivatedAt != null &&
                  previous?.batteryTypeId != type.id)) {
            throw const BatteryValidationException(
                'Choose an active Battery Type.');
          }
          typeId = type.id;
        }
        int? batchId;
        final batchCode = _text(draft.batchCode);
        final now = DateTime.now().toUtc();
        if (batchCode != null) {
          final batch = await (database.select(database.batteryBatches)
                ..where(
                    (t) => t.batchCode.lower().equals(batchCode.toLowerCase())))
              .getSingleOrNull();
          batchId = batch?.id ??
              await database.into(database.batteryBatches).insert(
                  BatteryBatchesCompanion.insert(
                      uuid: idGenerator.next().value, batchCode: batchCode));
        }
        final permanentId = id ?? idGenerator.next();
        final values = BatteriesCompanion(
          userBatteryId: Value(draft.userBatteryId.trim()),
          name: Value(_text(draft.name)),
          batteryTypeId: Value(typeId),
          batchId: Value(batchId),
          manufacturer: Value(_text(draft.manufacturer)),
          model: Value(_text(draft.model)),
          serialNumber: Value(_text(draft.serialNumber)),
          customLabel: Value(_text(draft.customLabel)),
          chemistry: Value(_text(draft.chemistry)),
          nominalVoltage: Value(draft.nominalVoltage),
          capacity: Value(draft.capacity),
          capacityUnit: Value(_text(draft.capacityUnit)),
          rechargeable: Value(draft.rechargeable),
          purchaseDate: Value(draft.purchaseDate?.toUtc()),
          purchaseLocation: Value(_text(draft.purchaseLocation)),
          purchasePrice: Value(draft.purchasePrice),
          totalPackagePrice: Value(draft.totalPackagePrice),
          perBatteryPrice: Value(draft.perBatteryPrice),
          warrantyExpiration: Value(draft.warrantyExpiration?.toUtc()),
          status: Value(draft.status),
          condition: Value(draft.condition),
          conditionNote: Value(_text(draft.conditionNote)),
          notes: Value(_text(draft.notes)),
          iconSource: Value(draft.icon.source.storageValue),
          iconKey: Value(draft.icon.key),
          iconColor: Value(draft.icon.color.value),
          retirementReason: Value(
              draft.status == 'Retired' ? previous?.retirementReason : null),
          retiredAt: Value(
              draft.status == 'Retired' ? previous?.retiredAt ?? now : null),
          modifiedAt: Value(now),
        );
        if (previous == null) {
          await database.into(database.batteries).insert(values.copyWith(
              uuid: Value(permanentId.value), createdAt: Value(now)));
        } else {
          await (database.update(database.batteries)
                ..where((t) => t.uuid.equals(permanentId.value)))
              .write(values);
        }
        await _event(
            permanentId,
            previous == null ? 'battery_created' : 'battery_updated',
            previous == null ? 'Battery created.' : 'Battery updated.', {
          'battery_id': draft.userBatteryId.trim(),
          'previous_battery_id': previous?.userBatteryId
        });
        if (previous == null || previous.status != draft.status) {
          await _event(
              permanentId,
              'battery_status_changed',
              'Status: ${previous?.status ?? 'New record'} → ${draft.status}.',
              {'from': previous?.status, 'to': draft.status});
        }
        return get(permanentId);
      });
    } on SqliteException catch (error) {
      if (error.message.contains('batteries_active_user_id_uq')) {
        throw const BatteryValidationException(
            'This Battery ID already exists. Enter a different ID.');
      }
      rethrow;
    }
  }

  Future<void> _event(PermanentId id, String type, String summary,
      Map<String, Object?> metadata) async {
    await database.into(database.activityLog).insert(
        ActivityLogCompanion.insert(
            uuid: idGenerator.next().value,
            eventType: type,
            entityType: 'battery',
            entityUuid: id.value,
            summary: summary,
            metadataJson: Value(jsonEncode(metadata))));
  }

  @override
  Future<List<String>> history(PermanentId id) async {
    final rows = await (database.select(database.activityLog)
          ..where((t) =>
              t.entityType.equals('battery') & t.entityUuid.equals(id.value))
          ..orderBy([
            (t) => OrderingTerm.desc(t.occurredAt),
            (t) => OrderingTerm.desc(t.id)
          ]))
        .get();
    return rows.map((r) => '${r.occurredAt.toLocal()} — ${r.summary}').toList();
  }

  @override
  Future<String> suggestId(
      {String prefix = 'BAT',
      String separator = '-',
      int start = 1,
      int padding = 3}) async {
    if (start < 0 || padding < 1 || padding > 12)
      throw const BatteryValidationException(
          'Use a nonnegative start and padding from 1 to 12.');
    final rows = await database.select(database.batteries).get();
    final used = rows.map((r) => r.userBatteryId.toLowerCase()).toSet();
    var next = start;
    while (true) {
      final candidate =
          '${prefix.trim()}$separator${next.toString().padLeft(padding, '0')}';
      if (!used.contains(candidate.toLowerCase())) return candidate;
      next++;
    }
  }

  Future<BatteryRecord> _map(Battery row) async {
    final photo = row.preferredPrimaryVisual != 'photo'
        ? null
        : await database.customSelect(
            'SELECT m.relative_path FROM battery_photos p JOIN media_assets m ON m.id=p.media_asset_id WHERE p.battery_id = ? AND p.is_primary = 1',
            variables: [Variable.withInt(row.id)]).getSingleOrNull();
    final sets = await database.customSelect(
        'SELECT s.user_set_id FROM battery_set_memberships m JOIN battery_sets s ON s.id = m.battery_set_id WHERE m.battery_id = ? AND m.removed_at IS NULL ORDER BY s.user_set_id',
        variables: [Variable.withInt(row.id)]).get();
    final devices = await database.customSelect(
        'SELECT d.name FROM assignments a JOIN devices d ON d.id = a.device_id WHERE a.battery_id = ? AND a.removed_at IS NULL ORDER BY d.name',
        variables: [Variable.withInt(row.id)]).get();
    final charges = await database.customSelect(
        'SELECT COUNT(*) AS count, MAX(charged_at) AS last FROM charge_records WHERE battery_id = ?',
        variables: [Variable.withInt(row.id)]).getSingle();
    final type = row.batteryTypeId == null
        ? null
        : await (database.select(database.batteryTypes)
              ..where((t) => t.id.equals(row.batteryTypeId!)))
            .getSingleOrNull();
    final batch = row.batchId == null
        ? null
        : await (database.select(database.batteryBatches)
              ..where((t) => t.id.equals(row.batchId!)))
            .getSingleOrNull();
    return BatteryRecord(
        estimatedChargePercent: row.estimatedChargePercent,
        retiredAt: row.retiredAt,
        retirementReason: row.retirementReason,
        primaryPhotoPath: photo == null
            ? null
            : ManagedRelativePath.parse(photo.read<String>('relative_path')),
        id: PermanentId.parse(row.uuid),
        currentSets:
            List.unmodifiable(sets.map((r) => r.read<String>('user_set_id'))),
        currentDevices:
            List.unmodifiable(devices.map((r) => r.read<String>('name'))),
        recordedCharges: charges.read<int>('count'),
        lastCharged:
            DateTime.tryParse(charges.readNullable<String>('last') ?? ''),
        createdAt: row.createdAt,
        modifiedAt: row.modifiedAt,
        values: BatteryDraft(
            userBatteryId: row.userBatteryId,
            name: row.name,
            batteryTypeId: type == null ? null : PermanentId.parse(type.uuid),
            batchCode: batch?.batchCode,
            manufacturer: row.manufacturer,
            model: row.model,
            serialNumber: row.serialNumber,
            customLabel: row.customLabel,
            chemistry: row.chemistry,
            nominalVoltage: row.nominalVoltage,
            capacity: row.capacity,
            capacityUnit: row.capacityUnit,
            rechargeable: row.rechargeable,
            purchaseDate: row.purchaseDate,
            purchaseLocation: row.purchaseLocation,
            purchasePrice: row.purchasePrice,
            totalPackagePrice: row.totalPackagePrice,
            perBatteryPrice: row.perBatteryPrice,
            warrantyExpiration: row.warrantyExpiration,
            status: row.status,
            condition: row.condition,
            conditionNote: row.conditionNote,
            notes: row.notes,
            icon: IconSelection(
                source: IconSource.fromStorage(row.iconSource),
                key: row.iconKey,
                color: IconColor.parse(row.iconColor))));
  }
}

String? _text(String? value) =>
    value == null || value.trim().isEmpty ? null : value.trim();
