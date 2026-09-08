import '../../qr_labels/domain/labels.dart';
import '../../qr_labels/presentation/qr_labels_page.dart';
import '../../batteries/presentation/batteries_page.dart';
import '../../battery_sets/presentation/battery_sets_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_providers.dart';
import '../../../core/identity/permanent_id.dart';
import '../../batteries/domain/battery.dart';
import '../../batteries/presentation/battery_form_dialog.dart';
import '../../battery_types/domain/battery_type.dart';
import '../../battery_types/presentation/battery_type_icon.dart';
import '../../battery_sets/domain/battery_set.dart';
import '../domain/bulk_creation.dart';

class BulkCreationDialog extends ConsumerStatefulWidget {
  const BulkCreationDialog({required this.types, super.key});
  final List<BatteryTypeRecord> types;
  @override
  ConsumerState<BulkCreationDialog> createState() => _BulkCreationDialogState();
}

class _BulkCreationDialogState extends ConsumerState<BulkCreationDialog> {
  final _prefix = TextEditingController(text: 'AA'),
      _separator = TextEditingController(text: '-'),
      _start = TextEditingController(text: '1'),
      _padding = TextEditingController(text: '3'),
      _quantity = TextEditingController(text: '4'),
      _tags = TextEditingController();
  BatteryDraft _shared = const BatteryDraft(userBatteryId: 'Shared defaults');
  List<BulkRow> _rows = [];
  List<SetRecord> _sets = [];
  final _newSets = <String, SetDraft>{};
  Set<String> _existing = {};
  String? _defaultSet, _error;
  bool _busy = false, _total = false;
  BulkResult? _result;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [_prefix, _separator, _start, _padding, _quantity, _tags]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    await _run(() async {
      _existing = await ref.read(bulkCreationRepositoryProvider).existingIds();
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
          .logger('bulk_creation')
          .severe('Bulk creation failed.', e, s);
      if (mounted)
        setState(() => _error =
            'Could not complete bulk creation. No partial batch was saved. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editShared() async {
    final draft = await showDialog<BatteryDraft>(
        context: context,
        builder: (_) => BatteryFormDialog(
            types: widget.types, initialDraft: _shared, draftOnly: true));
    if (draft != null && mounted) setState(() => _shared = draft);
  }

  BulkRow _row(BatteryDraft draft, String? target) => BulkRow(draft,
      existingSet: target != null && target.startsWith('existing:')
          ? PermanentId.parse(target.substring(9))
          : null,
      newSet: target != null && target.startsWith('new:')
          ? target.substring(4)
          : null);
  String? _target(BulkRow r) => r.existingSet != null
      ? 'existing:' + r.existingSet!.value
      : r.newSet != null
          ? 'new:' + r.newSet!
          : null;
  Future<void> _generate({bool next = false}) => _run(() async {
        if (_rows.isNotEmpty) {
          final confirmed = await showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                      title: const Text('Replace preview?'),
                      content: const Text(
                          'Regenerating applies shared defaults and replaces current row edits.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(c, false),
                            child: const Text('Cancel')),
                        FilledButton(
                            onPressed: () => Navigator.pop(c, true),
                            child: const Text('Replace preview'))
                      ]));
          if (confirmed != true) return;
        }
        int number(TextEditingController c) => int.tryParse(c.text) ?? -1;
        _existing =
            await ref.read(bulkCreationRepositoryProvider).existingIds();
        final ids = BulkIds.generate(
            prefix: _prefix.text,
            separator: _separator.text,
            start: number(_start),
            padding: number(_padding),
            quantity: number(_quantity),
            existing: _existing,
            nextAvailable: next);
        _shared.validate();
        final price = _shared.purchasePrice;
        _rows = ids
            .map((id) => _row(
                bulkCopy(_shared,
                    id: id,
                    total: _total ? price : null,
                    per: _total && price != null ? price / ids.length : price),
                _defaultSet))
            .toList();
      });
  Future<void> _editRow(int index) async {
    final row = _rows[index];
    final draft = await showDialog<BatteryDraft>(
        context: context,
        builder: (_) => BatteryFormDialog(
            types: widget.types, initialDraft: row.battery, draftOnly: true));
    if (draft != null && mounted)
      setState(() => _rows[index] = _row(draft, _target(row)));
  }

  Future<void> _createSet() async {
    var id = '', name = '';
    String? error;
    final draft = await showDialog<SetDraft>(
        context: context,
        builder: (c) => StatefulBuilder(
            builder: (c, update) => AlertDialog(
                    title: const Text('Create Battery Set in preview'),
                    content: SizedBox(
                        width: 450,
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          if (error != null) Text(error!),
                          TextField(
                              key: const ValueKey('bulk-set-id'),
                              decoration:
                                  const InputDecoration(labelText: 'Set ID'),
                              onChanged: (v) => id = v),
                          TextField(
                              key: const ValueKey('bulk-set-name'),
                              decoration:
                                  const InputDecoration(labelText: 'Set name'),
                              onChanged: (v) => name = v)
                        ])),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(c),
                          child: const Text('Cancel')),
                      FilledButton(
                          onPressed: () {
                            if (id.trim().isEmpty || name.trim().isEmpty) {
                              update(() => error = 'Enter a Set ID and name.');
                              return;
                            }
                            if (_newSets.values.any((s) =>
                                    s.userSetId.toLowerCase() ==
                                    id.trim().toLowerCase()) ||
                                _sets.any((s) =>
                                    s.values.userSetId.toLowerCase() ==
                                    id.trim().toLowerCase())) {
                              update(
                                  () => error = 'This Set ID already exists.');
                              return;
                            }
                            Navigator.pop(
                                c,
                                SetDraft(
                                    userSetId: id.trim(), name: name.trim()));
                          },
                          child: const Text('Add preview Set'))
                    ])));
    if (draft != null && mounted)
      setState(() {
        final key = const UuidV4PermanentIdGenerator().next().value;
        _newSets[key] = draft;
        _defaultSet = 'new:' + key;
      });
  }

  Future<void> _save() => _run(() async {
        final request = BulkRequest(
            rows: _rows, newSets: _newSets, tags: _tags.text.split(','));
        final accepted = <String>{};
        while (true) {
          try {
            _result = await ref
                .read(bulkCreationRepositoryProvider)
                .save(request, acceptedWarnings: accepted);
            if (mounted) {
              ref.invalidate(batteryInventoryProvider);
              ref.invalidate(batterySetsProvider);
            }
            break;
          } on SetWarnings catch (e) {
            if (!mounted) return;
            final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                        title: const Text('Set compatibility warning'),
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
      });
  Widget _setPicker(String? value, ValueChanged<String?> change) =>
      DropdownButtonFormField<String>(
          key: ValueKey(value),
          initialValue: value,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Battery Set'),
          items: [
            const DropdownMenuItem<String>(value: null, child: Text('No Set')),
            for (final s
                in _sets.where((s) => s.active && s.currentAssignment == null))
              DropdownMenuItem(
                  value: 'existing:' + s.id.value,
                  child: Text(s.values.userSetId + ' · ' + s.values.name)),
            for (final e in _newSets.entries)
              DropdownMenuItem(
                  value: 'new:' + e.key,
                  child:
                      Text(e.value.userSetId + ' · ' + e.value.name + ' (new)'))
          ],
          onChanged: _busy ? null : change);
  @override
  Widget build(BuildContext context) {
    final duplicates = BulkIds.duplicates(_rows, _existing);
    return PopScope(
        canPop: !_busy,
        child: AlertDialog(
            title: const Text('Add Multiple Batteries'),
            content: SizedBox(
                width: 1050,
                height: MediaQuery.sizeOf(context).height * .75,
                child: _result != null
                    ? SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Text('Created ' +
                                _result!.batteries.length.toString() +
                                ' Batteries and ' +
                                _result!.sets.length.toString() +
                                ' Sets.'),
                            const Text(
                                'Each Battery has its own UUID, icon, and history. Batch and Set memberships were saved together.'),
                            for (final row in _rows)
                              Text(row.battery.userBatteryId)
                          ]))
                    : Column(children: [
                        if (_error != null)
                          Text(_error!,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error)),
                        if (_busy) const Text('Working…'),
                        Expanded(
                            child: ListView(children: [
                          const Text(
                              '1. Configure shared values and IDs. 2. Generate and edit the preview. 3. Confirm the exact preview to save.'),
                          Wrap(spacing: 12, runSpacing: 8, children: [
                            for (final entry in {
                              'Prefix': _prefix,
                              'Separator': _separator,
                              'Starting number': _start,
                              'Padding': _padding,
                              'Quantity': _quantity
                            }.entries)
                              SizedBox(
                                  width: 160,
                                  child: TextField(
                                      key: ValueKey('bulk-' + entry.key),
                                      controller: entry.value,
                                      enabled: !_busy,
                                      decoration: InputDecoration(
                                          labelText: entry.key)))
                          ]),
                          Wrap(
                              spacing: 12,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                BatteryTypeIcon(selection: _shared.icon),
                                OutlinedButton(
                                    onPressed: _busy ? null : _editShared,
                                    child: const Text(
                                        'Edit shared fields, icon and color')),
                                Text('Batch: ' + (_shared.batchCode ?? 'None'))
                              ]),
                          const Text(
                              'Shared changes apply when you generate a preview. Use row Edit to override individual values.'),
                          SwitchListTile(
                              title: const Text(
                                  'Purchase price is the total purchase price'),
                              subtitle: const Text(
                                  'Otherwise it is per Battery. Total is preserved and approximate per-Battery cost is calculated in the generated preview.'),
                              value: _total,
                              onChanged: _busy
                                  ? null
                                  : (v) => setState(() => _total = v)),
                          TextField(
                              controller: _tags,
                              enabled: !_busy,
                              decoration: const InputDecoration(
                                  labelText:
                                      'Shared tags (comma-separated, optional)')),
                          _setPicker(_defaultSet,
                              (v) => setState(() => _defaultSet = v)),
                          Wrap(spacing: 12, runSpacing: 8, children: [
                            OutlinedButton(
                                onPressed: _busy ? null : _createSet,
                                child: const Text('Create Battery Set')),
                            OutlinedButton(
                                onPressed: _busy || _rows.isEmpty
                                    ? null
                                    : () => setState(() => _rows = _rows
                                        .map(
                                            (r) => _row(r.battery, _defaultSet))
                                        .toList()),
                                child: const Text(
                                    'Apply Set to all preview rows')),
                            FilledButton(
                                onPressed: _busy ? null : () => _generate(),
                                child: const Text('Generate preview')),
                            OutlinedButton(
                                onPressed:
                                    _busy ? null : () => _generate(next: true),
                                child: const Text('Use Next Available IDs'))
                          ]),
                          if (duplicates.isNotEmpty) ...[
                            Text('Duplicate IDs: ' + duplicates.join(', '),
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.error)),
                            TextButton(
                                onPressed: _busy
                                    ? null
                                    : () => setState(() {
                                          final seen = _existing
                                              .map((s) => s.toLowerCase())
                                              .toSet();
                                          _rows = _rows
                                              .where((r) => seen.add(r
                                                  .battery.userBatteryId
                                                  .trim()
                                                  .toLowerCase()))
                                              .toList();
                                        }),
                                child: const Text('Skip Existing IDs'))
                          ],
                          Text('Preview: ' +
                              _rows.length.toString() +
                              ' Batteries'),
                          for (var i = 0; i < _rows.length; i++)
                            Card(
                                child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Wrap(
                                              spacing: 12,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                BatteryTypeIcon(
                                                    selection:
                                                        _rows[i].battery.icon),
                                                Text(
                                                    _rows[i]
                                                        .battery
                                                        .userBatteryId,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium),
                                                Text(_rows[i].battery.name ??
                                                    ''),
                                                OutlinedButton(
                                                    key: ValueKey('bulk-edit-' +
                                                        i.toString()),
                                                    onPressed: _busy
                                                        ? null
                                                        : () => _editRow(i),
                                                    child: const Text('Edit'))
                                              ]),
                                          Text('Batch: ' +
                                              (_rows[i].battery.batchCode ??
                                                  'None') +
                                              ' · Per Battery: ' +
                                              (_rows[i]
                                                      .battery
                                                      .perBatteryPrice
                                                      ?.toStringAsFixed(2) ??
                                                  'Not entered') +
                                              ' · Total: ' +
                                              (_rows[i]
                                                      .battery
                                                      .totalPackagePrice
                                                      ?.toStringAsFixed(2) ??
                                                  'Not entered')),
                                          if (_rows[i]
                                                  .battery
                                                  .notes
                                                  ?.isNotEmpty ??
                                              false)
                                            Text(_rows[i].battery.notes!),
                                          _setPicker(
                                              _target(_rows[i]),
                                              (v) => setState(() => _rows[i] =
                                                  _row(_rows[i].battery, v)))
                                        ]))),
                        ]))
                      ])),
            actions: [
              TextButton(
                  onPressed: _busy
                      ? null
                      : () => Navigator.pop(context, _result != null),
                  child: Text(_result != null ? 'Done' : 'Cancel')),
              if (_result != null)
                OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () async {
                            await showDialog<void>(
                                context: context,
                                builder: (_) => QrLabelsDialog(
                                    initialRefs: _result!.batteries
                                        .map((id) =>
                                            LabelRef(LabelKind.battery, id))
                                        .toList()));
                          },
                    child: const Text('Create QR Labels')),
              if (_result == null)
                FilledButton(
                    onPressed: _busy || _rows.isEmpty || duplicates.isNotEmpty
                        ? null
                        : _save,
                    child: const Text('Confirm preview and save'))
            ]));
  }
}
