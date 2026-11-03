import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/providers/clock_provider.dart';
import 'package:budget_buddy/core/services/balance_checkpoint_service.dart';
import 'package:budget_buddy/core/services/financial_adoption_service.dart';
import 'package:budget_buddy/core/services/receipt_snapshot_repository.dart';
import 'package:budget_buddy/features/finance/providers/receipt_reconciliation_provider.dart';
import 'package:budget_buddy/features/identity/providers/device_auth_session.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import '../../support/receipt_financial_harness.dart';

class TestSession extends DeviceAuthSession {
  TestSession(this.unlocked);
  final bool unlocked;
  @override
  NativeAuthSnapshot build() => NativeAuthSnapshot(
      generation: 7,
      binding: const NativeAccessBinding(key: 'fixture'),
      authenticated: unlocked);
  @override
  bool isCurrent(int generation) => unlocked && generation == 7;
}

class TestLock extends LockController {
  @override
  LockSnapshot build() => const LockSnapshot();
}

class TestClock extends ClockNotifier {
  TestClock(DateTime time) {
    state = time;
  }
}

void main() {
  test(
      'saved review refreshes on added expense; locked access fails instead of zero',
      () async {
    final h = await ReceiptFinancialHarness.create();
    IsarHelper.instance = h.db;
    final now = DateTime.utc(2026, 10, 28, 16);
    final adoption = FinancialAdoptionService(h.db, clock: () => now);
    final a = await adoption.preview(
        context: h.context(), actorId: h.ownerId, isAccessCurrent: () => true);
    await adoption.confirm(
        preview: a, operationKey: 'start', isAccessCurrent: () => true);
    final service = BalanceCheckpointService(h.db, clock: () => now);
    final sources = await service.load(
        context: h.context(), actorId: h.ownerId, isAccessCurrent: () => true);
    final p = await service.preview(
        sources: sources,
        draft: CheckpointDraft(
            balanceMinor: 600000,
            balanceAsOf: DateTime.utc(2026, 10, 28, 12),
            localZone: 'Europe/Budapest',
            pool: 'Bank',
            choices: []),
        isAccessCurrent: () => true);
    await service.confirm(
        preview: p, operationKey: 'balance', isAccessCurrent: () => true);
    ProviderContainer container(bool unlocked) => ProviderContainer(overrides: [
          budgetContextProvider.overrideWithValue(h.context()),
          actingProfileIdProvider.overrideWithValue(h.ownerId),
          clockProvider.overrideWith((ref) => TestClock(now)),
          checkpointClockProvider.overrideWithValue(() => now),
          deviceAuthSessionProvider.overrideWith(() => TestSession(unlocked)),
          lockControllerProvider.overrideWith(TestLock.new),
        ]);
    final c = container(true);
    final changed = Completer<CheckpointReadiness>();
    final subscription =
        c.listen(receiptReconciliationProvider, (before, after) {
      final value = after.valueOrNull;
      if (value?.cash?.blockers.contains('movementNeedsReview') == true &&
          !changed.isCompleted) {
        changed.complete(value);
      }
    });
    try {
      final ready = await c.read(receiptReconciliationProvider.future);
      expect(ready.needsReview, isFalse);
      expect(ready.cash!.bankMinor, 600000);
      await h.db.writeTxn(() async {
        await h.db.expenses
            .put(h.expense()..paidAt = DateTime.utc(2026, 10, 28, 14));
      });
      final updated = await changed.future.timeout(const Duration(seconds: 5));
      expect(updated.needsReview, isTrue);
      expect(updated.cash!.bankMinor, isNull);
      final locked = container(false);
      try {
        await expectLater(locked.read(receiptReconciliationProvider.future),
            throwsA(isA<ReceiptGuardException>()));
      } finally {
        locked.dispose();
      }
    } finally {
      subscription.close();
      c.dispose();
      // Allow async stream-finally cleanup before closing its disposable store.
      await Future<void>.delayed(Duration.zero);
      await h.close();
    }
  });
}
