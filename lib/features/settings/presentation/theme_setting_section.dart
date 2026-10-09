import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_profile.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../providers/settings_provider.dart';

/// Phase 9-E (T061): the Settings card that chooses the app theme, mirroring
/// the font section next to it.
///
/// The choice lives on `UserProfile` (default `AppThemeMode.system`) and is
/// persisted through the single [appThemeControllerProvider] write path, so a
/// widget test can override the controller with a real Isar instance and prove
/// the write lands (T058).
class ThemeSettingSection extends ConsumerWidget {
  const ThemeSettingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfileAsync = ref.watch(activeProfileProvider);

    return activeProfileAsync.when(
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Theme',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AppThemeMode>(
                  initialValue: profile.themeMode,
                  decoration: const InputDecoration(
                    labelText: 'Select Theme',
                    border: OutlineInputBorder(),
                  ),
                  items: AppThemeMode.values.map((mode) {
                    String label;
                    switch (mode) {
                      case AppThemeMode.system:
                        label = 'Follow system';
                      case AppThemeMode.light:
                        label = 'Light';
                      case AppThemeMode.dark:
                        label = 'Dark';
                    }
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(label),
                    );
                  }).toList(),
                  onChanged: (AppThemeMode? newValue) async {
                    if (newValue != null && newValue != profile.themeMode) {
                      await ref
                          .read(appThemeControllerProvider)
                          .setThemeMode(newValue);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
