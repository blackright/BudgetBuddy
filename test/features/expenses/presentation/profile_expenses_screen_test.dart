import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/dashboard/providers/dashboard_providers.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/expenses/presentation/profile_expenses_screen.dart';
import 'package:budget_buddy/features/finance/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Expense expense({
    int id = 1,
    String title = 'Groceries',
    ExpenseStatus status = ExpenseStatus.paid,
  }) {
    return Expense(
      profileId: 1,
      sharedSpaceId: null,
      type: ExpenseType.standard,
      yearMonth: '2026-01',
      budgetId: 1,
      budgetProfileId: 1,
      financialProfileType: FinancialProfileType.budget,
      title: title,
      amount: 15000,
      currency: 'huf',
      categoryId: Expense.defaultCategoryId,
      date: DateTime(2026, 1, 15),
      status: status,
    )..id = id;
  }

  BudgetProfile budget() {
    return BudgetProfile()
      ..id = 1
      ..name = 'Food'
      ..yearMonth = '2026-01'
      ..allocation = 50000
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
  }

  Widget wrap({
    Brightness brightness = Brightness.light,
    List<Expense>? expenses,
  }) {
    return ProviderScope(
      overrides: [
        dashboardCurrencyProvider.overrideWithValue(CurrencyCode.huf),
        selectedYearMonthProvider.overrideWith((ref) => '2026-01'),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        budgetProfilesProvider.overrideWith(
          (ref) => Stream.value([budget()]),
        ),
        directExpenseProfilesProvider.overrideWith(
          (ref) => Stream.value(const []),
        ),
        contextExpensesProvider.overrideWithValue(expenses ?? [expense()]),
      ],
      child: MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: const ProfileExpensesScreen(profileId: 1),
      ),
    );
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    List<Expense>? expenses,
  }) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrap(brightness: brightness, expenses: expenses),
    );
    await tester.pumpAndSettle();
  }

  RoundedRectangleBorder cardShape(WidgetTester tester, int id) {
    final material = tester.widget<Material>(
      find
          .descendant(
            of: find.byKey(Key('profileExpense-$id')),
            matching: find.byType(Material),
          )
          .first,
    );
    return material.shape! as RoundedRectangleBorder;
  }

  testWidgets('shows each expense as a bordered card with minimal details',
      (tester) async {
    await pumpScreen(tester);

    expect(find.text('Food'), findsOneWidget);
    expect(find.byKey(const Key('profileExpense-1')), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('15 Jan 2026'), findsOneWidget);
    expect(find.text('Paid'), findsOneWidget);
    expect(find.text('Ft 15,000'), findsOneWidget);
    expect(find.widgetWithText(FloatingActionButton, 'Add expense'),
        findsOneWidget);

    final context = tester.element(find.byKey(const Key('profileExpense-1')));
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final shape = cardShape(tester, 1);
    expect(shape.side.color, outline);
    expect(shape.side.width, greaterThan(0));
  });

  testWidgets('expense card outlines stay visible in dark mode',
      (tester) async {
    await pumpScreen(tester, brightness: Brightness.dark);

    final context = tester.element(find.byKey(const Key('profileExpense-1')));
    final outline = Theme.of(context).colorScheme.outlineVariant;
    expect(outline.a, greaterThan(0));

    final shape = cardShape(tester, 1);
    expect(shape.side.color, outline);
    expect(shape.side.color.a, greaterThan(0));
  });
}
