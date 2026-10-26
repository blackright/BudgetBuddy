import '../../../core/models/merchant.dart';
import '../../../core/services/fx_booking_service.dart';
import '../../../core/models/expense_purchase.dart';
import '../../../core/services/purchase_policy.dart';
import 'codecs/expense_purchase_codec.dart';
import '../../../core/models/expense_evidence_chunk.dart';
import '../../../core/services/expense_evidence.dart';
import '../../../core/services/evidence_privacy.dart';
import '../../expenses/repositories/expense_evidence_repository.dart';
import 'codecs/expense_evidence_chunk_codec.dart';
import 'codecs/merchant_codec.dart';
import '../../../core/database/schema_migrations.dart';
import '../../../core/models/audit_event.dart';
import 'codecs/audit_event_codec.dart';
import 'package:isar/isar.dart';

import '../../../core/models/expense.dart';
import '../../../core/models/budget_profile.dart';
import '../../../core/models/month_end_run.dart';
import '../../../core/models/change_record.dart';
import '../../../core/services/month_end_service.dart';
import '../../../core/services/month_end_report.dart';
import 'codecs/budget_profile_codec.dart';
import 'codecs/month_end_run_codec.dart';
import '../../../core/models/direct_expense_profile.dart';
import '../../../core/services/expense_profile_identity.dart';
import '../../../core/models/insurance_profile.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/medical_service_type.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/models/shared_member.dart';
import '../../../core/models/shared_space.dart';
import '../../expenses/models/reimbursement.dart';
import 'codec_support.dart';
import 'codecs/expense_codec.dart';
import 'codecs/family_member_codec.dart';
import 'codecs/insurance_profile_codec.dart';
import 'codecs/medical_bill_codec.dart';
import 'codecs/medical_provider_codec.dart';
import 'codecs/medical_service_type_codec.dart';
import 'codecs/monthly_budget_codec.dart';
import 'codecs/reimbursement_codec.dart';
import 'codecs/shared_member_codec.dart';
import 'codecs/shared_space_codec.dart';
import 'sync_codec.dart';
import 'sync_id_translator.dart';

/// Applies a `ChangeRecord.payload` to the local entity rows — the *write* side
/// of a [`SyncCodec`] (`contracts/sync-protocol.md` §3 step 3).
///
/// A codec turns a row into canonical bytes; an applier turns those bytes back
/// into a row for the local device. Applying goes through Isar directly (the
/// same tables the repositories write), which keeps one storage path even when a
/// remote change wins over a local edit.
///
/// **Identity (015)**: the payload carries the row's own `syncGuid` and refers to
/// other rows by GUID, never by a local `Id` (data-model §3). [upsert] therefore
/// finds the existing local row by `syncGuid` (inserting a fresh row the first
/// time the GUID is seen) and rewrites each GUID reference to a local id via
/// [SyncIdTranslator]. Since the [SyncEngine] applies a batch in dependency order
/// (`data-model` §4 step 2), an upserted row's targets are already local when the
/// reference is resolved; a reference to a row that has not arrived yet is left
/// unset and healed on the next exchange (rule R2).
///
/// **Transaction contract**: [upsert] / [delete] never open their own
/// transaction; the [SyncEngine] calls them inside a single `isar.writeTxn` per
/// record (Isar cannot nest write transactions).
abstract class EntityApplier {
  const EntityApplier();

  /// One of the covered entity class names (data-model §2.6, FR-010).
  String get entityType;

  /// Upserts the decoded entity, returning its local row id.
  Future<int> upsert(Isar isar, String payload);

  /// Removes the entity row (a tombstone application).
  Future<void> delete(Isar isar, int entityLocalId);
}

/// Every applier that can be applied in v1 (mirrors `syncCodecs`).
const List<EntityApplier> entityAppliers = [
  AuditEventApplier(),
  MerchantApplier(),
  ExpenseEvidenceChunkApplier(),
  SharedSpaceApplier(),
  SharedMemberApplier(),
  MonthlyBudgetApplier(),
  BudgetProfileApplier(),
  MonthEndRunApplier(),
  ExpenseApplier(),
  ExpensePurchaseApplier(),
  ReimbursementApplier(),
  MedicalBillApplier(),
  FamilyMemberApplier(),
  MedicalProviderApplier(),
  MedicalServiceTypeApplier(),
  InsuranceProfileApplier(),
];

/// Resolves a [ChangeRecord.entityType] to its applier, or `null` when the type
/// is not applied in v1 (a peer should drop such a record, not crash).
EntityApplier? applierForEntityType(String entityType) {
  for (final applier in entityAppliers) {
    if (applier.entityType == entityType) return applier;
  }
  return null;
}

class ExpenseEvidenceChunkApplier extends EntityApplier {
  const ExpenseEvidenceChunkApplier();
  @override
  String get entityType => 'ExpenseEvidenceChunk';
  @override
  Future<int> upsert(Isar isar, String payload) async {
    final json = canonicalJsonDecode(payload);
    final chunk = const ExpenseEvidenceChunkCodec().fromJson(json);
    validateChunk(chunk);
    chunk.sharedSpaceId = await SyncIdTranslator(isar)
        .resolveLocalContext(json['sharedSpaceSyncGuid'] as String);
    final existing = await isar.expenseEvidenceChunks
        .filter()
        .syncGuidEqualTo(chunk.syncGuid)
        .findFirst();
    if (existing != null) {
      if (existing.sharedSpaceId != chunk.sharedSpaceId ||
          const ExpenseEvidenceChunkCodec().toPayload(existing) !=
              const ExpenseEvidenceChunkCodec().toPayload(chunk)) {
        throw const FormatException('Immutable document content conflicts.');
      }
      return existing.id;
    }
    final expense = await isar.expenses
        .filter()
        .syncGuidEqualTo(chunk.expenseSyncGuid)
        .findFirst();
    final anchor = await isar.expenseEvidenceChunks
        .filter()
        .documentGuidEqualTo(chunk.documentGuid)
        .findFirst();
    var declared = anchor != null &&
        anchor.sharedSpaceId == chunk.sharedSpaceId &&
        anchor.expenseSyncGuid == chunk.expenseSyncGuid &&
        anchor.yearMonth == chunk.yearMonth &&
        anchor.sha256 == chunk.sha256 &&
        anchor.byteLength == chunk.byteLength &&
        anchor.fileName == chunk.fileName &&
        anchor.role == chunk.role &&
        anchor.mediaType == chunk.mediaType;
    if (anchor != null && !declared) {
      throw const FormatException(
          'Document identity belongs to different evidence.');
    }
    if (!declared &&
        expense != null &&
        expense.sharedSpaceId == chunk.sharedSpaceId &&
        expense.yearMonth == chunk.yearMonth) {
      declared = _declares(expense.paymentEvidenceJson, chunk);
    }
    if (!declared) {
      final events = await isar.auditEvents
          .filter()
          .sharedSpaceIdEqualTo(chunk.sharedSpaceId)
          .objectTypeEqualTo('Expense')
          .findAll();
      for (final event in events) {
        for (final raw in [event.previousValue, event.newValue]) {
          if (raw == null) continue;
          try {
            final snapshot = canonicalJsonDecode(raw);
            if (snapshot['syncGuid'] == chunk.expenseSyncGuid &&
                snapshot['yearMonth'] == chunk.yearMonth &&
                _declares(snapshot['paymentEvidenceJson'] as String?, chunk)) {
              declared = true;
            }
          } on Object {
            /* Unrelated legacy snapshots do not establish ownership. */
          }
        }
        if (declared) break;
      }
    }
    if (!declared) {
      throw const FormatException(
          'Document is not declared by this context\'s expense or retained history.');
    }
    return isar.expenseEvidenceChunks.put(chunk);
  }

  bool _declares(String? raw, ExpenseEvidenceChunk chunk) {
    try {
      return ExpenseEvidence.decode(raw)?.documents.any((d) =>
              d.guid == chunk.documentGuid &&
              d.role == chunk.role &&
              d.name == chunk.fileName &&
              d.mediaType == chunk.mediaType &&
              d.length == chunk.byteLength &&
              d.hash == chunk.sha256) ??
          false;
    } on FormatException {
      return false;
    }
  }

  @override
  Future<void> delete(Isar isar, int id) async {
    throw StateError(
        'Evidence versions are retained until whole-owner deletion.');
  }
}

class MerchantApplier extends EntityApplier {
  const MerchantApplier();
  @override
  String get entityType => 'Merchant';
  @override
  Future<int> upsert(Isar isar, String payload) async {
    final json = canonicalJsonDecode(payload);
    final merchant = const MerchantCodec().fromJson(json);
    final existing = await isar.merchants
        .filter()
        .syncGuidEqualTo(merchant.syncGuid)
        .findFirst();
    merchant.id = existing?.id ?? Isar.autoIncrement;
    merchant.sharedSpaceId = await SyncIdTranslator(isar)
        .resolveLocalContext(decodeGuid(json['sharedSpaceSyncGuid']));
    return isar.merchants.put(merchant);
  }

  @override
  Future<void> delete(Isar isar, int id) => isar.merchants.delete(id);
}

class SharedSpaceApplier extends EntityApplier {
  const SharedSpaceApplier();

  @override
  String get entityType => 'SharedSpace';

  @override
  Future<int> upsert(Isar isar, String payload) async {
    final json = canonicalJsonDecode(payload);
    final guid = decodeGuid(json['syncGuid']);
    final existing =
        await isar.sharedSpaces.filter().syncGuidEqualTo(guid).findFirst();
    final space = const SharedSpaceCodec().fromJson(json)
      ..id = existing?.id ?? Isar.autoIncrement;
    return isar.sharedSpaces.put(space);
  }

  @override
  Future<void> delete(Isar isar, int entityLocalId) async {
    await purgeSpaceEvidenceInTxn(isar, entityLocalId);
    await isar.sharedSpaces.delete(entityLocalId);
  }
}

class SharedMemberApplier extends EntityApplier {
  const SharedMemberApplier();

  @override
  String get entityType => 'SharedMember';

  @override
  Future<int> upsert(Isar isar, String payload) async {
    final json = canonicalJsonDecode(payload);
    final guid = decodeGuid(json['syncGuid']);
    final existing =
        await isar.sharedMembers.filter().syncGuidEqualTo(guid).findFirst();
    final member = const SharedMemberCodec().fromJson(json)
      ..id = existing?.id ?? Isar.autoIncrement;
    // `sharedSpaceId` is a non-null `late int`, so an unresolved reference uses
    // 0 as the "not yet known" sentinel (rule R2); the space row normally
    // precedes the membership in dependency order (data-model §4 step 2).
    final spaceGuid = decodeGuidOrNull(json['sharedSpaceSyncGuid']);
    member.sharedSpaceId = spaceGuid == null
        ? 0
        : await SyncIdTranslator(isar).resolveLocalContext(spaceGuid);
    return isar.sharedMembers.put(member);
  }

  @override
  Future<void> delete(Isar isar, int entityLocalId) =>
      isar.sharedMembers.delete(entityLocalId);
}

class MonthlyBudgetApplier extends EntityApplier {
  const MonthlyBudgetApplier();

  @override
  String get entityType => 'MonthlyBudget';

  @override
  Future<int> upsert(Isar isar, String payload) async {
    final json = canonicalJsonDecode(payload);
    final guid = decodeGuid(json['syncGuid']);
    final existing =
        await isar.monthlyBudgets.filter().syncGuidEqualTo(guid).findFirst();
    final budget = const MonthlyBudgetCodec().fromJson(json)
      ..id = existing?.id ?? Isar.autoIncrement
      ..sharedSpaceId = await SyncIdTranslator(isar).resolveLocalEntity(
        'SharedSpace',
        decodeGuidOrNull(json['sharedSpaceSyncGuid']),
      );
    return isar.monthlyBudgets.put(budget);
  }

  @override
  Future<void> delete(Isar isar, int entityLocalId) =>
      isar.monthlyBudgets.delete(entityLocalId);
}

class ExpenseApplier extends EntityApplier {
  const ExpenseApplier({this.purchaseWrite = false});
  final bool purchaseWrite;

  @override
  String get entityType => 'Expense';

  @override
  Future<int> upsert(Isar isar, String payload) async {
    final json = canonicalJsonDecode(payload);
    final guid = decodeGuid(json['syncGuid']);
    final translator = SyncIdTranslator(isar);
    final existing =
        await isar.expenses.filter().syncGuidEqualTo(guid).findFirst();
    if (!purchaseWrite &&
        (existing?.purchaseSyncGuid != null ||
            json['purchaseSyncGuid'] != null)) {
      throw StateError('Update this purchase with a compatible app.');
    }
    if (existing != null &&
        purchaseWrite &&
        existing.purchaseSyncGuid != json['purchaseSyncGuid']) {
      throw StateError('Purchase cannot claim an existing expense.');
    }
    final expense = const ExpenseCodec().fromJson(json)
      ..id = existing?.id ?? Isar.autoIncrement
      ..sharedSpaceId = await translator.resolveLocalEntity(
        'SharedSpace',
        decodeGuidOrNull(json['sharedSpaceSyncGuid']),
      )
      ..budgetId = await translator.resolveLocalEntity(
            'MonthlyBudget',
            decodeGuidOrNull(json['budgetSyncGuid']),
          ) ??
          0;
    if (expense.financialProfileSyncGuid != null) {
      resolveExpenseProfileIdentity(
          expense,
          await isar.budgetProfiles.where().findAll(),
          await isar.directExpenseProfiles.where().findAll());
    } else if (json.containsKey('financialProfileType') == false &&
        existing != null) {
      // Older peers cannot represent this link. Preserve the known local link.
      expense
        ..budgetProfileId = existing.budgetProfileId
        ..financialProfileType = existing.financialProfileType
        ..financialProfileSyncGuid = existing.financialProfileSyncGuid;
    }
    if (!json.containsKey('merchantSyncGuid') && existing != null) {
      expense
        ..merchantSyncGuid = existing.merchantSyncGuid
        ..merchantName = existing.merchantName
        ..tags = existing.tags
        ..paymentMethod = existing.paymentMethod;
    }
    if (!json.containsKey('paymentEvidenceJson') && existing != null) {
      expense.paymentEvidenceJson = existing.paymentEvidenceJson;
    }
    if (expense.type == ExpenseType.standard) {
      expense.receiptPath = existing?.receiptPath;
    }
    await FxBookingService(isar).validateRemoteExpense(expense, existing,
        carriesFx: json.containsKey('fxHistoryJson'));
    return isar.expenses.put(expense);
  }

  @override
  Future<void> delete(Isar isar, int entityLocalId) async {
    if ((await isar.expenses.get(entityLocalId))?.purchaseSyncGuid != null) {
      throw StateError('Remove the whole purchase.');
    }
    await isar.expenses.delete(entityLocalId);
  }
}

class ExpensePurchaseApplier extends EntityApplier {
  const ExpensePurchaseApplier();
  @override
  String get entityType => 'ExpensePurchase';
  @override
  Future<int> upsert(Isar isar, String payload) async {
    final json = canonicalJsonDecode(payload);
    final p = const ExpensePurchaseCodec().fromJson(json);
    final translator = SyncIdTranslator(isar);
    p.sharedSpaceId = await translator
        .resolveLocalContext(json['sharedSpaceSyncGuid'] as String);
    p.budgetId = await translator.resolveLocalEntity(
            'MonthlyBudget', json['budgetSyncGuid'] as String?) ??
        0;
    if (p.budgetId == 0) throw StateError('The purchase month is unavailable.');
    final existing = await isar.expensePurchases
        .filter()
        .syncGuidEqualTo(p.syncGuid)
        .findFirst();
    if (existing != null &&
        (existing.sharedSpaceId != p.sharedSpaceId ||
            existing.yearMonth != p.yearMonth ||
            existing.itemGuids.join(',') != p.itemGuids.join(','))) {
      throw StateError('Purchase ownership or item membership changed.');
    }
    final snapshots = (json['items'] as List)
        .map((e) => Map<String, Object?>.from(e as Map))
        .toList();
    if (snapshots.length != p.itemGuids.length || snapshots.length > 50) {
      throw StateError('Incomplete purchase snapshot.');
    }
    final rows = <Expense>[];
    for (final item in snapshots) {
      if (item['sharedSpaceSyncGuid'] != json['sharedSpaceSyncGuid'] ||
          item['budgetSyncGuid'] != json['budgetSyncGuid']) {
        throw StateError('Purchase item destination mismatch.');
      }
      final id = await const ExpenseApplier(purchaseWrite: true)
          .upsert(isar, canonicalJsonEncode(item));
      rows.add((await isar.expenses.get(id))!);
    }
    validatePurchaseItems(p, rows);
    for (final row in rows) {
      if (expenseEvidenceProblems(row).isNotEmpty) {
        throw StateError('Invalid purchase payment evidence.');
      }
    }
    p.id = existing?.id ?? Isar.autoIncrement;
    return isar.expensePurchases.put(p);
  }

  @override
  Future<void> delete(Isar isar, int entityLocalId) async {
    final p = await isar.expensePurchases.get(entityLocalId);
    if (p == null) return;
    final rows = await isar.expenses
        .filter()
        .purchaseSyncGuidEqualTo(p.syncGuid)
        .findAll();
    if (await isar.reimbursements
            .filter()
            .anyOf(rows.map((e) => e.id).toList(),
                (q, int id) => q.expenseIdEqualTo(id))
            .count() >
        0) {
      throw StateError('Refunded purchases cannot be removed.');
    }
    await isar.expenses.deleteAll(rows.map((e) => e.id).toList());
    await isar.expensePurchases.delete(p.id);
  }
}

class ReimbursementApplier extends EntityApplier {
  const ReimbursementApplier();

  @override
  String get entityType => 'Reimbursement';

  @override
  Future<int> upsert(Isar isar, String payload) async {
    final json = canonicalJsonDecode(payload);
    final guid = decodeGuid(json['syncGuid']);
    final translator = SyncIdTranslator(isar);
    final existing =
        await isar.reimbursements.filter().syncGuidEqualTo(guid).findFirst();
    final reimbursement = const ReimbursementCodec().fromJson(json)
      ..id = existing?.id ?? Isar.autoIncrement
      ..sharedSpaceId = await translator.resolveLocalEntity(
        'SharedSpace',
        decodeGuidOrNull(json['sharedSpaceSyncGuid']),
      )
      ..expenseId = await translator.resolveLocalEntity(
        'Expense',
        decodeGuidOrNull(json['expenseSyncGuid']),
      );
    await FxBookingService(isar).validateRemoteRefund(reimbursement, existing,
        carriesFx: json.containsKey('fxHistoryJson'));
    return isar.reimbursements.put(reimbursement);
  }

  @override
  Future<void> delete(Isar isar, int entityLocalId) =>
      isar.reimbursements.delete(entityLocalId);
}

class MedicalBillApplier extends EntityApplier {
  const MedicalBillApplier();

  @override
  String get entityType => 'MedicalBill';

  @override
  Future<int> upsert(Isar isar, String payload) async {
    final json = canonicalJsonDecode(payload);
    final guid = decodeGuid(json['syncGuid']);
    final translator = SyncIdTranslator(isar);
    final existing =
        await isar.medicalBills.filter().syncGuidEqualTo(guid).findFirst();
    final bill = const MedicalBillCodec().fromJson(json)
      ..id = existing?.id ?? Isar.autoIncrement
      ..sharedSpaceId = await translator.resolveLocalEntity(
        'SharedSpace',
        decodeGuidOrNull(json['sharedSpaceSyncGuid']),
      )
      ..linkedExpenseId = await translator.resolveLocalEntity(
        'Expense',
        decodeGuidOrNull(json['linkedExpenseSyncGuid']),
      )
      ..familyMemberId = await translator.resolveLocalEntity(
        'FamilyMember',
        decodeGuidOrNull(json['familyMemberSyncGuid']),
      )
      ..providerId = await translator.resolveLocalEntity(
        'MedicalProvider',
        decodeGuidOrNull(json['providerSyncGuid']),
      )
      ..serviceTypeId = await translator.resolveLocalEntity(
        'MedicalServiceType',
        decodeGuidOrNull(json['serviceTypeSyncGuid']),
      );
    return isar.medicalBills.put(bill);
  }

  @override
  Future<void> delete(Isar isar, int entityLocalId) =>
      isar.medicalBills.delete(entityLocalId);
}

class FamilyMemberApplier extends EntityApplier {
  const FamilyMemberApplier();

  @override
  String get entityType => 'FamilyMember';

  @override
  Future<int> upsert(Isar isar, String payload) async {
    final json = canonicalJsonDecode(payload);
    final guid = decodeGuid(json['syncGuid']);
    final existing =
        await isar.familyMembers.filter().syncGuidEqualTo(guid).findFirst();
    final member = const FamilyMemberCodec().fromJson(json)
      ..id = existing?.id ?? Isar.autoIncrement
      ..sharedSpaceId = await SyncIdTranslator(isar).resolveLocalEntity(
        'SharedSpace',
        decodeGuidOrNull(json['sharedSpaceSyncGuid']),
      );
    return isar.familyMembers.put(member);
  }

  @override
  Future<void> delete(Isar isar, int entityLocalId) =>
      isar.familyMembers.delete(entityLocalId);
}

class MedicalProviderApplier extends EntityApplier {
  const MedicalProviderApplier();

  @override
  String get entityType => 'MedicalProvider';

  @override
  Future<int> upsert(Isar isar, String payload) async {
    final json = canonicalJsonDecode(payload);
    final guid = decodeGuid(json['syncGuid']);
    final existing =
        await isar.medicalProviders.filter().syncGuidEqualTo(guid).findFirst();
    final provider = const MedicalProviderCodec().fromJson(json)
      ..id = existing?.id ?? Isar.autoIncrement
      ..sharedSpaceId = await SyncIdTranslator(isar).resolveLocalEntity(
        'SharedSpace',
        decodeGuidOrNull(json['sharedSpaceSyncGuid']),
      );
    return isar.medicalProviders.put(provider);
  }

  @override
  Future<void> delete(Isar isar, int entityLocalId) =>
      isar.medicalProviders.delete(entityLocalId);
}

class MedicalServiceTypeApplier extends EntityApplier {
  const MedicalServiceTypeApplier();

  @override
  String get entityType => 'MedicalServiceType';

  @override
  Future<int> upsert(Isar isar, String payload) async {
    final json = canonicalJsonDecode(payload);
    final guid = decodeGuid(json['syncGuid']);
    final existing = await isar.medicalServiceTypes
        .filter()
        .syncGuidEqualTo(guid)
        .findFirst();
    final serviceType = const MedicalServiceTypeCodec().fromJson(json)
      ..id = existing?.id ?? Isar.autoIncrement
      ..sharedSpaceId = await SyncIdTranslator(isar).resolveLocalEntity(
        'SharedSpace',
        decodeGuidOrNull(json['sharedSpaceSyncGuid']),
      );
    return isar.medicalServiceTypes.put(serviceType);
  }

  @override
  Future<void> delete(Isar isar, int entityLocalId) =>
      isar.medicalServiceTypes.delete(entityLocalId);
}

class InsuranceProfileApplier extends EntityApplier {
  const InsuranceProfileApplier();

  @override
  String get entityType => 'InsuranceProfile';

  @override
  Future<int> upsert(Isar isar, String payload) async {
    final json = canonicalJsonDecode(payload);
    final guid = decodeGuid(json['syncGuid']);
    final existing =
        await isar.insuranceProfiles.filter().syncGuidEqualTo(guid).findFirst();
    final profile = const InsuranceProfileCodec().fromJson(json)
      ..id = existing?.id ?? Isar.autoIncrement
      ..sharedSpaceId = await SyncIdTranslator(isar).resolveLocalEntity(
        'SharedSpace',
        decodeGuidOrNull(json['sharedSpaceSyncGuid']),
      );
    return isar.insuranceProfiles.put(profile);
  }

  @override
  Future<void> delete(Isar isar, int entityLocalId) =>
      isar.insuranceProfiles.delete(entityLocalId);
}

class BudgetProfileApplier extends EntityApplier {
  const BudgetProfileApplier();
  @override
  String get entityType => 'BudgetProfile';
  @override
  Future<int> upsert(Isar isar, String payload) async {
    final json = canonicalJsonDecode(payload);
    final row = const BudgetProfileCodec().fromJson(json);
    row.sharedSpaceId = await SyncIdTranslator(isar).resolveLocalEntity(
        'SharedSpace', decodeGuidOrNull(json['sharedSpaceSyncGuid']));
    if (row.sharedSpaceId == null ||
        row.allocation < 0 ||
        (row.defaultAllocationMinor ?? 0) < 0) {
      throw const FormatException('Invalid Budget Profile');
    }
    final existing = await isar.budgetProfiles
        .filter()
        .syncGuidEqualTo(row.syncGuid)
        .findFirst();
    if (existing != null &&
        (existing.sharedSpaceId != row.sharedSpaceId ||
            existing.yearMonth != row.yearMonth)) {
      throw const FormatException('Profile identity changed context/month');
    }
    if (row.monthEndOriginGuid != null) {
      final run = await isar.monthEndRuns
          .filter()
          .syncGuidEqualTo(row.monthEndOriginGuid!)
          .findFirst();
      // The verified record remains in the journal. Its settlement will project
      // it in the same transaction as the funding, even on bootstrap/reordering.
      if (run == null) return existing?.id ?? 0;
      if (run.fingerprint != row.monthEndFingerprint ||
          !run.applied ||
          run.hasConflict) {
        run.hasConflict = true;
        await isar.monthEndRuns.put(run);
        return existing?.id ?? 0;
      }
    }
    row.id = existing?.id ?? Isar.autoIncrement;
    await isar.budgetProfiles.put(row);
    // Heal expense references that arrived before this profile.
    for (final expense in await isar.expenses
        .filter()
        .sharedSpaceIdEqualTo(row.sharedSpaceId)
        .findAll()) {
      if (expense.financialProfileSyncGuid == row.syncGuid &&
          expense.yearMonth == row.yearMonth &&
          expense.financialProfileType == FinancialProfileType.budget) {
        expense.budgetProfileId = row.id;
        await isar.expenses.put(expense);
      }
    }
    return row.id;
  }

  @override
  Future<void> delete(Isar isar, int entityLocalId) async {
    throw const FormatException(
        'Month profile removal is not a synced operation');
  }
}

class MonthEndRunApplier extends EntityApplier {
  const MonthEndRunApplier();
  @override
  String get entityType => 'MonthEndRun';
  @override
  Future<int> upsert(Isar isar, String payload) async {
    final run = const MonthEndRunCodec().fromPayload(payload);
    if (run.destinationMonth != nextFinancialMonth(run.yearMonth) ||
        run.syncGuid !=
            'month-end:${monthEndDigest([
                  'shared',
                  run.contextGuid,
                  run.yearMonth
                ])}') {
      throw const FormatException('Invalid month-end identity');
    }
    run.sharedSpaceId = await SyncIdTranslator(isar)
        .resolveLocalEntity('SharedSpace', run.contextGuid);
    if (run.sharedSpaceId == null) {
      throw const FormatException('Missing month-end context');
    }
    await projectMonthEnd(isar, run, remote: true);
    // Original signed audit evidence arrives separately; never re-author it.
    final stored = await isar.monthEndRuns.get(run.id);
    if (stored?.applied == true && stored?.hasConflict == false) {
      final records = await isar.changeRecords
          .filter()
          .entityTypeEqualTo('BudgetProfile')
          .contextLocalIdEqualTo(run.sharedSpaceId!)
          .findAll();
      final heads = <String, ChangeRecord>{};
      for (final record in records) {
        final head = heads[record.entitySyncGuid];
        if (head == null || _profileChangeOrder(record, head) > 0) {
          heads[record.entitySyncGuid] = record;
        }
      }
      for (final head in heads.values) {
        if (head.op != 'delete' &&
            canonicalJsonDecode(head.payload)['monthEndOriginGuid'] ==
                run.syncGuid) {
          await const BudgetProfileApplier().upsert(isar, head.payload);
        }
      }
    }
    return run.id;
  }

  @override
  Future<void> delete(Isar isar, int entityLocalId) async {
    throw const FormatException('Confirmed month-end runs are immutable');
  }
}

int _profileChangeOrder(ChangeRecord a, ChangeRecord b) {
  final millis = a.hlcMillis.compareTo(b.hlcMillis);
  if (millis != 0) return millis;
  final counter = a.hlcCounter.compareTo(b.hlcCounter);
  if (counter != 0) return counter;
  if (a.op != b.op) return a.op == 'delete' ? 1 : -1;
  return a.deviceId.compareTo(b.deviceId);
}

class AuditEventApplier extends EntityApplier {
  const AuditEventApplier();
  @override
  String get entityType => 'AuditEvent';
  @override
  Future<int> upsert(Isar isar, String payload) async {
    final event = const AuditEventCodec().fromPayload(payload);
    event.sharedSpaceId = await SyncIdTranslator(isar)
        .resolveLocalEntity('SharedSpace', event.contextSyncGuid);
    if (event.sharedSpaceId == null) {
      throw const FormatException('Missing audit context.');
    }
    final old = await isar.auditEvents
        .filter()
        .syncGuidEqualTo(event.syncGuid)
        .findFirst();
    if (old != null) {
      if (old.evidenceJson != event.evidenceJson ||
          old.hash != event.hash ||
          old.signature != event.signature) {
        throw const FormatException('Immutable audit record conflict.');
      }
      if (old.sharedSpaceId != event.sharedSpaceId) {
        old.sharedSpaceId = event.sharedSpaceId;
        await isar.auditEvents.put(old);
      }
      return old.id;
    }
    final evidence = canonicalJsonDecode(event.evidenceJson!);
    final chain = evidence['chain'] as String;
    final number = evidence['sequence'] as int;
    for (final row in await isar.auditEvents
        .filter()
        .sharedSpaceIdEqualTo(event.sharedSpaceId)
        .findAll()) {
      if (row.evidenceJson == null) continue;
      final prior = canonicalJsonDecode(row.evidenceJson!);
      if (prior['chain'] == chain &&
          prior['sequence'] == number &&
          row.hash != event.hash) {
        throw const FormatException('Conflicting audit sequence.');
      }
    }
    final key = 'audit:head:$chain';
    final head =
        await isar.schemaMigrationStamps.filter().keyEqualTo(key).findFirst();
    if (head == null ||
        (canonicalJsonDecode(head.value)['sequence'] as int) < number) {
      await isar.schemaMigrationStamps.put((head ?? SchemaMigrationStamp())
        ..key = key
        ..value = canonicalJsonEncode(
            {'sequence': number, 'hash': event.hash, 'id': event.syncGuid}));
    }
    return isar.auditEvents.put(event);
  }

  @override
  Future<void> delete(Isar isar, int entityLocalId) async {
    throw const FormatException(
        'Audit records cannot be deleted individually.');
  }
}
