import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/features/budget_setup/presentation/widgets/learning_steps.dart';
import 'package:budget_buddy/features/budget_setup/presentation/widgets/setup_form_components.dart';
import 'support/phase_eight_host.dart';
import 'support/financial_drafts.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_finance.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_state.dart';

class _RejectOnceController extends LayoutController {
  _RejectOnceController() : super(2);
  bool fail = true;
  @override
  Future<void> next() async {
    if (fail) {
      fail = false;
      throw StateError('injected failure');
    }
    await super.next();
  }
}

void main() {
  testWidgets(
      'missing currency focuses its dropdown without losing profile name',
      (tester) async {
    final draft = replaceOnboardingDraft(financialDraft(),
        profile: const OnboardingProfileDraft(name: 'Jason'));
    await pumpStage(tester, LayoutController(2, initial: draft));
    await tester.ensureVisible(find.byKey(const Key('guidedContinue')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('guidedContinue')));
    await tester.pumpAndSettle();
    final dropdown = find.byKey(const Key('financialCurrency'));
    expect(dropdown.hitTestable(), findsOneWidget);
    expect(
        find.descendant(
            of: dropdown,
            matching: find.byWidgetPredicate(
                (w) => w is Focus && w.focusNode?.hasFocus == true)),
        findsWidgets);
    expect(find.text('Jason'), findsWidgets);
  });

  testWidgets('invalid source dates reveal and focus the date choices',
      (tester) async {
    final c = LayoutController(3);
    c.updateSource('salary-1',
        startDate: DateTime(2026, 10, 20), endDate: DateTime(2026, 10, 1));
    c.toggleSource('salary-1');
    await pumpStage(tester, c);
    await tester.ensureVisible(find.byKey(const Key('guidedContinue')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('guidedContinue')));
    await tester.pumpAndSettle();
    final target = find.byWidgetPredicate(
        (w) => w is SetupValidationTarget && w.error != null);
    expect(target, findsOneWidget);
    expect(
        find.descendant(
            of: target,
            matching: find.byWidgetPredicate(
                (w) => w is Focus && w.focusNode?.hasFocus == true)),
        findsWidgets);
    expect(find.textContaining('Starts ').hitTestable(), findsOneWidget);
  });

  testWidgets('Retry repeats the failed step and retains entries',
      (tester) async {
    final c = _RejectOnceController();
    await pumpStage(tester, c);
    await tester.ensureVisible(find.byKey(const Key('guidedContinue')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('guidedContinue')));
    await tester.pumpAndSettle();
    expect(find.text('Retry this step'), findsOneWidget);
    expect(c.state.draft.profile.name, 'Jason');
    await tester.ensureVisible(find.text('Retry this step'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retry this step'));
    await tester.pumpAndSettle();
    expect(find.text('Step 4 of 7'), findsOneWidget);
    expect(find.text('Retry this step'), findsNothing);
  });
  testWidgets(
      'missing income choice focuses its action group with a persistent message',
      (tester) async {
    final c = LayoutController(3,
        initial: financialDraft(incomeChoice: OnboardingIncomeChoice.unset));
    await pumpStage(tester, c);
    await tester.ensureVisible(find.byKey(const Key('guidedContinue')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('guidedContinue')));
    await tester.pumpAndSettle();
    final target = find.byWidgetPredicate(
        (w) => w is SetupValidationTarget && w.error != null);
    expect(target, findsOneWidget);
    final focus = find.descendant(
        of: target,
        matching: find.byWidgetPredicate(
            (w) => w is Focus && w.focusNode?.hasFocus == true));
    expect(focus, findsWidgets);
    expect(
        find.byKey(const Key('addIncomeSource')).hitTestable(), findsOneWidget);
  });

  testWidgets('Continue reveals and focuses first invalid profile field',
      (tester) async {
    final c = LayoutController(2);
    c.setProfileName('');
    await pumpStage(tester, c);
    await tester.ensureVisible(find.byKey(const Key('guidedContinue')));
    await tester.tap(find.byKey(const Key('guidedContinue')));
    await tester.pumpAndSettle();
    final input = find.descendant(
        of: find.byKey(const Key('financialProfileName')),
        matching: find.byType(EditableText));
    expect(tester.widget<EditableText>(input).focusNode.hasFocus, isTrue);
    expect(find.byKey(const Key('financialProfileName')).hitTestable(),
        findsOneWidget);
  });
  testWidgets(
      'collapsed invalid source expands and focuses amount before notes',
      (tester) async {
    final c = LayoutController(3);
    c.updateSource('salary-1', amountText: '');
    c.toggleSource('salary-1');
    await pumpStage(tester, c);
    await tester.ensureVisible(find.byKey(const Key('guidedContinue')));
    await tester.tap(find.byKey(const Key('guidedContinue')));
    await tester.pumpAndSettle();
    final input = find.descendant(
        of: find.byKey(const Key('sourceAmount-salary-1')),
        matching: find.byType(EditableText));
    expect(input, findsOneWidget);
    expect(tester.widget<EditableText>(input).focusNode.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(tester.widget<EditableText>(input).focusNode.hasFocus, isFalse);
  });
  testWidgets(
      'semantic progress, target sizes and static reduced-motion examples',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await pumpStage(tester, LayoutController(3), reduced: true);
      expect(find.bySemanticsLabel('Your first month, step 4 of 7'),
          findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('.*Salary.*income source.*')),
          findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('noIncomeYet')));
      expect(tester.getSize(find.byKey(const Key('noIncomeYet'))).height,
          greaterThanOrEqualTo(48));
      await tester.pumpWidget(phaseEightApp(
          const Scaffold(body: SingleChildScrollView(child: LearningSteps())),
          reduced: true));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ExpansionTile).first);
      await tester.pump();
      expect(find.text('Example'), findsOneWidget);
      final height = tester.getSize(find.byType(ExpansionTile).first).height;
      await tester.pump(const Duration(seconds: 1));
      expect(tester.getSize(find.byType(ExpansionTile).first).height, height);
    } finally {
      semantics.dispose();
    }
  });
  testWidgets('input error is explicitly announced, not color alone',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(phaseEightApp(Scaffold(
          body: SetupInput(
              label: 'Amount',
              text: '',
              onChanged: (_) {},
              error: 'Enter a positive amount.'))));
      expect(
          find.byWidgetPredicate((w) =>
              w is Semantics &&
              w.properties.liveRegion == true &&
              w.properties.label == 'Enter a positive amount.'),
          findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });
}
