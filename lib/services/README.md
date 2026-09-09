# Services

Use this area for cross-cutting service interfaces and implementations. Phase 1 service contracts are platform-neutral and must not expose plugin classes to domain models.

Expected services include:

- DatabaseService
- IconService / IconRegistry
- ImageService
- CameraService
- BatterySetService
- AssignmentService
- ChargeService
- QrCodeService
- LabelService
- PrintService
- BackupService
- ImportService
- ExportService

Platform-specific behavior is isolated behind these interfaces rather than embedded in domain models or UI widgets. Feature phases may add typed request/response values, but Windows adapters must remain replaceable by Android/iOS/macOS adapters.

Phase 3 adds `FileSelectorFileSelectionService`, the production native-dialog adapter for `FileSelectionService`. It maps project-owned extension filters to the plugin at the boundary and returns file URIs only; icon domain/application code does not import `file_selector` types.

## Application data directory

Two `AppDataDirectoryService` adapters exist. `lib/main.dart` selects between them by platform:

- `PathProviderAppDataDirectoryService` — the per-user platform application-support folder (via `path_provider`). Used on non-Windows platforms.
- `ExecutableRelativeAppDataDirectoryService` — a fixed-name folder (`My Battery Data` by default) created next to the running executable, resolved from `Platform.resolvedExecutable` at every launch. Used on Windows, to support a fully portable deployment (executable and data together on a USB drive) that works correctly regardless of which drive letter Windows assigns the media on a given machine.

Both return a `Uri`; no other code cares which one produced it. Database, photo, custom-icon, log, and backup storage all resolve `ManagedRelativePath` values against whatever root the active adapter returns.
