import 'dart:convert';
import 'dart:typed_data';
import '../models/financial_report.dart';
import '../models/currency_code.dart';
import 'report_format.dart';

/// Explicit numeric cells are generated only from bounded integer money.
class ReportCsvNumber {
  ReportCsvNumber(this.text) {
    if (!RegExp(r'^-?[0-9]+(?:\.[0-9]+)?$').hasMatch(text)) {
      throw ArgumentError('Not an exact number.');
    }
  }
  final String text;
}

String reportCsvCell(Object? value) {
  if (value is ReportCsvNumber) return value.text;
  if (value is int) return value.toString();
  var text = value?.toString() ?? '';
  if (RegExp(r'^[\s\x00-\x1f\ufeff]*[=+\-@]').hasMatch(text)) text = "'$text";
  return '"${text.replaceAll('"', '""')}"';
}

class ExportCsvService {
  const ExportCsvService();
  Uint8List transactions(FinancialReport report,
      {ReportExportOptions options = const ReportExportOptions()}) {
    report.requireExportable();
    final rows = <List<Object?>>[
      [
        'Report',
        'Generated UTC',
        'Period start',
        'Period end',
        'Context',
        'Financial month',
        'Type',
        'Name',
        'Expense/event date',
        'Recorded UTC',
        'Paid date',
        'Financial profile',
        'Merchant',
        'Category',
        'Payment method',
        'Status',
        'Evidence status',
        'Original currency',
        'Original amount',
        'Original minor units',
        'Report currency',
        'Report amount',
        'Report minor units',
        'Spending effect',
        'Rate basis',
        if (options.notes) 'Notes'
      ],
      for (final r in report.transactions)
        [
          report.request.label,
          report.generatedAt.toIso8601String(),
          report.request.firstMonth,
          report.request.lastMonth,
          r.context,
          r.month,
          r.kind,
          r.name,
          r.date.toIso8601String(),
          r.recordedAt?.toUtc().toIso8601String(),
          r.paidAt?.toIso8601String(),
          r.profile,
          r.merchant,
          r.category,
          reportPayment(r.payment),
          reportStatus(r.status),
          r.evidence,
          r.currency,
          CurrencyCode.tryParse(r.currency) == null
              ? null
              : ReportCsvNumber(exactReportDecimal(
                  r.amount, CurrencyCode.tryParse(r.currency)!)),
          r.amount,
          report.request.currency.code.toUpperCase(),
          r.converted == null
              ? null
              : ReportCsvNumber(
                  exactReportDecimal(r.converted!, report.request.currency)),
          r.converted,
          r.effect,
          r.rateBasis,
          if (options.notes) r.notes
        ],
    ];
    return _encode(rows);
  }

  Uint8List summary(FinancialReport report) {
    report.requireExportable();
    final code = report.request.currency;
    Object? number(int? value) =>
        value == null ? null : ReportCsvNumber(exactReportDecimal(value, code));
    final rows = <List<Object?>>[
      [
        'Section',
        'Context',
        'Month/event date',
        'Metric',
        'Currency',
        'Amount',
        'Minor units',
        'Basis / explanation',
        'Generated UTC'
      ],
      for (final s in report.statements) ...[
        if (s.amounts.isEmpty)
          [
            'Monthly statement',
            s.context,
            s.month,
            'No recorded data',
            code.code.toUpperCase(),
            null,
            null,
            'No monthly figures were inferred.',
            report.generatedAt.toIso8601String()
          ],
        for (final amount in s.amounts.entries)
          [
            'Monthly statement',
            s.context,
            s.month,
            reportMetricLabels[amount.key] ?? amount.key,
            code.code.toUpperCase(),
            number(amount.value),
            amount.value,
            s.rateBasis,
            report.generatedAt.toIso8601String()
          ],
      ],
      for (final key in reportFlowMetrics)
        [
          'Period activity',
          'Selected contexts',
          '${report.request.firstMonth} to ${report.request.lastMonth}',
          reportMetricLabels[key],
          code.code.toUpperCase(),
          number(report.flow(key)),
          report.flow(key),
          'Activity only; balances are not summed.',
          report.generatedAt.toIso8601String()
        ],
      for (final p in report.profiles) ...[
        [
          'Financial profile',
          p.context,
          p.month,
          '${p.type}: ${p.name} — Net allocation usage',
          code.code.toUpperCase(),
          number(p.net),
          p.net,
          'Profile spending policy; see monthly statement for all credited refunds.',
          report.generatedAt.toIso8601String()
        ],
        if (p.allocation != null)
          [
            'Financial profile',
            p.context,
            p.month,
            '${p.type}: ${p.name} — Allocation',
            code.code.toUpperCase(),
            number(p.allocation),
            p.allocation,
            'Not an expense.',
            report.generatedAt.toIso8601String()
          ],
        if (p.borrowed != null)
          [
            'Financial profile',
            p.context,
            p.month,
            '${p.type}: ${p.name} — Borrowing',
            code.code.toUpperCase(),
            number(p.borrowed),
            p.borrowed,
            'Shared reserve; do not add individual borrowing capacities.',
            report.generatedAt.toIso8601String()
          ],
      ],
      for (final b in report.balances)
        [
          'Endpoint balance',
          b.context,
          b.date.toUtc().toIso8601String(),
          b.label,
          b.currency,
          CurrencyCode.tryParse(b.currency) == null
              ? null
              : ReportCsvNumber(exactReportDecimal(
                  b.amount, CurrencyCode.tryParse(b.currency)!)),
          b.amount,
          'Original-currency endpoint; not a period activity total.',
          report.generatedAt.toIso8601String()
        ],
      for (final e in originalReportTotals(report).entries)
        [
          'Original subtotal',
          'Selected contexts',
          '${report.request.firstMonth} to ${report.request.lastMonth}',
          e.key,
          e.key.split(' · ').first,
          e.value == null
              ? null
              : ReportCsvNumber(exactReportDecimal(
                  e.value!, CurrencyCode.tryParse(e.key.split(' · ').first)!)),
          e.value,
          'Separate currencies and transaction kinds; do not sum mixed units.',
          report.generatedAt.toIso8601String()
        ],
      [
        'Reconciliation',
        '',
        '',
        'Explanation',
        '',
        '',
        '',
        reportReconciliation,
        report.generatedAt.toIso8601String()
      ],
      for (final warning in report.warnings)
        [
          'Data quality',
          '',
          '',
          'Warning',
          '',
          '',
          '',
          warning,
          report.generatedAt.toIso8601String()
        ],
    ];
    return _encode(rows);
  }

  Uint8List _encode(List<List<Object?>> rows) => Uint8List.fromList(utf8.encode(
      '\ufeff${rows.map((r) => r.map(reportCsvCell).join(',')).join('\r\n')}\r\n'));
}
