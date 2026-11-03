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
      appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 48,
          title: const Text('Analytics'),
          actions: [
            IconButton(
                tooltip: 'Reports',
                onPressed: () => context.push('/reports'),
                icon: const Icon(Icons.summarize_outlined))
          ]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                  Theme.of(context).colorScheme.surface,
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(Icons.insights_outlined,
                      color: Theme.of(context).colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Money at a glance',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text(
                        'Spending, cash flow and shared contribution in one place.',
                        style: TextStyle(
                            fontSize: 12,
                            height: 1.3,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('VIEW',
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                const Center(child: LensSwitch()),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _AnalyticsSection(
              icon: Icons.pie_chart_outline, title: 'Spending'),
          const SizedBox(height: 8),
          SpendingChart(series: spending, size: ChartSize.full),
          const SizedBox(height: 12),
          CategoryChart(
            series: category,
            size: ChartSize.full,
            onDrillDown: (d) {
              if (d is ChartDrillDownCategory) {
                context.go('/expenses', extra: {
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
                context.go('/expenses', extra: {
                  'status': d.status.name,
                });
              }
            },
          ),
          const SizedBox(height: 18),
          const _AnalyticsSection(
              icon: Icons.account_balance_wallet_outlined, title: 'Cash flow'),
          const SizedBox(height: 8),
          AvailableTrendChart(series: availableTrend, size: ChartSize.full),
          const SizedBox(height: 12),
          InsuranceChart(series: insurance, size: ChartSize.full),
          // The shared-only charts render only while a space is active
          // (FR-011, contracts/chart-ui.md §3).
          if (isShared) ...[
            const SizedBox(height: 18),
            const _AnalyticsSection(
                icon: Icons.groups_outlined, title: 'Shared space'),
            const SizedBox(height: 8),
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
        ],
      ),
    );
  }
}

class _AnalyticsSection extends StatelessWidget {
  const _AnalyticsSection({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 17, color: scheme.primary),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}
