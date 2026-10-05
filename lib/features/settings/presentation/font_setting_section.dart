import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/active_profile_provider.dart';

class FontSettingSection extends ConsumerWidget {
  const FontSettingSection({super.key});

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
                  'App Font Style',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AppFontFamily>(
                  initialValue: profile.fontFamily,
                  decoration: const InputDecoration(
                    labelText: 'Select Font',
                    border: OutlineInputBorder(),
                  ),
                  items: AppFontFamily.values.map((font) {
                    String label = 'System Default';
                    if (font == AppFontFamily.roboto) label = 'Roboto';
                    if (font == AppFontFamily.inter) label = 'Inter';
                    if (font == AppFontFamily.openSans) label = 'Open Sans';

                    return DropdownMenuItem(
                      value: font,
                      child: Text(label),
                    );
                  }).toList(),
                  onChanged: (AppFontFamily? newValue) async {
                    if (newValue != null && newValue != profile.fontFamily) {
                      final isar = IsarHelper.instance;
                      await isar.writeTxn(() async {
                        profile.fontFamily = newValue;
                        await isar.userProfiles.put(profile);
                      });
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
