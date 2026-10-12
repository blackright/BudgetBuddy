import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_helper.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../spaces/repositories/space_write_guard.dart';
import '../models/reimbursement.dart';
import '../repositories/reimbursement_repository.dart';

final reimbursementRepositoryProvider =
    Provider<ReimbursementRepository>((ref) {
  return ReimbursementRepository(
    IsarHelper.instance,
    guard: ref.watch(spaceWriteGuardProvider),
    actingProfileId: ref.watch(actingProfileIdProvider),
  );
});

final reimbursementsByExpenseProvider =
    StreamProvider.family<List<Reimbursement>, int>((ref, expenseId) {
  final repository = ref.watch(reimbursementRepositoryProvider);
  return repository.watchReimbursementsForExpense(expenseId);
});

/// Reimbursements that belong to the active context's month (FR-004, R3).
final reimbursementsByMonthProvider =
    StreamProvider<List<Reimbursement>>((ref) {
  final context = ref.watch(budgetContextProvider);
  final repository = ref.watch(reimbursementRepositoryProvider);
  return repository.watchReimbursementsForContext(context);
});
