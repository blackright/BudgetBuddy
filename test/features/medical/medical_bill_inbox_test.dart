import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_service_type.dart';
import 'package:budget_buddy/core/models/medical_settlement_event.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/providers/clock_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/identity/providers/device_auth_session.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:budget_buddy/features/medical/providers/medical_receipt_provider.dart';
import 'package:budget_buddy/features/medical/presentation/medical_bill_state_resolver.dart';
import 'package:budget_buddy/features/medical/presentation/medical_bill_view_state.dart';
import 'package:budget_buddy/features/medical/repositories/medical_repository.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import '../../support/receipt_financial_harness.dart';

class _Session extends DeviceAuthSession {
  @override
  NativeAuthSnapshot build() => const NativeAuthSnapshot(
      generation: 3,
      binding: NativeAccessBinding(key: 'phase-e'),
      authenticated: true);
  @override
  bool isCurrent(int generation) =>
      state.authenticated && state.generation == generation;
}

class _Lock extends LockController {
  @override
  LockSnapshot build() => const LockSnapshot();
}

class _Clock extends ClockNotifier {
  _Clock() {
    state = DateTime(2026, 11, 15);
  }
}

void main() {
  late ReceiptFinancialHarness h;
  late ProviderContainer container;
  final now = DateTime(2026, 11, 15);
  const resolver = MedicalBillStateResolver();

  setUp(() async {
    h = await ReceiptFinancialHarness.create();
  });
  tearDown(() async {
    container.dispose();
    await h.close();
  });

  ProviderContainer create() {
    IsarHelper.instance = h.db;
    return ProviderContainer(overrides: [
      budgetContextProvider.overrideWithValue(
          ContextRef.personal(profileId: h.ownerId, yearMonth: '2026-11')),
      selectedYearMonthProvider.overrideWith((ref) => '2026-11'),
      actingProfileIdProvider.overrideWithValue(h.ownerId),
      deviceAuthSessionProvider.overrideWith(_Session.new),
      lockControllerProvider.overrideWith(_Lock.new),
      clockProvider.overrideWith((ref) => _Clock()),
      activeContextCanEditProvider.overrideWithValue(true),
      rateRegistryProvider.overrideWithValue(RateTableRegistry()),
      medicalDisplayCurrencyProvider.overrideWithValue(CurrencyCode.huf),
      mainCurrencyProvider.overrideWithValue(CurrencyCode.huf),
      medicalDirectoryProvider.overrideWithValue(
          const MedicalDirectory(members: [], providers: [])),
      medicalServiceTypesProvider
          .overrideWith((ref) => Stream.value(const <MedicalServiceType>[])),
      medicalRepositoryProvider.overrideWithValue(
          MedicalRepository(h.db, actingProfileId: h.ownerId)),
    ]);
  }

  Future<MedicalBill> seedBill({
    required String month,
    int? owner,
    MedicalPaymentMethod method = MedicalPaymentMethod.selfPaid,
    bool providerPaid = false,
    int? approved,
    int? received,
    int billed = 10000,
    String currency = 'huf',
    DateTime? followUp,
  }) async {
    final expense = h.expense(owner: owner, month: month)
      ..type = ExpenseType.medical
      ..amount = (billed * 0.2).round()
      ..status = providerPaid ? ExpenseStatus.paid : ExpenseStatus.planned
      ..paidAt = providerPaid ? DateTime.utc(2026, 9, 10) : null;
    final bill = MedicalBill()
      ..profileId = owner ?? h.ownerId
      ..yearMonth = month
      ..serviceDate = DateTime.utc(2026, 9, 10)
      ..billedAmount = billed
      ..currency = currency
      ..patientSharePercent = 20
      ..paymentMethod = method
      ..followUpDate = followUp
      ..state = providerPaid ? MedicalBillState.paid : MedicalBillState.planned;
    await h.db.writeTxn(() async {
      expense.id = await h.db.expenses.put(expense);
      bill.linkedExpenseId = expense.id;
      bill.id = await h.db.medicalBills.put(bill);
    });
    return bill;
  }

  Future<void> until(bool Function() predicate) async {
    for (var i = 0; i < 200; i++) {
      if (predicate()) return;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    fail('Inbox condition did not become true.');
  }

  Future<MedicalInbox> inbox() async {
    container = create();
    final sub = container.listen(medicalInboxProvider, (_, __) {});
    addTearDown(sub.close);
    await until(() => container.read(medicalInboxProvider).hasValue);
    return container.read(medicalInboxProvider).requireValue;
  }

  test('September open bill stays visible with November selected', () async {
    final september = await seedBill(month: '2026-09');
    final november = await seedBill(month: '2026-11');
    await seedBill(month: '2026-11', owner: h.ownerId + 80);

    final result = await inbox();
    expect(result.items.map((item) => item.bill.id),
        containsAll([september.id, november.id]));
    expect(result.items.any((item) => item.bill.profileId != h.ownerId), false);
    expect(result.allBillsCount, 2);
  });

  test('explicit month and arrangement filters narrow the same resolver data',
      () async {
    final september = await seedBill(month: '2026-09');
    final direct = await seedBill(
        month: '2026-11',
        method: MedicalPaymentMethod.insurerPaid,
        providerPaid: true);
    final result = await inbox();

    container.read(medicalInboxFiltersProvider.notifier).state =
        const MedicalInboxFilters(month: '2026-09');
    await until(() =>
        container.read(medicalInboxProvider).valueOrNull?.items.length == 1);
    expect(
        container.read(medicalInboxProvider).requireValue.items.single.bill.id,
        september.id);

    container.read(medicalInboxFiltersProvider.notifier).state =
        const MedicalInboxFilters(
            month: '2026-11', arrangement: MedicalInboxArrangement.insurerPaid);
    await until(() =>
        container.read(medicalInboxProvider).valueOrNull?.items.length == 1);
    expect(
        container.read(medicalInboxProvider).requireValue.items.single.bill.id,
        direct.id);
    expect(result.allBillsCount, 2);
  });

  test('new bill refreshes the inbox without recreating the provider',
      () async {
    await seedBill(month: '2026-09');
    final result = await inbox();
    expect(result.allBillsCount, 1);

    await seedBill(month: '2026-11');
    await until(() =>
        container.read(medicalInboxProvider).valueOrNull?.allBillsCount == 2);
    expect(container.read(medicalInboxProvider).requireValue.allBillsCount, 2);
  });

  test('settlement write refreshes direct bill state without restart',
      () async {
    final bill = await seedBill(
        month: '2026-11',
        method: MedicalPaymentMethod.insurerPaid,
        providerPaid: true);
    await inbox();
    expect(
        container
            .read(medicalInboxProvider)
            .requireValue
            .items
            .single
            .state
            .headline,
        'Needs review');

    await h.db.writeTxn(() async {
      await h.db.medicalSettlements.put(MedicalSettlementEvent()
        ..profileId = h.ownerId
        ..billGuid = bill.syncGuid
        ..kind = MedicalSettlementKind.insurerProviderSettlement
        ..confirmed = true
        ..effectiveDate = DateTime.utc(2026, 11, 10)
        ..recordedAt = DateTime.utc(2026, 11, 10)
        ..currency = 'huf'
        ..amountMinor = 8000
        ..operationIdentity = 'phase-e-settlement'
        ..inputFingerprint = 'phase-e');
    });
    await until(() =>
        container
            .read(medicalInboxProvider)
            .valueOrNull
            ?.items
            .single
            .state
            .actionLabel ==
        'Record your share');
    expect(
        container
            .read(medicalInboxProvider)
            .requireValue
            .items
            .single
            .state
            .actionLabel,
        'Record your share');
  });

  test('due follow-up is Needs you; future follow-up stays Waiting', () {
    MedicalInboxItem synthetic({
      required int id,
      required bool due,
      required bool waiting,
    }) {
      final bill = MedicalBill()
        ..id = id
        ..profileId = 1
        ..yearMonth = '2026-09'
        ..billedAmount = 10000
        ..currency = 'huf'
        ..patientSharePercent = 20
        ..paymentMethod = MedicalPaymentMethod.selfPaid
        ..state = MedicalBillState.paid
        ..followUpDate = due
            ? now.subtract(const Duration(days: 1))
            : now.add(const Duration(days: 3));
      final state = resolver.resolve(
        MedicalBillFacts(
          billId: id,
          billGuid: 'bill-$id',
          method: MedicalPaymentMethod.selfPaid,
          legacyState: MedicalBillState.paid,
          isShared: false,
          currency: CurrencyCode.huf,
          billedMinor: 10000,
          patientShareMinor: 2000,
          providerPaid: true,
          approvedMinor: waiting ? 8000 : null,
          receivedMinor: waiting ? 0 : null,
          followUp: bill.followUpDate,
        ),
        canEdit: true,
        readiness: MedicalReadiness.ready(),
        now: now,
      );
      return MedicalInboxItem(bill: bill, state: state, providerName: 'Clinic');
    }

    final due = synthetic(id: 1, due: true, waiting: false);
    final future = synthetic(id: 2, due: false, waiting: true);
    final inbox = buildMedicalInbox(
      items: [due, future],
      filters: const MedicalInboxFilters(),
      display: CurrencyCode.huf,
      now: now,
      convert: (money) => money,
    );
    expect(due.state.group, MedicalInboxGroup.needsYou);
    expect(future.state.group, MedicalInboxGroup.waiting);
    expect(inbox.count(MedicalInboxGroup.needsYou), 1);
    expect(inbox.count(MedicalInboxGroup.waiting), 1);
  });

  test('closed outcomes stay distinct and mixed currencies need review', () {
    MedicalInboxItem synthetic({
      required int id,
      required bool shortfall,
      required bool cancelled,
      required String currency,
    }) {
      final bill = MedicalBill()
        ..id = id
        ..profileId = 1
        ..yearMonth = '2026-09'
        ..billedAmount = 10000
        ..currency = currency
        ..patientSharePercent = 20
        ..paymentMethod = MedicalPaymentMethod.selfPaid
        ..state = cancelled
            ? MedicalBillState.paid
            : shortfall
                ? MedicalBillState.finished
                : MedicalBillState.paid;
      final state = resolver.resolve(
        MedicalBillFacts(
          billId: id,
          billGuid: 'bill-$id',
          method: MedicalPaymentMethod.selfPaid,
          legacyState: bill.state,
          isShared: false,
          currency: CurrencyCode.tryParse(currency) ?? CurrencyCode.huf,
          billedMinor: 10000,
          patientShareMinor: 2000,
          providerPaid: !cancelled,
          approvedMinor: 8000,
          receivedMinor: shortfall ? 7000 : 0,
          cancelled: cancelled,
          closed: shortfall,
          shortfallMinor: shortfall ? 1000 : 0,
        ),
        canEdit: true,
        readiness: MedicalReadiness.ready(),
        now: now,
      );
      return MedicalInboxItem(bill: bill, state: state, providerName: 'Clinic');
    }

    final closed =
        synthetic(id: 1, shortfall: true, cancelled: false, currency: 'huf');
    final cancelled =
        synthetic(id: 2, shortfall: false, cancelled: true, currency: 'huf');
    final foreign =
        synthetic(id: 3, shortfall: false, cancelled: false, currency: 'eur');
    final waiting =
        synthetic(id: 4, shortfall: false, cancelled: false, currency: 'huf');
    final inbox = buildMedicalInbox(
      items: [closed, cancelled, foreign, waiting],
      filters: const MedicalInboxFilters(group: MedicalInboxGroup.closed),
      display: CurrencyCode.huf,
      now: now,
      convert: (money) => money.currency == CurrencyCode.eur ? null : money,
    );
    expect(closed.state.headline, 'Closed');
    expect(cancelled.state.headline, 'Claim cancelled');
    expect(cancelled.state.group, MedicalInboxGroup.needsYou);
    expect(inbox.amountsNeedReview, true);
    expect(inbox.approvedStillToReceiveMinor, 8000);
    expect(inbox.allBillsCount, 4);
    expect(inbox.items.any((item) => item.state.headline == 'Closed'), true);
  });
}
