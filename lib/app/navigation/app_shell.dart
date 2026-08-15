import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import 'app_destination.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    const destinations = AppDestination.values;
    final selected = destinations[_selectedIndex];

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            extended: MediaQuery.sizeOf(context).width >= 1050,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Icon(Icons.battery_charging_full, size: 32),
            ),
            destinations: [
              for (final destination in destinations)
                NavigationRailDestination(
                  icon: Icon(destination.icon),
                  label: Text(destination.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _FoundationView(destination: selected),
          ),
        ],
      ),
    );
  }
}

class _FoundationView extends StatelessWidget {
  const _FoundationView({required this.destination});

  final AppDestination destination;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              destination.label,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              AppConstants.foundationMessage,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
