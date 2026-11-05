import 'package:isar/isar.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../core/models/balance_checkpoint.dart';
import '../../../core/models/financial_adoption.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/services/balance_checkpoint_service.dart';
import '../../../core/services/financial_adoption_service.dart';

/// Creates the existing financial adoption and opening balance checkpoint from
/// the first-month opening amount entered during onboarding.
///
/// This is the same start boundary the normal first-month review records. It
/// adds no new schema and does not change income expectations. Salary receipts
/// require this boundary, so onboarding confirms it once from the entered
/// opening balance before income activation.
class OnboardingOpeningService {
  OnboardingOpeningService(this.db, {DateTime Function()? clock})
      : clock = clock ?? DateTime.now;

  final Isar db;
  final DateTime Function() clock;

  Future<void> ensure({
    required int profileId,
    required String yearMonth,
    required int openingMinor,
    required String timezone,
    required String flowId,
    required bool Function() isAccessCurrent,
  }) async {
    final context =
        ContextRef.personal(profileId: profileId, yearMonth: yearMonth);

    // Re-entering the same step must reuse the boundary it already recorded.
    // The financial adoption service rejects a second confirm when its input
    // fingerprint no longer matches, so reuse the stored identity first.
    final adoptionIdentity = 'personal:$profileId:2:onboarding-adopt:$flowId';
    final existingAdoption = await db.financialAdoptions
        .filter()
        .operationIdentityEqualTo(adoptionIdentity)
        .findFirst();
    if (existingAdoption == null) {
      final adoption = FinancialAdoptionService(db, clock: clock);
      final adoptionPreview = await adoption.preview(
          context: context,
          actorId: profileId,
          isAccessCurrent: isAccessCurrent);
      if (!adoptionPreview.canConfirm) {
        throw StateError(
            'Opening adoption needs review: ${adoptionPreview.blockers.join(', ')}');
      }
      await adoption.confirm(
          preview: adoptionPreview,
          operationKey: 'onboarding-adopt:$flowId',
          isAccessCurrent: isAccessCurrent);
    }

    final checkpointIdentity =
        '${BalanceCheckpointService.ownerMonth(context)}:onboarding-checkpoint:$flowId';
    final existingCheckpoint = await db.balanceCheckpoints
        .filter()
        .operationIdentityEqualTo(checkpointIdentity)
        .findFirst();
    if (existingCheckpoint != null) return;

    final checkpoint = BalanceCheckpointService(db, clock: clock);
    final sources = await checkpoint.load(
        context: context, actorId: profileId, isAccessCurrent: isAccessCurrent);
    BalanceCheckpointService.initializeZones();
    final parts = yearMonth.split('-').map(int.parse).toList();
    final monthStart = tz.TZDateTime(
            BalanceCheckpointService.location(timezone), parts[0], parts[1], 1)
        .toUtc();
    final preview = await checkpoint.preview(
        sources: sources,
        draft: CheckpointDraft(
          balanceMinor: openingMinor,
          balanceAsOf: monthStart,
          localZone: timezone,
          pool: 'Onboarding opening',
          choices: sources.movements.map((movement) => MovementChoice(
                key: movement.key,
                revision: movement.revision,
                role: 'later',
                actualAt: movement.actualAt,
              )),
        ),
        isAccessCurrent: isAccessCurrent);
    if (!preview.canConfirm) {
      throw StateError(
          'Opening checkpoint needs review: ${preview.blockers.join(', ')}');
    }
    await checkpoint.confirm(
        preview: preview,
        operationKey: 'onboarding-checkpoint:$flowId',
        isAccessCurrent: isAccessCurrent);
  }
}
