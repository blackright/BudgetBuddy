import 'package:isar/isar.dart';
import '../../../core/models/category.dart';

class CategoryRepository {
  final Isar isar;

  CategoryRepository(this.isar);

  Future<void> ensureDefaultCategory() async {
    final existing = await isar.categorys.where().categoryIdEqualTo(Expense.defaultCategoryId).findFirst();
    if (existing == null) {
      final defaultCategory = Category(
        categoryId: Expense.defaultCategoryId,
        name: 'General',
        emoji: '📌',
        colorValue: 0xFF9E9E9E,
        isDefault: true,
      );
      await isar.writeTxn(() async {
        await isar.categorys.put(defaultCategory);
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
