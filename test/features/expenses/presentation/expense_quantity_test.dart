import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/category.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/expenses/presentation/add_expense_screen.dart';
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
import '../support/recording_expenses_notifier.dart';

/// US1: the add-expense form records a whole-number quantity and stores the
/// checked line total while keeping the quantity as metadata.
void main() {
  late MedicalTestHarness h;
  late RecordingExpensesNotifier recorder;
  final month = currentYearMonth(DateTime.now());

  setUp(() async {
    h = await MedicalTestHarness.create();
    IsarHelper.instance = h.isar;
    recorder = RecordingExpensesNotifier();
  });
  tearDown(() => h.close());

  UserProfile profile() => UserProfile()
    ..id = 1
    ..name = 'Test Profile'
    ..primaryCurrency = PrimaryCurrency.usd;

  MonthlyBudget budget() => MonthlyBudget()
    ..id = 1
    ..yearMonth = month
    ..baseAvailableAmount = 1000.0
    ..currency = 'usd'
    ..createdAt = DateTime.now()
    ..updatedAt = DateTime.now();

  Widget host() {
    final router = GoRouter(
      initialLocation: '/add',
      routes: [
        GoRoute(
            path: '/', builder: (_, __) => const Scaffold(body: Text('back'))),
        GoRoute(path: '/add', builder: (_, __) => const AddExpenseScreen()),
      ],
    );
    addTearDown(router.dispose);
    return ProviderScope(
      overrides: [
        activeProfileProvider.overrideWith((ref) => Stream.value(profile())),
        activeBudgetProvider.overrideWith((ref) => Stream.value(budget())),
        selectedYearMonthProvider.overrideWith((ref) => month),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        categoriesProvider.overrideWith((ref) async => const <Category>[]),
        expenseSearchMerchantsProvider.overrideWith((ref) => Stream.value([])),
        budgetProfilesProvider.overrideWith((ref) => Stream.value([])),
        directExpenseProfilesProvider.overrideWith((ref) => Stream.value([])),
        expensesProvider.overrideWith((ref) => recorder),
        mainCurrencyProvider.overrideWithValue(CurrencyCode.usd),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Finder amountField() => find.byKey(const Key('addExpenseAmountField'));
  Finder quantityField() => find.byKey(const Key('addExpenseQuantityField'));
  Finder increase() => find.byKey(const Key('addExpenseQuantityIncrease'));
  Finder decrease() => find.byKey(const Key('addExpenseQuantityDecrease'));

  String amountText(WidgetTester tester) => tester
      .widget<TextField>(
          find.descendant(of: amountField(), matching: find.byType(TextField)))
      .controller!
      .text;
  String quantityText(WidgetTester tester) =>
      tester.widget<TextField>(quantityField()).controller!.text;

  testWidgets('quantity 1 keeps the simple amount-only entry step',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(quantityText(tester), '1');
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Unit price'), findsNothing);

    await tester.enterText(amountField(), '25');
    await tester.pump();

    expect(find.text('\$ 25.00'), findsOneWidget);
    expect(amountText(tester), '25');
    expect(find.textContaining(' × '), findsNothing);
    expect(tester.widget<IconButton>(decrease()).onPressed, isNull,
        reason: 'the minimum quantity cannot be stepped below 1');
  });

  testWidgets('stepping to quantity 2 shows the unit price and line total',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.enterText(amountField(), '25');
    await tester.tap(increase());
    await tester.pump();

    expect(quantityText(tester), '2');
    expect(find.text('Unit price'), findsOneWidget);
    expect(find.text('Amount'), findsNothing);
    expect(find.text('\$ 50.00'), findsOneWidget);
    expect(find.text('2 × \$ 25.00'), findsOneWidget);
    expect(tester.widget<IconButton>(decrease()).onPressed, isNotNull);
  });

  testWidgets('typing a quantity updates the derived line total',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.enterText(amountField(), '25');
    await tester.enterText(quantityField(), '3');
    await tester.pump();

    expect(quantityText(tester), '3');
    expect(find.text('\$ 75.00'), findsOneWidget);
    expect(find.text('3 × \$ 25.00'), findsOneWidget);
  });

  testWidgets('unsupported quantity blocks the save and reports the range',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byWidgetPredicate((w) =>
            w is TextField && w.decoration?.labelText == 'What did you buy?'),
        'Coffee');
    final merchant = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == 'Merchant *');
    await tester.ensureVisible(merchant);
    await tester.enterText(merchant, 'Cafe');
    await tester.enterText(amountField(), '25');
    await tester.enterText(quantityField(), '0');
    await tester.pump();

    await tester.tap(find.text('Save expense'));
    await tester.pump();

    expect(find.text('Choose a quantity from 1 to 999.'), findsOneWidget);
    expect(recorder.written, isEmpty);
  });

  testWidgets('the saved expense stores the line total and the quantity',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byWidgetPredicate((w) =>
            w is TextField && w.decoration?.labelText == 'What did you buy?'),
        'Coffee');
    await tester.enterText(amountField(), '25');
    await tester.tap(increase());
    await tester.pump();
    final merchant = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == 'Merchant *');
    await tester.ensureVisible(merchant);
    await tester.enterText(merchant, 'Cafe');
    await tester.pump();

    // The screen requires an explicit profile choice, including Main.
    await tester.ensureVisible(find.text('Change'));
    await tester.tap(find.text('Change'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mainProfileOption')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byIcon(Icons.calendar_month_outlined));
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();
    final today = DateTime.now();
    await tester.tap(find.text('${today.day}').last);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('destinationGuardDialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirmDestinationButton')));
    await tester.pumpAndSettle();

    expect(recorder.written, hasLength(1));
    final saved = recorder.written.single;
    expect(saved.amount, 5000, reason: '25.00 × 2 is the recorded total');
    expect(saved.quantity, 2);
    expect(saved.currency, 'USD');
  });
}
