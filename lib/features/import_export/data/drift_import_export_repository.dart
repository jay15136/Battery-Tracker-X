import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/identity/permanent_id.dart';
import '../../batteries/domain/battery.dart';
import '../../battery_sets/domain/battery_set.dart';
import '../../battery_types/domain/battery_type_repository.dart';
import '../domain/import_export.dart';

const _csvReader = CsvToListConverter(shouldParseNumbers: false);
const _csvWriter = ListToCsvConverter();

String? _optional(String value) => value.isEmpty ? null : value;

String _dateOnly(DateTime value) =>
    value.toLocal().toIso8601String().split('T').first;

/// CSV export for Batteries and Battery Sets, and preview-before-commit CSV
/// import for Batteries. Built entirely on the existing Battery, Battery
/// Set, and Battery Type repositories, so export/import share exactly the
/// same validation and persistence rules as manual entry. No migration or
/// schema change is needed.
final class DriftImportExportRepository implements ImportExportRepository {
  DriftImportExportRepository({
    required this.db,
    required this.batteries,
    required this.batterySets,
    required this.batteryTypes,
    this.idGenerator = const UuidV4PermanentIdGenerator(),
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;

  final AppDatabase db;
  final BatteryRepository batteries;
  final BatterySetRepository batterySets;
  final BatteryTypeRepository batteryTypes;
  final PermanentIdGenerator idGenerator;
  final DateTime Function() now;

  @override
  String batteryCsvTemplate() => _csvWriter.convert([batteryCsvFields]);

  @override
  Future<String> exportBatteriesCsv() async {
    final all = await batteries.list();
    final typeNames = {
      for (final t in await batteryTypes.list(includeInactive: true))
        t.id: t.typeName
    };
    final rows = <List<Object?>>[
      [...batteryCsvFields, ...batteryExportOnlyFields]
    ];
    for (final battery in all) {
      final v = battery.values;
      rows.add([
        v.userBatteryId,
        v.name ?? '',
        v.batteryTypeId == null ? '' : (typeNames[v.batteryTypeId] ?? ''),
        v.manufacturer ?? '',
        v.model ?? '',
        v.serialNumber ?? '',
        v.chemistry ?? '',
        v.nominalVoltage?.toString() ?? '',
        v.capacity?.toString() ?? '',
        v.capacityUnit ?? '',
        v.status,
        v.condition,
        v.purchaseDate == null ? '' : _dateOnly(v.purchaseDate!),
        v.purchaseLocation ?? '',
        v.purchasePrice?.toString() ?? '',
        v.notes ?? '',
        battery.currentSets.join('; '),
        battery.currentDevices.join('; '),
        v.batchCode ?? '',
        battery.recordedCharges.toString(),
        battery.lastCharged == null
            ? ''
            : battery.lastCharged!.toIso8601String(),
      ]);
    }
    return _csvWriter.convert(rows);
  }

  @override
  Future<String> exportBatterySetsCsv() async {
    final all = await batterySets.list();
    final rows = <List<Object?>>[batterySetCsvFields];
    for (final set in all) {
      rows.add([
        set.values.userSetId,
        set.values.name,
        set.typeName ?? '',
        set.values.description ?? '',
        set.members.length.toString(),
        set.currentAssignment?.deviceName ?? '',
        set.recordedCharges.toString(),
        set.lastCharged == null ? '' : set.lastCharged!.toIso8601String(),
        set.active ? 'Yes' : 'No',
        set.values.notes ?? '',
      ]);
    }
    return _csvWriter.convert(rows);
  }

  @override
  Future<CsvImportPreview> previewBatteryImport(String csvText,
      {CsvFieldMapping? mapping}) async {
    final table = _csvReader.convert(csvText);
    if (table.isEmpty) {
      return CsvImportPreview(
          header: const [],
          mapping: mapping ?? const CsvFieldMapping({}),
          rows: const []);
    }
    final header = table.first.map((cell) => cell.toString()).toList();
    final effectiveMapping = mapping ?? CsvFieldMapping.guess(header);

    final existingIds = (await batteries.list())
        .map((b) => b.values.userBatteryId.trim().toLowerCase())
        .toSet();
    final typeIdByName = {
      for (final t in await batteryTypes.list(includeInactive: true))
        t.typeName.trim().toLowerCase(): t.id
    };

    final seenInFile = <String>{};
    final rows = <CsvImportRowResult>[];
    for (var i = 0; i < table.length - 1; i++) {
      final raw = table[i + 1];
      String cell(String field) {
        final index = effectiveMapping.indexOf(field);
        if (index == null || index < 0 || index >= raw.length) return '';
        return raw[index].toString().trim();
      }

      final values = {for (final field in batteryCsvFields) field: cell(field)};
      final errors = <String>[];
      final warnings = <String>[];

      final id = values['Battery ID']!;
      if (id.isEmpty) errors.add('Enter a Battery ID.');

      PermanentId? typeId;
      final typeName = values['Type']!;
      if (typeName.isNotEmpty) {
        typeId = typeIdByName[typeName.toLowerCase()];
        if (typeId == null) {
          warnings.add(
              'Battery Type "$typeName" was not found; imported without a Type.');
        }
      }

      double? parseAmount(String field) {
        final text = values[field]!;
        if (text.isEmpty) return null;
        final parsed = double.tryParse(text);
        if (parsed == null) errors.add('$field must be a number.');
        return parsed;
      }

      final voltage = parseAmount('Voltage');
      final capacity = parseAmount('Capacity');
      final capacityUnit = values['Capacity Unit']!;
      if ((capacity != null) != capacityUnit.isNotEmpty) {
        errors.add('Enter both Capacity and Capacity Unit, or neither.');
      }
      final price = parseAmount('Purchase Price');

      DateTime? purchaseDate;
      final dateText = values['Purchase Date']!;
      if (dateText.isNotEmpty) {
        purchaseDate = DateTime.tryParse(dateText);
        if (purchaseDate == null) {
          errors.add('Purchase Date must look like YYYY-MM-DD.');
        }
      }

      final status =
          values['Status']!.isEmpty ? 'Available' : values['Status']!;
      if (!batteryStatuses.contains(status)) {
        errors.add('Status "$status" is not recognized.');
      }
      final condition =
          values['Condition']!.isEmpty ? 'New' : values['Condition']!;
      if (!batteryConditions.contains(condition)) {
        errors.add('Condition "$condition" is not recognized.');
      }

      BatteryDraft? draft;
      if (errors.isEmpty) {
        try {
          draft = BatteryDraft(
            userBatteryId: id,
            name: _optional(values['Name']!),
            batteryTypeId: typeId,
            manufacturer: _optional(values['Manufacturer']!),
            model: _optional(values['Model']!),
            serialNumber: _optional(values['Serial Number']!),
            chemistry: _optional(values['Chemistry']!),
            nominalVoltage: voltage,
            capacity: capacity,
            capacityUnit: _optional(capacityUnit),
            purchaseDate: purchaseDate,
            purchaseLocation: _optional(values['Purchase Location']!),
            purchasePrice: price,
            status: status,
            condition: condition,
            notes: _optional(values['Notes']!),
          );
          draft.validate();
        } on BatteryValidationException catch (e) {
          errors.add(e.message);
          draft = null;
        }
      }

      String? duplicateOf;
      if (id.isNotEmpty) {
        final key = id.toLowerCase();
        if (existingIds.contains(key)) {
          duplicateOf = id;
        } else if (errors.isEmpty) {
          if (seenInFile.contains(key)) {
            duplicateOf = id;
          } else {
            seenInFile.add(key);
          }
        }
      }

      rows.add(CsvImportRowResult(
          rowNumber: i + 1,
          rawValues: values,
          draft: draft,
          duplicateOf: duplicateOf,
          errors: errors,
          warnings: warnings));
    }
    return CsvImportPreview(
        header: header, mapping: effectiveMapping, rows: rows);
  }

  @override
  Future<CsvImportSummary> commitBatteryImport(CsvImportPreview preview) =>
      db.transaction(() async {
        var created = 0, skippedDuplicates = 0, skippedInvalid = 0;
        final createdIds = <String>[];
        for (final row in preview.rows) {
          if (!row.isValid) {
            skippedInvalid++;
            continue;
          }
          if (row.duplicateOf != null) {
            skippedDuplicates++;
            continue;
          }
          final record = await batteries.save(row.draft!);
          createdIds.add(record.id.value);
          created++;
        }
        if (created > 0) {
          final summaryParts = [
            'Imported $created ${created == 1 ? 'Battery' : 'Batteries'} from CSV'
          ];
          if (skippedDuplicates > 0) {
            summaryParts.add('$skippedDuplicates duplicate(s) skipped');
          }
          if (skippedInvalid > 0) {
            summaryParts.add('$skippedInvalid row(s) failed validation');
          }
          await db.into(db.activityLog).insert(ActivityLogCompanion.insert(
              uuid: idGenerator.next().value,
              eventType: 'csv_batteries_imported',
              entityType: 'bulk_operation',
              entityUuid: idGenerator.next().value,
              summary: '${summaryParts.join('; ')}.',
              metadataJson: Value(jsonEncode({'batteries': createdIds})),
              occurredAt: Value(now())));
        }
        return CsvImportSummary(
            created: created,
            skippedDuplicates: skippedDuplicates,
            skippedInvalid: skippedInvalid);
      });
}
