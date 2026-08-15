# Database

Phase 1 established:

- Drift/SQLite as the persistence stack
- contiguous migration metadata through `MigrationRegistry`
- a shared atomic-operation boundary through `DatabaseService`

Phase 2 implements the 20-table Drift database, executable schema version 1 migration and indexes, foreign-key initialization, background production connection, injected test executors, transaction adapter, and `drift_schemas/schema_v1.json` snapshot. See `docs/DATABASE_PLAN.md` before editing schema code.
