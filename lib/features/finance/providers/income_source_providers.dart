import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/income_source.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../repositories/income_source_repository.dart';

final incomeSourcesProvider = StreamProvider<List<IncomeSource>>((ref) {
  final context = ref.watch(budgetContextProvider);
  final repo = ref.watch(incomeSourceRepositoryProvider);
  if (context.isShared) {
    return repo.watchAll(sharedSpaceId: context.spaceId);
  }
  return repo.watchAll(profileId: context.profileId);
});

final incomeSourceActionsProvider = Provider<IncomeSourceActions>((ref) {
  return IncomeSourceActions(ref);
});

class IncomeSourceActions {
  final Ref _ref;
  IncomeSourceActions(this._ref);

  Future<void> save(IncomeSource source) async {
    final context = _ref.read(budgetContextProvider);
    if (context.isShared) {
      source.sharedSpaceId = context.spaceId;
      source.profileId = null;
    } else {
      source.profileId = context.profileId;
      source.sharedSpaceId = null;
    }
    await _ref.read(incomeSourceRepositoryProvider).save(source);
  }

  Future<void> delete(int id) async {
    await _ref.read(incomeSourceRepositoryProvider).delete(id);
  }
}
