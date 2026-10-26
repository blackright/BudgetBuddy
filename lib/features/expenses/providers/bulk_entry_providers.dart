import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/services/bulk_entry_service.dart';
import '../../spaces/providers/spaces_providers.dart';
import 'expenses_provider.dart';
import 'expense_search_provider.dart';

typedef BulkSubmit = Future<Map<String, String>> Function(
    List<BulkExpenseDraft> rows, ContextRef destination, int actor);

bool sameBulkContext(ContextRef a, ContextRef b) =>
    a.profileId == b.profileId &&
    a.spaceId == b.spaceId &&
    a.yearMonth == b.yearMonth;

final bulkSubmitProvider = Provider<BulkSubmit>((ref) {
  bool busy = false;
  return (rows, destination, actor) async {
    if (busy) throw StateError('A submission is already in progress.');
    void check() {
      if (!sameBulkContext(ref.read(budgetContextProvider), destination) ||
          ref.read(actingProfileIdProvider) != actor ||
          !ref.read(activeContextCanEditProvider)) {
        throw StateError(
            'The context or permission changed. Reopen Bulk Entry.');
      }
    }

    check();
    final budget = ref.read(activeBudgetProvider).valueOrNull;
    if (budget == null) throw StateError('This month is not available.');
    busy = true;
    try {
      final expenses = rows
          .map((row) => const BulkEntryService().expense(row,
              owner: destination.profileKey,
              space: destination.spaceId,
              month: destination.yearMonth,
              actor: actor,
              budget: budget.id))
          .toList();
      final errors = await ref
          .read(expensesProvider.notifier)
          .addBulkExpenses(expenses, destination, assertContext: check);
      // Refresh the providers read by Expenses after a successful commit.
      // Preserve normal search/filter selections until the user chooses View.
      if (errors.length < rows.length &&
          sameBulkContext(ref.read(budgetContextProvider), destination) &&
          ref.read(actingProfileIdProvider) == actor) {
        ref.invalidate(expenseSearchRowsProvider);
        ref.invalidate(expenseSearchMerchantsProvider);
        ref.invalidate(expenseSearchProfileNamesProvider);
      }
      for (final row in rows) {
        if (!errors.containsKey(row.guid)) await row.evidence.dispose();
      }
      return errors;
    } finally {
      busy = false;
    }
  };
});
