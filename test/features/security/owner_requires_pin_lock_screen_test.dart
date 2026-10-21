import 'package:budget_buddy/core/models/lock_setting.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/identity/repositories/secret_store.dart';
import 'package:budget_buddy/features/security/domain/away_time.dart';
import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/security/presentation/lock_keys.dart';
import 'package:budget_buddy/features/security/presentation/lock_screen.dart';
import 'package:budget_buddy/features/security/presentation/pin_setup_screen.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import 'package:budget_buddy/features/security/repositories/monotonic_clock_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_monotonic_clock.dart';
import 'support/fake_pin_kdf.dart';
import 'support/in_memory_lock_settings_store.dart';

/// T061 (FR-027, FR-028): when a space Owner requires a PIN and the member has
/// not set one, the lock screen **explains why** and offers to set one up.
///
/// This is the difference between a lock and a wall: a member who never chose a
/// PIN must be told an Owner demanded one and be given the means to satisfy it,
/// rather than being left staring at an Unlock button that cannot work.
void main() {
  const subject = LockSubject(
    kind: LockSubjectKind.space,
    localId: 1,
    guid: 'guid-owner',
    name: 'Our space',
    avatar: '🏠',
  );

  late InMemorySecretStore secrets;
  late InMemoryLockSettingsStore settings;

  SharedSpace spaceRequiring({required bool requirePin}) {
    final space = SharedSpace()
      ..id = 1
      ..syncGuid = 'guid-owner'
      ..name = 'Our space'
      ..avatar = '🏠'
      ..currency = PrimaryCurrency.usd
      ..defaultIncome = 0
      ..createdByProfileId = 1
      ..createdAt = DateTime.utc(2026, 1, 2)
      ..requirePin = requirePin;
    space.awayTime = AwayTime.twoMinutes;
    return space;
  }

  setUp(() {
    secrets = InMemorySecretStore();
    settings = InMemoryLockSettingsStore();
  });

  tearDown(() => settings.dispose());

  Widget host(SharedSpace space, {LockSubject? lockSubject = subject}) =>
      ProviderScope(
        overrides: [
          lockSubjectProvider.overrideWithValue(lockSubject),
          lockSettingRepositoryProvider.overrideWithValue(settings),
          secretStoreProvider.overrideWithValue(secrets),
          pinKdfProvider.overrideWithValue(FakePinKdf()),
          monotonicClockProvider.overrideWithValue(FakeMonotonicClock()),
          activeSpaceProvider.overrideWith((ref) => Stream.value(space)),
          identityProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: MaterialApp(home: LockScreen(subject: lockSubject)),
      );

  testWidgets('the Owner\'s requirement is explained and a PIN is offered',
      (tester) async {
    await tester.pumpWidget(host(spaceRequiring(requirePin: true)));
    await tester.pump();
    await tester.pump();

    expect(
      find.text('The Owner of this space requires a PIN. Set one up to '
          'continue.'),
      findsOneWidget,
      reason: 'the member is told *why* they are locked out',
    );
    expect(find.text('Set up PIN'), findsOneWidget,
        reason: 'and given the means to satisfy it');
    expect(find.byKey(const Key(LockKeys.unlockButton)), findsNothing,
        reason: 'an Unlock the member cannot satisfy must not be offered');

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('tapping Set up PIN opens the PIN setup screen', (tester) async {
    await tester.pumpWidget(host(spaceRequiring(requirePin: true)));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Set up PIN'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key(LockKeys.pinSetupScreen)), findsOneWidget);
    // The forgotten-PIN warning still rides above the keypad (FR-039): even a
    // member forced into a PIN is told what forgetting it means first.
    expect(find.textContaining('cannot be recovered'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('without an Owner requirement the plain Unlock is shown',
      (tester) async {
    await tester.pumpWidget(host(spaceRequiring(requirePin: false)));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key(LockKeys.unlockButton)), findsOneWidget,
        reason: 'a member with their own lock gets the ordinary way in');
    expect(find.text('Set up PIN'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a locked-out wait survives and is still offered the PIN path',
      (tester) async {
    // A row with the lock on, so `effectiveLockProvider` has something to gate.
    await settings.upsert(
      LockSetting.forSubject(subject)
        ..lockEnabled = true
        ..awayTime = AwayTime.twoMinutes,
    );

    await tester.pumpWidget(host(spaceRequiring(requirePin: true)));
    await tester.pump();
    await tester.pump();

    // The Owner path is decided by the space, not by the member's row, so the
    // "Set up PIN" offer must not disappear just because a row exists.
    expect(find.text('Set up PIN'), findsOneWidget);
    expect(find.byType(PinSetupScreen), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
