import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/providers/clock_provider.dart';
import 'package:budget_buddy/core/services/medical_receipt_service.dart';
import 'package:budget_buddy/features/identity/providers/device_auth_session.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import 'package:budget_buddy/features/security/domain/lock_state.dart';
import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:budget_buddy/features/medical/providers/medical_receipt_provider.dart';
import 'package:budget_buddy/features/medical/repositories/medical_repository.dart';
import '../../support/receipt_financial_harness.dart';

class _Session extends DeviceAuthSession {
  @override
  NativeAuthSnapshot build() => const NativeAuthSnapshot(
      generation: 7,
      binding: NativeAccessBinding(key: 'phase-a-test'),
      authenticated: true);
  @override
  bool isCurrent(int generation) =>
      state.authenticated && state.generation == generation;
  void expire() {
    state = NativeAuthSnapshot(generation: 8, binding: state.binding);
  }
}

class _Lock extends LockController {
  @override
  LockSnapshot build() => const LockSnapshot();
  @override
  void lockNow() {
    state = LockSnapshot(
        subject: LockSubject.profile(id: 1, name: 'test'),
        state: LockState.locked);
  }
}

class _Clock extends ClockNotifier {
  _Clock() {
    state = DateTime(2026, 10, 30);
  }
}

/// Delayed read simulates a transaction finishing after a context switch.
class _DelayedRepository extends MedicalRepository {
  _DelayedRepository(super.db);
  final reads = <Completer<MedicalHistoryBatch>>[];
  final checks = <bool Function()>[];
  @override
  Future<MedicalHistoryBatch> readInboxViewData(ContextRef context,
      {required bool Function() isAccessCurrent}) {
    final next = Completer<MedicalHistoryBatch>();
    reads.add(next);
    checks.add(isAccessCurrent);
    return next.future;
  }
}

void main() {
  late ReceiptFinancialHarness h;
  late ProviderContainer container;
  final selected =
      StateProvider<ContextRef>((ref) => throw UnimplementedError());
  ProviderContainer create(
      {MedicalRepository? repository, bool canEdit = true}) {
    IsarHelper.instance = h.db;
    return ProviderContainer(overrides: [
      selected.overrideWith((ref) => h.context()),
      budgetContextProvider.overrideWith((ref) => ref.watch(selected)),
      actingProfileIdProvider.overrideWithValue(h.ownerId),
      deviceAuthSessionProvider.overrideWith(_Session.new),
      lockControllerProvider.overrideWith(_Lock.new),
      activeContextCanEditProvider.overrideWithValue(canEdit),
      clockProvider.overrideWith((ref) => _Clock()),
      medicalRepositoryProvider.overrideWithValue(
          repository ?? MedicalRepository(h.db, actingProfileId: h.ownerId)),
    ]);
  }

  setUp(() async {
    h = await ReceiptFinancialHarness.create();
  });
  tearDown(() async {
    container.dispose();
    await h.close();
  });
  Future<MedicalBill> seed() async {
    final expense = h.expense()
      ..type = ExpenseType.medical
      ..status = ExpenseStatus.planned;
    final bill = MedicalBill()
      ..profileId = h.ownerId
      ..yearMonth = '2026-10'
      ..currency = 'huf'
      ..billedAmount = 10000
      ..state = MedicalBillState.planned;
    await h.db.writeTxn(() async {
      expense.id = await h.db.expenses.put(expense);
      bill.linkedExpenseId = expense.id;
      bill.id = await h.db.medicalBills.put(bill);
    });
    return bill;
  }

  Future<void> until(bool Function() predicate) async {
    for (var i = 0; i < 100; i++) {
      if (predicate()) return;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    fail('Provider condition did not become true within one second.');
  }

  MedicalHistoryBatch empty() =>
      MedicalHistoryBatch(bills: [], histories: {}, issues: {}, blockers: []);

  test('one batch stream reacts to expense changes and lock hides old data',
      () async {
    final bill = await seed();
    container = create();
    final sub =
        container.listen(medicalBillViewStatesProvider, (before, after) {});
    addTearDown(sub.close);
    await until(() => container.read(medicalBillViewStatesProvider).hasValue);
    expect(
        container
            .read(medicalBillViewStatesProvider)
            .requireValue[bill.id]!
            .providerLabel,
        'Provider not paid');
    await h.db.writeTxn(() async {
      final expense = (await h.db.expenses.get(bill.linkedExpenseId!))!;
      expense.status = ExpenseStatus.paid;
      await h.db.expenses.put(expense);
    });
    await until(() =>
        container
            .read(medicalBillViewStatesProvider)
            .valueOrNull?[bill.id]
            ?.providerLabel ==
        'Provider paid');
    (container.read(lockControllerProvider.notifier) as _Lock).lockNow();
    final locked = container.read(medicalBillViewStatesProvider);
    expect(locked.hasError, true);
    expect(locked.valueOrNull, isNull);
  });
  test('pending old context cannot publish data into new month', () async {
    final repository = _DelayedRepository(h.db);
    container = create(repository: repository);
    final sub =
        container.listen(medicalBillViewStatesProvider, (before, after) {});
    addTearDown(sub.close);
    await until(() => repository.reads.length == 1);
    container.read(selected.notifier).state = h.context('2026-11');
    expect(container.read(medicalBillViewStatesProvider).valueOrNull, isNull);
    await until(() => repository.reads.length == 2);
    expect(repository.checks.first(), false);
    repository.reads.first.complete(empty());
    repository.reads.last.complete(empty());
    await until(() => container.read(medicalBillViewStatesProvider).hasValue);
    expect(container.read(medicalBillViewStatesProvider).requireValue, isEmpty);
  });
  test('last listener disposal invalidates in-flight access callback',
      () async {
    final repository = _DelayedRepository(h.db);
    container = create(repository: repository);
    final sub =
        container.listen(medicalBillViewStatesProvider, (before, after) {});
    await until(() => repository.reads.isNotEmpty);
    expect(repository.checks.single(), true);
    sub.close();
    await container.pump();
    expect(repository.checks.single(), false);
    repository.reads.single.complete(empty());
    await container.pump();
  });
  test('previously loaded data is cleared while a new context is loading',
      () async {
    final repository = _DelayedRepository(h.db);
    container = create(repository: repository);
    final sub =
        container.listen(medicalBillViewStatesProvider, (before, after) {});
    addTearDown(sub.close);
    await until(() => repository.reads.length == 1);
    repository.reads.first.complete(empty());
    await until(() => container.read(medicalBillViewStatesProvider).hasValue);
    container.read(selected.notifier).state = h.context('2026-11');
    expect(container.read(medicalBillViewStatesProvider).isLoading, true);
    expect(container.read(medicalBillViewStatesProvider).valueOrNull, isNull);
    await until(() => repository.reads.length == 2);
    repository.reads.last.complete(empty());
    await until(() => container.read(medicalBillViewStatesProvider).hasValue);
  });
  test('disposed native read access error is not emitted to a new context',
      () async {
    final repository = _DelayedRepository(h.db);
    container = create(repository: repository);
    final sub =
        container.listen(medicalBillViewStatesProvider, (before, after) {});
    addTearDown(sub.close);
    await until(() => repository.reads.length == 1);
    container.read(selected.notifier).state = h.context('2026-11');
    container.read(medicalBillViewStatesProvider);
    await until(() => repository.reads.length == 2);
    repository.reads.first
        .completeError(const MedicalReceiptException('accessChanged'));
    repository.reads.last.complete(empty());
    await until(() => container.read(medicalBillViewStatesProvider).hasValue);
    expect(container.read(medicalBillViewStatesProvider).hasError, false);
  });
  test('expired native session and wrong-owner batch publish no values',
      () async {
    final repository = _DelayedRepository(h.db);
    container = create(repository: repository);
    final sub =
        container.listen(medicalBillViewStatesProvider, (before, after) {});
    addTearDown(sub.close);
    await until(() => repository.reads.isNotEmpty);
    repository.reads.single.complete(MedicalHistoryBatch(
      bills: [
        MedicalBill()
          ..profileId = h.ownerId + 10
          ..yearMonth = '2026-10'
      ],
      histories: {},
      issues: {},
      blockers: [],
    ));
    await until(() => container.read(medicalBillViewStatesProvider).hasError);
    expect(container.read(medicalBillViewStatesProvider).valueOrNull, isNull);
    (container.read(deviceAuthSessionProvider.notifier) as _Session).expire();
    expect(container.read(medicalBillViewStatesProvider).valueOrNull, isNull);
    expect(repository.checks.single(), false);
  });
  test(
      'readiness error remains error and cannot supply cached empty-ready data',
      () async {
    final repository = _DelayedRepository(h.db);
    container = create(repository: repository, canEdit: false);
    final sub =
        container.listen(medicalBillViewStatesProvider, (before, after) {});
    addTearDown(sub.close);
    await until(() => repository.reads.isNotEmpty);
    repository.reads.single
        .completeError(const MedicalReceiptException('accessChanged'));
    await until(() => container.read(medicalBillViewStatesProvider).hasError);
    expect(container.read(medicalBillViewStatesProvider).valueOrNull, isNull);
  });
  test('read-only provider preserves facts but exposes no writable action',
      () async {
    final bill = await seed();
    container = create(canEdit: false);
    final sub =
        container.listen(medicalBillViewStatesProvider, (before, after) {});
    addTearDown(sub.close);
    await until(() => container.read(medicalBillViewStatesProvider).hasValue);
    final state =
        container.read(medicalBillViewStatesProvider).requireValue[bill.id]!;
    expect(state.providerLabel, 'Provider not paid');
    expect(state.actionEnabled, false);
    expect(state.secondaryActions, isEmpty);
    expect(state.blocker, 'This bill is read-only.');
  });
}
