import 'package:flutter/material.dart';
import 'package:budget_buddy/core/presentation/app_themes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/features/budget_setup/presentation/introduction_screen.dart';
import 'support/phase_eight_host.dart';

void main() {
  test('actual app themes keep essential setup text readable', () {
    double contrast(Color a, Color b) {
      final x = a.computeLuminance(), y = b.computeLuminance();
      return ((x > y ? x : y) + .05) / ((x < y ? x : y) + .05);
    }

    for (final brightness in Brightness.values) {
      final c = buildAppTheme(brightness: brightness).colorScheme;
      expect(contrast(c.onSurface, c.surface), greaterThanOrEqualTo(4.5));
      expect(contrast(c.onSurfaceVariant, c.surfaceContainerLow),
          greaterThanOrEqualTo(4.5));
      expect(contrast(c.onPrimary, c.primary), greaterThanOrEqualTo(4.5));
      expect(
          contrast(
              c.onSurface,
              Color.alphaBlend(
                  c.primaryContainer.withValues(alpha: .45), c.surface)),
          greaterThanOrEqualTo(4.5));
    }
  });

  for (final brightness in Brightness.values) {
    testWidgets(
        'seven stages, review and retained error at 320 / 200%: $brightness',
        (tester) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final stage in List.generate(7, (i) => i)) {
        await pumpStage(tester, LayoutController(stage),
            brightness: brightness);
        expect(tester.takeException(), isNull, reason: 'stage $stage');
        final controls = find
            .byWidgetPredicate((w) => w is ButtonStyleButton || w is TextField)
            .evaluate()
            .map((e) => e.widget)
            .toList();
        for (final control in controls) {
          final target = find.byWidget(control);
          await tester.ensureVisible(target);
          await tester.pumpAndSettle();
          final rect = tester.getRect(target);
          expect(rect.left, greaterThanOrEqualTo(0),
              reason: '$stage $control left');
          expect(rect.right, lessThanOrEqualTo(320),
              reason: '$stage $control right');
          expect(rect.height, greaterThanOrEqualTo(48),
              reason: '$stage $control target');
          expect(target.hitTestable(), findsOneWidget,
              reason: '$stage $control reachable');
        }

        final action = find.byKey(const Key('guidedContinue'));
        await tester.ensureVisible(action);
        await tester.pumpAndSettle();
        expect(action.hitTestable(), findsOneWidget,
            reason: 'stage $stage action reachable');
        expect(tester.getSize(action).height, greaterThanOrEqualTo(48));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      }
      await pumpStage(tester, LayoutController(3, review: true),
          brightness: brightness);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byKey(const Key('guidedContinue')));
      expect(find.byKey(const Key('guidedContinue')).hitTestable(),
          findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await pumpStage(tester, LayoutController(2, failure: true),
          brightness: brightness, keyboard: 280);
      await tester.ensureVisible(find.text('Review saved setup'));
      expect(find.text('Review saved setup').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('replay chapters and examples fit small screen / large text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(phaseEightApp(const IntroductionScreen()));
    for (var i = 0; i < 3; i++) {
      expect(tester.takeException(), isNull);
      if (i > 0) {
        final tile = find.text(i == 1
            ? 'Opening money and income'
            : 'Planned, Paid and Cancelled');
        await tester.ensureVisible(tile);
        await tester.pumpAndSettle();
        await tester.tap(tile);
        await tester.pumpAndSettle();
        expect(find.text('Example'), findsWidgets);
        expect(tester.takeException(), isNull);
      }
      if (i < 2) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }
    }
    expect(find.text('Done').hitTestable(), findsOneWidget);
  });
}
