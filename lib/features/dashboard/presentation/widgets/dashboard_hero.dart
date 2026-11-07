import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/currency_code.dart';
import '../../../../core/providers/selected_month_provider.dart';
import '../../../../shared/presentation/money_format.dart';
import '../../../medical/presentation/medical_theme.dart';
import '../../providers/dashboard_providers.dart';
import '../dashboard_copy.dart';
import '../dashboard_view_state.dart';

/// The single verdict at the top of the Dashboard.
///
/// The amount is painted directly on the page surface, never in a card, and is
/// the largest element on the screen (FR-001, FR-008). Every state that is not
/// a real verdict is explicit: loading, failed, incomplete, future-empty,
/// negative and zero all read differently.
class DashboardHero extends ConsumerWidget {
  const DashboardHero({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardMonthVerdictProvider);
    final yearMonth = ref.watch(selectedYearMonthProvider);
    final currency = ref.watch(dashboardCurrencyProvider);
    final verdict =
        DashboardMonthVerdict.fromAsync(async, yearMonth: yearMonth);

    return switch (verdict.status) {
      DashboardDataStatus.loading => _HeroFrame(
          caption: verdict.caption,
          child: const _LoadingAmount(),
        ),
      DashboardDataStatus.error => _HeroFrame(
          caption: verdict.caption,
          child: _ErrorAmount(
            onRetry: () => retryDashboardVerdict(ref),
          ),
        ),
      DashboardDataStatus.ready => _ReadyHero(
          verdict: verdict,
          currency: currency,
        ),
    };
  }
}

class _HeroFrame extends StatelessWidget {
  const _HeroFrame({required this.caption, required this.child});

  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              DashboardCopy.kept,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(width: 6),
            const Text('·'),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                caption,
                key: const Key('heroCaption'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _ReadyHero extends StatelessWidget {
  const _ReadyHero({required this.verdict, required this.currency});

  final DashboardMonthVerdict verdict;
  final CurrencyCode currency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final summary = verdict.summary!;

    if (verdict.isFutureEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroFrame(
            caption: verdict.caption,
            child: _AmountText(
              text: DashboardCopy.planThisMonth,
              amountKey: const Key('heroPlanPrompt'),
              color: scheme.onSurface,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DashboardCopy.planThisMonthDetail,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      );
    }

    final incomplete = verdict.isIncomplete;
    final amountColor = incomplete
        ? scheme.onSurfaceVariant
        : summary.kept < 0
            ? MedicalTheme.semantic(context, MedicalTheme.moneyOut)
            : scheme.onSurface;
    final supporting = DashboardCopy.heroSupportingLine(summary, currency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroFrame(
          caption: verdict.caption,
          child: Semantics(
            label: _amountSemantics(verdict, currency),
            excludeSemantics: true,
            child: _AmountText(
              text: formatMajorUnits(summary.kept, currency),
              amountKey: const Key('keptHero'),
              color: amountColor,
            ),
          ),
        ),
        if (incomplete) ...[
          const SizedBox(height: 6),
          _IncompleteMarker(),
        ],
        if (supporting.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            supporting,
            key: const Key('heroSupportingLine'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
        if (verdict.hasDeficit) ...[
          const SizedBox(height: 4),
          Text(
            DashboardCopy.deficitThisMonth,
            key: const Key('heroDeficitLabel'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: MedicalTheme.semantic(context, MedicalTheme.moneyOut),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ],
    );
  }

  String _amountSemantics(DashboardMonthVerdict value, CurrencyCode currency) {
    final amount = formatMajorUnits(value.summary!.kept, currency);
    final extra = value.hasDeficit
        ? ', ${DashboardCopy.deficitThisMonth}'
        : value.isIncomplete
            ? ', ${DashboardCopy.incomplete}'
            : '';
    return '${DashboardCopy.kept}, $amount, ${value.caption}$extra';
  }
}

class _IncompleteMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const Key('incompleteMarker'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        DashboardCopy.incomplete,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _LoadingAmount extends StatelessWidget {
  const _LoadingAmount();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Loading month verdict',
      child: Container(
        key: const Key('heroLoading'),
        width: 180,
        height: 48,
        decoration: BoxDecoration(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _ErrorAmount extends StatelessWidget {
  const _ErrorAmount({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DashboardCopy.couldNotLoadThisMonth,
          key: const Key('heroError'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        TextButton(
          key: const Key('heroRetry'),
          onPressed: onRetry,
          child: const Text(DashboardCopy.retry),
        ),
      ],
    );
  }
}

class _AmountText extends StatelessWidget {
  const _AmountText({
    required this.text,
    required this.color,
    this.amountKey,
    this.fontSize = 52,
  });

  final String text;
  final Color color;
  final Key? amountKey;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          key: amountKey,
          maxLines: 1,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.0,
            color: color,
          ),
        ),
      ),
    );
  }
}
