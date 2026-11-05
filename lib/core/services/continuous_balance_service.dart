import 'dart:convert';
import 'dart:math' as math;

import 'package:isar/isar.dart';

import '../models/budget_profile.dart';
import '../models/currency_code.dart';
import '../models/expense.dart';
import '../models/medical_bill.dart';
import '../models/medical_withholding_match.dart';
import '../models/money.dart';
import '../models/month_end_run.dart';
import '../models/monthly_budget.dart';
import '../models/user_profile.dart';
import '../../features/engine/providers/rate_registry_provider.dart';
import '../../features/expenses/models/reimbursement.dart';
import '../../features/vault/models/savings_vault.dart';
import '../../features/vault/models/vault_entry.dart';
import '../../features/vault/vault_transfer_ledger.dart';
import 'free_funds.dart';
import 'fx_booking_service.dart';
import 'income_receipt_ledger.dart';
import 'month_end_report.dart';
import 'profile_spending_service.dart';

/// The derived continuity state of one personal profile's money chain.
enum BalanceChainStatus { intact, firstMonth, legacyGap, needsReview }

/// One month of the continuous personal balance, in the profile's accounting
/// minor units. Nothing here is persisted; it is always derived from facts.
class ContinuousBalance {
  const ContinuousBalance({
    required this.yearMonth,
    required this.openingMinor,
    required this.cashInMinor,
    required this.cashOutMinor,
    required this.closingMinor,
    required this.allocatedMinor,
    required this.freeToUseMinor,
    required this.vaultMinor,
    required this.status,
    this.reviewReason,
  });

  final String yearMonth;
  final int openingMinor;
  final int cashInMinor;
  final int cashOutMinor;
  final int closingMinor;
  final int allocatedMinor;
  final int freeToUseMinor;
  final int vaultMinor;
  final BalanceChainStatus status;
  final String? reviewReason;

  bool get needsOpeningReview =>
      status == BalanceChainStatus.firstMonth ||
      status == BalanceChainStatus.legacyGap ||
      status == BalanceChainStatus.needsReview;
}

class _NeedsReview implements Exception {
  const _NeedsReview(this.reason);
  final String reason;
}

/// Derives the one continuous balance a personal profile owns across months.
///
/// The anchor is the earliest confirmed `MonthlyBudget.openingBalanceConfirmed`
/// at or before the requested month. Every later month is derived from facts, so
/// a correction in an earlier month flows forward without rewriting a snapshot.
class ContinuousBalanceService {
  ContinuousBalanceService(this.db,
      {RateTableRegistry? rates, DateTime Function()? clock})
      : rates = rates ?? RateTableRegistry(),
        clock = clock ?? DateTime.now;

  final Isar db;
  final RateTableRegistry rates;
  final DateTime Function() clock;

  Future<ContinuousBalance> balance(
      {required int profileId, required String yearMonth}) async {
    if (!_validMonth(yearMonth)) {
      return _empty(yearMonth, BalanceChainStatus.needsReview,
          reviewReason: 'Choose a valid month.');
    }
    final profile = await db.userProfiles.get(profileId);
    if (profile == null) {
      return _empty(yearMonth, BalanceChainStatus.needsReview,
          reviewReason: 'The profile is missing.');
    }
    final currency = profile.primaryCurrency.code;
    final rows = await db.monthlyBudgets
        .filter()
        .profileIdEqualTo(profileId)
        .sharedSpaceIdIsNull()
        .sortByYearMonth()
        .findAll();
    final byMonth = <String, MonthlyBudget>{};
    for (final row in rows) {
      if (!_validMonth(row.yearMonth)) {
        return _empty(yearMonth, BalanceChainStatus.needsReview,
            reviewReason: 'A stored month needs review.');
      }
      if (byMonth.containsKey(row.yearMonth)) {
        return _empty(yearMonth, BalanceChainStatus.needsReview,
            reviewReason: 'Two budget rows own the same month.');
      }
      byMonth[row.yearMonth] = row;
    }
    for (final row in rows) {
      final base = row.baseAvailableAmount;
      if (!base.isFinite || base < 0) {
        return _empty(yearMonth, BalanceChainStatus.needsReview,
            reviewReason: 'A stored opening balance needs review.');
      }
    }

    final anchor = _anchorAtOrBefore(byMonth, yearMonth);
    if (anchor == null) {
      final earlier = byMonth.keys.any((m) => m.compareTo(yearMonth) < 0);
      return _empty(
          yearMonth,
          earlier
              ? BalanceChainStatus.legacyGap
              : BalanceChainStatus.firstMonth,
          reviewReason: earlier
              ? 'An earlier month has no confirmed opening balance.'
              : 'Confirm this profile\'s opening balance.');
    }
    final anchorRow = byMonth[anchor]!;
    final anchorMinor =
        Money.fromMajor(anchorRow.baseAvailableAmount, currency).minorUnits;

    final chain = <String>[];
    var cursor = anchor;
    while (cursor != yearMonth) {
      if (cursor.compareTo(yearMonth) > 0) break;
      chain.add(cursor);
      cursor = nextFinancialMonth(cursor);
      if (chain.length > 1200) {
        return _empty(yearMonth, BalanceChainStatus.needsReview,
            reviewReason: 'The balance chain is too long to verify.');
      }
    }
    if (cursor != yearMonth) {
      return _empty(yearMonth, BalanceChainStatus.needsReview,
          reviewReason: 'The balance chain needs review.');
    }
    chain.add(yearMonth);
    for (final month in chain) {
      if (!byMonth.containsKey(month)) {
        return _empty(yearMonth, BalanceChainStatus.legacyGap,
            reviewReason: 'Month $month is missing from the chain.');
      }
    }

    try {
      final facts = await _loadFacts(profileId, currency);
      final conflict = facts.runs.where((run) =>
          run.hasConflict ||
          !run.applied ||
          chain.contains(run.yearMonth) ||
          chain.contains(run.destinationMonth));
      if (conflict.any((run) => run.hasConflict || !run.applied)) {
        return _empty(yearMonth, BalanceChainStatus.needsReview,
            reviewReason:
                'A month-end settlement conflicts or is not applied.');
      }
      var opening = anchorMinor;
      for (final month in chain) {
        final cashIn = _cashIn(facts, month, currency);
        final cashOut = _cashOut(facts, month, currency);
        final closing = sumFinancialMinor([opening, cashIn, -cashOut]);
        final allocated = _allocated(facts, month, currency);
        final free = sumFinancialMinor([closing, -allocated]);
        if (month == yearMonth) {
          return ContinuousBalance(
            yearMonth: yearMonth,
            openingMinor: opening,
            cashInMinor: cashIn,
            cashOutMinor: cashOut,
            closingMinor: closing,
            allocatedMinor: allocated,
            freeToUseMinor: free,
            vaultMinor: facts.vaultMinor,
            status: BalanceChainStatus.intact,
          );
        }
        opening = closing;
      }
      return _empty(yearMonth, BalanceChainStatus.needsReview,
          reviewReason: 'The balance chain needs review.');
    } on _NeedsReview catch (error) {
      return _empty(yearMonth, BalanceChainStatus.needsReview,
          reviewReason: error.reason);
    } on FormatException catch (error) {
      return _empty(yearMonth, BalanceChainStatus.needsReview,
          reviewReason: error.message);
    } on IsarError {
      return _empty(yearMonth, BalanceChainStatus.needsReview,
          reviewReason: 'A stored collection is missing from this database.');
    } on ArgumentError catch (error) {
      return _empty(yearMonth, BalanceChainStatus.needsReview,
          reviewReason: error.message?.toString() ??
              'A stored money value needs review.');
    }
  }

  String? _anchorAtOrBefore(Map<String, MonthlyBudget> rows, String yearMonth) {
    final months = rows.keys.where((m) => m.compareTo(yearMonth) <= 0).toList()
      ..sort();
    for (final month in months) {
      if (rows[month]!.openingBalanceConfirmed) return month;
    }
    return null;
  }

  Future<_BalanceFacts> _loadFacts(int profileId, CurrencyCode currency) async {
    final budgets = await db.monthlyBudgets
        .filter()
        .profileIdEqualTo(profileId)
        .sharedSpaceIdIsNull()
        .findAll();
    final expenses = await db.expenses
        .filter()
        .profileIdEqualTo(profileId)
        .sharedSpaceIdIsNull()
        .findAll();
    final reimbursements = await db.reimbursements
        .filter()
        .profileIdEqualTo(profileId)
        .sharedSpaceIdIsNull()
        .findAll();
    final profiles = await db.budgetProfiles
        .filter()
        .profileIdEqualTo(profileId)
        .sharedSpaceIdIsNull()
        .findAll();
    final runs = await db.monthEndRuns
        .filter()
        .profileIdEqualTo(profileId)
        .sharedSpaceIdIsNull()
        .findAll();
    final vault =
        await db.savingsVaults.filter().profileIdEqualTo(profileId).findFirst();
    final vaultEntries =
        await db.vaultEntrys.filter().profileIdEqualTo(profileId).findAll();
    final withholding = await _salaryWithheldExpenseIds(profileId);
    final ledger = await IncomeReceiptLedger.forOwner(db, profileId);
    final corrections = await SalaryCorrection.forOwner(db, profileId);
    final componentGuids = <String>{
      for (final row in ledger)
        if (row.group.profileId == profileId)
          ...row.group.componentReceiptGuids,
    };
    if (vault != null && vault.currency.toLowerCase() != currency.code) {
      throw const _NeedsReview('The Savings Vault currency needs review.');
    }
    return _BalanceFacts(
      budgets: budgets,
      expenses: expenses,
      reimbursements: reimbursements,
      budgetProfiles: profiles,
      runs: runs,
      vaultMinor: vault?.totalMinor ?? 0,
      vaultEntries: vaultEntries,
      salaryWithheldExpenseIds: withholding,
      ledger: ledger,
      corrections: corrections,
      componentGuids: componentGuids,
    );
  }

  Future<Set<int>> _salaryWithheldExpenseIds(int profileId) async {
    final matches = await db.medicalWithholdingMatchs
        .filter()
        .profileIdEqualTo(profileId)
        .reversedEqualTo(false)
        .findAll();
    final ids = <int>{};
    for (final match in matches) {
      final bill = await db.medicalBills
          .filter()
          .syncGuidEqualTo(match.billGuid)
          .findFirst();
      if (bill != null &&
          bill.paymentMethod == MedicalPaymentMethod.insurerPaid &&
          bill.linkedExpenseId != null) {
        ids.add(bill.linkedExpenseId!);
      }
    }
    return ids;
  }

  int _cashIn(_BalanceFacts facts, String month, CurrencyCode currency) {
    var total = 0;
    for (final ledger in facts.ledger) {
      final group = ledger.group;
      if (group.destinationMonth != month) continue;
      if (group.currency.toLowerCase() != currency.code) {
        throw const _NeedsReview('Confirmed salary currency needs review.');
      }
      total = sumFinancialMinor([total, group.totalMinor]);
    }
    for (final correction in facts.corrections) {
      if (correction.cashMonth != month) continue;
      if (correction.currency != currency.code) {
        throw const _NeedsReview('Salary correction currency needs review.');
      }
      total = sumFinancialMinor([total, correction.amountMinor]);
    }
    for (final row in facts.reimbursements) {
      if (facts.componentGuids.contains(row.syncGuid)) continue;
      final creditMonth = row.creditYearMonth ?? row.originYearMonth;
      if (creditMonth != month) continue;
      total = sumFinancialMinor([total, _convertRefund(row, currency, month)]);
    }
    return total;
  }

  int _cashOut(_BalanceFacts facts, String month, CurrencyCode currency) {
    var total = 0;
    for (final expense in facts.expenses) {
      if (facts.salaryWithheldExpenseIds.contains(expense.id)) continue;
      if (!_countsAsSpending(expense.status)) continue;
      final cashMonth = expense.cashYearMonth ?? expense.yearMonth;
      if (cashMonth != month) continue;
      total =
          sumFinancialMinor([total, _convertExpense(expense, currency, month)]);
    }
    total = sumFinancialMinor(
        [total, -monthlyVaultCredit(facts.vaultEntries, month, currency)]);
    return total;
  }

  int _allocated(_BalanceFacts facts, String month, CurrencyCode currency) {
    final profiles =
        facts.budgetProfiles.where((p) => p.yearMonth == month).toList();
    if (profiles.isEmpty) {
      return _legacyAllocated(facts, month, currency);
    }
    const spending = ProfileSpendingService();
    var total = 0;
    for (final profile in profiles) {
      if (profile.allocation < 0) {
        throw const _NeedsReview('A budget allocation needs review.');
      }
      final spent = spending.spentInYearMonth(
        profileId: profile.id,
        profileType: FinancialProfileType.budget,
        yearMonth: month,
        expenses: facts.expenses,
        reimbursements: facts.reimbursements,
        convert: (e) => _convertExpense(e, currency, month),
        convertReimbursement: (r) => _convertRefund(r, currency, month),
        excludedExpenseIds: facts.salaryWithheldExpenseIds,
      );
      total =
          sumFinancialMinor([total, math.max(0, profile.allocation - spent)]);
    }
    return total;
  }

  /// Legacy months without profile rows use the applied source run's unused
  /// envelopes and settlement terms. Profile rows always win when present.
  int _legacyAllocated(
      _BalanceFacts facts, String month, CurrencyCode currency) {
    var incoming = 0, released = 0, carry = 0, unusedTotal = 0;
    for (final run in facts.runs.where((r) => r.applied)) {
      if (run.destinationMonth == month) {
        incoming = sumFinancialMinor(
            [incoming, _convertRun(run, run.carriedMinor, currency)]);
      }
      if (run.yearMonth != month) continue;
      final report = _runLines(run);
      for (final line in report) {
        final allocation = line['allocation'];
        final spent = line['spent'];
        final carried = line['carried'];
        final releasedMinor = line['released'];
        if (allocation is! int ||
            spent is! int ||
            carried is! int ||
            releasedMinor is! int ||
            allocation < 0 ||
            spent < 0 ||
            carried < 0 ||
            releasedMinor < 0) {
          throw const _NeedsReview('A month-end settlement line needs review.');
        }
        final reservation = MonthEndReservation(
            unused: math.max(0, allocation - spent),
            carried: _convertRun(run, carried, currency),
            released: _convertRun(run, releasedMinor, currency));
        unusedTotal = sumFinancialMinor([unusedTotal, reservation.unused]);
        released = sumFinancialMinor([released, reservation.releasedCredit]);
        carry = sumFinancialMinor([carry, reservation.carryShortfall]);
      }
    }
    return sumFinancialMinor([unusedTotal, carry, -incoming, -released]);
  }

  int _convertExpense(Expense expense, CurrencyCode currency, String month) {
    final money = expenseAccountingMoney(expense);
    return _convert(money, currency, month);
  }

  int _convertRefund(
      Reimbursement refund, CurrencyCode currency, String month) {
    final money = reimbursementAccountingMoney(refund);
    return _convert(money, currency, month);
  }

  int _convertRun(MonthEndRun run, int minor, CurrencyCode currency) {
    final code = CurrencyCode.tryParse(run.currency);
    if (code == null) {
      throw const _NeedsReview('A settlement currency needs review.');
    }
    return _convert(Money(minor, code), currency, run.yearMonth);
  }

  int _convert(Money money, CurrencyCode currency, String month) {
    final converted =
        rates.convert(amount: money, to: currency, yearMonth: month);
    if (converted.isDegraded) {
      throw const _NeedsReview('An exchange rate needs review.');
    }
    return converted.amount.minorUnits;
  }

  List<Map> _runLines(MonthEndRun run) {
    try {
      final json = jsonDecode(run.reportJson);
      if (json is! Map || json['lines'] is! List) {
        throw const _NeedsReview('A month-end settlement needs review.');
      }
      return (json['lines'] as List).whereType<Map>().toList();
    } catch (error) {
      if (error is _NeedsReview) rethrow;
      throw const _NeedsReview('A month-end settlement needs review.');
    }
  }

  bool _countsAsSpending(ExpenseStatus status) =>
      status == ExpenseStatus.paid ||
      status == ExpenseStatus.reimbursed ||
      status == ExpenseStatus.partiallyReimbursed;

  ContinuousBalance _empty(String yearMonth, BalanceChainStatus status,
          {String? reviewReason}) =>
      ContinuousBalance(
        yearMonth: yearMonth,
        openingMinor: 0,
        cashInMinor: 0,
        cashOutMinor: 0,
        closingMinor: 0,
        allocatedMinor: 0,
        freeToUseMinor: 0,
        vaultMinor: 0,
        status: status,
        reviewReason: reviewReason,
      );

  bool _validMonth(String month) =>
      RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(month);
}

class _BalanceFacts {
  const _BalanceFacts({
    required this.budgets,
    required this.expenses,
    required this.reimbursements,
    required this.budgetProfiles,
    required this.runs,
    required this.vaultMinor,
    required this.vaultEntries,
    required this.salaryWithheldExpenseIds,
    required this.ledger,
    required this.corrections,
    required this.componentGuids,
  });

  final List<MonthlyBudget> budgets;
  final List<Expense> expenses;
  final List<Reimbursement> reimbursements;
  final List<BudgetProfile> budgetProfiles;
  final List<MonthEndRun> runs;
  final int vaultMinor;
  final List<VaultEntry> vaultEntries;
  final Set<int> salaryWithheldExpenseIds;
  final List<IncomeReceiptLedger> ledger;
  final List<SalaryCorrection> corrections;
  final Set<String> componentGuids;
}
