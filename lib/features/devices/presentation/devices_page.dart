import '../../qr_labels/domain/labels.dart';
import '../../qr_labels/presentation/qr_labels_page.dart';
import '../../assignments/presentation/assignments_page.dart';
import '../../assignments/application/assignment_providers.dart';
import '../../assignments/presentation/assignment_date_field.dart';
import '../application/device_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_providers.dart';
import '../../../core/identity/permanent_id.dart';
import '../../batteries/presentation/batteries_page.dart';
import '../../battery_sets/domain/battery_set.dart';
import '../../battery_sets/presentation/battery_sets_page.dart';
import '../../icons/domain/icon_definition.dart';
import '../../icons/presentation/inventory_icon.dart';
import '../../photos/domain/photo.dart';
import '../../photos/presentation/photo_visual.dart';
import '../../photos/presentation/photo_manager_dialog.dart';
import '../domain/device.dart';
import 'device_form_dialog.dart';

class DevicesPage extends ConsumerStatefulWidget {
  const DevicesPage({this.initialId, super.key});
  final PermanentId? initialId;
  @override
  ConsumerState<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends ConsumerState<DevicesPage> {
  PermanentId? _selected;
  @override
  void initState() {
    super.initState();
    _selected = widget.initialId;
    if (widget.initialId != null) _status = 'All';
  }

  String _search = '', _status = 'Active', _category = 'All categories';
  bool _busy = false;
  String? _error;
  DeviceRepository get _repo => ref.read(deviceRepositoryProvider);
  void _refresh() {
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
    } on DeviceValidationException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on SetValidationException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on Object catch (e, s) {
      ref
          .read(appLogServiceProvider)
          .logger('devices.ui')
          .severe('Device operation failed.', e, s);
      if (mounted)
        setState(() => _error =
            'The Device operation could not be completed. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _confirm(String title, String message,
      {bool notes = false,
      ValueChanged<DateTime>? onDateChanged,
      String dateLabel = 'Assignment date'}) async {
    var text = '';
    return showDialog<String>(
        context: context,
        builder: (c) => AlertDialog(
                title: Text(title),
                content: SizedBox(
                    width: 540,
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
                                decoration: const InputDecoration(
                                    labelText: 'Notes (optional)'),
                                onChanged: (v) => text = v)
                        ]))),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, text),
                      child: const Text('Confirm'))
                ]));
  }

  Future<void> _edit([DeviceRecord? r]) => _run(() async {
        final types = await ref
            .read(batteryTypeRepositoryProvider)
            .list(includeInactive: true);
        final devices = await _repo.list();
        if (!mounted) return;
        await showDialog<bool>(
            context: context,
            builder: (_) => DeviceFormDialog(
                types: types,
                categories: devices
                    .map((d) => d.values.category)
                    .whereType<String>()
                    .toSet()
                    .toList()
                  ..sort(),
                record: r,
                save: (draft) async {
                  try {
                    final saved = await _repo.save(draft, id: r?.id);
                    _selected = saved.id;
                  } on Object catch (e, s) {
                    ref
                        .read(appLogServiceProvider)
                        .logger('devices.ui')
                        .severe('Saving Device failed.', e, s);
                    rethrow;
                  }
                }));
      });
  Widget _visual(DeviceRecord r, {double size = 48}) => PhotoVisual(
      root: ref.watch(applicationSupportRootProvider),
      path: r.photoPath,
      size: size,
      fallback: InventoryIcon(
          selection: r.values.icon, scope: IconScope.device, size: size),
      onUnavailable: () {});
  Widget _button(String title, Future<void> Function() action,
          {bool enabled = true}) =>
      OutlinedButton(
          onPressed: _busy || !enabled ? null : () => _run(action),
          child: Text(title));
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(devicesProvider);
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Devices', style: Theme.of(context).textTheme.headlineMedium),
          const Text(
              'Equipment, battery requirements, and installed inventory.'),
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
                            labelText: 'Search Devices',
                            prefixIcon: Icon(Icons.search)),
                        onChanged: (v) =>
                            setState(() => _search = v.toLowerCase()))),
                DropdownButton<String>(
                    value: _status,
                    items: [
                      for (final s in ['Active', 'Inactive', 'All'])
                        DropdownMenuItem(value: s, child: Text(s))
                    ],
                    onChanged: (v) => setState(() => _status = v!)),
                DropdownButton<String>(
                    value: _category,
                    items: [
                      for (final c in {
                        'All categories',
                        _category,
                        ...?data.asData?.value
                            .map((d) => d.values.category)
                            .whereType<String>()
                      })
                        DropdownMenuItem(value: c, child: Text(c))
                    ],
                    onChanged: (v) => setState(() => _category = v!)),
                FilledButton.icon(
                    onPressed: _busy ? null : () => _edit(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Device')),
                IconButton(
                    tooltip: 'Refresh',
                    onPressed: _busy ? null : _refresh,
                    icon: const Icon(Icons.refresh))
              ]),
          if (_busy) const Text('Working…'),
          if (_error != null)
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          const SizedBox(height: 12),
          Expanded(
              child: data.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                        const Text('Devices could not be loaded.'),
                        TextButton(
                            onPressed: _refresh, child: const Text('Retry'))
                      ])),
                  data: (rows) {
                    final visible = rows
                        .where((r) =>
                            (_status == 'All' ||
                                r.active == (_status == 'Active')) &&
                            (_category == 'All categories' ||
                                r.values.category == _category) &&
                            [
                              r.values.name,
                              r.values.category,
                              r.values.manufacturer,
                              r.values.model,
                              r.values.serialNumber,
                              r.values.location,
                              r.values.description,
                              r.values.notes
                            ]
                                .whereType<String>()
                                .join(' ')
                                .toLowerCase()
                                .contains(_search))
                        .toList();
                    final selected =
                        rows.where((r) => r.id == _selected).firstOrNull;
                    return ListView(children: [
                      if (visible.isEmpty)
                        const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                                'No matching Devices. Add a Device with just a name and icon.')),
                      for (final r in visible)
                        Card(
                            child: ListTile(
                                leading: _visual(r),
                                title: Text(r.values.name),
                                subtitle: Text(
                                    '${r.values.category ?? 'Uncategorized'} · ${r.values.location ?? 'No location'} · ${r.batteries.length} Batteries · ${r.active ? 'Active' : 'Inactive'}'),
                                selected: r.id == _selected,
                                onTap: _busy
                                    ? null
                                    : () => setState(() => _selected = r.id))),
                      if (selected != null) _detail(selected)
                    ]);
                  })),
        ]));
  }

  Widget _detail(DeviceRecord r) {
    final v = r.values;
    final warnings = v.assess(r.batteries);
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _visual(r, size: 80),
              Text(v.name, style: Theme.of(context).textTheme.titleLarge),
              SelectableText('Permanent ID: ${r.id.value}'),
              Text(
                  'Added: ${_date(r.createdAt)} · ${r.active ? 'Active' : 'Inactive'}'),
              for (final e in {
                'Category': v.category,
                'Manufacturer': v.manufacturer,
                'Model': v.model,
                'Serial number': v.serialNumber,
                'Location': v.location,
                'Description': v.description,
                'Notes': v.notes
              }.entries)
                if (e.value != null) Text('${e.key}: ${e.value}'),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                OutlinedButton(
                    onPressed: _busy ? null : () => _edit(r),
                    child: const Text('Edit Device')),
                _button('Create QR Labels', () async {
                  await showDialog<void>(
                      context: context,
                      builder: (_) => QrLabelsDialog(
                          initialRefs: [LabelRef(LabelKind.device, r.id)]));
                }),
                _button('Photographs', () async {
                  await showDialog<void>(
                      context: context,
                      builder: (_) => PhotoManagerDialog(
                          owner: PhotoOwner(PhotoOwnerKind.device, r.id),
                          fallback: InventoryIcon(
                              selection: v.icon,
                              scope: IconScope.device,
                              size: 80)));
                }),
                _button('Battery assignments', () async {
                  await showDialog<void>(
                      context: context,
                      builder: (_) => AssignmentManagerDialog(deviceId: r.id));
                }),
                _button('Assign Battery Set', () => _assign(r),
                    enabled: r.active),
                _button(r.active ? 'Mark Inactive' : 'Reactivate Device',
                    () async {
                  if (await _confirm(
                          r.active
                              ? 'Mark Device Inactive'
                              : 'Reactivate Device',
                          r.active
                              ? 'Keep this Device and its history, but hide it from active assignment choices?'
                              : 'Make this Device available for assignments again?') !=
                      null) await _repo.setActive(r.id, !r.active);
                }, enabled: !r.isAssigned),
                _button('Delete Device', () async {
                  if (await _confirm('Delete Device',
                          'Remove this Device from inventory? Its history and photographs are retained. No Batteries or Sets will be deleted.') !=
                      null) {
                    await _repo.delete(r.id);
                    _selected = null;
                  }
                }, enabled: !r.isAssigned)
              ]),
              if (r.isAssigned)
                const Text(
                    'Remove all assigned inventory before deactivating or deleting this Device.'),
              const SizedBox(height: 20),
              Text('Battery requirements',
                  style: Theme.of(context).textTheme.titleMedium),
              Text(
                  'Type: ${r.typeName ?? 'Any'} · Quantity: ${v.quantity ?? 'Any'} · Voltage: ${v.voltage ?? 'Any'}'),
              if (v.requirementNotes != null) Text(v.requirementNotes!),
              if (!v.hasRequirements)
                const Text('No battery requirements configured.')
              else if (r.batteries.isEmpty && warnings.isEmpty)
                const Text('Assign inventory to check these requirements.')
              else if (warnings.isEmpty)
                const Text(
                    'Assigned Batteries match the configured requirements.')
              else
                for (final w in warnings)
                  Text(w,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: 16),
              Text('Current Battery Sets (${r.currentSets.length})',
                  style: Theme.of(context).textTheme.titleMedium),
              for (final a in r.currentSets)
                ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(a.label),
                    subtitle: Text('Assigned ${_date(a.assignedAt)}'),
                    trailing: TextButton(
                        onPressed: _busy
                            ? null
                            : () => _run(() async {
                                  var removedAt = DateTime.now();
                                  final notes = await _confirm(
                                      'Remove Battery Set',
                                      'End this Set assignment and all its linked member assignments?',
                                      notes: true,
                                      dateLabel: 'Removal date',
                                      onDateChanged: (v) => removedAt = v);
                                  if (notes != null)
                                    await ref
                                        .read(batterySetRepositoryProvider)
                                        .unassign(a.subjectId,
                                            notes: notes, removedAt: removedAt);
                                }),
                        child: const Text('Remove Set'))),
              if (r.currentSets.isEmpty) const Text('No Set assigned.'),
              Text('Current Batteries (${r.batteries.length})',
                  style: Theme.of(context).textTheme.titleMedium),
              for (final b in r.batteries)
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
                        '${b.values.status} · ${b.values.condition} · Recorded Charges: ${b.recordedCharges}')),
              if (r.batteries.isEmpty) const Text('No Batteries assigned.'),
              ExpansionTile(title: const Text('Assignment history'), children: [
                if (r.assignments.isEmpty)
                  const ListTile(title: Text('No assignment history.')),
                for (final a in r.assignments)
                  ListTile(
                      title: Text('${a.label}${a.fromSet ? ' (via Set)' : ''}'),
                      subtitle: Text(
                          'Assigned ${_date(a.assignedAt)} · Removed ${_date(a.removedAt, empty: 'Current')}\n${a.notes ?? ''}'))
              ]),
              ExpansionTile(
                  title: const Text('Device activity history'),
                  children: [
                    for (final a in r.activity) ListTile(title: Text(a))
                  ])
            ])));
  }

  Future<void> _assign(DeviceRecord device) async {
    final repo = ref.read(batterySetRepositoryProvider);
    final sets = (await repo.list())
        .where((s) =>
            s.active && s.currentAssignment == null && s.members.isNotEmpty)
        .toList();
    if (sets.isEmpty)
      throw const DeviceValidationException(
          'Create a nonempty, unassigned Battery Set before assigning it.');
    if (!mounted) return;
    final selected = await showDialog<SetRecord>(
        context: context,
        builder: (c) =>
            SimpleDialog(title: const Text('Choose Battery Set'), children: [
              for (final s in sets)
                SimpleDialogOption(
                    onPressed: () => Navigator.pop(c, s),
                    child: Text(
                        '${s.values.userSetId} · ${s.values.name} · ${s.members.length} Batteries'))
            ]));
    if (selected == null || !mounted) return;
    final matches = device.values.hasRequirements &&
        device.values.assess(selected.members).isEmpty;
    var assignedAt = DateTime.now();
    final notes = await _confirm('Assign Battery Set',
        '${matches ? 'This Set matches the configured requirements.\n\n' : ''}Assign ${selected.values.name} and its ${selected.members.length} current Batteries to ${device.values.name}?',
        notes: true, onDateChanged: (v) => assignedAt = v);
    if (notes == null) return;
    var accepted = <String>{};
    while (mounted) {
      try {
        await repo.assign(selected.id, device.id,
            notes: notes, acceptedWarnings: accepted, assignedAt: assignedAt);
        return;
      } on SetWarnings catch (e) {
        if (await _confirm('Review compatibility warnings',
                e.messages.map((w) => '• $w').join('\n\n')) ==
            null) return;
        accepted = {...accepted, ...e.messages};
      }
    }
  }

  String _date(DateTime? value, {String empty = 'Never'}) =>
      value == null ? empty : value.toLocal().toString().split('.').first;
}
