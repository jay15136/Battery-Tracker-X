import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../../../core/identity/permanent_id.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../services/file_selection_service.dart';
import '../application/icon_catalog_controller.dart';
import '../data/built_in_icon_registry.dart';
import '../domain/custom_icon_storage.dart';
import '../domain/icon_definition.dart';
import '../domain/icon_registry.dart';
import '../domain/icon_repository.dart';
import '../domain/icon_selection.dart';
import 'custom_icon_editor_dialog.dart';
import 'icon_picker_dialog.dart';
import 'icon_visual.dart';

class IconLibraryPage extends ConsumerStatefulWidget {
  const IconLibraryPage({super.key});

  @override
  ConsumerState<IconLibraryPage> createState() => _IconLibraryPageState();
}

class _IconLibraryPageState extends ConsumerState<IconLibraryPage> {
  String? _selectedIdentity;
  bool _working = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      await ref.read(iconCatalogProvider.future);
      await ref.read(iconCatalogProvider.notifier).setScope(IconScope.battery);
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(iconCatalogProvider);
    final supportRoot = ref.watch(applicationSupportRootProvider);
    return Scaffold(
      key: const ValueKey('icon-library-page'),
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Settings'),
      ),
      body: AppPageScaffold(
        title: 'Icon Library',
        description:
            'Manage the icons that identify batteries, sets, and devices.',
        icon: Icons.widgets_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LibrarySummary(working: _working),
            const SizedBox(height: 16),
            SizedBox(
              height: 650,
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: catalog.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => _LoadFailure(onRetry: _refresh),
                  data: (snapshot) => LayoutBuilder(
                    builder: (context, constraints) {
                      final selected = _selectedDefinition(snapshot);
                      final catalogPanel = _LibraryCatalog(
                        snapshot: snapshot,
                        supportRoot: supportRoot,
                        selectedIdentity: _selectedIdentity,
                        onSelected: (definition) {
                          setState(() {
                            _selectedIdentity = _identity(definition);
                          });
                        },
                        onImport: _working ? null : _importCustomIcon,
                      );
                      final details = _IconDetails(
                        definition: selected,
                        supportRoot: supportRoot,
                        scope: snapshot.scope,
                        working: _working,
                        onEdit: selected?.source == IconSource.custom
                            ? () => _editCustomIcon(selected!)
                            : null,
                        onReplace: selected?.source == IconSource.custom
                            ? () => _replaceSource(selected!)
                            : null,
                        onDuplicate: selected?.source == IconSource.custom
                            ? () => _duplicate(selected!)
                            : null,
                        onDelete: selected?.source == IconSource.custom
                            ? () => _delete(selected!)
                            : null,
                      );
                      if (constraints.maxWidth < 850) {
                        return Column(
                          children: [
                            Expanded(child: catalogPanel),
                            const Divider(height: 1),
                            SizedBox(height: 230, child: details),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: catalogPanel),
                          const VerticalDivider(width: 1),
                          SizedBox(width: 320, child: details),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconDefinition? _selectedDefinition(IconCatalogSnapshot snapshot) {
    final identity = _selectedIdentity;
    if (identity == null) {
      return null;
    }
    final matches = snapshot.definitions.where(
      (definition) => _identity(definition) == identity,
    );
    return matches.isEmpty ? null : matches.first;
  }

  Future<void> _importCustomIcon() async {
    final source = await ref.read(fileSelectionServiceProvider).chooseOpenFile(
      acceptedTypes: const [
        FileTypeFilter(label: 'Icon files', extensions: ['png', 'svg']),
      ],
    );
    if (source == null || !mounted) {
      return;
    }
    final library = ref.read(iconLibraryServiceProvider);
    try {
      await library.storage.inspect(source);
      final snapshot = await ref.read(iconCatalogProvider.future);
      final result = await CustomIconEditorDialog.show(
        context,
        scope: snapshot.scope,
        categories: await ref.read(iconRepositoryProvider).listCategories(),
        applicationSupportRoot: ref.read(applicationSupportRootProvider),
        source: source,
        onCreateCategory: (name, scope) =>
            library.createCategory(name: name, scope: scope),
      );
      if (result == null || !mounted) {
        return;
      }
      await _runOperation(
        () => library.importCustomIcon(
          source: source,
          name: result.name,
          categoryId: result.categoryId,
          supportsColor: result.supportsColor,
        ),
        failureMessage: 'The custom icon could not be imported.',
      );
      ref
          .read(iconCatalogProvider.notifier)
          .setSourceFilter(IconCatalogSource.custom);
    } on InvalidCustomIconFileException catch (error, stackTrace) {
      _reportFailure(error.message, error, stackTrace);
    } on Object catch (error, stackTrace) {
      _reportFailure(
        'The custom icon could not be imported.',
        error,
        stackTrace,
      );
    }
  }

  Future<void> _editCustomIcon(IconDefinition definition) async {
    try {
      final id = PermanentId.parse(definition.key);
      final repository = ref.read(iconRepositoryProvider);
      final record = await repository.getCustomIcon(id);
      if (!mounted) {
        return;
      }
      final library = ref.read(iconLibraryServiceProvider);
      final result = await CustomIconEditorDialog.show(
        context,
        scope: record.scope,
        categories: await repository.listCategories(),
        applicationSupportRoot: ref.read(applicationSupportRootProvider),
        existing: record,
        onCreateCategory: (name, scope) =>
            library.createCategory(name: name, scope: scope),
      );
      if (result == null) {
        return;
      }
      await _runOperation(
        () => library.updateMetadata(
          id: id,
          name: result.name,
          categoryId: result.categoryId,
          supportsColor: result.supportsColor,
        ),
        failureMessage: 'The icon details could not be saved.',
      );
    } on Object catch (error, stackTrace) {
      _reportFailure(
        'The icon details could not be loaded.',
        error,
        stackTrace,
      );
    }
  }

  Future<void> _replaceSource(IconDefinition definition) async {
    final source = await ref.read(fileSelectionServiceProvider).chooseOpenFile(
      acceptedTypes: const [
        FileTypeFilter(label: 'Icon files', extensions: ['png', 'svg']),
      ],
    );
    if (source == null) {
      return;
    }
    await _runOperation(
      () => ref.read(iconLibraryServiceProvider).replaceSource(
            id: PermanentId.parse(definition.key),
            source: source,
          ),
      failureMessage: 'The icon source could not be replaced.',
    );
  }

  Future<void> _duplicate(IconDefinition definition) {
    return _runOperation(
      () => ref
          .read(iconLibraryServiceProvider)
          .duplicate(PermanentId.parse(definition.key)),
      failureMessage: 'The custom icon could not be duplicated.',
    );
  }

  Future<void> _delete(IconDefinition definition) async {
    final id = PermanentId.parse(definition.key);
    try {
      final usage = await ref.read(iconRepositoryProvider).usageCount(id);
      if (!mounted) {
        return;
      }
      final choice = await showDialog<_DeleteChoice>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _DeleteIconDialog(
          name: definition.displayName,
          usage: usage,
        ),
      );
      if (choice == null) {
        return;
      }
      IconSelection? replacement;
      var replaceWithDefaults = false;
      if (choice == _DeleteChoice.replace) {
        if (!mounted) {
          return;
        }
        replacement = await IconPickerDialog.show(
          context,
          scope: definition.scope,
        );
        if (replacement == null) {
          return;
        }
      } else if (choice == _DeleteChoice.defaults) {
        replaceWithDefaults = true;
      }
      await _runOperation(
        () => ref.read(iconLibraryServiceProvider).delete(
              id,
              replacement: replacement,
              replaceWithDefaults: replaceWithDefaults,
            ),
        failureMessage: 'The custom icon could not be deleted.',
      );
      if (mounted) {
        setState(() => _selectedIdentity = null);
      }
    } on Object catch (error, stackTrace) {
      _reportFailure(
        'The custom icon could not be deleted.',
        error,
        stackTrace,
      );
    }
  }

  Future<void> _runOperation(
    Future<Object?> Function() operation, {
    required String failureMessage,
  }) async {
    if (mounted) {
      setState(() => _working = true);
    }
    try {
      await operation();
      await _refresh();
    } on InvalidCustomIconFileException catch (error, stackTrace) {
      _reportFailure(error.message, error, stackTrace);
    } on Object catch (error, stackTrace) {
      _reportFailure(failureMessage, error, stackTrace);
    } finally {
      if (mounted) {
        setState(() => _working = false);
      }
    }
  }

  Future<void> _refresh() => ref.read(iconCatalogProvider.notifier).refresh();

  void _reportFailure(
    String userMessage,
    Object error,
    StackTrace stackTrace,
  ) {
    ref.read(appLogServiceProvider).logger('icons.ui').severe(
          userMessage,
          error,
          stackTrace,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userMessage)),
      );
    }
  }

  static String _identity(IconDefinition definition) =>
      '${definition.source.storageValue}:${definition.key}';
}

class _LibrarySummary extends StatelessWidget {
  const _LibrarySummary({required this.working});

  final bool working;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              '${BuiltInIconRegistry.definitions.length} packaged icons',
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Built-in icons stay available; imported files are copied into managed storage.',
          ),
        ),
        if (working)
          const SizedBox.square(
              dimension: 22, child: CircularProgressIndicator()),
      ],
    );
  }
}

class _LibraryCatalog extends ConsumerWidget {
  const _LibraryCatalog({
    required this.snapshot,
    required this.supportRoot,
    required this.selectedIdentity,
    required this.onSelected,
    required this.onImport,
  });

  final IconCatalogSnapshot snapshot;
  final Uri supportRoot;
  final String? selectedIdentity;
  final ValueChanged<IconDefinition> onSelected;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(iconCatalogProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('icon-library-search'),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Search icon library',
                  ),
                  onChanged: controller.setQuery,
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: onImport,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Import Custom Icon'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SegmentedButton<IconScope>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: IconScope.battery,
                      label: Text('Battery'),
                    ),
                    ButtonSegment(
                      value: IconScope.batterySet,
                      label: Text('Set'),
                    ),
                    ButtonSegment(
                      value: IconScope.device,
                      label: Text('Device'),
                    ),
                  ],
                  selected: {snapshot.scope},
                  onSelectionChanged: (selection) async {
                    await controller.setScope(selection.single);
                  },
                ),
                const SizedBox(width: 12),
                SegmentedButton<IconCatalogSource>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: IconCatalogSource.all,
                      label: Text('All'),
                    ),
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
                  onSelectionChanged: (selection) {
                    controller.setSourceFilter(selection.single);
                  },
                ),
                const SizedBox(width: 12),
                DropdownButton<String?>(
                  value: snapshot.category,
                  hint: const Text('All categories'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All categories'),
                    ),
                    for (final category in snapshot.categories)
                      DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                  ],
                  onChanged: controller.setCategory,
                ),
              ],
            ),
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
                      maxCrossAxisExtent: 140,
                      mainAxisExtent: 132,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: snapshot.definitions.length,
                    itemBuilder: (context, index) {
                      final definition = snapshot.definitions[index];
                      final identity =
                          '${definition.source.storageValue}:${definition.key}';
                      return _LibraryIconTile(
                        definition: definition,
                        selected: identity == selectedIdentity,
                        supportRoot: supportRoot,
                        fallback: IconRegistry(
                          builtIns: BuiltInIconRegistry.definitions,
                        ).defaultFor(snapshot.scope),
                        onTap: () => onSelected(definition),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _LibraryIconTile extends StatelessWidget {
  const _LibraryIconTile({
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
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconVisual(
                definition: definition,
                color: definition.defaultColor,
                fallbackDefinition: fallback,
                applicationSupportRoot: supportRoot,
                size: 50,
              ),
              const SizedBox(height: 8),
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

class _IconDetails extends StatelessWidget {
  const _IconDetails({
    required this.definition,
    required this.supportRoot,
    required this.scope,
    required this.working,
    required this.onEdit,
    required this.onReplace,
    required this.onDuplicate,
    required this.onDelete,
  });

  final IconDefinition? definition;
  final Uri supportRoot;
  final IconScope scope;
  final bool working;
  final VoidCallback? onEdit;
  final VoidCallback? onReplace;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final selected = definition;
    if (selected == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Text(
            'Select an icon to preview it and manage custom icon details.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final fallback = IconRegistry(
      builtIns: BuiltInIconRegistry.definitions,
    ).defaultFor(scope);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: IconVisual(
              definition: selected,
              color: selected.defaultColor,
              fallbackDefinition: fallback,
              applicationSupportRoot: supportRoot,
              size: 82,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Selected: ${selected.displayName}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            '${selected.category} · ${selected.source == IconSource.builtin ? 'Built-In' : 'Custom'}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          if (selected.source == IconSource.builtin)
            const Text(
              'This packaged icon is always available and cannot be edited or deleted.',
              textAlign: TextAlign.center,
            )
          else ...[
            OutlinedButton.icon(
              onPressed: working ? null : onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Details'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: working ? null : onReplace,
              icon: const Icon(Icons.swap_horiz_outlined),
              label: const Text('Replace Source'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: working ? null : onDuplicate,
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Duplicate'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: working ? null : onDelete,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('The icon library could not be loaded.'),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ),
    );
  }
}

enum _DeleteChoice { delete, replace, defaults }

class _DeleteIconDialog extends StatelessWidget {
  const _DeleteIconDialog({required this.name, required this.usage});

  final String name;
  final IconUsage usage;

  @override
  Widget build(BuildContext context) {
    final inUse = usage.total > 0;
    return AlertDialog(
      title: Text('Delete $name?'),
      content: Text(
        inUse
            ? 'This icon is currently used by ${usage.total} ${usage.total == 1 ? 'record' : 'records'}.'
            : 'The managed icon file and its inactive library entry will no longer be available.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (inUse) ...[
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(_DeleteChoice.replace),
            child: const Text('Replace With Another Icon'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_DeleteChoice.defaults),
            child: const Text('Replace With Defaults and Delete'),
          ),
        ] else
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_DeleteChoice.delete),
            child: const Text('Delete Icon'),
          ),
      ],
    );
  }
}
