import 'dart:io';
import 'dart:ui' as ui;
import 'package:crypto/crypto.dart';
import '../../../core/identity/permanent_id.dart';
import '../../../core/storage/managed_relative_path.dart';
import '../domain/photo.dart';

/// Validates the actual image before copying the exact inspected bytes.
final class LocalPhotoStorage implements PhotoStorage {
  const LocalPhotoStorage(this.root);
  final Uri root;
  static const maxBytes = 25 * 1024 * 1024;
  static const maxPixels = 40000000;

  @override
  Future<StoredPhoto> import(Uri source, PermanentId revisionId) async {
    if (source.scheme != 'file')
      throw const PhotoException(
          'Choose a local PNG, JPEG, or WebP photograph.');
    final input = File.fromUri(source);
    if (!await input.exists())
      throw const PhotoException('The selected photograph is unavailable.');
    final length = await input.length();
    if (length == 0 || length > maxBytes)
      throw const PhotoException('Photographs must be no larger than 25 MB.');
    final bytes = await input.readAsBytes();
    if (bytes.isEmpty || bytes.length > maxBytes)
      throw const PhotoException('Photographs must be no larger than 25 MB.');
    String extension;
    if (bytes.length >= 8 &&
        bytes[0] == 137 &&
        bytes[1] == 80 &&
        bytes[2] == 78 &&
        bytes[3] == 71 &&
        bytes[4] == 13 &&
        bytes[5] == 10 &&
        bytes[6] == 26 &&
        bytes[7] == 10) {
      extension = 'png';
    } else if (bytes.length >= 3 &&
        bytes[0] == 255 &&
        bytes[1] == 216 &&
        bytes[2] == 255) {
      extension = 'jpg';
    } else if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
      extension = 'webp';
    } else {
      throw const PhotoException(
          'Choose a valid PNG, JPEG, or WebP photograph.');
    }
    ui.ImmutableBuffer? buffer;
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    late int width, height;
    try {
      buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      width = descriptor.width;
      height = descriptor.height;
      if (width <= 0 || height <= 0 || width * height > maxPixels)
        throw const PhotoException(
            'Photographs must be no larger than 40 megapixels.');
      codec = await descriptor.instantiateCodec(
          targetWidth: width > 1600 ? 1600 : width);
      final frame = await codec.getNextFrame();
      frame.image.dispose();
    } on PhotoException {
      rethrow;
    } on Object {
      throw const PhotoException(
          'This photograph cannot be decoded. Choose another image.');
    } finally {
      codec?.dispose();
      descriptor?.dispose();
      buffer?.dispose();
    }
    final path =
        ManagedRelativePath.parse('photos/${revisionId.value}.$extension');
    final output = await _resolve(path);
    try {
      await output.writeAsBytes(bytes, flush: true);
    } on Object {
      if (await output.exists()) await output.delete();
      rethrow;
    }
    return StoredPhoto(
        path: path,
        filename: input.uri.pathSegments.last,
        mimeType: extension == 'jpg' ? 'image/jpeg' : 'image/$extension',
        byteSize: bytes.length,
        width: width,
        height: height,
        checksum: sha256.convert(bytes).toString());
  }

  Future<File> _resolve(ManagedRelativePath path) async {
    if (!RegExp(r'^photos/[0-9a-f-]{36}\.(png|jpg|webp)$').hasMatch(path.value))
      throw const PhotoException('Invalid managed photograph reference.');
    final parent = Directory.fromUri(root.resolve('photos/'));
    await parent.create(recursive: true);
    final canonicalRoot = await Directory.fromUri(root).resolveSymbolicLinks();
    final canonicalParent = await parent.resolveSymbolicLinks();
    final expected = Directory('$canonicalRoot${Platform.pathSeparator}photos')
        .absolute
        .path;
    if (canonicalParent != expected)
      throw const PhotoException(
          'Photograph storage points outside the application directory.');
    final file = File.fromUri(root.resolve(path.value));
    if (await FileSystemEntity.type(file.path, followLinks: false) ==
        FileSystemEntityType.link)
      throw const PhotoException('Photograph links are not supported.');
    return file;
  }

  @override
  Future<bool> exists(ManagedRelativePath path) async =>
      (await _resolve(path)).exists();
  @override
  Future<void> delete(ManagedRelativePath path) async {
    final file = await _resolve(path);
    if (await file.exists()) await file.delete();
  }
}
