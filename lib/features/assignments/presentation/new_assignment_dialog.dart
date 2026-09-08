import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_providers.dart';
import '../../../core/identity/permanent_id.dart';
import '../../batteries/domain/battery.dart';
import '../../battery_sets/domain/battery_set.dart';
import '../../devices/domain/device.dart';
import '../domain/assignment.dart';
import 'assignment_date_field.dart';

class NewAssignmentDialog extends ConsumerStatefulWidget {
  const NewAssignmentDialog(
      {required this.devices,
      required this.batteries,
      required this.sets,
      this.deviceId,
      this.batteryId,
      super.key});
  final List<DeviceRecord> devices;
  final List<BatteryRecord> batteries;
  final List<SetRecord> sets;
  final PermanentId? deviceId, batteryId;
  @override
  ConsumerState<NewAssignmentDialog> createState() =>
      _NewAssignmentDialogState();
}

class _NewAssignmentDialogState extends ConsumerState<NewAssignmentDialog> {
  PermanentId? _device, _set;
  final _selected = <PermanentId>{};
  String _mode = 'Batteries', _query = '', _notes = '';
  bool _all = false, _busy = false;
  String? _error;
  DateTime _date = DateTime.now();
  @override
  void initState() {
    super.initState();
    _device = widget.deviceId ?? widget.devices.firstOrNull?.id;
    if (widget.batteryId != null) {
      _selected.add(widget.batteryId!);
      _all = true;
    }
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_device == null)
        throw const AssignmentValidationException('Choose a Device.');
      var accepted = <String>{};
      while (mounted) {
        try {
          await ref.read(assignmentRepositoryProvider).assign(
              deviceId: _device!,
              batteryIds: _mode == 'Batteries' ? _selected.toList() : [],
              setId: _mode == 'Battery Set' ? _set : null,
              assignedAt: _date,
              notes: _notes,
              acceptedWarnings: accepted);
          if (mounted) Navigator.pop(context, true);
          return;
        } on AssignmentWarnings catch (e) {
          final ok = await showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                      title: const Text('Review compatibility warnings'),
                      content: SizedBox(
                          width: 540,
                          child: SingleChildScrollView(
                              child: Text(
                                  e.messages.map((w) => '• $w').join('\n\n')))),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(c, false),
                            child: const Text('Cancel')),
                        FilledButton(
                            onPressed: () => Navigator.pop(c, true),
                            child: const Text('Assign anyway'))
                      ]));
          if (ok != true) return;
          accepted = {...accepted, ...e.messages};
        }
      }
    } on AssignmentValidationException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on Object catch (e, s) {
      ref
          .read(appLogServiceProvider)
          .logger('assignments.ui')
          .severe('Assignment failed.', e, s);
      if (mounted)
        setState(() =>
            _error = 'The assignment could not be saved. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final candidates = widget.batteries
        .where((b) =>
            (_all ||
                (b.currentDevices.isEmpty &&
                    ['Available', 'In Set'].contains(b.values.status))) &&
            '${b.values.userBatteryId} ${b.values.name ?? ''}'
                .toLowerCase()
                .contains(_query))
        .toList();
    return PopScope(
        canPop: !_busy,
        child: AlertDialog(
            title: const Text('New assignment'),
            content: SizedBox(
                width: 720,
                height: MediaQuery.sizeOf(context).height * .65,
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      if (_error != null)
                        Text(_error!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error)),
                      DropdownButtonFormField<PermanentId>(
                          initialValue: _device,
                          isExpanded: true,
                          decoration:
                              const InputDecoration(labelText: 'Device'),
                          items: [
                            for (final d in widget.devices)
                              DropdownMenuItem(
                                  value: d.id, child: Text(d.values.name))
                          ],
                          onChanged: _busy
                              ? null
                              : (v) => setState(() => _device = v)),
                      DropdownButtonFormField<String>(
                          initialValue: _mode,
                          decoration:
                              const InputDecoration(labelText: 'Assign'),
                          items: [
                            for (final m in ['Batteries', 'Battery Set'])
                              DropdownMenuItem(value: m, child: Text(m))
                          ],
                          onChanged:
                              _busy ? null : (v) => setState(() => _mode = v!)),
                      AssignmentDateField(
                          initial: _date,
                          onChanged: (v) => _date = v,
                          enabled: !_busy),
                      TextField(
                          enabled: !_busy,
                          decoration: const InputDecoration(
                              labelText: 'Installation notes'),
                          onChanged: (v) => _notes = v,
                          maxLines: 2),
                      if (_mode == 'Battery Set')
                        DropdownButtonFormField<PermanentId>(
                            initialValue: _set,
                            isExpanded: true,
                            decoration:
                                const InputDecoration(labelText: 'Battery Set'),
                            items: [
                              for (final s in widget.sets.where((s) =>
                                  s.active &&
                                  s.currentAssignment == null &&
                                  s.members.isNotEmpty))
                                DropdownMenuItem(
                                    value: s.id,
                                    child: Text(
                                        '${s.values.userSetId} · ${s.values.name} (${s.members.length})'))
                            ],
                            onChanged:
                                _busy ? null : (v) => setState(() => _set = v))
                      else ...[
                        SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Show all Batteries'),
                            subtitle: const Text(
                                'Assigned and retired Batteries cannot be selected.'),
                            value: _all,
                            onChanged:
                                _busy ? null : (v) => setState(() => _all = v)),
                        TextField(
                            enabled: !_busy,
                            decoration: const InputDecoration(
                                labelText: 'Find Batteries'),
                            onChanged: (v) =>
                                setState(() => _query = v.toLowerCase())),
                        Text('${_selected.length} selected'),
                        if (candidates.isEmpty)
                          const Text('No matching Batteries.'),
                        for (final b in candidates)
                          CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(b.values.userBatteryId),
                              subtitle: Text(
                                  '${b.values.status} · ${b.currentDevices.isEmpty ? 'Unassigned' : b.currentDevices.join(', ')}${b.currentSets.isEmpty ? '' : ' · Set: ${b.currentSets.join(', ')}'}'),
                              value: _selected.contains(b.id),
                              onChanged: _busy ||
                                      b.currentDevices.isNotEmpty ||
                                      b.values.status == 'Retired' ||
                                      b.values.condition == 'Retired'
                                  ? null
                                  : (v) => setState(() {
                                        if (v == true) {
                                          _selected.add(b.id);
                                        } else {
                                          _selected.remove(b.id);
                                        }
                                      }))
                      ]
                    ]))),
            actions: [
              TextButton(
                  onPressed: _busy ? null : () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: _busy ? null : _save,
                  child: Text(_busy ? 'Saving…' : 'Confirm assignment'))
            ]));
  }
}
