# agent.md — Compatibility Copy

> Important: Codex automatically discovers `AGENTS.md` by default. This `agent.md`
> file is included because it was explicitly requested. Keep `AGENTS.md` as the
> authoritative repository instruction file unless Codex is separately configured
> to treat `agent.md` as a fallback filename.

# Battery Tracker Agent Instructions

## Mission

Build and maintain **Battery Tracker** as a real, tested Windows 11 application using Flutter, Dart, and SQLite, while preserving a clean path to Android, iPhone/iPad, and macOS.

Before substantial work, read:

1. `Battery_Tracker_Master_Codex_Prompt.md`
2. `CODEX_INSTRUCTIONS.md`
3. Relevant source files and tests
4. `docs/IMPLEMENTATION_PLAN.md` if it exists

The master prompt defines product requirements. This file defines how to work in this repository.

## Source of truth

Use this order:

1. Newest explicit user instruction
2. `Battery_Tracker_Master_Codex_Prompt.md`
3. This `AGENTS.md`
4. `CODEX_INSTRUCTIONS.md`
5. Existing docs/code when they do not conflict

Do not silently drop or defer a required Version 1 feature.

## Core product invariant

**Icons identify inventory. Photographs add detail.**

Battery Tracker is **icon-first, photo-optional**.

- Battery, Battery Set, and Device records always have a usable icon.
- Photograph capture/upload is optional.
- Icon is the default primary visual.
- Adding a photo does not automatically make it primary.
- Keep the icon as a fallback even when photos exist.
- Missing photo files must fall back to the icon.

## Version 1 required features

Treat these as required, not roadmap items:

- Battery Types
- Individual Battery inventory
- Battery Sets and membership history
- Devices
- Battery/Set-to-Device assignments and history
- Charge tracking and Recorded Charges
- Built-in generic icon library
- Icon colors
- User-imported PNG/SVG custom icons
- Optional photographs
- Bulk Battery Creation
- Automatic sequential Battery IDs
- Optional Batch IDs
- Bulk Edit
- Bulk charge actions
- UUID-based QR codes
- QR label designer
- Label templates
- Label sheet printing
- PDF label export
- QR lookup
- Dashboard
- Unified history/activity log
- CSV import/export
- Complete backup and restore
- Light/Dark/System appearance

## Technology

Preferred stack:

- Flutter
- Dart
- SQLite
- Local application-managed file storage
- Repository/data-access layer
- Cross-platform service abstractions

Do not add cloud, accounts, web servers, or required internet access for Version 1.

## Architecture

Keep responsibilities separated.

Do not place substantial business logic in UI widgets.

Prefer clear feature modules plus services/repositories.

Isolate platform-sensitive capabilities behind interfaces/services, especially:

- database
- image storage
- camera/webcam
- printing
- QR generation/decoding
- backup/restore
- import/export

Do not embed Windows-only assumptions into domain models.

## Data identity

Permanent UUIDs are authoritative for:

- Batteries
- Battery Sets
- Devices
- Custom Icons

Editable user-facing IDs such as `AA-001` are labels, not primary identity.

Never regenerate a permanent UUID during ordinary edits.

QR codes must use permanent UUIDs, not editable display IDs.

## Database rules

- Use SQLite migrations/versioning.
- Enable and respect foreign keys.
- Add indexes for common lookups.
- Use parameterized queries.
- Use transactions for multi-record operations.
- Preserve history instead of overwriting it.
- Use soft deletion/deactivation where it preserves meaning.

Do not fake persistence.

## Transaction-required operations

Use all-or-nothing transactions where appropriate, including:

- bulk battery creation
- bulk creation plus Set membership
- assigning/removing an entire Set
- Mark Entire Set Charged
- Mark Selected Charged
- multi-record history updates

Do not leave partial state after a failed operation.

## Batch versus Set

Keep these separate:

- **Batch:** batteries purchased or entered together.
- **Battery Set:** batteries intentionally kept, charged, or used together.

A battery can belong to both.

## Icon system

Implement and maintain a centralized IconService/IconRegistry.

Support:

- built-in icons
- custom icons
- categories
- search
- defaults
- icon colors
- custom PNG/SVG imports
- safe replacement/deletion
- missing/deprecated icon fallback

Built-in icons are application assets.

Custom icons are copied to application-managed storage and referenced by logical ID/UUID, not original absolute path.

## Photos

Photos are optional and stored in application-managed storage.

Do not store photo bytes in SQLite unless there is a documented compelling reason.

Store logical/relative references.

Never show a broken primary image when an icon fallback exists.

## Assignments and history

Never destroy historical meaning by overwriting assignment rows.

Track:

- assigned date
- removed date
- Battery
- Battery Set when applicable
- Device
- notes

Set membership history must likewise record addition/removal dates.

## Charging

Use the term **Recorded Charges**.

Do not represent the count as a true electrochemical cycle count.

Marking an entire Set charged must create individual charge records for current members in one transaction.

## QR codes

Use stable logical URIs such as:

- `batterytracker://battery/{UUID}`
- `batterytracker://set/{UUID}`
- `batterytracker://device/{UUID}`

Changing a user-facing Battery ID must not break an existing QR label.

## Bulk creation

Bulk creation must support:

- prefix
- separator
- starting number
- padding
- quantity
- duplicate detection
- next-available IDs
- preview before save
- per-row edits
- shared fields
- icon/color
- optional Batch
- optional Set creation/membership
- transactional save

Do not silently alter generated IDs after preview.

## Backup and restore

Backups must preserve the usable application state, including:

- SQLite database
- photographs
- custom icon files
- custom icon metadata
- label templates
- settings
- icon selections/colors

Validate backups before restore.

Require confirmation before overwriting current data.

After restore, verify core database access and asset resolution.

## UI expectations

The application should feel like a finished inventory tool.

- Modern Windows desktop layout
- Left navigation
- Resizable
- Keyboard/mouse friendly
- Light/Dark/System themes
- Clear empty states
- Clear validation
- Clear destructive confirmations
- No raw stack traces in user dialogs
- No broken-image boxes
- No production debug controls

Do not hard-code dashboard statistics.

## Error handling

Show concise user-facing errors and log technical details.

Never expose raw stack traces to normal users.

## Dependencies

Before adding a production dependency:

- verify Windows suitability
- consider future Android/iOS/macOS support
- prefer maintained packages
- avoid unnecessary overlap
- avoid cloud-required packages
- document important choices

Do not add a dependency just to avoid writing a small amount of clear code.

## Testing

A feature is not complete merely because it compiles.

After relevant changes, run the appropriate subset of:

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build windows
```

For dependency changes also run:

```powershell
flutter pub get
```

Add targeted tests for business rules and regressions.

If an environmental blocker prevents a command, report the exact blocker. Do not claim a command passed if it was not run.

## High-risk regression areas

Pay special attention to:

- migrations
- UUID stability
- Set membership history
- assignment history
- bulk transactions
- icon references
- photo fallback
- QR resolution
- backup/restore
- CSV import
- label rendering

## Development workflow

For each meaningful task:

1. Read relevant requirements and code.
2. Inspect tests.
3. Plan the smallest coherent change.
4. Implement.
5. Format.
6. Analyze.
7. Run targeted tests.
8. Run broader tests when appropriate.
9. Review the diff.
10. Update docs/plan if behavior or architecture changed.

Do not rewrite unrelated working code.

## Complex work

For complex features or significant refactors, create or update the living execution plan at:

`docs/IMPLEMENTATION_PLAN.md`

Keep it current with:

- decisions
- milestones
- progress
- discoveries
- test status
- remaining work

Do not stop at the planning stage.

## Documentation

Keep `README.md` current.

Document setup, run/build/test commands, storage locations, database/migration behavior, backup behavior, and important architecture decisions.

## Git hygiene

Do not commit:

- local SQLite user databases
- user photographs
- imported personal icons
- secrets
- build outputs
- machine-specific absolute paths

Maintain `.gitignore`.

Keep changes reviewable and logically scoped.

## Definition of done

Before claiming a feature is complete:

- required behavior exists
- persistence is real
- validation is present
- history is preserved where required
- errors are handled
- targeted tests pass
- analysis is acceptable
- changed setup/behavior is documented

No placeholders for required Version 1 features.

## Final working rule

**Read → Plan → Implement → Build → Test → Fix → Document → Continue**

The deliverable is a working application, not snippets or scaffolding.
