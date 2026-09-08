# QR Labels

## Workflow

Open **QR Labels**, select Batteries, Sets, or Devices, choose a size preset, and adjust dimensions, QR size, text size, fields, alignment, orientation, and margins. Dimensions are entered in inches and stored as PDF points (72 per inch). Small Battery, Medium Battery, Device, Address Label Sheet, and Custom Size presets are included.

The live preview uses the first selected record. **Preview pages** shows every output page. Enable **Print on label sheets** to set paper size, rows, columns, margins, gaps, and the one-based starting position. Starting positions skip used slots only on the first page; subsequent pages begin at the first slot. Print at actual size (100%) and check a plain-paper sample against the label stock before using adhesive sheets. Printer hardware margins still apply.

**Export labels to PDF** writes the complete document through the native save dialog. **Print labels** submits the same document to the host print system. Canceling the print dialog creates no print-history event; submission is recorded as submission, not proof that paper emerged from a printer.

Battery details and selected inventory, Set details/current members, Device details, and the successful bulk-creation dialog provide **Create QR Labels** shortcuts. After bulk creation, every new Battery UUID is selected; uncheck records to print a subset. **Save for later** retains the selected UUIDs and the complete design/sheet configuration.

## Identity and lookup

QR payloads are strictly validated `batterytracker://battery/{UUID}`, `batterytracker://set/{UUID}`, or `batterytracker://device/{UUID}` URIs. Editable inventory IDs never enter the QR payload. Lookup resolves current SQLite records, so labels continue working after renaming. Unknown/deleted records produce a clear unavailable-record message.

Enter/paste a QR value, read a saved QR image, or capture an image through the existing camera/webcam service. A successful lookup opens the actual Battery, Set, or Device details. No cloud lookup or runtime internet access is required. Native webcam capture requires an available camera and OS permission; image-file and text lookup remain available.

## Rendering and validation

`CanvasLabelRenderer` renders labels at 600 dpi using Flutter text/image rendering. Live preview, sheet preview, PDF, and printing share these rendered images. QR codes use black on white, medium error correction, and a four-module quiet zone. Labels require a QR size of at least half an inch. Invalid geometry, excessive record counts (over 1,000), and overflowing text are rejected before output; text is never silently clipped. Reduce displayed fields/font size or enlarge the label when validation identifies a record that does not fit.

The centralized icon registry supplies built-in and managed PNG/SVG custom icons with the inventory's selected color. Photographs are opt-in for each layout. This explicit label choice may use the selected photograph even when the inventory record remains icon-first. Missing, inactive, invalid, or unreadable assets fall back to the appropriate built-in icon. Label design never changes the inventory's visual preference.

## Persistence and services

Schema v1 already contains `qr_label_templates`; no migration is required. Each template stores its permanent UUID, target type, dimensions, and JSON containing the complete label and sheet configuration. Updates preserve UUID and creation time; duplicate active names are rejected. The repository supports soft deactivation.

Saved label selections use `settings` JSON keys prefixed `qr_job_`, containing UUID URIs plus layout/sheet configuration. Labels resolve current metadata when exported, rather than freezing display IDs in the saved job. Export/print activity rows retain each entity UUID and share one operation UUID, written transactionally after successful output.

`LabelRepository`, `LabelRenderer`, `QrCodeService`, `PrintService`, `FileSelectionService`, and `CameraService` isolate persistence, rendering, file dialogs, printing, and capture from UI controls. Production dependencies added in Phase 13:

- [pdf](https://pub.dev/packages/pdf): offline PDF creation with physical page geometry; Windows, Android, iOS, and macOS support.
- [printing](https://pub.dev/packages/printing): native printing with PDF bytes; Windows PDFium is downloaded at build time and bundled beside the executable. Distribute the complete release directory. macOS print entitlements are included; Apple/mobile builds have not been verified here.
- [zxing2](https://pub.dev/packages/zxing2): pure-Dart offline QR encoding/decoding, sharing stable payloads across platforms.
- [image](https://pub.dev/packages/image): pure-Dart PNG encoding and QR input-image decoding; also used transitively by PDF generation.

## Verification

`flutter test test/features/qr_labels` covers URI validation and round trips, rename stability, real SQLite restart, current Set membership, template validation, image/color/fallback behavior, text overflow, sheet pagination, canceled printing/export, lookup dialogs, and bulk-creation handoff. The full suite also exercises prior inventory workflows.

For optional local visual verification, set `LABEL_ARTIFACT_DIR` to an ignored/local output directory and `LABEL_TEST_FONT` to a locally installed TTF file before running `canvas_label_renderer_test.dart`. This writes representative PNG/PDF artifacts using a readable test font instead of Flutter's block-shaped test font. No machine-specific font path or font file is committed. Physical printer alignment and live webcam capture require a hardware check on the target workstation.
