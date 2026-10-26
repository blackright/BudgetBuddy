import '../../../core/models/app_settings.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/shared_space.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/services/free_funds.dart';
import '../../../core/services/audit_financial_state.dart';
import '../../../core/models/budget_profile.dart';
import '../../../core/services/transfer_service.dart';
import '../../spaces/repositories/space_write_guard.dart';
import 'audit_repository.dart';
import '../../sync/repositories/sync_recorder.dart';
import '../../sync/providers/sync_recorder_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/transfer.dart';

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  return TransferRepository(IsarHelper.instance,
      recorder: ref.watch(syncRecorderProvider),
      actorId: ref.watch(actingProfileIdProvider));
});

class TransferRepository {
  final Isar _isar;

  TransferRepository(this._isar, {this.recorder, this.actorId});
  final SyncRecorder? recorder;
  final int? actorId;
  AuditRepository get audit =>
      AuditRepository(_isar, recorder: recorder, actorId: actorId);

  Stream<List<Transfer>> watchAll(
      {int? profileId, int? sharedSpaceId, String? yearMonth}) {
    if (profileId != null) {
      var q = _isar.transfers.filter().profileIdEqualTo(profileId);
      if (yearMonth != null) q = q.and().yearMonthEqualTo(yearMonth);
      return q.watch(fireImmediately: true);
    }
    if (sharedSpaceId != null) {
      var q = _isar.transfers.filter().sharedSpaceIdEqualTo(sharedSpaceId);
      if (yearMonth != null) q = q.and().yearMonthEqualTo(yearMonth);
      return q.watch(fireImmediately: true);
    }
    return _isar.transfers.where().watch(fireImmediately: true);
  }

  Future<void> save(Transfer transfer) async {
    final now = DateTime.now();
    transfer.createdAt = now;
    if (transfer.date.millisecondsSinceEpoch == 0) {
      transfer.date = now;
    }
    await _isar.writeTxn(() async {
      transfer.id = await audit.put(_isar.transfers, transfer,
          id: transfer.id, type: 'Transfer');
    });
  }

  /// Both allocation legs, immutable transfer and audit commit together.
  Future<void> apply(Transfer transfer) => _isar.writeTxn(() async {
        final prior = await _isar.transfers
            .filter()
            .syncGuidEqualTo(transfer.syncGuid)
            .findFirst();
        if (prior != null) {
          if (prior.sourceProfileId != transfer.sourceProfileId ||
              prior.destinationProfileId != transfer.destinationProfileId ||
              prior.amount != transfer.amount ||
              prior.currency != transfer.currency ||
              prior.yearMonth != transfer.yearMonth ||
              prior.profileId != transfer.profileId ||
              prior.sharedSpaceId != transfer.sharedSpaceId ||
              prior.reason != transfer.reason) {
            throw StateError('Conflicting transfer retry.');
          }
          return;
        }
        if ((await _isar.appSettings.where().findFirst())?.transferToggle !=
            true) {
          throw StateError('Enable allocation transfers in Settings first.');
        }
        final currency = transfer.sharedSpaceId == null
            ? (await _isar.userProfiles.get(transfer.profileId!))
                ?.primaryCurrency
                .code
            : (await _isar.sharedSpaces.get(transfer.sharedSpaceId!))
                ?.currency
                .code;
        if (currency == null ||
            CurrencyCode.tryParse(transfer.currency) != currency) {
          throw StateError('The accounting currency changed. Review again.');
        }

        final source = await _isar.budgetProfiles.get(transfer.sourceProfileId);
        final target =
            await _isar.budgetProfiles.get(transfer.destinationProfileId);
        if (source == null ||
            target == null ||
            source.yearMonth != transfer.yearMonth ||
            target.yearMonth != transfer.yearMonth ||
            source.profileId != transfer.profileId ||
            target.profileId != transfer.profileId ||
            source.sharedSpaceId != transfer.sharedSpaceId ||
            target.sharedSpaceId != transfer.sharedSpaceId) {
          throw StateError('Transfer profiles changed. Review again.');
        }
        await SpaceWriteGuard(_isar).assertSharedMoneyWrite(
            sharedSpaceId: transfer.sharedSpaceId,
            actingProfileId: actorId,
            yearMonth: transfer.yearMonth);
        const service = TransferService();
        final refusal = service.refusalReason(
            source: source, destination: target, amount: transfer.amount);
        if (refusal != null) throw StateError(refusal);
        final scope = AuditFinancialScope(
            source.profileId, source.sharedSpaceId, source.yearMonth);
        final financialBefore = await auditFinancialState(_isar, scope);
        sumFinancialMinor([source.allocation, -transfer.amount]);
        sumFinancialMinor([target.allocation, transfer.amount]);
        service.apply(source, target, transfer.amount);
        await audit.put(_isar.budgetProfiles, source,
            id: source.id, type: 'BudgetProfile', derived: false);
        await audit.put(_isar.budgetProfiles, target,
            id: target.id, type: 'BudgetProfile', derived: false);
        await recorder?.recordBudgetProfile(source);
        await recorder?.recordBudgetProfile(target);
        transfer.id = await audit.put(_isar.transfers, transfer,
            id: transfer.id, type: 'Transfer');
        await audit.recordDerived(
            scope, financialBefore, await auditFinancialState(_isar, scope));
      });

  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      await audit.remove(_isar.transfers, id, type: 'Transfer');
    });
  }
}
