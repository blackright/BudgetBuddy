import 'package:budget_buddy/core/models/lock_setting.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
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

/// T056 (FR-020, FR-027, FR-028): when the space Owner forbids the in-session
/// biometric shortcut, only the member's PIN is accepted for that space — and the
/// member's own toggle cannot turn the shortcut back on.
///
/// The device *can* satisfy a biometric prompt (the fake reports enrolled), so a
/// passing PIN proves the refusal is the Owner's rule and not a missing sensor.
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
    final accepted = _answers.isEmpty ? false : _answers.removeAt(0);
    return accepted ? BiometricOutcome.unlocked : BiometricOutcome.cancelled;
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

SharedSpace _space({required bool forbidBiometrics}) {
  final space = SharedSpace()
    ..id = 1
    ..syncGuid = 'guid-forbid'
    ..name = 'Our space'
    ..avatar = '🏠'
    ..currency = PrimaryCurrency.usd
    ..createdByProfileId = 1
    ..createdAt = DateTime.utc(2026, 1, 2)
    ..requirePin = true
    ..forbidBiometrics = forbidBiometrics;
  space.awayTime = AwayTime.twoMinutes;
  return space;
}

void main() {
  late InMemorySecretStore secrets;
  late InMemoryLockSettingsStore settings;
  late FakeMonotonicClock clock;

  // The member unlocking the space as themselves.
  const subject = LockSubject(
    kind: LockSubjectKind.space,
    localId: 1,
    guid: 'guid-forbid',
    name: 'Our space',
    avatar: '🏠',
  );

  setUp(() async {
    secrets = InMemorySecretStore();
    settings = InMemoryLockSettingsStore();
    clock = FakeMonotonicClock();
    // The member's OWN PIN, not the Owner's: the requirement demands their own.
    await PinVerifierStore(secrets, kdf: FakePinKdf())
        .setPin(subject.key, '4821');
    await settings.upsert(LockSetting.forSubject(subject)
      ..lockEnabled = true
      ..awayTime = AwayTime.twoMinutes);
  });

  tearDown(() => settings.dispose());

  Future<ProviderContainer> start(SharedSpace space) async {
    final container = ProviderContainer(overrides: [
      lockSubjectProvider.overrideWithValue(subject),
      lockSettingRepositoryProvider.overrideWithValue(settings),
      secretStoreProvider.overrideWithValue(secrets),
      pinKdfProvider.overrideWithValue(FakePinKdf()),
      monotonicClockProvider.overrideWithValue(clock),
      deviceAuthenticatorProvider
          .overrideWithValue(_ScriptedAuthenticator(const [true, true])),
      identityKeyLoaderProvider.overrideWithValue(_FakeKeyLoader(_keyPair())),
      activeSpaceProvider.overrideWith((ref) => Stream.value(space)),
    ]);
    addTearDown(container.dispose);
    await container.read(activeLockSettingProvider.future);
    await container.read(activeSpaceProvider.future);
    // The device-capability check is async; settle it so the composed
    // `memberBiometricsEnabled` is definitive before any assertion.
    await container.read(deviceBiometricsAvailableProvider.future);
    return container;
  }

  group('T056: the Owner forbidding the shortcut', () {
    test('biometricsAllowed is false even though the device is enrolled',
        () async {
      final container = await start(_space(forbidBiometrics: true));

      final effective = container.read(effectiveLockProvider);
      expect(effective!.forbidBiometrics, isTrue,
          reason: 'the Owner\'s forbid is carried into the composed setting');
      expect(container.read(lockControllerProvider).biometricsAllowed, isFalse,
          reason: 'the shortcut is refused for this space');
    });

    test('the member\'s own toggle cannot turn it back on', () async {
      final container = await start(_space(forbidBiometrics: true));

      // The member tries to re-enable their own biometrics.
      await settings.upsert(LockSetting.forSubject(subject)
        ..lockEnabled = true
        ..biometricsEnabled = true
        ..awayTime = AwayTime.twoMinutes);
      await container.read(activeLockSettingProvider.future);

      expect(container.read(lockControllerProvider).biometricsAllowed, isFalse,
          reason: 'a member preference never overrides the Owner');
    });

    test('the member\'s PIN still opens the space', () async {
      final container = await start(_space(forbidBiometrics: true));

      await container.read(lockControllerProvider.notifier).submitPin('4821');

      expect(container.read(lockControllerProvider).isLocked, isFalse,
          reason: 'the PIN the Owner demanded is the way in');
    });
  });

  group('T056: with no forbid, the enrolled device may use the shortcut', () {
    test('biometricsAllowed is true', () async {
      final container = await start(_space(forbidBiometrics: false));

      expect(
        container.read(lockControllerProvider).biometricsAllowed,
        isTrue,
        reason: 'the Owner left the shortcut alone and the phone is enrolled',
      );
    });
  });
}
