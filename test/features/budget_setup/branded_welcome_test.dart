import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/presentation/app_themes.dart';
import 'package:budget_buddy/shared/presentation/branding/brand_artwork.dart';
import 'package:budget_buddy/features/budget_setup/presentation/widgets/learning_steps.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('offline local branded welcome at 320/200% $brightness',
        (tester) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(MaterialApp(
            theme: buildAppTheme(brightness: brightness),
            builder: (c, w) => MediaQuery(
                data: MediaQuery.of(c).copyWith(
                    textScaler: const TextScaler.linear(2),
                    disableAnimations: true),
                child: w!),
            home: PublicSetupIntroduction(onContinue: () {})));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(BrandArtwork), findsOneWidget);
        expect(find.bySemanticsLabel('BudgetBuddy'), findsOneWidget);
        await tester.ensureVisible(find.text('Get started'));
        await tester.pumpAndSettle();
        expect(find.text('Get started').hitTestable(), findsOneWidget);
        expect(tester.hasRunningAnimations, isFalse);
      } finally {
        semantics.dispose();
      }
    });
  }
}
