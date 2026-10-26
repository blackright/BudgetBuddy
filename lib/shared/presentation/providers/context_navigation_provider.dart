import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_helper.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/services/context_navigation.dart';
import '../../../features/security/providers/lock_providers.dart';

final contextNavigationRepositoryProvider =
    Provider((ref) => ContextNavigationRepository(IsarHelper.instance));
final contextDestinationsProvider =
    FutureProvider.autoDispose<List<ContextDestination>>((ref) {
  final actor = ref.watch(actingProfileIdProvider);
  if (actor == null) return [];
  return ref.watch(contextNavigationRepositoryProvider).choices(actor);
});
typedef SelectNavigationContext = Future<ContextDestination> Function(
    int? spaceId);
final selectNavigationContextProvider =
    Provider<SelectNavigationContext>((ref) => (spaceId) async {
          final actor = ref.read(actingProfileIdProvider);
          final previousSpace = ref.read(activeSpaceIdProvider);
          if (actor == null) {
            throw StateError('Select a personal profile first.');
          }
          if (ref.read(lockResolutionPendingProvider) ||
              ref.read(lockControllerProvider).isLocked) {
            throw StateError('Unlock the current context first.');
          }
          final selected = await ref
              .read(contextNavigationRepositoryProvider)
              .require(actor, spaceId);
          if (ref.read(actingProfileIdProvider) != actor ||
              ref.read(activeSpaceIdProvider) != previousSpace ||
              ref.read(lockResolutionPendingProvider) ||
              ref.read(lockControllerProvider).isLocked) {
            throw StateError('Your context changed. Reopen Spaces.');
          }
          ref.read(activeSpaceIdProvider.notifier).state = spaceId;
          return selected;
        });

// Session-local only; no new schema or automatic renaming on upgrade.
final dismissedProfileNamePromptsProvider =
    StateProvider<Set<int>>((ref) => {});
