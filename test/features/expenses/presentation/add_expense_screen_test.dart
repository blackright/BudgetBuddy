import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_buddy/features/expenses/presentation/add_expense_screen.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';

void main() {
  UserProfile makeProfile(PrimaryCurrency currency) => UserProfile()
    ..id = 1
    ..name = 'Test Profile'
    ..primaryCurrency = currency;

  MonthlyBudget makeBudget({String currency = 'usd'}) => MonthlyBudget()
    ..id = 1
    ..yearMonth = '2026-10'
    ..baseAvailableAmount = 1000.0
    ..currency = currency
    ..createdAt = DateTime.now()
    ..updatedAt = DateTime.now();

  Widget pump(
    WidgetTester tester, {
    required UserProfile profile,
    required MonthlyBudget budget,
  }) {
    return ProviderScope(
      overrides: [
        activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
        activeBudgetProvider.overrideWith((ref) => Stream.value(budget)),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
      ],
      child: const MaterialApp(
        home: AddExpenseScreen(),
      ),
    );
  }

  testWidgets('AddExpenseScreen basic render test',
      (WidgetTester tester) async {
    await tester.pumpWidget(pump(
      tester,
      profile: makeProfile(PrimaryCurrency.usd),
      budget: makeBudget(),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Add Expense'), findsOneWidget);
    expect(find.text('What did you buy?'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Save Expense'), findsOneWidget);
  });

  testWidgets('defaults the currency to the profile main, not the budget',
      (WidgetTester tester) async {
    final profile = makeProfile(PrimaryCurrency.huf);
    final budget = makeBudget(currency: 'usd');
    await tester.pumpWidget(pump(tester, profile: profile, budget: budget));
    await tester.pumpAndSettle();

    expect(find.text('HUF'), findsOneWidget);
    expect(find.text('USD'), findsNothing);
  });

  Finder amountField() => find.byWidgetPredicate(
        (w) => w is TextField && (w.decoration?.labelText) == 'Amount',
      );

  testWidgets('shows the cross-rate hint once the amount differs in currency',
      (WidgetTester tester) async {
    final profile = makeProfile(PrimaryCurrency.huf);
    final budget = makeBudget(currency: 'usd');
    await tester.pumpWidget(pump(tester, profile: profile, budget: budget));
    await tester.pumpAndSettle();

    await tester.enterText(amountField(), '100');
    await tester.pump();

    expect(find.textContaining('at 1 \$ = 345 Ft'), findsOneWidget);
    expect(find.textContaining('≈'), findsOneWidget);
  });

  testWidgets('clears the hint when the input is not a number',
      (WidgetTester tester) async {
    final profile = makeProfile(PrimaryCurrency.huf);
    final budget = makeBudget(currency: 'usd');
    await tester.pumpWidget(pump(tester, profile: profile, budget: budget));
    await tester.pumpAndSettle();

    await tester.enterText(amountField(), 'oops');
    await tester.pump();

    expect(find.textContaining('at 1 \$ = 345 Ft'), findsNothing);
  });

  testWidgets('keeps the hint hidden when the currency matches the display',
      (WidgetTester tester) async {
    final profile = makeProfile(PrimaryCurrency.usd);
    final budget = makeBudget(currency: 'usd');
    await tester.pumpWidget(pump(tester, profile: profile, budget: budget));
    await tester.pumpAndSettle();

    await tester.enterText(amountField(), '100');
    await tester.pump();

    expect(find.textContaining('at 1 \$ = 345 Ft'), findsNothing);
  });
}
