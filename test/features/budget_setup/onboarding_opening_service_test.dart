import 'package:budget_buddy/core/models/balance_checkpoint.dart';
import 'package:budget_buddy/core/models/financial_adoption.dart';
import 'package:budget_buddy/features/budget_setup/services/onboarding_opening_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../../support/receipt_financial_harness.dart';

void main() {
  test('onboarding creates one opening adoption and checkpoint idempotently',
      () async {
    final h = await ReceiptFinancialHarness.create();
    addTearDown(h.close);
    final service = OnboardingOpeningService(h.db);

    Future<void> ensure() => service.ensure(
          profileId: h.ownerId,
          yearMonth: '2026-10',
          openingMinor: 600000,
          timezone: 'UTC',
          flowId: 'onboarding-flow',
          isAccessCurrent: () => true,
        );

    await ensure();
    expect(await h.db.financialAdoptions.count(), 1);
    expect(await h.db.balanceCheckpoints.count(), 1);
    final checkpoint = (await h.db.balanceCheckpoints.where().findFirst())!;
    expect(checkpoint.balanceMinor, 600000);

    await ensure();
    expect(await h.db.financialAdoptions.count(), 1);
    expect(await h.db.balanceCheckpoints.count(), 1);
  });
}
