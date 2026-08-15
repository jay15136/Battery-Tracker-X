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
