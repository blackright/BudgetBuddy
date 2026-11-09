import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/dashboard/presentation/widgets/budgets_ledger.dart';
import 'package:budget_buddy/features/dashboard/providers/dashboard_providers.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  Expense expense({int id = 1, String title = 'Groceries'}) {
    return Expense(
      profileId: 1,
      sharedSpaceId: null,
      type: ExpenseType.standard,
      yearMonth: '2026-01',
      budgetId: 1,
      title: title,
      amount: 15000,
      currency: 'huf',
      categoryId: Expense.defaultCategoryId,
      date: DateTime(2026, 1, 15),
      status: ExpenseStatus.paid,
    )..id = id;
  }

  DashboardProfileState profile({
    required int id,
    required String name,
    bool isDirect = false,
    int allocation = 1000,
    int spent = 500,
    int reserve = 1000,
    int expenseCount = 0,
    List<Expense> recentExpenses = const [],
  }) {
    return DashboardProfileState(
      id: id,
      name: name,
      isDirect: isDirect,
      allocation: allocation,
      spent: spent,
      expenseCount: expenseCount,
      availableReserve: reserve,
      recentExpenses: recentExpenses,
    );
  }

  List<DashboardProfileState> sixProfiles() => [
        profile(
          id: 1,
          name: 'Food',
          spent: 1200,
          reserve: 100,
          expenseCount: 1,
          recentExpenses: [expense()],
        ),
        profile(id: 2, name: 'Rent', spent: 1000),
        profile(id: 3, name: 'Transport', spent: 850),
        profile(id: 4, name: 'Fun', spent: 500),
        profile(
            id: 5, name: 'Medical', isDirect: true, allocation: 0, spent: 300),
        profile(
            id: 6, name: 'Travel', isDirect: true, allocation: 0, spent: 200),
      ];

  Widget wrap({
    required List<DashboardProfileState> profiles,
    bool canEdit = true,
    Size size = const Size(1000, 2400),
    double textScale = 1,
  }) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: BudgetsLedger(),
            ),
          ),
        ),
        GoRoute(
          path: '/profiles',
          builder: (context, state) => const Scaffold(
            body: Text('Profiles destination'),
          ),
        ),
        GoRoute(
          path: '/allocations',
          builder: (context, state) => const Scaffold(
            body: Text('Allocations destination'),
          ),
        ),
        GoRoute(
          path: '/profile_expenses/:id',
          builder: (context, state) => const Scaffold(
            body: Text('Profile expenses destination'),
          ),
        ),
        GoRoute(
          path: '/add_expense',
          builder: (context, state) => const Scaffold(
            body: Text('Add expense destination'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    return ProviderScope(
      overrides: [
        dashboardProfilesProvider.overrideWithValue(profiles),
        dashboardCurrencyProvider.overrideWithValue(CurrencyCode.huf),
        selectedYearMonthProvider.overrideWith((ref) => '2026-01'),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        activeContextCanEditProvider.overrideWithValue(canEdit),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Future<void> pumpLedger(
    WidgetTester tester, {
    required List<DashboardProfileState> profiles,
    bool canEdit = true,
    Size size = const Size(1000, 2400),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      wrap(
        profiles: profiles,
        canEdit: canEdit,
        size: size,
        textScale: textScale,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the header and See all', (tester) async {
    await pumpLedger(tester, profiles: sixProfiles());

    expect(find.byKey(const Key('budgetsSection')), findsOneWidget);
    expect(find.byKey(const Key('budgetsHeader')), findsOneWidget);
    expect(find.byKey(const Key('budgetsSeeAll')), findsOneWidget);

    await tester.tap(find.byKey(const Key('budgetsSeeAll')));
    await tester.pumpAndSettle();
    expect(find.text('Profiles destination'), findsOneWidget);
  });

  testWidgets('caps the ledger at four rows worst-first', (tester) async {
    await pumpLedger(tester, profiles: sixProfiles());

    expect(find.byKey(const Key('budgetRow-budget:1')), findsOneWidget);
    expect(find.byKey(const Key('budgetRow-budget:2')), findsOneWidget);
    expect(find.byKey(const Key('budgetRow-budget:3')), findsOneWidget);
    expect(find.byKey(const Key('budgetRow-budget:4')), findsOneWidget);
    expect(find.byKey(const Key('budgetRow-direct:5')), findsNothing);
    expect(find.byKey(const Key('budgetRow-direct:6')), findsNothing);

    expect(
      tester.getTopLeft(find.byKey(const Key('budgetRow-budget:1'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('budgetRow-budget:2'))).dy,
      ),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('budgetRow-budget:2'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('budgetRow-budget:3'))).dy,
      ),
    );
  });

  testWidgets('shows budget status, progress and left amount', (tester) async {
    await pumpLedger(tester,
        profiles: [profile(id: 1, name: 'Food', spent: 500)]);

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('On track'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('budgetRow-budget:1')),
        matching: find.text('Ft 500'),
      ),
      findsOneWidget,
    );
    expect(find.text('left'), findsOneWidget);
  });

  testWidgets('shows total budget and net left across all profiles',
      (tester) async {
    await pumpLedger(tester, profiles: sixProfiles());

    expect(find.byKey(const Key('budgetsSummary')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('budgetsTotal')),
        matching: find.text('Ft 4,000'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('budgetsLeft')),
        matching: find.text('Ft 450'),
      ),
      findsOneWidget,
    );
    expect(find.text('Left'), findsOneWidget);
  });

  testWidgets('shows a net overspend in words', (tester) async {
    await pumpLedger(
      tester,
      profiles: [
        profile(id: 1, name: 'Food', spent: 1200, reserve: 100),
        profile(id: 2, name: 'Rent', spent: 1200, reserve: 100),
      ],
    );

    expect(find.text('Over by'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('budgetsLeft')),
        matching: find.text('Ft 400'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('states an over-budget amount in words', (tester) async {
    await pumpLedger(
      tester,
      profiles: [profile(id: 1, name: 'Food', spent: 1200, reserve: 100)],
    );

    expect(find.text('Over by Ft 200'), findsOneWidget);
  });

  testWidgets('shows a direct profile as spent and no budget', (tester) async {
    await pumpLedger(
      tester,
      profiles: [
        profile(
          id: 2,
          name: 'Travel',
          isDirect: true,
          allocation: 0,
          spent: 300,
        ),
      ],
    );

    expect(find.text('Travel'), findsOneWidget);
    expect(find.text('no budget'), findsOneWidget);
    expect(find.text('Ft 300'), findsOneWidget);
    expect(find.text('spent'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('shows the empty state and opens allocations', (tester) async {
    await pumpLedger(tester, profiles: const []);

    expect(find.byKey(const Key('budgetsEmpty')), findsOneWidget);
    expect(find.text('Create your first budget'), findsOneWidget);

    await tester.tap(find.byKey(const Key('budgetsEmpty')));
    await tester.pumpAndSettle();
    expect(find.text('Allocations destination'), findsOneWidget);
  });

  testWidgets('opens the detail sheet with recent expenses and actions',
      (tester) async {
    await pumpLedger(
      tester,
      profiles: [sixProfiles().first],
    );

    await tester.tap(find.byKey(const Key('budgetRow-budget:1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('budgetDetailSheet')), findsOneWidget);
    expect(find.byKey(const Key('appSheetClose')), findsNothing);
    expect(find.text('Food'), findsWidgets);
    expect(find.textContaining('Over by'), findsWidgets);
    expect(find.text('Budget profile · Over by Ft 200'), findsOneWidget);
    expect(find.byKey(const Key('budgetDetailSummary')), findsOneWidget);
    final summaryAmount = tester.widget<Text>(
      find.byKey(const Key('budgetDetailSummaryAmount')),
    );
    expect(summaryAmount.data, 'Ft 200');
    expect(summaryAmount.textAlign, TextAlign.center);
    expect(find.text('Recent'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('15 Jan 2026'), findsOneWidget);
    expect(find.byKey(const Key('budgetDetailExpense-1')), findsOneWidget);
    expect(find.byKey(const Key('budgetDetailSeeAll')), findsOneWidget);
    expect(find.byKey(const Key('budgetDetailAddExpense')), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Add expense'), findsOneWidget);
  });

  testWidgets('omits Add expense in a read-only context', (tester) async {
    await pumpLedger(
      tester,
      profiles: [sixProfiles().first],
      canEdit: false,
    );

    await tester.tap(find.byKey(const Key('budgetRow-budget:1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('budgetDetailSheet')), findsOneWidget);
    expect(find.byKey(const Key('budgetDetailAddExpense')), findsNothing);
    expect(find.byKey(const Key('budgetDetailSeeAll')), findsOneWidget);
  });

  testWidgets('reveals the original amount on long-press', (tester) async {
    await pumpLedger(
      tester,
      profiles: [sixProfiles().first],
    );

    await tester.tap(find.byKey(const Key('budgetRow-budget:1')));
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Ft 15,000'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Original:'), findsOneWidget);
  });

  testWidgets('stays usable at 320 dp and 200% text', (tester) async {
    await pumpLedger(
      tester,
      profiles: sixProfiles(),
      size: const Size(320, 1600),
      textScale: 2,
    );

    expect(find.byKey(const Key('budgetsHeader')), findsOneWidget);
    expect(find.byKey(const Key('budgetRow-budget:1')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('detail sheet stays usable at 320 dp and 200% text',
      (tester) async {
    await pumpLedger(
      tester,
      profiles: [sixProfiles().first],
      size: const Size(320, 1600),
      textScale: 2,
    );

    await tester.tap(find.byKey(const Key('budgetRow-budget:1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('budgetDetailSheet')), findsOneWidget);
    expect(find.byKey(const Key('budgetDetailSummaryAmount')), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Add expense'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
