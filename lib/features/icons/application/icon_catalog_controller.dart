import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../data/built_in_icon_registry.dart';
import '../domain/icon_definition.dart';
import '../domain/icon_registry.dart';
import '../domain/icon_repository.dart';
import '../domain/icon_selection.dart';

enum IconCatalogSource { all, builtin, custom, recent }

final class IconCatalogSnapshot {
  const IconCatalogSnapshot({
    required this.scope,
    required this.sourceFilter,
    required this.query,
    required this.category,
    required this.categories,
    required this.definitions,
    required this.recentSelections,
  });

  final IconScope scope;
  final IconCatalogSource sourceFilter;
  final String query;
  final String? category;
  final List<String> categories;
  final List<IconDefinition> definitions;
  final List<IconSelection> recentSelections;
}

final iconCatalogProvider =
    AsyncNotifierProvider<IconCatalogController, IconCatalogSnapshot>(
  IconCatalogController.new,
);

final class IconCatalogController extends AsyncNotifier<IconCatalogSnapshot> {
  IconScope _scope = IconScope.battery;
  IconCatalogSource _sourceFilter = IconCatalogSource.all;
  String _query = '';
  String? _category;
  List<CustomIconRecord> _customIcons = const [];
  List<IconCategoryRecord> _categories = const [];
  List<IconSelection> _recentSelections = const [];

  @override
  Future<IconCatalogSnapshot> build() async {
    await _reloadResources();
    return _snapshot();
  }

  void setQuery(String query) {
    _query = query;
    _emit();
  }

  void setSourceFilter(IconCatalogSource source) {
    _sourceFilter = source;
    _emit();
  }

  void setCategory(String? category) {
    final normalized = category?.trim();
    _category = normalized == null || normalized.isEmpty ? null : normalized;
    _emit();
  }

  Future<void> setScope(IconScope scope) async {
    if (_scope == scope) {
      return;
    }
    _scope = scope;
    _category = null;
    _recentSelections =
        await ref.read(iconRepositoryProvider).recentSelections(scope);
    _emit();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _reloadResources();
      return _snapshot();
    });
  }

  Future<void> _reloadResources() async {
    final repository = ref.read(iconRepositoryProvider);
    final results = await Future.wait([
      repository.listCustomIcons(),
      repository.listCategories(),
      repository.recentSelections(_scope),
    ]);
    _customIcons = results[0] as List<CustomIconRecord>;
    _categories = results[1] as List<IconCategoryRecord>;
    _recentSelections = results[2] as List<IconSelection>;
  }

  IconCatalogSnapshot _snapshot() {
    final registry = IconRegistry(
      builtIns: BuiltInIconRegistry.definitions,
      customIcons: _customIcons.map((icon) => icon.toDefinition()),
    );
    final categoryNames = _categories
        .where(
          (category) =>
              category.scope == _scope || category.scope == IconScope.general,
        )
        .map((category) => category.name)
        .toSet()
        .toList()
      ..sort();

    final source = switch (_sourceFilter) {
      IconCatalogSource.builtin => IconSource.builtin,
      IconCatalogSource.custom => IconSource.custom,
      IconCatalogSource.all || IconCatalogSource.recent => null,
    };
    final matching = registry.search(
      scope: _scope,
      query: _query,
      category: _category,
      source: source,
    );
    if (_sourceFilter != IconCatalogSource.recent) {
      return IconCatalogSnapshot(
        scope: _scope,
        sourceFilter: _sourceFilter,
        query: _query,
        category: _category,
        categories: List.unmodifiable(categoryNames),
        definitions: matching,
        recentSelections: _recentSelections,
      );
    }

    final matchingKeys = {
      for (final definition in matching)
        '${definition.source.storageValue}:${definition.key}',
    };
    final recentDefinitions = <IconDefinition>[];
    final validRecent = <IconSelection>[];
    for (final selection in _recentSelections) {
      final identity = '${selection.source.storageValue}:${selection.key}';
      if (!matchingKeys.contains(identity)) {
        continue;
      }
      final definition = matching.firstWhere(
        (candidate) =>
            candidate.source == selection.source &&
            candidate.key == selection.key,
      );
      recentDefinitions.add(definition);
      validRecent.add(selection);
    }
    return IconCatalogSnapshot(
      scope: _scope,
      sourceFilter: _sourceFilter,
      query: _query,
      category: _category,
      categories: List.unmodifiable(categoryNames),
      definitions: List.unmodifiable(recentDefinitions),
      recentSelections: List.unmodifiable(validRecent),
    );
  }

  void _emit() {
    if (state.hasValue) {
      state = AsyncData(_snapshot());
    }
  }
}
