import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/dashboard/presentation/widgets/onboarding_guidance_card.dart';
import 'package:budget_buddy/features/finance/providers/income_source_providers.dart';
import 'package:budget_buddy/features/finance/providers/profile_providers.dart';
import 'package:budget_buddy/features/engine/providers/true_available_provider.dart';

void main() {
  for (final kind in ['none', 'zero', 'inactive', 'active']) {
    test('actual guidance distinguishes $kind income without changing totals',
        () async {
      final source = IncomeSource()
        ..id = 1
        ..profileId = 1
        ..name = 'Salary'
        ..currency = 'HUF'
        ..amount = kind == 'zero' ? 0 : 500000
        ..startDate = DateTime(kind == 'inactive' ? 2027 : 2026, 1, 1);
      final c = ProviderContainer(overrides: [
        onboardingGuidanceEligibleProvider.overrideWithValue(true),
        activeProfileProvider.overrideWith((ref) => Stream.value(UserProfile()
          ..id = 1
          ..name = 'Jason'
          ..primaryCurrency = PrimaryCurrency.huf)),
        selectedYearMonthProvider.overrideWith((ref) => '2026-10'),
        activeBudgetProvider.overrideWith((ref) =>
            Stream.value(MonthlyBudget()..openingBalanceConfirmed = false)),
        incomeSourcesProvider.overrideWith(
            (ref) => Stream.value(kind == 'none' ? [] : [source])),
        budgetProfilesProvider.overrideWith((ref) => Stream.value([])),
        monthlyExpensesProvider.overrideWith((ref) => Stream.value([]))
      ]);
      addTearDown(c.dispose);
      await c.read(activeProfileProvider.future);
      await c.read(activeBudgetProvider.future);
      await c.read(incomeSourcesProvider.future);
      await c.read(budgetProfilesProvider.future);
      await c.read(monthlyExpensesProvider.future);
      final items = c.read(onboardingGuidanceProvider).requireValue;
      expect(items.first.title, 'Confirm opening balance');
      expect(items.any((s) => s.title == 'Add income when you are ready'),
          kind == 'none');
      expect(items.any((s) => s.title == 'Check this month?s income'),
          kind == 'zero' || kind == 'inactive');
      expect(source.amount, kind == 'zero' ? 0 : 500000);
    });
  }
  test('failed income read is unavailable, never No income yet', () async {
    final c = ProviderContainer(overrides: [
      onboardingGuidanceEligibleProvider.overrideWithValue(true),
      activeProfileProvider.overrideWith((ref) => Stream.value(UserProfile()
        ..id = 1
        ..primaryCurrency = PrimaryCurrency.huf)),
      activeBudgetProvider.overrideWith((ref) => Stream.value(MonthlyBudget())),
      incomeSourcesProvider
          .overrideWith((ref) => Stream.error(StateError('read failure'))),
      budgetProfilesProvider.overrideWith((ref) => Stream.value([])),
      monthlyExpensesProvider.overrideWith((ref) => Stream.value([]))
    ]);
    addTearDown(c.dispose);
    await c.read(activeBudgetProvider.future);
    try {
      await c.read(incomeSourcesProvider.future);
    } catch (_) {}
    expect(c.read(onboardingGuidanceProvider).hasError, isTrue);
  });
  for (final dark in [false, true]) {
    testWidgets(
        'one primary action and expandable suggestions, dark=$dark, 320/200%',
        (tester) async {
      tester.view.physicalSize = const Size(640, 1800);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(ProviderScope(
          overrides: [
            onboardingGuidanceEligibleProvider.overrideWithValue(true),
            onboardingGuidanceProvider.overrideWithValue(const AsyncData([
              SetupSuggestion(
                  'Add income when you are ready',
                  'No income sources are recorded. This is allowed.',
                  '/income_sources',
                  Icons.add_card),
              SetupSuggestion(
                  'Plan your allocations',
                  'Set aside money for your budget.',
                  '/allocations',
                  Icons.pie_chart)
            ]))
          ],
          child: MaterialApp(
              theme: ThemeData(
                  brightness: dark ? Brightness.dark : Brightness.light),
              home: const MediaQuery(
                  data: MediaQueryData(textScaler: TextScaler.linear(2)),
                  child: Scaffold(
                      body: SingleChildScrollView(
                          child: OnboardingGuidanceCard()))))));
      expect(find.text('Plan your allocations'), findsNothing);
      await tester.ensureVisible(find.text('More suggestions'));
      await tester.tap(find.text('More suggestions'));
      await tester.pumpAndSettle();
      expect(find.text('Plan your allocations'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
