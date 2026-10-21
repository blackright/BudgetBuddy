import 'package:budget_buddy/core/models/lock_setting.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/identity/providers/device_key_session.dart';
import 'package:budget_buddy/features/identity/repositories/secret_store.dart';
import 'package:budget_buddy/features/security/domain/away_time.dart';
import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/security/presentation/lock_screen.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import 'package:budget_buddy/features/security/repositories/monotonic_clock_impl.dart';
import 'package:budget_buddy/features/security/repositories/pin_verifier_store.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../identity/support/fake_device_authenticator.dart';
import 'support/fake_monotonic_clock.dart';
import 'support/fake_pin_kdf.dart';
import 'support/in_memory_lock_settings_store.dart';

/// T063 (FR-039, FR-045, FR-039/FR-038): a forgotten PIN is recovered by another
/// unlocked subject on the same phone, **keeping every record**; and the only
/// alternative — erasing everything — warns first and never implies anything
/// survives.
///
/// Two halves, deliberately:
/// * the mechanical half proves [LockController.resetPin] replaces only the
///   verifier and keeps the setting row, so recovery is not a quiet wipe;
/// * the honesty half proves the erase dialog says, in plain words, that nothing
///   is kept and there is no backup — the thing a tired user must read before
///   tapping the destructive button.
void main() {
  const locked = LockSubject(
    kind: LockSubjectKind.space,
    localId: 1,
    guid: 'guid-recover',
    name: 'Our space',
    avatar: '🏠',
  );

  late InMemorySecretStore secrets;
  late InMemoryLockSettingsStore settings;
  late PinVerifierStore verifiers;

  SharedSpace space({String guid = 'guid-recover'}) {
    final row = SharedSpace()
      ..id = 1
      ..syncGuid = guid
      ..name = 'Our space'
      ..avatar = '🏠'
      ..currency = PrimaryCurrency.usd
      ..defaultIncome = 0
      ..createdByProfileId = 1
      ..createdAt = DateTime.utc(2026, 1, 2);
    row.awayTime = AwayTime.twoMinutes;
    return row;
  }

  setUp(() async {
    secrets = InMemorySecretStore();
    settings = InMemoryLockSettingsStore();
    verifiers = PinVerifierStore(secrets, kdf: FakePinKdf());
  });

  tearDown(() => settings.dispose());

  group('T063: recovery keeps every record (FR-045)', () {
    Future<ProviderContainer> container() async {
      final c = ProviderContainer(overrides: [
        lockSubjectProvider.overrideWithValue(locked),
        lockSettingRepositoryProvider.overrideWithValue(settings),
        secretStoreProvider.overrideWithValue(secrets),
        pinKdfProvider.overrideWithValue(FakePinKdf()),
        monotonicClockProvider.overrideWithValue(FakeMonotonicClock()),
        deviceAuthenticatorProvider
            .overrideWithValue(FakeDeviceAuthenticator()),
        identityKeyLoaderProvider.overrideWithValue(_FakeKeyLoader(_keyPair())),
        activeSpaceProvider.overrideWith((ref) => Stream.value(space())),
        identityProvider.overrideWith((ref) => Stream.value(null)),
      ]);
      addTearDown(c.dispose);
      await c.read(activeLockSettingProvider.future);
      return c;
    }

    test(
        'resetting replaces the verifier and clears the lockout, keeping the '
        'setting row', () async {
      final original = LockSetting.forSubject(locked)
        ..lockEnabled = true
        ..awayTime = AwayTime.fiveMinutes;
      await settings.upsert(original);
      await verifiers.setPin(locked.key, '4821');

      final c = await container();
      // A member locked out by failed attempts (so the reset must clear it).
      await c.read(lockControllerProvider.notifier).refreshLockout();

      await c.read(lockControllerProvider.notifier).resetPin('7731');

      expect(await verifiers.verify(locked.key, '4821'), isFalse,
          reason: 'the old PIN no longer opens the lock');
      expect(await verifiers.verify(locked.key, '7731'), isTrue,
          reason: 'the new PIN does');

      final row = await settings.find(locked.key);
      expect(row, isNotNull, reason: 'the setting row survives recovery');
      expect(row!.lockEnabled, isTrue);
      expect(row.awayTime, AwayTime.fiveMinutes,
          reason: 'the member\'s own away-time is not collateral damage');
    });

    test('a reset the policy refuses changes nothing', () async {
      await settings.upsert(LockSetting.forSubject(locked)..lockEnabled = true);
      await verifiers.setPin(locked.key, '4821');

      final c = await container();

      await expectLater(
        c.read(lockControllerProvider.notifier).resetPin('1111'),
        throwsA(isA<ArgumentError>()),
        reason: 'a new PIN must still pass the policy (FR-010)',
      );

      expect(await verifiers.verify(locked.key, '4821'), isTrue,
          reason: 'a refused reset must not have already overwritten the PIN');
    });

    test('after a reset the subject can unlock with the new PIN', () async {
      await settings.upsert(LockSetting.forSubject(locked)..lockEnabled = true);
      await verifiers.setPin(locked.key, '4821');

      final c = await container();
      await c.read(lockControllerProvider.notifier).resetPin('7731');

      final result =
          await c.read(lockControllerProvider.notifier).submitPin('7731');
      expect(result.name, 'accepted');
      expect(c.read(lockControllerProvider).isLocked, isFalse,
          reason: 'the whole point of recovery is getting back in');
    });
  });

  group('T063: the erase path warns first (FR-039)', () {
    Widget host() => ProviderScope(
          overrides: [
            lockSubjectProvider.overrideWithValue(locked),
            lockSettingRepositoryProvider.overrideWithValue(settings),
            secretStoreProvider.overrideWithValue(secrets),
            pinKdfProvider.overrideWithValue(FakePinKdf()),
            monotonicClockProvider.overrideWithValue(FakeMonotonicClock()),
            activeSpaceProvider.overrideWith((ref) => Stream.value(space())),
            profilesProvider
                .overrideWith((ref) => Stream.value(<UserProfile>[])),
            identityProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(home: LockScreen(subject: locked)),
        );

    testWidgets(
        'the forgot-PIN dialog offers recovery and says what erasing '
        'costs', (tester) async {
      await tester.pumpWidget(host());
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byKey(const Key('forgotPinButton')));
      await tester.pumpAndSettle();

      expect(find.text('Forgot your PIN?'), findsWidgets,
          reason: 'the button and the dialog title both carry the words');
      expect(
          find.textContaining('another profile on this phone'), findsOneWidget,
          reason: 'recovery is offered as the preferred road');
      expect(
          find.textContaining('erase all data and start clean'), findsOneWidget,
          reason: 'erasing is named as the last resort, plainly');

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('with no other profile, erasing warns that nothing is kept',
        (tester) async {
      await tester.pumpWidget(host());
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byKey(const Key('forgotPinButton')));
      await tester.pumpAndSettle();
      // No other profile can unlock, so the recovery road leads straight to the
      // erase confirm rather than a useless picker.
      await tester.tap(find.text('I have another profile'));
      await tester.pumpAndSettle();

      expect(find.text('Erase and start over?'), findsOneWidget);
      expect(find.textContaining('What will be kept: nothing'), findsOneWidget,
          reason: 'the wording must never imply a backup survives');
      expect(find.textContaining('cannot be undone'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('cancel leaves the lock untouched', (tester) async {
      await tester.pumpWidget(host());
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byKey(const Key('forgotPinButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Erase and start over'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(LockScreen), findsOneWidget);
      expect(find.text('Erase and start over?'), findsNothing);
    });
  });
}

/// A keystore seam that hands back a fixed key without hardware.
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
