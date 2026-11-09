import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_profile.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../providers/settings_provider.dart';
import 'settings_copy.dart';

/// The Appearance sheet's font choice.
///
/// The four options come from [AppFontFamily] and persist through the single
/// [appFontControllerProvider] write path. The whole radio tile is tappable, so
/// the list stays usable at 320 dp and 200% text.
class FontSettingSection extends ConsumerWidget {
  const FontSettingSection({super.key});

  static String labelFor(AppFontFamily font) {
    switch (font) {
      case AppFontFamily.system:
        return SettingsCopy.systemDefault;
      case AppFontFamily.roboto:
        return SettingsCopy.roboto;
      case AppFontFamily.inter:
        return SettingsCopy.inter;
      case AppFontFamily.openSans:
        return SettingsCopy.openSans;
    }
  }

  static Key keyFor(AppFontFamily font) => Key('font${font.name}');

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
                  SettingsCopy.font,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                RadioGroup<AppFontFamily>(
                  groupValue: profile.fontFamily,
                  onChanged: (newValue) async {
                    if (newValue != null && newValue != profile.fontFamily) {
                      await ref
                          .read(appFontControllerProvider)
                          .setFontFamily(newValue, profileId: profile.id);
                    }
                  },
                  child: Column(
                    children: [
                      for (final font in AppFontFamily.values)
                        RadioListTile<AppFontFamily>(
                          key: keyFor(font),
                          value: font,
                          contentPadding: EdgeInsets.zero,
                          title: Text(labelFor(font)),
                        ),
                    ],
                  ),
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
