import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_providers.dart';
import '../domain/assignment.dart';

final assignmentsProvider = FutureProvider<List<AssignmentRecord>>((ref) async {
  try {
    return await ref.watch(assignmentRepositoryProvider).list();
  } on Object catch (e, s) {
    ref
        .read(appLogServiceProvider)
        .logger('assignments.ui')
        .severe('Loading assignments failed.', e, s);
    rethrow;
  }
});
