import 'package:isar/isar.dart';

part 'shared_member.g.dart';

/// A profile's membership in a shared space, with its role (FR-002, FR-005).
///
/// One row per (space, profile) — the unique composite index makes a second
/// membership impossible. Roles gate money and people operations through
/// `SpaceAccessGuard` at the data layer (`contracts/space-roles.md`).
enum SharedMemberRole {
  owner,
  editor,
  viewer,
}

@collection
class SharedMember {
  Id id = Isar.autoIncrement;

  /// Links to `SharedSpace.id`.
  @Index(composite: [CompositeIndex('profileId')], unique: true, replace: true)
  late int sharedSpaceId;

  /// Links to `UserProfile.id`.
  late int profileId;

  @enumerated
  late SharedMemberRole role;

  /// When the profile joined the space (FR-006).
  late DateTime joinedAt;

  /// HLC millis of the last change to this membership (data-model §3.1, R5).
  /// The higher version wins, so a removal or demotion authored later supersedes
  /// an earlier role on every device (role-authorization §2). Genesis/legacy
  /// rows sit at `0` (migration step 15).
  int version = 0;

  /// When this membership row was last written (data-model §3.1). Nullable so
  /// the many pre-pairing creation sites (and legacy rows) stay valid; migration
  /// step 15 stamps legacy rows from [joinedAt] and the sync paths set it when
  /// they author a change.
  DateTime? updatedAt;

  /// The signer's identity fingerprint (nullable on legacy/backfilled rows).
  String? authorIdentityId;

  /// Base64 ed25519 over the membership fields + [version]; `null` on
  /// legacy/backfilled rows (data-model §3.1, R5).
  String? signature;

  /// Removal tombstone: once set, the member's later changes are refused
  /// everywhere and the row cannot be resurrected (role-authorization §2).
  DateTime? revokedAt;
}
