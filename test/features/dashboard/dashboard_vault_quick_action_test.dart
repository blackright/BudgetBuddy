import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:budget_buddy/features/dashboard/presentation/widgets/onboarding_guidance_card.dart';
import 'package:budget_buddy/features/dashboard/providers/dashboard_providers.dart';
import 'package:budget_buddy/features/vault/providers/vault_providers.dart';
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

/// The personal-only Savings row is the Vault entry point on the Dashboard.
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
      expectedIncome: 0,
    );
  }

  Widget app({required bool shared}) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/vault',
          builder: (context, state) => const Scaffold(
            body: Text('Vault destination'),
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
        activeSpaceIdProvider.overrideWith((ref) => shared ? 2 : null),
        budgetContextProvider.overrideWithValue(shared
            ? ContextRef.shared(spaceId: 2, yearMonth: month)
            : ContextRef.personal(profileId: 1, yearMonth: month)),
        activeBudgetProvider.overrideWith((ref) => Stream.value(budget())),
        activeContextCanEditProvider.overrideWithValue(false),
        monthSummaryProvider.overrideWithValue(summary()),
        vaultProvider.overrideWith((ref) => Stream.value(null)),
        vaultReviewMessageProvider.overrideWithValue(null),
        onboardingGuidanceProvider.overrideWithValue(
          const AsyncData(<SetupSuggestion>[]),
        ),
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

  testWidgets('a personal dashboard exposes the Savings row', (tester) async {
    await tester.pumpWidget(app(shared: false));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('savingsCard')), findsOneWidget);
    expect(find.byKey(const Key('vaultQuickAction')), findsNothing);
    expect(find.byKey(const Key('monthStatementRow')), findsOneWidget);
  });

  testWidgets('the Savings row opens the vault', (tester) async {
    await tester.pumpWidget(app(shared: false));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('savingsCard')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('savingsCard')));
    await tester.pumpAndSettle();
    expect(find.text('Vault destination'), findsOneWidget);
  });

  testWidgets('a shared dashboard hides the Savings row', (tester) async {
    await tester.pumpWidget(app(shared: true));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('savingsCard')), findsNothing);
    expect(find.byKey(const Key('vaultQuickAction')), findsNothing);
    expect(find.byKey(const Key('monthStatementRow')), findsOneWidget);
  });
}
