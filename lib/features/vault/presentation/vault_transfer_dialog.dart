import '../../../shared/presentation/financial_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/services/refund_service.dart' show parseRefundAmount;
import '../../../features/sync/domain/sync_guid.dart';
import '../../../shared/presentation/input_formatters/thousands_separator_input_formatter.dart';
import '../../../shared/presentation/money_format.dart';
import '../models/vault_entry.dart';
import '../providers/vault_providers.dart';
import '../vault_transfer_service.dart';
import '../vault_transfer_ledger.dart';
import 'vault_time.dart';

CurrencyCode currencyForTransfer(String code) => CurrencyCode.tryParse(code)!;

String transferError(Object error) => error is VaultTransferException
    ? error.message
    : 'The transfer could not be verified. No changes were committed. Close and retry.';

class VaultTransferPanel extends ConsumerWidget {
  const VaultTransferPanel({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readiness = ref.watch(vaultTransferReadinessProvider);
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: readiness.when(
              loading: () => const Text('Checking transfer availability...'),
              error: (error, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Transfers unavailable'),
                    Text(transferError(error)),
                    TextButton(
                        onPressed: () =>
                            ref.invalidate(vaultTransferReadinessProvider),
                        child: const Text('Retry transfer check')),
                  ]),
              data: (state) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Transfers for ${state.month}'),
                    Text(
                        'Maximum deposit: ${formatMinorUnits(state.maxDeposit, state.currency)}'),
                    Text(
                        'Maximum withdrawal: ${formatMinorUnits(state.maxWithdrawal, state.currency)}'),
                    if (state.maxDeposit == 0)
                      const Text(
                          'No Free to spend remains after spending, allocations and protected carry.'),
                    if (state.maxWithdrawal == 0)
                      const Text(
                          'No savings can be withdrawn within the supported balance limits.'),
                    const Text(
                        'Moves recorded funds between this month and savings. It does not initiate a bank transfer.'),
                    Wrap(spacing: 12, children: [
                      for (final kind in ['deposit', 'withdrawal'])
                        FilledButton.tonal(
                            onPressed: (kind == 'deposit'
                                        ? state.maxDeposit
                                        : state.maxWithdrawal) <=
                                    0
                                ? null
                                : () => showDialog<void>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) =>
                                        VaultTransferDialog(kind: kind)),
                            child: Text(
                                kind == 'deposit' ? 'Deposit' : 'Withdraw')),
                    ]),
                  ]),
            )));
  }
}

class VaultTransferDialog extends ConsumerStatefulWidget {
  const VaultTransferDialog({super.key, required this.kind, this.original});
  final String kind;
  final VaultEntry? original;
  @override
  ConsumerState<VaultTransferDialog> createState() =>
      _VaultTransferDialogState();
}

class _VaultTransferDialogState extends ConsumerState<VaultTransferDialog> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  final _request = newSyncGuid();
  VaultTransferPreview? _preview;
  VaultTransferService? _service;
  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _review() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final service = ref.read(vaultTransferServiceProvider);
      final state = await service.readiness();
      final amount = widget.original?.amountMinor.abs() ??
          parseRefundAmount(_amount.text, state.currency);
      if (amount == null) {
        throw const VaultTransferException(
            'Enter a positive amount with valid currency precision.');
      }
      final preview = await service.preview(
          kind: widget.kind,
          amount: amount,
          requestId: _request,
          note: _note.text,
          reverses: widget.original?.operationKey);
      if (mounted) {
        setState(() {
          _preview = preview;
          _service = service;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = transferError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirm() async {
    final preview = _preview;
    if (preview == null || _service == null || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _service!.confirm(preview);
      if (mounted) {
        ref.invalidate(vaultTransferReadinessProvider);
        showFinancialFeedback(
            context,
            switch (widget.kind) {
              'deposit' => 'Savings deposited',
              'withdrawal' => 'Savings withdrawn',
              _ => 'Savings transfer reversed',
            });
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        showFinancialFeedback(context, transferError(error),
            kind: FinancialFeedbackKind.error);
        setState(() {
          _error = transferError(error);
          _preview = null;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview;
    final title = widget.kind == 'deposit'
        ? 'Deposit to savings'
        : widget.kind == 'withdrawal'
            ? 'Withdraw from savings'
            : 'Reverse full transfer';
    return PopScope(
        canPop: !_busy,
        child: AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                if (preview == null) ...[
                  if (widget.original == null)
                    TextField(
                        key: const Key('vaultTransferAmount'),
                        controller: _amount,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: const [
                          ThousandsSeparatorInputFormatter()
                        ],
                        enabled: !_busy,
                        decoration: const InputDecoration(labelText: 'Amount')),
                  if (widget.original != null)
                    Text(
                        'Original ${widget.original!.kind}: ${formatMinorUnits(widget.original!.amountMinor.abs(), currencyForTransfer(widget.original!.currency))} on ${formatVaultTime(widget.original!.createdAt)}'),
                  TextField(
                      key: const Key('vaultTransferNote'),
                      controller: _note,
                      enabled: !_busy,
                      maxLength: 120,
                      decoration: InputDecoration(
                          labelText: widget.kind == 'reversal'
                              ? 'Reason (required)'
                              : 'Note (optional)')),
                ] else ...[
                  Text('Personal funds for ${preview.state.month}'),
                  Text(
                      'Savings: ${formatMinorUnits(preview.state.balance, preview.state.currency)} -> ${formatMinorUnits(preview.vaultAfter, preview.state.currency)}'),
                  Text(
                      'Free to spend: ${formatMinorUnits(preview.state.freeFunds, preview.state.currency)} -> ${formatMinorUnits(preview.freeAfter, preview.state.currency)}'),
                  Text(
                      'Monthly bank funds: ${formatMinorUnits(preview.state.bank, preview.state.currency)} -> ${formatMinorUnits(preview.bankAfter, preview.state.currency)}'),
                  Text(
                      'Monthly reserve: ${formatMinorUnits(preview.state.reserve, preview.state.currency)} -> ${formatMinorUnits(preview.reserveAfter, preview.state.currency)}'),
                  if (preview.note.isNotEmpty) Text(preview.note),
                  const Text(
                      'Income, expenses and the original opening balance stay unchanged.'),
                ],
                if (_error != null)
                  Text(_error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
              ])),
          actions: [
            TextButton(
                onPressed: _busy ? null : () => Navigator.pop(context),
                child: const Text('Cancel')),
            if (preview != null)
              TextButton(
                  onPressed:
                      _busy ? null : () => setState(() => _preview = null),
                  child: const Text('Edit')),
            FilledButton(
                onPressed: _busy
                    ? null
                    : preview == null
                        ? _review
                        : _confirm,
                child: Text(_busy
                    ? 'Checking...'
                    : preview == null
                        ? 'Review transfer'
                        : 'Confirm transfer')),
          ],
        ));
  }
}

/// Preserves original records; each linked reversal is a new funded operation.
class VaultTransferHistory extends StatelessWidget {
  const VaultTransferHistory(
      {super.key,
      required this.entry,
      required this.reversed,
      this.reversedOriginal});
  final VaultEntry entry;
  final bool reversed;
  final VaultEntry? reversedOriginal;
  @override
  Widget build(BuildContext context) {
    final data = transferDetails(entry);
    if (data == null) {
      return const ListTile(title: Text('Transfer history needs review'));
    }
    final code = entry.currency;
    final caption = entry.kind == 'deposit'
        ? 'Deposit'
        : entry.kind == 'withdrawal'
            ? 'Withdrawal'
            : 'Reversal';
    // Validated currency is available from the same ledger validator.
    final original = entry;
    return Card(
        child: ExpansionTile(
      title: Text(
          '$caption - ${entry.amountMinor > 0 ? '+' : '-'} ${formatMinorUnits(entry.amountMinor.abs(), currencyForTransfer(code))}'),
      subtitle:
          Text('${entry.yearMonth} - ${formatVaultTime(entry.createdAt)}'),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      childrenPadding: const EdgeInsets.all(16),
      children: [
        if (entry.reason != null) Text(entry.reason!),
        if (data['version'] == 2)
          Text(
              'Free to spend: ${formatMinorUnits(data['freeBefore'] as int, currencyForTransfer(code))} -> ${formatMinorUnits(data['freeAfter'] as int, currencyForTransfer(code))}'),
        Text(
            'Monthly funds: ${formatMinorUnits(data['bankBefore'] as int, currencyForTransfer(code))} -> ${formatMinorUnits(data['bankAfter'] as int, currencyForTransfer(code))}'),
        Text(
            'Vault balance after entry: ${formatMinorUnits(entry.balanceAfterMinor, currencyForTransfer(code))}'),
        if (data['reverses'] != null)
          Text(reversedOriginal == null
              ? 'Linked original transfer needs review'
              : 'Reverses ${reversedOriginal!.kind} of ${formatMinorUnits(reversedOriginal!.amountMinor.abs(), currencyForTransfer(code))} from ${formatVaultTime(reversedOriginal!.createdAt)}'),
        if (reversed) const Text('Reversed - original evidence retained'),
        if (!reversed && entry.kind != 'reversal')
          TextButton(
              onPressed: () => showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => VaultTransferDialog(
                      kind: 'reversal', original: original)),
              child: const Text('Reverse full transfer')),
      ],
    ));
  }
}
