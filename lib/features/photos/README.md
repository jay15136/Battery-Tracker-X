# Optional Photographs

Phase 6 adds managed PNG/JPEG/WebP photographs, a reusable gallery, and primary
visual selection. The Battery detail dialog exposes Photographs; Set/Device owner
support is implemented and tested for their upcoming detail screens.

## Data and storage

The existing schema v1 media_assets and three owner-specific photo link tables are
used without migrations. Photos live at photos/{UUID}.{png|jpg|webp} below the
application-support directory. SQLite stores relative paths, format, original
filename, dimensions, byte count, and SHA-256; it never stores image bytes.

LocalPhotoStorage checks the file signature, decodes an image, enforces 25 MB and
40-megapixel limits, then writes the inspected bytes. Source files are not modified.
Imports receive new paths. Replacements write a new managed file before committing
the replacement link, so the old photograph remains usable on a failed transaction.

PhotoService compensates for failed database writes by removing newly copied files.
Removal/replacement deletes an old file only after metadata commits and no owner
still references it. Failed file cleanup is logged; an unreferenced file may remain
for later maintenance after a crash or filesystem failure.

## Visual behavior

Import never changes the owner's preferred visual. The gallery then offers Keep
Icon as Primary (default) or Use Photo as Primary. A primary photograph and a
photo-primary visual preference are separate stored values. Selecting a different
primary photograph preserves the current preference. Removing a primary photo
switches back to the icon; additional photos remain available.

The inventory renders the icon while photo decoding is pending, and falls back to
it for missing/corrupt files. Failures are logged; the gallery surfaces an unavailable
message with Replace and Remove controls. Original icon key, source, color, and
permanent inventory UUID are never changed by photograph operations.

## Platform adapters

FileSelectionService provides file dialogs. PhotographDropTarget isolates the
Windows/macOS/Linux desktop_drop plugin. Multiple dropped photographs commit one
at a time; a failed file reports how many succeeded and leaves later files untouched.

DialogCameraService implements CameraService with a camera preview, device
selection, explicit shutter, cancellation, and no-device/permission errors. Audio is
disabled. It opens only on Capture Photograph and releases controllers on dialog
close and app inactivity. Windows uses camera_windows. Android/iOS use the camera
package backends; macOS camera capture needs a future adapter. File import remains
available there. Physical webcam capture and native OS drag gestures require a
manual hardware smoke test; automated tests cover the gallery integration,
cancellation, no-camera state, and drop callback.

## Dependencies reviewed 2026-09-08

- camera 0.12.1 and camera_windows 0.2.6+5: Flutter-maintained preview/still capture.
  Windows requires explicit registration of its non-endorsed implementation.
  https://pub.dev/packages/camera and https://pub.dev/packages/camera_windows
- desktop_drop 0.8.4: native Windows/macOS/Linux drop handling; isolated because
  iOS is not supported. https://pub.dev/packages/desktop_drop
- crypto 3.0.7: promotes an existing transitive Dart package to a direct dependency
  for SHA-256 checksums. https://pub.dev/packages/crypto

No cloud, account, web server, or runtime internet access is required.
