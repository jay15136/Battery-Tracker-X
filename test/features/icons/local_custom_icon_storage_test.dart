import 'dart:io';

import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/features/icons/data/local_custom_icon_storage.dart';
import 'package:battery_tracker/features/icons/domain/custom_icon_storage.dart';
import 'package:battery_tracker/features/icons/domain/icon_definition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;
  late Directory sources;
  late LocalCustomIconStorage storage;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('battery-tracker-icons-root-');
    sources = await Directory.systemTemp.createTemp(
      'battery-tracker-icons-source-',
    );
    storage = LocalCustomIconStorage(applicationSupportRoot: root.uri);
  });

  tearDown(() async {
    await root.delete(recursive: true);
    await sources.delete(recursive: true);
  });

  test('validates and copies PNG independently of the original path', () async {
    final source = File('${sources.path}${Platform.pathSeparator}crest.PNG');
    await source.writeAsBytes([
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
      ...List<int>.filled(96, 0),
    ]);
    final ownerId = _id('10000000-0000-4000-8000-000000000001');
    final revisionId = _id('20000000-0000-4000-8000-000000000001');

    final inspection = await storage.inspect(source.uri);
    final managed = await storage.copySource(
      source: source.uri,
      ownerId: ownerId,
      revisionId: revisionId,
    );
    await source.delete();

    expect(inspection.fileType, IconFileType.png);
    expect(inspection.byteSize, 104);
    expect(
      managed.value,
      'custom_icons/${ownerId.value}/source-${revisionId.value}.png',
    );
    expect(await storage.exists(managed), isTrue);
  });

  test('accepts a local self-contained SVG', () async {
    final source = File('${sources.path}${Platform.pathSeparator}radio.svg');
    await source.writeAsString(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">'
      '<path d="M8 8h48v48H8z" fill="#000000"/></svg>',
    );

    final result = await storage.inspect(source.uri);

    expect(result.fileType, IconFileType.svg);
    expect(result.byteSize, greaterThan(100));
  });

  test('rejects bad PNG signatures, unsupported files, and unsafe SVG',
      () async {
    final badPng = File('${sources.path}${Platform.pathSeparator}bad.png');
    final text = File('${sources.path}${Platform.pathSeparator}icon.jpg');
    final unsafeSvg =
        File('${sources.path}${Platform.pathSeparator}unsafe.svg');
    await badPng.writeAsBytes(List<int>.filled(32, 0));
    await text.writeAsString('not supported');
    await unsafeSvg.writeAsString(
      '<svg xmlns="http://www.w3.org/2000/svg">'
      '<script>alert(1)</script><image href="https://example.test/a.png"/>'
      '</svg>',
    );

    for (final file in [badPng, text, unsafeSvg]) {
      await expectLater(
        storage.inspect(file.uri),
        throwsA(isA<InvalidCustomIconFileException>()),
        reason: file.path,
      );
    }
  });

  test('rejects files beyond the bounded import size', () async {
    final source = File('${sources.path}${Platform.pathSeparator}large.svg');
    await source.writeAsString(
      '<svg xmlns="http://www.w3.org/2000/svg"><path d="M0 0"/>'
      '${' '.padRight(LocalCustomIconStorage.maxSvgBytes)}'
      '</svg>',
    );

    await expectLater(
      storage.inspect(source.uri),
      throwsA(isA<InvalidCustomIconFileException>()),
    );
  });

  test('copies managed sources for duplication and deletes only that file',
      () async {
    final source = File('${sources.path}${Platform.pathSeparator}radio.svg');
    await source.writeAsString(
      '<svg xmlns="http://www.w3.org/2000/svg"><path d="M2 2h20v20H2z"/>'
      '</svg>',
    );
    final original = await storage.copySource(
      source: source.uri,
      ownerId: _id('10000000-0000-4000-8000-000000000002'),
      revisionId: _id('20000000-0000-4000-8000-000000000002'),
    );

    final duplicate = await storage.copyManaged(
      source: original,
      ownerId: _id('10000000-0000-4000-8000-000000000003'),
      revisionId: _id('20000000-0000-4000-8000-000000000003'),
    );
    await storage.delete(duplicate);

    expect(await storage.exists(original), isTrue);
    expect(await storage.exists(duplicate), isFalse);
  });
}

PermanentId _id(String value) => PermanentId.parse(value);
