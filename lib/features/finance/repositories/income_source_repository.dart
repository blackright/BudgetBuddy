import 'audit_repository.dart';
import '../../sync/repositories/sync_recorder.dart';
import '../../sync/providers/sync_recorder_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/income_source.dart';

final incomeSourceRepositoryProvider = Provider<IncomeSourceRepository>((ref) {
  return IncomeSourceRepository(IsarHelper.instance,
      recorder: ref.watch(syncRecorderProvider),
      actorId: ref.watch(actingProfileIdProvider));
});

class IncomeSourceRepository {
  final Isar _isar;

  IncomeSourceRepository(this._isar, {this.recorder, this.actorId});
  final SyncRecorder? recorder;
  final int? actorId;
  AuditRepository get audit =>
      AuditRepository(_isar, recorder: recorder, actorId: actorId);

  Future<List<IncomeSource>> getAll(
      {int? profileId, int? sharedSpaceId}) async {
    if (profileId != null) {
      return _isar.incomeSources.filter().profileIdEqualTo(profileId).findAll();
    }
    if (sharedSpaceId != null) {
      return _isar.incomeSources
          .filter()
          .sharedSpaceIdEqualTo(sharedSpaceId)
          .findAll();
    }
    return _isar.incomeSources.where().findAll();
  }

  Stream<List<IncomeSource>> watchAll({int? profileId, int? sharedSpaceId}) {
    if (profileId != null) {
      return _isar.incomeSources
          .filter()
          .profileIdEqualTo(profileId)
          .watch(fireImmediately: true);
    }
    if (sharedSpaceId != null) {
      return _isar.incomeSources
          .filter()
          .sharedSpaceIdEqualTo(sharedSpaceId)
          .watch(fireImmediately: true);
    }
    return _isar.incomeSources.where().watch(fireImmediately: true);
  }

  Future<void> save(IncomeSource source) async {
    final now = DateTime.now();
    source.updatedAt = now;
    if (source.createdAt.millisecondsSinceEpoch == 0) {
      source.createdAt = now;
    }
    await _isar.writeTxn(() async {
      source.id = await audit.put(_isar.incomeSources, source,
          id: source.id, type: 'IncomeSource');
    });
  }

  Future<void> delete(int id) => _isar.writeTxn(() async {
        await audit.remove(_isar.incomeSources, id, type: 'IncomeSource');
      });
}
