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

final class DriftBatteryTypeRepository implements BatteryTypeRepository {
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

  @override
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

  @override
  Future<BatteryTypeRecord> get(PermanentId id) async {
    final row = await _rowById(id);
    if (row == null) {
      throw BatteryTypeNotFoundException(id);
    }
    return _mapRecord(row);
  }

  @override
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

  @override
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

  @override
  Future<BatteryTypeUsage> usage(PermanentId id) async {
    await get(id);
    return _usageForExistingType(id);
  }

  @override
  Future<BatteryTypeRecord> deactivate(PermanentId id) {
    return database.transaction(() async {
      final current = await _rowById(id);
      if (current == null) {
        throw BatteryTypeNotFoundException(id);
      }
      if (current.deactivatedAt != null) {
        throw BatteryTypeStateConflictException(
          id,
          'Battery Type is already inactive.',
        );
      }

      final counts = await _usageForExistingType(id);
      final now = _clock();
      final changed = await (database.update(database.batteryTypes)
            ..where(
              (table) =>
                  table.uuid.equals(id.value) & table.deactivatedAt.isNull(),
            ))
          .write(
        BatteryTypesCompanion(
          deactivatedAt: Value(now),
          modifiedAt: Value(now),
        ),
      );
      if (changed != 1) {
        throw BatteryTypeStateConflictException(
          id,
          'Battery Type is no longer active.',
        );
      }
      await _recordActivity(
        'battery_type_deactivated',
        id,
        metadata: {
          'batteries': counts.batteries,
          'battery_sets': counts.batterySets,
          'devices': counts.devices,
        },
      );
      return get(id);
    });
  }

  @override
  Future<BatteryTypeRecord> reactivate(PermanentId id) async {
    try {
      return await database.transaction(() async {
        final current = await _rowById(id);
        if (current == null) {
          throw BatteryTypeNotFoundException(id);
        }
        if (current.deactivatedAt == null) {
          throw BatteryTypeStateConflictException(
            id,
            'Battery Type is already active.',
          );
        }
        try {
          await _ensureActiveNameAvailable(current.typeName);
        } on BatteryTypeNameConflictException {
          throw BatteryTypeReactivationConflictException(
            id: id,
            name: current.typeName,
          );
        }

        final now = _clock();
        final changed = await (database.update(database.batteryTypes)
              ..where(
                (table) =>
                    table.uuid.equals(id.value) &
                    table.deactivatedAt.isNotNull(),
              ))
            .write(
          BatteryTypesCompanion(
            deactivatedAt: const Value(null),
            modifiedAt: Value(now),
          ),
        );
        if (changed != 1) {
          throw BatteryTypeStateConflictException(
            id,
            'Battery Type is no longer inactive.',
          );
        }
        await _recordActivity('battery_type_reactivated', id);
        return get(id);
      });
    } on SqliteException catch (error) {
      if (_isActiveNameUniqueViolation(error)) {
        final current = await _rowById(id);
        throw BatteryTypeReactivationConflictException(
          id: id,
          name: current?.typeName ?? '',
        );
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

  Future<BatteryTypeUsage> _usageForExistingType(PermanentId id) async {
    final batteries = await _referenceCount(
      table: 'batteries',
      column: 'battery_type_id',
      id: id,
    );
    final batterySets = await _referenceCount(
      table: 'battery_sets',
      column: 'battery_type_id',
      id: id,
    );
    final devices = await _referenceCount(
      table: 'devices',
      column: 'required_battery_type_id',
      id: id,
    );
    return BatteryTypeUsage(
      batteries: batteries,
      batterySets: batterySets,
      devices: devices,
    );
  }

  Future<int> _referenceCount({
    required String table,
    required String column,
    required PermanentId id,
  }) async {
    final row = await database.customSelect(
      'SELECT COUNT(*) AS usage_count FROM $table '
      'WHERE $column = ('
      'SELECT id FROM battery_types WHERE uuid = ?'
      ')',
      variables: [Variable.withString(id.value)],
    ).getSingle();
    return row.read<int>('usage_count');
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

  Future<void> _recordActivity(
    String eventType,
    PermanentId id, {
    Map<String, Object?> metadata = const {},
  }) {
    return database.into(database.activityLog).insert(
          ActivityLogCompanion.insert(
            uuid: idGenerator.next().value,
            eventType: eventType,
            entityType: 'battery_type',
            entityUuid: id.value,
            summary: _activitySummary(eventType),
            metadataJson: Value(jsonEncode(metadata)),
            occurredAt: Value(_clock()),
          ),
        );
  }

  bool _isActiveNameUniqueViolation(SqliteException error) =>
      error.message.contains('battery_types_active_name_uq');

  String _activitySummary(String eventType) {
    switch (eventType) {
      case 'battery_type_created':
        return 'Battery Type created.';
      case 'battery_type_updated':
        return 'Battery Type updated.';
      case 'battery_type_deactivated':
        return 'Battery Type deactivated.';
      case 'battery_type_reactivated':
        return 'Battery Type reactivated.';
    }
    throw ArgumentError.value(eventType, 'eventType', 'Unsupported activity.');
  }
}
