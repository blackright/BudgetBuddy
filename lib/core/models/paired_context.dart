import 'package:isar/isar.dart';

import 'context_kind.dart';
import 'shared_member.dart';

part 'paired_context.g.dart';

/// Which context is shared with which peer (data-model §2.4).
///
/// One row per (peer, context): the unique composite index refuses a duplicate
/// pairing. [peerRole] is only a local cache — the authoritative copy of a
/// member's role is the signed [SharedMember] history (`contracts/role-
/// authorization.md` §2).
@collection
class PairedContext {
  Id id = Isar.autoIncrement;

  /// Links to `PairedPeer.id`.
  @Index(composite: [
    CompositeIndex('contextKind'),
    CompositeIndex('contextLocalId'),
  ], unique: true, replace: true)
  late int peerId;

  /// `shared` in v1 (FR-016).
  @enumerated
  late ContextKind contextKind;

  /// The `SharedSpace.id` (personal contexts are deferred, US6).
  late int contextLocalId;

  /// Local cache of the peer's role.
  @enumerated
  late SharedMemberRole peerRole;

  late DateTime pairedAt;

  /// `false` once unpaired/tombstoned (FR-014 unpair).
  bool active = true;
}
