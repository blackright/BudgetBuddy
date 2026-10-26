import 'dart:convert';
import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/services/audit_verify_service.dart';
import 'package:budget_buddy/features/finance/presentation/audit_history_screen.dart';
import 'package:budget_buddy/features/finance/providers/audit_providers.dart';
import 'package:budget_buddy/features/settings/providers/audit_diagnostics_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

AuditEvent event(int n) => AuditEvent()
  ..syncGuid = 'event-$n'
  ..profileId = 1
  ..timestamp = DateTime(2026, 10, 24, 12, n)
  ..createdAt = DateTime(2026)
  ..action = 'income.update'
  ..objectType = 'IncomeSource'
  ..userIdentity = 'Owner'
  ..hash = ''
  ..previousHash = ''
  ..previousValue = '{"amount":1000,"currency":"huf"}'
  ..newValue = '{"amount":1000000,"currency":"huf"}';

void main() {
  String comparison(WidgetTester tester, String field) => tester
      .widget<SelectableText>(find.descendant(
          of: find.byKey(ValueKey('audit-change-$field')),
          matching: find.byType(SelectableText)))
      .textSpan!
      .toPlainText();
  Future<void> open(WidgetTester tester, List<AuditEvent> rows,
      {bool fail = false,
      bool diagnostics = false,
      Size size = const Size(390, 844),
      double scale = 1,
      Brightness brightness = Brightness.light}) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(ProviderScope(
        overrides: [
          auditDiagnosticsEnabledProvider.overrideWithValue(diagnostics),
          budgetContextProvider.overrideWithValue(
              ContextRef.personal(profileId: 1, yearMonth: '2026-10')),
          auditAuthorNamesProvider
              .overrideWith((ref) async => <String, String>{'Owner': 'Owner'}),
          auditRowsProvider.overrideWith((ref) =>
              fail ? Stream.error(StateError('denied')) : Stream.value(rows)),
          auditVerificationProvider.overrideWith((ref) async =>
              const AuditVerification(
                  AuditStatus.legacy, 'Legacy records present.', 21)),
        ],
        child: MaterialApp(
            theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.deepPurple, brightness: brightness)),
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!),
            home: const AuditHistoryScreen())));
    await tester.pumpAndSettle();
  }

  testWidgets('phone pages/filter old records, readable details, grouped money',
      (tester) async {
    final rows = [for (var i = 0; i < 21; i++) event(i)];
    rows.first.timestamp = DateTime(2021, 3, 1);
    await open(tester, rows);
    await tester.scrollUntilVisible(find.text('Next'), 300);
    expect(find.text('Page 1 of 2 · 21 records'), findsOneWidget);
    await tester.ensureVisible(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.byType(ExpansionTile), findsOneWidget);
    expect(find.text('Page 2 of 2 · 21 records'), findsOneWidget);
    await tester.tap(find.byKey(const Key('auditYear')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2021').last);
    await tester.pumpAndSettle();
    expect(find.text('Page 1 of 1 · 1 records'), findsOneWidget);
    await tester.tap(find.byType(ExpansionTile));
    await tester.pumpAndSettle();
    expect(find.text('Legacy — not fully verified'), findsOneWidget);
    expect(find.text('Author: Owner'), findsOneWidget);
    expect(comparison(tester, 'amount'), 'Amount: Ft 1,000 → Ft 1,000,000');
    expect(
        tester
            .getSize(find.byKey(const ValueKey('audit-change-amount')))
            .height,
        lessThan(90));
    expect(tester.takeException(), isNull);
  });
  testWidgets('permission error shows no financial details', (tester) async {
    await open(tester, [], fail: true);
    expect(find.textContaining('Check your profile and space permissions'),
        findsOneWidget);
    expect(find.byType(ExpansionTile), findsNothing);
  });
  testWidgets(
      'changed fields lead and unchanged snapshots remain available on demand',
      (tester) async {
    final row = event(1)
      ..objectType = 'Expense'
      ..action = 'expense.update'
      ..previousValue =
          '{"title":"Groceries","amount":1000,"currency":"huf","status":0,"notes":"old"}'
      ..newValue =
          '{"title":"Groceries","amount":2500,"currency":"huf","status":1,"notes":null}';
    final raw = row.newValue;
    await open(tester, [row]);
    await tester.tap(find.text('Expense updated'));
    await tester.pumpAndSettle();
    expect(find.text('What changed'), findsOneWidget);
    expect(find.text('Title: Groceries'), findsNothing);
    final amount = find.byKey(const ValueKey('audit-change-amount'));
    expect(comparison(tester, 'amount'), 'Amount: Ft 1,000 → Ft 2,500');
    expect(tester.getSize(amount).height, lessThan(90));
    expect(comparison(tester, 'status'), 'Status: Planned → Paid');
    await tester.ensureVisible(find.text('Show all recorded fields'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show all recorded fields'));
    await tester.pumpAndSettle();
    expect(find.text('Title: Groceries'), findsOneWidget);
    expect(find.text('Currency: HUF'), findsOneWidget);
    expect(row.newValue, raw);
    expect(tester.takeException(), isNull);
  });
  testWidgets('added and deleted records do not repeat empty comparisons',
      (tester) async {
    final row = event(1)
      ..action = 'expense.create'
      ..objectType = 'Expense'
      ..previousValue = null
      ..newValue =
          '{"title":"Shopping","amount":2000,"currency":"huf","guiltLevel":0}';
    await open(tester, [row]);
    await tester.tap(find.text('Expense added'));
    await tester.pumpAndSettle();
    expect(find.text('New record. No previous snapshot was recorded.'),
        findsOneWidget);
    expect(find.text('Before'), findsNothing);
    expect(comparison(tester, 'guiltLevel'), 'Spending choice: Essential');
    expect(find.text('Guilt level: 0'), findsNothing);
    row
      ..action = 'expense.delete'
      ..previousValue = row.newValue
      ..newValue = null;
    await tester.pumpWidget(const SizedBox.shrink());
    await open(tester, [row]);
    await tester.tap(find.text('Expense deleted'));
    await tester.pumpAndSettle();
    expect(find.text('Record removed. Showing its last recorded values.'),
        findsOneWidget);
    expect(find.text('After'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  for (final size in [const Size(320, 844), const Size(760, 1000)]) {
    testWidgets('compact comparisons retain complete values at ${size.width}',
        (tester) async {
      final row = event(1)
        ..evidenceJson = '{}'
        ..previousValue =
            '{"name":"Monthly shopping and household essentials","amount":1000,"currency":"huf"}'
        ..newValue =
            '{"name":"Monthly shopping and household essentials","amount":1000000,"currency":"huf"}';
      await open(tester, [row],
          size: size,
          scale: size.width == 320 ? 1.8 : 1,
          brightness: size.width == 320 ? Brightness.dark : Brightness.light);
      await tester.scrollUntilVisible(find.text('Income updated'), 200);
      await tester.tap(find.text('Income updated'));
      await tester.pumpAndSettle();
      expect(find.text('Recorded'), findsOneWidget);
      expect(find.text('Verified'), findsNothing);
      final amount = find.byKey(const ValueKey('audit-change-amount'));
      expect(comparison(tester, 'amount'), 'Amount: Ft 1,000 → Ft 1,000,000');
      final value = tester.widget<SelectableText>(
          find.descendant(of: amount, matching: find.byType(SelectableText)));
      expect(value.semanticsLabel,
          'Amount. Before: Ft 1,000. After: Ft 1,000,000.');
      if (size.width == 760) {
        expect(tester.getSize(amount).height, lessThan(50));
      }
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
      'opening another record closes the first including technical details',
      (tester) async {
    final first = event(2)..newValue = '{"title":"First record"}';
    final second = event(1)..newValue = '{"title":"Second record"}';
    await open(tester, [first, second], diagnostics: true);
    Finder card(AuditEvent row) =>
        find.byKey(ValueKey('${row.id}:${row.syncGuid}'));
    await tester.tap(find.descendant(
        of: card(first), matching: find.text('Income updated')));
    await tester.pumpAndSettle();
    expect(find.byKey(ValueKey('audit-metadata-${first.id}:${first.syncGuid}')),
        findsOneWidget);
    await tester.ensureVisible(find.text('Technical details'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Technical details'));
    await tester.pumpAndSettle();
    expect(find.textContaining('"eventReference": "event-2"'), findsOneWidget);
    await tester.scrollUntilVisible(card(second), 300,
        scrollable: find
            .descendant(
                of: find.byType(ListView).first,
                matching: find.byType(Scrollable))
            .first);
    await tester.ensureVisible(find.descendant(
        of: card(second), matching: find.text('Income updated')));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
        of: card(second), matching: find.text('Income updated')));
    await tester.pumpAndSettle();
    expect(find.byKey(ValueKey('audit-metadata-${first.id}:${first.syncGuid}')),
        findsNothing);
    expect(
        find.byKey(ValueKey('audit-metadata-${second.id}:${second.syncGuid}')),
        findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, 4000));
    await tester.pumpAndSettle();
    expect(find.text('First record'), findsOneWidget);
    expect(find.byKey(ValueKey('audit-metadata-${first.id}:${first.syncGuid}')),
        findsNothing);
    expect(find.textContaining('"eventReference": "event-2"'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Verify history shows its result only as temporary feedback',
      (tester) async {
    await open(tester, [event(1)]);
    expect(find.textContaining('Legacy records present.'), findsNothing);
    await tester.tap(find.text('Verify history'));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(SnackBar),
            matching: find.text('Legacy records present.')),
        findsOneWidget);
    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
    expect(find.textContaining('Legacy records present.'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'friendly labels and technical references are separated without rewriting evidence',
      (tester) async {
    final row = event(1)
      ..action = 'expense.refund'
      ..objectType = 'Expense'
      ..evidenceJson = '{"object":"expense-long-object-reference"}'
      ..newValue = '{"title":"Groceries","contextCurrency":"huf",'
          '"currency":"eur","refundSyncGuid":"refund-long-reference","amount":100}';
    final evidence = row.evidenceJson;
    final after = row.newValue;
    await open(tester, [row], diagnostics: true);
    expect(find.text('Expense refunded'), findsOneWidget);
    expect(find.textContaining('Groceries'), findsOneWidget);
    await tester.tap(find.byType(ExpansionTile).first);
    await tester.pumpAndSettle();
    expect(comparison(tester, 'contextCurrency'),
        'Context currency: Not recorded → HUF');
    expect(comparison(tester, 'currency'), 'Currency: HUF → EUR');
    expect(find.textContaining('refund-long-reference'), findsNothing);
    expect(find.textContaining('expense-long-object-reference'), findsNothing);
    await tester.ensureVisible(find.text('Technical details'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Technical details'));
    await tester.pumpAndSettle();
    expect(find.textContaining('refund-long-reference'), findsOneWidget);
    expect(
        find.textContaining('expense-long-object-reference'), findsOneWidget);
    expect(row.action, 'expense.refund');
    expect(row.evidenceJson, evidence);
    expect(row.newValue, after);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'compact details preserve full notes and accessible before/after descriptions',
      (tester) async {
    final before =
        List.filled(12, 'Previous note with every detail.').join(' ');
    final after =
        'A revised note with all information.\n${List.filled(12, 'Nothing is truncated.').join(' ')}';
    final row = event(1)
      ..objectType = 'Expense'
      ..action = 'expense.update'
      ..previousValue = jsonEncode({'title': 'Groceries', 'notes': before})
      ..newValue = jsonEncode({'title': 'Groceries', 'notes': after});
    final original = row.newValue;
    await open(tester, [row]);
    await tester.tap(find.text('Expense updated'));
    await tester.pumpAndSettle();
    expect(
        comparison(tester, 'notes'), 'Notes\nBefore: $before\nAfter: $after');
    final notes = tester.widget<SelectableText>(find.descendant(
        of: find.byKey(const ValueKey('audit-change-notes')),
        matching: find.byType(SelectableText)));
    expect(notes.maxLines, isNull);
    expect(notes.semanticsLabel, 'Notes. Before: $before. After: $after.');
    expect(
        tester
            .getSize(find
                .byKey(ValueKey('audit-metadata-${row.id}:${row.syncGuid}')))
            .height,
        lessThan(120));
    expect(find.text('Record: Groceries'), findsNothing);
    expect(row.newValue, original);
    expect(tester.takeException(), isNull);
  });
}
