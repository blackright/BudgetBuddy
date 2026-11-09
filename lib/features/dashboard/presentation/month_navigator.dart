import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/selected_month_provider.dart';

class MonthNavigator extends ConsumerWidget {
  const MonthNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yearMonth = ref.watch(selectedYearMonthProvider);
    final isToday = yearMonth == currentYearMonth();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: const Key('previousMonth'),
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            ref.read(selectedYearMonthProvider.notifier).state =
                previousMonth(yearMonth);
          },
          tooltip: 'Previous month',
        ),
        Flexible(
          child: Text(
            monthLabel(yearMonth),
            key: const Key('monthLabel'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        IconButton(
          key: const Key('nextMonth'),
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            ref.read(selectedYearMonthProvider.notifier).state =
                nextMonth(yearMonth);
          },
          tooltip: 'Next month',
        ),
        if (!isToday)
          IconButton(
            key: const Key('todayButton'),
            icon: const Icon(Icons.today, size: 20),
            onPressed: () {
              ref.read(selectedYearMonthProvider.notifier).state = goToToday();
            },
            tooltip: 'Today',
          ),
      ],
    );
  }
}
