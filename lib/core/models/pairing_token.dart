import 'package:isar/isar.dart';

import 'context_kind.dart';
import 'shared_member.dart';

part 'pairing_token.g.dart';

/// A single-use, expirable, cancellable pairing token (data-model §2.5,
/// FR-005).
///
/// The QR a presenter shows encodes a brand-new [PairingToken] with
/// [direction] = [PairingDirection.presented] and an [expiresAt] TTL (default
/// 120 s). A successful claim stamps [usedAt] so a replay is refused; a cancel
/// simply invalidates the row (`contracts/pairing.md` §2/§5).
@collection
class PairingToken {
  Id id = Isar.autoIncrement;

  /// URL-safe random value, at least 128 bits (pairing §2). Unique so a guess
  /// cannot collide with a live token.
  @Index(unique: true, replace: true)
  late String token;

  /// The shared space being offered (`SharedSpace.id`).
  late int spaceId;

  /// The role the Owner is granting (FR-005).
  @enumerated
  late SharedMemberRole offeredRole;

  /// Presented (showing the QR) or claimed (scanned it) (data-model §1.2).
  @enumerated
  late PairingDirection direction;

  /// Bound on a successful claim so a mismatched scanner is detected.
  String? peerFingerprint;

  late DateTime createdAt;

  /// After this instant the token is refused; a new QR must be shown (FR-005).
  late DateTime expiresAt;

  /// Non-null once claimed: refuses reuse (single-use, FR-005).
  DateTime? usedAt;
}
