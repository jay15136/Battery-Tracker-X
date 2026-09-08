import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_providers.dart';
import '../domain/charge.dart';

final chargeHistoryProvider = FutureProvider<List<RecordedCharge>>((ref) async {
  try {
    return await ref.watch(chargeRepositoryProvider).list();
  } on Object catch (e, s) {
    ref
        .read(appLogServiceProvider)
        .logger('charging.ui')
        .severe('Loading charge history failed.', e, s);
    rethrow;
  }
});
