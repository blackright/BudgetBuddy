import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/month_end_run.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/services/continuous_balance_service.dart';
import 'package:budget_buddy/core/services/salary_receipt_service.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/vault/models/savings_vault.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../features/medical/repositories/medical_test_harness.dart';
import '../../support/d1_financial_harness.dart';

void main() {
  late MedicalTestHarness h;

  setUp(() async {
    h = await MedicalTestHarness.create();
  });

  tearDown(() => h.close());

  ContinuousBalanceService service() =>
      ContinuousBalanceService(h.isar, clock: () => DateTime.utc(2026, 11, 2));

  Future<void> seedProfile({PrimaryCurrency currency = PrimaryCurrency.usd}) =>
      h.isar.writeTxn(() async {
        await h.isar.userProfiles.put(UserProfile()
          ..id = 1
          ..name = 'Owner'
          ..primaryCurrency = currency
          ..monthlyAvailableAmount = 0
          ..createdAt = DateTime.utc(2026)
          ..updatedAt = DateTime.utc(2026));
      });

  Future<void> seedOpening(String month, double opening,
          {bool confirmed = true}) =>
      h.isar.writeTxn(() async {
        await h.isar.monthlyBudgets.put(MonthlyBudget()
          ..profileId = 1
          ..yearMonth = month
          ..baseAvailableAmount = opening
          ..openingBalanceConfirmed = confirmed
          ..createdAt = DateTime.utc(2026)
          ..updatedAt = DateTime.utc(2026));
      });

  Future<Expense> seedExpense({
    int amount = 2000,
    String currency = 'usd',
    String month = '2026-10',
    ExpenseStatus status = ExpenseStatus.paid,
    String? cashMonth,
  }) async {
    final row = Expense(
        profileId: 1,
        yearMonth: month,
        budgetId: 1,
        title: 'Spend',
        amount: amount,
        currency: currency,
        categoryId: 'food',
        date: DateTime.utc(2026, 10, 5),
        status: status)
      ..cashYearMonth = cashMonth;
    await h.isar.writeTxn(() async {
      row.id = await h.isar.expenses.put(row);
    });
    return row;
  }

  test('no month means the profile must confirm its first opening balance',
      () async {
    await seedProfile();
    final result = await service().balance(profileId: 1, yearMonth: '2026-10');

    expect(result.status, BalanceChainStatus.firstMonth);
    expect(result.needsOpeningReview, isTrue);
    expect(result.openingMinor, 0);
  });

  test('opening + confirmed cash in - cash out - allocations = free to use',
      () async {
    await seedProfile();
    await seedOpening('2026-10', 1000);
    final expense = await seedExpense(amount: 2000);
    await h.isar.writeTxn(() async {
      await h.isar.reimbursements.put(Reimbursement(
          profileId: 1,
          expenseId: expense.id,
          originYearMonth: '2026-10',
          amount: 500,
          currency: 'usd',
          date: DateTime.utc(2026, 10, 10)));
      await h.isar.savingsVaults.put(SavingsVault()
        ..profileId = 1
        ..totalMinor = 700
        ..currency = 'usd'
        ..lastSweepYearMonth = ''
        ..updatedAt = DateTime.utc(2026));
    });

    final result = await service().balance(profileId: 1, yearMonth: '2026-10');

    expect(result.status, BalanceChainStatus.intact);
    expect(result.openingMinor, 100000);
    expect(result.cashInMinor, 500);
    expect(result.cashOutMinor, 2000);
    expect(result.closingMinor, 98500);
    expect(result.allocatedMinor, 0);
    expect(result.freeToUseMinor, 98500);
    // The Vault is owned money, never subtracted a second time.
    expect(result.vaultMinor, 700);
  });

  test('a late salary is counted once in its actual cash month', () async {
    final f = await D1FinancialHarness.create();
    addTearDown(f.close);
    final salary =
        SalaryReceiptService(f.h.db, clock: () => D1FinancialHarness.now);
    final preview = await salary.preview(
        actorId: f.h.ownerId,
        sourceGuid: f.source.syncGuid,
        cycleGuid: f.cycle.guid,
        salaryMinor: 500000,
        actualDate: DateTime.utc(2026, 10, 27),
        selectedClaimGuids: const [],
        isAccessCurrent: () => true);
    await salary.confirm(
        preview: preview,
        bankTotalMinor: 500000,
        operationKey: 'late',
        isAccessCurrent: () => true);

    final october = await ContinuousBalanceService(f.h.db,
            clock: () => D1FinancialHarness.now)
        .balance(profileId: f.h.ownerId, yearMonth: '2026-10');
    final november = await ContinuousBalanceService(f.h.db,
            clock: () => D1FinancialHarness.now)
        .balance(profileId: f.h.ownerId, yearMonth: '2026-11');

    expect(october.cashInMinor, 500000);
    expect(october.openingMinor, 600000);
    expect(october.cashOutMinor, 10000);
    expect(october.closingMinor, 1090000);
    expect(november.openingMinor, october.closingMinor);
    expect(november.cashInMinor, 0);
    expect(november.freeToUseMinor, october.closingMinor);
  });

  test('a forecast salary never changes free-to-use', () async {
    await seedProfile();
    await seedOpening('2026-10', 1000);
    final before = await service().balance(profileId: 1, yearMonth: '2026-10');
    await h.isar.writeTxn(() async {
      await h.isar.incomeSources.put(IncomeSource()
        ..profileId = 1
        ..name = 'Salary'
        ..type = IncomeSourceType.salary
        ..amount = 900000
        ..currency = 'usd'
        ..frequency = IncomeFrequency.monthly
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
    });
    final after = await service().balance(profileId: 1, yearMonth: '2026-10');

    expect(after.freeToUseMinor, before.freeToUseMinor);
    expect(after.cashInMinor, 0);
  });

  test('a correction flows forward without changing the earlier month',
      () async {
    final f = await D1FinancialHarness.create();
    addTearDown(f.close);
    final salary =
        SalaryReceiptService(f.h.db, clock: () => D1FinancialHarness.now);
    final preview = await salary.preview(
        actorId: f.h.ownerId,
        sourceGuid: f.source.syncGuid,
        cycleGuid: f.cycle.guid,
        salaryMinor: 500000,
        actualDate: DateTime.utc(2026, 10, 27),
        selectedClaimGuids: const [],
        isAccessCurrent: () => true);
    final group = await salary.confirm(
        preview: preview,
        bankTotalMinor: 500000,
        operationKey: 'salary',
        isAccessCurrent: () => true);
    final october = await ContinuousBalanceService(f.h.db)
        .balance(profileId: f.h.ownerId, yearMonth: '2026-10');
    await SalaryReceiptService(f.h.db,
            clock: () => DateTime.utc(2026, 11, 5))
        .correct(
            actorId: f.h.ownerId,
            groupGuid: group.guid,
            correctionMinor: -10000,
            reason: 'Corrected credit',
            operationKey: 'fix',
            correctedAt: DateTime.utc(2026, 11, 2),
            isAccessCurrent: () => true);

    final octoberAgain = await ContinuousBalanceService(f.h.db)
        .balance(profileId: f.h.ownerId, yearMonth: '2026-10');
    final november = await ContinuousBalanceService(f.h.db)
        .balance(profileId: f.h.ownerId, yearMonth: '2026-11');

    expect(octoberAgain.closingMinor, october.closingMinor);
    expect(november.openingMinor, october.closingMinor);
    expect(november.cashInMinor, -10000);
    expect(november.closingMinor, october.closingMinor - 10000);
  });

  test('a missing intermediate month is a legacy gap', () async {
    await seedProfile();
    await seedOpening('2026-10', 1000);
    final result = await service().balance(profileId: 1, yearMonth: '2026-12');

    expect(result.status, BalanceChainStatus.legacyGap);
    expect(result.needsOpeningReview, isTrue);
  });

  test('unsupported stored money is surfaced for review', () async {
    await seedProfile();
    await seedOpening('2026-10', 1000);
    await seedExpense(amount: 2000, currency: 'gbp');
    final result = await service().balance(profileId: 1, yearMonth: '2026-10');

    expect(result.status, BalanceChainStatus.needsReview);
    expect(result.reviewReason, isNotNull);
  });

  test('legacy month-end lines supply the allocation when no profile rows exist',
      () async {
    await seedProfile();
    await seedOpening('2026-10', 1000);
    await h.isar.writeTxn(() async {
      await h.isar.monthEndRuns.put(MonthEndRun()
        ..syncGuid = 'run-1'
        ..profileId = 1
        ..contextGuid = 'personal:1'
        ..yearMonth = '2026-10'
        ..destinationMonth = '2026-11'
        ..currency = 'usd'
        ..reportJson =
            '{"lines":[{"sourceGuid":"p1","allocation":50000,"spent":20000,"carried":30000,"released":0}]}'
        ..fingerprint = 'fp'
        ..actor = 'actor'
        ..createdAt = DateTime.utc(2026)
        ..carriedMinor = 30000
        ..releasedMinor = 0);
    });
    final result = await service().balance(profileId: 1, yearMonth: '2026-10');

    // No profile rows: the run's unused envelope is the allocation.
    expect(result.allocatedMinor, 30000);
    expect(result.freeToUseMinor, 70000);
  });

  test('profile rows win over a legacy run instead of adding both', () async {
    await seedProfile();
    await seedOpening('2026-10', 1000);
    await h.isar.writeTxn(() async {
      await h.isar.budgetProfiles.put(BudgetProfile()
        ..profileId = 1
        ..yearMonth = '2026-10'
        ..name = 'Car'
        ..allocation = 20000
        ..spent = 0
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
      await h.isar.monthEndRuns.put(MonthEndRun()
        ..syncGuid = 'run-2'
        ..profileId = 1
        ..contextGuid = 'personal:1'
        ..yearMonth = '2026-10'
        ..destinationMonth = '2026-11'
        ..currency = 'usd'
        ..reportJson =
            '{"lines":[{"sourceGuid":"p1","allocation":50000,"spent":20000,"carried":30000,"released":0}]}'
        ..fingerprint = 'fp2'
        ..actor = 'actor'
        ..createdAt = DateTime.utc(2026)
        ..carriedMinor = 30000);
    });
    final result = await service().balance(profileId: 1, yearMonth: '2026-10');

    expect(result.allocatedMinor, 20000);
    expect(result.freeToUseMinor, 80000);
  });

  test('covered allocation spending does not reduce free-to-use twice',
      () async {
    await seedProfile();
    await seedOpening('2026-10', 1000);
    final profileId = await h.isar.writeTxn(() async {
      return h.isar.budgetProfiles.put(BudgetProfile()
        ..profileId = 1
        ..yearMonth = '2026-10'
        ..name = 'Car'
        ..allocation = 50000
        ..spent = 0
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
    });
    final before = await service().balance(profileId: 1, yearMonth: '2026-10');
    expect(before.freeToUseMinor, 50000);

    await h.isar.writeTxn(() async {
      await h.isar.expenses.put(Expense(
          profileId: 1,
          yearMonth: '2026-10',
          budgetId: 1,
          title: 'Covered spend',
          amount: 20000,
          currency: 'usd',
          categoryId: 'food',
          date: DateTime.utc(2026, 10, 5),
          status: ExpenseStatus.paid)
        ..budgetProfileId = profileId
        ..financialProfileType = FinancialProfileType.budget);
    });

    final after = await service().balance(profileId: 1, yearMonth: '2026-10');
    expect(after.allocatedMinor, 30000);
    expect(after.freeToUseMinor, before.freeToUseMinor,
        reason: 'covered spending moves money inside the envelope only');
  });

  test('spending above the allocation reduces free-to-use once for the excess',
      () async {
    await seedProfile();
    await seedOpening('2026-10', 1000);
    final profileId = await h.isar.writeTxn(() async {
      return h.isar.budgetProfiles.put(BudgetProfile()
        ..profileId = 1
        ..yearMonth = '2026-10'
        ..name = 'Car'
        ..allocation = 50000
        ..spent = 0
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
    });
    await h.isar.writeTxn(() async {
      await h.isar.expenses.put(Expense(
          profileId: 1,
          yearMonth: '2026-10',
          budgetId: 1,
          title: 'Excess spend',
          amount: 70000,
          currency: 'usd',
          categoryId: 'food',
          date: DateTime.utc(2026, 10, 5),
          status: ExpenseStatus.paid)
        ..budgetProfileId = profileId
        ..financialProfileType = FinancialProfileType.budget);
    });

    final result = await service().balance(profileId: 1, yearMonth: '2026-10');
    expect(result.allocatedMinor, 0);
    expect(result.freeToUseMinor, 30000); // 50,000 opening - 20,000 excess
  });
}
