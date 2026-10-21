import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/identity/providers/device_key_session.dart';
import 'package:budget_buddy/features/identity/repositories/device_authenticator.dart';
import 'package:budget_buddy/features/identity/repositories/local_auth_outcome.dart';
import 'package:budget_buddy/features/sync/providers/sync_session_provider.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// T076 / T073: the unlock session must prompt **once** per launch even when
/// several features ask at the same instant, must **never** remember a refusal,
/// and must hand out an already-released key for free.
///
/// Both seams are faked (a scripted authenticator and an in-memory key loader),
/// so nothing here touches `local_auth` or the keystore.
class _ScriptedAuthenticator implements DeviceAuthenticator {
  _ScriptedAuthenticator(this._answers);

  /// Consumed front-to-back; exhausted answers refuse.
  final List<bool> _answers;

  int prompts = 0;
  final List<String> reasons = [];

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> isEnrolled() async => true;

  @override
  Future<bool> authenticate({required String reason}) async {
    prompts++;
    reasons.add(reason);
    return _answers.isEmpty ? false : _answers.removeAt(0);
  }

  @override
  Future<BiometricOutcome> classify({required String reason}) async {
    prompts++;
    reasons.add(reason);
    final answer = _answers.isEmpty ? false : _answers.removeAt(0);
    return answer ? BiometricOutcome.unlocked : BiometricOutcome.cancelled;
  }
}

class _FakeKeyLoader implements IdentityKeyLoader {
  _FakeKeyLoader(this.keyPair);

  final SimpleKeyPair? keyPair;
  int loads = 0;

  @override
  Future<SimpleKeyPair?> load() async {
    loads++;
    return keyPair;
  }
}

/// A keystore/platform failure on the first attempt and success afterwards, the
/// way a `PlatformException` from `flutter_secure_storage` behaves on hardware.
class _FlakyAuthenticator implements DeviceAuthenticator {
  int prompts = 0;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> isEnrolled() async => true;

  @override
  Future<bool> authenticate({required String reason}) async {
    prompts++;
    if (prompts == 1) throw Exception('keystore unavailable');
    return true;
  }

  @override
  Future<BiometricOutcome> classify({required String reason}) async {
    prompts++;
    if (prompts == 1) throw Exception('keystore unavailable');
    return BiometricOutcome.unlocked;
  }
}

/// A throwaway ed25519 keypair — only identity matters here, not its bytes.
SimpleKeyPair _keyPair() => SimpleKeyPairData(
      List<int>.filled(32, 7),
      publicKey: SimplePublicKey(
        List<int>.filled(32, 9),
        type: KeyPairType.ed25519,
      ),
      type: KeyPairType.ed25519,
    );

void main() {
  ProviderContainer containerWith({
    required DeviceAuthenticator authenticator,
    required IdentityKeyLoader loader,
  }) {
    final container = ProviderContainer(
      overrides: [
        deviceAuthenticatorProvider.overrideWithValue(authenticator),
        identityKeyLoaderProvider.overrideWithValue(loader),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('three simultaneous callers share one prompt and one key', () async {
    final authenticator = _ScriptedAuthenticator([true]);
    final loader = _FakeKeyLoader(_keyPair());
    final container =
        containerWith(authenticator: authenticator, loader: loader);
    final session = container.read(deviceKeySessionProvider.notifier);

    // Start all three before any of them can finish, exactly like the cold
    // start that used to fire three racing `local_auth` prompts.
    final results = await Future.wait([
      session.require(reason: 'Unlock BudgetBuddy'),
      session.require(reason: 'Pair with a device'),
      session.require(reason: 'Confirm it is you'),
    ]);

    expect(authenticator.prompts, 1,
        reason: 'one prompt, no matter how many callers race');
    expect(loader.loads, 1, reason: 'the key is read once');
    expect(results, everyElement(isNotNull));
    expect(identical(results[0], results[1]), isTrue);
    expect(identical(results[1], results[2]), isTrue);
  });

  test('a declined prompt is not remembered, so the next ask prompts again',
      () async {
    final authenticator = _ScriptedAuthenticator([false, true]);
    final loader = _FakeKeyLoader(_keyPair());
    final container =
        containerWith(authenticator: authenticator, loader: loader);
    final session = container.read(deviceKeySessionProvider.notifier);

    expect(await session.require(reason: 'Pair with a device'), isNull);
    expect(authenticator.prompts, 1);
    expect(loader.loads, 0, reason: 'nothing is read when the user declines');

    // This is the bug the user hit: previously the `null` was memoised for the
    // whole session, so every later attempt said "your identity stayed locked".
    final keyPair = await session.require(reason: 'Pair with a device');
    expect(keyPair, isNotNull, reason: 'a fresh attempt may still succeed');
    expect(authenticator.prompts, 2);
  });

  test('an unlocked key is handed out without prompting again', () async {
    final authenticator = _ScriptedAuthenticator([true]);
    final loader = _FakeKeyLoader(_keyPair());
    final container =
        containerWith(authenticator: authenticator, loader: loader);
    final session = container.read(deviceKeySessionProvider.notifier);

    final first = await session.require(reason: 'Unlock BudgetBuddy');
    final second = await session.require(reason: 'Add a person to this space');

    expect(authenticator.prompts, 1);
    expect(identical(first, second), isTrue);
  });

  test('lock() drops the key, so the next require asks again', () async {
    final authenticator = _ScriptedAuthenticator([true, true]);
    final loader = _FakeKeyLoader(_keyPair());
    final container =
        containerWith(authenticator: authenticator, loader: loader);
    final session = container.read(deviceKeySessionProvider.notifier);

    await session.require(reason: 'Unlock BudgetBuddy');
    expect(session.isUnlocked, isTrue);

    session.lock();
    expect(session.state, isNull);
    expect(session.isUnlocked, isFalse);

    await session.require(reason: 'Unlock BudgetBuddy');
    expect(authenticator.prompts, 2);
  });

  test('a phone with no stored key stays retryable instead of latching',
      () async {
    final authenticator = _ScriptedAuthenticator([true, true]);
    final loader = _FakeKeyLoader(null);
    final container =
        containerWith(authenticator: authenticator, loader: loader);
    final session = container.read(deviceKeySessionProvider.notifier);

    expect(await session.require(reason: 'Unlock BudgetBuddy'), isNull);
    expect(await session.require(reason: 'Unlock BudgetBuddy'), isNull);
    expect(authenticator.prompts, 2,
        reason: 'no key is a refusal too — it must not be cached');
    expect(session.isUnlocked, isFalse);
  });

  test('a keystore failure is retryable, not an unhandled error', () async {
    final authenticator = _FlakyAuthenticator();
    final loader = _FakeKeyLoader(_keyPair());
    final container =
        containerWith(authenticator: authenticator, loader: loader);
    final session = container.read(deviceKeySessionProvider.notifier);

    // The first attempt blows up inside the platform channel; the session must
    // report it as "nothing was released" (null), never throw at a
    // fire-and-forget caller, and clear the single-flight guard.
    expect(await session.require(reason: 'Unlock BudgetBuddy'), isNull);
    expect(session.isUnlocked, isFalse);

    final keyPair = await session.require(reason: 'Unlock BudgetBuddy');
    expect(keyPair, isNotNull, reason: 'the second try works');
    expect(authenticator.prompts, 2);
  });

  test('sync stays silent (and prompts zero times) until the gate unlocks',
      () async {
    final authenticator = _ScriptedAuthenticator([true]);
    final loader = _FakeKeyLoader(_keyPair());
    final identity = Identity()
      ..username = 'Alice'
      ..publicKey = 'pk'
      ..fingerprint = 'FINGERPRINT'
      ..localProfileId = 1
      ..createdAt = DateTime(2026, 3, 5)
      ..updatedAt = DateTime(2026, 3, 5);
    final container = ProviderContainer(
      overrides: [
        deviceAuthenticatorProvider.overrideWithValue(authenticator),
        identityKeyLoaderProvider.overrideWithValue(loader),
        identityProvider.overrideWith((ref) => Stream.value(identity)),
      ],
    );
    addTearDown(container.dispose);

    // The sync layer only ever reads the session *value*, so at cold start it
    // resolves to null and originates no prompt of its own — the second (racing)
    // prompt that used to fire here is gone (T074).
    final subscription = container.listen(syncSessionProvider, (_, __) {});
    addTearDown(subscription.close);
    await pumpEventQueue();

    expect(subscription.read().value, isNull);
    expect(authenticator.prompts, 0);

    await container
        .read(deviceKeySessionProvider.notifier)
        .require(reason: 'Unlock BudgetBuddy');
    await pumpEventQueue();

    // Once the app-lock gate has released the key, sync picks it up by itself.
    expect(subscription.read().value, isNotNull);
    expect(authenticator.prompts, 1);
  });
}
