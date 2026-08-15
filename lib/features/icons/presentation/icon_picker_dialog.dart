import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../application/icon_catalog_controller.dart';
import '../data/built_in_icon_registry.dart';
import '../domain/icon_color.dart';
import '../domain/icon_definition.dart';
import '../domain/icon_registry.dart';
import '../domain/icon_selection.dart';
import 'icon_color_picker.dart';
import 'icon_visual.dart';

class IconPickerDialog extends ConsumerStatefulWidget {
  const IconPickerDialog({
    required this.scope,
    this.initialSelection,
    this.onImportRequested,
    super.key,
  });

  final IconScope scope;
  final IconSelection? initialSelection;
  final Future<void> Function()? onImportRequested;

  static Future<IconSelection?> show(
    BuildContext context, {
    required IconScope scope,
    IconSelection? initialSelection,
    Future<void> Function()? onImportRequested,
  }) {
    return showDialog<IconSelection>(
      context: context,
      barrierDismissible: false,
      builder: (_) => IconPickerDialog(
        scope: scope,
        initialSelection: initialSelection,
        onImportRequested: onImportRequested,
      ),
    );
  }

  @override
  ConsumerState<IconPickerDialog> createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends ConsumerState<IconPickerDialog> {
  late IconDefinition _selectedDefinition;
  late IconColor _selectedColor;
  bool _initialCustomResolved = false;

  IconRegistry get _builtIns => IconRegistry(
        builtIns: BuiltInIconRegistry.definitions,
      );

  @override
  void initState() {
    super.initState();
    final initial = widget.initialSelection;
    final defaultDefinition = _builtIns.defaultFor(widget.scope);
    _selectedDefinition = initial == null
        ? defaultDefinition
        : BuiltInIconRegistry.definitions.firstWhere(
            (definition) =>
                initial.source == IconSource.builtin &&
                definition.key == initial.key &&
                (definition.scope == widget.scope ||
                    definition.scope == IconScope.general),
            orElse: () => defaultDefinition,
          );
    _selectedColor = initial?.color ?? _selectedDefinition.defaultColor;
    Future<void>.microtask(() async {
      await ref.read(iconCatalogProvider.future);
      await ref.read(iconCatalogProvider.notifier).setScope(widget.scope);
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(iconCatalogProvider);
    final supportRoot = ref.watch(applicationSupportRootProvider);
    _resolveInitialCustom(catalog);

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120, maxHeight: 760),
        child: Column(
          children: [
            _Header(scope: widget.scope),
            const Divider(height: 1),
            Expanded(
              child: catalog.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(
                  child: Text('The icon catalog could not be loaded.'),
                ),
                data: (snapshot) => LayoutBuilder(
                  builder: (context, constraints) {
                    final stacked = constraints.maxWidth < 820;
                    final catalogPanel = _CatalogPanel(
                      snapshot: snapshot,
                      selected: _selectedDefinition,
                      supportRoot: supportRoot,
                      onSelected: _selectDefinition,
                    );
                    final previewPanel = _PreviewPanel(
                      definition: _selectedDefinition,
                      color: _selectedColor,
                      fallback: _builtIns.defaultFor(widget.scope),
                      supportRoot: supportRoot,
                      onColorChanged: (color) {
                        setState(() => _selectedColor = color);
                      },
                      onReset: _resetDefault,
                    );
                    return stacked
                        ? Column(
                            children: [
                              Expanded(child: catalogPanel),
                              const Divider(height: 1),
                              SizedBox(height: 245, child: previewPanel),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(flex: 3, child: catalogPanel),
                              const VerticalDivider(width: 1),
                              SizedBox(width: 360, child: previewPanel),
                            ],
                          );
                  },
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: widget.onImportRequested == null
                        ? null
                        : () async {
                            await widget.onImportRequested!();
                            await ref
                                .read(iconCatalogProvider.notifier)
                                .refresh();
                          },
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('Import Custom Icon'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(
                        IconSelection(
                          source: _selectedDefinition.source,
                          key: _selectedDefinition.key,
                          color: _selectedColor,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Choose'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resolveInitialCustom(AsyncValue<IconCatalogSnapshot> catalog) {
    if (_initialCustomResolved ||
        widget.initialSelection?.source != IconSource.custom ||
        !catalog.hasValue) {
      return;
    }
    _initialCustomResolved = true;
    final initial = widget.initialSelection!;
    final matches = catalog.requireValue.definitions.where(
      (definition) =>
          definition.source == initial.source && definition.key == initial.key,
    );
    if (matches.isNotEmpty) {
      _selectedDefinition = matches.single;
    }
  }

  void _selectDefinition(
    IconDefinition definition,
    IconSelection? recentSelection,
  ) {
    setState(() {
      _selectedDefinition = definition;
      _selectedColor = recentSelection?.color ?? definition.defaultColor;
    });
  }

  void _resetDefault() {
    final definition = _builtIns.defaultFor(widget.scope);
    setState(() {
      _selectedDefinition = definition;
      _selectedColor = definition.defaultColor;
    });
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.scope});

  final IconScope scope;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 18),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.widgets_outlined),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Choose Icon',
                    style: Theme.of(context).textTheme.titleLarge),
                Text(
                  '${scope.label} identity · icons remain available without photos',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _CatalogPanel extends ConsumerWidget {
  const _CatalogPanel({
    required this.snapshot,
    required this.selected,
    required this.supportRoot,
    required this.onSelected,
  });

  final IconCatalogSnapshot snapshot;
  final IconDefinition selected;
  final Uri supportRoot;
  final void Function(IconDefinition, IconSelection?) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(iconCatalogProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            key: const ValueKey('icon-search-field'),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Search icons',
              hintText: 'Name, category, or keyword',
            ),
            onChanged: controller.setQuery,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SegmentedButton<IconCatalogSource>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                        value: IconCatalogSource.all, label: Text('All')),
                    ButtonSegment(
                      value: IconCatalogSource.builtin,
                      label: Text('Built-In'),
                    ),
                    ButtonSegment(
                      value: IconCatalogSource.custom,
                      label: Text('Custom'),
                    ),
                    ButtonSegment(
                      value: IconCatalogSource.recent,
                      label: Text('Recent'),
                    ),
                  ],
                  selected: {snapshot.sourceFilter},
                  onSelectionChanged: (value) {
                    controller.setSourceFilter(value.single);
                  },
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String?>(
                value: snapshot.category,
                hint: const Text('All categories'),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('All categories')),
                  for (final category in snapshot.categories)
                    DropdownMenuItem(value: category, child: Text(category)),
                ],
                onChanged: controller.setCategory,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: snapshot.definitions.isEmpty
                ? const Center(
                    child: Text('No icons match the current filters.'),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 150,
                      mainAxisExtent: 142,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: snapshot.definitions.length,
                    itemBuilder: (context, index) {
                      final definition = snapshot.definitions[index];
                      final recent = snapshot.recentSelections.where(
                        (selection) =>
                            selection.source == definition.source &&
                            selection.key == definition.key,
                      );
                      return _IconTile(
                        definition: definition,
                        selected: definition.source == selected.source &&
                            definition.key == selected.key,
                        supportRoot: supportRoot,
                        fallback: IconRegistry(
                          builtIns: BuiltInIconRegistry.definitions,
                        ).defaultFor(snapshot.scope),
                        onTap: () => onSelected(
                          definition,
                          recent.isEmpty ? null : recent.first,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.definition,
    required this.selected,
    required this.supportRoot,
    required this.fallback,
    required this.onTap,
  });

  final IconDefinition definition;
  final bool selected;
  final Uri supportRoot;
  final IconDefinition fallback;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colors.primaryContainer : colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('icon-option-${definition.key}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconVisual(
                definition: definition,
                color: definition.defaultColor,
                fallbackDefinition: fallback,
                applicationSupportRoot: supportRoot,
                size: 52,
              ),
              const SizedBox(height: 10),
              Text(
                definition.displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({
    required this.definition,
    required this.color,
    required this.fallback,
    required this.supportRoot,
    required this.onColorChanged,
    required this.onReset,
  });

  final IconDefinition definition;
  final IconColor color;
  final IconDefinition fallback;
  final Uri supportRoot;
  final ValueChanged<IconColor> onColorChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selected Preview',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 132,
              height: 132,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: IconVisual(
                definition: definition,
                color: color,
                fallbackDefinition: fallback,
                applicationSupportRoot: supportRoot,
                size: 82,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                Text(
                  definition.displayName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  '${definition.source == IconSource.builtin ? 'Built-In' : 'Custom'} · ${definition.category}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.settings_backup_restore),
              label: const Text('Reset to Default'),
            ),
          ),
          const SizedBox(height: 24),
          IconColorPicker(
            selected: color,
            defaultColor: definition.defaultColor,
            onChanged: onColorChanged,
          ),
        ],
      ),
    );
  }
}
