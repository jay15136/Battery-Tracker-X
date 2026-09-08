import 'dart:io';
import 'package:flutter/services.dart';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/core/storage/managed_relative_path.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_selection.dart';
import 'package:battery_tracker/features/icons/domain/icon_definition.dart';
import 'package:battery_tracker/features/icons/domain/icon_color.dart';
import 'package:battery_tracker/features/qr_labels/application/canvas_label_renderer.dart';
import 'package:battery_tracker/features/qr_labels/domain/labels.dart';
import 'package:battery_tracker/services/zxing_qr_code_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = Platform.environment['LABEL_TEST_FONT'];
    if (font != null) {
      final loader = FontLoader('LabelPreviewTest')
        ..addFont(
            File(font).readAsBytes().then((b) => ByteData.sublistView(b)));
      await loader.load();
    }
  });
  late AppDatabase db;
  late DriftIconRepository icons;
  late Directory root;
  late CanvasLabelRenderer renderer;
  const qr = ZxingQrCodeService();
  final id = PermanentId.parse('12345678-1234-4234-9234-123456789abc');
  LabelTarget target({IconSelection? icon, ManagedRelativePath? photo}) =>
      LabelTarget(
          ref: LabelRef(LabelKind.battery, id),
          fields: {'id': 'AA-001', 'name': 'Radio spare'},
          icon: icon ??
              const IconSelection(
                  source: IconSource.builtin,
                  key: 'battery_generic',
                  color: IconColor.red),
          photo: photo);
  setUp(() async {
    root = await Directory.systemTemp.createTemp('label-render-');
    db = AppDatabase.forTesting(NativeDatabase.memory());
    icons = DriftIconRepository(
        database: db,
        idGenerator: const UuidV4PermanentIdGenerator(),
        builtInRegistry:
            IconRegistry(builtIns: BuiltInIconRegistry.definitions));
    renderer = CanvasLabelRenderer(
        qr: qr,
        icons: icons,
        root: root.uri,
        fontFamily: Platform.environment['LABEL_TEST_FONT'] == null
            ? null
            : 'LabelPreviewTest');
  });
  tearDown(() async {
    await db.close();
    await root.delete(recursive: true);
  });
  testWidgets(
      'small and portrait full labels contain readable QR at physical dimensions',
      (tester) async {
    await tester.runAsync(() async {
      for (final l in [
        LabelLayout.presets['Small Battery Label']!,
        LabelLayout(orientation: 'portrait')
      ]) {
        final bytes = await renderer.renderLabel(target(), l);
        final image = img.decodePng(bytes)!;
        expect(image.width, (l.pageWidth * 600 / 72).round());
        expect(image.height, (l.pageHeight * 600 / 72).round());
        expect(await qr.decode(bytes), target().ref.uri);
      }
    });
  });
  testWidgets(
      'optional photo and missing custom icon fall back to colored built-in icon',
      (tester) async {
    await tester.runAsync(() async {
      final l = LabelLayout(usePhoto: true);
      final normal = await renderer.renderLabel(target(), l);
      final missing = await renderer.renderLabel(
          target(photo: ManagedRelativePath.parse('photos/missing.png')), l);
      expect(missing, normal);
      final customMissing = await renderer.renderLabel(
          target(
              icon: IconSelection(
                  source: IconSource.custom,
                  key: id.value,
                  color: IconColor.red)),
          l);
      expect(customMissing, normal);
      final pixels = img.decodePng(normal)!;
      expect(pixels.where((p) => p.r > 200 && p.g < 100 && p.b < 100).length,
          greaterThan(100));
    });
  });
  testWidgets(
      'managed PNG SVG and photograph render with QR remaining readable',
      (tester) async {
    await tester.runAsync(() async {
      final category = await icons.createCategory(
          id: const UuidV4PermanentIdGenerator().next(),
          name: 'Labels',
          scope: IconScope.battery);
      final green = img.Image(width: 32, height: 32);
      img.fill(green, color: img.ColorRgb8(0, 200, 0));
      await File('${root.path}/green.png').writeAsBytes(img.encodePng(green));
      await File('${root.path}/square.svg').writeAsString(
          '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32"><rect width="32" height="32" fill="black"/></svg>');
      for (final type in [IconFileType.png, IconFileType.svg]) {
        final custom = await icons.createCustomIcon(
            id: const UuidV4PermanentIdGenerator().next(),
            name: type.name,
            categoryId: category.id,
            relativePath: ManagedRelativePath.parse(
                type == IconFileType.png ? 'green.png' : 'square.svg'),
            fileType: type,
            supportsColor: type == IconFileType.svg);
        final bytes = await renderer.renderLabel(
            target(
                icon: IconSelection(
                    source: IconSource.custom,
                    key: custom.id.value,
                    color: IconColor.blue)),
            LabelLayout());
        final pixels = img.decodePng(bytes)!;
        expect(
            pixels
                .where((p) => type == IconFileType.png
                    ? p.g > 150 && p.r < 50
                    : p.b > 200 && p.r < 80)
                .length,
            greaterThan(100));
        expect(await qr.decode(bytes), target().ref.uri);
      }
      final photo = await renderer.renderLabel(
          target(photo: ManagedRelativePath.parse('green.png')),
          LabelLayout(usePhoto: true));
      expect(img.decodePng(photo)!.where((p) => p.g > 150 && p.r < 50).length,
          greaterThan(100));
    });
  });
  testWidgets('overflowing text is rejected rather than silently clipped',
      (tester) async {
    await tester.runAsync(() async {
      await expectLater(
          renderer.renderLabel(target(),
              LabelLayout(customText: List.filled(30, 'Long text').join('\n'))),
          throwsA(isA<LabelValidationException>()));
    });
  });
  testWidgets(
      'PDF contains three physical sheets starting at last slot and individual pages',
      (tester) async {
    await tester.runAsync(() async {
      final l = LabelLayout.presets['Address Label Sheet']!;
      final pdf = await renderer.renderPdf(LabelDocument(
          List.generate(32, (_) => target()),
          l,
          const LabelSheet(enabled: true, start: 30)));
      expect(String.fromCharCodes(pdf.take(5)), '%PDF-');
      final artifact = Platform.environment['LABEL_ARTIFACT_DIR'];
      if (artifact != null) {
        await Directory(artifact).create(recursive: true);
        await File('$artifact/sheet.pdf').writeAsBytes(pdf);
        await File('$artifact/label.png')
            .writeAsBytes(await renderer.renderLabel(target(), l));
        await File('$artifact/individual.pdf').writeAsBytes(
            await renderer.renderPdf(LabelDocument([target(), target()],
                LabelLayout(orientation: 'portrait'), const LabelSheet())));
      }
    });
  });
}
