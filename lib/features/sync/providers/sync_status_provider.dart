import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/change_record.dart';
import '../../../core/models/context_kind.dart';
import '../../../core/models/paired_context.dart';
import '../../../core/models/sync_cursor.dart';
import '../../../core/providers/identity_provider.dart';
import '../domain/hlc.dart';

/// Where a shared space's sync currently stands (FR-013).
enum SyncStatus {
  /// Something this device wrote has not reached every paired peer yet, so the
  /// edits keep queuing offline.
  waitingForPeer,

  /// An exchange for this space is in flight right now. The user-facing label
  /// for this phase is "in progress" (FR-008).
  syncing,

  /// Nothing is pending; the last exchange finished and both sides hold the same
  /// rows.
  converged,
}

/// The status shown next to a shared space: phase, pending work, conflicts.
///
/// A conflict is a losing change (a newer edit superseded it) — it is surfaced
/// here rather than hidden, so the user knows the app made a choice for them
/// (FR-007, FR-013).
class SyncStatusState {
  const SyncStatusState({
    this.pending = 0,
    this.conflictCount = 0,
    this.exchanging = false,
    this.lastSyncedAt,
  });

  /// How many of this device's own changes for the space the peers have not been
  /// handed yet (`SyncStatusFacts.pending`).
  final int pending;

  /// Losing changes the merge kept aside for this space (FR-007).
  final int conflictCount;

  /// True while a snapshot exchange for this space is in flight.
  final bool exchanging;

  /// When the last exchange with a peer finished, if one ever has.
  final DateTime? lastSyncedAt;

  /// The phase, **derived** from the facts above rather than stored beside them.
  ///
  /// Making it a function means the badge can never contradict `pending`: it
  /// cannot read "up to date" while a change is still queued, and cannot nag
  /// "waiting for peer" over a space with nothing to send (FR-008, SC-005).
  SyncStatus get status {
    if (exchanging) return SyncStatus.syncing;
    if (pending > 0) return SyncStatus.waitingForPeer;
    return SyncStatus.converged;
  }

  bool get hasConflicts => conflictCount > 0;

  SyncStatusState copyWith({
    int? pending,
    int? conflictCount,
    bool? exchanging,
    DateTime? lastSyncedAt,
  }) =>
      SyncStatusState(
        pending: pending ?? this.pending,
        conflictCount: conflictCount ?? this.conflictCount,
        exchanging: exchanging ?? this.exchanging,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      );
}

/// What the store itself says about one space, read straight from the persisted
/// `SyncCursor` rows plus the local change-log (data-model §5) — so the badge is
/// still honest after a restart.
class SyncStatusFacts {
  const SyncStatusFacts({
    this.pending = 0,
    this.conflictCount = 0,
    this.lastSyncedAt,
  });

  /// Changes this device authored that no complete round has delivered yet.
  final int pending;

  /// Losing changes recorded on the space's cursors.
  final int conflictCount;

  /// The newest cursor write, i.e. when a peer was last talked to.
  final DateTime? lastSyncedAt;
}

/// Derives [SyncStatusFacts] from the store (research R6).
///
/// A plain class over [Isar] rather than a provider body, so it can be exercised
/// against a real database with no running app; [syncStatusFactsProvider] is the
/// thin Riverpod wrapper around it.
///
/// `pending` counts the records this device authored for the space whose HLC is
/// above the **lowest** `lastSent` watermark across the space's **active** peers:
/// the changes at least one reachable phone has not been handed yet. With no
/// active peer every locally authored record counts, so a space nobody can reach
/// keeps saying "waiting for peer" — which is the truth.
class SyncStatusFactsReader {
  const SyncStatusFactsReader(this._isar);

  final Isar _isar;

  /// Reads the facts for the space whose **local** id is [spaceId].
  ///
  /// [selfIdentityId] is this device's `Identity.fingerprint`. When it is null
  /// (the identity is locked) nothing can be attributed to this device, so
  /// `pending` stays 0 while the conflict total is still reported.
  Future<SyncStatusFacts> read({
    required int spaceId,
    required String? selfIdentityId,
  }) async {
    final contexts = await _isar.pairedContexts
        .filter()
        .contextKindEqualTo(ContextKind.shared)
        .contextLocalIdEqualTo(spaceId)
        .activeEqualTo(true)
        .findAll();
    final activePeers = {for (final context in contexts) context.peerId};

    final cursors = await _isar.syncCursors
        .filter()
        .contextLocalIdEqualTo(spaceId)
        .findAll();

    var conflicts = 0;
    DateTime? lastSyncedAt;
    // The lowest watermark across the peers that can still receive; `null` means
    // no active peer has ever been sent to, which is the same as sending nothing
    // at all — so every locally authored record is still owed.
    Hlc? lowestSent;
    for (final cursor in cursors) {
      conflicts += cursor.conflictCount;
      if (lastSyncedAt == null || cursor.updatedAt.isAfter(lastSyncedAt)) {
        lastSyncedAt = cursor.updatedAt;
      }
      // An unpaired peer can no longer receive anything, so its stale watermark
      // must not keep the space pinned at "waiting for peer" forever (FR-014).
      if (!activePeers.contains(cursor.peerId)) continue;
      final sent = Hlc(
        cursor.lastSentHlcMillis,
        cursor.lastSentCounter,
        cursor.lastSentDeviceId,
      );
      if (lowestSent == null || sent < lowestSent) lowestSent = sent;
    }
    final delivered = lowestSent ?? Hlc.genesis;

    if (selfIdentityId == null) {
      return SyncStatusFacts(
        conflictCount: conflicts,
        lastSyncedAt: lastSyncedAt,
      );
    }

    final records = await _isar.changeRecords
        .filter()
        .contextKindEqualTo(ContextKind.shared)
        .contextLocalIdEqualTo(spaceId)
        .findAll();

    var pending = 0;
    for (final record in records) {
      if (record.authorIdentityId != selfIdentityId) {
        continue; // the peer's own history is not ours to deliver
      }
      final hlc = Hlc(record.hlcMillis, record.hlcCounter, record.deviceId);
      if (hlc > delivered) pending++;
    }

    return SyncStatusFacts(
      pending: pending,
      conflictCount: conflicts,
      lastSyncedAt: lastSyncedAt,
    );
  }
}

/// The persisted facts behind one space's status, keyed by the **local** space id
/// (post-translation) so the key is stable no matter which peer's GUID arrived
/// first (research R6).
///
/// This reads the database, so it is an `AsyncError` whenever Isar is not open
/// (widget tests): callers read it through `valueOrNull` and simply keep the
/// previous state.
final syncStatusFactsProvider =
    FutureProvider.family<SyncStatusFacts, int>((ref, spaceId) async {
  final self = ref.watch(identityProvider).valueOrNull?.fingerprint;
  return SyncStatusFactsReader(IsarHelper.instance)
      .read(spaceId: spaceId, selfIdentityId: self);
});

/// Holds the live status of **one** shared space (FR-013).
///
/// The engine drives the round lifecycle through [roundStarted] /
/// [roundFinished]; the store's own account arrives through [applyFacts]. The
/// phase itself is derived (see [SyncStatusState.status]), so neither caller has
/// to keep the two in step.
class SyncStatusNotifier extends StateNotifier<SyncStatusState> {
  SyncStatusNotifier() : super(const SyncStatusState());

  /// Folds in a fresh read of the persisted facts (a round just ended, or the
  /// change-log moved).
  void applyFacts(SyncStatusFacts facts) {
    state = state.copyWith(
      pending: facts.pending,
      conflictCount: facts.conflictCount,
      lastSyncedAt: facts.lastSyncedAt,
    );
  }

  /// An exchange for this space has started (T051).
  void roundStarted() {
    state = state.copyWith(exchanging: true);
  }

  /// That exchange has ended; the caller refreshes [syncStatusFactsProvider] so
  /// `pending` catches up with what was just delivered (T051).
  void roundFinished() {
    state = state.copyWith(exchanging: false);
  }
}

/// The live sync status of one shared space, keyed by its **local** id so two
/// spaces show two independent badges (research R6).
final syncStatusProvider =
    StateNotifierProvider.family<SyncStatusNotifier, SyncStatusState, int>(
  (ref, spaceId) {
    final notifier = SyncStatusNotifier();

    // Seed from whatever facts are already resolved, then keep up with the store
    // for as long as anyone watches this space.
    final initial = ref.read(syncStatusFactsProvider(spaceId)).valueOrNull;
    if (initial != null) notifier.applyFacts(initial);
    ref.listen(syncStatusFactsProvider(spaceId), (_, next) {
      final facts = next.valueOrNull;
      if (facts != null) notifier.applyFacts(facts);
    });

    return notifier;
  },
);
