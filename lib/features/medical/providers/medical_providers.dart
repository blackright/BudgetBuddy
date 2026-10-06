import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/insurance_profile.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/medical_service_type.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../repositories/medical_repository.dart';

final medicalRepositoryProvider = Provider<MedicalRepository>((ref) {
  return MedicalRepository(IsarHelper.instance);
});

/// Alias used by the service-type providers so a rename of the primary
/// repository provider cannot silently orphan them.
final medicalServiceTypesRepositoryProvider = Provider<MedicalRepository>(
  (ref) => ref.watch(medicalRepositoryProvider),
);

// -----------------------------------------------------------------------------
// Streamed source data
// -----------------------------------------------------------------------------

/// Every medical bill for the active profile in the selected month.
///
/// Month-scoped: a bill's money impact lands in exactly one month's totals
/// (FR-055, FR-056).
///
/// Yields an empty list until a profile exists so consumers never have to
/// null-check the profile themselves.
final medicalBillsProvider = StreamProvider<List<MedicalBill>>((ref) {
  final profileId = ref.watch(activeProfileProvider).value?.id;
  final yearMonth = ref.watch(selectedYearMonthProvider);
  if (profileId == null) return Stream.value(const <MedicalBill>[]);
  return ref
      .watch(medicalRepositoryProvider)
      .watchMedicalBills(profileId, yearMonth);
});

final insuranceProfileProvider = StreamProvider<InsuranceProfile?>((ref) {
  final profileId = ref.watch(activeProfileProvider).value?.id;
  if (profileId == null) return Stream.value(null);
  return ref.watch(medicalRepositoryProvider).watchInsuranceProfile(profileId);
});

final familyMembersProvider = StreamProvider<List<FamilyMember>>((ref) {
  final profileId = ref.watch(activeProfileProvider).value?.id;
  if (profileId == null) return Stream.value(const <FamilyMember>[]);
  return ref.watch(medicalRepositoryProvider).watchFamilyMembers(profileId);
});

final medicalProvidersProvider = StreamProvider<List<MedicalProvider>>((ref) {
  final profileId = ref.watch(activeProfileProvider).value?.id;
  if (profileId == null) return Stream.value(const <MedicalProvider>[]);
  return ref.watch(medicalRepositoryProvider).watchMedicalProviders(profileId);
});

/// A single bill, kept live so the detail screen reflects edits made elsewhere.
final medicalBillProvider = StreamProvider.family<MedicalBill?, int>((ref, id) {
  return ref.watch(medicalRepositoryProvider).watchMedicalBill(id);
});

/// Reactive join between the bills and their linked expenses, so UI can tell a
/// provider-payment state that lives on the expense, not the bill.
final medicalExpenseStatusesProvider =
    StreamProvider<Map<int, ExpenseStatus>>((ref) {
  final bills = ref.watch(medicalBillsProvider).value ?? const <MedicalBill>[];
  final ids = <int>{
    for (final b in bills)
      if (b.linkedExpenseId != null) b.linkedExpenseId!,
  };
  if (ids.isEmpty) return Stream.value(const <int, ExpenseStatus>{});
  return ref
      .watch(medicalRepositoryProvider)
      .watchExpenseStatuses(ids.toList());
});

// -----------------------------------------------------------------------------
// Budget context
// -----------------------------------------------------------------------------

/// The budget-scoped inputs the repository needs to link a bill to an expense.
final medicalBillContextProvider = Provider<MedicalBillContext?>((ref) {
  final profile = ref.watch(activeProfileProvider).value;
  final budget = ref.watch(activeBudgetProvider).value;
  if (profile == null || budget == null) return null;
  return MedicalBillContext(
    profileId: profile.id,
    budgetId: budget.id,
    yearMonth: budget.yearMonth,
    primaryCurrency: budget.currency.name.toUpperCase(),
  );
});

/// Display currency for the active budget, as the single [CurrencyCode] the
/// medical screens format through (FR-018) instead of a hardcoded symbol.
final medicalDisplayCurrencyProvider = Provider<CurrencyCode>((ref) {
  final budget = ref.watch(activeBudgetProvider).value;
  if (budget == null) return CurrencyCode.usd;
  return budget.currency.code;
});

// -----------------------------------------------------------------------------
// Derived aggregates
// -----------------------------------------------------------------------------

/// Name lookups so list/detail widgets can resolve names without extra queries.
final medicalDirectoryProvider = Provider<MedicalDirectory>((ref) {
  final members =
      ref.watch(familyMembersProvider).value ?? const <FamilyMember>[];
  final providers =
      ref.watch(medicalProvidersProvider).value ?? const <MedicalProvider>[];
  return MedicalDirectory(members: members, providers: providers);
});

/// User-editable service types for the active profile (FR-040).
///
/// Archived types are included so a historical bill can still resolve its type
/// by name.
final medicalServiceTypesProvider =
    StreamProvider<List<MedicalServiceType>>((ref) {
  final profileId = ref.watch(activeProfileProvider).value?.id;
  if (profileId == null) return Stream.value(const <MedicalServiceType>[]);
  return ref
      .watch(medicalServiceTypesRepositoryProvider)
      .watchServiceTypes(profileId);
});

/// Types offered when picking one for a new bill — archived types are excluded.
final selectableServiceTypesProvider =
    Provider<List<MedicalServiceType>>((ref) {
  final all = ref.watch(medicalServiceTypesProvider).value ??
      const <MedicalServiceType>[];
  return all.where((t) => !t.archived).toList();
});

/// Patient-share totals for the selected month (FR-038, SC-007).
///
/// Replaces the retired deductible aggregation: there is no deductible, so this
/// reports what the user actually owes and what the insurers covered. Summed on
/// the fly so edits and deletes need no stored running total.
final patientShareTotalsProvider = Provider<PatientShareTotals>((ref) {
  final bills = ref.watch(medicalBillsProvider).value ?? const <MedicalBill>[];
  return PatientShareTotals.from(bills);
});

/// What the medical feature currently costs the selected month's budget.
final medicalBudgetImpactProvider = Provider<MedicalBudgetImpact>((ref) {
  final bills = ref.watch(medicalBillsProvider).value ?? const <MedicalBill>[];
  final statuses = ref.watch(medicalExpenseStatusesProvider).value ??
      const <int, ExpenseStatus>{};
  return MedicalBudgetImpact.from(bills, expenseStatuses: statuses);
});

// -----------------------------------------------------------------------------
// Value types
// -----------------------------------------------------------------------------

class MedicalDirectory {
  const MedicalDirectory({
    required this.members,
    required this.providers,
  });

  final List<FamilyMember> members;
  final List<MedicalProvider> providers;

  String? providerName(int? id) {
    if (id == null) return null;
    for (final p in providers) {
      if (p.id == id) return p.name;
    }
    return null;
  }

  String? memberName(int? id) {
    if (id == null) return null;
    for (final m in members) {
      if (m.id == id) return m.name;
    }
    return null;
  }
}

/// Patient-share totals for a set of bills (FR-038).
///
/// The deductible aggregate this replaces is gone by design (FR-037): every bill
/// is treated as if no deductible applies, so there is no limit, no remaining
/// balance and no progress to track - only what the user owes and what the
/// insurers covered.
class PatientShareTotals {
  const PatientShareTotals({
    required this.billedTotal,
    required this.patientShareTotal,
    required this.insurerPaidTotal,
    required this.reimbursedTotal,
    required this.netPatientCost,
    required this.billCount,
  });

  const PatientShareTotals.empty()
      : billedTotal = 0.0,
        patientShareTotal = 0.0,
        insurerPaidTotal = 0.0,
        reimbursedTotal = 0.0,
        netPatientCost = 0.0,
        billCount = 0;

  /// Full charges across every bill.
  final double billedTotal;

  /// What the user owes across every bill, before reimbursements.
  final double patientShareTotal;

  /// What the insurers paid across every bill.
  final double insurerPaidTotal;

  /// Money that came back.
  final double reimbursedTotal;

  /// What the user is actually out of pocket once returns are counted.
  final double netPatientCost;

  final int billCount;

  bool get isEmpty => billCount == 0;

  static PatientShareTotals from(List<MedicalBill> bills) {
    if (bills.isEmpty) return const PatientShareTotals.empty();

    var billed = 0.0;
    var patient = 0.0;
    var insurer = 0.0;
    var reimbursed = 0.0;
    var net = 0.0;

    for (final bill in bills) {
      billed += bill.billedAmount;
      patient += bill.patientShareAmount;
      insurer += bill.insurerPaidAmount;
      reimbursed += bill.reimbursedAmount;
      net += bill.netOutOfPocket;
    }

    return PatientShareTotals(
      billedTotal: billed,
      patientShareTotal: patient,
      insurerPaidTotal: insurer,
      reimbursedTotal: reimbursed,
      netPatientCost: net,
      billCount: bills.length,
    );
  }
}

/// What the medical feature currently costs the budget.
class MedicalBudgetImpact {
  const MedicalBudgetImpact({
    required this.plannedTotal,
    required this.paidTotal,
    required this.outOfPocketTotal,
    required this.reimbursedTotal,
    required this.netOutOfPocket,
  });

  const MedicalBudgetImpact.empty()
      : plannedTotal = 0.0,
        paidTotal = 0.0,
        outOfPocketTotal = 0.0,
        reimbursedTotal = 0.0,
        netOutOfPocket = 0.0;

  /// Billed amount of bills whose linked expense is still `planned`.
  final double plannedTotal;

  /// What the selected month's medical spending actually cost the budget.
  ///
  /// Taken from [MedicalBill.fundsImpact] rather than from
  /// [MedicalBill.billedAmount], so an insurer-paid bill contributes only the
  /// patient share (FR-042). SC-009 — this is the same figure the month summary
  /// reports for its medical line.
  final double paidTotal;

  final double outOfPocketTotal;
  final double reimbursedTotal;

  /// What the user is out of pocket after reimbursements land.
  ///
  /// Mirrors the budget itself: a paid bill leaves the budget at its full
  /// [MedicalBill.billedAmount] and a reimbursement is the only thing that
  /// gives money back, so the net cost is `billed - reimbursed` per paid bill.
  final double netOutOfPocket;

  bool get hasPending => plannedTotal > 0;

  static MedicalBudgetImpact from(
    List<MedicalBill> bills, {
    Map<int, ExpenseStatus> expenseStatuses = const {},
  }) {
    if (bills.isEmpty) return const MedicalBudgetImpact.empty();

    var planned = 0.0;
    var paid = 0.0;
    var outOfPocket = 0.0;
    var reimbursed = 0.0;
    var net = 0.0;

    for (final bill in bills) {
      outOfPocket += bill.patientShareAmount;
      reimbursed += bill.reimbursedAmount;

      final expenseId = bill.linkedExpenseId;
      final status = expenseId == null ? null : expenseStatuses[expenseId];
      switch (status) {
        case ExpenseStatus.paid:
        case ExpenseStatus.reimbursed:
        case ExpenseStatus.partiallyReimbursed:
          // `fundsImpact`, not the billed amount: a rejected insurer-paid bill
          // owes the full charge and an unresolved one owes only the share.
          paid += bill.fundsImpact;
          net += bill.netOutOfPocket;
        case ExpenseStatus.planned:
          planned += bill.billedAmount;
        // Cancelled expenses, or bills saved without a linked expense, leave
        // the budget untouched.
        case ExpenseStatus.cancelled:
        case null:
          break;
      }
    }

    return MedicalBudgetImpact(
      plannedTotal: planned,
      paidTotal: paid,
      outOfPocketTotal: outOfPocket,
      reimbursedTotal: reimbursed,
      netOutOfPocket: net,
    );
  }
}

/// Whether a bill has been paid to the provider, given the joined statuses.
bool isPaidToProvider(MedicalBill bill, Map<int, ExpenseStatus> statuses) {
  final expenseId = bill.linkedExpenseId;
  if (expenseId == null) return false;
  return statuses[expenseId] == ExpenseStatus.paid;
}
