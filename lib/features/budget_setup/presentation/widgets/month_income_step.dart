import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/income_source.dart';
import '../../../../shared/presentation/money_format.dart';
import '../../domain/onboarding_state.dart';
import '../../domain/onboarding_finance.dart';
import '../../providers/budget_setup_provider.dart';
import 'setup_form_components.dart';

class MonthIncomeStep extends StatelessWidget {
  const MonthIncomeStep(
      {super.key, required this.view, required this.controller});
  final FinancialSetupView view;
  final FinancialSetupController controller;
  Future<DateTime?> _pick(BuildContext context, DateTime initial) =>
      showDatePicker(
          context: context,
          initialDate: initial.isBefore(DateTime(2000))
              ? DateTime(2000)
              : initial.isAfter(DateTime(2100))
                  ? DateTime(2100)
                  : initial,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100));
  @override
  Widget build(BuildContext context) {
    final d = view.draft;
    final currency = d.profile.currency!;
    final month = DateTime.parse('${d.yearMonth}-01');
    OnboardingReview? preview;
    try {
      preview = OnboardingFinance.review(d);
    } on OnboardingFinanceException {
      /* Missing inputs are shown below, not as invented zero totals. */
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Your first month',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      const Text('Start with what you have. Then add what you earn.'),
      const SizedBox(height: 24),
      SetupSurface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('MONTH',
            style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        SetupValidationTarget(
            error: view.errors['month'],
            child: OutlinedButton.icon(
                key: const Key('financialMonth'),
                icon: const Icon(Icons.calendar_month_rounded),
                label: Text(DateFormat.yMMMM().format(month)),
                onPressed: () async {
                  final date = await _pick(context, month);
                  if (date != null) {
                    controller.setMonth(
                        '${date.year}-${date.month.toString().padLeft(2, '0')}');
                  }
                })),
        if (view.errors['month'] != null)
          Text(view.errors['month']!,
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
        const SizedBox(height: 18),
        Text('Opening money',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text(
            'Your balance at the start of this month. Keep this separate from the income you enter below.'),
        const SizedBox(height: 12),
        SetupValidationTarget(
            error: d.opening.choice == OnboardingOpeningChoice.known
                ? null
                : view.errors['opening'],
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              ChoiceChip(
                  label: const Text('I know the balance'),
                  selected: d.opening.choice == OnboardingOpeningChoice.known,
                  onSelected: (_) =>
                      controller.setOpening(OnboardingOpeningChoice.known)),
              ChoiceChip(
                  label: const Text('I do not know yet'),
                  selected: d.opening.choice == OnboardingOpeningChoice.unknown,
                  onSelected: (_) =>
                      controller.setOpening(OnboardingOpeningChoice.unknown))
            ])),
        const SizedBox(height: 16),
        if (d.opening.choice == OnboardingOpeningChoice.known)
          SetupInput(
              key: const Key('openingAmount'),
              label: 'Opening balance',
              text: d.opening.amountText,
              currency: currency,
              onChanged: (text) => controller
                  .setOpening(OnboardingOpeningChoice.known, amountText: text),
              error: view.errors['opening'],
              helper: '0 is a confirmed zero balance.'),
        if (d.opening.choice == OnboardingOpeningChoice.unknown)
          const Text(
              'We will keep the bank balance unconfirmed until you know it.'),
        if (d.opening.choice != OnboardingOpeningChoice.known &&
            view.errors['opening'] != null)
          Text(view.errors['opening']!,
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ])),
      Text('Set up your income',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      const Text(
          'These become real income sources. Each card shows what applies to your selected month.'),
      const SizedBox(height: 16),
      if (preview != null)
        SetupSurface(
            highlight: true,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Income for this month'),
              const SizedBox(height: 6),
              Text(formatMinorUnits(preview.incomeMinor, currency),
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              Text(currency.name.toUpperCase())
            ])),
      for (final source in d.sources) _source(context, source, preview),
      if (view.errors['income'] != null)
        Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(view.errors['income']!,
                style: TextStyle(color: Theme.of(context).colorScheme.error))),
      if (d.incomeChoice == OnboardingIncomeChoice.none)
        const SetupSurface(
            highlight: true,
            child: Text(
                'No income yet. No placeholder source or salary will be created.')),
      SetupValidationTarget(
          error: view.errors['income'],
          child: Wrap(spacing: 10, runSpacing: 10, children: [
            FilledButton.tonalIcon(
                key: const Key('addIncomeSource'),
                onPressed: controller.addSource,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add income source')),
            OutlinedButton(
                key: const Key('noIncomeYet'),
                onPressed: () async {
                  if (controller.chooseNoIncome()) return;
                  final yes = await confirmDraftRemoval(context,
                      title: 'Choose No income yet?',
                      message:
                          'This removes the ${d.sources.length} income source drafts you entered. Nothing has been saved as income yet.');
                  if (yes) {
                    controller.chooseNoIncome(discardSourcesConfirmed: true);
                  }
                },
                child: const Text('No income yet'))
          ])),
      const SizedBox(height: 16),
      if (view.errors['totals'] != null)
        Text(view.errors['totals']!,
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
    ]);
  }

  Widget _source(BuildContext context, OnboardingSourceDraft source,
      OnboardingReview? preview) {
    final expanded = view.expandedSourceGuid == source.sourceGuid;
    final key = 'source:${source.sourceGuid}';
    final line = preview?.contributions
        .where((c) => c.sourceGuid == source.sourceGuid)
        .firstOrNull;
    final month = DateTime.parse('${view.draft.yearMonth}-01');
    return SetupSurface(
        key: ValueKey(source.sourceGuid),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Semantics(
              button: true,
              expanded: expanded,
              label:
                  '${source.name.isEmpty ? "New" : source.name} income source',
              child: InkWell(
                  key: Key('sourceCard-${source.sourceGuid}'),
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => controller.toggleSource(source.sourceGuid),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(children: [
                        const Icon(Icons.account_balance_wallet_outlined),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(
                                  source.name.isEmpty
                                      ? 'New income source'
                                      : source.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              Text(line == null
                                  ? 'Not yet reviewed'
                                  : formatMinorUnits(
                                      line.minor, view.draft.profile.currency!))
                            ])),
                        Icon(expanded ? Icons.expand_less : Icons.expand_more)
                      ])))),
          if (line != null)
            Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(line.explanation)),
          if (expanded) ...[
            const SizedBox(height: 18),
            SetupInput(
                key: Key('sourceName-${source.sourceGuid}'),
                label: 'Source name',
                text: source.name,
                onChanged: (v) =>
                    controller.updateSource(source.sourceGuid, name: v),
                error: view.errors['$key:name']),
            const SizedBox(height: 16),
            SetupInput(
                key: Key('sourceAmount-${source.sourceGuid}'),
                label: 'Amount per occurrence',
                text: source.amountText,
                currency: view.draft.profile.currency,
                onChanged: (v) =>
                    controller.updateSource(source.sourceGuid, amountText: v),
                error: view.errors['$key:amount']),
            const SizedBox(height: 16),
            DropdownButtonFormField<IncomeSourceType>(
                isExpanded: true,
                itemHeight: null,
                initialValue: source.type,
                decoration: const InputDecoration(
                    labelText: 'Income type', border: OutlineInputBorder()),
                items: IncomeSourceType.values
                    .map((v) =>
                        DropdownMenuItem(value: v, child: Text(_type(v))))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    controller.updateSource(source.sourceGuid, type: v);
                  }
                }),
            const SizedBox(height: 16),
            DropdownButtonFormField<IncomeFrequency>(
                isExpanded: true,
                itemHeight: null,
                initialValue: source.frequency,
                decoration: const InputDecoration(
                    labelText: 'Frequency', border: OutlineInputBorder()),
                items: IncomeFrequency.values
                    .map((v) =>
                        DropdownMenuItem(value: v, child: Text(_frequency(v))))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    controller.updateSource(source.sourceGuid, frequency: v);
                  }
                }),
            const SizedBox(height: 12),
            if (source.frequency == IncomeFrequency.weekly)
              const Text(
                  'Weekly income uses the existing four occurrences per month.'),
            SetupValidationTarget(
                error: view.errors['$key:dates'],
                child: Wrap(spacing: 8, runSpacing: 8, children: [
                  OutlinedButton.icon(
                      icon: const Icon(Icons.event),
                      label: Text(source.startDate == null
                          ? 'Choose start date'
                          : 'Starts ${DateFormat.yMMMd().format(source.startDate!)}'),
                      onPressed: () async {
                        final date =
                            await _pick(context, source.startDate ?? month);
                        if (date != null) {
                          controller.updateSource(source.sourceGuid,
                              startDate: date);
                        }
                      }),
                  OutlinedButton.icon(
                      icon: const Icon(Icons.event_available),
                      label: Text(source.endDate == null
                          ? 'No end date'
                          : 'Ends ${DateFormat.yMMMd().format(source.endDate!)}'),
                      onPressed: () async {
                        final date = await _pick(context,
                            source.endDate ?? source.startDate ?? month);
                        if (date != null) {
                          controller.updateSource(source.sourceGuid,
                              endDate: date);
                        }
                      }),
                  if (source.endDate != null)
                    IconButton(
                        tooltip: 'Clear end date',
                        onPressed: () => controller
                            .updateSource(source.sourceGuid, clearEnd: true),
                        icon: const Icon(Icons.close))
                ])),
            if (view.errors['$key:dates'] != null)
              Text(view.errors['$key:dates']!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 12),
            SetupInput(
                key: Key('sourceNotes-${source.sourceGuid}'),
                label: 'Notes (optional)',
                text: source.notes ?? '',
                notes: true,
                onChanged: (v) =>
                    controller.updateSource(source.sourceGuid, notes: v)),
            const SizedBox(height: 8),
            TextButton.icon(
                onPressed: () => controller.removeSource(source.sourceGuid),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove source')),
          ] else if (view.errors.keys.any((k) => k.startsWith(key)))
            Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                    'Open this card to complete or correct its details.',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error))),
        ]));
  }

  static String _frequency(IncomeFrequency value) => const {
        IncomeFrequency.oneTime: 'One time',
        IncomeFrequency.weekly: 'Weekly',
        IncomeFrequency.monthly: 'Monthly',
        IncomeFrequency.quarterly: 'Quarterly',
        IncomeFrequency.yearly: 'Yearly'
      }[value]!;
  static String _type(IncomeSourceType value) => const {
        IncomeSourceType.salary: 'Salary',
        IncomeSourceType.freelance: 'Freelance',
        IncomeSourceType.bonus: 'Bonus',
        IncomeSourceType.rental: 'Rental',
        IncomeSourceType.investment: 'Investment',
        IncomeSourceType.cashDeposit: 'Cash deposit',
        IncomeSourceType.other: 'Other'
      }[value]!;
}
