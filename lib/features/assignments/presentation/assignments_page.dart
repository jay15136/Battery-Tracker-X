import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_providers.dart';
import '../../../core/identity/permanent_id.dart';
import '../../batteries/presentation/batteries_page.dart';
import '../../battery_sets/presentation/battery_sets_page.dart';
import '../../devices/application/device_providers.dart';
import '../application/assignment_providers.dart';
import '../domain/assignment.dart';
import 'new_assignment_dialog.dart';
import 'assignment_date_field.dart';

class AssignmentManagerDialog extends StatelessWidget {
  const AssignmentManagerDialog({this.deviceId, this.batteryId, super.key});
  final PermanentId? deviceId, batteryId;
  @override
  Widget build(BuildContext context) => Dialog(
      child: SizedBox(
          width: 1100,
          height: MediaQuery.sizeOf(context).height * .85,
          child: Column(children: [
            Expanded(
                child:
                    AssignmentsPage(deviceId: deviceId, batteryId: batteryId)),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'))
          ])));
}

class AssignmentsPage extends ConsumerStatefulWidget {
  const AssignmentsPage({this.deviceId, this.batteryId, super.key});
  final PermanentId? deviceId, batteryId;
  @override
  ConsumerState<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends ConsumerState<AssignmentsPage> {
  String _query = '';
  bool _history = false, _busy = false;
  String? _error;
  final _selected = <PermanentId>{};
  void _refresh() {
    ref.invalidate(assignmentsProvider);
    ref.invalidate(batteryInventoryProvider);
    ref.invalidate(batterySetsProvider);
    ref.invalidate(devicesProvider);
    _selected.clear();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (mounted) _refresh();
    } on AssignmentValidationException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on Object catch (e, s) {
      ref
          .read(appLogServiceProvider)
          .logger('assignments.ui')
          .severe('Assignment operation failed.', e, s);
      if (mounted)
        setState(() => _error =
            'The assignment operation could not be completed. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _new() => _run(() async {
        final devices = (await ref.read(deviceRepositoryProvider).list())
            .where((d) => d.active)
            .toList();
        if (devices.isEmpty)
          throw const AssignmentValidationException(
              'Add an active Device before assigning inventory.');
        if (widget.deviceId != null &&
            !devices.any((d) => d.id == widget.deviceId)) {
          throw const AssignmentValidationException(
              'Reactivate this Device before assigning inventory.');
        }
        final batteries = await ref.read(batteryRepositoryProvider).list();
        final sets = await ref.read(batterySetRepositoryProvider).list();
        if (!mounted) return;
        await showDialog<bool>(
            context: context,
            builder: (_) => NewAssignmentDialog(
                devices: devices,
                batteries: batteries,
                sets: sets,
                deviceId: widget.deviceId,
                batteryId: widget.batteryId));
      });
  Future<void> _remove(List<AssignmentRecord> rows) => _run(() async {
        var date = DateTime.now();
        var notes = '';
        final count = rows.fold<int>(
            0, (n, a) => n + (a.setId == null ? 1 : a.memberIds.length));
        final result = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
                    title: const Text('Remove selected assignments'),
                    content: SizedBox(
                        width: 620,
                        child: SingleChildScrollView(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(
                                  'Remove ${rows.length} assignments covering $count Batteries? Set assignments include every linked member. Installation dates, notes, and history will be retained.'),
                              for (final r in rows)
                                Text('${r.label} → ${r.deviceName}'),
                              AssignmentDateField(
                                  initial: date,
                                  label: 'Removal date',
                                  onChanged: (v) => date = v),
                              TextField(
                                  decoration: const InputDecoration(
                                      labelText: 'Removal notes'),
                                  onChanged: (v) => notes = v)
                            ]))),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: const Text('Cancel')),
                      FilledButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: const Text('Confirm removal'))
                    ]));
        if (result == true)
          await ref.read(assignmentRepositoryProvider).remove(
              rows.map((r) => r.id).toList(),
              removedAt: date,
              notes: notes);
      });
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(assignmentsProvider);
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Assignments',
              style: Theme.of(context).textTheme.headlineMedium),
          const Text(
              'Install or remove inventory while preserving its history.'),
          Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.icon(
                    onPressed: _busy ? null : _new,
                    icon: const Icon(Icons.add),
                    label: const Text('New assignment')),
                SizedBox(
                    width: 230,
                    child: TextField(
                        decoration: const InputDecoration(
                            labelText: 'Search assignments'),
                        onChanged: (v) =>
                            setState(() => _query = v.toLowerCase()))),
                FilterChip(
                    label: const Text('Include history'),
                    selected: _history,
                    onSelected: (v) => setState(() => _history = v)),
                IconButton(
                    tooltip: 'Refresh',
                    onPressed: _busy ? null : () => setState(_refresh),
                    icon: const Icon(Icons.refresh))
              ]),
          if (_busy) const Text('Working…'),
          if (_error != null)
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          Expanded(
              child: data.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(
                      child: TextButton(
                          onPressed: () => setState(_refresh),
                          child:
                              const Text('Could not load assignments. Retry'))),
                  data: (all) {
                    final rows = all
                        .where((a) =>
                            (widget.deviceId == null ||
                                widget.deviceId == a.deviceId) &&
                            (widget.batteryId == null ||
                                widget.batteryId == a.batteryId ||
                                a.memberIds.contains(widget.batteryId)) &&
                            (_history || a.removedAt == null) &&
                            '${a.label} ${a.deviceName} ${a.notes ?? ''}'
                                .toLowerCase()
                                .contains(_query))
                        .toList();
                    final selected = all
                        .where((a) =>
                            _selected.contains(a.id) &&
                            a.removedAt == null &&
                            a.parentId == null)
                        .toList();
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (selected.isNotEmpty)
                            OutlinedButton(
                                onPressed:
                                    _busy ? null : () => _remove(selected),
                                child: Text(
                                    'Remove selected (${selected.length})')),
                          Expanded(
                              child: ListView(children: [
                            if (rows.isEmpty)
                              const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text('No matching assignments.')),
                            for (final a in rows)
                              Card(
                                  child: ListTile(
                                      leading: a.removedAt != null ||
                                              a.parentId != null
                                          ? Icon(a.parentId != null
                                              ? Icons.link
                                              : Icons.history)
                                          : Checkbox(
                                              value: _selected.contains(a.id),
                                              onChanged: _busy
                                                  ? null
                                                  : (v) => setState(() {
                                                        if (v == true) {
                                                          _selected.add(a.id);
                                                        } else {
                                                          _selected
                                                              .remove(a.id);
                                                        }
                                                      })),
                                      title:
                                          Text('${a.label} → ${a.deviceName}'),
                                      subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                'Assigned: ${_date(a.assignedAt)} · Removed: ${a.removedAt == null ? 'Current' : _date(a.removedAt!)}'),
                                            Text(
                                                'Duration: ${_duration(a.durationAt(DateTime.now()))}${a.parentId != null ? ' · Installed through Set; remove the Set above.' : ''}'),
                                            if (a.notes != null)
                                              Text(
                                                  'Installation notes: ${a.notes}'),
                                            if (a.removalNotes != null)
                                              Text(
                                                  'Removal notes: ${a.removalNotes}'),
                                            if (a.overrideReason != null)
                                              Text(
                                                  'Acknowledged warnings: ${a.overrideReason}')
                                          ]),
                                      trailing: a.removedAt != null ||
                                              a.parentId != null
                                          ? null
                                          : TextButton(
                                              onPressed: _busy
                                                  ? null
                                                  : () => _remove([a]),
                                              child: const Text('Remove'))))
                          ]))
                        ]);
                  }))
        ]));
  }

  String _date(DateTime value) => value.toLocal().toString().split('.').first;
  String _duration(Duration value) =>
      '${value.inDays}d ${value.inHours.remainder(24)}h ${value.inMinutes.remainder(60)}m';
}
