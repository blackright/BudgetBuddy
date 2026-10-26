import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/features/expenses/providers/category_provider.dart';
import 'package:budget_buddy/features/expenses/providers/expense_search_provider.dart';
import 'package:budget_buddy/core/models/category.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:budget_buddy/core/database/isar_helper.dart';
import '../../medical/repositories/medical_test_harness.dart';
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
  late MedicalTestHarness h;
  setUp(() async {
    h = await MedicalTestHarness.create();
    IsarHelper.instance = h.isar;
  });
  tearDown(() => h.close());
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
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const AddExpenseScreen())
    ]);
    addTearDown(router.dispose);
    return ProviderScope(
      overrides: [
        activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
        activeBudgetProvider.overrideWith((ref) => Stream.value(budget)),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        categoriesProvider.overrideWith((ref) async => const <Category>[]),
        expenseSearchMerchantsProvider.overrideWith((ref) => Stream.value([])),
        mainCurrencyProvider.overrideWithValue(profile.primaryCurrency.code),
      ],
      child: MaterialApp.router(routerConfig: router),
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

  testWidgets('groups a large amount while typing (US1, SC-001)',
      (WidgetTester tester) async {
    final profile = makeProfile(PrimaryCurrency.usd);
    final budget = makeBudget(currency: 'usd');
    await tester.pumpWidget(pump(tester, profile: profile, budget: budget));
    await tester.pumpAndSettle();

    await tester.enterText(amountField(), '1000000');
    await tester.pump();

    expect(
        tester.widget<TextField>(amountField()).controller!.text, '1,000,000');
  });
  testWidgets(
      'an oversized amount cannot produce a wrapped negative conversion hint',
      (tester) async {
    await tester.pumpWidget(pump(tester,
        profile: makeProfile(PrimaryCurrency.huf), budget: makeBudget()));
    await tester.pumpAndSettle();
    await tester.enterText(amountField(), '1000000000000000000000000');
    await tester.pump();
    expect(find.textContaining('at 1 \$'), findsNothing);
    expect(tester.state<FormState>(find.byType(Form)).validate(), isFalse);
    await tester.pump();
    expect(find.text('Amount is too large.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
