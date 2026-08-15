# Icons Feature

The Phase 3 icon system implements Battery Tracker's icon-first identity invariant.

## Layers

- `domain/` contains immutable colors, definitions, selections, storage/repository contracts, and the centralized registry.
- `data/` contains the 54-definition packaged catalog, Drift repository, and application-managed PNG/SVG storage adapter.
- `application/` contains the transaction-aware lifecycle service and Riverpod catalog controller.
- `presentation/` contains the fallback renderer, color picker, reusable chooser, custom editor, and Settings library.

Built-ins persist logical keys. Custom icons persist permanent UUIDs plus safe managed relative paths; original absolute paths never enter SQLite. Owner rows always retain a valid source/key/color selection, and resolution/rendering falls back to the owner-specific packaged default.

Custom import validates PNG signatures and SVG structure/content before copying. Database failures remove only newly staged files. Source replacement preserves UUID identity. Duplication creates a new UUID. Deletion checks references and requires an explicit replacement/default strategy when in use; all database reference changes are transactional.

Use `IconPickerDialog` wherever a feature needs an icon/color selection. Do not duplicate registry, fallback, color, or file-selection logic inside Battery, Battery Set, Device, or Battery Type widgets.
