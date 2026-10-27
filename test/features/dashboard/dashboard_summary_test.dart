import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:budget_buddy/features/dashboard/presentation/widgets/month_summary_card.dart';
import 'package:budget_buddy/features/dashboard/presentation/widgets/month_summary_details.dart';
import 'package:budget_buddy/features/engine/month_summary.dart';
import 'package:budget_buddy/features/dashboard/providers/dashboard_providers.dart';
import 'package:budget_buddy/features/engine/providers/month_summary_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/medical/presentation/medical_theme.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:budget_buddy/shared/presentation/widgets/month_incomplete_banner.dart';
import 'package:budget_buddy/features/engine/providers/true_available_provider.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:budget_buddy/features/expenses/providers/category_provider.dart';
import 'package:budget_buddy/features/finance/providers/finance_providers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Oracle for FR-018 to FR-023 and SC-001 / SC-002.
///
/// The providers the dashboard reads are overridden, so these tests need no
/// Isar instance and stay fast.
void main() {
  /// Builds a summary with specific figures.
  ///
  /// Uses the public constructor directly: the arithmetic that derives these
  /// numbers from expenses is already covered by `month_summary_test.dart`, so
  /// these widget tests only need known field values.
  MonthSummary makeSummary({
    double income = 4000,
    double paymentsMade = 1200,
    double moneyReturned = 300,
    double planned = 800,
    double cancelled = 150,
    double medicalPaid = 200,
    double excessReturned = 0,
    double insuranceReturned = 0,
    double expenseReturned = 0,
    double? openingBalance = 1000,
    bool usesOverriddenIncome = false,
  }) {
    return MonthSummary(
      yearMonth: '2026-01',
      income: income,
      usesOverriddenIncome: usesOverriddenIncome,
      paymentsMade: paymentsMade,
      moneyReturned: moneyReturned,
      planned: planned,
      cancelled: cancelled,
      medicalPaid: medicalPaid,
      excessReturned: excessReturned,
      insuranceReturned: insuranceReturned,
      expenseReturned: expenseReturned,
      openingBalance: openingBalance,
    );
  }

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

  Widget wrap(Widget child, {MonthSummary? value}) {
    return ProviderScope(
      overrides: [
        dashboardBorrowingTotalsProvider
            .overrideWithValue((borrowed: 0, deficit: 0)),
        dashboardProfilesProvider.overrideWithValue([]),
        activeProfileProvider.overrideWith((ref) => Stream.value(null)),
        budgetContextProvider.overrideWithValue(
          ContextRef.personal(profileId: 1, yearMonth: '2026-01'),
        ),
        activeBudgetProvider.overrideWith((ref) => Stream.value(budget())),
        monthSummaryProvider.overrideWithValue(value ?? makeSummary()),
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
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  Future<void> pumpCard(WidgetTester tester, {MonthSummary? value}) async {
    await tester.pumpWidget(
      wrap(
        const MonthSummaryCard(currency: CurrencyCode.usd),
        value: value,
      ),
    );
    await tester.pumpAndSettle();
  }

  group('hero hierarchy (SC-001, SC-002)', () {
    testWidgets('the kept figure is visible without any interaction',
        (tester) async {
      await pumpCard(tester);

      expect(find.byKey(const Key('monthSummaryCard')), findsOneWidget);
      expect(find.byKey(const Key('keptHero')), findsOneWidget);
      expect(find.text('Kept this month'), findsOneWidget);
    });

    testWidgets('SC-002: the hero is the largest text in the card',
        (tester) async {
      await pumpCard(tester);

      final hero = tester.widget<Text>(find.descendant(
        of: find.byKey(const Key('keptHero')),
        matching: find.byType(Text),
      ));
      final heroSize = hero.style?.fontSize ?? 0;
      expect(heroSize, greaterThan(0));

      final allSizes = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.style?.fontSize ?? 0)
          .toList();

      expect(allSizes, isNotEmpty);
      for (final size in allSizes) {
        expect(heroSize, greaterThanOrEqualTo(size));
      }
    });

    testWidgets('SC-001: the hero shows income minus payments plus returns',
        (tester) async {
      await pumpCard(tester, value: makeSummary());

      // 4000 - 1200 + 300. Asserted through the shared formatter rather than a
      // hardcoded string, so this stays a test of the arithmetic rather than of
      // MedicalTheme's display policy.
      const kept = 4000.0 - 1200 + 300;
      expect(
          find.textContaining(MedicalTheme.moneyMajor(CurrencyCode.usd, kept)),
          findsWidgets);
    });

    testWidgets('the four supporting lines are labelled', (tester) async {
      await pumpCard(tester);

      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Paid out'), findsOneWidget);
      expect(find.text('Planned'), findsOneWidget);
      expect(find.text('Returned'), findsOneWidget);
    });

    testWidgets('T-R07: a major figure renders its true magnitude',
        (tester) async {
      // The engine converts a stored minor-unit expense (USD 10.00 = 1000
      // minor) into a major double before the card sees it. The card must show
      // `$ 10.00`, not the inflated `$ 1,000.00` that a raw minor int would.
      await pumpCard(tester, value: makeSummary(paymentsMade: 10.0));

      final paid = find.descendant(
        of: find.byKey(const Key('paymentsLine')),
        matching: find.byType(Text),
      );
      final rendered =
          tester.widgetList<Text>(paid).map((t) => t.data ?? '').join(' ');

      expect(rendered, contains(r'$ 10.00'));
      expect(rendered, isNot(contains('1,000.00')));
    });
  });

  group('T-R06 conversion caption (T054)', () {
    testWidgets('the hero card names the rate when display ≠ main',
        (tester) async {
      await pumpCard(tester);

      expect(find.byKey(const Key('conversionFootnote')), findsOneWidget);
      expect(find.textContaining('1 \$ = 345 Ft'), findsOneWidget);
    });

    testWidgets('the hero card stays quiet for a single currency',
        (tester) async {
      await tester.pumpWidget(
        wrap(const MonthSummaryCard(currency: CurrencyCode.huf)),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('conversionFootnote')), findsNothing);
    });
  });

  group('FR-023: prohibited content', () {
    testWidgets('the dashboard default view omits Safe to Spend',
        (tester) async {
      await tester.pumpWidget(wrap(const DashboardScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Safe to Spend'), findsNothing);
    });

    testWidgets('the dashboard default view omits True Available',
        (tester) async {
      await tester.pumpWidget(wrap(const DashboardScreen()));
      await tester.pumpAndSettle();

      expect(find.text('True Available'), findsNothing);
    });
  });

  group('FR-021: collapsed detail group', () {
    testWidgets('the detail group starts collapsed', (tester) async {
      await tester.pumpWidget(
        wrap(const MonthSummaryDetails(currency: CurrencyCode.usd)),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('summaryDetails')), findsOneWidget);
      expect(find.byKey(const Key('bankLine')), findsNothing);
    });

    testWidgets('expanding reveals the bank and medical lines', (tester) async {
      await tester.pumpWidget(
        wrap(const MonthSummaryDetails(currency: CurrencyCode.usd)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('summaryDetails')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('medicalLine')), findsOneWidget);
      expect(find.byKey(const Key('cancelledLine')), findsOneWidget);
    });

    testWidgets('the override marker appears only for an overridden month',
        (tester) async {
      await tester.pumpWidget(
        wrap(const MonthSummaryDetails(currency: CurrencyCode.usd),
            value: makeSummary()),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('summaryDetails')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('overrideMarker')), findsNothing);

      await tester.pumpWidget(
        wrap(
          const MonthSummaryDetails(currency: CurrencyCode.usd),
          value: makeSummary(usesOverriddenIncome: true),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('summaryDetails')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('overrideMarker')), findsOneWidget);
    });

    testWidgets('tapping the medical line reports the tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(
          MonthSummaryDetails(
            currency: CurrencyCode.usd,
            onMedicalTap: () => taps++,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('summaryDetails')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('medicalLine')));
      await tester.pumpAndSettle();

      expect(taps, 1);
    });

    testWidgets('excess returned is surfaced as its own figure',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          const MonthSummaryDetails(currency: CurrencyCode.usd),
          value: makeSummary(excessReturned: 100),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('summaryDetails')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('excessLine')), findsOneWidget);
      expect(find.text('Excess returned'), findsOneWidget);
    });

    testWidgets('the medical figure matches the summary', (tester) async {
      await tester.pumpWidget(
        wrap(
          const MonthSummaryDetails(currency: CurrencyCode.usd),
          value: makeSummary(medicalPaid: 450),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('summaryDetails')));
      await tester.pumpAndSettle();

      final medicalLine = find.byKey(const Key('medicalLine'));
      expect(medicalLine, findsOneWidget);
      expect(
        find.descendant(
          of: medicalLine,
          matching: find
              .textContaining(MedicalTheme.moneyMajor(CurrencyCode.usd, 450)),
        ),
        findsOneWidget,
      );
    });
  });

  group('FR-019: colour roles', () {
    Future<Color?> colorOfKey(WidgetTester tester, Key key) async {
      final text = tester.widget<Text>(find.descendant(
        of: find.byKey(key),
        matching: find.byType(Text),
      ));
      return text.style?.color;
    }

    testWidgets('income reads as money in', (tester) async {
      await pumpCard(tester);

      expect(await colorOfKey(tester, const Key('incomeLine')),
          MedicalTheme.moneyIn);
    });

    testWidgets('money out reads as money out', (tester) async {
      await pumpCard(tester);

      expect(await colorOfKey(tester, const Key('paymentsLine')),
          MedicalTheme.moneyOut);
    });

    testWidgets('planned uses the planned token', (tester) async {
      await pumpCard(tester);

      expect(await colorOfKey(tester, const Key('plannedLine')),
          MedicalTheme.planned);
    });

    testWidgets('returned money reads as money in', (tester) async {
      await pumpCard(tester);

      expect(await colorOfKey(tester, const Key('returnedLine')),
          MedicalTheme.moneyIn);
    });
  });

  group('FR-025: incomplete month', () {
    testWidgets('the banner shows when the month is incomplete',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          const MonthIncompleteBanner(currencySymbol: r'$'),
          value: makeSummary(income: 0, openingBalance: null),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('monthIncompleteBanner')), findsOneWidget);
      expect(find.textContaining('Income Sources'), findsOneWidget);
    });

    testWidgets('the banner is absent for a complete month', (tester) async {
      await tester.pumpWidget(
        wrap(const MonthIncompleteBanner(currencySymbol: r'$')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('monthIncompleteBanner')), findsNothing);
    });
  });

  group('US8: returned money split into insurance vs expense', () {
    const split = 300.0 + 200.0;

    testWidgets('the card shows both sub-lines under Returned', (tester) async {
      await tester.pumpWidget(
        wrap(
          const MonthSummaryCard(currency: CurrencyCode.usd),
          value: makeSummary(
            moneyReturned: split,
            insuranceReturned: 300,
            expenseReturned: 200,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('returnedLine')), findsOneWidget);
      expect(find.byKey(const Key('insuranceReturnedLine')), findsOneWidget);
      expect(find.byKey(const Key('expenseReturnsLine')), findsOneWidget);
      expect(find.text('Insurance return'), findsOneWidget);
      expect(find.text('Expense returns'), findsOneWidget);
    });

    testWidgets('a zero half is not rendered', (tester) async {
      await tester.pumpWidget(
        wrap(
          const MonthSummaryCard(currency: CurrencyCode.usd),
          value: makeSummary(moneyReturned: 300, insuranceReturned: 300),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('insuranceReturnedLine')), findsOneWidget);
      expect(find.byKey(const Key('expenseReturnsLine')), findsNothing);
    });

    testWidgets('both lines are hidden when nothing was returned',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          const MonthSummaryCard(currency: CurrencyCode.usd),
          value: makeSummary(moneyReturned: 0),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('insuranceReturnedLine')), findsNothing);
      expect(find.byKey(const Key('expenseReturnsLine')), findsNothing);
    });

    testWidgets('tapping the card sub-lines fires their callbacks',
        (tester) async {
      var insuranceTaps = 0;
      var expenseTaps = 0;
      await tester.pumpWidget(
        wrap(
          MonthSummaryCard(
            currency: CurrencyCode.usd,
            onInsuranceReturnTap: () => insuranceTaps++,
            onExpenseReturnTap: () => expenseTaps++,
          ),
          value: makeSummary(
            moneyReturned: split,
            insuranceReturned: 300,
            expenseReturned: 200,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('insuranceReturnedLine')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('expenseReturnsLine')));
      await tester.pumpAndSettle();

      expect(insuranceTaps, 1);
      expect(expenseTaps, 1);
    });

    testWidgets('the details group mirrors both figures and is tappable',
        (tester) async {
      var insuranceTaps = 0;
      var expenseTaps = 0;
      await tester.pumpWidget(
        wrap(
          MonthSummaryDetails(
            currency: CurrencyCode.usd,
            onInsuranceReturnTap: () => insuranceTaps++,
            onExpenseReturnTap: () => expenseTaps++,
          ),
          value: makeSummary(
            moneyReturned: split,
            insuranceReturned: 300,
            expenseReturned: 200,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('summaryDetails')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('insuranceReturnedLine')), findsOneWidget);
      expect(find.byKey(const Key('expenseReturnsLine')), findsOneWidget);

      await tester.tap(find.byKey(const Key('insuranceReturnedLine')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('expenseReturnsLine')));
      await tester.pumpAndSettle();

      expect(insuranceTaps, 1);
      expect(expenseTaps, 1);
    });
  });
}
