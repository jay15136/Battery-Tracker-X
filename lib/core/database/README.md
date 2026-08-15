# Database

Phase 1 establishes:

- Drift/SQLite as the persistence stack
- contiguous migration metadata through `MigrationRegistry`
- a shared atomic-operation boundary through `DatabaseService`

Phase 2 adds the Drift database, schema version 1 migration, foreign-key initialization, background production connection, and in-memory test connection. See `docs/DATABASE_PLAN.md` before editing schema code.
