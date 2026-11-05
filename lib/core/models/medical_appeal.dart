import 'package:isar/isar.dart';

import '../../features/sync/domain/sync_guid.dart';

part 'medical_appeal.g.dart';

/// One repeatable insurance appeal attempt.
///
/// Appeals are history records, not renamed statuses: a rejected appeal can be
/// followed by another appeal, and the request status points at the latest one.
@collection
class MedicalAppeal {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String syncGuid = newSyncGuid();

  @Index()
  late String billGuid;

  /// Owning personal profile, or null for a shared-space appeal.
  @Index()
  int? profileId;

  /// Owning shared space, or null for a personal appeal.
  @Index()
  int? sharedSpaceId;

  late DateTime submittedAt;

  String? reference;

  DateTime? expectedResponseAt;

  String notes = '';

  List<String> documentPaths = [];

  @enumerated
  MedicalAppealOutcome outcome = MedicalAppealOutcome.pending;

  DateTime? decidedAt;

  late DateTime recordedAt;

  late int actorId;

  @Index(unique: true)
  late String operationIdentity;
}

enum MedicalAppealOutcome { pending, approved, rejected }
