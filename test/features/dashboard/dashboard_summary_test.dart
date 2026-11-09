import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:budget_buddy/features/dashboard/providers/dashboard_providers.dart';
import 'package:budget_buddy/features/engine/month_summary.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// The Dashboard default view after the Phase 3 composition rewrite.
void main() {
  const month = '2026-01';

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

  Widget wrap({bool canEdit = false}) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/month_summary_detail',
          builder: (context, state) => const Scaffold(
            body: Text('Statement destination'),
          ),
        ),
        GoRoute(
          path: '/add_expense',
          builder: (context, state) => Scaffold(
            appBar: AppBar(),
            body: const Text('Add expense destination'),
          ),
        ),
        GoRoute(
          path: '/medical_bill_form',
          builder: (context, state) => Scaffold(
            appBar: AppBar(),
            body: const Text('Medical bill destination'),
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
        selectedYearMonthProvider.overrideWith((ref) => month),
        activeProfileProvider.overrideWith((ref) => Stream.value(null)),
        budgetContextProvider.overrideWithValue(
          ContextRef.personal(profileId: 1, yearMonth: month),
        ),
        activeBudgetProvider.overrideWith((ref) => Stream.value(budget())),
        activeSpaceIdProvider.overrideWith((ref) => null),
        activeContextCanEditProvider.overrideWithValue(canEdit),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('shows the hero and the month-statement row', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('keptHero')), findsOneWidget);
    expect(find.byKey(const Key('monthStatementRow')), findsOneWidget);
    expect(find.byKey(const Key('budgetsHeader')), findsOneWidget);
    expect(find.byKey(const Key('budgetsEmpty')), findsOneWidget);
    expect(find.text('Kept'), findsOneWidget);
    expect(find.text(monthLabel(month)), findsWidgets);
    expect(find.byType(Card), findsNothing);
  });

  testWidgets('shows the kept figure exactly once', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('keptHero')), findsOneWidget);
    expect(find.text(r'$ 3,100.00'), findsOneWidget);
  });

  testWidgets('does not render the retired cards, charts or quick actions',
      (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('monthSummaryCard')), findsNothing);
    expect(find.byKey(const Key('summaryDetails')), findsNothing);
    expect(find.byKey(const Key('vaultQuickAction')), findsNothing);
    expect(find.byKey(const Key('monthIncompleteBanner')), findsNothing);
    expect(find.byKey(const Key('onboardingGuidance')), findsNothing);
    expect(find.text('Quick actions'), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('opens the month statement from the row', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('monthStatementRow')));
    await tester.pumpAndSettle();

    expect(find.text('Statement destination'), findsOneWidget);
  });

  testWidgets('shows Add expense when editing is allowed', (tester) async {
    await tester.pumpWidget(wrap(canEdit: true));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('addExpenseAction')), findsOneWidget);
    expect(find.byKey(const Key('addMedicalBillAction')), findsOneWidget);
    expect(find.text('Add expense'), findsOneWidget);
    expect(find.text('Add medical bill'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(
      tester.getTopLeft(find.byKey(const Key('addExpenseAction'))).dy,
      tester.getTopLeft(find.byKey(const Key('addMedicalBillAction'))).dy,
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('addExpenseAction'))).dx,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('addMedicalBillAction'))).dx,
      ),
    );
  });

  testWidgets('hides Add expense in a read-only context', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('addExpenseAction')), findsNothing);
    expect(find.byKey(const Key('addMedicalBillAction')), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('opens Add expense in one tap', (tester) async {
    await tester.pumpWidget(wrap(canEdit: true));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('addExpenseAction')));
    await tester.pumpAndSettle();

    expect(find.text('Add expense destination'), findsOneWidget);
  });

  testWidgets('opens Add medical bill in one tap', (tester) async {
    await tester.pumpWidget(wrap(canEdit: true));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('addMedicalBillAction')));
    await tester.pumpAndSettle();

    expect(find.text('Medical bill destination'), findsOneWidget);
  });

  testWidgets('preserves the selected month and context after returning',
      (tester) async {
    await tester.pumpWidget(wrap(canEdit: true));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byKey(const Key('monthStatementRow'))),
    );
    final monthBefore = container.read(selectedYearMonthProvider);
    final spaceBefore = container.read(activeSpaceIdProvider);

    await tester.tap(find.byKey(const Key('addExpenseAction')));
    await tester.pumpAndSettle();
    expect(find.text('Add expense destination'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(container.read(selectedYearMonthProvider), monthBefore);
    expect(container.read(activeSpaceIdProvider), spaceBefore);
  });

  testWidgets('uses the selected month name in the statement row',
      (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byKey(const Key('monthStatementRow'))),
    );
    container.read(selectedYearMonthProvider.notifier).state = previousMonth();
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('monthStatementRow')),
        matching: find.text('${monthLabel(previousMonth())} breakdown'),
      ),
      findsOneWidget,
    );
  });
}
