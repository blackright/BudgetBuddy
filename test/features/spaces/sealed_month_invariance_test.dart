import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/money.dart';
import 'package:budget_buddy/core/models/month_rate_seal.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/features/engine/currency_conversion.dart';
import 'package:budget_buddy/features/spaces/domain/shared_member_key.dart';
import 'package:budget_buddy/features/spaces/repositories/space_role_guard.dart';
import 'package:budget_buddy/features/spaces/repositories/space_write_guard.dart';
import 'package:budget_buddy/features/sync/domain/codecs/expense_codec.dart';
import 'package:budget_buddy/features/sync/domain/sync_codec.dart';
import 'package:budget_buddy/features/sync/domain/sync_guid.dart';
import 'package:budget_buddy/features/sync/repositories/sync_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../sync/support/change_factory.dart';
import '../sync/support/sync_harness.dart';

/// T043: sealed-month invariance across devices (`contracts/role-authorization.md`
/// §3, FR-011, SC-004).
///
/// A sealed month is content-immutable **for every role and on every device**:
/// its records are exchanged once (while unsealed) and then refused on both the
/// local write path and the apply path (T047). Each device re-renders the sealed
/// month's totals from its *own* seal, so identical seals re-price identically in
/// every currency.
Expense _expense(
        {required int id,
        int amount = 100,
        String yearMonth = '2026-03',
        String? syncGuid}) =>
    (Expense(
      id: id,
      profileId: 1,
      sharedSpaceId: 1,
      yearMonth: yearMonth,
      title: 'Coffee',
      amount: amount,
      currency: 'usd',
      categoryId: 'general',
      date: DateTime.utc(2026, 3, 5),
      budgetId: 1,
    ))
      ..syncGuid = syncGuid ?? newSyncGuid();

void main() {
  late SyncTestHarness harnessA;
  late SyncTestHarness harnessB;
  late DeviceKeys owner;
  late DeviceKeys editor;
  late SyncEngine engineA;
  late SyncEngine engineB;
  late String spaceGuid;

  Future<void> seedSpace(SyncTestHarness h) async {
    await h.createSpaceAt(localId: 1, syncGuid: spaceGuid);
    await h.addSignedMember(
        spaceId: 1, keys: owner, role: SharedMemberRole.owner);
    await h.addSignedMember(
        spaceId: 1, keys: editor, role: SharedMemberRole.editor);
  }

  Future expenseChange(
    DeviceKeys author, {
    required String guid,
    int millis = 1000,
    int id = 1,
    int amount = 100,
    String yearMonth = '2026-03',
  }) async {
    final json = const ExpenseCodec().toJson(
        _expense(id: id, amount: amount, yearMonth: yearMonth, syncGuid: guid));
    json['sharedSpaceSyncGuid'] = spaceGuid;
    return signedChange(
      keys: author,
      deviceId: 'A',
      hlcMillis: millis,
      entityType: 'Expense',
      entitySyncGuid: guid,
      contextSyncGuid: spaceGuid,
      payload: canonicalJsonEncode(json),
    );
  }

  /// Writes a seal with a real four-currency rate table so totals can be re-priced
  /// deterministically on each device.
  Future<void> sealWithRates(SyncTestHarness h, String yearMonth) =>
      h.isar.writeTxn(() async {
        await h.isar.monthRateSeals.put(
          MonthRateSeal()
            ..yearMonth = yearMonth
            ..status = SealStatus.sealed
            ..ratesUsd = 1.0
            ..ratesHuf = 350.0
            ..ratesEur = 0.92
            ..ratesCad = 1.35
            ..asOf = DateTime.utc(2026, 3, 31)
            ..fetchedAt = DateTime.utc(2026, 3, 31)
            ..updatedAt = DateTime.utc(2026, 3, 31),
        );
      });

  setUp(() async {
    harnessA = await SyncTestHarness.create();
    harnessB = await SyncTestHarness.create();
    owner = await DeviceKeys.generate('owner');
    editor = await DeviceKeys.generate('editor');
    final trusted = {
      owner.identityId: owner.publicKey,
      editor.identityId: editor.publicKey,
    };
    engineA = SyncEngine(harnessA.isar, trustedKeys: trusted);
    engineB = SyncEngine(harnessB.isar, trustedKeys: trusted);
    spaceGuid = newSyncGuid();
    await seedSpace(harnessA);
    await seedSpace(harnessB);
  });

  tearDown(() async {
    await harnessA.close();
    await harnessB.close();
  });

  test('a month is exchanged once, then frozen on every peer (FR-011, R6)',
      () async {
    final exp1 = newSyncGuid();
    final exp2 = newSyncGuid();
    final exp3 = newSyncGuid();

    // 1. Unsealed: the change is exchanged normally.
    expect(
      await engineB.applyIncoming(
          await expenseChange(editor, guid: exp1, millis: 1000, amount: 100)),
      ApplyOutcome.applied,
    );
    expect((await harnessB.expenseByGuid(exp1))!.amount, 100);

    // 2. The Owner seals the month on both devices.
    await sealWithRates(harnessA, '2026-03');
    await sealWithRates(harnessB, '2026-03');

    // 3. A later edit to the sealed month is refused on **both** peers — even
    //    though the author is an Editor and the signature verifies.
    expect(
      await engineA.applyIncoming(
          await expenseChange(editor, guid: exp1, millis: 2000, amount: 999)),
      ApplyOutcome.droppedUnauthorized,
    );
    expect(
      await engineB.applyIncoming(
          await expenseChange(editor, guid: exp1, millis: 2000, amount: 999)),
      ApplyOutcome.droppedUnauthorized,
    );
    expect((await harnessB.expenseByGuid(exp1))!.amount, 100,
        reason: 'the sealed month keeps the content it froze with');

    // 4. A brand-new record in the sealed month is dropped too.
    expect(
      await engineB.applyIncoming(
          await expenseChange(editor, guid: exp2, millis: 3000, id: 2)),
      ApplyOutcome.droppedUnauthorized,
    );
    expect(await harnessB.expenseByGuid(exp2), isNull);

    // 5. An unsealed month still exchanges (only the sealed one is frozen).
    expect(
      await engineB.applyIncoming(await expenseChange(editor,
          guid: exp3, millis: 4000, id: 3, yearMonth: '2026-04')),
      ApplyOutcome.applied,
    );
    expect(await harnessB.expenseByGuid(exp3), isNotNull);
  });

  test('a sealed month is also refused on the local write path (both paths)',
      () async {
    await sealWithRates(harnessA, '2026-03');
    final guard = SpaceWriteGuard(harnessA.isar);

    // The editor holds a valid role, so the only reason to refuse is the seal.
    await expectLater(
      guard.assertSharedMoneyWrite(
        sharedSpaceId: 1,
        actingProfileId: sharedMemberKey(editor.identityId),
        yearMonth: '2026-03',
      ),
      throwsA(isA<UnauthorizedSpaceAction>()),
    );
  });

  test(
      'each device re-renders the sealed month identically from its own seal '
      '(SC-004)', () async {
    await sealWithRates(harnessA, '2026-03');
    await sealWithRates(harnessB, '2026-03');

    final sealA = await harnessA.isar.monthRateSeals
        .filter()
        .yearMonthEqualTo('2026-03')
        .findFirst();
    final sealB = await harnessB.isar.monthRateSeals
        .filter()
        .yearMonthEqualTo('2026-03')
        .findFirst();
    final tableA = sealA!.toRateTable();
    final tableB = sealB!.toRateTable();
    expect(tableA, isNotNull);
    expect(tableB, isNotNull);

    // Identical seals must price the same USD amount identically in every
    // supported currency, on both devices.
    const amount = Money(123456, CurrencyCode.usd);
    for (final code in CurrencyCode.values) {
      final fromA = convert(amount, code, tableA).amount;
      final fromB = convert(amount, code, tableB).amount;
      expect(
        fromA,
        fromB,
        reason: 'a sealed month re-prices identically in ${code.code} '
            'from each device\'s own seal',
      );
    }
  });
}
