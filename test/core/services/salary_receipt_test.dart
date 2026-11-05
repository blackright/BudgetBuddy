import 'package:budget_buddy/core/models/balance_checkpoint.dart';
import 'package:budget_buddy/core/models/month_rate_seal.dart';
import 'package:budget_buddy/core/models/month_end_run.dart';
import 'package:budget_buddy/core/models/pending_action.dart';
import 'package:budget_buddy/core/services/medical_receipt_service.dart';
import '../../support/d1_financial_harness.dart';
import 'package:budget_buddy/core/services/balance_checkpoint_service.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/money_receipt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/models/salary_cycle.dart';
import 'package:budget_buddy/core/models/income_receipt_group.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/services/salary_receipt_service.dart';
import 'package:budget_buddy/core/services/income_receipt_ledger.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/features/pending_actions/services/pending_action_service.dart';
import 'dart:convert';

void main() {
  test('preview and confirm a salary receipt once', () async {
    final f = await D1FinancialHarness.create();
    addTearDown(f.close);
    final service =
        SalaryReceiptService(f.h.db, clock: () => D1FinancialHarness.now);
    final preview = await service.preview(
        actorId: f.h.ownerId,
        sourceGuid: f.source.syncGuid,
        cycleGuid: f.cycle.guid,
        salaryMinor: 485000,
        actualDate: DateTime.utc(2026, 10, 25),
        selectedClaimGuids: [],
        isAccessCurrent: () => true);
    final group = await service.confirm(
        preview: preview,
        bankTotalMinor: 485000,
        operationKey: 'once',
        isAccessCurrent: () => true);
    final retry = await service.confirm(
        preview: preview,
        bankTotalMinor: 485000,
        operationKey: 'once',
        isAccessCurrent: () => true);
    expect(group.guid, retry.guid);
    expect(group.totalMinor, 485000);
    expect(preview.cashMonth, '2026-10');
    expect(preview.destinationMonth, '2026-10');
    expect(group.destinationMonth, '2026-10');
    expect(await f.h.db.incomeReceiptGroups.count(), 1);
  });

  test('cash month follows the actual date and IANA timezone', () {
    final instant = DateTime.utc(2026, 11, 1, 3, 30);
    String month(String zone) =>
        IncomeReceiptLedger.cashMonth(IncomeReceiptGroup()
          ..actualDate = instant
          ..timezone = zone);
    // 03:30 UTC is still 31 October in New York, already November in Budapest.
    expect(month('UTC'), '2026-11');
    expect(month('America/New_York'), '2026-10');
    expect(month('Europe/Budapest'), '2026-11');

    final winter = DateTime.utc(2026, 3, 1, 4, 30);
    String winterMonth(String zone) =>
        IncomeReceiptLedger.cashMonth(IncomeReceiptGroup()
          ..actualDate = winter
          ..timezone = zone);
    expect(winterMonth('America/New_York'), '2026-02');
    expect(winterMonth('Europe/Budapest'), '2026-03');
  });

  test('a future actual bank-credit date is refused', () async {
    final f = await D1FinancialHarness.create();
    addTearDown(f.close);
    final service =
        SalaryReceiptService(f.h.db, clock: () => D1FinancialHarness.now);
    await expectLater(
        service.preview(
            actorId: f.h.ownerId,
            sourceGuid: f.source.syncGuid,
            cycleGuid: f.cycle.guid,
            salaryMinor: 500000,
            actualDate: D1FinancialHarness.now.add(const Duration(days: 1)),
            selectedClaimGuids: const [],
            isAccessCurrent: () => true),
        throwsA(isA<SalaryReceiptException>()
            .having((e) => e.code, 'code', 'invalidAmount')));
  });

  test('an unknown timezone is refused instead of guessing a month', () async {
    final f = await D1FinancialHarness.create();
    addTearDown(f.close);
    final service =
        SalaryReceiptService(f.h.db, clock: () => D1FinancialHarness.now);
    await expectLater(
        service.preview(
            actorId: f.h.ownerId,
            sourceGuid: f.source.syncGuid,
            cycleGuid: f.cycle.guid,
            salaryMinor: 500000,
            actualDate: DateTime.utc(2026, 10, 27),
            timezone: 'Not/AZone',
            selectedClaimGuids: const [],
            isAccessCurrent: () => true),
        throwsA(isA<SalaryReceiptException>()
            .having((e) => e.code, 'code', 'invalidTimezone')));
  });
  test(
      'D1 preview writes nothing and mismatched components or owner are refused',
      () async {
    final f = await D1FinancialHarness.create();
    addTearDown(f.close);
    await f.approve();
    final service =
        SalaryReceiptService(f.h.db, clock: () => D1FinancialHarness.now);
    await expectLater(
        service.preview(
            actorId: f.h.ownerId,
            sourceGuid: f.source.syncGuid,
            cycleGuid: f.cycle.guid,
            salaryMinor: 500000,
            medicalMinor: 6000,
            claimAmounts: {f.bill.syncGuid: 7000},
            selectedClaimGuids: [f.bill.syncGuid],
            actualDate: DateTime.utc(2026, 10, 27),
            isAccessCurrent: () => true),
        throwsA(isA<Exception>()));
    await expectLater(
        service.preview(
            actorId: f.h.ownerId + 1,
            sourceGuid: f.source.syncGuid,
            cycleGuid: f.cycle.guid,
            salaryMinor: 500000,
            selectedClaimGuids: [],
            actualDate: DateTime.utc(2026, 10, 27),
            isAccessCurrent: () => true),
        throwsA(isA<Exception>()));
    expect(await f.h.db.incomeReceiptGroups.count(), 0);
    expect(await f.h.db.moneyReceipts.count(), 0);
  });

  test(
      'D1 a new standalone refund after the cost month closes leaves original money untouched',
      () async {
    final f = await D1FinancialHarness.create();
    addTearDown(f.close);
    await f.approve();
    await f.h.db.writeTxn(() => f.h.db.monthRateSeals.put(MonthRateSeal()
      ..yearMonth = '2026-10'
      ..asOf = D1FinancialHarness.now
      ..fetchedAt = D1FinancialHarness.now
      ..updatedAt = D1FinancialHarness.now));
    final before = await f.h.db.expenses.where().exportJson();
    final later = DateTime.utc(2026, 11, 28, 16);
    final checkpoint = BalanceCheckpointService(f.h.db, clock: () => later);
    final sources = await checkpoint.load(
        context: f.h.context('2026-11'),
        actorId: f.h.ownerId,
        isAccessCurrent: () => true);
    await checkpoint.confirm(
        preview: await checkpoint.preview(
            sources: sources,
            draft: CheckpointDraft(
                balanceMinor: 500000,
                balanceAsOf: DateTime.utc(2026, 11, 1),
                localZone: 'UTC',
                pool: 'November',
                choices: sources.movements.map((m) => MovementChoice(
                    key: m.key,
                    revision: m.revision,
                    role: 'included',
                    actualAt: m.actualAt))),
            isAccessCurrent: () => true),
        operationKey: 'november',
        isAccessCurrent: () => true);
    final medical = MedicalReceiptService(f.h.db, clock: () => later);
    final p = await medical.preview(
        billId: f.bill.id,
        actorId: f.h.ownerId,
        amountMinor: 7500,
        receivedAt: DateTime.utc(2026, 11, 27),
        destinationMonth: '2026-11',
        isAccessCurrent: () => true);
    await SalaryReceiptService(f.h.db, clock: () => later).confirmRefund(
        preview: p, operationKey: 'late', isAccessCurrent: () => true);
    expect(await f.h.db.expenses.where().exportJson(), before);
    expect(
        (await medical.history(
                billId: f.bill.id,
                actorId: f.h.ownerId,
                isAccessCurrent: () => true))
            .remainingMinor,
        0);
  });
  test(
      'D1 medical components are refused because refunds move to Medical management',
      () async {
    final f = await D1FinancialHarness.create();
    addTearDown(f.close);
    await f.approve();
    final service =
        SalaryReceiptService(f.h.db, clock: () => D1FinancialHarness.now);
    await expectLater(
        service.preview(
            actorId: f.h.ownerId,
            sourceGuid: f.source.syncGuid,
            cycleGuid: f.cycle.guid,
            salaryMinor: 500000,
            medicalMinor: 6000,
            claimAmounts: {f.bill.syncGuid: 6000},
            selectedClaimGuids: [f.bill.syncGuid],
            actualDate: DateTime.utc(2026, 10, 27),
            isAccessCurrent: () => true),
        throwsA(isA<SalaryReceiptException>()
            .having((e) => e.code, 'code', 'medicalReceiptMoved')));
  });
  test('D1 bank-total mismatch and lost access never confirm a credit',
      () async {
    final f = await D1FinancialHarness.create();
    addTearDown(f.close);
    final service =
        SalaryReceiptService(f.h.db, clock: () => D1FinancialHarness.now);
    final p = await service.preview(
        actorId: f.h.ownerId,
        sourceGuid: f.source.syncGuid,
        cycleGuid: f.cycle.guid,
        salaryMinor: 500000,
        selectedClaimGuids: [],
        actualDate: DateTime.utc(2026, 10, 27),
        isAccessCurrent: () => true);
    await expectLater(
        service.confirm(
            preview: p,
            bankTotalMinor: 508000,
            operationKey: 'wrong-total',
            isAccessCurrent: () => true),
        throwsA(isA<SalaryReceiptException>()));
    await expectLater(
        service.confirm(
            preview: p,
            bankTotalMinor: 500000,
            operationKey: 'locked',
            isAccessCurrent: () => false),
        throwsA(isA<SalaryReceiptException>()));
    expect(await f.h.db.incomeReceiptGroups.count(), 0);
  });
  test(
      'a future salary period confirms into its actual cash month without provisioning another month',
      () async {
    final f = await D1FinancialHarness.create();
    addTearDown(f.close);
    final service =
        SalaryReceiptService(f.h.db, clock: () => D1FinancialHarness.now);
    final months = await f.h.db.monthlyBudgets.count();
    final cycles = await f.h.db.salaryCycles.count();
    final draft = await service.prepareCycle(
        source: f.source, actorId: f.h.ownerId, month: '2026-12');
    final preview = await service.preview(
        actorId: f.h.ownerId,
        sourceGuid: f.source.syncGuid,
        cycleGuid: draft.guid,
        cycleDraft: draft,
        salaryMinor: 500000,
        selectedClaimGuids: [],
        actualDate: DateTime.utc(2026, 10, 27),
        isAccessCurrent: () => true);
    expect(preview.cashMonth, '2026-10');
    expect(preview.destinationMonth, '2026-10');
    expect(preview.cycle.occurrenceMonth, '2026-12');
    final group = await service.confirm(
        preview: preview,
        bankTotalMinor: 500000,
        operationKey: 'future-period',
        isAccessCurrent: () => true);
    expect(group.destinationMonth, '2026-10');
    expect(
        (await f.h.db.salaryCycles
                .filter()
                .guidEqualTo(draft.guid)
                .findFirst())!
            .occurrenceMonth,
        '2026-12');
    // The cash month already existed; no future month was provisioned.
    expect(await f.h.db.monthlyBudgets.count(), months);
    expect(await f.h.db.salaryCycles.count(), cycles + 1);
    expect(await f.h.db.incomeReceiptGroups.count(), 1);
  });
  test(
      'a salary cycle confirms once across operation keys, retries and restarts',
      () async {
    final f = await D1FinancialHarness.create();
    addTearDown(f.close);
    final service =
        SalaryReceiptService(f.h.db, clock: () => D1FinancialHarness.now);
    final preview = await service.preview(
        actorId: f.h.ownerId,
        sourceGuid: f.source.syncGuid,
        cycleGuid: f.cycle.guid,
        salaryMinor: 500000,
        actualDate: DateTime.utc(2026, 10, 27),
        selectedClaimGuids: const [],
        isAccessCurrent: () => true);
    final group = await service.confirm(
        preview: preview,
        bankTotalMinor: 500000,
        operationKey: 'first',
        isAccessCurrent: () => true);

    // A restart replays the same operation identity without writing again.
    final restarted =
        SalaryReceiptService(f.h.db, clock: () => D1FinancialHarness.now);
    final replay = await restarted.confirm(
        preview: preview,
        bankTotalMinor: 500000,
        operationKey: 'first',
        isAccessCurrent: () => true);
    expect(replay.guid, group.guid);

    // A second device with a different operation key cannot post twice.
    await expectLater(
        restarted.confirm(
            preview: preview,
            bankTotalMinor: 500000,
            operationKey: 'second',
            isAccessCurrent: () => true),
        throwsA(isA<SalaryReceiptException>()
            .having((e) => e.code, 'code', 'alreadyConfirmed')));
    await expectLater(
        restarted.preview(
            actorId: f.h.ownerId,
            sourceGuid: f.source.syncGuid,
            cycleGuid: f.cycle.guid,
            salaryMinor: 500000,
            actualDate: DateTime.utc(2026, 10, 27),
            selectedClaimGuids: const [],
            isAccessCurrent: () => true),
        throwsA(isA<SalaryReceiptException>()
            .having((e) => e.code, 'code', 'alreadyConfirmed')));
    expect(await f.h.db.incomeReceiptGroups.count(), 1);
  });

  test('a legacy future destination month is never re-dated', () async {
    final f = await D1FinancialHarness.create();
    addTearDown(f.close);
    final service =
        SalaryReceiptService(f.h.db, clock: () => D1FinancialHarness.now);
    final preview = await service.preview(
        actorId: f.h.ownerId,
        sourceGuid: f.source.syncGuid,
        cycleGuid: f.cycle.guid,
        salaryMinor: 500000,
        actualDate: DateTime.utc(2026, 10, 27),
        selectedClaimGuids: const [],
        isAccessCurrent: () => true);
    final group = await service.confirm(
        preview: preview,
        bankTotalMinor: 500000,
        operationKey: 'legacy',
        isAccessCurrent: () => true);
    // Simulate a pre-022 group that was posted to the visibly chosen month.
    await f.h.db.writeTxn(() async {
      final legacy = (await f.h.db.incomeReceiptGroups
          .filter()
          .guidEqualTo(group.guid)
          .findFirst())!
        ..destinationMonth = '2026-12';
      await f.h.db.incomeReceiptGroups.put(legacy);
      final revision = (await f.h.db.receiptRevisions
          .filter()
          .receiptGuidEqualTo(legacy.componentReceiptGuids.first)
          .findFirst())!;
      final evidence =
          jsonDecode(revision.evidenceJson) as Map<String, dynamic>;
      evidence['destinationMonth'] = '2026-12';
      revision.evidenceJson = jsonEncode(evidence);
      await f.h.db.receiptRevisions.put(revision);
    });

    final groups = await IncomeReceiptLedger.forOwner(f.h.db, f.h.ownerId);
    expect(
        IncomeReceiptLedger.incomeForMonth(
            groups, [f.source], '2026-12', CurrencyCode.huf),
        500000);
    // October keeps its 0 actual salary once the group has been re-homed.
    expect(
        IncomeReceiptLedger.incomeForMonth(
            groups, [f.source], '2026-10', CurrencyCode.huf),
        0);
    expect(groups.single.group.destinationMonth, '2026-12');
  });

  test('a confirmed salary completes its attention action only after commit',
      () async {
    final f = await D1FinancialHarness.create();
    addTearDown(f.close);
    final actions = _RecordingActions(f.h.db, f.h.ownerId);
    final service = SalaryReceiptService(f.h.db,
        clock: () => D1FinancialHarness.now, pendingActions: actions);
    final preview = await service.preview(
        actorId: f.h.ownerId,
        sourceGuid: f.source.syncGuid,
        cycleGuid: f.cycle.guid,
        salaryMinor: 500000,
        actualDate: DateTime.utc(2026, 10, 27),
        selectedClaimGuids: const [],
        isAccessCurrent: () => true);
    await expectLater(
        service.confirm(
            preview: preview,
            bankTotalMinor: 1,
            operationKey: 'wrong',
            isAccessCurrent: () => true),
        throwsA(isA<SalaryReceiptException>()));
    expect(actions.completed, isEmpty);

    await service.confirm(
        preview: preview,
        bankTotalMinor: 500000,
        operationKey: 'right',
        isAccessCurrent: () => true);
    expect(actions.completed, [
      'salary.confirm|${f.cycle.guid}|2026-10',
      'income.complete|${f.cycle.guid}|2026-10',
    ]);
  });

  test('a settled cash month is blocked with a specific code and no write',
      () async {
    final f = await D1FinancialHarness.create();
    addTearDown(f.close);
    await f.h.db.writeTxn(() async {
      await f.h.db.monthEndRuns.put(MonthEndRun()
        ..syncGuid = 'settled-oct'
        ..profileId = f.h.ownerId
        ..contextGuid = 'personal:${f.h.ownerId}'
        ..yearMonth = '2026-10'
        ..destinationMonth = '2026-11'
        ..currency = 'huf'
        ..reportJson = '{}'
        ..fingerprint = 'settled'
        ..actor = '${f.h.ownerId}'
        ..createdAt = DateTime.utc(2026, 10, 31)
        ..applied = true);
    });
    final service =
        SalaryReceiptService(f.h.db, clock: () => D1FinancialHarness.now);
    final before = await f.h.db.incomeReceiptGroups.count();

    await expectLater(
        service.preview(
            actorId: f.h.ownerId,
            sourceGuid: f.source.syncGuid,
            cycleGuid: f.cycle.guid,
            salaryMinor: 500000,
            actualDate: DateTime.utc(2026, 10, 27),
            selectedClaimGuids: const [],
            isAccessCurrent: () => true),
        throwsA(isA<SalaryReceiptException>()
            .having((e) => e.code, 'code', 'settledMonth')));
    expect(await f.h.db.incomeReceiptGroups.count(), before);
  });

  test('a correction in a sealed month is refused without rewriting history',
      () async {
    final f = await D1FinancialHarness.create();
    addTearDown(f.close);
    final salary =
        SalaryReceiptService(f.h.db, clock: () => D1FinancialHarness.now);
    final preview = await salary.preview(
        actorId: f.h.ownerId,
        sourceGuid: f.source.syncGuid,
        cycleGuid: f.cycle.guid,
        salaryMinor: 500000,
        actualDate: DateTime.utc(2026, 10, 27),
        selectedClaimGuids: const [],
        isAccessCurrent: () => true);
    final group = await salary.confirm(
        preview: preview,
        bankTotalMinor: 500000,
        operationKey: 'sealed',
        isAccessCurrent: () => true);
    await f.h.db.writeTxn(() async {
      await f.h.db.monthRateSeals.put(MonthRateSeal()
        ..yearMonth = '2026-11'
        ..status = SealStatus.sealed
        ..asOf = DateTime.utc(2026, 11, 1)
        ..fetchedAt = DateTime.utc(2026, 11, 1)
        ..updatedAt = DateTime.utc(2026, 11, 1));
    });
    final before = await f.h.db.moneyReceipts.count();
    final pendingService = PendingActionService(f.h.db,
        profileId: f.h.ownerId, clock: () => DateTime.utc(2026, 11, 5));
    final corrector = SalaryReceiptService(f.h.db,
        clock: () => DateTime.utc(2026, 11, 5), pendingActions: pendingService);

    await expectLater(
        corrector.correct(
            actorId: f.h.ownerId,
            groupGuid: group.guid,
            correctionMinor: -10000,
            reason: 'Late fix',
            operationKey: 'sealed-fix',
            correctedAt: DateTime.utc(2026, 11, 2),
            isAccessCurrent: () => true),
        throwsA(isA<SalaryReceiptException>()
            .having((e) => e.code, 'code', 'sealedMonth')));
    expect(await f.h.db.moneyReceipts.count(), before);
    await pendingService.refreshStatuses(DateTime.utc(2026, 11, 5));
    final review = await f.h.db.pendingActions
        .filter()
        .actionTypeEqualTo('correction.review')
        .findFirst();
    expect(review, isNotNull);
    expect(review!.status, 'due');
    expect(review.expectedMonth, '2026-11');
    expect(review.deepLink, '/month_end');
  });

  test('a correction is append-only and counts in its recording month',
      () async {
    final f = await D1FinancialHarness.create();
    addTearDown(f.close);
    final service =
        SalaryReceiptService(f.h.db, clock: () => D1FinancialHarness.now);
    final preview = await service.preview(
        actorId: f.h.ownerId,
        sourceGuid: f.source.syncGuid,
        cycleGuid: f.cycle.guid,
        salaryMinor: 485000,
        actualDate: DateTime.utc(2026, 10, 27),
        selectedClaimGuids: const [],
        isAccessCurrent: () => true);
    final group = await service.confirm(
        preview: preview,
        bankTotalMinor: 485000,
        operationKey: 'correct-me',
        isAccessCurrent: () => true);
    final originalRows = await f.h.db.moneyReceipts.where().exportJson();
    final originalCycle = (await f.h.db.salaryCycles
        .filter()
        .guidEqualTo(f.cycle.guid)
        .findFirst())!;

    // The correction is recorded later than the salary itself.
    final corrector =
        SalaryReceiptService(f.h.db, clock: () => DateTime.utc(2026, 11, 5));
    final correction = await corrector.correct(
        actorId: f.h.ownerId,
        groupGuid: group.guid,
        correctionMinor: -15000,
        reason: 'Bank credit was corrected',
        operationKey: 'fix-1',
        correctedAt: DateTime.utc(2026, 11, 2),
        isAccessCurrent: () => true);
    expect(correction.kind, 'salary-correction');

    final corrections = await SalaryCorrection.forOwner(f.h.db, f.h.ownerId);
    expect(corrections, hasLength(1));
    expect(corrections.single.cashMonth, '2026-11');
    expect(corrections.single.amountMinor, -15000);
    expect(corrections.single.groupGuid, group.guid);

    // Originals are untouched.
    final storedGroup = (await f.h.db.incomeReceiptGroups
        .filter()
        .guidEqualTo(group.guid)
        .findFirst())!;
    expect(storedGroup.totalMinor, 485000);
    expect(storedGroup.destinationMonth, '2026-10');
    final storedCycle = (await f.h.db.salaryCycles
        .filter()
        .guidEqualTo(f.cycle.guid)
        .findFirst())!;
    expect(storedCycle.confirmed, originalCycle.confirmed);
    expect(storedCycle.occurrenceMonth, originalCycle.occurrenceMonth);
    final rowsAfter = await f.h.db.moneyReceipts.where().exportJson();
    expect(rowsAfter.length, originalRows.length + 1);
    expect(
        rowsAfter
            .where((r) => r['kind'] == 'salary' && r['syncGuid'] != null)
            .length,
        originalRows.where((r) => r['kind'] == 'salary').length);

    final groups = await IncomeReceiptLedger.forOwner(f.h.db, f.h.ownerId);
    expect(
        IncomeReceiptLedger.incomeForMonth(
            groups, [f.source], '2026-11', CurrencyCode.huf,
            corrections: corrections),
        -15000);

    // Retrying the same operation identity (even on a later day) is a replay.
    final replay = await corrector.correct(
        actorId: f.h.ownerId,
        groupGuid: group.guid,
        correctionMinor: -15000,
        reason: 'Bank credit was corrected',
        operationKey: 'fix-1',
        correctedAt: DateTime.utc(2026, 11, 3),
        isAccessCurrent: () => true);
    expect(replay.syncGuid, correction.syncGuid);
    expect(await SalaryCorrection.forOwner(f.h.db, f.h.ownerId), hasLength(1));

    await expectLater(
        corrector.correct(
            actorId: f.h.ownerId,
            groupGuid: group.guid,
            correctionMinor: -485000,
            reason: 'Too much',
            operationKey: 'zero',
            correctedAt: DateTime.utc(2026, 11, 2),
            isAccessCurrent: () => true),
        throwsA(isA<SalaryReceiptException>()
            .having((e) => e.code, 'code', 'invalidCorrection')));
    await expectLater(
        corrector.correct(
            actorId: f.h.ownerId,
            groupGuid: group.guid,
            correctionMinor: 1000,
            reason: 'Future',
            operationKey: 'future',
            correctedAt: DateTime.utc(2026, 12, 1),
            isAccessCurrent: () => true),
        throwsA(isA<SalaryReceiptException>()
            .having((e) => e.code, 'code', 'invalidCorrection')));
  });
}

class _RecordingActions extends PendingActionService {
  _RecordingActions(super.db, int owner) : super(profileId: owner);

  final List<String> completed = [];

  @override
  Future<void> completeByRecord(
      String actionType, String recordRef, String cycleOrMonth) async {
    completed.add('$actionType|$recordRef|$cycleOrMonth');
  }
}
