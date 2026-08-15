import 'package:drift/drift.dart';

import 'drift_migration_runner.dart';
import 'schema/app_tables.dart';
import 'schema/utc_date_time_text_converter.dart';

part 'app_database.g.dart';

String _utcNow() => DateTime.now().toUtc().toIso8601String();

@DriftDatabase(
  tables: [
    BatteryTypes,
    BatteryBatches,
    Batteries,
    BatterySets,
    BatterySetMemberships,
    Devices,
    Assignments,
    SetChargeRecords,
    ChargeRecords,
    MediaAssets,
    BatteryPhotos,
    BatterySetPhotos,
    DevicePhotos,
    IconCategories,
    CustomIcons,
    Tags,
    BatteryTags,
    QrLabelTemplates,
    ActivityLog,
    Settings,
  ],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => DriftMigrationRunner.registry.currentVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) =>
            DriftMigrationRunner.createVersionOne(this, migrator),
        onUpgrade: (migrator, from, to) =>
            DriftMigrationRunner.upgrade(this, migrator, from, to),
        beforeOpen: (_) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
