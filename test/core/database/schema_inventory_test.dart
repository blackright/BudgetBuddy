import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'the complete inventory is unique and covers current cross-feature flows',
      () {
    final schemas = IsarHelper.schemas;

    expect(schemas, isNotEmpty);
    expect(
      schemas.map((schema) => schema.name).toSet(),
      hasLength(schemas.length),
      reason: 'every record type must appear once in the inventory',
    );
    expect(
      schemas.map((schema) => schema.name),
      containsAll([
        'Expense',
        'Reimbursement',
        'IncomeReceiptGroup',
        'MedicalBill',
        'MedicalApproval',
        'MedicalClaimActivity',
        'MedicalClaimClosure',
        'MedicalWithholdingMatch',
        'MoneyReceipt',
        'ReceiptRevision',
        'PendingAction',
      ]),
      reason: 'migration, refund and profile-deletion paths need these records',
    );
  });
}
