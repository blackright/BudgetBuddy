import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/models/balance_checkpoint.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/services/balance_checkpoint_service.dart';
import 'package:budget_buddy/core/services/financial_adoption_service.dart';
import 'package:budget_buddy/core/services/receipt_snapshot_repository.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import '../../support/receipt_financial_harness.dart';

void main() {
  late ReceiptFinancialHarness h;
  late BalanceCheckpointService service;
  final now = DateTime.utc(2026, 10, 28, 16);
  setUp(() async {
    h = await ReceiptFinancialHarness.create();
    final adoption = FinancialAdoptionService(h.db, clock: () => now);
    final p = await adoption.preview(
        context: h.context(), actorId: h.ownerId, isAccessCurrent: () => true);
    await adoption.confirm(
        preview: p, operationKey: 'start', isAccessCurrent: () => true);
    service = BalanceCheckpointService(h.db, clock: () => now);
  });
  tearDown(() async => h.close());
  Future<CheckpointSources> load() => service.load(
      context: h.context(), actorId: h.ownerId, isAccessCurrent: () => true);
  CheckpointDraft draft(
          {int amount = 600000, List<MovementChoice> choices = const []}) =>
      CheckpointDraft(
          balanceMinor: amount,
          balanceAsOf: DateTime.utc(2026, 10, 28, 12),
          localZone: 'Europe/Budapest',
          pool: 'My budget bank and cash',
          choices: choices);

  test('save and retry preserve legacy balance; re-review appends revision',
      () async {
    final before = await h.db.monthlyBudgets.where().exportJson();
    final sources = await load();
    final p = await service.preview(
        sources: sources, draft: draft(amount: 0), isAccessCurrent: () => true);
    expect(p.canConfirm, isTrue);
    final first = await service.confirm(
        preview: p, operationKey: 'one', isAccessCurrent: () => true);
    final retry = await service.confirm(
        preview: p, operationKey: 'one', isAccessCurrent: () => true);
    expect(first.guid, retry.guid);
    final next = await service.preview(
        sources: await load(),
        draft: draft(amount: 10),
        isAccessCurrent: () => true);
    final second = await service.confirm(
        preview: next, operationKey: 'two', isAccessCurrent: () => true);
    expect(second.previousCheckpointGuid, first.guid);
    expect(second.revision, 2);
    expect(await h.db.monthlyBudgets.where().exportJson(), before);
  });
  test('included expense retains cost and cash', () async {
    await h.db.writeTxn(() async {
      await h.db.expenses
          .put(h.expense()..paidAt = DateTime.utc(2026, 10, 28, 11));
    });
    final sources = await load();
    final m = sources.movements.single;
    final p = await service.preview(
        sources: sources,
        draft: draft(choices: [
          MovementChoice(
              key: m.key,
              revision: m.revision,
              role: 'included',
              actualAt: m.actualAt)
        ]),
        isAccessCurrent: () => true);
    expect(p.cash.bankMinor, 600000);
    final record = await service.confirm(
        preview: p, operationKey: 'expense', isAccessCurrent: () => true);
    expect(
        await h.db.movementInclusions
            .filter()
            .checkpointGuidEqualTo(record.guid)
            .count(),
        1);
    expect((await h.db.expenses.where().findFirst())!.amount, 10000);
  });
  test('changed cross-month cash source refuses stale confirmation', () async {
    late int id;
    await h.db.writeTxn(() async {
      id = await h.db.expenses.put(
          h.expense(month: '2026-11')..paidAt = DateTime.utc(2026, 10, 28, 11));
    });
    final sources = await load();
    final m = sources.movements.single;
    final p = await service.preview(
        sources: sources,
        draft: draft(choices: [
          MovementChoice(
              key: m.key,
              revision: m.revision,
              role: 'included',
              actualAt: m.actualAt)
        ]),
        isAccessCurrent: () => true);
    await h.db.writeTxn(() async {
      final expense = (await h.db.expenses.get(id))!..amount = 20000;
      await h.db.expenses.put(expense);
    });
    await expectLater(
        service.confirm(
            preview: p, operationKey: 'stale', isAccessCurrent: () => true),
        throwsA(isA<ReceiptGuardException>()));
    expect(await h.db.balanceCheckpoints.count(), 0);
  });
  test('invalid pool/timezone/month and future dates cannot save', () async {
    final sources = await load();
    for (final d in [
      CheckpointDraft(
          balanceMinor: 1,
          balanceAsOf: now,
          localZone: 'Unknown',
          pool: 'Bank',
          choices: []),
      CheckpointDraft(
          balanceMinor: 1,
          balanceAsOf: now,
          localZone: 'UTC',
          pool: ' ',
          choices: []),
      CheckpointDraft(
          balanceMinor: 1,
          balanceAsOf: DateTime.utc(2026, 11, 1),
          localZone: 'UTC',
          pool: 'Bank',
          choices: []),
    ]) {
      final p = await service.preview(
          sources: sources, draft: d, isAccessCurrent: () => true);
      expect(p.canConfirm, isFalse);
      await expectLater(
          service.confirm(
              preview: p, operationKey: 'bad', isAccessCurrent: () => true),
          throwsA(isA<ReceiptGuardException>()));
    }
    expect(await h.db.balanceCheckpoints.count(), 0);
  });
  test('access loss after insert rolls back checkpoint and inclusions',
      () async {
    await h.db.writeTxn(() async {
      await h.db.expenses
          .put(h.expense()..paidAt = DateTime.utc(2026, 10, 28, 11));
    });
    final sources = await load();
    final movement = sources.movements.single;
    final p = await service.preview(
        sources: sources,
        draft: draft(choices: [
          MovementChoice(
              key: movement.key,
              revision: movement.revision,
              role: 'included',
              actualAt: movement.actualAt)
        ]),
        isAccessCurrent: () => true);
    var calls = 0;
    await expectLater(
        service.confirm(
            preview: p,
            operationKey: 'rollback',
            isAccessCurrent: () => ++calls < 6),
        throwsA(isA<ReceiptGuardException>()));
    expect(await h.db.balanceCheckpoints.count(), 0);
    expect(await h.db.movementInclusions.count(), 0);
  });
  test('legacy return recorded date is not guessed as receipt date', () async {
    await h.db.writeTxn(() async {
      final expense = h.expense()..paidAt = DateTime.utc(2026, 10, 28, 11);
      expense.id = await h.db.expenses.put(expense);
      await h.db.reimbursements.put(Reimbursement(
          profileId: h.ownerId,
          expenseId: expense.id,
          originYearMonth: '2026-10',
          amount: 5000,
          currency: 'huf',
          date: DateTime.utc(2026, 10, 28, 15)));
    });
    final sources = await load();
    expect(sources.movements.firstWhere((m) => m.kind == 'receipt').actualAt,
        isNull);
    final choices = sources.movements
        .map((m) => MovementChoice(
            key: m.key,
            revision: m.revision,
            role: m.kind == 'receipt' ? 'later' : 'included',
            actualAt: m.actualAt ?? DateTime.utc(2026, 10, 28, 14)))
        .toList();
    final p = await service.preview(
        sources: sources,
        draft: draft(choices: choices),
        isAccessCurrent: () => true);
    expect(p.cash.bankMinor, 605000);
    await service.confirm(
        preview: p, operationKey: 'legacy-date', isAccessCurrent: () => true);
    expect((await h.db.reimbursements.where().findFirst())!.date.toUtc(),
        DateTime.utc(2026, 10, 28, 15));
  });
  test('shared editor cannot load the owner checkpoint review', () async {
    late int space;
    await h.db.writeTxn(() async {
      space = await h.db.sharedSpaces.put(SharedSpace()
        ..name = 'Family'
        ..currency = PrimaryCurrency.huf
        ..createdByProfileId = h.ownerId
        ..createdAt = now);
      await h.db.sharedMembers.put(SharedMember()
        ..sharedSpaceId = space
        ..profileId = h.ownerId
        ..role = SharedMemberRole.editor
        ..joinedAt = now);
      await h.db.monthlyBudgets.put(MonthlyBudget()
        ..sharedSpaceId = space
        ..yearMonth = '2026-10'
        ..baseAvailableAmount = 0
        ..openingBalanceConfirmed = true
        ..createdAt = now
        ..updatedAt = now);
    });
    await expectLater(
        service.load(
            context: ContextRef.shared(spaceId: space, yearMonth: '2026-10'),
            actorId: h.ownerId,
            isAccessCurrent: () => true),
        throwsA(isA<ReceiptGuardException>()
            .having((error) => error.code, 'code', 'ownerRequired')));
    expect(await h.db.balanceCheckpoints.count(), 0);
  });
}
