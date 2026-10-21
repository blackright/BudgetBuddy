import 'package:budget_buddy/core/models/lock_setting.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/identity/repositories/secret_store.dart';
import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/security/domain/pin_result.dart';
import 'package:budget_buddy/features/security/presentation/lock_keys.dart';
import 'package:budget_buddy/features/security/presentation/lock_screen.dart';
import 'package:budget_buddy/features/security/presentation/pin_keypad.dart';
import 'package:budget_buddy/features/security/presentation/pin_screen.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import 'package:budget_buddy/features/security/repositories/monotonic_clock_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_monotonic_clock.dart';
import 'support/fake_pin_kdf.dart';
import 'support/in_memory_lock_settings_store.dart';

/// T070 (contract §5, constitution VI): a screen reader can operate the lock,
/// and the screens keep the app's theme and dark mode.
///
/// The keypad and the PIN screen already carried labels; the lock screen did
/// not, so a blind user met an unlabelled avatar and an Unlock button announced
/// only as "button". These assertions are deliberately about the *spoken* tree —
/// what `find.bySemanticsLabel` can reach — not about pixels, because a label
/// that is not in the semantics tree does not help anyone.
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
  late FakeMonotonicClock clock;

  setUp(() {
    secrets = InMemorySecretStore();
    settings = InMemoryLockSettingsStore();
    clock = FakeMonotonicClock();
  });

  tearDown(() => settings.dispose());

  Widget host(Widget child, {ThemeData? theme}) => ProviderScope(
        overrides: [
          lockSubjectProvider.overrideWithValue(subject),
          lockSettingRepositoryProvider.overrideWithValue(settings),
          secretStoreProvider.overrideWithValue(secrets),
          pinKdfProvider.overrideWithValue(FakePinKdf()),
          monotonicClockProvider.overrideWithValue(clock),
          identityProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: MaterialApp(theme: theme, home: child),
      );

  testWidgets('the lock screen announces who is locked and the way in',
      (tester) async {
    final handle = tester.ensureSemantics();
    await settings.upsert(LockSetting.forSubject(subject)..lockEnabled = true);

    await tester.pumpWidget(host(const LockScreen(subject: subject)));
    await tester.pump();
    await tester.pump();

    expect(find.bySemanticsLabel('Ann, locked'), findsOneWidget,
        reason: 'the avatar and name are one spoken unit');
    expect(find.bySemanticsLabel('Unlock'), findsOneWidget,
        reason: 'the single way in must be announced, not just present');
    expect(find.byKey(const Key(LockKeys.unlockButton)), findsOneWidget);

    handle.dispose();
  });

  testWidgets('the lock screen renders under a dark theme (VI)',
      (tester) async {
    await settings.upsert(LockSetting.forSubject(subject)..lockEnabled = true);

    await tester.pumpWidget(host(
      const LockScreen(subject: subject),
      theme: ThemeData.dark(),
    ));
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull, reason: 'dark mode must not throw');
    expect(find.byKey(const Key(LockKeys.unlockButton)), findsOneWidget);
  });

  testWidgets('every keypad digit is independently labelled (contract §5)',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(PinKeypad(value: '', onChanged: (_) {})));
    await tester.pump();

    for (var digit = 0; digit <= 9; digit++) {
      expect(find.bySemanticsLabel('Digit $digit'), findsOneWidget,
          reason: 'a screen reader must reach every digit on its own');
    }
    expect(find.bySemanticsLabel('Delete'), findsOneWidget);
    expect(find.bySemanticsLabel('Confirm PIN'), findsOneWidget);

    handle.dispose();
  });

  testWidgets('the lockout countdown is announced (contract §5)',
      (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(host(
      PinScreen(
        subject: subject,
        onSubmit: (_) async => PinResult.wrongPin,
        remainingWait: () => const Duration(seconds: 30),
      ),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key(LockKeys.lockoutCountdown)), findsOneWidget,
        reason: 'a running wait must be shown on the PIN screen');
    // The countdown sits inside a liveRegion Semantics wrapper, so its text is
    // reachable by its spoken label.
    expect(
      find.bySemanticsLabel(RegExp('Too many attempts')),
      findsOneWidget,
      reason: 'the countdown must announce as it changes, not sit silent',
    );

    handle.dispose();
  });
}
