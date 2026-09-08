import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import '../../../app/navigation/app_destination.dart';
import '../../../app/navigation/navigation_controller.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../application/history_providers.dart';
import '../domain/history.dart';

IconData _categoryIcon(HistoryCategory category) => switch (category) {
      HistoryCategory.additions => Icons.add_circle_outline,
      HistoryCategory.statusChanges => Icons.sync_alt_outlined,
      HistoryCategory.assignments => Icons.swap_horiz_outlined,
      HistoryCategory.setMembership => Icons.inventory_2_outlined,
      HistoryCategory.charging => Icons.battery_charging_full_outlined,
      HistoryCategory.retirement => Icons.archive_outlined,
      HistoryCategory.qrLabels => Icons.qr_code_2_outlined,
      HistoryCategory.bulkOperations => Icons.dynamic_feed_outlined,
      HistoryCategory.iconsAndPhotos => Icons.image_outlined,
      HistoryCategory.other => Icons.circle_outlined,
    };

AppDestination? _destinationFor(HistoryEntityType? type) => switch (type) {
      HistoryEntityType.battery => AppDestination.batteries,
      HistoryEntityType.batterySet => AppDestination.batterySets,
      HistoryEntityType.device => AppDestination.devices,
      null => null,
    };

String _formatDate(DateTime? d) =>
    d == null ? 'Any' : d.toLocal().toString().split(' ').first;

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = ref.watch(historyRequestProvider);
    final result = ref.watch(historyResultProvider);
    return AppPageScaffold(
      title: 'History',
      description:
          'Assignment, membership, charge, status, and label activity recorded across the application.',
      icon: Icons.history_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Filters(filter: request.filter),
          const SizedBox(height: 20),
          result.when(
            loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator())),
            error: (error, stack) {
              Logger('battery_tracker.history')
                  .severe('History could not be loaded.', error, stack);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('History could not be loaded. Refresh to retry.'),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                      onPressed: () => ref.invalidate(historyResultProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'))
                ],
              );
            },
            data: (data) => _Results(data: data, filter: request.filter),
          ),
        ],
      ),
    );
  }
}

class _Filters extends ConsumerWidget {
  const _Filters({required this.filter});
  final HistoryFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void update(HistoryFilter Function(HistoryFilter) change) {
      ref
          .read(historyRequestProvider.notifier)
          .update((filter: change(filter), limit: 25));
    }

    Future<void> pickFrom() async {
      final picked = await showDatePicker(
          context: context,
          initialDate: filter.from ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 1)));
      if (picked != null) update((f) => f.copyWith(from: picked));
    }

    Future<void> pickTo() async {
      final picked = await showDatePicker(
          context: context,
          initialDate: filter.to ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 1)));
      if (picked != null) {
        update((f) => f.copyWith(
            to: DateTime(
                picked.year, picked.month, picked.day, 23, 59, 59, 999)));
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Wrap(
          spacing: 14,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DropdownMenu<HistoryCategory?>(
              key: const ValueKey('history-filter-category'),
              label: const Text('Activity Type'),
              initialSelection: filter.category,
              dropdownMenuEntries: [
                const DropdownMenuEntry(value: null, label: 'All Activity'),
                for (final category in HistoryCategory.values)
                  DropdownMenuEntry(value: category, label: category.label),
              ],
              onSelected: (value) => update((f) => value == null
                  ? f.copyWith(clearCategory: true)
                  : f.copyWith(category: value)),
            ),
            _EntityFilter(filter: filter, onChanged: update),
            OutlinedButton.icon(
                key: const ValueKey('history-filter-from'),
                onPressed: pickFrom,
                icon: const Icon(Icons.calendar_today_outlined, size: 16),
                label: Text('From: ${_formatDate(filter.from)}')),
            OutlinedButton.icon(
                key: const ValueKey('history-filter-to'),
                onPressed: pickTo,
                icon: const Icon(Icons.calendar_today_outlined, size: 16),
                label: Text('To: ${_formatDate(filter.to)}')),
            if (!filter.isEmpty)
              TextButton(
                  onPressed: () => ref
                      .read(historyRequestProvider.notifier)
                      .update((filter: const HistoryFilter(), limit: 25)),
                  child: const Text('Clear filters')),
          ],
        ),
      ),
    );
  }
}

class _EntityFilter extends ConsumerStatefulWidget {
  const _EntityFilter({required this.filter, required this.onChanged});
  final HistoryFilter filter;
  final void Function(HistoryFilter Function(HistoryFilter)) onChanged;

  @override
  ConsumerState<_EntityFilter> createState() => _EntityFilterState();
}

class _EntityFilterState extends ConsumerState<_EntityFilter> {
  HistoryEntityType? _kind;

  @override
  void initState() {
    super.initState();
    _kind = widget.filter.entity?.type;
  }

  @override
  Widget build(BuildContext context) {
    final kind = _kind;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      DropdownMenu<HistoryEntityType?>(
        key: const ValueKey('history-filter-entity-kind'),
        label: const Text('Battery, Set, or Device'),
        initialSelection: kind,
        dropdownMenuEntries: [
          const DropdownMenuEntry(value: null, label: 'Any record'),
          for (final type in HistoryEntityType.values)
            DropdownMenuEntry(value: type, label: type.label),
        ],
        onSelected: (value) {
          setState(() => _kind = value);
          if (value == null) {
            widget.onChanged((f) => f.copyWith(clearEntity: true));
          }
        },
      ),
      if (kind != null) ...[
        const SizedBox(width: 10),
        SizedBox(
            width: 260,
            child: Consumer(builder: (context, ref, _) {
              final options = ref.watch(historyEntityOptionsProvider(kind));
              return options.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => const Text('Records could not be loaded.'),
                data: (list) => DropdownMenu<HistoryEntityOption?>(
                  key: const ValueKey('history-filter-entity-value'),
                  label: Text('Choose a ${kind.label}'),
                  enableFilter: true,
                  enableSearch: true,
                  initialSelection: list
                      .cast<HistoryEntityOption?>()
                      .firstWhere((o) => o?.id == widget.filter.entity?.id,
                          orElse: () => null),
                  dropdownMenuEntries: [
                    for (final option in list)
                      DropdownMenuEntry(value: option, label: option.label),
                  ],
                  onSelected: (option) => widget.onChanged((f) => option == null
                      ? f.copyWith(clearEntity: true)
                      : f.copyWith(
                          entity: HistoryEntityFilter(
                              type: kind, id: option.id, label: option.label))),
                ),
              );
            })),
      ],
    ]);
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.data, required this.filter});
  final HistoryResult data;
  final HistoryFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data.totalCount == 0) {
      return Text(filter.isEmpty
          ? 'No activity recorded yet. Activity appears as inventory, assignments, charges, and labels change.'
          : 'No activity matches these filters.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Showing ${data.entries.length} of ${data.totalCount} events'),
        const SizedBox(height: 8),
        for (final entry in data.entries)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(_categoryIcon(entry.category)),
              title: Text(entry.summary),
              subtitle: Text([
                entry.category.label,
                if (entry.entityLabel != null) entry.entityLabel!,
                entry.occurredAt.toLocal().toString().split('.').first,
              ].join(' • ')),
              trailing: entry.available && entry.entityId != null
                  ? const Icon(Icons.chevron_right)
                  : null,
              onTap: !entry.available || entry.entityId == null
                  ? null
                  : () {
                      final destination =
                          _destinationFor(entry.resolvedEntityType);
                      if (destination == null) return;
                      ref.read(navigationProvider.notifier).openEntity(
                          destination: destination, entityId: entry.entityId!);
                    },
            ),
          ),
        if (data.entries.length < data.totalCount)
          Center(
            child: TextButton(
              onPressed: () => ref
                  .read(historyRequestProvider.notifier)
                  .update((filter: filter, limit: data.entries.length + 25)),
              child: const Text('Show more events'),
            ),
          ),
      ],
    );
  }
}
