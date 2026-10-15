import 'package:isar/isar.dart';

import '../../../core/models/expense.dart';
import '../../../core/models/insurance_profile.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/medical_service_type.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/models/shared_member.dart';
import '../../../core/models/shared_space.dart';
import '../../expenses/models/reimbursement.dart';
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

/// Applies a `ChangeRecord.payload` to the local entity rows — the *write* side
/// of a [`SyncCodec`] (`contracts/sync-protocol.md` §3 step 3).
///
/// A codec turns a row into canonical bytes; an applier turns those bytes back
/// into a row for the local device. Applying goes through Isar directly (the
/// same tables the repositories write), which keeps one storage path even when a
/// remote change wins over a local edit.
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
  Future<int> upsert(Isar isar, String payload) =>
      isar.sharedSpaces.put(const SharedSpaceCodec().fromPayload(payload));

  @override
  Future<void> delete(Isar isar, int entityLocalId) =>
      isar.sharedSpaces.delete(entityLocalId);
}

class SharedMemberApplier extends EntityApplier {
  const SharedMemberApplier();

  @override
  String get entityType => 'SharedMember';

  @override
  Future<int> upsert(Isar isar, String payload) =>
      isar.sharedMembers.put(const SharedMemberCodec().fromPayload(payload));

  @override
  Future<void> delete(Isar isar, int entityLocalId) =>
      isar.sharedMembers.delete(entityLocalId);
}

class MonthlyBudgetApplier extends EntityApplier {
  const MonthlyBudgetApplier();

  @override
  String get entityType => 'MonthlyBudget';

  @override
  Future<int> upsert(Isar isar, String payload) =>
      isar.monthlyBudgets.put(const MonthlyBudgetCodec().fromPayload(payload));

  @override
  Future<void> delete(Isar isar, int entityLocalId) =>
      isar.monthlyBudgets.delete(entityLocalId);
}

class ExpenseApplier extends EntityApplier {
  const ExpenseApplier();

  @override
  String get entityType => 'Expense';

  @override
  Future<int> upsert(Isar isar, String payload) =>
      isar.expenses.put(const ExpenseCodec().fromPayload(payload));

  @override
  Future<void> delete(Isar isar, int entityLocalId) =>
      isar.expenses.delete(entityLocalId);
}

class ReimbursementApplier extends EntityApplier {
  const ReimbursementApplier();

  @override
  String get entityType => 'Reimbursement';

  @override
  Future<int> upsert(Isar isar, String payload) =>
      isar.reimbursements.put(const ReimbursementCodec().fromPayload(payload));

  @override
  Future<void> delete(Isar isar, int entityLocalId) =>
      isar.reimbursements.delete(entityLocalId);
}

class MedicalBillApplier extends EntityApplier {
  const MedicalBillApplier();

  @override
  String get entityType => 'MedicalBill';

  @override
  Future<int> upsert(Isar isar, String payload) =>
      isar.medicalBills.put(const MedicalBillCodec().fromPayload(payload));

  @override
  Future<void> delete(Isar isar, int entityLocalId) =>
      isar.medicalBills.delete(entityLocalId);
}

class FamilyMemberApplier extends EntityApplier {
  const FamilyMemberApplier();

  @override
  String get entityType => 'FamilyMember';

  @override
  Future<int> upsert(Isar isar, String payload) =>
      isar.familyMembers.put(const FamilyMemberCodec().fromPayload(payload));

  @override
  Future<void> delete(Isar isar, int entityLocalId) =>
      isar.familyMembers.delete(entityLocalId);
}

class MedicalProviderApplier extends EntityApplier {
  const MedicalProviderApplier();

  @override
  String get entityType => 'MedicalProvider';

  @override
  Future<int> upsert(Isar isar, String payload) => isar.medicalProviders
      .put(const MedicalProviderCodec().fromPayload(payload));

  @override
  Future<void> delete(Isar isar, int entityLocalId) =>
      isar.medicalProviders.delete(entityLocalId);
}

class MedicalServiceTypeApplier extends EntityApplier {
  const MedicalServiceTypeApplier();

  @override
  String get entityType => 'MedicalServiceType';

  @override
  Future<int> upsert(Isar isar, String payload) => isar.medicalServiceTypes
      .put(const MedicalServiceTypeCodec().fromPayload(payload));

  @override
  Future<void> delete(Isar isar, int entityLocalId) =>
      isar.medicalServiceTypes.delete(entityLocalId);
}

class InsuranceProfileApplier extends EntityApplier {
  const InsuranceProfileApplier();

  @override
  String get entityType => 'InsuranceProfile';

  @override
  Future<int> upsert(Isar isar, String payload) => isar.insuranceProfiles
      .put(const InsuranceProfileCodec().fromPayload(payload));

  @override
  Future<void> delete(Isar isar, int entityLocalId) =>
      isar.insuranceProfiles.delete(entityLocalId);
}
