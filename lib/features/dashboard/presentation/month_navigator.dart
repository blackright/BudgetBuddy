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
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            ref.read(selectedYearMonthProvider.notifier).state = previousMonth(yearMonth);
          },
          tooltip: 'Previous Month',
        ),
        Text(
          monthLabel(yearMonth),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            ref.read(selectedYearMonthProvider.notifier).state = nextMonth(yearMonth);
          },
          tooltip: 'Next Month',
        ),
        if (!isToday)
          IconButton(
            icon: const Icon(Icons.today, size: 20),
            onPressed: () {
              ref.read(selectedYearMonthProvider.notifier).state = goToToday();
            },
            tooltip: 'Go to Today',
          ),
      ],
    );
  }
}
