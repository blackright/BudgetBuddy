import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/category.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/core/services/expense_evidence.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/engine/providers/safe_to_spend_provider.dart';
import 'package:budget_buddy/features/engine/providers/true_available_provider.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/expenses/presentation/edit_expense_screen.dart';
import 'package:budget_buddy/features/expenses/providers/category_provider.dart';
import 'package:budget_buddy/features/expenses/providers/expense_search_provider.dart';
import 'package:budget_buddy/features/expenses/providers/expenses_provider.dart';
import 'package:budget_buddy/features/finance/providers/profile_providers.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../medical/repositories/medical_test_harness.dart';
import '../support/quantity_fixtures.dart';
import '../support/recording_expenses_notifier.dart';

/// US1: editing an expense exposes the derived unit price, blocks silent
/// rounding of a legacy non-divisible total, and preserves quantity in a copy.
void main() {
  late RecordingExpensesNotifier recorder;
  const month = '2026-10';

  setUp(() async {
    // The recording notifier captures writes without reaching Isar. Open a
    // throwaway instance just long enough to satisfy the notifier constructor,
    // then close it so no database watcher can keep the widget test alive.
    final h = await MedicalTestHarness.create();
    IsarHelper.instance = h.isar;
    recorder = RecordingExpensesNotifier();
    await h.close();
  });

  UserProfile profile() => UserProfile()
    ..id = 1
    ..name = 'Test'
    ..primaryCurrency = PrimaryCurrency.huf;

  MonthlyBudget budget() => MonthlyBudget()
    ..id = 1
    ..yearMonth = month
    ..baseAvailableAmount = 100000.0
    ..currency = 'HUF'
    ..createdAt = DateTime(2026)
    ..updatedAt = DateTime(2026);

  Expense row({int amount = 1000, int quantity = 2}) => quantityExpense(
        profileId: 1,
        yearMonth: month,
        amount: amount,
        quantity: quantity,
        currency: 'HUF',
        budgetId: 1,
        date: DateTime(2026, 10, 5),
      )
        ..merchantName = 'Cafe'
        ..paymentMethod = 'card'
        ..paymentEvidenceJson =
            const ExpenseEvidence(profileChosen: true).encode();

  Future<void> pump(WidgetTester tester, Expense expense) async {
    final router = GoRouter(
      initialLocation: '/edit',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Text('back')),
          routes: [
            GoRoute(
                path: 'edit',
                builder: (_, __) => EditExpenseScreen(expense: expense)),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        budgetContextProvider.overrideWithValue(
            ContextRef.personal(profileId: 1, yearMonth: month)),
        budgetProfilesProvider.overrideWith((ref) => Stream.value([])),
        directExpenseProfilesProvider.overrideWith((ref) => Stream.value([])),
        expenseSearchMerchantsProvider.overrideWith((ref) => Stream.value([])),
        activeProfileProvider.overrideWith((ref) => Stream.value(profile())),
        activeBudgetProvider.overrideWith((ref) => Stream.value(budget())),
        selectedYearMonthProvider.overrideWith((ref) => month),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        safeToSpendProvider.overrideWithValue(100000.0),
        mainCurrencyProvider.overrideWithValue(CurrencyCode.huf),
        categoriesProvider.overrideWith((ref) async => const <Category>[]),
        expensesProvider.overrideWith((ref) => recorder),
        monthlyExpensesProvider
            .overrideWith((ref) => Stream.value(const <Expense>[])),
        monthlyReimbursementsProvider
            .overrideWith((ref) => Stream.value(const <Reimbursement>[])),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();
  }

  Finder amountField() => find.byKey(const Key('editExpenseAmountField'));
  Finder quantityField() => find.byKey(const Key('editExpenseQuantityField'));
  Finder increase() => find.byKey(const Key('editExpenseQuantityIncrease'));
  Finder decrease() => find.byKey(const Key('editExpenseQuantityDecrease'));

  String amountText(WidgetTester tester) => tester
      .widget<TextField>(
          find.descendant(of: amountField(), matching: find.byType(TextField)))
      .controller!
      .text;
  String quantityText(WidgetTester tester) =>
      tester.widget<TextField>(quantityField()).controller!.text;

  testWidgets('an evenly divisible total opens at its derived unit price',
      (tester) async {
    await pump(tester, row(amount: 1000, quantity: 2));

    expect(amountText(tester), '500');
    expect(quantityText(tester), '2');
    expect(find.text('Unit price'), findsOneWidget);
    expect(find.text('Ft 1,000'), findsOneWidget);
    expect(find.text('2 × Ft 500'), findsOneWidget);
    expect(find.textContaining('cannot be divided evenly'), findsNothing);
  });

  testWidgets('a legacy non-divisible total is preserved and must be corrected',
      (tester) async {
    await pump(tester, row(amount: 1001, quantity: 2));

    expect(amountText(tester), '1,001');
    expect(quantityText(tester), '2');
    expect(find.textContaining('cannot be divided evenly'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Save Changes'), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
    await tester.pump();

    expect(
        find.text(
            'This saved total cannot be divided evenly. Set quantity to 1 or enter a unit price before saving.'),
        findsOneWidget);
    expect(recorder.written, isEmpty,
        reason: 'no silent rounding has been written');

    await tester.ensureVisible(decrease());
    await tester.pumpAndSettle();
    await tester.tap(decrease());
    await tester.pump();
    expect(quantityText(tester), '1');
    expect(
        find.text(
            'The saved total cannot be divided evenly. Set quantity to 1 or enter a unit price.'),
        findsNothing);
    expect(amountText(tester), '1,001');
  });

  testWidgets('changing the quantity recomputes the line total',
      (tester) async {
    await pump(tester, row(amount: 1000, quantity: 2));

    await tester.tap(increase());
    await tester.pump();

    expect(quantityText(tester), '3');
    expect(find.text('Ft 1,500'), findsOneWidget);
    expect(find.text('3 × Ft 500'), findsOneWidget);
  });

  testWidgets('saving writes the recomputed line total and the new quantity',
      (tester) async {
    final source = row(amount: 1000, quantity: 2);
    await pump(tester, source);

    await tester.tap(increase());
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Save Changes'), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
    await tester.pumpAndSettle();

    expect(recorder.written, hasLength(1));
    final saved = recorder.written.single;
    expect(saved.amount, 1500);
    expect(saved.quantity, 3);
  });

  testWidgets('duplicate keeps the quantity and copies the line total',
      (tester) async {
    final source = row(amount: 1000, quantity: 2);
    await pump(tester, source);

    await tester.tap(increase());
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Duplicate Expense'), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Duplicate Expense'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('destinationGuardDialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirmDestinationButton')));
    await tester.pumpAndSettle();

    expect(recorder.written, hasLength(1));
    final copy = recorder.written.single;
    expect(copy.amount, 1500);
    expect(copy.quantity, 3);
    expect(copy.status, ExpenseStatus.planned);
  });

  testWidgets('a duplicate is blocked while the saved total needs correction',
      (tester) async {
    await pump(tester, row(amount: 1001, quantity: 2));

    await tester.scrollUntilVisible(find.text('Duplicate Expense'), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Duplicate Expense'));
    await tester.pump();

    expect(
        find.text(
            'This saved total cannot be divided evenly. Set quantity to 1 or enter a unit price before making a copy.'),
        findsOneWidget);
  });
}
