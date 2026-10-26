import '../models/expense.dart';
import '../models/currency_code.dart';
import 'bulk_entry_service.dart';
import 'expense_evidence_draft.dart';
import 'filter_service.dart';
import '../../features/sync/domain/sync_guid.dart';

/// Screen-only purchase. Only item expenses represent spending.
class PurchaseDraft {
  PurchaseDraft() : guid = newSyncGuid();
  String guid;
  int revision = 0;
  String? expectedToken;
  BulkExpenseDraft header = BulkExpenseDraft();
  final items = <BulkExpenseDraft>[];
  final defaults = BulkExpenseDraft();
  String receiptTotal = '';
  bool saved = false;
  String? error;
  ExpenseEvidenceDraft get evidence => header.evidence;

  void inherit(BulkExpenseDraft item) {
    item
      ..merchant = header.merchant
      ..currency = header.currency
      ..payment = header.payment
      ..date = header.date
      ..status = header.status;
  }

  BulkExpenseDraft addItem() {
    final item = defaults.copy(includeDetails: false);
    inherit(item);
    items.add(item);
    return item;
  }

  int? get totalMinor {
    final code = CurrencyCode.tryParse(header.currency);
    if (code == null) return null;
    var total = BigInt.zero;
    try {
      for (final item in items) {
        final value = parseSearchAmount(item.amount, code);
        if (value == null || value <= 0) return null;
        total += BigInt.from(value);
      }
      return total > BigInt.from(9007199254740991) ? null : total.toInt();
    } on FormatException {
      return null;
    }
  }

  int? get receiptMinor {
    try {
      return parseSearchAmount(
          receiptTotal, CurrencyCode.tryParse(header.currency));
    } on FormatException {
      return null;
    }
  }

  List<String> validate(String month, {bool showErrors = false}) {
    final issues = <String>[];
    if (items.isEmpty || items.length > 50) issues.add('Add 1 to 50 items.');
    for (final item in items) {
      inherit(item);
      // Reuse metadata policy; evidence is validated once for the purchase.
      final status = item.status;
      item.status = ExpenseStatus.planned;
      final errors = const BulkEntryService().validate(item, month);
      if (showErrors) {
        item.errors = errors;
      }
      item.status = status;
      if (errors.isNotEmpty) {
        issues
            .add('Complete ${item.title.isEmpty ? 'each item' : item.title}.');
      }
    }
    if (totalMinor == null) {
      issues.add('Enter valid item amounts within the supported total.');
    }
    if (header.status == ExpenseStatus.paid) {
      if (receiptMinor == null ||
          receiptMinor! <= 0 ||
          receiptMinor != totalMinor) {
        issues.add('Receipt total must match the items total exactly.');
      }
      if (!{'cash', 'card', 'bankTransfer'}.contains(header.payment)) {
        issues.add('Choose Cash, Card or Bank transfer.');
      }
      if (!evidence.documents.any((d) => d.role == 'receipt')) {
        issues.add('Add the merchant receipt or invoice.');
      }
      if (header.payment == 'cash' &&
          !evidence.cashConfirmed &&
          evidence.original == null) {
        issues.add('Confirm that you paid this purchase in cash.');
      }
      if (header.payment != 'cash' &&
          !evidence.documents.any((d) =>
              d.role == 'payment' &&
              (header.payment != 'card' || d.mediaType.startsWith('image/')))) {
        issues.add('Add separate payment proof.');
      }
    }
    if (receiptTotal.trim().isNotEmpty && receiptMinor == null) {
      issues
          .add('Enter a valid receipt total, or leave it blank while Planned.');
    }
    return issues.toSet().toList();
  }

  PurchaseDraft copy() {
    final result = PurchaseDraft();
    result.header
      ..merchant = header.merchant
      ..currency = header.currency
      ..payment = header.payment
      ..date = header.date;
    for (final item in items) {
      final copied = item.copy();
      result.inherit(copied);
      result.items.add(copied);
    }
    return result;
  }
}
