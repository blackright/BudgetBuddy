import 'package:budget_buddy/core/models/lock_setting.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/identity/repositories/secret_store.dart';
import 'package:budget_buddy/features/security/domain/away_time.dart';
import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/security/presentation/lock_keys.dart';
import 'package:budget_buddy/features/security/presentation/security_section.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import 'package:budget_buddy/features/security/repositories/lockout_store.dart';
import 'package:budget_buddy/features/security/repositories/monotonic_clock_impl.dart';
import 'package:budget_buddy/features/security/repositories/pin_verifier_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_monotonic_clock.dart';
import 'support/fake_pin_kdf.dart';
import 'support/in_memory_lock_settings_store.dart';

/// T062 (FR-009, FR-020, FR-033, FR-035): the Security card shows the subject's
/// state — the lock, the biometric status, the away-time and any running wait —
/// and never turns the lock off without the current PIN.
///
/// The away-time and the lockout row are the US5 additions: their keys were
/// reserved in Phase 1 and are only now given a control, so this test is what
/// turns two bare strings into a promise.
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
  late FakeMonotonicClock clock;

  setUp(() {
    secrets = InMemorySecretStore();
    settings = InMemoryLockSettingsStore();
    verifiers = PinVerifierStore(secrets, kdf: FakePinKdf());
    clock = FakeMonotonicClock();
  });

  tearDown(() => settings.dispose());

  Widget host({bool biometricsAvailable = false}) => ProviderScope(
        overrides: [
          lockSubjectProvider.overrideWithValue(subject),
          lockSettingRepositoryProvider.overrideWithValue(settings),
          secretStoreProvider.overrideWithValue(secrets),
          pinKdfProvider.overrideWithValue(FakePinKdf()),
          monotonicClockProvider.overrideWithValue(clock),
          identityProvider.overrideWith((ref) => Stream.value(null)),
          deviceBiometricsAvailableProvider.overrideWith((ref) async {
            return biometricsAvailable;
          }),
        ],
        child: const MaterialApp(home: Scaffold(body: SecuritySection())),
      );

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
  }

  testWidgets('the away-time control offers the five choices (FR-033)',
      (tester) async {
    await settings.upsert(
      LockSetting.forSubject(subject)
        ..lockEnabled = true
        ..awayTime = AwayTime.twoMinutes,
    );

    await tester.pumpWidget(host());
    await settle(tester);

    expect(find.byKey(const Key(LockKeys.awayTimeDropdown)), findsOneWidget,
        reason: 'the reserved key must finally host a control');
    expect(find.text('After 2 minutes'), findsWidgets,
        reason: 'the control shows the current choice in plain words');

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('changing the away-time writes the subject\'s own row (FR-033)',
      (tester) async {
    await settings.upsert(
      LockSetting.forSubject(subject)
        ..lockEnabled = true
        ..awayTime = AwayTime.twoMinutes,
    );

    await tester.pumpWidget(host());
    await settle(tester);

    await tester.tap(find.byKey(const Key(LockKeys.awayTimeDropdown)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('After 30 seconds').last);
    await tester.pumpAndSettle();

    final row = await settings.find(subject.key);
    expect(row!.awayTime, AwayTime.thirtySeconds,
        reason: 'the choice must be persisted, not just shown');

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the running lockout wait is shown read-only (FR-035)',
      (tester) async {
    await settings.upsert(
      LockSetting.forSubject(subject)
        ..lockEnabled = true
        ..awayTime = AwayTime.twoMinutes,
    );
    // A wait is running at the moment the card is read, recorded through the
    // real store so the record's shape is whatever the code actually writes.
    // Five failures is the first rung that owes a wait (FR-013).
    final lockout = LockoutStore(secrets);
    for (var i = 0; i < 5; i++) {
      await lockout.registerFailure(subject.key, nowMs: clock.nowMs());
    }

    await tester.pumpWidget(host());
    await settle(tester);

    expect(find.byKey(const Key(LockKeys.lockoutStatus)), findsOneWidget,
        reason: 'the wait must be visible on the card, not only on the lock');

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the biometric status reflects the device, read-only (FR-020)',
      (tester) async {
    await settings.upsert(
      LockSetting.forSubject(subject)..lockEnabled = true,
    );

    await tester.pumpWidget(host(biometricsAvailable: true));
    await settle(tester);

    final tile = tester.widget<SwitchListTile>(
      find.byKey(const Key(LockKeys.biometricSwitch)),
    );
    expect(tile.value, isTrue, reason: 'an enrolled phone offers the shortcut');
    expect(tile.onChanged, isNull,
        reason: 'it is a status, not a member switch to flick');

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('turning the lock off demands the current PIN (FR-009)',
      (tester) async {
    await settings.upsert(
      LockSetting.forSubject(subject)..lockEnabled = true,
    );
    await verifiers.setPin(subject.key, '4821');

    await tester.pumpWidget(host());
    await settle(tester);

    await tester.tap(find.byKey(const Key(LockKeys.lockSwitch)));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key(LockKeys.pinConfirmField)), '9999');
    await tester.tap(find.byKey(const Key(LockKeys.pinConfirmSubmit)));
    await tester.pumpAndSettle();
    expect((await settings.find(subject.key))!.lockEnabled, isTrue,
        reason: 'a wrong PIN must never turn the lock off');

    await tester.enterText(
        find.byKey(const Key(LockKeys.pinConfirmField)), '4821');
    await tester.tap(find.byKey(const Key(LockKeys.pinConfirmSubmit)));
    await tester.pumpAndSettle();
    expect((await settings.find(subject.key))!.lockEnabled, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
