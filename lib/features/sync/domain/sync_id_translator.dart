import 'package:isar/isar.dart';

import '../../../core/models/expense.dart';
import '../../../core/models/insurance_profile.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/medical_service_type.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/models/shared_member.dart';
import '../../../core/models/shared_space.dart';
import '../../../core/models/user_profile.dart';
import '../../expenses/models/reimbursement.dart';

/// Translates the device-independent GUIDs on the wire to this device's local
/// Isar row ids (data-model §3/§4, `contracts/entity-identity.md` §4).
///
/// The wire never carries a local `Id`, so a received change refers to another
/// row by `syncGuid`. This class is the one place that turns such a GUID into
/// the local id the tables use, using the (non-unique) `syncGuid` index added in
/// step 17. It is a thin, read-only lookup plus one deliberate creation:
/// [resolveLocalEntity] never invents a row (a reference to something this
/// device has not seen yet resolves to `null`, rule R2), while
/// [resolveLocalContext] creates the space on first sight (bootstrap, §4 step 1).
class SyncIdTranslator {
  const SyncIdTranslator(this.isar);

  final Isar isar;

  /// The local row id of `entityType` whose `syncGuid` is [entitySyncGuid], or
  /// `null` when this device has not seen that entity yet.
  ///
  /// `null` is a *signal*, not an error: the caller leaves the foreign-key field
  /// unset and the next round re-applies the record once the target arrives
  /// (self-healing, R2).
  Future<int?> resolveLocalEntity(
      String entityType, String? entitySyncGuid) async {
    if (entitySyncGuid == null || entitySyncGuid.isEmpty) return null;
    switch (entityType) {
      case 'SharedSpace':
        return (await isar.sharedSpaces
                .filter()
                .syncGuidEqualTo(entitySyncGuid)
                .findFirst())
            ?.id;
      case 'SharedMember':
        return (await isar.sharedMembers
                .filter()
                .syncGuidEqualTo(entitySyncGuid)
                .findFirst())
            ?.id;
      case 'MonthlyBudget':
        return (await isar.monthlyBudgets
                .filter()
                .syncGuidEqualTo(entitySyncGuid)
                .findFirst())
            ?.id;
      case 'Expense':
        return (await isar.expenses
                .filter()
                .syncGuidEqualTo(entitySyncGuid)
                .findFirst())
            ?.id;
      case 'Reimbursement':
        return (await isar.reimbursements
                .filter()
                .syncGuidEqualTo(entitySyncGuid)
                .findFirst())
            ?.id;
      case 'MedicalBill':
        return (await isar.medicalBills
                .filter()
                .syncGuidEqualTo(entitySyncGuid)
                .findFirst())
            ?.id;
      case 'FamilyMember':
        return (await isar.familyMembers
                .filter()
                .syncGuidEqualTo(entitySyncGuid)
                .findFirst())
            ?.id;
      case 'MedicalProvider':
        return (await isar.medicalProviders
                .filter()
                .syncGuidEqualTo(entitySyncGuid)
                .findFirst())
            ?.id;
      case 'MedicalServiceType':
        return (await isar.medicalServiceTypes
                .filter()
                .syncGuidEqualTo(entitySyncGuid)
                .findFirst())
            ?.id;
      case 'InsuranceProfile':
        return (await isar.insuranceProfiles
                .filter()
                .syncGuidEqualTo(entitySyncGuid)
                .findFirst())
            ?.id;
      default:
        return null;
    }
  }

  /// The local id of the space identified by [contextSyncGuid], creating a bare
  /// `SharedSpace` the first time the GUID is seen (data-model §4 step 1).
  ///
  /// The full space row arrives as its own `SharedSpace` record; this only
  /// guarantees a local anchor exists so the engine can load members and run the
  /// role/seal gate against the **local** space id (closing the 012 hole where
  /// authorization ran against the author's id).
  ///
  /// The first-sight bootstrap is a `put`, so callers **must** already hold a
  /// write transaction when the context may be unseen (the engine wraps this).
  Future<int> resolveLocalContext(String contextSyncGuid) async {
    final existing = await isar.sharedSpaces
        .filter()
        .syncGuidEqualTo(contextSyncGuid)
        .findFirst();
    if (existing != null) return existing.id;
    // Bootstrap anchor: a bare but *valid* row so the engine can load members
    // and run the role/seal gate against a local space id. The full space row
    // (name, currency, provenance) arrives as its own `SharedSpace` record and
    // overwrites this by syncGuid (data-model §4 step 1).
    return isar.sharedSpaces.put(SharedSpace()
      ..syncGuid = contextSyncGuid
      ..name = 'Shared space'
      ..currency = PrimaryCurrency.usd
      ..createdByProfileId = 0
      ..createdAt = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true));
  }
}
