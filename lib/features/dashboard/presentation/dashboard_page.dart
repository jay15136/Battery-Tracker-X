import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import '../../../app/app_providers.dart';
import '../../../app/navigation/navigation_controller.dart';
import '../../../app/navigation/app_destination.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../icons/domain/icon_definition.dart';
import '../../icons/presentation/inventory_icon.dart';
import '../domain/dashboard.dart';

final dashboardProvider = StreamProvider.autoDispose<DashboardSnapshot>((ref) {
  final timer =
      Timer.periodic(const Duration(minutes: 1), (_) => ref.invalidateSelf());
  ref.onDispose(timer.cancel);
  return ref.watch(dashboardRepositoryProvider).watch();
});

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});
  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  String _search = '';
  bool _includeRetired = true;
  int _limit = 25;
  Object? _reported;
  void _go(AppDestination destination) =>
      ref.read(navigationProvider.notifier).selectDestination(destination);
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dashboardProvider);
    return AppPageScaffold(
        title: 'Dashboard',
        description:
            'Current inventory, recent activity, and reminders from your local records.',
        icon: Icons.dashboard_outlined,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Wrap(spacing: 8, runSpacing: 8, children: [
            FilledButton.icon(
                onPressed: () => _go(AppDestination.batteries),
                icon: const Icon(Icons.battery_full),
                label: const Text('View Batteries')),
            OutlinedButton(
                onPressed: () => _go(AppDestination.batterySets),
                child: const Text('View Sets')),
            OutlinedButton(
                onPressed: () => _go(AppDestination.devices),
                child: const Text('View Devices')),
            OutlinedButton(
                onPressed: () => _go(AppDestination.charging),
                child: const Text('Record a charge')),
            OutlinedButton(
                onPressed: () => _go(AppDestination.qrLabels),
                child: const Text('Create QR Labels')),
            TextButton(
                onPressed: () => showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => _AttentionRules(
                        policy: data.asData?.value.policy ??
                            const AttentionPolicy())),
                child: const Text('Attention rules')),
            IconButton(
                tooltip: 'Refresh dashboard',
                onPressed: () => ref.invalidate(dashboardProvider),
                icon: const Icon(Icons.refresh)),
          ]),
          const SizedBox(height: 20),
          data.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) {
                if (!identical(_reported, e)) {
                  _reported = e;
                  Logger('battery_tracker.dashboard')
                      .severe('Dashboard could not be loaded.', e, s);
                }
                return const Text(
                    'Dashboard could not be loaded. Refresh to retry, or review Attention rules if saved settings are invalid.');
              },
              data: (snapshot) => _content(snapshot)),
        ]));
  }

  Widget _content(DashboardSnapshot s) {
    final visible = s.attention
        .where((b) =>
            (_includeRetired || !b.reasons.contains('Retired')) &&
            (b.label + ' ' + b.reasons.join(' '))
                .toLowerCase()
                .contains(_search))
        .toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (s.counts['Total Batteries'] == 0)
        const Card(
            child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                    'No Batteries yet. Open View Batteries to add your first Battery or create several at once. Photographs are optional.'))),
      LayoutBuilder(builder: (context, c) {
        final columns = c.maxWidth >= 850
            ? 3
            : c.maxWidth >= 480
                ? 2
                : 1;
        final width = (c.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(spacing: 12, runSpacing: 12, children: [
          for (final entry in s.counts.entries)
            SizedBox(
                width: width,
                child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.value.toString(),
                                  key: ValueKey('dashboard-count-' + entry.key),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge),
                              const SizedBox(height: 4),
                              Text(entry.key)
                            ]))))
        ]);
      }),
      const SizedBox(height: 10),
      const Text(
          'Counts exclude deleted records. Sets and Devices include inactive records. Assignment and Set counts can overlap; available Batteries have Available status and are free of both.'),
      const SizedBox(height: 28),
      Text('Batteries Needing Attention',
          style: Theme.of(context).textTheme.titleLarge),
      const Text(
          'Reminders describe recorded use, not measured battery health or true cycle counts.'),
      Wrap(
          spacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
                width: 320,
                child: TextField(
                    decoration: const InputDecoration(
                        labelText: 'Search attention list'),
                    onChanged: (v) => setState(() {
                          _search = v.toLowerCase();
                          _limit = 25;
                        }))),
            FilterChip(
                label: const Text('Include retired'),
                selected: _includeRetired,
                onSelected: (v) => setState(() {
                      _includeRetired = v;
                      _limit = 25;
                    }))
          ]),
      const SizedBox(height: 8),
      if (visible.isEmpty)
        Text(s.attention.isEmpty
            ? 'No Batteries meet the current attention rules.'
            : 'No attention records match these filters.'),
      for (final b in visible.take(_limit))
        Card(
            child: ListTile(
                leading: InventoryIcon(
                    selection: b.icon, scope: IconScope.battery, size: 36),
                title: Text(b.label),
                subtitle: Text(b.reasons.join(' • ')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => ref.read(navigationProvider.notifier).openEntity(
                    destination: AppDestination.batteries, entityId: b.id))),
      if (visible.isNotEmpty)
        Text(
            'Showing ${visible.length < _limit ? visible.length : _limit} of ${visible.length} matching Batteries'),
      if (visible.length > _limit)
        TextButton(
            onPressed: () => setState(() => _limit += 25),
            child: const Text('Show more Batteries')),
      const SizedBox(height: 28),
      Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge),
      const Text(
          'Latest 20 recorded events, newest first. Historical entries remain when inventory is deleted.'),
      if (s.activity.isEmpty)
        const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('No activity recorded yet.')),
      for (final a in s.activity)
        ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(a.summary),
            subtitle: Text([
              if (a.entityLabel != null) a.entityLabel!,
              a.at.toLocal().toString().split('.').first
            ].join(' • ')),
            trailing: a.available ? const Icon(Icons.chevron_right) : null,
            onTap: !a.available || a.entityId == null
                ? null
                : () => ref.read(navigationProvider.notifier).openEntity(
                    destination: switch (a.entityType) {
                      'battery_set' => AppDestination.batterySets,
                      'device' => AppDestination.devices,
                      _ => AppDestination.batteries
                    },
                    entityId: a.entityId!)),
      const SizedBox(height: 12),
      Text('Updated ${s.at.toLocal().toString().split('.').first}'),
    ]);
  }
}

class _AttentionRules extends ConsumerStatefulWidget {
  const _AttentionRules({required this.policy});
  final AttentionPolicy policy;
  @override
  ConsumerState<_AttentionRules> createState() => _AttentionRulesState();
}

class _AttentionRulesState extends ConsumerState<_AttentionRules> {
  late final List<TextEditingController> _controllers;
  bool _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _controllers = [
      widget.policy.daysWithoutCharge,
      widget.policy.recordedChargeThreshold,
      widget.policy.setChargeDifference
    ].map((v) => TextEditingController(text: v.toString())).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final values =
          _controllers.map((c) => int.tryParse(c.text.trim())).toList();
      if (values.any((v) => v == null))
        throw const FormatException(
            'Enter whole numbers; zero disables a reminder.');
      final policy = AttentionPolicy(
          daysWithoutCharge: values[0]!,
          recordedChargeThreshold: values[1]!,
          setChargeDifference: values[2]!);
      await ref.read(dashboardRepositoryProvider).savePolicy(policy);
      if (mounted) Navigator.pop(context);
    } on FormatException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on Object catch (e, s) {
      Logger('battery_tracker.dashboard')
          .severe('Attention rules could not be saved.', e, s);
      if (mounted)
        setState(() => _error = 'Rules could not be saved. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !_busy,
      child: AlertDialog(
          title: const Text('Attention rules'),
          content: SizedBox(
              width: 450,
              child: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text(
                    'Zero disables a numeric reminder. Poor, Damaged, Needs Attention, and Retired flags always appear. Charge reminders apply to rechargeable, non-retired Batteries.'),
                for (var i = 0; i < 3; i++)
                  TextField(
                      key: ValueKey('attention-rule-$i'),
                      controller: _controllers[i],
                      enabled: !_busy,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: const [
                        'Days without a recorded charge',
                        'Recorded Charges threshold',
                        'Set Recorded Charges difference'
                      ][i])),
                if (_error != null)
                  Text(_error!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error))
              ]))),
          actions: [
            TextButton(
                onPressed: _busy ? null : () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: _busy ? null : _save,
                child: const Text('Save rules'))
          ]));
}
