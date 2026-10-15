import 'dart:convert';
import 'dart:math';

import 'package:isar/isar.dart';

import '../../../core/models/context_kind.dart';
import '../../../core/models/identity.dart';
import '../../../core/models/paired_context.dart';
import '../../../core/models/paired_peer.dart';
import '../../../core/models/pairing_token.dart';
import '../../../core/models/shared_member.dart';
import '../../../core/models/shared_space.dart';
import '../../../core/models/sync_cursor.dart';
import '../../identity/domain/fingerprint.dart';
import '../../sync/domain/change_signing.dart';
import '../../sync/domain/codecs/shared_member_codec.dart';
import '../../sync/domain/hlc.dart';
import '../../sync/repositories/change_signer.dart';
import '../../sync/repositories/sync_recorder.dart';
import '../domain/pairing_protocol.dart';

/// The co-located pairing handshake, driven entirely from one device
/// (`contracts/pairing.md` §2–§5, FR-004/005).
///
/// One instance acts for **one** device's identity. The Owner (presenter) calls
/// [createInvite] → [handleClaim]; the joining device (scanner) calls
/// [parsePayload] → [claimFrom] → (after receiving the reply) [acceptResult].
/// Nothing here touches the network: the claim/result messages are passed to the
/// caller, who carries them over the LAN [Transport]; that keeps the whole
/// handshake unit-testable without sockets.
///
/// **Signing**: the membership the Owner grants is signed by the Owner's own
/// identity (R5) — the same trust that every later change rides — so apply-time
/// authorization (US4) can verify it against the paired public key.
class PairingService {
  PairingService(
    this._isar, {
    required Identity identity,
    ChangeSigner? signer,
    HlcClock? clock,
    DateTime Function()? wallClock,
    SyncRecorder? recorder,
  })  : _identity = identity,
        _signer = signer,
        _clock = clock ?? HlcClock(deviceId: ''),
        _wallClock = wallClock ?? DateTime.now,
        _recorder = recorder ??
            (signer == null
                ? null
                : SyncRecorder(
                    _isar,
                    signer: signer,
                    clock: clock ?? HlcClock(deviceId: ''),
                    wallClock: wallClock,
                  ));

  /// Default QR lifetime: long enough to walk over, short enough to be safe
  /// (`contracts/pairing.md` §2).
  static const Duration defaultTtl = Duration(seconds: 120);

  final Isar _isar;
  final Identity _identity;
  final ChangeSigner? _signer;
  final HlcClock _clock;
  final DateTime Function() _wallClock;
  final SyncRecorder? _recorder;

  final Random _random = Random.secure();

  String get identityId => _identity.fingerprint;

  /// The signing key must be released (identity unlocked) before a membership
  /// can be granted; listing/cancelling do not need it.
  ChangeSigner get _requireSigner {
    final signer = _signer;
    if (signer == null) {
      throw const PairingException(
        'unlock your identity before completing a pairing',
      );
    }
    return signer;
  }

  // ---------------------------------------------------------------------------
  // Presenter (the Owner showing the QR)
  // ---------------------------------------------------------------------------

  /// Persists a brand-new single-use [PairingToken] and returns the QR payload
  /// (`pairing.md` §2). Any earlier live invite for the same space is
  /// invalidated first, so a re-made QR is the only one that works.
  Future<PairingInvite> createInvite({
    required int spaceId,
    required SharedMemberRole offeredRole,
    Duration ttl = defaultTtl,
    DateTime? now,
  }) async {
    final clock = now ?? _wallClock();
    final token = _newToken();
    return _isar.writeTxn(() async {
      await _isar.pairingTokens
          .filter()
          .spaceIdEqualTo(spaceId)
          .directionEqualTo(PairingDirection.presented)
          .usedAtIsNull()
          .deleteAll();

      final row = PairingToken()
        ..token = token
        ..spaceId = spaceId
        ..offeredRole = offeredRole
        ..direction = PairingDirection.presented
        ..createdAt = clock
        ..expiresAt = clock.add(ttl);
      row.id = await _isar.pairingTokens.put(row);

      final payload = PairingPayload(
        identityId: _identity.fingerprint,
        username: _identity.username,
        publicKey: _identity.publicKey,
        fingerprint: _identity.fingerprint,
        spaceId: spaceId,
        offeredRole: offeredRole,
        token: token,
        expiresAt: row.expiresAt,
      );
      return PairingInvite(token: token, payload: payload);
    });
  }

  /// Invalidates an outstanding invite so its QR stops working (`pairing.md` §5).
  Future<void> cancelInvite({required String token}) =>
      _isar.writeTxn(() async {
        await _isar.pairingTokens.filter().tokenEqualTo(token).deleteAll();
      });

  /// Unpairs a peer for one space (or every space when [spaceId] is null):
  /// the paired context is deactivated so no further change is exchanged and the
  /// local copy of the data is kept (FR-014, `pairing.md` §5). The exchange
  /// cursor is retained as a watermark so a re-pair resumes cleanly.
  Future<void> unpair({
    required String peerIdentityId,
    int? spaceId,
  }) =>
      _isar.writeTxn(() async {
        final peer = await _isar.pairedPeers
            .filter()
            .peerIdentityIdEqualTo(peerIdentityId)
            .findFirst();
        if (peer == null) return;
        final contexts = await _isar.pairedContexts
            .filter()
            .peerIdEqualTo(peer.id)
            .findAll();
        for (final context in contexts) {
          if (spaceId != null && context.contextLocalId != spaceId) continue;
          context.active = false;
          await _isar.pairedContexts.put(context);
        }
      });

  /// Validates a scanner's [claim] and, on success, grants the membership and
  /// records the pairing (`pairing.md` §3 step 4–5).
  ///
  /// Refuses (with [PairingException] and nothing persisted) a cancelled/unknown
  /// token, a reused token, an expired token, a key/fingerprint mismatch, a
  /// space without an Owner, or a peer already paired for this space (FR-005).
  Future<PairingClaimResult> handleClaim(
    PairingClaim claim, {
    DateTime? now,
  }) async {
    final clock = now ?? _wallClock();
    final scannerFingerprint = await _fingerprint(claim.scannerPublicKey);
    if (scannerFingerprint != claim.scannerIdentityId) {
      throw const PairingException(
        'the scanner key does not match the fingerprint it claims',
      );
    }

    return _isar.writeTxn(() async {
      final token = await _isar.pairingTokens
          .filter()
          .tokenEqualTo(claim.token)
          .findFirst();
      if (token == null) {
        throw const PairingException(
            'this invite was cancelled or never existed');
      }
      if (token.usedAt != null) {
        throw const PairingException('this invite was already used');
      }
      if (!clock.isBefore(token.expiresAt)) {
        throw const PairingException('this invite has expired');
      }
      if (await _isar.sharedSpaces.get(token.spaceId) == null) {
        throw const PairingException('the space to share no longer exists');
      }
      if (await _activeOwnerCount(token.spaceId) < 1) {
        throw const PairingException('the space has no Owner to pair from');
      }

      final existingPeer = await _isar.pairedPeers
          .filter()
          .peerIdentityIdEqualTo(claim.scannerIdentityId)
          .findFirst();
      if (existingPeer != null &&
          await _hasActiveContext(existingPeer.id, token.spaceId)) {
        throw const PairingException(
          'this device is already paired to that space',
        );
      }

      final member = await _grantMembership(
        spaceId: token.spaceId,
        scannerFingerprint: scannerFingerprint,
        role: token.offeredRole,
        clock: clock,
      );

      token
        ..usedAt = clock
        ..peerFingerprint = scannerFingerprint;
      await _isar.pairingTokens.put(token);

      final peer = await _persistPeer(
        identityId: scannerFingerprint,
        username: claim.scannerUsername,
        publicKey: claim.scannerPublicKey,
        existing: existingPeer,
        clock: clock,
      );
      await _persistContext(peer.id, token.spaceId, token.offeredRole, clock);
      await _ensureCursor(peer.id, token.spaceId, clock);
      await _recorder?.recordMember(member, now: clock);

      return PairingClaimResult(
        presenterIdentityId: _identity.fingerprint,
        presenterUsername: _identity.username,
        presenterPublicKey: _identity.publicKey,
        contextLocalId: token.spaceId,
        membership: const SharedMemberCodec().toPayload(member),
        decidedAt: clock,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Scanner (the joining device)
  // ---------------------------------------------------------------------------

  /// Parses and validates a scanned QR (`pairing.md` §2/§4): checks the version,
  /// the expiry, and that the public key matches the fingerprint it claims. A
  /// tampered or foreign code is refused before any state changes.
  Future<PairingPayload> parsePayload(String raw, {DateTime? now}) async {
    final clock = now ?? _wallClock();
    final PairingPayload payload;
    try {
      payload = PairingPayload.parse(raw);
    } catch (_) {
      throw const PairingException('this is not a BudgetBuddy pairing code');
    }
    if (payload.v != kPairingPayloadVersion ||
        payload.type != kPairingPayloadType) {
      throw const PairingException(
          'this pairing code is an unsupported version');
    }
    if (!clock.isBefore(payload.expiresAt)) {
      throw const PairingException('this pairing code has expired');
    }
    final expected = await _fingerprint(payload.publicKey);
    if (expected != payload.fingerprint || expected != payload.identityId) {
      throw const PairingException(
        'the pairing code is tampered: key and fingerprint disagree',
      );
    }
    return payload;
  }

  /// Builds this device's [PairingClaim] for a scanned [payload] (§3 step 3).
  PairingClaim claimFrom(PairingPayload payload) => PairingClaim(
        token: payload.token,
        scannerIdentityId: _identity.fingerprint,
        scannerPublicKey: _identity.publicKey,
        scannerUsername: _identity.username,
      );

  /// Persists the pairing on the scanner side after the presenter replies
  /// (§3 step 5): the presenter becomes a paired peer, the space a paired
  /// context, and the echoed signed membership is materialized locally.
  Future<void> acceptResult(
    PairingPayload payload,
    PairingClaimResult result, {
    required int spaceId,
    DateTime? now,
  }) async {
    final clock = now ?? _wallClock();
    final presenterFingerprint = await _fingerprint(result.presenterPublicKey);
    if (presenterFingerprint != result.presenterIdentityId) {
      throw const PairingException(
        'the presenter key does not match its fingerprint',
      );
    }
    await _isar.writeTxn(() async {
      final existing = await _isar.pairedPeers
          .filter()
          .peerIdentityIdEqualTo(result.presenterIdentityId)
          .findFirst();
      final peer = await _persistPeer(
        identityId: result.presenterIdentityId,
        username: result.presenterUsername,
        publicKey: result.presenterPublicKey,
        existing: existing,
        clock: clock,
      );
      await _persistContext(peer.id, spaceId, payload.offeredRole, clock);
      await _ensureCursor(peer.id, spaceId, clock);
      if (result.membership != null) {
        final member =
            const SharedMemberCodec().fromPayload(result.membership!);
        member.id = await _isar.sharedMembers.put(member);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  Future<SharedMember> _grantMembership({
    required int spaceId,
    required String scannerFingerprint,
    required SharedMemberRole role,
    required DateTime clock,
  }) async {
    final profileId = remoteProfileIdFor(scannerFingerprint);
    final existing = await _isar.sharedMembers
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .profileIdEqualTo(profileId)
        .findFirst();
    final member = existing ??
        (SharedMember()
          ..sharedSpaceId = spaceId
          ..profileId = profileId
          ..joinedAt = clock);
    member
      ..role = role
      ..version = _clock.tick(clock).millis
      ..updatedAt = clock
      ..authorIdentityId = _identity.fingerprint
      ..revokedAt = null;
    member.signature =
        await _requireSigner.sign(membershipCanonicalBytes(member));
    member.id = await _isar.sharedMembers.put(member);
    return member;
  }

  Future<PairedPeer> _persistPeer({
    required String identityId,
    required String username,
    required String publicKey,
    required PairedPeer? existing,
    required DateTime clock,
  }) async {
    final peer = existing ?? (PairedPeer()..pairedAt = clock);
    peer
      ..peerIdentityId = identityId
      ..peerUsername = username
      ..peerPublicKey = publicKey
      ..peerFingerprint = identityId
      ..lastSeenAt = clock;
    peer.id = await _isar.pairedPeers.put(peer);
    return peer;
  }

  Future<void> _persistContext(
    int peerId,
    int spaceId,
    SharedMemberRole role,
    DateTime clock,
  ) async {
    final existing = await _isar.pairedContexts
        .filter()
        .peerIdEqualTo(peerId)
        .contextKindEqualTo(ContextKind.shared)
        .contextLocalIdEqualTo(spaceId)
        .findFirst();
    final context = existing ??
        (PairedContext()
          ..peerId = peerId
          ..contextKind = ContextKind.shared
          ..contextLocalId = spaceId
          ..pairedAt = clock);
    context
      ..peerRole = role
      ..active = true;
    await _isar.pairedContexts.put(context);
  }

  Future<void> _ensureCursor(int peerId, int spaceId, DateTime clock) async {
    final existing = await _isar.syncCursors
        .filter()
        .peerIdEqualTo(peerId)
        .contextLocalIdEqualTo(spaceId)
        .findFirst();
    if (existing != null) return;
    final cursor = SyncCursor()
      ..peerId = peerId
      ..contextLocalId = spaceId
      ..updatedAt = clock;
    await _isar.syncCursors.put(cursor);
  }

  Future<bool> _hasActiveContext(int peerId, int spaceId) async {
    final context = await _isar.pairedContexts
        .filter()
        .peerIdEqualTo(peerId)
        .contextKindEqualTo(ContextKind.shared)
        .contextLocalIdEqualTo(spaceId)
        .findFirst();
    return context != null && context.active;
  }

  Future<int> _activeOwnerCount(int spaceId) async {
    final owners = await _isar.sharedMembers
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .roleEqualTo(SharedMemberRole.owner)
        .findAll();
    return owners.where((member) => member.revokedAt == null).length;
  }

  Future<String> _fingerprint(String publicKeyBase64) async {
    try {
      return await fingerprintOfPublicKeyBytes(base64Decode(publicKeyBase64));
    } catch (_) {
      throw const PairingException('the pairing key is not a valid public key');
    }
  }

  /// A URL-safe, ≥128-bit random token (`pairing.md` §2); a guess cannot collide
  /// with a live token because the column is unique.
  String _newToken() =>
      base64UrlEncode(List<int>.generate(16, (_) => _random.nextInt(256)));
}
