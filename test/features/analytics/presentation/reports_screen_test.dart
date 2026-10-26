import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/models/financial_report.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/services/report_access.dart';
import 'package:budget_buddy/core/services/report_delivery.dart';
import 'package:budget_buddy/core/services/report_format.dart';
import 'package:budget_buddy/features/analytics/providers/report_providers.dart';
import 'package:budget_buddy/features/analytics/presentation/reports_screen.dart';
import 'package:budget_buddy/features/analytics/presentation/widgets/report_results.dart';
import '../../../core/services/report_fixture.dart';

void main() {
  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets(
      'transaction pages contain twenty entries with controls only when needed',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: ReportResults(report: reportFixture(count: 25))))));
    await tap(tester, find.text('Transaction details'));
    expect(find.text('Coffee 0'), findsOneWidget);
    expect(find.text('Coffee 19'), findsOneWidget);
    expect(find.text('Coffee 20'), findsNothing);
    await tap(tester, find.text('Next'));
    expect(find.text('Coffee 20'), findsOneWidget);
    expect(find.text('Coffee 0'), findsNothing);
    expect(find.text('Page 2 of 2'), findsOneWidget);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: ReportResults(
                    key: const ValueKey('short'),
                    report: reportFixture(count: 20))))));
    await tap(tester, find.text('Transaction details'));
    expect(find.text('Next'), findsNothing);
    expect(find.text('Previous'), findsNothing);
  });
  for (final brightness in Brightness.values) {
    testWidgets(
        'report sections fit narrow large-text ${brightness.name} layouts',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 760));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      tester.platformDispatcher.textScaleFactorTestValue = 1.8;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(MaterialApp(
          theme: ThemeData(useMaterial3: true, brightness: brightness),
          home: Scaffold(
              body: SingleChildScrollView(
                  child: ReportResults(
                      report: reportFixture(
                          title:
                              'A long purchase name for this accessible phone layout'))))));
      for (final label in [
        'Monthly statements',
        'How totals add up',
        'Transaction details'
      ]) {
        await tap(tester, find.text(label));
      }
      expect(tester.takeException(), isNull);
    });
  }
  Future<void> open(WidgetTester tester,
      {required GenerateFinancialReport generate,
      SendFinancialReport? send,
      bool exportAllowed = true}) async {
    await tester.pumpWidget(ProviderScope(overrides: [
      budgetContextProvider.overrideWithValue(
          ContextRef.personal(profileId: 1, yearMonth: '2026-10')),
      actingProfileIdProvider.overrideWithValue(1),
      activeProfileProvider.overrideWith((ref) => Stream.value(null)),
      reportOwnersProvider.overrideWith((ref) async => [
            const ReportOwnerChoice(ReportOwner.personal(1), 'Me',
                locked: false, canExport: true),
            const ReportOwnerChoice(ReportOwner.space(2), 'Home',
                locked: false, canExport: true)
          ]),
      generateFinancialReportProvider.overrideWithValue(generate),
      reportCurrentAccessProvider
          .overrideWith((ref, report) async => exportAllowed),
      if (send != null) sendFinancialReportProvider.overrideWithValue(send),
    ], child: const MaterialApp(home: ReportsScreen())));
    await tester.pumpAndSettle();
  }

  testWidgets(
      'generation and export reuse the same frozen snapshot; notes default off',
      (tester) async {
    final snapshot = reportFixture();
    var sent = false;
    await open(tester, generate: (request, actor) async {
      expect(request.firstMonth, '2026-10');
      expect(actor, 1);
      return snapshot;
    }, send: (report, kind,
        {required share, options = const ReportExportOptions(), origin}) async {
      expect(identical(report, snapshot), isTrue);
      expect(options.notes, isFalse);
      expect(options.appendix, isFalse);
      expect(share, isFalse);
      sent = true;
      return ReportDeliveryResult.saved;
    });
    await tap(tester, find.text('Generate report'));
    await tap(tester, find.text('Export report'));
    expect(find.text('Export preview'), findsOneWidget);
    await tap(tester, find.text('Save file'));
    expect(sent, isTrue);
    expect(find.text('Report saved.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('viewer report is readable but export is disabled',
      (tester) async {
    await open(tester,
        generate: (_, __) async => reportFixture(canExport: false),
        exportAllowed: false);
    await tap(tester, find.text('Generate report'));
    final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Export report'));
    expect(button.onPressed, isNull);
    expect(find.textContaining('View-only report'), findsOneWidget);
  });
}
