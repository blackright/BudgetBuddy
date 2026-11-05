import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/models/financial_adoption.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/month_rate_seal.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/fx_revision.dart';
import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/services/financial_adoption_service.dart';
import 'package:budget_buddy/core/services/receipt_snapshot_repository.dart';
import '../../support/receipt_financial_harness.dart';
import '../medical/repositories/medical_test_harness.dart';

void main() {
  late ReceiptFinancialHarness h;
  late FinancialAdoptionService service;
  setUp(() async {
    h = await ReceiptFinancialHarness.create();
    service = FinancialAdoptionService(h.db);
  });
  tearDown(() async => h.close());

  Future<AdoptionPreview> preview() => service.preview(
      context: h.context(), actorId: h.ownerId, isAccessCurrent: () => true);

  test('zero is reviewable; save and retry preserve legacy month unchanged',
      () async {
    final before = await h.db.monthlyBudgets.where().exportJson();
    final p = await preview();
    expect(p.currentIncomeMinor, 0);
    final first = await service.confirm(
        preview: p, operationKey: 'one', isAccessCurrent: () => true);
    final again = await service.confirm(
        preview: p, operationKey: 'one', isAccessCurrent: () => true);
    expect(first.guid, again.guid);
    expect(first.status, 'reviewed');
    expect(first.enabledCapabilities, isEmpty);
    expect(await h.db.financialAdoptions.count(), 1);
    expect(await h.db.monthlyBudgets.where().exportJson(), before);
  });

  test('changed source blocks stale confirmation with no adoption write',
      () async {
    final p = await preview();
    await h.db.writeTxn(() async {
      final month = (await h.db.monthlyBudgets.get(h.budgetId))!;
      month.netSalaryOverride = 123;
      await h.db.monthlyBudgets.put(month);
    });
    await expectLater(
        service.confirm(
            preview: p, operationKey: 'stale', isAccessCurrent: () => true),
        throwsA(isA<ReceiptGuardException>()));
    expect(await h.db.financialAdoptions.count(), 0);
  });

  test('lost access rolls back review', () async {
    final p = await preview();
    await expectLater(
        service.confirm(
            preview: p, operationKey: 'lost', isAccessCurrent: () => false),
        throwsA(isA<ReceiptGuardException>()));
    expect(await h.db.financialAdoptions.count(), 0);
  });

  test('new review appends revision and old operation cannot overwrite it',
      () async {
    final p = await preview();
    await service.confirm(
        preview: p, operationKey: 'old', isAccessCurrent: () => true);
    final next = await preview();
    final revision = await service.confirm(
        preview: next, operationKey: 'new', isAccessCurrent: () => true);
    expect(revision.revision, 2);
    await expectLater(
        service.confirm(
            preview: next, operationKey: 'old', isAccessCurrent: () => true),
        throwsA(isA<ReceiptGuardException>()));
    expect(await h.db.financialAdoptions.count(), 2);
  });

  test(
      'explicit zero override wins over sources and fallback, without mutation',
      () async {
    await h.db.writeTxn(() async {
      final month = (await h.db.monthlyBudgets.get(h.budgetId))!
        ..netSalaryOverride = 0;
      await h.db.monthlyBudgets.put(month);
      await h.db.incomeSources.put(IncomeSource()
        ..profileId = h.ownerId
        ..name = 'Salary'
        ..amount = 500000
        ..currency = 'huf'
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
    });
    final p = await preview();
    expect(p.sourcesMinor, 500000);
    expect(p.overrideMinor, 0);
    expect(p.currentIncomeMinor, 0);
    expect(p.canConfirm, isTrue);
  });

  test('missing and closed months block; no fabricated opening or activation',
      () async {
    final missing = await service.preview(
        context: h.context('2026-11'),
        actorId: h.ownerId,
        isAccessCurrent: () => true);
    expect(missing.blockers, contains('missingMonth'));
    await h.db.writeTxn(() async {
      await h.db.monthRateSeals.put(MonthRateSeal()
        ..yearMonth = '2026-10'
        ..closedAt = DateTime.utc(2026, 11)
        ..asOf = DateTime.utc(2026, 11)
        ..fetchedAt = DateTime.utc(2026, 11)
        ..updatedAt = DateTime.utc(2026, 11));
    });
    final p = await preview();
    expect(p.blockers, contains('sealedMonth'));
    await expectLater(
        service.confirm(
            preview: p, operationKey: 'closed', isAccessCurrent: () => true),
        throwsA(isA<ReceiptGuardException>()));
    expect(await h.db.financialAdoptions.count(), 0);
  });

  test('invalid or foreign source requires review rather than guessed funding',
      () async {
    await h.db.writeTxn(() async {
      await h.db.incomeSources.put(IncomeSource()
        ..profileId = h.ownerId
        ..name = 'Foreign'
        ..amount = 10000
        ..currency = 'eur'
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
    });
    expect((await preview()).blockers, contains('foreignIncomeNeedsReview'));
  });

  test('ambiguous source owner and overflowing totals cannot be confirmed',
      () async {
    await h.db.writeTxn(() async {
      await h.db.incomeSources.put(IncomeSource()
        ..profileId = h.ownerId
        ..sharedSpaceId = 999
        ..name = 'Ambiguous'
        ..amount = 0
        ..currency = 'huf'
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
    });
    expect((await preview()).blockers, contains('ambiguousIncomeOwner'));
    await h.db.writeTxn(() async {
      await h.db.incomeSources.clear();
      for (var i = 0; i < 2; i++) {
        await h.db.incomeSources.put(IncomeSource()
          ..profileId = h.ownerId
          ..name = 'Large $i'
          ..amount = fxMoneyBound
          ..currency = 'huf'
          ..createdAt = DateTime.utc(2026)
          ..updatedAt = DateTime.utc(2026));
      }
    });
    final p = await preview();
    expect(p.blockers, contains('invalidMoney'));
    expect(p.sourcesMinor, isNull);
    await expectLater(
        service.confirm(
            preview: p, operationKey: 'overflow', isAccessCurrent: () => true),
        throwsA(isA<ReceiptGuardException>()));
    expect(await h.db.financialAdoptions.count(), 0);
  });

  test('shared owner can review; editor cannot read funding preview or save',
      () async {
    late int spaceId, membershipId;
    await h.db.writeTxn(() async {
      spaceId = await h.db.sharedSpaces.put(SharedSpace()
        ..name = 'Shared fixture'
        ..currency = PrimaryCurrency.huf
        ..createdByProfileId = h.ownerId
        ..createdAt = DateTime.utc(2026));
      membershipId = await h.db.sharedMembers.put(SharedMember()
        ..sharedSpaceId = spaceId
        ..profileId = h.ownerId
        ..role = SharedMemberRole.owner
        ..joinedAt = DateTime.utc(2026));
      await h.db.monthlyBudgets.put(MonthlyBudget()
        ..sharedSpaceId = spaceId
        ..yearMonth = '2026-10'
        ..baseAvailableAmount = 0
        ..openingBalanceConfirmed = true
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
    });
    final context = ContextRef.shared(spaceId: spaceId, yearMonth: '2026-10');
    final p = await service.preview(
        context: context, actorId: h.ownerId, isAccessCurrent: () => true);
    expect(p.canConfirm, isTrue);
    await service.confirm(
        preview: p, operationKey: 'owner', isAccessCurrent: () => true);
    await h.db.writeTxn(() async {
      final member = (await h.db.sharedMembers.get(membershipId))!
        ..role = SharedMemberRole.editor;
      await h.db.sharedMembers.put(member);
    });
    await expectLater(
        service.preview(
            context: context, actorId: h.ownerId, isAccessCurrent: () => true),
        throwsA(isA<ReceiptGuardException>()));
    await expectLater(
        service.confirm(
            preview: p, operationKey: 'demoted', isAccessCurrent: () => true),
        throwsA(isA<ReceiptGuardException>()));
    expect(await h.db.financialAdoptions.count(), 1);
  });

  test('post-write access failure rolls back the newly inserted review',
      () async {
    final p = await preview();
    // Fail at the guard's post-write read, after the fresh in-transaction
    // preview has completed, to exercise actual transaction rollback.
    var calls = 0;
    await expectLater(
        service.confirm(
            preview: p,
            operationKey: 'rollback',
            isAccessCurrent: () => ++calls < 6),
        throwsA(isA<ReceiptGuardException>()));
    expect(await h.db.financialAdoptions.count(), 0);
  });

  test('real pre-adoption schema reopens additively; migration preserves rows',
      () async {
    // Open the old schema list first, not the new collection with an old stamp.
    final name = 'legacy_${h.ownerId}';
    var legacy = await Isar.open(
        MedicalTestHarness.schemas
            .where((schema) => !{
                  'FinancialAdoption',
                  'MedicalApproval',
                  'MedicalClaimActivity',
                  'MedicalClaimClosure',
                  'MoneyReceipt',
                  'ReceiptRevision'
                }.contains(schema.name))
            .toList(),
        directory: h.directory.path,
        name: name);
    try {
      await writeSchemaVersion(legacy, 32);
      await legacy.writeTxn(() async {
        await legacy.userProfiles.put(UserProfile()
          ..id = 1
          ..name = 'Legacy'
          ..primaryCurrency = PrimaryCurrency.huf
          ..monthlyAvailableAmount = 600000
          ..createdAt = DateTime.utc(2026)
          ..updatedAt = DateTime.utc(2026));
        final expense = h.expense();
        expense.fxHistoryJson = FxHistory([
          FxRevision(
            id: 'legacy-booking',
            target: expense.syncGuid,
            context: 'personal:1:2026-10',
            kind: 'expense',
            originalMinor: expense.amount,
            originalCurrency: 'HUF',
            baseMinor: expense.amount,
            baseCurrency: 'HUF',
            numerator: '1',
            denominator: '1',
            source: 'same-currency',
            asOf: '2026-10-28',
            capturedAt: '2026-10-28T10:00:00Z',
            previousHash: '',
          )
        ]).encode();
        await legacy.expenses.put(expense);
        await legacy.sharedSpaces.put(SharedSpace()
          ..name = 'Preserved family'
          ..currency = PrimaryCurrency.huf
          ..createdByProfileId = 1
          ..createdAt = DateTime.utc(2026));
      });
      final before = await legacy.expenses.where().exportJson();
      final profiles = await legacy.userProfiles.where().exportJson();
      final spaces = await legacy.sharedSpaces.where().exportJson();
      await legacy.close();
      legacy = await Isar.open(ReceiptFinancialHarness.schemas,
          directory: h.directory.path, name: name);
      await runSchemaMigrations(legacy);
      await runSchemaMigrations(legacy);
      expect(await readSchemaVersion(legacy), schemaVersion);
      expect(await legacy.expenses.where().exportJson(), before);
      expect(await legacy.userProfiles.where().exportJson(), profiles);
      expect(await legacy.sharedSpaces.where().exportJson(), spaces);
      expect(await legacy.financialAdoptions.count(), 0);
    } finally {
      await legacy.close(deleteFromDisk: true);
    }
  });
}
