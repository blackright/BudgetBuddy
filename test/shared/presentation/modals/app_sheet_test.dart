import 'package:budget_buddy/core/presentation/app_themes.dart';
import 'package:budget_buddy/shared/presentation/modals/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(ThemeData theme, VoidCallback onOpen) => MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Center(
            child: TextButton(
              key: const Key('openSheet'),
              onPressed: onOpen,
              child: const Text('Open sheet'),
            ),
          ),
        ),
      );

  void openSheet(
    WidgetTester tester, {
    required BuildContext context,
    required Widget body,
  }) {
    showAppSheet<void>(
      context,
      builder: (_) => AppSheet(
        title: 'Review items',
        subtitle: 'Only one purchase is affected.',
        body: body,
        footer: OverflowBar(
          alignment: MainAxisAlignment.end,
          overflowAlignment: OverflowBarAlignment.end,
          spacing: 12,
          children: [
            TextButton(
              key: const Key('sheetReset'),
              onPressed: () {},
              child: const Text('Reset'),
            ),
            FilledButton(
              key: const Key('sheetApply'),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  testWidgets('sheet header, body and sticky footer stay reachable',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    for (final brightness in Brightness.values) {
      final theme = buildAppTheme(brightness: brightness);
      await tester.pumpWidget(host(theme, () {}));
      final context = tester.element(find.byKey(const Key('openSheet')));
      openSheet(
        tester,
        context: context,
        body: Column(
          children: [
            for (var i = 0; i < 30; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('Line $i with enough text to require scrolling.'),
              ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Review items'), findsOneWidget);
      expect(find.byKey(AppSheet.footerKey), findsOneWidget);
      expect(tester.takeException(), isNull);

      final footerBefore = tester.getRect(find.byKey(AppSheet.footerKey));
      await tester.drag(find.byKey(AppSheet.bodyKey), const Offset(0, -240));
      await tester.pumpAndSettle();
      final footerAfter = tester.getRect(find.byKey(AppSheet.footerKey));
      expect(footerAfter.top, closeTo(footerBefore.top, 1));
      expect(find.byKey(const Key('sheetApply')), findsOneWidget);

      await tester.tap(find.byKey(const Key('sheetApply')));
      await tester.pumpAndSettle();
      expect(find.text('Review items'), findsNothing);
    }
  });

  testWidgets('keyboard inset keeps the footer above the keyboard',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    addTearDown(tester.view.resetViewInsets);

    final theme = buildAppTheme(brightness: Brightness.light);
    await tester.pumpWidget(host(theme, () {}));
    final context = tester.element(find.byKey(const Key('openSheet')));
    openSheet(
      tester,
      context: context,
      body: const TextField(
        autofocus: true,
        decoration: InputDecoration(labelText: 'Search'),
      ),
    );
    await tester.pumpAndSettle();

    final footerBottom =
        tester.getBottomLeft(find.byKey(AppSheet.footerKey)).dy;
    expect(footerBottom, lessThanOrEqualTo(844 - 260 + 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the close button and barrier dismiss the sheet', (tester) async {
    final theme = buildAppTheme(brightness: Brightness.light);
    await tester.pumpWidget(host(theme, () {}));
    final context = tester.element(find.byKey(const Key('openSheet')));

    openSheet(tester, context: context, body: const Text('Short body'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(AppSheet.closeKey));
    await tester.pumpAndSettle();
    expect(find.text('Review items'), findsNothing);

    openSheet(tester, context: context, body: const Text('Short body'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Review items'), findsNothing);
  });
}
