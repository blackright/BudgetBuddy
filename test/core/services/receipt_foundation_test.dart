import 'package:isar/isar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/models/reconciliation_snapshot.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/services/receipt_reconciliation_service.dart';

import 'package:budget_buddy/core/services/receipt_snapshot_repository.dart';
import 'package:budget_buddy/core/services/receipt_write_guard.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/month_rate_seal.dart';
import 'package:budget_buddy/core/models/month_end_run.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/vault/models/vault_entry.dart';
import '../../support/receipt_financial_harness.dart';

void main() {
  const service = ReceiptReconciliationService();
  test(
      'checkpoint and funding are distinct; included salary is not bank cash twice',
      () {
    final result = service.reconcile(const ReconciliationInputs(
      currency: CurrencyCode.huf,
      checkpointMinor: 600000,
      eligibleIncomeMinor: 500000,
      paidMinor: 0,
      returnedMinor: 0,
      unusedAllocationMinor: 100000,
      allocatedMinor: 100000,
      netDirectSpendingMinor: 0,
    ));
    expect(result.bankMinor, 600000);
    expect(result.freeToSpendMinor, 400000);
    expect(result.reserveMinor, 400000);
  });
  test(
      'a cash payment included in checkpoint retains cost without second bank debit',
      () {
    final result = service.reconcile(const ReconciliationInputs(
      currency: CurrencyCode.huf,
      checkpointMinor: 600000,
      eligibleIncomeMinor: 500000,
      paidMinor: 10000,
      returnedMinor: 0,
      unusedAllocationMinor: 0,
      allocatedMinor: 0,
      netDirectSpendingMinor: 10000,
      expenseCostMinor: 10000,
    ));
    expect(result.bankMinor, 600000);
    expect(result.expenseCostMinor, 10000);
    expect(result.freeToSpendMinor, 490000);
  });
  test('zero is ready while missing checkpoint withholds a verdict', () {
    ReconciliationInputs inputs(int? checkpoint) => ReconciliationInputs(
          currency: CurrencyCode.huf,
          checkpointMinor: checkpoint,
          eligibleIncomeMinor: 0,
          paidMinor: 0,
          returnedMinor: 0,
          unusedAllocationMinor: 0,
          allocatedMinor: 0,
          netDirectSpendingMinor: 0,
        );
    expect(
        service.reconcile(inputs(0)).readiness, ReconciliationReadiness.ready);
    final missing = service.reconcile(inputs(null));
    expect(missing.readiness, ReconciliationReadiness.needsReview);
    expect(missing.bankMinor, isNull);
    expect(missing.freeToSpendMinor, isNull);
  });
  test(
      'overflow is refused before integer addition and negative funding inputs fail',
      () {
    ReconciliationInputs inputs({int income = 0, int credit = 0}) =>
        ReconciliationInputs(
          currency: CurrencyCode.huf,
          checkpointMinor: 9007199254740991,
          cashCreditsAfterCheckpointMinor: credit,
          eligibleIncomeMinor: income,
          paidMinor: 0,
          returnedMinor: 0,
          unusedAllocationMinor: 0,
          allocatedMinor: 0,
          netDirectSpendingMinor: 0,
        );
    expect(() => service.reconcile(inputs(credit: 1)), throwsFormatException);
    expect(() => service.reconcile(inputs(income: -1)), throwsFormatException);
  });
  group('current-store transaction foundation', () {
    late ReceiptFinancialHarness fixture;
    late ReceiptSnapshotRepository repository;
    late ReceiptWriteGuard guard;
    setUp(() async {
      fixture = await ReceiptFinancialHarness.create();
      repository = ReceiptSnapshotRepository(fixture.db);
      guard = ReceiptWriteGuard(repository);
    });
    tearDown(() async => fixture.close());
    Future<ReceiptSourceSnapshot> read([String month = '2026-10']) =>
        repository.read(
          context: fixture.context(month),
          actorId: fixture.ownerId,
          isAccessCurrent: () => true,
        );
    test(
        'scoped source hash is stable; unrelated owner rows do not leak or invalidate',
        () async {
      final before = await read();
      expect(before.canReviewWrite, isTrue);
      await fixture.db.writeTxn(() => fixture.db.expenses
          .put(fixture.expense(owner: fixture.ownerId + 100)));
      final after = await read();
      expect(after.fingerprint, before.fingerprint);
      expect(after.sourceCounts['expenses'], 0);
      expect(() => after.sourceCounts['expenses'] = 9, throwsUnsupportedError);
      expect(() => after.blockers.add(ReceiptBlocker.sealedMonth),
          throwsUnsupportedError);
    });
    test(
        'accepted guard writes only in disposable transaction; stale source is refused',
        () async {
      final before = await read();
      await guard.run(
          previews: [before],
          actorId: fixture.ownerId,
          isAccessCurrent: () => true,
          write: () async {
            await fixture.db.expenses.put(fixture.expense());
          });
      expect(await fixture.db.expenses.count(), 1);
      var called = false;
      await expectLater(
          guard.run(
              previews: [before],
              actorId: fixture.ownerId,
              isAccessCurrent: () => true,
              write: () async {
                called = true;
              }),
          throwsA(isA<ReceiptGuardException>()
              .having((e) => e.code, 'code', 'stalePreview')));
      expect(called, isFalse);
      expect(await fixture.db.expenses.count(), 1);
    });
    test(
        'callback failure and access loss both roll back proposed money writes',
        () async {
      final before = await read();
      await expectLater(
          guard.run(
              previews: [before],
              actorId: fixture.ownerId,
              isAccessCurrent: () => true,
              write: () async {
                await fixture.db.expenses.put(fixture.expense());
                throw StateError('simulated required history failure');
              }),
          throwsStateError);
      expect(await fixture.db.expenses.count(), 0);
      var active = true;
      await expectLater(
          guard.run(
              previews: [before],
              actorId: fixture.ownerId,
              isAccessCurrent: () => active,
              write: () async {
                await fixture.db.expenses.put(fixture.expense());
                active = false;
              }),
          throwsA(isA<ReceiptGuardException>()
              .having((e) => e.code, 'code', 'accessChanged')));
      expect(await fixture.db.expenses.count(), 0);
      expect((await read()).fingerprint, before.fingerprint);
    });
    test('wrong owner and malformed month fail before source access', () async {
      await expectLater(
          repository.read(
              context: fixture.context(),
              actorId: fixture.ownerId + 999,
              isAccessCurrent: () => true),
          throwsA(isA<ReceiptGuardException>()));
      await expectLater(read('2026-13'), throwsA(isA<ReceiptGuardException>()));
      final absent = await read('2026-11');
      expect(absent.blockers, contains(ReceiptBlocker.missingMonth));
    });
    test(
        'missing opening review blocks a write without becoming a zero balance',
        () async {
      await fixture.db.writeTxn(() async {
        final month =
            (await fixture.db.monthlyBudgets.where().findAll()).single;
        month.openingBalanceConfirmed = false;
        await fixture.db.monthlyBudgets.put(month);
      });
      final before = await read();
      expect(before.blockers, contains(ReceiptBlocker.missingOpeningReview));
      await expectLater(
          guard.run(
              previews: [before],
              actorId: fixture.ownerId,
              isAccessCurrent: () => true,
              write: () async {}),
          throwsA(isA<ReceiptGuardException>()
              .having((e) => e.code, 'code', 'missingOpeningReview')));
    });
    test('a sealed second affected month prevents the entire operation',
        () async {
      await fixture.db
          .writeTxn(() => fixture.db.monthlyBudgets.put(MonthlyBudget()
            ..profileId = fixture.ownerId
            ..yearMonth = '2026-11'
            ..baseAvailableAmount = 0
            ..openingBalanceConfirmed = true
            ..createdAt = DateTime.utc(2026, 11)
            ..updatedAt = DateTime.utc(2026, 11)));
      final first = await read();
      final second = await read('2026-11');
      await fixture.db
          .writeTxn(() => fixture.db.monthRateSeals.put(MonthRateSeal()
            ..yearMonth = '2026-11'
            ..status = SealStatus.sealed
            ..asOf = DateTime.utc(2026, 11)
            ..fetchedAt = DateTime.utc(2026, 11)
            ..updatedAt = DateTime.utc(2026, 11)));
      var called = false;
      await expectLater(
          guard.run(
              previews: [first, second],
              actorId: fixture.ownerId,
              isAccessCurrent: () => true,
              write: () async {
                called = true;
              }),
          throwsA(isA<ReceiptGuardException>()
              .having((e) => e.code, 'code', 'sealedMonth')));
      expect(called, isFalse);
    });
    test('settled or swept months are explicitly blocked', () async {
      await fixture.db.writeTxn(() async {
        await fixture.db.monthEndRuns.put(MonthEndRun()
          ..syncGuid = 'fixture-run'
          ..profileId = fixture.ownerId
          ..contextGuid = 'personal-fixture'
          ..yearMonth = '2026-10'
          ..destinationMonth = '2026-11'
          ..currency = 'HUF'
          ..reportJson = '{}'
          ..fingerprint = 'fixture'
          ..actor = 'fixture'
          ..createdAt = DateTime.utc(2026, 10));
        await fixture.db.vaultEntrys.put(VaultEntry()
          ..profileId = fixture.ownerId
          ..operationKey = 'fixture-sweep'
          ..kind = 'sweep'
          ..yearMonth = '2026-10'
          ..amountMinor = 0
          ..balanceAfterMinor = 0
          ..currency = 'HUF'
          ..createdAt = DateTime.utc(2026, 10));
      });
      final blocked = await read();
      expect(
          blocked.blockers,
          containsAll(
              [ReceiptBlocker.settledMonth, ReceiptBlocker.sweptMonth]));
      await expectLater(
          guard.run(
              previews: [blocked],
              actorId: fixture.ownerId,
              isAccessCurrent: () => true,
              write: () async {}),
          throwsA(isA<ReceiptGuardException>()));
    });
    test('shared viewer cannot write and revocation invalidates access',
        () async {
      final space = SharedSpace()
        ..name = 'Fixture space'
        ..currency = PrimaryCurrency.huf
        ..createdByProfileId = fixture.ownerId
        ..createdAt = DateTime.utc(2026, 10);
      final member = SharedMember()
        ..profileId = fixture.ownerId
        ..role = SharedMemberRole.viewer
        ..joinedAt = DateTime.utc(2026, 10);
      await fixture.db.writeTxn(() async {
        space.id = await fixture.db.sharedSpaces.put(space);
        member.sharedSpaceId = space.id;
        member.id = await fixture.db.sharedMembers.put(member);
        await fixture.db.monthlyBudgets.put(MonthlyBudget()
          ..sharedSpaceId = space.id
          ..yearMonth = '2026-10'
          ..baseAvailableAmount = 0
          ..openingBalanceConfirmed = true
          ..createdAt = DateTime.utc(2026, 10)
          ..updatedAt = DateTime.utc(2026, 10));
      });
      final context =
          ContextRef.shared(spaceId: space.id, yearMonth: '2026-10');
      Future<ReceiptSourceSnapshot> shared() => repository.read(
          context: context,
          actorId: fixture.ownerId,
          isAccessCurrent: () => true);
      final preview = await shared();
      await expectLater(
          guard.run(
              previews: [preview],
              actorId: fixture.ownerId,
              isAccessCurrent: () => true,
              write: () async {}),
          throwsA(isA<ReceiptGuardException>()
              .having((e) => e.code, 'code', 'writeNotPermitted')));
      await fixture.db.writeTxn(() async {
        member.revokedAt = DateTime.utc(2026, 10, 28);
        await fixture.db.sharedMembers.put(member);
      });
      await expectLater(
          shared(),
          throwsA(isA<ReceiptGuardException>()
              .having((e) => e.code, 'code', 'notActiveMember')));
    });
  });
}
