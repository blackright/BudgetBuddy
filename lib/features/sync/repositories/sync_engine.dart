import '../../../core/services/audit_verify_service.dart';
import '../domain/codecs/audit_event_codec.dart';
import '../../../core/models/month_end_run.dart';
import '../../../core/models/merchant.dart';
import '../../../core/models/expense_purchase.dart';
import '../../../core/database/schema_migrations.dart';
import '../../../core/services/evidence_privacy.dart';
import '../domain/sync_guid.dart';
import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:isar/isar.dart';

import '../../../core/models/change_record.dart';
import '../../../core/models/context_kind.dart';
import '../../../core/models/month_rate_seal.dart';
import '../../../core/models/paired_context.dart';
import '../../../core/models/paired_peer.dart';
import '../../../core/models/shared_member.dart';
import '../../../core/models/shared_space.dart';
import '../../../core/models/sync_cursor.dart';
import '../../spaces/domain/shared_member_key.dart';
import '../../spaces/repositories/space_role_guard.dart';
import '../domain/change_signing.dart';
import '../domain/codecs/shared_member_codec.dart';
import '../domain/entity_applier.dart';
import '../domain/hlc.dart';
import '../domain/month_key.dart';
import '../domain/sync_codec_registry.dart';
import '../domain/sync_codec.dart';
import '../domain/sync_id_translator.dart';
import '../transport/transport.dart';
import 'sync_recorder.dart';

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

  /// The entity type is not exchanged in v1, or the record is malformed (an
  /// empty `entitySyncGuid`); dropped (a peer stays compatible).
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
/// **Identity (015)**: the wire carries each row's `syncGuid`, never a local
/// `Id` (`contracts/entity-identity.md`). Dedupe, the merge head, and the
/// delete lookup are all keyed by `entitySyncGuid`; the record's `contextLocalId`
/// (a device-local value) is resolved from `contextSyncGuid` on apply so
/// authorization and cursors use **this** device's space id.
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
    String? selfIdentityId,
    SyncRecorder? recorder,
  })  : _trustedKeys = Map.of(trustedKeys),
        _clock = clock,
        _guard = guard,
        _selfIdentityId = selfIdentityId,
        _recorder = recorder,
        _ed25519 = Ed25519();

  final Isar _isar;
  final Map<String, SimplePublicKey> _trustedKeys;
  final HlcClock? _clock;
  final SpaceAccessGuard _guard;

  /// The change recorder, so an outbound snapshot can first journal any row of
  /// the context that never reached the change-log (015 back-fill,
  /// [SyncRecorder.backfillContext]). `null` in tests that send a hand-built
  /// log.
  final SyncRecorder? _recorder;

  /// This device's own identity id, or `null` in tests that want the raw
  /// snapshot. When set, an outgoing snapshot carries only records **this
  /// device authored** (`authorIdentityId == selfIdentityId`), never a record a
  /// peer authored and this device merely re-stored (FR-014, research R4).
  final String? _selfIdentityId;

  final Ed25519 _ed25519;

  /// Dependency order for a snapshot (`data-model` §4 step 2, `contracts/
  /// entity-identity.md` §3): a row is applied **after** everything it can
  /// reference, so an applier's GUID references resolve in one pass. Rows of the
  /// same rank do not reference each other.
  ///
  /// The order follows the reference graph, not the listing order in the design
  /// doc: the medical **directory** (`FamilyMember`/`MedicalProvider`/
  /// `MedicalServiceType`/`InsuranceProfile`) only points at its space, yet a
  /// `MedicalBill` points at those rows *and* at its linked `Expense` — so the
  /// directory must be written before the money, and a bill after both.
  /// (`Reimbursement` points only at its expense; `MedicalBill` points only at
  /// the expense + directory, so the two can share a rank.)
  static const Map<String, int> _dependencyRank = {
    'SharedSpace': 0,
    'SharedMember': 1,
    'MonthlyBudget': 2,
    'BudgetProfile': 3,
    'Merchant': 3,
    'MonthEndRun': 4,
    'FamilyMember': 3,
    'MedicalProvider': 3,
    'MedicalServiceType': 3,
    'InsuranceProfile': 3,
    'Expense': 4,
    'ExpensePurchase': 4,
    'ExpenseEvidenceChunk': 5,
    'Reimbursement': 5,
    'MedicalBill': 5,
  };

  /// Registers/overwrites a trusted author key (after a pairing confirms it).
  void trust(String identityId, SimplePublicKey publicKey) {
    _trustedKeys[identityId] = publicKey;
  }

  /// The records for [contextLocalId] that this device **authored**, in
  /// insertion order — the outbound snapshot (FR-014, research R4).
  ///
  /// A device forwards nothing: it only ever sends what it wrote itself, so two
  /// peers exchange strictly pairwise. When [selfIdentityId] is unset (tests
  /// that build no identity), every record is returned unchanged.
  Future<List<ChangeRecord>> recordsForContext(int contextLocalId) {
    final self = _selfIdentityId;
    final query =
        _isar.changeRecords.filter().contextLocalIdEqualTo(contextLocalId);
    if (self == null) return query.findAll();
    return query.authorIdentityIdEqualTo(self).findAll();
  }

  /// The snapshot this device sends for [contextLocalId]: journal whatever of
  /// it was never recorded (015 back-fill), then the records this device
  /// authored ([recordsForContext]).
  ///
  /// The back-fill is what keeps the apply-time gate honest: rows written while
  /// recording was inert carry no record, so without it the snapshot leaves out
  /// the space and the Owner's own membership — and the peer, holding a managed
  /// space with no head for the batch's author, refuses **every** record as
  /// `droppedUnauthorized` (`applied 0 of N`).
  Future<List<ChangeRecord>> _outboundSnapshot(int contextLocalId) async {
    await _recorder?.backfillContext(contextLocalId);
    final query = _isar.changeRecords
        .filter()
        .contextLocalIdEqualTo(contextLocalId)
        .and()
        .not()
        .entityTypeEqualTo('ExpenseEvidenceChunk');
    return _selfIdentityId == null
        ? query.findAll()
        : query.authorIdentityIdEqualTo(_selfIdentityId!).findAll();
  }

  /// The current winning record for an entity key, or `null` if none exists.
  ///
  /// Keyed by the device-independent `entitySyncGuid` (data-model §4).
  Future<ChangeRecord?> headFor({
    required ContextKind contextKind,
    required int contextLocalId,
    required String entityType,
    required String entitySyncGuid,
  }) async {
    final candidates = await _isar.changeRecords
        .filter()
        .contextKindEqualTo(contextKind)
        .contextLocalIdEqualTo(contextLocalId)
        .entityTypeEqualTo(entityType)
        .entitySyncGuidEqualTo(entitySyncGuid)
        .findAll();
    ChangeRecord? winner;
    for (final candidate in candidates) {
      if (winner == null || _wins(candidate, winner)) winner = candidate;
    }
    return winner;
  }

  /// Verifies, merges and applies one incoming [ChangeRecord] (§3 step 2–3).
  ///
  /// [batchMembers] are the membership heads arriving **in the same snapshot**,
  /// keyed by the member's `profileId`. They let the apply-time gate see the
  /// memberships a snapshot is delivering (see [_batchMembershipHeads]); when
  /// omitted the gate reads only the local table.
  Future<ApplyOutcome> applyIncoming(
    ChangeRecord record, {
    int? peerId,
    Map<int, SharedMember>? batchMembers,
  }) async {
    if (codecForEntityType(record.entityType) == null ||
        applierForEntityType(record.entityType) == null) {
      return ApplyOutcome.droppedUnknownType;
    }
    // A record with no device-independent identity cannot be placed (data-model
    // §7): reject it defensively rather than key it on a foreign local id.
    if (record.entitySyncGuid.isEmpty) return ApplyOutcome.droppedUnknownType;
    if (!await _verify(record)) return ApplyOutcome.droppedBadSignature;
    if (record.entityType == 'AuditEvent') {
      if (record.contextKind != ContextKind.shared ||
          record.contextSyncGuid.isEmpty ||
          record.op == 'delete') {
        return ApplyOutcome.droppedUnauthorized;
      }
      try {
        final event = const AuditEventCodec().fromPayload(record.payload)
          ..sharedSpaceId = record.contextLocalId;
        if (event.contextSyncGuid != record.contextSyncGuid ||
            event.syncGuid != record.entitySyncGuid ||
            event.userIdentity != record.authorIdentityId ||
            (await const AuditVerifyService()
                        .verify([event], trustedKeys: _trustedKeys))
                    .status ==
                AuditStatus.failed ||
            !_trustedKeys.containsKey(event.userIdentity)) {
          return ApplyOutcome.droppedBadSignature;
        }
      } catch (_) {
        return ApplyOutcome.droppedBadSignature;
      }
    }
    if (await _isDuplicate(record)) {
      // A membership this device already holds still has to name the pairing
      // context. The row may have landed before the authoring peer was a contact
      // (or before this device had an identity), and the mirror is what lets an
      // added phone send its own edits back (T067). Idempotent.
      await _mirrorStoredMembership(record);
      return ApplyOutcome.duplicate;
    }

    return _isar.writeTxn(() async {
      // Resolve this device's space id from the signed context GUID (bootstrap
      // on first sight, data-model §4 step 1); legacy/local records already
      // carry a local id and no GUID, so they keep it.
      if (record.contextSyncGuid.isNotEmpty) {
        record.contextLocalId =
            await SyncIdTranslator(_isar).resolveLocalContext(
          record.contextSyncGuid,
        );
      }

      // US4: verify → authorize → merge (role-authorization §3). A refusal is
      // dropped, never silently applied, and never projected.
      //
      // It is deliberately **not** counted as a kept-aside conflict: the
      // coordinator re-offers the same change on every discovery round (a sealed
      // month frozen after the edit, a demoted author's stale change), so a
      // per-attempt +1 snowballed into a nonsense tally ("967 conflicts") while
      // nothing was actually wrong. Only a losing merge — an edit the app chose
      // between — is a conflict, and that branch below is deduplicated so its
      // one conflict is counted exactly once (FR-007, FR-008).
      final denied = await _authorize(record, batchMembers: batchMembers);
      if (denied != null) {
        return denied;
      }

      if (record.entityType == 'ExpenseEvidenceChunk') {
        if (record.op == 'delete' || record.contextKind != ContextKind.shared) {
          return ApplyOutcome.droppedUnauthorized;
        }
        final payload = canonicalJsonDecode(record.payload);
        if (payload['syncGuid'] != record.entitySyncGuid ||
            payload['sharedSpaceSyncGuid'] != record.contextSyncGuid) {
          return ApplyOutcome.droppedUnauthorized;
        }
      }
      if (record.entityType == 'Merchant' ||
          record.entityType == 'ExpensePurchase') {
        final purchase = record.entityType == 'ExpensePurchase'
            ? await _isar.expensePurchases
                .filter()
                .syncGuidEqualTo(record.entitySyncGuid)
                .findFirst()
            : null;
        final merchant = record.entityType == 'Merchant'
            ? await _isar.merchants
                .filter()
                .syncGuidEqualTo(record.entitySyncGuid)
                .findFirst()
            : null;
        final existingSpace =
            purchase?.sharedSpaceId ?? merchant?.sharedSpaceId;
        if (record.contextKind != ContextKind.shared ||
            record.contextSyncGuid.isEmpty ||
            ((purchase != null || merchant != null) &&
                existingSpace != record.contextLocalId)) {
          return ApplyOutcome.droppedUnauthorized;
        }
        if (record.op != 'delete') {
          final payload = canonicalJsonDecode(record.payload);
          if (payload['syncGuid'] != record.entitySyncGuid ||
              payload['sharedSpaceSyncGuid'] != record.contextSyncGuid) {
            return ApplyOutcome.droppedUnauthorized;
          }
        }
      }

      if (record.entityType == 'MonthEndRun') {
        if (record.op == 'delete') return ApplyOutcome.droppedUnauthorized;
        final payload = canonicalJsonDecode(record.payload);
        if (payload['sharedSpaceSyncGuid'] != record.contextSyncGuid ||
            payload['syncGuid'] != record.entitySyncGuid ||
            payload['actor'] != record.authorIdentityId) {
          return ApplyOutcome.droppedUnauthorized;
        }
      }
      final head = await headFor(
        contextKind: record.contextKind,
        contextLocalId: record.contextLocalId,
        entityType: record.entityType,
        entitySyncGuid: record.entitySyncGuid,
      );

      if (record.entityType == 'AuditEvent' &&
          head != null &&
          record.payload != head.payload) {
        return ApplyOutcome.droppedUnauthorized;
      }
      if (head != null && !_wins(record, head)) {
        // Retain the losing record (so a re-send dedupes and the cursor can
        // advance) but never project it; surface it as a conflict.
        if (record.entityType == 'MonthEndRun' && record.op != 'delete') {
          final run = await _isar.monthEndRuns
              .filter()
              .syncGuidEqualTo(record.entitySyncGuid)
              .findFirst();
          if (run != null &&
              canonicalJsonDecode(record.payload)['fingerprint'] !=
                  run.fingerprint) {
            run.hasConflict = true;
            await _isar.monthEndRuns.put(run);
          }
        }
        await _isar.changeRecords.put(record);
        _observe(record);
        await _bumpConflict(peerId, record.contextLocalId);
        return ApplyOutcome.losing;
      }

      final applier = applierForEntityType(record.entityType)!;
      if (record.op == 'delete') {
        // Tombstones are keyed by GUID: resolve the local row, then remove it.
        final localId = await SyncIdTranslator(_isar)
            .resolveLocalEntity(record.entityType, record.entitySyncGuid);
        if (localId != null) await applier.delete(_isar, localId);
      } else {
        await applier.upsert(_isar, record.payload);
      }
      // T067: a membership that makes **this device** a member flips it from mute
      // to two-way — mirror the pairing context for the authoring peer so this
      // phone records and sends its own edits back.
      if (record.entityType == 'SharedMember' && record.op != 'delete') {
        await _mirrorContextIfSelfAdded(record);
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
    void Function(int spaceId)? onRoundStart,
    void Function(int spaceId)? onRoundEnd,
  }) async {
    var applied = 0;
    final evidenceReceipt = _EvidenceReceipt();
    if (initiator) {
      onRoundStart?.call(contextLocalId);
      try {
        final outbound = await _outboundSnapshot(contextLocalId);
        final transfer =
            await _sendSnapshot(connection, contextLocalId, outbound, peerId);
        var acknowledged = false;
        await for (final message in connection.incoming) {
          final envelope = await _decodeEnvelope(message);
          final evidenceApplied =
              await _consumeEvidence(envelope, peerId, evidenceReceipt);
          if (evidenceApplied != null) {
            applied += evidenceApplied;
            continue;
          }
          if (envelope.type == 'snapshot') {
            applied += await _applyAll(envelope.records, peerId);
            await _ackEvidence(transfer, envelope.evidenceAck, peerId);
            await connection.send(
              _encodeEnvelope(
                'ack',
                await _contextSyncGuid(contextLocalId),
                const [],
                evidenceAck: evidenceReceipt.acknowledge(envelope),
              ),
            );
            // Their snapshot only leaves after ours was processed, so a reply
            // is the delivery signal the send-side watermark may record (§7).
            acknowledged = true;
            break;
          }
        }
        if (acknowledged) {
          await _advanceSent(peerId, contextLocalId, outbound);
        }
      } finally {
        onRoundEnd?.call(contextLocalId);
      }
    } else {
      final active = <int>[];
      int? sentContext;
      List<ChangeRecord>? sentRecords;
      _EvidenceTransfer? transfer;
      try {
        await for (final message in connection.incoming) {
          final envelope = await _decodeEnvelope(message);
          final evidenceApplied =
              await _consumeEvidence(envelope, peerId, evidenceReceipt);
          if (evidenceApplied != null) {
            applied += evidenceApplied;
            continue;
          }
          if (envelope.type == 'snapshot') {
            applied += await _applyAll(envelope.records, peerId);
            // T069: same guard as [respond] — a dialed peer cannot plant a space
            // this device is not a member of.
            await _discardNonMemberContexts(envelope.records);
            final replyContext =
                await _localContextFor(envelope, contextLocalId);
            onRoundStart?.call(replyContext);
            active.add(replyContext);
            sentContext = replyContext;
            sentRecords = await _outboundSnapshot(replyContext);
            transfer = await _sendSnapshot(
                connection, replyContext, sentRecords, peerId,
                evidenceAck: evidenceReceipt.acknowledge(envelope));
          } else if (envelope.type == 'ack') {
            await _ackEvidence(transfer, envelope.evidenceAck, peerId);
            // The peer's ack is the delivery signal for the snapshot above.
            if (sentRecords != null) {
              await _advanceSent(peerId, sentContext!, sentRecords);
            }
            break;
          }
        }
      } finally {
        for (final spaceId in active) {
          onRoundEnd?.call(spaceId);
        }
      }
    }
    return applied;
  }

  /// Responds to one snapshot without knowing the context up front (§3):
  /// resolves the incoming `contextSyncGuid` to a local context, applies it, and
  /// replies with this device's records for that context. Used by the running
  /// coordinator (2g) where the responder is not the caller.
  Future<int> respond(
    TransportConnection connection, {
    int? peerId,
    void Function(int spaceId)? onRoundStart,
    void Function(int spaceId)? onRoundEnd,
  }) async {
    var applied = 0;
    final active = <int>[];
    int? sentContext;
    List<ChangeRecord>? sentRecords;
    final evidenceReceipt = _EvidenceReceipt();
    _EvidenceTransfer? transfer;
    try {
      await for (final message in connection.incoming) {
        final envelope = await _decodeEnvelope(message);
        final evidenceApplied =
            await _consumeEvidence(envelope, peerId, evidenceReceipt);
        if (evidenceApplied != null) {
          applied += evidenceApplied;
          continue;
        }
        if (envelope.type == 'snapshot') {
          final localContextId = envelope.contextSyncGuid.isEmpty
              ? 0
              : await _isar.writeTxn(() => SyncIdTranslator(_isar)
                  .resolveLocalContext(envelope.contextSyncGuid));
          // FR-010: a context this device has left or unpaired is not accepted —
          // apply nothing and send nothing back. Returning ends the round; the
          // coordinator closes the connection.
          if (!await _contextAccepted(peerId, localContextId)) {
            return applied;
          }
          applied += await _applyAll(envelope.records, peerId);
          // T069: never let a peer leave behind a space this device was not added to.
          // Keyed off the applied records' contexts, not the envelope's GUID, so a
          // peer cannot dodge the guard by sending an empty envelope GUID.
          await _discardNonMemberContexts(envelope.records);
          onRoundStart?.call(localContextId);
          active.add(localContextId);
          sentContext = localContextId;
          sentRecords = await _outboundSnapshot(localContextId);
          transfer = await _sendSnapshot(
              connection, localContextId, sentRecords, peerId,
              evidenceAck: evidenceReceipt.acknowledge(envelope));
        } else if (envelope.type == 'ack') {
          await _ackEvidence(transfer, envelope.evidenceAck, peerId);
          // The peer's ack is the delivery signal for the snapshot above.
          if (sentRecords != null) {
            await _advanceSent(peerId, sentContext!, sentRecords);
          }
          break;
        }
      }
    } finally {
      for (final spaceId in active) {
        onRoundEnd?.call(spaceId);
      }
    }
    return applied;
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  /// Financial snapshots retain the existing protocol. Document bytes travel
  /// in separate bounded messages; old peers ignore these extension messages.
  Future<_EvidenceTransfer?> _sendSnapshot(TransportConnection connection,
      int contextId, List<ChangeRecord> financial, int? peerId,
      {String? evidenceAck}) async {
    final contextGuid = await _contextSyncGuid(contextId);
    final stampKey =
        'evidence:sent:$peerId:${_selfIdentityId ?? 'local'}:$contextGuid';
    var watermark = Hlc.genesis;
    if (peerId != null) {
      final stamp = await _isar.schemaMigrationStamps
          .filter()
          .keyEqualTo(stampKey)
          .findFirst();
      if (stamp != null) {
        try {
          final value = jsonDecode(stamp.value) as List;
          watermark = Hlc(value[0] as int, value[1] as int, value[2] as String);
        } catch (_) {
          /* Unknown/corrupt acknowledgement safely resends files. */
        }
      }
    }
    var query = _isar.changeRecords
        .filter()
        .contextLocalIdEqualTo(contextId)
        .entityTypeEqualTo('ExpenseEvidenceChunk')
        .hlcMillisGreaterThan(watermark.millis, include: true);
    if (_selfIdentityId != null) {
      query = query.authorIdentityIdEqualTo(_selfIdentityId!);
    }
    String? round;
    var head = watermark;
    var offset = 0;
    while (true) {
      final batch = await query
          .sortByHlcMillis()
          .thenByHlcCounter()
          .thenByDeviceId()
          .offset(offset)
          .limit(16)
          .findAll();
      if (batch.isEmpty) break;
      for (final record in batch) {
        final clock = Hlc(record.hlcMillis, record.hlcCounter, record.deviceId);
        if (clock <= watermark) continue;
        if (round == null) {
          round = newSyncGuid();
          await connection
              .send(_encodeEnvelope('evidence-base', contextGuid, financial));
        }
        await connection
            .send(_encodeEnvelope('evidence-chunk', contextGuid, [record]));
        if (clock > head) head = clock;
      }
      offset += batch.length;
    }
    await connection.send(_encodeEnvelope('snapshot', contextGuid, financial,
        evidenceRound: round, evidenceAck: evidenceAck));
    return round == null ? null : _EvidenceTransfer(round, stampKey, head);
  }

  Future<void> _ackEvidence(
      _EvidenceTransfer? transfer, String? ack, int? peerId) async {
    if (transfer == null || transfer.token != ack || peerId == null) return;
    await _isar.writeTxn(() async {
      final stamp = await _isar.schemaMigrationStamps
          .filter()
          .keyEqualTo(transfer.key)
          .findFirst();
      if (stamp != null) {
        try {
          final value = jsonDecode(stamp.value) as List;
          if (Hlc(value[0] as int, value[1] as int, value[2] as String) >
              transfer.head) {
            return;
          }
        } catch (_) {
          /* Replace malformed acknowledgement with a verified one. */
        }
      }
      await _isar.schemaMigrationStamps.put((stamp ?? SchemaMigrationStamp())
        ..key = transfer.key
        ..value = jsonEncode([
          transfer.head.millis,
          transfer.head.counter,
          transfer.head.deviceId
        ]));
    });
  }

  Future<int?> _consumeEvidence(
      _Envelope envelope, int? peerId, _EvidenceReceipt receipt) async {
    if (envelope.type == 'evidence-base') {
      receipt.context = envelope.contextSyncGuid;
      receipt.started = true;
      receipt.valid = false;
      if (envelope.contextSyncGuid.isEmpty ||
          envelope.records.any((r) => r.entityType == 'ExpenseEvidenceChunk')) {
        return 0;
      }
      final context = await _isar.writeTxn(() => SyncIdTranslator(_isar)
          .resolveLocalContext(envelope.contextSyncGuid));
      if (!await _contextAccepted(peerId, context)) return 0;
      final applied = await _applyAll(envelope.records, peerId);
      await _discardNonMemberContexts(envelope.records);
      receipt.valid = await _isar.sharedSpaces.get(context) != null;
      return applied;
    }
    if (envelope.type != 'evidence-chunk') return null;
    if (!receipt.started ||
        !receipt.valid ||
        receipt.context != envelope.contextSyncGuid ||
        envelope.records.length != 1 ||
        envelope.records.single.entityType != 'ExpenseEvidenceChunk') {
      receipt.valid = false;
      return 0;
    }
    final record = envelope.records.single;
    if (record.contextSyncGuid != receipt.context) {
      receipt.valid = false;
      return 0;
    }
    final outcome = await applyIncoming(record, peerId: peerId);
    if (outcome != ApplyOutcome.applied && outcome != ApplyOutcome.duplicate) {
      receipt.valid = false;
    }
    return outcome == ApplyOutcome.applied ? 1 : 0;
  }

  Future<int> _applyAll(List<ChangeRecord> records, int? peerId) async {
    // Sort by dependency rank, keeping the original order within a rank so the
    // apply is deterministic (List.sort is not stable).
    final indexed = records.asMap().entries.toList()
      ..sort((a, b) {
        final rank = _rankOf(a.value).compareTo(_rankOf(b.value));
        return rank != 0 ? rank : a.key.compareTo(b.key);
      });
    // The memberships that grant apply-time authority arrive in this same batch,
    // so resolve them up front and hand them to the gate (T-fix, 015).
    final batchMembers = await _batchMembershipHeads(records);
    var applied = 0;
    for (final entry in indexed) {
      final outcome = await applyIncoming(
        entry.value,
        peerId: peerId,
        batchMembers: batchMembers,
      );
      if (outcome == ApplyOutcome.applied) {
        applied++;
      }
    }
    return applied;
  }

  int _rankOf(ChangeRecord record) => _dependencyRank[record.entityType] ?? 9;

  /// The membership heads a snapshot carries **in its own batch**, keyed by the
  /// member's `profileId` — the same key [_authorize] uses to resolve an author.
  ///
  /// A snapshot delivers the memberships that grant the authority the gate
  /// checks, so the gate must be able to see them ([_authorize]). Only signature-
  /// verified upserts are included, so a forged row cannot grant authority; the
  /// winning row for a member re-sent at several versions is chosen by [_wins].
  Future<Map<int, SharedMember>> _batchMembershipHeads(
    List<ChangeRecord> records,
  ) async {
    final heads = <int, (ChangeRecord, SharedMember)>{};
    for (final record in records) {
      if (record.entityType != 'SharedMember' || record.op == 'delete') {
        continue;
      }
      if (!await _verify(record)) continue;
      final SharedMember member;
      try {
        member = const SharedMemberCodec().fromPayload(record.payload);
      } on Object {
        continue; // a malformed payload is dropped by the applier anyway
      }
      final existing = heads[member.profileId];
      if (existing == null || _wins(record, existing.$1)) {
        heads[member.profileId] = (record, member);
      }
    }
    return {for (final entry in heads.entries) entry.key: entry.value.$2};
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
  /// The space's memberships are loaded once for the **local** space id (already
  /// resolved from `contextSyncGuid`), so the gate fires for a remapped context.
  /// A space is **012-managed** (signed authorization) when at least one
  /// membership carries an `authorIdentityId`, which a legacy/011 row never does
  /// — so unmanaged spaces keep their pre-012 behaviour. In a managed space the
  /// author's head is resolved by identity and the guard decides; a refusal
  /// becomes [ApplyOutcome.droppedUnauthorized]. The month seal is read here so a
  /// sealed month is content-immutable regardless of role (T047).
  ///
  /// The head is resolved from the local table first and then from
  /// [batchMembers] — the memberships arriving in this very snapshot. A snapshot
  /// delivers the memberships that **grant** the authority being checked, so a
  /// gate that read only the local table deadlocked: the first row to land
  /// flipped the space to managed and every other author, the Owner included,
  /// was refused on every retry, forever. A **local** head always wins, so the
  /// batch can never *upgrade* a role an author already holds locally.
  Future<ApplyOutcome?> _authorize(
    ChangeRecord record, {
    Map<int, SharedMember>? batchMembers,
  }) async {
    if (record.contextKind != ContextKind.shared) return null;

    final members = await _isar.sharedMembers
        .filter()
        .sharedSpaceIdEqualTo(record.contextLocalId)
        .findAll();
    if (!members.any((m) => m.authorIdentityId != null) &&
        record.entityType != 'MonthEndRun' &&
        record.entityType != 'AuditEvent' &&
        record.entityType != 'Merchant' &&
        record.entityType != 'ExpenseEvidenceChunk' &&
        record.entityType != 'ExpensePurchase') {
      return null;
    }

    SharedMember? head;
    final key = sharedMemberKey(record.authorIdentityId);
    for (final member in members) {
      if (member.profileId == key) {
        head = member;
        break;
      }
    }
    head ??= batchMembers?[key];

    var sealed = false;
    // Delivering already-declared immutable file bytes does not edit a sealed
    // financial month. The applier still requires its expense/history manifest.
    final month = record.entityType == 'ExpenseEvidenceChunk'
        ? null
        : record.entityType == 'ExpensePurchase' && record.op == 'delete'
            ? (await _isar.expensePurchases
                    .filter()
                    .syncGuidEqualTo(record.entitySyncGuid)
                    .findFirst())
                ?.yearMonth
            : monthKeyOf(record.entityType, record.payload);
    if (month != null) {
      sealed =
          await _isar.monthRateSeals.filter().yearMonthEqualTo(month).count() >
              0;
    }

    if (record.entityType == 'AuditEvent') {
      try {
        final type =
            const AuditEventCodec().fromPayload(record.payload).objectType;
        if (!_guard.canAuthor(head, type)) {
          return ApplyOutcome.droppedUnauthorized;
        }
      } catch (_) {
        return ApplyOutcome.droppedUnauthorized;
      }
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
        .entitySyncGuidEqualTo(record.entitySyncGuid)
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

  /// Advances the **send-side** watermark for `(peerId, contextLocalId)` to the
  /// highest HLC in [records] — the snapshot this device just handed the peer
  /// (T030, research R6).
  ///
  /// `lastSent*` is what the per-space status derives "nothing pending" from: a
  /// locally authored record above this watermark has not reached that peer yet.
  /// Called only once the peer has answered, so a dropped connection leaves the
  /// watermark where it was and the space keeps reporting "waiting for peer"
  /// (SC-005).
  Future<void> _advanceSent(
    int? peerId,
    int contextLocalId,
    List<ChangeRecord> records,
  ) async {
    if (peerId == null || records.isEmpty) return;
    var head = Hlc.genesis;
    for (final record in records) {
      final hlc = Hlc(record.hlcMillis, record.hlcCounter, record.deviceId);
      if (hlc > head) head = hlc;
    }
    if (head.isGenesis) return;
    await _isar.writeTxn(() async {
      final cursor = await _cursor(peerId, contextLocalId);
      final current = Hlc(
        cursor.lastSentHlcMillis,
        cursor.lastSentCounter,
        cursor.lastSentDeviceId,
      );
      if (head > current) {
        cursor.lastSentHlcMillis = head.millis;
        cursor.lastSentCounter = head.counter;
        cursor.lastSentDeviceId = head.deviceId;
      }
      cursor.updatedAt = DateTime.now();
      await _isar.syncCursors.put(cursor);
    });
  }

  Future<void> _bumpConflict(int? peerId, int contextLocalId) async {
    if (peerId == null) return;
    final cursor = await _cursor(peerId, contextLocalId);
    cursor.conflictCount += 1;
    cursor.updatedAt = DateTime.now();
    await _isar.syncCursors.put(cursor);
  }

  /// Runs the [T067] context mirror for a membership this device **already
  /// stored** (an idempotent [ApplyOutcome.duplicate]). Without this an added
  /// phone whose own membership landed before the authoring peer was a contact
  /// would stay mute — `_activeSharedContexts` never offered the space — even
  /// though the membership row is present. Opens its own transaction because it
  /// runs before `applyIncoming`'s.
  Future<void> _mirrorStoredMembership(ChangeRecord record) async {
    if (record.entityType != 'SharedMember' || record.op == 'delete') return;
    if (record.contextKind != ContextKind.shared) return;
    await _isar.writeTxn(() => _mirrorContextIfSelfAdded(record));
  }

  /// T067: the joining phone mirrors the [PairedContext] so it can send too.
  ///
  /// When an applied [SharedMember] row is **this device's own** membership (its
  /// `profileId` is this identity's shared key), the authoring peer becomes this
  /// phone's sync partner for the space. Without this the added phone only ever
  /// receives: `respond`/`exchange` created the context on the *adding* side, so
  /// `_activeSharedContexts` never offered the space here and every local edit
  /// was dropped for want of a context. Runs inside the apply transaction; the
  /// received-record cursor is already advanced by [_advanceReceived].
  Future<void> _mirrorContextIfSelfAdded(ChangeRecord record) async {
    final self = _selfIdentityId;
    if (self == null) return;
    final member = await _isar.sharedMembers
        .filter()
        .syncGuidEqualTo(record.entitySyncGuid)
        .findFirst();
    if (member == null) return;
    // Only my own membership flips me from mute to two-way.
    if (member.profileId != sharedMemberKey(self)) return;
    final peer = await _isar.pairedPeers
        .filter()
        .peerIdentityIdEqualTo(record.authorIdentityId)
        .findFirst();
    if (peer == null) return; // the author is not a contact; nothing to send to

    final spaceId = member.sharedSpaceId;
    final existing = await _isar.pairedContexts
        .filter()
        .peerIdEqualTo(peer.id)
        .contextKindEqualTo(ContextKind.shared)
        .contextLocalIdEqualTo(spaceId)
        .findFirst();
    final context = existing ??
        (PairedContext()
          ..peerId = peer.id
          ..contextKind = ContextKind.shared
          ..contextLocalId = spaceId
          ..pairedAt = record.createdAt);
    // `peerRole` is only a local cache of the author's role (the signed
    // [SharedMember] history is authoritative); default to Owner when the
    // author's own membership has not been applied yet in this batch.
    final authorHead = await _isar.sharedMembers
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .profileIdEqualTo(sharedMemberKey(record.authorIdentityId))
        .findFirst();
    context
      ..peerRole = authorHead?.role ?? SharedMemberRole.owner
      ..active = true;
    await _isar.pairedContexts.put(context);
  }

  /// T069: discard every space the last snapshot touched that this device is not
  /// a member of. Runs after [_applyAll], so each record's `contextLocalId` has
  /// been resolved from its signed `contextSyncGuid`.
  Future<void> _discardNonMemberContexts(List<ChangeRecord> records) async {
    final seen = <int>{};
    for (final record in records) {
      if (record.contextKind != ContextKind.shared) continue;
      final spaceId = record.contextLocalId;
      if (spaceId == 0 || !seen.add(spaceId)) continue;
      await _discardIfNotMember(spaceId);
    }
  }

  /// The per-space worker for [T069]: a snapshot must not leave behind a space
  /// this device is not a member of.
  ///
  /// A paired peer names an arbitrary `contextSyncGuid`; `resolveLocalContext`
  /// bootstraps a local space for it, and without this guard the peer could
  /// plant spaces — and membership rows granting themselves a role — on a phone
  /// that was never added to them. Money rows are already unreachable (every
  /// money read is scoped to a space the caller belongs to), so discarding the
  /// space and its membership rows neutralises the injection. A space this
  /// device has a **membership** in, or a deliberately-created **paired
  /// context** for, is genuine and kept. No-op when this device has no identity.
  Future<void> _discardIfNotMember(int spaceId) async {
    final self = _selfIdentityId;
    if (spaceId == 0 || self == null) return;
    final mine = await _isar.sharedMembers
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .profileIdEqualTo(sharedMemberKey(self))
        .findFirst();
    if (mine != null) return; // a space I genuinely belong to; keep it
    final shared = await _isar.pairedContexts
        .filter()
        .contextKindEqualTo(ContextKind.shared)
        .contextLocalIdEqualTo(spaceId)
        .findFirst();
    if (shared != null) return; // a context I deliberately share; keep it
    await _isar.writeTxn(() async {
      final members = await _isar.sharedMembers
          .filter()
          .sharedSpaceIdEqualTo(spaceId)
          .findAll();
      for (final member in members) {
        await _isar.sharedMembers.delete(member.id);
      }
      await purgeSpaceEvidenceInTxn(_isar, spaceId);
      await _isar.sharedSpaces.delete(spaceId);
    });
  }

  /// FR-010 (stop-delivery): a context this device has left or unpaired must not
  /// be accepted. An existing `PairedContext` that is **inactive** means the space
  /// is no longer shared with this peer, so the snapshot is refused — nothing is
  /// applied and nothing is sent back.
  ///
  /// A context with **no** local pairing row is a first-sight bootstrap and is
  /// allowed; the membership guard ([_discardIfNotMember]) still neutralises
  /// anything injected. A null [peerId] (an unknown peer) is refused elsewhere.
  Future<bool> _contextAccepted(int? peerId, int localContextId) async {
    if (peerId == null || localContextId == 0) return true;
    final context = await _isar.pairedContexts
        .filter()
        .peerIdEqualTo(peerId)
        .contextKindEqualTo(ContextKind.shared)
        .contextLocalIdEqualTo(localContextId)
        .findFirst();
    return context == null || context.active;
  }

  /// The `syncGuid` of the space that a local [contextLocalId] names, or `''`
  /// when the space row is not present yet.
  Future<String> _contextSyncGuid(int contextLocalId) async {
    final space = await _isar.sharedSpaces.get(contextLocalId);
    return space?.syncGuid ?? '';
  }

  /// The local context an incoming snapshot should be answered for: the resolved
  /// local id of its `contextSyncGuid`, falling back to [fallback] when the
  /// envelope predates GUID contexts. Runs in its own write transaction because a
  /// first-sight context bootstraps a local space (data-model §4 step 1) and this
  /// path is outside `applyIncoming`'s transaction.
  Future<int> _localContextFor(_Envelope envelope, int fallback) async {
    if (envelope.contextSyncGuid.isEmpty) return fallback;
    return _isar.writeTxn(() =>
        SyncIdTranslator(_isar).resolveLocalContext(envelope.contextSyncGuid));
  }

  // --- envelope wire format --------------------------------------------------

  String _encodeEnvelope(
          String type, String contextSyncGuid, List<ChangeRecord> records,
          {String? evidenceRound, String? evidenceAck}) =>
      jsonEncode({
        'type': type,
        'contextSyncGuid': contextSyncGuid,
        'records': [for (final record in records) _encodeRecord(record)],
        if (evidenceRound != null) 'evidenceRound': evidenceRound,
        if (evidenceAck != null) 'evidenceAck': evidenceAck,
      });

  Future<_Envelope> _decodeEnvelope(String message) async {
    final json = jsonDecode(message) as Map<String, Object?>;
    final records = (json['records'] as List? ?? const [])
        .cast<Map<Object?, Object?>>()
        .map(_decodeRecord)
        .toList();
    return _Envelope(
      json['type'] as String,
      (json['contextSyncGuid'] as String?) ?? '',
      records,
      evidenceRound: json['evidenceRound'] is String
          ? json['evidenceRound'] as String
          : null,
      evidenceAck:
          json['evidenceAck'] is String ? json['evidenceAck'] as String : null,
    );
  }

  Map<String, Object?> _encodeRecord(ChangeRecord record) => {
        'contextKind': record.contextKind.name,
        'contextSyncGuid': record.contextSyncGuid,
        'entityType': record.entityType,
        'entitySyncGuid': record.entitySyncGuid,
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
    ..contextSyncGuid = (json['contextSyncGuid'] as String?) ?? ''
    // `contextLocalId` / `entityLocalId` are device-local bookkeeping and never
    // travel on the wire, but they are still `late` fields Isar serializes, so
    // they must be initialized here (0) and stamped at apply time.
    ..contextLocalId = 0
    ..entityType = json['entityType'] as String
    ..entitySyncGuid = (json['entitySyncGuid'] as String?) ?? ''
    ..entityLocalId = 0
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
  const _Envelope(this.type, this.contextSyncGuid, this.records,
      {this.evidenceRound, this.evidenceAck});

  final String type;
  final String contextSyncGuid;
  final List<ChangeRecord> records;
  final String? evidenceRound, evidenceAck;
}

class _EvidenceTransfer {
  const _EvidenceTransfer(this.token, this.key, this.head);
  final String token, key;
  final Hlc head;
}

class _EvidenceReceipt {
  bool started = false, valid = false;
  String context = '';
  String? acknowledge(_Envelope envelope) =>
      started && valid && context == envelope.contextSyncGuid
          ? envelope.evidenceRound
          : null;
}
