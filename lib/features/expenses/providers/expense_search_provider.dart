import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_helper.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/merchant.dart';
import '../../../core/models/budget_profile.dart';
import '../../../core/models/direct_expense_profile.dart';
import 'package:isar/isar.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/services/filter_service.dart';
import '../../../core/services/search_service.dart';
import '../../spaces/providers/spaces_providers.dart';
import '../repositories/expense_search_repository.dart';

class ExpenseSearchState {
  const ExpenseSearchState(
      {this.query = '',
      this.filters = const ExpenseFilters(),
      this.page = 0,
      this.savedBatch,
      this.resetToken = 0});
  final String query;
  final ExpenseFilters filters;
  final int page;
  final int resetToken;
  final Set<String>? savedBatch;
}

class ExpenseSearchController extends StateNotifier<ExpenseSearchState> {
  ExpenseSearchController() : super(const ExpenseSearchState());
  Timer? _timer;
  String _draft = '';
  void type(String query) {
    _draft = query;
    _timer?.cancel();
    _timer = Timer(
        const Duration(milliseconds: 150),
        () => state = ExpenseSearchState(
            query: query,
            filters: state.filters,
            savedBatch: state.savedBatch,
            resetToken: state.resetToken));
  }

  void apply(ExpenseFilters filters) {
    _timer?.cancel();
    state = ExpenseSearchState(
        query: _draft,
        filters: filters,
        savedBatch: state.savedBatch,
        resetToken: state.resetToken);
  }

  void showSavedBatch(Iterable<String> guids) {
    _timer?.cancel();
    _draft = '';
    state = ExpenseSearchState(
        savedBatch: Set.unmodifiable(guids), resetToken: state.resetToken + 1);
  }

  void clearSavedBatch() {
    if (state.savedBatch == null) return;
    state = ExpenseSearchState(
        query: state.query,
        filters: state.filters,
        resetToken: state.resetToken);
  }

  void page(int page) => state = ExpenseSearchState(
      query: state.query,
      filters: state.filters,
      page: page,
      savedBatch: state.savedBatch,
      resetToken: state.resetToken);
  void clear() {
    _timer?.cancel();
    _draft = '';
    state = ExpenseSearchState(resetToken: state.resetToken + 1);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Owner selection resets transient filters, but month navigation does not.
final expenseSearchStateProvider =
    StateNotifierProvider<ExpenseSearchController, ExpenseSearchState>((ref) {
  ref.watch(budgetContextProvider.select((c) => (c.profileId, c.spaceId)));
  final controller = ExpenseSearchController();
  ref.listen(budgetContextProvider.select((c) => c.yearMonth), (_, __) {
    controller.clearSavedBatch();
  });
  return controller;
});
final expenseSearchRepositoryProvider =
    Provider((ref) => ExpenseSearchRepository(IsarHelper.instance));
final expenseSearchRowsProvider =
    StreamProvider.autoDispose<List<Expense>>((ref) {
  final scope = ref.watch(budgetContextProvider);
  final actor = ref.watch(actingProfileIdProvider);
  if (scope.isShared) ref.watch(activeSpaceMembersProvider);
  return ref.watch(expenseSearchRepositoryProvider).watch(scope, actor);
});
final expenseSearchMerchantsProvider =
    StreamProvider.autoDispose<List<Merchant>>((ref) {
  final scope = ref.watch(budgetContextProvider);
  final actor = ref.watch(actingProfileIdProvider);
  if (scope.isShared) ref.watch(activeSpaceMembersProvider);
  return ref.watch(expenseSearchRepositoryProvider).merchants(scope, actor);
});
final expenseSearchResultsProvider = Provider<AsyncValue<List<Expense>>>((ref) {
  final rows = ref.watch(expenseSearchRowsProvider);
  final merchants = ref.watch(expenseSearchMerchantsProvider);
  if (merchants.hasError) {
    return AsyncValue.error(
        merchants.error!, merchants.stackTrace ?? StackTrace.current);
  }
  if (merchants.isLoading || rows.isLoading || !merchants.hasValue) {
    return const AsyncValue.loading();
  }
  final state = ref.watch(expenseSearchStateProvider);
  final month = ref.watch(budgetContextProvider).yearMonth;
  return rows.whenData((list) => const SearchService().searchExpenses(
          state.savedBatch == null
              ? list
              : list
                  .where((e) => state.savedBatch!.contains(e.syncGuid))
                  .toList(),
          state.query,
          state.filters,
          month,
          merchantAliases: {
            for (final m in merchants.requireValue)
              m.syncGuid: [m.canonicalName, ...m.aliases]
          }));
});

final expenseSearchProfileNamesProvider =
    FutureProvider.autoDispose<Map<String, String>>((ref) async {
  final scope = ref.watch(budgetContextProvider);
  final actor = ref.watch(actingProfileIdProvider);
  ref.watch(expenseSearchRowsProvider);
  final repo = ref.watch(expenseSearchRepositoryProvider);
  await repo.authorize(scope, actor);
  final names = <String, String>{
    'main': 'Main',
    'unresolved': 'Needs profile review'
  };
  final budget = await (scope.isShared
          ? repo.db.budgetProfiles.filter().sharedSpaceIdEqualTo(scope.spaceId)
          : repo.db.budgetProfiles
              .filter()
              .sharedSpaceIdIsNull()
              .profileIdEqualTo(scope.profileId))
      .findAll();
  final direct = await (scope.isShared
          ? repo.db.directExpenseProfiles
              .filter()
              .sharedSpaceIdEqualTo(scope.spaceId)
          : repo.db.directExpenseProfiles
              .filter()
              .sharedSpaceIdIsNull()
              .profileIdEqualTo(scope.profileId))
      .findAll();
  for (final p in budget) {
    names['budget:${p.syncGuid}:${p.yearMonth}'] =
        '${p.name} (Budget, ${p.yearMonth})';
    names['budget:local:${p.id}:${p.yearMonth}'] =
        '${p.name} (Budget, ${p.yearMonth})';
  }
  for (final p in direct) {
    names['direct:${p.syncGuid}:${p.yearMonth}'] =
        '${p.name} (Direct, ${p.yearMonth})';
    names['direct:local:${p.id}:${p.yearMonth}'] =
        '${p.name} (Direct, ${p.yearMonth})';
  }
  return names;
});
