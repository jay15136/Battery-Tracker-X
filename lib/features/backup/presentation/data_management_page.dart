import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../../app/app_providers.dart';
import '../../../app/battery_tracker_root.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../services/file_selection_service.dart';
import '../../import_export/domain/import_export.dart';
import '../domain/backup.dart';

final _log = Logger('battery_tracker.data_management');

class DataManagementPage extends StatelessWidget {
  const DataManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('data-management-page'),
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Settings'),
      ),
      body: const AppPageScaffold(
        title: 'Data Management',
        description:
            'Back up, restore, export, and import your local Battery Tracker data.',
        icon: Icons.storage_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BackupCard(),
            SizedBox(height: 20),
            _ExportCard(),
            SizedBox(height: 20),
            _ImportCard(),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard(
      {required this.title, required this.description, required this.children});
  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      );
}

class _BackupCard extends ConsumerStatefulWidget {
  const _BackupCard();
  @override
  ConsumerState<_BackupCard> createState() => _BackupCardState();
}

class _BackupCardState extends ConsumerState<_BackupCard> {
  bool _busy = false;
  String? _status;
  bool _statusIsError = false;

  Future<void> _run(Future<String> Function() action) async {
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final message = await action();
      if (mounted) setState(() => _status = message);
    } on BackupValidationException catch (e) {
      if (mounted) {
        setState(() {
          _status = e.message;
          _statusIsError = true;
        });
      }
    } on BackupRestoreException catch (e) {
      if (mounted) {
        setState(() {
          _status = e.message;
          _statusIsError = true;
        });
      }
    } on Object catch (error, stack) {
      _log.severe('Backup operation failed.', error, stack);
      if (mounted) {
        setState(() {
          _status = 'The operation could not be completed. Please try again.';
          _statusIsError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _create() => _run(() async {
        _statusIsError = false;
        final files = ref.read(fileSelectionServiceProvider);
        final destination = await files.chooseSaveLocation(
            suggestedFileName:
                'BatteryTracker_Backup_${DateTime.now().toIso8601String().split('T').first}.zip');
        if (destination == null) return 'Backup canceled.';
        final summary =
            await ref.read(backupRepositoryProvider).createBackup(destination);
        final mb =
            (summary.manifest.totalBytes / (1024 * 1024)).toStringAsFixed(1);
        return 'Backup created: ${summary.manifest.entries.length} files, $mb MB.';
      });

  Future<void> _restore() => _run(() async {
        _statusIsError = false;
        final files = ref.read(fileSelectionServiceProvider);
        final source = await files.chooseOpenFile(acceptedTypes: const [
          FileTypeFilter(label: 'Battery Tracker Backup', extensions: ['zip'])
        ]);
        if (source == null) return 'Restore canceled.';
        final backups = ref.read(backupRepositoryProvider);
        final validation = await backups.validateBackup(source);
        if (!validation.valid) {
          throw BackupValidationException(
              validation.reason ?? 'This backup could not be validated.');
        }
        final manifest = validation.manifest!;
        if (!mounted) return 'Restore canceled.';
        final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Restore this backup?'),
                  content: Text(
                      'This backup was created ${manifest.createdAt.toLocal().toString().split('.').first} '
                      'and contains ${manifest.entries.length} files (${(manifest.totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB).\n\n'
                      'Restoring replaces the current database, photographs, and custom icons. '
                      'The current data is kept as a recovery copy until the restore is verified.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Restore')),
                  ],
                ));
        if (confirmed != true) return 'Restore canceled.';
        await backups.restoreBackup(source);
        await ref.read(appLifecycleProvider).reload();
        return 'Backup restored. The application has reloaded your restored data.';
      });

  @override
  Widget build(BuildContext context) => _SectionCard(
        title: 'Backup and Restore',
        description:
            'A backup archive includes the database, Battery/Set/Device photographs, and custom icons. '
            'QR label templates, settings, and icon selections are stored in the database and travel with it. '
            'Built-in icons ship with the application and are never copied.',
        children: [
          Wrap(spacing: 12, runSpacing: 8, children: [
            FilledButton.icon(
                onPressed: _busy ? null : _create,
                icon: const Icon(Icons.archive_outlined),
                label: const Text('Create Backup')),
            OutlinedButton.icon(
                onPressed: _busy ? null : _restore,
                icon: const Icon(Icons.settings_backup_restore_outlined),
                label: const Text('Restore Backup')),
          ]),
          if (_busy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (_status != null) ...[
            const SizedBox(height: 12),
            Text(_status!,
                style: TextStyle(
                    color: _statusIsError
                        ? Theme.of(context).colorScheme.error
                        : null)),
          ],
        ],
      );
}

class _ExportCard extends ConsumerStatefulWidget {
  const _ExportCard();
  @override
  ConsumerState<_ExportCard> createState() => _ExportCardState();
}

class _ExportCardState extends ConsumerState<_ExportCard> {
  bool _busy = false;
  String? _status;

  Future<void> _export(String fileName, Future<String> Function() csv) async {
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final files = ref.read(fileSelectionServiceProvider);
      final destination =
          await files.chooseSaveLocation(suggestedFileName: fileName);
      if (destination == null) {
        setState(() => _status = 'Export canceled.');
        return;
      }
      final text = await csv();
      await File.fromUri(destination).writeAsString(text, flush: true);
      setState(() => _status = 'Exported to ${destination.toFilePath()}.');
    } on Object catch (error, stack) {
      _log.severe('CSV export failed.', error, stack);
      setState(() => _status = 'The export could not be completed.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(importExportRepositoryProvider);
    return _SectionCard(
      title: 'CSV Export',
      description:
          'Export the current Battery or Battery Set inventory to CSV.',
      children: [
        Wrap(spacing: 12, runSpacing: 8, children: [
          FilledButton.icon(
              onPressed: _busy
                  ? null
                  : () =>
                      _export('Batteries.csv', repository.exportBatteriesCsv),
              icon: const Icon(Icons.file_download_outlined),
              label: const Text('Export Batteries')),
          OutlinedButton.icon(
              onPressed: _busy
                  ? null
                  : () => _export(
                      'BatterySets.csv', repository.exportBatterySetsCsv),
              icon: const Icon(Icons.file_download_outlined),
              label: const Text('Export Battery Sets')),
          TextButton.icon(
              onPressed: _busy
                  ? null
                  : () => _export('BatteryImportTemplate.csv',
                      () async => repository.batteryCsvTemplate()),
              icon: const Icon(Icons.description_outlined),
              label: const Text('Download Battery Import Template')),
        ]),
        if (_busy) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
        ],
        if (_status != null) ...[
          const SizedBox(height: 12),
          Text(_status!),
        ],
      ],
    );
  }
}

class _ImportCard extends ConsumerStatefulWidget {
  const _ImportCard();
  @override
  ConsumerState<_ImportCard> createState() => _ImportCardState();
}

class _ImportCardState extends ConsumerState<_ImportCard> {
  bool _busy = false;
  String? _status;

  Future<void> _chooseFile() async {
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final files = ref.read(fileSelectionServiceProvider);
      final source = await files.chooseOpenFile(acceptedTypes: const [
        FileTypeFilter(label: 'CSV', extensions: ['csv'])
      ]);
      if (source == null) {
        setState(() => _status = 'Import canceled.');
        return;
      }
      final text = await File.fromUri(source).readAsString();
      final repository = ref.read(importExportRepositoryProvider);
      final preview = await repository.previewBatteryImport(text);
      if (!mounted) return;
      final summary = await showDialog<CsvImportSummary>(
          context: context,
          builder: (context) => _CsvImportPreviewDialog(preview: preview));
      if (summary != null) {
        setState(() => _status =
            'Imported ${summary.created}, skipped ${summary.skippedDuplicates} duplicate(s) '
                'and ${summary.skippedInvalid} invalid row(s).');
      } else {
        setState(() => _status = 'Import canceled.');
      }
    } on Object catch (error, stack) {
      _log.severe('CSV import failed.', error, stack);
      setState(() => _status = 'The CSV file could not be read.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => _SectionCard(
        title: 'CSV Import',
        description:
            'Import Batteries from a CSV file. Nothing is saved until you review and confirm the preview.',
        children: [
          FilledButton.icon(
              onPressed: _busy ? null : _chooseFile,
              icon: const Icon(Icons.file_upload_outlined),
              label: const Text('Choose CSV File')),
          if (_busy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (_status != null) ...[
            const SizedBox(height: 12),
            Text(_status!),
          ],
        ],
      );
}

class _CsvImportPreviewDialog extends ConsumerStatefulWidget {
  const _CsvImportPreviewDialog({required this.preview});
  final CsvImportPreview preview;
  @override
  ConsumerState<_CsvImportPreviewDialog> createState() =>
      _CsvImportPreviewDialogState();
}

class _CsvImportPreviewDialogState
    extends ConsumerState<_CsvImportPreviewDialog> {
  bool _busy = false;
  String? _error;

  Future<void> _confirm() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final summary = await ref
          .read(importExportRepositoryProvider)
          .commitBatteryImport(widget.preview);
      if (mounted) Navigator.pop(context, summary);
    } on Object catch (error, stack) {
      _log.severe('CSV import commit failed.', error, stack);
      if (mounted) {
        setState(() =>
            _error = 'The import could not be completed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = widget.preview;
    return PopScope(
      canPop: !_busy,
      child: Dialog(
        child: SizedBox(
          width: 900,
          height: MediaQuery.sizeOf(context).height * .8,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Import Preview',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                        '${preview.willImportCount} to import, ${preview.duplicateCount} duplicate(s), '
                        '${preview.errorCount} row(s) with errors, out of ${preview.rows.length} data rows.'),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: preview.rows.isEmpty
                    ? const Center(child: Text('No data rows were found.'))
                    : ListView.builder(
                        itemCount: preview.rows.length,
                        itemBuilder: (context, index) {
                          final row = preview.rows[index];
                          final id =
                              row.rawValues['Battery ID']?.trim().isNotEmpty ==
                                      true
                                  ? row.rawValues['Battery ID']!
                                  : '(blank)';
                          final label = row.willImport
                              ? 'Will import'
                              : row.duplicateOf != null
                                  ? 'Duplicate of ${row.duplicateOf}'
                                  : 'Row error';
                          return ListTile(
                            dense: true,
                            leading: Icon(row.willImport
                                ? Icons.check_circle_outline
                                : row.duplicateOf != null
                                    ? Icons.content_copy_outlined
                                    : Icons.error_outline),
                            title: Text('Row ${row.rowNumber}: $id'),
                            subtitle: Text([
                              label,
                              ...row.errors,
                              ...row.warnings,
                            ].join(' • ')),
                          );
                        },
                      ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_error != null) ...[
                      Expanded(
                          child: Text(_error!,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error))),
                    ],
                    TextButton(
                        onPressed: _busy ? null : () => Navigator.pop(context),
                        child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    FilledButton(
                        onPressed: _busy || preview.willImportCount == 0
                            ? null
                            : _confirm,
                        child: Text(_busy
                            ? 'Importing…'
                            : 'Import ${preview.willImportCount} Batteries')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
