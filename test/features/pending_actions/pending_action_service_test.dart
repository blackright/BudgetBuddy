import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/pending_action.dart';
import 'package:budget_buddy/core/services/reminder_notification_service.dart';
import 'package:budget_buddy/features/finance/repositories/audit_repository.dart';
import 'package:budget_buddy/features/pending_actions/services/pending_action_service.dart';
import 'package:budget_buddy/features/pending_actions/services/pending_action_types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../../features/medical/repositories/medical_test_harness.dart';

void main() {
  late MedicalTestHarness harness;
  late DateTime now;

  setUp(() async {
    harness = await MedicalTestHarness.create();
    now = DateTime(2026, 10, 24, 12);
  });

  tearDown(() async {
    await harness.close();
  });

  PendingActionService service({
    int profileId = 7,
    AuditRepository? audit,
    ReminderNotificationService? notifications,
  }) =>
      PendingActionService(
        harness.isar,
        profileId: profileId,
        audit: audit,
        notifications: notifications,
        clock: () => now,
      );

  PendingActionDraft draft({
    String recordRef = 'cycle-1',
    String cycleOrMonth = '2026-10',
    String title = 'Salary arrived',
    int? amountMinor = 50000000,
    String? currency = 'HUF',
    DateTime? expectedAt,
    String? expectedMonth,
    int priority = 1,
    String? deepLink = '/income_sources',
  }) =>
      PendingActionDraft(
        actionType: 'salary.confirm',
        title: title,
        nextAction: 'Confirm the amount you received',
        feature: 'salary',
        recordRef: recordRef,
        cycleOrMonth: cycleOrMonth,
        expectedAmountMinor: amountMinor,
        currency: currency,
        expectedAt: expectedAt,
        expectedMonth: expectedMonth,
        priority: priority,
        deepLink: deepLink,
      );

  test('upsert creates one action with a stable dedupe key', () async {
    final row = await service().upsert(draft());

    expect(row.profileId, 7);
    expect(row.sharedSpaceId, isNull);
    expect(row.dedupeKey, 'salary.confirm|cycle-1|2026-10');
    expect(row.status, 'pending');
    expect(row.guid, isNotEmpty);
    expect(await harness.isar.pendingActions.count(), 1);
  });

  test('upsert for the same type/record/cycle updates instead of duplicating',
      () async {
    final svc = service();
    final first = await svc.upsert(draft());
    await svc.markRead(first.guid);
    now = now.add(const Duration(minutes: 5));

    final second = await svc.upsert(draft(title: 'Salary still waiting'));

    expect(second.guid, first.guid);
    expect(second.title, 'Salary still waiting');
    expect(second.notificationReadAt, isNotNull,
        reason: 're-synthesis keeps notification read state');
    expect(await harness.isar.pendingActions.count(), 1);
  });

  test('a terminal action is never revived by the same cycle', () async {
    final svc = service();
    final first = await svc.upsert(draft());
    await svc.completeByRecord('salary.confirm', 'cycle-1', '2026-10');

    final again = await svc.upsert(draft(title: 'Should not return'));

    expect(again.guid, first.guid);
    expect(again.status, 'completed');
    expect(again.title, first.title);
  });

  test('a new cycle creates a new action', () async {
    final svc = service();
    await svc.upsert(draft());
    await svc.completeByRecord('salary.confirm', 'cycle-1', '2026-10');

    final next = await svc.upsert(draft(cycleOrMonth: '2026-11'));

    expect(next.status, 'pending');
    expect(await harness.isar.pendingActions.count(), 2);
  });

  test('completeByRecord is idempotent and writes no money', () async {
    final svc = service();
    final row = await svc.upsert(draft());

    await svc.completeByRecord('salary.confirm', 'cycle-1', '2026-10');
    final completed = (await harness.isar.pendingActions.get(row.id))!;
    expect(completed.status, 'completed');
    expect(completed.completedAt, now);

    now = now.add(const Duration(hours: 1));
    await svc.completeByRecord('salary.confirm', 'cycle-1', '2026-10');
    final again = (await harness.isar.pendingActions.get(row.id))!;
    expect(again.completedAt, completed.completedAt);
    expect(await harness.isar.monthlyBudgets.count(), 0);
    expect(await harness.isar.expenses.count(), 0);
  });

  test('dismiss requires a reason and keeps the row in history', () async {
    final svc = service();
    final row = await svc.upsert(draft());

    await expectLater(svc.dismiss(row.guid, '  '), throwsArgumentError);
    await svc.dismiss(row.guid, 'I will handle it later');
    final dismissed = (await harness.isar.pendingActions.get(row.id))!;
    expect(dismissed.status, 'dismissed');
    expect(dismissed.dismissedReason, 'I will handle it later');
  });

  test('markRead only records the read instant', () async {
    final svc = service();
    final row = await svc.upsert(draft());

    await svc.markRead(row.guid);

    final read = (await harness.isar.pendingActions.get(row.id))!;
    expect(read.notificationReadAt, now);
    expect(read.status, 'pending');
    expect(read.completedAt, isNull);
  });

  test('unread count excludes read and terminal actions', () async {
    final svc = service();
    final first = await svc.upsert(draft());
    await svc.upsert(draft(recordRef: 'cycle-2', cycleOrMonth: '2026-11'));
    await svc.markRead(first.guid);

    final unread =
        await svc.watchUnreadCount(profileId: 7, sharedSpaceId: null).first;
    expect(unread, 1);
  });

  test('refreshStatuses promotes pending to due, then due to overdue',
      () async {
    final svc = service();
    final row = await svc.upsert(draft(
      expectedAt: DateTime(2026, 10, 24, 12),
      expectedMonth: '2026-10',
    ));

    await svc.refreshStatuses(DateTime(2026, 10, 24, 12));
    expect((await harness.isar.pendingActions.get(row.id))!.status, 'due');

    await svc.refreshStatuses(DateTime(2026, 10, 25, 8));
    expect((await harness.isar.pendingActions.get(row.id))!.status, 'overdue');
  });

  test('a past expected month is overdue even without an instant', () async {
    final svc = service();
    final row = await svc.upsert(draft(expectedMonth: '2026-09'));
    await svc.refreshStatuses(DateTime(2026, 10, 24));
    expect((await harness.isar.pendingActions.get(row.id))!.status, 'overdue');
  });

  test('terminal actions are never promoted', () async {
    final svc = service();
    final row = await svc.upsert(draft(
      expectedAt: DateTime(2026, 1, 1),
      expectedMonth: '2026-01',
    ));
    await svc.cancel(row.guid, 'sourceMissing');

    await svc.refreshStatuses(DateTime(2026, 10, 24));

    expect(
        (await harness.isar.pendingActions.get(row.id))!.status, 'cancelled');
  });

  test('a draft for another profile is rejected', () async {
    const draftRow = PendingActionDraft(
      profileId: 99,
      actionType: 'salary.confirm',
      title: 'x',
      nextAction: 'x',
      feature: 'salary',
      recordRef: 'r',
      cycleOrMonth: '2026-10',
    );
    await expectLater(service().upsert(draftRow), throwsArgumentError);
  });

  test('invalid money context is rejected', () async {
    await expectLater(
        service().upsert(draft(currency: null)), throwsArgumentError);
    await expectLater(
        service().upsert(draft(amountMinor: -1)), throwsArgumentError);
  });

  test('writes are audited through the existing repository', () async {
    final audit = AuditRepository(harness.isar, actorId: 7);
    final svc = service(audit: audit);
    await svc.upsert(draft());
    await svc.completeByRecord('salary.confirm', 'cycle-1', '2026-10');

    final events = (await harness.isar.auditEvents.where().findAll())
        .where((event) => event.objectType == 'PendingAction')
        .toList();
    expect(events.map((e) => e.action), contains('pendingAction.create'));
    expect(events.map((e) => e.action), contains('pendingAction.complete'));
    expect(events.every((e) => e.objectType == 'PendingAction'), isTrue);
    expect(events, isNotEmpty);
  });

  test('shared actions are scoped to the space', () async {
    final svc =
        PendingActionService(harness.isar, sharedSpaceId: 5, clock: () => now);
    final row = await svc.upsert(const PendingActionDraft(
      actionType: 'sync.conflict',
      title: 'Sync needs you',
      nextAction: 'Review changes',
      feature: 'sync',
      recordRef: 'space-5',
      cycleOrMonth: '2026-10',
    ));
    expect(row.sharedSpaceId, 5);
    expect(row.profileId, isNull);

    final personal = await service()
        .watch(
          profileId: 7,
          sharedSpaceId: null,
        )
        .first;
    expect(personal, isEmpty);
  });

  test('the model exposes the persistence invariants', () {
    final row = PendingAction()
      ..profileId = null
      ..sharedSpaceId = null
      ..actionType = 'x'
      ..title = 'x'
      ..nextAction = 'x'
      ..feature = 'x'
      ..recordRef = 'x'
      ..dedupeKey = 'x';
    expect(row.hasValidOwnership, isFalse);
    expect(row.hasValidFields, isTrue);
  });

  test('an existing audit event type is untouched by action writes', () async {
    expect(await harness.isar.auditEvents.count(), 0);
    await service().upsert(draft());
    expect(await harness.isar.auditEvents.count(), 0,
        reason: 'no audit repository was supplied; no event is fabricated');
  });

  test('activation actions route to the Income Sources setup flow', () {
    final action = PendingAction()
      ..actionType = PendingActionTypes.incomeActivate
      ..recordRef = 'source-guid'
      ..expectedMonth = '2026-11';

    expect(PendingActionService.destinationFor(action),
        '/income_sources?activate=source-guid&period=2026-11');
  });

  test('completeByRecord cancels the delivered notification', () async {
    final notifications = _RecordingNotifications();
    final svc = service(notifications: notifications);
    final row = await svc.upsert(draft());

    await svc.completeByRecord('salary.confirm', 'cycle-1', '2026-10');

    expect(notifications.cancelled, [pendingActionNotificationId(row.guid)]);
  });

  test('dismiss cancels the delivered notification', () async {
    final notifications = _RecordingNotifications();
    final svc = service(notifications: notifications);
    final row = await svc.upsert(draft());

    await svc.dismiss(row.guid, 'I will handle it later');

    expect(notifications.cancelled, [pendingActionNotificationId(row.guid)]);
  });

  test('cancel cancels the delivered notification', () async {
    final notifications = _RecordingNotifications();
    final svc = service(notifications: notifications);
    final row = await svc.upsert(draft());

    await svc.cancel(row.guid, 'sourceMissing');

    expect(notifications.cancelled, [pendingActionNotificationId(row.guid)]);
  });

  test('an already-terminal action does not cancel again', () async {
    final notifications = _RecordingNotifications();
    final svc = service(notifications: notifications);
    final row = await svc.upsert(draft());
    await svc.completeByRecord('salary.confirm', 'cycle-1', '2026-10');
    notifications.cancelled.clear();

    await svc.completeByRecord('salary.confirm', 'cycle-1', '2026-10');
    await svc.dismiss(row.guid, 'later');
    await svc.cancel(row.guid, 'later');

    expect(notifications.cancelled, isEmpty);
  });

  test('a missing action does not cancel any notification', () async {
    final notifications = _RecordingNotifications();
    final svc = service(notifications: notifications);

    await svc.cancel('missing-guid', 'sourceMissing');

    expect(notifications.cancelled, isEmpty);
  });

  test('notifyDue carries the action GUID and route', () async {
    final notifications = _RecordingNotifications();
    final svc = service(notifications: notifications);
    final row = await svc.upsert(draft(
        expectedAt: DateTime(2026, 10, 24, 12),
        expectedMonth: '2026-10',
        deepLink: '/month_end?month=2026-09'));
    await svc.refreshStatuses(now);

    final sent = await svc.notifyDue(now: now);

    expect(sent, 1);
    final shown = notifications.shown.single;
    expect(shown.id, pendingActionNotificationId(row.guid));
    expect(pendingActionNotification(shown.payload),
        (guid: row.guid, route: '/month_end?month=2026-09'));
  });

  test('notifyDue still sends at most once per day', () async {
    final notifications = _RecordingNotifications();
    final svc = service(notifications: notifications);
    await svc.upsert(draft(
        expectedAt: DateTime(2026, 10, 24, 12), expectedMonth: '2026-10'));
    await svc.refreshStatuses(now);

    expect(await svc.notifyDue(now: now), 1);
    expect(await svc.notifyDue(now: now.add(const Duration(hours: 1))), 0);
    expect(notifications.shown, hasLength(1));
  });
}

class _RecordingNotifications extends ReminderNotificationService {
  _RecordingNotifications() : super.forTest();

  final cancelled = <int>[];
  final shown = <({int id, String title, String body, String? payload})>[];

  @override
  Future<void> cancelReminder(int id) async => cancelled.add(id);

  @override
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async =>
      shown.add((id: id, title: title, body: body, payload: payload));
}
