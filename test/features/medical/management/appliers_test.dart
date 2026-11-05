import 'package:flutter_test/flutter_test.dart';

import 'package:budget_buddy/core/models/medical_appeal.dart';
import 'package:budget_buddy/core/models/medical_approval.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/features/sync/domain/codecs/medical_appeal_codec.dart';
import 'package:budget_buddy/features/sync/domain/codecs/medical_claim_activity_codec.dart';
import 'package:budget_buddy/features/sync/domain/entity_applier.dart';
import 'package:budget_buddy/features/sync/domain/sync_codec.dart';
import '../repositories/medical_test_harness.dart';

import 'fixtures.dart' as fixtures;

void main() {
  test('shared activity and appeal appliers keep the bill owner', () async {
    final harness = await MedicalTestHarness.create();
    addTearDown(harness.close);
    final spaceId = await harness.createSpace();
    final context = await harness.seedBudget(spaceId: spaceId);
    final seeded = await fixtures.seedManagementBill(
      harness.isar,
      profileId: 0,
      sharedSpaceId: spaceId,
      budgetId: context.budgetId,
      currency: 'usd',
      yearMonth: context.yearMonth,
    );
    final space = (await harness.isar.sharedSpaces.get(spaceId))!;

    final activity = MedicalClaimActivity()
      ..billGuid = seeded.bill.syncGuid
      ..profileId = 0
      ..sharedSpaceId = spaceId
      ..yearMonth = context.yearMonth
      ..kind = 'submitted'
      ..reason = ''
      ..currency = 'usd'
      ..recordedAt = DateTime.utc(2026, 4, 1)
      ..operationIdentity = 'activity:${seeded.bill.syncGuid}'
      ..inputFingerprint = 'fp';

    final activityJson = const MedicalClaimActivityCodec().toJson(activity)
      ..['sharedSpaceSyncGuid'] = space.syncGuid;
    final activityId = await harness.isar.writeTxn(() =>
        const MedicalClaimActivityApplier()
            .upsert(harness.isar, canonicalJsonEncode(activityJson)));
    final storedActivity =
        (await harness.isar.medicalClaimActivitys.get(activityId))!;
    expect(storedActivity.sharedSpaceId, spaceId);
    expect(storedActivity.profileId, 0);

    final appeal = MedicalAppeal()
      ..billGuid = seeded.bill.syncGuid
      ..profileId = 0
      ..sharedSpaceId = spaceId
      ..submittedAt = DateTime.utc(2026, 4, 2)
      ..recordedAt = DateTime.utc(2026, 4, 2)
      ..operationIdentity = 'appeal:${seeded.bill.syncGuid}';
    final appealJson = const MedicalAppealCodec().toJson(appeal)
      ..['sharedSpaceSyncGuid'] = space.syncGuid;
    final appealId = await harness.isar.writeTxn(() =>
        const MedicalAppealApplier()
            .upsert(harness.isar, canonicalJsonEncode(appealJson)));
    final storedAppeal = (await harness.isar.medicalAppeals.get(appealId))!;
    expect(storedAppeal.sharedSpaceId, spaceId);
    expect(storedAppeal.profileId, isNull);
  });
}
