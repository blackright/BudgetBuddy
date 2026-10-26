import 'codecs/merchant_codec.dart';
import 'codecs/expense_purchase_codec.dart';
import 'codecs/expense_evidence_chunk_codec.dart';
import 'codecs/audit_event_codec.dart';
import '../../../core/models/change_record.dart';
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
import 'codecs/budget_profile_codec.dart';
import 'codecs/month_end_run_codec.dart';

/// The entity types exchanged for a shared context (data-model §2.6, FR-010).
///
/// Whole-month atomicity means a month's `MonthlyBudget` (budget/income) plus its
/// `Expense` / `Reimbursement` / `MedicalBill` and the space's directory rows all
/// travel as their own [ChangeRecord] (`contracts/sync-protocol.md` §5).
const List<SyncCodec<dynamic>> syncCodecs = [
  AuditEventCodec(),
  MerchantCodec(),
  ExpenseEvidenceChunkCodec(),
  SharedSpaceCodec(),
  SharedMemberCodec(),
  MonthlyBudgetCodec(),
  BudgetProfileCodec(),
  MonthEndRunCodec(),
  ExpenseCodec(),
  ExpensePurchaseCodec(),
  ReimbursementCodec(),
  MedicalBillCodec(),
  FamilyMemberCodec(),
  MedicalProviderCodec(),
  MedicalServiceTypeCodec(),
  InsuranceProfileCodec(),
];

/// Resolves a [ChangeRecord.entityType] to its codec, or `null` when the type is
/// not exchanged in v1 (a peer should drop such a record, not crash).
SyncCodec<dynamic>? codecForEntityType(String entityType) {
  for (final codec in syncCodecs) {
    if (codec.entityType == entityType) return codec;
  }
  return null;
}
