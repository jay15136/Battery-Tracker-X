# Phase 3 Icon System Design

## Purpose

Phase 3 establishes the icon-first visual system used by Batteries, Battery
Sets, Devices, Battery Types, QR labels, bulk operations, and later photo
fallback behavior. It must work entirely offline and must never leave a record
without a usable visual.

## Invariants

- Built-in icons are packaged application assets and cannot be deleted.
- Battery, Battery Set, Device, and Custom Icon permanent UUIDs never change
  during ordinary edits.
- Custom icon database references use permanent UUIDs, never row IDs or source
  computer paths.
- Imported files live below `custom_icons/{uuid}/` in application-managed
  storage and SQLite stores only validated relative paths.
- Missing, inactive, or deprecated icons resolve to the correct scope default.
- Color is stored as uppercase `#RRGGBB`; text identifiers remain visible.
- Custom-icon import and reference replacement use transactions plus file
  compensation so failures cannot leave broken database references.
- Photographs remain optional and are outside this phase.

## Packaged catalog

Ship every icon named in sections 13 and 14 of the master prompt as an SVG
asset. Each definition has a stable key, display name, scope, category,
search terms, asset path, default color, and recoloring capability. Required
defaults are `battery_generic`, `battery_set_generic`, and `device_generic`.

The catalog is a pure-Dart `BuiltInIconRegistry`. Search is case-insensitive
over display name, key, category, and keywords. Scope filters include General
icons where appropriate. Definitions may be marked deprecated with a
replacement key; resolution follows a bounded replacement chain and otherwise
uses the scope default.

## Domain model and service boundaries

`IconColor` validates and normalizes portable hexadecimal colors.
`IconSelection` stores source, key, and color. `IconDefinition` describes
built-in or custom choices without importing Flutter widgets.

`IconRepository` owns SQLite metadata, categories, recent-use settings, usage
counts, record selection updates, and reference replacement. Its Drift adapter
uses the existing `custom_icons`, `icon_categories`, inventory, settings, and
activity-log tables.

`CustomIconStorage` validates and copies PNG/SVG sources. The local adapter
uses the application-support root; the domain never receives an absolute
stored path. PNG validation checks file size and signature. SVG validation
checks UTF-8 content, an SVG root, and rejects scripts, event handlers,
external references, entities, and doctypes.

`IconLibraryService` coordinates storage and repository operations:

1. validate source;
2. create a permanent UUID and managed copy;
3. insert metadata;
4. remove the new copy if the database write fails.

Source replacement writes a new managed file before changing the row, removes
the new file on database failure, and removes the superseded file only after a
successful update. Deletion first performs transactional reference replacement
and deactivation, then removes the old managed file. A cleanup failure is
logged but cannot create a broken reference.

## Custom icon behavior

Custom icon categories support the four standard scopes plus user-created
names. Icons support import, preview, rename, category change, source-image
replacement, duplication, and deletion.

Usage counts include Batteries, Battery Sets, Devices, and Battery Type
suggestions. An in-use icon cannot be deleted without either a replacement icon
or explicit replacement with each owner's default. All affected rows and the
activity event change inside one transaction. Built-in definitions never expose
a delete operation.

If a custom icon row or file is unavailable, `IconRegistry.resolve` returns the
owner-scope default and a fallback reason. Rendering also supplies an error
builder that draws the default asset if decoding fails.

## Selection, color, and recent use

The reusable chooser provides:

- searchable icon grid;
- scope and category filters;
- Built-In, Custom, and Recent sources;
- selected preview and text name;
- Default, Black, Gray, White, Red, Orange, Yellow, Green, Blue, Purple, and
  Brown presets;
- custom `#RRGGBB` input;
- Reset Icon Color and Reset to Default;
- Import Custom Icon.

Confirmed record selections are persisted through `IconRepository` and update
a bounded per-scope recent list in the settings table. The database update,
recent-list update, and activity event share one transaction.

## Presentation

Settings gains an Icon Library entry. The library uses a restrained industrial
catalog aesthetic consistent with the existing teal Material 3 shell: a compact
scope rail, searchable grid, strong icon preview, category labels, and clear
custom-management actions. It remains keyboard and mouse friendly and adapts to
narrow widths.

`IconVisual` renders packaged SVGs or managed PNG/SVG files and always owns a
default fallback. `IconPickerDialog` is feature-neutral so Battery Types,
Batteries, Sets, Devices, bulk creation, and label design can reuse it later.

## Dependencies

- `flutter_svg: ^2.3.0` renders packaged and managed SVG files on every target.
- `file_selector: ^1.1.0` supplies federated native open dialogs on Windows,
  Android, iOS, macOS, Linux, and web while the project interface remains the
  application boundary.

No network, cloud, account, or Windows-only production dependency is added.

## Verification

Use strict red-green-refactor cycles for values, registry resolution, Drift
operations, file validation/compensation, and UI behavior. Final acceptance
requires formatting, clean analysis, the full Flutter test suite, generated
artifact consistency, a Windows Release build, two launch checks, and a diff
audit. Tests must cover all three owner scopes, restart persistence, different
colors on the same icon, color reset, PNG/SVG import, missing-file fallback,
in-use deletion refusal, transactional replacement, unused deletion, and
Light/Dark rendering.
