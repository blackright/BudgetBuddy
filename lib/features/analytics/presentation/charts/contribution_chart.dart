import 'package:budget_buddy/features/analytics/domain/chart_series.dart';
import 'package:budget_buddy/shared/presentation/money_format.dart';
import 'package:flutter/material.dart';

import '../widgets/chart_card.dart';

/// Each shared member's net contribution (US4, FR-011).
///
/// A labelled bar list rather than a proportional ring: a member's net can be
/// negative (they were reimbursed more than they spent), which a pie cannot
/// show. Every member of the space appears — including those who contributed
/// nothing, who keep a visible zero row (contracts/chart-data.md §4.2).
class ContributionChart extends StatelessWidget {
  const ContributionChart({
    super.key,
    required this.series,
    this.size = ChartSize.full,
  });

  final ChartSeries series;
  final ChartSize size;

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: 'Member Contributions',
      subtitle: 'Net of reimbursements',
      series: series,
      size: size,
      emptyMessage: 'No shared members yet',
      child: _plot(context),
    );
  }

  Widget _plot(BuildContext context) {
    final theme = Theme.of(context);
    final slices = series.slices;

    if (slices.isEmpty) {
      return const SizedBox.shrink();
    }

    // Bars are scaled against the largest absolute contribution, so the biggest
    // member fills the track and a zero contributor stays visible as a bare row.
    var peak = 0;
    for (final slice in slices) {
      final magnitude = slice.minorUnits.abs();
      if (magnitude > peak) peak = magnitude;
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: slices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final slice = slices[index];
        final fraction = peak == 0 ? 0.0 : slice.minorUnits.abs() / peak;
        return _ContributionRow(
          label: slice.label,
          amount: formatMinorUnits(slice.minorUnits, series.currency),
          color: Color(slice.colorValue),
          fraction: fraction.clamp(0.0, 1.0),
          theme: theme,
        );
      },
    );
  }
}

class _ContributionRow extends StatelessWidget {
  const _ContributionRow({
    required this.label,
    required this.amount,
    required this.color,
    required this.fraction,
    required this.theme,
  });

  final String label;
  final String amount;
  final Color color;
  final double fraction;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              amount,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
