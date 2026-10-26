import 'package:budget_buddy/core/models/category.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/routing/app_router.dart';
import 'package:budget_buddy/features/analytics/domain/chart_series.dart';
import 'package:budget_buddy/features/analytics/presentation/charts/category_chart.dart';
import 'package:budget_buddy/features/analytics/presentation/charts/planned_paid_chart.dart';
import 'package:budget_buddy/features/dashboard/presentation/month_summary_detail_screen.dart';
import 'package:budget_buddy/features/dashboard/providers/dashboard_providers.dart';
import 'package:budget_buddy/features/engine/month_summary.dart';
import 'package:budget_buddy/features/engine/providers/month_summary_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/engine/providers/true_available_provider.dart';
import 'package:budget_buddy/features/expenses/presentation/expenses_screen.dart';
import 'package:budget_buddy/features/expenses/providers/category_provider.dart';
import 'package:budget_buddy/features/expenses/providers/expense_search_provider.dart';
import 'package:budget_buddy/features/finance/providers/finance_providers.dart';
import 'package:budget_buddy/features/finance/providers/income_source_providers.dart';
import 'package:budget_buddy/features/finance/providers/profile_providers.dart';
import 'package:budget_buddy/features/finance/providers/reserve_providers.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:budget_buddy/shared/presentation/app_shell.dart';
import 'package:budget_buddy/shared/presentation/providers/context_navigation_provider.dart';
import 'package:budget_buddy/core/services/context_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  Future<GoRouter> pumpApp(WidgetTester tester,
      {MonthSummary? summary,
      CurrencyCode? displayCurrency,
      int borrowed = 0}) async {
    final router = createAppRouter(initialLocation: '/dashboard');
    addTearDown(router.dispose);
    final month = displayCurrency == null
        ? null
        : (MonthlyBudget()
          ..yearMonth = '2026-01'
          ..baseAvailableAmount = 1000
          ..currency = displayCurrency.code);
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Keep the real screens and router; replace only their data sources.
          activeProfileProvider.overrideWith((ref) => Stream.value(null)),
          contextDestinationsProvider.overrideWith((ref) async => const [
                ContextDestination(name: 'Family', spaceId: 7, locked: false)
              ]),
          selectNavigationContextProvider.overrideWith((ref) => (id) async {
                ref.read(activeSpaceIdProvider.notifier).state = id;
                return ContextDestination(
                    name: 'Family', spaceId: id, locked: false);
              }),
          activeSpaceProvider.overrideWith((ref) => Stream.value(null)),
          mySpacesProvider.overrideWith((ref) => Stream.value([])),
          activeBudgetProvider.overrideWith((ref) => Stream.value(month)),
          budgetContextProvider.overrideWith((ref) {
            final space = ref.watch(activeSpaceIdProvider);
            return space == null
                ? ContextRef.personal(profileId: 1, yearMonth: '2026-01')
                : ContextRef.shared(spaceId: space, yearMonth: '2026-01');
          }),
          activeContextCanEditProvider.overrideWithValue(false),
          dashboardProfilesProvider.overrideWithValue([]),
          dashboardBorrowingTotalsProvider.overrideWithValue(
            (borrowed: borrowed, deficit: 0),
          ),
          incomeSourcesProvider.overrideWith((ref) => Stream.value([])),
          budgetProfilesProvider.overrideWith((ref) => Stream.value([])),
          directExpenseProfilesProvider.overrideWith((ref) => Stream.value([])),
          contextExpensesProvider.overrideWithValue([]),
          availableReserveProvider.overrideWithValue(0),
          monthSummaryProvider.overrideWithValue(
            summary ??
                const MonthSummary(
                  yearMonth: '2026-01',
                  income: 4000,
                  usesOverriddenIncome: false,
                  paymentsMade: 1200,
                  moneyReturned: 300,
                  expenseReturned: 300,
                  planned: 800,
                  cancelled: 0,
                  medicalPaid: 200,
                  excessReturned: 0,
                  openingBalance: 1000,
                ),
          ),
          monthlyExpensesProvider.overrideWith((ref) => Stream.value([])),
          monthlyOriginReimbursementsProvider
              .overrideWith((ref) => Stream.value([])),
          monthlyReimbursementsProvider.overrideWith((ref) => Stream.value([])),
          monthFinanceProvider.overrideWith((ref) => Stream.value(month)),
          activeSpaceMembersProvider.overrideWith((ref) => Stream.value([])),
          categoriesProvider.overrideWith((ref) async => [
                Category(
                  categoryId: 'food',
                  name: 'Food',
                  emoji: '',
                  colorValue: 0xff00ff00,
                ),
              ]),
          insuranceProfileProvider.overrideWith((ref) => Stream.value(null)),
          medicalBillsProvider.overrideWith((ref) => Stream.value([])),
          rateRegistryProvider.overrideWithValue(RateTableRegistry()),
          mainCurrencyProvider.overrideWithValue(CurrencyCode.huf),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    return router;
  }

  Future<void> openSummary(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('keptHero')));
    await tester.pumpAndSettle();
    expect(find.byType(MonthSummaryDetailScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  }

  testWidgets(
      'owner switch goes home and cached Expenses cannot restore old owner filters',
      (tester) async {
    final router = await pumpApp(tester);
    router.go('/expenses', extra: {'categoryId': 'food'});
    await tester.pumpAndSettle();
    final container =
        ProviderScope.containerOf(tester.element(find.byType(ExpensesScreen)));
    expect(container.read(expenseSearchStateProvider).filters.category, 'food');
    await tester.tap(find.byKey(const Key('spacesNavigationMenu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spaces').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('contextChoice_7')));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/dashboard');
    expect(router.canPop(), isFalse);
    expect(container.read(budgetContextProvider).yearMonth, '2026-01');
    await tester.tap(find.descendant(
        of: find.byType(NavigationBar), matching: find.text('Expenses')));
    await tester.pumpAndSettle();
    expect(container.read(expenseSearchStateProvider).filters.category, isNull);
    expect(tester.takeException(), isNull);
  });

  MonthSummary detailedSummary(
          {double carryOver = 100, double? opening = 1000}) =>
      MonthSummary(
        yearMonth: '2026-01',
        income: 4000,
        usesOverriddenIncome: false,
        paymentsMade: 1200,
        moneyReturned: 300,
        insuranceReturned: 100,
        expenseReturned: 200,
        planned: 800,
        cancelled: 0,
        medicalPaid: 200,
        excessReturned: 0,
        openingBalance: opening,
        allocated: 1000,
        setAside: 800,
        carryOver: carryOver,
      );

  void expectRow(WidgetTester tester, String label, String value) {
    final row = find
        .ancestor(
          of: find.text(label),
          matching: find.byType(Row),
        )
        .first;
    expect(
        find.descendant(of: row, matching: find.text(value)), findsOneWidget);
  }

  testWidgets(
      'detail uses display currency and reconciles without subtracting borrowing twice',
      (tester) async {
    await pumpApp(tester,
        summary: detailedSummary(),
        displayCurrency: CurrencyCode.usd,
        borrowed: 1234);
    // These figures are already converted by the summary provider. The detail
    // must retain their magnitude, not convert them a second time or label HUF.
    expect(find.text(r'$ 2,200.00'), findsWidgets);
    await openSummary(tester);
    expect(find.text(r'$ 2,200.00'), findsNWidgets(2));
    expect(find.text(r'$ 4,100.00'), findsOneWidget);
    expectRow(tester, 'Income', r'$ 4,000.00');
    expectRow(tester, 'Paid out', r'- $ 1,200.00');
    expectRow(tester, 'Returned', r'+ $ 300.00');
    expectRow(tester, 'Set aside for budgets', r'- $ 800.00');
    expectRow(tester, 'Borrowed so far', r'$ 12.34');
    expectRow(tester, 'Carry over', r'- $ 100.00');
    expect(
        find.text(
            'Kept = Income − Paid out + Returned − Set aside for budgets − Carry over'),
        findsOneWidget);
    expect(
        find.text(
            'Borrowing is already included in paid out; it is not subtracted again.'),
        findsOneWidget);
  });

  testWidgets(
      'negative carry over is shown as an addition and main currency is the fallback',
      (tester) async {
    await pumpApp(tester, summary: detailedSummary(carryOver: -50));
    await openSummary(tester);
    expectRow(tester, 'Carry over', '+ Ft 50');
    expect(find.text('Ft 2,350'), findsNWidgets(2));
  });

  testWidgets(
      'unconfirmed opening balance shows the prompt instead of a bank amount',
      (tester) async {
    await pumpApp(tester, summary: detailedSummary(opening: null));
    await openSummary(tester);
    expect(
        find.text(
            'Opening balance not confirmed yet. Confirm it in this month to see money in bank.'),
        findsOneWidget);
    expect(find.text('Ft 4,100'), findsNothing);
  });

  testWidgets(
      'info button opens only its dialog, card body opens detail, and Back returns',
      (tester) async {
    final router = await pumpApp(tester);
    final card = find.byKey(const Key('monthSummaryCard'));
    await tester.tap(find.descendant(
      of: card,
      matching: find.byIcon(Icons.info_outline),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(MonthSummaryDetailScreen), findsNothing);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(router.canPop(), isFalse);

    // The supporting line is part of the whole card, outside its hero amount.
    await tester.tap(find.descendant(of: card, matching: find.text('Income')));
    await tester.pumpAndSettle();
    expect(find.byType(MonthSummaryDetailScreen), findsOneWidget);
    expect(router.canPop(), isTrue);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(MonthSummaryDetailScreen), findsNothing);
    expect(find.byKey(const Key('keptHero')), findsOneWidget);
    expect(router.canPop(), isFalse);
    expect(tester.takeException(), isNull);
  });

  for (final entry in {
    'Income': '/income_sources',
    'Set aside for budgets': '/allocations',
    'Borrowed so far': '/allocations',
    'Allocated total': '/allocations',
    '  Insurance return': '/medical',
    'Medical': '/medical',
  }.entries) {
    testWidgets('detail ${entry.key.trim()} opens ${entry.value}',
        (tester) async {
      final router =
          await pumpApp(tester, summary: detailedSummary(), borrowed: 1234);
      await openSummary(tester);
      final link = find.text(entry.key);
      await tester.ensureVisible(link);
      await tester.tap(link);
      await tester.pumpAndSettle();
      expect(router.state.uri.path, entry.value);
      expect(tester.takeException(), isNull);
      if (entry.value == '/medical') {
        expect(find.text('Health & Insurance'), findsOneWidget);
        expect(find.byType(MonthSummaryDetailScreen), findsNothing);
      } else {
        expect(
            find.text(entry.value == '/allocations'
                ? 'Allocations'
                : 'Income Sources'),
            findsOneWidget);
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(find.byType(MonthSummaryDetailScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  }

  Future<void> expectExpenses(WidgetTester tester, GoRouter router,
      {ExpenseStatus? status, String? categoryId}) async {
    expect(tester.takeException(), isNull);
    expect(find.byType(ExpensesScreen), findsOneWidget);
    expect(find.byType(AppShell, skipOffstage: false), findsOneWidget);
    expect(find.byType(MonthSummaryDetailScreen), findsNothing);
    expect(router.canPop(), isFalse);
    expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        1);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ExpensesScreen)),
    );
    expect(container.read(expenseSearchStateProvider).filters.status, status);
    expect(container.read(expenseSearchStateProvider).filters.category,
        categoryId);

    final dashboardTab = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Dashboard'),
    );
    await tester.tap(dashboardTab);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('keptHero')), findsOneWidget);
    final expensesTab = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Expenses'),
    );
    await tester.tap(expensesTab);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(ExpensesScreen), findsOneWidget);
    expect(find.byType(AppShell, skipOffstage: false), findsOneWidget);
  }

  for (final entry in <String, ExpenseStatus?>{
    'Paid out': null,
    '  Expense returns': ExpenseStatus.reimbursed,
    'Planned': ExpenseStatus.planned,
  }.entries) {
    testWidgets(
        'summary ${entry.key.trim()} opens Expenses without duplicate shell',
        (tester) async {
      final router = await pumpApp(tester);
      await tester.tap(find.byKey(const Key('keptHero')));
      await tester.pumpAndSettle();
      expect(find.byType(MonthSummaryDetailScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      final link = find.text(entry.key);
      await tester.ensureVisible(link);
      await tester.tap(link);
      await tester.pumpAndSettle();
      await expectExpenses(tester, router, status: entry.value);
    });
  }

  for (final expanded in [false, true]) {
    testWidgets(
        'dashboard expense returns (expanded: $expanded) keeps status filter',
        (tester) async {
      final router = await pumpApp(tester);
      if (expanded) {
        final details = find.byKey(const Key('summaryDetails'));
        await tester.ensureVisible(details);
        await tester.tap(details);
        await tester.pumpAndSettle();
      }
      final link = find.descendant(
        of: expanded
            ? find.byKey(const Key('summaryDetails'))
            : find.byKey(const Key('monthSummaryCard')),
        matching: find.byKey(const Key('expenseReturnsLine')),
      );
      await tester.ensureVisible(link);
      await tester.tap(link);
      await tester.pumpAndSettle();
      await expectExpenses(tester, router, status: ExpenseStatus.reimbursed);
    });
  }

  for (final byCategory in [true, false]) {
    testWidgets(
        'analytics drill-down keeps ${byCategory ? 'category' : 'status'} filter',
        (tester) async {
      final router = await pumpApp(tester);
      await tester.tap(find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Analytics'),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Chart gesture-to-request conversion has its own widget tests. Exercise
      // the real Analytics callback here to test its route and filter payload.
      if (byCategory) {
        tester.widget<CategoryChart>(find.byType(CategoryChart)).onDrillDown!(
          const ChartDrillDownCategory(categoryId: 'food'),
        );
      } else {
        tester
            .widget<PlannedPaidChart>(find.byType(PlannedPaidChart))
            .onDrillDown!(
          const ChartDrillDownStatus(status: ExpenseStatus.paid),
        );
      }
      await tester.pumpAndSettle();
      await expectExpenses(tester, router,
          categoryId: byCategory ? 'food' : null,
          status: byCategory ? null : ExpenseStatus.paid);
    });
  }
}
