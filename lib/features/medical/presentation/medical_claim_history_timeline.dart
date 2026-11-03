import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/services/medical_receipt_booking_service.dart';
import '../../../core/services/medical_receipt_service.dart';

/// Visual claim history timeline (UX #10, Phase 2d).
///
/// Pure presentation: vertical timeline with colour-coded events.
class MedicalClaimHistoryTimeline extends StatelessWidget {
  const MedicalClaimHistoryTimeline({
    super.key,
    required this.history,
    required this.money,
    this.moneyWithCurrency,
    this.showHeading = true,
    this.includeActivities = true,
    this.showMonths = true,
  });

  final MedicalReceiptHistory history;
  final String Function(int) money;
  final String Function(int, String)? moneyWithCurrency;
  final bool showHeading;

  /// The management detail shows new activity separately and uses this widget
  /// only for earlier approval/refund/closure records.
  final bool includeActivities;

  /// Shared bills hide salary-month evidence from other space members.
  final bool showMonths;

  String _recorded(int amount, String currency) =>
      moneyWithCurrency?.call(amount, currency) ?? money(amount);

  @override
  Widget build(BuildContext context) {
    final events = <_TimelineEvent>[];
    for (final a in history.activities) {
      if (!includeActivities) break;
      // Their richer decision/closure records are rendered once below.
      if (a.kind == 'closed' || a.kind == 'noRefundDecision') continue;
      events.add(_TimelineEvent(
        date: a.submittedAt ?? a.recordedAt,
        icon: a.kind == 'submitted' ? Icons.outgoing_mail : Icons.history,
        color: Colors.blue,
        title: switch (a.kind) {
          'submitted' => 'Submitted to insurer',
          'cancelled' => 'Claim cancelled',
          'noRefundDecision' => 'No refund ? final insurance decision',
          'closed' => 'Closure confirmed',
          'corrected' => a.approvalGuid == null
              ? 'Bill payment or details recorded'
              : 'Bill corrected; earlier approval retained',
          'removed' => 'Bill marked entered in error',
          _ => 'Bill recorded',
        },
        subtitle:
            '${DateFormat.yMMMd().format((a.submittedAt ?? a.recordedAt).toLocal())}'
            '${a.reason.isEmpty ? '' : ' - ${a.reason}'}'
            '${a.kind == 'corrected' ? '\nBefore: ${_basisLabel(a.beforeJson)}\nAfter: ${_basisLabel(a.afterJson)}' : ''}',
      ));
    }
    for (final a in history.approvals) {
      events.add(_TimelineEvent(
        date: a.decisionDate,
        icon: Icons.fact_check_outlined,
        color: Colors.green,
        title: a.approvedMinor == 0
            ? 'No refund decision'
            : 'Approved ${_recorded(a.approvedMinor, a.currency)}',
        subtitle:
            '${DateFormat.yMMMd().format(a.decisionDate.toLocal())} - ${_basisLabel(a.basisJson)}'
            '${a.approvedMinor == 0 ? '\n${history.activities.where((event) => event.kind == "noRefundDecision" && event.approvalGuid == a.syncGuid).firstOrNull?.reason ?? "Decision reason needs review"}' : ''}',
      ));
    }
    for (final r in history.returns) {
      final evidence = MedicalReceiptEvidence.of(r);
      events.add(_TimelineEvent(
        date: evidence?.receivedAt,
        icon: Icons.south_west,
        color: Colors.teal,
        title: 'Received ${_recorded(r.amount, r.currency)}',
        subtitle: evidence == null
            ? 'Legacy record - actual receipt date not verified'
            : '${DateFormat('d MMM yyyy, HH:mm').format(evidence.receivedAt.toLocal())} '
                '${showMonths ? 'Funding ${evidence.fundingMonth}' : ''}',
      ));
    }

    final closure = history.closure;
    if (closure != null) {
      events.add(_TimelineEvent(
          date: closure.recordedAt,
          icon: Icons.task_alt,
          color: Colors.teal,
          title: closure.shortfallMinor > 0
              ? 'Closed with money missing'
              : 'Bill closed',
          subtitle:
              '${DateFormat.yMMMd().format(closure.recordedAt.toLocal())} - ${closure.reason}'
              '\nMoney received: ${_recorded(closure.receivedMinor, closure.currency)}'
              '${closure.shortfallMinor > 0 ? '\nMoney not received: ${_recorded(closure.shortfallMinor, closure.currency)}' : ''}'));
    }
    // Sort only known dates; unknown legacy receipt dates are never invented.
    final order = {for (var i = 0; i < events.length; i++) events[i]: i};
    events.sort((a, b) {
      if (a.date == null && b.date == null) {
        return order[a]!.compareTo(order[b]!);
      }
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      final comparison = a.date!.compareTo(b.date!);
      return comparison == 0 ? order[a]!.compareTo(order[b]!) : comparison;
    });
    if (history.revisions.any((r) => r.revision > 1)) {
      events.add(_TimelineEvent(
        icon: Icons.edit_note,
        color: Colors.grey,
        title:
            '${history.revisions.where((r) => r.revision > 1).length} correction revision(s) retained.',
        subtitle: '',
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeading)
          const Text('Claim history',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        if (events.isEmpty) const Text('No activity recorded yet.'),
        const SizedBox(height: 8),
        for (int i = 0; i < events.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Icon(events[i].icon, size: 16, color: events[i].color),
                  if (i < events.length - 1)
                    Container(width: 2, height: 24, color: events[i].color),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(events[i].title,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      if (events[i].subtitle.isNotEmpty)
                        Text(events[i].subtitle,
                            style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  String _basisLabel(String? raw) {
    if (raw == null) return 'Original expected amount not recorded';
    try {
      final values = jsonDecode(raw);
      final expected = values is Map ? values['expectedMinor'] : null;
      if (expected is int && expected >= 0) {
        if (values is Map &&
            values['currency'] is String &&
            moneyWithCurrency != null) {
          final code = values['currency'] as String;
          final total = values['billedMinor'], patient = values['patientMinor'];
          return '${total is int ? 'Bill total ${_recorded(total, code)} · ' : ''}'
              '${patient is int ? 'Your share ${_recorded(patient, code)} · ' : ''}'
              'Expected refund ${_recorded(expected, code)}'
              '${values["paidAt"] is String ? ' ? Payment date ${DateTime.tryParse(values["paidAt"] as String)?.toLocal().toString().substring(0, 10) ?? "Needs review"}' : ''}';
        }
        return 'Expected amount recorded';
      }
    } on FormatException {
      return 'Expected amount needs review';
    }
    return 'Expected amount needs review';
  }
}

class _TimelineEvent {
  const _TimelineEvent({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.date,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final DateTime? date;
}
