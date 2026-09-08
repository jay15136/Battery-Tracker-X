import 'dart:typed_data';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/features/qr_labels/domain/labels.dart';
import 'package:battery_tracker/services/zxing_qr_code_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  final id = PermanentId.parse('12345678-1234-4234-9234-123456789abc');
  const qr = ZxingQrCodeService();
  for (final kind in LabelKind.values) {
    test('${kind.host} stable UUID URI survives QR image round trip', () async {
      final ref = LabelRef(kind, id);
      expect(LabelRef.parse('  ${ref.uri}  '), ref);
      expect(await qr.decode(qr.render(ref.uri)), ref.uri);
    });
  }
  test('rejects malformed, foreign, display-ID and ambiguous QR payloads', () {
    for (final value in [
      'AA-001',
      'https://battery/${id.value}',
      'batterytracker://other/${id.value}',
      'batterytracker://battery/AA-001',
      'batterytracker://battery/${id.value}/extra',
      'batterytracker://battery/${id.value}?x=1',
      'batterytracker://battery/${id.value}#x',
      'batterytracker://user@battery/${id.value}',
      'batterytracker://battery:90/${id.value}',
    ]) {
      expect(() => LabelRef.parse(value),
          throwsA(isA<LabelValidationException>()));
    }
  });
  test('unreadable image returns no match', () async {
    expect(await qr.decode(Uint8List.fromList([1, 2, 3])), isNull);
    expect(
        await qr.decode(Uint8List.fromList(
            img.encodePng(img.Image(width: 100, height: 100)))),
        isNull);
  });
  test('all presets serialize with valid geometry', () {
    for (final l in LabelLayout.presets.values) {
      l.validate();
      expect(LabelLayout.fromJson(l.toJson()).toJson(), l.toJson());
    }
  });
  test('sheet starts at requested slot and continues at next page first slot',
      () {
    final l = LabelLayout.presets['Address Label Sheet']!;
    const sheet = LabelSheet(enabled: true, start: 30);
    final p = sheet.positions(32, l);
    expect([p[0].page, p[0].x, p[0].y], [0, 409.5, 684]);
    expect([p[1].page, p[1].x, p[1].y], [1, 13.5, 36]);
    expect([p[30].page, p[30].x, p[30].y], [1, 409.5, 684]);
    expect([p[31].page, p[31].x, p[31].y], [2, 13.5, 36]);
    expect(LabelSheet.fromJson(sheet.toJson()).toJson(), sheet.toJson());
  });
  test('individual labels use separate pages and portrait swaps paper geometry',
      () {
    final l = LabelLayout(orientation: 'portrait');
    expect([l.pageWidth, l.pageHeight], [72, 144]);
    final positions = const LabelSheet().positions(3, l);
    expect(positions.map((p) => p.page), [0, 1, 2]);
    expect(positions.every((p) => p.x == 0 && p.y == 0), isTrue);
  });
  test('invalid sheet and label dimensions cannot produce output', () {
    for (final s in [
      const LabelSheet(enabled: true, start: 31),
      const LabelSheet(enabled: true, rows: 0),
      const LabelSheet(enabled: true, columns: 4),
      const LabelSheet(enabled: true, gapX: -1)
    ]) {
      expect(() => s.positions(1, LabelLayout.presets['Address Label Sheet']!),
          throwsA(isA<LabelValidationException>()));
    }
    for (final l in [
      LabelLayout(qrSize: 10),
      LabelLayout(fontSize: double.nan),
      LabelLayout(width: 36),
      LabelLayout(fields: ['unknown']),
      LabelLayout(margin: -1)
    ]) {
      expect(l.validate, throwsA(isA<LabelValidationException>()));
    }
    expect(() => const LabelSheet().positions(0, LabelLayout()),
        throwsA(isA<LabelValidationException>()));
    expect(() => const LabelSheet().positions(1001, LabelLayout()),
        throwsA(isA<LabelValidationException>()));
  });
}
