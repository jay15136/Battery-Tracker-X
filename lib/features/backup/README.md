# Backup

Single-archive backup, validation, and restore for the whole local
application state. No migration or schema change is needed; `archive`
(ZIP) is the one new dependency, matching the Phase 1 architecture decision.

## What a backup contains

A backup is one ZIP archive:

- `manifest.json` — format version, app version, schema version, creation
  time, and a per-file logical path/size/SHA-256 entry for every other file
  in the archive.
- `database/battery_tracker.sqlite` — a consistent snapshot taken with
  SQLite's `VACUUM INTO`, so it is safe to copy even while the application
  has the live database open.
- `photos/*` and `custom_icons/*` — every application-managed photograph
  and custom icon file, walked recursively.

QR label templates, application settings, icon selections, and icon colors
already live inside the SQLite database and travel with it automatically.
Built-in icons ship with the application and are never copied.

## Validation

`validateBackup` never changes application data. It decodes the archive,
rejects any entry with an absolute path, a drive letter, or a `..`
traversal segment, requires `manifest.json`, checks every manifest entry's
size and SHA-256 against the archive's actual bytes, and opens the
embedded database from a throwaway temporary copy to confirm it is a
readable SQLite file before reporting the backup valid.

## Restore

`restoreBackup` validates first, then: extracts the archive's contents to a
staging directory, closes the live database connection, moves the current
`database/`, `photos/`, and `custom_icons/` into a timestamped recovery
folder under `backups/`, copies the staged contents into their live
locations, and opens a fresh database connection to run migrations and a
basic integrity query. The recovery folder is deleted only after that
verification succeeds. Any failure after validation restores the recovery
copy automatically and raises `BackupRestoreException`; a failure during
validation never touches the live database or files at all.

Because closing and reopening the database means every previously
constructed repository object in the running application now points at a
stale connection, `restoreBackup` documents that the caller must rebuild
the whole dependency graph afterward rather than continue using this
repository instance. `AppLifecycle.reload()` (`lib/app/battery_tracker_root.dart`)
does exactly that in place, without restarting the process: it reruns
`AppBootstrap.start()` and swaps every provider override, so a restored
backup is usable immediately.

## Testing

`LocalBackupRepository` tests use real temporary directories and real
file-backed SQLite (required for `VACUUM INTO`) to cover: a full
create/validate round trip, a backup with no photos or custom icons yet, a
missing file, a non-archive file, a missing `manifest.json`, a tampered
checksum, a path-traversal entry name, a full restore that replaces the
database while preserving unrelated photographs, and a failed restore that
leaves the live database completely untouched. `DataManagementPage` widget
tests cover backup creation, a canceled restore confirmation, and a
confirmed restore that triggers `AppLifecycle.reload()`.
