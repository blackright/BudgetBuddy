import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_helper.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/services/refund_service.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../engine/providers/true_available_provider.dart';
import '../../finance/providers/profile_providers.dart';
import '../../finance/providers/finance_providers.dart';
import '../../sync/providers/sync_recorder_provider.dart';
import 'reimbursement_provider.dart';

final refundServiceProvider = Provider<RefundService>((ref) {
  final actor = ref.watch(actingProfileIdProvider);
  if (actor == null) {
    throw const RefundException('Select an acting profile first.');
  }
  return RefundService(IsarHelper.instance,
      context: ref.watch(budgetContextProvider),
      actingProfileId: actor,
      rates: ref.watch(rateRegistryProvider),
      syncRecorder: ref.watch(syncRecorderProvider));
});

/// Requotes when money, the active context, or applicable rates change. Save
/// always reloads the database too; this value is never a write authorization.
final refundQuoteProvider =
    FutureProvider.autoDispose.family<RefundQuote, int>((ref, id) {
  ref.watch(reimbursementsByExpenseProvider(id));
  ref.watch(monthlyExpensesProvider);
  ref.watch(monthlyReimbursementsProvider);
  ref.watch(budgetProfilesProvider);
  ref.watch(directExpenseProfilesProvider);
  ref.watch(resolvedIncomeProvider);
  return ref.watch(refundServiceProvider).quote(id);
});
