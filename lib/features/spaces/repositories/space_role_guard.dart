import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/change_record.dart';
import '../../../core/models/shared_member.dart';

/// Thrown by [SpaceAccessGuard] when a shared-space write is refused
/// (contracts/space-roles §3–4).
///
/// Every refusal shares one meaning: the operation did not happen and nothing
/// was persisted. Callers surface the message to identify which rule fired.
class UnauthorizedSpaceAction implements Exception {
  const UnauthorizedSpaceAction(this.message);

  /// Human-readable reason, always mentioning the refusing rule so tests and
  /// logs can pin the exact failure.
  final String message;

  @override
  String toString() => 'UnauthorizedSpaceAction: $message';
}

/// The single authority for shared-space writes (contracts/space-roles §1).
///
/// Pure Dart — no Isar, no Riverpod — so the role matrix is unit-testable
/// without a database (FR-005, SC-005, I1). Repositories load the acting
/// profile's [SharedMember] row and pass it in; a `null` member is a
/// non-member and every gate fails closed.
class SpaceAccessGuard {
  const SpaceAccessGuard();

  /// View = opened membership of any role (Owner/Editor/Viewer, §2).
  ///
  /// `canView(null)` is false — a profile with no membership row cannot even
  /// read the space (failure matrix: "Non-member reads or writes a space").
  bool canView(SharedMember? member) => member != null;

  /// Edit = money operations (§2): Owner and Editor write shared money rows;
  /// Viewer only reads.
  bool canEdit(SharedMember? member) =>
      member != null && member.role != SharedMemberRole.viewer;

  /// Manage = people + space settings (§2): only the Owner.
  bool canManage(SharedMember? member) =>
      member != null && member.role == SharedMemberRole.owner;

  /// Read refusal — throws instead of returning false so write paths cannot
  /// accidentally ignore a failed check.
  void assertView(SharedMember? member) {
    if (!canView(member)) {
      throw const UnauthorizedSpaceAction(
        'a profile without a membership row cannot access this space',
      );
    }
  }

  /// Edit refusal — every shared money write funnels through here (I1).
  void assertEdit(SharedMember? member) {
    if (!canEdit(member)) {
      throw const UnauthorizedSpaceAction(
        'SharedMember.role does not permit editing money (needs Owner/Editor)',
      );
    }
  }

  /// Manage refusal — space settings, invites, roles, transfer, delete.
  void assertManage(SharedMember? member) {
    if (!canManage(member)) {
      throw const UnauthorizedSpaceAction(
        'SharedMember.role does not permit managing the space (needs Owner)',
      );
    }
  }

  /// Sealed-month refusal (I4, FR-012): a sealed shared month is immutable for
  /// **every** role — the guard refuses even the Owner.
  ///
  /// [sealed] comes from the month-seal table the caller already read inside
  /// its transaction, so the guard itself stays database-free.
  void assertMonthEditable(SharedMember? member, {required bool sealed}) {
    assertEdit(member);
    if (sealed) {
      throw const UnauthorizedSpaceAction(
        'sealed months are frozen for every role; no write may land',
      );
    }
  }

  /// The entity types whose author must be the **Owner** (people and space
  /// settings); every other covered type is a money/directory write open to
  /// Owner or Editor (`contracts/role-authorization.md` §1).
  static const Set<String> _ownerOnlyEntityTypes = {
    'SharedMember',
    'SharedSpace',
    'MonthEndRun',
  };

  /// Whether [member]'s role may author a change of [entityType] at apply time
  /// (`role-authorization.md` §1/§3).
  ///
  /// Money and directory entity types need Owner or Editor; `SharedMember` and
  /// `SharedSpace` are Owner-only.
  bool canAuthor(SharedMember? member, String entityType) =>
      _ownerOnlyEntityTypes.contains(entityType)
          ? canManage(member)
          : canEdit(member);

  /// Apply-time authorization for one incoming change (`role-authorization.md`
  /// §3, FR-008/009/011).
  ///
  /// Called by the sync engine for every change in a **signed (012-managed)
  /// space**, where [membershipHead] is the author's local membership resolved
  /// by their identity and [sealed] says the change targets a sealed month.
  /// Refuses, in order: an unknown author; an author revoked at or before the
  /// change's HLC; a role that may not author [ChangeRecord.entityType]; and any
  /// change to a sealed month — for every role. The engine turns a refusal into
  /// a drop, so nothing is silently applied.
  void assertAuthorizedAt(
    ChangeRecord change, {
    required SharedMember? membershipHead,
    required bool sealed,
  }) {
    final author = membershipHead;
    if (author == null) {
      throw const UnauthorizedSpaceAction(
        'the author is not a member of this space',
      );
    }
    if (author.revokedAt != null && change.hlcMillis >= author.version) {
      throw const UnauthorizedSpaceAction(
        'the author was removed before this change',
      );
    }
    if (!canAuthor(author, change.entityType)) {
      throw UnauthorizedSpaceAction(
        'SharedMember.role "${author.role.name}" may not write '
        '${change.entityType}',
      );
    }
    if (sealed) {
      throw const UnauthorizedSpaceAction(
        'sealed months are frozen for every role; no change may be applied',
      );
    }
  }

  /// Exactly-one-context invariant (I5, FR-003): a money row must carry exactly
  /// one owner — a personal [profileId] **or** a [sharedSpaceId], never both
  /// and never neither.
  ///
  /// [owner] names the row for the message (e.g. 'MonthlyBudget').
  void assertExactlyOneContext({
    required int? profileId,
    required int? sharedSpaceId,
    String owner = 'money row',
  }) {
    if ((profileId == null) == (sharedSpaceId == null)) {
      throw UnauthorizedSpaceAction(
        '$owner must resolve to exactly one context: got profileId=$profileId, '
        'sharedSpaceId=$sharedSpaceId',
      );
    }
  }
}

/// The app-wide guard instance exposed for repositories and UI (T022).
final spaceRoleGuardProvider = Provider<SpaceAccessGuard>(
  (ref) => const SpaceAccessGuard(),
);
