import 'dart:convert';

import 'package:budget_buddy/core/models/pending_action.dart';
import 'package:budget_buddy/features/pending_actions/services/pending_action_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../features/medical/repositories/medical_test_harness.dart';

/// F2 / T084 and T085: the notification payload carries both the action GUID
/// and its route; a tap marks the action read before routing; bare legacy links
/// still route unchanged.
void main() {
  late MedicalTestHarness h;
  final now = DateTime(2026, 10, 24, 12);

  setUp(() async {
    h = await MedicalTestHarness.create();
  });

  tearDown(() => h.close());

  PendingActionService service() =>
      PendingActionService(h.isar, profileId: 7, clock: () => now);

  Future<PendingAction> action(
          {String? deepLink = '/month_end?month=2026-09'}) =>
      service().upsert(PendingActionDraft(
        actionType: 'monthend.close',
        title: 'Finish 2026-09 month-end',
        nextAction: 'Review month-end',
        feature: 'month-end',
        recordRef: '2026-09',
        cycleOrMonth: '2026-09',
        expectedMonth: '2026-09',
        priority: 1,
        deepLink: deepLink,
      ));

  test('the payload carries the action GUID and its route', () async {
    final row = await action();

    final payload = pendingActionNotificationPayload(row);

    expect(jsonDecode(payload),
        {'guid': row.guid, 'route': '/month_end?month=2026-09'});
    expect(pendingActionNotification(payload),
        (guid: row.guid, route: '/month_end?month=2026-09'));
  });

  test('a direct tap marks the action read before returning the route',
      () async {
    final row = await action();

    final route = await openPendingActionNotification(
        pendingActionNotificationPayload(row), service);

    expect(route, '/month_end?month=2026-09');
    final read = (await h.isar.pendingActions.get(row.id))!;
    expect(read.notificationReadAt, now);
    expect(read.status, 'pending');
  });

  test('a bare /vault payload still routes', () async {
    final route = await openPendingActionNotification('/vault', service);

    expect(route, '/vault');
    expect(await h.isar.pendingActions.count(), 0);
  });

  test('a bare /month_end?month= payload still routes', () async {
    final route = await openPendingActionNotification(
        '/month_end?month=2026-09', service);

    expect(route, '/month_end?month=2026-09');
  });

  test('an action without a route is still marked read', () async {
    final row = await action(deepLink: null);
    final payload = pendingActionNotificationPayload(row);

    expect(jsonDecode(payload), {'guid': row.guid});
    final route = await openPendingActionNotification(payload, service);

    expect(route, isNull);
    expect((await h.isar.pendingActions.get(row.id))!.notificationReadAt, now);
  });

  test('empty or unknown payloads produce no route', () async {
    expect(pendingActionNotification(null), isNull);
    expect(pendingActionNotification('   '), isNull);
    expect(await openPendingActionNotification('', service), isNull);
  });
}
