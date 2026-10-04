import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_helper.dart'; // To get the ISAR instance
import '../repositories/category_repository.dart';
import '../../../core/models/category.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final isar = IsarHelper.instance;
  return CategoryRepository(isar);
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  await repository.ensureDefaultCategory();
  return repository.getAllCategories();
});
