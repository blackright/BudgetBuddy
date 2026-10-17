import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/expense.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../engine/providers/month_summary_provider.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../engine/providers/true_available_provider.dart';
import '../../expenses/models/reimbursement.dart';
import '../../expenses/providers/category_provider.dart';
import '../../expenses/repositories/expense_repository.dart';
import '../../finance/providers/finance_providers.dart';
import '../../medical/providers/medical_providers.dart';
import '../../settings/providers/settings_provider.dart';
import '../../spaces/providers/spaces_providers.dart';
import '../domain/chart_filters.dart';
import '../domain/chart_query.dart';
import '../domain/chart_series.dart';
import '../repositories/analytics_repository.dart';

/// The single chart-data entry point (the "One Chart Brain",
/// contracts/chart-data.md §1).
///
/// Aggregation is performed by the pure `chart_query.dart` functions over the
/// [AnalyticsSnapshot] this provider exposes — no chart touches Isar or converts
/// currency itself (FR-001).
final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(ref.watch(rateRegistryProvider));
});

/// The active chart filters. Transient UI state; never persisted (FR-014).
final chartFiltersProvider =
    StateProvider<ChartFilters>((ref) => ChartFilters.none);

/// Every context-scoped row a chart can need, normalized once into the display
/// currency and re-derived whenever the context, month, currency, filters, or
/// any underlying row changes (FR-006).
///
/// Synchronous over already-watched streams — like `month_summaryProvider` — so
/// an edit anywhere upstream rebuilds every dependent chart in the same frame
/// without a manual refresh.
final analyticsSnapshotProvider = Provider<AnalyticsSnapshot>((ref) {
  final context = ref.watch(budgetContextProvider);
  final repository = ref.watch(analyticsRepositoryProvider);
  final main = ref.watch(mainCurrencyProvider);
  final filters = ref.watch(chartFiltersProvider);

  return repository.build(
    context: context,
    mainCurrency: main,
    filters: filters,
    expenses: ref.watch(monthlyExpensesProvider).value ?? const [],
    reimbursements:
        ref.watch(monthlyOriginReimbursementsProvider).value ?? const [],
    medicalBills: ref.watch(medicalBillsProvider).value ?? const [],
    month: ref.watch(monthFinanceProvider).value,
    members: ref.watch(activeSpaceMembersProvider).value ?? const [],
    categories: ref.watch(categoriesProvider).value ?? const [],
  );
});

/// Spending over time for the active context/month/filters (US1, FR-015).
final spendingSeriesProvider = Provider<ChartSeries>((ref) {
  return spendingSeries(ref.watch(analyticsSnapshotProvider));
});

/// Category breakdown for the active context/month/filters (US1, SC-001).
final categorySeriesProvider = Provider<ChartSeries>((ref) {
  return categorySeries(ref.watch(analyticsSnapshotProvider));
});

/// Planned vs paid for the active context/month/filters (US1, FR-013).
final plannedPaidSeriesProvider = Provider<ChartSeries>((ref) {
  return plannedPaidSeries(ref.watch(analyticsSnapshotProvider));
});

/// Available-amount trend for the active context/month/filters (US2, FR-016).
final availableTrendSeriesProvider = Provider<ChartSeries>((ref) {
  return availableTrendSeries(ref.watch(analyticsSnapshotProvider));
});

/// Medical insurer/user split for the active context/month (US4).
final insuranceSeriesProvider = Provider<ChartSeries>((ref) {
  return insuranceSeries(ref.watch(analyticsSnapshotProvider));
});

/// Shared-member contribution for the active space/month (US4, FR-011).
///
/// Empty in a personal context, because a personal profile has no members
/// (`snapshot.members` is empty) — the chart is only rendered in the shared lens.
/// Profile names are looked up here (and only here), so the foundational
/// snapshot keeps no dependency on the profile table.
final contributionSeriesProvider = Provider<ChartSeries>((ref) {
  final names = <int, String>{
    for (final profile in ref.watch(profilesProvider).value ?? const [])
      profile.id: profile.name,
  };
  return contributionSeries(
    ref.watch(analyticsSnapshotProvider),
    profileNames: names,
  );
});

/// The active profile's personal context, even while a space is active — the
/// "personal" side of the comparison chart, or `null` when no profile is known.
final _personalComparisonContextProvider = Provider<ContextRef?>((ref) {
  final profileId = ref.watch(actingProfileIdProvider);
  if (profileId == null) return null;
  return ContextRef.personal(
    profileId: profileId,
    yearMonth: ref.watch(selectedYearMonthProvider),
  );
});

final _personalMonthlyExpensesProvider = StreamProvider<List<Expense>>((ref) {
  final context = ref.watch(_personalComparisonContextProvider);
  if (context == null) return Stream.value(const []);
  return ref.watch(expenseRepositoryProvider).watchExpensesForContext(context);
});

final _personalMonthlyReimbursementsProvider =
    StreamProvider<List<Reimbursement>>((ref) {
  final context = ref.watch(_personalComparisonContextProvider);
  if (context == null) return Stream.value(const []);
  return ref
      .watch(expenseRepositoryProvider)
      .watchReimbursementsForContext(context);
});

/// The active profile's personal snapshot for the selected month, normalized
/// into the shared snapshot's display currency so the two sides of the
/// comparison add honestly (FR-004). `null` outside a shared context.
final personalSnapshotProvider = Provider<AnalyticsSnapshot?>((ref) {
  final shared = ref.watch(analyticsSnapshotProvider);
  if (!shared.context.isShared) return null;

  final context = ref.watch(_personalComparisonContextProvider);
  if (context == null) return null;

  final expenses = ref.watch(_personalMonthlyExpensesProvider).value;
  final reimbursements =
      ref.watch(_personalMonthlyReimbursementsProvider).value;
  if (expenses == null || reimbursements == null) return null;

  return ref.watch(analyticsRepositoryProvider).build(
        context: context,
        mainCurrency: ref.watch(mainCurrencyProvider),
        filters: ref.watch(chartFiltersProvider),
        expenses: expenses,
        reimbursements: reimbursements,
        medicalBills: const [],
        month: null,
        members: const [],
        categories: ref.watch(categoriesProvider).value ?? const [],
        displayOverride: shared.displayCurrency,
      );
});

/// Shared-vs-personal comparison for the active space/month (US4).
///
/// Only meaningful in a shared context; elsewhere it is honestly empty. The
/// personal side is loaded lazily, so a personal lens never touches it.
final sharedVsPersonalSeriesProvider = Provider<ChartSeries>((ref) {
  final shared = ref.watch(analyticsSnapshotProvider);
  if (!shared.context.isShared) {
    return ChartSeries.empty(
        ChartKind.sharedVsPersonal, shared.displayCurrency);
  }
  final personal = ref.watch(personalSnapshotProvider);
  if (personal == null) {
    return ChartSeries.empty(
        ChartKind.sharedVsPersonal, shared.displayCurrency);
  }
  return sharedVsPersonalSeries(shared, personal);
});
