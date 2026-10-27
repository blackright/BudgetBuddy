import '../identity/support/fake_device_authenticator.dart';
import 'package:budget_buddy/features/identity/providers/device_auth_session.dart';
import 'support/native_identity_fixture.dart';
import 'package:budget_buddy/core/models/lock_setting.dart';
import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/security/presentation/lock_keys.dart';
import 'package:budget_buddy/features/security/presentation/security_section.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import 'package:budget_buddy/features/security/repositories/monotonic_clock_impl.dart';
import 'package:budget_buddy/features/security/repositories/pin_verifier_store.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/identity/repositories/secret_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_monotonic_clock.dart';
import 'support/fake_pin_kdf.dart';
import 'support/in_memory_lock_settings_store.dart';

/// The minimal Settings -> Security card pulled forward for US1 (Option A).
///
/// Without it there is no surface that can set `lockEnabled` or a PIN, so the
/// lock is unreachable on the device. This pins the one path the playground test
/// needs: turn the lock on, set a PIN, and see the setting and the verifier
/// actually written.
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
  late PinVerifierStore verifiers;

  setUp(() {
    secrets = InMemorySecretStore();
    settings = InMemoryLockSettingsStore();
    verifiers = PinVerifierStore(secrets, kdf: FakePinKdf());
  });

  Widget host() => ProviderScope(
        overrides: [
          nativeAccessBindingProvider.overrideWith(nativeFixtureBinding),
          deviceAuthenticatorProvider
              .overrideWithValue(FakeDeviceAuthenticator()),
          lockSubjectProvider.overrideWithValue(subject),
          lockSettingRepositoryProvider.overrideWithValue(settings),
          secretStoreProvider.overrideWithValue(secrets),
          pinKdfProvider.overrideWithValue(FakePinKdf()),
          monotonicClockProvider.overrideWithValue(FakeMonotonicClock()),
        ],
        child: const MaterialApp(
          home: Scaffold(body: SecuritySection()),
        ),
      );

  Future<void> enter(WidgetTester tester, String digits) async {
    for (final digit in digits.split('')) {
      await tester.tap(find.text(digit).first);
      await tester.pump();
    }
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('pinSubmit')));
    await tester.pump();
  }

  testWidgets('the card starts with the lock off and offers a PIN',
      (tester) async {
    await tester.pumpWidget(host());

    expect(find.byKey(const Key(LockKeys.securitySection)), findsOneWidget);
    final switchTile = tester.widget<SwitchListTile>(
      find.byKey(const Key(LockKeys.lockSwitch)),
    );
    expect(switchTile.value, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the card says what the lock does, in the user\'s own words',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pump();

    // Off: the consequence, said plainly — not a neutral description of a
    // switch — and in the words the user has (profile, shared space), never the
    // internal word "subject".
    expect(
      find.text(
          'Extra app PIN is off. Phone verification still protects this profile.'),
      findsOneWidget,
    );
    expect(find.textContaining('subject'), findsNothing,
        reason:
            'the screen speaks the user\'s language, not the data model\'s');

    await settings.upsert(_enabledRow(subject));
    await tester.pump();
    await tester.pump();

    expect(
        find.text('On: app PIN and phone verification protect this profile.'),
        findsOneWidget);
    expect(find.byKey(const Key(LockKeys.changePinButton)), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('turning the lock on sets a PIN and flips the switch',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pump();

    await tester.tap(find.byKey(const Key(LockKeys.lockSwitch)));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key(LockKeys.pinSetupScreen)), findsOneWidget);

    await enter(tester, '4821');
    await submit(tester);
    await enter(tester, '4821');
    await submit(tester);
    await tester.pumpAndSettle();

    final row = await settings.find(subject.key);
    expect(row, isNotNull);
    expect(row!.lockEnabled, isTrue,
        reason: 'the setting must actually be written, not just shown');
    expect(await verifiers.isSet(subject.key), isTrue,
        reason: 'and the verifier must live in the secret store (FR-008)');
    expect(await verifiers.verify(subject.key, '4821'), isTrue);

    final switchTile = tester.widget<SwitchListTile>(
      find.byKey(const Key(LockKeys.lockSwitch)),
    );
    expect(switchTile.value, isTrue);
    expect(find.byKey(const Key(LockKeys.changePinButton)), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('turning the lock off requires the current PIN (FR-009)',
      (tester) async {
    await settings.upsert(_enabledRow(subject));
    await verifiers.setPin(subject.key, '4821');

    await tester.pumpWidget(host());
    await tester.pump();

    await tester.tap(find.byKey(const Key(LockKeys.lockSwitch)));
    await tester.pumpAndSettle();

    // The confirm dialog refuses a wrong PIN and accepts the right one.
    await tester.enterText(find.byKey(const Key('pinConfirmField')), '9999');
    await tester.tap(find.byKey(const Key('pinConfirmSubmit')));
    await tester.pumpAndSettle();
    expect((await settings.find(subject.key))!.lockEnabled, isTrue,
        reason: 'a wrong PIN must not turn the lock off');

    await tester.enterText(find.byKey(const Key('pinConfirmField')), '4821');
    await tester.tap(find.byKey(const Key('pinConfirmSubmit')));
    await tester.pumpAndSettle();

    expect(await verifiers.isSet(subject.key), isFalse);
    expect((await settings.find(subject.key))!.lockEnabled, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

/// A setting row with the lock already on, matching what a prior run left
/// behind on the device.
LockSetting _enabledRow(LockSubject subject) =>
    LockSetting.forSubject(subject)..lockEnabled = true;
