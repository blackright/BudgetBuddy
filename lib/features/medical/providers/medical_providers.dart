import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/insurance_profile.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../repositories/medical_repository.dart';

final medicalRepositoryProvider = Provider<MedicalRepository>((ref) {
  return MedicalRepository(IsarHelper.instance);
});

/// Deductible year currently in force. A provider (not a constant) so the app
/// stays correct if it is left running across New Year.
final currentMedicalYearProvider = Provider<int>((ref) => DateTime.now().year);

// -----------------------------------------------------------------------------
// Streamed source data
// -----------------------------------------------------------------------------

/// Every medical bill for the active profile in the current calendar year.
///
/// Yields an empty list until a profile exists so consumers never have to
/// null-check the profile themselves.
final medicalBillsProvider = StreamProvider<List<MedicalBill>>((ref) {
  final profileId = ref.watch(activeProfileProvider).value?.id;
  if (profileId == null) return Stream.value(const <MedicalBill>[]);
  return ref
      .watch(medicalRepositoryProvider)
      .watchMedicalBills(profileId, ref.watch(currentMedicalYearProvider));
});

final insuranceProfileProvider = StreamProvider<InsuranceProfile?>((ref) {
  final profileId = ref.watch(activeProfileProvider).value?.id;
  if (profileId == null) return Stream.value(null);
  return ref
      .watch(medicalRepositoryProvider)
      .watchInsuranceProfile(profileId, ref.watch(currentMedicalYearProvider));
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

/// Currency symbol for the active budget, matching the dashboard's convention.
final medicalCurrencySymbolProvider = Provider<String>((ref) {
  final budget = ref.watch(activeBudgetProvider).value;
  if (budget == null) return r'$';
  return switch (budget.currency) {
    PrimaryCurrency.usd => r'$',
    PrimaryCurrency.eur => '€',
    PrimaryCurrency.cad => r'C$',
    PrimaryCurrency.huf => 'Ft',
  };
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

/// Deductible progress for the current year (FR-006).
///
/// Summed on the fly rather than stored (research.md §3) so edits and deletes
/// are reflected without maintaining a running total.
final deductibleProgressProvider = Provider<DeductibleProgress>((ref) {
  final bills = ref.watch(medicalBillsProvider).value ?? const <MedicalBill>[];
  final insurance = ref.watch(insuranceProfileProvider).value;
  return DeductibleProgress.from(bills: bills, insurance: insurance);
});

/// What the medical feature currently costs the budget.
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

/// Aggregate out-of-pocket spend against the deductible for the current year.
class DeductibleProgress {
  const DeductibleProgress({
    required this.outOfPocketTotal,
    required this.billedTotal,
    required this.reimbursedTotal,
    required this.individualLimit,
    required this.familyLimit,
    required this.individualOutOfPocket,
    required this.billCount,
  });

  const DeductibleProgress.empty()
      : outOfPocketTotal = 0.0,
        billedTotal = 0.0,
        reimbursedTotal = 0.0,
        individualLimit = 0.0,
        familyLimit = 0.0,
        individualOutOfPocket = 0.0,
        billCount = 0;

  final double outOfPocketTotal;
  final double billedTotal;
  final double reimbursedTotal;
  final double individualLimit;
  final double familyLimit;
  final double individualOutOfPocket;
  final int billCount;

  bool get hasInsuranceProfile => individualLimit > 0 || familyLimit > 0;

  bool get hasFamilyLimit => familyLimit > individualLimit && familyLimit > 0;

  /// Limit that applies to a bill attributed to [memberId].
  double limitFor(int? memberId) {
    if (memberId == null) return individualLimit;
    return hasFamilyLimit ? familyLimit : individualLimit;
  }

  /// Out-of-pocket already credited against the limit for [memberId].
  ///
  /// The individual limit only absorbs bills with no family attribution, so a
  /// family member's care never eats into [individualOutOfPocket].
  double metFor(int? memberId) =>
      memberId == null ? individualOutOfPocket : outOfPocketTotal;

  /// Family-wide out-of-pocket, i.e. every attributed and unattributed bill.
  double get familyMet => outOfPocketTotal;

  /// Fraction of the deductible met, clamped to 0..1 for progress indicators.
  double fractionOf({int? memberId}) =>
      _fraction(metFor(memberId), limitFor(memberId));

  /// Fraction of the *family* aggregate deductible met.
  double familyFraction() => _fraction(familyMet, familyLimit);

  double remainingFor({int? memberId}) =>
      _remaining(metFor(memberId), limitFor(memberId));

  double familyRemaining() => _remaining(familyMet, familyLimit);

  static double _fraction(double met, double limit) =>
      limit <= 0 ? 0.0 : (met / limit).clamp(0.0, 1.0);

  static double _remaining(double met, double limit) =>
      limit <= 0 ? 0.0 : (limit - met).clamp(0.0, double.infinity);

  static DeductibleProgress from({
    required List<MedicalBill> bills,
    required InsuranceProfile? insurance,
  }) {
    if (bills.isEmpty && insurance == null) {
      return const DeductibleProgress.empty();
    }

    var outOfPocket = 0.0;
    var individualOutOfPocket = 0.0;
    var billed = 0.0;
    var reimbursed = 0.0;

    for (final bill in bills) {
      outOfPocket += bill.estimatedOutPocket;
      billed += bill.billedAmount;
      reimbursed += bill.reimbursedAmount;
      // Bills with no patient attribution count against the individual limit.
      if (bill.familyMemberId == null) {
        individualOutOfPocket += bill.estimatedOutPocket;
      }
    }

    return DeductibleProgress(
      outOfPocketTotal: outOfPocket,
      billedTotal: billed,
      reimbursedTotal: reimbursed,
      individualLimit: insurance?.individualDeductible ?? 0.0,
      familyLimit: insurance?.familyDeductible ?? 0.0,
      individualOutOfPocket: individualOutOfPocket,
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

  /// Billed amount of bills whose linked expense is `paid`.
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
      outOfPocket += bill.estimatedOutPocket;
      reimbursed += bill.reimbursedAmount;

      final expenseId = bill.linkedExpenseId;
      final status = expenseId == null ? null : expenseStatuses[expenseId];
      switch (status) {
        case ExpenseStatus.paid:
          paid += bill.billedAmount;
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
