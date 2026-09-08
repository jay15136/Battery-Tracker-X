import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_page_scaffold.dart';
import '../../backup/presentation/data_management_page.dart';
import '../../icons/presentation/icon_library_page.dart';
import '../application/theme_preference_controller.dart';
import '../domain/theme_preference.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(themePreferenceProvider);
    final selectedPreference = switch (preference) {
      AsyncData(:final value) => value,
      _ => ThemePreference.system,
    };

    return AppPageScaffold(
      title: 'Settings',
      description: 'Appearance and local application preferences.',
      icon: Icons.settings_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose how Battery Tracker follows your display.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  SegmentedButton<ThemePreference>(
                    segments: const [
                      ButtonSegment(
                        value: ThemePreference.system,
                        icon: Icon(Icons.brightness_auto_outlined),
                        label: Text('System'),
                      ),
                      ButtonSegment(
                        value: ThemePreference.light,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemePreference.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('Dark'),
                      ),
                    ],
                    selected: {selectedPreference},
                    onSelectionChanged: preference.isLoading
                        ? null
                        : (selection) async {
                            try {
                              await ref
                                  .read(themePreferenceProvider.notifier)
                                  .setPreference(selection.single);
                            } on Object {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Appearance setting could not be saved.',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                  ),
                  if (preference.isLoading) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(),
                  ],
                  if (preference.hasError) ...[
                    const SizedBox(height: 16),
                    Text(
                      'The saved appearance could not be loaded. System '
                      'appearance is active.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              key: const ValueKey('settings-icon-library'),
              leading: const Icon(Icons.widgets_outlined),
              title: const Text('Icon Library'),
              subtitle: const Text(
                'Browse packaged icons and safely manage custom PNG or SVG icons.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const IconLibraryPage(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              key: const ValueKey('settings-data-management'),
              leading: const Icon(Icons.storage_outlined),
              title: const Text('Data Management'),
              subtitle: const Text(
                'Back up, restore, and export or import CSV data. Database, '
                'logs, photographs, and custom icons use application-managed '
                'storage.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DataManagementPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
