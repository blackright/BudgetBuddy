import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/identity/providers/device_auth_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_device_authenticator.dart';

/// Fresh-install onboarding used to prompt once per auth-subject change: the
/// first `UserProfile` moves the binding from `setup:<flow>` to `p<id>`, and
/// every change called `lock()`. One Save therefore cost several prompts and
/// restarted the setup screen. Creating the owner is not a new subject.
final _binding = StateProvider<NativeAccessBinding>(
    (ref) => const NativeAccessBinding(key: 'setup:flow-one'));

void main() {
  late FakeDeviceAuthenticator auth;
  late ProviderContainer c;

  setUp(() {
    auth = FakeDeviceAuthenticator();
    c = ProviderContainer(overrides: [
      nativeAccessBindingProvider.overrideWith((ref) => ref.watch(_binding)),
      deviceAuthenticatorProvider.overrideWithValue(auth),
    ]);
  });

  tearDown(() => c.dispose());

  NativeAuthSnapshot snapshot() => c.read(deviceAuthSessionProvider);

  Future<void> moveTo(NativeAccessBinding binding) async {
    c.read(_binding.notifier).state = binding;
    await pumpEventQueue();
  }

  test('the profile created by setup keeps the grant', () async {
    expect(c.read(nativeAccessBindingProvider).key, 'setup:flow-one');
    expect(
        await c
            .read(deviceAuthSessionProvider.notifier)
            .require(reason: 'Verify'),
        isTrue);
    expect(auth.authenticateCalls, 1);

    await moveTo(const NativeAccessBinding(key: 'p1'));

    expect(snapshot().authenticated, isTrue,
        reason: 'creating the owner must not cost a second prompt');
    expect(auth.authenticateCalls, 1);
  });

  test('the carry happens once; a later subject still locks', () async {
    await c
        .read(deviceAuthSessionProvider.notifier)
        .require(reason: 'Verify');
    await moveTo(const NativeAccessBinding(key: 'p1'));
    expect(snapshot().authenticated, isTrue);

    await moveTo(const NativeAccessBinding(key: 'p2'));

    expect(snapshot().authenticated, isFalse,
        reason: 'a second profile is a different principal');
  });

  test('a replaced setup flow is a new subject', () async {
    await c
        .read(deviceAuthSessionProvider.notifier)
        .require(reason: 'Verify');

    await moveTo(const NativeAccessBinding(key: 'setup:flow-two'));

    expect(snapshot().authenticated, isFalse);
  });

  test('an unresolved subject holds the grant but refuses to prompt', () async {
    await c
        .read(deviceAuthSessionProvider.notifier)
        .require(reason: 'Verify');
    final calls = auth.authenticateCalls;

    await moveTo(
        const NativeAccessBinding(key: 'resolving', resolved: false));

    expect(
        await c
            .read(deviceAuthSessionProvider.notifier)
            .require(reason: 'Verify'),
        isFalse);
    expect(auth.authenticateCalls, calls,
        reason: 'an unknown subject fails closed without a prompt');

    await moveTo(const NativeAccessBinding(key: 'setup:flow-one'));

    expect(snapshot().authenticated, isTrue,
        reason: 'the same subject resolving again is not a new subject');
    expect(auth.authenticateCalls, calls);
  });

  test('identity replacement under the same key locks', () async {
    await c
        .read(deviceAuthSessionProvider.notifier)
        .require(reason: 'Verify');
    await moveTo(const NativeAccessBinding(key: 'p1'));
    expect(snapshot().authenticated, isTrue);

    await moveTo(NativeAccessBinding(
        key: 'p1', identity: Identity()..publicKey = 'replacement'));

    expect(snapshot().authenticated, isFalse);
  });
}
