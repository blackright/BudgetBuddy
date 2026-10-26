import '../models/expense.dart';
import '../models/expense_purchase.dart';
import '../../features/sync/domain/codecs/expense_codec.dart';
import '../../features/sync/domain/sync_codec.dart';
import 'expense_evidence.dart';

List<int> oldRowsIds(List<Expense> rows) => rows.map((e) => e.id).toList();

void validatePurchaseItems(ExpensePurchase purchase, List<Expense> rows) {
  if (rows.isEmpty ||
      rows.length > 50 ||
      purchase.itemGuids.length != rows.length ||
      purchase.itemGuids.toSet().length != rows.length) {
    throw StateError('A purchase needs 1 to 50 distinct items.');
  }
  final first = rows.first;
  if (purchase.receiptTotalMinor < 0 ||
      purchase.receiptTotalMinor > 9007199254740991) {
    throw StateError('Receipt total is outside the supported amount.');
  }
  if (purchase.currency != first.currency ||
      purchase.merchantName != first.merchantName) {
    throw StateError('Purchase header does not match its items.');
  }
  var total = BigInt.zero;
  for (var i = 0; i < rows.length; i++) {
    final row = rows[i];
    if (row.syncGuid != purchase.itemGuids[i] ||
        row.purchaseSyncGuid != purchase.syncGuid ||
        row.purchaseEvidenceOwnerGuid != rows.first.syncGuid ||
        row.profileId != purchase.profileId ||
        row.sharedSpaceId != purchase.sharedSpaceId ||
        row.yearMonth != purchase.yearMonth ||
        row.budgetId != purchase.budgetId ||
        row.type != ExpenseType.standard ||
        row.merchantName != first.merchantName ||
        row.currency != first.currency ||
        row.date != first.date ||
        row.paymentMethod != first.paymentMethod ||
        row.paidAt != first.paidAt ||
        (isPaidExpenseStatus(row.status) !=
            isPaidExpenseStatus(first.status)) ||
        (row.status == ExpenseStatus.planned) !=
            (first.status == ExpenseStatus.planned)) {
      throw StateError(
          'Purchase items must share merchant, date, currency and payment details.');
    }
    if (row.amount <= 0 || row.amount > 9007199254740991) {
      throw StateError('Invalid purchase amount.');
    }
    total += BigInt.from(row.amount);
    final manifest = ExpenseEvidence.decode(row.paymentEvidenceJson);
    final initial = ExpenseEvidence.decode(first.paymentEvidenceJson);
    if (canonicalJsonEncode(
                manifest?.documents.map((d) => d.toJson()).toList()) !=
            canonicalJsonEncode(
                initial?.documents.map((d) => d.toJson()).toList()) ||
        manifest?.cashActor != initial?.cashActor ||
        manifest?.cashAt != initial?.cashAt) {
      throw StateError('All items must use the same purchase evidence.');
    }
  }
  if (total > BigInt.from(9007199254740991)) {
    throw StateError('Purchase total exceeds the supported amount.');
  }
  if (isPaidExpenseStatus(first.status) &&
      total != BigInt.from(purchase.receiptTotalMinor)) {
    throw StateError('Receipt total must match the items total exactly.');
  }
}

bool samePurchaseContent(ExpensePurchase a, List<Expense> oldRows,
    ExpensePurchase b, List<Expense> rows) {
  final old = {for (final row in oldRows) row.syncGuid: row};
  String content(Expense row) =>
      canonicalJsonEncode(const ExpenseCodec().toJson(row)
        ..remove('merchantSyncGuid')
        // Booking is committed by the service, not supplied by a retried draft.
        ..remove('fxHistoryJson'));
  return a.receiptTotalMinor == b.receiptTotalMinor &&
      a.profileId == b.profileId &&
      a.sharedSpaceId == b.sharedSpaceId &&
      a.budgetId == b.budgetId &&
      a.yearMonth == b.yearMonth &&
      a.itemGuids.join(',') == b.itemGuids.join(',') &&
      oldRows.length == rows.length &&
      rows.every((r) =>
          old[r.syncGuid] != null && content(old[r.syncGuid]!) == content(r));
}
