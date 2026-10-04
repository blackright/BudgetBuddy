import 'package:isar/isar.dart';
import '../../../core/models/category.dart';
import '../../../core/models/expense.dart';

class CategoryRepository {
  final Isar isar;

  CategoryRepository(this.isar);

  Future<void> ensureDefaultCategory() async {
    final defaultCategories = [
      Category(categoryId: Expense.defaultCategoryId, name: 'General', emoji: '📌', colorValue: 0xFF9E9E9E, isDefault: true),
      Category(categoryId: 'food', name: 'Food & Dining', emoji: '🍔', colorValue: 0xFFFF9800, isDefault: true),
      Category(categoryId: 'transport', name: 'Transportation', emoji: '🚗', colorValue: 0xFF2196F3, isDefault: true),
      Category(categoryId: 'utilities', name: 'Utilities', emoji: '💡', colorValue: 0xFFFFEB3B, isDefault: true),
      Category(categoryId: 'entertainment', name: 'Entertainment', emoji: '🍿', colorValue: 0xFF9C27B0, isDefault: true),
      Category(categoryId: 'health', name: 'Health & Medical', emoji: '💊', colorValue: 0xFFF44336, isDefault: true),
      Category(categoryId: 'shopping', name: 'Shopping', emoji: '🛍️', colorValue: 0xFFE91E63, isDefault: true),
    ];

    final existingIds = (await isar.categorys.where().findAll()).map((c) => c.categoryId).toSet();
    final toAdd = defaultCategories.where((c) => !existingIds.contains(c.categoryId)).toList();

    if (toAdd.isNotEmpty) {
      await isar.writeTxn(() async {
        await isar.categorys.putAll(toAdd);
      });
    }
  }

  Future<List<Category>> getAllCategories() async {
    return await isar.categorys.where().findAll();
  }

  Future<void> saveCategory(Category category) async {
    await isar.writeTxn(() async {
      await isar.categorys.put(category);
    });
  }

  Future<void> deleteCategory(Id id) async {
    await isar.writeTxn(() async {
      await isar.categorys.delete(id);
    });
  }
}
