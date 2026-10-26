import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/currency_code.dart';
import '../../../../core/models/expense.dart';
import '../../../../core/providers/budget_context_provider.dart';
import '../../../../shared/presentation/money_format.dart';
import '../../providers/daily_cards_provider.dart';

String expenseDayLabel(DateTime date, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  if (date == today) return 'Today';
  final yesterday = DateTime(today.year, today.month, today.day - 1);
  if (date == yesterday) return 'Yesterday';
  return DateFormat.yMMMMEEEEd().format(date);
}

class DailyExpenseCardTile extends StatelessWidget {
  const DailyExpenseCardTile(
      {super.key,
      required this.day,
      required this.expenseBuilder,
      this.detailFootnote});
  final DailyExpenseCard day;
  final Widget Function(Expense) expenseBuilder;
  final Widget? detailFootnote;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), colors = Theme.of(context).colorScheme;
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
        child: Material(
            color: colors.surfaceContainerLow,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: BorderSide(color: colors.outlineVariant)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
                onTap: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    showDragHandle: true,
                    builder: (_) => FractionallySizedBox(
                        heightFactor: .92,
                        child: _DayExpenseModal(
                            date: day.date,
                            expenseBuilder: expenseBuilder,
                            footnote: detailFootnote))),
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: colors.primaryContainer,
                                    borderRadius: BorderRadius.circular(14)),
                                child: Icon(Icons.calendar_today_rounded,
                                    color: colors.onPrimaryContainer,
                                    size: 22)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(
                                      expenseDayLabel(day.date, DateTime.now()),
                                      style: theme.textTheme.titleMedium),
                                  Text(
                                      '${day.expenses.length} expense${day.expenses.length == 1 ? '' : 's'}',
                                      style: theme.textTheme.bodySmall)
                                ])),
                            const Icon(Icons.chevron_right_rounded)
                          ]),
                          const SizedBox(height: 14),
                          Wrap(spacing: 12, runSpacing: 8, children: [
                            for (final currency
                                in {...day.paid.keys, ...day.planned.keys}
                                    .toList()
                                  ..sort())
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 9),
                                  decoration: BoxDecoration(
                                      color: colors.surface,
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(currency,
                                            style: theme.textTheme.labelSmall),
                                        if (day.paid.containsKey(currency))
                                          Text(
                                              day.incompleteCurrencies
                                                      .contains(currency)
                                                  ? '$currency net paid unavailable'
                                                  : 'Net paid  ${_money(day.paid[currency]!, currency)}',
                                              style: theme.textTheme.labelLarge
                                                  ?.copyWith(
                                                      color: colors.primary)),
                                        if (day.planned.containsKey(currency))
                                          Text(
                                              day.incompleteCurrencies
                                                      .contains(currency)
                                                  ? '$currency planned total unavailable'
                                                  : 'Planned  ${_money(day.planned[currency]!, currency)}',
                                              style: theme.textTheme.labelMedium
                                                  ?.copyWith(
                                                      color: colors
                                                          .onSurfaceVariant)),
                                      ])),
                          ]),
                          if (day.incompleteCurrencies.isNotEmpty)
                            const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                    'An amount or refund conversion needs review.')),
                        ])))));
  }

  String _money(int amount, String currency) {
    final code = CurrencyCode.tryParse(currency);
    return code == null
        ? '$currency $amount (minor units)'
        : formatMinorUnits(amount, code);
  }
}

class _DayExpenseModal extends ConsumerStatefulWidget {
  const _DayExpenseModal(
      {required this.date, required this.expenseBuilder, this.footnote});
  final DateTime date;
  final Widget Function(Expense) expenseBuilder;
  final Widget? footnote;
  @override
  ConsumerState<_DayExpenseModal> createState() => _DayExpenseModalState();
}

class _DayExpenseModalState extends ConsumerState<_DayExpenseModal> {
  int page = 0;
  final scroll = ScrollController();
  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  void changePage(int next) {
    setState(() => page = next);
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(budgetContextProvider.select((c) => (c.profileId, c.spaceId)),
        (previous, next) {
      if (previous != next && mounted) Navigator.pop(context);
    });
    final days = ref.watch(dailyCardsProvider);
    return Column(children: [
      Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
          child: Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(expenseDayLabel(widget.date, DateTime.now()),
                      style: Theme.of(context).textTheme.titleLarge),
                  Text(DateFormat.yMMMd().format(widget.date),
                      style: Theme.of(context).textTheme.bodySmall)
                ])),
            IconButton(
                tooltip: 'Close day',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close))
          ])),
      const Divider(height: 1),
      Expanded(
          child: days.when(
              data: (values) {
                final found = values.where((d) => d.date == widget.date);
                final expenses =
                    found.isEmpty ? const <Expense>[] : found.first.expenses;
                final pages = (expenses.length + 19) ~/ 20;
                final current = pages == 0 ? 0 : page.clamp(0, pages - 1);
                return Column(children: [
                  if (widget.footnote != null) widget.footnote!,
                  Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                          '${expenses.length} expenses · Page ${pages == 0 ? 0 : current + 1} of $pages')),
                  Expanded(
                      child: expenses.isEmpty
                          ? const Center(
                              child: Text(
                                  'No matching expenses remain for this day.'))
                          : ListView(
                              controller: scroll,
                              padding: const EdgeInsets.only(bottom: 16),
                              children: [
                                  for (final expense
                                      in expenses.skip(current * 20).take(20))
                                    widget.expenseBuilder(expense)
                                ])),
                  if (expenses.length > 20)
                    SafeArea(
                        top: false,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                  onPressed: current > 0
                                      ? () => changePage(current - 1)
                                      : null,
                                  child: const Text('Previous')),
                              const SizedBox(width: 24),
                              TextButton(
                                  onPressed: current + 1 < pages
                                      ? () => changePage(current + 1)
                                      : null,
                                  child: const Text('Next'))
                            ])),
                ]);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(
                  child: Text(
                      'This day could not be loaded. Close and try again.')))),
    ]);
  }
}
