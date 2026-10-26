import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/models/financial_report.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/services/report_calculation.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';

void main() {
  const owner = ReportOwner.personal(1);
  ReportRequest request() => ReportRequest(
      scope: ReportScope.personal,
      personalProfileId: 1,
      owners: [owner],
      firstMonth: '2026-10',
      lastMonth: '2026-10',
      currency: CurrencyCode.huf);
  Expense expense(int id, int amount, ExpenseStatus status) => Expense(
      id: id,
      profileId: 1,
      yearMonth: '2026-10',
      title: 'Item $id',
      amount: amount,
      currency: 'HUF',
      categoryId: 'food',
      date: DateTime(2026, 10, 20),
      budgetId: 1,
      status: status);
  ReportMonthInput input(
          {List<Expense> expenses = const [],
          List<Reimbursement> refunds = const [],
          List<BudgetProfile> budgets = const []}) =>
      ReportMonthInput(
          owner: owner,
          name: 'Personal',
          currency: CurrencyCode.huf,
          month: MonthlyBudget()
            ..id = 1
            ..profileId = 1
            ..yearMonth = '2026-10'
            ..baseAvailableAmount = 100000
            ..openingBalanceConfirmed = true
            ..createdAt = DateTime(2026)
            ..updatedAt = DateTime(2026),
          defaultIncome: 100000,
          expenses: expenses,
          refunds: refunds,
          budgets: budgets,
          directs: [],
          sources: [],
          settlements: [],
          vault: [],
          categories: {'food': 'Food'},
          recorded: {});
  test('paid/refunds/planned and opening funds reconcile separately', () {
    final result = calculateReportMonth(
        input(expenses: [
          expense(1, 10000, ExpenseStatus.paid),
          expense(2, 5000, ExpenseStatus.planned),
          expense(3, 9000, ExpenseStatus.cancelled)
        ], refunds: [
          Reimbursement(
              profileId: 1,
              expenseId: 1,
              originYearMonth: '2026-10',
              amount: 1000,
              currency: 'HUF',
              date: DateTime(2026, 11, 1))
        ]),
        request(),
        RateTableRegistry());
    expect(result.statement.issues, isEmpty);
    expect(result.statement.amounts['paid'], 10000);
    expect(result.statement.amounts['refunds'], 1000);
    expect(result.statement.amounts['net'], 9000);
    expect(result.statement.amounts['planned'], 5000);
    expect(result.statement.amounts['free'], 91000);
    expect(result.statement.amounts['bank'], 91000);
    expect(result.rows.last.month, '2026-10');
    expect(result.rows.last.recordedAt, DateTime(2026, 11, 1));
  });
  test('reserve cannot be borrowed twice across two overspent budgets', () {
    final a = BudgetProfile()
      ..id = 1
      ..profileId = 1
      ..yearMonth = '2026-10'
      ..name = 'A'
      ..allocation = 49000
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    final b = BudgetProfile()
      ..id = 2
      ..profileId = 1
      ..yearMonth = '2026-10'
      ..name = 'B'
      ..allocation = 49000
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    final ea = expense(1, 52000, ExpenseStatus.paid)
      ..budgetProfileId = 1
      ..financialProfileType = FinancialProfileType.budget
      ..financialProfileSyncGuid = a.syncGuid;
    final eb = expense(2, 52000, ExpenseStatus.paid)
      ..budgetProfileId = 2
      ..financialProfileType = FinancialProfileType.budget
      ..financialProfileSyncGuid = b.syncGuid;
    final result = calculateReportMonth(
        input(expenses: [ea, eb], budgets: [a, b]),
        request(),
        RateTableRegistry());
    expect(result.statement.issues, isEmpty);
    expect(result.statement.amounts['reserve'], 2000);
    expect(result.statement.amounts['borrowed'], 2000);
    expect(result.statement.amounts['deficit'], 4000);
    expect(result.statement.amounts['free'], -4000);
  });
  test(
      'unsupported currency and legacy missing refund are never invented zeros',
      () {
    final result = calculateReportMonth(
        input(expenses: [
          expense(1, 10000, ExpenseStatus.reimbursed)..currency = 'XYZ'
        ]),
        request(),
        RateTableRegistry());
    expect(result.statement.complete, isFalse);
    expect(result.rows.single.converted, isNull);
    expect(result.statement.amounts['net'], isNull);
  });
  test(
      'period parsing includes both boundary months and rejects duplicate scopes',
      () {
    expect(
        reportMonths('2025-12', '2026-02'), ['2025-12', '2026-01', '2026-02']);
    expect(() => reportMonths('2026-02', '2025-12'), throwsArgumentError);
    expect(
        () => ReportRequest(
            scope: ReportScope.consolidated,
            personalProfileId: 1,
            owners: [owner, owner],
            firstMonth: '2026-10',
            lastMonth: '2026-10',
            currency: CurrencyCode.huf),
        throwsArgumentError);
  });
  test('conversion rejects overflow before the engine can wrap', () {
    expect(
        () => reportConvert(9007199254740991, CurrencyCode.usd,
            CurrencyCode.huf, '2026-10', RateTableRegistry()),
        throwsFormatException);
    expect(
        reportConvert(1000, CurrencyCode.huf, CurrencyCode.huf, '2026-10',
            RateTableRegistry()),
        1000);
  });
  test(
      'zero insurer-paid medical row is counted once without invented spending',
      () {
    final result = calculateReportMonth(
        input(expenses: [
          expense(1, 0, ExpenseStatus.paid)..type = ExpenseType.medical,
          expense(2, 500, ExpenseStatus.paid)
        ]),
        request(),
        RateTableRegistry());
    expect(result.statement.issues, isEmpty);
    expect(result.rows.length, 2);
    expect(result.statement.amounts['paid'], 500);
    expect(result.statement.amounts['free'], 99500);
  });
}
