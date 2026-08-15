import 'icon_color.dart';
import 'icon_definition.dart';

final class IconSelection {
  const IconSelection({
    required this.source,
    required this.key,
    required this.color,
  });

  final IconSource source;
  final String key;
  final IconColor color;

  @override
  bool operator ==(Object other) =>
      other is IconSelection &&
      other.source == source &&
      other.key == key &&
      other.color == color;

  @override
  int get hashCode => Object.hash(source, key, color);
}
