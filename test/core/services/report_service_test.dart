import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/models/financial_report.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/services/report_access.dart';
import 'package:budget_buddy/core/services/report_service.dart';
import 'package:budget_buddy/core/services/report_delivery.dart';
import 'package:budget_buddy/features/vault/models/savings_vault.dart';
import 'package:budget_buddy/features/vault/models/vault_entry.dart';
import 'package:budget_buddy/core/services/report_calculation.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import '../../features/medical/repositories/medical_test_harness.dart';

class TestReportFileTarget implements ReportFileTarget {
  int calls = 0;
  final started = Completer<void>();
  Completer<ReportDeliveryResult>? gate;
  @override
  Future<ReportDeliveryResult> save(
      String name, String mime, Uint8List bytes) async {
    calls++;
    if (!started.isCompleted) started.complete();
    return gate == null ? ReportDeliveryResult.saved : await gate!.future;
  }

  @override
  Future<ReportDeliveryResult> share(
          String name, String mime, Uint8List bytes, Rect? origin) =>
      save(name, mime, bytes);
}

void main() {
  late Isar db;
  late Directory dir;
  late ReportService service;
  int serial = 0;
  setUp(() async {
    await Isar.initializeIsarCore(download: false);
    dir = await Directory.systemTemp.createTemp('report_test_');
    db = await Isar.open(MedicalTestHarness.schemas,
        directory: dir.path, name: 'reports_${serial++}');
    await db.writeTxn(() async {
      await db.userProfiles.put(UserProfile()
        ..id = 1
        ..name = 'Me'
        ..primaryCurrency = PrimaryCurrency.huf
        ..monthlyAvailableAmount = 100000
        ..defaultNetSalary = 100000
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026));
      await db.monthlyBudgets.put(MonthlyBudget()
        ..id = 1
        ..profileId = 1
        ..yearMonth = '2026-10'
        ..baseAvailableAmount = 100000
        ..openingBalanceConfirmed = true
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026));
      await db.expenses.put(Expense(
          profileId: 1,
          yearMonth: '2026-10',
          title: 'Rice',
          amount: 10000,
          currency: 'HUF',
          categoryId: 'food',
          date: DateTime(2026, 10, 26),
          budgetId: 1));
    });
    service = ReportService(db,
        access:
            ReportAccess(db, isUnlocked: (_) => false, assertSession: () {}),
        clock: () => DateTime.utc(2026, 10, 26, 12));
  });
  tearDown(() async {
    await db.close(deleteFromDisk: true);
    await dir.delete(recursive: true);
  });
  ReportRequest request(
          {List<ReportOwner>? owners,
          ReportScope scope = ReportScope.personal}) =>
      ReportRequest(
          scope: scope,
          personalProfileId: 1,
          owners: owners ?? [const ReportOwner.personal(1)],
          firstMonth: '2026-10',
          lastMonth: '2026-10',
          currency: CurrencyCode.huf);
  Future<void> shared(SharedMemberRole role) => db.writeTxn(() async {
        await db.sharedSpaces.put(SharedSpace()
          ..id = 2
          ..name = 'Home'
          ..currency = PrimaryCurrency.huf
          ..defaultIncome = 0
          ..createdByProfileId = 1
          ..createdAt = DateTime(2026));
        await db.sharedMembers.put(SharedMember()
          ..id = 2
          ..sharedSpaceId = 2
          ..profileId = 1
          ..role = role
          ..joinedAt = DateTime(2026));
        await db.monthlyBudgets.put(MonthlyBudget()
          ..id = 2
          ..sharedSpaceId = 2
          ..yearMonth = '2026-10'
          ..baseAvailableAmount = 0
          ..createdAt = DateTime(2026)
          ..updatedAt = DateTime(2026));
      });
  test(
      'frozen snapshot remains unchanged after later edits and generation is read-only',
      () async {
    final before = await db.expenses.count();
    final budgets = await db.monthlyBudgets.count();
    final report = await service.generate(request(), 1);
    expect(report.complete, isTrue);
    expect(report.flow('paid'), 10000);
    expect(report.transactions.single.recordedAt, isNull);
    await db.writeTxn(() async {
      final row = (await db.expenses.where().findFirst())!..amount = 20000;
      await db.expenses.put(row);
    });
    expect(report.flow('paid'), 10000);
    expect((await service.generate(request(), 1)).flow('paid'), 20000);
    expect(await db.expenses.count(), before);
    expect(await db.monthlyBudgets.count(), budgets);
    expect(() => report.transactions.clear(), throwsUnsupportedError);
  });
  test('other personal profile and missing memberships are refused', () async {
    await expectLater(
        service.generate(
            request(
                owners: [const ReportOwner.space(2)], scope: ReportScope.space),
            1),
        throwsStateError);
    await expectLater(service.generate(request(), 99), throwsStateError);
  });
  test('viewer can view but cannot export; owner loss is rechecked at handoff',
      () async {
    await shared(SharedMemberRole.viewer);
    final req =
        request(owners: [const ReportOwner.space(2)], scope: ReportScope.space);
    final viewed = await service.generate(req, 1);
    expect(viewed.canExport, isFalse);
    await expectLater(service.authorizeExport(viewed), throwsStateError);
    await db.writeTxn(() async {
      final row = (await db.sharedMembers.get(2))!
        ..role = SharedMemberRole.owner;
      await db.sharedMembers.put(row);
    });
    final exported = await service.generate(req, 1);
    expect(exported.canExport, isTrue);
    await db.writeTxn(() async {
      await db.sharedMembers.delete(2);
    });
    await expectLater(service.authorizeExport(exported), throwsStateError);
  });
  test('a protected inactive shared context cannot enter a consolidated report',
      () async {
    await shared(SharedMemberRole.owner);
    await db.writeTxn(() async {
      final s = (await db.sharedSpaces.get(2))!..requirePin = true;
      await db.sharedSpaces.put(s);
    });
    await expectLater(
        service.generate(
            request(owners: [
              const ReportOwner.personal(1),
              const ReportOwner.space(2)
            ], scope: ReportScope.consolidated),
            1),
        throwsStateError);
  });
  test('membership loss while rendering prevents any native file handoff',
      () async {
    await shared(SharedMemberRole.owner);
    await db.writeTxn(() async {
      final month = (await db.monthlyBudgets.get(2))!
        ..openingBalanceConfirmed = true;
      await db.monthlyBudgets.put(month);
    });
    final report = await service.generate(
        request(owners: [const ReportOwner.space(2)], scope: ReportScope.space),
        1);
    final target = TestReportFileTarget();
    final delivery = ReportDelivery(
        service: service,
        target: target,
        pdf: (_, __) async {
          await db.writeTxn(() async {
            final m = (await db.sharedMembers.get(2))!
              ..role = SharedMemberRole.viewer;
            await db.sharedMembers.put(m);
          });
          return Uint8List.fromList([37, 80, 68, 70]);
        });
    await expectLater(delivery.deliver(report, ReportFileKind.pdf, share: true),
        throwsStateError);
    expect(target.calls, 0);
  });
  test(
      'only one handoff may be active and native cancellation resets readiness',
      () async {
    final report = await service.generate(request(), 1);
    final target = TestReportFileTarget()
      ..gate = Completer<ReportDeliveryResult>();
    final delivery = ReportDelivery(service: service, target: target);
    final first =
        delivery.deliver(report, ReportFileKind.summaryCsv, share: false);
    await target.started.future;
    await expectLater(
        delivery.deliver(report, ReportFileKind.summaryCsv, share: false),
        throwsStateError);
    target.gate!.complete(ReportDeliveryResult.cancelled);
    expect(await first, ReportDeliveryResult.cancelled);
    target.gate = null;
    expect(
        await delivery.deliver(report, ReportFileKind.transactionsCsv,
            share: false),
        ReportDeliveryResult.saved);
  });
  test(
      'consolidation includes selected space once and excludes other personal owners',
      () async {
    await shared(SharedMemberRole.owner);
    await db.writeTxn(() async {
      await db.expenses.put(Expense(
          profileId: 99,
          yearMonth: '2026-10',
          title: 'Private other owner',
          amount: 99999,
          currency: 'HUF',
          categoryId: 'food',
          date: DateTime(2026, 10, 1),
          budgetId: 1));
      await db.expenses.put(Expense(
          profileId: 1,
          sharedSpaceId: 2,
          yearMonth: '2026-10',
          title: 'Shared purchase',
          amount: 2000,
          currency: 'HUF',
          categoryId: 'food',
          date: DateTime(2026, 10, 1),
          budgetId: 2));
      final month = (await db.monthlyBudgets.get(2))!
        ..openingBalanceConfirmed = true;
      await db.monthlyBudgets.put(month);
    });
    final report = await service.generate(
        request(scope: ReportScope.consolidated, owners: [
          const ReportOwner.personal(1),
          const ReportOwner.space(2)
        ]),
        1);
    expect(report.complete, isTrue);
    expect(report.flow('paid'), 12000);
    expect(report.transactions.map((r) => r.name),
        isNot(contains('Private other owner')));
    expect(report.statements.length, 2);
  });
  test(
      'unconfirmed opening prevents export and missing months do not become zero',
      () async {
    await db.writeTxn(() async {
      final month = (await db.monthlyBudgets.get(1))!
        ..openingBalanceConfirmed = false;
      await db.monthlyBudgets.put(month);
    });
    final report = await service.generate(request(), 1);
    expect(report.complete, isFalse);
    expect(report.requireExportable, throwsStateError);
    final range = ReportRequest(
        scope: ReportScope.personal,
        personalProfileId: 1,
        owners: [const ReportOwner.personal(1)],
        firstMonth: '2026-09',
        lastMonth: '2026-10',
        currency: CurrencyCode.huf);
    final missing = await service.generate(range, 1);
    expect(missing.statements.first.amounts, isEmpty);
    expect(missing.flow('paid'), isNull);
  });
  test(
      'vault endpoint uses the vault currency, not the current profile currency',
      () async {
    await db.writeTxn(() async {
      await db.savingsVaults.put(SavingsVault()
        ..profileId = 1
        ..currency = 'eur'
        ..totalMinor = 10000
        ..lastSweepYearMonth = '2026-10'
        ..updatedAt = DateTime(2026, 10, 1));
      await db.vaultEntrys.put(VaultEntry()
        ..operationKey = 'opening-1'
        ..profileId = 1
        ..kind = 'opening'
        ..amountMinor = 10000
        ..currency = 'eur'
        ..balanceAfterMinor = 10000
        ..createdAt = DateTime(2026, 10, 1));
    });
    final report = await service.generate(request(), 1);
    expect(report.issues, isEmpty);
    expect(report.balances.single.amount, 10000);
    expect(report.balances.single.currency, 'EUR');
    expect(
        report.balances.single.converted,
        reportConvert(10000, CurrencyCode.eur, CurrencyCode.huf, '2026-10',
            RateTableRegistry()));
    expect(report.flow('income'), 100000);
    expect(report.flow('savingsAdded'), 0);
  });
}
