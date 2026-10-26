import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/transfer.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../repositories/transfer_repository.dart';

final transfersProvider = StreamProvider<List<Transfer>>((ref) {
  final context = ref.watch(budgetContextProvider);
  final repo = ref.watch(transferRepositoryProvider);
  if (context.isShared) {
    return repo.watchAll(
        sharedSpaceId: context.spaceId, yearMonth: context.yearMonth);
  }
  return repo.watchAll(
      profileId: context.profileId, yearMonth: context.yearMonth);
});

final transferActionsProvider = Provider<TransferActions>((ref) {
  return TransferActions(ref);
});

class TransferActions {
  final Ref _ref;
  TransferActions(this._ref);

  Future<void> save(Transfer transfer) async {
    final context = _ref.read(budgetContextProvider);
    if (context.isShared) {
      transfer.sharedSpaceId = context.spaceId;
      transfer.profileId = null;
    } else {
      transfer.profileId = context.profileId;
      transfer.sharedSpaceId = null;
    }
    transfer.yearMonth = context.yearMonth;
    await _ref.read(transferRepositoryProvider).save(transfer);
  }

  /// Saves a transfer and records it in the audit log (T046, FR-021).
  Future<void> saveWithAudit(
    Transfer transfer, {
    required String sourceName,
    required String destinationName,
  }) async {
    final context = _ref.read(budgetContextProvider);
    transfer
      ..sharedSpaceId = context.spaceId
      ..profileId = context.isShared ? null : context.profileId
      ..yearMonth = context.yearMonth;
    await _ref.read(transferRepositoryProvider).apply(transfer);
  }
}
