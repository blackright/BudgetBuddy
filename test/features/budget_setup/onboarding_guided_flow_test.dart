import 'package:budget_buddy/features/budget_setup/domain/onboarding_startup.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:budget_buddy/features/budget_setup/providers/onboarding_readiness_provider.dart';
import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/core/routing/app_router.dart';
import 'package:budget_buddy/features/budget_setup/presentation/guided_setup_screen.dart';
import 'package:budget_buddy/features/budget_setup/providers/budget_setup_provider.dart';
import 'package:budget_buddy/features/budget_setup/providers/setup_flow_provider.dart';
import 'package:budget_buddy/features/budget_setup/providers/onboarding_rollout_provider.dart';
import 'package:budget_buddy/features/budget_setup/repositories/onboarding_repository.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_state.dart';
import 'package:budget_buddy/features/identity/presentation/app_lock_gate.dart';
import 'package:budget_buddy/features/identity/providers/device_auth_session.dart';
import 'package:budget_buddy/features/identity/repositories/secret_store.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import '../security/support/in_memory_lock_settings_store.dart';
import '../identity/support/fake_device_authenticator.dart';
import '../medical/repositories/medical_test_harness.dart';
import 'support/financial_drafts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/features/budget_setup/presentation/widgets/learning_steps.dart';

final _recordedOwner = StateProvider<UserProfile?>((ref) => null);
void main() {
  for (final noIncome in [false, true]) {
    testWidgets(
        'seven-stage actual-router flow, noIncome=$noIncome, preserves real money',
        (tester) async {
      late MedicalTestHarness h;
      await tester.runAsync(() async {
        h = await MedicalTestHarness.create();
        IsarHelper.instance = h.isar;
      });
      final locks = InMemoryLockSettingsStore();
      final auth = FakeDeviceAuthenticator();
      final c = ProviderContainer(overrides: [
        unifiedOnboardingEnabledProvider.overrideWithValue(true),
        setupFlowProvider.overrideWithValue('guided-flow'),
        onboardingStartupProvider.overrideWith(
            (ref) => Stream.value(OnboardingStartup(StartupKind.firstSetup))),
        medicalBillsProvider.overrideWith((ref) => Stream.value([])),
        activeProfileProvider
            .overrideWith((ref) => Stream.value(ref.watch(_recordedOwner))),
        activeSpaceProvider.overrideWith((ref) => Stream.value(null)),
        identityProvider.overrideWith((ref) => Stream.value(null)),
        nativeAccessBindingProvider.overrideWith((ref) {
          final p = ref.watch(_recordedOwner);
          return NativeAccessBinding(
              key: p == null
                  ? 'setup:${ref.watch(setupFlowProvider)}'
                  : 'p${p.id}');
        }),
        lockSettingRepositoryProvider.overrideWithValue(locks),
        deviceAuthenticatorProvider.overrideWithValue(auth),
        secretStoreProvider.overrideWithValue(InMemorySecretStore()),
        financialSetupProvider.overrideWith((ref) => FinancialSetupController(
            initial: financialDraft(
                flow: ref.read(setupFlowProvider),
                month: '2025-01',
                openingChoice: noIncome
                    ? OnboardingOpeningChoice.unknown
                    : OnboardingOpeningChoice.known,
                incomeChoice: noIncome
                    ? OnboardingIncomeChoice.none
                    : OnboardingIncomeChoice.sources),
            autoSave: true,
            repository: OnboardingRepository(h.isar))),
      ]);
      await tester.runAsync(() async {
        await c.read(onboardingStartupProvider.future);
      });
      final router = createAppRouter(
          initialLocation: '/setup',
          setupBuilder: (_) => const GuidedSetupScreen(),
          dashboardBuilder: (_) => const Text('Exact personal Dashboard'));
      Future<void> tap(String label) async {
        final text = find.text(label).last;
        for (var i = 0; i < 80; i++) {
          await tester.pump();
          final buttons = find.ancestor(
              of: text,
              matching: find.byWidgetPredicate((w) => w is ButtonStyleButton));
          if (buttons.evaluate().isNotEmpty &&
              tester.widget<ButtonStyleButton>(buttons.first).onPressed !=
                  null) {
            break;
          }
          await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 50)));
        }
        final button = find
            .ancestor(
                of: text,
                matching: find.byWidgetPredicate((w) => w is ButtonStyleButton))
            .first;
        expect(tester.widget<ButtonStyleButton>(button).onPressed, isNotNull,
            reason: '$label should be ready');
        await tester.ensureVisible(text);
        await tester.runAsync(() async {
          final dynamic action =
              tester.widget<ButtonStyleButton>(button).onPressed;
          final dynamic result = action();
          if (result is Future) await result;
        });
        await tester.pump();
        for (var i = 0; i < 80; i++) {
          await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 50)));
          await tester.pump();
          if (find.text('Working...').evaluate().isEmpty) break;
        }
        await tester.pumpAndSettle();
      }

      await tester.pumpWidget(UncontrolledProviderScope(
          container: c,
          child: MaterialApp.router(
              routerConfig: router,
              builder: (_, child) => AppLockGate(child: child!))));
      await tester.pumpAndSettle();
      expect(find.text('Step 1 of 7'), findsOneWidget);
      await tap('Get started');
      expect(find.text('Step 2 of 7'), findsOneWidget);
      await tap(
          noIncome ? 'Skip explanations' : 'Continue to phone verification');
      expect(find.text('BudgetBuddy is locked'), findsOneWidget);
      await tap('Unlock');
      expect(find.text('Step 3 of 7'), findsOneWidget);
      await tap('Continue');
      expect(find.text('Step 4 of 7'), findsOneWidget);
      await tap('Back');
      expect(find.text('Step 3 of 7'), findsOneWidget);
      expect(c.read(financialSetupProvider).draft.profile.name, 'Jason');
      await tap('Continue');
      await tap('Continue');
      expect(find.text('Review your first month'), findsOneWidget);
      await tap('Confirm financial details');
      expect(c.read(financialSetupProvider).receipt, isNotNull,
          reason:
              '${c.read(financialSetupProvider).error} page=${c.read(financialSetupProvider).page} saving=${c.read(financialSetupProvider).isSaving}');
      final receipt = c.read(financialSetupProvider).receipt!;
      await tester.runAsync(() async {
        c.read(_recordedOwner.notifier).state =
            await h.isar.userProfiles.get(receipt.profileId);
      });
      await tester.pumpAndSettle();
      if (find.text('Unlock').evaluate().isNotEmpty) await tap('Unlock');
      expect(find.text('Step 5 of 7'), findsOneWidget);
      await tap('Prepare required records');
      await tap('Continue with phone authentication');
      await tap('Continue');
      expect(find.text('Step 6 of 7'), findsOneWidget);
      await tap(noIncome ? 'Skip explanations' : 'Continue');
      expect(find.text('Step 7 of 7'), findsOneWidget);
      await tester.runAsync(() async {
        expect(
            (await OnboardingRepository(h.isar).readStartupState())
                .state!
                .completedAt,
            isNull);
      });
      await tap('Open my Dashboard');
      expect(router.routeInformationProvider.value.uri.path, '/dashboard');
      expect(c.read(selectedYearMonthProvider), '2025-01');
      expect(c.read(activeSpaceIdProvider), isNull);
      expect(c.read(activeProfileIdProvider), receipt.profileId);
      await tester.runAsync(() async {
        final complete =
            (await OnboardingRepository(h.isar).readStartupState()).state!;
        expect(complete.stage, OnboardingStage.completed);
        final month = (await h.isar.monthlyBudgets.get(receipt.budgetId))!;
        expect(month.baseAvailableAmount, noIncome ? 0 : 100000);
        expect(month.openingBalanceConfirmed, !noIncome);
        expect(month.yearMonth, '2025-01');
        final sources = await h.isar.incomeSources.where().findAll();
        expect(sources.length, noIncome ? 0 : 1);
        if (!noIncome) expect(sources.single.amount, 500000);
        expect(await h.isar.identitys.count(), 0);
        expect(await h.isar.changeRecords.count(), 0);
      });
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
      c.dispose();
      await tester.runAsync(() async {
        await locks.dispose();
        await h.close();
      });
    });
  }

  testWidgets(
      'public introduction has progress, Back, and optional labelled examples',
      (tester) async {
    var verifiedNext = 0;
    await tester.pumpWidget(MaterialApp(
        home: PublicSetupIntroduction(onContinue: () => verifiedNext++)));
    expect(find.text('Step 1 of 7'), findsOneWidget);
    await tester.ensureVisible(find.text('Get started'));
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('Step 2 of 7'), findsOneWidget);
    await tester.tap(find.text('Opening money and income'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Example'), findsWidgets);
    await tester.ensureVisible(find.text('Skip explanations'));
    await tester.tap(find.text('Skip explanations'));
    expect(verifiedNext, 1);
  });
}
