import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/shared_space.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../providers/spaces_providers.dart';
import '../repositories/month_move_operations.dart';
import '../repositories/space_role_guard.dart';

/// US3: the "move this month" bottom sheet (contracts/month-move-lifecycle §2).
///
/// In a personal context it lists the acting profile's shared spaces as
/// destinations; in a shared context it lists the local profiles. Choosing one
/// re-homes the whole month through [MonthMoveOperations] — move, never copy.
///
/// The sheet is UX only: the data layer re-checks the acting profile's role and
/// refuses a target that already owns the month, surfacing the reason here.
class MoveMonthSheet extends ConsumerStatefulWidget {
  const MoveMonthSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const MoveMonthSheet(),
    );
  }

  @override
  ConsumerState<MoveMonthSheet> createState() => _MoveMonthSheetState();
}

class _MoveMonthSheetState extends ConsumerState<MoveMonthSheet> {
  bool _busy = false;

  Future<void> _move(
      ContextRef from, ContextRef to, int actingProfileId) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(monthMoveOperationsProvider).moveMonth(
            from,
            to,
            from.yearMonth,
            actingProfileId: actingProfileId,
          );
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Month moved.')),
      );
    } on UnauthorizedSpaceAction catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text('Could not move: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final from = ref.watch(budgetContextProvider);
    final actingProfileId = ref.watch(activeProfileProvider).value?.id;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Move ${from.yearMonth}',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                from.isShared
                    ? 'Choose a personal profile to move this month into.'
                    : 'Choose a shared space to move this month into.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              if (actingProfileId == null)
                const Text('No active profile.')
              else if (_busy)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (from.isShared)
                _PersonalTargets(
                  yearMonth: from.yearMonth,
                  onPick: (to) => _move(from, to, actingProfileId),
                )
              else
                _SpaceTargets(
                  yearMonth: from.yearMonth,
                  onPick: (to) => _move(from, to, actingProfileId),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonalTargets extends ConsumerWidget {
  const _PersonalTargets({required this.yearMonth, required this.onPick});

  final String yearMonth;
  final void Function(ContextRef to) onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider).value ?? const <UserProfile>[];
    if (profiles.isEmpty) {
      return const Text('No personal profiles to move into.');
    }
    return Column(
      children: [
        for (final profile in profiles)
          ListTile(
            key: Key('moveTargetProfile_${profile.id}'),
            leading: CircleAvatar(
              child: Text(profile.avatar.isEmpty ? '👤' : profile.avatar),
            ),
            title: Text(profile.name),
            subtitle: const Text('Personal profile'),
            onTap: () => onPick(
              ContextRef.personal(profileId: profile.id, yearMonth: yearMonth),
            ),
          ),
      ],
    );
  }
}

class _SpaceTargets extends ConsumerWidget {
  const _SpaceTargets({required this.yearMonth, required this.onPick});

  final String yearMonth;
  final void Function(ContextRef to) onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaces = ref.watch(mySpacesProvider).value ?? const <SharedSpace>[];
    if (spaces.isEmpty) {
      return const Text('No shared spaces to move into.');
    }
    return Column(
      children: [
        for (final space in spaces)
          ListTile(
            key: Key('moveTargetSpace_${space.id}'),
            leading: CircleAvatar(child: Text(space.avatar)),
            title: Text(space.name),
            subtitle: const Text('Shared space'),
            onTap: () => onPick(
              ContextRef.shared(spaceId: space.id, yearMonth: yearMonth),
            ),
          ),
      ],
    );
  }
}
