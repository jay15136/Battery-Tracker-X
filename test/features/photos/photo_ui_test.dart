import 'dart:io';
import 'package:battery_tracker/app/app_providers.dart';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/core/logging/app_log_service.dart';
import 'package:battery_tracker/core/storage/managed_relative_path.dart';
import 'package:battery_tracker/features/photos/domain/photo.dart';
import 'package:battery_tracker/features/photos/data/drift_photo_repository.dart';
import 'package:battery_tracker/features/photos/application/photo_service.dart';
import 'package:battery_tracker/features/photos/presentation/photo_manager_dialog.dart';
import 'package:battery_tracker/features/photos/presentation/photo_visual.dart';
import 'package:battery_tracker/services/camera_service.dart';
import 'package:battery_tracker/services/dialog_camera_service.dart';
import 'package:battery_tracker/services/file_selection_service.dart';
import 'package:battery_tracker/services/photograph_drop_target.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

void main() {
  late Directory root;
  late AppDatabase db;
  late DriftPhotoRepository repository;
  late PhotoService service;
  late PhotoOwner owner;
  late _Picker picker;
  late _Camera camera;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('photos-ui-');
    db = AppDatabase.forTesting(NativeDatabase.memory());
    owner = PhotoOwner(
        PhotoOwnerKind.battery, const UuidV4PermanentIdGenerator().next());
    await db.into(db.batteries).insert(BatteriesCompanion.insert(
        uuid: owner.id.value, userBatteryId: 'AA-001'));
    repository = DriftPhotoRepository(db);
    service = PhotoService(
        repository: repository,
        storage: _Storage(root.uri),
        logger: Logger('test.photos'));
    picker = _Picker(
        File('android/app/src/main/res/mipmap-mdpi/ic_launcher.png')
            .absolute
            .uri);
    camera = _Camera();
  });
  tearDown(() async {
    await db.close();
    await root.delete(recursive: true);
  });
  Future<void> pump(WidgetTester tester, {bool dark = false}) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
        overrides: [
          photoServiceProvider.overrideWithValue(service),
          applicationSupportRootProvider.overrideWithValue(root.uri),
          fileSelectionServiceProvider.overrideWithValue(picker),
          cameraServiceFactoryProvider.overrideWithValue((_) => camera),
          appLogServiceProvider.overrideWithValue(_Logs())
        ],
        child: MaterialApp(
            theme: ThemeData(
                brightness: dark ? Brightness.dark : Brightness.light),
            home: Scaffold(
                body: PhotoManagerDialog(
                    owner: owner,
                    fallback: const Icon(Icons.battery_full,
                        key: ValueKey('icon-fallback')))))));
    await tester.pumpAndSettle();
  }

  testWidgets(
      'adding is optional and default choice preserves icon in dark mode',
      (tester) async {
    await pump(tester, dark: true);
    expect(picker.calls, 0);
    expect(camera.calls, 0);
    await tester.tap(find.text('Add Photograph'));
    await tester.pumpAndSettle();
    expect(find.text('Keep Icon as Primary'), findsOneWidget);
    await tester.tap(find.text('Keep Icon as Primary'));
    await tester.pumpAndSettle();
    expect((await repository.gallery(owner)).preferPhoto, isFalse);
    await tester.ensureVisible(find.text('Use Photo as Primary'));
    await tester.tap(find.text('Use Photo as Primary'));
    await tester.pumpAndSettle();
    expect((await repository.gallery(owner)).preferPhoto, isTrue);
    await tester.ensureVisible(find.text('Remove'));
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
    await tester.pumpAndSettle();
    expect((await repository.gallery(owner)).photos, isEmpty);
    expect((await repository.gallery(owner)).preferPhoto, isFalse);
  });
  testWidgets('picker and camera cancellation leave inventory unchanged',
      (tester) async {
    picker.source = null;
    await pump(tester);
    await tester.tap(find.text('Add Photograph'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Capture Photograph'));
    await tester.pumpAndSettle();
    expect(picker.calls, 1);
    expect(camera.calls, 1);
    expect((await repository.gallery(owner)).photos, isEmpty);
  });
  testWidgets('drop callback imports through the same managed workflow',
      (tester) async {
    await pump(tester);
    tester
        .widget<PhotographDropTarget>(find.byType(PhotographDropTarget))
        .onFiles([picker.source!]);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep Icon as Primary'));
    await tester.pumpAndSettle();
    expect((await repository.gallery(owner)).photos.length, 1);
  });
  testWidgets('missing and corrupt images render inventory icon',
      (tester) async {
    final path = ManagedRelativePath.parse(
        'photos/00000000-0000-4000-8000-000000000001.png');
    var reports = 0;
    Future<void> visual() async {
      await tester.pumpWidget(MaterialApp(
          home: PhotoVisual(
              root: root.uri,
              path: path,
              fallback:
                  const Icon(Icons.battery_full, key: ValueKey('fallback')),
              onUnavailable: () => reports++)));
      await tester.pumpAndSettle();
    }

    await visual();
    expect(find.byKey(const ValueKey('fallback')), findsOneWidget);
    Directory.fromUri(root.uri.resolve('photos/')).createSync();
    File.fromUri(root.uri.resolve(path.value)).writeAsStringSync('broken png');
    await tester.pumpWidget(const SizedBox());
    await visual();
    for (var attempt = 0; attempt < 100 && reports < 2; attempt++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('fallback')), findsOneWidget);
    expect(reports, greaterThan(1));
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
      'camera adapter reports no hardware and cancellation returns null',
      (tester) async {
    Uri? captured;
    bool finished = false;
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => TextButton(
                onPressed: () async {
                  captured = await DialogCameraService(context,
                      loadCameras: () async => []).capturePhoto();
                  finished = true;
                },
                child: const Text('Camera')))));
    await tester.tap(find.text('Camera'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No camera was found'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(captured, isNull);
    expect(finished, isTrue);
  });
}

class _Picker implements FileSelectionService {
  _Picker(this.source);
  Uri? source;
  int calls = 0;
  @override
  Future<Uri?> chooseOpenFile(
      {required List<FileTypeFilter> acceptedTypes}) async {
    calls++;
    return source;
  }

  @override
  Future<Uri?> chooseSaveLocation({required String suggestedFileName}) async =>
      null;
}

class _Camera implements CameraService {
  @override
  Future<Uri?> capturePhoto() async {
    calls++;
    return null;
  }

  int calls = 0;
}

class _Logs implements AppLogService {
  @override
  Future<void> close() async {}
  @override
  Future<void> initialize() async {}
  @override
  Logger logger(String scope) => Logger(scope);
}

class _Storage implements PhotoStorage {
  _Storage(this.root);
  final Uri root;
  @override
  Future<StoredPhoto> import(Uri source, PermanentId id) async {
    final path = ManagedRelativePath.parse('photos/${id.value}.png');
    Directory.fromUri(root.resolve('photos/')).createSync(recursive: true);
    File.fromUri(source).copySync(File.fromUri(root.resolve(path.value)).path);
    return StoredPhoto(
        path: path,
        filename: 'photo.png',
        mimeType: 'image/png',
        byteSize: 1,
        width: 48,
        height: 48,
        checksum: 'test');
  }

  @override
  Future<bool> exists(ManagedRelativePath path) async =>
      File.fromUri(root.resolve(path.value)).existsSync();
  @override
  Future<void> delete(ManagedRelativePath path) async {
    final file = File.fromUri(root.resolve(path.value));
    if (file.existsSync()) file.deleteSync();
  }
}
