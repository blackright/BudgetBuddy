import 'package:budget_buddy/features/analytics/domain/chart_series.dart';
import 'package:budget_buddy/shared/presentation/money_format.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../widgets/chart_card.dart';

/// Shared spending versus personal spending (US4).
///
/// Two slices whose sum is the combined figure shown in the header, so the
/// comparison is always internally consistent (SC-001). Shared-only: it renders
/// from the Analytics screen only while a space is active.
class SharedVsPersonalChart extends StatelessWidget {
  const SharedVsPersonalChart({
    super.key,
    required this.series,
    required this.size,
  });

  final ChartSeries series;
  final ChartSize size;

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: 'Shared vs Personal',
      subtitle: formatMinorUnits(series.total, series.currency),
      series: series,
      size: size,
      emptyMessage: 'No spending this month',
      child: _plot(context),
    );
  }

  Widget _plot(BuildContext context) {
    final theme = Theme.of(context);
    final slices = series.slices;
    final isMini = size == ChartSize.mini;

    if (slices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: [
                for (final slice in slices)
                  PieChartSectionData(
                    value: slice.minorUnits.toDouble(),
                    color: Color(slice.colorValue),
                    title: '',
                    showTitle: false,
                    radius: isMini ? 48 : 62,
                  )
              ],
              centerSpaceRadius: isMini ? 22 : 28,
              sectionsSpace: 2,
              startDegreeOffset: -90,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            for (final slice in slices)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(slice.colorValue),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isMini
                        ? slice.label
                        : '${slice.label} '
                            '${formatMinorUnits(slice.minorUnits, series.currency)}',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
