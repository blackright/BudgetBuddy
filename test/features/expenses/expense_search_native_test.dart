import 'package:flutter/foundation.dart' show debugPrint;
import 'dart:io';
import 'package:budget_buddy/core/services/expense_evidence.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/merchant.dart';
import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/services/search_service.dart';
import 'package:budget_buddy/core/services/filter_service.dart';
import 'package:budget_buddy/features/expenses/repositories/expense_search_repository.dart';
import 'package:budget_buddy/features/expenses/repositories/expense_repository.dart';
import 'package:budget_buddy/features/sync/domain/codecs/expense_codec.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import '../medical/repositories/medical_test_harness.dart';

Expense item(int owner, int i) => Expense(
    profileId: owner,
    yearMonth: '2026-10',
    title: 'Coffee $i',
    amount: 1000 + i,
    currency: 'eur',
    categoryId: 'food',
    date: DateTime(2026, 10, 1).add(Duration(minutes: i)),
    budgetId: 1)
  ..notes = 'Office meeting'
  ..tags = ['Work'];

void main() {
  test(
      'search isolates personal/shared owners and rejects absent or revoked members',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    await h.isar.writeTxn(() async {
      await h.isar.expenses
          .putAll([item(1, 1), item(2, 2), item(1, 3)..sharedSpaceId = 9]);
    });
    final repo = ExpenseSearchRepository(h.isar);
    final personal = ContextRef.personal(profileId: 1, yearMonth: '2026-10');
    expect(await repo.watch(personal, 1).first, hasLength(1));
    expect(repo.watch(personal, 2).first, throwsStateError);
    final shared = ContextRef.shared(spaceId: 9, yearMonth: '2026-10');
    await expectLater(repo.watch(shared, 1).first, throwsStateError);
    final member = SharedMember()
      ..sharedSpaceId = 9
      ..profileId = 1
      ..role = SharedMemberRole.viewer
      ..joinedAt = DateTime(2026);
    await h.isar.writeTxn(() => h.isar.sharedMembers.put(member));
    expect(await repo.watch(shared, 1).first, hasLength(1));
    member.revokedAt = DateTime.now();
    await h.isar.writeTxn(() => h.isar.sharedMembers.put(member));
    await expectLater(repo.watch(shared, 1).first, throwsStateError);
  });
  test(
      'merchant normalization, expense metadata and audit commit atomically and roundtrip',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    final context = await h.seedBudget();
    final repo = ExpenseRepository(h.isar, actingProfileId: context.profileId);
    Expense planned(int index) => item(context.profileId, index)
      ..status = ExpenseStatus.planned
      ..paymentMethod = 'card'
      ..paymentEvidenceJson =
          const ExpenseEvidence(profileChosen: true).encode();
    final first = planned(1)
      ..merchantName = '  Corner   SHOP '
      ..paymentMethod = 'card';
    await repo.addExpense(first);
    final second = planned(2)..merchantName = 'corner shop';
    await repo.addExpense(second);
    expect(await h.isar.merchants.count(), 1);
    final stored = await h.isar.expenses.get(first.id);
    expect(stored!.merchantName, 'Corner SHOP');
    expect(stored.merchantSyncGuid, second.merchantSyncGuid);
    expect(
        const ExpenseCodec()
            .fromPayload(const ExpenseCodec().toPayload(stored))
            .tags,
        ['Work']);
    expect(
        await h.isar.auditEvents.filter().objectTypeEqualTo('Merchant').count(),
        1);
    final invalid = planned(3)
      ..merchantName = 'Must rollback'
      ..tags = List.generate(31, (i) => 'tag$i');
    await expectLater(repo.addExpense(invalid), throwsArgumentError);
    expect(await h.isar.expenses.count(), 2);
    expect(await h.isar.merchants.count(), 1);
  });
  test(
      '10,000 persisted expenses: scoped query + combined search/filter under 200ms',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    final repo = ExpenseSearchRepository(h.isar);
    await h.isar.writeTxn(
        () => h.isar.expenses.putAll(List.generate(10000, (i) => item(1, i))));
    final context = ContextRef.personal(profileId: 1, yearMonth: '2026-10');
    final watch = Stopwatch()..start();
    final source = await repo.watch(context, 1).first;
    final result = const SearchService().searchExpenses(
        source,
        'cof off work',
        const ExpenseFilters(currency: 'eur', minimum: 1000, maximum: 10999),
        '2026-10');
    watch.stop();
    expect(result, hasLength(10000));
    // Includes authorization/read/deserialization/filter/sort. No debounce/UI.
    debugPrint(
        'PHASE10_BENCHMARK ${watch.elapsedMicroseconds / 1000} ms; ${Platform.operatingSystem}; Dart ${Platform.version}; 10000 matches');
    expect(watch.elapsedMilliseconds, lessThan(200));
  }, tags: 'performance');
}
