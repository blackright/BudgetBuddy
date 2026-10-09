import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/money.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/network/rate_types.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/engine/providers/month_summary_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/engine/providers/true_available_provider.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/finance/providers/finance_providers.dart';
import 'package:budget_buddy/features/finance/repositories/month_finance_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Oracle for Phase 9-A (T053): the dashboard summary must present one single
/// currency.
///
/// The regression it guards: income and the confirmed opening balance were
/// passed straight through in profile-main HUF, while expenses were converted
/// to the month's display currency — producing a kept figure that mixed units.
/// Task T053 converts income + opening balance *from* the main currency through
/// the month's own table, exactly like the expenses already were.
void main() {
  const yearMonth = '2026-02';

  /// 1 US$ = 345 Ft; the rounded cross-rates below are exact for this table.
  RateTable table() => RateTable.tryCreate(
        usdRates: {
          CurrencyCode.usd: 1.0,
          CurrencyCode.huf: 345.0,
          CurrencyCode.cad: 1.36,
          CurrencyCode.eur: 0.92,
        },
        asOf: DateTime.utc(2026, 2, 1),
        fetchedAt: DateTime.utc(2026, 2, 1),
        source: RateSource.live,
      )!;

  UserProfile user({PrimaryCurrency primary = PrimaryCurrency.huf}) =>
      UserProfile()
        ..name = 'Tester'
        ..primaryCurrency = primary
        ..monthlyAvailableAmount = 0
        ..defaultNetSalary = 0
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026);

  MonthlyBudget month({
    String? currency,
    double baseAvailable = 345000,
  }) =>
      MonthlyBudget()
        ..id = 1
        ..yearMonth = yearMonth
        ..baseAvailableAmount = baseAvailable
        ..openingBalanceConfirmed = true
        ..currency = currency
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026);

  Expense hufExpense({
    required double huf,
    int id = 1,
    ExpenseStatus status = ExpenseStatus.paid,
    String categoryId = 'general',
  }) =>
      Expense(
        id: id,
        profileId: 1,
        yearMonth: yearMonth,
        title: 'HUF expense',
        amount: Money.fromMajor(huf, CurrencyCode.huf).minorUnits,
        currency: 'huf',
        categoryId: categoryId,
        status: status,
        date: DateTime(2026, 2, 10),
        budgetId: 1,
      );

  Reimbursement hufReimbursement({
    required double huf,
    int? expenseId = 1,
  }) =>
      Reimbursement(
        id: 99,
        profileId: 1,
        expenseId: expenseId,
        originYearMonth: yearMonth,
        amount: Money.fromMajor(huf, CurrencyCode.huf).minorUnits,
        currency: 'huf',
        date: DateTime(2026, 2, 20),
      );

  ProviderContainer build({
    required UserProfile? user,
    required MonthlyBudget? month,
    List<Expense> expenses = const [],
    List<Reimbursement> reimbursements = const [],
    ResolvedIncome resolvedIncome =
        const ResolvedIncome(amount: 690000, usesOverride: false),
  }) {
    final container = ProviderContainer(
      overrides: [
        selectedYearMonthProvider.overrideWith((ref) => yearMonth),
        activeProfileProvider.overrideWith((ref) => Stream.value(user)),
        activeBudgetProvider.overrideWith((ref) => Stream.value(month)),
        monthFinanceProvider.overrideWith((ref) => Stream.value(month)),
        rateRegistryProvider.overrideWithValue(RateTableRegistry(sealedTables: {
          yearMonth: table(),
        })),
        monthlyExpensesProvider.overrideWith((ref) => Stream.value(expenses)),
        monthlyOriginReimbursementsProvider
            .overrideWith((ref) => Stream.value(reimbursements)),
        monthlyReimbursementsProvider
            .overrideWith((ref) => Stream.value(reimbursements)),
        resolvedIncomeProvider.overrideWithValue(resolvedIncome),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Lets every overridden StreamProvider deliver its (single) event before the
  /// synchronous provider reads below, exactly like `await provider.future`.
  Future<ProviderContainer> prepared({
    required UserProfile? user,
    required MonthlyBudget? month,
    List<Expense> expenses = const [],
    List<Reimbursement> reimbursements = const [],
    ResolvedIncome resolvedIncome =
        const ResolvedIncome(amount: 690000, usesOverride: false),
  }) async {
    final container = build(
      user: user,
      month: month,
      expenses: expenses,
      reimbursements: reimbursements,
      resolvedIncome: resolvedIncome,
    );
    await container.read(activeProfileProvider.future);
    await container.read(activeBudgetProvider.future);
    await container.read(monthFinanceProvider.future);
    await container.read(monthlyExpensesProvider.future);
    await container.read(monthlyOriginReimbursementsProvider.future);
    return container;
  }

  group('T053: income and opening balance convert main -> display', () {
    test(
        'HUF income/opening show in USD when the month converts to USD '
        '(regression: no more mixed-unit kept)', () async {
      final container = await prepared(
        user: user(),
        month: month(currency: 'usd'),
        expenses: [
          hufExpense(huf: 34500, id: 1),
          hufExpense(huf: 17250, id: 2, status: ExpenseStatus.planned),
        ],
        reimbursements: [hufReimbursement(huf: 34500, expenseId: 1)],
      );

      final summary = container.read(monthSummaryProvider);

      // 690000 Ft -> $2000, 345000 Ft -> $1000, 34500 Ft -> $100.
      expect(summary.income, 2000.0);
      expect(summary.openingBalance, 1000.0);
      expect(summary.paymentsMade, 100.0);
      expect(summary.moneyReturned, 100.0);
      expect(summary.planned, 50.0);
      expect(summary.kept, 2000.0);
      expect(summary.moneyInBank, 3000.0);

      // The regression it guards: the raw HUF majors must not survive.
      expect(summary.income, isNot(690000.0));
      expect(summary.openingBalance, isNot(345000.0));
    });

    test('same-currency month is untouched (main HUF, no convert-to)',
        () async {
      final container = await prepared(
        user: user(),
        month: month(currency: null),
        expenses: [
          hufExpense(huf: 34500, id: 1),
          hufExpense(huf: 17250, id: 2, status: ExpenseStatus.planned),
        ],
      );

      final summary = container.read(monthSummaryProvider);

      expect(summary.income, 690000.0);
      expect(summary.openingBalance, 345000.0);
      expect(summary.paymentsMade, 34500.0);
      expect(summary.kept, 655500.0);
      expect(summary.moneyInBank, 1000500.0);
      expect(summary.isComplete, isTrue);
    });

    test('USD profile with a USD month passes values straight through',
        () async {
      final container = await prepared(
        user: user(primary: PrimaryCurrency.usd),
        month: month(currency: 'usd', baseAvailable: 1000),
      );

      final summary = container.read(monthSummaryProvider);

      expect(summary.income, 690000.0);
      expect(summary.openingBalance, 1000.0);
    });

    test('the override marker survives the conversion', () async {
      final container = await prepared(
        user: user(),
        month: month(currency: 'usd'),
        resolvedIncome:
            const ResolvedIncome(amount: 500000, usesOverride: true),
      );

      final summary = container.read(monthSummaryProvider);

      expect(summary.income, lessThan(2000.0));
      expect(summary.usesOverriddenIncome, isTrue);
    });

    test('no confirmed opening balance stays null regardless of currency',
        () async {
      final unconfirmed = month(currency: 'usd');
      unconfirmed.openingBalanceConfirmed = false;
      unconfirmed.baseAvailableAmount = 0;

      final container = await prepared(
        user: user(),
        month: unconfirmed,
      );

      expect(container.read(monthSummaryProvider).openingBalance, isNull);
    });
  });
}
