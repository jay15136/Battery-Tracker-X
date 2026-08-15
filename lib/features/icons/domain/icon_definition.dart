import 'icon_color.dart';

enum IconScope {
  battery('battery', 'Battery'),
  batterySet('battery_set', 'Battery Set'),
  device('device', 'Device'),
  general('general', 'General');

  const IconScope(this.storageValue, this.label);

  final String storageValue;
  final String label;

  static IconScope fromStorage(String value) => values.firstWhere(
        (scope) => scope.storageValue == value,
        orElse: () => throw FormatException('Unknown icon scope: $value'),
      );
}

enum IconSource {
  builtin('builtin'),
  custom('custom');

  const IconSource(this.storageValue);

  final String storageValue;

  static IconSource fromStorage(String value) => values.firstWhere(
        (source) => source.storageValue == value,
        orElse: () => throw FormatException('Unknown icon source: $value'),
      );
}

enum IconFileType { svg, png }

final class IconDefinition {
  const IconDefinition._({
    required this.key,
    required this.displayName,
    required this.scope,
    required this.category,
    required this.location,
    required this.fileType,
    required this.source,
    required this.supportsColor,
    required this.defaultColor,
    required this.keywords,
    required this.deprecatedReplacementKey,
  });

  const IconDefinition.builtIn({
    required String key,
    required String displayName,
    required IconScope scope,
    required String category,
    required String location,
    required IconColor defaultColor,
    List<String> keywords = const [],
    bool supportsColor = true,
    String? deprecatedReplacementKey,
  }) : this._(
          key: key,
          displayName: displayName,
          scope: scope,
          category: category,
          location: location,
          fileType: IconFileType.svg,
          source: IconSource.builtin,
          supportsColor: supportsColor,
          defaultColor: defaultColor,
          keywords: keywords,
          deprecatedReplacementKey: deprecatedReplacementKey,
        );

  const IconDefinition.custom({
    required String key,
    required String displayName,
    required IconScope scope,
    required String category,
    required String location,
    required IconFileType fileType,
    required bool supportsColor,
    IconColor defaultColor = IconColor.defaultColor,
    List<String> keywords = const [],
  }) : this._(
          key: key,
          displayName: displayName,
          scope: scope,
          category: category,
          location: location,
          fileType: fileType,
          source: IconSource.custom,
          supportsColor: supportsColor,
          defaultColor: defaultColor,
          keywords: keywords,
          deprecatedReplacementKey: null,
        );

  final String key;
  final String displayName;
  final IconScope scope;
  final String category;
  final String location;
  final IconFileType fileType;
  final IconSource source;
  final bool supportsColor;
  final IconColor defaultColor;
  final List<String> keywords;
  final String? deprecatedReplacementKey;

  bool get isDeprecated => deprecatedReplacementKey != null;
}
