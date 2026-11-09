import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:budget_buddy/features/dashboard/presentation/month_navigator.dart';
import 'package:budget_buddy/features/dashboard/providers/dashboard_providers.dart';
import 'package:budget_buddy/features/engine/month_summary.dart';
import 'package:budget_buddy/features/engine/providers/month_summary_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/dashboard/presentation/widgets/onboarding_guidance_card.dart';
import 'package:budget_buddy/features/spaces/presentation/move_month_sheet.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:budget_buddy/features/vault/providers/vault_providers.dart';
import 'package:budget_buddy/features/finance/providers/finance_providers.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  const month = '2026-01';

  MonthlyBudget budget() {
    return MonthlyBudget()
      ..id = 1
      ..yearMonth = month
      ..baseAvailableAmount = 1000
      ..openingBalanceConfirmed = true
      ..currency = 'usd'
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
  }

  MonthSummary summary() {
    return const MonthSummary(
      yearMonth: month,
      income: 4000,
      usesOverriddenIncome: false,
      paymentsMade: 1200,
      moneyReturned: 300,
      planned: 800,
      cancelled: 150,
      medicalPaid: 200,
      excessReturned: 0,
      insuranceReturned: 0,
      expenseReturned: 0,
      openingBalance: 1000,
    );
  }

  Widget wrap({
    bool canEdit = true,
    bool hasBudget = true,
    String selectedMonth = month,
  }) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        for (final path in [
          '/audit_history',
          '/month_summary_detail',
          '/add_expense',
          '/vault',
          '/analytics',
          '/profiles',
          '/allocations',
        ])
          GoRoute(
            path: path,
            builder: (context, state) => Scaffold(
              body: Text('$path destination'),
            ),
          ),
      ],
    );
    addTearDown(router.dispose);

    return ProviderScope(
      overrides: [
        dashboardMonthVerdictProvider.overrideWithValue(
          AsyncData(summary()),
        ),
        dashboardCurrencyProvider.overrideWithValue(CurrencyCode.usd),
        dashboardProfilesProvider.overrideWithValue(const []),
        activeProfileProvider.overrideWith((ref) => Stream.value(null)),
        activeSpaceIdProvider.overrideWith((ref) => null),
        budgetContextProvider.overrideWithValue(
          ContextRef.personal(profileId: 1, yearMonth: selectedMonth),
        ),
        activeBudgetProvider.overrideWith(
          (ref) => Stream.value(hasBudget ? budget() : null),
        ),
        activeContextCanEditProvider.overrideWithValue(canEdit),
        selectedYearMonthProvider.overrideWith((ref) => selectedMonth),
        monthSummaryProvider.overrideWithValue(summary()),
        monthFinanceProvider.overrideWith((ref) => Stream.value(budget())),
        mainCurrencyProvider.overrideWithValue(CurrencyCode.huf),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        vaultProvider.overrideWith((ref) => Stream.value(null)),
        vaultReviewMessageProvider.overrideWithValue(null),
        onboardingGuidanceProvider.overrideWithValue(
          const AsyncData(<SetupSuggestion>[]),
        ),
        profilesProvider.overrideWith((ref) => Stream.value([])),
        mySpacesProvider.overrideWith((ref) => Stream.value([])),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Future<void> pumpDashboard(
    WidgetTester tester, {
    bool canEdit = true,
    bool hasBudget = true,
    String selectedMonth = month,
  }) async {
    await tester.pumpWidget(
      wrap(
        canEdit: canEdit,
        hasBudget: hasBudget,
        selectedMonth: selectedMonth,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows one overflow and no old app-bar controls', (tester) async {
    await pumpDashboard(tester);

    expect(find.byKey(const Key('dashboardOverflow')), findsOneWidget);
    expect(find.byKey(const Key('monthConvertToMenu')), findsNothing);
    expect(find.byKey(const Key('moveMonthButton')), findsNothing);
  });

  testWidgets('shows Convert, Move and History when editable with a budget',
      (tester) async {
    await pumpDashboard(tester);

    await tester.tap(find.byKey(const Key('dashboardOverflow')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('menuConvertMonth')), findsOneWidget);
    expect(find.byKey(const Key('menuMoveMonth')), findsOneWidget);
    expect(find.byKey(const Key('menuHistory')), findsOneWidget);
  });

  testWidgets('shows only History without editing permission', (tester) async {
    await pumpDashboard(tester, canEdit: false);

    await tester.tap(find.byKey(const Key('dashboardOverflow')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('menuConvertMonth')), findsNothing);
    expect(find.byKey(const Key('menuMoveMonth')), findsNothing);
    expect(find.byKey(const Key('menuHistory')), findsOneWidget);
  });

  testWidgets('shows only History without a budget', (tester) async {
    await pumpDashboard(tester, hasBudget: false);

    await tester.tap(find.byKey(const Key('dashboardOverflow')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('menuConvertMonth')), findsNothing);
    expect(find.byKey(const Key('menuMoveMonth')), findsNothing);
    expect(find.byKey(const Key('menuHistory')), findsOneWidget);
  });

  testWidgets('opens the convert-month sheet', (tester) async {
    await pumpDashboard(tester);

    await tester.tap(find.byKey(const Key('dashboardOverflow')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('menuConvertMonth')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('monthToolsSheet')), findsOneWidget);
    expect(find.text('Convert month'), findsOneWidget);
    expect(find.byKey(const Key('convertToDefault')), findsOneWidget);
    expect(find.byKey(const Key('convertTo-eur')), findsOneWidget);
  });

  testWidgets('opens the move-month sheet', (tester) async {
    await pumpDashboard(tester);

    await tester.tap(find.byKey(const Key('dashboardOverflow')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('menuMoveMonth')));
    await tester.pumpAndSettle();

    expect(find.byType(MoveMonthSheet), findsOneWidget);
    expect(find.byKey(const Key('moveMonthSheet')), findsOneWidget);
    expect(find.byKey(const Key('appSheetClose')), findsOneWidget);
    expect(find.text('No active profile.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('appSheetClose')));
    await tester.pumpAndSettle();
    expect(find.byType(MoveMonthSheet), findsNothing);
  });

  testWidgets('opens History from the overflow', (tester) async {
    await pumpDashboard(tester);

    await tester.tap(find.byKey(const Key('dashboardOverflow')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('menuHistory')));
    await tester.pumpAndSettle();

    expect(find.text('/audit_history destination'), findsOneWidget);
  });

  testWidgets('Today returns to the current month', (tester) async {
    await pumpDashboard(tester, selectedMonth: previousMonth());

    expect(find.byKey(const Key('todayButton')), findsOneWidget);
    await tester.tap(find.byKey(const Key('todayButton')));
    await tester.pumpAndSettle();

    expect(find.byType(MonthNavigator), findsOneWidget);
    final label = tester.widget<Text>(find.byKey(const Key('monthLabel')));
    expect(label.data, monthLabel(currentYearMonth()));
  });

  testWidgets('resets scroll to the top after a month change', (tester) async {
    await pumpDashboard(tester);

    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -300));
    await tester.pumpAndSettle();
    final position = tester.state<ScrollableState>(scrollable).position;
    expect(position.pixels, greaterThan(0));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MonthNavigator)),
    );
    container.read(selectedYearMonthProvider.notifier).state = previousMonth();
    await tester.pumpAndSettle();

    expect(position.pixels, 0);
  });

  testWidgets('horizontal swipe changes the month', (tester) async {
    await pumpDashboard(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MonthNavigator)),
    );

    await tester.fling(
      find.byType(ListView),
      const Offset(-400, 0),
      1000,
    );
    await tester.pumpAndSettle();

    expect(
      container.read(selectedYearMonthProvider),
      nextMonth(month),
    );
  });

  testWidgets('pull-to-refresh does not change the selected month',
      (tester) async {
    await pumpDashboard(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MonthNavigator)),
    );
    final before = container.read(selectedYearMonthProvider);

    await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
    await tester.pumpAndSettle();

    expect(container.read(selectedYearMonthProvider), before);
  });
}
