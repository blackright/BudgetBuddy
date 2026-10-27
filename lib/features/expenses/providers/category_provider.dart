import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_helper.dart'; // To get the ISAR instance
import '../repositories/category_repository.dart';
import '../../../core/models/category.dart';
import '../../budget_setup/providers/onboarding_rollout_provider.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final isar = IsarHelper.instance;
  return CategoryRepository(isar);
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  if (ref.watch(unifiedOnboardingEnabledProvider)) {
    return repository.getForUnifiedSetup();
  }
  await repository.ensureDefaultCategory();
  return repository.getAllCategories();
});
