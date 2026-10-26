import 'audit_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/budget_profile.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../spaces/repositories/space_write_guard.dart';
import '../../sync/repositories/sync_recorder.dart';
import '../../sync/providers/sync_recorder_provider.dart';

final budgetProfileRepositoryProvider =
    Provider<BudgetProfileRepository>((ref) {
  return BudgetProfileRepository(IsarHelper.instance,
      guard: ref.watch(spaceWriteGuardProvider),
      actorId: ref.watch(actingProfileIdProvider),
      recorder: ref.watch(syncRecorderProvider));
});

class BudgetProfileRepository {
  final Isar _isar;

  BudgetProfileRepository(this._isar,
      {this.guard, this.actorId, this.recorder});
  final SpaceWriteGuard? guard;
  final int? actorId;
  final SyncRecorder? recorder;

  Future<List<BudgetProfile>> getAll(
      {int? profileId, int? sharedSpaceId, String? yearMonth}) async {
    if (profileId != null) {
      var q = _isar.budgetProfiles.filter().profileIdEqualTo(profileId);
      if (yearMonth != null) q = q.and().yearMonthEqualTo(yearMonth);
      return q.findAll();
    }
    if (sharedSpaceId != null) {
      var q = _isar.budgetProfiles.filter().sharedSpaceIdEqualTo(sharedSpaceId);
      if (yearMonth != null) q = q.and().yearMonthEqualTo(yearMonth);
      return q.findAll();
    }
    return _isar.budgetProfiles.where().findAll();
  }

  Stream<List<BudgetProfile>> watchAll(
      {int? profileId, int? sharedSpaceId, String? yearMonth}) {
    if (profileId != null) {
      var q = _isar.budgetProfiles.filter().profileIdEqualTo(profileId);
      if (yearMonth != null) q = q.and().yearMonthEqualTo(yearMonth);
      return q.watch(fireImmediately: true);
    }
    if (sharedSpaceId != null) {
      var q = _isar.budgetProfiles.filter().sharedSpaceIdEqualTo(sharedSpaceId);
      if (yearMonth != null) q = q.and().yearMonthEqualTo(yearMonth);
      return q.watch(fireImmediately: true);
    }
    return _isar.budgetProfiles.where().watch(fireImmediately: true);
  }

  Future<void> save(BudgetProfile profile) async {
    await guard?.assertSharedMoneyWrite(
        sharedSpaceId: profile.sharedSpaceId,
        actingProfileId: actorId,
        yearMonth: profile.yearMonth);
    final now = DateTime.now();
    profile.updatedAt = now;
    if (profile.createdAt.millisecondsSinceEpoch == 0) {
      profile.createdAt = now;
    }
    await _isar.writeTxn(() async {
      profile.id =
          await AuditRepository(_isar, recorder: recorder, actorId: actorId)
              .put(_isar.budgetProfiles, profile,
                  id: profile.id, type: 'BudgetProfile');
      await recorder?.recordBudgetProfile(profile);
    });
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      await AuditRepository(_isar, recorder: recorder, actorId: actorId)
          .remove(_isar.budgetProfiles, id, type: 'BudgetProfile');
    });
  }
}
