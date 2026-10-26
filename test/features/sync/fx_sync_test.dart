import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/live_rate_set.dart';
import 'package:budget_buddy/core/services/fx_booking_service.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/sync/domain/codecs/expense_codec.dart';
import 'package:budget_buddy/features/sync/domain/codecs/reimbursement_codec.dart';
import 'package:budget_buddy/features/sync/domain/sync_codec.dart';
import 'package:budget_buddy/features/sync/repositories/sync_engine.dart';
import 'support/sync_harness.dart';
import 'support/change_factory.dart';

void main() {
  late SyncTestHarness h;
  late DeviceKeys keys;
  late SyncEngine engine;
  late String spaceGuid;
  late Expense original;
  late Map<String, Object?> expensePayload;
  setUp(() async {
    h = await SyncTestHarness.create();
    await h.createSpaceAt(localId: 42);
    keys = await DeviceKeys.generate('owner');
    await h.addSignedMember(
        spaceId: 42, keys: keys, role: SharedMemberRole.owner);
    spaceGuid = await h.spaceGuid(42);
    engine = SyncEngine(h.isar, trustedKeys: {'owner': keys.publicKey});
    original = Expense(
        profileId: 0,
        sharedSpaceId: 42,
        yearMonth: '2026-01',
        title: 'Foreign payment',
        amount: 2000,
        currency: 'EUR',
        categoryId: 'food',
        date: DateTime(2026, 1, 3),
        budgetId: 0);
    await h.isar.writeTxn(() async {
      final space = (await h.isar.sharedSpaces.get(42))!
        ..currency = PrimaryCurrency.usd;
      await h.isar.sharedSpaces.put(space);
      await h.isar.liveRateSets.put(LiveRateSet()
        ..ratesUsd = 1
        ..ratesEur = .8
        ..ratesHuf = 400
        ..ratesCad = 1.4
        ..fetchedAt = DateTime(2026));
      await FxBookingService(h.isar).prepareExpense(original);
      original.id = await h.isar.expenses.put(original);
    });
    expensePayload = const ExpenseCodec().toJson(original)
      ..['sharedSpaceSyncGuid'] = spaceGuid;
  });
  tearDown(() => h.close());

  test(
      'signed delivery retains source booking at different receiver rates and replay is idempotent',
      () async {
    await h.isar.writeTxn(() async {
      await h.isar.expenses.delete(original.id);
      final rates = (await h.isar.liveRateSets.get(1))!..ratesEur = 1;
      await h.isar.liveRateSets.put(rates);
    });
    final change = await signedChange(
        keys: keys,
        deviceId: 'sender',
        hlcMillis: 100,
        contextSyncGuid: spaceGuid,
        payload: canonicalJsonEncode(expensePayload));
    expect(await engine.applyIncoming(change), ApplyOutcome.applied);
    expect(await engine.applyIncoming(change), ApplyOutcome.duplicate);
    final received = (await h.isar.expenses.where().findAll()).single;
    expect(received.fxHistoryJson, original.fxHistoryJson);
    expect(expenseAccountingMoney(received).minorUnits, 2500);
  });

  test(
      'refund before its payment rolls back and can retry after the signed payment arrives',
      () async {
    final refund = Reimbursement(
        profileId: 0,
        sharedSpaceId: 42,
        expenseId: original.id,
        originYearMonth: original.yearMonth,
        amount: 2000,
        currency: 'EUR',
        date: original.date);
    await h.isar.writeTxn(() => FxBookingService(h.isar).prepareRefund(refund));
    final payload = const ReimbursementCodec().toJson(refund)
      ..['sharedSpaceSyncGuid'] = spaceGuid
      ..['expenseSyncGuid'] = original.syncGuid;
    await h.isar.writeTxn(() => h.isar.expenses.delete(original.id));
    final change = await signedChange(
        keys: keys,
        deviceId: 'sender',
        hlcMillis: 200,
        contextSyncGuid: spaceGuid,
        entityType: 'Reimbursement',
        payload: canonicalJsonEncode(payload));
    await expectLater(engine.applyIncoming(change), throwsStateError);
    expect(await h.isar.reimbursements.count(), 0);
    expect(await h.isar.changeRecords.count(), 0);
    final payment = await signedChange(
        keys: keys,
        deviceId: 'sender',
        hlcMillis: 100,
        contextSyncGuid: spaceGuid,
        payload: canonicalJsonEncode(expensePayload));
    expect(await engine.applyIncoming(payment), ApplyOutcome.applied);
    expect(await engine.applyIncoming(change), ApplyOutcome.applied);
    final received = (await h.isar.reimbursements.where().findAll()).single;
    expect(reimbursementAccountingMoney(received).minorUnits, 2500);
    expect(received.expenseId,
        (await h.isar.expenses.where().findAll()).single.id);
  });

  test('a valid signature cannot remove evidence or assign another context',
      () async {
    final remove = Map<String, Object?>.from(expensePayload)
      ..['fxHistoryJson'] = null;
    final change = await signedChange(
        keys: keys,
        deviceId: 'sender',
        hlcMillis: 200,
        contextSyncGuid: spaceGuid,
        payload: canonicalJsonEncode(remove));
    await expectLater(engine.applyIncoming(change), throwsStateError);
    expect((await h.isar.expenses.get(original.id))!.fxHistoryJson,
        original.fxHistoryJson);
    final foreign = original.copyForEditing()
      ..profileId = 999
      ..sharedSpaceId = null;
    await expectLater(
        FxBookingService(h.isar)
            .validateRemoteExpense(foreign, null, carriesFx: true),
        throwsStateError);
  });
  test(
      'signed prefix rewrites are refused even when the replacement arithmetic is valid',
      () async {
    final history = jsonDecode(original.fxHistoryJson!) as Map<String, dynamic>;
    (history['revisions'] as List).first['id'] = 'rewritten-revision';
    final payload = Map<String, Object?>.from(expensePayload)
      ..['fxHistoryJson'] = jsonEncode(history);
    final change = await signedChange(
        keys: keys,
        deviceId: 'sender',
        hlcMillis: 200,
        contextSyncGuid: spaceGuid,
        payload: canonicalJsonEncode(payload));
    await expectLater(engine.applyIncoming(change), throwsFormatException);
    expect((await h.isar.expenses.get(original.id))!.fxHistoryJson,
        original.fxHistoryJson);
  });
  test(
      'overlapping signed offline refunds cannot consume the same original units twice',
      () async {
    final first = Reimbursement(
        profileId: 0,
        sharedSpaceId: 42,
        expenseId: original.id,
        originYearMonth: original.yearMonth,
        amount: 333,
        currency: 'EUR',
        date: original.date);
    final second = Reimbursement(
        profileId: 0,
        sharedSpaceId: 42,
        expenseId: original.id,
        originYearMonth: original.yearMonth,
        amount: 333,
        currency: 'EUR',
        date: original.date);
    await h.isar.writeTxn(() async {
      // Two offline authors both saw the same unrefunded original payment.
      await FxBookingService(h.isar).prepareRefund(first);
      await FxBookingService(h.isar).prepareRefund(second);
    });
    Future<ApplyOutcome> deliver(Reimbursement row, int clock) async {
      final payload = const ReimbursementCodec().toJson(row)
        ..['sharedSpaceSyncGuid'] = spaceGuid
        ..['expenseSyncGuid'] = original.syncGuid;
      return engine.applyIncoming(await signedChange(
          keys: keys,
          deviceId: 'sender',
          hlcMillis: clock,
          contextSyncGuid: spaceGuid,
          entityType: 'Reimbursement',
          payload: canonicalJsonEncode(payload)));
    }

    expect(await deliver(first, 100), ApplyOutcome.applied);
    await expectLater(deliver(second, 200), throwsStateError);
    expect(await h.isar.reimbursements.count(), 1);
    expect(
        reimbursementAccountingMoney(
                (await h.isar.reimbursements.where().findAll()).single)
            .minorUnits,
        416);
  });
  test(
      'deleted-payment refunds retain booked money and orphan status through update and fresh bootstrap',
      () async {
    final refund = Reimbursement(
        profileId: 0,
        sharedSpaceId: 42,
        expenseId: original.id,
        originYearMonth: original.yearMonth,
        amount: 333,
        currency: 'EUR',
        date: original.date);
    await h.isar.writeTxn(() => FxBookingService(h.isar).prepareRefund(refund));
    final payload = const ReimbursementCodec().toJson(refund)
      ..['sharedSpaceSyncGuid'] = spaceGuid
      ..['expenseSyncGuid'] = original.syncGuid;
    final normal = await signedChange(
        keys: keys,
        deviceId: 'sender',
        hlcMillis: 100,
        contextSyncGuid: spaceGuid,
        entityType: 'Reimbursement',
        payload: canonicalJsonEncode(payload));
    expect(await engine.applyIncoming(normal), ApplyOutcome.applied);
    await h.isar.writeTxn(() => h.isar.expenses.delete(original.id));
    payload
      ..['orphaned'] = true
      ..['expenseSyncGuid'] = null;
    final orphan = await signedChange(
        keys: keys,
        deviceId: 'sender',
        hlcMillis: 200,
        contextSyncGuid: spaceGuid,
        entityType: 'Reimbursement',
        payload: canonicalJsonEncode(payload));
    expect(await engine.applyIncoming(orphan), ApplyOutcome.applied);
    expect((await h.isar.reimbursements.where().findAll()).single.fxHistoryJson,
        refund.fxHistoryJson);
    final fresh = await SyncTestHarness.create();
    addTearDown(fresh.close);
    await fresh.createSpaceAt(localId: 99, syncGuid: spaceGuid);
    await fresh.addSignedMember(
        spaceId: 99, keys: keys, role: SharedMemberRole.owner);
    expect(
        await SyncEngine(fresh.isar, trustedKeys: {'owner': keys.publicKey})
            .applyIncoming(orphan),
        ApplyOutcome.applied);
    final received = (await fresh.isar.reimbursements.where().findAll()).single;
    expect(received.sharedSpaceId, 99);
    expect(received.expenseId, isNull);
    expect(received.orphaned, isTrue);
    expect(received.fxHistoryJson, refund.fxHistoryJson);
    expect(reimbursementAccountingMoney(received).minorUnits, 416);
  });
}
