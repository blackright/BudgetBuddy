import 'package:budget_buddy/core/models/live_rate_set.dart';
import '../../support/audit_test_support.dart';
import 'package:budget_buddy/core/models/month_end_run.dart';
import 'package:budget_buddy/features/vault/models/vault_entry.dart';
import 'package:budget_buddy/features/vault/models/savings_vault.dart';
import 'dart:io';
import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/features/sync/domain/codecs/expense_codec.dart';
import 'package:budget_buddy/features/sync/domain/entity_applier.dart';
import 'package:budget_buddy/features/sync/domain/sync_codec.dart';
import 'dart:convert';
import 'package:budget_buddy/core/models/context_kind.dart';
import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/direct_expense_profile.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/month_rate_seal.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/services/refund_service.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/finance/repositories/audit_repository.dart';
import 'package:budget_buddy/features/spaces/repositories/space_role_guard.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:cryptography/cryptography.dart';
import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/features/sync/repositories/sync_recorder.dart';
import 'package:budget_buddy/features/sync/repositories/change_signer.dart';
import 'package:budget_buddy/features/sync/domain/change_signing.dart';

class _FailingAudit extends AuditRepository {
  _FailingAudit(super.isar);
  @override
  Future<void> appendRefund(
      {required Expense expense,
      required Reimbursement refund,
      required String actor,
      required Map<String, Object?> before,
      required Map<String, Object?> after,
      String? contextSyncGuid}) async {
    throw StateError('simulated audit failure');
  }
}

class _FailingRecorder extends SyncRecorder {
  _FailingRecorder(super.isar);
  @override
  Future<ChangeRecord?> recordExpense(Expense expense, {DateTime? now}) async {
    throw StateError('simulated sync journal failure');
  }
}

void main() {
  late Isar isar;
  late Directory directory;
  var serial = 0;
  final now = DateTime.utc(2026, 10, 23);
  setUpAll(() async {
    await Isar.initializeIsarCore(download: false);
  });
  late SyncRecorder auditRecorder;
  setUp(() async {
    directory = Directory.systemTemp.createTempSync('budget_buddy_refunds_');
    isar = await Isar.open([
      UserProfileSchema,
      MonthlyBudgetSchema,
      ExpenseSchema,
      ReimbursementSchema,
      BudgetProfileSchema,
      MonthEndRunSchema,
      DirectExpenseProfileSchema,
      IncomeSourceSchema,
      VaultEntrySchema,
      SavingsVaultSchema,
      AuditEventSchema,
      SharedSpaceSchema,
      SharedMemberSchema,
      IdentitySchema,
      MonthRateSealSchema,
      LiveRateSetSchema,
      ChangeRecordSchema,
      SchemaMigrationStampSchema
    ], directory: directory.path, name: 'refund_${serial++}');
    auditRecorder = await auditTestRecorder(isar);
    await isar.writeTxn(() async {
      await isar.userProfiles.put(UserProfile()
        ..id = 1
        ..name = 'Owner'
        ..primaryCurrency = PrimaryCurrency.huf
        ..monthlyAvailableAmount = 0
        ..defaultNetSalary = 110000
        ..createdAt = now
        ..updatedAt = now);
      await isar.monthlyBudgets.put(MonthlyBudget()
        ..id = 1
        ..profileId = 1
        ..yearMonth = '2026-10'
        ..baseAvailableAmount = 0
        ..createdAt = now
        ..updatedAt = now);
      await isar.budgetProfiles.put(BudgetProfile()
        ..id = 1
        ..profileId = 1
        ..yearMonth = '2026-10'
        ..name = 'Food'
        ..allocation = 100000
        ..spent = 130000
        ..createdAt = now
        ..updatedAt = now);
      await isar.expenses.put(Expense(
          id: 1,
          profileId: 1,
          yearMonth: '2026-10',
          title: 'Purchase',
          amount: 130000,
          currency: 'huf',
          categoryId: 'food',
          date: now,
          paidAt: now,
          budgetId: 1,
          budgetProfileId: 1));
    });
  });
  tearDown(() async {
    // Only the isolated, explicitly opened test database is removed.
    await isar.close(deleteFromDisk: true);
    final root = Directory.systemTemp.absolute.path;
    final target = directory.absolute.path;
    if (!target.startsWith('$root${Platform.pathSeparator}') ||
        !target
            .split(Platform.pathSeparator)
            .last
            .startsWith('budget_buddy_refunds_')) {
      throw StateError(
          'Refusing to delete a directory outside this test fixture.');
    }
    await directory.delete(recursive: true);
  });
  RefundService service(
          {ContextRef? context,
          int actor = 1,
          AuditRepository? audit,
          SyncRecorder? recorder}) =>
      RefundService(isar,
          context: context ??
              ContextRef.personal(profileId: 1, yearMonth: '2026-10'),
          actingProfileId: actor,
          rates: RateTableRegistry(),
          audit: audit,
          syncRecorder: recorder ?? auditRecorder);

  test('refund, status, profile cache and complete audit are saved together',
      () async {
    final api = service();
    final quote = await api.quote(1);
    expect(quote.impactFor(25000).deficitReduction, 20000);
    await api.record(
        expenseId: 1,
        amount: 25000,
        operationId: 'refund-one',
        note: 'Returned item');
    final expense = (await isar.expenses.get(1))!;
    expect(expense.amount, 130000);
    expect(expense.status, ExpenseStatus.partiallyReimbursed);
    expect((await isar.budgetProfiles.get(1))!.spent, 105000);
    expect((await isar.budgetProfiles.get(1))!.allocation, 100000);
    final after = await api.quote(1);
    expect(after.remainingMinor, 105000);
    expect(after.spent, 105000);
    final event = (await isar.auditEvents
            .filter()
            .actionEqualTo('expense.refund')
            .findAll())
        .single;
    expect(event.action, 'expense.refund');
    expect(event.userIdentity, 'profile:1');
    expect(event.hash, hasLength(64));
    expect(jsonDecode(event.previousValue!)['deficit'], 20000);
    expect(jsonDecode(event.newValue!)['borrowed'], 5000);
    expect(jsonDecode(event.newValue!)['refundSyncGuid'], 'refund-one');
    final derived = (await isar.auditEvents
            .filter()
            .actionEqualTo('borrowing.deficit.change')
            .findAll())
        .single;
    expect(derived.previousValue, contains('20000'));
    expect(derived.newValue, contains('5000'));
  });
  test('retry is idempotent; changed payload with the same key is rejected',
      () async {
    final api = service();
    await api.record(expenseId: 1, amount: 25000, operationId: 'same');
    await api.record(expenseId: 1, amount: 25000, operationId: 'same');
    expect(await isar.reimbursements.count(), 1);
    expect(
        await isar.auditEvents.filter().actionEqualTo('expense.refund').count(),
        1);
    expect(
        await isar.auditEvents
            .filter()
            .actionEqualTo('borrowing.deficit.change')
            .count(),
        1);
    await expectLater(
        api.record(expenseId: 1, amount: 5000, operationId: 'same'),
        throwsA(isA<RefundException>()));
  });
  test('concurrent submissions cannot exceed the remaining original payment',
      () async {
    final api = service();
    final results = await Future.wait(['a', 'b'].map((id) async {
      try {
        await api.record(expenseId: 1, amount: 100000, operationId: id);
        return true;
      } on RefundException {
        return false;
      }
    }));
    expect(results.where((r) => r), hasLength(1));
    expect(await isar.reimbursements.count(), 1);
    expect(
        await isar.auditEvents.filter().actionEqualTo('expense.refund').count(),
        1);
    expect(
        await isar.auditEvents
            .filter()
            .actionEqualTo('borrowing.deficit.change')
            .count(),
        1);
  });
  test('separate legitimate partial refunds and final remainder are allowed',
      () async {
    final api = service();
    await api.record(expenseId: 1, amount: 10000, operationId: 'a');
    await api.record(expenseId: 1, amount: 10000, operationId: 'b');
    await api.record(expenseId: 1, amount: 110000, operationId: 'c');
    expect((await api.quote(1)).remainingMinor, 0);
    expect((await isar.expenses.get(1))!.status, ExpenseStatus.reimbursed);
    expect((await isar.budgetProfiles.get(1))!.spent, 0);
    await expectLater(api.record(expenseId: 1, amount: 1, operationId: 'd'),
        throwsA(isA<RefundException>()));
  });
  test('legacy fully-returned status cannot be refunded again without a ledger',
      () async {
    await isar.writeTxn(() async {
      final expense = (await isar.expenses.get(1))!
        ..status = ExpenseStatus.reimbursed;
      await isar.expenses.put(expense);
    });
    expect((await service().quote(1)).remainingMinor, 0);
    await expectLater(
        service().record(expenseId: 1, amount: 1, operationId: 'legacy'),
        throwsA(isA<RefundException>()));
    expect(await isar.reimbursements.count(), 0);
  });

  test('existing reimbursements consume the same refundable balance', () async {
    await isar.writeTxn(() async {
      await isar.reimbursements.put(Reimbursement(
          profileId: 1,
          expenseId: 1,
          originYearMonth: '2026-10',
          amount: 120000,
          currency: 'huf',
          date: now));
    });
    expect((await service().quote(1)).remainingMinor, 10000);
    await expectLater(
        service().record(expenseId: 1, amount: 10001, operationId: 'a'),
        throwsA(isA<RefundException>()));
  });
  test('audit failure rolls back the refund, status and spending cache',
      () async {
    await expectLater(
        service(audit: _FailingAudit(isar))
            .record(expenseId: 1, amount: 25000, operationId: 'a'),
        throwsStateError);
    expect(await isar.reimbursements.count(), 0);
    expect(await isar.auditEvents.count(), 0);
    expect((await isar.expenses.get(1))!.status, ExpenseStatus.paid);
    expect((await isar.budgetProfiles.get(1))!.spent, 130000);
  });
  test('another personal profile or month cannot refund this expense',
      () async {
    for (final api in [
      service(actor: 2),
      service(
          context: ContextRef.personal(profileId: 2, yearMonth: '2026-10'),
          actor: 2),
      service(context: ContextRef.personal(profileId: 1, yearMonth: '2026-09'))
    ]) {
      await expectLater(api.record(expenseId: 1, amount: 1, operationId: 'x'),
          throwsA(isA<RefundException>()));
    }
    expect(await isar.reimbursements.count(), 0);
  });
  for (final status in [ExpenseStatus.planned, ExpenseStatus.cancelled]) {
    test('$status is not refundable', () async {
      await isar.writeTxn(() async {
        final e = (await isar.expenses.get(1))!..status = status;
        await isar.expenses.put(e);
      });
      await expectLater(service().quote(1), throwsA(isA<RefundException>()));
    });
  }
  test('medical expenses remain on the insurer workflow', () async {
    await isar.writeTxn(() async {
      final e = (await isar.expenses.get(1))!..type = ExpenseType.medical;
      await isar.expenses.put(e);
    });
    await expectLater(service().quote(1), throwsA(isA<RefundException>()));
  });
  test('unsupported stored return currency fails closed', () async {
    await isar.writeTxn(() async {
      await isar.reimbursements.put(Reimbursement(
          profileId: 1,
          expenseId: 1,
          originYearMonth: '2026-10',
          amount: 1,
          currency: 'unknown',
          date: now));
    });
    await expectLater(
        service().record(expenseId: 1, amount: 1, operationId: 'x'),
        throwsA(isA<RefundException>()));
    expect(await isar.reimbursements.count(), 1);
    expect(await isar.auditEvents.count(), 0);
  });

  test('direct profile and Main expenses restore reserve without borrowing',
      () async {
    await isar.writeTxn(() async {
      await isar.budgetProfiles.clear();
      await isar.directExpenseProfiles.put(DirectExpenseProfile()
        ..id = 7
        ..profileId = 1
        ..yearMonth = '2026-10'
        ..name = 'Emergency'
        ..spent = 130000
        ..expenseCount = 1
        ..createdAt = now
        ..updatedAt = now);
      final e = (await isar.expenses.get(1))!..budgetProfileId = 7;
      await isar.expenses.put(e);
    });
    final api = service();
    final before = (await api.quote(1)).impactFor(25000);
    expect(before.deficitReduction, 20000);
    expect(before.borrowingReduction, 0);
    await api.record(expenseId: 1, amount: 25000, operationId: 'direct');
    expect((await isar.directExpenseProfiles.get(7))!.spent, 105000);
    await isar.writeTxn(() async {
      await isar.directExpenseProfiles.clear();
      final e = (await isar.expenses.get(1))!
        ..budgetProfileId = null
        ..financialProfileType = null
        ..financialProfileSyncGuid = null;
      await isar.expenses.put(e);
    });
    final main = (await api.quote(1)).impactFor(10000);
    expect(main.borrowedBefore, 0);
    expect(main.borrowedAfter, 0);
    await api.record(expenseId: 1, amount: 10000, operationId: 'main');
    expect((await api.quote(1)).remainingMinor, 95000);
  });

  for (final primary in PrimaryCurrency.values) {
    test('$primary refund persists exact units in the original currency',
        () async {
      await isar.writeTxn(() async {
        final user = (await isar.userProfiles.get(1))!
          ..primaryCurrency = primary;
        await isar.userProfiles.put(user);
        final e = (await isar.expenses.get(1))!
          ..currency = primary.name
          ..amount = 2345;
        await isar.expenses.put(e);
      });
      final row = await service()
          .record(expenseId: 1, amount: 45, operationId: 'precision');
      expect(row.currency, primary.name);
      expect(row.amount, 45);
      expect((await service().quote(1)).remainingMinor, 2300);
      expect((await isar.expenses.get(1))!.amount, 2345);
    });
  }

  test('ambiguous budget/direct numeric IDs fail without guessing or writing',
      () async {
    await isar.writeTxn(() async {
      await isar.directExpenseProfiles.put(DirectExpenseProfile()
        ..id = 1
        ..profileId = 1
        ..yearMonth = '2026-10'
        ..name = 'Collision'
        ..createdAt = now
        ..updatedAt = now);
    });
    await expectLater(
        service().record(expenseId: 1, amount: 25000, operationId: 'ambiguous'),
        throwsA(isA<RefundException>()
            .having((e) => e.message, 'message', contains('ambiguous'))));
    expect(await isar.reimbursements.count(), 0);
    expect(await isar.auditEvents.count(), 0);
    expect((await isar.budgetProfiles.get(1))!.spent, 130000);
  });

  for (final type in [
    FinancialProfileType.budget,
    FinancialProfileType.direct
  ]) {
    test('explicit $type identity separates colliding ID 1 during refund',
        () async {
      await isar.writeTxn(() async {
        await isar.directExpenseProfiles.put(DirectExpenseProfile()
          ..id = 1
          ..profileId = 1
          ..yearMonth = '2026-10'
          ..name = 'Direct'
          ..spent = 130000
          ..createdAt = now
          ..updatedAt = now);
      });
      final budget = (await isar.budgetProfiles.get(1))!;
      final direct = (await isar.directExpenseProfiles.get(1))!;
      await service().assignProfile(
          expenseId: 1,
          profileId: 1,
          profileType: type,
          syncGuid: type == FinancialProfileType.budget
              ? budget.syncGuid
              : direct.syncGuid);
      await service().record(expenseId: 1, amount: 25000, operationId: 'typed');
      expect((await isar.budgetProfiles.get(1))!.spent,
          type == FinancialProfileType.budget ? 105000 : 130000);
      expect((await isar.directExpenseProfiles.get(1))!.spent,
          type == FinancialProfileType.direct ? 105000 : 130000);
      expect((await isar.expenses.get(1))!.financialProfileType, type);
    });
  }

  test(
      'step 23 backfills unique identities, preserves ambiguity and historic data',
      () async {
    await isar.writeTxn(() async {
      await isar.directExpenseProfiles.put(DirectExpenseProfile()
        ..id = 1
        ..profileId = 1
        ..yearMonth = '2026-10'
        ..name = 'Collision'
        ..createdAt = now
        ..updatedAt = now);
      final copy = Expense(
          id: 2,
          profileId: 1,
          yearMonth: '2026-10',
          title: 'Unique',
          amount: 100,
          currency: 'huf',
          categoryId: 'food',
          date: now,
          budgetId: 1,
          budgetProfileId: 7);
      await isar.expenses.put(copy);
      await isar.directExpenseProfiles.put(DirectExpenseProfile()
        ..id = 7
        ..profileId = 1
        ..yearMonth = '2026-10'
        ..name = 'Unique Direct'
        ..createdAt = now
        ..updatedAt = now);
      await isar.changeRecords.put(ChangeRecord()
        ..entityType = 'Expense'
        ..entityLocalId = 1
        ..contextKind = ContextKind.shared
        ..contextLocalId = 1
        ..authorIdentityId = 'a'
        ..hlcMillis = 1
        ..hlcCounter = 0
        ..deviceId = 'test'
        ..op = 'upsert'
        ..payload = '{}'
        ..signature = 'sig'
        ..createdAt = now);
    });
    await writeSchemaVersion(isar, 22);
    await runSchemaMigrations(isar);
    await runSchemaMigrations(isar);
    expect(await readSchemaVersion(isar), schemaVersion);
    expect((await isar.expenses.get(1))!.financialProfileType, isNull);
    expect((await isar.expenses.get(1))!.amount, 130000);
    expect((await isar.expenses.get(2))!.financialProfileType,
        FinancialProfileType.direct);
    expect((await isar.expenses.get(2))!.financialProfileSyncGuid,
        (await isar.directExpenseProfiles.get(7))!.syncGuid);
    expect(await isar.changeRecords.count(), 1);
  });

  test(
      'profile repair validates ownership and leaves ambiguous rows untouched on failure',
      () async {
    await expectLater(
        service().assignProfile(
            expenseId: 1,
            profileId: 1,
            profileType: FinancialProfileType.direct,
            syncGuid: 'missing'),
        throwsA(isA<RefundException>()));
    expect((await isar.expenses.get(1))!.financialProfileType, isNull);
    await expectLater(
        service(actor: 2).assignProfile(
            expenseId: 1, profileId: null, profileType: null, syncGuid: null),
        throwsA(isA<RefundException>()));
  });

  test(
      'sync carries portable profile identity and resolves a different local ID',
      () async {
    final budget = (await isar.budgetProfiles.get(1))!;
    final expense = (await isar.expenses.get(1))!
      ..financialProfileType = FinancialProfileType.budget
      ..financialProfileSyncGuid = budget.syncGuid;
    final json = const ExpenseCodec().toJson(expense);
    expect(json.containsKey('budgetProfileId'), isFalse);
    await isar.writeTxn(() async {
      await isar.budgetProfiles.delete(1);
      budget.id = 42;
      await isar.budgetProfiles.put(budget);
      final id =
          await const ExpenseApplier().upsert(isar, canonicalJsonEncode(json));
      expect((await isar.expenses.get(id))!.budgetProfileId, 42);
    });
  });

  Future<void> shared(SharedMemberRole role) async {
    await isar.writeTxn(() async {
      await isar.sharedSpaces.put(SharedSpace()
        ..id = 1
        ..name = 'Our space'
        ..currency = PrimaryCurrency.huf
        ..defaultIncome = 110000
        ..createdByProfileId = 1
        ..createdAt = now);
      await isar.sharedMembers.put(SharedMember()
        ..sharedSpaceId = 1
        ..profileId = 1
        ..role = role
        ..joinedAt = now);
      final e = (await isar.expenses.get(1))!
        ..profileId = 0
        ..sharedSpaceId = 1;
      await isar.expenses.put(e);
      final p = (await isar.budgetProfiles.get(1))!
        ..profileId = null
        ..sharedSpaceId = 1;
      await isar.budgetProfiles.put(p);
      final month = (await isar.monthlyBudgets.get(1))!
        ..profileId = null
        ..sharedSpaceId = 1;
      await isar.monthlyBudgets.put(month);
    });
  }

  test('shared refund journals financial and audit signed changes atomically',
      () async {
    await shared(SharedMemberRole.owner);
    final algorithm = Ed25519();
    final keys = await algorithm.newKeyPair();
    final signer =
        Ed25519ChangeSigner(authorIdentityId: 'test-author', keyPair: keys);
    final api = service(
        context: ContextRef.shared(spaceId: 1, yearMonth: '2026-10'),
        recorder: SyncRecorder(isar, signer: signer));
    await api.record(expenseId: 1, amount: 25000, operationId: 'signed');
    final changes = await isar.changeRecords.where().findAll();
    expect(changes.map((r) => r.entityType).toSet(),
        {'Expense', 'Reimbursement', 'AuditEvent'});
    final publicKey = await keys.extractPublicKey();
    for (final row in changes) {
      expect(
          await algorithm.verify(changeCanonicalBytes(row),
              signature:
                  Signature(base64Decode(row.signature), publicKey: publicKey)),
          isTrue);
      final payload = jsonDecode(row.payload) as Map<String, dynamic>;
      expect(payload['sharedSpaceSyncGuid'],
          (await isar.sharedSpaces.get(1))!.syncGuid);
    }
    final returned =
        changes.singleWhere((r) => r.entityType == 'Reimbursement');
    expect(jsonDecode(returned.payload)['expenseSyncGuid'],
        (await isar.expenses.get(1))!.syncGuid);
  });

  test('sync journal failure also rolls back refund and audit evidence',
      () async {
    await shared(SharedMemberRole.owner);
    final api = service(
        context: ContextRef.shared(spaceId: 1, yearMonth: '2026-10'),
        recorder: _FailingRecorder(isar));
    await expectLater(
        api.record(expenseId: 1, amount: 25000, operationId: 'rollback'),
        throwsStateError);
    expect(await isar.reimbursements.count(), 0);
    expect(await isar.auditEvents.count(), 0);
    expect((await isar.budgetProfiles.get(1))!.spent, 130000);
  });

  for (final role in [SharedMemberRole.owner, SharedMemberRole.editor]) {
    test('shared $role uses its own reserve and records shared context',
        () async {
      await shared(role);
      final api =
          service(context: ContextRef.shared(spaceId: 1, yearMonth: '2026-10'));
      expect((await api.quote(1)).reserve, 10000);
      await api.record(expenseId: 1, amount: 25000, operationId: 'shared');
      final row = (await isar.reimbursements.where().findAll()).single;
      expect(row.sharedSpaceId, 1);
      expect(row.profileId, 0);
      final audit = (await isar.auditEvents
              .filter()
              .actionEqualTo('expense.refund')
              .findAll())
          .single;
      expect(audit.sharedSpaceId, 1);
      expect(audit.profileId, isNull);
    });
  }
  test('viewer and sealed shared month cannot save refunds', () async {
    await shared(SharedMemberRole.viewer);
    final api =
        service(context: ContextRef.shared(spaceId: 1, yearMonth: '2026-10'));
    await expectLater(
        api.record(expenseId: 1, amount: 1, operationId: 'viewer'),
        throwsA(isA<UnauthorizedSpaceAction>()));
    await isar.writeTxn(() async {
      final member = (await isar.sharedMembers.where().findAll()).single
        ..role = SharedMemberRole.owner;
      await isar.sharedMembers.put(member);
      await isar.monthRateSeals.put(MonthRateSeal()
        ..yearMonth = '2026-10'
        ..asOf = now
        ..fetchedAt = now
        ..updatedAt = now);
    });
    await expectLater(
        api.record(expenseId: 1, amount: 1, operationId: 'sealed'),
        throwsA(isA<UnauthorizedSpaceAction>()));
    expect(await isar.reimbursements.count(), 0);
  });
}
