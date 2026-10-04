import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:budget_buddy/features/medical/repositories/medical_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'medical_test_harness.dart';

/// End-to-end validation of the quickstart.md scenarios against a real Isar
/// instance, so the expense and reimbursement rows the engine reads exist.
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
    double coverage = 80,
    int month = 1,
    int? providerId,
  }) {
    return MedicalBill()
      ..billedAmount = amount
      ..insuranceCoveragePercent = coverage
      ..providerId = providerId
      ..serviceDate = DateTime(2026, month, 15);
  }

  group('Scenario 1 — insurance profile', () {
    test('deductible starts empty with the configured limits', () async {
      final profile =
          await harness.repository.getInsuranceProfile(context.profileId, 2026);

      expect(profile, isNotNull);
      expect(profile!.individualDeductible, 2000);
      expect(profile.defaultCoveragePercent, 80);

      final progress =
          DeductibleProgress.from(bills: const [], insurance: profile);
      expect(progress.outOfPocketTotal, 0);
      expect(progress.fractionOf(), 0);
      expect(progress.remainingFor(), 2000);
    });

    test('each profile resolves its own insurance record', () async {
      final other = await harness.seedBudget(yearMonth: '2026-02');
      expect(other.profileId, isNot(context.profileId));

      final mine =
          await harness.repository.getInsuranceProfile(context.profileId, 2026);
      expect(mine!.profileId, context.profileId);

      final theirs =
          await harness.repository.getInsuranceProfile(other.profileId, 2026);
      expect(theirs!.profileId, other.profileId);
    });

    test('only bills from the requested year count toward the deductible',
        () async {
      await harness.repository.saveBill(bill(), context);
      await harness.repository.saveBill(
        MedicalBill()
          ..billedAmount = 500
          ..insuranceCoveragePercent = 100
          ..serviceDate = DateTime(2025, 6, 1),
        context,
      );

      final currentYear = await harness.repository
          .getMedicalBillsForYear(context.profileId, 2026);
      expect(currentYear, hasLength(1));
      expect(currentYear.single.billedAmount, 1000);

      final lastYear = await harness.repository
          .getMedicalBillsForYear(context.profileId, 2025);
      expect(lastYear, hasLength(1));
      expect(lastYear.single.billedAmount, 500);
    });
  });

  group('Scenario 2 — log a medical bill', () {
    test('saving creates a linked expense that defaults to planned', () async {
      final saved = await harness.repository.saveBill(bill(), context);

      expect(saved.linkedExpenseId, isNotNull);
      final expense = (await harness.expenseFor(saved))!;
      expect(expense.amount, 1000);
      expect(expense.type, ExpenseType.medical);
      expect(expense.categoryId, MedicalRepository.medicalCategoryId);
      expect(expense.status, ExpenseStatus.planned);
      expect(expense.isReimbursable, isTrue);
      expect(expense.exchangeRateToPrimary, 1.0);
      expect(expense.yearMonth, context.yearMonth);
      expect(expense.profileId, context.profileId);
      expect(expense.budgetId, context.budgetId);

      // Planned costs must not touch the budget yet.
      expect(await available(), 5000);
    });

    test('estimated out-of-pocket is 200 for 1000 at 80% coverage', () async {
      final saved = await harness.repository.saveBill(bill(), context);

      expect(saved.insuranceCoveredAmount, 800);
      expect(saved.estimatedOutPocket, 200);

      final insurance =
          await harness.repository.getInsuranceProfile(context.profileId, 2026);
      final progress =
          DeductibleProgress.from(bills: [saved], insurance: insurance);
      expect(progress.outOfPocketTotal, 200);
      expect(progress.fractionOf(), closeTo(0.1, 1e-9));
      expect(progress.remainingFor(), 1800);
    });

    test('marking the bill paid reduces trueAvailable by the full amount',
        () async {
      final saved = await harness.repository.saveBill(bill(), context);

      final delta = await harness.repository
          .setBillPaidToProvider(saved, context, paid: true);

      expect(delta.trueAvailableDelta, -1000);
      final expense = (await harness.expenseFor(saved))!;
      expect(expense.status, ExpenseStatus.paid);
      expect(expense.paidAt, isNotNull);
      expect(await available(), 4000);
    });

    test('marking it paid then back to planned restores the balance', () async {
      final saved = await harness.repository.saveBill(bill(), context);

      await harness.repository
          .setBillPaidToProvider(saved, context, paid: true);
      final back = await harness.repository
          .setBillPaidToProvider(saved, context, paid: false);

      expect(back.trueAvailableDelta, 1000);
      expect((await harness.expenseFor(saved))!.paidAt, isNull);
      expect(await available(), 5000);
    });

    test('saving as paid drops the balance in one step', () async {
      await harness.repository.saveBill(
        bill(),
        context,
        status: ExpenseStatus.paid,
      );
      expect(await available(), 4000);
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
        ..insuranceCoveragePercent = 50;
      await harness.repository.saveBill(saved, context);

      expect(saved.linkedExpenseId, expenseId);
      expect(await harness.allExpenses(), hasLength(1));
      final expense = await harness.isar.expenses.get(expenseId!);
      expect(expense!.amount, 1500);
    });

    test('raising the billed amount of a paid bill moves the balance',
        () async {
      final saved = await harness.repository.saveBill(
        bill(),
        context,
        status: ExpenseStatus.paid,
      );
      expect(await available(), 4000);

      saved.billedAmount = 1200;
      await harness.repository.saveBill(saved, context);

      expect(await available(), 3800);
    });
  });

  group('Scenario 3 — log a reimbursement', () {
    Future<MedicalBill> paidBill({double amount = 1000}) =>
        harness.repository.saveBill(
          bill(amount: amount),
          context,
          status: ExpenseStatus.paid,
        );

    test('reimbursing 800 lifts trueAvailable and closes the claim', () async {
      final paid = await paidBill();
      expect(await available(), 4000);

      await harness.repository.logReimbursement(paid, amount: 800);

      expect(paid.claimStatus, ClaimStatus.reimbursed);
      expect(paid.reimbursedAmount, 800);
      expect(paid.netOutOfPocket, 200);

      expect(await available(), 4800);
      // Net medical cost is exactly the out-of-pocket estimate.
      expect(await available(), 5000 - paid.netOutOfPocket);
    });

    test('re-logging replaces the payout instead of stacking one', () async {
      final paid = await paidBill();
      await harness.repository.logReimbursement(paid, amount: 800);
      await harness.repository.logReimbursement(paid, amount: 750);

      expect(await harness.allReimbursements(), hasLength(1));
      expect(await available(), 4750);
      expect(paid.reimbursedAmount, 750);
    });

    test('a reimbursement larger than the estimate is honoured as entered',
        () async {
      final paid = await paidBill();
      await harness.repository.logReimbursement(paid, amount: 1000);

      expect(paid.netOutOfPocket, 0);
      expect(await available(), 5000);
    });

    test('a partial reimbursement leaves the rest owed', () async {
      final paid = await paidBill();
      await harness.repository.logReimbursement(paid, amount: 150);

      // Paid 1000 to the provider, got 150 back -> 850 still owed.
      expect(paid.netOutOfPocket, closeTo(850, 1e-9));
      expect(await available(), 4150);
    });

    test('the reimbursement hangs off the bill expense', () async {
      final paid = await paidBill();
      await harness.repository.logReimbursement(paid, amount: 800);

      final rows = await harness.allReimbursements();
      expect(rows.single.expenseId, paid.linkedExpenseId);
      expect(rows.single.amount, 800);
    });

    test('moving a claim to denied removes the injected payout', () async {
      final paid = await paidBill();
      await harness.repository.logReimbursement(paid, amount: 800);
      expect(await available(), 4800);

      await harness.repository
          .updateClaimStatus(paid, status: ClaimStatus.denied);

      expect(paid.claimStatus, ClaimStatus.denied);
      expect(paid.reimbursedAmount, 0);
      expect(await harness.allReimbursements(), isEmpty);
      expect(await available(), 4000);
    });

    test('marking a claim as processing leaves the budget alone', () async {
      final paid = await paidBill();
      await harness.repository
          .updateClaimStatus(paid, status: ClaimStatus.processing);

      expect(paid.claimStatus, ClaimStatus.processing);
      expect(await available(), 4000);
    });

    test('moving back to unclaimed also drops the payout', () async {
      final paid = await paidBill();
      await harness.repository.logReimbursement(paid, amount: 800);
      await harness.repository
          .updateClaimStatus(paid, status: ClaimStatus.unclaimed);

      expect(paid.reimbursedAmount, 0);
      expect(await harness.allReimbursements(), isEmpty);
      expect(await available(), 4000);
    });

    test('marking as reimbursed without an amount is rejected', () async {
      final paid = await paidBill();
      expect(
        () => harness.repository
            .updateClaimStatus(paid, status: ClaimStatus.reimbursed),
        throwsArgumentError,
      );
      expect(paid.claimStatus, ClaimStatus.unclaimed);
    });

    test('a non-positive reimbursement is rejected', () async {
      final paid = await paidBill();
      expect(
        () => harness.repository.logReimbursement(paid, amount: 0),
        throwsArgumentError,
      );
      expect(paid.claimStatus, ClaimStatus.unclaimed);
    });

    test('a planned bill can still record a reimbursement', () async {
      final planned = await harness.repository.saveBill(bill(), context);
      await harness.repository.logReimbursement(planned, amount: 800);

      // The provider payment never happened, so the payout nets to +800.
      expect(await available(), 5800);
    });
  });

  group('deletion', () {
    test('deleting a bill removes its expense and reimbursement', () async {
      final saved = await harness.repository.saveBill(
        bill(),
        context,
        status: ExpenseStatus.paid,
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
        bill(),
        context,
        status: ExpenseStatus.paid,
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
      final when = DateTime(2026, 2, 1);

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

    test('an out-of-range coverage percentage is rejected', () async {
      expect(
        () => harness.repository.saveBill(
          MedicalBill()
            ..billedAmount = 100
            ..insuranceCoveragePercent = 140,
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
}
