import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/medical_bill.dart';
import '../../../core/models/medical_settlement_event.dart';
import '../../../core/services/medical_receipt_service.dart';
import 'medical_theme.dart';

/// Chronological history for the new management workflow.
///
/// It renders the new activity kinds, amounts, affected months, documents and
/// correction markers. Legacy screens keep using the legacy timeline.
class MedicalManagementTimeline extends StatelessWidget {
  const MedicalManagementTimeline({
    super.key,
    required this.bill,
    required this.history,
    required this.money,
    this.showMonths = true,
  });

  final MedicalBill bill;
  final MedicalReceiptHistory history;
  final String Function(int) money;
  final bool showMonths;

  String _title(String kind) => switch (kind) {
        'submitted' => 'Request submitted',
        'receiptPending' => 'Waiting for insurance receipt',
        'receiptConfirmed' => 'Insurance received request',
        'approved' => 'Approved',
        'rejected' => 'Rejected',
        'requestCancelled' => 'Request cancelled',
        'refundReceived' => 'Refund received',
        'refundNotReceived' => 'Refund not received',
        'deductionConfirmed' => 'Salary deduction confirmed',
        'deductionNotShown' => 'Deduction not shown',
        'caseComplete' => 'Case complete',
        'appealSubmitted' => 'Appeal submitted',
        'appealDecided' => 'Appeal decided',
        'rejectionAccepted' => 'Rejection accepted',
        'rejectionResolved' => 'Rejection resolved',
        'providerRefund' => 'Provider refund',
        'reopened' => 'Bill reopened',
        'closed' => 'Bill closed',
        'correction' => 'Correction',
        'created' => 'Bill created',
        _ => kind,
      };

  @override
  Widget build(BuildContext context) {
    final entries = <_Entry>[
      for (final activity in history.activities)
        _Entry(
          date: activity.recordedAt,
          title: _title(activity.kind),
          detail: [
            if (activity.afterMinor > 0) money(activity.afterMinor),
            if (showMonths && activity.transactionMonth != null)
              'Month ${activity.transactionMonth}',
            if (activity.reason.isNotEmpty) activity.reason,
            if (activity.reference != null) 'Ref ${activity.reference}',
            if (activity.documentPaths.isNotEmpty)
              '${activity.documentPaths.length} document(s)',
          ].join(' · '),
          corrected: activity.correctedByGuid != null,
          marker: activity.correctedByGuid != null ? 'corrected' : null,
        ),
      for (final settlement in history.settlements)
        if (settlement.kind == MedicalSettlementKind.correction ||
            settlement.kind == MedicalSettlementKind.reversal)
          _Entry(
            date: settlement.recordedAt,
            title: settlement.kind == MedicalSettlementKind.reversal
                ? 'Reversal'
                : 'Corrected event',
            detail: [
              if (settlement.amountMinor > 0) money(settlement.amountMinor),
              if (showMonths && settlement.transactionMonth != null)
                'Month ${settlement.transactionMonth}',
              if (settlement.reason.isNotEmpty) settlement.reason,
            ].join(' · '),
            corrected: true,
            marker: settlement.kind == MedicalSettlementKind.reversal
                ? 'reversed'
                : 'corrected',
          ),
      if (history.closure != null)
        _Entry(
          date: history.closure!.recordedAt,
          title: 'Bill closed',
          detail: history.closure!.reason,
        ),
    ]..sort((a, b) => a.date.compareTo(b.date));

    if (entries.isEmpty) {
      return const Text('No activity yet.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(entry.corrected ? Icons.edit_note : Icons.history,
                    size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.title,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      if (entry.marker != null)
                        Text(
                          entry.marker!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: MedicalTheme.subtleText(context),
                          ),
                        ),
                      Text(
                        '${DateFormat.yMMMd().add_jm().format(entry.date.toLocal())}'
                        '${entry.detail.isEmpty ? '' : ' · ${entry.detail}'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Entry {
  _Entry({
    required this.date,
    required this.title,
    required this.detail,
    this.corrected = false,
    this.marker,
  });

  final DateTime date;
  final String title;
  final String detail;
  final bool corrected;
  final String? marker;
}
