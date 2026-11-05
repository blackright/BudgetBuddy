import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/medical_bill.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/services/medical_management_reducer.dart';
import '../../../core/services/medical_management_service.dart';
import '../../../shared/presentation/money_format.dart';
import '../providers/medical_providers.dart';
import '../providers/medical_receipt_provider.dart';
import 'medical_money_format.dart' show formatMedicalRecordedMoney;
import 'medical_claim_history_timeline.dart';
import 'medical_management_timeline.dart';
import 'medical_money_row.dart';
import 'medical_management_sheets.dart';
import 'medical_section_card.dart';
import 'medical_theme.dart';
import 'reminder_picker_sheet.dart';

/// The Bill Management detail surface for both payment models.
///
/// Legacy and Needs-review bills keep the legacy screen.
class MedicalManagementDetail extends ConsumerWidget {
  const MedicalManagementDetail({super.key, required this.billId});

  final int billId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billAsync = ref.watch(medicalBillProvider(billId));
    final historyAsync = ref.watch(medicalReceiptHistoryProvider(billId));
    final bill = billAsync.valueOrNull;
    final history = historyAsync.valueOrNull;
    if (bill == null || history == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Medical Bill')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final state = ref.watch(medicalManagementReducerProvider).resolve(bill);
    final statusColor = MedicalTheme.managementStageColor(context, state.stage);
    final statusIcon = MedicalTheme.managementStageIcon(state.stage);
    final code = bill.currencyCode;
    final money = code == null
        ? (int minor) => formatMinorUnitsInput(minor, CurrencyCode.huf)
        : (int minor) => MedicalTheme.moneyMinor(code, minor);
    final approvals = [...history.approvals]
      ..sort((a, b) => a.revision.compareTo(b.revision));
    final latestApproval = approvals.isEmpty ? null : approvals.last;
    final direct = bill.paymentMethod == MedicalPaymentMethod.insurerPaid;
    final shared = bill.sharedSpaceId != null;
    final showLegacyHistory = history.approvals.isNotEmpty ||
        history.returns.isNotEmpty ||
        (history.closure?.shortfallMinor ?? 0) > 0;
    final approvedBillMinor =
        latestApproval?.approvedBillMinor ?? bill.billedAmount;
    final approvedShareMinor =
        latestApproval?.approvedShareMinor ?? bill.patientShareAmount;
    final approvedInsuranceMinor = latestApproval?.approvedInsuranceMinor ??
        latestApproval?.approvedMinor ??
        bill.insurerPaidAmount;
    final actualAmount = bill.settledAmountMinor ?? history.receivedMinor;
    Widget summaryRow(String label, String value) => Padding(
          padding: const EdgeInsets.only(top: 6),
          child: MedicalMoneyRow(label: label, value: value, compact: true),
        );
    String monthLabel(String raw) {
      final parts = raw.split('-');
      if (parts.length != 2) return raw;
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      if (year == null || month == null || month < 1 || month > 12) return raw;
      return DateFormat.yMMMM().format(DateTime(year, month));
    }

    return Scaffold(
      backgroundColor: MedicalTheme.background(context),
      appBar: AppBar(
        title: const Text('Medical Bill'),
        backgroundColor: MedicalTheme.background(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MedicalSectionCard(
              title: 'Status',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: statusColor.withValues(alpha: 0.28)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.16),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(statusIcon, color: statusColor, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CURRENT STATUS',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.9,
                                  color: statusColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state.stageLabel,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: statusColor,
                                ),
                              ),
                              if (bill.lastUpdatedAt != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Updated ${DateFormat.yMMMd().add_jm().format(bill.lastUpdatedAt!.toLocal())}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: MedicalTheme.subtleText(context)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.blockers.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .errorContainer
                            .withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 20,
                              color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final blocker in state.blockers)
                                  Text(
                                    blocker,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onErrorContainer,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  FilledButton(
                    key: const Key('managementPrimaryAction'),
                    style: FilledButton.styleFrom(
                      backgroundColor: statusColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed: () => _runPrimary(context, ref, bill, state),
                    child: Text(state.primaryActionLabel),
                  ),
                  if (state.secondaryActions.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final action in state.secondaryActions)
                          OutlinedButton.icon(
                            key: Key('managementSecondary-${action.name}'),
                            onPressed: () =>
                                _runSecondary(context, ref, bill, action),
                            icon: Icon(_secondaryIcon(action), size: 18),
                            label: Text(_secondaryLabel(action)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: statusColor,
                              side: BorderSide(
                                  color: statusColor.withValues(alpha: 0.45)),
                              minimumSize: const Size(0, 48),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            MedicalSectionCard(
              title: 'Bill summary',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MedicalMoneyRow(
                    label: 'Bill total',
                    value: money(bill.billedAmount),
                    emphasize: true,
                  ),
                  summaryRow(
                    'Your share',
                    '${bill.patientSharePercent.toStringAsFixed(0)}% · ${money(bill.patientShareAmount)}',
                  ),
                  const Divider(height: 24),
                  summaryRow(
                    'Payment',
                    direct
                        ? 'Insurance pays the provider'
                        : 'I paid the provider',
                  ),
                  if (bill.serviceDate != null)
                    summaryRow(
                      'Service date',
                      DateFormat.yMMMd().format(bill.serviceDate!.toLocal()),
                    ),
                  if (bill.insuranceReference != null)
                    summaryRow('Insurance reference', bill.insuranceReference!),
                  if (bill.submissionDate != null)
                    summaryRow(
                      'Submitted',
                      DateFormat.yMMMd().format(bill.submissionDate!.toLocal()),
                    ),
                  if (!shared && bill.expectedSalaryMonth != null)
                    summaryRow(
                      'Expected salary month',
                      monthLabel(bill.expectedSalaryMonth!),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            MedicalSectionCard(
              title: 'Money',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Expected',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  MedicalMoneyRow(
                      label: 'Bill total', value: money(bill.billedAmount)),
                  MedicalMoneyRow(
                      label: 'Your share',
                      value:
                          '${bill.patientSharePercent.toStringAsFixed(0)}% · ${money(bill.patientShareAmount)}'),
                  MedicalMoneyRow(
                    label: direct
                        ? 'Insurance pays provider'
                        : 'Expected insurance refund',
                    value: money(bill.insurerPaidAmount),
                  ),
                  if (latestApproval != null) ...[
                    const Divider(height: 20),
                    const Text('Approved',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    MedicalMoneyRow(
                        label: 'Approved bill',
                        value: money(approvedBillMinor)),
                    MedicalMoneyRow(
                        label: 'Approved your share',
                        value: money(approvedShareMinor)),
                    MedicalMoneyRow(
                        label: direct
                            ? 'Approved insurance payment'
                            : 'Approved refund',
                        value: money(approvedInsuranceMinor)),
                  ],
                  if (actualAmount > 0 ||
                      bill.settledDate != null ||
                      bill.providerPaymentStatus ==
                          MedicalProviderPaymentStatus.refunded) ...[
                    const Divider(height: 20),
                    const Text('Actual',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    if (actualAmount > 0)
                      MedicalMoneyRow(
                          label: direct ? 'Share deducted' : 'Refund received',
                          value: money(actualAmount)),
                    if (!shared && bill.actualSalaryMonth != null)
                      MedicalMoneyRow(
                          label: 'Actual month',
                          value: bill.actualSalaryMonth!),
                    if (bill.providerPaymentStatus ==
                        MedicalProviderPaymentStatus.refunded)
                      const MedicalMoneyRow(
                          label: 'Provider payment', value: 'Refunded to you'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            MedicalSectionCard(
              title: 'Activity',
              child: MedicalManagementTimeline(
                bill: bill,
                history: history,
                money: money,
                showMonths: !shared,
              ),
            ),
            if (showLegacyHistory) ...[
              const SizedBox(height: 12),
              MedicalSectionCard(
                title: 'Earlier recorded history',
                child: MedicalClaimHistoryTimeline(
                  history: history,
                  showHeading: false,
                  includeActivities: false,
                  showMonths: !shared,
                  money: money,
                  moneyWithCurrency: (amount, currency) =>
                      formatMedicalRecordedMoney(amount, currency),
                ),
              ),
            ],
            if ((ref.watch(medicalAppealsProvider(bill.syncGuid)).value ??
                    const [])
                .isNotEmpty) ...[
              const SizedBox(height: 12),
              MedicalSectionCard(
                title: 'Appeals',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final appeal in ref
                        .watch(medicalAppealsProvider(bill.syncGuid))
                        .value!)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '${DateFormat.yMMMd().format(appeal.submittedAt.toLocal())} · '
                          '${appeal.outcome.name}'
                          '${appeal.reference == null ? '' : ' · ${appeal.reference}'}',
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _runPrimary(
    BuildContext context,
    WidgetRef ref,
    MedicalBill bill,
    MedicalManagementState state,
  ) async {
    bool? changed;
    switch (state.primaryAction) {
      case MedicalManagementAction.submitRequest:
        changed = bill.paymentMethod == MedicalPaymentMethod.insurerPaid
            ? await MedicalInsuranceSubmitSheet.show(context, bill)
            : await MedicalSubmitRequestSheet.show(context, bill);
      case MedicalManagementAction.confirmReceipt:
        changed = await MedicalReceiptConfirmationSheet.show(context, bill);
      case MedicalManagementAction.recordDecision:
        changed = await MedicalDecisionSheet.show(context, bill);
      case MedicalManagementAction.reviewApprovedAmounts:
        changed = await MedicalApprovedAmountsSheet.show(context, bill);
      case MedicalManagementAction.resolveRejection:
        changed = await MedicalRejectionSheet.show(context, bill);
      case MedicalManagementAction.recordAppeal:
        changed = await MedicalAppealSheet.show(context, bill);
      case MedicalManagementAction.recordAppealOutcome:
        changed = await MedicalAppealOutcomeSheet.show(context, bill);
      case MedicalManagementAction.cancelRequest:
        changed = await MedicalCancelRequestSheet.show(context, bill);
      case MedicalManagementAction.checkPayslip:
        changed = await MedicalRefundSheet.show(context, bill);
      case MedicalManagementAction.completeCase:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialog) => AlertDialog(
            title: const Text('Confirm case complete?'),
            content: const Text(
                'Insurance approved 100% of the bill. Confirm that the case is complete in the insurer’s own application.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialog, false),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(dialog, true),
                  child: const Text('Case complete')),
            ],
          ),
        );
        if (confirmed == true) {
          try {
            await ref
                .read(medicalManagementServiceProvider)
                .completeAt100Percent(
                  billId: bill.id,
                  operationKey:
                      DateTime.now().microsecondsSinceEpoch.toString(),
                  isAccessCurrent: () => true,
                );
            changed = true;
          } on MedicalManagementException catch (error) {
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(error.message)));
            }
          }
        }
      case MedicalManagementAction.reopenBill:
        changed = await MedicalReopenSheet.show(context, bill);
      case MedicalManagementAction.editBill:
      case MedicalManagementAction.reviewBill:
        if (context.mounted) {
          await context.push('/edit_medical_bill', extra: bill.id);
        }
        changed = true;
      case MedicalManagementAction.viewActivity:
        await _showActivity(context, ref, bill);
      case MedicalManagementAction.setReminder:
        await _setReminder(context, ref, bill);
      case MedicalManagementAction.closeBill:
        final confirmed = await _confirmCloseBill(context, bill, state);
        if (confirmed == true) {
          try {
            await ref.read(medicalManagementServiceProvider).closeBill(
                  billId: bill.id,
                  operationKey:
                      DateTime.now().microsecondsSinceEpoch.toString(),
                  isAccessCurrent: () => true,
                );
            changed = true;
          } on MedicalManagementException catch (error) {
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(error.message)));
            }
          }
        }
      default:
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This step is not available yet.')));
        }
    }
    if (changed == true) {
      ref.invalidate(medicalBillProvider(bill.id));
      ref.invalidate(medicalReceiptHistoryProvider(bill.id));
      ref.invalidate(medicalBillViewBatchProvider);
    }
  }

  Future<bool?> _confirmCloseBill(
    BuildContext context,
    MedicalBill bill,
    MedicalManagementState state,
  ) {
    final currency = bill.currencyCode ?? CurrencyCode.huf;
    String money(int minor) => bill.currencyCode == null
        ? formatMinorUnitsInput(minor, currency)
        : MedicalTheme.moneyMinor(currency, minor);
    final direct = bill.paymentMethod == MedicalPaymentMethod.insurerPaid;
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialog) {
        var acknowledged = false;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            icon: const Icon(Icons.task_alt_outlined),
            title: const Text('Close this bill?'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Closing only marks the bill resolved. It does not move, refund or deduct money.',
                    style: TextStyle(
                        color: MedicalTheme.subtleText(context), fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final entry in [
                          ('Bill total', money(bill.billedAmount)),
                          (
                            'Your share',
                            '${bill.patientSharePercent.toStringAsFixed(0)}% · ${money(bill.patientShareAmount)}'
                          ),
                          (
                            'Payment',
                            direct
                                ? 'Insurance pays the provider'
                                : 'I paid the provider'
                          ),
                          if (bill.serviceDate != null)
                            (
                              'Service date',
                              DateFormat.yMMMd()
                                  .format(bill.serviceDate!.toLocal())
                            ),
                          ('Current status', state.stageLabel),
                        ])
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(entry.$1,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: MedicalTheme.subtleText(
                                              context))),
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    entry.$2,
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    key: const Key('closeBillUnderstand'),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text(
                        'I understand this bill will be marked closed.'),
                    value: acknowledged,
                    onChanged: (value) =>
                        setDialogState(() => acknowledged = value == true),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                key: const Key('closeBillKeepOpen'),
                onPressed: () => Navigator.pop(dialog, false),
                child: const Text('Keep bill open'),
              ),
              FilledButton(
                key: const Key('closeBillConfirm'),
                onPressed:
                    acknowledged ? () => Navigator.pop(dialog, true) : null,
                child: const Text('Yes, close bill'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _runSecondary(
    BuildContext context,
    WidgetRef ref,
    MedicalBill bill,
    MedicalManagementAction action,
  ) async {
    bool? changed;
    switch (action) {
      case MedicalManagementAction.cancelRequest:
        changed = await MedicalCancelRequestSheet.show(context, bill);
      case MedicalManagementAction.recordAppeal:
        changed = await MedicalAppealSheet.show(context, bill);
      case MedicalManagementAction.recordProviderRefund:
        changed = await MedicalProviderRefundSheet.show(context, bill);
      case MedicalManagementAction.correctEvent:
        changed = await MedicalCorrectionSheet.show(context, bill);
      case MedicalManagementAction.reviewBill:
      case MedicalManagementAction.editBill:
        if (context.mounted) {
          await context.push('/edit_medical_bill', extra: bill.id);
        }
        changed = true;
      case MedicalManagementAction.viewActivity:
        await _showActivity(context, ref, bill);
      case MedicalManagementAction.setReminder:
        await _setReminder(context, ref, bill);
      default:
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This step is not available yet.')));
        }
    }
    if (changed == true) {
      ref.invalidate(medicalBillProvider(bill.id));
      ref.invalidate(medicalReceiptHistoryProvider(bill.id));
      ref.invalidate(medicalBillViewBatchProvider);
    }
  }

  Future<void> _setReminder(
      BuildContext context, WidgetRef ref, MedicalBill bill) async {
    final date = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheet) => ReminderPickerSheet(initialDate: bill.followUpDate),
    );
    if (date == null || !context.mounted) return;
    try {
      await ref.read(medicalRepositoryProvider).setFollowUpDate(bill, date);
      ref.invalidate(medicalBillProvider(bill.id));
      ref.invalidate(medicalBillViewBatchProvider);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not save the reminder: $error')));
      }
    }
  }

  Future<void> _showActivity(
      BuildContext context, WidgetRef ref, MedicalBill bill) async {
    final history =
        ref.read(medicalReceiptHistoryProvider(bill.id)).valueOrNull;
    if (history == null) return;
    final code = bill.currencyCode;
    final money = code == null
        ? (int minor) => formatMinorUnitsInput(minor, CurrencyCode.huf)
        : (int minor) => MedicalTheme.moneyMinor(code, minor);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheet) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: MedicalManagementTimeline(
          bill: bill,
          history: history,
          money: money,
          showMonths: bill.sharedSpaceId == null,
        ),
      ),
    );
  }

  String _secondaryLabel(MedicalManagementAction action) => switch (action) {
        MedicalManagementAction.cancelRequest => 'Cancel request',
        MedicalManagementAction.recordAppeal => 'Record appeal',
        MedicalManagementAction.recordProviderRefund => 'Provider refund',
        MedicalManagementAction.correctEvent => 'Correct amount/month',
        MedicalManagementAction.setReminder => 'Set reminder',
        _ => 'More',
      };

  IconData _secondaryIcon(MedicalManagementAction action) => switch (action) {
        MedicalManagementAction.cancelRequest => Icons.cancel_outlined,
        MedicalManagementAction.recordAppeal => Icons.history_edu,
        MedicalManagementAction.recordProviderRefund => Icons.currency_exchange,
        MedicalManagementAction.correctEvent => Icons.edit_note,
        MedicalManagementAction.setReminder => Icons.alarm,
        MedicalManagementAction.editBill => Icons.edit_outlined,
        MedicalManagementAction.viewActivity => Icons.history,
        _ => Icons.more_horiz,
      };
}
