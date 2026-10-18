import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/models/paired_peer.dart';
import '../../../core/models/shared_member.dart';
import '../../../core/models/shared_space.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/identity_provider.dart';
import '../../identity/domain/identity_profile_key.dart';
import '../../pairing/providers/pairing_providers.dart';
import '../domain/shared_member_key.dart';
import '../repositories/space_role_guard.dart';

/// The uniform membership key for [profileId] (T060).
///
/// Membership rows are **stored** under `sharedMemberKey` (the fingerprint-
/// derived key) whenever the profile owns an `Identity`, and under the raw
/// `UserProfile.id` only for a pre-012 profile with no identity. This provider
/// resolves that key so the read paths below can match the rows the write paths
/// actually produce.
final profileMembershipKeyProvider = FutureProvider.family<int, int>(
  (ref, profileId) =>
      sharedMemberKeyForLocalProfile(IsarHelper.instance, profileId),
);

/// The display name for every form `SharedMember.profileId` can take (015).
///
/// A membership row is stored under the identity-derived key — `sharedMemberKey`
/// of the local profile's fingerprint (T044a) or `remoteProfileIdFor` of a
/// paired peer's fingerprint — so a name map built from raw `UserProfile.id`s
/// alone resolves nobody on a synced phone: the Members list, the transfer
/// dialog and the remove confirmation all fell back to their placeholders.
/// This map covers all three forms the rows actually use: the raw id (a
/// pre-012 profile with no `Identity`), the local profile under its identity
/// key, and a paired contact under the key its membership was granted with
/// (named by `peerUsername`, the label every other peer surface shows).
///
/// Built only from watched streams — no direct Isar access — so widget tests
/// can drive it entirely through overrides (see `member_display_name_test`).
final memberDisplayNamesProvider = Provider<Map<int, String>>((ref) {
  final profiles =
      ref.watch(profilesProvider).valueOrNull ?? const <UserProfile>[];
  final peers =
      ref.watch(pairedPeersProvider).valueOrNull ?? const <PairedPeer>[];
  final identity = ref.watch(identityProvider).valueOrNull;

  final names = <int, String>{
    for (final profile in profiles) profile.id: profile.name,
    for (final peer in peers)
      if (peer.peerUsername.isNotEmpty)
        remoteProfileIdFor(peer.peerIdentityId): peer.peerUsername,
  };
  if (identity != null) {
    // The identity-backed key is what the write paths store for this profile
    // (`sharedMemberKeyForLocalProfile`), so the local member's own row
    // resolves too. The device holds a single identity (FR-016), and any
    // other profile keeps its raw id above.
    for (final profile in profiles) {
      if (profile.id == identity.localProfileId) {
        names[sharedMemberKey(identity.fingerprint)] = profile.name;
      }
    }
  }
  return names;
});

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
  // Match the uniform membership key AND the raw id, so both an identity-keyed
  // row and a legacy pre-012 row resolve (T060). When the key future resolves,
  // this provider rebuilds and the query tightens to the real key.
  final key = ref.watch(profileMembershipKeyProvider(profileId)).valueOrNull ??
      profileId;
  return isar.sharedMembers
      .filter()
      .group((q) => q.profileIdEqualTo(profileId).or().profileIdEqualTo(key))
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
  final key = ref.watch(profileMembershipKeyProvider(profileId)).valueOrNull ??
      profileId;
  return isar.sharedMembers
      .filter()
      .group((q) => q.profileIdEqualTo(profileId).or().profileIdEqualTo(key))
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
  final key = ref.watch(profileMembershipKeyProvider(profileId)).valueOrNull ??
      profileId;
  final members = ref.watch(activeSpaceMembersProvider).value;
  if (members == null) return null;
  for (final member in members) {
    // The uniform membership key is what the write paths store; the raw id is
    // the pre-012 fallback, so match either (T060).
    if (member.profileId == key || member.profileId == profileId) return member;
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
