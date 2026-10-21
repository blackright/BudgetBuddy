import 'package:budget_buddy/core/models/lock_setting.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/identity/repositories/secret_store.dart';
import 'package:budget_buddy/features/security/domain/away_time.dart';
import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/security/presentation/lock_keys.dart';
import 'package:budget_buddy/features/security/presentation/security_section.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import 'package:budget_buddy/features/security/repositories/monotonic_clock_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_monotonic_clock.dart';
import 'support/fake_pin_kdf.dart';
import 'support/in_memory_lock_settings_store.dart';

/// T060 (FR-027, FR-028): a member sees the Owner's requirement as a fact they
/// cannot switch off.
///
/// The whole point of US4 is that a member is *answered* on their own device,
/// not asked. So the card must show the requirement and disable the control —
/// a live switch that offered a Turn-off the composed lock would immediately
/// undo is the lie this test exists to prevent.
void main() {
  const subject = LockSubject(
    kind: LockSubjectKind.space,
    localId: 1,
    guid: 'guid-member',
    name: 'Our space',
    avatar: '🏠',
  );

  late InMemorySecretStore secrets;
  late InMemoryLockSettingsStore settings;

  SharedSpace spaceRequiring({required bool requirePin, bool forbid = false}) {
    final space = SharedSpace()
      ..id = 1
      ..syncGuid = 'guid-member'
      ..name = 'Our space'
      ..avatar = '🏠'
      ..currency = PrimaryCurrency.usd
      ..defaultIncome = 0
      ..createdByProfileId = 1
      ..createdAt = DateTime.utc(2026, 1, 2)
      ..requirePin = requirePin
      ..forbidBiometrics = forbid;
    space.awayTime = AwayTime.twoMinutes;
    return space;
  }

  setUp(() {
    secrets = InMemorySecretStore();
    settings = InMemoryLockSettingsStore();
  });

  tearDown(() => settings.dispose());

  Widget host(SharedSpace space) => ProviderScope(
        overrides: [
          lockSubjectProvider.overrideWithValue(subject),
          lockSettingRepositoryProvider.overrideWithValue(settings),
          secretStoreProvider.overrideWithValue(secrets),
          pinKdfProvider.overrideWithValue(FakePinKdf()),
          monotonicClockProvider.overrideWithValue(FakeMonotonicClock()),
          activeSpaceProvider.overrideWith((ref) => Stream.value(space)),
          // The card reads this to decide whether to show the device-auth line.
          identityProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const MaterialApp(home: Scaffold(body: SecuritySection())),
      );

  testWidgets('the switch is read-only and says the Owner turned it on',
      (tester) async {
    await settings.upsert(
      LockSetting.forSubject(subject)
        ..lockEnabled = true
        ..awayTime = AwayTime.twoMinutes,
    );

    await tester.pumpWidget(host(spaceRequiring(requirePin: true)));
    await tester.pump();
    await tester.pump();

    final switchTile = tester.widget<SwitchListTile>(
      find.byKey(const Key(LockKeys.lockSwitch)),
    );
    expect(switchTile.value, isTrue);
    expect(switchTile.onChanged, isNull,
        reason: 'a member must not be offered a Turn-off the Owner forbids');

    expect(
      find.text('Required for this shared space — the Owner turned this on.'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the requirement stands even before the member sets a PIN',
      (tester) async {
    // No row at all: the member has never configured anything, yet the Owner's
    // requirement must still be visible and not switchable.
    await tester.pumpWidget(host(spaceRequiring(requirePin: true)));
    await tester.pump();
    await tester.pump();

    final switchTile = tester.widget<SwitchListTile>(
      find.byKey(const Key(LockKeys.lockSwitch)),
    );
    expect(switchTile.onChanged, isNull,
        reason: 'the lock is the Owner\'s demand, not the member\'s choice');

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('when the Owner forbids it, the biometric row says so',
      (tester) async {
    await settings.upsert(
      LockSetting.forSubject(subject)
        ..lockEnabled = true
        ..awayTime = AwayTime.twoMinutes,
    );

    await tester
        .pumpWidget(host(spaceRequiring(requirePin: true, forbid: true)));
    await tester.pump();
    await tester.pump();

    final bioTile = tester.widget<SwitchListTile>(
      find.byKey(const Key(LockKeys.biometricSwitch)),
    );
    expect(bioTile.value, isFalse,
        reason: 'a forbidden shortcut must never read as on');
    expect(bioTile.onChanged, isNull);
    expect(find.text('Forbidden by the space Owner.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('without an Owner requirement the member keeps their choice',
      (tester) async {
    await settings.upsert(
      LockSetting.forSubject(subject)
        ..lockEnabled = true
        ..awayTime = AwayTime.twoMinutes,
    );

    await tester.pumpWidget(host(spaceRequiring(requirePin: false)));
    await tester.pump();
    await tester.pump();

    final switchTile = tester.widget<SwitchListTile>(
      find.byKey(const Key(LockKeys.lockSwitch)),
    );
    expect(switchTile.onChanged, isNotNull,
        reason: 'with no Owner demand the switch is the member\'s own again');

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
