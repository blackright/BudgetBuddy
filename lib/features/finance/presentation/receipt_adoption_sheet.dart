import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/services/financial_adoption_service.dart';
import '../../../core/services/receipt_snapshot_repository.dart';
import '../../../features/sync/domain/sync_guid.dart';
import '../../../shared/presentation/money_format.dart';

/// The host supplies authenticated, context-bound commands. No direct database
/// access or money writes in this sheet. Leaving does not confirm the review.
class ReceiptAdoptionSheet extends StatefulWidget {
  const ReceiptAdoptionSheet(
      {super.key, required this.load, required this.save});
  final Future<AdoptionPreview> Function() load;
  final Future<void> Function(AdoptionPreview, String) save;

  @override
  State<ReceiptAdoptionSheet> createState() => _ReceiptAdoptionSheetState();
}

class _ReceiptAdoptionSheetState extends State<ReceiptAdoptionSheet> {
  AdoptionPreview? _preview;
  String? _error;
  bool _loading = true, _saving = false, _acknowledged = false, _saved = false;
  // Retain the operation identity after an uncertain failure; Retry cannot
  // accidentally create a second review if the first transaction committed.
  String _operationKey = newSyncGuid();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _preview = null;
      _acknowledged = false;
    });
    try {
      final result = await widget.load();
      if (!mounted) return;
      setState(() {
        _preview = result;
        _loading = false;
        _operationKey = newSyncGuid();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _message(e);
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final preview = _preview;
    if (_saving || preview == null || !preview.canConfirm || !_acknowledged) {
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.save(preview, _operationKey);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saved = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = _message(e);
      });
    }
  }

  static String _message(Object error) {
    if (error is ReceiptGuardException) return blockerMessage(error.code);
    return 'The review could not be saved or loaded. Your money was not changed. Please retry.';
  }

  static String blockerMessage(String code) => switch (code) {
        'missingMonth' =>
          'This month needs its financial setup before you can review it.',
        'missingOpeningReview' =>
          'Confirm this month\'s opening balance first. Zero is allowed.',
        'sealedMonth' =>
          'This month is closed. Choose an open month using the month selector.',
        'settledMonth' ||
        'settlementNeedsReview' =>
          'Month-End has already processed this month or needs review. Choose an eligible month.',
        'sweptMonth' =>
          'Savings have already been processed for this month. Choose an unswept month.',
        'ownerRequired' => 'Only the budget owner can review the start month.',
        'differentStartMonth' =>
          'A different start month has already been reviewed. Changing that boundary needs a separate review.',
        'alreadyActivated' =>
          'These rules are already active. Their start month cannot be changed here.',
        'foreignIncomeNeedsReview' =>
          'An income source uses another currency. Review it before preparing this transition.',
        'invalidMoney' ||
        'invalidIncomeSource' =>
          'Some financial information needs correction. Check the opening balance and Income Sources.',
        'ambiguousIncomeOwner' =>
          'An income source has an unclear owner. Resolve its assignment before preparing this transition.',
        'stalePreview' ||
        'duplicateMismatch' =>
          'Information changed since this preview. Refresh the review before confirming.',
        'accessChanged' ||
        'wrongOwner' ||
        'notActiveMember' ||
        'writeNotPermitted' =>
          'Your profile, access or unlock status changed. Close this review and reopen it in the correct budget.',
        _ =>
          'This review is not ready. Check the selected month and your access, then retry.',
      };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final p = _preview;
    String amount(int? value) => value == null || p == null
        ? 'Needs review'
        : '${p.source.currency.code.toUpperCase()} ${formatMinorUnitsInput(value, p.source.currency)}';
    return PopScope(
      canPop: !_saving,
      child: SafeArea(
          child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, 24 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                          color: colors.outlineVariant,
                          borderRadius: BorderRadius.circular(4)))),
              Row(children: [
                Icon(Icons.fact_check_outlined, color: colors.primary),
                const SizedBox(width: 12),
                Expanded(
                    child: Text('Review receipt setup',
                        style: Theme.of(context).textTheme.titleLarge))
              ]),
              const SizedBox(height: 12),
              const Text(
                  'Prepare a safe starting point for actual payments. Your existing records and money stay unchanged.'),
              if (_loading)
                const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator())),
              if (p != null) ...[
                const SizedBox(height: 16),
                Card(
                    color: colors.primaryContainer,
                    margin: EdgeInsets.zero,
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.ownerName,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                  'Start month: ${DateFormat.yMMMM().format(DateTime.parse('${p.source.context.yearMonth}-01'))}'),
                              const SizedBox(height: 8),
                              const Text('New financial rules: not active yet'),
                            ]))),
                const SizedBox(height: 12),
                _value('Current recorded income', amount(p.currentIncomeMinor)),
                _value('After this review', amount(p.currentIncomeMinor)),
                const Text(
                    'No income is confirmed as received by this review.'),
                ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text('How current income is selected'),
                    children: [
                      _value(
                          'Monthly override',
                          p.overrideMinor == null
                              ? 'Not set'
                              : amount(p.overrideMinor)),
                      _value('Income Sources for this month',
                          amount(p.sourcesMinor)),
                      _value('Fallback default', amount(p.defaultIncomeMinor)),
                      const Text(
                          'The current app uses the override when set; otherwise Income Sources when positive, then the default. This review changes none of them.'),
                      const SizedBox(height: 8),
                      Text(
                          '${p.sourceLabels.length} income source(s) reviewed.'),
                      const SizedBox(height: 8),
                    ]),
                for (final blocker in p.blockers)
                  _notice(blockerMessage(blocker), colors.errorContainer),
                if (p.canConfirm && !_saved)
                  CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                          'I reviewed this start month and the existing funding settings.'),
                      value: _acknowledged,
                      onChanged: _saving
                          ? null
                          : (v) => setState(() => _acknowledged = v ?? false)),
              ],
              if (_error != null)
                Semantics(
                    liveRegion: true,
                    child: _notice(_error!, colors.errorContainer)),
              if (_saved)
                Semantics(
                    liveRegion: true,
                    child: _notice(
                        'Review saved on this device. Money is unchanged. New financial rules remain inactive.',
                        colors.secondaryContainer)),
              const SizedBox(height: 12),
              if (!_saved && p != null)
                FilledButton.icon(
                    onPressed: !_saving && p.canConfirm && _acknowledged
                        ? _save
                        : null,
                    icon: Icon(_saving
                        ? Icons.hourglass_top
                        : Icons.check_circle_outline),
                    label:
                        Text(_saving ? 'Saving review...' : 'Confirm review')),
              if (!_saved && !_loading)
                TextButton(
                    onPressed: _saving ? null : _load,
                    child: const Text('Refresh review')),
              TextButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  child: Text(_saved ? 'Done' : 'Close')),
            ]),
      )),
    );
  }

  Widget _value(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Wrap(
          spacing: 12,
          runSpacing: 4,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600))
          ]));

  Widget _notice(String text, Color color) => Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(text));
}
