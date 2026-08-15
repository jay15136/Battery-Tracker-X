import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PermanentId', () {
    test('normalizes a valid UUID to its canonical lowercase form', () {
      final id = PermanentId.parse(
        '550E8400-E29B-41D4-A716-446655440000',
      );

      expect(id.value, '550e8400-e29b-41d4-a716-446655440000');
      expect(id.toString(), id.value);
    });

    test('rejects an editable display identifier', () {
      expect(
        () => PermanentId.parse('AA-001'),
        throwsA(isA<FormatException>()),
      );
    });

    test('generated values are distinct RFC UUID version 4 identifiers', () {
      const generator = UuidV4PermanentIdGenerator();

      final first = generator.next();
      final second = generator.next();

      expect(first, isNot(second));
      expect(first.value, matches(RegExp(r'^[0-9a-f-]{36}$')));
      expect(first.value.split('-')[2].startsWith('4'), isTrue);
    });
  });
}
