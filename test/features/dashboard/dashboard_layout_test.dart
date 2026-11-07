import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/analytics/presentation/widgets/analytics_mini_charts.dart';
import 'package:budget_buddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:budget_buddy/features/dashboard/presentation/widgets/onboarding_guidance_card.dart';
import 'package:budget_buddy/features/dashboard/providers/dashboard_providers.dart';
import 'package:budget_buddy/features/engine/month_summary.dart';
import 'package:budget_buddy/features/engine/providers/month_summary_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/finance/providers/finance_providers.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:budget_buddy/features/vault/providers/vault_providers.dart';
import 'package:budget_buddy/shared/presentation/widgets/month_incomplete_banner.dart';
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
      ..currency = 'huf'
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

  DashboardProfileState profile(int id, String name) {
    return DashboardProfileState(
      id: id,
      name: name,
      isDirect: false,
      allocation: 1000,
      spent: 500,
      expenseCount: 0,
      availableReserve: 1000,
      recentExpenses: const [],
    );
  }

  Widget wrap() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        for (final path in [
          '/month_summary_detail',
          '/add_expense',
          '/medical_bill_form',
          '/vault',
          '/analytics',
          '/audit_history',
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
        dashboardCurrencyProvider.overrideWithValue(CurrencyCode.huf),
        dashboardProfilesProvider.overrideWithValue([
          profile(1, 'Food'),
          profile(2, 'Rent'),
        ]),
        activeProfileProvider.overrideWith((ref) => Stream.value(null)),
        activeSpaceIdProvider.overrideWith((ref) => null),
        budgetContextProvider.overrideWithValue(
          ContextRef.personal(profileId: 1, yearMonth: month),
        ),
        activeBudgetProvider.overrideWith((ref) => Stream.value(budget())),
        activeContextCanEditProvider.overrideWithValue(true),
        selectedYearMonthProvider.overrideWith((ref) => month),
        monthSummaryProvider.overrideWithValue(summary()),
        monthFinanceProvider.overrideWith((ref) => Stream.value(budget())),
        mainCurrencyProvider.overrideWithValue(CurrencyCode.huf),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        vaultProvider.overrideWith((ref) => Stream.value(null)),
        vaultReviewMessageProvider.overrideWithValue(null),
        onboardingGuidanceProvider.overrideWithValue(
          const AsyncData(<SetupSuggestion>[]),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Future<void> pumpDashboard(
    WidgetTester tester, {
    required Size size,
    required double textScale,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();
  }

  for (final width in [320.0, 360.0, 412.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
          'fits at ${width.toInt()} dp and ${(scale * 100).toInt()}% text',
          (tester) async {
        await pumpDashboard(
          tester,
          size: Size(width, scale == 1 ? 640 : 1600),
          textScale: scale,
        );

        expect(tester.takeException(), isNull);
        expect(find.byKey(const Key('monthStatementRow')), findsOneWidget);
        expect(find.byKey(const Key('addExpenseAction')), findsOneWidget);
        expect(find.byKey(const Key('addMedicalBillAction')), findsOneWidget);
        expect(find.byKey(const Key('budgetsHeader')), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsNothing);
      });
    }
  }

  testWidgets('shows Budgets header without scrolling on 360 x 640',
      (tester) async {
    await pumpDashboard(
      tester,
      size: const Size(360, 640),
      textScale: 1,
    );

    final header = find.byKey(const Key('budgetsHeader'));
    expect(header, findsOneWidget);
    expect(tester.getTopLeft(header).dy, lessThan(640));
  });

  testWidgets('meets 48 dp hit targets', (tester) async {
    await pumpDashboard(
      tester,
      size: const Size(360, 640),
      textScale: 1,
    );

    for (final key in const [
      'monthStatementRow',
      'addExpenseAction',
      'addMedicalBillAction',
    ]) {
      final size = tester.getSize(find.byKey(Key(key)));
      expect(size.width, greaterThanOrEqualTo(48), reason: key);
      expect(size.height, greaterThanOrEqualTo(48), reason: key);
    }

    for (final key in const ['savingsCard', 'analyticsCard']) {
      await tester.scrollUntilVisible(
        find.byKey(Key(key)),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      final size = tester.getSize(find.byKey(Key(key)));
      expect(size.width, greaterThanOrEqualTo(48), reason: key);
      expect(size.height, greaterThanOrEqualTo(48), reason: key);
    }
  });

  testWidgets('does not render retired cards, charts or banners',
      (tester) async {
    await pumpDashboard(
      tester,
      size: const Size(360, 640),
      textScale: 1,
    );

    expect(find.byType(AnalyticsMiniCharts), findsNothing);
    expect(find.byType(MonthIncompleteBanner), findsNothing);
    expect(find.byKey(const Key('monthSummaryCard')), findsNothing);
    expect(find.byKey(const Key('summaryDetails')), findsNothing);
    expect(find.byKey(const Key('allocationCard')), findsNothing);
    expect(find.byKey(const Key('vaultQuickAction')), findsNothing);
    expect(find.byKey(const Key('monthIncompleteBanner')), findsNothing);
  });
}
