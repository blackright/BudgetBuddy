import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/security/presentation/lock_keys.dart';
import 'package:budget_buddy/features/security/presentation/security_settings_screen.dart';
import 'package:budget_buddy/features/settings/presentation/settings_copy.dart';
import 'package:budget_buddy/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/settings_test_harness.dart';

void main() {
  Switch securitySwitch(WidgetTester tester) {
    return tester.widget<Switch>(
      find.descendant(
        of: find.byKey(const Key('settingsSecurityRow')),
        matching: find.byType(Switch),
      ),
    );
  }

  testWidgets('hub Security row shows the local lock state', (tester) async {
    await SettingsTestHarness().pump(tester, const SettingsScreen());

    expect(find.byKey(const Key('settingsSecurityRow')), findsOneWidget);
    expect(securitySwitch(tester).value, isFalse);
    expect(securitySwitch(tester).onChanged, isNotNull);
  });

  testWidgets('hub Security row is read-only when the Owner requires it',
      (tester) async {
    final space = settingsTestSpace()..requirePin = true;

    await SettingsTestHarness(
      spaces: [space],
      isShared: true,
      lockEnabled: true,
    ).pump(tester, const SettingsScreen());

    expect(securitySwitch(tester).value, isTrue);
    expect(securitySwitch(tester).onChanged, isNull);
    expect(find.text(SettingsCopy.required), findsOneWidget);
  });

  testWidgets('hub Security row is hidden without a lock subject',
      (tester) async {
    await SettingsTestHarness(hasLockSubject: false)
        .pump(tester, const SettingsScreen());

    expect(find.byKey(const Key('settingsSecurityRow')), findsNothing);
  });

  testWidgets('Security surface hosts the lock card and recovery entries once',
      (tester) async {
    final subject = LockSubject.profile(id: 1, name: 'Alex');
    await SettingsTestHarness().pump(
      tester,
      SecuritySettingsScreen(subject: subject),
      size: const Size(360, 1200),
    );

    expect(find.byKey(const Key('settingsSecurityScreen')), findsOneWidget);
    expect(find.text('Security'), findsOneWidget);
    expect(find.byKey(const Key(LockKeys.securitySection)), findsOneWidget);
    expect(find.byKey(const Key(LockKeys.lockSwitch)), findsOneWidget);
    expect(find.byKey(const Key('securityChangePin')), findsOneWidget);
    expect(find.byKey(const Key('securityForgotPin')), findsOneWidget);

    expect(find.byKey(const Key('securityMoreButton')), findsNothing);
    expect(find.text('Privacy & security'), findsNothing);
    expect(find.byKey(const Key(LockKeys.changePinButton)), findsNothing);
  });

  testWidgets('hub Security row opens the focused Security surface',
      (tester) async {
    await SettingsTestHarness().pump(tester, const SettingsScreen());

    await tester.tap(find.byKey(const Key('settingsSecurityRow')));
    await tester.pumpAndSettle();

    expect(find.byType(SecuritySettingsScreen), findsOneWidget);
    expect(find.byKey(const Key('settingsSecurityScreen')), findsOneWidget);
    expect(find.byKey(const Key(LockKeys.securitySection)), findsOneWidget);
    expect(find.byKey(const Key('securityChangePin')), findsOneWidget);
    expect(find.byKey(const Key('securityForgotPin')), findsOneWidget);
  });
}
