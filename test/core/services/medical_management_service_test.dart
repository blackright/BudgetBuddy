import 'package:flutter_test/flutter_test.dart';

import 'package:budget_buddy/core/models/medical_approval.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/services/medical_management_reducer.dart';
import 'package:budget_buddy/core/services/medical_management_service.dart';
import '../../features/medical/repositories/medical_test_harness.dart';

import '../../features/medical/management/fixtures.dart' as fixtures;

void main() {
  test('service loads a visible bill and resolves its stage', () async {
    final harness = await MedicalTestHarness.create();
    addTearDown(harness.close);
    final context = await harness.seedBudget();
    final seeded = await fixtures.seedManagementBill(
      harness.isar,
      profileId: context.profileId,
      budgetId: context.budgetId,
      currency: 'usd',
      yearMonth: context.yearMonth,
    );
    final service = MedicalManagementService(
      db: harness.isar,
      actingProfileId: context.profileId,
    );

    final state =
        await service.load(seeded.bill.id, isAccessCurrent: () => true);

    expect(state.stage, MedicalManagementStage.planned);
    expect(state.primaryAction, MedicalManagementAction.submitRequest);
  });

  test('service refuses revoked access and foreign owners', () async {
    final harness = await MedicalTestHarness.create();
    addTearDown(harness.close);
    final context = await harness.seedBudget();
    final seeded = await fixtures.seedManagementBill(
      harness.isar,
      profileId: context.profileId,
      budgetId: context.budgetId,
      currency: 'usd',
      yearMonth: context.yearMonth,
    );

    final revoked = MedicalManagementService(
      db: harness.isar,
      actingProfileId: context.profileId,
    );
    expect(
      () => revoked.load(seeded.bill.id, isAccessCurrent: () => false),
      throwsA(isA<MedicalManagementException>()
          .having((e) => e.code, 'code', 'accessChanged')),
    );

    final foreign = MedicalManagementService(
      db: harness.isar,
      actingProfileId: context.profileId + 1,
    );
    expect(
      () => foreign.load(seeded.bill.id, isAccessCurrent: () => true),
      throwsA(isA<MedicalManagementException>()
          .having((e) => e.code, 'code', 'wrongOwner')),
    );
  });

  test('ensureOpen refuses closed and Needs-review bills', () async {
    final harness = await MedicalTestHarness.create();
    addTearDown(harness.close);

    final service = MedicalManagementService(
      db: harness.isar,
      actingProfileId: 1,
    );
    final closed = MedicalBill()
      ..profileId = 1
      ..overallStatus = MedicalOverallStatus.closed;
    final review = MedicalBill()
      ..profileId = 1
      ..needsReview = true;

    expect(
      () => service.ensureOpen(closed),
      throwsA(isA<MedicalManagementException>()
          .having((e) => e.code, 'code', 'billClosed')),
    );
    expect(
      () => service.ensureOpen(review),
      throwsA(isA<MedicalManagementException>()
          .having((e) => e.code, 'code', 'legacyFrozen')),
    );
  });

  test('appendActivity writes one append-only row', () async {
    final harness = await MedicalTestHarness.create();
    addTearDown(harness.close);
    final context = await harness.seedBudget();
    final seeded = await fixtures.seedManagementBill(
      harness.isar,
      profileId: context.profileId,
      budgetId: context.budgetId,
      currency: 'usd',
      yearMonth: context.yearMonth,
    );
    final service = MedicalManagementService(
      db: harness.isar,
      actingProfileId: context.profileId,
    );

    final row = await service.appendActivity(
      bill: seeded.bill,
      kind: 'submitted',
      recordedAt: DateTime.utc(2026, 4, 1),
      isAccessCurrent: () => true,
      transactionMonth: '2026-04',
      documentPaths: const ['proof.pdf'],
    );

    expect(row.billGuid, seeded.bill.syncGuid);
    expect(row.profileId, context.profileId);
    expect(row.transactionMonth, '2026-04');
    expect(row.documentPaths, ['proof.pdf']);
    expect(await harness.isar.medicalClaimActivitys.count(), 1);
  });
}
