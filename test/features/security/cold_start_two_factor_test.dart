import 'dart:async';

import 'package:budget_buddy/core/models/lock_setting.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/identity/providers/device_key_session.dart';
import 'package:budget_buddy/features/identity/repositories/device_authenticator.dart';
import 'package:budget_buddy/features/identity/repositories/local_auth_outcome.dart';
import 'package:budget_buddy/features/identity/repositories/secret_store.dart';
import 'package:budget_buddy/features/security/domain/lock_state.dart';
import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/security/domain/pin_result.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import 'package:budget_buddy/features/security/repositories/monotonic_clock_impl.dart';
import 'package:budget_buddy/features/security/repositories/pin_verifier_store.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_monotonic_clock.dart';
import 'support/fake_pin_kdf.dart';

/// T024: FR-021/FR-048 and SC-011 — a cold start costs the PIN **plus** the
/// device's own authentication, and a biometric can never open a cold start on
/// its own.
///
/// Every cold start is a brand-new `ProviderContainer`, which is exactly what a
/// cold start is: no session state survives, only the keystore record does.
class _ScriptedAuthenticator implements DeviceAuthenticator {
  /// The list is copied into a growable one: the call sites pass `const [...]`
  /// literals, and a `const` list throws on `removeAt`.
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
    final answer = _answers.isEmpty ? false : _answers.removeAt(0);
    return answer ? BiometricOutcome.unlocked : BiometricOutcome.cancelled;
  }
}

/// A prompt that is held open until the test releases it, so "the app is not
/// usable before it succeeds" can be observed rather than assumed.
class _GatedAuthenticator implements DeviceAuthenticator {
  final List<Completer<bool>> pending = [];
  int prompts = 0;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> isEnrolled() async => true;

  @override
  Future<bool> authenticate({required String reason}) {
    prompts++;
    final completer = Completer<bool>();
    pending.add(completer);
    return completer.future;
  }

  @override
  Future<BiometricOutcome> classify({required String reason}) async {
    prompts++;
    return BiometricOutcome.cancelled;
  }
}

class _FakeKeyLoader implements IdentityKeyLoader {
  _FakeKeyLoader(this.keyPair);

  final SimpleKeyPair? keyPair;

  @override
  Future<SimpleKeyPair?> load() async => keyPair;
}

/// A throwaway ed25519 keypair — only its presence matters here.
SimpleKeyPair _keyPair() => SimpleKeyPairData(
      List<int>.filled(32, 7),
      publicKey: SimplePublicKey(
        List<int>.filled(32, 9),
        type: KeyPairType.ed25519,
      ),
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
  const pin = '4821';

  late InMemorySecretStore secrets;

  setUp(() async {
    secrets = InMemorySecretStore();
    await PinVerifierStore(secrets, kdf: FakePinKdf()).setPin(subject.key, pin);
  });

  LockSetting configuredRow() =>
      LockSetting.forSubject(subject)..lockEnabled = true;

  /// One cold start: a fresh container with no session state.
  ///
  /// The composed lock reads the subject's setting through a *stream*, so the
  /// container is awaited until that stream has answered — the same microtask
  /// flush a real cold start performs before the gate paints its first frame.
  /// Without the await the controller would briefly see "no setting yet" and
  /// mistake a protected subject for an unprotected one.
  Future<ProviderContainer> coldStart({
    required DeviceAuthenticator authenticator,
    required IdentityKeyLoader loader,
  }) async {
    final container = ProviderContainer(
      overrides: [
        lockSubjectProvider.overrideWithValue(subject),
        activeLockSettingProvider
            .overrideWith((ref) => Stream.value(configuredRow())),
        lockSettingRepositoryProvider.overrideWithValue(null),
        secretStoreProvider.overrideWithValue(secrets),
        pinKdfProvider.overrideWithValue(FakePinKdf()),
        monotonicClockProvider.overrideWithValue(FakeMonotonicClock()),
        deviceAuthenticatorProvider.overrideWithValue(authenticator),
        identityKeyLoaderProvider.overrideWithValue(loader),
      ],
    );
    addTearDown(container.dispose);
    await container.read(activeLockSettingProvider.future);
    // Both streams the composed lock watches must have answered before the
    // controller is first read, otherwise a late emission would invalidate it
    // mid-await.
    await container.read(activeSpaceProvider.future);
    return container;
  }

  test('a cold start begins locked with no key released', () async {
    final container = await coldStart(
      authenticator: _ScriptedAuthenticator(const []),
      loader: _FakeKeyLoader(_keyPair()),
    );

    final snapshot = container.read(lockControllerProvider);
    expect(snapshot.isProtected, isTrue);
    expect(snapshot.isLocked, isTrue);
    expect(container.read(deviceKeySessionProvider), isNull,
        reason: 'the session key is absent while locked (FR-024)');
  });

  test('across ten cold starts a correct PIN costs exactly one system prompt',
      () async {
    for (var start = 0; start < 10; start++) {
      final authenticator = _ScriptedAuthenticator(const [true]);
      final container = await coldStart(
        authenticator: authenticator,
        loader: _FakeKeyLoader(_keyPair()),
      );

      final result =
          await container.read(lockControllerProvider.notifier).submitPin(pin);

      expect(result, PinResult.accepted, reason: 'cold start $start');
      expect(container.read(lockControllerProvider).state, LockState.unlocked);
      expect(container.read(deviceKeySessionProvider), isNotNull,
          reason: 'the key is released only after the system prompt');
      expect(authenticator.prompts, 1,
          reason: 'one PIN entry plus at most one system prompt (FR-021)');
    }
  });

  test('the app is not usable until the system prompt succeeds', () async {
    final authenticator = _GatedAuthenticator();
    final container = await coldStart(
      authenticator: authenticator,
      loader: _FakeKeyLoader(_keyPair()),
    );
    final controller = container.read(lockControllerProvider.notifier);

    final unlock = controller.submitPin(pin);
    await pumpEventQueue();

    expect(authenticator.prompts, 1);
    expect(container.read(lockControllerProvider).isLocked, isTrue,
        reason: 'a correct PIN alone does not open the app (FR-048)');
    expect(container.read(deviceKeySessionProvider), isNull);

    authenticator.pending.single.complete(true);
    expect(await unlock, PinResult.accepted);
    expect(container.read(lockControllerProvider).state, LockState.unlocked);
  });

  test('a refused system prompt leaves the app locked (FR-048)', () async {
    final authenticator = _ScriptedAuthenticator(const [false]);
    final container = await coldStart(
      authenticator: authenticator,
      loader: _FakeKeyLoader(_keyPair()),
    );

    final result =
        await container.read(lockControllerProvider.notifier).submitPin(pin);

    expect(result, PinResult.deviceRefused);
    expect(container.read(lockControllerProvider).isLocked, isTrue);
    expect(container.read(deviceKeySessionProvider), isNull);
  });

  test('a second unlock in the same session adds no second prompt', () async {
    final authenticator = _ScriptedAuthenticator(const [true]);
    final container = await coldStart(
      authenticator: authenticator,
      loader: _FakeKeyLoader(_keyPair()),
    );
    final controller = container.read(lockControllerProvider.notifier);

    await controller.submitPin(pin);
    // What the away-time does later, minus the wait: back to locked, key
    // dropped, then a biometric in the session the PIN already opened.
    container.read(deviceKeySessionProvider.notifier).lock();
    controller.markUnlocked(LockEvent.biometricAccepted);

    expect(container.read(lockControllerProvider).state, LockState.unlocked);
    expect(authenticator.prompts, 1,
        reason:
            'the session remembers a success, so no second prompt (FR-021)');
  });

  test('a biometric can never open a cold start on its own (FR-018, SC-011)',
      () async {
    for (var start = 0; start < 10; start++) {
      final container = await coldStart(
        authenticator: _ScriptedAuthenticator(const []),
        loader: _FakeKeyLoader(_keyPair()),
      );

      container
          .read(lockControllerProvider.notifier)
          .markUnlocked(LockEvent.biometricAccepted);

      expect(container.read(lockControllerProvider).isLocked, isTrue,
          reason: 'cold start $start must stay closed to the biometric alone');
      expect(container.read(deviceKeySessionProvider), isNull);
    }
  });

  test('a wrong PIN is rejected, counted and leaves the app locked', () async {
    final container = await coldStart(
      authenticator: _ScriptedAuthenticator(const []),
      loader: _FakeKeyLoader(_keyPair()),
    );
    final controller = container.read(lockControllerProvider.notifier);

    final result = await controller.submitPin('9999');

    expect(result, PinResult.wrongPin);
    expect(container.read(lockControllerProvider).isLocked, isTrue);
    expect(container.read(lockControllerProvider).failCount, 1);
  });

  test('a correct PIN clears the failure record (FR-011)', () async {
    final container = await coldStart(
      authenticator: _ScriptedAuthenticator(const [true]),
      loader: _FakeKeyLoader(_keyPair()),
    );
    final controller = container.read(lockControllerProvider.notifier);

    await controller.submitPin('9999');
    await controller.submitPin('9998');
    expect(container.read(lockControllerProvider).failCount, 2);

    await controller.submitPin(pin);

    expect(container.read(lockControllerProvider).failCount, 0);
    expect(container.read(lockControllerProvider).remainingWait(0), isNull);
  });
}
