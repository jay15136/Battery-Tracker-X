import 'app_database.dart';
import 'database_service.dart';
import 'drift_migration_runner.dart';
import 'migration_registry.dart';

final class DriftDatabaseTransaction implements DatabaseTransaction {
  const DriftDatabaseTransaction(this.database);

  final AppDatabase database;
}

final class DriftDatabaseService implements DatabaseService {
  DriftDatabaseService(this.database);

  final AppDatabase database;

  @override
  MigrationRegistry get migrations => DriftMigrationRunner.registry;

  @override
  Future<void> initialize() async {
    await database.customSelect('SELECT 1').getSingle();
    final result =
        await database.customSelect('PRAGMA foreign_keys').getSingle();
    if (result.read<int>('foreign_keys') != 1) {
      throw StateError('SQLite foreign-key enforcement is not enabled.');
    }
  }

  @override
  Future<T> transaction<T>(TransactionWork<T> work) {
    return database.transaction(
      () => work(DriftDatabaseTransaction(database)),
    );
  }

  @override
  Future<void> close() => database.close();
}
