import 'dart:convert';

import 'package:budget_buddy/core/models/lock_setting.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/identity/providers/device_key_session.dart';
import 'package:budget_buddy/features/identity/repositories/secret_store.dart';
import 'package:budget_buddy/features/security/domain/lock_secret_keys.dart';
import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import 'package:budget_buddy/features/security/repositories/lockout_store.dart';
import 'package:budget_buddy/features/security/repositories/monotonic_clock_impl.dart';
import 'package:budget_buddy/features/security/repositories/pin_verifier_store.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../identity/support/fake_device_authenticator.dart';
import 'support/fake_monotonic_clock.dart';
import 'support/fake_pin_kdf.dart';
import 'support/in_memory_lock_settings_store.dart';

/// T078 (FR-046, SC-010): the only stored security state is the failure count
/// and the wait-until. There is no event log, no timestamp list, no attempt
/// history anywhere, and a correct PIN clears the record.
///
/// FR-046 is a *minimality* requirement, and minimality is the kind of promise
/// that erodes one convenient field at a time. The key assertion is therefore
/// about the exact set of stored keys: adding a sixth must break this test and
/// force a deliberate decision rather than a quiet accumulation of history.
void main() {
  const subject = LockSubject(
    kind: LockSubjectKind.profile,
    localId: 1,
    guid: '',
    name: 'Ann',
    avatar: '🧑',
  );

  late InMemorySecretStore secrets;
  late InMemoryLockSettingsStore settings;
  late FakeMonotonicClock clock;

  setUp(() {
    secrets = InMemorySecretStore();
    settings = InMemoryLockSettingsStore();
    clock = FakeMonotonicClock();
  });

  tearDown(() => settings.dispose());

  group('T078: the stored security state is minimal', () {
    test('the lockout record holds exactly the count and the wait', () async {
      final lockout = LockoutStore(secrets);
      await lockout.registerFailure(subject.key, nowMs: clock.nowMs());

      final raw = await secrets.read(LockSecretKeys.lockout(subject.key));
      expect(raw, isNotNull);

      final decoded = jsonDecode(raw!) as Map<String, dynamic>;
      expect(
        decoded.keys.toSet(),
        {'v', 'failCount', 'waitMs', 'appliedAtElapsedMs', 'appliedAtUtc'},
        reason: 'a sixth key means someone started keeping history (FR-046)',
      );
    });

    test('no list, log or per-attempt record is stored', () async {
      final lockout = LockoutStore(secrets);
      for (var i = 0; i < 6; i++) {
        await lockout.registerFailure(subject.key, nowMs: clock.nowMs());
      }

      final raw = await secrets.read(LockSecretKeys.lockout(subject.key));
      final decoded = jsonDecode(raw!) as Map<String, dynamic>;

      for (final value in decoded.values) {
        expect(value, isNot(isA<List>()),
            reason: 'a list is where attempt history would hide');
        expect(value, isNot(isA<Map>()),
            reason: 'a nested map is a log by another name');
      }
      // Nothing that reads as a sequence of moments.
      expect(raw, isNot(contains('attempts')));
      expect(raw, isNot(contains('history')));
      expect(raw, isNot(contains('events')));
    });

    test('the failure count is a single number, not a growing record',
        () async {
      final lockout = LockoutStore(secrets);
      for (var i = 0; i < 6; i++) {
        await lockout.registerFailure(subject.key, nowMs: clock.nowMs());
      }

      final decoded = jsonDecode(
        (await secrets.read(LockSecretKeys.lockout(subject.key)))!,
      ) as Map<String, dynamic>;
      expect(decoded['failCount'], 6,
          reason: 'the count is the whole of what is remembered');
    });

    test('a correct PIN clears the record entirely (FR-011)', () async {
      final verifiers = PinVerifierStore(secrets, kdf: FakePinKdf());
      await verifiers.setPin(subject.key, '4821');

      final container = ProviderContainer(overrides: [
        lockSubjectProvider.overrideWithValue(subject),
        lockSettingRepositoryProvider.overrideWithValue(settings),
        secretStoreProvider.overrideWithValue(secrets),
        pinKdfProvider.overrideWithValue(FakePinKdf()),
        monotonicClockProvider.overrideWithValue(clock),
        deviceAuthenticatorProvider
            .overrideWithValue(FakeDeviceAuthenticator()),
        identityKeyLoaderProvider.overrideWithValue(_FakeKeyLoader(_keyPair())),
        identityProvider.overrideWith((ref) => Stream.value(null)),
      ]);
      addTearDown(container.dispose);

      await settings.upsert(
        LockSetting.forSubject(subject)..lockEnabled = true,
      );
      await container.read(activeLockSettingProvider.future);

      // Two failures owe no wait (FR-013), so the count is on record without a
      // wait blocking the attempt.
      final lockout = LockoutStore(secrets);
      await lockout.registerFailure(subject.key, nowMs: clock.nowMs());
      await lockout.registerFailure(subject.key, nowMs: clock.nowMs());
      expect(
        (await lockout.status(subject.key, nowMs: clock.nowMs())).failCount,
        2,
      );

      final result = await container
          .read(lockControllerProvider.notifier)
          .submitPin('4821');
      expect(result.name, 'accepted');

      expect(
        await secrets.read(LockSecretKeys.lockout(subject.key)),
        isNull,
        reason: 'unlocking wipes the failure count; nothing lingers',
      );
    });

    test('a running wait blocks even a correct PIN (FR-013)', () async {
      // The other half of "the count is the whole of it": while a wait runs,
      // the right PIN does not shortcut it, and the record is not cleared.
      final verifiers = PinVerifierStore(secrets, kdf: FakePinKdf());
      await verifiers.setPin(subject.key, '4821');

      final container = ProviderContainer(overrides: [
        lockSubjectProvider.overrideWithValue(subject),
        lockSettingRepositoryProvider.overrideWithValue(settings),
        secretStoreProvider.overrideWithValue(secrets),
        pinKdfProvider.overrideWithValue(FakePinKdf()),
        monotonicClockProvider.overrideWithValue(clock),
        deviceAuthenticatorProvider
            .overrideWithValue(FakeDeviceAuthenticator()),
        identityKeyLoaderProvider.overrideWithValue(_FakeKeyLoader(_keyPair())),
        identityProvider.overrideWith((ref) => Stream.value(null)),
      ]);
      addTearDown(container.dispose);

      await settings.upsert(
        LockSetting.forSubject(subject)..lockEnabled = true,
      );
      await container.read(activeLockSettingProvider.future);

      final lockout = LockoutStore(secrets);
      for (var i = 0; i < 5; i++) {
        await lockout.registerFailure(subject.key, nowMs: clock.nowMs());
      }

      final result = await container
          .read(lockControllerProvider.notifier)
          .submitPin('4821');
      expect(result.name, 'lockedOut',
          reason: 'the countdown is not a hint the right PIN can skip');
    });

    test('the surrogate PIN was never a second thing kept', () async {
      // FR-046 in one line: what survives a restart is the count and the wait,
      // and nothing about *which* PINs were tried.
      final lockout = LockoutStore(secrets);
      await lockout.registerFailure(subject.key, nowMs: clock.nowMs());

      final raw = (await secrets.read(LockSecretKeys.lockout(subject.key)))!;
      expect(raw, isNot(contains('4821')));
      expect(raw, isNot(contains('wrong')));
      expect(raw, isNot(contains('tried')));
    });
  });
}

/// A keystore seam that hands back a fixed key without hardware.
class _FakeKeyLoader implements IdentityKeyLoader {
  _FakeKeyLoader(this.keyPair);
  final SimpleKeyPair? keyPair;
  @override
  Future<SimpleKeyPair?> load() async => keyPair;
}

SimpleKeyPair _keyPair() => SimpleKeyPairData(
      List<int>.filled(32, 7),
      publicKey:
          SimplePublicKey(List<int>.filled(32, 9), type: KeyPairType.ed25519),
      type: KeyPairType.ed25519,
    );
