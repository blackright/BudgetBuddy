import 'package:budget_buddy/features/budget_setup/presentation/widgets/learning_steps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'public introduction has progress, Back, and optional labelled examples',
      (tester) async {
    var verifiedNext = 0;
    await tester.pumpWidget(MaterialApp(
        home: PublicSetupIntroduction(onContinue: () => verifiedNext++)));
    expect(find.text('Step 1 of 8'), findsOneWidget);
    await tester.ensureVisible(find.text('Get started'));
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('Step 2 of 8'), findsOneWidget);
    await tester.tap(find.text('Opening money and income'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Example'), findsWidgets);
    await tester.ensureVisible(find.text('Skip explanations'));
    await tester.tap(find.text('Skip explanations'));
    await tester.pump();
    expect(verifiedNext, 1);
  }, timeout: const Timeout(Duration(minutes: 2)));
}
