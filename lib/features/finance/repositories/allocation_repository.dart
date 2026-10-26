import 'audit_repository.dart';
import '../../sync/repositories/sync_recorder.dart';
import '../../sync/providers/sync_recorder_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/allocation.dart';

final allocationRepositoryProvider = Provider<AllocationRepository>((ref) {
  return AllocationRepository(IsarHelper.instance,
      recorder: ref.watch(syncRecorderProvider),
      actorId: ref.watch(actingProfileIdProvider));
});

class AllocationRepository {
  final Isar _isar;

  AllocationRepository(this._isar, {this.recorder, this.actorId});
  final SyncRecorder? recorder;
  final int? actorId;
  AuditRepository get audit =>
      AuditRepository(_isar, recorder: recorder, actorId: actorId);

  Stream<List<Allocation>> watchAll(
      {int? profileId, int? sharedSpaceId, String? yearMonth}) {
    if (profileId != null) {
      var q = _isar.allocations.filter().profileIdEqualTo(profileId);
      if (yearMonth != null) q = q.and().yearMonthEqualTo(yearMonth);
      return q.watch(fireImmediately: true);
    }
    if (sharedSpaceId != null) {
      var q = _isar.allocations.filter().sharedSpaceIdEqualTo(sharedSpaceId);
      if (yearMonth != null) q = q.and().yearMonthEqualTo(yearMonth);
      return q.watch(fireImmediately: true);
    }
    return _isar.allocations.where().watch(fireImmediately: true);
  }

  Future<void> save(Allocation allocation) async {
    final now = DateTime.now();
    allocation.createdAt = now;
    await _isar.writeTxn(() async {
      allocation.id = await audit.put(_isar.allocations, allocation,
          id: allocation.id, type: 'Allocation');
    });
  }
}
