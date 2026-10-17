import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/features/analytics/domain/chart_series.dart';
import 'package:budget_buddy/shared/presentation/money_format.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../widgets/chart_card.dart';
import 'chart_scale.dart';

/// Planned versus paid per category (US1, Constitution IV).
class PlannedPaidChart extends StatelessWidget {
  const PlannedPaidChart({
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
      title: 'Planned vs Paid',
      series: series,
      size: size,
      child: _plot(context),
    );
  }

  Widget _plot(BuildContext context) {
    final theme = Theme.of(context);
    final bars = series.bars;
    final isMini = size == ChartSize.mini;

    if (bars.isEmpty) {
      return const SizedBox.shrink();
    }

    // The tallest rod is the biggest single planned or paid value (the two bars
    // sit side by side), so scaling to that fills the height instead of
    // squashing every bar to half.
    var peak = 0;
    for (final bar in bars) {
      if (bar.plannedMinorUnits > peak) peak = bar.plannedMinorUnits;
      if (bar.paidMinorUnits > peak) peak = bar.paidMinorUnits;
    }
    final yInterval = niceInterval(peak.toDouble());
    final maxY = prettyMaxY(peak.toDouble(), yInterval);

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceEvenly,
              maxY: maxY,
              minY: 0,
              barGroups: [
                for (var i = 0; i < bars.length; i++)
                  BarChartGroupData(
                    x: i,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        fromY: 0,
                        toY: bars[i].plannedMinorUnits.toDouble(),
                        color: theme.colorScheme.tertiary,
                        width: isMini ? 10 : 12,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        fromY: 0,
                        toY: bars[i].paidMinorUnits.toDouble(),
                        color: theme.colorScheme.primary,
                        width: isMini ? 10 : 12,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  )
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
                    showTitles: !isMini && bars.length <= 6,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final idx = value.round();
                      if (idx < 0 || idx >= bars.length) {
                        return SideTitleWidget(
                          meta: meta,
                          child: const SizedBox.shrink(),
                        );
                      }
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          bars[idx].label,
                          style: theme.textTheme.labelSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: !isMini,
                horizontalInterval: yInterval,
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                enabled: !isMini,
                handleBuiltInTouches: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, _, rod, rodIndex) {
                    final bar = bars[group.x.toInt()];
                    final label = rodIndex == 0 ? 'Planned' : 'Paid';
                    final amount = rodIndex == 0
                        ? bar.plannedMinorUnits
                        : bar.paidMinorUnits;
                    return BarTooltipItem(
                      '$label: ${formatMinorUnits(amount, series.currency)}\n'
                      '${bar.label}',
                      theme.textTheme.bodySmall ?? const TextStyle(),
                    );
                  },
                  tooltipBorder: BorderSide(color: theme.colorScheme.outline),
                ),
                touchCallback: (event, response) {
                  if (isMini || event is! FlTapUpEvent) return;
                  if (response == null || response.spot == null) return;
                  final group = response.spot!.touchedBarGroup;
                  final rodIndex = response.spot!.touchedRodDataIndex;
                  if (group.x < 0 || group.x >= bars.length) return;
                  if (rodIndex == 0) {
                    onDrillDown?.call(
                      const ChartDrillDownStatus(
                        status: ExpenseStatus.planned,
                      ),
                    );
                  } else if (rodIndex == 1) {
                    onDrillDown?.call(
                      const ChartDrillDownStatus(
                        status: ExpenseStatus.paid,
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(
              color: theme.colorScheme.tertiary,
              label: 'Planned',
              theme: theme,
            ),
            const SizedBox(width: 12),
            _LegendItem(
              color: theme.colorScheme.primary,
              label: 'Paid',
              theme: theme,
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.theme,
  });

  final Color color;
  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
