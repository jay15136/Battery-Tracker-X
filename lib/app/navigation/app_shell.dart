import '../../core/identity/permanent_id.dart';
import '../../features/qr_labels/presentation/qr_labels_page.dart';
import '../../features/charging/presentation/charge_tracking_page.dart';
import '../../features/assignments/presentation/assignments_page.dart';
import '../../features/devices/presentation/devices_page.dart';
import '../../features/battery_sets/presentation/battery_sets_page.dart';
import '../../features/batteries/presentation/batteries_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/history/presentation/history_page.dart';
import '../../features/battery_types/presentation/battery_types_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import 'app_destination.dart';
import 'navigation_controller.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigation = ref.watch(navigationProvider);
    const destinations = AppDestination.values;
    final selectedIndex = destinations.indexOf(navigation.destination);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final extended = constraints.maxWidth >= 1050;

          return Row(
            children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                extended: extended,
                scrollable: true,
                minExtendedWidth: 232,
                groupAlignment: -1,
                onDestinationSelected: (index) {
                  ref
                      .read(navigationProvider.notifier)
                      .selectDestination(destinations[index]);
                },
                leading: _BrandHeader(extended: extended),
                trailing: Padding(
                  padding: const EdgeInsets.only(top: 18, bottom: 12),
                  child: Text(
                    extended
                        ? 'Version ${AppConstants.version}'
                        : 'v${AppConstants.version}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                destinations: [
                  for (final destination in destinations)
                    NavigationRailDestination(
                      icon: Icon(
                        destination.icon,
                        key: ValueKey('destination-${destination.name}'),
                      ),
                      selectedIcon: Icon(
                        destination.icon,
                        key: ValueKey(
                          'destination-${destination.name}-selected',
                        ),
                      ),
                      label: Text(destination.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _DestinationContent(
                    key: ValueKey(
                        (navigation.destination, navigation.routeIntent)),
                    destination: navigation.destination,
                    entityId: navigation.routeIntent is EntityRouteIntent
                        ? (navigation.routeIntent as EntityRouteIntent).entityId
                        : null,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mark = Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(
        Icons.battery_charging_full,
        color: colorScheme.onPrimary,
      ),
    );

    return SizedBox(
      width: extended ? 208 : 56,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(7, 16, 7, 22),
        child: extended
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  mark,
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      AppConstants.appName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              )
            : Center(child: mark),
      ),
    );
  }
}

class _DestinationContent extends StatelessWidget {
  const _DestinationContent(
      {required this.destination, this.entityId, super.key});
  final PermanentId? entityId;

  final AppDestination destination;

  @override
  Widget build(BuildContext context) {
    return switch (destination) {
      AppDestination.batteries => BatteriesPage(initialId: entityId),
      AppDestination.qrLabels => const QrLabelsPage(),
      AppDestination.charging => const ChargeTrackingPage(),
      AppDestination.assignments => const AssignmentsPage(),
      AppDestination.devices => DevicesPage(initialId: entityId),
      AppDestination.batterySets => BatterySetsPage(initialId: entityId),
      AppDestination.dashboard => const DashboardPage(),
      AppDestination.batteryTypes => const BatteryTypesPage(),
      AppDestination.settings => const SettingsPage(),
      AppDestination.history => const HistoryPage(),
    };
  }
}
