import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_profile.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../providers/settings_provider.dart';
import 'settings_copy.dart';

/// The Appearance sheet's theme choice.
///
/// The choice lives on `UserProfile` (default `AppThemeMode.system`) and is
/// persisted through the single [appThemeControllerProvider] write path, so a
/// widget test can override the controller with a real Isar instance and prove
/// the write lands (T058). Selecting a chip writes immediately; there is no
/// Save button.
class ThemeSettingSection extends ConsumerWidget {
  const ThemeSettingSection({super.key});

  static String labelFor(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return SettingsCopy.system;
      case AppThemeMode.light:
        return SettingsCopy.light;
      case AppThemeMode.dark:
        return SettingsCopy.dark;
    }
  }

  static Key keyFor(AppThemeMode mode) => Key('theme${mode.name}');

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
                  SettingsCopy.theme,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final mode in AppThemeMode.values)
                      ChoiceChip(
                        key: keyFor(mode),
                        label: Text(labelFor(mode)),
                        selected: profile.themeMode == mode,
                        onSelected: (selected) async {
                          if (selected && mode != profile.themeMode) {
                            await ref
                                .read(appThemeControllerProvider)
                                .setThemeMode(mode, profileId: profile.id);
                          }
                        },
                      ),
                  ],
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
