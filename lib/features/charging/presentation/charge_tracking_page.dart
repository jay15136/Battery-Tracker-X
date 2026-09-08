import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_providers.dart';
import '../../../core/identity/permanent_id.dart';
import '../../batteries/domain/battery.dart';
import '../../batteries/presentation/batteries_page.dart';
import '../../battery_sets/presentation/battery_sets_page.dart';
import '../../devices/application/device_providers.dart';
import '../application/charge_providers.dart';
import '../domain/charge.dart';
import 'charge_record_dialog.dart';

class ChargeManagerDialog extends StatelessWidget {
  const ChargeManagerDialog({this.batteryId, this.setId, super.key});
  final PermanentId? batteryId, setId;
  @override
  Widget build(BuildContext context) => Dialog(
      child: SizedBox(
          width: 1050,
          height: MediaQuery.sizeOf(context).height * .85,
          child: Column(children: [
            Expanded(
                child: ChargeTrackingPage(batteryId: batteryId, setId: setId)),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'))
          ])));
}

class ChargeTrackingPage extends ConsumerStatefulWidget {
  const ChargeTrackingPage({this.batteryId, this.setId, super.key});
  final PermanentId? batteryId, setId;
  @override
  ConsumerState<ChargeTrackingPage> createState() => _ChargeTrackingPageState();
}

class _ChargeTrackingPageState extends ConsumerState<ChargeTrackingPage> {
  final _selected = <PermanentId>{};
  String _query = '';
  bool _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    if (widget.batteryId != null) _selected.add(widget.batteryId!);
  }

  void _refresh() {
    ref.invalidate(chargeHistoryProvider);
    ref.invalidate(batteryInventoryProvider);
    ref.invalidate(batterySetsProvider);
    ref.invalidate(devicesProvider);
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
    } on ChargeValidationException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on Object catch (e, s) {
      if (mounted) {
        ref
            .read(appLogServiceProvider)
            .logger('charging.ui')
            .severe('Charge operation failed.', e, s);
        setState(() => _error =
            'The charge operation could not be completed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _record(List<BatteryRecord> batteries) => _run(() async {
        if (widget.setId != null) {
          final set =
              await ref.read(batterySetRepositoryProvider).get(widget.setId!);
          if (!mounted) return;
          await showDialog<bool>(
              context: context,
              builder: (_) => ChargeRecordDialog(
                  setId: set.id,
                  labels:
                      set.members.map((b) => b.values.userBatteryId).toList(),
                  title: 'Mark Entire Set Charged'));
        } else {
          final chosen =
              batteries.where((b) => _selected.contains(b.id)).toList();
          if (chosen.isEmpty)
            throw const ChargeValidationException(
                'Select at least one Battery.');
          await showDialog<bool>(
              context: context,
              builder: (_) => ChargeRecordDialog(
                  batteryIds: chosen.map((b) => b.id).toList(),
                  labels: chosen.map((b) => b.values.userBatteryId).toList(),
                  title: chosen.length == 1
                      ? 'Mark Charged'
                      : 'Mark Selected Charged'));
        }
      });
  Future<void> _estimate(BatteryRecord battery) => _run(() async {
        var value = battery.estimatedChargePercent?.toString() ?? '';
        String? error;
        var saving = false;
        if (!mounted) return;
        await showDialog<bool>(
            context: context,
            builder: (c) => StatefulBuilder(
                builder: (c, update) => PopScope(
                    canPop: !saving,
                    child: AlertDialog(
                        title: Text(
                            'Current estimate · ${battery.values.userBatteryId}'),
                        content: SizedBox(
                            width: 500,
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                      'Manual estimate, 0–100%. Clear the field for unknown. This does not record a charge.'),
                                  if (error != null)
                                    Text(error!,
                                        style: TextStyle(
                                            color:
                                                Theme.of(c).colorScheme.error)),
                                  TextFormField(
                                      initialValue: value,
                                      enabled: !saving,
                                      decoration: const InputDecoration(
                                          labelText: 'Current manual estimate'),
                                      onChanged: (v) => value = v)
                                ])),
                        actions: [
                          TextButton(
                              onPressed:
                                  saving ? null : () => Navigator.pop(c, false),
                              child: const Text('Cancel')),
                          FilledButton(
                              onPressed: saving
                                  ? null
                                  : () async {
                                      final p = value.trim().isEmpty
                                          ? null
                                          : int.tryParse(value.trim());
                                      if (value.trim().isNotEmpty &&
                                          p == null) {
                                        update(() => error =
                                            'Enter a whole number from 0 to 100.');
                                        return;
                                      }
                                      update(() => saving = true);
                                      try {
                                        await ref
                                            .read(chargeRepositoryProvider)
                                            .setEstimate(battery.id, p);
                                        if (c.mounted) Navigator.pop(c, true);
                                      } on ChargeValidationException catch (e) {
                                        if (c.mounted)
                                          update(() => error = e.message);
                                      } on Object catch (e, s) {
                                        ref
                                            .read(appLogServiceProvider)
                                            .logger('charging.ui')
                                            .severe('Saving estimate failed.',
                                                e, s);
                                        if (c.mounted)
                                          update(() => error =
                                              'The estimate could not be saved.');
                                      } finally {
                                        if (c.mounted)
                                          update(() => saving = false);
                                      }
                                    },
                              child: const Text('Save estimate'))
                        ]))));
      });
  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(batteryInventoryProvider),
        history = ref.watch(chargeHistoryProvider);
    return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Charge Tracking',
              style: Theme.of(context).textTheme.headlineMedium),
          const Text(
              'Recorded Charges track logged events. Current percentages are manual estimates.'),
          if (_busy) const Text('Working…'),
          if (_error != null)
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          Expanded(
              child: inventory.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => TextButton(
                      onPressed: () => setState(_refresh),
                      child: const Text('Could not load Batteries. Retry')),
                  data: (all) {
                    final rows = all
                        .where((b) =>
                            (widget.batteryId == null ||
                                b.id == widget.batteryId) &&
                            b.values.userBatteryId
                                .toLowerCase()
                                .contains(_query))
                        .toList();
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                FilledButton(
                                    onPressed: _busy ||
                                            (_selected.isEmpty &&
                                                widget.setId == null)
                                        ? null
                                        : () => _record(all),
                                    child: Text(widget.setId != null
                                        ? 'Mark Entire Set Charged'
                                        : widget.batteryId != null
                                            ? 'Mark Charged'
                                            : 'Mark Selected Charged')),
                                if (widget.setId == null)
                                  SizedBox(
                                      width: 230,
                                      child: TextField(
                                          decoration: const InputDecoration(
                                              labelText: 'Find Batteries'),
                                          onChanged: (v) => setState(
                                              () => _query = v.toLowerCase()))),
                                IconButton(
                                    tooltip: 'Refresh',
                                    onPressed:
                                        _busy ? null : () => setState(_refresh),
                                    icon: const Icon(Icons.refresh))
                              ]),
                          Expanded(
                              child: ListView(children: [
                            if (widget.setId == null) ...[
                              Text('${_selected.length} selected'),
                              if (rows.isEmpty)
                                const Text('No matching Batteries.'),
                              for (final b in rows)
                                Card(
                                    child: ListTile(
                                        leading: Checkbox(
                                            value: _selected.contains(b.id),
                                            onChanged: _busy ||
                                                    !b.values.rechargeable ||
                                                    b.values.status ==
                                                        'Retired' ||
                                                    b.values.condition ==
                                                        'Retired'
                                                ? null
                                                : (v) => setState(() {
                                                      if (v == true) {
                                                        _selected.add(b.id);
                                                      } else {
                                                        _selected.remove(b.id);
                                                      }
                                                    })),
                                        title: Text(b.values.userBatteryId),
                                        subtitle: Text(
                                            'Recorded Charges: ${b.recordedCharges} · Last charged: ${b.lastCharged == null ? 'Never' : _date(b.lastCharged!)}\nCurrent manual estimate: ${b.estimatedChargePercent == null ? 'Unknown' : '${b.estimatedChargePercent}%'}'),
                                        trailing: TextButton(
                                            onPressed: _busy
                                                ? null
                                                : () => _estimate(b),
                                            child:
                                                const Text('Edit estimate'))))
                            ],
                            const SizedBox(height: 16),
                            Text('Charge history',
                                style: Theme.of(context).textTheme.titleLarge),
                            history.when(
                                loading: () =>
                                    const Text('Loading charge history…'),
                                error: (e, s) => TextButton(
                                    onPressed: () => setState(_refresh),
                                    child: const Text(
                                        'Could not load history. Retry')),
                                data: (records) {
                                  final filtered = records
                                      .where((r) =>
                                          (widget.batteryId == null ||
                                              r.batteryId ==
                                                  widget.batteryId) &&
                                          (widget.setId == null ||
                                              r.setId == widget.setId) &&
                                          r.batteryLabel
                                              .toLowerCase()
                                              .contains(_query))
                                      .toList();
                                  return Column(children: [
                                    if (filtered.isEmpty)
                                      const ListTile(
                                          title:
                                              Text('No Recorded Charges yet.')),
                                    for (final r in filtered)
                                      ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(
                                              '${r.batteryLabel} · ${_date(r.chargedAt)}'),
                                          subtitle: Text(
                                              'Start: ${r.startPercent == null ? 'Not entered' : '${r.startPercent}%'} · End: ${r.endPercent == null ? 'Not entered' : '${r.endPercent}%'}\nCharger: ${r.charger ?? 'Not entered'}${r.setLabel == null ? '' : ' · Set: ${r.setLabel}'}${r.notes == null ? '' : '\n${r.notes}'}'))
                                  ]);
                                })
                          ]))
                        ]);
                  }))
        ]));
  }

  String _date(DateTime value) => value.toLocal().toString().split('.').first;
}
