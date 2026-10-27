import 'package:isar/isar.dart';
import '../../../core/models/category.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/app_settings.dart';

class CategoryRepository {
  final Isar isar;

  CategoryRepository(this.isar);

  List<Category> get _legacyDefaults => [
        Category(
            categoryId: Expense.defaultCategoryId,
            name: 'General',
            emoji: '📌',
            colorValue: 0xFF9E9E9E,
            isDefault: true),
        Category(
            categoryId: 'food',
            name: 'Food & Dining',
            emoji: '🍔',
            colorValue: 0xFFFF9800,
            isDefault: true),
        Category(
            categoryId: 'transport',
            name: 'Transportation',
            emoji: '🚗',
            colorValue: 0xFF2196F3,
            isDefault: true),
        Category(
            categoryId: 'utilities',
            name: 'Utilities',
            emoji: '💡',
            colorValue: 0xFFFFEB3B,
            isDefault: true),
        Category(
            categoryId: 'entertainment',
            name: 'Entertainment',
            emoji: '🍿',
            colorValue: 0xFF9C27B0,
            isDefault: true),
        Category(
            categoryId: 'health',
            name: 'Health & Medical',
            emoji: '💊',
            colorValue: 0xFFF44336,
            isDefault: true),
        Category(
            categoryId: 'shopping',
            name: 'Shopping',
            emoji: '🛍️',
            colorValue: 0xFFE91E63,
            isDefault: true),
      ];

  Future<void> ensureDefaultCategory() =>
      isar.writeTxn(() => _insertMissingInTxn(_legacyDefaults));

  Future<void> _insertMissingInTxn(List<Category> defaults) async {
    final existingIds = (await isar.categorys.where().findAll())
        .map((c) => c.categoryId)
        .toSet();
    final missing =
        defaults.where((c) => !existingIds.contains(c.categoryId)).toList();
    if (missing.isNotEmpty) {
      await isar.categorys.putAll(missing);
    }
  }

  /// Activated together with the new form, never by the current live path.
  Future<List<Category>> getForUnifiedSetup() async {
    final marker = (await isar.appSettings.get(1))?.starterCategoryPolicy;
    if (marker == null ||
        marker == StarterCategoryPolicy.preserveExisting.name) {
      await ensureDefaultCategory();
    }
    // Pending/seeded/future policies cannot cause a lazy legacy seed.
    return getAllCategories();
  }

  /// Caller owns the setup transaction. Custom labels and IDs win over defaults.
  Future<bool> seedUnifiedStarterInTxn() async {
    final settings = await isar.appSettings.get(1);
    if (settings?.starterCategoryPolicy !=
        StarterCategoryPolicy.unifiedPending.name) {
      return false;
    }
    await _insertMissingInTxn([
      ..._legacyDefaults,
      Category(
          categoryId: 'housing',
          name: 'Housing',
          emoji: '\u{1f3e0}',
          colorValue: 0xFF607D8B,
          isDefault: true),
      Category(
          categoryId: 'insurance',
          name: 'Insurance',
          emoji: '\u{1f6e1}',
          colorValue: 0xFF00897B,
          isDefault: true),
      Category(
          categoryId: 'subscriptions',
          name: 'Subscriptions',
          emoji: '\u{1f501}',
          colorValue: 0xFF7E57C2,
          isDefault: true),
      Category(
          categoryId: 'miscellaneous',
          name: 'Miscellaneous',
          emoji: '\u{1f4e6}',
          colorValue: 0xFF78909C,
          isDefault: true),
    ]);
    settings!.starterCategoryPolicy = StarterCategoryPolicy.unifiedSeeded.name;
    settings.updatedAt = DateTime.now();
    await isar.appSettings.put(settings);
    return true;
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
