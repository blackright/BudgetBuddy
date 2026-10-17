import 'package:budget_buddy/features/analytics/domain/chart_series.dart';
import 'package:budget_buddy/shared/presentation/money_format.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../widgets/chart_card.dart';
import 'chart_scale.dart';

/// How the available amount moved over the month (US2, FR-016).
///
/// The line counts down from the month's opening available amount as money
/// leaves and back up as reimbursements arrive — see `availableTrendSeries`.
class AvailableTrendChart extends StatelessWidget {
  const AvailableTrendChart({
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
      title: 'Available Trend',
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

    // The balance can dip below zero, so the axis spans the data rather than
    // always starting at 0.
    var lo = buckets.first.minorUnits;
    var hi = buckets.first.minorUnits;
    for (final bucket in buckets) {
      if (bucket.minorUnits < lo) lo = bucket.minorUnits;
      if (bucket.minorUnits > hi) hi = bucket.minorUnits;
    }
    if (lo > 0) lo = 0;
    if (hi < 0) hi = 0;
    final yInterval = niceInterval((hi - lo).toDouble());
    final maxY = prettyMaxY(hi.toDouble(), yInterval);
    final minY = lo < 0 ? -prettyMaxY(-lo.toDouble(), yInterval) : 0.0;

    final singlePoint = spots.length == 1;
    final minX = singlePoint ? -0.5 : 0.0;
    final maxX = singlePoint ? 0.5 : (spots.length - 1).toDouble();
    final showDots = !isMini || buckets.length <= 3;

    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: theme.colorScheme.tertiary,
            barWidth: 3,
            dotData: FlDotData(show: showDots),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.tertiary.withValues(alpha: 0.12),
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
