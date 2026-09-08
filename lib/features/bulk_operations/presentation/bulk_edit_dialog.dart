import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_providers.dart';
import '../../../core/identity/permanent_id.dart';
import '../../batteries/domain/battery.dart';
import '../../batteries/presentation/batteries_page.dart';
import '../../battery_sets/domain/battery_set.dart';
import '../../battery_sets/presentation/battery_sets_page.dart';
import '../../battery_types/domain/battery_type.dart';
import '../../icons/domain/icon_color.dart';
import '../../icons/domain/icon_definition.dart';
import '../../icons/domain/icon_selection.dart';
import '../../icons/presentation/icon_picker_dialog.dart';
import '../../assignments/presentation/assignment_date_field.dart';
import '../domain/bulk_creation.dart';
import '../domain/bulk_edit.dart';

class BulkEditDialog extends ConsumerStatefulWidget {
  const BulkEditDialog(
      {required this.ids,
      required this.types,
      this.initialAction = BulkEditAction.status,
      super.key});
  final List<PermanentId> ids;
  final List<BatteryTypeRecord> types;
  final BulkEditAction initialAction;
  @override
  ConsumerState<BulkEditDialog> createState() => _BulkEditDialogState();
}

class _BulkEditDialogState extends ConsumerState<BulkEditDialog> {
  late BulkEditAction _action;
  Object? _value = 'Storage';
  final _text = TextEditingController();
  DateTime _retired = DateTime.now();
  String _reason = retirementReasons.first;
  List<SetRecord> _sets = [];
  BulkEditPreview? _preview;
  String? _error;
  bool _busy = false, _done = false;
  @override
  void initState() {
    super.initState();
    _action = widget.initialAction;
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _change(BulkEditAction action) {
    setState(() {
      _action = action;
      _preview = null;
      _value = action == BulkEditAction.status
          ? 'Storage'
          : action == BulkEditAction.condition
              ? 'Good'
              : null;
      _text.clear();
      _error = null;
    });
    if (action == BulkEditAction.addSet || action == BulkEditAction.removeSet)
      _run(() async {
        _sets = await ref.read(batterySetRepositoryProvider).list();
      });
  }

  Future<void> _run(Future<void> Function() work) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await work();
    } on BulkValidationException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on BatteryValidationException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on SetValidationException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on Object catch (e, s) {
      ref
          .read(appLogServiceProvider)
          .logger('bulk_edit')
          .severe('Bulk edit failed.', e, s);
      if (mounted)
        setState(() => _error =
            'Changes could not be saved. No partial edits were applied.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  BulkEditRequest _request() {
    Object? value = _value;
    if ([
      BulkEditAction.note,
      BulkEditAction.tag,
      BulkEditAction.purchaseLocation
    ].contains(_action)) value = _text.text.trim();
    if ([
      BulkEditAction.purchasePrice,
      BulkEditAction.totalPackagePrice,
      BulkEditAction.perBatteryPrice
    ].contains(_action)) {
      value = _text.text.trim().isEmpty ? null : double.tryParse(_text.text);
      if (value == null && _text.text.trim().isNotEmpty)
        throw const BulkValidationException(
            'Enter a valid price or leave blank to clear.');
    }
    if ([BulkEditAction.purchaseDate, BulkEditAction.warrantyExpiration]
        .contains(_action)) {
      value = _text.text.trim().isEmpty
          ? null
          : DateTime.tryParse(_text.text.trim());
      if (_text.text.trim().isNotEmpty &&
          (value == null ||
              !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(_text.text.trim()) ||
              (value as DateTime).toIso8601String().substring(0, 10) !=
                  _text.text.trim()))
        throw const BulkValidationException(
            'Use a real date in YYYY-MM-DD format, or blank to clear.');
    }
    if (_action == BulkEditAction.purchaseLocation && value == '') value = null;
    if ((_action == BulkEditAction.purchaseDate ||
            _action == BulkEditAction.warrantyExpiration) &&
        value is DateTime)
      value = DateTime.utc(value.year, value.month, value.day);
    return BulkEditRequest(
        ids: widget.ids,
        action: _action,
        value: value,
        retirementDate: _retired,
        reason: _reason);
  }

  Future<void> _apply() => _run(() async {
        final accepted = <String>{};
        while (true) {
          try {
            await ref
                .read(bulkEditRepositoryProvider)
                .apply(_preview!, acceptedWarnings: accepted);
            break;
          } on SetWarnings catch (e) {
            if (!mounted) return;
            final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                        title: const Text('Review Set warning'),
                        content: Text(e.messages.join('\n')),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(c, false),
                              child: const Text('Cancel')),
                          FilledButton(
                              onPressed: () => Navigator.pop(c, true),
                              child: const Text('Accept warning'))
                        ]));
            if (ok != true) return;
            accepted.addAll(e.messages);
          }
        }
        if (mounted) {
          ref.invalidate(batteryInventoryProvider);
          ref.invalidate(batterySetsProvider);
          setState(() => _done = true);
        }
      });
  Widget _input() {
    switch (_action) {
      case BulkEditAction.status:
      case BulkEditAction.condition:
        final choices = (_action == BulkEditAction.status
                ? batteryStatuses
                : batteryConditions)
            .where((v) => v != 'Retired');
        return DropdownButtonFormField<String>(
            key: ValueKey(_action),
            initialValue: _value as String?,
            decoration: InputDecoration(labelText: _action.label),
            items: [
              for (final c in choices)
                DropdownMenuItem(value: c, child: Text(c))
            ],
            onChanged: _busy ? null : (v) => setState(() => _value = v));
      case BulkEditAction.type:
        return DropdownButtonFormField<PermanentId>(
            initialValue: _value as PermanentId?,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Battery Type'),
            items: [
              const DropdownMenuItem(
                  value: null, child: Text('Clear Battery Type')),
              for (final t in widget.types.where((t) => t.isActive))
                DropdownMenuItem(value: t.id, child: Text(t.typeName))
            ],
            onChanged: _busy ? null : (v) => setState(() => _value = v));
      case BulkEditAction.addSet:
      case BulkEditAction.removeSet:
        return DropdownButtonFormField<PermanentId>(
            key: ValueKey(_action),
            initialValue: _value as PermanentId?,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Battery Set'),
            items: [
              for (final s in _sets.where((s) =>
                  (_action == BulkEditAction.removeSet || s.active) &&
                  s.currentAssignment == null))
                DropdownMenuItem(
                    value: s.id,
                    child: Text(s.values.userSetId + ' · ' + s.values.name))
            ],
            onChanged: _busy ? null : (v) => setState(() => _value = v));
      case BulkEditAction.icon:
      case BulkEditAction.color:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_action == BulkEditAction.color
              ? 'Only color changes; each Battery keeps its icon.'
              : 'The chosen icon and color replace each selected Battery’s icon selection.'),
          Text(_value is IconSelection
              ? (_value as IconSelection).key +
                  ' / ' +
                  (_value as IconSelection).color.value
              : _value?.toString() ?? 'Choose a value'),
          OutlinedButton(
              onPressed: _busy
                  ? null
                  : () async {
                      final selection = await IconPickerDialog.show(context,
                          scope: IconScope.battery,
                          initialSelection: _value is IconSelection
                              ? _value as IconSelection
                              : const BatteryDraft(userBatteryId: '').icon);
                      if (selection != null && mounted)
                        setState(() => _value = _action == BulkEditAction.color
                            ? selection.color
                            : selection);
                    },
              child: const Text('Choose icon and color')),
          if (_action == BulkEditAction.color)
            DropdownButtonFormField<IconColor>(
                decoration: const InputDecoration(labelText: 'Preset color'),
                items: [
                  for (final p in IconColor.presets)
                    DropdownMenuItem(value: p.color, child: Text(p.label))
                ],
                onChanged: _busy ? null : (v) => setState(() => _value = v))
        ]);
      case BulkEditAction.retire:
        return Column(children: [
          AssignmentDateField(
              initial: _retired,
              label: 'Retirement date',
              enabled: !_busy,
              onChanged: (v) => _retired = v),
          DropdownButtonFormField<String>(
              initialValue: _reason,
              decoration: const InputDecoration(labelText: 'Retirement reason'),
              items: [
                for (final r in retirementReasons)
                  DropdownMenuItem(value: r, child: Text(r))
              ],
              onChanged: _busy ? null : (v) => setState(() => _reason = v!)),
          const Text(
              'Active Device assignments must be removed first. Set membership and all history are retained.')
        ]);
      default:
        return TextField(
            key: const ValueKey('bulk-edit-value'),
            controller: _text,
            enabled: !_busy,
            maxLines: _action == BulkEditAction.note ? 3 : 1,
            decoration: InputDecoration(
                labelText: _action.label,
                helperText: [
                  BulkEditAction.purchaseDate,
                  BulkEditAction.warrantyExpiration
                ].contains(_action)
                    ? 'YYYY-MM-DD; blank clears this field.'
                    : _action == BulkEditAction.note
                        ? 'Appends text; existing notes are retained.'
                        : _action == BulkEditAction.tag
                            ? 'Adds a tag; existing tags are retained.'
                            : 'Blank clears this field.'));
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !_busy,
      child: AlertDialog(
          title: const Text('Bulk Edit'),
          content: SizedBox(
              width: 900,
              height: MediaQuery.sizeOf(context).height * .7,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.ids.length.toString() + ' Batteries selected'),
                    if (_error != null)
                      Text(_error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    if (_busy) const Text('Working…'),
                    if (_done)
                      const Text('All changes saved successfully.')
                    else
                      Expanded(
                          child: ListView(children: [
                        if (_preview == null) ...[
                          DropdownButtonFormField<BulkEditAction>(
                              initialValue: _action,
                              isExpanded: true,
                              decoration:
                                  const InputDecoration(labelText: 'Action'),
                              items: [
                                for (final a in BulkEditAction.values)
                                  DropdownMenuItem(
                                      value: a, child: Text(a.label))
                              ],
                              onChanged: _busy ? null : (v) => _change(v!)),
                          const SizedBox(height: 16),
                          _input()
                        ] else ...[
                          Text(
                              'Review ' +
                                  _preview!.rows.length.toString() +
                                  ' Batteries · ' +
                                  _preview!.request.action.label,
                              style: Theme.of(context).textTheme.titleLarge),
                          for (final row in _preview!.rows)
                            Card(
                                child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(row.battery.values.userBatteryId,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium),
                                          Text('Before: ' + row.before),
                                          Text('After: ' + row.after),
                                          if (row
                                              .battery.currentSets.isNotEmpty)
                                            Text('Current Sets: ' +
                                                row.battery.currentSets
                                                    .join(', ')),
                                          if (row.battery.currentDevices
                                              .isNotEmpty)
                                            Text('Current Devices: ' +
                                                row.battery.currentDevices
                                                    .join(', '))
                                        ])))
                        ]
                      ]))
                  ])),
          actions: [
            TextButton(
                onPressed: _busy ? null : () => Navigator.pop(context, _done),
                child: Text(_done ? 'Done' : 'Cancel')),
            if (!_done && _preview != null)
              TextButton(
                  onPressed:
                      _busy ? null : () => setState(() => _preview = null),
                  child: const Text('Back to changes')),
            if (!_done)
              FilledButton(
                  onPressed: _busy
                      ? null
                      : _preview == null
                          ? () => _run(() async {
                                _preview = await ref
                                    .read(bulkEditRepositoryProvider)
                                    .preview(_request());
                              })
                          : _apply,
                  child: Text(
                      _preview == null ? 'Preview changes' : 'Confirm changes'))
          ]));
}
