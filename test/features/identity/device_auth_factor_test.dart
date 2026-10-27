import 'dart:async';
import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/features/identity/providers/device_key_session.dart';
import 'package:budget_buddy/features/security/repositories/monotonic_clock_impl.dart';
import '../security/support/fake_monotonic_clock.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/identity/providers/device_auth_session.dart';
import 'package:budget_buddy/features/identity/repositories/device_authenticator.dart';
import 'package:budget_buddy/features/identity/repositories/local_auth_outcome.dart';
import 'support/fake_device_authenticator.dart';

class HeldNative implements DeviceAuthenticator {
  final pending = Completer<bool>();
  int calls = 0;
  @override
  Future<bool> authenticate({required String reason}) {
    calls++;
    return pending.future;
  }

  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<bool> isEnrolled() async => false;
  @override
  Future<BiometricOutcome> classify({required String reason}) async =>
      BiometricOutcome.notEnrolled;
}

final _binding = StateProvider<NativeAccessBinding>(
    (ref) => const NativeAccessBinding(key: 'setup:one'));

class HeldKey implements IdentityKeyLoader {
  final result = Completer<SimpleKeyPair?>();
  @override
  Future<SimpleKeyPair?> load() => result.future;
}

SimpleKeyPair fixtureKey() => SimpleKeyPairData(List.filled(32, 1),
    publicKey: SimplePublicKey(List.filled(32, 2), type: KeyPairType.ed25519),
    type: KeyPairType.ed25519);

class BrokenKey implements IdentityKeyLoader {
  @override
  Future<SimpleKeyPair?> load() async =>
      throw StateError('simulated corrupt key');
}

void main() {
  test(
      'corrupt identity key refuses twice without becoming personal-only access',
      () async {
    final auth = FakeDeviceAuthenticator();
    final c = ProviderContainer(overrides: [
      nativeAccessBindingProvider.overrideWithValue(NativeAccessBinding(
          key: 'p1', identity: Identity()..publicKey = 'present')),
      deviceAuthenticatorProvider.overrideWithValue(auth),
      identityKeyLoaderProvider.overrideWithValue(BrokenKey())
    ]);
    addTearDown(c.dispose);
    final session = c.read(deviceKeySessionProvider.notifier);
    expect(await session.require(reason: 'Verify'), isNull);
    expect(await session.require(reason: 'Verify'), isNull);
    expect(auth.authenticateCalls, 2);
    expect(c.read(deviceKeySessionProvider), isNull);
    expect(c.read(deviceAuthSessionProvider).authenticated, isFalse);
  });

  for (final key in ['p2', 'setup:another', 'wiped']) {
    test('late native success cannot cross binding change to $key', () async {
      final auth = HeldNative();
      final c = ProviderContainer(overrides: [
        nativeAccessBindingProvider.overrideWith((ref) => ref.watch(_binding)),
        deviceAuthenticatorProvider.overrideWithValue(auth)
      ]);
      addTearDown(c.dispose);
      final pending =
          c.read(deviceAuthSessionProvider.notifier).require(reason: 'Verify');
      await pumpEventQueue();
      c.read(_binding.notifier).state = NativeAccessBinding(key: key);
      c.read(deviceAuthSessionProvider);
      auth.pending.complete(true);
      expect(await pending, isFalse);
      expect(c.read(deviceAuthSessionProvider).authenticated, isFalse);
    });
  }
  test('disposed native flight cannot authenticate a fresh container',
      () async {
    final auth = HeldNative();
    final c = ProviderContainer(overrides: [
      nativeAccessBindingProvider
          .overrideWithValue(const NativeAccessBinding(key: 'p1')),
      deviceAuthenticatorProvider.overrideWithValue(auth)
    ]);
    final pending =
        c.read(deviceAuthSessionProvider.notifier).require(reason: 'Verify');
    await pumpEventQueue();
    c.dispose();
    auth.pending.complete(true);
    expect(await pending, isFalse);
  });
  test(
      'unresolved identity and shared identity absence cannot prompt or authenticate',
      () async {
    for (final binding in [
      const NativeAccessBinding(key: 'unknown', resolved: false),
      const NativeAccessBinding(key: 's1', isShared: true)
    ]) {
      final auth = FakeDeviceAuthenticator();
      final c = ProviderContainer(overrides: [
        nativeAccessBindingProvider.overrideWithValue(binding),
        deviceAuthenticatorProvider.overrideWithValue(auth)
      ]);
      expect(
          await c
              .read(deviceAuthSessionProvider.notifier)
              .require(reason: 'Verify'),
          isFalse);
      expect(auth.authenticateCalls, 0);
      c.dispose();
    }
  });
  test('native unavailable refuses without assuming credential success',
      () async {
    final auth = FakeDeviceAuthenticator(available: false);
    final c = ProviderContainer(overrides: [
      nativeAccessBindingProvider
          .overrideWithValue(const NativeAccessBinding(key: 'p1')),
      deviceAuthenticatorProvider.overrideWithValue(auth)
    ]);
    addTearDown(c.dispose);
    expect(
        await c
            .read(deviceAuthSessionProvider.notifier)
            .require(reason: 'Verify'),
        isFalse);
    expect(c.read(deviceAuthSessionProvider).message, contains('unavailable'));
    expect(auth.authenticateCalls, 0);
  });
  test('pending real-key load cannot repopulate after lock', () async {
    final loader = HeldKey();
    final c = ProviderContainer(overrides: [
      nativeAccessBindingProvider.overrideWithValue(NativeAccessBinding(
          key: 'p1', identity: Identity()..publicKey = 'key')),
      deviceAuthenticatorProvider.overrideWithValue(FakeDeviceAuthenticator()),
      identityKeyLoaderProvider.overrideWithValue(loader)
    ]);
    addTearDown(c.dispose);
    final session = c.read(deviceKeySessionProvider.notifier);
    final pending = session.require(reason: 'Verify');
    await pumpEventQueue();
    session.lock();
    loader.result.complete(fixtureKey());
    expect(await pending, isNull);
    expect(c.read(deviceKeySessionProvider), isNull);
  });
  test('identity replacement invalidates native proof and a released key',
      () async {
    final loader = HeldKey();
    final c = ProviderContainer(overrides: [
      nativeAccessBindingProvider.overrideWith((ref) => ref.watch(_binding)),
      deviceAuthenticatorProvider.overrideWithValue(FakeDeviceAuthenticator()),
      identityKeyLoaderProvider.overrideWithValue(loader)
    ]);
    addTearDown(c.dispose);
    c.read(_binding.notifier).state = NativeAccessBinding(
        key: 'p1', identity: Identity()..publicKey = 'original');
    final pending =
        c.read(deviceKeySessionProvider.notifier).require(reason: 'Verify');
    await pumpEventQueue();
    c.read(_binding.notifier).state = NativeAccessBinding(
        key: 'p1', identity: Identity()..publicKey = 'replacement');
    c.read(deviceAuthSessionProvider);
    loader.result.complete(fixtureKey());
    expect(await pending, isNull);
    expect(c.read(deviceKeySessionProvider), isNull);
  });
  test('legacy native-only session retains the existing two-minute away policy',
      () async {
    final clock = FakeMonotonicClock();
    final c = ProviderContainer(overrides: [
      nativeAccessBindingProvider
          .overrideWithValue(const NativeAccessBinding(key: 'p1')),
      deviceAuthenticatorProvider.overrideWithValue(FakeDeviceAuthenticator()),
      monotonicClockProvider.overrideWithValue(clock)
    ]);
    addTearDown(c.dispose);
    final session = c.read(deviceAuthSessionProvider.notifier);
    expect(await session.require(reason: 'Verify'), isTrue);
    session.noteLeftForeground();
    clock.advance(const Duration(seconds: 30));
    session.noteResumed();
    expect(c.read(deviceAuthSessionProvider).authenticated, isTrue);
    session.noteLeftForeground();
    clock.advance(const Duration(minutes: 2));
    session.noteResumed();
    expect(c.read(deviceAuthSessionProvider).authenticated, isFalse);
    expect(await session.require(reason: 'Verify'), isTrue);
    session.notePhoneLocked();
    session.noteResumed();
    expect(c.read(deviceAuthSessionProvider).authenticated, isFalse);
  });

  test(
      'one native flight; lock invalidates success even before state is populated',
      () async {
    final auth = HeldNative();
    final c = ProviderContainer(overrides: [
      nativeAccessBindingProvider
          .overrideWithValue(const NativeAccessBinding(key: 'p1')),
      deviceAuthenticatorProvider.overrideWithValue(auth)
    ]);
    addTearDown(c.dispose);
    final session = c.read(deviceAuthSessionProvider.notifier);
    final one = session.require(reason: 'Verify');
    final two = session.require(reason: 'Verify');
    await pumpEventQueue();
    expect(auth.calls, 1);
    session.lock();
    auth.pending.complete(true);
    expect(await one, isFalse);
    expect(await two, isFalse);
    expect(c.read(deviceAuthSessionProvider).authenticated, isFalse);
  });
  test(
      'device credentials work without enrolled biometrics; refusal is retryable',
      () async {
    final auth = FakeDeviceAuthenticator(allow: false)..enrolled = false;
    final c = ProviderContainer(overrides: [
      nativeAccessBindingProvider
          .overrideWithValue(const NativeAccessBinding(key: 'p1')),
      deviceAuthenticatorProvider.overrideWithValue(auth)
    ]);
    addTearDown(c.dispose);
    expect(
        await c
            .read(deviceAuthSessionProvider.notifier)
            .require(reason: 'Verify'),
        isFalse);
    auth.allow = true;
    expect(
        await c
            .read(deviceAuthSessionProvider.notifier)
            .require(reason: 'Verify'),
        isTrue);
    expect(auth.authenticateCalls, 2);
  });
}
