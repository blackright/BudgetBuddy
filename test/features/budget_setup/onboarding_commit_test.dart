import 'package:budget_buddy/core/models/app_settings.dart';
import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:budget_buddy/core/models/category.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/finance/providers/finance_providers.dart';
import 'package:budget_buddy/features/finance/providers/profile_providers.dart';
import 'package:budget_buddy/features/finance/providers/month_end_providers.dart';
import 'package:budget_buddy/features/finance/providers/income_source_providers.dart';
import 'package:budget_buddy/features/engine/providers/month_summary_provider.dart';
import 'package:budget_buddy/features/engine/providers/true_available_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:budget_buddy/features/vault/providers/vault_providers.dart';
import 'package:budget_buddy/features/expenses/providers/category_provider.dart';
import 'package:budget_buddy/features/budget_setup/providers/onboarding_rollout_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_finance.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_state.dart';
import 'package:budget_buddy/features/budget_setup/repositories/onboarding_repository.dart';
import 'package:budget_buddy/features/expenses/repositories/category_repository.dart';
import 'package:budget_buddy/features/finance/repositories/audit_repository.dart';
import 'package:budget_buddy/features/finance/repositories/income_source_repository.dart';
import 'package:budget_buddy/features/settings/providers/app_settings_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import '../medical/repositories/medical_test_harness.dart';
import 'support/financial_drafts.dart';
import 'package:budget_buddy/features/budget_setup/providers/budget_setup_provider.dart';

class _LostResponseRepository extends OnboardingRepository {
  _LostResponseRepository(super.isar);
  bool loseResponse = true;
  @override
  Future<OnboardingCommitReference> commitCore(OnboardingState reviewed,
      {required String reviewedDigest,
      required int expectedRevision,
      bool Function()? isAuthorized}) async {
    final result = await super.commitCore(reviewed,
        reviewedDigest: reviewedDigest,
        expectedRevision: expectedRevision,
        isAuthorized: isAuthorized);
    if (loseResponse) {
      loseResponse = false;
      throw StateError('simulated lost response');
    }
    return result;
  }
}

class _BrokenAudit extends AuditRepository {
  _BrokenAudit(super.isar, {super.actorId});
  @override
  Future<int> put<T>(IsarCollection<T> collection, T value,
          {required int id, required String type, bool derived = true}) async =>
      throw StateError('audit failure');
}

class _BrokenIncomeAudit extends AuditRepository {
  _BrokenIncomeAudit(super.isar, {super.actorId});
  @override
  Future<int> put<T>(IsarCollection<T> collection, T value,
      {required int id, required String type, bool derived = true}) async {
    if (type == 'IncomeSource') throw StateError('source failure');
    return super.put(collection, value, id: id, type: type, derived: derived);
  }
}

class _BrokenCheckpoint extends AppSettingsRepository {
  _BrokenCheckpoint(super.isar);
  @override
  Future<void> saveOnboardingStateInTxn(OnboardingState next,
          {required String? expectedFlowId,
          required int? expectedRevision}) async =>
      throw StateError('checkpoint failure');
}

void main() {
  late MedicalTestHarness h;
  setUp(() async {
    h = await MedicalTestHarness.create();
    await h.isar.writeTxn(() async {
      final now = DateTime.utc(2026);
      await h.isar.appSettings.put(AppSettings()
        ..id = 1
        ..createdAt = now
        ..updatedAt = now
        ..starterCategoryPolicy = 'unifiedPending');
    });
  });
  tearDown(() => h.close());
  Future<OnboardingReview> stage(OnboardingState draft) async {
    await AppSettingsRepository(h.isar).saveOnboardingState(draft,
        expectedFlowId: null, expectedRevision: null);
    return OnboardingFinance.review(draft);
  }

  test(
      'controller retains entries after lost response and ignores simultaneous submit',
      () async {
    final controller = FinancialSetupController(
        initial: financialDraft(), repository: _LostResponseRepository(h.isar));
    addTearDown(controller.dispose);
    controller.next();
    controller.next();
    await Future.wait([controller.save(), controller.save()]);
    expect(controller.state.receipt, isNull);
    expect(controller.state.isSaving, isFalse);
    expect(controller.state.error, contains('could not confirm'));
    expect(controller.state.draft.sources.single.amountText, '500,000');
    final audits = await h.isar.auditEvents.count();
    await controller.save();
    expect(controller.state.receipt, isNotNull);
    expect(controller.state.error, isNull);
    expect(await h.isar.userProfiles.count(), 1);
    expect(await h.isar.monthlyBudgets.count(), 1);
    expect(await h.isar.incomeSources.count(), 1);
    expect(await h.isar.auditEvents.count(), audits);
  });

  test('separate real sources retain zero amounts and exact minor units',
      () async {
    final review =
        await stage(financialDraft(currency: CurrencyCode.eur, sources: [
      const OnboardingSourceDraft(
          sourceGuid: 'first',
          name: 'Work',
          amountText: '1,234.56',
          currency: CurrencyCode.eur),
      const OnboardingSourceDraft(
          sourceGuid: 'second',
          name: 'Variable',
          amountText: '0',
          currency: CurrencyCode.eur),
    ]));
    final ref = await OnboardingRepository(h.isar).commitCore(review.normalized,
        reviewedDigest: review.digest, expectedRevision: 0);
    final rows =
        await IncomeSourceRepository(h.isar).getAll(profileId: ref.profileId);
    expect(rows.map((r) => r.amount).toSet(), {123456, 0});
    expect(
        rows.every((r) =>
            r.profileId == ref.profileId &&
            r.currency == CurrencyCode.eur.code &&
            r.sharedSpaceId == null),
        isTrue);
    expect(ref.sourceIds.keys.toSet(), {'first', 'second'});
  });

  test(
      'ten lost-response retries keep one owner, month, income and audit history',
      () async {
    final r = await stage(financialDraft());
    final repo = OnboardingRepository(h.isar);
    final first = await repo.commitCore(r.normalized,
        reviewedDigest: r.digest, expectedRevision: 0);
    final count = await h.isar.auditEvents.count();
    for (var i = 0; i < 10; i++) {
      final retry = await OnboardingRepository(h.isar).commitCore(r.normalized,
          reviewedDigest: r.digest, expectedRevision: 0);
      expect(retry.budgetId, first.budgetId);
    }
    expect(await h.isar.userProfiles.count(), 1);
    expect(await h.isar.monthlyBudgets.count(), 1);
    expect(await h.isar.incomeSources.count(), 1);
    expect(await h.isar.auditEvents.count(), count);
    final profile = (await h.isar.userProfiles.get(first.profileId))!;
    expect(profile.defaultNetSalary, 0);
    expect(profile.monthlyAvailableAmount, 100000);
    final month = (await h.isar.monthlyBudgets.get(first.budgetId))!;
    expect(month.profileId, profile.id);
    expect(month.sharedSpaceId, isNull);
    expect(month.netSalaryOverride, isNull);
    expect(month.currency, isNull);
    expect(month.openingBalanceConfirmed, isTrue);
    final sources =
        await IncomeSourceRepository(h.isar).getAll(profileId: profile.id);
    expect(sources.single.syncGuid, 'salary-1');
    expect(sources.single.amount, 500000);
    expect(sources.single.sharedSpaceId, isNull);
    final events = await h.isar.auditEvents.where().findAll();
    expect(events.where((e) => e.action == 'income.create'), hasLength(1));
    expect(events.every((e) => e.profileId == profile.id), isTrue);
    final saved = OnboardingState.decode(
        (await h.isar.appSettings.get(1))!.onboardingStateJson!);
    expect(saved.stage, OnboardingStage.coreCommitted);
    expect(saved.directoryReady, isFalse);
    expect(saved.completedAt, isNull);
    expect(await h.isar.categorys.count(), 11);
    expect((await h.isar.appSettings.get(1))!.starterCategoryPolicy,
        'unifiedSeeded');
  });
  test(
      'audit failure rolls back profile/month/source/category and checkpoint together',
      () async {
    final r = await stage(financialDraft());
    final before = (await h.isar.appSettings.get(1))!.onboardingStateJson;
    final repo = OnboardingRepository(h.isar,
        auditFactory: (owner) => _BrokenAudit(h.isar, actorId: owner));
    await expectLater(
        repo.commitCore(r.normalized,
            reviewedDigest: r.digest, expectedRevision: 0),
        throwsStateError);
    expect(await h.isar.userProfiles.count(), 0);
    expect(await h.isar.monthlyBudgets.count(), 0);
    expect(await h.isar.incomeSources.count(), 0);
    expect(await h.isar.categorys.count(), 0);
    expect(await h.isar.auditEvents.count(), 0);
    expect((await h.isar.appSettings.get(1))!.onboardingStateJson, before);
    expect((await h.isar.appSettings.get(1))!.starterCategoryPolicy,
        'unifiedPending');
  });
  for (final currency in CurrencyCode.values) {
    test(
        '${currency.name}: unknown opening and No income create no placeholder',
        () async {
      final r = await stage(financialDraft(
          currency: currency,
          openingChoice: OnboardingOpeningChoice.unknown,
          incomeChoice: OnboardingIncomeChoice.none));
      final ref = await OnboardingRepository(h.isar).commitCore(r.normalized,
          reviewedDigest: r.digest, expectedRevision: 0);
      final month = (await h.isar.monthlyBudgets.get(ref.budgetId))!;
      expect(month.baseAvailableAmount, 0);
      expect(month.openingBalanceConfirmed, isFalse);
      expect(await h.isar.incomeSources.count(), 0);
    });
  }
  test('stale digest and deleted committed targets never recreate money',
      () async {
    final r = await stage(financialDraft());
    final repo = OnboardingRepository(h.isar);
    await expectLater(
        repo.commitCore(r.normalized,
            reviewedDigest: 'a' * 64, expectedRevision: 0),
        throwsA(isA<OnboardingCommitException>()));
    expect(await h.isar.userProfiles.count(), 0);
    final ref = await repo.commitCore(r.normalized,
        reviewedDigest: r.digest, expectedRevision: 0);
    await h.isar.writeTxn(() => h.isar.monthlyBudgets.delete(ref.budgetId));
    await expectLater(
        repo.commitCore(r.normalized,
            reviewedDigest: r.digest, expectedRevision: 0),
        throwsA(isA<OnboardingCommitException>()));
    expect(await h.isar.monthlyBudgets.count(), 0);
    expect(await h.isar.userProfiles.count(), 1);
  });
  test(
      'seed preserves custom labels, runs only for eligible marker and is repeat-safe',
      () async {
    await h.isar.writeTxn(() => h.isar.categorys.put(Category(
        categoryId: 'food', name: 'My food', emoji: 'x', colorValue: 1)));
    final repo = CategoryRepository(h.isar);
    await h.isar.writeTxn(repo.seedUnifiedStarterInTxn);
    await h.isar.writeTxn(repo.seedUnifiedStarterInTxn);
    expect(await h.isar.categorys.count(), 11);
    expect(
        (await h.isar.categorys.filter().categoryIdEqualTo('food').findFirst())!
            .name,
        'My food');
    await h.isar.writeTxn(() async {
      await h.isar.categorys.clear();
      final settings = (await h.isar.appSettings.get(1))!;
      settings.starterCategoryPolicy = 'preserveExisting';
      await h.isar.appSettings.put(settings);
      await repo.seedUnifiedStarterInTxn();
    });
    expect(await h.isar.categorys.count(), 0);
  });

  for (final currency in CurrencyCode.values) {
    test(
        '${currency.name}: ordinary income and Dashboard engine read the actual committed records',
        () async {
      final review = await stage(financialDraft(currency: currency));
      final receipt = await OnboardingRepository(h.isar).commitCore(
          review.normalized,
          reviewedDigest: review.digest,
          expectedRevision: 0);
      final profile = (await h.isar.userProfiles.get(receipt.profileId))!;
      final month = (await h.isar.monthlyBudgets.get(receipt.budgetId))!;
      final c = ProviderContainer(overrides: [
        budgetContextProvider.overrideWithValue(ContextRef.personal(
            profileId: profile.id, yearMonth: month.yearMonth)),
        selectedYearMonthProvider.overrideWith((ref) => month.yearMonth),
        activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
        activeBudgetProvider.overrideWith((ref) => Stream.value(month)),
        monthFinanceProvider.overrideWith((ref) => Stream.value(month)),
        incomeSourceRepositoryProvider.overrideWithValue(
            IncomeSourceRepository(h.isar, actorId: profile.id)),
        budgetProfilesProvider.overrideWith((ref) => Stream.value([])),
        contextExpensesProvider.overrideWithValue([]),
        monthlyExpensesProvider.overrideWith((ref) => Stream.value([])),
        monthlyOriginReimbursementsProvider
            .overrideWith((ref) => Stream.value([])),
        reimbursementTargetExpensesProvider
            .overrideWith((ref) => Stream.value([])),
        mainCurrencyProvider.overrideWithValue(currency),
        rateRegistryProvider.overrideWithValue(MedicalTestHarness.rates),
        monthEndBalanceProvider
            .overrideWithValue((incoming: 0, released: 0, carryShortfall: 0)),
        monthlyVaultCreditProvider.overrideWithValue(0),
      ]);
      try {
        await c.read(activeProfileProvider.future);
        await c.read(activeBudgetProvider.future);
        await c.read(monthFinanceProvider.future);
        await c.read(incomeSourcesProvider.future);
        await c.read(budgetProfilesProvider.future);
        await c.read(monthlyExpensesProvider.future);
        await c.read(monthlyOriginReimbursementsProvider.future);
        await c.read(reimbursementTargetExpensesProvider.future);
        expect(c.read(incomeSourcesTotalProvider), 500000);
        final summary = c.read(monthSummaryProvider);
        expect(summary.moneyInBank, 600000);
        expect(summary.kept, 500000);
      } finally {
        c.dispose();
      }
    });
  }
  for (final checkpointFailure in [false, true]) {
    test(
        '${checkpointFailure ? 'checkpoint' : 'source'} failure rolls back already-written finance and audits',
        () async {
      final review = await stage(financialDraft());
      final before = (await h.isar.appSettings.get(1))!.onboardingStateJson;
      final repo = OnboardingRepository(h.isar,
          settings: checkpointFailure ? _BrokenCheckpoint(h.isar) : null,
          auditFactory: checkpointFailure
              ? null
              : (owner) => _BrokenIncomeAudit(h.isar, actorId: owner));
      await expectLater(
          repo.commitCore(review.normalized,
              reviewedDigest: review.digest, expectedRevision: 0),
          throwsStateError);
      expect(await h.isar.userProfiles.count(), 0);
      expect(await h.isar.monthlyBudgets.count(), 0);
      expect(await h.isar.incomeSources.count(), 0);
      expect(await h.isar.auditEvents.count(), 0);
      expect(await h.isar.categorys.count(), 0);
      expect((await h.isar.appSettings.get(1))!.onboardingStateJson, before);
    });
  }
  test('ten fresh setup and retry trials create exactly their own records',
      () async {
    for (var i = 0; i < 10; i++) {
      final trial = await MedicalTestHarness.createPreMigration();
      try {
        await trial.runMigrations();
        final draft = financialDraft(
            flow: 'trial-$i', currency: CurrencyCode.values[i % 4]);
        await AppSettingsRepository(trial.isar).saveOnboardingState(draft,
            expectedFlowId: null, expectedRevision: null);
        final review = OnboardingFinance.review(draft);
        final repo = OnboardingRepository(trial.isar);
        final a = await repo.commitCore(review.normalized,
            reviewedDigest: review.digest, expectedRevision: 0);
        final audits = await trial.isar.auditEvents.count();
        final b = await repo.commitCore(review.normalized,
            reviewedDigest: review.digest, expectedRevision: 0);
        expect(a.profileId, b.profileId);
        expect(a.budgetId, b.budgetId);
        expect(await trial.isar.userProfiles.count(), 1);
        expect(await trial.isar.monthlyBudgets.count(), 1);
        expect(await trial.isar.incomeSources.count(), 1);
        expect(await trial.isar.auditEvents.count(), audits);
      } finally {
        await trial.close();
      }
    }
  });
  test(
      'policy-aware reads do not seed pending categories; live gate stays legacy',
      () async {
    final policy = ProviderContainer(overrides: [
      unifiedOnboardingEnabledProvider.overrideWithValue(true),
      categoryRepositoryProvider.overrideWithValue(CategoryRepository(h.isar))
    ]);
    try {
      expect(await policy.read(categoriesProvider.future), isEmpty);
      expect(await h.isar.categorys.count(), 0);
    } finally {
      policy.dispose();
    }
    final live = ProviderContainer(overrides: [
      categoryRepositoryProvider.overrideWithValue(CategoryRepository(h.isar))
    ]);
    try {
      expect(await live.read(categoriesProvider.future), hasLength(7));
    } finally {
      live.dispose();
    }
  });
  test(
      'an orphan personal month is refused instead of reattaching it to a guessed owner',
      () async {
    final now = DateTime.utc(2026);
    await h.isar.writeTxn(() => h.isar.monthlyBudgets.put(MonthlyBudget()
      ..profileId = 1
      ..yearMonth = '2026-10'
      ..baseAvailableAmount = 900
      ..createdAt = now
      ..updatedAt = now));
    final review = await stage(financialDraft());
    await expectLater(
        OnboardingRepository(h.isar).commitCore(review.normalized,
            reviewedDigest: review.digest, expectedRevision: 0),
        throwsA(isA<OnboardingCommitException>()));
    expect(await h.isar.userProfiles.count(), 0);
    expect(await h.isar.monthlyBudgets.count(), 1);
    expect(await h.isar.incomeSources.count(), 0);
  });
}
