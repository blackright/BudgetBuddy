import 'dart:convert';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/services/expense_evidence.dart';
import 'package:budget_buddy/core/services/expense_evidence_draft.dart';
import 'package:budget_buddy/features/expenses/presentation/widgets/expense_evidence_editor.dart';
import 'package:budget_buddy/features/expenses/presentation/widgets/expense_evidence_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'cash declaration starts unchecked; phone layout supports large text and three-file errors',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final draft = ExpenseEvidenceDraft();
    await tester.pumpWidget(MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: Scaffold(
            body: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
                child: SingleChildScrollView(
                    child: ExpenseEvidenceEditor(
                        draft: draft,
                        status: ExpenseStatus.paid,
                        payment: 'cash'))))));
    expect(draft.cashConfirmed, isFalse);
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    expect(draft.cashConfirmed, isTrue);
    expect(draft.cashConfirmedAt, isNotNull);
    for (var index = 0; index < 3; index++) {
      final prepared = await prepareEvidence(
          bytes: [37, 80, 68, 70, 45, index],
          name: 'Receipt $index.pdf',
          role: 'receipt');
      draft.documents.add(prepared.document);
    }
    await tester.ensureVisible(find.text('Add receipt'));
    await tester.tap(find.text('Add receipt'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Use at most three files'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'PDF preview renders pages privately and exposes bounded navigation',
      (tester) async {
    final pages = <int>[];
    final png = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGP4//8/AAX+Av4N70a4AAAAAElFTkSuQmCC');
    const channel = MethodChannel('budget_buddy/payment_document');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (call) async {
      pages.add((call.arguments as Map)['page'] as int);
      return {'pages': 2, 'image': png};
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));
    final prepared = await prepareEvidence(
        bytes: [37, 80, 68, 70, 45, 49], name: 'Receipt.pdf', role: 'receipt');
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () => openEvidenceDocument(
                        context, prepared.bytes, prepared.document),
                    child: const Text('Open document'))))));
    await tester.tap(find.text('Open document'));
    await tester.pumpAndSettle();
    expect(find.text('Page 1 of 2'), findsOneWidget);
    await tester.tap(find.byTooltip('Next page'));
    await tester.pumpAndSettle();
    expect(find.text('Page 2 of 2'), findsOneWidget);
    expect(pages, [0, 1]);
    expect(
        tester
            .widget<IconButton>(find.byWidgetPredicate((widget) =>
                widget is IconButton && widget.tooltip == 'Next page'))
            .onPressed,
        isNull);
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
