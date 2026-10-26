import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/expense_purchase.dart';
import 'package:budget_buddy/core/models/expense_evidence_chunk.dart';
import 'package:budget_buddy/features/expenses/repositories/expense_evidence_repository.dart';
import 'package:budget_buddy/features/sync/domain/codecs/expense_evidence_chunk_codec.dart';
import '../expenses/bulk_entry_service_test.dart' show readyBulkRow;
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/services/expense_evidence.dart';
import 'package:budget_buddy/features/sync/domain/codecs/expense_codec.dart';
import 'package:budget_buddy/features/sync/domain/codecs/expense_purchase_codec.dart';
import 'package:budget_buddy/features/sync/domain/sync_codec.dart';
import 'package:budget_buddy/features/sync/repositories/sync_engine.dart';
import 'support/sync_harness.dart';
import 'support/change_factory.dart';

void main() {
  late SyncTestHarness h;
  late DeviceKeys keys;
  late SyncEngine engine;
  late String space;
  late MonthlyBudget budget;
  setUp(() async {
    h = await SyncTestHarness.create();
    keys = await DeviceKeys.generate('owner');
    await h.createSpaceAt(localId: 42);
    space = await h.spaceGuid(42);
    await h.addSignedMember(
        spaceId: 42, keys: keys, role: SharedMemberRole.owner);
    engine = SyncEngine(h.isar, trustedKeys: {'owner': keys.publicKey});
    budget = MonthlyBudget()
      ..sharedSpaceId = 42
      ..yearMonth = '2026-10'
      ..baseAvailableAmount = 0
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    await h.isar.writeTxn(() async {
      budget.id = await h.isar.monthlyBudgets.put(budget);
    });
  });
  tearDown(() async => h.close());
  Map<String, Object?> payload() {
    final p = ExpensePurchase()
      ..currency = 'HUF'
      ..merchantName = 'Shop'
      ..profileId = 0
      ..sharedSpaceId = 42
      ..yearMonth = '2026-10'
      ..budgetId = budget.id;
    final rows = List.generate(
        2,
        (i) => Expense(
            profileId: 0,
            sharedSpaceId: 42,
            yearMonth: '2026-10',
            title: 'Item $i',
            amount: 1000,
            currency: 'HUF',
            categoryId: 'food',
            date: DateTime(2026, 10, 26),
            budgetId: budget.id,
            status: ExpenseStatus.planned,
            merchantName: 'Shop',
            paymentMethod: 'card',
            paymentEvidenceJson:
                const ExpenseEvidence(profileChosen: true).encode()));
    p.itemGuids = rows.map((e) => e.syncGuid).toList();
    for (final row in rows) {
      row
        ..purchaseSyncGuid = p.syncGuid
        ..purchaseEvidenceOwnerGuid = rows.first.syncGuid;
    }
    return const ExpensePurchaseCodec().toJson(p)
      ..['sharedSpaceSyncGuid'] = space
      ..['budgetSyncGuid'] = budget.syncGuid
      ..['items'] = rows
          .map((r) => const ExpenseCodec().toJson(r)
            ..['sharedSpaceSyncGuid'] = space
            ..['budgetSyncGuid'] = budget.syncGuid)
          .toList();
  }

  test(
      'signed purchase projects all items atomically, refuses old item edits and seals deletion',
      () async {
    final json = payload();
    final change = await signedChange(
        keys: keys,
        deviceId: 'a',
        hlcMillis: 100,
        entityType: 'ExpensePurchase',
        contextSyncGuid: space,
        payload: canonicalJsonEncode(json));
    expect(await engine.applyIncoming(change), ApplyOutcome.applied);
    expect(await h.isar.expensePurchases.count(), 1);
    expect(await h.isar.expenses.count(), 2);
    expect(await engine.applyIncoming(change), ApplyOutcome.duplicate);
    final oldItem =
        Map<String, Object?>.from((json['items'] as List).first as Map)
          ..remove('purchaseSyncGuid')
          ..remove('purchaseEvidenceOwnerGuid')
          ..['amount'] = 9;
    final legacy = await signedChange(
        keys: keys,
        deviceId: 'old',
        hlcMillis: 101,
        contextSyncGuid: space,
        payload: canonicalJsonEncode(oldItem));
    await expectLater(engine.applyIncoming(legacy), throwsStateError);
    expect((await h.isar.expenses.where().findFirst())!.amount, 1000);
    await h.sealMonth('2026-10');
    final removal = await signedChange(
        keys: keys,
        deviceId: 'a',
        hlcMillis: 102,
        entityType: 'ExpensePurchase',
        entitySyncGuid: json['syncGuid'] as String,
        contextSyncGuid: space,
        op: 'delete');
    expect(
        await engine.applyIncoming(removal), ApplyOutcome.droppedUnauthorized);
    expect(await h.isar.expenses.count(), 2);
  });
  test('malformed second item cannot leave the first item behind', () async {
    final json = payload();
    ((json['items'] as List).last as Map)['merchantName'] = 'Other shop';
    final change = await signedChange(
        keys: keys,
        deviceId: 'a',
        hlcMillis: 100,
        entityType: 'ExpensePurchase',
        contextSyncGuid: space,
        payload: canonicalJsonEncode(json));
    await expectLater(engine.applyIncoming(change), throwsStateError);
    expect(await h.isar.expensePurchases.count(), 0);
    expect(await h.isar.expenses.count(), 0);
  });
  test(
      'an old shared deletion cannot remove a purchase moved to personal ownership',
      () async {
    final json = payload();
    final create = await signedChange(
        keys: keys,
        deviceId: 'a',
        hlcMillis: 100,
        entityType: 'ExpensePurchase',
        contextSyncGuid: space,
        payload: canonicalJsonEncode(json));
    expect(await engine.applyIncoming(create), ApplyOutcome.applied);
    await h.isar.writeTxn(() async {
      final p = (await h.isar.expensePurchases.where().findFirst())!
        ..sharedSpaceId = null
        ..profileId = 7;
      await h.isar.expensePurchases.put(p);
    });
    final remove = await signedChange(
        keys: keys,
        deviceId: 'a',
        hlcMillis: 101,
        entityType: 'ExpensePurchase',
        entitySyncGuid: json['syncGuid'] as String,
        contextSyncGuid: space,
        op: 'delete');
    expect(
        await engine.applyIncoming(remove), ApplyOutcome.droppedUnauthorized);
    expect(await h.isar.expensePurchases.count(), 1);
    expect(await h.isar.expenses.count(), 2);
  });
  test('viewer cannot author a purchase', () async {
    await h.setMemberHead(
        spaceId: 42, keys: keys, role: SharedMemberRole.viewer, version: 2);
    final change = await signedChange(
        keys: keys,
        deviceId: 'a',
        hlcMillis: 100,
        entityType: 'ExpensePurchase',
        contextSyncGuid: space,
        payload: canonicalJsonEncode(payload()));
    expect(
        await engine.applyIncoming(change), ApplyOutcome.droppedUnauthorized);
    expect(await h.isar.expenses.count(), 0);
  });
  test('one signed document set serves both paid items after content delivery',
      () async {
    final json = payload();
    final evidence = readyBulkRow().evidence;
    json['receiptTotalMinor'] = 2000;
    final paid = <Map<String, Object?>>[];
    for (final raw in json['items'] as List) {
      final row = const ExpenseCodec()
          .fromJson(Map<String, Object?>.from(raw as Map))
        ..status = ExpenseStatus.paid;
      row.paidAt = row.date;
      row.paymentEvidenceJson =
          ExpenseEvidence(profileChosen: true, documents: evidence.documents)
              .encode();
      paid.add(const ExpenseCodec().toJson(row)
        ..['sharedSpaceSyncGuid'] = space
        ..['budgetSyncGuid'] = budget.syncGuid);
    }
    json['items'] = paid;
    final change = await signedChange(
        keys: keys,
        deviceId: 'a',
        hlcMillis: 100,
        entityType: 'ExpensePurchase',
        contextSyncGuid: space,
        payload: canonicalJsonEncode(json));
    expect(await engine.applyIncoming(change), ApplyOutcome.applied);
    final rows = await h.isar.expenses.where().findAll();
    final documents =
        ExpenseEvidence.decode(rows.last.paymentEvidenceJson)!.documents;
    expect(
        await ExpenseEvidenceRepository(h.isar)
            .readDocument(rows.last, documents.first),
        isNull);
    var clock = 101;
    for (final prepared in evidence.prepared.values) {
      for (final chunk
          in ExpenseEvidenceRepository.chunks(rows.first, prepared)) {
        final data = const ExpenseEvidenceChunkCodec().toJson(chunk)
          ..['sharedSpaceSyncGuid'] = space;
        final record = await signedChange(
            keys: keys,
            deviceId: 'a',
            hlcMillis: clock++,
            entityType: 'ExpenseEvidenceChunk',
            contextSyncGuid: space,
            payload: canonicalJsonEncode(data));
        expect(await engine.applyIncoming(record), ApplyOutcome.applied);
      }
    }
    expect(await h.isar.expenseEvidenceChunks.count(), documents.length);
    expect(
        await ExpenseEvidenceRepository(h.isar)
            .readDocument(rows.last, documents.first),
        isNotNull);
  });
}
