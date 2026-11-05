import 'package:budget_buddy/features/expenses/providers/expense_search_provider.dart';
import 'package:budget_buddy/features/expenses/providers/daily_cards_provider.dart';
import 'package:budget_buddy/features/expenses/presentation/widgets/daily_expense_card.dart';
import 'package:budget_buddy/core/models/category.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/expenses/presentation/expenses_screen.dart';
import 'package:budget_buddy/features/expenses/providers/category_provider.dart';
import 'package:budget_buddy/features/expenses/repositories/expense_repository.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../medical/repositories/medical_test_harness.dart';

/// A repository whose Isar-backed watches resolve immediately, so the widgets
/// settle under the widget-test fake clock instead of spinning a loader while
/// a real Isar stream never emits.
class StaticExpenseRepo extends ExpenseRepository {
  StaticExpenseRepo(super.isar, {this.expenses = const <Expense>[]});

  final List<Expense> expenses;

  @override
  Stream<List<Expense>> watchExpensesForContext(ContextRef context) =>
      Stream.value(expenses);

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
          expenseSearchRowsProvider
              .overrideWith((ref) => Stream.value(const <Expense>[])),
          budgetContextProvider.overrideWithValue(
              ContextRef.personal(profileId: profile.id, yearMonth: '2026-01')),
          activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
          activeBudgetProvider.overrideWith((ref) => Stream.value(budget)),
          selectedYearMonthProvider.overrideWith((ref) => '2026-01'),
          rateRegistryProvider.overrideWithValue(RateTableRegistry()),
          mainCurrencyProvider.overrideWithValue(CurrencyCode.huf),
          expenseRepositoryProvider
              .overrideWithValue(StaticExpenseRepo(harness.isar)),
          categoriesProvider.overrideWith((ref) async => const <Category>[]),
          expenseSearchMerchantsProvider
              .overrideWith((ref) => Stream.value([])),
          expenseSearchProfileNamesProvider
              .overrideWith((ref) async => {'main': 'Main'}),
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
          expenseSearchRowsProvider
              .overrideWith((ref) => Stream.value([hufExpense, usdExpense])),
          expenseSearchMerchantsProvider
              .overrideWith((ref) => Stream.value([])),
          dailyCardReturnsProvider.overrideWith((ref) => Stream.value([])),
          budgetContextProvider.overrideWithValue(
              ContextRef.personal(profileId: profile.id, yearMonth: '2026-01')),
          activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
          activeBudgetProvider.overrideWith((ref) => Stream.value(budget)),
          selectedYearMonthProvider.overrideWith((ref) => '2026-01'),
          rateRegistryProvider.overrideWithValue(RateTableRegistry()),
          mainCurrencyProvider.overrideWithValue(CurrencyCode.huf),
          expenseRepositoryProvider.overrideWithValue(
            StaticExpenseRepo(harness.isar, expenses: [hufExpense, usdExpense]),
          ),
          categoriesProvider.overrideWith((ref) async => const <Category>[]),
          expenseSearchMerchantsProvider
              .overrideWith((ref) => Stream.value([])),
          expenseSearchProfileNamesProvider
              .overrideWith((ref) async => {'main': 'Main'}),
        ],
        child: const MaterialApp(home: ExpensesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // T157: 1000 Ft at the bundled 345 Ft/$ reads as the primary "$ 2.90";
    // the recorded Ft amount lives in the long-press tooltip.
    await tester.tap(find.byWidgetPredicate((widget) =>
        widget is DailyExpenseCardTile && widget.day.date.day == 10));
    await tester.pumpAndSettle();
    expect(find.text('\$ 2.90'), findsOneWidget);
    expect(find.text('Ft 1,000'), findsNothing);
    // A row already in the display currency is unchanged.
    await tester.tap(find.byTooltip('Close day'));
    await tester.pumpAndSettle();
    await tester.tap(find.byWidgetPredicate((widget) =>
        widget is DailyExpenseCardTile && widget.day.date.day == 11));
    await tester.pumpAndSettle();
    expect(find.text('\$ 5.00'), findsOneWidget);
    expect(find.textContaining('≈'), findsNothing);

    await tester.runAsync(harness.close);
  });

  // T030: bulk entry is a first-class, always-visible action instead of a
  // hidden menu item. It stays reachable at narrow widths and large text.
  testWidgets(
      'editable context shows a visible bulk entry that opens its route',
      (WidgetTester tester) async {
    late MedicalTestHarness harness;
    late UserProfile profile;
    late MonthlyBudget budget;
    await tester.runAsync(() async {
      harness = await MedicalTestHarness.create();
      final context = await harness.seedBudget();
      budget = (await harness.budgetFor(context.yearMonth))!;
      profile = (await harness.isar.userProfiles.get(context.profileId))!;
    });

    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const ExpensesScreen()),
      GoRoute(
          path: '/bulk_entry',
          builder: (_, __) => const Scaffold(body: Text('Bulk entry route'))),
    ]);
    addTearDown(router.dispose);
    await pumpExpenses(tester,
        harness: harness, profile: profile, budget: budget, router: router);

    // The label is on screen without opening any menu.
    expect(find.text('Bulk entry'), findsOneWidget);
    final button = tester.widget(find.byKey(const ValueKey('bulk-entry')));
    expect(button, isA<FilledButton>());
    expect(find.byIcon(Icons.playlist_add), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('bulk-entry')));
    await tester.pumpAndSettle();
    expect(find.text('Bulk entry route'), findsOneWidget);
    expect(find.byType(ExpensesScreen), findsNothing);

    await tester.runAsync(harness.close);
  });

  testWidgets('read-only context hides bulk entry and add expense',
      (WidgetTester tester) async {
    late MedicalTestHarness harness;
    late UserProfile profile;
    late MonthlyBudget budget;
    await tester.runAsync(() async {
      harness = await MedicalTestHarness.create();
      final context = await harness.seedBudget();
      budget = (await harness.budgetFor(context.yearMonth))!;
      profile = (await harness.isar.userProfiles.get(context.profileId))!;
    });

    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const ExpensesScreen()),
      GoRoute(
          path: '/bulk_entry',
          builder: (_, __) => const Scaffold(body: Text('Bulk entry route'))),
    ]);
    addTearDown(router.dispose);
    await pumpExpenses(tester,
        harness: harness,
        profile: profile,
        budget: budget,
        router: router,
        canEdit: false);

    expect(find.text('Bulk entry'), findsNothing);
    expect(find.byKey(const ValueKey('bulk-entry')), findsNothing);
    expect(find.text('Add expense'), findsNothing);

    await tester.runAsync(harness.close);
  });

  testWidgets('narrow phone keeps bulk entry as a labelled icon action',
      (WidgetTester tester) async {
    // `setSurfaceSize` does not reach the MediaQuery used by the app shell on
    // this Flutter version; drive the actual view instead.
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    late MedicalTestHarness harness;
    late UserProfile profile;
    late MonthlyBudget budget;
    await tester.runAsync(() async {
      harness = await MedicalTestHarness.create();
      final context = await harness.seedBudget();
      budget = (await harness.budgetFor(context.yearMonth))!;
      profile = (await harness.isar.userProfiles.get(context.profileId))!;
    });

    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const ExpensesScreen()),
      GoRoute(
          path: '/bulk_entry',
          builder: (_, __) => const Scaffold(body: Text('Bulk entry route'))),
    ]);
    addTearDown(router.dispose);
    await pumpExpenses(tester,
        harness: harness, profile: profile, budget: budget, router: router);

    // The text label yields, but the action never disappears behind a menu.
    final appContext = tester.element(find.byType(ExpensesScreen));
    expect(MediaQuery.sizeOf(appContext).width, 320);
    expect(find.text('Bulk entry'), findsNothing);
    final compact = find.byKey(const ValueKey('bulk-entry'));
    expect(compact, findsOneWidget);
    expect(tester.widget(compact), isA<IconButton>());
    expect(find.byTooltip('Bulk entry'), findsOneWidget);

    await tester.tap(compact);
    await tester.pumpAndSettle();
    expect(find.text('Bulk entry route'), findsOneWidget);

    await tester.runAsync(harness.close);
  });

  testWidgets('200% text keeps bulk entry visible as an icon action',
      (WidgetTester tester) async {
    late MedicalTestHarness harness;
    late UserProfile profile;
    late MonthlyBudget budget;
    await tester.runAsync(() async {
      harness = await MedicalTestHarness.create();
      final context = await harness.seedBudget();
      budget = (await harness.budgetFor(context.yearMonth))!;
      profile = (await harness.isar.userProfiles.get(context.profileId))!;
    });

    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const ExpensesScreen()),
    ]);
    addTearDown(router.dispose);
    await pumpExpenses(tester,
        harness: harness,
        profile: profile,
        budget: budget,
        router: router,
        textScaler: const TextScaler.linear(2));

    expect(find.text('Bulk entry'), findsNothing);
    expect(find.byKey(const ValueKey('bulk-entry')), findsOneWidget);
    expect(find.byTooltip('Bulk entry'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.runAsync(harness.close);
  });
}

/// Pumps the real Expenses screen with the same lightweight stream fakes the
/// other cases use, so no Isar watcher spins under the fake test clock.
Future<void> pumpExpenses(
  WidgetTester tester, {
  required MedicalTestHarness harness,
  required UserProfile profile,
  required MonthlyBudget budget,
  required GoRouter router,
  bool canEdit = true,
  TextScaler? textScaler,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        expenseSearchRowsProvider
            .overrideWith((ref) => Stream.value(const <Expense>[])),
        budgetContextProvider.overrideWithValue(
            ContextRef.personal(profileId: profile.id, yearMonth: '2026-01')),
        activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
        activeBudgetProvider.overrideWith((ref) => Stream.value(budget)),
        selectedYearMonthProvider.overrideWith((ref) => '2026-01'),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        mainCurrencyProvider.overrideWithValue(CurrencyCode.huf),
        activeContextCanEditProvider.overrideWithValue(canEdit),
        expenseRepositoryProvider
            .overrideWithValue(StaticExpenseRepo(harness.isar)),
        categoriesProvider.overrideWith((ref) async => const <Category>[]),
        expenseSearchMerchantsProvider.overrideWith((ref) => Stream.value([])),
        expenseSearchProfileNamesProvider
            .overrideWith((ref) async => {'main': 'Main'}),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        builder: textScaler == null
            ? null
            : (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: textScaler),
                  child: child!,
                ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
