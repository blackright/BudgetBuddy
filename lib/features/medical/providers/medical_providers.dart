import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/insurance_profile.dart';
import '../../../core/models/medical_appeal.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/reconciliation_snapshot.dart';
import '../../../core/models/medical_service_type.dart';
import '../../../core/models/money.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../engine/currency_resolution.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../spaces/repositories/space_write_guard.dart';
import '../../sync/providers/sync_recorder_provider.dart';
import '../../../core/services/medical_withholding_service.dart';
import '../../../core/services/medical_management_reducer.dart';
import '../../../core/services/medical_management_service.dart';
import '../../../core/services/medical_settlement_service.dart';
import '../../../core/services/medical_receipt_service.dart';
import '../repositories/medical_repository.dart';
import '../presentation/medical_bill_view_state.dart';
import '../presentation/medical_bill_state_resolver.dart';

/// Pure shared interpreter; future screens use the same instance contract.
final medicalBillStateResolverProvider = Provider<MedicalBillStateResolver>(
    (ref) => const MedicalBillStateResolver());

/// Readiness failure is not silently treated as a successful empty check.
MedicalReadiness medicalViewReadiness(List<ReceiptBlocker>? blockers) =>
    blockers == null
        ? MedicalReadiness.unknown()
        : blockers.isEmpty
            ? MedicalReadiness.ready()
            : MedicalReadiness.blocked(blockers.map((b) => b.name));
final medicalWithholdingServiceProvider =
    Provider<MedicalWithholdingService>((ref) {
  return MedicalWithholdingService(IsarHelper.instance,
      recorder: ref.watch(syncRecorderProvider));
});
final medicalSettlementServiceProvider =
    Provider<MedicalSettlementService>((ref) {
  return MedicalSettlementService(IsarHelper.instance,
      recorder: ref.watch(syncRecorderProvider));
});

final medicalManagementReducerProvider =
    Provider<MedicalManagementReducer>((ref) {
  return const MedicalManagementReducer();
});

final medicalManagementServiceProvider =
    Provider<MedicalManagementService>((ref) {
  return MedicalManagementService(
    db: IsarHelper.instance,
    actingProfileId: ref.watch(actingProfileIdProvider),
    recorder: ref.watch(syncRecorderProvider),
    reducer: ref.watch(medicalManagementReducerProvider),
  );
});

final medicalRepositoryProvider = Provider<MedicalRepository>((ref) {
  return MedicalRepository(
    IsarHelper.instance,
    rateRegistry: ref.watch(rateRegistryProvider),
    guard: ref.watch(spaceWriteGuardProvider),
    actingProfileId: ref.watch(actingProfileIdProvider),
    syncRecorder: ref.watch(syncRecorderProvider),
  );
});

/// Alias used by the service-type providers so a rename of the primary
/// repository provider cannot silently orphan them.
final medicalServiceTypesRepositoryProvider = Provider<MedicalRepository>(
  (ref) => ref.watch(medicalRepositoryProvider),
);

// -----------------------------------------------------------------------------
// Streamed source data
// -----------------------------------------------------------------------------

/// Every medical bill for the active context in the selected month.
///
/// Month-scoped: a bill's money impact lands in exactly one month's totals
/// (FR-055, FR-056). Context-scoped: a shared space sees only its own bills
/// (R3, data-model §3.5).
///
/// Yields an empty list until a context exists so consumers never have to
/// null-check it themselves.
final medicalBillsProvider = StreamProvider<List<MedicalBill>>((ref) {
  final context = ref.watch(budgetContextProvider);
  return ref
      .watch(medicalRepositoryProvider)
      .watchMedicalBillsForContext(context);
});

final insuranceProfileProvider = StreamProvider<InsuranceProfile?>((ref) {
  final context = ref.watch(budgetContextProvider);
  return ref.watch(medicalRepositoryProvider).watchInsuranceProfileForContext(
        context,
      );
});

final familyMembersProvider = StreamProvider<List<FamilyMember>>((ref) {
  final context = ref.watch(budgetContextProvider);
  return ref
      .watch(medicalRepositoryProvider)
      .watchFamilyMembersForContext(context);
});

final medicalProvidersProvider = StreamProvider<List<MedicalProvider>>((ref) {
  final context = ref.watch(budgetContextProvider);
  return ref
      .watch(medicalRepositoryProvider)
      .watchMedicalProvidersForContext(context);
});

/// A single bill, kept live so the detail screen reflects edits made elsewhere.
final medicalBillProvider = StreamProvider.family<MedicalBill?, int>((ref, id) {
  return ref.watch(medicalRepositoryProvider).watchMedicalBill(id);
});

/// Repeatable appeal attempts for one bill, oldest first.
final medicalAppealsProvider =
    StreamProvider.family<List<MedicalAppeal>, String>((ref, billGuid) {
  final db = IsarHelper.maybeInstance;
  if (db == null) return Stream.value(const <MedicalAppeal>[]);
  return db.medicalAppeals.watchLazy().asyncMap((_) async {
    final rows =
        await db.medicalAppeals.filter().billGuidEqualTo(billGuid).findAll();
    rows.sort((a, b) => a.submittedAt.compareTo(b.submittedAt));
    return rows;
  });
});

/// Read-only receipt-readiness blockers for a bill's owning month, used to
/// surface month setup problems before the reviewed provider-payment path is
/// attempted (A1, improvements plan).
final medicalBillMonthBlockersProvider =
    FutureProvider.family<List<ReceiptBlocker>, int>((ref, billId) async {
  final bill = await ref.watch(medicalBillProvider(billId).future);
  if (bill == null) return const <ReceiptBlocker>[];
  return ref.watch(medicalRepositoryProvider).monthBlockersFor(bill);
});

/// Resolve the canonical bill only inside the selected owner and month.
/// A missing or ambiguous link must never open another owner's Medical data.
final medicalBillForExpenseProvider =
    StreamProvider.family<MedicalBill?, int>((ref, expenseId) {
  final context = ref.watch(budgetContextProvider);
  return ref
      .watch(medicalRepositoryProvider)
      .watchMedicalBillsForContext(context)
      .map((bills) {
    final matches =
        bills.where((bill) => bill.linkedExpenseId == expenseId).toList();
    if (matches.length > 1) throw StateError('Medical bill link needs review.');
    return matches.firstOrNull;
  });
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
///
/// Resolved straight from the selection markers and the live profile/space rows
/// rather than through [budgetContextProvider], so a context that has not
/// resolved yet (no profile on the first build frame, no budget) yields `null`
/// instead of propagating a `StateError`.
final medicalBillContextProvider = Provider<MedicalBillContext?>((ref) {
  final budget = ref.watch(activeBudgetProvider).value;
  if (budget == null) return null;

  final spaceId = ref.watch(activeSpaceIdProvider);
  if (spaceId != null) {
    return MedicalBillContext(
      profileId: 0, // unused for shared context; money rows key on spaceId
      sharedSpaceId: spaceId,
      budgetId: budget.id,
      yearMonth: budget.yearMonth,
      primaryCurrency: ref.watch(mainCurrencyProvider).name.toUpperCase(),
      rateTable: ref.watch(rateRegistryProvider).tableFor(budget.yearMonth),
    );
  }
  final profile = ref.watch(activeProfileProvider).value;
  if (profile == null) return null;
  return MedicalBillContext(
    profileId: profile.id,
    sharedSpaceId: null,
    budgetId: budget.id,
    yearMonth: budget.yearMonth,
    primaryCurrency: profile.primaryCurrency.name.toUpperCase(),
    rateTable: ref.watch(rateRegistryProvider).tableFor(budget.yearMonth),
  );
});

/// Display currency for the active month, as the single [CurrencyCode] the
/// medical screens format through (FR-011, FR-018) instead of a hardcoded
/// symbol: the month's convert-to choice when set, otherwise the context's main
/// currency (space currency when a space is active, context-router §4-I5).
final medicalDisplayCurrencyProvider = Provider<CurrencyCode>((ref) {
  final budget = ref.watch(activeBudgetProvider).value;
  final main = ref.watch(mainCurrencyProvider);
  return resolveContextDisplayCurrency(budget, main);
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

/// User-editable service types for the active context (FR-040).
///
/// Archived types are included so a historical bill can still resolve its type
/// by name. Context-aware (R3): a shared space with bills seeds/reads its own.
final medicalServiceTypesProvider =
    StreamProvider<List<MedicalServiceType>>((ref) {
  final context = ref.watch(budgetContextProvider);
  return ref
      .watch(medicalServiceTypesRepositoryProvider)
      .watchServiceTypesForContext(context);
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
  final display = ref.watch(medicalDisplayCurrencyProvider);
  final table = ref.watch(rateRegistryProvider).tableFor(
        ref.watch(selectedYearMonthProvider),
      );
  final statuses = ref.watch(medicalExpenseStatusesProvider).valueOrNull ??
      const <int, ExpenseStatus>{};
  return PatientShareTotals.from(
    bills
        .where(
            (bill) => statuses[bill.linkedExpenseId] != ExpenseStatus.cancelled)
        .toList(),
    display: display,
    convert: (amount) => toDisplay(amount, display, table),
  );
});

/// What the medical feature currently costs the selected month's budget.
final medicalBudgetImpactProvider = Provider<MedicalBudgetImpact>((ref) {
  final bills = ref.watch(medicalBillsProvider).value ?? const <MedicalBill>[];
  final statuses = ref.watch(medicalExpenseStatusesProvider).value ??
      const <int, ExpenseStatus>{};
  final display = ref.watch(medicalDisplayCurrencyProvider);
  final table = ref.watch(rateRegistryProvider).tableFor(
        ref.watch(selectedYearMonthProvider),
      );
  return MedicalBudgetImpact.from(
    bills,
    display: display,
    convert: (amount) => toDisplay(amount, display, table),
    expenseStatuses: statuses,
  );
});

// -----------------------------------------------------------------------------
// Value types
// -----------------------------------------------------------------------------

/// Filter selection for the Medical action inbox. Open bills default to all
/// months; [month] null means "All months".
enum MedicalInboxArrangement { all, selfPay, insurerPaid }

class MedicalInboxFilters {
  const MedicalInboxFilters({
    this.group = MedicalInboxGroup.needsYou,
    this.query = '',
    this.arrangement = MedicalInboxArrangement.all,
    this.month,
  });

  final MedicalInboxGroup group;
  final String query;
  final MedicalInboxArrangement arrangement;

  /// `null` is All months.
  final String? month;

  bool get isDefault =>
      group == MedicalInboxGroup.needsYou &&
      query.trim().isEmpty &&
      arrangement == MedicalInboxArrangement.all &&
      month == null;

  static const Object _unset = Object();

  MedicalInboxFilters copyWith({
    MedicalInboxGroup? group,
    String? query,
    MedicalInboxArrangement? arrangement,
    Object? month = _unset,
  }) =>
      MedicalInboxFilters(
        group: group ?? this.group,
        query: query ?? this.query,
        arrangement: arrangement ?? this.arrangement,
        month: identical(month, _unset) ? this.month : month as String?,
      );
}

final medicalInboxFiltersProvider =
    StateProvider<MedicalInboxFilters>((ref) => const MedicalInboxFilters());

class MedicalInboxItem {
  const MedicalInboxItem({
    required this.bill,
    required this.state,
    this.providerName,
    this.memberName,
    this.serviceTypeName,
    this.issue,
  });

  final MedicalBill bill;
  final MedicalBillViewState state;
  final String? providerName;
  final String? memberName;
  final String? serviceTypeName;
  final String? issue;
}

class MedicalInbox {
  const MedicalInbox({
    required this.items,
    required this.counts,
    required this.needsYouCount,
    required this.approvedStillToReceiveMinor,
    required this.currency,
    required this.amountsNeedReview,
    required this.monthOptions,
    required this.allBillsCount,
  });

  final List<MedicalInboxItem> items;
  final Map<MedicalInboxGroup, int> counts;
  final int needsYouCount;
  final int approvedStillToReceiveMinor;
  final CurrencyCode currency;
  final bool amountsNeedReview;
  final List<String> monthOptions;
  final int allBillsCount;

  int count(MedicalInboxGroup group) => counts[group] ?? 0;
}

/// Pure inbox filtering and summary. Money is converted by the caller; an
/// unconvertible row is excluded and flagged, never added as if it were zero.
MedicalInbox buildMedicalInbox({
  required List<MedicalInboxItem> items,
  required MedicalInboxFilters filters,
  required CurrencyCode display,
  required DateTime now,
  required Money? Function(Money amount) convert,
}) {
  final query = filters.query.trim().toLowerCase();
  bool matches(MedicalInboxItem item) {
    final bill = item.bill;
    if (filters.arrangement == MedicalInboxArrangement.selfPay &&
        bill.paymentMethod != MedicalPaymentMethod.selfPaid) {
      return false;
    }
    if (filters.arrangement == MedicalInboxArrangement.insurerPaid &&
        bill.paymentMethod != MedicalPaymentMethod.insurerPaid) {
      return false;
    }
    if (filters.month != null && bill.yearMonth != filters.month) return false;
    if (query.isEmpty) return true;
    return [
      item.providerName,
      item.memberName,
      item.serviceTypeName,
      bill.yearMonth,
      item.state.headline,
      item.state.actionLabel,
    ].whereType<String>().any((value) => value.toLowerCase().contains(query));
  }

  final counts = <MedicalInboxGroup, int>{
    for (final group in MedicalInboxGroup.values) group: 0,
  };
  for (final item in items.where(matches)) {
    counts[item.state.group] = (counts[item.state.group] ?? 0) + 1;
  }

  var approved = 0;
  var needReview = false;
  for (final item in items) {
    final state = item.state;
    if (state.group == MedicalInboxGroup.closed ||
        state.isCancelled ||
        state.isEnteredInError ||
        state.insuranceDeclined) {
      continue;
    }
    final remaining = state.remainingRefund;
    if (remaining == null || remaining.minorUnits <= 0) continue;
    final converted = convert(remaining);
    if (converted == null) {
      needReview = true;
      continue;
    }
    approved += converted.minorUnits;
  }

  final visible = items
      .where((item) => item.state.group == filters.group && matches(item))
      .toList()
    ..sort((a, b) {
      int rank(MedicalInboxItem item) {
        final followUp = item.bill.followUpDate;
        if (followUp == null) return 2;
        return followUp.isAfter(now) ? 1 : 0;
      }

      final byRank = rank(a).compareTo(rank(b));
      if (byRank != 0) return byRank;
      final aFollow = a.bill.followUpDate;
      final bFollow = b.bill.followUpDate;
      if (aFollow != null && bFollow != null) {
        final byFollow = aFollow.compareTo(bFollow);
        if (byFollow != 0) return byFollow;
      }
      final aDate = a.bill.serviceDate;
      final bDate = b.bill.serviceDate;
      if (aDate != null && bDate != null) {
        final byDate = bDate.compareTo(aDate);
        if (byDate != 0) return byDate;
      }
      return b.bill.id.compareTo(a.bill.id);
    });

  final months = items
      .map((item) => item.bill.yearMonth)
      .where((month) => month.isNotEmpty)
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a));

  return MedicalInbox(
    items: List.unmodifiable(visible),
    counts: Map.unmodifiable(counts),
    needsYouCount: items
        .where((item) => item.state.group == MedicalInboxGroup.needsYou)
        .length,
    approvedStillToReceiveMinor: approved,
    currency: display,
    amountsNeedReview: needReview,
    monthOptions: List.unmodifiable(months),
    allBillsCount: items.length,
  );
}

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

/// Converts a [Money] in a bill's own currency into the display currency.
typedef MoneyConverter = Money Function(Money amount);

/// Patient-share totals for a set of bills (FR-038).
///
/// The deductible aggregate this replaces is gone by design (FR-037): every bill
/// is treated as if no deductible applies, so there is no limit, no remaining
/// balance and no progress to track - only what the user owes and what the
/// insurers covered.
///
/// Every figure is held in **whole minor units of the display currency**; each
/// bill is converted from its own currency as it is folded in (FR-016).
class PatientShareTotals {
  const PatientShareTotals({
    required this.currency,
    required this.billedTotal,
    required this.patientShareTotal,
    required this.insurerPaidTotal,
    required this.reimbursedTotal,
    required this.netPatientCost,
    required this.billCount,
  });

  const PatientShareTotals.empty(this.currency)
      : billedTotal = 0,
        patientShareTotal = 0,
        insurerPaidTotal = 0,
        reimbursedTotal = 0,
        netPatientCost = 0,
        billCount = 0;

  /// The currency every total is denominated in.
  final CurrencyCode currency;

  /// Full charges across every bill, in [currency] minor units.
  final int billedTotal;

  /// What the user owes across every bill, before reimbursements.
  final int patientShareTotal;

  /// What the insurers paid across every bill.
  final int insurerPaidTotal;

  /// Money that came back.
  final int reimbursedTotal;

  /// What the user is actually out of pocket once returns are counted.
  final int netPatientCost;

  final int billCount;

  bool get isEmpty => billCount == 0;

  static PatientShareTotals from(
    List<MedicalBill> bills, {
    required CurrencyCode display,
    required MoneyConverter convert,
  }) {
    if (bills.isEmpty) return PatientShareTotals.empty(display);

    int inDisplay(int minor, CurrencyCode? billCurrency) =>
        convert(Money(minor, billCurrency ?? display)).minorUnits;

    var billed = 0;
    var patient = 0;
    var insurer = 0;
    var reimbursed = 0;
    var net = 0;

    for (final bill in bills) {
      final code = bill.currencyCode;
      billed += inDisplay(bill.billedAmount, code);
      patient += inDisplay(bill.patientShareAmount, code);
      insurer += inDisplay(bill.insurerPaidAmount, code);
      reimbursed += inDisplay(bill.reimbursedAmount, code);
      net += inDisplay(bill.netOutOfPocket, code);
    }

    return PatientShareTotals(
      currency: display,
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
///
/// Every figure is held in **whole minor units of the display currency**;
/// each bill is converted from its own currency as it is folded in (FR-016).
class MedicalBudgetImpact {
  const MedicalBudgetImpact({
    required this.currency,
    required this.plannedTotal,
    required this.paidTotal,
    required this.outOfPocketTotal,
    required this.reimbursedTotal,
    required this.netOutOfPocket,
  });

  const MedicalBudgetImpact.empty(this.currency)
      : plannedTotal = 0,
        paidTotal = 0,
        outOfPocketTotal = 0,
        reimbursedTotal = 0,
        netOutOfPocket = 0;

  /// The currency every total is denominated in.
  final CurrencyCode currency;

  /// Billed amount of bills whose linked expense is still `planned`.
  final int plannedTotal;

  /// What the selected month's medical spending actually cost the budget.
  ///
  /// Taken from [MedicalBill.fundsImpact] rather than from
  /// [MedicalBill.billedAmount], so an insurer-paid bill contributes only the
  /// patient share (FR-042). SC-009 — this is the same figure the month summary
  /// reports for its medical line.
  final int paidTotal;

  final int outOfPocketTotal;
  final int reimbursedTotal;

  /// What the user is out of pocket after reimbursements land.
  ///
  /// Mirrors the budget itself: a paid bill leaves the budget at its full
  /// [MedicalBill.billedAmount] and a reimbursement is the only thing that
  /// gives money back, so the net cost is `billed - reimbursed` per paid bill.
  final int netOutOfPocket;

  bool get hasPending => plannedTotal > 0;

  static MedicalBudgetImpact from(
    List<MedicalBill> bills, {
    required CurrencyCode display,
    required MoneyConverter convert,
    Map<int, ExpenseStatus> expenseStatuses = const {},
  }) {
    if (bills.isEmpty) return MedicalBudgetImpact.empty(display);

    int inDisplay(int minor, CurrencyCode? billCurrency) =>
        convert(Money(minor, billCurrency ?? display)).minorUnits;

    var planned = 0;
    var paid = 0;
    var outOfPocket = 0;
    var reimbursed = 0;
    var net = 0;

    for (final bill in bills) {
      if (expenseStatuses[bill.linkedExpenseId] == ExpenseStatus.cancelled) {
        continue;
      }
      final code = bill.currencyCode;
      outOfPocket += inDisplay(bill.patientShareAmount, code);
      reimbursed += inDisplay(bill.reimbursedAmount, code);

      final expenseId = bill.linkedExpenseId;
      final status = expenseId == null ? null : expenseStatuses[expenseId];
      switch (status) {
        case ExpenseStatus.paid:
        case ExpenseStatus.reimbursed:
        case ExpenseStatus.partiallyReimbursed:
          // `fundsImpact`, not the billed amount: a rejected insurer-paid bill
          // owes the full charge and an unresolved one owes only the share.
          paid += inDisplay(bill.fundsImpact, code);
          net += inDisplay(bill.netOutOfPocket, code);
        case ExpenseStatus.planned:
          planned += inDisplay(bill.billedAmount, code);
        // Cancelled expenses, or bills saved without a linked expense, leave
        // the budget untouched.
        case ExpenseStatus.cancelled:
        case null:
          break;
      }
    }

    return MedicalBudgetImpact(
      currency: display,
      plannedTotal: planned,
      paidTotal: paid,
      outOfPocketTotal: outOfPocket,
      reimbursedTotal: reimbursed,
      netOutOfPocket: net,
    );
  }
}

/// Whether the direct-insurer provider payment is confirmed from retained
/// evidence, falling back to the legacy bill state only when evidence is truly
/// absent. A pending event is not treated as paid.
bool isInsurerPaidFromEvidence(
    MedicalBill bill, MedicalReceiptHistory? history) {
  if (bill.paymentMethod != MedicalPaymentMethod.insurerPaid) return false;
  if (history != null) {
    final facts = MedicalBillFacts.fromHistory(bill, history);
    if (facts.directProviderSettlement == MedicalEvidence.confirmed) {
      return true;
    }
    if (facts.directProviderSettlement == MedicalEvidence.notConfirmed) {
      return false;
    }
  }
  return bill.state == MedicalBillState.paid;
}

/// Whether a bill has been paid to the provider, given the joined statuses.
bool isPaidToProvider(MedicalBill bill, Map<int, ExpenseStatus> statuses) {
  final expenseId = bill.linkedExpenseId;
  if (expenseId == null) return false;
  return {
    ExpenseStatus.paid,
    ExpenseStatus.partiallyReimbursed,
    ExpenseStatus.reimbursed
  }.contains(statuses[expenseId]);
}
