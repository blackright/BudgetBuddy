import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:budget_buddy/features/medical/repositories/medical_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'medical_test_harness.dart';

/// End-to-end validation of the US2 lifecycle against a real Isar instance, so
/// the expense and reimbursement rows the engine reads actually exist.
void main() {
  late MedicalTestHarness harness;
  late MedicalBillContext context;

  setUp(() async {
    harness = await MedicalTestHarness.create();
    context = await harness.seedBudget();
  });

  tearDown(() async {
    await harness.close();
  });

  Future<double> available() => harness.trueAvailable(
        profileId: context.profileId,
        yearMonth: context.yearMonth,
      );

  MedicalBill bill({
    double amount = 1000,
    double patientShare = 20,
    int month = 1,
    int? providerId,
    MedicalPaymentMethod method = MedicalPaymentMethod.insurerPaid,
    MedicalBillState state = MedicalBillState.planned,
  }) {
    return MedicalBill()
      ..billedAmount = amount
      ..patientSharePercent = patientShare
      ..providerId = providerId
      ..serviceDate = DateTime(2026, month, 15)
      ..paymentMethod = method
      ..state = state;
  }

  group('insurance profile (FR-035)', () {
    test('the profile carries a default patient share, not deductibles',
        () async {
      final profile =
          await harness.repository.getInsuranceProfile(context.profileId);

      expect(profile, isNotNull);
      expect(profile!.profileId, context.profileId);
      expect(profile.defaultPatientPercent, 20);
    });

    test('the seeded default is used when the caller overrides it', () async {
      final other = await harness.seedBudget(
        yearMonth: '2026-02',
        defaultPatientPercent: 5,
      );

      final theirs =
          await harness.repository.getInsuranceProfile(other.profileId);
      expect(theirs!.defaultPatientPercent, 5);
      expect(theirs.profileId, other.profileId);
    });

    test('each profile resolves its own insurance record', () async {
      final other = await harness.seedBudget(yearMonth: '2026-02');
      expect(other.profileId, isNot(context.profileId));

      final mine =
          await harness.repository.getInsuranceProfile(context.profileId);
      expect(mine!.profileId, context.profileId);

      final theirs =
          await harness.repository.getInsuranceProfile(other.profileId);
      expect(theirs!.profileId, other.profileId);
    });

    test('the plan name and insurer round-trip on the profile', () async {
      final existing =
          await harness.repository.getInsuranceProfile(context.profileId);
      existing!
        ..insurerName = 'Blue Cross'
        ..planName = 'PPO 500';
      await harness.repository.saveInsuranceProfile(existing);

      final profile =
          await harness.repository.getInsuranceProfile(context.profileId);
      expect(profile!.insurerName, 'Blue Cross');
      expect(profile.planName, 'PPO 500');
    });

    test('an unset plan reads back as null, not an empty string', () async {
      final existing =
          await harness.repository.getInsuranceProfile(context.profileId);
      existing!
        ..insurerName = null
        ..planName = null;
      await harness.repository.saveInsuranceProfile(existing);

      final profile =
          await harness.repository.getInsuranceProfile(context.profileId);
      // The summary line joins these, so an empty string would leave a stray
      // separator on screen.
      expect(profile!.insurerName, isNull);
      expect(profile.planName, isNull);
    });

    test('saving the plan keeps it scoped to that profile', () async {
      final other = await harness.seedBudget(yearMonth: '2026-02');
      final mine =
          await harness.repository.getInsuranceProfile(context.profileId);
      final theirs =
          await harness.repository.getInsuranceProfile(other.profileId);
      mine!
        ..insurerName = 'Mine'
        ..planName = 'Mine Plan';
      theirs!
        ..insurerName = 'Theirs'
        ..planName = 'Their Plan';
      await harness.repository.saveInsuranceProfile(mine);
      await harness.repository.saveInsuranceProfile(theirs);

      expect(
        (await harness.repository.getInsuranceProfile(context.profileId))!
            .planName,
        'Mine Plan',
      );
      expect(
        (await harness.repository.getInsuranceProfile(other.profileId))!
            .planName,
        'Their Plan',
      );
    });

    test('FR-037: no bill in a month means an empty patient-share aggregate',
        () async {
      final totals = PatientShareTotals.from(const []);
      expect(totals.isEmpty, isTrue);
      expect(totals.patientShareTotal, 0);
    });
  });

  group('money impact on save (R07 / FR-042)', () {
    test('a planned bill creates a linked expense worth nothing', () async {
      final saved = await harness.repository.saveBill(bill(), context);

      expect(saved.linkedExpenseId, isNotNull);
      final expense = (await harness.expenseFor(saved))!;
      expect(expense.amount, 0);
      expect(expense.status, ExpenseStatus.planned);
      expect(expense.type, ExpenseType.medical);
      expect(expense.categoryId, MedicalRepository.medicalCategoryId);
      // R-1: an insurer-paid bill has nothing to claim back.
      expect(expense.isReimbursable, isFalse);
      expect(expense.yearMonth, context.yearMonth);
      expect(expense.profileId, context.profileId);
      expect(expense.budgetId, context.budgetId);

      // Planned costs must not touch the budget yet (M4).
      expect(await available(), 5000);
    });

    test('FR-048: the percentage is the user\'s share', () async {
      final saved = await harness.repository.saveBill(bill(), context);

      expect(saved.patientSharePercent, 20);
      expect(saved.patientShareAmount, 200);
      expect(saved.insurerPaidAmount, 800);
    });

    test('FR-043: an insurer-paid waiting bill costs only the share (M2)',
        () async {
      final saved = await harness.repository.saveBill(
        bill(state: MedicalBillState.waiting),
        context,
      );

      // M2 — the reduction lands the moment the bill is entered.
      expect((await harness.expenseFor(saved))!.amount, 200);
      expect(await available(), 4800);
    });

    test('FR-045: a self-paid waiting bill costs the full charge', () async {
      final saved = await harness.repository.saveBill(
        bill(
            method: MedicalPaymentMethod.selfPaid,
            state: MedicalBillState.waiting),
        context,
      );

      expect((await harness.expenseFor(saved))!.amount, 1000);
      expect(await available(), 4000);
    });

    test('FR-051: a rejected insurer-paid bill raises the cost to full',
        () async {
      final saved = await harness.repository.saveBill(
        bill(state: MedicalBillState.rejected),
        context,
      );

      expect((await harness.expenseFor(saved))!.amount, 1000);
      expect(await available(), 4000);
    });

    test('M1: an insurer-paid bill is never charged the full amount while open',
        () async {
      final saved = await harness.repository.saveBill(
        bill(state: MedicalBillState.paid),
        context,
      );

      expect(saved.fundsImpact, 200);
      expect((await harness.expenseFor(saved))!.amount, 200);
    });

    test('the expense title comes from the provider directory (FR-008)',
        () async {
      final provider = await harness.repository.saveProvider(
        profileId: context.profileId,
        name: 'Dr. Smith',
        specialty: 'Cardiology',
      );

      final saved = await harness.repository
          .saveBill(bill(providerId: provider.id), context);

      expect((await harness.expenseFor(saved))!.title, 'Dr. Smith');
    });

    test('a bill without a provider falls back to a generic title', () async {
      final saved = await harness.repository.saveBill(bill(), context);
      expect((await harness.expenseFor(saved))!.title, 'Medical Bill');
    });

    test('saving an existing bill updates the same expense', () async {
      final saved = await harness.repository.saveBill(bill(), context);
      final expenseId = saved.linkedExpenseId;

      saved
        ..billedAmount = 1500
        ..patientSharePercent = 10
        ..state = MedicalBillState.waiting;
      await harness.repository.saveBill(saved, context);

      expect(saved.linkedExpenseId, expenseId);
      expect(await harness.allExpenses(), hasLength(1));
      final expense = await harness.isar.expenses.get(expenseId!);
      expect(expense!.amount, 150);
    });

    test('FR-054: correcting the percentage updates the expense immediately',
        () async {
      final saved = await harness.repository.saveBill(
        bill(state: MedicalBillState.waiting),
        context,
      );
      expect(await available(), 4800);

      saved.patientSharePercent = 50;
      await harness.repository.saveBill(saved, context);

      expect((await harness.expenseFor(saved))!.amount, 500);
      expect(await available(), 4500);
    });

    test('raising the billed amount of a live bill moves the balance',
        () async {
      final saved = await harness.repository.saveBill(
        bill(state: MedicalBillState.waiting),
        context,
      );
      expect(await available(), 4800);

      saved.billedAmount = 1200;
      await harness.repository.saveBill(saved, context);

      // 20% of 1200 is 240.
      expect(await available(), 4760);
    });
  });

  group('state transitions (FR-054 / M5)', () {
    Future<MedicalBill> liveBill({
      MedicalPaymentMethod method = MedicalPaymentMethod.insurerPaid,
      double amount = 1000,
    }) =>
        harness.repository.saveBill(
          bill(amount: amount, method: method, state: MedicalBillState.waiting),
          context,
        );

    test('M5: moving from planned to waiting applies the share at once',
        () async {
      final planned = await harness.repository.saveBill(bill(), context);
      expect(await available(), 5000);

      await harness.repository
          .setBillState(planned, MedicalBillState.waiting, context: context);

      expect(planned.state, MedicalBillState.waiting);
      expect((await harness.expenseFor(planned))!.amount, 200);
      expect(await available(), 4800);
    });

    test('M5: moving back to planned restores the balance', () async {
      final waiting = await liveBill();
      expect(await available(), 4800);

      await harness.repository
          .setBillState(waiting, MedicalBillState.planned, context: context);

      expect((await harness.expenseFor(waiting))!.amount, 0);
      expect(
          (await harness.expenseFor(waiting))!.status, ExpenseStatus.planned);
      expect(await available(), 5000);
    });

    test('a self-paid bill crosses planned to waiting at full cost', () async {
      final waiting = await liveBill(method: MedicalPaymentMethod.selfPaid);
      expect(await available(), 4000);

      await harness.repository
          .setBillState(waiting, MedicalBillState.planned, context: context);
      expect(await available(), 5000);

      await harness.repository
          .setBillState(waiting, MedicalBillState.waiting, context: context);
      expect(await available(), 4000);
    });

    test('FR-051: rejecting a live insurer-paid bill raises it to full',
        () async {
      final waiting = await liveBill();
      expect(await available(), 4800);

      await harness.repository
          .setBillState(waiting, MedicalBillState.rejected, context: context);

      expect((await harness.expenseFor(waiting))!.amount, 1000);
      expect(await available(), 4000);
    });

    test('FR-050: rejecting a self-paid bill leaves the amount unchanged',
        () async {
      final waiting = await liveBill(method: MedicalPaymentMethod.selfPaid);
      expect(await available(), 4000);

      await harness.repository
          .setBillState(waiting, MedicalBillState.rejected, context: context);

      expect((await harness.expenseFor(waiting))!.amount, 1000);
      expect(await available(), 4000);
    });
  });

  group('payment method (FR-041)', () {
    test('switching to self-paid raises the cost to the full charge', () async {
      final saved = await harness.repository.saveBill(
        bill(state: MedicalBillState.waiting),
        context,
      );
      expect(await available(), 4800);

      await harness.repository.setPaymentMethod(
        saved,
        MedicalPaymentMethod.selfPaid,
        context: context,
      );

      expect((await harness.expenseFor(saved))!.amount, 1000);
      expect(await available(), 4000);
    });

    test('switching back to insurer-paid drops it to the share', () async {
      final saved = await harness.repository.saveBill(
        bill(
          method: MedicalPaymentMethod.selfPaid,
          state: MedicalBillState.waiting,
        ),
        context,
      );
      expect(await available(), 4000);

      await harness.repository.setPaymentMethod(
        saved,
        MedicalPaymentMethod.insurerPaid,
        context: context,
      );

      expect((await harness.expenseFor(saved))!.amount, 200);
      expect(await available(), 4800);
    });

    test('D2: switching to insurer-paid clears the insurer reply', () async {
      final saved = await harness.repository.saveBill(
        bill(
          method: MedicalPaymentMethod.selfPaid,
          state: MedicalBillState.waiting,
        ),
        context,
      );
      saved.insurerReplyPath = '/tmp/eob.pdf';
      await harness.repository.saveBill(saved, context);

      await harness.repository.setPaymentMethod(
        saved,
        MedicalPaymentMethod.insurerPaid,
        context: context,
      );

      expect(saved.insurerReplyPath, isNull);
    });

    test('switching to insurer-paid clears a payout that can no longer apply',
        () async {
      final saved = await harness.repository.saveBill(
        bill(
          method: MedicalPaymentMethod.selfPaid,
          state: MedicalBillState.waiting,
        ),
        context,
      );
      await harness.repository.logReimbursement(saved, amount: 800);
      expect(await available(), 4800);

      await harness.repository.setPaymentMethod(
        saved,
        MedicalPaymentMethod.insurerPaid,
        context: context,
      );

      expect(saved.reimbursedAmount, 0);
      expect(await harness.allReimbursements(), isEmpty);
    });

    test('R-1: switching to insurer-paid un-finishes the bill', () async {
      final saved = await harness.repository.saveBill(
        bill(
          method: MedicalPaymentMethod.selfPaid,
          state: MedicalBillState.waiting,
        ),
        context,
      );
      await harness.repository.logReimbursement(saved, amount: 800);
      expect(saved.state, MedicalBillState.finished);

      await harness.repository.setPaymentMethod(
        saved,
        MedicalPaymentMethod.insurerPaid,
        context: context,
      );

      expect(saved.state, MedicalBillState.paid);
    });

    test('setting the same method again is a no-op', () async {
      final saved = await harness.repository.saveBill(
        bill(state: MedicalBillState.waiting),
        context,
      );

      await harness.repository.setPaymentMethod(
        saved,
        MedicalPaymentMethod.insurerPaid,
        context: context,
      );

      expect(await available(), 4800);
      expect((await harness.expenseFor(saved))!.amount, 200);
    });
  });

  group('reimbursement (FR-034 / FR-044)', () {
    Future<MedicalBill> selfPaidBill({double amount = 1000}) =>
        harness.repository.saveBill(
          bill(
            amount: amount,
            method: MedicalPaymentMethod.selfPaid,
            state: MedicalBillState.waiting,
          ),
          context,
        );

    test('logging a payout lifts available and finishes the bill', () async {
      final paid = await selfPaidBill();
      expect(await available(), 4000);

      await harness.repository.logReimbursement(paid, amount: 800);

      expect(paid.state, MedicalBillState.finished);
      expect(paid.reimbursedAmount, 800);
      expect(paid.netOutOfPocket, 200);

      expect(await available(), 4800);
      expect(await available(), 5000 - paid.netOutOfPocket);
    });

    test('R-2: re-logging replaces the payout instead of stacking one',
        () async {
      final paid = await selfPaidBill();
      await harness.repository.logReimbursement(paid, amount: 800);
      await harness.repository.logReimbursement(paid, amount: 750);

      expect(await harness.allReimbursements(), hasLength(1));
      expect(await available(), 4750);
      expect(paid.reimbursedAmount, 750);
    });

    test('a payout larger than the charge is honoured as entered', () async {
      final paid = await selfPaidBill();
      await harness.repository.logReimbursement(paid, amount: 1000);

      expect(paid.netOutOfPocket, 0);
      expect(await available(), 5000);
    });

    test('a partial payout leaves the rest owed', () async {
      final paid = await selfPaidBill();
      await harness.repository.logReimbursement(paid, amount: 150);

      expect(paid.netOutOfPocket, closeTo(850, 1e-9));
      expect(await available(), 4150);
    });

    test('R-5: the payout is attributed to the bill month', () async {
      final paid = await selfPaidBill();
      await harness.repository.logReimbursement(
        paid,
        amount: 800,
        date: DateTime(2026, 6, 1),
      );

      final row = (await harness.allReimbursements()).single;
      expect(row.originYearMonth, context.yearMonth);
    });

    test('the payout hangs off the bill expense', () async {
      final paid = await selfPaidBill();
      await harness.repository.logReimbursement(paid, amount: 800);

      final row = (await harness.allReimbursements()).single;
      expect(row.expenseId, paid.linkedExpenseId);
      expect(row.amount, 800);
    });

    test('FR-044: an insurer-paid bill cannot be reimbursed', () async {
      final insurerPaid = await harness.repository.saveBill(
        bill(state: MedicalBillState.waiting),
        context,
      );

      expect(
        () => harness.repository.logReimbursement(insurerPaid, amount: 800),
        throwsA(isA<ArgumentError>()),
      );
      expect(insurerPaid.reimbursedAmount, 0);
    });

    test('T1: a self-paid bill cannot finish without a payout', () async {
      final paid = await selfPaidBill();

      expect(
        () => harness.repository.setBillState(paid, MedicalBillState.finished),
        throwsArgumentError,
      );
      expect(paid.state, isNot(MedicalBillState.finished));
    });

    test('a state change plus an amount finishes the bill in one step',
        () async {
      final paid = await selfPaidBill();

      await harness.repository.setBillState(
        paid,
        MedicalBillState.finished,
        context: context,
        reimbursedAmount: 800,
      );

      expect(paid.state, MedicalBillState.finished);
      expect(paid.reimbursedAmount, 800);
      expect(await available(), 4800);
    });

    test('R-1: an insurer-paid bill cannot be finished', () async {
      final insurerPaid = await harness.repository.saveBill(
        bill(state: MedicalBillState.waiting),
        context,
      );

      expect(
        () => harness.repository
            .setBillState(insurerPaid, MedicalBillState.finished),
        throwsA(isA<InvalidBillTransitionException>()),
      );
    });

    test('T4: rejecting a reimbursed bill removes the injected payout',
        () async {
      final paid = await selfPaidBill();
      await harness.repository.logReimbursement(paid, amount: 800);
      expect(await available(), 4800);

      await harness.repository
          .setBillState(paid, MedicalBillState.rejected, context: context);

      expect(paid.state, MedicalBillState.rejected);
      expect(paid.reimbursedAmount, 0);
      expect(await harness.allReimbursements(), isEmpty);
      expect(await available(), 4000);
    });

    test('moving away from finished also drops the payout', () async {
      final paid = await selfPaidBill();
      await harness.repository.logReimbursement(paid, amount: 800);
      expect(await harness.allReimbursements(), hasLength(1));

      await harness.repository
          .setBillState(paid, MedicalBillState.waiting, context: context);

      expect(paid.reimbursedAmount, 0);
      expect(await harness.allReimbursements(), isEmpty);
      expect(await available(), 4000);
    });

    test('a non-positive payout is rejected', () async {
      final paid = await selfPaidBill();
      expect(
        () => harness.repository.logReimbursement(paid, amount: 0),
        throwsArgumentError,
      );
      expect(paid.reimbursedAmount, 0);
    });
  });

  group('documents (FR-047 / D2)', () {
    test('a self-paid bill keeps its insurer reply', () async {
      final saved = await harness.repository.saveBill(
        bill(
          method: MedicalPaymentMethod.selfPaid,
          state: MedicalBillState.waiting,
        ),
        context,
      );
      saved
        ..billPhotoPath = '/tmp/bill.jpg'
        ..insurerReplyPath = '/tmp/eob.pdf';
      final result = await harness.repository.saveBill(saved, context);

      expect(result.billPhotoPath, '/tmp/bill.jpg');
      expect(result.insurerReplyPath, '/tmp/eob.pdf');
    });

    test('an insurer-paid bill cannot carry an insurer reply', () async {
      final saved = await harness.repository.saveBill(
        bill(state: MedicalBillState.waiting),
        context,
      );
      saved.insurerReplyPath = '/tmp/eob.pdf';

      expect(
        () => harness.repository.saveBill(saved, context),
        throwsA(isA<InvalidDocumentException>()),
      );
    });

    test('both documents are optional', () async {
      final saved = await harness.repository.saveBill(
        bill(state: MedicalBillState.waiting),
        context,
      );

      expect(saved.billPhotoPath, isNull);
      expect(saved.insurerReplyPath, isNull);
    });
  });

  group('owning month (FR-055)', () {
    test('a bill lands in its service month by default', () async {
      final saved = await harness.repository.saveBill(
        bill(month: 3, state: MedicalBillState.waiting),
        MedicalBillContext(
          profileId: context.profileId,
          budgetId: context.budgetId,
          yearMonth: '2026-03',
          primaryCurrency: 'USD',
        ),
      );

      expect(saved.yearMonth, '2026-03');
    });

    test('an explicit month overrides the service month', () async {
      final saved = await harness.repository.saveBill(
        bill(month: 3, state: MedicalBillState.waiting),
        MedicalBillContext(
          profileId: context.profileId,
          budgetId: context.budgetId,
          yearMonth: '2026-03',
          primaryCurrency: 'USD',
        ),
      );
      saved.yearMonth = '2026-02';
      final result = await harness.repository.saveBill(saved, context);

      expect(result.yearMonth, '2026-02');
      expect((await harness.expenseFor(result))!.yearMonth, '2026-02');
    });

    test('bills are queried by their owning month', () async {
      await harness.repository.saveBill(
        bill(month: 1, state: MedicalBillState.waiting),
        context,
      );
      await harness.repository.saveBill(
        bill(month: 2, state: MedicalBillState.waiting),
        MedicalBillContext(
          profileId: context.profileId,
          budgetId: context.budgetId,
          yearMonth: '2026-02',
          primaryCurrency: 'USD',
        ),
      );

      final january = await harness.repository
          .getMedicalBillsForMonth(context.profileId, '2026-01');
      final february = await harness.repository
          .getMedicalBillsForMonth(context.profileId, '2026-02');

      expect(january, hasLength(1));
      expect(february, hasLength(1));
      expect(january.single.billedAmount, 1000);
      expect(february.single.billedAmount, 1000);
    });
  });

  group('deletion', () {
    test('deleting a bill removes its expense and reimbursement', () async {
      final saved = await harness.repository.saveBill(
        bill(
          method: MedicalPaymentMethod.selfPaid,
          state: MedicalBillState.waiting,
        ),
        context,
      );
      await harness.repository.logReimbursement(saved, amount: 800);

      await harness.repository.deleteBill(saved.id, force: true);

      expect(await harness.allBills(), isEmpty);
      expect(await harness.allExpenses(), isEmpty);
      expect(await harness.allReimbursements(), isEmpty);
      expect(await available(), 5000);
    });

    test('a reimbursed bill requires force to delete', () async {
      final saved = await harness.repository.saveBill(
        bill(
          method: MedicalPaymentMethod.selfPaid,
          state: MedicalBillState.waiting,
        ),
        context,
      );
      await harness.repository.logReimbursement(saved, amount: 800);

      expect(
        () => harness.repository.deleteBill(saved.id),
        throwsA(isA<ReimbursedBillDeletionException>()),
      );
      expect(await harness.allBills(), hasLength(1));

      await harness.repository.deleteBill(saved.id, force: true);
      expect(await harness.allBills(), isEmpty);
    });

    test('deleting an unknown bill is a no-op', () async {
      await harness.repository.deleteBill(9999);
      expect(await harness.allBills(), isEmpty);
    });
  });

  group('follow-up reminders (FR-009)', () {
    test('a reminder date can be set and cleared', () async {
      final saved = await harness.repository.saveBill(bill(), context);
      final when = DateTime(2036, 2, 1);

      await harness.repository.setFollowUpDate(saved, when);
      expect(saved.followUpDate, when);

      await harness.repository.setFollowUpDate(saved, null);
      expect(saved.followUpDate, isNull);
    });
  });

  group('validation', () {
    test('a zero billed amount is rejected', () async {
      expect(
        () => harness.repository
            .saveBill(MedicalBill()..billedAmount = 0, context),
        throwsArgumentError,
      );
    });

    test('a negative billed amount is rejected', () async {
      expect(
        () => harness.repository
            .saveBill(MedicalBill()..billedAmount = -50, context),
        throwsArgumentError,
      );
    });

    test('FR-048: an out-of-range patient share is rejected', () async {
      expect(
        () => harness.repository.saveBill(
          MedicalBill()
            ..billedAmount = 100
            ..patientSharePercent = 140,
          context,
        ),
        throwsArgumentError,
      );
      expect(
        () => harness.repository.saveBill(
          MedicalBill()
            ..billedAmount = 100
            ..patientSharePercent = -5,
          context,
        ),
        throwsArgumentError,
      );
    });
  });

  group('provider directory (FR-008)', () {
    test('saving the same name twice reuses the existing entry', () async {
      final first = await harness.repository
          .saveProvider(profileId: context.profileId, name: 'City Hospital');
      final second = await harness.repository
          .saveProvider(profileId: context.profileId, name: 'city hospital');

      expect(second.id, first.id);
      expect(await harness.allProviders(), hasLength(1));
    });

    test('findOrCreateProvider registers a typed provider once', () async {
      final created = await harness.repository
          .findOrCreateProvider(profileId: context.profileId, name: 'Dr. Who');
      final again = await harness.repository
          .findOrCreateProvider(profileId: context.profileId, name: 'Dr. Who');

      expect(created.autoCreated, isTrue);
      expect(again.id, created.id);
      expect(await harness.allProviders(), hasLength(1));
    });

    test('an empty provider name is rejected', () async {
      expect(
        () => harness.repository
            .saveProvider(profileId: context.profileId, name: '   '),
        throwsArgumentError,
      );
    });

    test('providers are scoped per profile', () async {
      await harness.repository
          .saveProvider(profileId: context.profileId, name: 'City Hospital');

      final other = await harness.seedBudget(yearMonth: '2026-02');
      final visible =
          await harness.repository.getMedicalProviders(other.profileId);

      expect(visible, isEmpty);
    });

    test('a removed provider is no longer listed', () async {
      final provider = await harness.repository
          .saveProvider(profileId: context.profileId, name: 'Dr. Gone');
      await harness.repository.deleteProvider(provider.id);

      final remaining =
          await harness.repository.getMedicalProviders(context.profileId);
      expect(remaining, isEmpty);
    });
  });

  group('family members', () {
    test('members are created, renamed and removed', () async {
      final member = await harness.repository.saveFamilyMember(
        profileId: context.profileId,
        name: 'Alice',
        relation: 'Spouse',
      );
      final listed =
          await harness.repository.getFamilyMembers(context.profileId);
      expect(listed, hasLength(1));
      expect(listed.single.name, 'Alice');

      await harness.repository.saveFamilyMember(
        id: member.id,
        profileId: context.profileId,
        name: 'Alicia',
        relation: 'Spouse',
      );
      final renamed =
          await harness.repository.getFamilyMembers(context.profileId);
      expect(renamed.single.name, 'Alicia');

      await harness.repository.deleteFamilyMember(member.id);
      expect(
        await harness.repository.getFamilyMembers(context.profileId),
        isEmpty,
      );
    });

    test('an empty member name is rejected', () async {
      expect(
        () => harness.repository.saveFamilyMember(
          profileId: context.profileId,
          name: ' ',
          relation: 'Self',
        ),
        throwsArgumentError,
      );
    });
  });

  group('service types', () {
    test('service types are created, renamed and archived', () async {
      final created = await harness.repository.saveServiceType(
        profileId: context.profileId,
        name: 'Physician',
      );

      final listed =
          await harness.repository.getAllServiceTypes(context.profileId);
      expect(listed.map((t) => t.name), contains('Physician'));

      await harness.repository.saveServiceType(
        id: created.id,
        profileId: context.profileId,
        name: 'Specialist',
      );
      final renamed =
          await harness.repository.getAllServiceTypes(context.profileId);
      expect(renamed.single.name, 'Specialist');

      await harness.repository.archiveServiceType(created.id);

      // R10: archiving hides it from new choices but keeps it readable for the
      // historical bills that already reference it.
      final offered =
          await harness.repository.getServiceTypes(context.profileId);
      expect(offered, isEmpty);

      final archived =
          await harness.repository.getAllServiceTypes(context.profileId);
      expect(archived.single.name, 'Specialist');
      expect(archived.single.archived, isTrue);
    });

    test('a duplicate service type name is rejected', () async {
      await harness.repository.saveServiceType(
        profileId: context.profileId,
        name: 'Physician',
      );

      expect(
        () => harness.repository.saveServiceType(
          profileId: context.profileId,
          name: 'physician',
        ),
        throwsA(isA<DuplicateServiceTypeException>()),
      );
    });
  });
}
