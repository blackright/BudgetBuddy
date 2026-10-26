import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:budget_buddy/core/models/app_settings.dart';
import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/transfer.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/finance/repositories/income_source_repository.dart';
import 'package:budget_buddy/features/finance/repositories/transfer_repository.dart';
import 'package:budget_buddy/features/finance/repositories/budget_profile_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import '../medical/repositories/medical_test_harness.dart';

void main() {
  late MedicalTestHarness h;
  setUp(() async {
    h = await MedicalTestHarness.create();
    await h.isar.writeTxn(() async {
      await h.isar.userProfiles.put(UserProfile()
        ..id = 1
        ..name = 'Me'
        ..primaryCurrency = PrimaryCurrency.huf
        ..monthlyAvailableAmount = 0
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026));
      await h.isar.appSettings.put(AppSettings()
        ..transferToggle = true
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026));
    });
  });
  tearDown(() => h.close());
  test(
      'income CRUD retains before/after and refuses another profile atomically',
      () async {
    final repo = IncomeSourceRepository(h.isar, actorId: 1);
    final source = IncomeSource()
      ..profileId = 1
      ..name = 'Salary'
      ..amount = 1000000
      ..currency = 'huf'
      ..frequency = IncomeFrequency.monthly
      ..startDate = DateTime(2026)
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    await repo.save(source);
    source.amount = 2000000;
    await repo.save(source);
    final event = (await h.isar.auditEvents
            .filter()
            .actionEqualTo('income.update')
            .findAll())
        .single;
    expect(event.previousValue, contains('1000000'));
    expect(event.newValue, contains('2000000'));
    source.amount = 3000000;
    await expectLater(IncomeSourceRepository(h.isar, actorId: 2).save(source),
        throwsStateError);
    expect((await h.isar.incomeSources.get(source.id))!.amount, 2000000);
    await repo.delete(source.id);
    expect(await h.isar.auditEvents.count(), 3);
    expect(await h.isar.incomeSources.count(), 0);
  });
  test(
      'transfer retry applies once and an audit failure rolls back both allocation legs',
      () async {
    await h.isar.writeTxn(() async {
      for (final id in [1, 2]) {
        await h.isar.budgetProfiles.put(BudgetProfile()
          ..id = id
          ..profileId = 1
          ..yearMonth = '2026-10'
          ..name = 'Budget $id'
          ..allocation = id == 1 ? 100000 : 50000
          ..createdAt = DateTime(2026)
          ..updatedAt = DateTime(2026));
      }
    });
    Transfer request() => Transfer()
      ..profileId = 1
      ..yearMonth = '2026-10'
      ..sourceProfileId = 1
      ..destinationProfileId = 2
      ..amount = 10000
      ..currency = 'huf'
      ..date = DateTime(2026, 10, 24)
      ..createdAt = DateTime(2026, 10, 24);
    final repo = TransferRepository(h.isar, actorId: 1);
    final transfer = request();
    await repo.apply(transfer);
    await repo.apply(transfer);
    expect((await h.isar.budgetProfiles.get(1))!.allocation, 90000);
    expect((await h.isar.budgetProfiles.get(2))!.allocation, 60000);
    expect(await h.isar.transfers.count(), 1);
    expect(await h.isar.auditEvents.count(), 3);
    await h.isar.writeTxn(() async {
      final tip = (await h.isar.auditEvents
              .filter()
              .objectTypeEqualTo('Transfer')
              .findAll())
          .single;
      tip.hash = 'corrupted';
      await h.isar.auditEvents.put(tip);
    });
    await expectLater(repo.apply(request()), throwsStateError);
    expect((await h.isar.budgetProfiles.get(1))!.allocation, 90000);
    expect((await h.isar.budgetProfiles.get(2))!.allocation, 60000);
    expect(await h.isar.transfers.count(), 1);
    expect(await h.isar.auditEvents.count(), 3);
  });
  test('spending cache refresh does not manufacture a financial action',
      () async {
    final repo = BudgetProfileRepository(h.isar, actorId: 1);
    final profile = BudgetProfile()
      ..profileId = 1
      ..name = 'Food'
      ..yearMonth = '2026-10'
      ..allocation = 100000
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    await repo.save(profile);
    final count = await h.isar.auditEvents.count();
    profile.spent = 5000;
    await repo.save(profile);
    expect(await h.isar.auditEvents.count(), count);
    expect((await h.isar.budgetProfiles.get(profile.id))!.spent, 5000);
  });
}
