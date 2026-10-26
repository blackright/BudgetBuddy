import '../../../core/models/merchant.dart';
import '../../../core/models/expense_purchase.dart';
import '../domain/codecs/expense_purchase_codec.dart';
import '../../../core/models/expense_evidence_chunk.dart';
import '../domain/codecs/expense_evidence_chunk_codec.dart';
import '../domain/codecs/merchant_codec.dart';
import '../../../core/models/audit_event.dart';
import '../domain/codecs/audit_event_codec.dart';
import 'package:isar/isar.dart';

import '../../../core/models/change_record.dart';
import '../../../core/models/context_kind.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/budget_profile.dart';
import '../../../core/models/month_end_run.dart';
import '../domain/codecs/budget_profile_codec.dart';
import '../domain/codecs/month_end_run_codec.dart';
import '../../../core/models/direct_expense_profile.dart';
import '../../../core/services/expense_profile_identity.dart';
import '../../../core/models/insurance_profile.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/medical_service_type.dart';
import '../../../core/models/monthly_budget.dart';
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
import '../domain/sync_codec.dart';
import 'change_signer.dart';

/// The seam that appends a signed [ChangeRecord] to the change-log on every
/// write to a **shared context** (research R3, FR-006).
///
/// Feature code (spaces/finance/medical repositories) does not change: the
/// recorder is handed the just-written row and, when a [ChangeSigner] is attached,
/// appends a canonical, signed record — even for a space that has no paired
/// contact yet, so its whole history is journaled and later delivered to whoever
/// is added (T066). Sending is gated separately by the coordinator's active
/// `PairedContext`s, so nothing new leaks. When no signer is available (before
/// onboarding) the call is a no-op — 011 behaviour is unchanged.
///
/// **Identity (015)**: a record carries the row's device-independent `syncGuid`
/// (`entitySyncGuid`) and the owning space's `syncGuid` (`contextSyncGuid`), never
/// the local `Id` (`contracts/entity-identity.md` §1). The typed wrappers also
/// inject each foreign-key **GUID reference** into the payload (the codec is pure
/// and cannot look a reference up), so the receiving applier can resolve it to a
/// local row.
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

  /// Appends an `upsert` record for [entityType]/[entitySyncGuid] when the
  /// context is paired. Returns the record, or `null` when skipped.
  Future<ChangeRecord?> record({
    required ContextKind contextKind,
    required int contextLocalId,
    required String entityType,
    required String entitySyncGuid,
    required String payload,
    int entityLocalId = 0,
    DateTime? now,
  }) =>
      _append(
        contextKind: contextKind,
        contextLocalId: contextLocalId,
        entityType: entityType,
        entityLocalId: entityLocalId,
        entitySyncGuid: entitySyncGuid,
        op: 'upsert',
        payload: payload,
        now: now,
      );

  /// Appends a retained `delete` tombstone (empty payload) (FR-006/007).
  Future<ChangeRecord?> recordDelete({
    required ContextKind contextKind,
    required int contextLocalId,
    required String entityType,
    required String entitySyncGuid,
    int entityLocalId = 0,
    DateTime? now,
  }) =>
      _append(
        contextKind: contextKind,
        contextLocalId: contextLocalId,
        entityType: entityType,
        entityLocalId: entityLocalId,
        entitySyncGuid: entitySyncGuid,
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
        entitySyncGuid: space.syncGuid,
        payload: const SharedSpaceCodec().toPayload(space),
        now: now,
      );

  /// Records a [SharedMember] upsert (join / role change / transfer).
  Future<ChangeRecord?> recordMember(
    SharedMember member, {
    DateTime? now,
  }) async {
    final json = const SharedMemberCodec().toJson(member);
    _putRef(
        json, 'sharedSpaceSyncGuid', await _spaceGuid(member.sharedSpaceId));
    return record(
      contextKind: ContextKind.shared,
      contextLocalId: member.sharedSpaceId,
      entityType: 'SharedMember',
      entityLocalId: member.id,
      entitySyncGuid: member.syncGuid,
      payload: canonicalJsonEncode(json),
      now: now,
    );
  }

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
        entitySyncGuid: member.syncGuid,
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
        entitySyncGuid: space.syncGuid,
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
    final json = const MonthlyBudgetCodec().toJson(budget);
    _putRef(json, 'sharedSpaceSyncGuid', await _spaceGuid(spaceId));
    return record(
      contextKind: ContextKind.shared,
      contextLocalId: spaceId,
      entityType: 'MonthlyBudget',
      entityLocalId: budget.id,
      entitySyncGuid: budget.syncGuid,
      payload: canonicalJsonEncode(json),
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
      entitySyncGuid: budget.syncGuid,
      now: now,
    );
  }

  Future<ChangeRecord?> recordBudgetProfile(BudgetProfile profile) async {
    if (profile.sharedSpaceId == null) return null;
    final json = const BudgetProfileCodec().toJson(profile);
    json['sharedSpaceSyncGuid'] = await _spaceGuid(profile.sharedSpaceId!);
    return record(
        contextKind: ContextKind.shared,
        contextLocalId: profile.sharedSpaceId!,
        entityType: 'BudgetProfile',
        entityLocalId: profile.id,
        entitySyncGuid: profile.syncGuid,
        payload: canonicalJsonEncode(json));
  }

  Future<ChangeRecord?> recordMonthEnd(MonthEndRun run) {
    if (run.sharedSpaceId == null) return Future.value(null);
    return record(
        contextKind: ContextKind.shared,
        contextLocalId: run.sharedSpaceId!,
        entityType: 'MonthEndRun',
        entityLocalId: run.id,
        entitySyncGuid: run.syncGuid,
        payload: const MonthEndRunCodec().toPayload(run));
  }

  Future<ChangeRecord?> recordEvidenceChunk(ExpenseEvidenceChunk chunk) async {
    if (chunk.sharedSpaceId == null) return null;
    final json = const ExpenseEvidenceChunkCodec().toJson(chunk);
    json['sharedSpaceSyncGuid'] = await _spaceGuid(chunk.sharedSpaceId!);
    return record(
        contextKind: ContextKind.shared,
        contextLocalId: chunk.sharedSpaceId!,
        entityType: 'ExpenseEvidenceChunk',
        entityLocalId: chunk.id,
        entitySyncGuid: chunk.syncGuid,
        payload: canonicalJsonEncode(json));
  }

  Future<ChangeRecord?> recordMerchant(Merchant merchant) async {
    if (merchant.sharedSpaceId == null) return null;
    final json = const MerchantCodec().toJson(merchant);
    json['sharedSpaceSyncGuid'] = await _spaceGuid(merchant.sharedSpaceId!);
    return record(
        contextKind: ContextKind.shared,
        contextLocalId: merchant.sharedSpaceId!,
        entityType: 'Merchant',
        entityLocalId: merchant.id,
        entitySyncGuid: merchant.syncGuid,
        payload: canonicalJsonEncode(json));
  }

  /// Records an [Expense] upsert (a shared-space expense).
  Future<ChangeRecord?> recordExpense(
    Expense expense, {
    DateTime? now,
  }) async {
    final spaceId = expense.sharedSpaceId;
    if (spaceId == null) return null;
    if (expense.purchaseSyncGuid != null) {
      final purchase = await _isar.expensePurchases
          .filter()
          .syncGuidEqualTo(expense.purchaseSyncGuid!)
          .findFirst();
      if (purchase == null) throw StateError('Purchase is missing.');
      final items = <Map<String, Object?>>[];
      for (final guid in purchase.itemGuids) {
        final row =
            await _isar.expenses.filter().syncGuidEqualTo(guid).findFirst();
        if (row == null) throw StateError('Purchase items are incomplete.');
        final item = const ExpenseCodec().toJson(row);
        _putRef(item, 'sharedSpaceSyncGuid', await _spaceGuid(spaceId));
        _putRef(item, 'budgetSyncGuid', await _budgetGuid(row.budgetId));
        items.add(item);
      }
      final json = const ExpensePurchaseCodec().toJson(purchase)
        ..['items'] = items;
      _putRef(json, 'sharedSpaceSyncGuid', await _spaceGuid(spaceId));
      _putRef(json, 'budgetSyncGuid', await _budgetGuid(purchase.budgetId));
      return record(
          contextKind: ContextKind.shared,
          contextLocalId: spaceId,
          entityType: 'ExpensePurchase',
          entityLocalId: purchase.id,
          entitySyncGuid: purchase.syncGuid,
          payload: canonicalJsonEncode(json),
          now: now);
    }
    if (expense.budgetProfileId != null &&
        expense.financialProfileSyncGuid == null) {
      if (!resolveExpenseProfileIdentity(
          expense,
          await _isar.budgetProfiles.where().findAll(),
          await _isar.directExpenseProfiles.where().findAll())) {
        throw StateError('Resolve the expense profile before syncing.');
      }
    }
    if (expense.merchantSyncGuid != null) {
      final merchant = await _isar.merchants
          .filter()
          .syncGuidEqualTo(expense.merchantSyncGuid!)
          .findFirst();
      if (merchant != null && merchant.sharedSpaceId == spaceId) {
        await recordMerchant(merchant);
      }
    }
    final json = const ExpenseCodec().toJson(expense);
    _putRef(json, 'sharedSpaceSyncGuid', await _spaceGuid(spaceId));
    _putRef(json, 'budgetSyncGuid', await _budgetGuid(expense.budgetId));
    return record(
      contextKind: ContextKind.shared,
      contextLocalId: spaceId,
      entityType: 'Expense',
      entityLocalId: expense.id,
      entitySyncGuid: expense.syncGuid,
      payload: canonicalJsonEncode(json),
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
      entityType:
          expense.purchaseSyncGuid == null ? 'Expense' : 'ExpensePurchase',
      entityLocalId: expense.id,
      entitySyncGuid: expense.purchaseSyncGuid ?? expense.syncGuid,
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
    final json = const ReimbursementCodec().toJson(reimbursement);
    _putRef(json, 'sharedSpaceSyncGuid', await _spaceGuid(spaceId));
    _putRef(
        json, 'expenseSyncGuid', await _expenseGuid(reimbursement.expenseId));
    return record(
      contextKind: ContextKind.shared,
      contextLocalId: spaceId,
      entityType: 'Reimbursement',
      entityLocalId: reimbursement.id,
      entitySyncGuid: reimbursement.syncGuid,
      payload: canonicalJsonEncode(json),
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
      entitySyncGuid: reimbursement.syncGuid,
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
    final json = const MedicalBillCodec().toJson(bill);
    _putRef(json, 'sharedSpaceSyncGuid', await _spaceGuid(spaceId));
    _putRef(json, 'linkedExpenseSyncGuid',
        await _expenseGuid(bill.linkedExpenseId));
    _putRef(
      json,
      'familyMemberSyncGuid',
      await _familyMemberGuid(bill.familyMemberId),
    );
    _putRef(json, 'providerSyncGuid', await _providerGuid(bill.providerId));
    _putRef(
      json,
      'serviceTypeSyncGuid',
      await _serviceTypeGuid(bill.serviceTypeId),
    );
    return record(
      contextKind: ContextKind.shared,
      contextLocalId: spaceId,
      entityType: 'MedicalBill',
      entityLocalId: bill.id,
      entitySyncGuid: bill.syncGuid,
      payload: canonicalJsonEncode(json),
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
      entitySyncGuid: bill.syncGuid,
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
    final json = const FamilyMemberCodec().toJson(member);
    _putRef(json, 'sharedSpaceSyncGuid', await _spaceGuid(spaceId));
    return record(
      contextKind: ContextKind.shared,
      contextLocalId: spaceId,
      entityType: 'FamilyMember',
      entityLocalId: member.id,
      entitySyncGuid: member.syncGuid,
      payload: canonicalJsonEncode(json),
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
      entitySyncGuid: member.syncGuid,
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
    final json = const MedicalProviderCodec().toJson(provider);
    _putRef(json, 'sharedSpaceSyncGuid', await _spaceGuid(spaceId));
    return record(
      contextKind: ContextKind.shared,
      contextLocalId: spaceId,
      entityType: 'MedicalProvider',
      entityLocalId: provider.id,
      entitySyncGuid: provider.syncGuid,
      payload: canonicalJsonEncode(json),
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
      entitySyncGuid: provider.syncGuid,
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
    final json = const MedicalServiceTypeCodec().toJson(serviceType);
    _putRef(json, 'sharedSpaceSyncGuid', await _spaceGuid(spaceId));
    return record(
      contextKind: ContextKind.shared,
      contextLocalId: spaceId,
      entityType: 'MedicalServiceType',
      entityLocalId: serviceType.id,
      entitySyncGuid: serviceType.syncGuid,
      payload: canonicalJsonEncode(json),
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
      entitySyncGuid: serviceType.syncGuid,
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
    final json = const InsuranceProfileCodec().toJson(profile);
    _putRef(json, 'sharedSpaceSyncGuid', await _spaceGuid(spaceId));
    return record(
      contextKind: ContextKind.shared,
      contextLocalId: spaceId,
      entityType: 'InsuranceProfile',
      entityLocalId: profile.id,
      entitySyncGuid: profile.syncGuid,
      payload: canonicalJsonEncode(json),
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
      entitySyncGuid: profile.syncGuid,
      now: now,
    );
  }

  // --- back-fill -------------------------------------------------------------

  /// Journals every row of [spaceId] that has no [ChangeRecord] yet (015).
  ///
  /// Rows written while recording was inert — the identity had not unlocked, or
  /// the writer held no recorder — never reached the change-log, so no snapshot
  /// ever carried them: the peer could not materialize the space, and without
  /// the Owner's membership among them its apply-time gate refused every record
  /// as `droppedUnauthorized` (`applied 0 of N`, on every retry, forever — the
  /// two-phone wedge).
  ///
  /// The engine calls this just before it builds an outbound snapshot, so a
  /// device that journalised late still ships its whole history. A row some
  /// identity already journaled is left alone — re-recording a peer's row would
  /// forge authorship — and a second sweep adds nothing (idempotent). Without a
  /// signer it is a no-op, exactly like [record].
  Future<void> backfillContext(int spaceId) async {
    if (_signer == null) return;
    final space = await _isar.sharedSpaces.get(spaceId);
    if (space == null) return;

    // Everything already journalised for this context, by any author.
    final known = {
      for (final record in await _isar.changeRecords
          .filter()
          .contextLocalIdEqualTo(spaceId)
          .and()
          .not()
          .entityTypeEqualTo('ExpenseEvidenceChunk')
          .findAll())
        '${record.entityType}:${record.entitySyncGuid}',
    };
    for (final guid in await _isar.changeRecords
        .filter()
        .contextLocalIdEqualTo(spaceId)
        .entityTypeEqualTo('ExpenseEvidenceChunk')
        .entitySyncGuidProperty()
        .findAll()) {
      known.add('ExpenseEvidenceChunk:$guid');
    }

    final pending = <Future<ChangeRecord?> Function()>[];
    void ifMissing(
      String entityType,
      String syncGuid,
      Future<ChangeRecord?> Function() write,
    ) {
      if (syncGuid.isEmpty) return;
      if (!known.add('$entityType:$syncGuid')) return;
      pending.add(write);
    }

    for (final event in await _isar.auditEvents
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .findAll()) {
      if (event.evidenceJson == null ||
          event.userIdentity != _signer?.authorIdentityId) {
        continue;
      }
      ifMissing(
          'AuditEvent',
          event.syncGuid,
          () => record(
              contextKind: ContextKind.shared,
              contextLocalId: spaceId,
              entityType: 'AuditEvent',
              entitySyncGuid: event.syncGuid,
              entityLocalId: event.id,
              payload: const AuditEventCodec().toPayload(event)));
    }
    for (final merchant in await _isar.merchants
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .findAll()) {
      ifMissing('Merchant', merchant.syncGuid, () => recordMerchant(merchant));
    }
    for (final guid in await _isar.expenseEvidenceChunks
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .syncGuidProperty()
        .findAll()) {
      ifMissing('ExpenseEvidenceChunk', guid, () async {
        final chunk = await _isar.expenseEvidenceChunks
            .filter()
            .syncGuidEqualTo(guid)
            .findFirst();
        return chunk == null ? null : recordEvidenceChunk(chunk);
      });
    }
    ifMissing('SharedSpace', space.syncGuid, () => recordSpace(space));
    for (final member in await _isar.sharedMembers
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .findAll()) {
      ifMissing('SharedMember', member.syncGuid, () => recordMember(member));
    }
    for (final budget in await _isar.monthlyBudgets
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .findAll()) {
      ifMissing('MonthlyBudget', budget.syncGuid, () => recordBudget(budget));
    }
    for (final family in await _isar.familyMembers
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .findAll()) {
      ifMissing(
          'FamilyMember', family.syncGuid, () => recordFamilyMember(family));
    }
    for (final provider in await _isar.medicalProviders
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .findAll()) {
      ifMissing('MedicalProvider', provider.syncGuid,
          () => recordMedicalProvider(provider));
    }
    for (final serviceType in await _isar.medicalServiceTypes
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .findAll()) {
      ifMissing('MedicalServiceType', serviceType.syncGuid,
          () => recordMedicalServiceType(serviceType));
    }
    for (final plan in await _isar.insuranceProfiles
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .findAll()) {
      ifMissing('InsuranceProfile', plan.syncGuid,
          () => recordInsuranceProfile(plan));
    }
    for (final profile in await _isar.budgetProfiles
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .findAll()) {
      ifMissing('BudgetProfile', profile.syncGuid,
          () => recordBudgetProfile(profile));
    }
    for (final run in await _isar.monthEndRuns
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .findAll()) {
      ifMissing('MonthEndRun', run.syncGuid, () => recordMonthEnd(run));
    }
    for (final expense in await _isar.expenses
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .findAll()) {
      ifMissing(
          expense.purchaseSyncGuid == null ? 'Expense' : 'ExpensePurchase',
          expense.purchaseSyncGuid ?? expense.syncGuid,
          () => recordExpense(expense));
    }
    for (final reimbursement in await _isar.reimbursements
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .findAll()) {
      ifMissing('Reimbursement', reimbursement.syncGuid,
          () => recordReimbursement(reimbursement));
    }
    for (final bill in await _isar.medicalBills
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .findAll()) {
      ifMissing('MedicalBill', bill.syncGuid, () => recordMedicalBill(bill));
    }

    if (pending.isEmpty) return; // steady state: nothing to journal, no lock
    await _isar.writeTxn(() async {
      for (final write in pending) {
        await write();
      }
    });
  }

  // --- reference GUID lookups ------------------------------------------------

  static void _putRef(
    Map<String, Object?> json,
    String key,
    String? guid,
  ) {
    if (guid != null && guid.isNotEmpty) json[key] = guid;
  }

  Future<String?> _spaceGuid(int? id) async =>
      id == null ? null : (await _isar.sharedSpaces.get(id))?.syncGuid;

  Future<String?> _budgetGuid(int? id) async =>
      id == null ? null : (await _isar.monthlyBudgets.get(id))?.syncGuid;

  Future<String?> _expenseGuid(int? id) async =>
      id == null ? null : (await _isar.expenses.get(id))?.syncGuid;

  Future<String?> _familyMemberGuid(int? id) async =>
      id == null ? null : (await _isar.familyMembers.get(id))?.syncGuid;

  Future<String?> _providerGuid(int? id) async =>
      id == null ? null : (await _isar.medicalProviders.get(id))?.syncGuid;

  Future<String?> _serviceTypeGuid(int? id) async =>
      id == null ? null : (await _isar.medicalServiceTypes.get(id))?.syncGuid;

  // --- append ----------------------------------------------------------------

  Future<ChangeRecord?> _append({
    required ContextKind contextKind,
    required int contextLocalId,
    required String entityType,
    required int entityLocalId,
    required String entitySyncGuid,
    required String op,
    required String payload,
    DateTime? now,
  }) async {
    final signer = _signer;
    if (signer == null) return null;

    // The signed, wire identity of the context is its space's GUID, not the
    // local id (which differs per device).
    final space = await _isar.sharedSpaces.get(contextLocalId);
    final contextSyncGuid = space?.syncGuid ?? '';

    final clock = now ?? _wallClock();
    final hlc = _clock.tick(clock);
    final record = ChangeRecord()
      ..contextKind = contextKind
      ..contextLocalId = contextLocalId
      ..contextSyncGuid = contextSyncGuid
      ..entityType = entityType
      ..entityLocalId = entityLocalId
      ..entitySyncGuid = entitySyncGuid
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
