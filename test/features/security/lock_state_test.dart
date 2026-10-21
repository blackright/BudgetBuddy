import 'package:budget_buddy/features/security/domain/lock_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// T005: the state machine's contract (`contracts/lock-state-machine.md` §3).
///
/// Pure rules, no widget and no database, so each line of the event table can be
/// pinned on its own. The two that matter most:
///
/// * leaving the foreground never locks by itself — it only starts the away
///   window, and returning early must discard it (FR-022);
/// * a rejected biometric is treated exactly like a rejected PIN in *state*
///   terms, so a cancel can never leave the app open (FR-019).
void main() {
  group('T005: lock state machine', () {
    test('every protected subject starts locked at a cold start', () {
      expect(reduceLockState(LockState.unlocked, LockEvent.coldStart),
          LockState.locked);
      expect(reduceLockState(LockState.locked, LockEvent.coldStart),
          LockState.locked);
    });

    test('asking to unlock shows the challenge without opening anything', () {
      expect(reduceLockState(LockState.locked, LockEvent.unlockRequested),
          LockState.unlocking);
    });

    test('an accepted PIN opens the subject', () {
      expect(reduceLockState(LockState.unlocking, LockEvent.pinAccepted),
          LockState.unlocked);
    });

    test('a rejected PIN returns to locked', () {
      expect(reduceLockState(LockState.unlocking, LockEvent.pinRejected),
          LockState.locked);
    });

    test('a successful in-session biometric opens the subject', () {
      expect(reduceLockState(LockState.unlocking, LockEvent.biometricAccepted),
          LockState.unlocked);
    });

    test('a biometric cannot open a cold-started lock (FR-018, FR-048)', () {
      expect(reduceLockState(LockState.locked, LockEvent.biometricAccepted),
          LockState.locked);
    });

    test('asking to unlock while already open changes nothing', () {
      expect(reduceLockState(LockState.unlocked, LockEvent.unlockRequested),
          LockState.unlocked);
    });

    test('a cancelled or failed biometric locks, never unlocks (FR-019)', () {
      expect(reduceLockState(LockState.unlocking, LockEvent.biometricRejected),
          LockState.locked);
      expect(reduceLockState(LockState.unlocked, LockEvent.biometricRejected),
          LockState.locked);
    });

    test('leaving the foreground does not lock on its own (FR-022)', () {
      expect(reduceLockState(LockState.unlocked, LockEvent.leftForeground),
          LockState.unlocked);
      expect(reduceLockState(LockState.unlocked, LockEvent.phoneLocked),
          LockState.unlocked);
    });

    test('returning before the away-time discards the window', () {
      expect(
          reduceLockState(LockState.unlocked, LockEvent.returnedBeforeAwayTime),
          LockState.unlocked);
    });

    test('returning after the away-time locks (FR-022)', () {
      expect(
          reduceLockState(LockState.unlocked, LockEvent.returnedAfterAwayTime),
          LockState.locked);
    });

    test('entering another subject locks it (FR-032)', () {
      expect(reduceLockState(LockState.unlocked, LockEvent.subjectSwitched),
          LockState.locked);
    });

    test('an on-demand lock locks (FR-022)', () {
      expect(reduceLockState(LockState.unlocked, LockEvent.explicitLock),
          LockState.locked);
    });

    test(
        'the machine is total: every event has a defined outcome for every '
        'state', () {
      for (final state in LockState.values) {
        for (final event in LockEvent.values) {
          expect(() => reduceLockState(state, event), returnsNormally);
        }
      }
    });
  });
}
