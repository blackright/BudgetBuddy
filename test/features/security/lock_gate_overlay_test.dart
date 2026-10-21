import 'package:budget_buddy/core/models/lock_setting.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/identity/presentation/app_lock_gate.dart';
import 'package:budget_buddy/features/identity/repositories/secret_store.dart';
import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/security/presentation/lock_keys.dart';
import 'package:budget_buddy/features/security/presentation/pin_keypad.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import 'package:budget_buddy/features/security/repositories/monotonic_clock_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_monotonic_clock.dart';
import 'support/fake_pin_kdf.dart';
import 'support/in_memory_lock_settings_store.dart';

/// The 016 gate must be mounted **the way `main.dart` mounts it** — as
/// `MaterialApp.builder`, which sits *above* the Navigator — because that is
/// where it replaces the tree's only [Overlay].
///
/// The other gate tests (T015/T017) mount the gate inside `home`, i.e. *under*
/// the Navigator, where an Overlay is always present. That hides the defect this
/// test pins: with the gate above the Navigator, returning the lock screen in
/// place of the child removed the only Overlay, so the PIN keypad's [Tooltip]
/// threw "No Overlay widget found" the moment the challenge opened (the crash
/// reported on the device, `RawTooltip` "Delete" at `pin_keypad.dart`).
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

  setUp(() async {
    secrets = InMemorySecretStore();
    settings = InMemoryLockSettingsStore();
    await settings.upsert(LockSetting.forSubject(subject)..lockEnabled = true);
  });

  tearDown(() => settings.dispose());

  Widget host() => ProviderScope(
        overrides: [
          lockSubjectProvider.overrideWithValue(subject),
          lockSettingRepositoryProvider.overrideWithValue(settings),
          secretStoreProvider.overrideWithValue(secrets),
          pinKdfProvider.overrideWithValue(FakePinKdf()),
          monotonicClockProvider.overrideWithValue(FakeMonotonicClock()),
          // The 015 gate reads these once 016 is quiet; keep them off Isar so no
          // async database stream is left open in the widget tree.
          identityProvider.overrideWith((ref) => Stream.value(null)),
          consentProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: MaterialApp(
          builder: (context, child) =>
              AppLockGate(child: child ?? const SizedBox.shrink()),
          home: const Scaffold(body: Text('secret app')),
        ),
      );

  testWidgets('the locked gate still hides the app behind it (FR-023)',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pump();

    expect(find.text('secret app'), findsNothing,
        reason: 'not one frame of the app may show behind the lock');
    expect(find.byKey(const Key(LockKeys.unlockButton)), findsOneWidget);
  });

  testWidgets('the PIN keypad opens with an Overlay present', (tester) async {
    await tester.pumpWidget(host());
    await tester.pump();

    await tester.tap(find.byKey(const Key(LockKeys.unlockButton)));
    await tester.pump();

    // The keypad's action keys carry tooltips, and a tooltip needs an Overlay
    // ancestor. Without one this pump reports "No Overlay widget found".
    expect(tester.takeException(), isNull,
        reason: 'the lock screen must own an Overlay (a one-page Navigator)');
    expect(find.byType(PinKeypad), findsOneWidget);
    expect(find.byKey(const Key(LockKeys.pinBackspace)), findsOneWidget);
  });
}
