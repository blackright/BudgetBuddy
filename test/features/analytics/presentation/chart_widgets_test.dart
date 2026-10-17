import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/features/analytics/domain/chart_series.dart';
import 'package:budget_buddy/features/analytics/presentation/charts/available_trend_chart.dart';
import 'package:budget_buddy/features/analytics/presentation/charts/category_chart.dart';
import 'package:budget_buddy/features/analytics/presentation/charts/contribution_chart.dart';
import 'package:budget_buddy/features/analytics/presentation/charts/insurance_chart.dart';
import 'package:budget_buddy/features/analytics/presentation/charts/planned_paid_chart.dart';
import 'package:budget_buddy/features/analytics/presentation/charts/shared_vs_personal_chart.dart';
import 'package:budget_buddy/features/analytics/presentation/charts/spending_chart.dart';
import 'package:budget_buddy/features/analytics/presentation/widgets/chart_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// US2 chart-widget contract (T016): every chart is one widget that renders at
/// both sizes, and the shared [ChartCard] shell owns the empty and degraded
/// states (contract chart-ui.md §1, §4).
void main() {
  Widget wrap(Widget child) =>
      MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

  ChartSeries spending(
          {bool isEmpty = false,
          ChartDegradedState? degraded,
          int excluded = 0}) =>
      ChartSeries(
        kind: ChartKind.spending,
        currency: CurrencyCode.huf,
        total: 3000,
        isEmpty: isEmpty,
        buckets: [
          DayBucket(
            label: '5',
            minorUnits: 1000,
            date: DateTime(2026, 1, 5),
            pointCount: 1,
          ),
          DayBucket(
            label: '12',
            minorUnits: 2000,
            date: DateTime(2026, 1, 12),
            pointCount: 2,
          ),
        ],
        degraded: degraded,
        excludedCount: excluded,
      );

  ChartSeries category() => const ChartSeries(
        kind: ChartKind.category,
        currency: CurrencyCode.huf,
        total: 3000,
        isEmpty: false,
        slices: [
          CategorySlice(
            categoryId: 'food',
            label: 'Food',
            emoji: '🍎',
            colorValue: 0xFF4CAF50,
            minorUnits: 3000,
            fraction: 1,
          ),
        ],
      );

  ChartSeries plannedPaid() => const ChartSeries(
        kind: ChartKind.plannedPaid,
        currency: CurrencyCode.huf,
        total: 2000,
        isEmpty: false,
        bars: [
          BarPair(
            label: 'Food',
            plannedMinorUnits: 800,
            paidMinorUnits: 2000,
          ),
        ],
      );

  group('ChartCard empty state (FR-013, SC-005)', () {
    testWidgets('shows the friendly hint instead of a plot', (tester) async {
      await tester.pumpWidget(
        wrap(
          SpendingChart(
            series: spending(isEmpty: true),
            size: ChartSize.full,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(ChartCard.emptyStateKey), findsOneWidget);
      expect(find.text('No expenses this month'), findsOneWidget);
      expect(find.byType(LineChart), findsNothing);
    });
  });

  group('ChartCard degraded badge (FR-005, SC-005)', () {
    testWidgets('names the currency and the excluded count', (tester) async {
      await tester.pumpWidget(
        wrap(
          SpendingChart(
            series: spending(
              degraded: const ChartDegradedState(hasMissingRates: true),
              excluded: 2,
            ),
            size: ChartSize.full,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(ChartCard.degradedBadgeKey), findsOneWidget);
      expect(find.textContaining('2 excluded'), findsOneWidget);
      expect(find.textContaining('HUF'), findsOneWidget);
    });

    testWidgets('is absent for a complete series', (tester) async {
      await tester.pumpWidget(
        wrap(SpendingChart(series: spending(), size: ChartSize.full)),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(ChartCard.degradedBadgeKey), findsNothing);
    });
  });

  group('one widget renders at mini and full (FR-002, SC-002)', () {
    testWidgets('spending line renders at both sizes', (tester) async {
      await tester.pumpWidget(
        wrap(SpendingChart(series: spending(), size: ChartSize.mini)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LineChart), findsOneWidget);

      await tester.pumpWidget(
        wrap(SpendingChart(series: spending(), size: ChartSize.full)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('category pie renders at both sizes', (tester) async {
      await tester.pumpWidget(
        wrap(CategoryChart(series: category(), size: ChartSize.mini)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PieChart), findsOneWidget);

      await tester.pumpWidget(
        wrap(CategoryChart(series: category(), size: ChartSize.full)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PieChart), findsOneWidget);
    });

    testWidgets('planned-vs-paid bars render at both sizes', (tester) async {
      await tester.pumpWidget(
        wrap(PlannedPaidChart(series: plannedPaid(), size: ChartSize.mini)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BarChart), findsOneWidget);

      await tester.pumpWidget(
        wrap(PlannedPaidChart(series: plannedPaid(), size: ChartSize.full)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('available trend line renders at both sizes', (tester) async {
      await tester.pumpWidget(
        wrap(AvailableTrendChart(series: spending(), size: ChartSize.mini)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LineChart), findsOneWidget);

      await tester.pumpWidget(
        wrap(AvailableTrendChart(series: spending(), size: ChartSize.full)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LineChart), findsOneWidget);
    });
  });

  group('segment-tap drill-down (US3, FR-008, SC-007)', () {
    testWidgets('a full-size category slice emits a typed category request',
        (tester) async {
      final requests = <ChartDrillDown>[];
      await tester.pumpWidget(
        wrap(
          CategoryChart(
            series: category(),
            size: ChartSize.full,
            onDrillDown: requests.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The only slice fills the whole ring, so any ring point hits it.
      final center = tester.getCenter(find.byType(PieChart));
      await tester.tapAt(center + const Offset(36, 0));
      await tester.pumpAndSettle();

      expect(requests, hasLength(1));
      expect(requests.single, isA<ChartDrillDownCategory>());
      expect(
        (requests.single as ChartDrillDownCategory).categoryId,
        'food',
      );
    });

    testWidgets('a full-size paid bar emits a typed status request',
        (tester) async {
      final requests = <ChartDrillDown>[];
      await tester.pumpWidget(
        wrap(
          PlannedPaidChart(
            series: plannedPaid(),
            size: ChartSize.full,
            onDrillDown: requests.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // A single spaceEvenly group is centred after the 44px left axis; the
      // two rods sit about 8px either side of that centre. Tap low, where both
      // rods have height, on the paid (right) rod.
      final rect = tester.getRect(find.byType(BarChart));
      final plotCenterX = rect.left + 44 + (rect.width - 44) / 2;
      final lowY = rect.bottom - 28 - 15;
      await tester.tapAt(Offset(plotCenterX + 8, lowY));
      await tester.pumpAndSettle();

      expect(requests, hasLength(1));
      expect(requests.single, isA<ChartDrillDownStatus>());
      expect(
        (requests.single as ChartDrillDownStatus).status,
        ExpenseStatus.paid,
      );
    });

    testWidgets('mini charts do not drill down (contract §5)', (tester) async {
      final requests = <ChartDrillDown>[];
      await tester.pumpWidget(
        wrap(
          CategoryChart(
            series: category(),
            size: ChartSize.mini,
            onDrillDown: requests.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final center = tester.getCenter(find.byType(PieChart));
      await tester.tapAt(center + const Offset(24, 0));
      await tester.pumpAndSettle();

      expect(requests, isEmpty);
    });

    testWidgets('an empty series stays inert and never crashes',
        (tester) async {
      final requests = <ChartDrillDown>[];
      await tester.pumpWidget(
        wrap(
          CategoryChart(
            series: const ChartSeries(
              kind: ChartKind.category,
              currency: CurrencyCode.huf,
              total: 0,
              isEmpty: true,
            ),
            size: ChartSize.full,
            onDrillDown: requests.add,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(ChartCard.emptyStateKey), findsOneWidget);
      await tester.tapAt(
        tester.getCenter(find.byKey(ChartCard.emptyStateKey)),
      );
      await tester.pumpAndSettle();
      expect(requests, isEmpty);
    });
  });

  group('accessibility, dark mode & formatting (T032, contract §6)', () {
    Widget darkWrap(Widget child) => MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(body: SingleChildScrollView(child: child)),
        );

    testWidgets('the US4 charts render in dark mode without error',
        (tester) async {
      const insurance = ChartSeries(
        kind: ChartKind.insurance,
        currency: CurrencyCode.huf,
        total: 10000,
        isEmpty: false,
        slices: [
          CategorySlice(
            categoryId: 'insurer',
            label: 'Insurer paid',
            emoji: '',
            colorValue: 0xFF42A5F5,
            minorUnits: 8000,
            fraction: 0.8,
          ),
          CategorySlice(
            categoryId: 'patient',
            label: 'You pay',
            emoji: '',
            colorValue: 0xFFFFA726,
            minorUnits: 2000,
            fraction: 0.2,
          ),
        ],
      );
      const contribution = ChartSeries(
        kind: ChartKind.contribution,
        currency: CurrencyCode.huf,
        total: 3500,
        isEmpty: false,
        slices: [
          CategorySlice(
            categoryId: 'member:2',
            label: 'Member 2',
            emoji: '',
            colorValue: 0xFF66BB6A,
            minorUnits: 3000,
            fraction: 0.8,
          ),
          CategorySlice(
            categoryId: 'member:1',
            label: 'Member 1',
            emoji: '',
            colorValue: 0xFF42A5F5,
            minorUnits: 500,
            fraction: 0.14,
          ),
          CategorySlice(
            categoryId: 'member:3',
            label: 'Member 3',
            emoji: '',
            colorValue: 0xFFEF5350,
            minorUnits: 0,
            fraction: 0,
          ),
        ],
      );
      const comparison = ChartSeries(
        kind: ChartKind.sharedVsPersonal,
        currency: CurrencyCode.huf,
        total: 3500,
        isEmpty: false,
        slices: [
          CategorySlice(
            categoryId: 'personal',
            label: 'Personal',
            emoji: '',
            colorValue: 0xFF7E57C2,
            minorUnits: 1000,
            fraction: 0.286,
          ),
          CategorySlice(
            categoryId: 'shared',
            label: 'Shared',
            emoji: '',
            colorValue: 0xFF26A69A,
            minorUnits: 2500,
            fraction: 0.714,
          ),
        ],
      );

      await tester.pumpWidget(
        darkWrap(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InsuranceChart(series: insurance, size: ChartSize.full),
              ContributionChart(series: contribution),
              SharedVsPersonalChart(series: comparison, size: ChartSize.full),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Every money label comes from the single formatter — the HUF symbol (Ft)
      // appears and no chart hardcodes a currency symbol of its own (contract §6).
      expect(find.textContaining('Ft'), findsWidgets);
      // The zero contributor keeps a visible labelled row, never dropped.
      expect(find.text('Member 3'), findsOneWidget);
    });
  });
}
