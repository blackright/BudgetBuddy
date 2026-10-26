import 'audit_repository.dart';
import '../../sync/repositories/sync_recorder.dart';
import '../../sync/providers/sync_recorder_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/direct_expense_profile.dart';

final directExpenseProfileRepositoryProvider =
    Provider<DirectExpenseProfileRepository>((ref) {
  return DirectExpenseProfileRepository(IsarHelper.instance,
      recorder: ref.watch(syncRecorderProvider),
      actorId: ref.watch(actingProfileIdProvider));
});

class DirectExpenseProfileRepository {
  final Isar _isar;

  DirectExpenseProfileRepository(this._isar, {this.recorder, this.actorId});
  final SyncRecorder? recorder;
  final int? actorId;
  AuditRepository get audit =>
      AuditRepository(_isar, recorder: recorder, actorId: actorId);

  Future<List<DirectExpenseProfile>> getAll(
      {int? profileId, int? sharedSpaceId, String? yearMonth}) async {
    if (profileId != null) {
      var q = _isar.directExpenseProfiles.filter().profileIdEqualTo(profileId);
      if (yearMonth != null) q = q.and().yearMonthEqualTo(yearMonth);
      return q.findAll();
    }
    if (sharedSpaceId != null) {
      var q = _isar.directExpenseProfiles
          .filter()
          .sharedSpaceIdEqualTo(sharedSpaceId);
      if (yearMonth != null) q = q.and().yearMonthEqualTo(yearMonth);
      return q.findAll();
    }
    return _isar.directExpenseProfiles.where().findAll();
  }

  Stream<List<DirectExpenseProfile>> watchAll(
      {int? profileId, int? sharedSpaceId, String? yearMonth}) {
    if (profileId != null) {
      var q = _isar.directExpenseProfiles.filter().profileIdEqualTo(profileId);
      if (yearMonth != null) q = q.and().yearMonthEqualTo(yearMonth);
      return q.watch(fireImmediately: true);
    }
    if (sharedSpaceId != null) {
      var q = _isar.directExpenseProfiles
          .filter()
          .sharedSpaceIdEqualTo(sharedSpaceId);
      if (yearMonth != null) q = q.and().yearMonthEqualTo(yearMonth);
      return q.watch(fireImmediately: true);
    }
    return _isar.directExpenseProfiles.where().watch(fireImmediately: true);
  }

  Future<void> save(DirectExpenseProfile profile) async {
    final now = DateTime.now();
    profile.updatedAt = now;
    if (profile.createdAt.millisecondsSinceEpoch == 0) {
      profile.createdAt = now;
    }
    await _isar.writeTxn(() async {
      profile.id = await audit.put(_isar.directExpenseProfiles, profile,
          id: profile.id, type: 'DirectExpenseProfile');
    });
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      await audit.remove(_isar.directExpenseProfiles, id,
          type: 'DirectExpenseProfile');
    });
  }
}
