import '../../finance/providers/income_source_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../expenses/repositories/expense_repository.dart';
import '../../expenses/providers/reimbursement_provider.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/money.dart';
import '../../expenses/models/reimbursement.dart';
import '../../settings/providers/settings_provider.dart';
import '../currency_resolution.dart';
import 'rate_registry_provider.dart';
import '../../vault/providers/vault_providers.dart';
import '../../finance/providers/receipt_reconciliation_provider.dart';
import '../../../core/database/isar_helper.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/medical_withholding_match.dart';
import '../../../core/services/continuous_balance_service.dart';
import 'continuous_balance_provider.dart';

/// Expenses whose patient share is already reflected in confirmed net salary.
///
/// A linked withholding is a classification, not a second cash event. Cash
/// consumers skip these expense IDs; cost consumers keep them.
final salaryWithheldExpenseIdsProvider = FutureProvider<Set<int>>((ref) async {
  final db = IsarHelper.maybeInstance;
  if (db == null) return const <int>{};
  final matches = await db.medicalWithholdingMatchs
      .filter()
      .reversedEqualTo(false)
      .findAll();
  final ids = <int>{};
  for (final match in matches) {
    final bill = await db.medicalBills
        .filter()
        .syncGuidEqualTo(match.billGuid)
        .findFirst();
    final expenseId = bill?.linkedExpenseId;
    if (bill != null &&
        bill.paymentMethod == MedicalPaymentMethod.insurerPaid &&
        expenseId != null) {
      ids.add(expenseId);
    }
  }
  return ids;
});

final monthlyExpensesProvider = StreamProvider<List<Expense>>((ref) {
  final context = ref.watch(budgetContextProvider);
  final budget = ref.watch(activeBudgetProvider).value;
  if (context.isShared && budget == null) return Stream.value([]);

  final repository = ref.watch(expenseRepositoryProvider);
  return repository.watchExpensesForContext(context);
});

/// Reimbursements that *belong* to the selected month, keyed on
/// `originYearMonth` (FR-032, FR-033).
///
/// Deliberately not derived from the viewed month's expense ids: a
/// reimbursement recorded months after the expense it belongs to would then
/// vanish from the month that actually spent the money. Keying on the origin
/// month is what stops that (SC-005).
final monthlyReimbursementsProvider =
    StreamProvider<List<Reimbursement>>((ref) {
  final context = ref.watch(budgetContextProvider);
  final budget = ref.watch(activeBudgetProvider).value;
  if (context.isShared && budget == null) return Stream.value([]);

  final repository = ref.watch(reimbursementRepositoryProvider);
  return repository.watchReimbursementsForContext(context);
});

/// Expenses whose explicit cash month is the selected month.
final monthlyCashExpensesProvider = StreamProvider<List<Expense>>((ref) {
  final context = ref.watch(budgetContextProvider);
  final budget = ref.watch(activeBudgetProvider).value;
  if (context.isShared && budget == null) return Stream.value([]);
  if (IsarHelper.maybeInstance == null) return Stream.value([]);
  final repository = ref.watch(expenseRepositoryProvider);
  return repository.watchExpensesByCashMonth(context);
});

/// Reimbursements whose explicit credit month is the selected month.
final monthlyCashReimbursementsProvider =
    StreamProvider<List<Reimbursement>>((ref) {
  final context = ref.watch(budgetContextProvider);
  final budget = ref.watch(activeBudgetProvider).value;
  if (context.isShared && budget == null) return Stream.value([]);
  if (IsarHelper.maybeInstance == null) return Stream.value([]);
  final repository = ref.watch(reimbursementRepositoryProvider);
  return repository.watchReimbursementsByCreditMonth(context);
});

/// Combines service-month expenses with explicit cash-month rows once.
///
/// A medical row with a cash override is counted only in its cash month; every
/// row without one keeps the legacy service-month behavior. Non-medical rows are
/// never duplicated by the merge.
List<Expense> mergeCashExpenses(
    List<Expense> serviceExpenses, List<Expense> cashExpenses) {
  final merged = <Expense>[];
  final seen = <int>{};
  for (final expense in serviceExpenses) {
    if (expense.type == ExpenseType.medical && expense.cashYearMonth != null) {
      continue;
    }
    merged.add(expense);
    seen.add(expense.id);
  }
  for (final expense in cashExpenses) {
    if (seen.add(expense.id)) merged.add(expense);
  }
  return merged;
}

/// Combines origin-month reimbursements with explicit credit-month rows once.
List<Reimbursement> mergeCreditedReimbursements(
    List<Reimbursement> originReimbursements,
    List<Reimbursement> creditReimbursements) {
  final merged = <Reimbursement>[];
  final seen = <int>{};
  for (final row in originReimbursements) {
    if (row.creditYearMonth != null) continue;
    merged.add(row);
    seen.add(row.id);
  }
  for (final row in creditReimbursements) {
    if (seen.add(row.id)) merged.add(row);
  }
  return merged;
}

/// Money in the bank minus what has actually left, converted to the month's
/// display currency through the registry table (FR-011, FR-013).
final trueAvailableProvider = Provider<double>((ref) {
  final budget = ref.watch(activeBudgetProvider).value;
  final yearMonth = ref.watch(selectedYearMonthProvider);
  final table = ref.watch(rateRegistryProvider).tableFor(yearMonth);
  final serviceExpenses = ref.watch(monthlyExpensesProvider).value ?? [];
  final cashExpenses = ref.watch(monthlyCashExpensesProvider).value ?? [];
  final expenses = mergeCashExpenses(serviceExpenses, cashExpenses);
  final serviceReimbursements =
      ref.watch(monthlyReimbursementsProvider).value ?? [];
  final cashReimbursements =
      ref.watch(monthlyCashReimbursementsProvider).value ?? [];
  final reimbursements =
      mergeCreditedReimbursements(serviceReimbursements, cashReimbursements);
  final salaryWithheldExpenseIds =
      ref.watch(salaryWithheldExpenseIdsProvider).valueOrNull ?? const <int>{};

  if (budget == null) return 0.0;

  final main = ref.watch(mainCurrencyProvider);
  final display = resolveContextDisplayCurrency(budget, main);
  final source = main;
  final context = ref.watch(budgetContextProvider);
  if (!context.isShared && context.profileId != null) {
    final continuous = ref
        .watch(continuousBalanceProvider(
            (profileId: context.profileId!, yearMonth: yearMonth)))
        .valueOrNull;
    if (continuous?.status == BalanceChainStatus.needsReview) {
      throw FormatException(
          continuous!.reviewReason ?? 'The balance chain needs review.');
    }
    if (continuous != null && continuous.status == BalanceChainStatus.intact) {
      return toDisplay(Money(continuous.freeToUseMinor, source), display, table)
          .majorValue;
    }
  }
  if (reimbursements.any((r) => r.medicalReceiptJson != null) ||
      (ref.watch(actualIncomeLedgerProvider).valueOrNull?.isEmpty == false)) {
    final review = ref.watch(receiptReconciliationProvider).valueOrNull;
    final cash = review?.cash?.bankMinor;
    if (review == null || review.needsReview || cash == null) {
      throw const FormatException(
          'Review opening money before using the bank balance.');
    }
    return toDisplay(Money(cash, source), display, table).majorValue;
  }
  var total = toDisplay(
      Money.fromMajor(budget.baseAvailableAmount, source), display, table);

  for (final exp in expenses) {
    if (salaryWithheldExpenseIds.contains(exp.id)) continue;
    if (exp.status == ExpenseStatus.paid ||
        exp.status == ExpenseStatus.reimbursed ||
        exp.status == ExpenseStatus.partiallyReimbursed) {
      total = total -
          expenseToDisplay(exp, display, table, accountingCurrency: source);
    }
  }

  for (final reimb in reimbursements) {
    total = total +
        reimbursementToDisplay(reimb, display, table,
            accountingCurrency: source);
  }

  total = total +
      toDisplay(
          Money(ref.watch(monthlyVaultCreditProvider), source), display, table);
  return total.majorValue;
});
