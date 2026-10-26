import 'package:isar/isar.dart';
import '../models/financial_report.dart';
import '../models/user_profile.dart';
import '../models/shared_space.dart';
import '../models/shared_member.dart';
import '../models/lock_setting.dart';
import '../../features/security/domain/lock_subject.dart';

class ReportOwnerChoice {
  const ReportOwnerChoice(this.owner, this.name,
      {required this.locked, required this.canExport});
  final ReportOwner owner;
  final String name;
  final bool locked, canExport;
}

/// UI session callback is checked alongside persisted membership/lock policy.
/// It never releases keys, changes active context or creates a new permission.
class ReportAccess {
  ReportAccess(this.db,
      {required this.isUnlocked, required this.assertSession});
  final Isar db;
  final bool Function(String subjectKey) isUnlocked;
  final void Function() assertSession;

  Future<List<ReportOwnerChoice>> choices(int actor) async {
    assertSession();
    final profile = await db.userProfiles.get(actor);
    if (profile == null) {
      throw StateError('Select an available personal profile.');
    }
    final result = <ReportOwnerChoice>[];
    final own = ReportOwner.personal(actor);
    result.add(ReportOwnerChoice(own, profile.name,
        locked: await _locked(own), canExport: true));
    final ids =
        (await db.sharedMembers.filter().profileIdEqualTo(actor).findAll())
            .where((m) => m.revokedAt == null)
            .map((m) => m.sharedSpaceId)
            .toSet();
    for (final id in ids) {
      final space = await db.sharedSpaces.get(id);
      if (space == null) continue;
      final members = (await db.sharedMembers
              .filter()
              .sharedSpaceIdEqualTo(id)
              .profileIdEqualTo(actor)
              .findAll())
          .where((m) => m.revokedAt == null)
          .toList();
      if (members.length != 1) continue;
      final owner = ReportOwner.space(id);
      result.add(ReportOwnerChoice(owner, space.name,
          locked: await _locked(owner),
          canExport: members.single.role != SharedMemberRole.viewer));
    }
    return List.unmodifiable(result);
  }

  Future<bool> _locked(ReportOwner owner) async {
    final space = owner.shared ? await db.sharedSpaces.get(owner.id) : null;
    final key = owner.shared
        ? LockSubject.spaceKey(space!.syncGuid)
        : LockSubject.profileKey(owner.id);
    final setting =
        await db.lockSettings.filter().subjectKeyEqualTo(key).findFirst();
    return ((setting?.lockEnabled ?? false) || (space?.requirePin ?? false)) &&
        !isUnlocked(key);
  }

  Future<bool> authorize(ReportRequest request, int actor,
      {bool exporting = false}) async {
    assertSession();
    if (actor != request.personalProfileId) {
      throw StateError('The acting profile changed. Generate a new report.');
    }
    final permitted = await choices(actor);
    var canExport = true;
    for (final owner in request.owners) {
      final choice = permitted.where((c) => c.owner == owner).firstOrNull;
      if (choice == null) {
        throw StateError(
            'A selected context is no longer permitted. Generate a new report.');
      }
      if (choice.locked) {
        throw StateError(
            '${choice.name} is locked. Open and unlock that context to report on it. Protected inactive contexts cannot be included silently.');
      }
      canExport = canExport && choice.canExport;
      if (exporting && !choice.canExport) {
        throw StateError('Only Owners and Editors may export ${choice.name}.');
      }
    }
    assertSession();
    return canExport;
  }
}
