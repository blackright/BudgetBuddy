import '../models/currency_code.dart';
import '../models/expense.dart';
import 'filter_service.dart';
import 'merchant_service.dart';
import 'expense_evidence_draft.dart';
import '../../features/sync/domain/sync_guid.dart';

/// Temporary row identity survives retries but is never shared by a copied row.
class BulkExpenseDraft {
  BulkExpenseDraft({Expense? source, String? identity})
      : guid = identity ?? newSyncGuid(),
        evidence = ExpenseEvidenceDraft(source);
  final String guid;
  String title = '', amount = '', merchant = '', notes = '', tags = '';
  String? currency, category, payment, profileType, profileGuid;
  int? profileId;
  String? profileName;
  DateTime? date;
  bool profileChosen = false, reimbursable = false, saved = false;
  ExpenseStatus status = ExpenseStatus.planned;
  GuiltLevel guilt = GuiltLevel.essential;
  Map<String, String> errors = {};
  final ExpenseEvidenceDraft evidence;

  BulkExpenseDraft copy({bool includeDetails = true}) {
    final row = BulkExpenseDraft()
      ..currency = currency
      ..category = category
      ..payment = payment
      ..profileType = profileType
      ..profileGuid = profileGuid
      ..profileId = profileId
      ..profileName = profileName
      ..profileChosen = profileChosen
      ..date = date;
    if (includeDetails) {
      row
        ..title = title
        ..merchant = merchant
        ..notes = notes
        ..tags = tags
        ..reimbursable = reimbursable
        ..guilt = guilt;
    }
    // No amount, paid status, saved marker or identity is inherited.
    return row;
  }
}

class BulkEntryService {
  const BulkEntryService();
  static const maximumRows = 50;

  Map<String, String> validate(BulkExpenseDraft row, String month) {
    final errors = <String, String>{};
    if (row.title.trim().isEmpty) errors['name'] = 'Enter an expense name.';
    if (row.merchant.trim().isEmpty) errors['merchant'] = 'Enter a merchant.';
    if (row.merchant.trim().length > 200) {
      errors['merchant'] = 'Use at most 200 characters.';
    }
    final currency = CurrencyCode.tryParse(row.currency);
    if (currency == null) errors['currency'] = 'Choose a currency.';
    try {
      if ((parseSearchAmount(row.amount, currency) ?? 0) <= 0) {
        errors['amount'] = 'Enter an amount greater than zero.';
      }
    } on FormatException catch (e) {
      errors['amount'] = e.message;
    }
    if (row.category == null || row.category!.isEmpty) {
      errors['category'] = 'Choose a category.';
    }
    if (!expensePaymentMethods.containsKey(row.payment)) {
      errors['payment'] = 'Choose a payment method.';
    }
    if (!row.profileChosen ||
        (row.profileId == null &&
            (row.profileType != null || row.profileGuid != null)) ||
        (row.profileId != null &&
            (!{FinancialProfileType.budget, FinancialProfileType.direct}
                    .contains(row.profileType) ||
                (row.profileGuid?.isEmpty ?? true)))) {
      errors['profile'] = 'Choose Main, Budget or Direct Expense profile.';
    }
    final date = row.date;
    if (date == null ||
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}' !=
            month) {
      errors['date'] = 'Choose a date within $month.';
    }
    if (row.status != ExpenseStatus.paid &&
        row.status != ExpenseStatus.planned) {
      errors['status'] = 'Choose Paid or Planned.';
    }
    if (row.status == ExpenseStatus.paid) {
      final docs = row.evidence.documents;
      if (!{'cash', 'card', 'bankTransfer'}.contains(row.payment)) {
        errors['payment'] = 'Paid entries require Cash, Card or Bank transfer.';
      }
      if (!docs.any((d) => d.role == 'receipt')) {
        errors['evidence'] = 'Add the merchant receipt or invoice.';
      } else if (row.payment == 'cash' && !row.evidence.cashConfirmed) {
        errors['evidence'] = 'Confirm that you paid this purchase in cash.';
      } else if (row.payment != 'cash' &&
          !docs.any((d) =>
              d.role == 'payment' &&
              (row.payment != 'card' || d.mediaType.startsWith('image/')))) {
        errors['evidence'] = 'Add separate payment proof.';
      }
    }
    return errors;
  }

  Expense expense(
    BulkExpenseDraft row, {
    required int owner,
    required int? space,
    required String month,
    required int budget,
    int? actor,
  }) {
    final errors = validate(row, month);
    if (errors.isNotEmpty) throw StateError(errors.values.join(' '));
    final result = Expense(
      profileId: owner,
      sharedSpaceId: space,
      yearMonth: month,
      title: row.title.trim(),
      amount:
          parseSearchAmount(row.amount, CurrencyCode.tryParse(row.currency))!,
      currency: row.currency!.toUpperCase(),
      categoryId: row.category!,
      status: row.status,
      date: row.date!,
      budgetId: budget,
      merchantName: merchantDisplayName(row.merchant),
      paymentMethod: row.payment,
      notes: row.notes.trim().isEmpty ? null : row.notes.trim(),
      budgetProfileId: row.profileId,
      financialProfileType: row.profileType,
      financialProfileSyncGuid: row.profileGuid,
      isReimbursable: row.reimbursable,
      guiltLevel: row.guilt,
      paidAt: row.status == ExpenseStatus.paid ? row.date : null,
    )
      ..syncGuid = row.guid
      ..tags = normalizeExpenseTags(row.tags.split(','));
    row.evidence.profileChosen = row.profileChosen;
    row.evidence.apply(result, actor: '${actor ?? owner}');
    return result;
  }
}
