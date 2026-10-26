import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/category.dart';
import '../../engine/providers/true_available_provider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final activeCategoryIdFilterProvider = StateProvider<String?>((ref) => null);
final activeCategoryFilterProvider = StateProvider<Category?>((ref) => null);
final activeStatusFilterProvider = StateProvider<ExpenseStatus?>((ref) => null);
final activeGuiltLevelFilterProvider =
    StateProvider<GuiltLevel?>((ref) => null);

final filteredExpensesProvider = Provider<AsyncValue<List<Expense>>>((ref) {
  final expenses = ref.watch(monthlyExpensesProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final activeCategoryId = ref.watch(activeCategoryIdFilterProvider);
  final activeCategory = ref.watch(activeCategoryFilterProvider);
  final activeStatus = ref.watch(activeStatusFilterProvider);
  final activeGuilt = ref.watch(activeGuiltLevelFilterProvider);

  return expenses.whenData((list) {
    final filtered = list.where((e) {
      if (searchQuery.isNotEmpty &&
          !e.title.toLowerCase().contains(searchQuery)) {
        return false;
      }
      final categoryId = activeCategory?.categoryId ?? activeCategoryId;
      if (categoryId != null && e.categoryId != categoryId) {
        return false;
      }
      if (activeStatus != null && e.status != activeStatus) {
        return false;
      }
      if (activeGuilt != null && e.guiltLevel != activeGuilt) {
        return false;
      }
      return true;
    }).toList();
    // Sort a copy for presentation; never reorder the engine's source list.
    // Expense has no createdAt field. Local IDs break same-date ties in the
    // order rows were added on this device, including imported records.
    filtered.sort((a, b) {
      final date = b.date.compareTo(a.date);
      if (date != 0) return date;
      final added = b.id.compareTo(a.id);
      return added != 0 ? added : b.syncGuid.compareTo(a.syncGuid);
    });
    return filtered;
  });
});
