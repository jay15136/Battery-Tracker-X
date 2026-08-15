import 'package:battery_tracker/core/storage/managed_relative_path.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ManagedRelativePath', () {
    test('normalizes Windows separators to logical forward slashes', () {
      final path = ManagedRelativePath.parse(
        r'photos\batteries\550e8400-e29b-41d4-a716-446655440000\primary.png',
      );

      expect(
        path.value,
        'photos/batteries/550e8400-e29b-41d4-a716-446655440000/primary.png',
      );
    });

    test('rejects absolute and parent-traversal paths', () {
      const unsafePaths = <String>[
        r'C:\Users\person\photo.png',
        r'\\server\share\photo.png',
        '/Users/person/photo.png',
        '../photo.png',
        'photos/../photo.png',
      ];

      for (final value in unsafePaths) {
        expect(
          () => ManagedRelativePath.parse(value),
          throwsA(isA<FormatException>()),
          reason: value,
        );
      }
    });

    test('joins validated path segments without exposing host separators', () {
      final path = ManagedRelativePath.fromSegments(const [
        'custom_icons',
        '550e8400-e29b-41d4-a716-446655440000',
        'icon.svg',
      ]);

      expect(
        path.value,
        'custom_icons/550e8400-e29b-41d4-a716-446655440000/icon.svg',
      );
    });
  });
}
