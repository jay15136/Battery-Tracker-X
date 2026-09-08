import 'package:battery_tracker/features/dashboard/data/drift_dashboard_repository.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:battery_tracker/app/app_providers.dart';
import 'package:battery_tracker/app/navigation/app_shell.dart';
import 'package:battery_tracker/core/database/app_database.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:battery_tracker/core/logging/app_log_service.dart';
import 'package:battery_tracker/features/batteries/data/drift_battery_repository.dart';
import 'package:battery_tracker/features/batteries/domain/battery.dart';
import 'package:battery_tracker/features/bulk_operations/data/drift_bulk_creation_repository.dart';
import 'package:battery_tracker/features/bulk_operations/presentation/bulk_creation_dialog.dart';
import 'package:battery_tracker/features/battery_types/data/drift_battery_type_repository.dart';
import 'package:battery_tracker/features/battery_sets/data/drift_battery_set_repository.dart';
import 'package:battery_tracker/features/battery_sets/domain/battery_set.dart';
import 'package:battery_tracker/features/devices/data/drift_device_repository.dart';
import 'package:battery_tracker/features/devices/domain/device.dart';
import 'package:battery_tracker/features/icons/data/drift_icon_repository.dart';
import 'package:battery_tracker/features/icons/data/built_in_icon_registry.dart';
import 'package:battery_tracker/features/icons/domain/icon_registry.dart';
import 'package:battery_tracker/features/qr_labels/data/drift_label_repository.dart';
import 'package:battery_tracker/features/qr_labels/domain/labels.dart';
import 'package:battery_tracker/features/qr_labels/application/canvas_label_renderer.dart';
import 'package:battery_tracker/features/qr_labels/presentation/qr_labels_page.dart';
import 'package:battery_tracker/services/platform_service_contracts.dart';
import 'package:battery_tracker/services/file_selection_service.dart';
import 'package:battery_tracker/services/zxing_qr_code_service.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

void main() {
  late AppDatabase db;
  late DriftLabelRepository labels;
  late DriftBatteryRepository batteries;
  late DriftBatterySetRepository sets;
  late DriftDeviceRepository devices;
  late DriftIconRepository icons;
  late _Renderer renderer;
  late _Printer printer;
  late _Files files;
  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    icons = DriftIconRepository(
        database: db,
        idGenerator: const UuidV4PermanentIdGenerator(),
        builtInRegistry:
            IconRegistry(builtIns: BuiltInIconRegistry.definitions));
    batteries = DriftBatteryRepository(database: db, iconRepository: icons);
    sets =
        DriftBatterySetRepository(db: db, batteries: batteries, icons: icons);
    devices = DriftDeviceRepository(db: db, batteries: batteries, icons: icons);
    labels = DriftLabelRepository(
        db: db, batteries: batteries, sets: sets, devices: devices);
    renderer = _Renderer();
    printer = _Printer();
    files = _Files();
  });
  tearDown(() => db.close());
  Future<void> pump(WidgetTester tester,
      {List<LabelRef> refs = const [], bool dark = false, Widget? page}) async {
    tester.view.physicalSize = const Size(1300, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
        overrides: [
          labelRepositoryProvider.overrideWithValue(labels),
          dashboardRepositoryProvider
              .overrideWithValue(DriftDashboardRepository(db)),
          bulkCreationRepositoryProvider.overrideWithValue(
              DriftBulkCreationRepository(
                  db: db, batteries: batteries, sets: sets)),
          labelRendererProvider.overrideWithValue(renderer),
          printServiceProvider.overrideWithValue(printer),
          fileSelectionServiceProvider.overrideWithValue(files),
          batteryRepositoryProvider.overrideWithValue(batteries),
          batterySetRepositoryProvider.overrideWithValue(sets),
          deviceRepositoryProvider.overrideWithValue(devices),
          iconRepositoryProvider.overrideWithValue(icons),
          batteryTypeRepositoryProvider.overrideWithValue(
              DriftBatteryTypeRepository(
                  database: db,
                  idGenerator: const UuidV4PermanentIdGenerator(),
                  iconRepository: icons)),
          applicationSupportRootProvider
              .overrideWithValue(Directory.systemTemp.uri),
          appLogServiceProvider.overrideWithValue(_Log()),
        ],
        child: MaterialApp(
            theme: ThemeData(
                brightness: dark ? Brightness.dark : Brightness.light),
            home: Scaffold(body: page ?? QrLabelsPage(initialRefs: refs)))));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();
  }

  Future<void> reveal(WidgetTester tester, String text) async {
    for (var i = 0; i < 20 && find.text(text).evaluate().isEmpty; i++) {
      final position = tester
          .state<ScrollableState>(find.byType(QrLabelsPage).evaluate().isEmpty
              ? find.byType(Scrollable).first
              : find
                  .descendant(
                      of: find.byType(QrLabelsPage),
                      matching: find.byType(Scrollable))
                  .first)
          .position;
      position
          .jumpTo((position.pixels + 400).clamp(0, position.maxScrollExtent));
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(find.text(text).last);
  }

  Future<void> tap(WidgetTester tester, String text) async {
    await reveal(tester, text);
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  testWidgets('navigation opens the QR workspace in a narrow desktop window',
      (tester) async {
    await pump(tester, page: const AppShell());
    tester.view.physicalSize = const Size(850, 1000);
    await tester.pumpAndSettle();
    final entry = find.byKey(const ValueKey('destination-qrLabels'));
    await tester.ensureVisible(entry);
    await tester.tap(entry);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Enter or paste QR value'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'empty inventory and invalid lookup show actionable feedback in dark mode',
      (tester) async {
    await pump(tester, dark: true);
    expect(find.text('No matching inventory records.'), findsOneWidget);
    await tester.enterText(
        find.widgetWithText(TextField, 'Enter or paste QR value'), 'AA-001');
    await tap(tester, 'Open QR record');
    expect(find.textContaining('valid permanent UUID'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'print cancellation writes no history; success records selected UUIDs and dimensions',
      (tester) async {
    final a = await batteries.save(const BatteryDraft(userBatteryId: 'A'));
    final b = await batteries.save(const BatteryDraft(userBatteryId: 'B'));
    await pump(tester, refs: [
      LabelRef(LabelKind.battery, a.id),
      LabelRef(LabelKind.battery, b.id)
    ]);
    await tap(tester, 'Print labels');
    expect(
        (await db.select(db.activityLog).get())
            .where((r) => r.eventType == 'qr_labels_printed'),
        isEmpty);
    expect(
        renderer.document!.targets.map((t) => t.ref.id).toSet(), {a.id, b.id});
    printer.result = true;
    await tap(tester, 'Print labels');
    expect(printer.width, 144);
    expect(printer.height, 72);
    expect(
        (await db.select(db.activityLog).get())
            .where((r) => r.eventType == 'qr_labels_printed')
            .length,
        2);
    expect(tester.takeException(), isNull);
  });
  testWidgets('export canceled by file picker does not record output',
      (tester) async {
    final a = await batteries.save(const BatteryDraft(userBatteryId: 'A'));
    await pump(tester, refs: [LabelRef(LabelKind.battery, a.id)]);
    await tap(tester, 'Export labels to PDF');
    expect(files.saveCalls, 1);
    expect(
        (await db.select(db.activityLog).get())
            .where((r) => r.eventType == 'qr_labels_exported'),
        isEmpty);
  });
  testWidgets('renamed Battery QR opens its actual details', (tester) async {
    final b = await batteries.save(const BatteryDraft(userBatteryId: 'Old'));
    final uri = LabelRef(LabelKind.battery, b.id).uri;
    await batteries.save(const BatteryDraft(userBatteryId: 'New'), id: b.id);
    await pump(tester);
    await tester.enterText(
        find.widgetWithText(TextField, 'Enter or paste QR value'),
        uri.toString());
    await tap(tester, 'Open QR record');
    expect(find.text('Edit Battery'), findsOneWidget);
    expect(find.textContaining(b.id.value), findsWidgets);
    await tap(tester, 'Close');
    expect(find.text('QR match: New'), findsOneWidget);
    await tap(tester, 'Close record');
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'successful PDF export writes the chosen file before recording history',
      (tester) async {
    final root = await tester
        .runAsync(() => Directory.systemTemp.createTemp('label-export-'));
    final output = File('${root!.path}/labels.pdf');
    files.savePath = output.uri;
    try {
      final b = await batteries.save(const BatteryDraft(userBatteryId: 'A'));
      await pump(tester, refs: [LabelRef(LabelKind.battery, b.id)]);
      await reveal(tester, 'Export labels to PDF');
      await tester.runAsync(() async {
        final callback = tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Export labels to PDF'))
            .onPressed;
        await (callback as dynamic)();
      });
      await tester.pumpAndSettle();
      expect(await tester.runAsync(() => output.readAsString()), '%PDF-test');
      expect(
          (await db.select(db.activityLog).get())
              .where((r) => r.eventType == 'qr_labels_exported')
              .length,
          1);
    } finally {
      await tester.runAsync(() => root.delete(recursive: true));
    }
  });
  testWidgets(
      'bulk creation opens labels with every new permanent UUID selected',
      (tester) async {
    await pump(tester, page: const BulkCreationDialog(types: []));
    await tap(tester, 'Generate preview');
    await tap(tester, 'Confirm preview and save');
    await tap(tester, 'Create QR Labels');
    expect(find.text('4 labels selected'), findsOneWidget);
    await tap(tester, 'Print labels');
    expect(renderer.document!.targets.map((t) => t.ref.id).toSet(),
        (await batteries.list()).map((b) => b.id).toSet());
    expect(tester.takeException(), isNull);
  });
  testWidgets('template controls save and reuse the chosen geometry',
      (tester) async {
    final b = await batteries.save(const BatteryDraft(userBatteryId: 'A'));
    await pump(tester, refs: [LabelRef(LabelKind.battery, b.id)]);
    await tester.ensureVisible(find.widgetWithText(TextField, 'Template name'));
    await tester.enterText(
        find.widgetWithText(TextField, 'Template name'), 'My label');
    await tap(tester, 'Save new template');
    final saved = (await labels.templates()).single;
    expect(saved.name, 'My label');
    await tap(tester, 'Saved template');
    await tap(tester, 'My label');
    await tap(tester, 'Update template');
    expect((await labels.templates()).single.id, saved.id);
    expect(tester.takeException(), isNull);
  });
  testWidgets('whole Set selection and save-for-later retain member UUIDs',
      (tester) async {
    final a = await batteries.save(const BatteryDraft(userBatteryId: 'A'));
    final s = await sets.save(const SetDraft(userSetId: 'S', name: 'Kit'));
    await sets.addMember(s.id, a.id);
    await pump(tester);
    await tap(tester, 'Select Set member labels');

    await tap(tester, 'Save for later');
    await tester.enterText(
        find.widgetWithText(TextField, 'Name'), 'New batteries');
    await tap(tester, 'Save');
    expect(
        (await labels.jobs()).single.refs, [LabelRef(LabelKind.battery, a.id)]);
  });
  for (final kind in [LabelKind.set, LabelKind.device]) {
    testWidgets('pasted ${kind.host} UUID opens the correct record',
        (tester) async {
      final id = kind == LabelKind.set
          ? (await sets.save(const SetDraft(userSetId: 'S', name: 'Kit'))).id
          : (await devices.save(const DeviceDraft(name: 'Radio'))).id;
      await pump(tester);
      await tester.enterText(
          find.widgetWithText(TextField, 'Enter or paste QR value'),
          LabelRef(kind, id).uri.toString());
      await tap(tester, 'Open QR record');
      expect(
          find.text(kind == LabelKind.set ? 'QR match: S' : 'QR match: Radio'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
      await tap(tester, 'Close record');
    });
  }
}

class _Renderer implements LabelRenderer {
  LabelDocument? document;
  @override
  Future<Uint8List> renderLabel(LabelTarget t, LabelLayout l) async =>
      const ZxingQrCodeService().render(t.ref.uri);
  @override
  Future<Uint8List> renderPdf(Object value) async {
    document = value as LabelDocument;
    document!.sheet.positions(document!.targets.length, document!.layout);
    return Uint8List.fromList('%PDF-test'.codeUnits);
  }
}

class _Printer implements PrintService {
  bool result = false;
  double? width, height;
  @override
  Future<bool> printPdf(
      {required Uint8List bytes,
      required String jobName,
      double? pageWidth,
      double? pageHeight}) async {
    width = pageWidth;
    height = pageHeight;
    return result;
  }
}

class _Files implements FileSelectionService {
  int saveCalls = 0;
  Uri? savePath;
  @override
  Future<Uri?> chooseOpenFile(
          {required List<FileTypeFilter> acceptedTypes}) async =>
      null;
  @override
  Future<Uri?> chooseSaveLocation({required String suggestedFileName}) async {
    saveCalls++;
    return savePath;
  }
}

class _Log implements AppLogService {
  @override
  Future<void> initialize() async {}
  @override
  Future<void> close() async {}
  @override
  Logger logger(String scope) => Logger('test.$scope');
}
