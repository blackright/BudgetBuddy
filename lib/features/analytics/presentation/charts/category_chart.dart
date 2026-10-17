import 'package:budget_buddy/features/analytics/domain/chart_series.dart';
import 'package:budget_buddy/shared/presentation/money_format.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../widgets/chart_card.dart';

/// Spending by category, one slice per category (US1, SC-001).
class CategoryChart extends StatelessWidget {
  const CategoryChart({
    super.key,
    required this.series,
    required this.size,
    this.onDrillDown,
  });

  final ChartSeries series;
  final ChartSize size;
  final void Function(ChartDrillDown)? onDrillDown;

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: 'By Category',
      series: series,
      size: size,
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

    final topSlices = slices.take(isMini ? 4 : slices.length).toList();

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: [
                for (final slice in topSlices)
                  PieChartSectionData(
                    value: slice.minorUnits.toDouble(),
                    color: Color(slice.colorValue),
                    title: isMini ? '' : slice.label,
                    showTitle: !isMini,
                    titleStyle: theme.textTheme.labelSmall,
                    radius: isMini ? 48 : 62,
                  )
              ],
              centerSpaceRadius: isMini ? 22 : 28,
              sectionsSpace: 2,
              startDegreeOffset: -90,
              pieTouchData: PieTouchData(
                enabled: !isMini,
                touchCallback: (event, response) {
                  if (isMini || event is! FlTapUpEvent) return;
                  if (response == null || response.touchedSection == null) {
                    return;
                  }
                  final idx = response.touchedSection!.touchedSectionIndex;
                  if (idx < 0 || idx >= topSlices.length) return;
                  onDrillDown?.call(
                    ChartDrillDownCategory(
                      categoryId: topSlices[idx].categoryId,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            for (final slice in topSlices)
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
                        ? (slice.label.length > 12
                            ? '${slice.label.substring(0, 12)}...'
                            : slice.label)
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
