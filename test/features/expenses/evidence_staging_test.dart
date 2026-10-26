import 'dart:io';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/services/evidence_staging.dart';
import 'package:budget_buddy/core/services/expense_evidence.dart';
import 'package:budget_buddy/core/services/expense_evidence_draft.dart';
import 'package:budget_buddy/features/expenses/repositories/expense_evidence_repository.dart';
import 'package:budget_buddy/features/expenses/repositories/expense_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../medical/repositories/medical_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temporary;
  setUpAll(() async {
    temporary = await Directory.systemTemp.createTemp('phase12_staging_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (call) async => temporary.path);
  });
  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'), null);
    await temporary.delete(recursive: true);
  });
  test('private staging is released after save; committed proof remains intact',
      () async {
    final h = await MedicalTestHarness.create();
    await h.seedBudget(yearMonth: '2026-10');
    addTearDown(h.close);
    final prepared = await prepareEvidence(
        bytes: [37, 80, 68, 70, 45, 49], name: 'receipt.pdf', role: 'receipt');
    final staged = await EvidenceStaging.stage(prepared);
    expect(staged.bytes, isEmpty);
    final draft = ExpenseEvidenceDraft()
      ..profileChosen = true
      ..changed = true
      ..cashConfirmed = true;
    draft.documents.add(staged.document);
    draft.prepared[staged.document.guid] = staged;
    final row = Expense(
        profileId: h.profileId,
        yearMonth: '2026-10',
        title: 'Cash purchase',
        amount: 1000,
        currency: 'HUF',
        categoryId: 'food',
        merchantName: 'Market',
        paymentMethod: 'cash',
        date: DateTime(2026, 10, 24),
        paidAt: DateTime(2026, 10, 24),
        budgetId: 1);
    draft.apply(row, actor: '${h.profileId}');
    expect(row.pendingEvidenceChunks, isEmpty);
    await ExpenseRepository(h.isar).addExpense(row);
    await draft.dispose();
    expect(await File(staged.stagedPath!).exists(), isFalse);
    expect(
        await ExpenseEvidenceRepository(h.isar)
            .readDocument(row, staged.document),
        prepared.bytes);
  });
  test(
      'cannot read an arbitrary external path; discarded drafts remove only their copy',
      () async {
    final original =
        File('${temporary.path}${Platform.pathSeparator}gallery-original.pdf');
    await original.writeAsBytes([37, 80, 68, 70, 45, 49]);
    await expectLater(
        EvidenceStaging.read(original.path), throwsFormatException);
    final prepared = await prepareEvidence(
        bytes: await original.readAsBytes(),
        name: 'receipt.pdf',
        role: 'receipt');
    final staged = await EvidenceStaging.stage(prepared);
    await EvidenceStaging.discard(staged.stagedPath);
    expect(await File(staged.stagedPath!).exists(), isFalse);
    expect(await original.exists(), isTrue);
  });
}
