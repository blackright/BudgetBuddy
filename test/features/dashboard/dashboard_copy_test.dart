import 'dart:io';

import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/dashboard/presentation/dashboard_copy.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  const month = '2026-01';

  const banned = [
    'free to spend',
    'allocation',
    'allocated',
    'envelope',
    'carry',
    'carried',
    'sweep',
    'remittance',
    'audit trail',
    'confirmed income',
    'excess returned',
    'insurance return',
    'expense returns',
    'borrowed so far',
    'set aside for budgets',
  ];

  const filler = [
    'Jump straight to what you need',
    'Record new spending',
    'Claims, bills and refunds',
    'Your saved money and history',
    'Your audit trail',
  ];

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

  Widget wrap() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
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
        dashboardProfilesProvider.overrideWithValue(const []),
        activeProfileProvider.overrideWith((ref) => Stream.value(null)),
        activeSpaceIdProvider.overrideWith((ref) => null),
        budgetContextProvider.overrideWithValue(
          ContextRef.personal(profileId: 1, yearMonth: month),
        ),
        activeBudgetProvider.overrideWith((ref) => Stream.value(budget())),
        activeContextCanEditProvider.overrideWithValue(true),
        selectedYearMonthProvider.overrideWith(
          (ref) => currentYearMonth(),
        ),
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

  testWidgets('default view uses the approved vocabulary', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    final rendered = <String>{};
    void collect() {
      for (final text in tester.widgetList<Text>(find.byType(Text))) {
        final value = text.data;
        if (value != null) rendered.add(value);
      }
    }

    expect(find.text(DashboardCopy.kept), findsWidgets);
    expect(find.text(DashboardCopy.monthBreakdown), findsOneWidget);
    expect(find.text(DashboardCopy.budgets), findsOneWidget);

    collect();
    final scrollable = find.byType(Scrollable).first;
    for (var i = 0; i < 6; i++) {
      await tester.drag(scrollable, const Offset(0, -350));
      await tester.pumpAndSettle();
      collect();
    }

    expect(find.text(DashboardCopy.savings), findsOneWidget);
    expect(find.text(DashboardCopy.analytics), findsOneWidget);

    final allText = rendered.join('\n').toLowerCase();
    for (final term in banned) {
      expect(allText, isNot(contains(term)), reason: 'banned term: $term');
    }
    for (final term in filler) {
      expect(rendered, isNot(contains(term)), reason: 'filler: $term');
    }
    expect(
      RegExp(r'[ÃÂâ€™œ�]').hasMatch(rendered.join('\n')),
      isFalse,
      reason: 'encoding defect',
    );

    expect(DashboardCopy.nextStep, 'Next step');
    expect(DashboardCopy.addExpense, 'Add expense');
    expect(DashboardCopy.addMedicalBill, 'Add medical bill');
    expect(DashboardCopy.today, 'Today');
    expect(DashboardCopy.convertMonth, 'Convert month');
    expect(DashboardCopy.moveMonth, 'Move month');
    expect(DashboardCopy.history, 'History');
  });

  test('dashboard_copy source has no banned copy or encoding defects', () {
    final source = File(
      'lib/features/dashboard/presentation/dashboard_copy.dart',
    ).readAsStringSync();
    final withoutComments = source
        .split('\n')
        .where((line) => !line.trimLeft().startsWith('//'))
        .join('\n')
        .toLowerCase();

    for (final term in banned) {
      expect(withoutComments, isNot(contains(term)), reason: term);
    }
    expect(
      RegExp(r'[ÃÂâ€™œ�]').hasMatch(withoutComments),
      isFalse,
      reason: 'encoding defect',
    );
  });
}
