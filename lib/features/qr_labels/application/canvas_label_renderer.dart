import 'dart:io';
import 'dart:math' as math;

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:logging/logging.dart';
import '../../../core/identity/permanent_id.dart';
import '../../../core/storage/managed_relative_path.dart';
import '../../../services/platform_service_contracts.dart';
import '../../icons/data/built_in_icon_registry.dart';
import '../../icons/domain/icon_definition.dart';
import '../../icons/domain/icon_registry.dart';
import '../../icons/domain/icon_repository.dart';
import '../domain/labels.dart';

final class LabelDocument {
  LabelDocument(this.targets, this.layout, this.sheet);
  final List<LabelTarget> targets;
  final LabelLayout layout;
  final LabelSheet sheet;
}

abstract interface class LabelRenderer implements LabelService {
  Future<Uint8List> renderLabel(LabelTarget target, LabelLayout layout);
}

final class CanvasLabelRenderer implements LabelRenderer {
  CanvasLabelRenderer(
      {required this.qr,
      required this.icons,
      required this.root,
      this.fontFamily});
  final QrCodeService qr;
  final IconRepository icons;
  final Uri root;
  final String? fontFamily;
  final _registry = IconRegistry(builtIns: BuiltInIconRegistry.definitions);
  Future<ui.Image> _decode(Uint8List bytes, {bool qrImage = false}) async {
    final codec = await ui.instantiateImageCodec(bytes,
        targetWidth: qrImage ? null : 1000);
    try {
      return (await codec.getNextFrame()).image;
    } finally {
      codec.dispose();
    }
  }

  Future<ui.Image> _icon(LabelTarget target) async {
    final fallback = _registry.defaultFor(target.ref.kind.scope);
    var definition = _registry
        .resolve(scope: target.ref.kind.scope, selection: target.icon)
        .definition;
    if (target.icon.source == IconSource.custom) {
      try {
        final custom =
            await icons.getCustomIcon(PermanentId.parse(target.icon.key));
        if (custom.isActive)
          definition = IconRegistry(
                  builtIns: BuiltInIconRegistry.definitions,
                  customIcons: [custom.toDefinition()])
              .resolve(scope: target.ref.kind.scope, selection: target.icon)
              .definition;
      } on Object catch (e, s) {
        Logger('battery_tracker.labels.assets')
            .warning('Custom label icon unavailable; using fallback.', e, s);
      }
    }
    Future<ui.Image> load(IconDefinition d) async {
      ui.Image base;
      if (d.fileType == IconFileType.svg) {
        final svg = d.source == IconSource.builtin
            ? await rootBundle.loadString(d.location)
            : await File.fromUri(
                    root.resolve(ManagedRelativePath.parse(d.location).value))
                .readAsString();
        final info = await vg.loadPicture(SvgStringLoader(svg), null);
        try {
          final rec = ui.PictureRecorder(), c = Canvas(rec);
          c.scale(256 / info.size.width, 256 / info.size.height);
          c.drawPicture(info.picture);
          final p = rec.endRecording();
          try {
            base = await p.toImage(256, 256);
          } finally {
            p.dispose();
          }
        } finally {
          info.picture.dispose();
        }
      } else {
        base = await _decode(await File.fromUri(
                root.resolve(ManagedRelativePath.parse(d.location).value))
            .readAsBytes());
      }
      if (!d.supportsColor) return base;
      final rec = ui.PictureRecorder(), c = Canvas(rec);
      c.drawImage(
          base,
          Offset.zero,
          Paint()
            ..colorFilter = ColorFilter.mode(
                Color(target.icon.color.argbValue), BlendMode.srcIn));
      final p = rec.endRecording();
      try {
        return await p.toImage(base.width, base.height);
      } finally {
        base.dispose();
        p.dispose();
      }
    }

    try {
      return await load(definition);
    } on Object catch (e, s) {
      Logger('battery_tracker.labels.assets').warning(
          'Label icon could not be rendered; using built-in fallback.', e, s);
      return load(fallback);
    }
  }

  Future<ui.Image> _visual(LabelTarget t, bool photo) async {
    if (photo && t.photo != null) {
      try {
        final file = File.fromUri(root.resolve(t.photo!.value));
        if (await file.length() > 30 * 1024 * 1024)
          throw const FormatException('Photo too large');
        return await _decode(await file.readAsBytes());
      } on Object catch (e, s) {
        Logger('battery_tracker.labels.assets')
            .warning('Label photo unavailable; using icon.', e, s);
      }
    }
    return _icon(t);
  }

  @override
  Future<Uint8List> renderLabel(LabelTarget t, LabelLayout l) async {
    l.validate();
    const scale = 600 / 72;
    final width = l.pageWidth, height = l.pageHeight;
    final recorder = ui.PictureRecorder(), canvas = Canvas(recorder);
    canvas.scale(scale);
    canvas.drawRect(
        Rect.fromLTWH(0, 0, width, height), Paint()..color = Colors.white);
    final qrImage = await _decode(qr.render(t.ref.uri), qrImage: true);
    final qx = l.orientation == 'portrait' ? (width - l.qrSize) / 2 : l.margin;
    canvas.drawImageRect(
        qrImage,
        Rect.fromLTWH(
            0, 0, qrImage.width.toDouble(), qrImage.height.toDouble()),
        Rect.fromLTWH(qx, l.margin, l.qrSize, l.qrSize),
        Paint()..filterQuality = FilterQuality.none);
    qrImage.dispose();
    final x = l.orientation == 'portrait' ? l.margin : l.margin + l.qrSize + 4;
    var y = l.orientation == 'portrait' ? l.margin + l.qrSize + 4 : l.margin;
    final availableWidth = width - l.margin - x;
    if (l.showIcon || l.usePhoto) {
      final visual = await _visual(t, l.usePhoto);
      final size = math.min(24.0, (height - l.margin - y) * .35);
      final imageX = l.align == 'center'
          ? x + (availableWidth - size) / 2
          : l.align == 'right'
              ? width - l.margin - size
              : x;
      final ratio = math.min(size / visual.width, size / visual.height);
      canvas.drawImageRect(
          visual,
          Rect.fromLTWH(
              0, 0, visual.width.toDouble(), visual.height.toDouble()),
          Rect.fromLTWH(imageX, y, visual.width * ratio, visual.height * ratio),
          Paint()..filterQuality = FilterQuality.high);
      visual.dispose();
      y += size + 2;
    }
    final text = [
      for (final field in l.fields)
        if (t.fields[field]?.isNotEmpty ?? false) t.fields[field]!,
      if (l.customText.isNotEmpty) l.customText
    ].join('\n');
    final painter = TextPainter(
        text: TextSpan(
            text: text,
            style: TextStyle(
                color: Colors.black,
                fontSize: l.fontSize,
                height: 1.1,
                fontFamily: fontFamily)),
        textDirection: TextDirection.ltr,
        textAlign: l.align == 'center'
            ? TextAlign.center
            : l.align == 'right'
                ? TextAlign.right
                : TextAlign.left)
      ..layout(maxWidth: availableWidth);
    if (painter.height > height - l.margin - y + .1) {
      painter.dispose();
      recorder.endRecording().dispose();
      throw LabelValidationException('Text does not fit for ' +
          t.title +
          '. Reduce fields/font size or enlarge the label.');
    }
    painter.paint(canvas, Offset(x, y));
    painter.dispose();
    final picture = recorder.endRecording();
    try {
      final image = await picture.toImage(
          (width * scale).round(), (height * scale).round());
      try {
        return (await image.toByteData(format: ui.ImageByteFormat.png))!
            .buffer
            .asUint8List();
      } finally {
        image.dispose();
      }
    } finally {
      picture.dispose();
    }
  }

  @override
  Future<Uint8List> renderPdf(Object document) async {
    if (document is! LabelDocument)
      throw const LabelValidationException('Invalid label document.');
    final l = document.layout, s = document.sheet;
    final placements = s.positions(document.targets.length, l);
    final doc = pw.Document(title: 'Battery Tracker QR Labels');
    for (var page = 0; page <= placements.last.page; page++) {
      final items = <pw.Widget>[];
      for (final pos in placements.where((p) => p.page == page)) {
        final bytes = await renderLabel(document.targets[pos.index], l);
        items.add(pw.Positioned(
            left: pos.x,
            top: pos.y,
            child: pw.SizedBox(
                width: l.pageWidth,
                height: l.pageHeight,
                child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.fill))));
      }
      doc.addPage(pw.Page(
          pageFormat: PdfPageFormat(s.enabled ? s.paperWidth : l.pageWidth,
              s.enabled ? s.paperHeight : l.pageHeight, marginAll: 0),
          build: (_) => pw.SizedBox(
              width: s.enabled ? s.paperWidth : l.pageWidth,
              height: s.enabled ? s.paperHeight : l.pageHeight,
              child: pw.Stack(children: items))));
    }
    return doc.save();
  }
}
