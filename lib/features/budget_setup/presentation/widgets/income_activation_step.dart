import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/currency_code.dart';
import '../../../../core/models/income_source.dart';
import '../../../../core/models/salary_cycle.dart';
import '../../../../core/providers/selected_month_provider.dart';
import '../../../../core/services/income_activation_period.dart';
import '../../../../core/services/income_activation_service.dart';
import '../../../../shared/presentation/money_format.dart';
import '../../../finance/presentation/income_confirmation.dart';
import '../../../finance/providers/income_source_providers.dart';
import 'setup_form_components.dart';

/// Onboarding's current-period activation list.
///
/// Each saved source shows its state. Undecided sources open the shared
/// activation sheet. The parent action bar owns Continue / Set up later.
class OnboardingIncomeActivationStep extends ConsumerStatefulWidget {
  const OnboardingIncomeActivationStep({
    super.key,
    required this.profileId,
    required this.month,
  });

  final int profileId;
  final String month;

  @override
  ConsumerState<OnboardingIncomeActivationStep> createState() =>
      _OnboardingIncomeActivationStepState();
}

class _OnboardingIncomeActivationStepState
    extends ConsumerState<OnboardingIncomeActivationStep> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(selectedYearMonthProvider.notifier).state = widget.month;
    });
  }

  void _retry() {
    ref.invalidate(onboardingActivationSourcesProvider(widget.profileId));
    ref.invalidate(salaryCyclesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final sources =
        ref.watch(onboardingActivationSourcesProvider(widget.profileId));
    final cycles = ref.watch(salaryCyclesProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Set up this month’s income',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      const Text(
          'Choose what happened for each source this month. Creating a source does not add money.'),
      const SizedBox(height: 24),
      sources.when(
        loading: () => const SetupSurface(
            child: Center(child: CircularProgressIndicator())),
        error: (_, __) => SetupSurface(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Income sources could not be loaded.'),
          TextButton(onPressed: _retry, child: const Text('Retry')),
        ])),
        data: (list) {
          if (list.isEmpty) {
            return const SetupSurface(
                child: Text(
                    'No income sources yet. You can add them later from Income Sources.'));
          }
          return cycles.when(
            loading: () => const SetupSurface(
                child: Center(child: CircularProgressIndicator())),
            error: (_, __) => SetupSurface(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('Income period states could not be loaded.'),
                  TextButton(onPressed: _retry, child: const Text('Retry')),
                ])),
            data: (rows) => Column(children: [
              for (final source in list) _sourceCard(context, source, rows),
            ]),
          );
        },
      ),
      const SizedBox(height: 8),
      const Text(
          'You can leave sources for later. They will appear in Pending Actions without adding money.'),
    ]);
  }

  Widget _sourceCard(
      BuildContext context, IncomeSource source, List<SalaryCycle> cycles) {
    final period = periodKeyFor(source, DateTime.parse('${widget.month}-01'));
    final startsLater = !isPeriodActive(source, period);
    final cycle = cycles
        .where((row) =>
            row.sourceGuid == source.syncGuid && row.occurrenceMonth == period)
        .firstOrNull;
    final state = cycle == null
        ? IncomePeriodState.needsActivation
        : cycle.confirmed
            ? IncomePeriodState.confirmed
            : incomePeriodStateFromStored(cycle.state);
    final currency = CurrencyCode.tryParse(source.currency) ?? CurrencyCode.huf;
    final label = switch (state) {
      IncomePeriodState.needsActivation => 'Current period not configured',
      IncomePeriodState.pending => 'Expected later',
      IncomePeriodState.confirmed => 'Confirmed',
      IncomePeriodState.skipped => 'Starts next period',
      IncomePeriodState.cancelled => 'Cancelled',
    };
    final canSetUp = !startsLater && state == IncomePeriodState.needsActivation;
    return SetupSurface(
      key: ValueKey('onboardingActivation-${source.syncGuid}'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.account_balance_wallet_outlined),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(source.name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Text('${formatMinorUnits(source.amount, currency)} · $label',
                    style: Theme.of(context).textTheme.bodySmall),
              ])),
        ]),
        if (startsLater)
          Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                  'Starts in ${_monthLabel(source.startDate ?? DateTime.parse('${widget.month}-01'))}')),
        if (canSetUp) ...[
          const SizedBox(height: 8),
          FilledButton.tonal(
            key: Key('onboardingSourceSetUp-${source.syncGuid}'),
            onPressed: () =>
                openIncomeActivation(context, ref, source, periodKey: period),
            child: const Text('Set up current period'),
          ),
        ],
      ]),
    );
  }

  static String _monthLabel(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';
}
