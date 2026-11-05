import 'package:budget_buddy/features/budget_setup/domain/onboarding_startup.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:budget_buddy/features/budget_setup/providers/onboarding_readiness_provider.dart';
import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/salary_cycle.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
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
import 'package:budget_buddy/features/budget_setup/repositories/onboarding_repository.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_state.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_starting_position.dart';
import 'package:budget_buddy/features/finance/providers/income_source_providers.dart';
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

final _recordedOwner = StateProvider<UserProfile?>((ref) => null);

/// Waits for [condition] while advancing both the real event loop and the
/// widget clock. Real async work (Isar) needs `runAsync`; timers, animations
/// and rebuilds need `pump`.
Future<void> pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  String? reason,
  Duration timeout = const Duration(seconds: 15),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
    await tester.pump(const Duration(milliseconds: 20));
    if (condition()) return;
  }
  fail('Timed out after ${timeout.inSeconds}s waiting for '
      '${reason ?? 'the expected UI state'}.');
}

/// Bounded replacement for `pumpAndSettle` that also yields to real async work.
Future<void> settle(WidgetTester tester) async {
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (DateTime.now().isBefore(deadline)) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 1)));
    await tester.pump(const Duration(milliseconds: 100));
    if (!tester.binding.hasScheduledFrame) return;
  }
  fail('The UI did not settle within 10 seconds.');
}

void main() {
  for (final noIncome in [false, true]) {
    testWidgets(
        'eight-stage actual-router flow, noIncome=$noIncome, preserves real money',
        (tester) async {
      late MedicalTestHarness h;
      var bodyCompleted = false;
      await tester.runAsync(() async {
        h = await MedicalTestHarness.create()
            .timeout(const Duration(seconds: 60));
        IsarHelper.instance = h.isar;
      });
      final locks = InMemoryLockSettingsStore();
      final auth = FakeDeviceAuthenticator();
      addTearDown(() async {
        // A failed or hung body may still own the binding's async task. Never
        // re-enter runAsync in that case: it masks the original failure with
        // "Reentrant call to runAsync() denied". A completed body has no
        // pending runAsync, so the Isar drain is safe.
        if (!bodyCompleted) return;
        // Isar watchers start a read that completes on the real event loop.
        // Drain any in-flight read so `close()` is not left waiting on it.
        for (var i = 0; i < 3; i++) {
          await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 20)));
          await tester.pump();
        }
        await tester.runAsync(() => h.close());
      });
      final c = ProviderContainer(overrides: [
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
        // This flow test exercises navigation. The activation widget and the
        // starting-position loader have focused tests that use a real database.
        onboardingActivationSourcesProvider
            .overrideWith((ref, id) async => const <IncomeSource>[]),
        salaryCyclesProvider.overrideWith((ref) async => const <SalaryCycle>[]),
        onboardingStartingPositionProvider.overrideWith((ref, args) async =>
            const OnboardingStartingPosition(
                month: '2025-01',
                currency: CurrencyCode.huf,
                openingMinor: 100000,
                confirmedMinor: 0,
                pendingMinor: 0,
                skippedMinor: 0,
                unconfiguredMinor: 0,
                cancelledMinor: 0,
                confirmed: [],
                pending: [],
                skipped: [],
                unconfigured: [],
                future: [],
                cancelled: [])),
      ]);
      await tester.runAsync(() async {
        await c
            .read(onboardingStartupProvider.future)
            .timeout(const Duration(seconds: 30));
      });
      final router = createAppRouter(
          initialLocation: '/setup',
          setupBuilder: (_) => const GuidedSetupScreen(),
          dashboardBuilder: (_) => const Text('Exact personal Dashboard'));
      Future<void> tap(String label, {Finder? until}) async {
        final text = find.text(label).last;
        Finder buttonFinder() => find
            .ancestor(
                of: text,
                matching: find.byWidgetPredicate((w) => w is ButtonStyleButton))
            .first;
        await pumpUntil(
          tester,
          () {
            final buttons = find.ancestor(
                of: text,
                matching:
                    find.byWidgetPredicate((w) => w is ButtonStyleButton));
            return buttons.evaluate().isNotEmpty &&
                tester.widget<ButtonStyleButton>(buttons.first).onPressed !=
                    null;
          },
          reason: '"$label" to be enabled',
        );
        final button = buttonFinder();
        expect(tester.widget<ButtonStyleButton>(button).onPressed, isNotNull,
            reason: '$label should be ready');
        await tester.ensureVisible(button);
        await tester.pump();
        // Tap the real control. Never await the button's callback Future inside
        // runAsync: it can depend on frames, providers or routes and would
        // deadlock the test until the 10-minute timeout.
        await tester.tap(button);
        await tester.pump();
        if (until != null) {
          await pumpUntil(tester, () => until.evaluate().isNotEmpty,
              reason: '"$label" to reach its next state');
        } else {
          // Wait for the flow's busy label to appear and clear. If it never
          // appears the action completed synchronously; a short grace period
          // is enough for its rebuild.
          var sawBusy = find.text('Working...').evaluate().isNotEmpty;
          for (var i = 0; i < 500; i++) {
            await tester.runAsync(
                () => Future<void>.delayed(const Duration(milliseconds: 5)));
            await tester.pump(const Duration(milliseconds: 20));
            final busy = find.text('Working...').evaluate().isNotEmpty;
            if (busy) {
              sawBusy = true;
            } else if (sawBusy || i >= 10) {
              break;
            }
          }
        }
        await settle(tester);
      }

      await tester.pumpWidget(UncontrolledProviderScope(
          container: c,
          child: MaterialApp.router(
              routerConfig: router,
              builder: (_, child) => AppLockGate(child: child!))));
      await pumpUntil(
          tester, () => find.text('Step 1 of 8').evaluate().isNotEmpty,
          reason: 'the guided setup to start');
      expect(find.text('Step 1 of 8'), findsOneWidget);
      await tap('Get started', until: find.text('Step 2 of 8'));
      expect(find.text('Step 2 of 8'), findsOneWidget);
      await tap(
          noIncome ? 'Skip explanations' : 'Continue to phone verification',
          until: find.text('BudgetBuddy is locked'));
      expect(find.text('BudgetBuddy is locked'), findsOneWidget);
      await tap('Unlock', until: find.text('Step 3 of 8'));
      expect(find.text('Step 3 of 8'), findsOneWidget);
      await tap('Continue', until: find.text('Step 4 of 8'));
      expect(find.text('Step 4 of 8'), findsOneWidget);
      await tap('Back', until: find.text('Step 3 of 8'));
      expect(find.text('Step 3 of 8'), findsOneWidget);
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
      await settle(tester);
      if (find.text('Unlock').evaluate().isNotEmpty) {
        await tap('Unlock', until: find.text('Step 5 of 8'));
      }
      // The harness records the new owner only after Save, so this step mounted
      // before the profile was readable. Re-read it with the screen's own retry
      // control; in production the active-profile stream supplies it.
      if (find.text('Reload protection status').evaluate().isNotEmpty) {
        await tap('Reload protection status', until: find.text('Step 5 of 8'));
      }
      expect(find.text('Step 5 of 8'), findsOneWidget);
      await tap('Prepare required records');
      await tap('Continue with phone authentication');
      await tap('Continue', until: find.text('Step 6 of 8'));
      expect(find.text('Step 6 of 8'), findsOneWidget);
      expect(find.text('Set up this month’s income'), findsOneWidget);
      await tap('Continue', until: find.text('Step 7 of 8'));
      expect(find.text('Step 7 of 8'), findsOneWidget);
      await tap(noIncome ? 'Skip explanations' : 'Continue',
          until: find.text('Step 8 of 8'));
      expect(find.text('Step 8 of 8'), findsOneWidget);
      expect(find.text('Your starting position'), findsOneWidget);
      await tester.runAsync(() async {
        expect(
            (await OnboardingRepository(h.isar).readStartupState())
                .state!
                .completedAt,
            isNull);
      });
      await tap('Open my Dashboard',
          until: find.text('Exact personal Dashboard'));
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
      await locks.dispose();
      bodyCompleted = true;
    }, timeout: const Timeout(Duration(minutes: 2)));
  }
}
