import '../../qr_labels/domain/labels.dart';
import '../../qr_labels/presentation/qr_labels_page.dart';
import '../../bulk_operations/presentation/bulk_edit_dialog.dart';
import '../../bulk_operations/domain/bulk_edit.dart';
import '../../charging/presentation/charge_record_dialog.dart';
import '../../charging/application/charge_providers.dart';
import '../../battery_sets/presentation/battery_sets_page.dart';
import '../../../core/identity/permanent_id.dart';
import '../../bulk_operations/presentation/bulk_creation_dialog.dart';
import '../../charging/presentation/charge_tracking_page.dart';
import '../../assignments/presentation/assignments_page.dart';
import '../domain/battery_inventory_query.dart';
import '../../photos/domain/photo.dart';
import '../../photos/presentation/photo_manager_dialog.dart';
import '../../photos/presentation/photo_visual.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_providers.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../battery_types/domain/battery_type.dart';
import '../../battery_types/presentation/battery_type_icon.dart';
import '../domain/battery.dart';
import 'battery_form_dialog.dart';

final batteryInventoryProvider = FutureProvider<List<BatteryRecord>>(
    (ref) => ref.watch(batteryRepositoryProvider).list());
final inventoryTypesProvider = FutureProvider<List<BatteryTypeRecord>>((ref) =>
    ref.watch(batteryTypeRepositoryProvider).list(includeInactive: true));

class BatteriesPage extends ConsumerStatefulWidget {
  const BatteriesPage({this.initialId, super.key});
  final PermanentId? initialId;
  @override
  ConsumerState<BatteriesPage> createState() => _BatteriesPageState();
}

class _BatteriesPageState extends ConsumerState<BatteriesPage> {
  bool _openedInitial = false;
  final _selected = <PermanentId>{};
  final _reportedPhotos = <String>{};
  Widget _visual(BatteryRecord record, {double size = 48}) => PhotoVisual(
        root: ref.read(applicationSupportRootProvider),
        path: record.primaryPhotoPath,
        fallback: BatteryTypeIcon(selection: record.values.icon, size: size),
        size: size,
        onUnavailable: () {
          final path = record.primaryPhotoPath?.value;
          if (path != null && _reportedPhotos.add(path))
            ref
                .read(appLogServiceProvider)
                .logger('photos')
                .warning('Primary photograph unavailable: $path');
        },
      );
  String _search = '', _sort = 'Battery ID';
  bool _cards = false, _descending = false;
  final _filters = <String, String?>{};
  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(batteryInventoryProvider);
    final types = ref.watch(inventoryTypesProvider);
    return AppPageScaffold(
        title: 'Batteries',
        description:
            'Individual inventory • Icons identify inventory. Photographs add detail.',
        icon: Icons.battery_full,
        child: inventory.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => _error(e, s),
            data: (records) => types.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => _error(e, s),
                data: (catalog) => _content(records, catalog))));
  }

  Widget _error(Object e, StackTrace s) {
    ref
        .read(appLogServiceProvider)
        .logger('batteries')
        .severe('Inventory could not be loaded.', e, s);
    return Column(children: [
      const Text('Inventory could not be loaded.'),
      TextButton(onPressed: _refresh, child: const Text('Retry'))
    ]);
  }

  void _refresh() {
    ref.invalidate(batteryInventoryProvider);
    ref.invalidate(inventoryTypesProvider);
    ref.invalidate(batterySetsProvider);
  }

  String _type(BatteryDraft v, List<BatteryTypeRecord> types) =>
      BatteryInventoryQuery.typeName(v, types);
  Widget _content(List<BatteryRecord> records, List<BatteryTypeRecord> types) {
    if (!_openedInitial && widget.initialId != null) {
      _openedInitial = true;
      final match = records.where((b) => b.id == widget.initialId).firstOrNull;
      if (match != null)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _details(match, types);
        });
    }
    final visible = BatteryInventoryQuery.apply(records, types,
        search: _search,
        filters: _filters,
        sort: _sort,
        descending: _descending);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 20),
      Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.icon(
                onPressed: () => _edit(types),
                icon: const Icon(Icons.add),
                label: const Text('Add Battery')),
            Text(_selected.length.toString() + ' selected'),
            TextButton(
                onPressed: () =>
                    setState(() => _selected.addAll(visible.map((b) => b.id))),
                child: const Text('Select filtered')),
            TextButton(
                onPressed: () => setState(() => _selected.clear()),
                child: const Text('Clear selection')),
            OutlinedButton(
                onPressed: _selected.isEmpty
                    ? null
                    : () async {
                        await showDialog<void>(
                            context: context,
                            builder: (_) => QrLabelsDialog(
                                initialRefs: _selected
                                    .map(
                                        (id) => LabelRef(LabelKind.battery, id))
                                    .toList()));
                      },
                child: const Text('Create QR Labels')),
            OutlinedButton(
                onPressed: _selected.isEmpty
                    ? null
                    : () async {
                        await showDialog<bool>(
                            context: context,
                            builder: (_) => BulkEditDialog(
                                ids: _selected.toList(), types: types));
                        if (mounted) _refresh();
                      },
                child: const Text('Bulk Edit')),
            OutlinedButton(
                onPressed: _selected.isEmpty
                    ? null
                    : () async {
                        await showDialog<bool>(
                            context: context,
                            builder: (_) => BulkEditDialog(
                                ids: _selected.toList(),
                                types: types,
                                initialAction: BulkEditAction.retire));
                        if (mounted) _refresh();
                      },
                child: const Text('Retire Selected Batteries')),
            OutlinedButton(
                onPressed: _selected.isEmpty
                    ? null
                    : () async {
                        final chosen = records
                            .where((b) => _selected.contains(b.id))
                            .toList();
                        await showDialog<bool>(
                            context: context,
                            builder: (_) => ChargeRecordDialog(
                                batteryIds: chosen.map((b) => b.id).toList(),
                                labels: chosen
                                    .map((b) => b.values.userBatteryId)
                                    .toList(),
                                title: 'Mark Selected Charged'));
                        if (mounted) {
                          ref.invalidate(chargeHistoryProvider);
                          _refresh();
                        }
                      },
                child: const Text('Mark Selected Charged')),
            OutlinedButton(
                onPressed: () async {
                  await showDialog<bool>(
                      context: context,
                      builder: (_) => BulkCreationDialog(types: types));
                  if (mounted) _refresh();
                },
                child: const Text('Add Multiple Batteries')),
            OutlinedButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh')),
            SegmentedButton<bool>(segments: const [
              ButtonSegment(
                  value: false,
                  label: Text('Table'),
                  icon: Icon(Icons.table_rows)),
              ButtonSegment(
                  value: true,
                  label: Text('Cards'),
                  icon: Icon(Icons.grid_view))
            ], selected: {
              _cards
            }, onSelectionChanged: (v) => setState(() => _cards = v.single)),
            Text('${visible.length} of ${records.length} Batteries'),
          ]),
      const SizedBox(height: 16),
      TextField(
          decoration: const InputDecoration(
              labelText: 'Search Batteries', prefixIcon: Icon(Icons.search)),
          onChanged: (v) => setState(() => _search = v)),
      const SizedBox(height: 16),
      Wrap(spacing: 12, runSpacing: 12, children: [
        for (final field in [
          'Battery Type',
          'Manufacturer',
          'Chemistry',
          'Status',
          'Condition',
          'Batch ID',
          'Battery Set',
          'Device Assignment'
        ])
          SizedBox(
              width: 180,
              child: DropdownButtonFormField<String>(
                  key: ValueKey('$field-${_filters[field]}'),
                  initialValue: _filters[field],
                  isExpanded: true,
                  decoration: InputDecoration(labelText: field),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    for (final value in ({
                      for (final r in records)
                        ...BatteryInventoryQuery.attributes(r, types)[field]!,
                      if (_filters[field] != null) _filters[field]!
                    }.toList()
                      ..sort()))
                      DropdownMenuItem(
                          value: value,
                          child: Text(value, overflow: TextOverflow.ellipsis))
                  ],
                  onChanged: (v) => setState(() => _filters[field] = v))),
        SizedBox(
            width: 180,
            child: DropdownButtonFormField<String>(
                initialValue: _sort,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Sort by'),
                items: [
                  for (final s in [
                    'Battery ID',
                    'Name',
                    'Status',
                    'Condition',
                    'Created'
                  ])
                    DropdownMenuItem(value: s, child: Text(s))
                ],
                onChanged: (v) => setState(() => _sort = v!))),
        IconButton(
            tooltip: _descending ? 'Sort ascending' : 'Sort descending',
            onPressed: () => setState(() => _descending = !_descending),
            icon:
                Icon(_descending ? Icons.arrow_downward : Icons.arrow_upward)),
        TextButton(
            onPressed: () => setState(() => _filters.clear()),
            child: const Text('Clear filters')),
      ]),
      const SizedBox(height: 20),
      if (visible.isEmpty)
        Padding(
            padding: const EdgeInsets.all(32),
            child: Text(records.isEmpty
                ? 'Add your first Battery. A photograph is optional.'
                : 'No Batteries match these filters.'))
      else if (_cards)
        Wrap(spacing: 12, runSpacing: 12, children: [
          for (final r in visible)
            SizedBox(
                width: 260,
                child: Card(
                    child: InkWell(
                        onTap: () => _details(r, types),
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CheckboxListTile(
                                      title: const Text('Select'),
                                      value: _selected.contains(r.id),
                                      onChanged: (v) => setState(() {
                                            if (v == true) {
                                              _selected.add(r.id);
                                            } else {
                                              _selected.remove(r.id);
                                            }
                                          })),
                                  _visual(r),
                                  const SizedBox(height: 8),
                                  Text(r.values.userBatteryId,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  if (r.values.name != null)
                                    Text(r.values.name!),
                                  Text(
                                      '${r.values.status} • ${r.values.condition}'),
                                  Text(_type(r.values, types)),
                                  TextButton(
                                      onPressed: () => _details(r, types),
                                      child: const Text('View details'))
                                ])))))
        ])
      else
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(showCheckboxColumn: false, columns: [
              for (final c in [
                'Select',
                'Icon',
                'Battery ID',
                'Name',
                'Battery Type',
                'Capacity',
                'Status',
                'Condition'
              ])
                DataColumn(label: Text(c))
            ], rows: [
              for (final r in visible)
                DataRow(onSelectChanged: (_) => _details(r, types), cells: [
                  DataCell(Checkbox(
                      key: ValueKey('select-' + r.id.value),
                      value: _selected.contains(r.id),
                      onChanged: (v) => setState(() {
                            if (v == true) {
                              _selected.add(r.id);
                            } else {
                              _selected.remove(r.id);
                            }
                          }))),
                  DataCell(_visual(r, size: 32)),
                  DataCell(Text(r.values.userBatteryId)),
                  DataCell(Text(r.values.name ?? '—')),
                  DataCell(Text(_type(r.values, types))),
                  DataCell(Text(r.values.capacity == null
                      ? '—'
                      : '${r.values.capacity} ${r.values.capacityUnit}')),
                  DataCell(Text(r.values.status)),
                  DataCell(Text(r.values.condition))
                ])
            ])),
    ]);
  }

  Future<void> _edit(List<BatteryTypeRecord> types,
      [BatteryRecord? record]) async {
    final saved = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => BatteryFormDialog(types: types, record: record));
    if (saved == true && mounted) {
      _refresh();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Battery saved.')));
    }
  }

  Future<void> _details(BatteryRecord r, List<BatteryTypeRecord> types) async {
    final v = r.values;
    final history = ref.read(batteryRepositoryProvider).history(r.id);
    final edit = await showDialog<String>(
        context: context,
        builder: (c) => AlertDialog(
                title: Text(v.userBatteryId),
                content: SizedBox(
                    width: 660,
                    child: SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          _visual(r, size: 80),
                          const SizedBox(height: 16),
                          for (final e in <String, Object?>{
                            'Current Battery Set': r.currentSets.isEmpty
                                ? 'No Set'
                                : r.currentSets.join(', '),
                            'Current Device': r.currentDevices.isEmpty
                                ? 'Unassigned'
                                : r.currentDevices.join(', '),
                            'Retirement date': r.retiredAt?.toLocal(),
                            'Retirement reason': r.retirementReason,
                            'Recorded Charges': r.recordedCharges,
                            'Current manual charge estimate':
                                r.estimatedChargePercent == null
                                    ? 'Unknown'
                                    : '${r.estimatedChargePercent}%',
                            'Last Charged': r.lastCharged?.toLocal(),
                            'Battery name': v.name,
                            'Permanent UUID': r.id.value,
                            'Battery Type': _type(v, types),
                            'Batch ID': v.batchCode,
                            'Manufacturer': v.manufacturer,
                            'Model': v.model,
                            'Serial number': v.serialNumber,
                            'Custom label': v.customLabel,
                            'Chemistry': v.chemistry,
                            'Voltage': v.nominalVoltage,
                            'Capacity': v.capacity == null
                                ? null
                                : '${v.capacity} ${v.capacityUnit}',
                            'Rechargeable': v.rechargeable ? 'Yes' : 'No',
                            'Status': v.status,
                            'Condition': v.condition,
                            'Condition note': v.conditionNote,
                            'Purchase date': v.purchaseDate
                                ?.toIso8601String()
                                .substring(0, 10),
                            'Purchase location': v.purchaseLocation,
                            'Purchase price': v.purchasePrice,
                            'Total package price': v.totalPackagePrice,
                            'Per-battery price': v.perBatteryPrice,
                            'Warranty expiration': v.warrantyExpiration
                                ?.toIso8601String()
                                .substring(0, 10),
                            'Notes': v.notes,
                            'Created': r.createdAt.toLocal(),
                            'Modified': r.modifiedAt.toLocal(),
                          }.entries)
                            Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: SelectableText(
                                    '${e.key}: ${e.value ?? '—'}')),
                          const Divider(),
                          Text('Status and activity history',
                              style: Theme.of(c).textTheme.titleMedium),
                          FutureBuilder<List<String>>(
                              future: history,
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  ref
                                      .read(appLogServiceProvider)
                                      .logger('batteries')
                                      .severe(
                                          'Battery history could not be loaded.',
                                          snapshot.error,
                                          snapshot.stackTrace);
                                  return const Text(
                                      'History could not be loaded. Close and reopen details to retry.');
                                }
                                if (!snapshot.hasData)
                                  return const LinearProgressIndicator();
                                return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (final item in snapshot.data!)
                                        Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: Text(item))
                                    ]);
                              }),
                        ]))),
                actions: [
                  OutlinedButton(
                      onPressed: () => Navigator.pop(c, 'labels'),
                      child: const Text('Create QR Labels')),
                  OutlinedButton(
                      onPressed: () => Navigator.pop(c, 'charges'),
                      child: const Text('Charge tracking')),
                  OutlinedButton(
                      onPressed: () => Navigator.pop(c, 'assignments'),
                      child: const Text('Assignments')),
                  TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Close')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, 'edit'),
                      child: const Text('Edit Battery')),
                  OutlinedButton.icon(
                      onPressed: () => Navigator.pop(c, 'photos'),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Photographs')),
                ]));
    if (edit == 'labels' && mounted) {
      await showDialog<void>(
          context: context,
          builder: (_) =>
              QrLabelsDialog(initialRefs: [LabelRef(LabelKind.battery, r.id)]));
    }
    if (edit == 'charges' && mounted) {
      await showDialog<void>(
          context: context,
          builder: (_) => ChargeManagerDialog(batteryId: r.id));
      if (mounted) _refresh();
    }
    if (edit == 'edit' && mounted) await _edit(types, r);
    if (edit == 'assignments' && mounted) {
      await showDialog<void>(
          context: context,
          builder: (_) => AssignmentManagerDialog(batteryId: r.id));
      if (mounted) _refresh();
    }
    if (edit == 'photos' && mounted) {
      await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => PhotoManagerDialog(
              owner: PhotoOwner(PhotoOwnerKind.battery, r.id),
              fallback: BatteryTypeIcon(selection: v.icon, size: 80)));
      if (mounted) _refresh();
    }
  }
}
