import 'package:flutter/material.dart';
import 'package:budget_buddy/core/presentation/app_themes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_state.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_finance.dart';
import 'package:budget_buddy/features/budget_setup/providers/budget_setup_provider.dart';
import 'package:budget_buddy/features/budget_setup/presentation/guided_setup_screen.dart';
import 'package:budget_buddy/features/budget_setup/presentation/widgets/security_setup_step.dart';
import 'financial_drafts.dart';

// Presentation fixtures only: no authentication or financial save is simulated.
class LayoutController extends FinancialSetupController {
  LayoutController(int stage,
      {bool review = false, bool failure = false, OnboardingState? initial})
      : super(initial: initial ?? financialDraft()) {
    final draft = state.draft;
    final committed = stage >= 4
        ? OnboardingCommitReference(
            profileId: 7,
            budgetId: 9,
            budgetSyncGuid: 'fixture',
            yearMonth: draft.yearMonth!,
            revision: 0,
            digest: 'fixture',
            sourceIds: {'salary-1': 1})
        : null;
    progress = OnboardingState(
        flowId: draft.flowId,
        revision: 0,
        createdAt: draft.createdAt,
        updatedAt: draft.updatedAt,
        step: OnboardingStep.values[stage],
        committed: committed,
        categoriesReady: stage >= 4,
        directoryReady: stage >= 4,
        securityChoice: OnboardingSecurityChoice.notNow);
    state = FinancialSetupView(
        draft: draft,
        page: stage == 3 ? (review ? 2 : 1) : 0,
        receipt: committed,
        expandedSourceGuid: 'salary-1',
        review: review ? OnboardingFinance.review(draft) : null,
        error: failure ? 'Could not save. Your entries are retained.' : null);
  }
  late OnboardingState progress;
  @override
  OnboardingState? get savedProgress => progress;
  @override
  bool get preparationReady => true;
  @override
  Future<void> checkpoint(OnboardingStep step) async {}
}

Widget phaseEightApp(Widget child,
        {Brightness brightness = Brightness.light,
        bool reduced = false,
        double keyboard = 0}) =>
    MaterialApp(
        theme: buildAppTheme(brightness: brightness),
        builder: (context, body) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(2),
                disableAnimations: reduced,
                viewInsets: EdgeInsets.only(bottom: keyboard)),
            child: body!),
        home: child);

Future<void> pumpStage(WidgetTester tester, LayoutController controller,
    {Brightness brightness = Brightness.light,
    bool reduced = false,
    double keyboard = 0}) async {
  await tester.pumpWidget(ProviderScope(
      overrides: [
        financialSetupProvider.overrideWith((ref) => controller),
        // Deliberately unresolved protection owner exercises the persistent error UI.
        activeProfileProvider
            .overrideWith((ref) => Stream<UserProfile?>.value(null)),
        setupProtectionStatusProvider
            .overrideWith((ref, key) async => SetupProtection.notConfigured),
      ],
      child: phaseEightApp(const GuidedSetupScreen(),
          brightness: brightness, reduced: reduced, keyboard: keyboard)));
  await tester.pumpAndSettle();
}
