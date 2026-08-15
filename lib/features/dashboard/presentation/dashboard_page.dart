import 'package:flutter/material.dart';

import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_page_scaffold.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPageScaffold(
      title: 'Dashboard',
      description: 'A clear starting point for local battery inventory.',
      icon: Icons.dashboard_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WelcomePanel(),
          SizedBox(height: 20),
          AppEmptyState(
            icon: Icons.battery_charging_full_outlined,
            title: 'Your inventory is ready.',
            message: 'Add Battery Types and Batteries to begin tracking '
                'equipment. Dashboard counts will always come from the local '
                'database.',
          ),
        ],
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.surfaceContainerHighest,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Battery Tracker',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Organize rechargeable batteries, keep Sets together, record '
            'charges, and track where equipment is being used—all offline.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          const Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _FoundationPill(Icons.cloud_off_outlined, 'Offline first'),
              _FoundationPill(Icons.fingerprint, 'Stable identity'),
              _FoundationPill(Icons.image_outlined, 'Icon-first records'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FoundationPill extends StatelessWidget {
  const _FoundationPill(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17),
          const SizedBox(width: 7),
          Text(label),
        ],
      ),
    );
  }
}
