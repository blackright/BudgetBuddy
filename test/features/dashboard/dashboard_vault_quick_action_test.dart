import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:budget_buddy/features/dashboard/providers/dashboard_providers.dart';
import 'package:budget_buddy/features/engine/month_summary.dart';
import 'package:budget_buddy/features/engine/providers/month_summary_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/engine/providers/true_available_provider.dart';
import 'package:budget_buddy/features/expenses/providers/category_provider.dart';
import 'package:budget_buddy/features/finance/providers/finance_providers.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:budget_buddy/features/sync/providers/sync_status_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// F1 / T070: the Vault is reachable from the personal dashboard as a quick
/// action, is hidden inside a shared space, and opens the existing `/vault`
/// route. The informational card is not the only entry point any more.
void main() {
  MonthlyBudget budget() {
    return MonthlyBudget()
      ..id = 1
      ..yearMonth = '2026-01'
      ..baseAvailableAmount = 1000
      ..openingBalanceConfirmed = true
      ..currency = 'usd'
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
  }

  MonthSummary summary() {
    return const MonthSummary(
      yearMonth: '2026-01',
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
      expectedIncome: 0,
    );
  }

  Widget app({required bool shared}) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
            path: '/', builder: (context, state) => const DashboardScreen()),
        GoRoute(
            path: '/vault',
            builder: (context, state) =>
                const Scaffold(body: Text('Vault destination'))),
      ],
    );
    addTearDown(router.dispose);
    return ProviderScope(
      overrides: [
        dashboardBorrowingTotalsProvider
            .overrideWithValue((borrowed: 0, deficit: 0)),
        dashboardProfilesProvider.overrideWithValue([]),
        activeProfileProvider.overrideWith((ref) => Stream.value(null)),
        activeSpaceIdProvider.overrideWith((ref) => shared ? 2 : null),
        budgetContextProvider.overrideWithValue(shared
            ? ContextRef.shared(spaceId: 2, yearMonth: '2026-01')
            : ContextRef.personal(profileId: 1, yearMonth: '2026-01')),
        activeBudgetProvider.overrideWith((ref) => Stream.value(budget())),
        monthSummaryProvider.overrideWithValue(summary()),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        mainCurrencyProvider.overrideWithValue(CurrencyCode.huf),
        monthlyExpensesProvider.overrideWith((ref) => Stream.value([])),
        monthlyReimbursementsProvider.overrideWith((ref) => Stream.value([])),
        monthlyOriginReimbursementsProvider
            .overrideWith((ref) => Stream.value([])),
        medicalBillsProvider.overrideWith((ref) => Stream.value([])),
        monthFinanceProvider.overrideWith((ref) => Stream.value(budget())),
        activeSpaceMembersProvider.overrideWith((ref) => Stream.value([])),
        categoriesProvider.overrideWith((ref) async => []),
        syncStatusFactsProvider(2)
            .overrideWith((ref) async => const SyncStatusFacts()),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('a personal dashboard exposes the Vault quick action',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(shared: false));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
        find.byKey(const Key('vaultQuickAction')), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.byKey(const Key('vaultQuickAction')), findsOneWidget);
  });

  testWidgets('the Vault quick action opens the existing vault route',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(shared: false));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
        find.byKey(const Key('vaultQuickAction')), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byKey(const Key('vaultQuickAction')));
    await tester.pumpAndSettle();

    expect(find.text('Vault destination'), findsOneWidget);
  });

  testWidgets('a shared space hides the Vault quick action', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(shared: true));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('vaultQuickAction')), findsNothing);
  });
}
