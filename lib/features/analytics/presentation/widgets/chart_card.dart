import 'package:flutter/material.dart';

import '../../domain/chart_series.dart';

/// The frame every chart is drawn inside (contracts/chart-ui.md §4).
///
/// It owns the two mandatory states so no individual chart has to:
/// - the **empty state** (FR-013) when [series] has nothing to draw, and
/// - the **degraded-rate badge** (FR-005) when some records could not be
///   converted and were excluded from the total.
///
/// The Plot itself is passed in as [child] so each chart type stays a single
/// widget that renders in both [ChartSize] modes (FR-002); the card only sizes
/// the slot, it never draws data.
class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.series,
    required this.size,
    required this.child,
    this.subtitle,
    this.emptyMessage,
  });

  /// Height of the plot slot in [ChartSize.mini] mode.
  static const double miniPlotHeight = 130;

  /// Height of the plot slot in [ChartSize.full] mode.
  static const double fullPlotHeight = 240;

  /// Key on the empty-state placeholder, for widget tests.
  static const Key emptyStateKey = Key('chartEmptyState');

  /// Key on the degraded-rate badge, for widget tests.
  static const Key degradedBadgeKey = Key('chartDegradedBadge');

  /// Card heading.
  final String title;

  /// Optional line under [title], e.g. the current total.
  final String? subtitle;

  /// The data to draw; its [ChartSeries.isEmpty] / [ChartSeries.degraded]
  /// states are handled here.
  final ChartSeries series;

  /// Density/interaction mode (contracts/chart-ui.md §1).
  final ChartSize size;

  /// The plot to render when the series is non-empty.
  final Widget child;

  /// Hint shown in the empty state; a sensible default is used when omitted.
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final degraded = series.degraded;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: theme.textTheme.titleSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
            if (degraded != null) ...[
              const SizedBox(height: 8),
              _DegradedBadge(series: series),
            ],
            const SizedBox(height: 12),
            SizedBox(
              height: size == ChartSize.mini ? miniPlotHeight : fullPlotHeight,
              child:
                  series.isEmpty ? _EmptyState(message: emptyMessage) : child,
            ),
          ],
        ),
      ),
    );
  }
}

/// The friendly empty hint shown instead of a fabricated plot (FR-013).
class _EmptyState extends StatelessWidget {
  const _EmptyState({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      key: ChartCard.emptyStateKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insights_outlined,
            size: 32,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            message ?? 'No expenses this month',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// The visible "rates unavailable" banner (FR-005, contracts/chart-ui.md §4.2).
///
/// It names the display currency and states plainly that the total is partial,
/// so a missing rate can never silently read as a smaller-but-complete figure.
class _DegradedBadge extends StatelessWidget {
  const _DegradedBadge({required this.series});

  final ChartSeries series;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = series.currency.code.toUpperCase();
    return Container(
      key: ChartCard.degradedBadgeKey,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Rates unavailable for some records — '
              '${series.excludedCount} excluded from the $currency total',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
