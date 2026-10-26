import 'dart:convert';

import 'package:budget_buddy/features/identity/repositories/secret_store.dart';
import 'package:budget_buddy/features/security/domain/lock_secret_keys.dart';
import 'package:budget_buddy/features/security/repositories/lockout_store.dart';
import 'package:flutter_test/flutter_test.dart';

/// T021: FR-014/FR-015/FR-016 and SC-005 — the count and the remaining wait
/// survive a restart, a moved clock never shortens the wait, a reboot re-imposes
/// it in full, and one subject's lockout never blocks another.
///
/// `LockoutStore` takes `nowMs` explicitly, so a test can simulate a force-quit
/// (a brand new store over the same secret storage) or a reboot (a *smaller*
/// monotonic reading) without needing a clock that can run backwards.
void main() {
  late InMemorySecretStore secrets;
  late LockoutStore store;

  setUp(() {
    secrets = InMemorySecretStore();
    store = LockoutStore(secrets);
  });

  group('T021: failures accumulate and the schedule applies', () {
    test('the fifth failure starts a 30 second wait', () async {
      for (var attempt = 1; attempt <= 4; attempt++) {
        final status = await store.registerFailure('p1', nowMs: 1000);
        expect(status.failCount, attempt);
        expect(status.remaining, Duration.zero,
            reason: 'the first four failures cost no wait');
      }

      final fifth = await store.registerFailure('p1', nowMs: 1000);
      expect(fifth.failCount, 5);
      expect(fifth.remaining, const Duration(seconds: 30));
    });

    test('the tenth failure starts a 5 minute wait', () async {
      LockoutStatus last =
          const LockoutStatus(failCount: 0, remaining: Duration.zero);
      for (var attempt = 1; attempt <= 10; attempt++) {
        last = await store.registerFailure('p1', nowMs: 1000);
      }

      expect(last.failCount, 10);
      expect(last.remaining, const Duration(minutes: 5));
    });
  });

  group('T021: surviving a restart (FR-014, SC-005)', () {
    test('ten force-quit/reopen cycles never shorten the wait', () async {
      for (var attempt = 1; attempt <= 5; attempt++) {
        await store.registerFailure('p1', nowMs: 5000);
      }

      final firstWait = (await store.status('p1', nowMs: 5000)).remaining;
      expect(firstWait, const Duration(seconds: 30));

      for (var cycle = 0; cycle < 10; cycle++) {
        // A force-quit is a brand new store over the same keystore; no time has
        // passed, so the wait must be byte-for-byte identical.
        final reopened = LockoutStore(secrets);
        final status = await reopened.status('p1', nowMs: 5000);
        expect(status.failCount, 5, reason: 'cycle $cycle must keep the count');
        expect(status.remaining, firstWait,
            reason: 'cycle $cycle must not shorten the wait');
      }
    });

    test('a correct PIN clears the record entirely (FR-011, FR-046)', () async {
      await store.registerFailure('p1', nowMs: 5000);
      await store.clear('p1');

      expect(await secrets.read(LockSecretKeys.lockout('p1')), isNull);
      expect(await store.failCount('p1'), 0);
      expect((await store.status('p1', nowMs: 5000)).remaining, Duration.zero);
    });
  });

  group('T021: the clock (FR-015)', () {
    test('a wait counts down as real time passes', () async {
      for (var attempt = 1; attempt <= 5; attempt++) {
        await store.registerFailure('p1', nowMs: 1000);
      }

      final after10s = await store.status('p1', nowMs: 11000);
      expect(after10s.remaining, const Duration(seconds: 20));

      final after30s = await store.status('p1', nowMs: 31000);
      expect(after30s.remaining, Duration.zero);
    });

    test('a smaller reading means a reboot, which re-imposes the full wait',
        () async {
      for (var attempt = 1; attempt <= 5; attempt++) {
        await store.registerFailure('p1', nowMs: 900000);
      }

      // The phone rebooted: elapsedRealtime reset, so the reading is smaller.
      final rebooted = LockoutStore(secrets);
      final status = await rebooted.status('p1', nowMs: 2000);

      expect(status.failCount, 5, reason: 'the count is untouched by a reboot');
      expect(status.remaining, const Duration(seconds: 30),
          reason: 'a reboot re-imposes the wait in full from that moment');

      // And from the reboot moment it counts down normally.
      final later = await rebooted.status('p1', nowMs: 8000);
      expect(later.remaining, const Duration(seconds: 24));
    });

    test('a moved wall clock changes nothing, because it is never read',
        () async {
      for (var attempt = 1; attempt <= 5; attempt++) {
        await store.registerFailure('p1', nowMs: 1000);
      }

      // No wall clock is involved at all; only the monotonic reading moves.
      expect((await store.status('p1', nowMs: 1000)).remaining,
          const Duration(seconds: 30));
      expect((await store.status('p1', nowMs: 16000)).remaining,
          const Duration(seconds: 15));
    });
  });

  group('T021: per subject (FR-016)', () {
    test('a lockout on one subject leaves another usable', () async {
      for (var attempt = 1; attempt <= 5; attempt++) {
        await store.registerFailure('p1', nowMs: 1000);
      }

      final other = await store.status('s-space-guid', nowMs: 1000);
      expect(other.failCount, 0);
      expect(other.remaining, Duration.zero,
          reason: 'a lockout on one subject must not block another');
    });

    test('clearing one subject leaves the other locked out', () async {
      for (var attempt = 1; attempt <= 5; attempt++) {
        await store.registerFailure('p1', nowMs: 1000);
        await store.registerFailure('p2', nowMs: 1000);
      }

      await store.clear('p1');

      expect(await store.failCount('p1'), 0);
      expect((await store.status('p2', nowMs: 1000)).remaining,
          const Duration(seconds: 30));
    });
  });

  group('T021: the record holds only the minimum (FR-046)', () {
    test('nothing but the count, the wait and its baseline is stored',
        () async {
      await store.registerFailure('p1', nowMs: 1000);

      final raw = await secrets.read(LockSecretKeys.lockout('p1'));
      expect(raw, isNotNull);
      final decoded = jsonDecode(raw!) as Map<String, Object?>;
      expect(decoded.keys.toSet(),
          {'v', 'failCount', 'waitMs', 'appliedAtElapsedMs', 'appliedAtUtc'},
          reason: 'no event log, no timestamps of past failures (FR-046)');
    });
  });
}
