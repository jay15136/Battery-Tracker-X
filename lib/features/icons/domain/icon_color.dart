final class IconColor {
  const IconColor._(this.value);

  static const defaultColor = IconColor._('#607D8B');
  static const black = IconColor._('#212121');
  static const gray = IconColor._('#757575');
  static const white = IconColor._('#FFFFFF');
  static const red = IconColor._('#F44336');
  static const orange = IconColor._('#FF9800');
  static const yellow = IconColor._('#FBC02D');
  static const green = IconColor._('#43A047');
  static const blue = IconColor._('#2196F3');
  static const purple = IconColor._('#7E57C2');
  static const brown = IconColor._('#795548');

  static const presets = [
    IconColorPreset(label: 'Default', color: defaultColor),
    IconColorPreset(label: 'Black', color: black),
    IconColorPreset(label: 'Gray', color: gray),
    IconColorPreset(label: 'White', color: white),
    IconColorPreset(label: 'Red', color: red),
    IconColorPreset(label: 'Orange', color: orange),
    IconColorPreset(label: 'Yellow', color: yellow),
    IconColorPreset(label: 'Green', color: green),
    IconColorPreset(label: 'Blue', color: blue),
    IconColorPreset(label: 'Purple', color: purple),
    IconColorPreset(label: 'Brown', color: brown),
  ];

  factory IconColor.parse(String value) {
    final normalized = value.trim().toUpperCase();
    if (!RegExp(r'^#[0-9A-F]{6}$').hasMatch(normalized)) {
      throw FormatException(
        'Icon color must use six-digit hexadecimal notation such as #3F51B5.',
        value,
      );
    }
    return IconColor._(normalized);
  }

  final String value;

  int get argbValue => 0xFF000000 | int.parse(value.substring(1), radix: 16);

  @override
  bool operator ==(Object other) => other is IconColor && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

final class IconColorPreset {
  const IconColorPreset({required this.label, required this.color});

  final String label;
  final IconColor color;
}
