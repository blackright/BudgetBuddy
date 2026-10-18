import 'package:isar/isar.dart';

import '../../../core/models/expense.dart';
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
  SharedSpaceApplier(),
  SharedMemberApplier(),
  MonthlyBudgetApplier(),
  ExpenseApplier(),
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
  Future<void> delete(Isar isar, int entityLocalId) =>
      isar.sharedSpaces.delete(entityLocalId);
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
  const ExpenseApplier();

  @override
  String get entityType => 'Expense';

  @override
  Future<int> upsert(Isar isar, String payload) async {
    final json = canonicalJsonDecode(payload);
    final guid = decodeGuid(json['syncGuid']);
    final translator = SyncIdTranslator(isar);
    final existing =
        await isar.expenses.filter().syncGuidEqualTo(guid).findFirst();
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
    return isar.expenses.put(expense);
  }

  @override
  Future<void> delete(Isar isar, int entityLocalId) =>
      isar.expenses.delete(entityLocalId);
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
