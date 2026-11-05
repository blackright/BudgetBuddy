import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/models/income_source.dart';
import '../../../shared/presentation/money_format.dart';

enum IncomeActivationChoice {
  alreadyReceived,
  expectLater,
  startNext,
}

/// The one shared prompt shown after an income source is created.
///
/// It only collects the user's choice. The caller owns persistence and money
/// effects so onboarding and normal Income Sources can use the same sheet.
class IncomeActivationSheet extends StatelessWidget {
  const IncomeActivationSheet({
    super.key,
    required this.source,
    required this.periodKey,
    required this.onChoice,
    required this.onClose,
    this.startsInFuture = false,
    this.expectedDate,
  });

  final IncomeSource source;
  final String periodKey;
  final ValueChanged<IncomeActivationChoice> onChoice;
  final VoidCallback onClose;
  final bool startsInFuture;

  /// The usual receipt date for the current period, when known.
  final DateTime? expectedDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = CurrencyCode.tryParse(source.currency) ?? CurrencyCode.huf;
    final amount = formatMinorUnits(source.amount, currency);
    final period = DateFormat.yMMMM().format(DateTime.parse('$periodKey-01'));
    final starts = startsInFuture && source.startDate != null
        ? DateFormat.yMMMM().format(source.startDate!)
        : period;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('What about your income for the current period?',
                style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              '${source.name} · $amount · ${startsInFuture ? 'starts $starts' : period}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Creating an income source does not add money. Choose what should happen to this period.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            if (startsInFuture) ...[
              Text('This income starts in $starts.',
                  style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('incomeActivationCloseFuture'),
                onPressed: onClose,
                child: const Text('Close'),
              ),
            ] else ...[
              _choice(
                context,
                key: const Key('incomeActivationAlreadyReceived'),
                icon: Icons.check_circle_outline,
                title: 'I already received it',
                subtitle: 'Confirm the amount that reached your bank.',
                choice: IncomeActivationChoice.alreadyReceived,
              ),
              const SizedBox(height: 8),
              _choice(
                context,
                key: const Key('incomeActivationExpectLater'),
                icon: Icons.schedule,
                title: 'I expect it later',
                subtitle: expectedDate == null
                    ? 'Keep the amount expected and remind you later.'
                    : 'Expected on ${DateFormat.yMMMd().format(expectedDate!)}. We will remind you.',
                choice: IncomeActivationChoice.expectLater,
              ),
              const SizedBox(height: 8),
              _choice(
                context,
                key: const Key('incomeActivationStartNext'),
                icon: Icons.skip_next,
                title: 'Start from the next period',
                subtitle: 'Skip this period and begin with the next one.',
                choice: IncomeActivationChoice.startNext,
              ),
              const SizedBox(height: 16),
              TextButton(
                key: const Key('incomeActivationNotNow'),
                onPressed: onClose,
                child: const Text('Not now'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _choice(
    BuildContext context, {
    required Key key,
    required IconData icon,
    required String title,
    required String subtitle,
    required IncomeActivationChoice choice,
  }) =>
      Card(
        key: key,
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => onChoice(choice),
        ),
      );
}
