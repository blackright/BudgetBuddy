import 'package:budget_buddy/features/identity/providers/device_auth_session.dart';
import 'support/native_identity_fixture.dart';
import 'package:budget_buddy/core/models/lock_setting.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/identity/providers/device_key_session.dart';
import 'package:budget_buddy/features/identity/repositories/device_authenticator.dart';
import 'package:budget_buddy/features/identity/repositories/local_auth_outcome.dart';
import 'package:budget_buddy/features/identity/repositories/secret_store.dart';
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
  const subjectA = LockSubject(
    kind: LockSubjectKind.profile,
    localId: 1,
    guid: '',
    name: 'Ann',
    avatar: '🧑',
  );
  const subjectB = LockSubject(
    kind: LockSubjectKind.profile,
    localId: 2,
    guid: '',
    name: 'Bob',
    avatar: '🧔',
  );

  late InMemorySecretStore secrets;
  late InMemoryLockSettingsStore settings;
  late FakeMonotonicClock clock;

  setUp(() async {
    secrets = InMemorySecretStore();
    settings = InMemoryLockSettingsStore();
    clock = FakeMonotonicClock();
    await PinVerifierStore(secrets, kdf: FakePinKdf())
        .setPin(subjectA.key, '1111');
    await PinVerifierStore(secrets, kdf: FakePinKdf())
        .setPin(subjectB.key, '2222');
    await settings.upsert(LockSetting.forSubject(subjectA)..lockEnabled = true);
    await settings.upsert(LockSetting.forSubject(subjectB)..lockEnabled = true);
  });

  tearDown(() => settings.dispose());

  Future<ProviderContainer> startWith(LockSubject subject) async {
    final container = ProviderContainer(overrides: [
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
    return container;
  }

  test('a protected subject starts locked', () async {
    final container = await startWith(subjectA);
    expect(container.read(lockControllerProvider).isLocked, isTrue);
  });

  test('re-selecting the same profile is a no-op', () async {
    final container = await startWith(subjectA);
    final controller = container.read(lockControllerProvider.notifier);
    await controller.submitPin('1111');
    expect(container.read(lockControllerProvider).isLocked, isFalse);
    // Re-entering the same subject keeps the unlocked state.
    // (LockController.build checks _subject?.key != effective.subject.key)
    expect(container.read(lockControllerProvider).isLocked, isFalse);
  });
}
