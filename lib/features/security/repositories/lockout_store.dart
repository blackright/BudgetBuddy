import 'dart:convert';

import '../../identity/repositories/secret_store.dart';
import '../domain/lock_secret_keys.dart';
import '../domain/lockout_schedule.dart';

/// One subject's persisted lockout (FR-013, FR-014, FR-046).
///
/// The **only** security state that survives a restart, and the minimum of it:
/// a consecutive-failure count and the current wait, nothing else. No event log,
/// no per-attempt timestamps, no history (FR-046).
class LockoutRecord {
  const LockoutRecord({
    required this.version,
    required this.failCount,
    required this.waitMs,
    required this.appliedAtElapsedMs,
    this.appliedAtUtc,
  });

  static const int currentVersion = 1;

  final int version;
  final int failCount;

  /// The wait owed once [appliedAtElapsedMs] is reached, in milliseconds.
  final int waitMs;

  /// The monotonic reading when the wait started. This is the value that lets a
  /// reboot be recognised: a *smaller* reading later cannot be this process's
  /// clock running, so the wait is re-imposed in full (research R3).
  final int appliedAtElapsedMs;

  /// The same moment on the wall clock. Display only — never used to time the
  /// wait, so moving the clock cannot shorten it.
  final String? appliedAtUtc;

  Map<String, Object?> toJson() => {
        'v': version,
        'failCount': failCount,
        'waitMs': waitMs,
        'appliedAtElapsedMs': appliedAtElapsedMs,
        'appliedAtUtc': appliedAtUtc,
      };

  static LockoutRecord? tryParse(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final version = decoded['v'];
      final failCount = decoded['failCount'];
      final waitMs = decoded['waitMs'];
      final appliedAtElapsedMs = decoded['appliedAtElapsedMs'];
      if (version is! int ||
          failCount is! int ||
          waitMs is! int ||
          appliedAtElapsedMs is! int) {
        return null;
      }
      final appliedAtUtc = decoded['appliedAtUtc'];
      return LockoutRecord(
        version: version,
        failCount: failCount,
        waitMs: waitMs,
        appliedAtElapsedMs: appliedAtElapsedMs,
        appliedAtUtc: appliedAtUtc is String ? appliedAtUtc : null,
      );
    } on Object {
      return null;
    }
  }

  /// The same record with its baseline moved to [nowMs], used when a reboot is
  /// detected so the wait runs in full from that moment.
  LockoutRecord rebased(int nowMs) => LockoutRecord(
        version: version,
        failCount: failCount,
        waitMs: waitMs,
        appliedAtElapsedMs: nowMs,
        appliedAtUtc: appliedAtUtc,
      );
}

/// A subject's lockout as the UI needs it: how many failures, and how long
/// until the next attempt is allowed.
class LockoutStatus {
  const LockoutStatus({required this.failCount, required this.remaining});

  final int failCount;
  final Duration remaining;

  bool get isWaiting => remaining > Duration.zero;
}

/// The persisted lockout, read and written through the [SecretStore] only
/// (FR-008, FR-014).
///
/// The seam takes `nowMs` explicitly. That is not a test convenience: it is the
/// whole argument of FR-015, because it makes the wall clock unreachable from
/// this class. The only clock it consults is the monotonic one the caller
/// passes, and a *smaller* reading than the stored baseline is treated as a
/// reboot and re-imposes the wait in full — the safe direction.
class LockoutStore {
  const LockoutStore(this._secrets);

  final SecretStore _secrets;

  /// The consecutive-failure count, or `0` when nothing is recorded.
  Future<int> failCount(String subjectKey) async =>
      (await _read(subjectKey))?.failCount ?? 0;

  /// The subject's lockout at [nowMs], rebasing the baseline if a reboot is
  /// detected.
  Future<LockoutStatus> status(String subjectKey, {required int nowMs}) async {
    final record = await _read(subjectKey);
    if (record == null) {
      return const LockoutStatus(failCount: 0, remaining: Duration.zero);
    }
    return _resolve(subjectKey, record, nowMs);
  }

  /// Records one more failure and returns the lockout that follows (FR-013).
  Future<LockoutStatus> registerFailure(
    String subjectKey, {
    required int nowMs,
    DateTime? nowUtc,
  }) async {
    final previous = await _read(subjectKey);
    final failCount = (previous?.failCount ?? 0) + 1;
    final waitMs = LockoutSchedule.waitFor(failCount).inMilliseconds;
    final record = LockoutRecord(
      version: LockoutRecord.currentVersion,
      failCount: failCount,
      waitMs: waitMs,
      appliedAtElapsedMs: nowMs,
      appliedAtUtc: (nowUtc ?? DateTime.now()).toIso8601String(),
    );
    await _write(subjectKey, record);
    return LockoutStatus(
      failCount: failCount,
      remaining: Duration(milliseconds: waitMs),
    );
  }

  /// Clears the record entirely — what a correct PIN does (FR-011).
  Future<void> clear(String subjectKey) =>
      _secrets.delete(LockSecretKeys.lockout(subjectKey));

  Future<LockoutStatus> _resolve(
    String subjectKey,
    LockoutRecord record,
    int nowMs,
  ) async {
    if (record.waitMs <= 0) {
      return LockoutStatus(
          failCount: record.failCount, remaining: Duration.zero);
    }

    if (nowMs < record.appliedAtElapsedMs) {
      // The monotonic reading cannot go backwards while the process lives, so
      // this is a reboot. The elapsed part of the wait is unknown, so it is
      // re-imposed in full from now (contracts §5), never shortened.
      await _write(subjectKey, record.rebased(nowMs));
      return LockoutStatus(
        failCount: record.failCount,
        remaining: Duration(milliseconds: record.waitMs),
      );
    }

    final left = record.waitMs - (nowMs - record.appliedAtElapsedMs);
    return LockoutStatus(
      failCount: record.failCount,
      remaining: left <= 0 ? Duration.zero : Duration(milliseconds: left),
    );
  }

  Future<LockoutRecord?> _read(String subjectKey) async {
    final raw = await _secrets.read(LockSecretKeys.lockout(subjectKey));
    return raw == null ? null : LockoutRecord.tryParse(raw);
  }

  Future<void> _write(String subjectKey, LockoutRecord record) =>
      _secrets.write(
        LockSecretKeys.lockout(subjectKey),
        jsonEncode(record.toJson()),
      );
}
