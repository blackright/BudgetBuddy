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
    await settings.upsert(LockSetting.forSubject(subject)..lockEnabled = true);
  });

  tearDown(() => settings.dispose());

  Future<ProviderContainer> start() async {
    final container = ProviderContainer(overrides: [
      lockSubjectProvider.overrideWithValue(subject),
      lockSettingRepositoryProvider.overrideWithValue(settings),
      secretStoreProvider.overrideWithValue(secrets),
      pinKdfProvider.overrideWithValue(FakePinKdf()),
      monotonicClockProvider.overrideWithValue(clock),
      deviceAuthenticatorProvider
          .overrideWithValue(_ScriptedAuthenticator(const [true])),
      identityKeyLoaderProvider.overrideWithValue(_FakeKeyLoader(_keyPair())),
      identityProvider.overrideWith((ref) => Stream.value(null)),
      consentProvider.overrideWith((ref) => Stream.value(null)),
    ]);
    addTearDown(container.dispose);
    await container.read(activeLockSettingProvider.future);
    await container.read(activeSpaceProvider.future);
    return container;
  }

  test('locking drops the released key', () async {
    final container = await start();
    final controller = container.read(lockControllerProvider.notifier);
    await controller.submitPin('4821');
    expect(container.read(deviceKeySessionProvider), isNotNull,
        reason: 'the key is out after a successful unlock');
    // Lock explicitly.
    controller.lockNow();
    expect(container.read(deviceKeySessionProvider), isNull,
        reason: 'locking drops the released key (FR-024)');
  });

  test('no code path can read the key while locked', () async {
    final container = await start();
    // Never unlocked — key must be absent.
    expect(container.read(deviceKeySessionProvider), isNull);
    expect(container.read(lockControllerProvider).isLocked, isTrue);
  });
}
