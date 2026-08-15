import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../../../app/navigation/app_destination.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../application/battery_type_catalog_controller.dart';
import '../domain/battery_type.dart';
import '../domain/battery_type_repository.dart';
import 'battery_type_form_dialog.dart';
import 'battery_type_icon.dart';

class BatteryTypesPage extends ConsumerWidget {
  const BatteryTypesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(batteryTypeCatalogProvider);
    final bodyHeight = math.max(450.0, MediaQuery.sizeOf(context).height - 190);

    return AppPageScaffold(
      title: AppDestination.batteryTypes.label,
      description: AppDestination.batteryTypes.description,
      icon: AppDestination.batteryTypes.icon,
      child: SizedBox(
        key: const ValueKey('battery-types-page'),
        height: bodyHeight,
        child: catalog.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _CatalogLoadError(
            onRetry: () => ref.invalidate(batteryTypeCatalogProvider),
          ),
          data: (snapshot) => Column(
            children: [
              _Toolbar(snapshot: snapshot),
              const SizedBox(height: 16),
              Expanded(child: _Workspace(snapshot: snapshot)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Toolbar extends ConsumerWidget {
  const _Toolbar({required this.snapshot});

  final BatteryTypeCatalogSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(batteryTypeCatalogProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const ValueKey('battery-types-search'),
                decoration: const InputDecoration(
                  labelText: 'Search Battery Types',
                  hintText: 'Name, chemistry, size, or description',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: controller.setQuery,
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              key: const ValueKey('battery-types-add'),
              onPressed: () => _addBatteryType(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add Battery Type'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _StatusChoice(
                key: const ValueKey('battery-types-filter-active'),
                label: 'Active',
                selected: snapshot.status == BatteryTypeStatusFilter.active,
                onSelected: () =>
                    controller.setStatus(BatteryTypeStatusFilter.active),
              ),
              const SizedBox(width: 8),
              _StatusChoice(
                key: const ValueKey('battery-types-filter-inactive'),
                label: 'Inactive',
                selected: snapshot.status == BatteryTypeStatusFilter.inactive,
                onSelected: () =>
                    controller.setStatus(BatteryTypeStatusFilter.inactive),
              ),
              const SizedBox(width: 8),
              _StatusChoice(
                key: const ValueKey('battery-types-filter-all'),
                label: 'All',
                selected: snapshot.status == BatteryTypeStatusFilter.all,
                onSelected: () =>
                    controller.setStatus(BatteryTypeStatusFilter.all),
              ),
              const SizedBox(width: 16),
              Text(
                '${snapshot.visible.length} shown',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChoice extends StatelessWidget {
  const _StatusChoice({
    required this.label,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _Workspace extends StatelessWidget {
  const _Workspace({required this.snapshot});

  final BatteryTypeCatalogSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final selected = _selectedRecord(snapshot);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 820;
        final list = _BatteryTypeList(snapshot: snapshot, selected: selected);
        final details = _BatteryTypeDetails(record: selected);
        if (compact) {
          return Column(
            children: [
              Expanded(flex: 3, child: list),
              const Divider(height: 17),
              Expanded(flex: 2, child: details),
            ],
          );
        }
        return Row(
          children: [
            Expanded(flex: 5, child: list),
            const VerticalDivider(width: 25),
            SizedBox(width: 390, child: details),
          ],
        );
      },
    );
  }
}

BatteryTypeRecord? _selectedRecord(BatteryTypeCatalogSnapshot snapshot) {
  for (final record in snapshot.records) {
    if (record.id == snapshot.selectedId) {
      return record;
    }
  }
  return snapshot.visible.isEmpty ? null : snapshot.visible.first;
}

class _BatteryTypeList extends ConsumerWidget {
  const _BatteryTypeList({required this.snapshot, required this.selected});

  final BatteryTypeCatalogSnapshot snapshot;
  final BatteryTypeRecord? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (snapshot.visible.isEmpty) {
      final databaseEmpty = snapshot.records.isEmpty;
      return _EmptyCatalog(
        icon: databaseEmpty ? Icons.battery_unknown_outlined : Icons.search_off,
        title: databaseEmpty
            ? 'No Battery Types yet.'
            : 'No Battery Types match these filters.',
        message: databaseEmpty
            ? 'Add a reusable specification before entering Batteries.'
            : 'Change the search or status filter to see other records.',
      );
    }

    return ListView.separated(
      key: const ValueKey('battery-types-list'),
      itemCount: snapshot.visible.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final record = snapshot.visible[index];
        return _BatteryTypeRow(
          record: record,
          selected: record.id == selected?.id,
          onTap: () =>
              ref.read(batteryTypeCatalogProvider.notifier).select(record.id),
        );
      },
    );
  }
}

class _BatteryTypeRow extends StatelessWidget {
  const _BatteryTypeRow({
    required this.record,
    required this.selected,
    required this.onTap,
  });

  final BatteryTypeRecord record;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final specifications = [
      record.chemistry,
      record.physicalSize,
      _capacity(record),
    ].whereType<String>().join(' • ');
    return Semantics(
      button: true,
      selected: selected,
      label: '${record.typeName}, ${record.isActive ? 'Active' : 'Inactive'}',
      child: Material(
        color:
            selected ? colors.secondaryContainer : colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: selected ? colors.secondary : colors.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey('battery-type-row-${record.id.value}'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 52,
                  child: Center(
                    child: BatteryTypeIcon(
                      selection: record.suggestedIcon,
                      size: 38,
                      semanticsLabel: '${record.typeName} icon',
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.typeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        specifications.isEmpty
                            ? 'No default specifications'
                            : specifications,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(active: record.isActive),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BatteryTypeDetails extends ConsumerWidget {
  const _BatteryTypeDetails({required this.record});

  final BatteryTypeRecord? record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final record = this.record;
    if (record == null) {
      return const _EmptyCatalog(
        icon: Icons.touch_app_outlined,
        title: 'Select a Battery Type.',
        message: 'Choose a record to review its specifications and usage.',
      );
    }
    final colors = Theme.of(context).colorScheme;
    final usage = ref.watch(batteryTypeUsageProvider(record.id));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        key: const ValueKey('battery-types-details'),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: BatteryTypeIcon(
                    selection: record.suggestedIcon,
                    size: 48,
                    semanticsLabel: '${record.typeName} suggested icon',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.typeName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      _StatusBadge(active: record.isActive),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  key: const ValueKey('battery-types-edit'),
                  onPressed: () => _editBatteryType(context, ref, record),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
                if (record.isActive)
                  FilledButton.tonalIcon(
                    key: const ValueKey('battery-types-deactivate'),
                    onPressed: () => _deactivate(context, ref, record),
                    icon: const Icon(Icons.pause_circle_outline),
                    label: const Text('Deactivate'),
                  )
                else
                  FilledButton.tonalIcon(
                    key: const ValueKey('battery-types-reactivate'),
                    onPressed: () => _reactivate(context, ref, record),
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('Reactivate'),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const _DetailHeading('Specifications'),
            _DetailValue(label: 'Chemistry', value: record.chemistry),
            _DetailValue(label: 'Physical size', value: record.physicalSize),
            _DetailValue(label: 'Default voltage', value: _voltage(record)),
            _DetailValue(label: 'Default capacity', value: _capacity(record)),
            _DetailValue(label: 'Description', value: record.description),
            _DetailValue(label: 'Notes', value: record.notes),
            const SizedBox(height: 18),
            const _DetailHeading('Inventory usage'),
            usage.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Usage counts are unavailable.'),
              data: (value) => Text(_usageSentence(value)),
            ),
            const SizedBox(height: 18),
            const _DetailHeading('Permanent UUID'),
            SelectableText(
              record.id.value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailHeading extends StatelessWidget {
  const _DetailHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.titleSmall),
      );
}

class _DetailValue extends StatelessWidget {
  const _DetailValue({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final shown = value?.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 116,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
              child: Text(shown == null || shown.isEmpty ? 'Not set' : shown)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(active ? 'Active' : 'Inactive'),
      );
}

class _EmptyCatalog extends StatelessWidget {
  const _EmptyCatalog({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36),
              const SizedBox(height: 10),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

class _CatalogLoadError extends StatelessWidget {
  const _CatalogLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 36),
            const SizedBox(height: 10),
            Text(
              'Battery Types could not be loaded.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text('Try again.'),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
}

Future<void> _addBatteryType(BuildContext context, WidgetRef ref) async {
  final draft = await BatteryTypeFormDialog.show(context);
  if (draft == null || !context.mounted) {
    return;
  }
  try {
    await ref.read(batteryTypeCatalogProvider.notifier).create(draft);
    if (context.mounted) {
      _message(context, 'Battery Type added.');
    }
  } on BatteryTypeNameConflictException {
    if (context.mounted) {
      _message(context, 'An active Battery Type already uses this name.');
    }
  } on Object catch (error, stackTrace) {
    _logFailure(ref, error, stackTrace);
    if (context.mounted) {
      _message(context, 'Battery Type could not be added.');
    }
  }
}

Future<void> _editBatteryType(
  BuildContext context,
  WidgetRef ref,
  BatteryTypeRecord record,
) async {
  final draft = await BatteryTypeFormDialog.show(context, record: record);
  if (draft == null || !context.mounted) {
    return;
  }
  try {
    await ref
        .read(batteryTypeCatalogProvider.notifier)
        .updateBatteryType(record.id, draft);
    if (context.mounted) {
      _message(context, 'Battery Type updated.');
    }
  } on BatteryTypeNameConflictException {
    if (context.mounted) {
      _message(context, 'An active Battery Type already uses this name.');
    }
  } on Object catch (error, stackTrace) {
    _logFailure(ref, error, stackTrace);
    if (context.mounted) {
      _message(context, 'Battery Type could not be updated.');
    }
  }
}

Future<void> _deactivate(
  BuildContext context,
  WidgetRef ref,
  BatteryTypeRecord record,
) async {
  try {
    final usage = await ref.read(batteryTypeUsageProvider(record.id).future);
    if (!context.mounted) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Deactivate Battery Type?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_usageSentence(usage)),
            const SizedBox(height: 10),
            const Text(
              'Existing references stay connected. New records will not use this type by default.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    await ref.read(batteryTypeCatalogProvider.notifier).deactivate(record.id);
    if (context.mounted) {
      _message(context, 'Battery Type deactivated.');
    }
  } on Object catch (error, stackTrace) {
    _logFailure(ref, error, stackTrace);
    if (context.mounted) {
      _message(context, 'Battery Type could not be deactivated.');
    }
  }
}

Future<void> _reactivate(
  BuildContext context,
  WidgetRef ref,
  BatteryTypeRecord record,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Reactivate Battery Type?'),
      content: Text(
        '${record.typeName} will return to the Active Battery Types list.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Reactivate'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) {
    return;
  }
  try {
    await ref.read(batteryTypeCatalogProvider.notifier).reactivate(record.id);
    if (context.mounted) {
      _message(context, 'Battery Type reactivated.');
    }
  } on BatteryTypeReactivationConflictException {
    if (context.mounted) {
      _message(
        context,
        'A different active Battery Type already uses this name.',
      );
    }
  } on Object catch (error, stackTrace) {
    _logFailure(ref, error, stackTrace);
    if (context.mounted) {
      _message(context, 'Battery Type could not be reactivated.');
    }
  }
}

void _logFailure(WidgetRef ref, Object error, StackTrace stackTrace) {
  ref.read(appLogServiceProvider).logger('battery_types.ui').severe(
        'Battery Type operation failed.',
        error,
        stackTrace,
      );
}

void _message(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

String? _voltage(BatteryTypeRecord record) => record.defaultVoltage == null
    ? null
    : '${_number(record.defaultVoltage!)} V';

String? _capacity(BatteryTypeRecord record) => record.defaultCapacity == null
    ? null
    : '${_number(record.defaultCapacity!)} ${record.capacityUnit ?? ''}'.trim();

String _number(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toString();

String _usageSentence(BatteryTypeUsage usage) {
  final batteries = usage.batteries == 1 ? 'Battery' : 'Batteries';
  final sets = usage.batterySets == 1 ? 'Battery Set' : 'Battery Sets';
  final devices = usage.devices == 1 ? 'Device' : 'Devices';
  return 'Used by ${usage.batteries} $batteries, '
      '${usage.batterySets} $sets, and ${usage.devices} $devices.';
}
