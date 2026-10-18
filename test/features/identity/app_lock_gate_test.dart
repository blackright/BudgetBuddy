import 'dart:async';

import 'package:budget_buddy/core/models/consent_record.dart';
import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/identity/presentation/app_lock_gate.dart';
import 'package:budget_buddy/features/identity/providers/device_key_session.dart';
import 'package:budget_buddy/features/identity/repositories/device_authenticator.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// T074 follow-up: the app-lock gate must show the lock screen — and keep the
/// identity key locked — without writing to a provider **during** the build
/// pass.
///
/// That write used to sit directly in `build`, which Riverpod rejects with
/// "Tried to modify a provider while the widget tree was building" (the crash
/// reported on the device). The guard now runs just after the frame; the case
/// that pins the fix is *"a key left in memory is dropped after the frame, not
/// during build"* — put the write back in `build` and it fails with exactly
/// that message.
class _ScriptedAuthenticator implements DeviceAuthenticator {
  _ScriptedAuthenticator(this._answers);

  /// Consumed front-to-back; exhausted answers refuse.
  final List<bool> _answers;

  int prompts = 0;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> authenticate({required String reason}) async {
    prompts++;
    return _answers.isEmpty ? false : _answers.removeAt(0);
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

Identity _identity() => Identity()
  ..username = 'Ann'
  ..publicKey = 'AAAA'
  ..localProfileId = 1
  ..fingerprint = 'abcd1234'
  ..createdAt = DateTime(2026, 1, 1)
  ..updatedAt = DateTime(2026, 1, 1);

ConsentRecord _consent({required bool deviceAuth}) => ConsentRecord()
  ..noticeVersion = 'v1'
  ..deviceAuthGranted = deviceAuth
  ..decidedAt = DateTime(2026, 1, 1)
  ..updatedAt = DateTime(2026, 1, 1);

ProviderContainer _containerWith({
  required bool withIdentity,
  required bool deviceAuth,
  required DeviceAuthenticator authenticator,
  required IdentityKeyLoader loader,
}) {
  final container = ProviderContainer(
    overrides: [
      identityProvider.overrideWith(
        (ref) => Stream<Identity?>.value(withIdentity ? _identity() : null),
      ),
      consentProvider.overrideWith(
        (ref) => Stream<ConsentRecord?>.value(_consent(deviceAuth: deviceAuth)),
      ),
      deviceAuthenticatorProvider.overrideWithValue(authenticator),
      identityKeyLoaderProvider.overrideWithValue(loader),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Widget _app(ProviderContainer container) => UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: AppLockGate(child: Text('secret app')),
      ),
    );

/// The identity/consent streams settle a microtask after they are watched, so
/// the decision lands on the frame after the first one.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('locks on start without writing to a provider during build',
      (tester) async {
    final container = _containerWith(
      withIdentity: true,
      deviceAuth: true,
      authenticator: _ScriptedAuthenticator([true]),
      loader: _FakeKeyLoader(_keyPair()),
    );

    await tester.pumpWidget(_app(container));
    await _settle(tester);

    // Any provider write during the build pass surfaces here as a framework
    // exception (the red box on the device).
    expect(tester.takeException(), isNull);
    expect(find.text('BudgetBuddy is locked'), findsOneWidget);
    expect(find.text('secret app'), findsNothing);
    expect(container.read(deviceKeySessionProvider), isNull,
        reason: 'a shut gate never leaves the key out');
  });

  testWidgets('one tap opens the gate and releases the key', (tester) async {
    final authenticator = _ScriptedAuthenticator([true]);
    final container = _containerWith(
      withIdentity: true,
      deviceAuth: true,
      authenticator: authenticator,
      loader: _FakeKeyLoader(_keyPair()),
    );

    await tester.pumpWidget(_app(container));
    await _settle(tester);
    expect(find.text('BudgetBuddy is locked'), findsOneWidget);

    await tester.tap(find.byKey(const Key('unlockButton')));
    await tester.pumpAndSettle();

    expect(authenticator.prompts, 1);
    expect(find.text('secret app'), findsOneWidget);
    expect(container.read(deviceKeySessionProvider), isNotNull);
  });

  testWidgets('a cancelled prompt stays on the lock screen and can be retried',
      (tester) async {
    final authenticator = _ScriptedAuthenticator([false, true]);
    final container = _containerWith(
      withIdentity: true,
      deviceAuth: true,
      authenticator: authenticator,
      loader: _FakeKeyLoader(_keyPair()),
    );

    await tester.pumpWidget(_app(container));
    await _settle(tester);

    await tester.tap(find.byKey(const Key('unlockButton')));
    await tester.pumpAndSettle();

    expect(find.text('BudgetBuddy is locked'), findsOneWidget,
        reason: 'a refusal must not be remembered (T073)');
    expect(find.text('secret app'), findsNothing);

    await tester.tap(find.byKey(const Key('unlockButton')));
    await tester.pumpAndSettle();

    expect(authenticator.prompts, 2);
    expect(find.text('secret app'), findsOneWidget);
  });

  testWidgets(
      'a key left in memory is dropped after the frame, not during build',
      (tester) async {
    final identityController = StreamController<Identity?>();
    final consentController = StreamController<ConsentRecord?>();
    addTearDown(identityController.close);
    addTearDown(consentController.close);

    final container = ProviderContainer(
      overrides: [
        identityProvider.overrideWith((ref) => identityController.stream),
        consentProvider.overrideWith((ref) => consentController.stream),
        deviceAuthenticatorProvider
            .overrideWithValue(_ScriptedAuthenticator([true])),
        identityKeyLoaderProvider.overrideWithValue(_FakeKeyLoader(_keyPair())),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_app(container));
    expect(find.text('secret app'), findsOneWidget,
        reason: 'nothing has settled, so the gate cannot decide yet');

    // Something already released the key this session (a tap-time prompt such
    // as "Pair with a device"), so the guard has a real write to make. This is
    // the case the in-build call crashed on.
    expect(
      await container
          .read(deviceKeySessionProvider.notifier)
          .require(reason: 'Pair with a device'),
      isNotNull,
    );
    expect(container.read(deviceKeySessionProvider), isNotNull);

    identityController.add(_identity());
    consentController.add(_consent(deviceAuth: true));
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull,
        reason: 'the write must not happen during the build pass');
    expect(find.text('BudgetBuddy is locked'), findsOneWidget);
    expect(container.read(deviceKeySessionProvider), isNull,
        reason: 'the shut gate drops the key it found');
  });

  testWidgets('no identity leaves the gate inert and never prompts',
      (tester) async {
    final authenticator = _ScriptedAuthenticator([true]);
    final container = _containerWith(
      withIdentity: false,
      deviceAuth: true,
      authenticator: authenticator,
      loader: _FakeKeyLoader(_keyPair()),
    );

    await tester.pumpWidget(_app(container));
    await _settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('secret app'), findsOneWidget);
    expect(authenticator.prompts, 0);
  });

  testWidgets('declined device auth leaves the gate inert and never prompts',
      (tester) async {
    final authenticator = _ScriptedAuthenticator([true]);
    final container = _containerWith(
      withIdentity: true,
      deviceAuth: false,
      authenticator: authenticator,
      loader: _FakeKeyLoader(_keyPair()),
    );

    await tester.pumpWidget(_app(container));
    await _settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('secret app'), findsOneWidget);
    expect(authenticator.prompts, 0);
  });
}
