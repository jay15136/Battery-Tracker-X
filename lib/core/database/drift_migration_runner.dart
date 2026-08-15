import 'package:drift/drift.dart';

import 'migration_registry.dart';

abstract final class DriftMigrationRunner {
  static final registry = MigrationRegistry(const [
    DatabaseMigration(version: 1, name: 'initial_schema'),
  ]);

  static const _versionOneIndexes = [
    'CREATE UNIQUE INDEX battery_types_active_name_uq '
        'ON battery_types(lower(type_name)) WHERE deactivated_at IS NULL',
    'CREATE UNIQUE INDEX battery_batches_code_uq '
        'ON battery_batches(lower(batch_code))',
    'CREATE UNIQUE INDEX batteries_active_user_id_uq '
        'ON batteries(lower(user_battery_id)) WHERE deleted_at IS NULL',
    'CREATE INDEX batteries_type_idx ON batteries(battery_type_id)',
    'CREATE INDEX batteries_batch_idx ON batteries(batch_id)',
    'CREATE INDEX batteries_status_idx ON batteries(status)',
    'CREATE INDEX batteries_condition_idx ON batteries(condition)',
    'CREATE INDEX batteries_manufacturer_idx ON batteries(manufacturer)',
    'CREATE INDEX batteries_model_idx ON batteries(model)',
    'CREATE INDEX batteries_serial_idx ON batteries(serial_number)',
    'CREATE UNIQUE INDEX battery_sets_active_user_id_uq '
        'ON battery_sets(lower(user_set_id)) WHERE deleted_at IS NULL',
    'CREATE INDEX memberships_battery_active_idx '
        'ON battery_set_memberships(battery_id, removed_at)',
    'CREATE INDEX memberships_set_active_idx '
        'ON battery_set_memberships(battery_set_id, removed_at)',
    'CREATE INDEX memberships_operation_idx '
        'ON battery_set_memberships(operation_uuid)',
    'CREATE INDEX devices_name_idx ON devices(name)',
    'CREATE INDEX devices_category_idx ON devices(category)',
    'CREATE INDEX assignments_device_active_idx '
        'ON assignments(device_id, removed_at)',
    'CREATE INDEX assignments_battery_active_idx '
        'ON assignments(battery_id, removed_at)',
    'CREATE INDEX assignments_set_active_idx '
        'ON assignments(battery_set_id, removed_at)',
    'CREATE INDEX assignments_source_set_idx '
        'ON assignments(source_set_assignment_id)',
    'CREATE INDEX assignments_operation_idx ON assignments(operation_uuid)',
    'CREATE INDEX charge_records_battery_time_idx '
        'ON charge_records(battery_id, charged_at)',
    'CREATE INDEX charge_records_set_charge_idx '
        'ON charge_records(source_set_charge_id)',
    'CREATE INDEX charge_records_bulk_operation_idx '
        'ON charge_records(bulk_operation_uuid)',
    'CREATE UNIQUE INDEX battery_photos_primary_uq '
        'ON battery_photos(battery_id) WHERE is_primary = 1',
    'CREATE INDEX battery_photos_order_idx '
        'ON battery_photos(battery_id, display_order)',
    'CREATE UNIQUE INDEX battery_set_photos_primary_uq '
        'ON battery_set_photos(battery_set_id) WHERE is_primary = 1',
    'CREATE INDEX battery_set_photos_order_idx '
        'ON battery_set_photos(battery_set_id, display_order)',
    'CREATE UNIQUE INDEX device_photos_primary_uq '
        'ON device_photos(device_id) WHERE is_primary = 1',
    'CREATE INDEX device_photos_order_idx '
        'ON device_photos(device_id, display_order)',
    'CREATE UNIQUE INDEX icon_categories_active_name_uq '
        'ON icon_categories(scope, lower(name)) WHERE deactivated_at IS NULL',
    'CREATE INDEX custom_icons_category_active_idx '
        'ON custom_icons(category_id, deactivated_at)',
    'CREATE UNIQUE INDEX tags_name_uq ON tags(lower(name))',
    'CREATE UNIQUE INDEX qr_templates_active_name_uq '
        'ON qr_label_templates(lower(name)) WHERE deactivated_at IS NULL',
    'CREATE INDEX activity_time_idx ON activity_log(occurred_at)',
    'CREATE INDEX activity_event_idx ON activity_log(event_type)',
    'CREATE INDEX activity_entity_idx ON activity_log(entity_uuid)',
    'CREATE INDEX activity_related_idx ON activity_log(related_entity_uuid)',
    'CREATE INDEX activity_operation_idx ON activity_log(operation_uuid)',
  ];

  static Future<void> createVersionOne(
    GeneratedDatabase database,
    Migrator migrator,
  ) async {
    await migrator.createAll();
    for (final statement in _versionOneIndexes) {
      await database.customStatement(statement);
    }
  }

  static Future<void> upgrade(
    GeneratedDatabase database,
    Migrator migrator,
    int from,
    int to,
  ) async {
    if (from < 0 || to > registry.currentVersion || from >= to) {
      throw StateError('Unsupported database migration from $from to $to.');
    }

    for (var version = from + 1; version <= to; version++) {
      switch (version) {
        case 1:
          await createVersionOne(database, migrator);
      }
    }
  }
}
