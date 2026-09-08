import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_providers.dart';
import '../domain/device.dart';

final devicesProvider = FutureProvider<List<DeviceRecord>>((ref) async {
  try {
    return await ref.watch(deviceRepositoryProvider).list();
  } on Object catch (error, stack) {
    ref
        .read(appLogServiceProvider)
        .logger('devices.ui')
        .severe('Loading Devices failed.', error, stack);
    rethrow;
  }
});
