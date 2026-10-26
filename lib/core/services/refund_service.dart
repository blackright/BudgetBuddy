import 'fx_booking_service.dart';
import '../models/fx_revision.dart';
import 'audit_financial_state.dart';
import 'dart:math' as math;
import 'package:isar/isar.dart';
import '../models/budget_profile.dart';
import '../models/direct_expense_profile.dart';
import '../models/currency_code.dart';
import '../models/expense.dart';
import '../models/expense_purchase.dart';
import '../models/income_source.dart';
import '../models/identity.dart';
import '../models/money.dart';
import '../models/monthly_budget.dart';
import '../models/month_end_run.dart';
import '../models/shared_space.dart';
import '../models/user_profile.dart';
import '../providers/budget_context_provider.dart';
import '../../features/engine/providers/rate_registry_provider.dart';
import '../../features/expenses/models/reimbursement.dart';
import '../../features/finance/repositories/audit_repository.dart';
import '../../features/spaces/repositories/space_write_guard.dart';
import '../../features/sync/repositories/sync_recorder.dart';
import 'income_aggregation_service.dart';
import 'month_end_report.dart';
import 'dart:convert';
import 'expense_profile_identity.dart';
import 'profile_spending_service.dart';
import '../../features/vault/vault_transfer_ledger.dart';

class RefundException implements Exception {
  const RefundException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Exact decimal input boundary: grouping is accepted, extra precision is not
/// silently rounded, and financial arithmetic never passes through a double.
int? parseRefundAmount(String input, CurrencyCode currency) {
  final raw = input.trim();
  if (!RegExp(r'^(?:\d+|\d{1,3}(?:,\d{3})+)(?:\.\d+)?$').hasMatch(raw)) {
    return null;
  }
  final parts = raw.replaceAll(',', '').split('.');
  final fraction = parts.length == 2 ? parts[1] : '';
  if (fraction.length > currency.exponent) return null;
  final major = int.tryParse(parts[0]);
  if (major == null ||
      major > 9007199254740991 ~/ currency.minorUnitsPerMajor) {
    return null;
  }
  final amount = major * currency.minorUnitsPerMajor +
      (fraction.isEmpty
          ? 0
          : int.parse(fraction.padRight(currency.exponent, '0')));
  // Dart/web's shared exact-integer boundary, also prevents pathological input.
  return amount > 0 && amount <= 9007199254740991 ? amount : null;
}

/// The three restoration bands partition the refund; net spending is reduced
/// exactly once. Direct/Main spending never creates budget borrowing.
class RefundImpact {
  RefundImpact.calculate(
      {required int spent,
      required int allocation,
      required int reserve,
      required int refund,
      bool direct = false,
      bool allowZero = false}) {
    if (refund < 0 ||
        (refund == 0 && !allowZero) ||
        refund > spent ||
        spent < 0 ||
        allocation < 0) {
      throw const RefundException('Refund exceeds the remaining net spending.');
    }
    spentBefore = spent;
    spentAfter = spent - refund;
    final capacity = math.max(0, reserve);
    int overspend(int value) => direct
        ? math.max(0, value - capacity)
        : math.max(0, value - allocation);
    borrowedBefore = direct ? 0 : math.min(overspend(spent), capacity);
    borrowedAfter = direct ? 0 : math.min(overspend(spentAfter), capacity);
    deficitBefore = overspend(spent) - borrowedBefore;
    deficitAfter = overspend(spentAfter) - borrowedAfter;
    spendingReduction = refund - deficitReduction - borrowingReduction;
  }
  late final int spentBefore,
      spentAfter,
      borrowedBefore,
      borrowedAfter,
      deficitBefore,
      deficitAfter,
      spendingReduction;
  int get deficitReduction => deficitBefore - deficitAfter;
  int get borrowingReduction => borrowedBefore - borrowedAfter;
  Map<String, Object?> values({required bool after}) => {
        'spent': after ? spentAfter : spentBefore,
        'borrowed': after ? borrowedAfter : borrowedBefore,
        'deficit': after ? deficitAfter : deficitBefore,
      };
}

class RefundQuote {
  RefundQuote(
      {required this.expense,
      required this.returnedMinor,
      required this.currency,
      required this.contextCurrency,
      required this.spent,
      required this.allocation,
      required this.reserve,
      required this.direct,
      this.expenseNetMinor,
      this.returnedBaseMinor = 0,
      required this.rates});
  final Expense expense;
  final int returnedMinor, spent, allocation, reserve;
  final CurrencyCode currency, contextCurrency;
  final bool direct;
  final int? expenseNetMinor;
  final int returnedBaseMinor;
  final RateTableRegistry rates;
  int get remainingMinor => math.max(0, expense.amount - returnedMinor);
  RefundImpact impactFor(int amount) {
    if (amount <= 0 || amount > remainingMinor) {
      throw const RefundException(
          'Amount exceeds the remaining refundable amount.');
    }
    final booked = expenseFx(expense)?.current;
    if (booked != null) {
      if (booked.money.currency != contextCurrency) {
        throw const RefundException(
            'Booked accounting currency changed. Review this payment.');
      }
      final value = fxRound(
              BigInt.from(booked.baseMinor) *
                  BigInt.from(returnedMinor + amount),
              BigInt.from(expense.amount)) -
          returnedBaseMinor;
      return RefundImpact.calculate(
          spent: spent,
          allocation: allocation,
          reserve: reserve,
          refund: value,
          direct: direct,
          allowZero: true);
    }
    final converted = rates.convert(
        amount: Money(amount, currency),
        to: contextCurrency,
        yearMonth: expense.yearMonth);
    if (converted.isDegraded) {
      throw const RefundException('Exchange rate unavailable.');
    }
    if (converted.amount.minorUnits <= 0) {
      throw const RefundException(
          'Refund is below one unit of the context currency.');
    }
    return RefundImpact.calculate(
        spent: spent,
        allocation: allocation,
        reserve: reserve,
        refund: math.min(converted.amount.minorUnits, expenseNetMinor ?? spent),
        direct: direct);
  }
}

/// Quote is advisory. Save reloads ownership, permissions, returns and financial
/// state inside one serialized Isar transaction, including the idempotency key.
class RefundService {
  RefundService(this.isar,
      {required this.context,
      required this.actingProfileId,
      required this.rates,
      AuditRepository? audit,
      SpaceWriteGuard? guard,
      this.syncRecorder})
      : audit = audit ??
            AuditRepository(isar,
                recorder: syncRecorder, actorId: actingProfileId),
        guard = guard ?? SpaceWriteGuard(isar);
  final Isar isar;
  final ContextRef context;
  final int actingProfileId;
  final RateTableRegistry rates;
  final AuditRepository audit;
  final SpaceWriteGuard guard;
  final SyncRecorder? syncRecorder;

  Future<RefundQuote> quote(int expenseId) => isar.txn(() => _quote(expenseId));

  Future<Expense> _expense(int id, {bool refund = true}) async {
    final expense = await isar.expenses.get(id);
    if (expense == null) {
      throw const RefundException('Expense no longer exists.');
    }
    final matches = context.isShared
        ? expense.sharedSpaceId == context.spaceId
        : expense.sharedSpaceId == null &&
            expense.profileId == context.profileId &&
            context.profileId == actingProfileId;
    if (!matches || expense.yearMonth != context.yearMonth) {
      throw const RefundException(
          'Expense does not belong to the active context and month.');
    }
    if (refund && expense.type != ExpenseType.standard) {
      throw const RefundException(
          'Medical returns use the existing insurer workflow.');
    }
    if (refund &&
        ![
          ExpenseStatus.paid,
          ExpenseStatus.partiallyReimbursed,
          ExpenseStatus.reimbursed
        ].contains(expense.status)) {
      throw const RefundException('Only paid expenses can receive a refund.');
    }
    await guard.assertSharedMoneyWrite(
        sharedSpaceId: expense.sharedSpaceId,
        actingProfileId: actingProfileId,
        yearMonth: expense.yearMonth);
    return expense;
  }

  /// Explicit user choice repairs an unresolved legacy assignment. The target
  /// is checked again in the transaction against the original month/context.
  Future<void> assignProfile(
      {required int expenseId,
      required int? profileId,
      required String? profileType,
      required String? syncGuid}) async {
    await isar.writeTxn(() async {
      final expense = await _expense(expenseId, refund: false);
      if (expense.purchaseSyncGuid != null) {
        throw const RefundException(
            'Open the purchase to change its financial profiles.');
      }
      expense
        ..budgetProfileId = profileId
        ..financialProfileType = profileType
        ..financialProfileSyncGuid = syncGuid;
      if (!resolveExpenseProfileIdentity(
          expense,
          await isar.budgetProfiles.where().findAll(),
          await isar.directExpenseProfiles.where().findAll())) {
        throw const RefundException(
            'Choose an existing profile in this month and context.');
      }
      await audit.put(isar.expenses, expense, id: expense.id, type: 'Expense');
      await syncRecorder?.recordExpense(expense);
    });
  }

  bool _owns(int? profileId, int? spaceId) => context.isShared
      ? spaceId == context.spaceId
      : spaceId == null && profileId == context.profileId;

  int _convert(int amount, CurrencyCode? from, CurrencyCode to) {
    if (from == null || amount < 0) {
      throw const RefundException(
          'Unsupported currency or invalid stored amount.');
    }
    final result = rates.convert(
        amount: Money(amount, from), to: to, yearMonth: context.yearMonth);
    if (result.isDegraded) {
      throw const RefundException(
          'Exchange rate unavailable; refund was not saved.');
    }
    return result.amount.minorUnits;
  }

  Future<RefundQuote> _quote(int id) async {
    final expense = await _expense(id);
    final currency = expense.currencyCode;
    if (currency == null) {
      throw const RefundException('Unsupported expense currency.');
    }
    if (expense.amount <= 0) {
      throw const RefundException('The original payment must be positive.');
    }
    final user = await isar.userProfiles.get(actingProfileId);
    if (user == null) {
      throw const RefundException('Acting profile no longer exists.');
    }
    final space =
        context.isShared ? await isar.sharedSpaces.get(context.spaceId!) : null;
    if (context.isShared && space == null) {
      throw const RefundException('Shared space no longer exists.');
    }
    final main = space?.currency.code ?? user.primaryCurrency.code;
    final expenses = (await isar.expenses
            .filter()
            .yearMonthEqualTo(context.yearMonth)
            .findAll())
        .where((e) => _owns(e.profileId, e.sharedSpaceId))
        .toList();
    final returns = (await isar.reimbursements
            .filter()
            .originYearMonthEqualTo(context.yearMonth)
            .findAll())
        .where((r) => _owns(r.profileId, r.sharedSpaceId))
        .toList();
    final targetReturns = returns.where((r) => r.expenseId == id);
    if (expenseFx(expense) != null &&
        targetReturns.any((r) => reimbursementFx(r) == null)) {
      throw const RefundException(
          'Refund history has incomplete booked FX evidence.');
    }
    final returned = targetReturns.isEmpty &&
            expense.status == ExpenseStatus.reimbursed
        ? expense.amount
        : targetReturns.fold<int>(
            0, (sum, r) => sum + _convert(r.amount, r.currencyCode, currency));
    final budgets = (await isar.budgetProfiles
            .filter()
            .yearMonthEqualTo(context.yearMonth)
            .findAll())
        .where((p) => _owns(p.profileId, p.sharedSpaceId))
        .toList();
    final directs = (await isar.directExpenseProfiles
            .filter()
            .yearMonthEqualTo(context.yearMonth)
            .findAll())
        .where((p) => _owns(p.profileId, p.sharedSpaceId))
        .toList();
    if (!resolveExpenseProfileIdentity(expense, budgets, directs) ||
        expenses
            .any((e) => !resolveExpenseProfileIdentity(e, budgets, directs))) {
      throw const RefundException(
          'An expense profile is ambiguous. Resolve its budget/direct assignment before refunding.');
    }
    final budget = budgets
        .where((p) =>
            expense.financialProfileType == FinancialProfileType.budget &&
            p.id == expense.budgetProfileId)
        .firstOrNull;
    final direct = directs
        .where((p) =>
            expense.financialProfileType == FinancialProfileType.direct &&
            p.id == expense.budgetProfileId)
        .firstOrNull;
    if (budget != null && direct != null) {
      throw const RefundException(
          'The expense profile is ambiguous. Resolve its budget/direct assignment before refunding.');
    }
    if (expense.budgetProfileId != null && budget == null && direct == null) {
      throw const RefundException(
          'The expense profile no longer exists in this context.');
    }
    int spent(int? profileId, [String? profileType]) =>
        const ProfileSpendingService().spentInYearMonth(
            profileId: profileId,
            profileType: profileType,
            yearMonth: context.yearMonth,
            expenses: expenses,
            reimbursements: returns,
            convert: (e) {
              final m = expenseAccountingMoney(e, expectedCurrency: main);
              return _convert(m.minorUnits, m.currency, main);
            },
            convertReimbursement: (r) => (() {
                  final m =
                      reimbursementAccountingMoney(r, expectedCurrency: main);
                  return _convert(m.minorUnits, m.currency, main);
                })());
    final months = await isar.monthlyBudgets
        .filter()
        .yearMonthEqualTo(context.yearMonth)
        .findAll();
    final month =
        months.where((m) => _owns(m.profileId, m.sharedSpaceId)).firstOrNull;
    final sources = (await isar.incomeSources.where().findAll())
        .where((s) => _owns(s.profileId, s.sharedSpaceId))
        .toList();
    final sourceIncome = const IncomeAggregationService()
        .monthlyTotal(sources, context.yearMonth, currency: main);
    // This matches resolvedIncomeProvider's existing override/fallback policy.
    final income = context.isShared
        ? month?.sharedIncomeOverride ??
            (sourceIncome > 0 ? sourceIncome : space!.defaultIncome)
        : month?.netSalaryOverride != null
            ? Money.fromMajor(month!.netSalaryOverride!, main).minorUnits
            : sourceIncome > 0
                ? sourceIncome
                : Money.fromMajor(user.defaultNetSalary, main).minorUnits;
    final settlements = (await isar.monthEndRuns.where().findAll())
        .where((r) => r.applied && _owns(r.profileId, r.sharedSpaceId));
    int settlementAmount(MonthEndRun run, int amount) {
      final code = CurrencyCode.tryParse(run.currency);
      if (code == null) {
        throw const RefundException('Unsupported settlement currency.');
      }
      final result = rates.convert(
          amount: Money(amount, code), to: main, yearMonth: run.yearMonth);
      if (result.isDegraded) {
        throw const RefundException('Settlement exchange rate missing.');
      }
      return result.amount.minorUnits;
    }

    var settlementFunds = 0;
    for (final run in settlements) {
      if (run.destinationMonth == context.yearMonth) {
        settlementFunds += settlementAmount(run, run.carriedMinor);
      }
      if (run.yearMonth != context.yearMonth) continue;
      for (final line in jsonDecode(run.reportJson)['lines'] as List) {
        final profile =
            budgets.where((p) => p.syncGuid == line['sourceGuid']).firstOrNull;
        final unused = profile == null
            ? 0
            : math.max(
                0,
                profile.allocation -
                    spent(profile.id, FinancialProfileType.budget));
        final reservation = MonthEndReservation(
            unused: unused,
            carried: settlementAmount(run, line['carried'] as int),
            released: settlementAmount(run, line['released'] as int));
        settlementFunds +=
            reservation.releasedCredit - reservation.carryShortfall;
      }
    }
    final totalAllocated = budgets.fold<int>(0, (sum, p) => sum + p.allocation);
    final otherDirectSpent = directs
        .where((p) => budget != null || p.id != direct?.id)
        .fold<int>(
            0, (sum, p) => sum + spent(p.id, FinancialProfileType.direct));
    final mainSpent = expense.budgetProfileId == null ? 0 : spent(null);
    return RefundQuote(
        expense: expense,
        returnedMinor: returned,
        returnedBaseMinor: returns.where((r) => r.expenseId == id).fold<int>(
            0, (sum, r) => sum + (reimbursementFx(r)?.current.baseMinor ?? 0)),
        currency: currency,
        contextCurrency: main,
        spent: spent(expense.budgetProfileId, expense.financialProfileType),
        allocation: budget?.allocation ?? 0,
        reserve: income +
            (context.isShared
                ? 0
                : await readMonthlyVaultCredit(
                    isar, actingProfileId, context.yearMonth, main)) +
            settlementFunds -
            totalAllocated -
            otherDirectSpent -
            mainSpent,
        direct: budget == null,
        expenseNetMinor: math.max(
            0,
            (() {
                  final m =
                      expenseAccountingMoney(expense, expectedCurrency: main);
                  return _convert(m.minorUnits, m.currency, main);
                })() -
                returns.where((r) => r.expenseId == id).fold<int>(
                    0,
                    (sum, r) =>
                        sum +
                        (() {
                          final m = reimbursementAccountingMoney(r,
                              expectedCurrency: main);
                          return _convert(m.minorUnits, m.currency, main);
                        })())),
        rates: rates);
  }

  Future<Reimbursement> record(
      {required int expenseId,
      required int amount,
      required String operationId,
      String? note}) async {
    if (operationId.trim().isEmpty || amount <= 0) {
      throw const RefundException(
          'A positive refund and submission ID are required.');
    }
    if ((note?.length ?? 0) > 500) {
      throw const RefundException(
          'Refund notes must be 500 characters or fewer.');
    }
    return isar.writeTxn(() async {
      final auditScope = AuditFinancialScope(
          context.profileId, context.spaceId, context.yearMonth);
      final expense = await _expense(expenseId);
      final existing = await isar.reimbursements
          .filter()
          .syncGuidEqualTo(operationId)
          .findFirst();
      if (existing != null) {
        if (existing.expenseId != expenseId ||
            existing.amount != amount ||
            !_owns(existing.profileId, existing.sharedSpaceId) ||
            existing.note != note?.trim()) {
          throw const RefundException(
              'This submission ID was already used for a different refund.');
        }
        return existing;
      }
      final quote = await _quote(expenseId);
      final financialBefore = await auditFinancialState(isar, auditScope);
      final impact = quote.impactFor(amount);
      expense.financialProfileType = quote.expense.financialProfileType;
      expense.financialProfileSyncGuid = quote.expense.financialProfileSyncGuid;
      final row = Reimbursement(
          profileId: expense.profileId,
          sharedSpaceId: expense.sharedSpaceId,
          expenseId: expenseId,
          originYearMonth: expense.yearMonth,
          amount: amount,
          currency: quote.currency.code,
          date: DateTime.now().toUtc(),
          note: note?.trim())
        ..syncGuid = operationId;
      await FxBookingService(isar).prepareRefund(row);
      await isar.reimbursements.put(row);
      expense.status = quote.returnedMinor + amount >= expense.amount
          ? ExpenseStatus.reimbursed
          : ExpenseStatus.partiallyReimbursed;
      await isar.expenses.put(expense);
      if (expense.purchaseSyncGuid != null) {
        final purchase = await isar.expensePurchases
            .filter()
            .syncGuidEqualTo(expense.purchaseSyncGuid!)
            .findFirst();
        if (purchase == null) {
          throw const RefundException('Purchase is missing.');
        }
        purchase.advanceRevision();
        await isar.expensePurchases.put(purchase);
      }
      if (expense.budgetProfileId != null) {
        final budget = await isar.budgetProfiles.get(expense.budgetProfileId!);
        if (expense.financialProfileType == FinancialProfileType.budget &&
            budget != null &&
            _owns(budget.profileId, budget.sharedSpaceId)) {
          budget.spent = impact.spentAfter;
          await isar.budgetProfiles.put(budget);
        } else {
          final direct =
              await isar.directExpenseProfiles.get(expense.budgetProfileId!);
          if (direct == null ||
              !_owns(direct.profileId, direct.sharedSpaceId)) {
            throw const RefundException('Expense profile changed.');
          }
          direct.spent = impact.spentAfter;
          await isar.directExpenseProfiles.put(direct);
        }
      }
      final identities = await isar.identitys.where().findAll();
      final identity = identities
          .where((i) => i.localProfileId == actingProfileId)
          .firstOrNull;
      final space = expense.sharedSpaceId == null
          ? null
          : await isar.sharedSpaces.get(expense.sharedSpaceId!);
      await audit.appendRefund(
          expense: expense,
          refund: row,
          actor: identity?.fingerprint ?? 'profile:$actingProfileId',
          contextSyncGuid: space?.syncGuid,
          before: {
            ...impact.values(after: false),
            'returned': quote.returnedMinor,
            'contextCurrency': quote.contextCurrency.code,
            'originalPaid': expense.amount
          },
          after: {
            ...impact.values(after: true),
            'returned': quote.returnedMinor + amount,
            'contextCurrency': quote.contextCurrency.code,
            'originalPaid': expense.amount
          });
      await syncRecorder?.recordReimbursement(row);
      await audit.recordDerived(auditScope, financialBefore,
          await auditFinancialState(isar, auditScope));
      await syncRecorder?.recordExpense(expense);
      return row;
    });
  }
}
