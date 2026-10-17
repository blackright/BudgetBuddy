import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/chart_series.dart';
import '../providers/chart_data_provider.dart';
import '../providers/chart_lens_provider.dart';
import 'charts/available_trend_chart.dart';
import 'charts/category_chart.dart';
import 'charts/contribution_chart.dart';
import 'charts/insurance_chart.dart';
import 'charts/planned_paid_chart.dart';
import 'charts/shared_vs_personal_chart.dart';
import 'charts/spending_chart.dart';
import 'widgets/lens_switch.dart';

/// The Analytics tab (US1/US2, contract chart-ui.md §2.2/§3): a scrollable
/// column of full-size charts under a single Personal/Shared lens switch.
///
/// It renders straight from the series providers, so it stays in sync with the
/// active context, month, and filters with no local state of its own (FR-006).
/// Switching the lens moves the app's active context, so every chart here
/// re-derives together (SC-004).
///
/// Drill-down and the remaining US3-US4 charts are layered in by later phases;
/// this screen only grows.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spending = ref.watch(spendingSeriesProvider);
    final category = ref.watch(categorySeriesProvider);
    final plannedPaid = ref.watch(plannedPaidSeriesProvider);
    final availableTrend = ref.watch(availableTrendSeriesProvider);
    final insurance = ref.watch(insuranceSeriesProvider);
    final isShared = ref.watch(chartLensProvider) == ChartLens.shared;

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(child: LensSwitch()),
          const SizedBox(height: 16),
          SpendingChart(series: spending, size: ChartSize.full),
          const SizedBox(height: 12),
          CategoryChart(
            series: category,
            size: ChartSize.full,
            onDrillDown: (d) {
              if (d is ChartDrillDownCategory) {
                context.push('/expenses', extra: {
                  'categoryId': d.categoryId,
                });
              }
            },
          ),
          const SizedBox(height: 12),
          PlannedPaidChart(
            series: plannedPaid,
            size: ChartSize.full,
            onDrillDown: (d) {
              if (d is ChartDrillDownStatus) {
                context.push('/expenses', extra: {
                  'status': d.status.name,
                });
              }
            },
          ),
          const SizedBox(height: 12),
          AvailableTrendChart(series: availableTrend, size: ChartSize.full),
          const SizedBox(height: 12),
          InsuranceChart(series: insurance, size: ChartSize.full),
          // The shared-only charts render only while a space is active
          // (FR-011, contracts/chart-ui.md §3).
          if (isShared) ...[
            const SizedBox(height: 12),
            SharedVsPersonalChart(
              series: ref.watch(sharedVsPersonalSeriesProvider),
              size: ChartSize.full,
            ),
            const SizedBox(height: 12),
            ContributionChart(
              series: ref.watch(contributionSeriesProvider),
              size: ChartSize.full,
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
