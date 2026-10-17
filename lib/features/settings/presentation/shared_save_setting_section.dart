import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/active_profile_provider.dart';
import '../providers/settings_provider.dart';

/// US6 (T056): the Settings card that chooses whether saving into a shared
/// space asks for confirmation first.
///
/// The choice lives on `UserProfile` (default `true` — confirm by design) and is
/// persisted through the single [confirmSharedSaveControllerProvider] write
/// path, so a widget test can override the controller with a real Isar instance
/// and prove the write lands.
class SharedSaveSettingSection extends ConsumerWidget {
  const SharedSaveSettingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfileAsync = ref.watch(activeProfileProvider);

    return activeProfileAsync.when(
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();

        final enabled = ref.watch(confirmSharedSaveOnProvider);
        return Card(
          child: SwitchListTile(
            key: const Key('confirmSharedSaveToggle'),
            title: const Text('Confirm before saving to a shared space'),
            subtitle: const Text(
              'Ask before adding an expense or medical bill to the active '
              'shared space.',
            ),
            value: enabled,
            onChanged: (value) async {
              await ref
                  .read(confirmSharedSaveControllerProvider)
                  .setConfirmSharedSave(value, profileId: profile.id);
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
