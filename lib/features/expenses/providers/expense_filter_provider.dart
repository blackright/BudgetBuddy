import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/category.dart';
import '../../engine/providers/true_available_provider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final activeCategoryFilterProvider = StateProvider<Category?>((ref) => null);
final activeStatusFilterProvider = StateProvider<ExpenseStatus?>((ref) => null);
final activeGuiltLevelFilterProvider = StateProvider<GuiltLevel?>((ref) => null);

final filteredExpensesProvider = Provider<AsyncValue<List<Expense>>>((ref) {
  final expenses = ref.watch(monthlyExpensesProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final activeCategory = ref.watch(activeCategoryFilterProvider);
  final activeStatus = ref.watch(activeStatusFilterProvider);
  final activeGuilt = ref.watch(activeGuiltLevelFilterProvider);

  return expenses.whenData((list) {
    return list.where((e) {
      if (searchQuery.isNotEmpty && !e.title.toLowerCase().contains(searchQuery)) return false;
      if (activeCategory != null && e.categoryId != activeCategory.categoryId) return false;
      if (activeStatus != null && e.status != activeStatus) return false;
      if (activeGuilt != null && e.guiltLevel != activeGuilt) return false;
      return true;
    }).toList();
  });
});
