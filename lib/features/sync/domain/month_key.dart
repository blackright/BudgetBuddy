import 'sync_codec.dart';

/// The `YYYY-MM` month a change's payload targets, or `null` when the entity is
/// not month-scoped (FR-011, research R6).
///
/// The month travels inside the canonical payload — `yearMonth` for budgets,
/// expenses and medical bills; `originYearMonth` for a reimbursement. Reading the
/// canonical JSON keeps this independent of the per-entity codecs, so the sync
/// engine can spot a sealed-month write without decoding every row.
String? monthKeyOf(String entityType, String payload) {
  final field = switch (entityType) {
    'MonthlyBudget' || 'Expense' || 'MedicalBill' => 'yearMonth',
    'Reimbursement' => 'originYearMonth',
    _ => null,
  };
  if (field == null || payload.isEmpty) return null;
  final value = canonicalJsonDecode(payload)[field];
  return value is String && value.isNotEmpty ? value : null;
}
