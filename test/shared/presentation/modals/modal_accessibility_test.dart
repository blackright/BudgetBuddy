import 'package:budget_buddy/core/presentation/app_themes.dart';
import 'package:budget_buddy/shared/presentation/modals/app_dialog.dart';
import 'package:budget_buddy/shared/presentation/modals/app_picker_sheet.dart';
import 'package:budget_buddy/shared/presentation/modals/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Consolidated small-screen, large-text, keyboard and dark-mode guards for the
/// shared modal primitives. The per-primitive tests cover detailed behavior;
/// this file proves the same structures survive the combined worst case.
void main() {
  void useWorstCaseSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  Widget host(ThemeData theme, VoidCallback open) => MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Center(
            child: TextButton(
              key: const Key('openOverlay'),
              onPressed: open,
              child: const Text('Open'),
            ),
          ),
        ),
      );

  for (final brightness in Brightness.values) {
    testWidgets(
        'AppDialog stays reachable at 320px, 200% text and keyboard (${brightness.name})',
        (tester) async {
      useWorstCaseSurface(tester);
      final theme = buildAppTheme(brightness: brightness);
      await tester.pumpWidget(host(theme, () {}));
      final context = tester.element(find.byKey(const Key('openOverlay')));

      showAppDialog<void>(
        context: context,
        builder: (dialog) => AppDialog(
          title: const Text('Review this save'),
          content: const Text(
            'A long explanation remains readable when the screen is narrow, '
            'the text is doubled and the keyboard is open. The primary action '
            'must stay reachable without clipping.',
          ),
          scrollable: true,
          actions: [
            TextButton(
              key: const Key('accessDialogAction'),
              onPressed: () => Navigator.of(dialog).pop(),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byKey(const Key('accessDialogAction')), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const Key('accessDialogAction')));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets(
        'AppSheet keeps its footer above the keyboard at 320px and 200% text (${brightness.name})',
        (tester) async {
      useWorstCaseSurface(tester);
      final theme = buildAppTheme(brightness: brightness);
      await tester.pumpWidget(host(theme, () {}));
      final context = tester.element(find.byKey(const Key('openOverlay')));

      showAppSheet<void>(
        context,
        builder: (_) => AppSheet(
          title: 'Review items',
          subtitle: 'The footer must remain reachable.',
          bodyScrollable: false,
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (var i = 0; i < 30; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text('Scrollable row $i with enough text to wrap.'),
                ),
            ],
          ),
          footer: OverflowBar(
            alignment: MainAxisAlignment.end,
            overflowAlignment: OverflowBarAlignment.end,
            spacing: 8,
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('Cancel'),
              ),
              FilledButton(
                key: const Key('accessSheetApply'),
                onPressed: () {},
                child: const Text('Apply'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Review items'), findsOneWidget);
      expect(find.byKey(const Key('accessSheetApply')), findsOneWidget);
      final footerBottom =
          tester.getBottomLeft(find.byKey(AppSheet.footerKey)).dy;
      expect(footerBottom, lessThanOrEqualTo(640 - 260 + 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'AppPickerSheet remains usable at 320px, 200% text and keyboard (${brightness.name})',
        (tester) async {
      useWorstCaseSurface(tester);
      final theme = buildAppTheme(brightness: brightness);
      await tester.pumpWidget(host(theme, () {}));
      final context = tester.element(find.byKey(const Key('openOverlay')));

      showAppPickerSheet<String>(
        context,
        title: 'Choose a category',
        items: const [
          AppPickerEntry(value: 'food', title: 'Food'),
          AppPickerEntry(value: 'travel', title: 'Travel'),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Choose a category'), findsOneWidget);
      expect(find.byKey(AppPickerSheet.searchKey), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
