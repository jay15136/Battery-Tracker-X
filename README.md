# Battery Tracker X

Battery Tracker is an **offline-first Windows desktop app** for tracking rechargeable batteries, the Battery Sets they're organized into, and the Devices they power — with no account, no server, and no internet connection required. Everything lives in a local SQLite database.

Built with Flutter/Dart (Material 3, Riverpod, Drift/SQLite), targeting Windows 11 first with an architecture kept portable to Android, iPhone/iPad, and macOS.

## What it does

- **Battery inventory** — permanent Batteries with specifications, purchase info, status/condition, optional photographs, and an icon-first visual system (54 built-in icons plus imported custom PNG/SVG icons)
- **Battery Sets** — batteries kept, charged, or used together, with membership history and compatibility warnings
- **Devices** — equipment that uses individual Batteries or Sets, with battery requirements and current-assignment tracking
- **Assignments & Charge Tracking** — Battery/Set ↔ Device assignments and Recorded Charges, both fully historied
- **Bulk operations** — create dozens of Batteries at once with sequential IDs, or bulk edit/retire/charge a selection
- **QR labels** — UUID-based labels with a visual designer, templates, sheet printing, and PDF export
- **Dashboard & History** — live inventory counts, attention reminders, and a unified, filterable activity log
- **Backup/Restore & CSV import/export** — one-archive backup with checksum validation and automatic rollback, plus preview-before-commit CSV import

All 17 development phases are complete — this is a working Version 1, not a prototype.

## Portable deployment

On Windows, Battery Tracker runs as a **fully portable, self-contained folder** — no installer. It stores its database, photographs, custom icons, and logs in a `My Battery Data` folder created next to the executable, resolved from wherever the exe is actually running (so it works correctly from any drive letter, including a USB drive moved between PCs).

A ready-to-run build is included in this repo: **[`Battery Tracker X.zip`](./Battery%20Tracker%20X.zip)**. Extract it anywhere and run `battery_tracker.exe`.

## Repository contents

- `lib/` — application source, organized feature-first (`lib/features/<feature>/{domain,data,application,presentation}`)
- `test/` — unit, repository, migration, and widget tests (380+)
- `docs/IMPLEMENTATION_PLAN.md` — the authoritative, phase-by-phase build log: what was implemented, how it was verified, every architecture decision and the reasoning behind it, and every defect found (with its fix)
- `docs/ARCHITECTURE.md` / `docs/DATABASE_PLAN.md` — system design and schema
- `Battery_Tracker_Master_Codex_Prompt.md` — the original product/requirements specification this app was built against
- `Battery Tracker X.zip` — the prebuilt portable Windows package described above
- `OLD-README.md` — the original, more granular development README (build/run instructions, phase-by-phase feature notes, dependency rationale); kept for reference

## Building from source

```powershell
flutter pub get
flutter build windows --release
```

See `OLD-README.md` for full prerequisites, code-generation steps, and testing commands, and `docs/IMPLEMENTATION_PLAN.md` for the exact, currently-passing verification commands.

## Status

Version `0.1.0`. Local, offline, single-machine data by design — see `docs/IMPLEMENTATION_PLAN.md` for known limitations and environment notes.
