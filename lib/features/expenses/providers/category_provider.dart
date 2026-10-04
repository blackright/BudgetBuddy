import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../engine/providers.dart'; // To get the ISAR instance
import '../repositories/category_repository.dart';
import '../../../core/models/category.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return CategoryRepository(isar);
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  await repository.ensureDefaultCategory();
  return repository.getAllCategories();
});
