import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:isar/isar.dart';

import '../../../core/models/change_record.dart';
import '../../../core/models/context_kind.dart';
import '../../../core/models/month_rate_seal.dart';
import '../../../core/models/shared_member.dart';
import '../../../core/models/sync_cursor.dart';
import '../../spaces/domain/shared_member_key.dart';
import '../../spaces/repositories/space_role_guard.dart';
import '../domain/change_signing.dart';
import '../domain/entity_applier.dart';
import '../domain/hlc.dart';
import '../domain/month_key.dart';
import '../domain/sync_codec_registry.dart';
import '../transport/transport.dart';

/// What happened when one incoming [ChangeRecord] met the local head.
enum ApplyOutcome {
  /// The change won and was applied to the local rows.
  applied,

  /// The change lost to the local head; retained (dedupe/cursor) but not applied
  /// and surfaced as a conflict (FR-007/FR-013).
  losing,

  /// The signature did not verify against the author's pinned key; dropped.
  droppedBadSignature,

  /// The signature verified but apply-time authorization refused the change
  /// (author unknown/revoked, role not permitted, or a sealed month); dropped
  /// and surfaced as a conflict (FR-008/009/011, SC-005).
  droppedUnauthorized,

  /// The entity type is not exchanged in v1; dropped (a peer stays compatible).
  droppedUnknownType,

  /// The exact change was already seen; a no-op (idempotent, §3).
  duplicate,
}

/// The peer-to-peer merge-and-exchange engine (`contracts/sync-protocol.md`).
///
/// It verifies each incoming record (signature → authorization is US4's seam),
/// merges by the deterministic HLC rule, and applies the winner through the
/// entity appliers — the same tables the repositories write. Exchange is a
/// terminating snapshot round over a [TransportConnection]; no sockets live here
/// so the whole protocol is testable with the in-memory fake transport.
///
/// **Merge rule (deterministic, §4)**: greater `(hlcMillis, hlcCounter)` wins; at
/// equal time a `delete` tombstone beats an `upsert`; otherwise the greater
/// `deviceId` wins. Every device computes the same winner regardless of arrival
/// order (FR-007).
class SyncEngine {
  SyncEngine(
    this._isar, {
    Map<String, SimplePublicKey> trustedKeys = const {},
    HlcClock? clock,
    SpaceAccessGuard guard = const SpaceAccessGuard(),
  })  : _trustedKeys = Map.of(trustedKeys),
        _clock = clock,
        _guard = guard,
        _ed25519 = Ed25519();

  final Isar _isar;
  final Map<String, SimplePublicKey> _trustedKeys;
  final HlcClock? _clock;
  final SpaceAccessGuard _guard;
  final Ed25519 _ed25519;

  /// Registers/overwrites a trusted author key (after a pairing confirms it).
  void trust(String identityId, SimplePublicKey publicKey) {
    _trustedKeys[identityId] = publicKey;
  }

  /// Every change record for [contextLocalId], in insertion order.
  Future<List<ChangeRecord>> recordsForContext(int contextLocalId) =>
      _isar.changeRecords
          .filter()
          .contextLocalIdEqualTo(contextLocalId)
          .findAll();

  /// The current winning record for an entity key, or `null` if none exists.
  Future<ChangeRecord?> headFor({
    required ContextKind contextKind,
    required int contextLocalId,
    required String entityType,
    required int entityLocalId,
  }) async {
    final candidates = await _isar.changeRecords
        .filter()
        .contextKindEqualTo(contextKind)
        .contextLocalIdEqualTo(contextLocalId)
        .entityTypeEqualTo(entityType)
        .entityLocalIdEqualTo(entityLocalId)
        .findAll();
    ChangeRecord? winner;
    for (final candidate in candidates) {
      if (winner == null || _wins(candidate, winner)) winner = candidate;
    }
    return winner;
  }

  /// Verifies, merges and applies one incoming [ChangeRecord] (§3 step 2–3).
  Future<ApplyOutcome> applyIncoming(ChangeRecord record, {int? peerId}) async {
    if (codecForEntityType(record.entityType) == null ||
        applierForEntityType(record.entityType) == null) {
      return ApplyOutcome.droppedUnknownType;
    }
    if (!await _verify(record)) return ApplyOutcome.droppedBadSignature;
    if (await _isDuplicate(record)) return ApplyOutcome.duplicate;

    return _isar.writeTxn(() async {
      // US4: verify → authorize → merge (role-authorization §3). A refusal is
      // dropped and surfaced as a conflict, never silently applied.
      final denied = await _authorize(record);
      if (denied != null) {
        await _bumpConflict(peerId, record.contextLocalId);
        return denied;
      }

      final head = await headFor(
        contextKind: record.contextKind,
        contextLocalId: record.contextLocalId,
        entityType: record.entityType,
        entityLocalId: record.entityLocalId,
      );

      if (head != null && !_wins(record, head)) {
        // Retain the losing record (so a re-send dedupes and the cursor can
        // advance) but never project it; surface it as a conflict.
        await _isar.changeRecords.put(record);
        _observe(record);
        await _bumpConflict(peerId, record.contextLocalId);
        return ApplyOutcome.losing;
      }

      final applier = applierForEntityType(record.entityType)!;
      if (record.op == 'delete') {
        await applier.delete(_isar, record.entityLocalId);
      } else {
        await applier.upsert(_isar, record.payload);
      }
      await _isar.changeRecords.put(record);
      _observe(record);
      await _advanceReceived(peerId, record);
      return ApplyOutcome.applied;
    });
  }

  /// Runs a terminating snapshot exchange over [connection] (§3).
  ///
  /// The **initiator** sends its snapshot first; the **responder** replies with
  /// its own. Both end when the initiator's `ack` arrives. Returns how many
  /// records this side actually applied.
  Future<int> exchange(
    TransportConnection connection, {
    required int contextLocalId,
    bool initiator = false,
    int? peerId,
  }) async {
    var applied = 0;
    if (initiator) {
      await connection.send(
        _encodeEnvelope(
          'snapshot',
          contextLocalId,
          await recordsForContext(contextLocalId),
        ),
      );
      await for (final message in connection.incoming) {
        final envelope = _decodeEnvelope(message);
        if (envelope.type == 'snapshot') {
          applied += await _applyAll(envelope.records, peerId);
          await connection
              .send(_encodeEnvelope('ack', contextLocalId, const []));
          break;
        }
      }
    } else {
      await for (final message in connection.incoming) {
        final envelope = _decodeEnvelope(message);
        if (envelope.type == 'snapshot') {
          applied += await _applyAll(envelope.records, peerId);
          await connection.send(
            _encodeEnvelope(
              'snapshot',
              contextLocalId,
              await recordsForContext(contextLocalId),
            ),
          );
        } else if (envelope.type == 'ack') {
          break;
        }
      }
    }
    return applied;
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  Future<int> _applyAll(List<ChangeRecord> records, int? peerId) async {
    var applied = 0;
    for (final record in records) {
      if (await applyIncoming(record, peerId: peerId) == ApplyOutcome.applied) {
        applied++;
      }
    }
    return applied;
  }

  /// §4: greater time wins; at equal time a delete beats an upsert; else the
  /// greater `deviceId`.
  bool _wins(ChangeRecord a, ChangeRecord b) {
    if (a.hlcMillis != b.hlcMillis) return a.hlcMillis > b.hlcMillis;
    if (a.hlcCounter != b.hlcCounter) return a.hlcCounter > b.hlcCounter;
    if (a.op != b.op) return a.op == 'delete';
    return a.deviceId.compareTo(b.deviceId) > 0;
  }

  Future<bool> _verify(ChangeRecord record) async {
    final publicKey = _trustedKeys[record.authorIdentityId];
    if (publicKey == null) return false;
    try {
      final signature = Signature(
        base64Decode(record.signature),
        publicKey: publicKey,
      );
      return await _ed25519.verify(
        changeCanonicalBytes(record),
        signature: signature,
      );
    } catch (_) {
      return false;
    }
  }

  /// US4 apply-time authorization (`contracts/role-authorization.md` §3,
  /// FR-008/009/011) — the seam called between signature verification and the
  /// merge (T046/T047).
  ///
  /// The space's memberships are loaded once. A space is **012-managed** (signed
  /// authorization) when at least one membership carries an `authorIdentityId`,
  /// which a legacy/011 row never does — so unmanaged spaces keep their pre-012
  /// behaviour and their tests stay green. In a managed space the author's head
  /// is resolved by identity and the guard decides; a refusal becomes
  /// [ApplyOutcome.droppedUnauthorized]. The month seal is read here so a sealed
  /// month is content-immutable regardless of role (T047).
  Future<ApplyOutcome?> _authorize(ChangeRecord record) async {
    if (record.contextKind != ContextKind.shared) return null;

    final members = await _isar.sharedMembers
        .filter()
        .sharedSpaceIdEqualTo(record.contextLocalId)
        .findAll();
    if (!members.any((m) => m.authorIdentityId != null)) return null;

    SharedMember? head;
    final key = sharedMemberKey(record.authorIdentityId);
    for (final member in members) {
      if (member.profileId == key) {
        head = member;
        break;
      }
    }

    var sealed = false;
    final month = monthKeyOf(record.entityType, record.payload);
    if (month != null) {
      sealed =
          await _isar.monthRateSeals.filter().yearMonthEqualTo(month).count() >
              0;
    }

    try {
      _guard.assertAuthorizedAt(
        record,
        membershipHead: head,
        sealed: sealed,
      );
      return null;
    } on UnauthorizedSpaceAction {
      return ApplyOutcome.droppedUnauthorized;
    }
  }

  Future<bool> _isDuplicate(ChangeRecord record) async {
    final existing = await _isar.changeRecords
        .filter()
        .deviceIdEqualTo(record.deviceId)
        .hlcMillisEqualTo(record.hlcMillis)
        .hlcCounterEqualTo(record.hlcCounter)
        .entityTypeEqualTo(record.entityType)
        .entityLocalIdEqualTo(record.entityLocalId)
        .findFirst();
    return existing != null;
  }

  void _observe(ChangeRecord record) {
    _clock?.observe(
      Hlc(record.hlcMillis, record.hlcCounter, record.deviceId),
    );
  }

  Future<SyncCursor> _cursor(int peerId, int contextLocalId) async {
    final existing = await _isar.syncCursors
        .filter()
        .peerIdEqualTo(peerId)
        .contextLocalIdEqualTo(contextLocalId)
        .findFirst();
    if (existing != null) return existing;
    return SyncCursor()
      ..peerId = peerId
      ..contextLocalId = contextLocalId
      ..updatedAt = DateTime.now();
  }

  Future<void> _advanceReceived(int? peerId, ChangeRecord record) async {
    if (peerId == null) return;
    final cursor = await _cursor(peerId, record.contextLocalId);
    final incoming = Hlc(record.hlcMillis, record.hlcCounter, record.deviceId);
    final current = Hlc(
      cursor.lastReceivedHlcMillis,
      cursor.lastReceivedCounter,
      cursor.lastReceivedDeviceId,
    );
    if (incoming > current) {
      cursor.lastReceivedHlcMillis = record.hlcMillis;
      cursor.lastReceivedCounter = record.hlcCounter;
      cursor.lastReceivedDeviceId = record.deviceId;
    }
    cursor.updatedAt = DateTime.now();
    await _isar.syncCursors.put(cursor);
  }

  Future<void> _bumpConflict(int? peerId, int contextLocalId) async {
    if (peerId == null) return;
    final cursor = await _cursor(peerId, contextLocalId);
    cursor.conflictCount += 1;
    cursor.updatedAt = DateTime.now();
    await _isar.syncCursors.put(cursor);
  }

  // --- envelope wire format --------------------------------------------------

  String _encodeEnvelope(
    String type,
    int contextLocalId,
    List<ChangeRecord> records,
  ) =>
      jsonEncode({
        'type': type,
        'contextLocalId': contextLocalId,
        'records': [for (final record in records) _encodeRecord(record)],
      });

  _Envelope _decodeEnvelope(String message) {
    final json = jsonDecode(message) as Map<String, Object?>;
    final records = (json['records'] as List? ?? const [])
        .cast<Map<Object?, Object?>>()
        .map(_decodeRecord)
        .toList();
    return _Envelope(json['type'] as String, records);
  }

  Map<String, Object?> _encodeRecord(ChangeRecord record) => {
        'contextKind': record.contextKind.name,
        'contextLocalId': record.contextLocalId,
        'entityType': record.entityType,
        'entityLocalId': record.entityLocalId,
        'op': record.op,
        'payload': record.payload,
        'hlcMillis': record.hlcMillis,
        'hlcCounter': record.hlcCounter,
        'deviceId': record.deviceId,
        'authorIdentityId': record.authorIdentityId,
        'signature': record.signature,
      };

  ChangeRecord _decodeRecord(Map<Object?, Object?> json) => ChangeRecord()
    ..contextKind =
        ContextKind.values.firstWhere((e) => e.name == json['contextKind'])
    ..contextLocalId = (json['contextLocalId'] as num).toInt()
    ..entityType = json['entityType'] as String
    ..entityLocalId = (json['entityLocalId'] as num).toInt()
    ..op = json['op'] as String
    ..payload = json['payload'] as String
    ..hlcMillis = (json['hlcMillis'] as num).toInt()
    ..hlcCounter = (json['hlcCounter'] as num).toInt()
    ..deviceId = json['deviceId'] as String
    ..authorIdentityId = json['authorIdentityId'] as String
    ..signature = json['signature'] as String
    ..createdAt = DateTime.fromMillisecondsSinceEpoch(
      (json['hlcMillis'] as num).toInt(),
      isUtc: true,
    );
}

class _Envelope {
  const _Envelope(this.type, this.records);

  final String type;
  final List<ChangeRecord> records;
}
