import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/dashboard/presentation/month_summary_detail_screen.dart';
import 'package:budget_buddy/features/dashboard/providers/dashboard_providers.dart';
import 'package:budget_buddy/features/engine/month_summary.dart';
import 'package:budget_buddy/features/engine/providers/month_summary_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/finance/providers/finance_providers.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:budget_buddy/shared/presentation/widgets/conversion_footnote.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  MonthlyBudget budget({required String currency}) {
    return MonthlyBudget()
      ..id = 1
      ..yearMonth = currentYearMonth()
      ..baseAvailableAmount = 1000
      ..openingBalanceConfirmed = true
      ..currency = currency
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
  }

  MonthSummary summary({
    String? yearMonth,
    double income = 4000,
    double paymentsMade = 1200,
    double moneyReturned = 300,
    double planned = 800,
    double cancelled = 150,
    double medicalPaid = 200,
    double insuranceReturned = 100,
    double expenseReturned = 200,
    double? openingBalance = 1000,
    double setAside = 800,
    double carryOver = 100,
    double carriedIn = 50,
    double releasedAtMonthEnd = 25,
    double vaultTransfers = 0,
    double expectedIncome = 500,
    bool usesOverriddenIncome = false,
  }) {
    return MonthSummary(
      yearMonth: yearMonth ?? currentYearMonth(),
      income: income,
      usesOverriddenIncome: usesOverriddenIncome,
      paymentsMade: paymentsMade,
      moneyReturned: moneyReturned,
      planned: planned,
      cancelled: cancelled,
      medicalPaid: medicalPaid,
      excessReturned: 0,
      insuranceReturned: insuranceReturned,
      expenseReturned: expenseReturned,
      openingBalance: openingBalance,
      setAside: setAside,
      carryOver: carryOver,
      carriedIn: carriedIn,
      releasedAtMonthEnd: releasedAtMonthEnd,
      vaultTransfers: vaultTransfers,
      expectedIncome: expectedIncome,
    );
  }

  Widget app({
    MonthSummary? value,
    String? yearMonth,
    CurrencyCode display = CurrencyCode.usd,
    CurrencyCode main = CurrencyCode.usd,
    int borrowed = 1234,
  }) {
    final month = yearMonth ?? currentYearMonth();
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const MonthSummaryDetailScreen(),
        ),
        GoRoute(
          path: '/income_sources',
          builder: (context, state) => const Scaffold(
            body: Text('Income Sources'),
          ),
        ),
        GoRoute(
          path: '/allocations',
          builder: (context, state) => const Scaffold(
            body: Text('Allocations'),
          ),
        ),
        GoRoute(
          path: '/medical',
          builder: (context, state) => const Scaffold(
            body: Text('Medical'),
          ),
        ),
        GoRoute(
          path: '/expenses',
          builder: (context, state) => const Scaffold(
            body: Text('Expenses'),
          ),
        ),
        GoRoute(
          path: '/month_end',
          builder: (context, state) => const Scaffold(
            body: Text('Month end'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    return ProviderScope(
      overrides: [
        selectedYearMonthProvider.overrideWith((ref) => month),
        monthSummaryProvider.overrideWithValue(
          value ?? summary(yearMonth: month),
        ),
        monthFinanceProvider.overrideWith(
          (ref) => Stream.value(budget(currency: display.code)),
        ),
        mainCurrencyProvider.overrideWithValue(main),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        dashboardBorrowingTotalsProvider.overrideWithValue(
          (borrowed: borrowed, deficit: 0),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Future<void> pumpStatement(
    WidgetTester tester, {
    MonthSummary? value,
    String? yearMonth,
    CurrencyCode display = CurrencyCode.usd,
    CurrencyCode main = CurrencyCode.usd,
    int borrowed = 1234,
    Size size = const Size(1000, 2400),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      app(
        value: value,
        yearMonth: yearMonth,
        display: display,
        main: main,
        borrowed: borrowed,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('uses a month-aware title and hero', (tester) async {
    await pumpStatement(tester);

    expect(find.byKey(const Key('statementTitle')), findsOneWidget);
    expect(find.text('Month breakdown'), findsOneWidget);
    expect(find.byKey(const Key('statementHeroTitle')), findsOneWidget);
    expect(find.text('Kept this month'), findsOneWidget);
    expect(find.byKey(const Key('statementKept')), findsOneWidget);
    expect(find.text(r'$ 2,275.00'), findsWidgets);
  });

  testWidgets('names the selected month outside the current month',
      (tester) async {
    final month = previousMonth();
    await pumpStatement(
      tester,
      value: summary(yearMonth: month),
      yearMonth: month,
    );

    expect(find.text('${monthLabel(month)} breakdown'), findsOneWidget);
    expect(find.text('Kept in ${monthLabel(month)}'), findsOneWidget);
  });

  testWidgets('shows every required row and the approved formula',
      (tester) async {
    await pumpStatement(tester);

    for (final key in const [
      'statementIncome',
      'statementPaidOut',
      'statementBack',
      'statementPlanned',
      'statementSetAside',
      'statementBorrowed',
      'statementCarriedOver',
      'statementReleased',
      'statementKeptTotal',
    ]) {
      expect(find.byKey(Key(key)), findsOneWidget, reason: key);
    }

    expect(find.byKey(const Key('statementReserved')), findsOneWidget);
    expect(find.byKey(const Key('statementMedicalBack')), findsOneWidget);
    expect(find.byKey(const Key('statementExpenseBack')), findsOneWidget);
    expect(find.byKey(const Key('statementCancelled')), findsOneWidget);
    expect(find.byKey(const Key('statementExpectedIncome')), findsNothing);
    expect(find.text('Expected income'), findsNothing);
    expect(find.byKey(const Key('statementIncomeAmount')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('statementCalculationSection')),
        matching: find.byKey(const Key('statementIncome')),
      ),
      findsNothing,
    );
    final keptText =
        tester.widget<Text>(find.byKey(const Key('statementKept')));
    final incomeText =
        tester.widget<Text>(find.byKey(const Key('statementIncomeAmount')));
    expect(
      incomeText.style!.fontSize!,
      lessThan(keptText.style!.fontSize!),
    );
    expect(find.byKey(const Key('statementVaultTransfers')), findsNothing);
    expect(find.text('Returned'), findsNothing);
    expect(find.text('Set aside for budgets'), findsNothing);
    expect(find.text('Borrowed so far'), findsNothing);
    expect(find.text('Allocated total'), findsNothing);
    expect(find.text('At a glance'), findsNothing);
    expect(find.text('Money back'), findsOneWidget);
    expect(find.text('Budget set-aside'), findsOneWidget);
    expect(find.text('Borrowed from reserve'), findsOneWidget);
    expect(find.text('What you kept'), findsOneWidget);
    expect(find.text('Money in the bank'), findsOneWidget);
    expect(find.text('How this month adds up'), findsOneWidget);

    final formula =
        tester.widget<Text>(find.byKey(const Key('statementFormula')));
    expect(formula.data, contains('Formula: Income − money paid out'));
    expect(formula.data, contains('− budget set-aside − held for next month'));
    expect(
      formula.data,
      contains('+ carried over from last month + released at month end'),
    );
    expect(formula.data, isNot(contains('Borrowed')));
    expect(
      find.text('Already included in money paid out'),
      findsOneWidget,
    );
  });

  testWidgets('keeps required zero rows while hiding optional zero rows',
      (tester) async {
    await pumpStatement(
      tester,
      value: summary(
        setAside: 0,
        carryOver: 0,
        carriedIn: 0,
        releasedAtMonthEnd: 0,
        expectedIncome: 0,
        cancelled: 0,
        insuranceReturned: 0,
        expenseReturned: 0,
      ),
      borrowed: 0,
    );

    for (final key in const [
      'statementSetAside',
      'statementBorrowed',
      'statementCarriedOver',
      'statementReleased',
    ]) {
      expect(find.byKey(Key(key)), findsOneWidget, reason: key);
    }
    expect(find.byKey(const Key('statementReserved')), findsNothing);
    expect(find.byKey(const Key('statementExpectedIncome')), findsNothing);
    expect(find.byKey(const Key('statementCancelled')), findsNothing);
    expect(find.byKey(const Key('statementMedicalBack')), findsNothing);
    expect(find.byKey(const Key('statementExpenseBack')), findsNothing);
  });

  testWidgets('uses titles and one calculation section with a result tile',
      (tester) async {
    await pumpStatement(tester);

    expect(find.byKey(const Key('statementMoneyInBankTitle')), findsOneWidget);
    expect(find.byKey(const Key('statementCalculationTitle')), findsOneWidget);
    expect(
      find.byKey(const Key('statementCalculationSection')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('statementResultTile')), findsOneWidget);
    expect(find.byKey(const Key('statementKeptTotal')), findsOneWidget);
  });

  testWidgets('omits the conversion note for a single currency',
      (tester) async {
    await pumpStatement(tester);
    expect(find.byKey(const Key('conversionFootnote')), findsNothing);
  });

  testWidgets('shows the conversion note when currencies differ',
      (tester) async {
    await pumpStatement(
      tester,
      display: CurrencyCode.eur,
      main: CurrencyCode.usd,
    );
    final footnote =
        tester.widget<ConversionFootnote>(find.byType(ConversionFootnote));
    expect(footnote.main, CurrencyCode.usd);
    expect(footnote.display, CurrencyCode.eur);
    expect(find.byKey(const Key('conversionFootnote')), findsOneWidget);
    expect(find.byKey(const Key('statementConversionNote')), findsOneWidget);
  });

  for (final entry in const {
    'statementSetAside': 'Allocations',
    'statementBorrowed': 'Allocations',
    'statementIncome': 'Income Sources',
    'statementMedicalBack': 'Medical',
    'statementExpenseBack': 'Expenses',
    'statementPlanned': 'Expenses',
    'statementCarriedOver': 'Month end',
    'statementReleased': 'Month end',
  }.entries) {
    testWidgets('${entry.key} opens ${entry.value}', (tester) async {
      await pumpStatement(tester);
      final link = find.byKey(Key(entry.key));
      await tester.ensureVisible(link);
      await tester.tap(link);
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('aligns values and separators across calculation tiles',
      (tester) async {
    await pumpStatement(tester);

    double valueRightEdge(String tileKey, String value) {
      final text = find.descendant(
        of: find.byKey(Key(tileKey)),
        matching: find.text(value),
      );
      expect(text, findsOneWidget, reason: '$tileKey value');
      return tester.getTopRight(text).dx;
    }

    final rightEdges = [
      valueRightEdge('statementPaidOut', r'- $ 1,200.00'),
      valueRightEdge('statementBack', r'+ $ 300.00'),
      valueRightEdge('statementSetAside', r'- $ 800.00'),
      valueRightEdge('statementCarriedOver', r'+ $ 50.00'),
      valueRightEdge('statementKeptTotal', r'$ 2,275.00'),
    ];
    for (final edge in rightEdges.skip(1)) {
      expect(edge, closeTo(rightEdges.first, 0.5));
    }

    double dividerX(String tileKey) =>
        tester.getTopLeft(find.byKey(Key('${tileKey}Divider'))).dx;

    final dividerXs = [
      dividerX('statementPaidOut'),
      dividerX('statementBack'),
      dividerX('statementSetAside'),
      dividerX('statementCarriedOver'),
      dividerX('statementKeptTotal'),
    ];
    for (final x in dividerXs.skip(1)) {
      expect(x, closeTo(dividerXs.first, 0.5));
    }
  });

  testWidgets('stays usable at 320 dp and 200% text', (tester) async {
    await pumpStatement(
      tester,
      size: const Size(320, 1600),
      textScale: 2,
    );

    expect(
        find.byKey(const Key('statementCalculationSection')), findsOneWidget);
    expect(find.byKey(const Key('statementResultTile')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the override marker only for an overridden month',
      (tester) async {
    await pumpStatement(tester);
    expect(find.byKey(const Key('overrideMarker')), findsNothing);

    await pumpStatement(
      tester,
      value: summary(usesOverriddenIncome: true),
    );
    expect(find.byKey(const Key('overrideMarker')), findsOneWidget);
  });
}
