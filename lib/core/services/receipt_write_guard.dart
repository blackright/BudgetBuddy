import 'package:isar/isar.dart';

import '../models/reconciliation_snapshot.dart';
import '../models/shared_member.dart';
import '../../features/spaces/repositories/space_write_guard.dart';
import 'receipt_snapshot_repository.dart';

/// Unwired transactional foundation. Trusted future coordinators provide the
/// required financial + audit writes; the guard never invents those operations.
/// Its callback must not start another transaction or perform network/native UI.
class ReceiptWriteGuard {
  ReceiptWriteGuard(this.snapshots);
  final ReceiptSnapshotRepository snapshots;
  Isar get _db => snapshots.db;

  Future<T> run<T>({
    required List<ReceiptSourceSnapshot> previews,
    required int actorId,
    required bool Function() isAccessCurrent,
    required Future<T> Function() write,
  }) {
    if (previews.isEmpty) throw const ReceiptGuardException('missingPreview');
    final reviewed = List<ReceiptSourceSnapshot>.unmodifiable(previews);
    final first = reviewed.first.context;
    final months = <String>{};
    for (final preview in reviewed) {
      if (preview.actorId != actorId ||
          preview.context.profileId != first.profileId ||
          preview.context.spaceId != first.spaceId ||
          !months.add(preview.context.yearMonth)) {
        throw const ReceiptGuardException('invalidPreviewScope');
      }
    }
    return _db.writeTxn(() async {
      for (final preview in reviewed) {
        await _verify(preview, actorId, isAccessCurrent,
            checkFingerprint: true);
      }
      final result = await write();
      // Access can change while the callback awaits: fail inside the same
      // transaction so the proposed financial write rolls back as well.
      for (final preview in reviewed) {
        await _verify(preview, actorId, isAccessCurrent,
            checkFingerprint: false);
      }
      return result;
    });
  }

  Future<void> _verify(ReceiptSourceSnapshot preview, int actorId,
      bool Function() isAccessCurrent,
      {required bool checkFingerprint}) async {
    final current = await snapshots.readInTransaction(
      context: preview.context,
      actorId: actorId,
      isAccessCurrent: isAccessCurrent,
    );
    if (current.blockers.isNotEmpty) {
      throw ReceiptGuardException(current.blockers.first.name);
    }
    if (preview.context.isShared) {
      final member = await SpaceWriteGuard(_db)
          .memberOf(preview.context.spaceId!, actorId);
      if (member == null ||
          member.revokedAt != null ||
          member.role == SharedMemberRole.viewer) {
        throw const ReceiptGuardException('writeNotPermitted');
      }
    }
    if (checkFingerprint && current.fingerprint != preview.fingerprint) {
      throw const ReceiptGuardException('stalePreview');
    }
  }
}
