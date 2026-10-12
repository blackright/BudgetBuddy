import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../database/isar_helper.dart';
import '../models/user_profile.dart';

/// The selected personal profile's id. `null` means "not chosen yet" — the
/// active profile falls back to the lowest-id row (today's single profile).
///
/// Serves as the persisted marker for the router (context-router §1): a context
/// switch writes this one id (plus `UserProfile.lastActiveAt`) and every
/// dependent stream re-derives in the same frame.
final activeProfileIdProvider = StateProvider<int?>((ref) => null);

/// The active personal profile: the row selected by [activeProfileIdProvider],
/// falling back to the lowest-id profile when nothing is chosen or the chosen
/// one has been deleted (R2, context-router §5).
final activeProfileProvider = StreamProvider<UserProfile?>((ref) {
  final selectedId = ref.watch(activeProfileIdProvider);
  final isar = IsarHelper.instance;
  return isar.userProfiles.where().watch(fireImmediately: true).map((profiles) {
    if (profiles.isEmpty) return null;

    if (selectedId != null) {
      for (final profile in profiles) {
        if (profile.id == selectedId) return profile;
      }
    }

    final sorted = [...profiles]..sort((a, b) => a.id.compareTo(b.id));
    return sorted.first;
  });
});

/// The id of the profile acting for the user right now: the explicitly chosen
/// profile, or the lowest-id fallback (context-router §1–2).
///
/// Shared-space role checks key on this — there is no separate "logged in"
/// concept, so the active personal profile is who "I" am inside a space.
final actingProfileIdProvider = Provider<int?>((ref) {
  final selected = ref.watch(activeProfileIdProvider);
  if (selected != null) return selected;
  return ref.watch(activeProfileProvider).value?.id;
});

/// Every user profile, most recently used first (US1, FR-001, context-router §3).
///
/// Backs the settings profile switcher and any "choose a profile" surface.
final profilesProvider = StreamProvider<List<UserProfile>>((ref) {
  final isar = IsarHelper.instance;
  return isar.userProfiles.where().watch(fireImmediately: true).map(
        (profiles) => [...profiles]..sort((a, b) {
            final aUsed = a.lastActiveAt ?? a.updatedAt;
            final bUsed = b.lastActiveAt ?? b.updatedAt;
            final byRecency = bUsed.compareTo(aUsed);
            if (byRecency != 0) return byRecency;
            return a.id.compareTo(b.id);
          }),
      );
});
