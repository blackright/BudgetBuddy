import 'package:budget_buddy/core/models/category.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/finance/providers/profile_providers.dart';
import 'package:budget_buddy/features/expenses/providers/expense_search_provider.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/money.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/engine/providers/true_available_provider.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/expenses/presentation/edit_expense_screen.dart';
import 'package:budget_buddy/features/expenses/providers/category_provider.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// T056: the live `≈ … at 1 $ = N Ft` hint also rides the edit form, so a
/// user correcting a pasted bill sees instantly how it compares in the
/// viewed month (FR-011, FR-014).
void main() {
  UserProfile makeProfile() => UserProfile()
    ..id = 1
    ..name = 'Test'
    ..primaryCurrency = PrimaryCurrency.usd;

  MonthlyBudget makeBudget() => MonthlyBudget()
    ..id = 1
    ..yearMonth = '2026-01'
    ..baseAvailableAmount = 1000.0
    ..currency = 'USD'
    ..createdAt = DateTime(2026)
    ..updatedAt = DateTime(2026);

  Expense makeExpense({
    required String currency,
    required double major,
  }) =>
      Expense(
        profileId: 1,
        yearMonth: '2026-01',
        budgetId: 1,
        title: 'Dentist',
        amount: Money.fromMajor(major, CurrencyCode.huf).minorUnits,
        currency: currency,
        categoryId: Expense.defaultCategoryId,
        date: DateTime(2026, 1, 15),
        status: ExpenseStatus.paid,
      );

  Future<void> pumpExpense(WidgetTester tester, Expense expense) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          budgetContextProvider.overrideWithValue(
              ContextRef.personal(profileId: 1, yearMonth: '2026-01')),
          budgetProfilesProvider.overrideWith((ref) => Stream.value([])),
          directExpenseProfilesProvider.overrideWith((ref) => Stream.value([])),
          expenseSearchMerchantsProvider
              .overrideWith((ref) => Stream.value([])),
          activeProfileProvider
              .overrideWith((ref) => Stream.value(makeProfile())),
          activeBudgetProvider
              .overrideWith((ref) => Stream.value(makeBudget())),
          selectedYearMonthProvider.overrideWith((ref) => '2026-01'),
          rateRegistryProvider.overrideWithValue(RateTableRegistry()),
          mainCurrencyProvider.overrideWithValue(CurrencyCode.huf),
          categoriesProvider.overrideWith((ref) async => const <Category>[]),
          // `safeToSpendProvider` drains these before the repositories can
          // reach IsarHelper.instance (uninitialized in widget tests).
          monthlyExpensesProvider.overrideWith(
            (ref) => Stream.value(const <Expense>[]),
          ),
          monthlyReimbursementsProvider.overrideWith(
            (ref) => Stream.value(const <Reimbursement>[]),
          ),
        ],
        child: MaterialApp(home: EditExpenseScreen(expense: expense)),
      ),
    );
  }

  Finder amountField() => find.byWidgetPredicate(
        (w) => w is TextField && (w.decoration?.labelText) == 'Amount',
      );

  testWidgets('hints the converted amount when the form currency differs',
      (WidgetTester tester) async {
    await pumpExpense(tester, makeExpense(currency: 'HUF', major: 345));
    await tester.pumpAndSettle();

    expect(find.textContaining('at 1 \$ = 345 Ft'), findsOneWidget);
    expect(find.textContaining('≈'), findsOneWidget);
  });

  testWidgets('keeps the hint hidden when the form currency is on display',
      (WidgetTester tester) async {
    await pumpExpense(tester, makeExpense(currency: 'USD', major: 100));
    await tester.pumpAndSettle();

    expect(find.textContaining('at 1 \$ = 345 Ft'), findsNothing);
  });

  testWidgets('clears the hint when the typed amount stops parsing',
      (WidgetTester tester) async {
    await pumpExpense(tester, makeExpense(currency: 'HUF', major: 345));
    await tester.pumpAndSettle();

    await tester.enterText(amountField(), 'abc');
    await tester.pump();

    expect(find.textContaining('at 1 \$ = 345 Ft'), findsNothing);
  });
  testWidgets(
      'legacy cancelled status and unknown currency stay unchanged while editing notes',
      (tester) async {
    final row = makeExpense(currency: 'XYZ', major: 345)
      ..status = ExpenseStatus.cancelled;
    await pumpExpense(tester, row);
    await tester.pumpAndSettle();
    expect(find.text('XYZ (legacy)'), findsOneWidget);
    expect(find.text('Status: Cancelled'), findsOneWidget);
    expect(tester.widget<TextField>(amountField()).controller!.text, '345');
    expect(row.currency, 'XYZ');
    expect(row.status, ExpenseStatus.cancelled);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'stored large decimal amounts load exactly without losing a minor unit',
      (tester) async {
    final row = makeExpense(currency: 'USD', major: 1)
      ..amount = 9007199254740991;
    await pumpExpense(tester, row);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(amountField()).controller!.text,
        '90,071,992,547,409.91');
    expect(row.amount, 9007199254740991);
    expect(tester.takeException(), isNull);
  });
}
