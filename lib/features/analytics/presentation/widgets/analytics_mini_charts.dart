import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/chart_series.dart';
import '../../providers/chart_data_provider.dart';
import '../charts/category_chart.dart';
import '../charts/planned_paid_chart.dart';
import '../charts/spending_chart.dart';

/// The Dashboard's analytics section (US1, contract chart-ui.md §3): a compact
/// horizontal strip of the three US1 charts in their [ChartSize.mini] form.
///
/// Data comes straight from the three series providers — no local state, so it
/// rebuilds whenever context/month/filters change (FR-006).
class AnalyticsMiniCharts extends ConsumerWidget {
  const AnalyticsMiniCharts({super.key});

  static const double _cardWidth = 232;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spending = ref.watch(spendingSeriesProvider);
    final category = ref.watch(categorySeriesProvider);
    final plannedPaid = ref.watch(plannedPaidSeriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analytics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: _cardWidth,
                child: SpendingChart(series: spending, size: ChartSize.mini),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: _cardWidth,
                child: CategoryChart(series: category, size: ChartSize.mini),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: _cardWidth,
                child: PlannedPaidChart(
                  series: plannedPaid,
                  size: ChartSize.mini,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
