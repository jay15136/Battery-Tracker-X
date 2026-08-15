import 'dart:typed_data';

/// Generates and recognizes stable Battery Tracker QR payloads.
abstract interface class QrCodeService {
  Uint8List render(Uri value);

  Future<Uri?> decode(Uint8List imageBytes);
}

/// Converts platform-neutral label data into a printable PDF document.
abstract interface class LabelService {
  Future<Uint8List> renderPdf(Object labelDocument);
}

/// Sends a generated PDF through the host platform's print workflow.
abstract interface class PrintService {
  Future<void> printPdf({required Uint8List bytes, required String jobName});
}

/// Creates, validates, and restores complete application archives.
abstract interface class BackupService {
  Future<void> createBackup(Uri destination);

  Future<bool> validateBackup(Uri source);

  Future<void> restoreBackup(Uri source);
}

/// Preview-before-commit import boundary.
abstract interface class ImportService<TPreview> {
  Future<TPreview> preview(Uri source);

  Future<void> commit(TPreview preview);
}

/// Cross-platform export boundary.
abstract interface class ExportService<TRequest> {
  Future<void> export(TRequest request, Uri destination);
}
