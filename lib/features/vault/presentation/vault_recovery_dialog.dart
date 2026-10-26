import '../../../shared/presentation/financial_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/currency_code.dart';
import '../../../shared/presentation/money_format.dart';
import '../providers/vault_providers.dart';
import '../vault_recovery_service.dart';

class VaultRecoveryDialog extends ConsumerStatefulWidget {
  const VaultRecoveryDialog({super.key});
  @override
  ConsumerState<VaultRecoveryDialog> createState() =>
      _VaultRecoveryDialogState();
}

class _VaultRecoveryDialogState extends ConsumerState<VaultRecoveryDialog> {
  VaultRecoveryPreview? _preview;
  VaultRecoveryService? _service;
  String? _error;
  bool _loading = true, _busy = false;
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      try {
        final service = ref.read(vaultRecoveryServiceProvider);
        final preview = await service.preview();
        if (mounted) {
          setState(() {
            _service = service;
            _preview = preview;
            _loading = false;
          });
        }
      } catch (error) {
        if (mounted) {
          setState(() {
            _error = error is VaultRecoveryException
                ? error.message
                : 'Recovery could not be verified. No data was changed.';
            _loading = false;
          });
        }
      }
    });
  }

  Future<void> _confirm() async {
    if (_preview == null || _service == null || _busy) return;
    setState(() => _busy = true);
    try {
      await _service!.confirm(_preview!);
      if (mounted) {
        showFinancialFeedback(context, 'Savings recovery confirmed');
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        showFinancialFeedback(context,
            'Recovery could not finish. Review the details before retrying.',
            kind: FinancialFeedbackKind.error);
        setState(() {
          _busy = false;
          _preview = null;
          _error = error is VaultRecoveryException
              ? error.message
              : 'Recovery failed. No changes were committed. Close and retry.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: const Text('Review balance recovery'),
        content: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              if (_loading) const Text('Checking the original records…'),
              if (_error != null) Text(_error!),
              if (_preview != null) ...[
                Text('Personal profile ${_preview!.profileId}'),
                Text(
                    'Recorded completed months: ${_preview!.months.join(', ')}'),
                const Text(
                    'Each has confirmed opening funds of zero and no recorded expenses, returns, budget profiles or Month-End carry. Current/future months and shared money are excluded.'),
                const SizedBox(height: 12),
                Text(
                    'Verified replacement: ${formatMinorUnits(0, CurrencyCode.huf)}'),
                const Text(
                    'Confirming corrects only the invalid vault balance and opening-history amount. Their original values are retained as evidence. Monthly funds, expenses and shared money are unchanged.'),
              ],
            ])),
        actions: [
          TextButton(
              onPressed: _busy ? null : () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: _busy || _preview == null ? null : _confirm,
              child: Text(_busy ? 'Recovering…' : 'Confirm recovery to Ft 0')),
        ],
      ));
}
