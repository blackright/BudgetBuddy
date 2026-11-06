import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/services/financial_adoption_service.dart';
import '../../../shared/presentation/modals/app_sheet.dart';
import '../../identity/providers/device_auth_session.dart';
import '../../security/providers/lock_providers.dart';
import '../repositories/month_finance_repository.dart';
import 'balance_checkpoint_sheet.dart';
import 'receipt_adoption_sheet.dart';

/// Opens the existing receipt-start review for [target].
///
/// [balance] opens the opening-money checkpoint review; otherwise it opens the
/// financial-adoption review. Both reuse the authenticated, context-bound
/// commands supplied by the finance repository.
Future<void> reviewReceiptSetup(BuildContext context, WidgetRef ref,
    {bool balance = false, ContextRef? target}) async {
  final selected = ref.read(budgetContextProvider);
  final reviewContext = target ?? selected;
  final actor = ref.read(actingProfileIdProvider);
  final auth = ref.read(deviceAuthSessionProvider);
  if (actor == null ||
      !auth.authenticated ||
      ref.read(lockControllerProvider).isLocked) {
    return;
  }
  final session = ref.read(deviceAuthSessionProvider.notifier);
  bool access() {
    if (!context.mounted || !session.isCurrent(auth.generation)) return false;
    final current = ref.read(budgetContextProvider);
    return ref.read(deviceAuthSessionProvider).authenticated &&
        !ref.read(lockControllerProvider).isLocked &&
        ref.read(actingProfileIdProvider) == actor &&
        current.profileId == selected.profileId &&
        current.spaceId == selected.spaceId &&
        current.yearMonth == selected.yearMonth;
  }

  final service = FinancialAdoptionService(IsarHelper.instance);
  final finance = ref.read(monthFinanceRepositoryProvider);
  await showAppSheet<void>(context,
      builder: (sheetContext) => Consumer(builder: (_, innerRef, __) {
            // Remove private preview content immediately on lock or context change.
            innerRef.watch(budgetContextProvider);
            innerRef.watch(actingProfileIdProvider);
            innerRef.watch(deviceAuthSessionProvider);
            innerRef.watch(lockControllerProvider);
            if (!access()) {
              return AppSheet(
                  title: 'Review unavailable',
                  showCloseButton: false,
                  body: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                            'Access changed. Reopen this review after unlocking the correct budget.'),
                        const SizedBox(height: 12),
                        TextButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            child: const Text('Close')),
                      ]));
            }
            if (balance) {
              return BalanceCheckpointSheet(
                  load: () async {
                    final zone = await FlutterTimezone.getLocalTimezone();
                    final sources = await finance.loadBalanceCheckpointReview(
                        reviewContext,
                        isAccessCurrent: access);
                    return CheckpointSheetData(
                        sources,
                        sources.previous?.localZone ?? zone.identifier,
                        DateTime.now());
                  },
                  preview: (sources, draft) => finance.previewBalanceCheckpoint(
                      sources, draft,
                      isAccessCurrent: access),
                  save: (preview, operation) async {
                    await finance.confirmBalanceCheckpoint(preview, operation,
                        isAccessCurrent: access);
                  });
            }
            return ReceiptAdoptionSheet(
                load: () => service.preview(
                    context: reviewContext,
                    actorId: actor,
                    isAccessCurrent: access),
                save: (preview, operation) async {
                  await service.confirm(
                      preview: preview,
                      operationKey: operation,
                      isAccessCurrent: access);
                });
          }));
}

/// Ensures the month has both its financial adoption and opening checkpoint.
///
/// The user always confirms each financial review; nothing is inferred or
/// written silently. Returns true when the checkpoint now exists for the
/// current adoption.
Future<bool> reviewReceiptBoundary(
  BuildContext context,
  WidgetRef ref, {
  required ContextRef target,
}) async {
  final finance = ref.read(monthFinanceRepositoryProvider);
  final selected = ref.read(budgetContextProvider);
  final actor = ref.read(actingProfileIdProvider);
  if (actor == null || target.profileId != actor) return false;
  final auth = ref.read(deviceAuthSessionProvider);
  final session = ref.read(deviceAuthSessionProvider.notifier);
  bool access() {
    if (!context.mounted || !session.isCurrent(auth.generation)) return false;
    final current = ref.read(budgetContextProvider);
    return ref.read(deviceAuthSessionProvider).authenticated &&
        !ref.read(lockControllerProvider).isLocked &&
        ref.read(actingProfileIdProvider) == actor &&
        current.profileId == selected.profileId &&
        current.spaceId == selected.spaceId;
  }

  try {
    final before = await finance.loadBalanceCheckpointReview(target,
        isAccessCurrent: access);
    final needsAdoption = before.adoptionGuid == null ||
        before.blockers.contains('adoptionRequired');
    if (needsAdoption) {
      if (!context.mounted) return false;
      await reviewReceiptSetup(context, ref, target: target);
      if (!context.mounted || !access()) return false;
      final after = await finance.loadBalanceCheckpointReview(target,
          isAccessCurrent: access);
      if (after.adoptionGuid == null ||
          after.blockers.contains('adoptionRequired')) {
        return false;
      }
    }
    if (!context.mounted) return false;
    await reviewReceiptSetup(context, ref, balance: true, target: target);
    if (!context.mounted || !access()) return false;
    final saved = await finance.loadBalanceCheckpointReview(target,
        isAccessCurrent: access);
    return saved.previous != null &&
        saved.previous!.adoptionGuid == saved.adoptionGuid;
  } catch (_) {
    return false;
  }
}
