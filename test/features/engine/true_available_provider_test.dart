import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/money.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/network/rate_types.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/engine/providers/safe_to_spend_provider.dart';
import 'package:budget_buddy/features/engine/providers/true_available_provider.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Oracle for Phase 9-A (T053): True Available and the Safe-to-Spend derived
/// from it must be single-currency.
///
/// Regression: the confirmed opening balance was relabelled into the display
/// currency instead of converted, so a HUF month shown in USD reported a base
/// of 345,000 "USD". T053 converts it from the profile main currency through
/// the month's table, exactly as the expenses are.
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

  Expense expenseIn({
    required String currencyCode,
    required double major,
    int id = 1,
    ExpenseStatus status = ExpenseStatus.paid,
  }) {
    final code = CurrencyCode.tryParse(currencyCode)!;
    return Expense(
      id: id,
      profileId: 1,
      yearMonth: yearMonth,
      title: 'Expense in $currencyCode',
      amount: Money.fromMajor(major, code).minorUnits,
      currency: currencyCode,
      categoryId: 'general',
      status: status,
      date: DateTime(2026, 2, 10),
      budgetId: 1,
    );
  }

  Reimbursement reimbursementIn({
    required String currencyCode,
    required double major,
    int expenseId = 1,
  }) {
    final code = CurrencyCode.tryParse(currencyCode)!;
    return Reimbursement(
      id: 99,
      profileId: 1,
      expenseId: expenseId,
      originYearMonth: yearMonth,
      amount: Money.fromMajor(major, code).minorUnits,
      currency: currencyCode,
      date: DateTime(2026, 2, 20),
    );
  }

  ProviderContainer build({
    required UserProfile? user,
    required MonthlyBudget? month,
    List<Expense> expenses = const [],
    List<Reimbursement> reimbursements = const [],
  }) {
    final container = ProviderContainer(
      overrides: [
        selectedYearMonthProvider.overrideWith((ref) => yearMonth),
        activeProfileProvider.overrideWith((ref) => Stream.value(user)),
        activeBudgetProvider.overrideWith((ref) => Stream.value(month)),
        rateRegistryProvider.overrideWithValue(RateTableRegistry(sealedTables: {
          yearMonth: table(),
        })),
        monthlyExpensesProvider.overrideWith((ref) => Stream.value(expenses)),
        monthlyReimbursementsProvider
            .overrideWith((ref) => Stream.value(reimbursements)),
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
  }) async {
    final container = build(
      user: user,
      month: month,
      expenses: expenses,
      reimbursements: reimbursements,
    );
    await container.read(activeProfileProvider.future);
    await container.read(activeBudgetProvider.future);
    await container.read(monthlyExpensesProvider.future);
    await container.read(monthlyReimbursementsProvider.future);
    return container;
  }

  group('T053: the opening balance converts main -> display', () {
    test(
        'HUF month shown in USD: 345000 Ft becomes 1000 USD, not 345000 '
        '(regression)', () async {
      final container = await prepared(
        user: user(),
        month: month(currency: 'usd'),
        expenses: [expenseIn(currencyCode: 'huf', major: 34500, id: 1)],
      );

      final trueAvailable = container.read(trueAvailableProvider);

      // 345000 Ft -> $1000 base, minus the 34500 Ft ($100) paid expense.
      expect(trueAvailable, 900.0);
      // The regression it guards: the raw HUF base must not survive.
      expect(trueAvailable, isNot(345000.0 - 100.0 - 34500.0));
    });

    test(
        'reimbursements convert too: 345000 Ft base, minus 50 USD paid, '
        'minus 100 USD reimbursed, plus 100 USD returned', () async {
      final container = await prepared(
        user: user(),
        month: month(currency: 'usd'),
        expenses: [
          expenseIn(currencyCode: 'huf', major: 17250, id: 1),
          expenseIn(
              currencyCode: 'huf',
              major: 34500,
              id: 2,
              status: ExpenseStatus.reimbursed),
        ],
        reimbursements: [
          reimbursementIn(currencyCode: 'huf', major: 34500, expenseId: 2),
        ],
      );

      expect(container.read(trueAvailableProvider), 950.0);
    });

    test('Safe-to-Spend subtracts planned in the same display currency',
        () async {
      final container = await prepared(
        user: user(),
        month: month(currency: 'usd'),
        expenses: [
          expenseIn(currencyCode: 'huf', major: 34500, id: 1),
          expenseIn(
              currencyCode: 'huf',
              major: 17250,
              id: 2,
              status: ExpenseStatus.planned),
        ],
      );

      expect(container.read(trueAvailableProvider), 900.0);
      expect(container.read(safeToSpendProvider), 850.0);
    });

    test('same-currency month is untouched', () async {
      final container = await prepared(
        user: user(primary: PrimaryCurrency.usd),
        month: month(currency: 'usd', baseAvailable: 1000),
        expenses: [expenseIn(currencyCode: 'usd', major: 100, id: 1)],
      );

      expect(container.read(trueAvailableProvider), 900.0);
    });

    test('no budget yields zero', () async {
      final container = await prepared(user: user(), month: null);

      expect(container.read(trueAvailableProvider), 0.0);
      expect(container.read(safeToSpendProvider), 0.0);
    });
  });
}
