import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../features/spaces/presentation/space_switcher.dart';

/// US6 (T052): a reusable banner that names the active context — the personal
/// profile or the shared space money is currently landing in — and offers a
/// "switch" affordance.
///
/// Tapping the banner opens the very same menu the top-of-app [SpaceSwitcher]
/// uses ([ContextSwitcherMenu]), so there is one switch code path. In a shared
/// context it also shows the gentle hint "You're adding to «space» — tap to
/// switch." (T053), so a shared save is never a surprise. Themed from the
/// active color scheme and overflow-safe at small widths.
class ContextBanner extends ConsumerWidget {
  const ContextBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final space = ref.watch(activeSpaceProvider).valueOrNull;
    final profile = ref.watch(activeProfileProvider).valueOrNull;

    if (space == null && profile == null) return const SizedBox.shrink();

    final isShared = space != null;
    final emoji =
        isShared ? (space.avatar.isEmpty ? '🏠' : space.avatar) : '👤';
    final name = isShared ? space.name : profile!.name;

    return ContextSwitcherMenu(
      key: const Key('contextBanner'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: isShared
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isShared ? 'Shared · $name' : 'Personal · $name',
                    key: const Key('contextBannerName'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (isShared)
                    Text(
                      'You\'re adding to "$name" — tap to switch.',
                      key: const Key('contextBannerHint'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
}
