import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/dashboard/presentation/dashboard_copy.dart';
import 'package:budget_buddy/features/dashboard/presentation/widgets/dashboard_hero.dart';
import 'package:budget_buddy/features/dashboard/providers/dashboard_providers.dart';
import 'package:budget_buddy/features/engine/month_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MonthSummary summary({
    String? yearMonth,
    double income = 4000,
    double paymentsMade = 1200,
    double moneyReturned = 300,
    double? openingBalance = 1000,
    double planned = 0,
    double cancelled = 0,
    double medicalPaid = 0,
    double setAside = 0,
    double carryOver = 0,
    double carriedIn = 0,
    double releasedAtMonthEnd = 0,
    double vaultTransfers = 0,
    double expectedIncome = 0,
  }) {
    return MonthSummary(
      yearMonth: yearMonth ?? currentYearMonth(),
      income: income,
      usesOverriddenIncome: false,
      paymentsMade: paymentsMade,
      moneyReturned: moneyReturned,
      planned: planned,
      cancelled: cancelled,
      medicalPaid: medicalPaid,
      excessReturned: 0,
      openingBalance: openingBalance,
      allocated: 0,
      setAside: setAside,
      carryOver: carryOver,
      carriedIn: carriedIn,
      releasedAtMonthEnd: releasedAtMonthEnd,
      vaultTransfers: vaultTransfers,
      expectedIncome: expectedIncome,
    );
  }

  Widget wrap(
    AsyncValue<MonthSummary> state, {
    String? yearMonth,
    CurrencyCode currency = CurrencyCode.usd,
  }) {
    final month = yearMonth ?? currentYearMonth();
    return ProviderScope(
      overrides: [
        dashboardMonthVerdictProvider.overrideWithValue(state),
        selectedYearMonthProvider.overrideWith((ref) => month),
        dashboardCurrencyProvider.overrideWithValue(currency),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: DashboardHero(),
          ),
        ),
      ),
    );
  }

  Future<void> pumpHero(
    WidgetTester tester, {
    required AsyncValue<MonthSummary> state,
    String? yearMonth,
    CurrencyCode currency = CurrencyCode.usd,
  }) async {
    await tester
        .pumpWidget(wrap(state, yearMonth: yearMonth, currency: currency));
    await tester.pumpAndSettle();
  }

  testWidgets('shows one kept figure with the current-month caption',
      (tester) async {
    final month = currentYearMonth();
    await pumpHero(tester, state: AsyncData(summary(yearMonth: month)));

    expect(find.text(DashboardCopy.kept), findsOneWidget);
    expect(find.text('this month'), findsOneWidget);
    expect(find.byKey(const Key('keptHero')), findsOneWidget);
    expect(find.text(r'$ 3,100.00'), findsOneWidget);
    expect(find.byKey(const Key('heroSupportingLine')), findsOneWidget);
    expect(find.text(r'$ 1,200.00 paid out · $ 300.00 back'), findsOneWidget);
    expect(find.byType(Card), findsNothing);
  });

  testWidgets('names the selected month when it is not the current month',
      (tester) async {
    final month = previousMonth();
    await pumpHero(
      tester,
      state: AsyncData(summary(yearMonth: month)),
      yearMonth: month,
    );

    expect(find.text('in ${monthLabel(month)}'), findsOneWidget);
  });

  testWidgets('shows a neutral loading state with no figure', (tester) async {
    await pumpHero(
      tester,
      state: const AsyncLoading<MonthSummary>(),
    );

    expect(find.byKey(const Key('heroLoading')), findsOneWidget);
    expect(find.byKey(const Key('keptHero')), findsNothing);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('shows an inline failure and a retry action', (tester) async {
    await pumpHero(
      tester,
      state: const AsyncError<MonthSummary>(
        FormatException('Confirmed income needs review.'),
        StackTrace.empty,
      ),
    );

    expect(find.byKey(const Key('heroError')), findsOneWidget);
    expect(find.text("Couldn't load this month"), findsOneWidget);
    expect(find.byKey(const Key('heroRetry')), findsOneWidget);
    expect(find.byKey(const Key('keptHero')), findsNothing);

    await tester.tap(find.byKey(const Key('heroRetry')));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('marks an incomplete month without hiding the computed amount',
      (tester) async {
    await pumpHero(
      tester,
      state: AsyncData(summary(openingBalance: null)),
    );

    expect(find.byKey(const Key('incompleteMarker')), findsOneWidget);
    expect(find.text('Incomplete'), findsOneWidget);
    expect(find.byKey(const Key('keptHero')), findsOneWidget);
  });

  testWidgets('invites planning for an empty future month', (tester) async {
    final month = nextMonth();
    await pumpHero(
      tester,
      state: AsyncData(summary(
        yearMonth: month,
        income: 0,
        paymentsMade: 0,
        moneyReturned: 0,
        openingBalance: null,
      )),
      yearMonth: month,
    );

    expect(find.byKey(const Key('heroPlanPrompt')), findsOneWidget);
    expect(find.text(DashboardCopy.planThisMonth), findsOneWidget);
    expect(find.byKey(const Key('keptHero')), findsNothing);
  });

  testWidgets('states a deficit in words as well as tone', (tester) async {
    await pumpHero(
      tester,
      state: AsyncData(summary(
        income: 100,
        paymentsMade: 500,
        moneyReturned: 0,
      )),
    );

    expect(find.byKey(const Key('heroDeficitLabel')), findsOneWidget);
    expect(find.text('Deficit this month'), findsOneWidget);
  });

  testWidgets('keeps a zero verdict neutral', (tester) async {
    await pumpHero(
      tester,
      state: AsyncData(summary(
        income: 1000,
        paymentsMade: 1000,
        moneyReturned: 0,
      )),
    );

    expect(find.byKey(const Key('keptHero')), findsOneWidget);
    expect(find.byKey(const Key('heroDeficitLabel')), findsNothing);
  });
}
