import 'package:isar/isar.dart';

import '../../features/security/domain/away_time.dart';
import '../../features/security/domain/lock_subject.dart';

part 'lock_setting.g.dart';

/// One subject's non-secret security setting (data-model §2, FR-032).
///
/// A **subject** is one personal profile or one shared space; there is exactly
/// one row per subject, keyed by [subjectKey] (`p<profileId>` or `s<syncGuid>`,
/// data-model §1). Everything here is non-secret and safe to stream into the UI.
///
/// What is deliberately *not* here: the PIN's verifier, its salt, its iteration
/// count and the lockout state. Those live in the OS secure storage
/// (`sec_pin_<subjectKey>` / `sec_lockout_<subjectKey>`) so the row can never
/// claim a PIN that is not there, and so a rooted device cannot reset the
/// failure count by editing the data store (FR-008, FR-014, research R1).
@collection
class LockSetting {
  Id id = Isar.autoIncrement;

  /// `p<profileId>` or `s<spaceSyncGuid>` (data-model §1). Unique per subject.
  @Index(unique: true, replace: true)
  late String subjectKey;

  @enumerated
  LockSubjectKind subjectKind = LockSubjectKind.profile;

  /// The profile id, or the space's local id at write time (display only).
  int subjectLocalId = 0;

  /// The space's `syncGuid` when [subjectKind] is [LockSubjectKind.space],
  /// else `''`.
  String subjectGuid = '';

  /// Whether this subject asks for a lock at all. `false` means the app behaves
  /// exactly as it did before this feature — opt-in, never forced (assumption).
  bool lockEnabled = false;

  /// Whether the in-session biometric shortcut is on for this subject
  /// (FR-020). Only meaningful while the device can satisfy FR-017.
  bool biometricsEnabled = false;

  /// One of the five bounded choices, default 2 minutes; there is no "never"
  /// (FR-033).
  @enumerated
  AwayTime awayTime = AwayTime.twoMinutes;

  late DateTime createdAt;

  late DateTime updatedAt;

  /// A fresh row for [subject], with the documented defaults and no lock.
  static LockSetting forSubject(LockSubject subject, {DateTime? at}) {
    final now = at ?? DateTime.now();
    return LockSetting()
      ..subjectKey = subject.key
      ..subjectKind = subject.kind
      ..subjectLocalId = subject.localId
      ..subjectGuid = subject.guid
      ..lockEnabled = false
      ..biometricsEnabled = false
      ..awayTime = AwayTime.twoMinutes
      ..createdAt = now
      ..updatedAt = now;
  }
}
