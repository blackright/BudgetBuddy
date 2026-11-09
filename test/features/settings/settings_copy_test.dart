import 'dart:io';

import 'package:budget_buddy/features/settings/presentation/settings_copy.dart';
import 'package:budget_buddy/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/settings_test_harness.dart';

void main() {
  const banned = <String>[
    'Budget & Direct Profiles',
    'Manage budget and direct expense profiles',
    'Money swept out of finished months',
    'Enable Budget Transfers',
    'Allow moving allocation between budget profiles',
    'Month-End',
    'Bulk Entry',
    'Audit technical details',
    'App Theme',
    'App Font Style',
    'Select Theme',
    'Select Font',
    'Our income',
    'Identity & privacy',
    'Privacy & security',
  ];

  const filler = <String>[
    'Tap to open',
    'Manage your settings',
    'More options',
    'Learn more',
  ];

  testWidgets('the rendered hub uses only approved copy', (tester) async {
    await SettingsTestHarness().pump(tester, const SettingsScreen());

    final rendered = <String>{};
    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      final value = text.data;
      if (value != null) rendered.add(value);
    }

    final allText = rendered.join('\n');
    final lower = allText.toLowerCase();

    for (final term in banned) {
      expect(
        lower,
        isNot(contains(term.toLowerCase())),
        reason: 'banned term: $term',
      );
    }
    for (final term in filler) {
      expect(rendered, isNot(contains(term)), reason: 'filler: $term');
    }
    expect(
      RegExp(r'[ÃÂâ€™œ�]').hasMatch(allText),
      isFalse,
      reason: 'encoding defect',
    );

    expect(find.text(SettingsCopy.budgeting), findsOneWidget);
    expect(find.text(SettingsCopy.sharing), findsOneWidget);
    expect(find.text(SettingsCopy.security), findsOneWidget);
    expect(find.text(SettingsCopy.appearance), findsOneWidget);
    expect(find.text(SettingsCopy.help), findsOneWidget);
    expect(find.text(SettingsCopy.advanced), findsOneWidget);
    expect(find.text(SettingsCopy.switchAction), findsOneWidget);
  });

  test('settings_copy source has no banned labels or encoding defects', () {
    final source = File(
      'lib/features/settings/presentation/settings_copy.dart',
    ).readAsStringSync();
    final lower = source.toLowerCase();

    for (final term in banned) {
      expect(
        lower,
        isNot(contains(term.toLowerCase())),
        reason: 'banned term in source: $term',
      );
    }
    expect(
      RegExp(r'[ÃÂâ€™œ�]').hasMatch(source),
      isFalse,
      reason: 'encoding defect in source',
    );
  });
}
