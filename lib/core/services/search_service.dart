import '../models/expense.dart';
import 'filter_service.dart';

/// Literal partial words, all required across any supported business fields.
/// Receives only authorized rows from the search repository.
class SearchService {
  const SearchService();
  List<Expense> searchExpenses(
      List<Expense> rows, String query, ExpenseFilters filters, String month,
      {Map<String, List<String>> merchantAliases = const {}}) {
    final words = query
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    final result = rows.where((e) {
      if (!const FilterService().matches(e, filters, month)) return false;
      final fields = [
        e.title,
        e.notes ?? '',
        e.merchantName ?? '',
        ...e.tags,
        ...(merchantAliases[e.merchantSyncGuid] ?? <String>[])
      ].map((s) => s.toLowerCase()).toList();
      return words.every((word) => fields.any((field) => field.contains(word)));
    }).toList();
    result.sort((a, b) {
      final date = b.date.compareTo(a.date);
      if (date != 0) return date;
      final id = b.id.compareTo(a.id);
      return id != 0 ? id : b.syncGuid.compareTo(a.syncGuid);
    });
    return result;
  }
}
