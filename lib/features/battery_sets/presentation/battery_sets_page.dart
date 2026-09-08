import '../../qr_labels/domain/labels.dart';
import '../../qr_labels/presentation/qr_labels_page.dart';
import '../../charging/presentation/charge_record_dialog.dart';
import '../../charging/presentation/charge_tracking_page.dart';
import '../../charging/application/charge_providers.dart';
import '../../assignments/presentation/assignment_date_field.dart';
import '../../assignments/application/assignment_providers.dart';
import '../../devices/application/device_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_providers.dart';
import '../../../core/identity/permanent_id.dart';
import '../../batteries/presentation/batteries_page.dart';
import '../../icons/domain/icon_definition.dart';
import '../../icons/presentation/inventory_icon.dart';
import '../../photos/domain/photo.dart';
import '../../photos/presentation/photo_manager_dialog.dart';
import '../../photos/presentation/photo_visual.dart';
import '../domain/battery_set.dart';
import 'set_form_dialog.dart';

final batterySetsProvider = FutureProvider<List<SetRecord>>(
    (ref) => ref.watch(batterySetRepositoryProvider).list());

class BatterySetsPage extends ConsumerStatefulWidget {
  const BatterySetsPage({this.initialId, super.key});
  final PermanentId? initialId;
  @override
  ConsumerState<BatterySetsPage> createState() => _BatterySetsPageState();
}

class _BatterySetsPageState extends ConsumerState<BatterySetsPage> {
  PermanentId? _selected;
  @override
  void initState() {
    super.initState();
    _selected = widget.initialId;
    if (widget.initialId != null) _filter = 'All';
  }

  String _search = '', _filter = 'Active';
  bool _busy = false;
  String? _error;
  BatterySetRepository get _repo => ref.read(batterySetRepositoryProvider);
  void _refresh() {
    ref.invalidate(chargeHistoryProvider);
    ref.invalidate(assignmentsProvider);
    ref.invalidate(devicesProvider);
    ref.invalidate(batterySetsProvider);
    ref.invalidate(batteryInventoryProvider);
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      _refresh();
    } on SetValidationException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on Object catch (e, s) {
      ref
          .read(appLogServiceProvider)
          .logger('sets.ui')
          .severe('Set operation failed.', e, s);
      if (mounted)
        setState(() => _error =
            'The Set operation could not be completed. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _confirm(String title, String message,
      {bool notes = true,
      ValueChanged<DateTime>? onDateChanged,
      String dateLabel = 'Assignment date'}) async {
    var noteText = '';
    final result = await showDialog<String>(
        context: context,
        builder: (c) => AlertDialog(
                title: Text(title),
                content: SizedBox(
                    width: 520,
                    child: SingleChildScrollView(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(message),
                          if (onDateChanged != null)
                            AssignmentDateField(
                                initial: DateTime.now(),
                                onChanged: onDateChanged,
                                label: dateLabel),
                          if (notes)
                            TextField(
                                onChanged: (value) => noteText = value,
                                decoration: const InputDecoration(
                                    labelText: 'Notes (optional)'),
                                maxLines: 2)
                        ]))),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, noteText),
                      child: const Text('Confirm'))
                ]));
    return result;
  }

  Future<void> _warnings(Future<void> Function(Set<String>) action) async {
    var accepted = <String>{};
    while (mounted) {
      try {
        await action(accepted);
        return;
      } on SetWarnings catch (e) {
        final answer = await _confirm('Review compatibility warnings',
            e.messages.map((m) => '• $m').join('\n\n'),
            notes: false);
        if (answer == null) return;
        accepted = {...accepted, ...e.messages};
      }
    }
  }

  Future<void> _edit([SetRecord? r]) => _run(() async {
        final types = await ref
            .read(batteryTypeRepositoryProvider)
            .list(includeInactive: true);
        if (!mounted) return;
        await showDialog<bool>(
            context: context,
            builder: (_) => SetFormDialog(
                types: types,
                record: r,
                suggest: (p, n) => _repo.suggestId(prefix: p, start: n),
                save: (draft) async {
                  try {
                    final saved = await _repo.save(draft, id: r?.id);
                    _selected = saved.id;
                  } on Object catch (e, s) {
                    ref
                        .read(appLogServiceProvider)
                        .logger('sets.ui')
                        .severe('Saving Set failed.', e, s);
                    rethrow;
                  }
                }));
      });
  Widget _visual(SetRecord r, {double size = 48}) => PhotoVisual(
      root: ref.watch(applicationSupportRootProvider),
      path: r.primaryPhotoPath,
      size: size,
      fallback: InventoryIcon(
          selection: r.values.icon, scope: IconScope.batterySet, size: size),
      onUnavailable: () {});
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(batterySetsProvider);
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Battery Sets',
              style: Theme.of(context).textTheme.headlineMedium),
          const Text('Keep, charge, and use batteries together.'),
          const SizedBox(height: 16),
          Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                    width: 260,
                    child: TextField(
                        decoration: const InputDecoration(
                            labelText: 'Search Sets',
                            prefixIcon: Icon(Icons.search)),
                        onChanged: (v) =>
                            setState(() => _search = v.toLowerCase()))),
                DropdownButton<String>(
                    value: _filter,
                    items: [
                      for (final f in ['Active', 'Inactive', 'All'])
                        DropdownMenuItem(value: f, child: Text(f))
                    ],
                    onChanged: (v) => setState(() => _filter = v!)),
                FilledButton.icon(
                    onPressed: _busy ? null : () => _edit(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Set')),
                IconButton(
                    tooltip: 'Refresh',
                    onPressed: _busy ? null : _refresh,
                    icon: const Icon(Icons.refresh))
              ]),
          if (_busy) const Text('Working…'),
          if (_error != null)
            Padding(
                padding: const EdgeInsets.all(8),
                child: Text(_error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error))),
          const SizedBox(height: 12),
          Expanded(
              child: data.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                        const Text('Battery Sets could not be loaded.'),
                        TextButton(
                            onPressed: _refresh, child: const Text('Retry'))
                      ])),
                  data: (rows) {
                    final visible = rows
                        .where((r) =>
                            (_filter == 'All' ||
                                r.active == (_filter == 'Active')) &&
                            '${r.values.userSetId} ${r.values.name} ${r.values.description ?? ''}'
                                .toLowerCase()
                                .contains(_search))
                        .toList();
                    SetRecord? selected;
                    for (final r in rows) {
                      if (r.id == _selected) selected = r;
                    }
                    return ListView(children: [
                      if (visible.isEmpty)
                        const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                                'No matching Sets. Add a Set to organize your batteries.')),
                      for (final r in visible)
                        Card(
                            child: ListTile(
                                leading: _visual(r),
                                title: Text(
                                    '${r.values.userSetId} · ${r.values.name}'),
                                subtitle: Text(
                                    '${r.members.length} batteries · ${r.active ? 'Active' : 'Inactive'}${r.currentAssignment == null ? '' : ' · ${r.currentAssignment!.deviceName}'}'),
                                selected: r.id == _selected,
                                onTap: _busy
                                    ? null
                                    : () => setState(() => _selected = r.id))),
                      if (selected != null) _detail(selected)
                    ]);
                  }))
        ]));
  }

  Widget _button(String text, Future<void> Function() action,
          {bool enabled = true}) =>
      OutlinedButton(
          onPressed: _busy || !enabled ? null : () => _run(action),
          child: Text(text));
  Widget _detail(SetRecord r) => Card(
      child: Padding(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _visual(r, size: 80),
            Text('${r.values.userSetId} · ${r.values.name}',
                style: Theme.of(context).textTheme.titleLarge),
            SelectableText('Permanent ID: ${r.id.value}'),
            Text('Created: ${_date(r.createdAt)}'),
            Text('Battery Type: ${r.typeName ?? 'Not specified'}'),
            Text(
                'Current Device: ${r.currentAssignment?.deviceName ?? 'Unassigned'}'),
            if (r.values.description != null) Text(r.values.description!),
            if (r.values.notes != null) Text('Notes: ${r.values.notes}'),
            Text(
                'Recorded Charges: ${r.recordedCharges} · Last charged: ${_date(r.lastCharged)}'),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              OutlinedButton(
                  onPressed: _busy ? null : () => _edit(r),
                  child: const Text('Edit Set')),
              _button('Create QR Labels', () async {
                await showDialog<void>(
                    context: context,
                    builder: (_) => QrLabelsDialog(
                        initialRefs: [LabelRef(LabelKind.set, r.id)]));
              }),
              _button('Photographs', () async {
                await showDialog<void>(
                    context: context,
                    builder: (_) => PhotoManagerDialog(
                        owner: PhotoOwner(PhotoOwnerKind.batterySet, r.id),
                        fallback: InventoryIcon(
                            selection: r.values.icon,
                            scope: IconScope.batterySet,
                            size: 80)));
              }),
              _button('Add / Move Battery', () => _add(r),
                  enabled: r.active && r.currentAssignment == null),
              _button('Create member QR Labels', () async {
                await showDialog<void>(
                    context: context,
                    builder: (_) => QrLabelsDialog(
                        initialRefs: r.members
                            .map((b) => LabelRef(LabelKind.battery, b.id))
                            .toList()));
              }, enabled: r.members.isNotEmpty),
              _button('Charge history', () async {
                await showDialog<void>(
                    context: context,
                    builder: (_) => ChargeManagerDialog(setId: r.id));
              }),
              _button('Mark Entire Set Charged', () async {
                await showDialog<bool>(
                    context: context,
                    builder: (_) => ChargeRecordDialog(
                        setId: r.id,
                        labels: r.members
                            .map((b) => b.values.userBatteryId)
                            .toList(),
                        title: 'Mark Entire Set Charged'));
              }, enabled: r.active && r.members.isNotEmpty),
              _button(
                  r.currentAssignment == null
                      ? 'Assign Set to Device'
                      : 'Remove Set from Device', () async {
                if (r.currentAssignment == null) {
                  await _assign(r);
                } else {
                  var removedAt = DateTime.now();
                  final notes = await _confirm('Remove Set from Device',
                      'End this Set assignment and its linked member assignments?',
                      dateLabel: 'Removal date',
                      onDateChanged: (v) => removedAt = v);
                  if (notes != null)
                    await _repo.unassign(r.id,
                        notes: notes, removedAt: removedAt);
                }
              }, enabled: r.active && r.members.isNotEmpty),
              _button(r.active ? 'Deactivate Set' : 'Reactivate Set', () async {
                if (await _confirm(
                        r.active ? 'Deactivate Set' : 'Reactivate Set',
                        r.active
                            ? 'Membership history stays intact. Members remain listed in the inactive Set.'
                            : 'Make this Set active again?',
                        notes: false) !=
                    null) await _repo.setActive(r.id, !r.active);
              }, enabled: r.currentAssignment == null),
              _button('Delete Set', () async {
                if (await _confirm('Delete Set',
                        'Remove this Set from inventory and end its ${r.members.length} current memberships? Batteries and historical records are retained.',
                        notes: false) !=
                    null) {
                  await _repo.delete(r.id);
                  _selected = null;
                }
              }, enabled: r.currentAssignment == null)
            ]),
            const SizedBox(height: 20),
            Text('Current members (${r.members.length})',
                style: Theme.of(context).textTheme.titleMedium),
            if (r.currentAssignment != null)
              const Text(
                  'Remove the Set from its Device before changing membership.'),
            if (r.members.isEmpty) const Text('No batteries in this Set.'),
            for (final b in r.members)
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: PhotoVisual(
                      root: ref.watch(applicationSupportRootProvider),
                      path: b.primaryPhotoPath,
                      size: 48,
                      fallback: InventoryIcon(selection: b.values.icon),
                      onUnavailable: () {}),
                  title: Text(b.values.userBatteryId),
                  subtitle: Text(
                      '${b.values.manufacturer ?? 'Manufacturer not specified'} · ${b.values.capacity == null ? 'Capacity not specified' : '${b.values.capacity} ${b.values.capacityUnit}'} · ${b.values.condition}\n${b.values.status} · Recorded Charges: ${b.recordedCharges}\nLast charged: ${_date(b.lastCharged)}'),
                  trailing: IconButton(
                      tooltip: 'Remove ${b.values.userBatteryId}',
                      onPressed: _busy || r.currentAssignment != null
                          ? null
                          : () => _run(() async {
                                final notes = await _confirm('Remove Battery',
                                    'Remove ${b.values.userBatteryId} from this Set? Its history will be retained.');
                                if (notes != null)
                                  await _repo.removeMember(r.id, b.id,
                                      notes: notes);
                              }),
                      icon: const Icon(Icons.remove_circle_outline))),
            const Divider(),
            ExpansionTile(title: const Text('Set activity history'), children: [
              for (final entry in r.activityHistory)
                ListTile(title: Text(entry))
            ]),
            ExpansionTile(title: const Text('Membership history'), children: [
              for (final h in r.membershipHistory)
                ListTile(
                    title: Text(h.batteryLabel),
                    subtitle: Text(
                        'Added ${_date(h.addedAt)} · Removed ${_date(h.removedAt, empty: 'Current')}\n${h.notes ?? ''}'))
            ]),
            ExpansionTile(
                title: const Text('Device assignment history'),
                children: [
                  if (r.assignments.isEmpty)
                    const ListTile(title: Text('No assignments recorded.')),
                  for (final a in r.assignments)
                    ListTile(
                        title: Text(a.deviceName),
                        subtitle: Text(
                            'Assigned ${_date(a.assignedAt)} · Removed ${_date(a.removedAt, empty: 'Current')}\n${a.notes ?? ''}'))
                ])
          ])));
  Future<void> _add(SetRecord r) async {
    final batteries = await ref.read(batteryRepositoryProvider).list();
    final available =
        batteries.where((b) => !r.members.any((m) => m.id == b.id)).toList();
    if (!mounted) return;
    if (available.isEmpty)
      throw const SetValidationException(
          'Add more batteries to inventory before adding a member.');
    var chosen = available.first.id;
    var mode = MembershipAction.add;
    String notes = '';
    final ok = await showDialog<bool>(
        context: context,
        builder: (c) => StatefulBuilder(
            builder: (c, update) => AlertDialog(
                    title: const Text('Add or move Battery'),
                    content: SizedBox(
                        width: 560,
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          DropdownButtonFormField<PermanentId>(
                              initialValue: chosen,
                              isExpanded: true,
                              items: [
                                for (final b in available)
                                  DropdownMenuItem(
                                      value: b.id,
                                      child: Text(
                                          '${b.values.userBatteryId}${b.currentSets.isEmpty ? '' : ' · ${b.currentSets.join(', ')}'}'))
                              ],
                              onChanged: (v) => chosen = v!),
                          DropdownButtonFormField<MembershipAction>(
                              initialValue: mode,
                              items: const [
                                DropdownMenuItem(
                                    value: MembershipAction.add,
                                    child:
                                        Text('Add (keep other memberships)')),
                                DropdownMenuItem(
                                    value: MembershipAction.move,
                                    child: Text('Move (end other memberships)'))
                              ],
                              onChanged: (v) => mode = v!),
                          TextField(
                              decoration: const InputDecoration(
                                  labelText: 'Membership notes'),
                              onChanged: (v) => notes = v)
                        ])),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: const Text('Cancel')),
                      FilledButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: const Text('Add Battery'))
                    ])));
    if (ok == true)
      await _warnings((accepted) => _repo.addMember(r.id, chosen,
          action: mode, notes: notes, acceptedWarnings: accepted));
  }

  Future<void> _assign(SetRecord r) async {
    var devices = await _repo.devices();
    if (!mounted) return;
    final choice = await showDialog<String>(
        context: context,
        builder: (c) =>
            SimpleDialog(title: const Text('Assign Set to Device'), children: [
              for (final d in devices)
                SimpleDialogOption(
                    onPressed: () => Navigator.pop(c, d.id.value),
                    child: Text(d.name)),
              SimpleDialogOption(
                  onPressed: () => Navigator.pop(c, 'create'),
                  child: const Text('Create Device…'))
            ]));
    if (choice == null) return;
    PermanentId device;
    if (choice == 'create') {
      if (!mounted) return;
      String name = '', quantity = '', voltage = '';
      PermanentId? type;
      final types = await ref.read(batteryTypeRepositoryProvider).list();
      if (!mounted) return;
      final ok = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
                  title: const Text('Create Device'),
                  content: SizedBox(
                      width: 500,
                      child: SingleChildScrollView(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                        TextField(
                            decoration:
                                const InputDecoration(labelText: 'Device name'),
                            onChanged: (v) => name = v),
                        DropdownButtonFormField<PermanentId>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                                labelText: 'Required Battery Type (optional)'),
                            items: [
                              for (final t in types)
                                DropdownMenuItem(
                                    value: t.id, child: Text(t.typeName))
                            ],
                            onChanged: (v) => type = v),
                        TextField(
                            decoration: const InputDecoration(
                                labelText: 'Required quantity (optional)'),
                            onChanged: (v) => quantity = v),
                        TextField(
                            decoration: const InputDecoration(
                                labelText: 'Required voltage (optional)'),
                            onChanged: (v) => voltage = v)
                      ]))),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(c, false),
                        child: const Text('Cancel')),
                    FilledButton(
                        onPressed: () => Navigator.pop(c, true),
                        child: const Text('Create Device'))
                  ]));
      if (ok != true) return;
      if (quantity.trim().isNotEmpty && int.tryParse(quantity) == null ||
          voltage.trim().isNotEmpty && double.tryParse(voltage) == null)
        throw const SetValidationException(
            'Enter a whole quantity and numeric voltage.');
      device = (await _repo.createDevice(name,
              requiredTypeId: type,
              quantity: int.tryParse(quantity),
              voltage: double.tryParse(voltage)))
          .id;
    } else {
      device = PermanentId.parse(choice);
    }
    devices = await _repo.devices();
    final selected = devices.where((d) => d.id == device).firstOrNull;
    final matches = selected != null &&
        (selected.quantity != null ||
            selected.requiredTypeId != null ||
            selected.voltage != null) &&
        (selected.quantity == null || selected.quantity == r.members.length) &&
        r.members.every((b) =>
            (selected.requiredTypeId == null ||
                selected.requiredTypeId == b.values.batteryTypeId) &&
            (selected.voltage == null ||
                selected.voltage == b.values.nominalVoltage));
    if (!mounted) return;
    var assignedAt = DateTime.now();
    final notes = await _confirm('Assign Set',
        '${matches ? 'This Set matches the configured Device requirements.\n\n' : ''}Assign all ${r.members.length} current members to ${selected?.name ?? 'this Device'}?',
        onDateChanged: (v) => assignedAt = v);
    if (notes != null)
      await _warnings((accepted) => _repo.assign(r.id, device,
          notes: notes, acceptedWarnings: accepted, assignedAt: assignedAt));
  }

  String _date(DateTime? date, {String empty = 'Never'}) =>
      date == null ? empty : date.toLocal().toString().split('.').first;
}
