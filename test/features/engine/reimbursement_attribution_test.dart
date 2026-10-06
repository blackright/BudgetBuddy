import 'dart:io';

import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/category.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/engine/month_summary.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/expenses/repositories/expense_repository.dart';
import 'package:budget_buddy/core/network/exchange_rate_cache.dart';
import 'package:budget_buddy/core/network/exchange_rate_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

/// T056 (FR-032 – FR-035, SC-005) — a reimbursement is money that came *back*,
/// so it belongs to the month of the expense it pays for, not to the month the
/// user happened to type it in.
///
/// SC-005 is stated as "entered up to 12 months late credits the original month
/// in 100% of cases", so the headline test loops the required 1/3/6/12-month
/// entry offsets and asserts the origin month's figure in every case. The
/// remaining groups pin down the two rules that make that true: one row per
/// target, and orphans kept rather than dropped.
void main() {
  late _AttributionFixture fixture;

  setUp(() async {
    fixture = await _AttributionFixture.open();
  });

  tearDown(() async {
    await fixture.close();
  });

  group('SC-005 late entry credits the origin month', () {
    // The offsets the success criterion names, plus zero as the control.
    for (final offset in [0, 1, 3, 6, 12]) {
      test('entered $offset month(s) late still credits 2026-01', () async {
        const origin = '2026-01';
        const expenseYearMonth = origin;
        final entryYearMonth = _shiftMonth(origin, offset);

        await fixture.seedExpense(yearMonth: expenseYearMonth, amount: 1200);
        await fixture.addReimbursement(
          amount: 300,
          date: DateTime(
            int.parse(entryYearMonth.substring(0, 4)),
            int.parse(entryYearMonth.substring(5, 7)),
            5,
          ),
          againstYearMonth: expenseYearMonth,
        );

        // The month of origin reports the return...
        final originSummary = await fixture.summary(origin);
        expect(originSummary.moneyReturned, 300);

        // ...and the month of entry does not double-count it.
        final entrySummary = await fixture.summary(entryYearMonth);
        expect(entrySummary.moneyReturned, offset == 0 ? 300 : 0);
      });
    }

    test('every offset credits the same origin month in one ledger', () async {
      const origin = '2026-03';
      // One target per return: FR-034 keeps a single row per target, so reusing
      // one expense would replace rather than accumulate.
      for (final offset in [1, 3, 6, 12]) {
        final entry = _shiftMonth(origin, offset);
        final target =
            await fixture.seedExpense(yearMonth: origin, amount: 500);
        await fixture.addReimbursement(
          amount: 100,
          date: DateTime(
            int.parse(entry.substring(0, 4)),
            int.parse(entry.substring(5, 7)),
            12,
          ),
          expenseId: target,
        );
      }

      final summary = await fixture.summary(origin);
      expect(summary.moneyReturned, 400);
      expect(summary.paymentsMade, 2000);
      expect(summary.kept, -2000 + 400);
    });

    test('a month crossing a year boundary still attributes correctly',
        () async {
      const origin = '2026-11';
      const entry = '2027-02';
      await fixture.seedExpense(yearMonth: origin, amount: 900);
      await fixture.addReimbursement(
        amount: 250,
        date: DateTime(2027, 2, 1),
        againstYearMonth: origin,
      );

      expect((await fixture.summary(origin)).moneyReturned, 250);
      expect((await fixture.summary(entry)).moneyReturned, 0);
    });

    test('attribution survives a year of unopened months', () async {
      const origin = '2026-06';
      await fixture.seedExpense(yearMonth: origin, amount: 500);
      await fixture.addReimbursement(
        amount: 500,
        date: DateTime(2027, 6, 1),
        againstYearMonth: origin,
      );

      // Nothing in between, and the origin month still balances.
      final summary = await fixture.summary(origin);
      expect(summary.moneyReturned, 500);
      expect(summary.kept, -500 + 500);
      // The return exactly covers the target, so nothing is in excess (R14).
      expect(summary.excessReturned, 0);
    });
  });

  group('FR-034 replacement', () {
    test('re-recording replaces the amount instead of adding to it', () async {
      const origin = '2026-01';
      await fixture.seedExpense(yearMonth: origin, amount: 1200);
      await fixture.addReimbursement(
        amount: 300,
        date: DateTime(2026, 1, 5),
        againstYearMonth: origin,
      );
      await fixture.addReimbursement(
        amount: 250,
        date: DateTime(2026, 1, 6),
        againstYearMonth: origin,
      );

      final summary = await fixture.summary(origin);
      expect(summary.moneyReturned, 250);
      // R-3: never 550.
      expect(summary.moneyReturned, isNot(550));
      expect(await fixture.repository.getReimbursementsForMonth(origin),
          hasLength(1));
    });

    test('replacement keeps the original row identity and date', () async {
      const origin = '2026-01';
      final expenseId = await fixture.seedExpense(yearMonth: origin);
      await fixture.addReimbursement(
        amount: 300,
        date: DateTime(2026, 1, 5),
        againstYearMonth: origin,
      );
      final before =
          await fixture.repository.getReimbursementsForExpense(expenseId);
      final beforeId = before.single.id;

      await fixture.addReimbursement(
        amount: 250,
        date: DateTime(2026, 1, 20),
        againstYearMonth: origin,
      );

      final after =
          await fixture.repository.getReimbursementsForExpense(expenseId);
      expect(after.single.id, beforeId);
      expect(after.single.date, DateTime(2026, 1, 20));
      expect(after.single.originYearMonth, origin);
    });

    test('two different targets each keep their own return', () async {
      const january = '2026-01';
      final first = await fixture.seedExpense(yearMonth: january, amount: 500);
      final second = await fixture.seedExpense(yearMonth: january, amount: 700);

      await fixture.addReimbursement(
        amount: 200,
        date: DateTime(2026, 1, 4),
        expenseId: first,
      );
      await fixture.addReimbursement(
        amount: 350,
        date: DateTime(2026, 1, 8),
        expenseId: second,
      );

      final summary = await fixture.summary(january);
      expect(summary.moneyReturned, 550);
      expect(await fixture.repository.getReimbursementsForMonth(january),
          hasLength(2));
    });
  });

  group('FR-035 orphan retention', () {
    test('deleting the target keeps the row and flags it', () async {
      const origin = '2026-01';
      final expenseId =
          await fixture.seedExpense(yearMonth: origin, amount: 800);
      await fixture.addReimbursement(
        amount: 260,
        date: DateTime(2026, 1, 9),
        againstYearMonth: origin,
      );
      expect((await fixture.summary(origin)).moneyReturned, 260);

      await fixture.repository.deleteExpense(expenseId);

      final orphans = await fixture.repository.getOrphanedReimbursements();
      expect(orphans, hasLength(1));
      expect(orphans.single.amount, 260);
      expect(orphans.single.orphaned, isTrue);
      // FR-032: the money still came back, so the month still reports it.
      expect((await fixture.summary(origin)).moneyReturned, 260);
    });

    test('an orphan can be re-attached and reports from its new month',
        () async {
      const original = '2026-01';
      const replacement = '2026-02';
      final doomed =
          await fixture.seedExpense(yearMonth: original, amount: 800);
      await fixture.addReimbursement(
        amount: 260,
        date: DateTime(2026, 1, 9),
        againstYearMonth: original,
      );
      await fixture.repository.deleteExpense(doomed);

      final survivor = await fixture.seedExpense(
        yearMonth: replacement,
        amount: 400,
      );
      final orphan =
          (await fixture.repository.getOrphanedReimbursements()).single;
      await fixture.repository.restoreOrphanReimbursement(orphan.id, survivor);

      expect(await fixture.repository.getOrphanedReimbursements(), isEmpty);
      final restated =
          await fixture.repository.getReimbursementsForExpense(survivor);
      expect(restated.single.orphaned, isFalse);
      expect(restated.single.originYearMonth, replacement);
      expect((await fixture.summary(replacement)).moneyReturned, 260);
    });

    test('an orphan the user discards stops counting', () async {
      const origin = '2026-01';
      final expenseId =
          await fixture.seedExpense(yearMonth: origin, amount: 800);
      await fixture.addReimbursement(
        amount: 260,
        date: DateTime(2026, 1, 9),
        againstYearMonth: origin,
      );
      await fixture.repository.deleteExpense(expenseId);

      final orphan =
          (await fixture.repository.getOrphanedReimbursements()).single;
      await fixture.repository.discardOrphanReimbursement(orphan.id);

      expect(await fixture.repository.getOrphanedReimbursements(), isEmpty);
      expect(
          await fixture.repository.getReimbursementsForMonth(origin), isEmpty);
    });

    test('a reimbursement recorded against a missing target stays visible',
        () async {
      // FR-032: a reimbursement whose target never resolves falls back to its
      // own recorded month rather than being discarded.
      await fixture.repository.addReimbursement(
        Reimbursement(
          profileId: 1,
          expenseId: 999999,
          amount: 75,
          currency: 'USD',
          originYearMonth: '2026-04',
          date: DateTime(2026, 4, 2),
        ),
      );

      expect((await fixture.summary('2026-04')).moneyReturned, 75.0);
      final stored = await fixture.isar.reimbursements.where().findAll();
      expect(stored.single.amount, 75);
    });
  });

  group('FR-033 origin-month query', () {
    test('the month query is keyed on origin, not on the entry date', () async {
      const origin = '2026-01';
      await fixture.seedExpense(yearMonth: origin, amount: 1200);
      await fixture.addReimbursement(
        amount: 300,
        date: DateTime(2026, 9, 9),
        againstYearMonth: origin,
      );

      expect(
        await fixture.repository.getReimbursementsForMonth(origin),
        hasLength(1),
      );
      expect(
        await fixture.repository.getReimbursementsForMonth('2026-09'),
        isEmpty,
      );
    });

    test('a target deleted after the fact stays in its origin month', () async {
      const origin = '2026-01';
      final expenseId =
          await fixture.seedExpense(yearMonth: origin, amount: 1200);
      await fixture.addReimbursement(
        amount: 300,
        date: DateTime(2026, 9, 9),
        againstYearMonth: origin,
      );
      await fixture.repository.deleteExpense(expenseId);

      expect(
        await fixture.repository.getReimbursementsForMonth(origin),
        hasLength(1),
      );
    });
  });
}

/// A reimbursable expense plus the repository, so the tests exercise the real
/// origin-month bookkeeping instead of a hand-built summary.
class _AttributionFixture {
  _AttributionFixture._(
      this.isar, this.directory, this.profileId, this.budgetId)
      // Every currency here is USD, so the cache short-circuits to 1.0 and never
      // touches the network or the documents directory.
      : repository = ExpenseRepository(
          isar,
          ExchangeRateCache(ExchangeRateClient(Dio())),
        );

  static bool _coreReady = false;
  static int _nextInstance = 0;

  final Isar isar;
  final Directory directory;
  final ExpenseRepository repository;
  final int profileId;
  final int budgetId;

  static Future<_AttributionFixture> open() async {
    if (!_coreReady) {
      await Isar.initializeIsarCore(download: true);
      _coreReady = true;
    }
    final directory =
        Directory.systemTemp.createTempSync('budget_buddy_reimb_');
    final isar = await Isar.open(
      [
        UserProfileSchema,
        MonthlyBudgetSchema,
        ExpenseSchema,
        ReimbursementSchema,
        CategorySchema,
        SchemaMigrationStampSchema,
      ],
      directory: directory.path,
      name: 'reimbursement_${_nextInstance++}',
    );
    await writeSchemaVersion(isar, schemaVersion);

    final profile = UserProfile()
      ..name = 'Attribution'
      ..primaryCurrency = PrimaryCurrency.usd
      ..monthlyAvailableAmount = 5000
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);

    final budget = MonthlyBudget()
      ..yearMonth = '2026-01'
      ..baseAvailableAmount = 5000
      ..openingBalanceConfirmed = true
      ..currency = PrimaryCurrency.usd
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);

    late int profileId;
    late int budgetId;
    await isar.writeTxn(() async {
      profileId = await isar.userProfiles.put(profile);
      budgetId = await isar.monthlyBudgets.put(budget);
      if (await isar.categorys.count() == 0) {
        await isar.categorys.put(
          Category(
            categoryId: 'medical',
            name: 'Health & Medical',
            emoji: 'H',
            colorValue: 0xFFF44336,
            isDefault: true,
          ),
        );
      }
    });

    return _AttributionFixture._(isar, directory, profileId, budgetId);
  }

  /// A paid, reimbursable expense owned by [yearMonth].
  Future<int> seedExpense({
    required String yearMonth,
    double amount = 1000,
  }) async {
    final expense = Expense(
      profileId: profileId,
      yearMonth: yearMonth,
      title: 'Reimbursable',
      amount: amount,
      currency: 'USD',
      categoryId: 'medical',
      date: DateTime(
        int.parse(yearMonth.substring(0, 4)),
        int.parse(yearMonth.substring(5, 7)),
        3,
      ),
      budgetId: budgetId,
      isReimbursable: true,
    );
    late int id;
    await isar.writeTxn(() async {
      id = await isar.expenses.put(expense);
    });
    return id;
  }

  /// Records a reimbursement.
  ///
  /// Pass [expenseId] to target a specific expense; otherwise the first
  /// reimbursable expense owned by [againstYearMonth] is used.
  Future<void> addReimbursement({
    required double amount,
    required DateTime date,
    String? againstYearMonth,
    int? expenseId,
  }) async {
    assert(expenseId != null || againstYearMonth != null,
        'target the reimbursement with either expenseId or againstYearMonth');

    final targetId = expenseId ??
        (await isar.expenses
                .filter()
                .profileIdEqualTo(profileId)
                .yearMonthEqualTo(againstYearMonth!)
                .findFirst())
            ?.id;

    await repository.addReimbursement(
      Reimbursement(
        profileId: 1,
        expenseId: targetId,
        amount: amount,
        currency: 'USD',
        originYearMonth: againstYearMonth ?? '',
        date: date,
      ),
    );
  }

  /// Builds the same summary the dashboard provider builds: expenses scoped to
  /// the month, reimbursements scoped by `originYearMonth`.
  Future<MonthSummary> summary(String yearMonth) async {
    final expenses = await isar.expenses
        .filter()
        .profileIdEqualTo(profileId)
        .yearMonthEqualTo(yearMonth)
        .findAll();
    final reimbursements =
        await repository.getReimbursementsForMonth(yearMonth);

    final budget = await _budget(yearMonth);
    final income = budget.netSalaryOverride ?? 0.0;

    return MonthSummary.from(
      yearMonth: yearMonth,
      income: income,
      usesOverriddenIncome: budget.netSalaryOverride != null,
      expenses: expenses,
      reimbursements: reimbursements,
      openingBalance: budget.baseAvailableAmount,
      targetPaidAmounts: {
        for (final expense in expenses)
          if (expense.status == ExpenseStatus.paid)
            expense.id: expense.amount * expense.exchangeRateToPrimary,
      },
    );
  }

  Future<MonthlyBudget> _budget(String yearMonth) async {
    final existing = await isar.monthlyBudgets
        .filter()
        .yearMonthEqualTo(yearMonth)
        .findFirst();
    if (existing != null) return existing;

    final budget = MonthlyBudget()
      ..yearMonth = yearMonth
      ..baseAvailableAmount = 0
      ..openingBalanceConfirmed = true
      ..currency = PrimaryCurrency.usd
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    await isar.writeTxn(() async {
      budget.id = await isar.monthlyBudgets.put(budget);
    });
    return budget;
  }

  Future<void> close() async {
    await isar.close(deleteFromDisk: true);
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  }
}

String _shiftMonth(String yearMonth, int months) {
  final year = int.parse(yearMonth.substring(0, 4));
  final month = int.parse(yearMonth.substring(5, 7));
  final zeroBased = year * 12 + (month - 1) + months;
  final shiftedYear = zeroBased ~/ 12;
  final shiftedMonth = zeroBased % 12 + 1;
  return '${shiftedYear.toString().padLeft(4, '0')}-'
      '${shiftedMonth.toString().padLeft(2, '0')}';
}
