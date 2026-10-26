import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/services/audit_verify_service.dart';
import 'package:budget_buddy/features/finance/providers/audit_providers.dart';
import 'package:budget_buddy/features/finance/repositories/audit_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../medical/repositories/medical_test_harness.dart';

void main() {
  late MedicalTestHarness h;
  late ProviderContainer container;
  setUp(() async {
    h = await MedicalTestHarness.create();
    IsarHelper.instance = h.isar;
    container = ProviderContainer(overrides: [
      actingProfileIdProvider.overrideWithValue(1),
      budgetContextProvider.overrideWithValue(
          ContextRef.personal(profileId: 1, yearMonth: '2026-10')),
    ]);
    container.listen(auditVerificationProvider, (_, __) {});
    await h.isar.writeTxn(() async {
      for (final id in [1, 2]) {
        await h.isar.userProfiles.put(UserProfile()
          ..id = id
          ..name = 'Owner $id'
          ..primaryCurrency = PrimaryCurrency.huf
          ..monthlyAvailableAmount = 0
          ..createdAt = DateTime(2026)
          ..updatedAt = DateTime(2026));
      }
    });
  });
  tearDown(() async {
    container.dispose();
    await h.close();
  });
  Future<void> waitFor(bool Function() ready) async {
    for (var i = 0; i < 60; i++) {
      if (ready()) return;
      await Future<void>.delayed(const Duration(milliseconds: 15));
    }
    fail('Reactive audit state did not update.');
  }

  Future<AuditEvent> append(int profile) =>
      h.isar.writeTxn(() => AuditRepository(h.isar).append(
          profileId: profile,
          action: 'income.create',
          objectType: 'IncomeSource',
          objectGuid: 'source-$profile',
          after: {'amount': 1}));

  test(
      'verification refreshes on new records, tampering and complete row removal',
      () async {
    await container.read(auditVerificationProvider.future);
    final row = await append(1);
    await waitFor(() =>
        container.read(auditVerificationProvider).valueOrNull?.checked == 1);
    expect(container.read(auditVerificationProvider).requireValue.status,
        AuditStatus.verified);
    await h.isar.writeTxn(() async {
      row.newValue = '{"amount":2}';
      await h.isar.auditEvents.put(row);
    });
    await waitFor(() =>
        container.read(auditVerificationProvider).valueOrNull?.status ==
        AuditStatus.failed);
    await h.isar.writeTxn(() => h.isar.auditEvents.delete(row.id));
    await waitFor(() =>
        container.read(auditVerificationProvider).valueOrNull?.checked == 0);
    expect(container.read(auditVerificationProvider).requireValue.status,
        AuditStatus.incomplete);
  });
  test('profile switch excludes prior owner and unassigned legacy evidence',
      () async {
    await append(1);
    await append(2);
    await h.isar.writeTxn(() => h.isar.auditEvents.put(AuditEvent()
      ..action = 'income.create'
      ..objectType = 'IncomeSource'
      ..userIdentity = 'local-user'
      ..hash = ''
      ..previousHash = ''
      ..timestamp = DateTime(2020)
      ..createdAt = DateTime(2020)));
    await waitFor(
        () => container.read(auditRowsProvider).valueOrNull?.length == 1);
    expect(container.read(auditRowsProvider).requireValue.single.profileId, 1);
    container.updateOverrides([
      actingProfileIdProvider.overrideWithValue(2),
      budgetContextProvider.overrideWithValue(
          ContextRef.personal(profileId: 2, yearMonth: '2026-10')),
    ]);
    await waitFor(() {
      final value = container.read(auditRowsProvider);
      return !value.isLoading &&
          value.valueOrNull?.singleOrNull?.profileId == 2;
    });
    expect(container.read(auditRowsProvider).requireValue.length, 1);
    expect((await container.read(auditVerificationProvider.future)).status,
        AuditStatus.verified);
  });
  test('shared history refuses a nonmember before returning records', () async {
    container.updateOverrides([
      actingProfileIdProvider.overrideWithValue(1),
      budgetContextProvider.overrideWithValue(
          ContextRef.shared(spaceId: 1, yearMonth: '2026-10')),
    ]);
    await waitFor(() => container.read(auditRowsProvider).hasError);
    final denied = container.read(auditRowsProvider);
    expect(denied.error, isA<StateError>());
    expect(denied.valueOrNull ?? const <AuditEvent>[], isEmpty);
  });
}
