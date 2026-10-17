import 'dart:convert';

import '../../../core/models/shared_member.dart';

/// The membership-key derivation re-exported for pairing callers; the single
/// definition lives in the identity domain so the spaces data layer can reuse it
/// without importing `features/pairing` (T044a).
export '../../identity/domain/identity_profile_key.dart'
    show remoteProfileIdFor;

/// The QR payload format version and discriminator (`contracts/pairing.md` §2).
const int kPairingPayloadVersion = 1;

/// A space **invite** code: the presenter offers a role in one shared space.
const String kPairingPayloadType = 'buddy.pairing';

/// A space-independent **identity** code (US7): the presenter only trades
/// contact details — no space and no role — so two people can become contacts
/// before (or instead of) sharing a space.
const String kIdentityPayloadType = 'buddy.identity';

/// Which kind of BudgetBuddy code a scanned string is, so the UI can route it
/// to the right flow (`pairing.md` §2). Unknown/foreign strings return `null`.
enum PairingCodeKind { spaceInvite, identity }

/// Reads only the `type` discriminator of [raw]; never throws.
PairingCodeKind? pairingCodeKindOf(String raw) {
  try {
    final json = (jsonDecode(raw) as Map).cast<String, Object?>();
    return switch (json['type']) {
      kPairingPayloadType => PairingCodeKind.spaceInvite,
      kIdentityPayloadType => PairingCodeKind.identity,
      _ => null,
    };
  } catch (_) {
    return null;
  }
}

/// Thrown for any refused pairing step — expired, already-used, cancelled,
/// duplicated, tampered, or missing a space/Owner (FR-005, `pairing.md` §4).
///
/// One exception type keeps the UI simple: every refusal carries a
/// human-readable [message] the caller can surface verbatim.
class PairingException implements Exception {
  const PairingException(this.message);

  /// Human-readable reason, always naming the rule that refused.
  final String message;

  @override
  String toString() => 'PairingException: $message';
}

/// The QR payload a presenter encodes and a scanner parses (`pairing.md` §2).
///
/// It carries a **public** key and a single-use token only — never a secret.
/// The scanner cross-checks [fingerprint] against [publicKey] before confirming,
/// which is what defeats a tampered or look-alike code (FR-004, SC-006).
class PairingPayload {
  const PairingPayload({
    required this.identityId,
    required this.username,
    required this.publicKey,
    required this.fingerprint,
    required this.spaceId,
    required this.offeredRole,
    required this.token,
    required this.expiresAt,
    this.v = kPairingPayloadVersion,
    this.type = kPairingPayloadType,
  });

  /// Format version, so a future change can be refused cleanly.
  final int v;

  /// Always [kPairingPayloadType]; a foreign QR is refused.
  final String type;

  /// The presenter's identity fingerprint (equals [fingerprint]).
  final String identityId;

  /// The presenter's display label (never a lookup key).
  final String username;

  /// Base64 ed25519 public key of the presenter.
  final String publicKey;

  /// Short human-comparable hash shown for confirmation.
  final String fingerprint;

  /// The presenter's `SharedSpace.id` (display only).
  final int spaceId;

  /// The role the Owner is granting.
  final SharedMemberRole offeredRole;

  /// The single-use `PairingToken.token` value.
  final String token;

  /// After this instant the token is refused (`pairing.md` §4).
  final DateTime expiresAt;

  /// Decodes a scanned string, throwing [FormatException] when it is not a
  /// well-formed payload object at all.
  static PairingPayload parse(String raw) =>
      PairingPayload.fromJson((jsonDecode(raw) as Map).cast<String, Object?>());

  factory PairingPayload.fromJson(Map<String, Object?> json) => PairingPayload(
        v: (json['v'] as num?)?.toInt() ?? 0,
        type: json['type'] as String? ?? '',
        identityId: json['identityId'] as String? ?? '',
        username: json['username'] as String? ?? '',
        publicKey: json['publicKey'] as String? ?? '',
        fingerprint: json['fingerprint'] as String? ?? '',
        spaceId: (json['spaceId'] as num?)?.toInt() ?? 0,
        offeredRole: SharedMemberRole.values.firstWhere(
          (role) => role.name == json['offeredRole'],
          orElse: () => SharedMemberRole.viewer,
        ),
        token: json['token'] as String? ?? '',
        expiresAt: DateTime.parse(json['expiresAt'] as String).toUtc(),
      );

  Map<String, Object?> toJson() => {
        'v': v,
        'type': type,
        'identityId': identityId,
        'username': username,
        'publicKey': publicKey,
        'fingerprint': fingerprint,
        'spaceId': spaceId,
        'offeredRole': offeredRole.name,
        'token': token,
        'expiresAt': expiresAt.toUtc().toIso8601String(),
      };

  /// The exact string encoded into the QR.
  String encode() => jsonEncode(toJson());
}

/// The scanner's claim message sent to the presenter over the LAN transport
/// (`pairing.md` §3 step 3).
class PairingClaim {
  const PairingClaim({
    required this.token,
    required this.scannerIdentityId,
    required this.scannerPublicKey,
    required this.scannerUsername,
  });

  final String token;
  final String scannerIdentityId;
  final String scannerPublicKey;
  final String scannerUsername;

  static PairingClaim parse(String raw) =>
      PairingClaim.fromJson((jsonDecode(raw) as Map).cast<String, Object?>());

  factory PairingClaim.fromJson(Map<String, Object?> json) => PairingClaim(
        token: json['token'] as String? ?? '',
        scannerIdentityId: json['scannerIdentityId'] as String? ?? '',
        scannerPublicKey: json['scannerPublicKey'] as String? ?? '',
        scannerUsername: json['scannerUsername'] as String? ?? '',
      );

  Map<String, Object?> toJson() => {
        'token': token,
        'scannerIdentityId': scannerIdentityId,
        'scannerPublicKey': scannerPublicKey,
        'scannerUsername': scannerUsername,
      };

  String encode() => jsonEncode(toJson());
}

/// The presenter's reply to a successful claim (`pairing.md` §3 step 5).
///
/// It returns the presenter's public identity plus the **signed membership
/// payload** and the change-log high-water mark the scanner needs to open a
/// cursor and converge.
class PairingClaimResult {
  const PairingClaimResult({
    required this.presenterIdentityId,
    required this.presenterUsername,
    required this.presenterPublicKey,
    required this.contextLocalId,
    required this.membership,
    required this.decidedAt,
  });

  final String presenterIdentityId;
  final String presenterUsername;
  final String presenterPublicKey;

  /// The presenter's `SharedSpace.id` for the pairing (§3 step 5).
  final int contextLocalId;

  /// The canonical `SharedMemberCodec` payload of the granted membership, or
  /// `null` if the impl chose not to echo it.
  final String? membership;

  final DateTime decidedAt;

  static PairingClaimResult parse(String raw) => PairingClaimResult.fromJson(
      (jsonDecode(raw) as Map).cast<String, Object?>());

  factory PairingClaimResult.fromJson(Map<String, Object?> json) =>
      PairingClaimResult(
        presenterIdentityId: json['presenterIdentityId'] as String? ?? '',
        presenterUsername: json['presenterUsername'] as String? ?? '',
        presenterPublicKey: json['presenterPublicKey'] as String? ?? '',
        contextLocalId: (json['contextLocalId'] as num?)?.toInt() ?? 0,
        membership: json['membership'] as String?,
        decidedAt: DateTime.parse(json['decidedAt'] as String).toUtc(),
      );

  Map<String, Object?> toJson() => {
        'presenterIdentityId': presenterIdentityId,
        'presenterUsername': presenterUsername,
        'presenterPublicKey': presenterPublicKey,
        'contextLocalId': contextLocalId,
        'membership': membership,
        'decidedAt': decidedAt.toUtc().toIso8601String(),
      };

  String encode() => jsonEncode(toJson());
}

/// The persisted presenter invite plus its scannable [payload] (`pairing.md` §2).
class PairingInvite {
  const PairingInvite({required this.token, required this.payload});

  /// The stored `PairingToken.token` value (for cancel).
  final String token;

  /// The QR content to display.
  final PairingPayload payload;
}

/// The QR payload for a **space-independent identity** code (US7, T059).
///
/// It is the [PairingPayload] minus `spaceId`/`offeredRole`: the same public
/// identity material and single-use token, but it grants no membership — the
/// two devices simply become each other's contacts. A distinct [type] keeps the
/// two code kinds apart, so a space invite is never mistaken for a contact
/// exchange.
class PairingIdentityPayload {
  const PairingIdentityPayload({
    required this.identityId,
    required this.username,
    required this.publicKey,
    required this.fingerprint,
    required this.token,
    required this.expiresAt,
    this.v = kPairingPayloadVersion,
    this.type = kIdentityPayloadType,
  });

  /// Format version, so a future change can be refused cleanly.
  final int v;

  /// Always [kIdentityPayloadType]; a foreign QR is refused.
  final String type;

  /// The presenter's identity fingerprint (equals [fingerprint]).
  final String identityId;

  /// The presenter's display label (never a lookup key).
  final String username;

  /// Base64 ed25519 public key of the presenter.
  final String publicKey;

  /// Short human-comparable hash shown for confirmation.
  final String fingerprint;

  /// The single-use token, echoed back in the reply so the two QRs must match.
  final String token;

  /// After this instant the code is refused (`pairing.md` §4).
  final DateTime expiresAt;

  /// Decodes a scanned string, throwing [FormatException] when it is not a
  /// well-formed payload object at all.
  static PairingIdentityPayload parse(String raw) =>
      PairingIdentityPayload.fromJson(
          (jsonDecode(raw) as Map).cast<String, Object?>());

  factory PairingIdentityPayload.fromJson(Map<String, Object?> json) =>
      PairingIdentityPayload(
        v: (json['v'] as num?)?.toInt() ?? 0,
        type: json['type'] as String? ?? '',
        identityId: json['identityId'] as String? ?? '',
        username: json['username'] as String? ?? '',
        publicKey: json['publicKey'] as String? ?? '',
        fingerprint: json['fingerprint'] as String? ?? '',
        token: json['token'] as String? ?? '',
        expiresAt: DateTime.parse(json['expiresAt'] as String).toUtc(),
      );

  Map<String, Object?> toJson() => {
        'v': v,
        'type': type,
        'identityId': identityId,
        'username': username,
        'publicKey': publicKey,
        'fingerprint': fingerprint,
        'token': token,
        'expiresAt': expiresAt.toUtc().toIso8601String(),
      };

  /// The exact string encoded into the QR.
  String encode() => jsonEncode(toJson());
}

/// The presenter's identity invite plus its scannable [payload] (US7, T059).
class PairingIdentityInvite {
  const PairingIdentityInvite({required this.token, required this.payload});

  /// The token to match against the scanned reply.
  final String token;

  /// The QR content to display.
  final PairingIdentityPayload payload;
}
