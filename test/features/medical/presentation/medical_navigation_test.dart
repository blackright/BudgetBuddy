import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/routing/app_router.dart';
import 'package:budget_buddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:budget_buddy/features/engine/month_summary.dart';
import 'package:budget_buddy/features/engine/providers/month_summary_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/engine/providers/true_available_provider.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late final router = createAppRouter(initialLocation: '/dashboard');

  setUp(() {
    router.go('/dashboard');
  });

  tearDownAll(() {
    router.dispose();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    // The month summary makes the dashboard taller than the default 800x600
    // surface, which leaves the quick-action row underneath the bottom nav bar.
    // A taller surface keeps the tap on the widget it names.
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeBudgetProvider.overrideWith((ref) => Stream.value(null)),
          // The dashboard renders the month summary, which otherwise reaches for
          // Isar. This is a routing test, so a fixed summary is enough.
          monthSummaryProvider.overrideWithValue(
            const MonthSummary(
              yearMonth: '2026-01',
              income: 4000,
              usesOverriddenIncome: false,
              paymentsMade: 1200,
              moneyReturned: 0,
              planned: 800,
              cancelled: 0,
              medicalPaid: 200,
              excessReturned: 0,
              openingBalance: 1000,
            ),
          ),
          monthlyExpensesProvider.overrideWith((ref) => Stream.value([])),
          monthlyReimbursementsProvider.overrideWith((ref) => Stream.value([])),
          insuranceProfileProvider.overrideWith((ref) => Stream.value(null)),
          medicalBillsProvider
              .overrideWith((ref) => Stream.value(<MedicalBill>[])),
          rateRegistryProvider.overrideWithValue(RateTableRegistry()),
          // The conversion captions read the profile main currency (T054);
          // HUF pairs with the real user profile semantics.
          mainCurrencyProvider.overrideWithValue(CurrencyCode.huf),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('dashboard Medical quick action opens the Medical dashboard',
      (tester) async {
    await pumpApp(tester);

    // Scoped to the dashboard, not .first/.last: the nav bar also has a Medical
    // tab, and the summary card makes this column taller than the viewport.
    final quickAction = find.descendant(
      of: find.byType(DashboardScreen),
      matching: find.text('Medical'),
    );
    await tester.tap(quickAction);
    await tester.pumpAndSettle();

    expect(find.text('Health & Insurance'), findsOneWidget);
    expect(find.text('Medical Bills Placeholder'), findsNothing);
  });

  testWidgets('Medical navigation tab opens the Medical dashboard',
      (tester) async {
    await pumpApp(tester);

    final navTab = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Medical'),
    );
    await tester.tap(navTab);
    await tester.pumpAndSettle();

    expect(find.text('Health & Insurance'), findsOneWidget);
    expect(find.text('Medical Bills Placeholder'), findsNothing);
  });
}
