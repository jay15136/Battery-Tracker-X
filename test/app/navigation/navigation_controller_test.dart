import 'package:battery_tracker/app/navigation/app_destination.dart';
import 'package:battery_tracker/app/navigation/navigation_controller.dart';
import 'package:battery_tracker/core/identity/permanent_id.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('selects destinations and clears stale detail route intent', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final entityId = PermanentId.parse(
      '11111111-1111-4111-8111-111111111111',
    );

    container.read(navigationProvider.notifier).openEntity(
          destination: AppDestination.batteries,
          entityId: entityId,
        );
    expect(container.read(navigationProvider).routeIntent, isNotNull);

    container
        .read(navigationProvider.notifier)
        .selectDestination(AppDestination.devices);

    final state = container.read(navigationProvider);
    expect(state.destination, AppDestination.devices);
    expect(state.routeIntent, isNull);
  });
}
