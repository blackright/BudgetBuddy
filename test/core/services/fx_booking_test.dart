import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/services/refund_service.dart';
import 'package:budget_buddy/features/spaces/repositories/month_move_operations.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/financial_report.dart';
import 'package:budget_buddy/core/services/report_calculation.dart';
import 'package:budget_buddy/features/vault/personal_month_funds.dart';
import 'package:budget_buddy/features/sync/domain/codecs/expense_codec.dart';
import 'package:budget_buddy/features/sync/domain/codecs/reimbursement_codec.dart';
import 'package:budget_buddy/core/models/fx_revision.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/live_rate_set.dart';
import 'package:budget_buddy/core/services/fx_booking_service.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/finance/repositories/audit_repository.dart';
import 'package:budget_buddy/features/engine/currency_resolution.dart';
import 'package:budget_buddy/shared/presentation/money_conversion.dart';
import 'package:budget_buddy/features/finance/presentation/audit_values.dart';
import 'dart:convert';
import '../../features/medical/repositories/medical_test_harness.dart';

void main() {
  late MedicalTestHarness h;
  setUp(() async {
    h = await MedicalTestHarness.create();
    await h.seedBudget();
    await h.isar.writeTxn(() async {
      await h.isar.liveRateSets.put(LiveRateSet()
        ..ratesUsd = 1
        ..ratesEur = .8
        ..ratesHuf = 400
        ..ratesCad = 1.4
        ..fetchedAt = DateTime.utc(2026, 1, 1));
    });
  });
  tearDown(() => h.close());
  Expense expense(
          {int amount = 2000, ExpenseStatus status = ExpenseStatus.paid}) =>
      Expense(
          profileId: h.profileId,
          budgetId: h.budgetId,
          yearMonth: '2026-01',
          title: 'Coffee',
          amount: amount,
          currency: 'EUR',
          categoryId: 'food',
          date: DateTime(2026, 1, 3),
          status: status);
  Future<void> save(Expense row) => h.isar.writeTxn(() async {
        await AuditRepository(h.isar, actorId: h.profileId)
            .put(h.isar.expenses, row, id: row.id, type: 'Expense');
      });
  test(
      'booked Paid amount stays fixed after rates refresh and same-currency correction retains rate',
      () async {
    final row = expense();
    await save(row);
    expect(expenseFx(row)!.current.baseMinor, 2500);
    final first = row.fxHistoryJson;
    await h.isar.writeTxn(() async {
      final rates = (await h.isar.liveRateSets.get(1))!..ratesEur = 1;
      await h.isar.liveRateSets.put(rates);
    });
    final rates = await readFxRates(h.isar);
    expect(
        expenseToDisplay(row, CurrencyCode.usd, rates.tableFor('2026-01'))
            .minorUnits,
        2500);
    final visible = formatExpenseConversion(
        row, CurrencyCode.usd, rates.tableFor('2026-01'));
    expect(visible.text, r'$ 25.00');
    expect(visible.originalText, '€ 20.00');
    final audit = formatAuditValues(
        jsonEncode({'fxHistoryJson': row.fxHistoryJson}),
        objectType: 'Expense');
    expect(audit, contains(r'$ 25.00 fixed'));
    expect(audit, isNot(contains('previousHash')));
    row.notes = 'Metadata only';
    await save(row);
    expect(row.fxHistoryJson, first);
    row.amount = 2500;
    await save(row);
    expect(expenseFx(row)!.revisions.length, 2);
    expect(expenseFx(row)!.current.baseMinor, 3125);
    expect(expenseFx(row)!.revisions.first.baseMinor, 2500);
  });
  test(
      'Planned uses estimates and books once when changed to Paid; legacy is never backfilled',
      () async {
    final planned = expense(status: ExpenseStatus.planned);
    await save(planned);
    expect(planned.fxHistoryJson, isNull);
    planned.status = ExpenseStatus.paid;
    await save(planned);
    final original = planned.fxHistoryJson;
    await save(planned);
    expect(planned.fxHistoryJson, original);
    final legacy = expense();
    await h.isar.writeTxn(() => h.isar.expenses.put(legacy));
    legacy.notes = 'Legacy edit';
    await save(legacy);
    expect(legacy.fxHistoryJson, isNull);
  });
  test(
      'partial refunds consume exact cumulative booked value including final remainder',
      () async {
    final row = expense();
    await save(row);
    final amounts = <int>[];
    for (final amount in [333, 333, 1334]) {
      final refund = Reimbursement(
          profileId: h.profileId,
          expenseId: row.id,
          originYearMonth: '2026-01',
          amount: amount,
          currency: 'EUR',
          date: DateTime(2026));
      await h.isar.writeTxn(() async {
        await AuditRepository(h.isar, actorId: h.profileId).put(
            h.isar.reimbursements, refund,
            id: refund.id, type: 'Reimbursement');
      });
      amounts.add(reimbursementFx(refund)!.current.baseMinor);
    }
    expect(amounts, [416, 417, 1667]);
    expect(amounts.reduce((a, b) => a + b), 2500);
    row.amount = 3000;
    await expectLater(save(row), throwsStateError);
    expect((await h.isar.expenses.get(row.id))!.amount, 2000);
  });
  test(
      'exact rational arithmetic rejects unsafe inputs and handles half rounding',
      () {
    expect(fxConvertMinor(1, CurrencyCode.eur, CurrencyCode.usd, '1', '2'), 1);
    expect(fxConvertMinor(2345, CurrencyCode.eur, CurrencyCode.huf, '400', '1'),
        9380);
    expect(
        () => fxConvertMinor(
            fxMoneyBound, CurrencyCode.huf, CurrencyCode.usd, '1000', '1'),
        throwsFormatException);
    expect(fxDecimal('1.25'), (BigInt.from(5), BigInt.from(4)));
  });
  test(
      'status reversal preserves old evidence and a later Paid transition appends a fresh revision',
      () async {
    final row = expense();
    await save(row);
    final first = expenseFx(row)!.current.hash;
    row
      ..status = ExpenseStatus.planned
      ..amount = 3000;
    await save(row);
    expect(expenseAccountingMoney(row).minorUnits, 3000);
    expect(expenseFx(row)!.current.hash, first);
    row.status = ExpenseStatus.paid;
    await save(row);
    expect(expenseFx(row)!.revisions.length, 2);
    expect(expenseFx(row)!.current.baseMinor, 3750);
  });
  test(
      'FX and money roll back together; retry books only the committed revision',
      () async {
    final row = expense();
    await expectLater(h.isar.writeTxn(() async {
      await FxBookingService(h.isar).prepareExpense(row);
      await h.isar.expenses.put(row);
      throw StateError('Injected after financial write');
    }), throwsStateError);
    expect(await h.isar.expenses.count(), 0);
    final retry = expense();
    await save(retry);
    await save(retry);
    expect(expenseFx(retry)!.revisions.length, 1);
    expect(await h.isar.expenses.count(), 1);
  });
  test(
      'codecs preserve evidence and old peers may change metadata but cannot downgrade or revalue',
      () async {
    final row = expense();
    await save(row);
    final decoded =
        const ExpenseCodec().fromJson(const ExpenseCodec().toJson(row));
    expect(decoded.fxHistoryJson, row.fxHistoryJson);
    decoded.fxHistoryJson = null;
    decoded.notes = 'Old peer metadata';
    await FxBookingService(h.isar)
        .validateRemoteExpense(decoded, row, carriesFx: false);
    expect(decoded.fxHistoryJson, row.fxHistoryJson);
    decoded.amount++;
    decoded.fxHistoryJson = null;
    await expectLater(
        FxBookingService(h.isar)
            .validateRemoteExpense(decoded, row, carriesFx: false),
        throwsStateError);
    decoded.amount = row.amount;
    await expectLater(
        FxBookingService(h.isar)
            .validateRemoteExpense(decoded, row, carriesFx: true),
        throwsStateError);
    final forged = FxHistory.decode(row.fxHistoryJson)!.current.json
      ..['baseMinor'] = 999;
    expect(() => FxRevision.fromJson(forged), throwsFormatException);
  });
  test(
      'tiny proportional refunds may return zero base units and still conserve the full payment',
      () async {
    final row = expense(amount: 3);
    await h.isar.writeTxn(() async {
      final rates = (await h.isar.liveRateSets.get(1))!..ratesEur = 2;
      await h.isar.liveRateSets.put(rates);
    });
    await save(row);
    expect(expenseFx(row)!.current.baseMinor, 2);
    final values = <int>[];
    for (var i = 0; i < 3; i++) {
      final refund = Reimbursement(
          profileId: h.profileId,
          expenseId: row.id,
          originYearMonth: row.yearMonth,
          amount: 1,
          currency: row.currency,
          date: row.date);
      await h.isar.writeTxn(() async {
        await FxBookingService(h.isar).prepareRefund(refund);
        await h.isar.reimbursements.put(refund);
      });
      values.add(reimbursementAccountingMoney(refund).minorUnits);
      expect(
          const ReimbursementCodec()
              .fromJson(const ReimbursementCodec().toJson(refund))
              .fxHistoryJson,
          refund.fxHistoryJson);
    }
    expect(values, [1, 0, 1]);
  });
  test(
      'Medical payouts keep next-month attribution, original FX and immutable correction revisions',
      () async {
    final context = await h.seedBudget(yearMonth: '2026-02');
    final bill = MedicalBill()
      ..yearMonth = context.yearMonth
      ..billedAmount = 2000
      ..currency = 'EUR'
      ..patientSharePercent = 20
      ..paymentMethod = MedicalPaymentMethod.selfPaid
      ..state = MedicalBillState.waiting
      ..serviceDate = DateTime(2026, 2, 3);
    final saved = await h.repository.saveBill(bill, context);
    final linked = (await h.expenseFor(saved))!;
    expect(expenseFx(linked)!.current.baseMinor, 2500);
    await h.isar.writeTxn(() async {
      final rates = (await h.isar.liveRateSets.get(1))!..ratesEur = 1;
      await h.isar.liveRateSets.put(rates);
    });
    await h.repository.logReimbursement(saved, amount: 1600);
    var refund = (await h.allReimbursements()).single;
    expect(refund.originYearMonth, '2026-03');
    expect(reimbursementFx(refund)!.current.baseMinor, 2000);
    await h.repository.logReimbursement(saved, amount: 1500);
    refund = (await h.allReimbursements()).single;
    expect(reimbursementFx(refund)!.revisions.length, 2);
    expect(reimbursementFx(refund)!.current.baseMinor, 1875);
  });
  test(
      'report and vault inputs keep booked spending stable and reject an accounting currency mismatch',
      () async {
    final row = expense();
    await save(row);
    final month = (await h.isar.monthlyBudgets.get(h.budgetId))!
      ..profileId = h.profileId
      ..openingBalanceConfirmed = true;
    await h.isar.writeTxn(() => h.isar.monthlyBudgets.put(month));
    final before = await readPersonalMonthFunds(
        h.isar, h.profileId, row.yearMonth, await readFxRates(h.isar));
    await h.isar.writeTxn(() async {
      final rates = (await h.isar.liveRateSets.get(1))!..ratesEur = 1;
      await h.isar.liveRateSets.put(rates);
    });
    final rates = await readFxRates(h.isar);
    expect(
        await readPersonalMonthFunds(h.isar, h.profileId, row.yearMonth, rates),
        before);
    final report = calculateReportMonth(
        ReportMonthInput(
            owner: ReportOwner.personal(h.profileId),
            name: 'Test',
            currency: CurrencyCode.usd,
            month: month,
            defaultIncome: 0,
            expenses: [row],
            refunds: [],
            budgets: [],
            directs: [],
            sources: [],
            settlements: [],
            vault: [],
            categories: {},
            recorded: {}),
        ReportRequest(
            scope: ReportScope.personal,
            personalProfileId: h.profileId,
            owners: [ReportOwner.personal(h.profileId)],
            firstMonth: row.yearMonth,
            lastMonth: row.yearMonth,
            currency: CurrencyCode.usd),
        rates);
    expect(report.statement.amounts['paid'], 2500);
    expect(report.rows.single.rateBasis, contains('Booked USD'));
    final profile = (await h.isar.userProfiles.get(h.profileId))!
      ..primaryCurrency = PrimaryCurrency.huf;
    await h.isar.writeTxn(() => h.isar.userProfiles.put(profile));
    await expectLater(
        readPersonalMonthFunds(h.isar, h.profileId, row.yearMonth, rates),
        throwsFormatException);
  });
  test(
      'refund preview and committed records use identical booked rounding after rates change',
      () async {
    final row = expense();
    await save(row);
    await h.isar.writeTxn(() async {
      final rates = (await h.isar.liveRateSets.get(1))!..ratesEur = 1;
      await h.isar.liveRateSets.put(rates);
    });
    final service = RefundService(h.isar,
        context: ContextRef.personal(
            profileId: h.profileId, yearMonth: row.yearMonth),
        actingProfileId: h.profileId,
        rates: await readFxRates(h.isar));
    for (final amount in [333, 333, 1334]) {
      final quote = await service.quote(row.id);
      final impact = quote.impactFor(amount);
      final saved = await service.record(
          expenseId: row.id,
          amount: amount,
          operationId: 'part-$amount-${quote.returnedMinor}');
      expect(reimbursementAccountingMoney(saved).minorUnits,
          impact.spentBefore - impact.spentAfter);
    }
    expect((await service.quote(row.id)).remainingMinor, 0);
  });
  for (final (currency, expected) in [
    (PrimaryCurrency.usd, 2500),
    (PrimaryCurrency.eur, 2000),
    (PrimaryCurrency.cad, 3500),
    (PrimaryCurrency.huf, 10000)
  ]) {
    test('books EUR 20 into $currency with exact stored minor units', () async {
      final profile = (await h.isar.userProfiles.get(h.profileId))!
        ..primaryCurrency = currency;
      await h.isar.writeTxn(() => h.isar.userProfiles.put(profile));
      final row = expense();
      await save(row);
      expect(expenseFx(row)!.current.baseMinor, expected);
      expect(expenseFx(row)!.current.baseCurrency,
          currency.code.code.toUpperCase());
    });
  }
  test('month move refuses booked owner changes before moving any money',
      () async {
    final month = (await h.isar.monthlyBudgets.get(h.budgetId))!
      ..profileId = h.profileId;
    await h.isar.writeTxn(() => h.isar.monthlyBudgets.put(month));
    final row = expense();
    await save(row);
    final space = await h.createSpace();
    await h.isar.writeTxn(() => h.isar.sharedMembers.put(SharedMember()
      ..sharedSpaceId = space
      ..profileId = h.profileId
      ..role = SharedMemberRole.owner
      ..joinedAt = DateTime(2026)));
    await expectLater(
        MonthMoveOperations(h.isar).moveMonth(
            ContextRef.personal(
                profileId: h.profileId, yearMonth: row.yearMonth),
            ContextRef.shared(spaceId: space, yearMonth: row.yearMonth),
            row.yearMonth,
            actingProfileId: h.profileId),
        throwsStateError);
    expect((await h.isar.expenses.get(row.id))!.sharedSpaceId, isNull);
    expect(
        (await h.isar.monthlyBudgets.get(h.budgetId))!.profileId, h.profileId);
  });
}
