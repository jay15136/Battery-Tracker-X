import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/identity/permanent_id.dart';
import 'app_destination.dart';

sealed class AppRouteIntent {
  const AppRouteIntent({required this.destination});

  final AppDestination destination;
}

final class EntityRouteIntent extends AppRouteIntent {
  const EntityRouteIntent({
    required super.destination,
    required this.entityId,
  });

  final PermanentId entityId;
}

final class AppNavigationState {
  const AppNavigationState({
    required this.destination,
    this.routeIntent,
  });

  final AppDestination destination;
  final AppRouteIntent? routeIntent;
}

final navigationProvider =
    NotifierProvider<NavigationController, AppNavigationState>(
  NavigationController.new,
);

final class NavigationController extends Notifier<AppNavigationState> {
  @override
  AppNavigationState build() => const AppNavigationState(
        destination: AppDestination.dashboard,
      );

  void selectDestination(AppDestination destination) {
    state = AppNavigationState(destination: destination);
  }

  void openEntity({
    required AppDestination destination,
    required PermanentId entityId,
  }) {
    state = AppNavigationState(
      destination: destination,
      routeIntent: EntityRouteIntent(
        destination: destination,
        entityId: entityId,
      ),
    );
  }
}
