import 'package:battery_tracker/features/icons/domain/icon_color.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IconColor', () {
    test('normalizes portable hexadecimal colors to uppercase', () {
      final color = IconColor.parse('#3f51b5');

      expect(color.value, '#3F51B5');
      expect(color.argbValue, 0xFF3F51B5);
    });

    test('rejects malformed and host-specific color values', () {
      for (final value in ['3F51B5', '#FFF', '#GG51B5', 'blue', '0xFF0000']) {
        expect(
          () => IconColor.parse(value),
          throwsA(isA<FormatException>()),
          reason: value,
        );
      }
    });

    test('provides every required predefined color', () {
      expect(
        IconColor.presets.map((preset) => preset.label),
        containsAll([
          'Default',
          'Black',
          'Gray',
          'White',
          'Red',
          'Orange',
          'Yellow',
          'Green',
          'Blue',
          'Purple',
          'Brown',
        ]),
      );
    });
  });
}
