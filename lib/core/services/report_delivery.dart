import 'dart:typed_data';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../models/financial_report.dart';
import 'report_service.dart';
import 'export_pdf_service.dart';
import 'export_csv_service.dart';
import 'report_format.dart';

enum ReportFileKind { pdf, summaryCsv, transactionsCsv }

enum ReportDeliveryResult { saved, shared, cancelled, unconfirmed }

abstract class ReportFileTarget {
  Future<ReportDeliveryResult> save(String name, String mime, Uint8List bytes);
  Future<ReportDeliveryResult> share(
      String name, String mime, Uint8List bytes, Rect? origin);
}

class NativeReportFileTarget implements ReportFileTarget {
  @override
  Future<ReportDeliveryResult> save(
      String name, String mime, Uint8List bytes) async {
    final result = await FilePicker.saveFile(
        fileName: name,
        bytes: bytes,
        mimeType: mime,
        dialogTitle: 'Save BudgetBuddy report',
        type: FileType.custom,
        allowedExtensions: [name.split('.').last]);
    return result == null
        ? ReportDeliveryResult.cancelled
        : ReportDeliveryResult.saved;
  }

  @override
  Future<ReportDeliveryResult> share(
      String name, String mime, Uint8List bytes, Rect? origin) async {
    final result = await SharePlus.instance.share(ShareParams(
        files: [XFile.fromData(bytes, mimeType: mime, name: name)],
        fileNameOverrides: [name],
        sharePositionOrigin: origin,
        title: 'BudgetBuddy report'));
    return switch (result.status) {
      ShareResultStatus.success => ReportDeliveryResult.shared,
      ShareResultStatus.dismissed => ReportDeliveryResult.cancelled,
      ShareResultStatus.unavailable => ReportDeliveryResult.unconfirmed
    };
  }
}

/// Permission checks bracket generation and precede the native file handoff.
/// No receipt bytes, persistent archive or automatic upload is created here.
class ReportDelivery {
  ReportDelivery(
      {required this.service,
      ReportFileTarget? target,
      Future<Uint8List> Function(FinancialReport, ReportExportOptions)? pdf})
      : target = target ?? NativeReportFileTarget(),
        pdf =
            pdf ?? ((r, o) => const ExportPdfService().generate(r, options: o));
  final ReportService service;
  final ReportFileTarget target;
  final Future<Uint8List> Function(FinancialReport, ReportExportOptions) pdf;
  bool _busy = false;
  Future<ReportDeliveryResult> deliver(
      FinancialReport report, ReportFileKind kind,
      {required bool share,
      ReportExportOptions options = const ReportExportOptions(),
      Rect? origin}) async {
    if (_busy) throw StateError('An export is already in progress.');
    _busy = true;
    try {
      await service.authorizeExport(report);
      final bytes = switch (kind) {
        ReportFileKind.pdf => await pdf(report, options),
        ReportFileKind.summaryCsv => const ExportCsvService().summary(report),
        ReportFileKind.transactionsCsv =>
          const ExportCsvService().transactions(report, options: options)
      };
      await service.authorizeExport(report);
      final extension = kind == ReportFileKind.pdf ? 'pdf' : 'csv';
      final name =
          'BudgetBuddy_${report.request.scope.name}_${report.request.firstMonth}_${report.request.lastMonth}_${report.generatedAt.toUtc().millisecondsSinceEpoch}_${kind.name}.$extension';
      final mime = kind == ReportFileKind.pdf ? 'application/pdf' : 'text/csv';
      return await (share
          ? target.share(name, mime, bytes, origin)
          : target.save(name, mime, bytes));
    } finally {
      _busy = false;
    }
  }
}
