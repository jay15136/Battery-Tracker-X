import 'dart:convert';
import 'dart:io';

import '../../../core/identity/permanent_id.dart';
import '../../../core/storage/managed_relative_path.dart';
import '../domain/custom_icon_storage.dart';
import '../domain/icon_definition.dart';

final class LocalCustomIconStorage implements CustomIconStorage {
  const LocalCustomIconStorage({required this.applicationSupportRoot});

  static const maxPngBytes = 5 * 1024 * 1024;
  static const maxSvgBytes = 1024 * 1024;
  static const _pngSignature = [
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
  ];

  final Uri applicationSupportRoot;

  @override
  Future<CustomIconInspection> inspect(Uri source) async {
    if (source.scheme != 'file') {
      throw const InvalidCustomIconFileException(
        'Only local PNG and SVG files can be imported.',
      );
    }
    final file = File.fromUri(source);
    if (!await file.exists()) {
      throw const InvalidCustomIconFileException(
        'The selected icon file is unavailable.',
      );
    }
    final extension = _extension(file.path);
    final byteSize = await file.length();
    return switch (extension) {
      'png' => _inspectPng(file, byteSize),
      'svg' => _inspectSvg(file, byteSize),
      _ => throw const InvalidCustomIconFileException(
          'Select a PNG or SVG icon file.',
        ),
    };
  }

  @override
  Future<ManagedRelativePath> copySource({
    required Uri source,
    required PermanentId ownerId,
    required PermanentId revisionId,
  }) async {
    final inspection = await inspect(source);
    final reference = _newReference(
      ownerId,
      revisionId,
      inspection.fileType,
    );
    await _copy(File.fromUri(source), reference);
    return reference;
  }

  @override
  Future<ManagedRelativePath> copyManaged({
    required ManagedRelativePath source,
    required PermanentId ownerId,
    required PermanentId revisionId,
  }) async {
    final sourceFile = _resolve(source);
    final inspection = await inspect(sourceFile.uri);
    final reference = _newReference(
      ownerId,
      revisionId,
      inspection.fileType,
    );
    await _copy(sourceFile, reference);
    return reference;
  }

  @override
  Future<bool> exists(ManagedRelativePath reference) =>
      _resolve(reference).exists();

  @override
  Future<void> delete(ManagedRelativePath reference) async {
    final file = _resolve(reference);
    if (!await file.exists()) {
      return;
    }
    await file.delete();
    final parent = file.parent;
    if (await parent.exists() && await parent.list().isEmpty) {
      await parent.delete();
    }
  }

  Future<CustomIconInspection> _inspectPng(File file, int byteSize) async {
    if (byteSize < _pngSignature.length || byteSize > maxPngBytes) {
      throw const InvalidCustomIconFileException(
        'PNG icons must be valid files no larger than 5 MB.',
      );
    }
    final bytes = await file.openRead(0, _pngSignature.length).first;
    for (var index = 0; index < _pngSignature.length; index++) {
      if (bytes[index] != _pngSignature[index]) {
        throw const InvalidCustomIconFileException(
          'The selected PNG signature is invalid.',
        );
      }
    }
    return CustomIconInspection(
      fileType: IconFileType.png,
      byteSize: byteSize,
    );
  }

  Future<CustomIconInspection> _inspectSvg(File file, int byteSize) async {
    if (byteSize == 0 || byteSize > maxSvgBytes) {
      throw const InvalidCustomIconFileException(
        'SVG icons must be valid files no larger than 1 MB.',
      );
    }
    late final String content;
    try {
      content = utf8.decode(await file.readAsBytes());
    } on FormatException {
      throw const InvalidCustomIconFileException(
        'The selected SVG is not valid UTF-8 text.',
      );
    }
    final normalized = content.trimLeft();
    if (!RegExp(r'<svg(?:\s|>)', caseSensitive: false).hasMatch(normalized)) {
      throw const InvalidCustomIconFileException(
        'The selected file does not contain an SVG root element.',
      );
    }
    final forbidden = [
      RegExp(r'<!DOCTYPE', caseSensitive: false),
      RegExp(r'<!ENTITY', caseSensitive: false),
      RegExp(r'<script(?:\s|>)', caseSensitive: false),
      RegExp(r'\son[a-z]+\s*=', caseSensitive: false),
      RegExp(r'<image(?:\s|>)', caseSensitive: false),
      RegExp(
        r'''(?:href|xlink:href)\s*=\s*["']\s*(?:https?:|//|file:|data:)''',
        caseSensitive: false,
      ),
    ];
    if (forbidden.any((pattern) => pattern.hasMatch(content))) {
      throw const InvalidCustomIconFileException(
        'The SVG contains scripts or external content and cannot be imported.',
      );
    }
    return CustomIconInspection(
      fileType: IconFileType.svg,
      byteSize: byteSize,
    );
  }

  ManagedRelativePath _newReference(
    PermanentId ownerId,
    PermanentId revisionId,
    IconFileType fileType,
  ) {
    return ManagedRelativePath.fromSegments([
      'custom_icons',
      ownerId.value,
      'source-${revisionId.value}.${fileType.name}',
    ]);
  }

  Future<void> _copy(File source, ManagedRelativePath reference) async {
    final destination = _resolve(reference);
    await destination.parent.create(recursive: true);
    if (await destination.exists()) {
      throw const InvalidCustomIconFileException(
        'A managed icon revision already exists.',
      );
    }
    await source.copy(destination.path);
  }

  File _resolve(ManagedRelativePath reference) =>
      File.fromUri(applicationSupportRoot.resolve(reference.value));

  String _extension(String path) {
    final name = path.replaceAll('\\', '/').split('/').last;
    final index = name.lastIndexOf('.');
    return index < 0 ? '' : name.substring(index + 1).toLowerCase();
  }
}
