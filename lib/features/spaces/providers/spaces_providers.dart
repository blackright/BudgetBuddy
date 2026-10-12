import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/models/shared_member.dart';
import '../../../core/models/shared_space.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../repositories/space_role_guard.dart';

/// The active profile's membership rows across every space (US2).
///
/// `null`/empty when no profile is active. Streaming, so an invite or role
/// change re-renders the switcher and settings in the same frame.
final myMembershipsProvider = StreamProvider<List<SharedMember>>((ref) {
  final profileId = ref.watch(activeProfileProvider).valueOrNull?.id;
  if (profileId == null) {
    return Stream.value(const <SharedMember>[]);
  }
  final isar = IsarHelper.instance;
  return isar.sharedMembers
      .filter()
      .profileIdEqualTo(profileId)
      .watch(fireImmediately: true);
});

/// The spaces the active profile belongs to, in name order (US2).
///
/// Drives the [SpaceSwitcher] dropdown. Built from [myMembershipsProvider], so
/// joining a space (creating one) or leaving one updates the list at once.
final mySpacesProvider = StreamProvider<List<SharedSpace>>((ref) {
  final profileId = ref.watch(activeProfileProvider).valueOrNull?.id;
  if (profileId == null) {
    return Stream.value(const <SharedSpace>[]);
  }
  final isar = IsarHelper.instance;
  return isar.sharedMembers
      .filter()
      .profileIdEqualTo(profileId)
      .watch(fireImmediately: true)
      .asyncMap((members) async {
    final spaces = <SharedSpace>[];
    for (final member in members) {
      final space = await isar.sharedSpaces.get(member.sharedSpaceId);
      if (space != null) spaces.add(space);
    }
    spaces.sort((a, b) {
      final byName = a.name.compareTo(b.name);
      if (byName != 0) return byName;
      return a.id.compareTo(b.id);
    });
    return spaces;
  });
});

/// The memberships of the active shared space, one row per member (US2).
///
/// Empty in personal context. The settings section renders members and roles
/// from here, and the owner/member role gates in the UI derive from it.
final activeSpaceMembersProvider = StreamProvider<List<SharedMember>>((ref) {
  final spaceId = ref.watch(activeSpaceIdProvider);
  if (spaceId == null) {
    return Stream.value(const <SharedMember>[]);
  }
  final isar = IsarHelper.instance;
  return isar.sharedMembers
      .filter()
      .sharedSpaceIdEqualTo(spaceId)
      .watch(fireImmediately: true);
});

/// The acting profile's membership in the active space, or `null`.
///
/// `null` means the acting profile is not a member (canView fails closed) or no
/// space is active. This is the value the UI reads to decide which controls to
/// offer; the repository re-checks the same rule at the data layer (US4).
final activeSpaceMyRoleProvider = Provider<SharedMember?>((ref) {
  final profileId = ref.watch(activeProfileProvider).valueOrNull?.id;
  if (profileId == null) return null;
  final members = ref.watch(activeSpaceMembersProvider).value;
  if (members == null) return null;
  for (final member in members) {
    if (member.profileId == profileId) return member;
  }
  return null;
});

/// Whether the acting profile may change money in the active context (US4 AC3).
///
/// Personal context has no roles, so it always returns `true`. Shared context
/// mirrors `SpaceAccessGuard.canEdit` — Owner/Editor true, Viewer false. The UI
/// hides controls on this; the repository re-checks it, so a stale UI can never
/// mutate beyond its role (guard stays authoritative).
final activeContextCanEditProvider = Provider<bool>((ref) {
  if (ref.watch(activeSpaceIdProvider) == null) return true;
  const guard = SpaceAccessGuard();
  return guard.canEdit(ref.watch(activeSpaceMyRoleProvider));
});

/// Whether the acting profile may manage the active space (Owner only, US4 AC3).
///
/// Personal context returns `true` because there is no space to manage; the
/// settings surface is only meaningful in a shared context anyway.
final activeContextCanManageProvider = Provider<bool>((ref) {
  if (ref.watch(activeSpaceIdProvider) == null) return true;
  const guard = SpaceAccessGuard();
  return guard.canManage(ref.watch(activeSpaceMyRoleProvider));
});

/// The months the shared [spaceId] owns, oldest first (US2 delete flow).
///
/// Drives the [DeleteSpaceSheet]: each row is one month the owner must resolve
/// (move back to a personal profile, or delete) before the space can go.
final spaceMonthsProvider =
    StreamProvider.family<List<MonthlyBudget>, int>((ref, spaceId) {
  return IsarHelper.instance.monthlyBudgets
      .filter()
      .sharedSpaceIdEqualTo(spaceId)
      .watch(fireImmediately: true)
      .map((months) =>
          [...months]..sort((a, b) => a.yearMonth.compareTo(b.yearMonth)));
});
