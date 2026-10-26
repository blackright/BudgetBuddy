import 'package:isar/isar.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/merchant.dart';
import '../../../core/models/shared_space.dart';
import '../../../core/services/audit_hash_service.dart';
import '../../../core/services/merchant_service.dart';
import '../../finance/repositories/audit_repository.dart';
import '../../sync/repositories/sync_recorder.dart';

/// Called in the expense's write transaction, so a new merchant cannot outlive
/// a failed expense/audit save. Context identity always comes from that expense.
class MerchantRepository {
  MerchantRepository(this.db, {this.recorder, this.actorId});
  final Isar db;
  final SyncRecorder? recorder;
  final int? actorId;

  Future<void> bindExpenseInTxn(Expense expense) async {
    expense.tags = normalizeExpenseTags(expense.tags);
    if (expense.tags.length > 30 || expense.tags.any((t) => t.length > 80)) {
      throw ArgumentError('Use at most 30 tags of 80 characters each.');
    }
    if (expense.paymentMethod != null &&
        !expensePaymentMethods.containsKey(expense.paymentMethod)) {
      // Preserve unknown values received from a future peer until edited.
      if (expense.paymentMethod!.length > 80) {
        throw ArgumentError('Invalid payment method.');
      }
    }
    final name = merchantDisplayName(expense.merchantName ?? '');
    if (name.isEmpty) {
      return; // Unresolved references are retained, not guessed.
    }
    if (name.length > 200) throw ArgumentError('Merchant name is too long.');
    final key = merchantKey(name);
    final matches = (await (expense.sharedSpaceId != null
                ? db.merchants
                    .filter()
                    .sharedSpaceIdEqualTo(expense.sharedSpaceId)
                : db.merchants
                    .filter()
                    .sharedSpaceIdIsNull()
                    .profileIdEqualTo(expense.profileId))
            .findAll())
        .where((m) =>
            (expense.sharedSpaceId != null
                ? m.sharedSpaceId == expense.sharedSpaceId
                : m.sharedSpaceId == null &&
                    m.profileId == expense.profileId) &&
            [m.canonicalName, ...m.aliases].any((n) => merchantKey(n) == key))
        .toList()
      ..sort((a, b) => a.syncGuid.compareTo(b.syncGuid));
    final merchant = matches.isNotEmpty
        ? matches.first
        : (Merchant()
          ..profileId = expense.sharedSpaceId == null ? expense.profileId : null
          ..sharedSpaceId = expense.sharedSpaceId
          ..canonicalName = name
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now());
    if (matches.isEmpty) {
      // Peers creating the same normalized merchant offline choose the same
      // portable identity. Personal merchants remain in their owning profile.
      final context = expense.sharedSpaceId == null
          ? 'personal:${expense.profileId}'
          : (await db.sharedSpaces.get(expense.sharedSpaceId!))?.syncGuid;
      if (context == null || context.isEmpty) {
        throw StateError('Merchant owner is unavailable.');
      }
      final identity = const AuditHashService().canonicalEvidence({
        'shared': expense.sharedSpaceId != null,
        'context': context,
        'merchant': key,
      });
      merchant.syncGuid =
          'merchant:${const AuditHashService().computeHash(previousHash: '', canonical: identity)}';
      merchant.id =
          await AuditRepository(db, recorder: recorder, actorId: actorId).put(
              db.merchants, merchant,
              id: merchant.id, type: 'Merchant', derived: false);
      await recorder?.recordMerchant(merchant);
    }
    expense.merchantName = merchant.canonicalName;
    expense.merchantSyncGuid = merchant.syncGuid;
  }
}
