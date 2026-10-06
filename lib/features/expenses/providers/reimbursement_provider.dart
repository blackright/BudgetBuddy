import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_helper.dart';
import '../models/reimbursement.dart';
import '../repositories/reimbursement_repository.dart';

final reimbursementRepositoryProvider =
    Provider<ReimbursementRepository>((ref) {
  return ReimbursementRepository(IsarHelper.instance);
});

final reimbursementsByExpenseProvider =
    StreamProvider.family<List<Reimbursement>, int>((ref, expenseId) {
  final repository = ref.watch(reimbursementRepositoryProvider);
  return repository.watchReimbursementsForExpense(expenseId);
});

final reimbursementsByMonthProvider =
    StreamProvider.family<List<Reimbursement>, String>((ref, yearMonth) {
  final repository = ref.watch(reimbursementRepositoryProvider);
  return repository.watchReimbursementsForMonth(yearMonth);
});
