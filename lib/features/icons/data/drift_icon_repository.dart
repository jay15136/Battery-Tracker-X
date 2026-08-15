import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/identity/permanent_id.dart';
import '../../../core/storage/managed_relative_path.dart';
import '../domain/icon_color.dart';
import '../domain/icon_definition.dart';
import '../domain/icon_registry.dart';
import '../domain/icon_repository.dart';
import '../domain/icon_selection.dart';

final class DriftIconRepository implements IconRepository {
  DriftIconRepository({
    required this.database,
    required this.idGenerator,
    required this.builtInRegistry,
    DateTime Function()? clock,
  }) : _clock = clock ?? (() => DateTime.now().toUtc());

  static const _recentLimit = 12;
  static const _recentKeyPrefix = 'icons.recent.';

  final AppDatabase database;
  final PermanentIdGenerator idGenerator;
  final IconRegistry builtInRegistry;
  final DateTime Function() _clock;

  @override
  Future<List<IconCategoryRecord>> listCategories({
    IconScope? scope,
    bool includeInactive = false,
  }) async {
    final query = database.select(database.iconCategories);
    if (scope != null) {
      query.where((table) => table.scope.equals(scope.storageValue));
    }
    if (!includeInactive) {
      query.where((table) => table.deactivatedAt.isNull());
    }
    query.orderBy([
      (table) => OrderingTerm.asc(table.name),
    ]);
    return (await query.get()).map(_mapCategory).toList(growable: false);
  }

  @override
  Future<IconCategoryRecord> createCategory({
    required PermanentId id,
    required String name,
    required IconScope scope,
  }) async {
    final normalizedName = _requireName(name, 'Category name');
    await database.into(database.iconCategories).insert(
          IconCategoriesCompanion.insert(
            uuid: id.value,
            name: normalizedName,
            scope: scope.storageValue,
          ),
        );
    return _categoryById(id);
  }

  @override
  Future<void> renameCategory(PermanentId id, String name) async {
    final updated = await (database.update(database.iconCategories)
          ..where((table) => table.uuid.equals(id.value)))
        .write(
      IconCategoriesCompanion(
        name: Value(_requireName(name, 'Category name')),
        modifiedAt: Value(_clock()),
      ),
    );
    if (updated != 1) {
      throw StateError('Icon category was not found.');
    }
  }

  @override
  Future<List<CustomIconRecord>> listCustomIcons({
    IconScope? scope,
    bool includeInactive = false,
  }) async {
    final query = database.select(database.customIcons).join([
      innerJoin(
        database.iconCategories,
        database.iconCategories.id.equalsExp(database.customIcons.categoryId),
      ),
    ]);
    if (scope != null) {
      query.where(database.iconCategories.scope.equals(scope.storageValue));
    }
    if (!includeInactive) {
      query.where(database.customIcons.deactivatedAt.isNull());
      query.where(database.iconCategories.deactivatedAt.isNull());
    }
    query.orderBy([
      OrderingTerm.asc(database.customIcons.name),
    ]);
    return (await query.get()).map(_mapJoinedIcon).toList(growable: false);
  }

  @override
  Future<CustomIconRecord> getCustomIcon(PermanentId id) async {
    final query = database.select(database.customIcons).join([
      innerJoin(
        database.iconCategories,
        database.iconCategories.id.equalsExp(database.customIcons.categoryId),
      ),
    ])
      ..where(database.customIcons.uuid.equals(id.value));
    final row = await query.getSingleOrNull();
    if (row == null) {
      throw CustomIconNotFoundException(id);
    }
    return _mapJoinedIcon(row);
  }

  @override
  Future<CustomIconRecord> createCustomIcon({
    required PermanentId id,
    required String name,
    required PermanentId categoryId,
    required ManagedRelativePath relativePath,
    required IconFileType fileType,
    required bool supportsColor,
  }) async {
    final category = await _categoryById(categoryId);
    if (!category.isActive) {
      throw StateError('Inactive categories cannot receive icons.');
    }
    await database.transaction(() async {
      await database.into(database.customIcons).insert(
            CustomIconsCompanion.insert(
              uuid: id.value,
              name: _requireName(name, 'Icon name'),
              categoryId: Value(await _categoryRowId(categoryId)),
              relativePath: relativePath.value,
              fileType: fileType.name,
              supportsColor: Value(supportsColor),
            ),
          );
      await _recordActivity(
        eventType: 'custom_icon_created',
        entityType: 'custom_icon',
        entityUuid: id.value,
        summary: 'Custom icon created.',
      );
    });
    return getCustomIcon(id);
  }

  @override
  Future<void> updateCustomIconMetadata({
    required PermanentId id,
    required String name,
    required PermanentId categoryId,
    required bool supportsColor,
  }) async {
    final category = await _categoryById(categoryId);
    if (!category.isActive) {
      throw StateError('Inactive categories cannot receive icons.');
    }
    await database.transaction(() async {
      final updated = await (database.update(database.customIcons)
            ..where(
              (table) =>
                  table.uuid.equals(id.value) & table.deactivatedAt.isNull(),
            ))
          .write(
        CustomIconsCompanion(
          name: Value(_requireName(name, 'Icon name')),
          categoryId: Value(await _categoryRowId(categoryId)),
          supportsColor: Value(supportsColor),
          modifiedAt: Value(_clock()),
        ),
      );
      if (updated != 1) {
        throw CustomIconNotFoundException(id);
      }
      await _recordActivity(
        eventType: 'custom_icon_updated',
        entityType: 'custom_icon',
        entityUuid: id.value,
        summary: 'Custom icon details updated.',
      );
    });
  }

  @override
  Future<void> updateCustomIconSource({
    required PermanentId id,
    required ManagedRelativePath relativePath,
    required IconFileType fileType,
  }) async {
    await database.transaction(() async {
      final updated = await (database.update(database.customIcons)
            ..where(
              (table) =>
                  table.uuid.equals(id.value) & table.deactivatedAt.isNull(),
            ))
          .write(
        CustomIconsCompanion(
          relativePath: Value(relativePath.value),
          fileType: Value(fileType.name),
          modifiedAt: Value(_clock()),
        ),
      );
      if (updated != 1) {
        throw CustomIconNotFoundException(id);
      }
      await _recordActivity(
        eventType: 'custom_icon_source_replaced',
        entityType: 'custom_icon',
        entityUuid: id.value,
        summary: 'Custom icon source image replaced.',
      );
    });
  }

  @override
  Future<IconUsage> usageCount(PermanentId id) => _usageCount(id.value);

  @override
  Future<void> saveOwnerSelection({
    required IconOwnerReference owner,
    required IconSelection selection,
  }) async {
    await validateSelection(
      scopes: {owner.type.scope},
      selection: selection,
    );
    await database.transaction(() async {
      final now = _clock();
      final updated = await _updateOwner(owner, selection, now);
      if (updated != 1) {
        throw IconOwnerNotFoundException(owner);
      }
      await _saveRecent(owner.type.scope, selection, now);
      await _recordActivity(
        eventType: 'icon_selection_changed',
        entityType: owner.type.storageValue,
        entityUuid: owner.id.value,
        summary: 'Icon selection updated.',
        metadata: {
          'icon_source': selection.source.storageValue,
          'icon_key': selection.key,
          'icon_color': selection.color.value,
        },
      );
    });
  }

  @override
  Future<List<IconSelection>> recentSelections(IconScope scope) async {
    final row = await (database.select(database.settings)
          ..where((table) => table.key.equals(_recentKey(scope))))
        .getSingleOrNull();
    if (row == null) {
      return const [];
    }
    try {
      final decoded = jsonDecode(row.value) as List<dynamic>;
      return decoded
          .cast<Map<String, dynamic>>()
          .map(
            (entry) => IconSelection(
              source: IconSource.fromStorage(entry['source'] as String),
              key: entry['key'] as String,
              color: IconColor.parse(entry['color'] as String),
            ),
          )
          .toList(growable: false);
    } on Object {
      return const [];
    }
  }

  @override
  Future<ManagedRelativePath> deactivateCustomIcon({
    required PermanentId id,
    IconSelection? replacement,
    bool replaceWithDefaults = false,
  }) async {
    if (replacement != null && replaceWithDefaults) {
      throw ArgumentError(
        'Choose a replacement icon or owner defaults, not both.',
      );
    }
    if (replacement?.source == IconSource.custom &&
        replacement?.key == id.value) {
      throw const InvalidIconSelectionException(
        'Choose a different replacement icon.',
      );
    }

    return database.transaction(() async {
      final icon = await getCustomIcon(id);
      if (!icon.isActive) {
        throw CustomIconNotFoundException(id);
      }
      final usage = await _usageCount(id.value);
      if (usage.total > 0 && replacement == null && !replaceWithDefaults) {
        throw IconInUseException(usage);
      }
      if (replacement != null) {
        await validateSelection(scopes: usage.scopes, selection: replacement);
        await _replaceReferences(id.value, replacement);
      } else if (replaceWithDefaults) {
        await _replaceReferencesWithDefaults(id.value);
      }

      final updated = await (database.update(database.customIcons)
            ..where(
              (table) =>
                  table.uuid.equals(id.value) & table.deactivatedAt.isNull(),
            ))
          .write(
        CustomIconsCompanion(
          modifiedAt: Value(_clock()),
          deactivatedAt: Value(_clock()),
        ),
      );
      if (updated != 1) {
        throw CustomIconNotFoundException(id);
      }
      await _recordActivity(
        eventType: 'custom_icon_deleted',
        entityType: 'custom_icon',
        entityUuid: id.value,
        summary: usage.total == 0
            ? 'Unused custom icon deleted.'
            : 'Custom icon references replaced and icon deleted.',
        metadata: {'replaced_reference_count': usage.total},
      );
      return icon.relativePath;
    });
  }

  Future<IconCategoryRecord> _categoryById(PermanentId id) async {
    final row = await (database.select(database.iconCategories)
          ..where((table) => table.uuid.equals(id.value)))
        .getSingleOrNull();
    if (row == null) {
      throw StateError('Icon category was not found.');
    }
    return _mapCategory(row);
  }

  Future<int> _categoryRowId(PermanentId id) async {
    final row = await (database.select(database.iconCategories)
          ..where((table) => table.uuid.equals(id.value)))
        .getSingleOrNull();
    if (row == null) {
      throw StateError('Icon category was not found.');
    }
    return row.id;
  }

  IconCategoryRecord _mapCategory(IconCategory row) => IconCategoryRecord(
        id: PermanentId.parse(row.uuid),
        name: row.name,
        scope: IconScope.fromStorage(row.scope),
        createdAt: row.createdAt,
        modifiedAt: row.modifiedAt,
        deactivatedAt: row.deactivatedAt,
      );

  CustomIconRecord _mapJoinedIcon(TypedResult result) {
    final icon = result.readTable(database.customIcons);
    final category = result.readTable(database.iconCategories);
    return CustomIconRecord(
      id: PermanentId.parse(icon.uuid),
      name: icon.name,
      category: _mapCategory(category),
      relativePath: ManagedRelativePath.parse(icon.relativePath),
      fileType: IconFileType.values.byName(icon.fileType),
      supportsColor: icon.supportsColor,
      createdAt: icon.createdAt,
      modifiedAt: icon.modifiedAt,
      deactivatedAt: icon.deactivatedAt,
    );
  }

  Future<IconUsage> _usageCount(String iconKey) async {
    final row = await database
        .customSelect(
          'SELECT '
          "(SELECT count(*) FROM batteries WHERE icon_source = 'custom' "
          'AND icon_key = ?) AS batteries, '
          "(SELECT count(*) FROM battery_sets WHERE icon_source = 'custom' "
          'AND icon_key = ?) AS battery_sets, '
          "(SELECT count(*) FROM devices WHERE icon_source = 'custom' "
          'AND icon_key = ?) AS devices, '
          "(SELECT count(*) FROM battery_types WHERE suggested_icon_source = 'custom' "
          'AND suggested_icon_key = ?) AS battery_types',
          variables: List.generate(4, (_) => Variable<String>(iconKey)),
        )
        .getSingle();
    return IconUsage(
      batteries: row.read<int>('batteries'),
      batterySets: row.read<int>('battery_sets'),
      devices: row.read<int>('devices'),
      batteryTypes: row.read<int>('battery_types'),
    );
  }

  @override
  Future<void> validateSelection({
    required Set<IconScope> scopes,
    required IconSelection selection,
  }) async {
    if (scopes.isEmpty) {
      return;
    }
    IconDefinition? definition;
    if (selection.source == IconSource.builtin) {
      final candidates = builtInRegistry.definitions.where(
        (candidate) =>
            candidate.source == IconSource.builtin &&
            candidate.key == selection.key &&
            !candidate.isDeprecated,
      );
      definition = candidates.isEmpty ? null : candidates.single;
    } else {
      try {
        final custom = await getCustomIcon(PermanentId.parse(selection.key));
        if (custom.isActive) {
          definition = custom.toDefinition();
        }
      } on FormatException {
        definition = null;
      } on CustomIconNotFoundException {
        definition = null;
      }
    }
    if (definition == null) {
      throw const InvalidIconSelectionException(
        'The selected icon is unavailable.',
      );
    }
    for (final scope in scopes) {
      if (definition.scope != scope && definition.scope != IconScope.general) {
        throw const InvalidIconSelectionException(
          'The selected icon is not available for every affected record.',
        );
      }
    }
  }

  Future<int> _updateOwner(
    IconOwnerReference owner,
    IconSelection selection,
    DateTime now,
  ) {
    return switch (owner.type) {
      IconOwnerType.battery => (database.update(database.batteries)
              ..where((table) => table.uuid.equals(owner.id.value)))
            .write(
          BatteriesCompanion(
            iconSource: Value(selection.source.storageValue),
            iconKey: Value(selection.key),
            iconColor: Value(selection.color.value),
            modifiedAt: Value(now),
          ),
        ),
      IconOwnerType.batterySet => (database.update(database.batterySets)
              ..where((table) => table.uuid.equals(owner.id.value)))
            .write(
          BatterySetsCompanion(
            iconSource: Value(selection.source.storageValue),
            iconKey: Value(selection.key),
            iconColor: Value(selection.color.value),
            modifiedAt: Value(now),
          ),
        ),
      IconOwnerType.device => (database.update(database.devices)
              ..where((table) => table.uuid.equals(owner.id.value)))
            .write(
          DevicesCompanion(
            iconSource: Value(selection.source.storageValue),
            iconKey: Value(selection.key),
            iconColor: Value(selection.color.value),
            modifiedAt: Value(now),
          ),
        ),
      IconOwnerType.batteryType => (database.update(database.batteryTypes)
              ..where((table) => table.uuid.equals(owner.id.value)))
            .write(
          BatteryTypesCompanion(
            suggestedIconSource: Value(selection.source.storageValue),
            suggestedIconKey: Value(selection.key),
            suggestedIconColor: Value(selection.color.value),
            modifiedAt: Value(now),
          ),
        ),
    };
  }

  Future<void> _saveRecent(
    IconScope scope,
    IconSelection selection,
    DateTime now,
  ) async {
    final current = await recentSelections(scope);
    final updated = [
      selection,
      ...current.where(
        (candidate) =>
            candidate.source != selection.source ||
            candidate.key != selection.key,
      ),
    ].take(_recentLimit);
    final value = jsonEncode([
      for (final item in updated)
        {
          'source': item.source.storageValue,
          'key': item.key,
          'color': item.color.value,
        },
    ]);
    await database.into(database.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: _recentKey(scope),
            value: value,
            valueType: 'json',
            modifiedAt: Value(now),
          ),
        );
  }

  Future<void> _replaceReferences(
    String oldKey,
    IconSelection replacement,
  ) async {
    final variables = [
      Variable<String>(replacement.source.storageValue),
      Variable<String>(replacement.key),
      Variable<String>(replacement.color.value),
      Variable<String>(_clock().toIso8601String()),
      Variable<String>(oldKey),
    ];
    for (final table in ['batteries', 'battery_sets', 'devices']) {
      await database.customUpdate(
        'UPDATE $table SET icon_source = ?, icon_key = ?, icon_color = ?, '
        "modified_at = ? WHERE icon_source = 'custom' AND icon_key = ?",
        variables: variables,
        updates: {
          switch (table) {
            'batteries' => database.batteries,
            'battery_sets' => database.batterySets,
            _ => database.devices,
          },
        },
      );
    }
    await database.customUpdate(
      'UPDATE battery_types SET suggested_icon_source = ?, '
      'suggested_icon_key = ?, suggested_icon_color = ?, modified_at = ? '
      "WHERE suggested_icon_source = 'custom' AND suggested_icon_key = ?",
      variables: variables,
      updates: {database.batteryTypes},
    );
  }

  Future<void> _replaceReferencesWithDefaults(String oldKey) async {
    final now = Variable<String>(_clock().toIso8601String());
    final old = Variable<String>(oldKey);
    final replacements = {
      'batteries': 'battery_generic',
      'battery_sets': 'battery_set_generic',
      'devices': 'device_generic',
    };
    for (final entry in replacements.entries) {
      await database.customUpdate(
        "UPDATE ${entry.key} SET icon_source = 'builtin', icon_key = ?, "
        "icon_color = '#607D8B', modified_at = ? "
        "WHERE icon_source = 'custom' AND icon_key = ?",
        variables: [Variable<String>(entry.value), now, old],
        updates: {
          switch (entry.key) {
            'batteries' => database.batteries,
            'battery_sets' => database.batterySets,
            _ => database.devices,
          },
        },
      );
    }
    await database.customUpdate(
      "UPDATE battery_types SET suggested_icon_source = 'builtin', "
      "suggested_icon_key = 'battery_generic', "
      "suggested_icon_color = '#607D8B', modified_at = ? "
      "WHERE suggested_icon_source = 'custom' AND suggested_icon_key = ?",
      variables: [now, old],
      updates: {database.batteryTypes},
    );
  }

  Future<void> _recordActivity({
    required String eventType,
    required String entityType,
    required String entityUuid,
    required String summary,
    Map<String, Object?> metadata = const {},
  }) {
    return database.into(database.activityLog).insert(
          ActivityLogCompanion.insert(
            uuid: idGenerator.next().value,
            eventType: eventType,
            entityType: entityType,
            entityUuid: entityUuid,
            summary: summary,
            metadataJson: Value(jsonEncode(metadata)),
            occurredAt: Value(_clock()),
          ),
        );
  }

  String _recentKey(IconScope scope) =>
      '$_recentKeyPrefix${scope.storageValue}';

  String _requireName(String value, String label) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('$label cannot be empty.');
    }
    return normalized;
  }
}
