import 'package:budget_buddy/features/settings/presentation/settings_screen.dart';
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

  for (final width in <double>[320, 360, 412]) {
    for (final scale in <double>[1, 2]) {
      testWidgets(
        'fits at ${width.toInt()} dp and ${(scale * 100).toInt()}% text',
        (tester) async {
          await SettingsTestHarness().pump(
            tester,
            const SettingsScreen(),
            size: Size(width, scale == 1 ? 640 : 1600),
            textScale: scale,
          );

          expect(tester.takeException(), isNull);
          expect(
              find.byKey(const Key('settingsContextHeader')), findsOneWidget);
          expect(find.byKey(const Key('settingsHubCard')), findsOneWidget);
          for (final key in rowKeys) {
            expect(find.byKey(Key(key)), findsOneWidget, reason: key);
          }
        },
      );
    }
  }

  testWidgets('shows the whole hub on 360 x 640 at default text',
      (tester) async {
    await SettingsTestHarness().pump(
      tester,
      const SettingsScreen(),
      size: const Size(360, 640),
    );

    expect(
      tester.getBottomLeft(find.byKey(const Key('settingsAdvancedRow'))).dy,
      lessThanOrEqualTo(640),
    );
  });

  testWidgets('meets the 48 dp target for the header, rows and switch',
      (tester) async {
    await SettingsTestHarness().pump(
      tester,
      const SettingsScreen(),
      size: const Size(360, 800),
    );

    for (final key in ['settingsContextHeader', ...rowKeys]) {
      final size = tester.getSize(find.byKey(Key(key)));
      expect(size.width, greaterThanOrEqualTo(48), reason: key);
      expect(size.height, greaterThanOrEqualTo(48), reason: key);
    }

    final switchSize = tester.getSize(
      find.descendant(
        of: find.byKey(const Key('settingsSecurityRow')),
        matching: find.byType(Switch),
      ),
    );
    expect(switchSize.width, greaterThanOrEqualTo(48));
    expect(switchSize.height, greaterThanOrEqualTo(48));
  });

  testWidgets('card lines stay visible in light and dark mode', (tester) async {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await SettingsTestHarness().pump(
        tester,
        const SettingsScreen(),
        size: const Size(360, 800),
        themeMode: mode,
      );

      final context = tester.element(find.byKey(const Key('settingsHubCard')));
      final outline = Theme.of(context).colorScheme.outlineVariant;

      final hub = tester.widget<Material>(
        find.byKey(const Key('settingsHubCard')),
      );
      final hubShape = hub.shape! as RoundedRectangleBorder;
      expect(hubShape.side.color, outline, reason: '$mode hub');
      expect(hubShape.side.width, 1, reason: '$mode hub width');

      final header = tester.widget<Material>(
        find
            .descendant(
              of: find.byKey(const Key('settingsContextHeader')),
              matching: find.byType(Material),
            )
            .first,
      );
      final headerShape = header.shape! as RoundedRectangleBorder;
      expect(headerShape.side.color, outline, reason: '$mode header');
      expect(headerShape.side.width, 1, reason: '$mode header width');
    }
  });
}
