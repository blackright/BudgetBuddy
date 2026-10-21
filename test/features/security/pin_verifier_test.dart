import 'dart:convert';

import 'package:budget_buddy/features/identity/repositories/secret_store.dart';
import 'package:budget_buddy/features/security/domain/lock_secret_keys.dart';
import 'package:budget_buddy/features/security/repositories/lockout_store.dart';
import 'package:budget_buddy/features/security/repositories/pin_verifier_store.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_pin_kdf.dart';

/// T019: FR-011/FR-012 — a correct PIN clears the record, a wrong one does
/// not, and changing a PIN touches nothing but its own record.
///
/// The verifier lives only in the [SecretStore] (never Isar), so these tests
/// speak to that seam directly and never open a database.
void main() {
  late InMemorySecretStore secrets;
  late PinVerifierStore store;

  setUp(() {
    secrets = InMemorySecretStore();
    store = PinVerifierStore(secrets, kdf: FakePinKdf());
  });

  test('a subject has no PIN until one is written', () async {
    expect(await store.isSet('p1'), isFalse);
    expect(await store.verify('p1', '4821'), isFalse,
        reason: 'nothing to match against, so nothing opens');
  });

  group('T019: set and verify (FR-011)', () {
    test('a correct PIN verifies and a wrong one does not', () async {
      await store.setPin('p1', '4821');

      expect(await store.isSet('p1'), isTrue);
      expect(await store.verify('p1', '4821'), isTrue);
      expect(await store.verify('p1', '4822'), isFalse);
      expect(await store.verify('p1', '48210'), isFalse);
      expect(await store.verify('p1', ''), isFalse);
    });

    test('the record never contains the PIN itself (FR-008)', () async {
      await store.setPin('p1', '4821');

      final raw = await secrets.read(LockSecretKeys.pin('p1'));
      expect(raw, isNotNull);
      expect(raw, isNot(contains('4821')),
          reason: 'the raw PIN is never stored anywhere, at any time');

      final decoded = jsonDecode(raw!) as Map<String, Object?>;
      expect(decoded['v'], 1);
      expect(decoded['kdf'], 'pbkdf2-hmac-sha256');
      expect(decoded['iterations'], isA<int>());
      expect(base64Decode(decoded['salt']! as String).length, 16,
          reason: 'a fresh 16-byte salt per subject');
      expect(base64Decode(decoded['verifier']! as String).length, 32,
          reason: 'a 256-bit verifier');
    });

    test('every subject gets its own salt, so records never collide', () async {
      await store.setPin('p1', '4821');
      await store.setPin('p2', '4821');

      final first = jsonDecode((await secrets.read(LockSecretKeys.pin('p1')))!);
      final second =
          jsonDecode((await secrets.read(LockSecretKeys.pin('p2')))!);
      expect(first['salt'], isNot(second['salt']));
      expect(first['verifier'], isNot(second['verifier']));
    });
  });

  group('T019: subjects are independent (FR-016, FR-032)', () {
    test('one subject\'s PIN unlocks neither another subject nor a space',
        () async {
      await store.setPin('p1', '4821');
      await store.setPin('s-space-guid', '7731');

      expect(await store.verify('p1', '7731'), isFalse);
      expect(await store.verify('s-space-guid', '4821'), isFalse);
      expect(await store.verify('p2', '4821'), isFalse,
          reason: 'a subject with no verifier never verifies');
      expect(await store.verify('p1', '4821'), isTrue);
      expect(await store.verify('s-space-guid', '7731'), isTrue);
    });

    test('deleting one subject leaves the other alone', () async {
      await store.setPin('p1', '4821');
      await store.setPin('p2', '7731');

      await store.delete('p1');

      expect(await store.isSet('p1'), isFalse);
      expect(await store.verify('p2', '7731'), isTrue);
    });
  });

  group('T019: changing a PIN (FR-012)', () {
    test('a change rewrites only the PIN record and keeps the lockout',
        () async {
      final lockout = LockoutStore(secrets);
      final before = await lockout.registerFailure('p1', nowMs: 1000);
      expect(before.failCount, 1);

      await store.setPin('p1', '4821');
      final lockoutAfterSet = await secrets.read(LockSecretKeys.lockout('p1'));

      await store.setPin('p1', '7731');

      expect(await secrets.read(LockSecretKeys.lockout('p1')), lockoutAfterSet,
          reason: 'a PIN change carries no data risk and touches no other '
              'record (FR-012)');
      expect((await lockout.failCount('p1')), 1);
      expect(await store.verify('p1', '4821'), isFalse);
      expect(await store.verify('p1', '7731'), isTrue);
    });
  });

  group('T019: the real KDF', () {
    test('PBKDF2-HMAC-SHA256 round-trips a PIN', () async {
      // A tiny floor/ceiling keeps the real KDF fast in the test; the shape of
      // the derivation is what is being checked, not its cost.
      final real = PinVerifierStore(
        InMemorySecretStore(),
        kdf: const Pbkdf2PinKdf(floorIterations: 1000, ceiling: 1000),
      );

      await real.setPin('p1', '4821');

      expect(await real.verify('p1', '4821'), isTrue);
      expect(await real.verify('p1', '4822'), isFalse);
      expect(await real.verify('p1', '48210'), isFalse);
    });

    test('calibration never returns below the documented floor', () async {
      const kdf = Pbkdf2PinKdf(floorIterations: 1000, ceiling: 4000);
      expect(await kdf.calibrate(), greaterThanOrEqualTo(1000));
    });
  });
}
