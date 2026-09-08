import '../../batteries/domain/battery.dart';

/// Canonical Battery CSV columns, in the order used by the downloadable
/// template and by [ImportExportRepository.exportBatteriesCsv].
const batteryCsvFields = <String>[
  'Battery ID',
  'Name',
  'Type',
  'Manufacturer',
  'Model',
  'Serial Number',
  'Chemistry',
  'Voltage',
  'Capacity',
  'Capacity Unit',
  'Status',
  'Condition',
  'Purchase Date',
  'Purchase Location',
  'Purchase Price',
  'Notes',
];

/// Read-only export columns appended after the editable import fields.
const batteryExportOnlyFields = <String>[
  'Battery Set',
  'Assigned Device',
  'Batch ID',
  'Recorded Charges',
  'Last Charged',
];

const batterySetCsvFields = <String>[
  'Set ID',
  'Name',
  'Battery Type',
  'Description',
  'Member Count',
  'Assigned Device',
  'Recorded Charges',
  'Last Charged',
  'Active',
  'Notes',
];

/// Maps CSV column headers onto the canonical [batteryCsvFields]. A missing
/// mapping (`null`) leaves that field blank for every row rather than
/// failing the whole file, so files with extra or reordered columns still
/// import their recognized fields.
final class CsvFieldMapping {
  const CsvFieldMapping(this.columnIndexByField);

  final Map<String, int?> columnIndexByField;

  int? indexOf(String field) => columnIndexByField[field];

  /// Matches each canonical field to the first header cell with the same
  /// text, ignoring case and surrounding whitespace.
  factory CsvFieldMapping.guess(List<String> header) {
    final normalized = header.map((h) => h.trim().toLowerCase()).toList();
    return CsvFieldMapping({
      for (final field in batteryCsvFields)
        field: normalized.indexOf(field.toLowerCase()) == -1
            ? null
            : normalized.indexOf(field.toLowerCase()),
    });
  }
}

/// One parsed and validated CSV row, ready for preview.
final class CsvImportRowResult {
  const CsvImportRowResult({
    required this.rowNumber,
    required this.rawValues,
    this.draft,
    this.duplicateOf,
    this.errors = const [],
    this.warnings = const [],
  });

  /// 1-based row number within the CSV file, header excluded, for display.
  final int rowNumber;
  final Map<String, String> rawValues;
  final BatteryDraft? draft;

  /// The Battery ID this row collides with (itself, an earlier row in the
  /// same file, or an existing record), or `null` if it is unique.
  final String? duplicateOf;
  final List<String> errors;
  final List<String> warnings;

  bool get isValid => errors.isEmpty && draft != null;
  bool get willImport => isValid && duplicateOf == null;
}

/// A previewed, not-yet-committed CSV import.
final class CsvImportPreview {
  const CsvImportPreview(
      {required this.header, required this.mapping, required this.rows});

  final List<String> header;
  final CsvFieldMapping mapping;
  final List<CsvImportRowResult> rows;

  int get willImportCount => rows.where((r) => r.willImport).length;
  int get duplicateCount =>
      rows.where((r) => r.isValid && r.duplicateOf != null).length;
  int get errorCount => rows.where((r) => !r.isValid).length;
}

/// The outcome of committing a previously previewed import.
final class CsvImportSummary {
  const CsvImportSummary(
      {required this.created,
      required this.skippedDuplicates,
      required this.skippedInvalid});

  final int created;
  final int skippedDuplicates;
  final int skippedInvalid;
}

/// CSV export/import for Batteries, plus Battery Set export. Keeps a
/// preview-before-commit boundary so nothing is written until the caller
/// explicitly confirms a [CsvImportPreview].
///
/// Export intentionally returns plain CSV text/requests rather than writing
/// files directly, so a future Excel or PDF report can share this boundary.
abstract interface class ImportExportRepository {
  /// A blank CSV file with only the canonical header row, for users who
  /// want to fill in a template from scratch.
  String batteryCsvTemplate();

  Future<String> exportBatteriesCsv();

  Future<String> exportBatterySetsCsv();

  /// Parses, maps, and validates [csvText] without writing anything.
  /// [mapping] overrides the automatically guessed header mapping.
  Future<CsvImportPreview> previewBatteryImport(String csvText,
      {CsvFieldMapping? mapping});

  /// Creates every row that is valid and not a duplicate. Rows with
  /// validation errors or duplicate Battery IDs are skipped and counted in
  /// the returned summary rather than failing the whole import.
  Future<CsvImportSummary> commitBatteryImport(CsvImportPreview preview);
}
