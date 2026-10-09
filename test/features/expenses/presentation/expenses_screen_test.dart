import 'package:budget_buddy/core/models/category.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/expenses/presentation/expenses_screen.dart';
import 'package:budget_buddy/features/expenses/providers/category_provider.dart';
import 'package:budget_buddy/features/expenses/repositories/expense_repository.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../medical/repositories/medical_test_harness.dart';

/// A repository whose Isar-backed watches resolve immediately, so the widgets
/// settle under the widget-test fake clock instead of spinning a loader while
/// a real Isar stream never emits.
class StaticExpenseRepo extends ExpenseRepository {
  StaticExpenseRepo(super.isar, {this.expenses = const <Expense>[]});

  final List<Expense> expenses;

  @override
  Stream<List<Expense>> watchExpenses(int profileId, String yearMonth) =>
      Stream.value(expenses);

  @override
  Stream<List<Reimbursement>> watchOrphanedReimbursements() =>
      Stream.value(const <Reimbursement>[]);

  @override
  Stream<List<Reimbursement>> watchReimbursementsForMonth(String yearMonth) =>
      Stream.value(const <Reimbursement>[]);
}

/// T055: the shared convert-to menu also rides the Expenses app bar — one
/// touch on any screen pins the viewed month to another display currency.
void main() {
  testWidgets('ExpensesScreen carries the month convert-to menu',
      (WidgetTester tester) async {
    // Isar I/O must not run under the widget-test fake clock; keep every real
    // read inside `runAsync`.
    late MedicalTestHarness harness;
    late MonthlyBudget budget;
    late UserProfile profile;
    await tester.runAsync(() async {
      harness = await MedicalTestHarness.create();
      final context = await harness.seedBudget();
      budget = (await harness.budgetFor(context.yearMonth))!;
      profile = (await harness.isar.userProfiles.get(context.profileId))!;
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
          activeBudgetProvider.overrideWith((ref) => Stream.value(budget)),
          selectedYearMonthProvider.overrideWith((ref) => '2026-01'),
          rateRegistryProvider.overrideWithValue(RateTableRegistry()),
          mainCurrencyProvider.overrideWithValue(CurrencyCode.huf),
          expenseRepositoryProvider
              .overrideWithValue(StaticExpenseRepo(harness.isar)),
          categoriesProvider.overrideWith((ref) async => const <Category>[]),
        ],
        child: const MaterialApp(home: ExpensesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Convert this month to'), findsOneWidget);

    await tester.tap(find.byTooltip('Convert this month to'));
    await tester.pumpAndSettle();

    expect(find.text('Show in Forint (default)'), findsOneWidget);
    expect(find.text('EUR (€)'), findsOneWidget);

    await tester.runAsync(harness.close);
  });

  testWidgets('each expense shows its conversion to the month display currency',
      (WidgetTester tester) async {
    // Isar I/O must not run under the widget-test fake clock; keep every real
    // read inside `runAsync`.
    late MedicalTestHarness harness;
    await tester.runAsync(() async {
      harness = await MedicalTestHarness.create();
    });
    final profile = UserProfile()
      ..id = 1
      ..name = 'Test'
      ..primaryCurrency = PrimaryCurrency.usd;
    final budget = MonthlyBudget()
      ..id = 1
      ..yearMonth = '2026-01'
      ..baseAvailableAmount = 10000.0
      ..currency = 'USD'
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    final hufExpense = Expense(
      profileId: 1,
      yearMonth: '2026-01',
      budgetId: 1,
      title: 'Coffee',
      amount: 1000,
      currency: 'huf',
      categoryId: Expense.defaultCategoryId,
      date: DateTime(2026, 1, 10),
      status: ExpenseStatus.paid,
    );
    final usdExpense = Expense(
      profileId: 1,
      yearMonth: '2026-01',
      budgetId: 1,
      title: 'Bagel',
      amount: 500,
      currency: 'usd',
      categoryId: Expense.defaultCategoryId,
      date: DateTime(2026, 1, 11),
      status: ExpenseStatus.paid,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
          activeBudgetProvider.overrideWith((ref) => Stream.value(budget)),
          selectedYearMonthProvider.overrideWith((ref) => '2026-01'),
          rateRegistryProvider.overrideWithValue(RateTableRegistry()),
          mainCurrencyProvider.overrideWithValue(CurrencyCode.huf),
          expenseRepositoryProvider.overrideWithValue(
            StaticExpenseRepo(harness.isar, expenses: [hufExpense, usdExpense]),
          ),
          categoriesProvider.overrideWith((ref) async => const <Category>[]),
        ],
        child: const MaterialApp(home: ExpensesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // 1000 Ft at the bundled 345 Ft/$ becomes $2.90 — caption under the row.
    expect(find.text('Ft 1,000'), findsOneWidget);
    expect(find.text('≈ \$ 2.90'), findsOneWidget);
    // A row already in the display currency shows no caption.
    expect(find.text('\$ 5.00'), findsOneWidget);
    expect(find.textContaining('≈'), findsOneWidget);

    await tester.runAsync(harness.close);
  });
}
