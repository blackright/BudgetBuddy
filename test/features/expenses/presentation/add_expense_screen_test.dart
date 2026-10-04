import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_buddy/features/expenses/presentation/add_expense_screen.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';

void main() {
  testWidgets('AddExpenseScreen basic render test',
      (WidgetTester tester) async {
    final profile = UserProfile()
      ..id = 1
      ..name = 'Test Profile'
      ..primaryCurrency = PrimaryCurrency.usd;
    final budget = MonthlyBudget()
      ..id = 1
      ..yearMonth = '2026-10'
      ..baseAvailableAmount = 1000.0
      ..currency = PrimaryCurrency.usd
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
          activeBudgetProvider.overrideWith((ref) => Stream.value(budget)),
        ],
        child: const MaterialApp(
          home: AddExpenseScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Add Expense'), findsOneWidget);
    expect(find.text('What did you buy?'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Save Expense'), findsOneWidget);
  });
}
