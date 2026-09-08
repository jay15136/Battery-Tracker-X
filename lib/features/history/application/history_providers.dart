import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_providers.dart';
import '../domain/history.dart';

/// The active History filter plus the current page size. Kept as one
/// immutable value so changing either restarts the underlying live query.
typedef HistoryRequest = ({HistoryFilter filter, int limit});

final historyRequestProvider =
    NotifierProvider.autoDispose<HistoryRequestController, HistoryRequest>(
        HistoryRequestController.new);

class HistoryRequestController extends Notifier<HistoryRequest> {
  @override
  HistoryRequest build() => (filter: const HistoryFilter(), limit: 25);

  void update(HistoryRequest request) => state = request;
}

/// Live, filtered, paginated History results. Recomputes automatically when
/// activity is recorded elsewhere in the app or when [historyRequestProvider]
/// changes.
final historyResultProvider = StreamProvider.autoDispose<HistoryResult>((ref) {
  final request = ref.watch(historyRequestProvider);
  return ref
      .watch(historyRepositoryProvider)
      .watch(request.filter, limit: request.limit, offset: 0);
});

/// Selectable Batteries, Battery Sets, or Devices for the entity filter.
final historyEntityOptionsProvider = FutureProvider.autoDispose
    .family<List<HistoryEntityOption>, HistoryEntityType>((ref, type) =>
        ref.watch(historyRepositoryProvider).entityOptions(type));
