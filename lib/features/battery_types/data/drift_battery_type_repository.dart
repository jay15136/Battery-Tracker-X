import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../core/database/app_database.dart';
import '../../../core/identity/permanent_id.dart';
import '../../icons/domain/icon_color.dart';
import '../../icons/domain/icon_definition.dart';
import '../../icons/domain/icon_repository.dart';
import '../../icons/domain/icon_selection.dart';
import '../domain/battery_type.dart';
import '../domain/battery_type_draft.dart';
import '../domain/battery_type_repository.dart';

final class DriftBatteryTypeRepository {
  DriftBatteryTypeRepository({
    required this.database,
    required this.idGenerator,
    required this.iconRepository,
    DateTime Function()? clock,
  }) : _clock = clock ?? (() => DateTime.now().toUtc());

  final AppDatabase database;
  final PermanentIdGenerator idGenerator;
  final IconRepository iconRepository;
  final DateTime Function() _clock;

  Future<List<BatteryTypeRecord>> list({bool includeInactive = false}) async {
    final query = database.select(database.batteryTypes);
    if (!includeInactive) {
      query.where((table) => table.deactivatedAt.isNull());
    }
    query.orderBy([
      (table) => OrderingTerm.asc(table.typeName.lower()),
    ]);
    return (await query.get()).map(_mapRecord).toList(growable: false);
  }

  Future<BatteryTypeRecord> get(PermanentId id) async {
    final row = await _rowById(id);
    if (row == null) {
      throw BatteryTypeNotFoundException(id);
    }
    return _mapRecord(row);
  }

  Future<BatteryTypeRecord> create(BatteryTypeDraft draft) async {
    try {
      return await database.transaction(() async {
        final values = draft.validated();
        await iconRepository.validateSelection(
          scopes: const {IconScope.battery},
          selection: values.suggestedIcon,
        );
        await _ensureActiveNameAvailable(values.typeName);
        final id = idGenerator.next();
        final now = _clock();
        await database.into(database.batteryTypes).insert(
              BatteryTypesCompanion.insert(
                uuid: id.value,
                typeName: values.typeName,
                description: Value(values.description),
                chemistry: Value(values.chemistry),
                defaultVoltage: Value(values.defaultVoltage),
                defaultCapacity: Value(values.defaultCapacity),
                capacityUnit: Value(values.capacityUnit),
                physicalSize: Value(values.physicalSize),
                suggestedIconSource:
                    Value(values.suggestedIcon.source.storageValue),
                suggestedIconKey: Value(values.suggestedIcon.key),
                suggestedIconColor: Value(values.suggestedIcon.color.value),
                notes: Value(values.notes),
                createdAt: Value(now),
                modifiedAt: Value(now),
              ),
            );
        await _recordActivity('battery_type_created', id);
        return get(id);
      });
    } on SqliteException catch (error) {
      if (_isActiveNameUniqueViolation(error)) {
        throw BatteryTypeNameConflictException(draft.typeName.trim());
      }
      rethrow;
    }
  }

  Future<BatteryTypeRecord> update(
    PermanentId id,
    BatteryTypeDraft draft,
  ) async {
    try {
      return await database.transaction(() async {
        final current = await _rowById(id);
        if (current == null) {
          throw BatteryTypeNotFoundException(id);
        }
        final values = draft.validated();
        await iconRepository.validateSelection(
          scopes: const {IconScope.battery},
          selection: values.suggestedIcon,
        );
        if (current.deactivatedAt == null) {
          await _ensureActiveNameAvailable(
            values.typeName,
            excluding: id,
          );
        }
        final now = _clock();
        await (database.update(database.batteryTypes)
              ..where((table) => table.uuid.equals(id.value)))
            .write(
          BatteryTypesCompanion(
            typeName: Value(values.typeName),
            description: Value(values.description),
            chemistry: Value(values.chemistry),
            defaultVoltage: Value(values.defaultVoltage),
            defaultCapacity: Value(values.defaultCapacity),
            capacityUnit: Value(values.capacityUnit),
            physicalSize: Value(values.physicalSize),
            suggestedIconSource:
                Value(values.suggestedIcon.source.storageValue),
            suggestedIconKey: Value(values.suggestedIcon.key),
            suggestedIconColor: Value(values.suggestedIcon.color.value),
            notes: Value(values.notes),
            modifiedAt: Value(now),
          ),
        );
        await _recordActivity('battery_type_updated', id);
        return get(id);
      });
    } on SqliteException catch (error) {
      if (_isActiveNameUniqueViolation(error)) {
        throw BatteryTypeNameConflictException(draft.typeName.trim());
      }
      rethrow;
    }
  }

  Future<BatteryType?> _rowById(PermanentId id) {
    return (database.select(database.batteryTypes)
          ..where((table) => table.uuid.equals(id.value)))
        .getSingleOrNull();
  }

  Future<void> _ensureActiveNameAvailable(
    String typeName, {
    PermanentId? excluding,
  }) async {
    final query = database.select(database.batteryTypes)
      ..where(
        (table) =>
            table.deactivatedAt.isNull() &
            table.typeName.lower().equals(typeName.toLowerCase()),
      );
    if (excluding != null) {
      query.where((table) => table.uuid.equals(excluding.value).not());
    }
    if (await query.getSingleOrNull() != null) {
      throw BatteryTypeNameConflictException(typeName);
    }
  }

  BatteryTypeRecord _mapRecord(BatteryType row) => BatteryTypeRecord(
        id: PermanentId.parse(row.uuid),
        typeName: row.typeName,
        description: row.description,
        chemistry: row.chemistry,
        defaultVoltage: row.defaultVoltage,
        defaultCapacity: row.defaultCapacity,
        capacityUnit: row.capacityUnit,
        physicalSize: row.physicalSize,
        suggestedIcon: IconSelection(
          source: IconSource.fromStorage(row.suggestedIconSource),
          key: row.suggestedIconKey,
          color: IconColor.parse(row.suggestedIconColor),
        ),
        notes: row.notes,
        createdAt: row.createdAt,
        modifiedAt: row.modifiedAt,
        deactivatedAt: row.deactivatedAt,
      );

  Future<void> _recordActivity(String eventType, PermanentId id) {
    return database.into(database.activityLog).insert(
          ActivityLogCompanion.insert(
            uuid: idGenerator.next().value,
            eventType: eventType,
            entityType: 'battery_type',
            entityUuid: id.value,
            summary: eventType == 'battery_type_created'
                ? 'Battery Type created.'
                : 'Battery Type updated.',
            metadataJson: Value(jsonEncode(const <String, Object?>{})),
            occurredAt: Value(_clock()),
          ),
        );
  }

  bool _isActiveNameUniqueViolation(SqliteException error) =>
      error.message.contains('battery_types_active_name_uq');
}
