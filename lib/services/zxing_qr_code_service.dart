import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';
import '../features/qr_labels/domain/labels.dart';
import 'platform_service_contracts.dart';

final class ZxingQrCodeService implements QrCodeService {
  const ZxingQrCodeService();
  @override
  Uint8List render(Uri value) {
    LabelRef.parse(value.toString());
    final matrix =
        Encoder.encode(value.toString(), ErrorCorrectionLevel.m).matrix!;
    const border = 4, scale = 8;
    final image = img.Image(
        width: (matrix.width + border * 2) * scale,
        height: (matrix.height + border * 2) * scale,
        numChannels: 3);
    img.fill(image, color: img.ColorRgb8(255, 255, 255));
    for (var x = 0; x < matrix.width; x++) {
      for (var y = 0; y < matrix.height; y++) {
        if (matrix.get(x, y) == 1)
          img.fillRect(image,
              x1: (x + border) * scale,
              y1: (y + border) * scale,
              x2: (x + border + 1) * scale - 1,
              y2: (y + border + 1) * scale - 1,
              color: img.ColorRgb8(0, 0, 0));
      }
    }
    return img.encodePng(image);
  }

  @override
  Future<Uri?> decode(Uint8List bytes) async {
    if (bytes.length > 30 * 1024 * 1024)
      throw const LabelValidationException(
          'QR image is too large. Use an image under 30 MB.');
    img.Image? decoded;
    try {
      decoded = img.decodeImage(bytes);
    } on Object {
      return null;
    }
    if (decoded == null) return null;
    final image = decoded.width > 2400 || decoded.height > 2400
        ? img.copyResize(decoded,
            width: decoded.width >= decoded.height ? 2400 : null,
            height: decoded.height > decoded.width ? 2400 : null)
        : decoded;
    try {
      final source = RGBLuminanceSource(
          image.width,
          image.height,
          image
              .convert(numChannels: 4)
              .getBytes(order: img.ChannelOrder.abgr)
              .buffer
              .asInt32List());
      final result =
          QRCodeReader().decode(BinaryBitmap(HybridBinarizer(source)));
      return LabelRef.parse(result.text).uri;
    } on ReaderException {
      return null;
    }
  }
}
