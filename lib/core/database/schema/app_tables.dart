import 'package:drift/drift.dart';

import 'utc_date_time_text_converter.dart';

String _utcNow() => DateTime.now().toUtc().toIso8601String();

class BatteryTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get typeName => text()();
  TextColumn get description => text().nullable()();
  TextColumn get chemistry => text().nullable()();
  RealColumn get defaultVoltage => real().nullable()();
  RealColumn get defaultCapacity => real().nullable()();
  TextColumn get capacityUnit => text().nullable()();
  TextColumn get physicalSize => text().nullable()();
  TextColumn get suggestedIconSource =>
      text().withDefault(const Constant('builtin'))();
  TextColumn get suggestedIconKey =>
      text().withDefault(const Constant('battery_generic'))();
  TextColumn get suggestedIconColor =>
      text().withDefault(const Constant('#607D8B'))();
  TextColumn get notes => text().nullable()();
  TextColumn get createdAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get modifiedAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get deactivatedAt =>
      text().map(const UtcDateTimeTextConverter()).nullable()();

  @override
  List<String> get customConstraints => const [
        'CHECK (length(trim(type_name)) > 0)',
        'CHECK (default_voltage IS NULL OR default_voltage >= 0)',
        'CHECK (default_capacity IS NULL OR default_capacity >= 0)',
        "CHECK (suggested_icon_source IN ('builtin', 'custom'))",
      ];
}

class BatteryBatches extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get batchCode => text()();
  TextColumn get description => text().nullable()();
  TextColumn get purchaseDate =>
      text().map(const UtcDateTimeTextConverter()).nullable()();
  TextColumn get purchaseLocation => text().nullable()();
  RealColumn get totalPurchasePrice => real().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get modifiedAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();

  @override
  List<String> get customConstraints => const [
        'CHECK (length(trim(batch_code)) > 0)',
        'CHECK (total_purchase_price IS NULL OR total_purchase_price >= 0)',
      ];
}

class Batteries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get userBatteryId => text()();
  TextColumn get name => text().nullable()();
  IntColumn get batteryTypeId => integer()
      .nullable()
      .references(BatteryTypes, #id, onDelete: KeyAction.restrict)();
  IntColumn get batchId => integer()
      .nullable()
      .references(BatteryBatches, #id, onDelete: KeyAction.restrict)();
  TextColumn get manufacturer => text().nullable()();
  TextColumn get model => text().nullable()();
  TextColumn get serialNumber => text().nullable()();
  TextColumn get customLabel => text().nullable()();
  TextColumn get chemistry => text().nullable()();
  RealColumn get nominalVoltage => real().nullable()();
  RealColumn get capacity => real().nullable()();
  TextColumn get capacityUnit => text().nullable()();
  BoolColumn get rechargeable => boolean().withDefault(const Constant(true))();
  TextColumn get purchaseDate =>
      text().map(const UtcDateTimeTextConverter()).nullable()();
  TextColumn get purchaseLocation => text().nullable()();
  RealColumn get purchasePrice => real().nullable()();
  RealColumn get totalPackagePrice => real().nullable()();
  RealColumn get perBatteryPrice => real().nullable()();
  TextColumn get warrantyExpiration =>
      text().map(const UtcDateTimeTextConverter()).nullable()();
  TextColumn get status => text().withDefault(const Constant('Available'))();
  TextColumn get condition => text().withDefault(const Constant('New'))();
  TextColumn get conditionNote => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get iconSource => text().withDefault(const Constant('builtin'))();
  TextColumn get iconKey =>
      text().withDefault(const Constant('battery_generic'))();
  TextColumn get iconColor => text().withDefault(const Constant('#607D8B'))();
  TextColumn get preferredPrimaryVisual =>
      text().withDefault(const Constant('icon'))();
  IntColumn get estimatedChargePercent => integer().nullable()();
  TextColumn get retiredAt =>
      text().map(const UtcDateTimeTextConverter()).nullable()();
  TextColumn get retirementReason => text().nullable()();
  TextColumn get createdAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get modifiedAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get deletedAt =>
      text().map(const UtcDateTimeTextConverter()).nullable()();

  @override
  List<String> get customConstraints => const [
        'CHECK (length(trim(user_battery_id)) > 0)',
        'CHECK (nominal_voltage IS NULL OR nominal_voltage >= 0)',
        'CHECK (capacity IS NULL OR capacity >= 0)',
        'CHECK (purchase_price IS NULL OR purchase_price >= 0)',
        'CHECK (total_package_price IS NULL OR total_package_price >= 0)',
        'CHECK (per_battery_price IS NULL OR per_battery_price >= 0)',
        'CHECK (estimated_charge_percent IS NULL OR '
            '(estimated_charge_percent BETWEEN 0 AND 100))',
        "CHECK (icon_source IN ('builtin', 'custom'))",
        "CHECK (preferred_primary_visual IN ('icon', 'photo'))",
      ];
}

class BatterySets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get userSetId => text()();
  TextColumn get name => text()();
  IntColumn get batteryTypeId => integer()
      .nullable()
      .references(BatteryTypes, #id, onDelete: KeyAction.restrict)();
  TextColumn get description => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get iconSource => text().withDefault(const Constant('builtin'))();
  TextColumn get iconKey =>
      text().withDefault(const Constant('battery_set_generic'))();
  TextColumn get iconColor => text().withDefault(const Constant('#607D8B'))();
  TextColumn get preferredPrimaryVisual =>
      text().withDefault(const Constant('icon'))();
  TextColumn get createdAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get modifiedAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get deactivatedAt =>
      text().map(const UtcDateTimeTextConverter()).nullable()();
  TextColumn get deletedAt =>
      text().map(const UtcDateTimeTextConverter()).nullable()();

  @override
  List<String> get customConstraints => const [
        'CHECK (length(trim(user_set_id)) > 0)',
        'CHECK (length(trim(name)) > 0)',
        "CHECK (icon_source IN ('builtin', 'custom'))",
        "CHECK (preferred_primary_visual IN ('icon', 'photo'))",
      ];
}

class BatterySetMemberships extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  IntColumn get batteryId =>
      integer().references(Batteries, #id, onDelete: KeyAction.restrict)();
  IntColumn get batterySetId =>
      integer().references(BatterySets, #id, onDelete: KeyAction.restrict)();
  TextColumn get addedAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get removedAt =>
      text().map(const UtcDateTimeTextConverter()).nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get operationUuid => text()();

  @override
  List<String> get customConstraints => const [
        'CHECK (removed_at IS NULL OR removed_at >= added_at)',
      ];
}

class Devices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get name => text()();
  TextColumn get category => text().nullable()();
  TextColumn get manufacturer => text().nullable()();
  TextColumn get model => text().nullable()();
  TextColumn get serialNumber => text().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get requiredBatteryTypeId => integer()
      .nullable()
      .references(BatteryTypes, #id, onDelete: KeyAction.restrict)();
  IntColumn get requiredBatteryQuantity => integer().nullable()();
  RealColumn get requiredVoltage => real().nullable()();
  TextColumn get requirementNotes => text().nullable()();
  TextColumn get iconSource => text().withDefault(const Constant('builtin'))();
  TextColumn get iconKey =>
      text().withDefault(const Constant('device_generic'))();
  TextColumn get iconColor => text().withDefault(const Constant('#607D8B'))();
  TextColumn get preferredPrimaryVisual =>
      text().withDefault(const Constant('icon'))();
  TextColumn get createdAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get modifiedAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get deactivatedAt =>
      text().map(const UtcDateTimeTextConverter()).nullable()();
  TextColumn get deletedAt =>
      text().map(const UtcDateTimeTextConverter()).nullable()();

  @override
  List<String> get customConstraints => const [
        'CHECK (length(trim(name)) > 0)',
        'CHECK (required_battery_quantity IS NULL OR '
            'required_battery_quantity > 0)',
        'CHECK (required_voltage IS NULL OR required_voltage >= 0)',
        "CHECK (icon_source IN ('builtin', 'custom'))",
        "CHECK (preferred_primary_visual IN ('icon', 'photo'))",
      ];
}

class Assignments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get subjectType => text()();
  IntColumn get batteryId => integer()
      .nullable()
      .references(Batteries, #id, onDelete: KeyAction.restrict)();
  IntColumn get batterySetId => integer()
      .nullable()
      .references(BatterySets, #id, onDelete: KeyAction.restrict)();
  IntColumn get deviceId =>
      integer().references(Devices, #id, onDelete: KeyAction.restrict)();
  IntColumn get sourceSetAssignmentId => integer()
      .nullable()
      .references(Assignments, #id, onDelete: KeyAction.restrict)();
  TextColumn get operationUuid => text()();
  TextColumn get assignedAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get removedAt =>
      text().map(const UtcDateTimeTextConverter()).nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get overrideReason => text().nullable()();

  @override
  List<String> get customConstraints => const [
        "CHECK (subject_type IN ('battery', 'battery_set'))",
        "CHECK ((subject_type = 'battery' AND battery_id IS NOT NULL AND "
            "battery_set_id IS NULL) OR (subject_type = 'battery_set' AND "
            'battery_id IS NULL AND battery_set_id IS NOT NULL))',
        'CHECK (removed_at IS NULL OR removed_at >= assigned_at)',
      ];
}

class SetChargeRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  IntColumn get batterySetId =>
      integer().references(BatterySets, #id, onDelete: KeyAction.restrict)();
  TextColumn get chargedAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get notes => text().nullable()();
  TextColumn get createdAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get operationUuid => text()();
}

class ChargeRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  IntColumn get batteryId =>
      integer().references(Batteries, #id, onDelete: KeyAction.restrict)();
  TextColumn get chargedAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  IntColumn get startingChargePercent => integer().nullable()();
  IntColumn get endingChargePercent => integer().nullable()();
  TextColumn get charger => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get sourceSetChargeId => integer()
      .nullable()
      .references(SetChargeRecords, #id, onDelete: KeyAction.restrict)();
  TextColumn get bulkOperationUuid => text().nullable()();
  TextColumn get createdAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();

  @override
  List<String> get customConstraints => const [
        'CHECK (starting_charge_percent IS NULL OR '
            '(starting_charge_percent BETWEEN 0 AND 100))',
        'CHECK (ending_charge_percent IS NULL OR '
            '(ending_charge_percent BETWEEN 0 AND 100))',
      ];
}

class MediaAssets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get relativePath => text().unique()();
  TextColumn get originalFilename => text()();
  TextColumn get mimeType => text()();
  IntColumn get byteSize => integer()();
  TextColumn get checksum => text()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  TextColumn get createdAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get modifiedAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get missingAt =>
      text().map(const UtcDateTimeTextConverter()).nullable()();

  @override
  List<String> get customConstraints => const [
        'CHECK (length(trim(relative_path)) > 0)',
        'CHECK (byte_size >= 0)',
        'CHECK (width IS NULL OR width > 0)',
        'CHECK (height IS NULL OR height > 0)',
      ];
}

class BatteryPhotos extends Table {
  IntColumn get batteryId =>
      integer().references(Batteries, #id, onDelete: KeyAction.restrict)();
  IntColumn get mediaAssetId =>
      integer().references(MediaAssets, #id, onDelete: KeyAction.restrict)();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  IntColumn get displayOrder => integer().withDefault(const Constant(0))();
  TextColumn get caption => text().nullable()();
  TextColumn get createdAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get modifiedAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();

  @override
  Set<Column<Object>> get primaryKey => {batteryId, mediaAssetId};
}

class BatterySetPhotos extends Table {
  IntColumn get batterySetId =>
      integer().references(BatterySets, #id, onDelete: KeyAction.restrict)();
  IntColumn get mediaAssetId =>
      integer().references(MediaAssets, #id, onDelete: KeyAction.restrict)();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  IntColumn get displayOrder => integer().withDefault(const Constant(0))();
  TextColumn get caption => text().nullable()();
  TextColumn get createdAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get modifiedAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();

  @override
  Set<Column<Object>> get primaryKey => {batterySetId, mediaAssetId};
}

class DevicePhotos extends Table {
  IntColumn get deviceId =>
      integer().references(Devices, #id, onDelete: KeyAction.restrict)();
  IntColumn get mediaAssetId =>
      integer().references(MediaAssets, #id, onDelete: KeyAction.restrict)();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  IntColumn get displayOrder => integer().withDefault(const Constant(0))();
  TextColumn get caption => text().nullable()();
  TextColumn get createdAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get modifiedAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();

  @override
  Set<Column<Object>> get primaryKey => {deviceId, mediaAssetId};
}

class IconCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get name => text()();
  TextColumn get scope => text()();
  TextColumn get createdAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get modifiedAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get deactivatedAt =>
      text().map(const UtcDateTimeTextConverter()).nullable()();

  @override
  List<String> get customConstraints => const [
        'CHECK (length(trim(name)) > 0)',
        "CHECK (scope IN ('battery', 'battery_set', 'device', 'general'))",
      ];
}

class CustomIcons extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get name => text()();
  IntColumn get categoryId => integer()
      .nullable()
      .references(IconCategories, #id, onDelete: KeyAction.restrict)();
  TextColumn get relativePath => text().unique()();
  TextColumn get fileType => text()();
  BoolColumn get supportsColor =>
      boolean().withDefault(const Constant(false))();
  TextColumn get createdAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get modifiedAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get deactivatedAt =>
      text().map(const UtcDateTimeTextConverter()).nullable()();

  @override
  List<String> get customConstraints => const [
        'CHECK (length(trim(name)) > 0)',
        "CHECK (file_type IN ('png', 'svg'))",
      ];
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get name => text()();
  TextColumn get createdAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get modifiedAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();

  @override
  List<String> get customConstraints => const [
        'CHECK (length(trim(name)) > 0)',
      ];
}

class BatteryTags extends Table {
  IntColumn get batteryId =>
      integer().references(Batteries, #id, onDelete: KeyAction.restrict)();
  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.restrict)();
  TextColumn get createdAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();

  @override
  Set<Column<Object>> get primaryKey => {batteryId, tagId};
}

class QrLabelTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get name => text()();
  TextColumn get targetType => text()();
  RealColumn get widthPoints => real()();
  RealColumn get heightPoints => real()();
  TextColumn get layoutJson => text()();
  TextColumn get createdAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get modifiedAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();
  TextColumn get deactivatedAt =>
      text().map(const UtcDateTimeTextConverter()).nullable()();

  @override
  List<String> get customConstraints => const [
        'CHECK (length(trim(name)) > 0)',
        "CHECK (target_type IN ('battery', 'battery_set', 'device'))",
        'CHECK (width_points > 0)',
        'CHECK (height_points > 0)',
      ];
}

class ActivityLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get eventType => text()();
  TextColumn get entityType => text()();
  TextColumn get entityUuid => text()();
  TextColumn get relatedEntityType => text().nullable()();
  TextColumn get relatedEntityUuid => text().nullable()();
  TextColumn get operationUuid => text().nullable()();
  TextColumn get summary => text()();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
  TextColumn get occurredAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();

  @override
  List<String> get customConstraints => const [
        'CHECK (length(trim(event_type)) > 0)',
        'CHECK (length(trim(entity_type)) > 0)',
        'CHECK (length(trim(summary)) > 0)',
      ];
}

class Settings extends Table {
  TextColumn get key => text().named('setting_key')();
  TextColumn get value => text()();
  TextColumn get valueType => text()();
  TextColumn get modifiedAt =>
      text().map(const UtcDateTimeTextConverter()).clientDefault(_utcNow)();

  @override
  Set<Column<Object>> get primaryKey => {key};

  @override
  List<String> get customConstraints => const [
        'CHECK (length(trim(setting_key)) > 0)',
        "CHECK (value_type IN ('string', 'integer', 'real', 'boolean', 'json'))",
      ];
}
