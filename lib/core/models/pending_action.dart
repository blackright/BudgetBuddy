import 'package:isar/isar.dart';

import '../../features/sync/domain/sync_guid.dart';

part 'pending_action.g.dart';

/// One thing that needs the user, in one place (022 FR-038–FR-048).
///
/// An action is **attention metadata**: it may describe an amount or a month,
/// but writing or completing an action never changes money, allocations or the
/// Vault. Completion is written only after the owning flow's confirmation has
/// committed.
///
/// Exactly one of [profileId] / [sharedSpaceId] is set, the same ownership
/// invariant as `MonthlyBudget`. [dedupeKey] is unique so re-running synthesis
/// updates the same row instead of creating a duplicate.
@collection
class PendingAction {
  Id id = Isar.autoIncrement;

  /// Stable identity, also used to derive the device-notification id.
  @Index(unique: true)
  String guid = newSyncGuid();

  /// Owning personal profile, or null when the action belongs to a space.
  @Index()
  int? profileId;

  /// Owning shared space, or null when the action is personal.
  int? sharedSpaceId;

  /// Machine type, e.g. `salary.confirm`, `vault.withdrawalDue`.
  @Index()
  late String actionType;

  /// User-facing title and one-line next step.
  late String title;
  late String nextAction;

  /// Owning feature and related record. [recordRef] is a stable, feature-local
  /// id (a salary cycle GUID, a month, a Vault operation key, …).
  late String feature;
  late String recordRef;
  String? relatedGuid;

  /// Optional money context. Never changes a balance by itself.
  int? expectedAmountMinor;
  String? currency;

  /// Optional timing context. [expectedAt] is an instant; [expectedMonth] is
  /// `YYYY-MM`.
  DateTime? expectedAt;
  String? expectedMonth;

  /// `pending | due | overdue | completed | dismissed | cancelled`.
  @Index()
  String status = 'pending';

  /// 0 normal, 1 attention, 2 urgent.
  int priority = 0;

  /// Deep link opened by the primary action (for example `/vault`).
  String? deepLink;

  /// Optional user reminder instant.
  DateTime? reminderAt;

  /// Completion / dismissal evidence.
  DateTime? completedAt;
  String? dismissedReason;

  /// Duplicate guard: `'<actionType>|<recordRef>|<cycleOrMonth>'`.
  @Index(unique: true)
  late String dedupeKey;

  /// In-app notification state. Reading never completes the action.
  DateTime? notificationReadAt;
  DateTime? lastNotifiedAt;
  int notificationCount = 0;

  late DateTime createdAt;
  late DateTime updatedAt;

  static const statuses = {
    'pending',
    'due',
    'overdue',
    'completed',
    'dismissed',
    'cancelled',
  };

  /// Terminal states are never revived by synthesis; a new cycle uses a new
  /// dedupe key instead.
  static const terminalStatuses = {'completed', 'dismissed', 'cancelled'};

  @ignore
  bool get isActive => status == 'pending' || status == 'due' || status == 'overdue';

  @ignore
  bool get isUnread => notificationReadAt == null && isActive;

  @ignore
  bool get isTerminal => terminalStatuses.contains(status);

  /// Mirrors the persistence validation in `PendingActionService.upsert`.
  @ignore
  bool get hasValidOwnership =>
      (profileId != null) != (sharedSpaceId != null);

  @ignore
  bool get hasValidFields =>
      actionType.trim().isNotEmpty &&
      title.trim().isNotEmpty &&
      nextAction.trim().isNotEmpty &&
      feature.trim().isNotEmpty &&
      recordRef.trim().isNotEmpty &&
      dedupeKey.trim().isNotEmpty &&
      statuses.contains(status) &&
      (expectedAmountMinor == null || expectedAmountMinor! >= 0) &&
      (expectedMonth == null ||
          RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(expectedMonth!));
}
