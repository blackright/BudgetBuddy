import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where a shared space's sync currently stands (FR-013).
enum SyncStatus {
  /// No reachable paired peer yet; local edits keep queuing offline.
  waitingForPeer,

  /// An exchange is in flight right now.
  syncing,

  /// The last exchange finished; both sides hold the same rows.
  converged,
}

/// The status shown next to a shared space: lifecycle plus conflict count.
///
/// A conflict is a losing change (a newer edit superseded it) — it is surfaced
/// here rather than hidden, so the user knows the app made a choice for them
/// (FR-007, FR-013).
class SyncStatusState {
  const SyncStatusState({
    this.status = SyncStatus.waitingForPeer,
    this.conflictCount = 0,
    this.lastSyncedAt,
  });

  final SyncStatus status;
  final int conflictCount;
  final DateTime? lastSyncedAt;

  bool get hasConflicts => conflictCount > 0;

  SyncStatusState copyWith({
    SyncStatus? status,
    int? conflictCount,
    DateTime? lastSyncedAt,
  }) =>
      SyncStatusState(
        status: status ?? this.status,
        conflictCount: conflictCount ?? this.conflictCount,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      );
}

/// Holds the live sync status for the UI (FR-013). The engine drives it via
/// [waitingForPeer] / [syncing] / [converged]; the chip only reads it.
class SyncStatusNotifier extends StateNotifier<SyncStatusState> {
  SyncStatusNotifier() : super(const SyncStatusState());

  /// No peer is reachable (yet); edits stay queued locally.
  void waitingForPeer() {
    state = state.copyWith(status: SyncStatus.waitingForPeer);
  }

  /// An exchange has started.
  void syncing() {
    state = state.copyWith(status: SyncStatus.syncing);
  }

  /// An exchange completed. [conflicts] replaces the running total when known.
  void converged({int? conflicts, DateTime? at}) {
    state = state.copyWith(
      status: SyncStatus.converged,
      conflictCount: conflicts,
      lastSyncedAt: at,
    );
  }

  /// Adds [count] surfaced conflicts outside a full exchange.
  void noteConflicts(int count) {
    state = state.copyWith(conflictCount: state.conflictCount + count);
  }
}

/// The live sync status for the active shared space (FR-013).
final syncStatusProvider =
    StateNotifierProvider<SyncStatusNotifier, SyncStatusState>(
  (ref) => SyncStatusNotifier(),
);
