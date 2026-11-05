import 'package:budget_buddy/features/identity/providers/device_auth_session.dart';
import 'support/native_identity_fixture.dart';
import 'dart:async';

import 'package:budget_buddy/core/models/lock_setting.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/identity/providers/device_key_session.dart';
import 'package:budget_buddy/features/identity/repositories/device_authenticator.dart';
import 'package:budget_buddy/features/identity/repositories/local_auth_outcome.dart';
import 'package:budget_buddy/features/identity/repositories/secret_store.dart';
import 'package:budget_buddy/features/security/domain/away_time.dart';
import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import 'package:budget_buddy/features/security/repositories/monotonic_clock_impl.dart';
import 'package:budget_buddy/features/security/repositories/pin_verifier_store.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_monotonic_clock.dart';
import 'support/fake_pin_kdf.dart';
import 'support/in_memory_lock_settings_store.dart';

/// T042: FR-022, FR-033 — the away-time transition. A protected subject
/// re-locks only when the app has been away longer than its away-time; the
/// five bounded choices and the 2-minute default are all pinned.
class _ScriptedAuthenticator implements DeviceAuthenticator {
  _ScriptedAuthenticator(List<bool> answers) : _answers = [...answers];
  final List<bool> _answers;
  int prompts = 0;
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<bool> isEnrolled() async => true;
  @override
  Future<bool> authenticate({required String reason}) async {
    prompts++;
    return _answers.isEmpty ? false : _answers.removeAt(0);
  }

  @override
  Future<BiometricOutcome> classify({required String reason}) async {
    prompts++;
    final a = _answers.isEmpty ? false : _answers.removeAt(0);
    return a ? BiometricOutcome.unlocked : BiometricOutcome.cancelled;
  }
}

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

  setUp(() async {
    secrets = InMemorySecretStore();
    settings = InMemoryLockSettingsStore();
    clock = FakeMonotonicClock();
    await PinVerifierStore(secrets, kdf: FakePinKdf())
        .setPin(subject.key, '4821');
    await settings.upsert(LockSetting.forSubject(subject)
      ..lockEnabled = true
      ..awayTime = AwayTime.twoMinutes);
  });

  tearDown(() => settings.dispose());

  Future<ProviderContainer> start({AwayTime away = AwayTime.twoMinutes}) async {
    await settings.upsert(LockSetting.forSubject(subject)
      ..lockEnabled = true
      ..awayTime = away);
    final container = ProviderContainer(overrides: [
      nativeAccessBindingProvider.overrideWith(nativeFixtureBinding),
      nativeAccessBindingProvider.overrideWith(nativeFixtureBinding),
      lockSubjectProvider.overrideWithValue(subject),
      lockSettingRepositoryProvider.overrideWithValue(settings),
      secretStoreProvider.overrideWithValue(secrets),
      pinKdfProvider.overrideWithValue(FakePinKdf()),
      monotonicClockProvider.overrideWithValue(clock),
      deviceAuthenticatorProvider
          .overrideWithValue(_ScriptedAuthenticator(const [true])),
      identityKeyLoaderProvider.overrideWithValue(_FakeKeyLoader(_keyPair())),
      identityProvider
          .overrideWith((ref) => Stream.value(nativeFixtureIdentity())),
      consentProvider.overrideWith((ref) => Stream.value(null)),
    ]);
    addTearDown(container.dispose);
    await container.read(activeLockSettingProvider.future);
    await container.read(activeSpaceProvider.future);
    // Unlock the subject so we can test the away transition.
    await container.read(lockControllerProvider.notifier).submitPin('4821');
    return container;
  }

  test('just under the away-time keeps the app open', () async {
    final container = await start();
    final controller = container.read(lockControllerProvider.notifier);
    // 1 minute 59 seconds away, default 2 minutes.
    clock.advance(const Duration(minutes: 1, seconds: 59));
    controller.noteLeftForeground();
    clock.advance(const Duration(minutes: 1, seconds: 59));
    controller.noteResumed();
    expect(container.read(lockControllerProvider).isLocked, isFalse);
  });

  test('exactly the away-time locks', () async {
    final container = await start();
    final controller = container.read(lockControllerProvider.notifier);
    controller.noteLeftForeground();
    clock.advance(const Duration(minutes: 2));
    controller.noteResumed();
    expect(container.read(lockControllerProvider).isLocked, isTrue);
  });

  test('five bounded choices are all honoured', () async {
    for (final away in AwayTime.values) {
      final container = await start(away: away);
      final controller = container.read(lockControllerProvider.notifier);
      controller.noteLeftForeground();
      // One ms short of the window: must stay open.
      clock.advance(away.window - const Duration(milliseconds: 1));
      controller.noteResumed();
      expect(container.read(lockControllerProvider).isLocked, isFalse,
          reason: '${away.label} short');
      // Re-unlock and try again at the boundary.
      await container.read(lockControllerProvider.notifier).submitPin('4821');
      controller.noteLeftForeground();
      clock.advance(away.window);
      controller.noteResumed();
      expect(container.read(lockControllerProvider).isLocked, isTrue,
          reason: '${away.label} boundary');
    }
  });
}
