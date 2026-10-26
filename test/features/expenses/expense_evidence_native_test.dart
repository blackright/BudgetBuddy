import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/features/expenses/providers/expenses_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_buddy/core/models/expense_evidence_chunk.dart';
import 'package:budget_buddy/core/services/expense_evidence.dart';
import 'package:budget_buddy/features/expenses/repositories/expense_evidence_repository.dart';
import 'package:budget_buddy/features/expenses/repositories/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import '../medical/repositories/medical_test_harness.dart';

void main() {
  late MedicalTestHarness h;
  late ExpenseRepository repository;
  setUp(() async {
    h = await MedicalTestHarness.create();
    await h.seedBudget(yearMonth: '2026-10');
    repository = ExpenseRepository(h.isar);
  });
  tearDown(() async => h.close());
  Expense expense() => Expense(
      profileId: h.profileId,
      yearMonth: '2026-10',
      title: 'Rice',
      amount: 10000,
      currency: 'HUF',
      categoryId: 'food',
      merchantName: 'Market',
      paymentMethod: 'bankTransfer',
      date: DateTime(2026, 10, 24),
      budgetId: 1);
  Future<Expense> ready() async {
    final row = expense();
    final receipt = await prepareEvidence(
        bytes: [37, 80, 68, 70, 45, 49], name: 'receipt.pdf', role: 'receipt');
    final proof = await prepareEvidence(
        bytes: [37, 80, 68, 70, 45, 50], name: 'transfer.pdf', role: 'payment');
    row.paymentEvidenceJson = ExpenseEvidence(
        profileChosen: true,
        documents: [receipt.document, proof.document]).encode();
    row.pendingEvidenceChunks = [
      ...ExpenseEvidenceRepository.chunks(row, receipt),
      ...ExpenseEvidenceRepository.chunks(row, proof)
    ];
    return row;
  }

  test('rejects missing proof without saving money or partial documents',
      () async {
    final row = await ready();
    row.pendingEvidenceChunks.removeLast();
    await expectLater(repository.addExpense(row), throwsStateError);
    expect(await h.isar.expenses.count(), 0);
    expect(await h.isar.expenseEvidenceChunks.count(), 0);
  });
  test('persists actual content atomically and retains it on expense deletion',
      () async {
    final row = await ready();
    await repository.addExpense(row);
    expect(await h.isar.expenseEvidenceChunks.count(), 2);
    final manifest = ExpenseEvidence.decode(row.paymentEvidenceJson)!;
    final bytes = await ExpenseEvidenceRepository(h.isar)
        .readDocument(row, manifest.documents.first);
    expect(bytes, [37, 80, 68, 70, 45, 49]);
    await repository.deleteExpense(row.id);
    expect(await h.isar.expenses.count(), 0);
    expect(await h.isar.expenseEvidenceChunks.count(), 2);
  });
  test('cannot borrow another expense document or overwrite immutable content',
      () async {
    final row = await ready();
    await repository.addExpense(row);
    final other = expense()..paymentEvidenceJson = row.paymentEvidenceJson;
    await expectLater(repository.addExpense(other), throwsFormatException);
    final stored = await h.isar.expenseEvidenceChunks.where().findFirst();
    row.pendingEvidenceChunks = [
      stored!..bytes = [37, 80, 68, 70, 45, 57]
    ];
    await expectLater(repository.updateExpense(row), throwsFormatException);
    expect(await h.isar.expenses.count(), 1);
  });
  test('legacy note edit works but financial edit requires current proof',
      () async {
    final row = expense();
    await h.isar.writeTxn(() async => row.id = await h.isar.expenses.put(row));
    row.notes = 'Corrected';
    await repository.updateExpense(row);
    row.amount++;
    await expectLater(repository.updateExpense(row), throwsStateError);
    expect((await h.isar.expenses.get(row.id))!.amount, 10000);
  });
  test(
      'legacy notes do not silently normalize merchant information or invent a link',
      () async {
    final row = expense()..merchantName = '  Legacy   Merchant  ';
    await h.isar.writeTxn(() async => row.id = await h.isar.expenses.put(row));
    row.notes = 'Corrected';
    await repository.updateExpense(row);
    final stored = await h.isar.expenses.get(row.id);
    expect(stored!.merchantName, '  Legacy   Merchant  ');
    expect(stored.merchantSyncGuid, isNull);
    expect(stored.paymentEvidenceJson, isNull);
  });
  test(
      'pending remote proof permits a notes correction but blocks an unverified payment edit',
      () async {
    final row = await ready();
    row.pendingEvidenceChunks = [];
    await h.isar.writeTxn(() async => row.id = await h.isar.expenses.put(row));
    row.notes = 'Corrected note';
    await repository.updateExpense(row);
    row.amount++;
    await expectLater(repository.updateExpense(row), throwsStateError);
    expect((await h.isar.expenses.get(row.id))!.amount, 10000);
  });
  test(
      'the actual writer preserves legacy status, missing payment date and currency on notes corrections',
      () async {
    IsarHelper.instance = h.isar;
    await h.isar.writeTxn(() async {
      final month = (await h.isar.monthlyBudgets.get(h.budgetId))!
        ..profileId = h.profileId;
      await h.isar.monthlyBudgets.put(month);
    });
    final writer = ExpensesNotifier(h.budgetId, (_) => 0,
        actingProfileId: h.profileId,
        initialState: const AsyncValue.data([]),
        rateRegistry: MedicalTestHarness.rates);
    addTearDown(writer.dispose);
    for (final status in [
      ExpenseStatus.paid,
      ExpenseStatus.cancelled,
      ExpenseStatus.reimbursed,
      ExpenseStatus.partiallyReimbursed
    ]) {
      final row = expense()
        ..budgetId = h.budgetId
        ..currency = 'huf'
        ..status = status
        ..paidAt = null
        ..merchantName = ' Legacy   merchant '
        ..paymentMethod = null;
      await h.isar
          .writeTxn(() async => row.id = await h.isar.expenses.put(row));
      final edit = row.copyForEditing()..notes = 'Corrected';
      await writer.updateExpense(edit);
      final saved = await h.isar.expenses.get(row.id);
      expect(saved!.paidAt, isNull);
      expect(saved.status, status);
      expect(saved.currency, 'huf');
      expect(saved.merchantName, ' Legacy   merchant ');
      expect(saved.paymentMethod, isNull);
      expect(saved.paymentEvidenceJson, isNull);
    }
  });
  test('another personal actor cannot create or edit evidence in this profile',
      () async {
    final row = await ready();
    final foreign = ExpenseRepository(h.isar, actingProfileId: h.profileId + 1);
    await expectLater(foreign.addExpense(row), throwsStateError);
    expect(await h.isar.expenses.count(), 0);
  });
  test(
      'context move copies proof under new identities and retains source versions',
      () async {
    final row = await ready();
    await repository.addExpense(row);
    final evidence = ExpenseEvidenceRepository(h.isar);
    final old = ExpenseEvidence.decode(row.paymentEvidenceJson)!;
    await h.isar.writeTxn(() async {
      final documents = await evidence.prepareContextMove(row);
      row.profileId = 987;
      await evidence.finishContextMoveInTxn(row, documents);
      await h.isar.expenses.put(row);
    });
    final moved = ExpenseEvidence.decode(row.paymentEvidenceJson)!;
    expect(moved.documents.first.guid, isNot(old.documents.first.guid));
    expect(await h.isar.expenseEvidenceChunks.count(), 4);
    expect(await evidence.readDocument(row, moved.documents.first), isNotNull);
    await expectLater(
        evidence.readDocument(row, old.documents.first), throwsFormatException);
  });
}
