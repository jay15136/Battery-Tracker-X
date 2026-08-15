import 'icon_color.dart';
import 'icon_definition.dart';
import 'icon_selection.dart';

enum IconFallbackReason { missing, deprecated, wrongScope }

final class ResolvedIcon {
  const ResolvedIcon({
    required this.definition,
    required this.color,
    this.fallbackReason,
  });

  final IconDefinition definition;
  final IconColor color;
  final IconFallbackReason? fallbackReason;

  bool get usedFallback => fallbackReason != null;
}

final class IconRegistry {
  IconRegistry({
    required Iterable<IconDefinition> builtIns,
    Iterable<IconDefinition> customIcons = const [],
  })  : _builtIns = List.unmodifiable(builtIns),
        _definitions = List.unmodifiable([...builtIns, ...customIcons]) {
    final keys = <String>{};
    for (final definition in _definitions) {
      if (!keys.add('${definition.source.storageValue}:${definition.key}')) {
        throw StateError('Duplicate icon definition: ${definition.key}');
      }
    }
  }

  final List<IconDefinition> _builtIns;
  final List<IconDefinition> _definitions;

  List<IconDefinition> get definitions => _definitions;

  IconDefinition defaultFor(IconScope scope) {
    final key = switch (scope) {
      IconScope.battery => 'battery_generic',
      IconScope.batterySet => 'battery_set_generic',
      IconScope.device || IconScope.general => 'device_generic',
    };
    return _builtIns.firstWhere(
      (definition) => definition.key == key,
      orElse: () => throw StateError('Missing built-in default icon: $key'),
    );
  }

  List<IconDefinition> search({
    required IconScope scope,
    String query = '',
    String? category,
    IconSource? source,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    final normalizedCategory = category?.trim().toLowerCase();
    final matches = _definitions.where((definition) {
      if (definition.scope != scope && definition.scope != IconScope.general) {
        return false;
      }
      if (source != null && definition.source != source) {
        return false;
      }
      if (normalizedCategory != null &&
          normalizedCategory.isNotEmpty &&
          definition.category.toLowerCase() != normalizedCategory) {
        return false;
      }
      if (normalizedQuery.isEmpty) {
        return true;
      }
      final haystack = [
        definition.displayName,
        definition.key,
        definition.category,
        ...definition.keywords,
      ].join(' ').toLowerCase();
      return haystack.contains(normalizedQuery);
    }).toList()
      ..sort(
        (left, right) => left.displayName.compareTo(right.displayName),
      );
    return List.unmodifiable(matches);
  }

  ResolvedIcon resolve({
    required IconScope scope,
    required IconSelection selection,
  }) {
    final matching = _definitions.where(
      (definition) =>
          definition.source == selection.source &&
          definition.key == selection.key,
    );
    if (matching.isEmpty) {
      return ResolvedIcon(
        definition: defaultFor(scope),
        color: selection.color,
        fallbackReason: IconFallbackReason.missing,
      );
    }

    final definition = matching.single;
    if (definition.scope != scope && definition.scope != IconScope.general) {
      return ResolvedIcon(
        definition: defaultFor(scope),
        color: selection.color,
        fallbackReason: IconFallbackReason.wrongScope,
      );
    }

    if (definition.deprecatedReplacementKey case final replacementKey?) {
      final replacement = _builtIns.where(
        (candidate) => candidate.key == replacementKey,
      );
      return ResolvedIcon(
        definition:
            replacement.isEmpty ? defaultFor(scope) : replacement.single,
        color: selection.color,
        fallbackReason: IconFallbackReason.deprecated,
      );
    }

    return ResolvedIcon(
      definition: definition,
      color: selection.color,
    );
  }
}
