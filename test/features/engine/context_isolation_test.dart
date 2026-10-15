import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/expenses/repositories/expense_repository.dart';
import 'package:budget_buddy/features/expenses/repositories/reimbursement_repository.dart';
import 'package:budget_buddy/features/finance/repositories/month_finance_repository.dart';
import 'package:budget_buddy/features/spaces/repositories/space_role_guard.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../medical/repositories/medical_test_harness.dart';

/// T025: money rows are fully isolated per context (SC-001) and every row owns
/// exactly one context (SC-005, FR-003) — a personal profile's budget, expenses,
/// reimbursements and medical bills are invisible to other profiles and to a
/// shared space, and no row may carry both or neither owner.
void main() {
  const yearMonth = '2026-01';

  late MedicalTestHarness harness;
  late ExpenseRepository expenses;
  late ReimbursementRepository reimbursements;
  late MonthFinanceRepository finance;
  late SpaceAccessGuard guard;

  late ContextRef ava;
  late ContextRef bea;
  late ContextRef home;

  late MonthlyBudget avaBudget;
  late MonthlyBudget beaBudget;
  late MonthlyBudget homeBudget;

  /// Seeds profiles Ava(id auto) and Bea, one shared space `Home`, and one
  /// budget/expense/reimbursement/medical-bill per context for [yearMonth].
  /// Amounts are whole minor units; every context gets a distinctly-scaled
  /// figure so a bleed across contexts is visible in a single equality check.
  Future<void> seedAll() async {
    final avaRow = UserProfile()
      ..name = 'Ava'
      ..primaryCurrency = PrimaryCurrency.usd
      ..monthlyAvailableAmount = 10000
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    final beaRow = UserProfile()
      ..name = 'Bea'
      ..primaryCurrency = PrimaryCurrency.usd
      ..monthlyAvailableAmount = 20000
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    final space = SharedSpace()
      ..name = 'Home'
      ..avatar = '👨‍👩‍👧'
      ..currency = PrimaryCurrency.usd
      ..createdByProfileId = 1
      ..createdAt = DateTime(2026);

    await harness.isar.writeTxn(() async {
      final avaId = await harness.isar.userProfiles.put(avaRow);
      final beaId = await harness.isar.userProfiles.put(beaRow);
      final spaceId = await harness.isar.sharedSpaces.put(space);

      ava = ContextRef.personal(profileId: avaId, yearMonth: yearMonth);
      bea = ContextRef.personal(profileId: beaId, yearMonth: yearMonth);
      home = ContextRef.shared(spaceId: spaceId, yearMonth: yearMonth);

      avaBudget = MonthlyBudget()
        ..yearMonth = yearMonth
        ..profileId = avaId
        ..baseAvailableAmount = 1000
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026);
      beaBudget = MonthlyBudget()
        ..yearMonth = yearMonth
        ..profileId = beaId
        ..baseAvailableAmount = 2000
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026);
      homeBudget = MonthlyBudget()
        ..yearMonth = yearMonth
        ..sharedSpaceId = spaceId
        ..baseAvailableAmount = 3000
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026);

      avaBudget.id = await harness.isar.monthlyBudgets.put(avaBudget);
      beaBudget.id = await harness.isar.monthlyBudgets.put(beaBudget);
      homeBudget.id = await harness.isar.monthlyBudgets.put(homeBudget);

      final avaExpense = Expense(
        profileId: avaId,
        yearMonth: yearMonth,
        title: 'Ava rent',
        amount: 100000,
        currency: 'usd',
        categoryId: 'general',
        date: DateTime(2026, 1, 5),
        budgetId: avaBudget.id,
      );
      final beaExpense = Expense(
        profileId: beaId,
        yearMonth: yearMonth,
        title: 'Bea groceries',
        amount: 200000,
        currency: 'usd',
        categoryId: 'general',
        date: DateTime(2026, 1, 6),
        budgetId: beaBudget.id,
      );
      final homeExpense = Expense(
        profileId: 0,
        sharedSpaceId: spaceId,
        yearMonth: yearMonth,
        title: 'Home wifi',
        amount: 300000,
        currency: 'usd',
        categoryId: 'general',
        date: DateTime(2026, 1, 7),
        budgetId: homeBudget.id,
      );
      final avaExpenseId = await harness.isar.expenses.put(avaExpense);
      final beaExpenseId = await harness.isar.expenses.put(beaExpense);
      final homeExpenseId = await harness.isar.expenses.put(homeExpense);

      await harness.isar.reimbursements.putAll([
        Reimbursement(
          profileId: avaId,
          expenseId: avaExpenseId,
          originYearMonth: yearMonth,
          amount: 10000,
          currency: 'usd',
          date: DateTime(2026, 1, 20),
        ),
        Reimbursement(
          profileId: beaId,
          expenseId: beaExpenseId,
          originYearMonth: yearMonth,
          amount: 20000,
          currency: 'usd',
          date: DateTime(2026, 1, 21),
        ),
        Reimbursement(
          profileId: 0,
          sharedSpaceId: spaceId,
          expenseId: homeExpenseId,
          originYearMonth: yearMonth,
          amount: 30000,
          currency: 'usd',
          date: DateTime(2026, 1, 22),
        ),
      ]);

      await harness.isar.medicalBills.putAll([
        MedicalBill()
          ..profileId = avaId
          ..yearMonth = yearMonth
          ..linkedExpenseId = avaExpenseId
          ..billedAmount = 400000
          ..currency = 'usd'
          ..paymentMethod = MedicalPaymentMethod.selfPaid
          ..state = MedicalBillState.finished
          ..serviceDate = DateTime(2026, 1, 10),
        MedicalBill()
          ..profileId = beaId
          ..yearMonth = yearMonth
          ..linkedExpenseId = beaExpenseId
          ..billedAmount = 500000
          ..currency = 'usd'
          ..paymentMethod = MedicalPaymentMethod.selfPaid
          ..state = MedicalBillState.finished
          ..serviceDate = DateTime(2026, 1, 11),
        MedicalBill()
          ..sharedSpaceId = spaceId
          ..yearMonth = yearMonth
          ..linkedExpenseId = homeExpenseId
          ..billedAmount = 600000
          ..currency = 'usd'
          ..paymentMethod = MedicalPaymentMethod.selfPaid
          ..state = MedicalBillState.finished
          ..serviceDate = DateTime(2026, 1, 12),
      ]);
    });
  }

  setUp(() async {
    harness = await MedicalTestHarness.create();
    expenses = ExpenseRepository(harness.isar);
    reimbursements = ReimbursementRepository(harness.isar);
    finance = MonthFinanceRepository(harness.isar);
    guard = const SpaceAccessGuard();
    await seedAll();
  });

  tearDown(() async {
    await harness.close();
  });

  group('SC-001: each context reads only its own rows', () {
    test('month rows are scoped by context', () async {
      expect((await finance.getMonthInContext(ava))!.baseAvailableAmount, 1000);
      expect((await finance.getMonthInContext(bea))!.baseAvailableAmount, 2000);
      expect(
        (await finance.getMonthInContext(home))!.baseAvailableAmount,
        3000,
      );
    });

    test('expense rows are scoped by context', () async {
      for (final (context, expected) in [
        (ava, ['Ava rent']),
        (bea, ['Bea groceries']),
        (home, ['Home wifi']),
      ]) {
        final rows = await expenses.getExpensesForContext(context);
        expect(rows.map((e) => e.title), expected,
            reason: 'context $context leaked another context’s expense');
      }
    });

    test('reimbursement rows are scoped by context', () async {
      for (final (context, expected) in [
        (ava, [10000]),
        (bea, [20000]),
        (home, [30000]),
      ]) {
        final rows = await reimbursements.getReimbursementsForContext(context);
        expect(rows.map((r) => r.amount), expected,
            reason: 'context $context leaked another context’s reimbursement');
      }
    });

    test('medical bill rows are scoped by context', () async {
      for (final (context, expected) in [
        (ava, [400000]),
        (bea, [500000]),
        (home, [600000]),
      ]) {
        final rows =
            await harness.repository.watchMedicalBillsForContext(context).first;
        expect(rows.map((b) => b.billedAmount), expected,
            reason: 'context $context leaked another context’s bill');
      }
    });

    test('the live expense stream scopes by context', () async {
      final avaRows = await expenses.watchExpensesForContext(ava).first;
      final homeRows = await expenses.watchExpensesForContext(home).first;
      expect(avaRows.map((e) => e.title), ['Ava rent']);
      expect(homeRows.map((e) => e.title), ['Home wifi']);
    });
  });

  group('SC-005: every money row has exactly one owner', () {
    test('each seeded row passes the exactly-one-context guard', () async {
      for (final budget
          in await harness.isar.monthlyBudgets.where().findAll()) {
        guard.assertExactlyOneContext(
          profileId: budget.profileId,
          sharedSpaceId: budget.sharedSpaceId,
          owner: 'MonthlyBudget',
        );
      }
      for (final row in await harness.isar.expenses.where().findAll()) {
        guard.assertExactlyOneContext(
          profileId: row.profileId == 0 ? null : row.profileId,
          sharedSpaceId: row.sharedSpaceId,
          owner: 'Expense',
        );
      }
      for (final row in await harness.isar.reimbursements.where().findAll()) {
        guard.assertExactlyOneContext(
          profileId: row.profileId == 0 ? null : row.profileId,
          sharedSpaceId: row.sharedSpaceId,
          owner: 'Reimbursement',
        );
      }
      for (final row in await harness.isar.medicalBills.where().findAll()) {
        guard.assertExactlyOneContext(
          profileId: row.profileId,
          sharedSpaceId: row.sharedSpaceId,
          owner: 'MedicalBill',
        );
      }
    });

    test('the guard refuses a row carrying both context owners', () {
      expect(
        () => guard.assertExactlyOneContext(
          profileId: 1,
          sharedSpaceId: 2,
          owner: 'MonthlyBudget',
        ),
        throwsA(isA<UnauthorizedSpaceAction>()),
      );
    });

    test('the guard refuses a row carrying neither context owner', () {
      expect(
        () => guard.assertExactlyOneContext(
          profileId: null,
          sharedSpaceId: null,
          owner: 'MonthlyBudget',
        ),
        throwsA(isA<UnauthorizedSpaceAction>()),
      );
    });

    test('the guard accepts exactly-one-context rows', () {
      expect(
        () => guard.assertExactlyOneContext(
          profileId: 1,
          sharedSpaceId: null,
          owner: 'MonthlyBudget',
        ),
        returnsNormally,
      );
      expect(
        () => guard.assertExactlyOneContext(
          profileId: null,
          sharedSpaceId: 2,
          owner: 'MonthlyBudget',
        ),
        returnsNormally,
      );
    });

    test('a write to one context never mutates a sibling context', () async {
      await finance.saveOpeningBalanceInContext(ava, 999);
      await finance.saveConvertToInContext(ava, CurrencyCode.eur);

      final afterAva = (await finance.getMonthInContext(ava))!;
      expect(afterAva.baseAvailableAmount, 999);
      expect(afterAva.openingBalanceConfirmed, isTrue);
      expect(afterAva.currency, 'eur');

      // Bea and Home keep their own opening balances, flags and convert-to.
      final afterBea = (await finance.getMonthInContext(bea))!;
      expect(afterBea.baseAvailableAmount, 2000);
      expect(afterBea.openingBalanceConfirmed, isFalse);
      expect(afterBea.currency, isNull);

      final afterHome = (await finance.getMonthInContext(home))!;
      expect(afterHome.baseAvailableAmount, 3000);
      expect(afterHome.openingBalanceConfirmed, isFalse);
      expect(afterHome.currency, isNull);
    });
  });
}
