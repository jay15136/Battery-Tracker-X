import '../features/dashboard/domain/dashboard.dart';
import '../features/history/domain/history.dart';
import '../features/backup/domain/backup.dart';
import '../features/import_export/domain/import_export.dart';
import '../features/qr_labels/domain/labels.dart';
import '../features/qr_labels/application/canvas_label_renderer.dart';
import '../services/platform_service_contracts.dart';
import '../services/zxing_qr_code_service.dart';
import '../services/native_print_service.dart';
import '../features/bulk_operations/domain/bulk_edit.dart';
import '../features/bulk_operations/domain/bulk_creation.dart';
import '../features/charging/domain/charge.dart';
import '../features/assignments/domain/assignment.dart';
import '../features/devices/domain/device.dart';
import '../features/batteries/domain/battery.dart';
import '../features/battery_sets/domain/battery_set.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import '../features/photos/application/photo_service.dart';
import '../services/camera_service.dart';
import '../services/dialog_camera_service.dart';

import '../core/configuration/app_configuration.dart';
import '../core/database/database_service.dart';
import '../core/logging/app_log_service.dart';
import '../features/icons/application/icon_library_service.dart';
import '../features/icons/domain/icon_repository.dart';
import '../features/battery_types/domain/battery_type_repository.dart';
import '../features/settings/domain/app_settings_repository.dart';
import '../services/file_selection_service.dart';

final appConfigurationProvider = Provider<AppConfiguration>(
  (ref) => AppConfiguration.production,
);

final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => throw StateError('DatabaseService was not configured at startup.'),
);

final appLogServiceProvider = Provider<AppLogService>(
  (ref) => throw StateError('AppLogService was not configured at startup.'),
);

final appSettingsRepositoryProvider = Provider<AppSettingsRepository>(
  (ref) =>
      throw StateError('AppSettingsRepository was not configured at startup.'),
);

final applicationSupportRootProvider = Provider<Uri>(
  (ref) => throw StateError(
    'Application support storage was not configured at startup.',
  ),
);

final iconRepositoryProvider = Provider<IconRepository>(
  (ref) => throw StateError('IconRepository was not configured at startup.'),
);

final batteryTypeRepositoryProvider = Provider<BatteryTypeRepository>(
  (ref) =>
      throw StateError('BatteryTypeRepository was not configured at startup.'),
);

final iconLibraryServiceProvider = Provider<IconLibraryService>(
  (ref) => throw StateError(
    'IconLibraryService was not configured at startup.',
  ),
);

final fileSelectionServiceProvider = Provider<FileSelectionService>(
  (ref) => throw StateError(
    'FileSelectionService was not configured at startup.',
  ),
);

final batteryRepositoryProvider = Provider<BatteryRepository>((ref) =>
    throw StateError('BatteryRepository was not configured at startup.'));

final photoServiceProvider = Provider<PhotoService>(
    (ref) => throw StateError('PhotoService was not configured at startup.'));
final cameraServiceFactoryProvider =
    Provider<CameraService Function(BuildContext)>(
        (ref) => DialogCameraService.new);

final batterySetRepositoryProvider = Provider<BatterySetRepository>((ref) =>
    throw StateError('BatterySetRepository was not configured at startup.'));

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) =>
    throw StateError('DeviceRepository was not configured at startup.'));

final assignmentRepositoryProvider = Provider<AssignmentRepository>((ref) =>
    throw StateError('AssignmentRepository was not configured at startup.'));

final chargeRepositoryProvider = Provider<ChargeRepository>((ref) =>
    throw StateError('ChargeRepository was not configured at startup.'));

final bulkCreationRepositoryProvider = Provider<BulkCreationRepository>(
    (ref) => throw StateError('Bulk creation was not configured.'));

final bulkEditRepositoryProvider = Provider<BulkEditRepository>(
    (ref) => throw StateError('Bulk Edit was not configured.'));

final labelRepositoryProvider = Provider<LabelRepository>(
    (ref) => throw StateError('Labels were not configured.'));
final qrCodeServiceProvider =
    Provider<QrCodeService>((ref) => const ZxingQrCodeService());
final printServiceProvider =
    Provider<PrintService>((ref) => const NativePrintService());
final labelRendererProvider = Provider<LabelRenderer>((ref) =>
    CanvasLabelRenderer(
        qr: ref.watch(qrCodeServiceProvider),
        icons: ref.watch(iconRepositoryProvider),
        root: ref.watch(applicationSupportRootProvider)));

final dashboardRepositoryProvider = Provider<DashboardRepository>(
    (ref) => throw StateError('Dashboard was not configured.'));

final historyRepositoryProvider = Provider<HistoryRepository>(
    (ref) => throw StateError('History was not configured.'));

final backupRepositoryProvider = Provider<BackupRepository>(
    (ref) => throw StateError('Backup was not configured.'));

final importExportRepositoryProvider = Provider<ImportExportRepository>(
    (ref) => throw StateError('Import/Export was not configured.'));
