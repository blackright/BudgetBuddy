import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/services/export_csv_service.dart';
import 'package:budget_buddy/core/services/export_pdf_service.dart';
import 'package:budget_buddy/core/services/report_format.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'report_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
      'CSV preserves Unicode, escapes delimiters and excludes notes by default',
      () {
    final report = reportFixture(
        title: 'Rice, "fine"\nsecond line', notes: 'SECRET = note');
    final csv = utf8.decode(const ExportCsvService().transactions(report));
    expect(const ExportCsvService().transactions(report).take(3).toList(),
        [239, 187, 191]);
    expect(csv, contains('"Rice, ""fine""\nsecond line 0"'));
    expect(csv, contains('Café Budapest'));
    expect(csv, contains('HUF'));
    expect(csv, contains(',1000,1000,'));
    expect(csv, contains('2026-10-26T12:00:00.000Z'));
    expect(csv, isNot(contains('SECRET')));
    final withNotes = utf8.decode(const ExportCsvService()
        .transactions(report, options: const ReportExportOptions(notes: true)));
    expect(withNotes, contains('SECRET = note'));
  });
  test(
      'text formulas are neutralized but generated negative numbers stay numeric',
      () {
    for (final value in [
      '=SUM(1,2)',
      ' +cmd',
      '\t@SUM(1)',
      '\r-4',
      '\ufeff=1'
    ]) {
      expect(reportCsvCell(value), startsWith('"\''));
    }
    expect(reportCsvCell(ReportCsvNumber('-12.34')), '-12.34');
    expect(() => ReportCsvNumber('=1'), throwsArgumentError);
    expect(exactReportDecimal(123456789, CurrencyCode.usd), '1234567.89');
    expect(exactReportDecimal(-123456789, CurrencyCode.huf), '-123456789');
  });
  test(
      'summary and transactions come from the frozen data with no raw paths or identifiers',
      () {
    final report = reportFixture(count: 2);
    final summary = utf8.decode(const ExportCsvService().summary(report));
    final rows = utf8.decode(const ExportCsvService().transactions(report));
    expect(report.flow('net'), 2000);
    expect(summary, contains(',2000,2000,'));
    for (final text in [summary, rows]) {
      expect(text, isNot(contains('syncGuid')));
      expect(text, isNot(contains('receiptPath')));
      expect(text, isNot(contains('PRIVATE NOTE')));
    }
    expect(
        () => const ExportCsvService()
            .transactions(reportFixture(canExport: false)),
        throwsStateError);
  });
  test('PDF embeds local Unicode fonts and paginates an optional appendix',
      () async {
    final normal =
        await File('assets/fonts/reports/NotoSans-Regular.ttf').readAsBytes();
    final bold =
        await File('assets/fonts/reports/NotoSans-Bold.ttf').readAsBytes();
    final report =
        reportFixture(count: 30, title: 'Őrölt kávé — Café — Продукты');
    final summary = await renderFinancialReportPdf(
        ReportPdfJob(report, normal, bold, const ReportExportOptions()));
    final detailed = await renderFinancialReportPdf(ReportPdfJob(
        report, normal, bold, const ReportExportOptions(appendix: true)));
    int pages(List<int> bytes) =>
        RegExp(r'/Type\s*/Page\b').allMatches(latin1.decode(bytes)).length;
    expect(ascii.decode(summary.take(5).toList()), '%PDF-');
    expect(latin1.decode(summary), contains('/FontFile2'));
    expect(latin1.decode(summary), contains('NotoSans'));
    expect(latin1.decode(detailed), contains('%%EOF'));
    expect(pages(detailed), greaterThan(pages(summary)));
    expect(reportPdfText('A😀', {65}), 'A[U+1F600]');
  });
  test('production PDF worker loads bundled assets offline', () async {
    final bytes = await const ExportPdfService().generate(reportFixture());
    expect(ascii.decode(bytes.take(5).toList()), '%PDF-');
  });
}
