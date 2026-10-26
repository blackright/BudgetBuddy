import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/financial_report.dart';
import '../models/currency_code.dart';
import 'report_format.dart';

class ReportPdfJob {
  const ReportPdfJob(this.report, this.regular, this.bold, this.options);
  final FinancialReport report;
  final Uint8List regular, bold;
  final ReportExportOptions options;
}

class ExportPdfService {
  const ExportPdfService();
  Future<Uint8List> generate(FinancialReport report,
      {ReportExportOptions options = const ReportExportOptions()}) async {
    report.requireExportable();
    final regular =
        await rootBundle.load('assets/fonts/reports/NotoSans-Regular.ttf');
    final bold =
        await rootBundle.load('assets/fonts/reports/NotoSans-Bold.ttf');
    return compute(
        renderFinancialReportPdf,
        ReportPdfJob(
            report,
            regular.buffer
                .asUint8List(regular.offsetInBytes, regular.lengthInBytes),
            bold.buffer.asUint8List(bold.offsetInBytes, bold.lengthInBytes),
            options));
  }
}

/// Missing glyphs are explicit code-point markers, never invisible lost text.
String reportPdfText(String value, Set<int> supported) =>
    String.fromCharCodes(value.runes.expand((c) =>
        c == 10 || c == 13 || c == 9 || supported.contains(c)
            ? [c]
            : '[U+${c.toRadixString(16).toUpperCase()}]'.runes));

Future<Uint8List> renderFinancialReportPdf(ReportPdfJob job) async {
  final report = job.report;
  report.requireExportable();
  final normal = pw.Font.ttf(ByteData.sublistView(job.regular));
  final bold = pw.Font.ttf(ByteData.sublistView(job.bold));
  final supported = TtfParser(ByteData.sublistView(job.regular))
      .charToGlyphIndexMap
      .keys
      .toSet();
  final document = pw.Document(
      title: 'BudgetBuddy ${report.request.label}',
      author: 'BudgetBuddy',
      creator: 'BudgetBuddy',
      compress: true);
  const ink = PdfColor.fromInt(0xff234b53);
  String text(String value) => reportPdfText(value, supported);
  pw.Widget heading(String value) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 16, bottom: 8),
      child: pw.Text(text(value),
          style: pw.TextStyle(font: bold, fontSize: 14, color: ink)));
  List<pw.Widget> paragraphs(String value, {double size = 9}) {
    final runes = value.runes.toList();
    return [
      for (var i = 0; i < runes.length; i += 240)
        pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.Text(
                text(String.fromCharCodes(
                    runes.sublist(i, math.min(i + 240, runes.length)))),
                style: pw.TextStyle(fontSize: size)))
    ];
  }

  pw.Widget table(List<String> columns, List<List<String>> rows) =>
      pw.TableHelper.fromTextArray(
          headers: columns.map(text).toList(),
          data: rows.map((r) => r.map(text).toList()).toList(),
          headerStyle:
              pw.TextStyle(font: bold, color: PdfColors.white, fontSize: 9),
          headerDecoration: const pw.BoxDecoration(color: ink),
          cellStyle: const pw.TextStyle(fontSize: 8),
          cellPadding: const pw.EdgeInsets.all(6),
          oddRowDecoration:
              const pw.BoxDecoration(color: PdfColor.fromInt(0xfff2f6f6)),
          border: null);
  final code = report.request.currency;
  final body = <pw.Widget>[
    pw.Container(
        padding: const pw.EdgeInsets.all(18),
        decoration: const pw.BoxDecoration(
            color: ink,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(12))),
        child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('BUDGETBUDDY',
                  style: pw.TextStyle(
                      font: bold, color: PdfColors.white, fontSize: 11)),
              pw.SizedBox(height: 6),
              pw.Text(report.request.label,
                  style: pw.TextStyle(
                      font: bold, color: PdfColors.white, fontSize: 23)),
              pw.Text(
                  '${report.request.firstMonth} — ${report.request.lastMonth} · ${code.code.toUpperCase()}',
                  style: const pw.TextStyle(color: PdfColors.white))
            ])),
    pw.SizedBox(height: 10),
    ...paragraphs(
        'Generated ${reportTime(report.generatedAt)}. Current recorded data frozen at generation. Full shared-space amounts are included once, not personal ownership shares.'),
    heading('Period activity'),
    table([
      'Activity',
      'Amount'
    ], [
      for (final key in reportFlowMetrics)
        [reportMetricLabels[key]!, reportMoney(report.flow(key), code)]
    ]),
    ...paragraphs(
        'Unavailable period totals mean one or more selected months have no recorded statement. See monthly sections. Balances and allocations are not added across months.'),
    if (report.previousNet != null && report.flow('net') != null) ...[
      heading('Previous-period comparison'),
      ...paragraphs(
          'Previous net paid: ${reportMoney(report.previousNet, code)}. Change: ${reportMoney(report.flow('net')! - report.previousNet!, code)}.')
    ],
    for (final s in report.statements) ...[
      heading('${s.context} · ${s.month}'),
      if (s.amounts.isEmpty)
        ...paragraphs(
            'No recorded monthly statement. No financial values have been inferred.')
      else
        table([
          'Monthly measure',
          'Amount'
        ], [
          for (final a in s.amounts.entries)
            [reportMetricLabels[a.key] ?? a.key, reportMoney(a.value, code)]
        ]),
      ...paragraphs(s.rateBasis)
    ],
    heading('Financial profiles'),
    if (report.profiles.isEmpty)
      ...paragraphs('No financial profiles in this selection.')
    else
      table([
        'Context / month',
        'Profile',
        'Allocation',
        'Net usage'
      ], [
        for (final p in report.profiles)
          [
            '${p.context} / ${p.month}',
            '${p.type}: ${p.name}',
            p.allocation == null
                ? 'Not applicable'
                : reportMoney(p.allocation, code),
            reportMoney(p.net, code)
          ]
      ]),
    for (final field in ['merchant', 'category']) ...[
      heading(field == 'merchant' ? 'Merchant analysis' : 'Category analysis'),
      table([
        field == 'merchant' ? 'Merchant' : 'Category',
        'Net paid'
      ], [
        for (final item
            in (report.breakdown(field).entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value))))
          [item.key, reportMoney(item.value, code)]
      ])
    ],
    heading('Original-currency subtotals'),
    table([
      'Currency / activity',
      'Original amount'
    ], [
      for (final t in originalReportTotals(report).entries)
        [
          t.key,
          reportMoney(t.value, CurrencyCode.tryParse(t.key.split(' · ').first)!)
        ]
    ]),
    if (report.balances.isNotEmpty) ...[
      heading('Savings endpoint balances'),
      for (final b in report.balances)
        ...paragraphs(
            '${b.context}: ${b.label} (${reportTime(b.date)}): ${b.currency} ${reportMoney(b.amount, CurrencyCode.tryParse(b.currency)!).split(' ').skip(1).join(' ')}. Report equivalent ${reportMoney(b.converted, code)}.')
    ],
    heading('How totals add up'),
    ...paragraphs(reportReconciliation),
    heading('Local insights'),
    for (final insight in report.insights) ...paragraphs(insight),
    if (report.warnings.isNotEmpty) ...[
      heading('Data quality and rate notes'),
      for (final warning in report.warnings) ...paragraphs(warning)
    ],
    ...paragraphs(
        'Receipt/payment files and raw audit or identity identifiers are excluded. Notes are ${job.options.notes ? 'included only in the transaction appendix' : 'excluded'}. Unsupported font characters are represented by explicit U+ code-point markers; CSV preserves original text.'),
    if (job.options.appendix) ...[
      heading('Transaction appendix'),
      for (final r in report.transactions) ...[
        heading('${reportDate(r.date)} · ${r.kind}'),
        ...paragraphs(r.name),
        ...paragraphs(
            '${r.context} · Budget month ${r.month} · ${r.profile}\n${r.merchant} · ${r.category} · ${reportPayment(r.payment)} · ${reportStatus(r.status)}'),
        ...paragraphs(
            'Original ${reportMoney(r.amount, CurrencyCode.tryParse(r.currency)!)}; report ${reportMoney(r.converted, code)}. Recorded ${reportTime(r.recordedAt)}. Paid ${r.paidAt == null ? 'Not recorded' : reportDate(r.paidAt!)}. Evidence: ${r.evidence}. Rate basis: ${r.rateBasis}.'),
        if (job.options.notes && r.notes?.isNotEmpty == true)
          ...paragraphs('Notes: ${r.notes}'),
      ]
    ],
  ];
  document.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      theme: pw.ThemeData.withFont(base: normal, bold: bold),
      maxPages: math.max(
          200, report.transactions.length * 20 + report.statements.length * 6),
      footer: (context) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                    'BudgetBuddy · ${report.request.currency.code.toUpperCase()}',
                    style: const pw.TextStyle(fontSize: 8)),
                pw.Text('Page ${context.pageNumber} / ${context.pagesCount}',
                    style: const pw.TextStyle(fontSize: 8))
              ])),
      build: (_) => body));
  // The always-visible font note above also covers any substitutions in tables.
  return document.save();
}
