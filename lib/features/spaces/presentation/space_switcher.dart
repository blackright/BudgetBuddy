import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/shared_space.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../settings/presentation/profile_switcher_section.dart';
import '../providers/spaces_providers.dart';
import '../repositories/spaces_repository.dart';
import 'create_space_sheet.dart';

/// Sentinel popup values: reserved, never a real space id (ids start at 1).
const _kBackToProfile = -1;
const _kNewSpace = -2;

/// Shows the "New space" bottom sheet and, on submit, creates the space for the
/// active profile and switches straight into it (US2, T057).
///
/// Returns the created [SharedSpace], or `null` when the sheet was dismissed or
/// no profile could be resolved. Shared by the context switcher and first-run
/// onboarding, so "create your first space" behaves exactly like "New space".
Future<SharedSpace?> showCreateSpaceFlow(
  BuildContext context,
  WidgetRef ref,
) async {
  final draft = await showModalBottomSheet<SpaceDraft>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const CreateSpaceSheet(),
  );
  if (draft == null) return null;
  final profileId = ref.read(activeProfileProvider).value?.id;
  if (profileId == null) return null;
  final space = await ref.read(spacesRepositoryProvider).createSpace(
        createdByProfileId: profileId,
        name: draft.name,
        avatar: draft.avatar,
        currency: draft.currency,
        defaultIncome: draft.defaultIncome,
        bringIn: draft.bringIn,
      );
  ref.read(activeSpaceIdProvider.notifier).state = space.id;
  ref
      .read(profileSwitcherControllerProvider)
      .touchLastActiveAt(profileId)
      .ignore();
  return space;
}

/// US2/US6: the single, reusable context-switch control.
///
/// Wraps [child] in a popup that lists the active context (a shared space, or
/// the personal profile) and every space the profile belongs to, plus "My
/// profile" and "New space". Selecting a space writes `activeSpaceIdProvider`
/// (the router marker, T037) and touches `lastActiveAt`; selecting "My profile"
/// clears it. Shared by the AppShell [SpaceSwitcher] and the dashboard
/// [ContextBanner] so both switch through one code path (US6).
class ContextSwitcherMenu extends ConsumerWidget {
  const ContextSwitcherMenu({super.key, required this.child});

  /// The tappable affordance that opens the menu.
  final Widget child;

  Future<void> _createSpace(BuildContext context, WidgetRef ref) =>
      showCreateSpaceFlow(context, ref);

  void _switchSpace(WidgetRef ref, int spaceId, int profileId) {
    ref.read(activeSpaceIdProvider.notifier).state = spaceId;
    ref
        .read(profileSwitcherControllerProvider)
        .touchLastActiveAt(profileId)
        .ignore();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSpace = ref.watch(activeSpaceProvider).value;
    final profile = ref.watch(activeProfileProvider).valueOrNull;
    final mySpaces = ref.watch(mySpacesProvider).value ?? const <SharedSpace>[];

    return PopupMenuButton<int>(
      tooltip: 'Switch context',
      onSelected: (value) {
        if (value == _kNewSpace) {
          _createSpace(context, ref);
        } else if (value == _kBackToProfile) {
          ref.read(activeSpaceIdProvider.notifier).state = null;
          if (profile != null) {
            ref
                .read(profileSwitcherControllerProvider)
                .touchLastActiveAt(profile.id)
                .ignore();
          }
        } else if (profile != null) {
          _switchSpace(ref, value, profile.id);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<int>(
          key: const Key('personalOption'),
          value: _kBackToProfile,
          child: Row(
            children: [
              const Icon(Icons.person_outline),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  profile != null
                      ? 'My profile\n${profile.name}'
                      : 'My profile',
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
        if (mySpaces.isNotEmpty) const PopupMenuDivider(),
        for (final space in mySpaces)
          PopupMenuItem<int>(
            key: Key('spaceOption_${space.id}'),
            value: space.id,
            child: Row(
              children: [
                Text(space.avatar, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    space.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (space.id == activeSpace?.id)
                  Icon(
                    Icons.check,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem<int>(
          key: Key('newSpaceOption'),
          value: _kNewSpace,
          child: Row(
            children: [
              Icon(Icons.add_circle_outline),
              SizedBox(width: 12),
              Text('New space'),
            ],
          ),
        ),
      ],
      child: child,
    );
  }
}

/// US2: the top-of-app context switcher — "which room am I in".
///
/// Shows the active context (a shared space, or the personal profile) and opens
/// [ContextSwitcherMenu]'s dropdown. Mounted once in the [AppShell], so every
/// tab sees the same single switch point (context-router §3).
class SpaceSwitcher extends ConsumerWidget {
  const SpaceSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSpace = ref.watch(activeSpaceProvider).value;
    final profile = ref.watch(activeProfileProvider).valueOrNull;

    final label = activeSpace != null
        ? '${activeSpace.avatar} ${activeSpace.name}'
        : profile != null
            ? '👤 ${profile.name}'
            : 'No profile';

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: ContextSwitcherMenu(
                key: const Key('spaceSwitcher'),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    if (activeSpace != null && activeSpace.avatar.isNotEmpty)
                      const SizedBox(width: 8),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
