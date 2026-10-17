import 'package:budget_buddy/features/analytics/domain/chart_series.dart';
import 'package:budget_buddy/shared/presentation/money_format.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../widgets/chart_card.dart';
import 'chart_scale.dart';

/// Monthly spending over time (US1, FR-015).
class SpendingChart extends StatelessWidget {
  const SpendingChart({
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
      title: 'Monthly Spending',
      subtitle: formatMinorUnits(series.total, series.currency),
      series: series,
      size: size,
      child: _plot(context),
    );
  }

  Widget _plot(BuildContext context) {
    final theme = Theme.of(context);
    final buckets = series.buckets;
    final isMini = size == ChartSize.mini;

    if (buckets.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = [
      for (var i = 0; i < buckets.length; i++)
        FlSpot(i.toDouble(), buckets[i].minorUnits.toDouble()),
    ];

    // Scale the axis to the tallest bucket, not the running total, so the line
    // uses the full height instead of hugging the bottom.
    final peak =
        buckets.fold<int>(0, (m, b) => b.minorUnits > m ? b.minorUnits : m);
    final yInterval = niceInterval(peak.toDouble());
    final maxY = prettyMaxY(peak.toDouble(), yInterval);

    // A single point has no line to draw, so widen the range and force its dot
    // on — otherwise the mini card would look empty.
    final singlePoint = spots.length == 1;
    final minX = singlePoint ? -0.5 : 0.0;
    final maxX = singlePoint ? 0.5 : (spots.length - 1).toDouble();
    final showDots = !isMini || buckets.length <= 3;

    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            dotData: FlDotData(show: showDots),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          show: true,
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: !isMini,
              reservedSize: 44,
              interval: yInterval,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(
                  formatMinorUnitsCompact(value.toInt(), series.currency),
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: !isMini && !singlePoint && spots.length <= 12,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.round();
                if (idx < 0 || idx >= buckets.length) {
                  return SideTitleWidget(
                    meta: meta,
                    child: const SizedBox.shrink(),
                  );
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    buckets[idx].label,
                    style: theme.textTheme.labelSmall,
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: !isMini,
          drawVerticalLine: false,
          horizontalInterval: yInterval,
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          enabled: !isMini,
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) => [
              for (final spot in touchedSpots)
                LineTooltipItem(
                  '${buckets[spot.spotIndex].label}: '
                  '${formatMinorUnits(spot.y.toInt(), series.currency)}',
                  theme.textTheme.bodySmall ?? const TextStyle(),
                )
            ],
            tooltipBorder: BorderSide(color: theme.colorScheme.outline),
          ),
        ),
      ),
    );
  }
}
