import 'dart:async';

import 'package:budget_buddy/core/models/consent_record.dart';
import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/core/models/lock_setting.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/identity/presentation/app_lock_gate.dart';
import 'package:budget_buddy/features/identity/providers/device_key_session.dart';
import 'package:budget_buddy/features/identity/repositories/device_authenticator.dart';
import 'package:budget_buddy/features/identity/repositories/local_auth_outcome.dart';
import 'package:budget_buddy/features/identity/repositories/secret_store.dart';
import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/security/presentation/lock_keys.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import 'package:budget_buddy/features/security/repositories/monotonic_clock_impl.dart';
import 'package:budget_buddy/features/security/repositories/pin_verifier_store.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_monotonic_clock.dart';
import 'support/fake_pin_kdf.dart';
import 'support/in_memory_lock_settings_store.dart';

/// The two gates must not both ask: **one unlock, one system prompt** (FR-021).
///
/// 016's own unlock already runs the device's prompt (FR-048: a correct PIN
/// alone never opens the app), so 015's device-auth gate has nothing left to add
/// for the session. Before this test, opening the app with a PIN cost a *second*
/// prompt on the very next frame: 016 unlocked, the gate re-read 015's
/// conditions, found an identity with device auth granted, and shut again — so
/// the user paid for the same factor twice, and a needless "BudgetBuddy is
/// locked" screen sat between them.
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
  late InMemoryLockSettingsStore settings;

  setUp(() async {
    secrets = InMemorySecretStore();
    settings = InMemoryLockSettingsStore();
    await settings.upsert(LockSetting.forSubject(subject)..lockEnabled = true);
    await PinVerifierStore(secrets, kdf: FakePinKdf()).setPin(subject.key, pin);
  });

  tearDown(() => settings.dispose());

  /// A cold start with the lock on, **and** both of 015's own conditions true:
  /// an identity exists and device auth was granted. That combination is what
  /// used to produce the double prompt.
  Future<ProviderContainer> coldStart(DeviceAuthenticator authenticator) async {
    final container = ProviderContainer(
      overrides: [
        lockSubjectProvider.overrideWithValue(subject),
        lockSettingRepositoryProvider.overrideWithValue(settings),
        secretStoreProvider.overrideWithValue(secrets),
        pinKdfProvider.overrideWithValue(FakePinKdf()),
        monotonicClockProvider.overrideWithValue(FakeMonotonicClock()),
        deviceAuthenticatorProvider.overrideWithValue(authenticator),
        identityKeyLoaderProvider.overrideWithValue(_FakeKeyLoader(_keyPair())),
        identityProvider.overrideWith((ref) => Stream.value(_identity())),
        consentProvider.overrideWith((ref) => Stream.value(_consent())),
      ],
    );
    addTearDown(container.dispose);
    // Await both streams the composed lock watches, so the first frame already
    // knows the subject is protected and no frame is spent on the wrong gate.
    await container.read(activeLockSettingProvider.future);
    await container.read(activeSpaceProvider.future);
    return container;
  }

  Widget app(ProviderContainer container) => UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          // Mounted the way `main.dart` mounts it — as `MaterialApp.builder`,
          // above the Navigator — so the lock screen's own Overlay counts.
          builder: (context, child) =>
              AppLockGate(child: child ?? const SizedBox.shrink()),
          home: const Scaffold(body: Text('secret app')),
        ),
      );

  Future<void> typePin(WidgetTester tester, String digits) async {
    for (final digit in digits.split('')) {
      await tester.tap(find.text(digit).first);
      await tester.pump();
    }
    await tester.tap(find.byKey(const Key(LockKeys.pinSubmit)));
    await tester.pumpAndSettle();
  }

  testWidgets('a PIN unlock costs one prompt and never stacks 015 on top',
      (tester) async {
    final authenticator = _ScriptedAuthenticator(const [true]);
    final container = await coldStart(authenticator);

    await tester.pumpWidget(app(container));
    await tester.pump();

    // The gate belongs to 016: its own lock screen, not 015's.
    expect(find.byKey(const Key(LockKeys.unlockButton)), findsOneWidget);
    expect(find.text('BudgetBuddy is locked'), findsNothing);

    await tester.tap(find.byKey(const Key(LockKeys.unlockButton)));
    await tester.pump();
    await typePin(tester, pin);

    expect(find.text('secret app'), findsOneWidget);
    expect(authenticator.prompts, 1,
        reason: 'the PIN unlock pays the device factor once (FR-021, FR-048)');
    expect(find.text('BudgetBuddy is locked'), findsNothing,
        reason: '015 must not stack a second screen on a subject 016 owns');

    // …and the deferred screen must not appear later either: turning the lock
    // off leaves the app open, because the factor was already paid this session.
    await settings.upsert(LockSetting.forSubject(subject)..lockEnabled = false);
    await tester.pump();
    await tester.pump();

    expect(find.text('secret app'), findsOneWidget);
    expect(find.text('BudgetBuddy is locked'), findsNothing);
    expect(authenticator.prompts, 1);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a subject 016 does not protect still gets the 015 gate',
      (tester) async {
    // The precedence must not have quietly disabled 015 for everyone: with the
    // lock row still present but switched off, 016 protects nothing and the
    // device-auth gate is the only thing between the app and the content.
    await settings.upsert(LockSetting.forSubject(subject)..lockEnabled = false);
    final authenticator = _ScriptedAuthenticator(const [true]);
    final container = await coldStart(authenticator);

    await tester.pumpWidget(app(container));
    await tester.pump();
    await tester.pump();

    expect(find.text('BudgetBuddy is locked'), findsOneWidget);
    expect(find.text('secret app'), findsNothing);

    await tester.tap(find.byKey(const Key(LockKeys.unlockButton)));
    await tester.pumpAndSettle();

    expect(find.text('secret app'), findsOneWidget);
    expect(authenticator.prompts, 1);
    expect(container.read(deviceKeySessionProvider), isNotNull);
  });
}

class _ScriptedAuthenticator implements DeviceAuthenticator {
  /// Copied into a growable list: the call sites pass `const [...]` literals,
  /// and a `const` list throws on `removeAt`.
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

ConsentRecord _consent() => ConsentRecord()
  ..noticeVersion = 'v1'
  ..deviceAuthGranted = true
  ..decidedAt = DateTime(2026, 1, 1)
  ..updatedAt = DateTime(2026, 1, 1);
