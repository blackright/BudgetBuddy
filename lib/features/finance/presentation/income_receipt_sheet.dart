import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/models/income_source.dart';
import '../../../core/models/salary_cycle.dart';
import '../../../core/services/salary_receipt_service.dart';
import '../../../shared/presentation/input_formatters/thousands_separator_input_formatter.dart';
import '../../../shared/presentation/money_format.dart';
import 'balance_checkpoint_sheet.dart' show parseCheckpointAmount;
import 'receipt_errors.dart';

/// Simple confirmation for a non-salary income receipt.
///
/// Salary keeps its own sheet because it also records a salary period, payslip
/// and corrections. This sheet records only the money that actually arrived.
class IncomeReceiptSheet extends ConsumerStatefulWidget {
  const IncomeReceiptSheet({
    super.key,
    required this.source,
    required this.cycle,
    required this.onConfirm,
    this.isAccessCurrent,
    this.timezone = 'UTC',
    this.now,
  });

  final IncomeSource source;
  final SalaryCycle cycle;
  final Future<void> Function(int amountMinor, DateTime actualDate, String note)
      onConfirm;
  final bool Function()? isAccessCurrent;
  final String timezone;
  final DateTime? now;

  @override
  ConsumerState<IncomeReceiptSheet> createState() => _IncomeReceiptSheetState();
}

class _IncomeReceiptSheetState extends ConsumerState<IncomeReceiptSheet> {
  late final CurrencyCode currency =
      CurrencyCode.tryParse(widget.source.currency) ?? CurrencyCode.huf;
  late final amount = TextEditingController(
      text: formatMinorUnitsInput(widget.cycle.expectedAmountMinor, currency));
  late final note = TextEditingController();
  late DateTime date;
  bool busy = false;
  String? error;
  String? details;

  DateTime get today => widget.now ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    date = today;
  }

  @override
  void dispose() {
    amount.dispose();
    note.dispose();
    super.dispose();
  }

  String get cashMonth {
    try {
      return SalaryReceiptService.cashMonthFor(date, widget.timezone);
    } catch (_) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}';
    }
  }

  String get monthLabel =>
      DateFormat.yMMMM().format(DateTime.parse('$cashMonth-01'));

  int get amountMinor => parseCheckpointAmount(amount.text, currency) ?? 0;

  Future<void> confirm() async {
    if (busy) return;
    final access = widget.isAccessCurrent;
    if (access == null || !access()) {
      setState(() =>
          error = 'Unlock the correct profile and reopen this confirmation.');
      return;
    }
    if (amountMinor <= 0) {
      setState(() => error = 'Enter the amount that actually arrived.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.onConfirm(amountMinor, date, note.text.trim());
      if (mounted && access()) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Nothing was saved. ${receiptErrorMessage(e)}';
          details = receiptErrorDetails(e);
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Confirm income received',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(widget.source.name),
            const SizedBox(height: 12),
            Text(
              'Expected ${formatMinorUnits(widget.cycle.expectedAmountMinor, currency)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('incomeReceiptAmount'),
              controller: amount,
              decoration: InputDecoration(
                labelText: 'Amount received (${currency.code.toUpperCase()})',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: const [ThousandsSeparatorInputFormatter()],
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Received on'),
              subtitle: Text(DateFormat.yMMMMd().format(date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: today,
                  initialDate: date,
                );
                if (picked != null) setState(() => date = picked);
              },
            ),
            Text('Counts in $monthLabel',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            TextField(
              key: const Key('incomeReceiptNote'),
              controller: note,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            if (kDebugMode && details != null)
              Text('Details: $details',
                  style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('incomeReceiptConfirm'),
              onPressed: busy ? null : confirm,
              child: busy
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Confirm received'),
            ),
          ],
        ),
      );
}
