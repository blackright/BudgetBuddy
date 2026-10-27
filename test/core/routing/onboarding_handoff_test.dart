import 'package:budget_buddy/features/budget_setup/providers/setup_handoff_provider.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_progress.dart';
import 'package:budget_buddy/features/budget_setup/providers/budget_setup_provider.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_buddy/core/routing/app_router.dart';
import 'package:budget_buddy/core/routing/router_providers.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_startup.dart';
import 'package:budget_buddy/features/budget_setup/providers/onboarding_rollout_provider.dart';
import 'package:budget_buddy/features/budget_setup/providers/onboarding_readiness_provider.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/app_settings.dart';
import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_finance.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_state.dart';
import 'package:budget_buddy/features/budget_setup/repositories/onboarding_repository.dart';
import '../../features/medical/repositories/medical_test_harness.dart';
import '../../features/budget_setup/support/financial_drafts.dart';

void main() {
  test('native session lost during financial transaction rolls back all writes',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    final repo = OnboardingRepository(h.isar);
    final d = await repo.saveDraft(financialDraft(), expectedRevision: null);
    final review = OnboardingFinance.review(d);
    var checks = 0;
    await expectLater(
        repo.commitCore(d,
            reviewedDigest: review.digest,
            expectedRevision: d.revision,
            isAuthorized: () => ++checks == 1),
        throwsA(isA<OnboardingCommitException>()));
    expect(await h.isar.userProfiles.count(), 0);
    expect(await h.isar.monthlyBudgets.count(), 0);
    expect(await h.isar.incomeSources.count(), 0);
    expect((await repo.readStartupState()).state!.stage, OnboardingStage.draft);
  });

  test('financial coordinator saves after guided checkpoints and Back',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    final repo = OnboardingRepository(h.isar);
    final c = FinancialSetupController(
        initial: financialDraft(), autoSave: true, repository: repo);
    addTearDown(c.dispose);
    await c.next();
    await c.checkpoint(OnboardingStep.firstMonth);
    await c.goTo(0);
    await c.checkpoint(OnboardingStep.profile);
    await c.next();
    await c.checkpoint(OnboardingStep.firstMonth);
    await c.next();
    await c.save();
    expect(c.state.receipt, isNotNull, reason: c.state.error);
    expect(c.state.page, 2);
  });

  testWidgets(
      'actual router blocks early deep links then opens exact personal month',
      (tester) async {
    final refresh = ValueNotifier(OnboardingStartup(StartupKind.resumeSetup));
    addTearDown(refresh.dispose);
    final c = ProviderContainer(overrides: [
      activeProfileIdProvider.overrideWith((ref) => 7),
      activeProfileProvider.overrideWith((ref) => Stream.value(UserProfile()
        ..id = 7
        ..name = 'Jason')),
      activeSpaceProvider.overrideWith((ref) => Stream.value(null)),
      medicalBillsProvider.overrideWith((ref) => Stream.value([])),
      selectedYearMonthProvider.overrideWith((ref) => '2025-01')
    ]);
    final router = createAppRouter(
        initialLocation: '/income_sources',
        refreshListenable: refresh,
        redirect: (_, state) =>
            onboardingRedirect(refresh.value, state.uri.path),
        setupBuilder: (_) => const Text('Setup destination'),
        dashboardBuilder: (_) => Consumer(
            builder: (_, ref, __) => Text(
                'Owner ${ref.watch(activeProfileIdProvider)} month ${ref.watch(selectedYearMonthProvider)}')));
    addTearDown(router.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: c, child: MaterialApp.router(routerConfig: router)));
    await tester.pumpAndSettle();
    expect(find.text('Setup destination'), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/setup');
    refresh.value = OnboardingStartup(StartupKind.establishedUser);
    await tester.pumpAndSettle();
    expect(find.text('Owner 7 month 2025-01'), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/dashboard');
    router.go('/setup');
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/dashboard');
    await tester.pumpWidget(const SizedBox.shrink());
    c.dispose();
  });
  test(
      'reactive production router keeps the same instance during startup updates',
      () async {
    final startup = StreamController<OnboardingStartup>();
    addTearDown(startup.close);
    final c = ProviderContainer(overrides: [
      unifiedOnboardingEnabledProvider.overrideWithValue(true),
      onboardingStartupProvider.overrideWith((ref) => startup.stream)
    ]);
    addTearDown(c.dispose);
    final router = c.read(routerProvider);
    startup.add(OnboardingStartup(StartupKind.firstSetup));
    await pumpEventQueue();
    expect(identical(c.read(routerProvider), router), isTrue);
    final review = OnboardingFinance.review(financialDraft());
    final receipt = OnboardingCommitReference(
        profileId: 7,
        budgetId: 9,
        budgetSyncGuid: 'month-guid',
        yearMonth: '2025-01',
        revision: 0,
        digest: review.digest,
        sourceIds: {'salary-1': 1});
    final pending = progressCopy(review.normalized,
        stage: OnboardingStage.coreCommitted, revision: 1, committed: receipt);
    c.read(activeSpaceIdProvider.notifier).state = 99;
    c.read(activeProfileIdProvider.notifier).state = 8;
    startup.add(OnboardingStartup(StartupKind.resumeSetup, state: pending));
    await pumpEventQueue();
    expect(c.read(activeProfileIdProvider), 7);
    expect(c.read(activeSpaceIdProvider), isNull);
    expect(c.read(selectedYearMonthProvider), '2025-01');
    expect(setupHandoffOwnsContext(receipt, profileId: 7, isShared: false),
        isTrue);
    expect(setupHandoffOwnsContext(receipt, profileId: 8, isShared: false),
        isFalse);
    expect(setupHandoffOwnsContext(receipt, profileId: 7, isShared: true),
        isFalse);
    expect(
        setupHandoffArrived(receipt,
            profileId: 7, isShared: false, budgetId: 9, yearMonth: '2025-01'),
        isTrue);
    expect(
        setupHandoffArrived(receipt,
            profileId: 7, isShared: false, budgetId: 9, yearMonth: '2026-10'),
        isFalse);
    startup.add(OnboardingStartup(StartupKind.establishedUser));
    await pumpEventQueue();
    expect(identical(c.read(routerProvider), router), isTrue);
  });
  test(
      'route policy preserves established forms and requires explicit valid recovery owner',
      () {
    final existing = OnboardingStartup(StartupKind.establishedUser);
    expect(onboardingRedirect(existing, '/edit_expense'), isNull);
    final broken =
        OnboardingStartup(StartupKind.needsReview, existingProfileIds: {7});
    expect(onboardingRedirect(broken, '/dashboard'), '/setup');
    expect(onboardingRedirect(broken, '/dashboard', recoveryProfileId: 8),
        '/setup');
    expect(
        onboardingRedirect(broken, '/dashboard', recoveryProfileId: 7), isNull);
    expect(onboardingRedirect(null, '/dashboard'), '/setup');
  });

  for (final month in ['2025-01', '2027-12']) {
    test('finish $month is authorized, repeat-safe, pruned and local only',
        () async {
      final h = await MedicalTestHarness.create();
      addTearDown(h.close);
      IsarHelper.instance = h.isar;
      final repo = OnboardingRepository(h.isar);
      final draft = await repo.saveDraft(financialDraft(month: month),
          expectedRevision: null);
      final review = OnboardingFinance.review(draft);
      final receipt = await repo.commitCore(draft,
          reviewedDigest: review.digest, expectedRevision: draft.revision);
      await expectLater(
          repo.finishSetup(draft.flowId,
              expectedRevision: 1,
              verifierIsSet: (_) async => false,
              isAuthorized: () => true),
          throwsA(isA<OnboardingCommitException>()));
      await repo.prepareCommittedSetup(draft.flowId);
      final ready = await repo.recordSecurityChoice(
          draft.flowId,
          receipt.profileId,
          OnboardingSecurityChoice.notNow,
          (_) async => false);
      await expectLater(
          repo.finishSetup(draft.flowId,
              expectedRevision: ready.revision,
              verifierIsSet: (_) async => false,
              isAuthorized: () => false),
          throwsA(isA<OnboardingCommitException>()));
      final complete = await repo.finishSetup(draft.flowId,
          expectedRevision: ready.revision,
          verifierIsSet: (_) async => false,
          isAuthorized: () => true);
      expect(complete.stage, OnboardingStage.completed);
      expect(complete.sources, isEmpty);
      expect(complete.profile.name, isEmpty);
      expect(complete.committed!.profileId, receipt.profileId);
      expect(complete.yearMonth, month);
      final retry = await repo.finishSetup(draft.flowId,
          expectedRevision: ready.revision,
          verifierIsSet: (_) async => false,
          isAuthorized: () => true);
      expect(retry.revision, complete.revision);
      expect(await h.isar.monthlyBudgets.count(), 1);
      expect(await h.isar.incomeSources.count(), 1);
      expect(await h.isar.identitys.count(), 0);
      expect(await h.isar.changeRecords.count(), 0);
      expect((await h.isar.appSettings.get(1))!.onboardingStateJson,
          isNot(contains('500,000')));
    });
  }
}
