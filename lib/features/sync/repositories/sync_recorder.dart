import 'package:isar/isar.dart';

import '../../../core/models/change_record.dart';
import '../../../core/models/context_kind.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/insurance_profile.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/medical_service_type.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/models/paired_context.dart';
import '../../../core/models/shared_member.dart';
import '../../../core/models/shared_space.dart';
import '../../expenses/models/reimbursement.dart';
import '../domain/change_signing.dart';
import '../domain/codecs/expense_codec.dart';
import '../domain/codecs/family_member_codec.dart';
import '../domain/codecs/insurance_profile_codec.dart';
import '../domain/codecs/medical_bill_codec.dart';
import '../domain/codecs/medical_provider_codec.dart';
import '../domain/codecs/medical_service_type_codec.dart';
import '../domain/codecs/monthly_budget_codec.dart';
import '../domain/codecs/reimbursement_codec.dart';
import '../domain/codecs/shared_member_codec.dart';
import '../domain/codecs/shared_space_codec.dart';
import '../domain/hlc.dart';
import 'change_signer.dart';

/// The seam that appends a signed [ChangeRecord] to the change-log on every
/// write to a **paired shared context** (research R3, FR-006).
///
/// Feature code (spaces/finance/medical repositories) does not change: the
/// recorder is handed the just-written row and, when a [ChangeSigner] is attached
/// *and* the context is paired, appends a canonical, signed record. When no
/// signer is available (before onboarding) or the context is unpaired, the call
/// is a no-op — 011 behaviour is unchanged.
///
/// **Transaction contract**: [record] never opens its own transaction. Callers
/// that already hold a write transaction (the repositories do) call it inside;
/// direct callers (tests) must wrap the call in `isar.writeTxn`.
class SyncRecorder {
  SyncRecorder(
    this._isar, {
    ChangeSigner? signer,
    HlcClock? clock,
    DateTime Function()? wallClock,
  })  : _signer = signer,
        _clock = clock ?? HlcClock(deviceId: ''),
        _wallClock = wallClock ?? DateTime.now;

  final Isar _isar;
  final ChangeSigner? _signer;
  final HlcClock _clock;
  final DateTime Function() _wallClock;

  /// Whether recording can happen at all (a signer is attached).
  bool get enabled => _signer != null;

  /// The attached signer, or `null` while recording is inert. Exposed so the
  /// spaces data layer can author signed, versioned membership rows with the same
  /// identity (and HLC) that signs the rest of the change-log (T045,
  /// `role-authorization.md` §2).
  ChangeSigner? get signer => _signer;

  /// The HLC generator for change ordering; paired with [signer] so a
  /// membership's `SharedMember.version` shares the change-log's HLC.
  HlcClock get clock => _clock;

  /// Appends an `upsert` record for [entityType]/[entityLocalId] when the
  /// context is paired. Returns the record, or `null` when skipped.
  Future<ChangeRecord?> record({
    required ContextKind contextKind,
    required int contextLocalId,
    required String entityType,
    required int entityLocalId,
    required String payload,
    DateTime? now,
  }) =>
      _append(
        contextKind: contextKind,
        contextLocalId: contextLocalId,
        entityType: entityType,
        entityLocalId: entityLocalId,
        op: 'upsert',
        payload: payload,
        now: now,
      );

  /// Appends a retained `delete` tombstone (empty payload) (FR-006/007).
  Future<ChangeRecord?> recordDelete({
    required ContextKind contextKind,
    required int contextLocalId,
    required String entityType,
    required int entityLocalId,
    DateTime? now,
  }) =>
      _append(
        contextKind: contextKind,
        contextLocalId: contextLocalId,
        entityType: entityType,
        entityLocalId: entityLocalId,
        op: 'delete',
        payload: '',
        now: now,
      );

  /// Records a [SharedSpace] upsert (space settings changes).
  Future<ChangeRecord?> recordSpace(SharedSpace space, {DateTime? now}) =>
      record(
        contextKind: ContextKind.shared,
        contextLocalId: space.id,
        entityType: 'SharedSpace',
        entityLocalId: space.id,
        payload: const SharedSpaceCodec().toPayload(space),
        now: now,
      );

  /// Records a [SharedMember] upsert (join / role change / transfer).
  Future<ChangeRecord?> recordMember(SharedMember member, {DateTime? now}) =>
      record(
        contextKind: ContextKind.shared,
        contextLocalId: member.sharedSpaceId,
        entityType: 'SharedMember',
        entityLocalId: member.id,
        payload: const SharedMemberCodec().toPayload(member),
        now: now,
      );

  /// Records a [SharedMember] removal tombstone (remove / leave).
  Future<ChangeRecord?> recordMemberRemoved(
    SharedMember member, {
    DateTime? now,
  }) =>
      recordDelete(
        contextKind: ContextKind.shared,
        contextLocalId: member.sharedSpaceId,
        entityType: 'SharedMember',
        entityLocalId: member.id,
        now: now,
      );

  /// Records a [SharedSpace] removal tombstone (space delete).
  Future<ChangeRecord?> recordSpaceRemoved(
    SharedSpace space, {
    DateTime? now,
  }) =>
      recordDelete(
        contextKind: ContextKind.shared,
        contextLocalId: space.id,
        entityType: 'SharedSpace',
        entityLocalId: space.id,
        now: now,
      );

  /// Records a [MonthlyBudget] upsert (budget/income change for a shared month).
  ///
  /// A personal budget (`sharedSpaceId == null`) is not exchanged, so it is a
  /// no-op.
  Future<ChangeRecord?> recordBudget(
    MonthlyBudget budget, {
    DateTime? now,
  }) async {
    final spaceId = budget.sharedSpaceId;
    if (spaceId == null) return null;
    return record(
      contextKind: ContextKind.shared,
      contextLocalId: spaceId,
      entityType: 'MonthlyBudget',
      entityLocalId: budget.id,
      payload: const MonthlyBudgetCodec().toPayload(budget),
      now: now,
    );
  }

  /// Records a [MonthlyBudget] removal tombstone.
  Future<ChangeRecord?> recordBudgetRemoved(
    MonthlyBudget budget, {
    DateTime? now,
  }) async {
    final spaceId = budget.sharedSpaceId;
    if (spaceId == null) return null;
    return recordDelete(
      contextKind: ContextKind.shared,
      contextLocalId: spaceId,
      entityType: 'MonthlyBudget',
      entityLocalId: budget.id,
      now: now,
    );
  }

  /// Records an [Expense] upsert (a shared-space expense).
  Future<ChangeRecord?> recordExpense(
    Expense expense, {
    DateTime? now,
  }) async {
    final spaceId = expense.sharedSpaceId;
    if (spaceId == null) return null;
    return record(
      contextKind: ContextKind.shared,
      contextLocalId: spaceId,
      entityType: 'Expense',
      entityLocalId: expense.id,
      payload: const ExpenseCodec().toPayload(expense),
      now: now,
    );
  }

  /// Records an [Expense] removal tombstone.
  Future<ChangeRecord?> recordExpenseRemoved(
    Expense expense, {
    DateTime? now,
  }) async {
    final spaceId = expense.sharedSpaceId;
    if (spaceId == null) return null;
    return recordDelete(
      contextKind: ContextKind.shared,
      contextLocalId: spaceId,
      entityType: 'Expense',
      entityLocalId: expense.id,
      now: now,
    );
  }

  /// Records a [Reimbursement] upsert.
  Future<ChangeRecord?> recordReimbursement(
    Reimbursement reimbursement, {
    DateTime? now,
  }) async {
    final spaceId = reimbursement.sharedSpaceId;
    if (spaceId == null) return null;
    return record(
      contextKind: ContextKind.shared,
      contextLocalId: spaceId,
      entityType: 'Reimbursement',
      entityLocalId: reimbursement.id,
      payload: const ReimbursementCodec().toPayload(reimbursement),
      now: now,
    );
  }

  /// Records a [Reimbursement] removal tombstone.
  Future<ChangeRecord?> recordReimbursementRemoved(
    Reimbursement reimbursement, {
    DateTime? now,
  }) async {
    final spaceId = reimbursement.sharedSpaceId;
    if (spaceId == null) return null;
    return recordDelete(
      contextKind: ContextKind.shared,
      contextLocalId: spaceId,
      entityType: 'Reimbursement',
      entityLocalId: reimbursement.id,
      now: now,
    );
  }

  /// Records a [MedicalBill] upsert.
  Future<ChangeRecord?> recordMedicalBill(
    MedicalBill bill, {
    DateTime? now,
  }) async {
    final spaceId = bill.sharedSpaceId;
    if (spaceId == null) return null;
    return record(
      contextKind: ContextKind.shared,
      contextLocalId: spaceId,
      entityType: 'MedicalBill',
      entityLocalId: bill.id,
      payload: const MedicalBillCodec().toPayload(bill),
      now: now,
    );
  }

  /// Records a [MedicalBill] removal tombstone.
  Future<ChangeRecord?> recordMedicalBillRemoved(
    MedicalBill bill, {
    DateTime? now,
  }) async {
    final spaceId = bill.sharedSpaceId;
    if (spaceId == null) return null;
    return recordDelete(
      contextKind: ContextKind.shared,
      contextLocalId: spaceId,
      entityType: 'MedicalBill',
      entityLocalId: bill.id,
      now: now,
    );
  }

  /// Records a [FamilyMember] upsert (shared directory row).
  Future<ChangeRecord?> recordFamilyMember(
    FamilyMember member, {
    DateTime? now,
  }) async {
    final spaceId = member.sharedSpaceId;
    if (spaceId == null) return null;
    return record(
      contextKind: ContextKind.shared,
      contextLocalId: spaceId,
      entityType: 'FamilyMember',
      entityLocalId: member.id,
      payload: const FamilyMemberCodec().toPayload(member),
      now: now,
    );
  }

  /// Records a [FamilyMember] removal tombstone.
  Future<ChangeRecord?> recordFamilyMemberRemoved(
    FamilyMember member, {
    DateTime? now,
  }) async {
    final spaceId = member.sharedSpaceId;
    if (spaceId == null) return null;
    return recordDelete(
      contextKind: ContextKind.shared,
      contextLocalId: spaceId,
      entityType: 'FamilyMember',
      entityLocalId: member.id,
      now: now,
    );
  }

  /// Records a [MedicalProvider] upsert (shared directory row).
  Future<ChangeRecord?> recordMedicalProvider(
    MedicalProvider provider, {
    DateTime? now,
  }) async {
    final spaceId = provider.sharedSpaceId;
    if (spaceId == null) return null;
    return record(
      contextKind: ContextKind.shared,
      contextLocalId: spaceId,
      entityType: 'MedicalProvider',
      entityLocalId: provider.id,
      payload: const MedicalProviderCodec().toPayload(provider),
      now: now,
    );
  }

  /// Records a [MedicalProvider] removal tombstone.
  Future<ChangeRecord?> recordMedicalProviderRemoved(
    MedicalProvider provider, {
    DateTime? now,
  }) async {
    final spaceId = provider.sharedSpaceId;
    if (spaceId == null) return null;
    return recordDelete(
      contextKind: ContextKind.shared,
      contextLocalId: spaceId,
      entityType: 'MedicalProvider',
      entityLocalId: provider.id,
      now: now,
    );
  }

  /// Records a [MedicalServiceType] upsert (shared directory row).
  Future<ChangeRecord?> recordMedicalServiceType(
    MedicalServiceType serviceType, {
    DateTime? now,
  }) async {
    final spaceId = serviceType.sharedSpaceId;
    if (spaceId == null) return null;
    return record(
      contextKind: ContextKind.shared,
      contextLocalId: spaceId,
      entityType: 'MedicalServiceType',
      entityLocalId: serviceType.id,
      payload: const MedicalServiceTypeCodec().toPayload(serviceType),
      now: now,
    );
  }

  /// Records a [MedicalServiceType] removal tombstone.
  Future<ChangeRecord?> recordMedicalServiceTypeRemoved(
    MedicalServiceType serviceType, {
    DateTime? now,
  }) async {
    final spaceId = serviceType.sharedSpaceId;
    if (spaceId == null) return null;
    return recordDelete(
      contextKind: ContextKind.shared,
      contextLocalId: spaceId,
      entityType: 'MedicalServiceType',
      entityLocalId: serviceType.id,
      now: now,
    );
  }

  /// Records an [InsuranceProfile] upsert (shared plan settings).
  Future<ChangeRecord?> recordInsuranceProfile(
    InsuranceProfile profile, {
    DateTime? now,
  }) async {
    final spaceId = profile.sharedSpaceId;
    if (spaceId == null) return null;
    return record(
      contextKind: ContextKind.shared,
      contextLocalId: spaceId,
      entityType: 'InsuranceProfile',
      entityLocalId: profile.id,
      payload: const InsuranceProfileCodec().toPayload(profile),
      now: now,
    );
  }

  /// Records an [InsuranceProfile] removal tombstone.
  Future<ChangeRecord?> recordInsuranceProfileRemoved(
    InsuranceProfile profile, {
    DateTime? now,
  }) async {
    final spaceId = profile.sharedSpaceId;
    if (spaceId == null) return null;
    return recordDelete(
      contextKind: ContextKind.shared,
      contextLocalId: spaceId,
      entityType: 'InsuranceProfile',
      entityLocalId: profile.id,
      now: now,
    );
  }

  Future<ChangeRecord?> _append({
    required ContextKind contextKind,
    required int contextLocalId,
    required String entityType,
    required int entityLocalId,
    required String op,
    required String payload,
    DateTime? now,
  }) async {
    final signer = _signer;
    if (signer == null) return null;

    final paired = await _isar.pairedContexts
        .filter()
        .contextKindEqualTo(contextKind)
        .contextLocalIdEqualTo(contextLocalId)
        .activeEqualTo(true)
        .findFirst();
    if (paired == null) return null;

    final clock = now ?? _wallClock();
    final hlc = _clock.tick(clock);
    final record = ChangeRecord()
      ..contextKind = contextKind
      ..contextLocalId = contextLocalId
      ..entityType = entityType
      ..entityLocalId = entityLocalId
      ..op = op
      ..payload = payload
      ..hlcMillis = hlc.millis
      ..hlcCounter = hlc.counter
      ..deviceId = hlc.deviceId
      ..authorIdentityId = signer.authorIdentityId
      ..createdAt = clock;
    record.signature = await signer.sign(changeCanonicalBytes(record));
    await _isar.changeRecords.put(record);
    return record;
  }
}
