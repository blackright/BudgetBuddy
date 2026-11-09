import 'package:budget_buddy/features/security/presentation/security_settings_screen.dart';
import 'package:budget_buddy/features/settings/presentation/settings_advanced_screen.dart';
import 'package:budget_buddy/features/settings/presentation/settings_budgeting_screen.dart';
import 'package:budget_buddy/features/settings/presentation/settings_copy.dart';
import 'package:budget_buddy/features/settings/presentation/settings_help_screen.dart';
import 'package:budget_buddy/features/settings/presentation/settings_profile_space_screen.dart';
import 'package:budget_buddy/features/settings/presentation/settings_screen.dart';
import 'package:budget_buddy/features/settings/presentation/settings_sharing_screen.dart';
import 'package:budget_buddy/features/settings/presentation/widgets/settings_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/settings_test_harness.dart';

void main() {
  const rowKeys = <String>[
    'settingsBudgetingRow',
    'settingsSharingRow',
    'settingsSecurityRow',
    'settingsAppearanceRow',
    'settingsHelpRow',
    'settingsAdvancedRow',
  ];

  Future<void> pumpHub(
    WidgetTester tester, {
    SettingsTestHarness? harness,
  }) {
    return (harness ?? SettingsTestHarness()).pump(
      tester,
      const SettingsScreen(),
    );
  }

  testWidgets('shows the context header and six rows in order', (tester) async {
    await pumpHub(tester);

    expect(find.text(SettingsCopy.settingsTitle), findsOneWidget);
    expect(find.byKey(const Key('settingsContextHeader')), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);
    expect(find.text('Personal · HUF'), findsOneWidget);
    expect(find.text(SettingsCopy.switchAction), findsOneWidget);

    for (final key in rowKeys) {
      expect(find.byKey(Key(key)), findsOneWidget, reason: key);
    }

    for (var index = 0; index < rowKeys.length - 1; index++) {
      expect(
        tester.getTopLeft(find.byKey(Key(rowKeys[index]))).dy,
        lessThan(tester.getTopLeft(find.byKey(Key(rowKeys[index + 1]))).dy),
        reason: '${rowKeys[index]} must be above ${rowKeys[index + 1]}',
      );
    }

    expect(find.text(SettingsCopy.budgetingSummary), findsOneWidget);
    expect(find.text(SettingsCopy.helpSummary), findsOneWidget);
    expect(find.text(SettingsCopy.advancedSummary), findsOneWidget);
    expect(find.text('Income'), findsNothing);
    expect(find.text('Profiles'), findsNothing);

    final securitySwitch = tester.widget<Switch>(
      find.descendant(
        of: find.byKey(const Key('settingsSecurityRow')),
        matching: find.byType(Switch),
      ),
    );
    expect(securitySwitch.value, isFalse);
    expect(securitySwitch.onChanged, isNotNull);
  });

  testWidgets('shows the shared space instead of Personal', (tester) async {
    await pumpHub(tester, harness: SettingsTestHarness(isShared: true));

    expect(find.text('Home · HUF'), findsOneWidget);
    expect(find.text('Personal · HUF'), findsNothing);
    expect(find.text('Alex'), findsOneWidget);
  });

  testWidgets('hides Security when there is no lock subject', (tester) async {
    await pumpHub(tester, harness: SettingsTestHarness(hasLockSubject: false));

    expect(find.byKey(const Key('settingsSecurityRow')), findsNothing);
    expect(find.byKey(const Key('settingsBudgetingRow')), findsOneWidget);
    expect(find.byKey(const Key('settingsAdvancedRow')), findsOneWidget);
  });

  testWidgets('opens every surface from its row', (tester) async {
    await pumpHub(tester);

    await tester.tap(find.byKey(const Key('settingsContextHeader')));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsProfileSpaceScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settingsBudgetingRow')));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsBudgetingScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settingsSharingRow')));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsSharingScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settingsSecurityRow')));
    await tester.pumpAndSettle();
    expect(find.byType(SecuritySettingsScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settingsAppearanceRow')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settingsAppearanceSheet')), findsOneWidget);
    await tester.tap(find.byKey(const Key('appSheetClose')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settingsHelpRow')));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsHelpScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settingsAdvancedRow')));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsAdvancedScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
  });

  testWidgets('the Security switch reflects and protects the lock state',
      (tester) async {
    final space = settingsTestSpace()..requirePin = true;
    await pumpHub(
      tester,
      harness: SettingsTestHarness(
        spaces: [space],
        isShared: true,
        lockEnabled: true,
      ),
    );

    final securitySwitch = tester.widget<Switch>(
      find.descendant(
        of: find.byKey(const Key('settingsSecurityRow')),
        matching: find.byType(Switch),
      ),
    );
    expect(securitySwitch.value, isTrue);
    expect(securitySwitch.onChanged, isNull);
    expect(find.text(SettingsCopy.required), findsOneWidget);
  });

  testWidgets('a trailing switch does not trigger the row action',
      (tester) async {
    var switched = false;
    var opened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Material(
            child: SettingsRow(
              title: SettingsCopy.security,
              summary: SettingsCopy.appLockOff,
              icon: Icons.lock_outline,
              excludeSemantics: false,
              onTap: () => opened = true,
              trailing: Switch(
                value: false,
                onChanged: (_) => switched = true,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Switch));
    expect(switched, isTrue);
    expect(opened, isFalse);
  });
}
