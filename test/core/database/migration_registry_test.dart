import 'package:battery_tracker/core/database/migration_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MigrationRegistry', () {
    test('reports zero for an empty database migration history', () {
      final registry = MigrationRegistry(const []);

      expect(registry.currentVersion, 0);
      expect(registry.migrations, isEmpty);
    });

    test('accepts migrations beginning at one with no version gaps', () {
      final registry = MigrationRegistry(const [
        DatabaseMigration(version: 1, name: 'initial_schema'),
        DatabaseMigration(version: 2, name: 'add_example_column'),
      ]);

      expect(registry.currentVersion, 2);
      expect(registry.migrations.map((migration) => migration.version), [1, 2]);
    });

    test('rejects a migration sequence with a skipped version', () {
      expect(
        () => MigrationRegistry(const [
          DatabaseMigration(version: 1, name: 'initial_schema'),
          DatabaseMigration(version: 3, name: 'skipped_version_two'),
        ]),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects non-positive migration versions', () {
      expect(
        () => MigrationRegistry(const [
          DatabaseMigration(version: 0, name: 'invalid'),
        ]),
        throwsA(isA<StateError>()),
      );
    });
  });
}
