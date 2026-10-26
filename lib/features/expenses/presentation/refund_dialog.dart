import '../../../shared/presentation/financial_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/services/refund_service.dart';
import '../../sync/domain/sync_guid.dart';
import '../../../shared/presentation/money_format.dart';
import '../../../shared/presentation/widgets/money_field.dart';
import '../providers/refund_provider.dart';

/// Amounts are entered in the original expense currency. The preview is in the
/// owning context's currency, which is stated explicitly beside the figures.
class RefundDialog extends ConsumerStatefulWidget {
  const RefundDialog({super.key, required this.expenseId});
  final int expenseId;
  @override
  ConsumerState<RefundDialog> createState() => _RefundDialogState();
}

class _RefundDialogState extends ConsumerState<RefundDialog> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  bool _saving = false;
  String? _error, _operationId, _payload;
  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  String _input(int amount, CurrencyCode currency) {
    final factor = currency.minorUnitsPerMajor;
    return currency.exponent == 0
        ? '$amount'
        : '${amount ~/ factor}.${(amount % factor).toString().padLeft(currency.exponent, '0')}';
  }

  Future<void> _save(RefundQuote quote) async {
    if (_saving) return;
    final amount = parseRefundAmount(_amount.text, quote.currency);
    if (amount == null) {
      setState(() => _error =
          'Enter a positive amount with the currency’s exact precision.');
      return;
    }
    try {
      quote.impactFor(amount);
    } on RefundException catch (e) {
      setState(() => _error = e.message);
      return;
    }
    final note = _note.text.trim();
    final payload = '$amount\u0000$note';
    if (_payload != payload) {
      _operationId = newSyncGuid();
      _payload = payload;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(refundServiceProvider).record(
          expenseId: widget.expenseId,
          amount: amount,
          operationId: _operationId!,
          note: note);
      if (mounted) {
        showFinancialFeedback(context, 'Refund recorded');
        Navigator.of(context).pop(true);
      }
    } on RefundException catch (e) {
      if (mounted) {
        setState(() => _error = e.message);
        showFinancialFeedback(context, e.message,
            kind: FinancialFeedbackKind.error);
      }
    } catch (_) {
      if (mounted) {
        showFinancialFeedback(
            context, 'Refund could not be saved. Please retry.',
            kind: FinancialFeedbackKind.error);
        setState(() => _error =
            'Refund could not be saved. Retry this submission; it will not be counted twice.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(refundQuoteProvider(widget.expenseId));
    final quote = state.valueOrNull;
    RefundImpact? impact;
    String? inputError;
    if (quote != null && _amount.text.isNotEmpty) {
      final amount = parseRefundAmount(_amount.text, quote.currency);
      if (amount == null) {
        inputError =
            'Enter a positive amount with the currency’s exact precision.';
      } else {
        try {
          impact = quote.impactFor(amount);
        } on RefundException catch (e) {
          inputError = e.message;
        }
      }
    }
    return PopScope(
        canPop: !_saving,
        child: AlertDialog(
          title: const Text('Record refund'),
          content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                  child: state.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(e is RefundException
                    ? e.message
                    : 'Refund information could not be loaded.'),
                data: (q) => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Still refundable: ${formatMinorUnits(q.remainingMinor, q.currency)}'),
                      const SizedBox(height: 12),
                      MoneyField(
                          key: const Key('refundAmount'),
                          controller: _amount,
                          label:
                              'Refund amount (${q.currency.code.toUpperCase()})',
                          enabled: !_saving,
                          fractionDigits: q.currency.exponent,
                          onChanged: (_) => setState(() => _error = null)),
                      TextButton(
                          onPressed: _saving || q.remainingMinor == 0
                              ? null
                              : () {
                                  setState(() {
                                    _amount.text =
                                        _input(q.remainingMinor, q.currency);
                                    _error = null;
                                  });
                                },
                          child: const Text('Refund remaining amount')),
                      TextField(
                          key: const Key('refundNote'),
                          controller: _note,
                          enabled: !_saving,
                          maxLength: 500,
                          decoration: const InputDecoration(
                              labelText: 'Note (optional)')),
                      if (inputError != null)
                        Text(inputError,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error)),
                      if (impact != null) ...[
                        const Divider(),
                        Text(
                            'Refund impact (${q.contextCurrency.code.toUpperCase()})',
                            style: Theme.of(context).textTheme.titleSmall),
                        Text(
                            'Net spending: ${formatMinorUnits(impact.spentBefore, q.contextCurrency)} → ${formatMinorUnits(impact.spentAfter, q.contextCurrency)}'),
                        Text(
                            'Deficit reduced by ${formatMinorUnits(impact.deficitReduction, q.contextCurrency)}'),
                        Text(
                            'Borrowing reduced by ${formatMinorUnits(impact.borrowingReduction, q.contextCurrency)}'),
                        Text(
                            'Restored within budget/reserve: ${formatMinorUnits(impact.spendingReduction, q.contextCurrency)}'),
                      ],
                      if (_error != null)
                        Text(_error!,
                            key: const Key('refundError'),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error)),
                    ]),
              ))),
          actions: [
            TextButton(
                onPressed:
                    _saving ? null : () => Navigator.of(context).pop(false),
                child: const Text('Cancel')),
            FilledButton(
                key: const Key('confirmRefund'),
                onPressed: _saving || quote == null || impact == null
                    ? null
                    : () => _save(quote),
                child: Text(_saving ? 'Saving…' : 'Confirm refund')),
          ],
        ));
  }
}
