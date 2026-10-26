import 'dart:convert';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/merchant.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/features/spaces/domain/shared_member_key.dart';
import 'package:budget_buddy/features/sync/repositories/change_signer.dart';
import 'package:budget_buddy/features/sync/repositories/sync_recorder.dart';
import 'package:budget_buddy/features/sync/repositories/sync_engine.dart';
import 'package:budget_buddy/features/sync/domain/change_signing.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import '../medical/repositories/medical_test_harness.dart';

void main() {
  test(
      'signed merchant/expense sync preserves missing-target metadata and older-peer fields, rejects cross-context merchant identity',
      () async {
    final a = await MedicalTestHarness.create(),
        b = await MedicalTestHarness.create();
    addTearDown(a.close);
    addTearDown(b.close);
    final pair = await Ed25519().newKeyPair(),
        key = await pair.extractPublicKey();
    final signer =
        Ed25519ChangeSigner(authorIdentityId: 'alice', keyPair: pair);
    for (final db in [a.isar, b.isar]) {
      await db.writeTxn(() async {
        await db.sharedSpaces.put(SharedSpace()
          ..id = 1
          ..syncGuid = 'space'
          ..name = 'Shared'
          ..currency = PrimaryCurrency.huf
          ..createdByProfileId = 1
          ..createdAt = DateTime(2026));
        await db.sharedMembers.put(SharedMember()
          ..sharedSpaceId = 1
          ..profileId = sharedMemberKey('alice')
          ..role = SharedMemberRole.owner
          ..authorIdentityId = 'alice'
          ..joinedAt = DateTime(2026));
      });
    }
    final merchant = Merchant()
      ..syncGuid = 'merchant'
      ..sharedSpaceId = 1
      ..canonicalName = 'Corner Shop'
      ..aliases = ['Shop']
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    final expense = Expense(
        profileId: 0,
        sharedSpaceId: 1,
        yearMonth: '2026-10',
        title: 'Lunch',
        amount: 1000,
        currency: 'huf',
        categoryId: 'food',
        date: DateTime(2026, 10, 1),
        budgetId: 0)
      ..merchantSyncGuid = 'merchant'
      ..merchantName = 'Corner Shop'
      ..tags = ['Work']
      ..paymentMethod = 'cash';
    final recorder = SyncRecorder(a.isar, signer: signer);
    await a.isar.writeTxn(() async {
      await a.isar.merchants.put(merchant);
      await a.isar.expenses.put(expense);
      await recorder.recordExpense(expense);
    });
    final changes = await a.isar.changeRecords.where().findAll();
    final engine = SyncEngine(b.isar, trustedKeys: {'alice': key});
    final expenseChange = changes.singleWhere((c) => c.entityType == 'Expense');
    expect(await engine.applyIncoming(expenseChange), ApplyOutcome.applied);
    var received = (await b.isar.expenses.where().findAll()).single;
    expect(received.merchantSyncGuid, 'merchant');
    expect(received.tags, ['Work']);
    expect(await b.isar.merchants.count(), 0);
    expect(
        await engine.applyIncoming(
            changes.singleWhere((c) => c.entityType == 'Merchant')),
        ApplyOutcome.applied);
    expect((await b.isar.merchants.where().findAll()).single.aliases, ['Shop']);
    final older = ChangeRecord()
      ..contextKind = expenseChange.contextKind
      ..contextLocalId = 1
      ..contextSyncGuid = 'space'
      ..entityType = 'Expense'
      ..entitySyncGuid = expense.syncGuid
      ..entityLocalId = received.id
      ..op = 'upsert'
      ..hlcMillis = expenseChange.hlcMillis + 10
      ..hlcCounter = 0
      ..deviceId = expenseChange.deviceId
      ..authorIdentityId = 'alice'
      ..createdAt = DateTime.now();
    final payload = jsonDecode(expenseChange.payload) as Map<String, dynamic>;
    for (final field in [
      'merchantSyncGuid',
      'merchantName',
      'tags',
      'paymentMethod'
    ]) {
      payload.remove(field);
    }
    payload['title'] = 'Older peer edit';
    older.payload = jsonEncode(payload);
    older.signature = await signer.sign(changeCanonicalBytes(older));
    expect(await engine.applyIncoming(older), ApplyOutcome.applied);
    received = (await b.isar.expenses.where().findAll()).single;
    expect(received.title, 'Older peer edit');
    expect(received.paymentMethod, 'cash');
    expect(received.tags, ['Work']);
    final foreign = Merchant()
      ..syncGuid = 'foreign'
      ..sharedSpaceId = 2
      ..canonicalName = 'Private to another space'
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    await b.isar.writeTxn(() => b.isar.merchants.put(foreign));
    final attack = changes.singleWhere((c) => c.entityType == 'Merchant')
      ..entitySyncGuid = 'foreign'
      ..hlcMillis = older.hlcMillis + 10;
    final attackPayload = jsonDecode(attack.payload) as Map<String, dynamic>;
    attackPayload['syncGuid'] = 'foreign';
    attack.payload = jsonEncode(attackPayload);
    attack.signature = await signer.sign(changeCanonicalBytes(attack));
    expect(
        await engine.applyIncoming(attack), ApplyOutcome.droppedUnauthorized);
    expect((await b.isar.merchants.get(foreign.id))!.sharedSpaceId, 2);
  });
}
