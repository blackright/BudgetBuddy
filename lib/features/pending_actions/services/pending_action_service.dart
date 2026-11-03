import 'package:isar/isar.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/models/pending_action.dart';
import '../../../core/services/reminder_notification_service.dart';
import '../../../shared/presentation/money_format.dart';
import '../../finance/repositories/audit_repository.dart';
import 'pending_action_types.dart';

/// Stable positive 31-bit notification id derived from the action GUID.
int pendingActionNotificationId(String guid) {
  var hash = 0x811c9dc5;
  for (final code in guid.codeUnits) {
    hash ^= code;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash & 0x7FFFFFFF;
}

/// The input to [PendingActionService.upsert]. A draft carries no status or
/// history: synthesis may only describe what needs attention, never complete it.
class PendingActionDraft {
  const PendingActionDraft({
    this.profileId,
    this.sharedSpaceId,
    required this.actionType,
    required this.title,
    required this.nextAction,
    required this.feature,
    required this.recordRef,
    required this.cycleOrMonth,
    this.relatedGuid,
    this.expectedAmountMinor,
    this.currency,
    this.expectedAt,
    this.expectedMonth,
    this.priority = 0,
    this.deepLink,
    this.reminderAt,
  });

  final int? profileId;
  final int? sharedSpaceId;
  final String actionType;
  final String title;
  final String nextAction;
  final String feature;
  final String recordRef;

  /// Cycle GUID, month (`YYYY-MM`) or another stable per-occurrence key.
  final String cycleOrMonth;
  final String? relatedGuid;
  final int? expectedAmountMinor;
  final String? currency;
  final DateTime? expectedAt;
  final String? expectedMonth;
  final int priority;
  final String? deepLink;
  final DateTime? reminderAt;

  String get dedupeKey => '$actionType|$recordRef|$cycleOrMonth';
}

/// Attention metadata only: creating, reading or completing an action never
/// changes money, allocations, Vault entries or month totals (022 FR-048).
///
/// Synthesis is idempotent because [PendingActionDraft.dedupeKey] is unique.
/// Terminal rows are never revived; a new cycle produces a new key.
class PendingActionService {
  PendingActionService(
    this.db, {
    this.profileId,
    this.sharedSpaceId,
    this.audit,
    DateTime Function()? clock,
  })  : assert((profileId == null) != (sharedSpaceId == null),
            'PendingActionService needs exactly one owner'),
        clock = clock ?? DateTime.now;

  final Isar db;

  /// The context this service instance writes for. Guards against a synthesis
  /// run leaking an action into another profile or space.
  final int? profileId;
  final int? sharedSpaceId;

  /// Personal actions are audited through the existing repository. Shared
  /// actions are signed by the sync recorder when one is supplied.
  final AuditRepository? audit;
  final DateTime Function() clock;

  int? get _profile => profileId;
  int? get _space => sharedSpaceId;

  Never _fail(String message) => throw ArgumentError.value(message, 'action');

  void _validateDraft(PendingActionDraft draft) {
    final ownerMatches = draft.profileId == null && draft.sharedSpaceId == null
        ? true
        : draft.profileId == _profile && draft.sharedSpaceId == _space;
    if (!ownerMatches) {
      _fail('The action belongs to another profile or space.');
    }
    if (draft.actionType.trim().isEmpty ||
        draft.title.trim().isEmpty ||
        draft.nextAction.trim().isEmpty ||
        draft.feature.trim().isEmpty ||
        draft.recordRef.trim().isEmpty ||
        draft.cycleOrMonth.trim().isEmpty) {
      _fail('Every action needs a type, title, next step and record.');
    }
    if (draft.expectedAmountMinor != null && draft.expectedAmountMinor! < 0) {
      _fail('An expected amount cannot be negative.');
    }
    if (draft.expectedAmountMinor != null &&
        (draft.currency == null ||
            CurrencyCode.tryParse(draft.currency!) == null)) {
      _fail('An expected amount needs a supported currency.');
    }
    if (draft.expectedMonth != null &&
        !RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(draft.expectedMonth!)) {
      _fail('An expected month must use YYYY-MM.');
    }
    if (draft.priority < 0 || draft.priority > 2) {
      _fail('Priority must be 0, 1 or 2.');
    }
  }

  /// Inserts or refreshes one action. Re-running synthesis for the same
  /// type/record/cycle updates the row and keeps its [PendingAction.guid],
  /// status and notification read state.
  Future<PendingAction> upsert(PendingActionDraft draft) async {
    _validateDraft(draft);
    return db.writeTxn(() async {
      final now = clock();
      final key = draft.dedupeKey;
      final existing =
          await db.pendingActions.filter().dedupeKeyEqualTo(key).findFirst();
      if (existing != null) {
        if (existing.profileId != _profile ||
            existing.sharedSpaceId != _space) {
          _fail('This action key belongs to another profile or space.');
        }
        if (existing.isTerminal) {
          // Completed/dismissed actions are history; a new cycle uses a new key.
          return existing;
        }
        final before = _snapshot(existing);
        existing
          ..title = draft.title
          ..nextAction = draft.nextAction
          ..feature = draft.feature
          ..relatedGuid = draft.relatedGuid
          ..expectedAmountMinor = draft.expectedAmountMinor
          ..currency = draft.currency
          ..expectedAt = draft.expectedAt
          ..expectedMonth = draft.expectedMonth
          ..priority = draft.priority
          ..deepLink = draft.deepLink
          ..reminderAt = draft.reminderAt;
        final after = _snapshot(existing);
        if (_same(before, after)) return existing;
        existing.updatedAt = now;
        await db.pendingActions.put(existing);
        await _audit(existing, 'pendingAction.update',
            before: before, after: _snapshot(existing));
        return existing;
      }

      final row = PendingAction()
        ..profileId = _profile
        ..sharedSpaceId = _space
        ..actionType = draft.actionType
        ..title = draft.title
        ..nextAction = draft.nextAction
        ..feature = draft.feature
        ..recordRef = draft.recordRef
        ..relatedGuid = draft.relatedGuid
        ..expectedAmountMinor = draft.expectedAmountMinor
        ..currency = draft.currency
        ..expectedAt = draft.expectedAt
        ..expectedMonth = draft.expectedMonth
        ..priority = draft.priority
        ..deepLink = draft.deepLink
        ..reminderAt = draft.reminderAt
        ..status = 'pending'
        ..dedupeKey = key
        ..createdAt = now
        ..updatedAt = now;
      row.id = await db.pendingActions.put(row);
      await _audit(row, 'pendingAction.create',
          before: null, after: _snapshot(row));
      return row;
    });
  }

  /// Marks the action for [actionType]/[recordRef]/[cycleOrMonth] complete.
  /// Called only after the owning flow commits. Idempotent; no money write.
  Future<void> completeByRecord(
      String actionType, String recordRef, String cycleOrMonth) async {
    final key = '$actionType|$recordRef|$cycleOrMonth';
    await db.writeTxn(() async {
      final row =
          await db.pendingActions.filter().dedupeKeyEqualTo(key).findFirst();
      if (row == null || row.isTerminal) return;
      final before = _snapshot(row);
      final now = clock();
      row
        ..status = 'completed'
        ..completedAt = now
        ..updatedAt = now;
      await db.pendingActions.put(row);
      await _audit(row, 'pendingAction.complete',
          before: before, after: _snapshot(row));
    });
  }

  /// The screen destination for an action.
  ///
  /// Activation tasks always route to the Income Sources setup flow with the
  /// source and period, even if an older row carries no deep link.
  static String? destinationFor(PendingAction action) {
    if (action.actionType != PendingActionTypes.incomeActivate) {
      return action.deepLink;
    }
    final period = action.expectedMonth ?? '';
    return Uri(path: '/income_sources', queryParameters: {
      'activate': action.recordRef,
      if (period.isNotEmpty) 'period': period,
    }).toString();
  }

  /// Cancels every active action for one lifecycle and period.
  ///
  /// Used when a period is skipped or cancelled. Terminal rows are untouched.
  /// [actionTypes] narrows the cancellation to the given types; omitting it
  /// keeps the original all-types behaviour.
  Future<int> cancelActiveForRecord(
      String recordRef, String cycleOrMonth, String reason,
      {Set<String>? actionTypes}) async {
    final cleaned = reason.trim();
    if (cleaned.isEmpty) _fail('A reason is required.');
    final rows = await _activeRows();
    var cancelled = 0;
    for (final row in rows) {
      if (row.recordRef != recordRef) continue;
      if (row.expectedMonth != cycleOrMonth) continue;
      if (actionTypes != null && !actionTypes.contains(row.actionType)) {
        continue;
      }
      await cancel(row.guid, cleaned);
      cancelled++;
    }
    return cancelled;
  }

  Future<void> dismiss(String guid, String reason) =>
      _close(guid, 'dismissed', reason, 'pendingAction.dismiss');

  Future<void> cancel(String guid, String reason) =>
      _close(guid, 'cancelled', reason, 'pendingAction.cancel');

  Future<void> _close(
      String guid, String status, String reason, String auditAction) async {
    if (reason.trim().isEmpty) {
      _fail('A reason is required.');
    }
    await db.writeTxn(() async {
      final row =
          await db.pendingActions.filter().guidEqualTo(guid).findFirst();
      if (row == null || row.isTerminal) return;
      if (row.profileId != _profile || row.sharedSpaceId != _space) {
        _fail('This action belongs to another profile or space.');
      }
      final before = _snapshot(row);
      final now = clock();
      row
        ..status = status
        ..dismissedReason = reason.trim()
        ..updatedAt = now;
      await db.pendingActions.put(row);
      await _audit(row, auditAction, before: before, after: _snapshot(row));
    });
  }

  /// Reading a notification is not doing the task: it never changes [status].
  Future<void> markRead(String guid) async {
    await db.writeTxn(() async {
      final row =
          await db.pendingActions.filter().guidEqualTo(guid).findFirst();
      if (row == null || row.notificationReadAt != null) return;
      row
        ..notificationReadAt = clock()
        ..updatedAt = clock();
      await db.pendingActions.put(row);
    });
  }

  Future<void> markAllRead() async {
    await db.writeTxn(() async {
      final rows = await _activeRows();
      final now = clock();
      final changed = <PendingAction>[];
      for (final row in rows) {
        if (row.notificationReadAt != null) continue;
        row
          ..notificationReadAt = now
          ..updatedAt = now;
        changed.add(row);
      }
      if (changed.isNotEmpty) await db.pendingActions.putAll(changed);
    });
  }

  /// Sends at most one device notification per due/overdue action per day.
  /// Reading or receiving it never completes the action.
  Future<int> notifyDue(
      {ReminderNotificationService? notifications, DateTime? now}) async {
    final target = notifications ?? ReminderNotificationService();
    final at = now ?? clock();
    final rows = await _activeRows();
    final changed = <PendingAction>[];
    for (final row in rows) {
      if (row.notificationReadAt != null) continue;
      if (row.status != 'due' && row.status != 'overdue') continue;
      final last = row.lastNotifiedAt;
      if (last != null &&
          last.year == at.year &&
          last.month == at.month &&
          last.day == at.day) {
        continue;
      }
      final body = <String>[
        row.nextAction,
        if (row.expectedAmountMinor != null && row.currency != null)
          formatMinorUnits(
              row.expectedAmountMinor!, CurrencyCode.parseOr(row.currency)),
        if (row.expectedMonth != null) row.expectedMonth!,
      ].join(' · ');
      await target.showNow(
        id: pendingActionNotificationId(row.guid),
        title: row.title,
        body: body,
        payload: row.deepLink,
      );
      row
        ..lastNotifiedAt = at
        ..notificationCount = row.notificationCount + 1
        ..updatedAt = at;
      changed.add(row);
    }
    if (changed.isNotEmpty) {
      await db.writeTxn(() => db.pendingActions.putAll(changed));
    }
    return changed.length;
  }

  /// Promotes timing states. Never touches terminal rows or money.
  Future<void> refreshStatuses(DateTime now) async {
    await db.writeTxn(() async {
      final rows = await _activeRows();
      if (rows.isEmpty) return;
      final today = DateTime(now.year, now.month, now.day);
      final currentMonth =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
      final changed = <PendingAction>[];
      for (final row in rows) {
        var next = row.status;
        final monthOverdue = row.expectedMonth != null &&
            row.expectedMonth!.compareTo(currentMonth) < 0;
        final date = row.expectedAt;
        if (monthOverdue ||
            (date != null && date.isBefore(today) && row.status == 'due')) {
          next = 'overdue';
        } else if (date != null &&
            !date.isAfter(now) &&
            row.status == 'pending') {
          next = 'due';
        }
        if (next != row.status) {
          row
            ..status = next
            ..updatedAt = now;
          changed.add(row);
        }
      }
      if (changed.isNotEmpty) await db.pendingActions.putAll(changed);
    });
  }

  /// Active first, urgent first, then nearest expected instant/month.
  Stream<List<PendingAction>> watch({
    required int? profileId,
    required int? sharedSpaceId,
  }) {
    _assertOwner(profileId, sharedSpaceId);
    return db.pendingActions.where().watch(fireImmediately: true).map((rows) =>
        rows
            .where((row) =>
                row.profileId == profileId &&
                row.sharedSpaceId == sharedSpaceId)
            .toList()
          ..sort(_compare));
  }

  Stream<int> watchUnreadCount({
    required int? profileId,
    required int? sharedSpaceId,
  }) =>
      watch(profileId: profileId, sharedSpaceId: sharedSpaceId)
          .map((rows) => rows.where((row) => row.isUnread).length);

  Future<List<PendingAction>> readAll() async {
    final list = await _activeRows();
    list.sort(_compare);
    return list;
  }

  Future<List<PendingAction>> _activeRows() async {
    final all = await db.pendingActions.where().findAll();
    return all
        .where((row) =>
            row.profileId == _profile &&
            row.sharedSpaceId == _space &&
            row.isActive)
        .toList();
  }

  void _assertOwner(int? profileId, int? sharedSpaceId) {
    if ((profileId == null) == (sharedSpaceId == null)) {
      _fail('Choose exactly one profile or shared space.');
    }
  }

  int _compare(PendingAction a, PendingAction b) {
    if (a.isTerminal != b.isTerminal) return a.isTerminal ? 1 : -1;
    final byPriority = b.priority.compareTo(a.priority);
    if (byPriority != 0) return byPriority;
    final aTime = a.expectedAt ?? _monthStart(a.expectedMonth);
    final bTime = b.expectedAt ?? _monthStart(b.expectedMonth);
    if (aTime != null && bTime != null) {
      final byTime = aTime.compareTo(bTime);
      if (byTime != 0) return byTime;
    } else if (aTime != null) {
      return -1;
    } else if (bTime != null) {
      return 1;
    }
    return a.createdAt.compareTo(b.createdAt);
  }

  DateTime? _monthStart(String? yearMonth) {
    if (yearMonth == null) return null;
    final parts = yearMonth.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]));
  }

  Map<String, Object?> _snapshot(PendingAction row) => {
        'guid': row.guid,
        'profileId': row.profileId,
        'sharedSpaceId': row.sharedSpaceId,
        'actionType': row.actionType,
        'title': row.title,
        'nextAction': row.nextAction,
        'feature': row.feature,
        'recordRef': row.recordRef,
        'relatedGuid': row.relatedGuid,
        'expectedAmountMinor': row.expectedAmountMinor,
        'currency': row.currency,
        'expectedAt': row.expectedAt?.toIso8601String(),
        'expectedMonth': row.expectedMonth,
        'status': row.status,
        'priority': row.priority,
        'deepLink': row.deepLink,
        'reminderAt': row.reminderAt?.toIso8601String(),
        'completedAt': row.completedAt?.toIso8601String(),
        'dismissedReason': row.dismissedReason,
        'notificationReadAt': row.notificationReadAt?.toIso8601String(),
        'lastNotifiedAt': row.lastNotifiedAt?.toIso8601String(),
        'notificationCount': row.notificationCount,
      };

  bool _same(Map<String, Object?> before, Map<String, Object?> after) {
    if (before.length != after.length) return false;
    for (final entry in before.entries) {
      if (after[entry.key] != entry.value) return false;
    }
    return true;
  }

  Future<void> _audit(
    PendingAction row,
    String action, {
    required Map<String, Object?>? before,
    required Map<String, Object?>? after,
  }) async {
    final repo = audit;
    if (repo == null) return;
    // A shared chain needs an unlocked signer; attention metadata must never
    // block the action itself when the user has not unlocked yet.
    if (row.sharedSpaceId != null && repo.recorder == null) return;
    await repo.append(
      profileId: row.profileId,
      spaceId: row.sharedSpaceId,
      action: action,
      objectType: 'PendingAction',
      objectGuid: row.guid,
      objectId: row.id,
      before: before,
      after: after,
    );
  }
}
