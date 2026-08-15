import 'migration_registry.dart';

/// An opaque transaction handle implemented by the selected database adapter.
abstract interface class DatabaseTransaction {}

typedef TransactionWork<T> = Future<T> Function(
  DatabaseTransaction transaction,
);

/// Cross-platform database lifecycle and atomic-operation boundary.
abstract interface class DatabaseService {
  MigrationRegistry get migrations;

  Future<void> initialize();

  Future<T> transaction<T>(TransactionWork<T> work);

  Future<void> close();
}
