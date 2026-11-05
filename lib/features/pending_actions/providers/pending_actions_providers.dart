import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/pending_action.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/services/income_activation_service.dart';
import '../../finance/repositories/audit_repository.dart';
import '../../medical/providers/medical_receipt_provider.dart';
import '../services/pending_action_service.dart';
import '../services/pending_action_synthesizer.dart';

/// Injectable clock so timing-state tests are deterministic.
final pendingActionClockProvider =
    Provider<DateTime Function()>((ref) => DateTime.now);

/// The service for the active context. Personal actions are audited; shared
/// actions skip audit until an unlocked sync recorder is supplied (the action
/// itself must never be blocked by a locked identity).
final pendingActionServiceProvider = Provider<PendingActionService>((ref) {
  final db = IsarHelper.instance;
  final context = ref.watch(budgetContextProvider);
  final profileId = context.profileId;
  return PendingActionService(
    db,
    profileId: profileId,
    sharedSpaceId: context.spaceId,
    audit: profileId == null ? null : AuditRepository(db, actorId: profileId),
    clock: ref.watch(pendingActionClockProvider),
  );
});

/// Everything for the active context, terminal rows last.
final pendingActionsProvider =
    StreamProvider.autoDispose<List<PendingAction>>((ref) {
  final context = ref.watch(budgetContextProvider);
  final service = ref.watch(pendingActionServiceProvider);
  return service.watch(
    profileId: context.profileId,
    sharedSpaceId: context.spaceId,
  );
});

/// Unread badge count. Reading a row never completes it.
final pendingActionUnreadCountProvider = StreamProvider.autoDispose<int>((ref) {
  final context = ref.watch(budgetContextProvider);
  final service = ref.watch(pendingActionServiceProvider);
  return service.watchUnreadCount(
    profileId: context.profileId,
    sharedSpaceId: context.spaceId,
  );
});

final pendingActionSynthesizerProvider =
    Provider<PendingActionSynthesizer>((ref) {
  final context = ref.watch(budgetContextProvider);
  return PendingActionSynthesizer(
    IsarHelper.instance,
    profileId: context.profileId,
    sharedSpaceId: context.spaceId,
    service: ref.watch(pendingActionServiceProvider),
    clock: ref.watch(pendingActionClockProvider),
  );
});

/// Runs synthesis, refreshes timing states and sends throttled notifications.
/// Reading or synthesizing never completes an action by itself.
final pendingActionsSynthesisProvider =
    FutureProvider.autoDispose<void>((ref) async {
  final context = ref.watch(budgetContextProvider);
  final clock = ref.read(pendingActionClockProvider);
  final now = clock();
  if (!context.isShared && context.profileId != null) {
    final month = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}';
    await IncomeActivationService(
      IsarHelper.instance,
      profileId: context.profileId,
      audit: AuditRepository(IsarHelper.instance, actorId: context.profileId),
      pendingActions: ref.read(pendingActionServiceProvider),
      clock: clock,
    ).ensureActivationActions(context.profileId!, month);
  }
  final inbox = ref.watch(medicalInboxProvider).valueOrNull;
  final service = ref.read(pendingActionServiceProvider);
  await ref.read(pendingActionSynthesizerProvider).synthesize(
        medicalInbox: inbox,
      );
  await service.refreshStatuses(now);
  await service.notifyDue(now: now);
});
