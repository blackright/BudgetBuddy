import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/expense_evidence_chunk.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/services/expense_evidence.dart';
import 'package:budget_buddy/features/expenses/repositories/expense_evidence_repository.dart';
import 'package:budget_buddy/features/sync/domain/codecs/expense_evidence_chunk_codec.dart';
import 'package:budget_buddy/features/sync/domain/codecs/expense_codec.dart';
import 'package:budget_buddy/features/sync/domain/sync_codec.dart';
import 'package:budget_buddy/features/sync/repositories/sync_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'support/sync_harness.dart';
import 'support/change_factory.dart';

void main() {
  late SyncTestHarness h;
  late DeviceKeys owner;
  late SyncEngine engine;
  late Expense expense;
  late String spaceGuid;
  setUp(() async {
    h = await SyncTestHarness.create();
    owner = await DeviceKeys.generate('owner');
    await h.createSpaceAt(localId: 42);
    spaceGuid = await h.spaceGuid(42);
    await h.addSignedMember(
        spaceId: 42, keys: owner, role: SharedMemberRole.owner);
    engine = SyncEngine(h.isar, trustedKeys: {'owner': owner.publicKey});
    expense = Expense(
        profileId: 0,
        sharedSpaceId: 42,
        yearMonth: '2026-10',
        title: 'Rice',
        amount: 10000,
        currency: 'HUF',
        categoryId: 'food',
        date: DateTime(2026, 10, 24),
        budgetId: 1);
    await h.isar
        .writeTxn(() async => expense.id = await h.isar.expenses.put(expense));
  });
  tearDown(() async => h.close());
  test(
      'signed content resolves portable owner, waits for missing chunks and retries idempotently',
      () async {
    final bytes = List<int>.filled(evidenceChunkBytes + 10, 32)
      ..setRange(0, 5, [37, 80, 68, 70, 45]);
    final prepared = await prepareEvidence(
        bytes: bytes, name: 'receipt.pdf', role: 'receipt');
    final chunks = ExpenseEvidenceRepository.chunks(expense, prepared);
    expense.paymentEvidenceJson =
        ExpenseEvidence(profileChosen: true, documents: [prepared.document])
            .encode();
    await h.isar.writeTxn(() => h.isar.expenses.put(expense));
    final repository = ExpenseEvidenceRepository(h.isar);
    for (var index = 0; index < chunks.length; index++) {
      final json = const ExpenseEvidenceChunkCodec().toJson(chunks[index])
        ..['sharedSpaceSyncGuid'] = spaceGuid;
      final change = await signedChange(
          keys: owner,
          deviceId: 'phone-a',
          hlcMillis: DateTime(2026, 10, 25).millisecondsSinceEpoch + index,
          entityType: 'ExpenseEvidenceChunk',
          entitySyncGuid: chunks[index].syncGuid,
          contextSyncGuid: spaceGuid,
          contextLocalId: 7,
          payload: canonicalJsonEncode(json));
      expect(await engine.applyIncoming(change), ApplyOutcome.applied);
      expect(await engine.applyIncoming(change), ApplyOutcome.duplicate);
      if (index == 0) {
        expect(
            await repository.readDocument(expense, prepared.document), isNull);
      }
    }
    expect(await repository.readDocument(expense, prepared.document), bytes);
    expect(
        (await h.isar.expenseEvidenceChunks.where().findFirst())!.sharedSpaceId,
        42);
  });
  test('viewer and mismatched context cannot inject content', () async {
    await h.setMemberHead(
        spaceId: 42, keys: owner, role: SharedMemberRole.viewer, version: 2);
    final prepared = await prepareEvidence(
        bytes: [37, 80, 68, 70, 45, 49], name: 'receipt.pdf', role: 'receipt');
    final chunk = ExpenseEvidenceRepository.chunks(expense, prepared).single;
    final json = const ExpenseEvidenceChunkCodec().toJson(chunk)
      ..['sharedSpaceSyncGuid'] = spaceGuid;
    final record = await signedChange(
        keys: owner,
        deviceId: 'phone-a',
        hlcMillis: DateTime(2026, 10, 25).millisecondsSinceEpoch,
        entityType: 'ExpenseEvidenceChunk',
        entitySyncGuid: chunk.syncGuid,
        contextSyncGuid: spaceGuid,
        payload: canonicalJsonEncode(json));
    expect(
        await engine.applyIncoming(record), ApplyOutcome.droppedUnauthorized);
    expect(await h.isar.expenseEvidenceChunks.count(), 0);
  });
  test(
      'declared files can finish arriving after sealing without permitting a financial edit',
      () async {
    final prepared = await prepareEvidence(
        bytes: [37, 80, 68, 70, 45, 49], name: 'Receipt.pdf', role: 'receipt');
    expense.paymentEvidenceJson =
        ExpenseEvidence(profileChosen: true, documents: [prepared.document])
            .encode();
    await h.isar.writeTxn(() => h.isar.expenses.put(expense));
    await h.sealMonth('2026-10');
    final chunk = ExpenseEvidenceRepository.chunks(expense, prepared).single;
    final json = const ExpenseEvidenceChunkCodec().toJson(chunk)
      ..['sharedSpaceSyncGuid'] = spaceGuid;
    final file = await signedChange(
        keys: owner,
        deviceId: 'phone-a',
        hlcMillis: DateTime(2026, 10, 25).millisecondsSinceEpoch,
        entityType: 'ExpenseEvidenceChunk',
        entitySyncGuid: chunk.syncGuid,
        contextSyncGuid: spaceGuid,
        payload: canonicalJsonEncode(json));
    expect(await engine.applyIncoming(file), ApplyOutcome.applied);
    expense.amount++;
    final financial = const ExpenseCodec().toJson(expense)
      ..['sharedSpaceSyncGuid'] = spaceGuid;
    final change = await signedChange(
        keys: owner,
        deviceId: 'phone-a',
        hlcMillis: DateTime(2026, 10, 25).millisecondsSinceEpoch + 1,
        contextSyncGuid: spaceGuid,
        payload: canonicalJsonEncode(financial));
    expect(
        await engine.applyIncoming(change), ApplyOutcome.droppedUnauthorized);
    expect((await h.isar.expenses.get(expense.id))!.amount, 10000);
  });
}
