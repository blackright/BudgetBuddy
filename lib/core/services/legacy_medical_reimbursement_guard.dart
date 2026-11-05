import 'package:isar/isar.dart';

import '../models/expense.dart';
import '../models/financial_adoption.dart';
import '../models/medical_approval.dart';
import '../models/medical_bill.dart';

/// Legacy money commands may maintain pre-transition records, but must not
/// create a second entry path after a personal claim enters receipt policy2.
/// Call under the same write transaction as the proposed change.
class LegacyMedicalReimbursementGuard {
  static const message =
      'This Medical claim uses insurance approval and Income Sources payment '
      'confirmation. The salary confirmation form is not available yet. '
      'No reimbursement was changed.';

  static Future<void> forBill(Isar db, MedicalBill bill) async {
    if (bill.sharedSpaceId != null) return;
    final profileId = bill.profileId;
    if (profileId == null) throw StateError('Medical owner needs review.');
    final approval = await db.medicalApprovals
        .filter()
        .billGuidEqualTo(bill.syncGuid)
        .findFirst();
    if (approval != null) throw StateError(message);
    await _forMonth(db, profileId, bill.yearMonth);
  }

  static Future<void> forExpense(Isar db, Expense expense) async {
    if (expense.type != ExpenseType.medical || expense.sharedSpaceId != null) {
      return;
    }
    final bills = await db.medicalBills
        .filter()
        .linkedExpenseIdEqualTo(expense.id)
        .findAll();
    for (final bill in bills) {
      if (bill.profileId != expense.profileId || bill.sharedSpaceId != null) {
        throw StateError('Medical owner needs review.');
      }
      await forBill(db, bill);
    }
    await _forMonth(db, expense.profileId, expense.yearMonth);
  }

  static Future<void> _forMonth(Isar db, int profileId, String month) async {
    final adoption = await db.financialAdoptions
        .filter()
        .ownerKeyEqualTo('personal:$profileId:2')
        .sortByRevisionDesc()
        .findFirst();
    if (adoption != null && month.compareTo(adoption.effectiveYearMonth) >= 0) {
      throw StateError(message);
    }
  }
}
