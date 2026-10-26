import '../models/expense.dart';
import 'dart:developer' as developer;
import 'expense_evidence.dart';
import 'evidence_staging.dart';
import '../../features/expenses/repositories/expense_evidence_repository.dart';

/// Temporary private draft; copying an expense starts a new, empty instance.
class ExpenseEvidenceDraft {
  ExpenseEvidenceDraft([Expense? expense])
      : originalExpense = expense,
        original = expense?.paymentEvidenceJson,
        profileChosen =
            _existingEvidence(expense?.paymentEvidenceJson)?.profileChosen ??
                false,
        documents = [
          ...?_existingEvidence(expense?.paymentEvidenceJson)?.documents
        ];
  final String? original;
  final Expense? originalExpense;
  DateTime? cashConfirmedAt;
  bool profileChosen, cashConfirmed = false, changed = false;
  bool cashInvalidated = false;
  final List<EvidenceDocument> documents;
  final Map<String, PreparedEvidence> prepared = {};

  void apply(Expense expense, {required String actor}) {
    if (cashConfirmed) cashConfirmedAt ??= DateTime.now().toUtc();
    if (!changed && original != null) {
      expense.paymentEvidenceJson = original;
    } else if (!changed && !profileChosen && original == null) {
      expense.paymentEvidenceJson = null;
    } else {
      final prior = _existingEvidence(original);
      expense.paymentEvidenceJson = ExpenseEvidence(
              profileChosen: profileChosen,
              documents: List.of(documents),
              cashActor: cashConfirmed
                  ? actor
                  : cashInvalidated
                      ? null
                      : prior?.cashActor,
              cashAt: cashConfirmed
                  ? cashConfirmedAt
                  : cashInvalidated
                      ? null
                      : prior?.cashAt,
              cashFingerprint: cashConfirmed
                  ? cashPaymentFingerprint(expense)
                  : prior?.cashFingerprint)
          .encode();
    }
    expense.pendingEvidenceChunks = [
      for (final item in prepared.values)
        if (item.stagedPath == null)
          ...ExpenseEvidenceRepository.chunks(expense, item)
    ];
    expense.pendingEvidenceFiles = {
      for (final item in prepared.values)
        if (item.stagedPath != null) item.document.guid: item.stagedPath!
    };
  }

  Future<void> dispose() async {
    for (final item in prepared.values) {
      try {
        await EvidenceStaging.discard(item.stagedPath);
      } catch (_) {
        developer.log('Temporary evidence cleanup will retry at next startup.',
            name: 'ExpenseEvidence');
      }
    }
    prepared.clear();
  }
}

ExpenseEvidence? _existingEvidence(String? raw) {
  try {
    return ExpenseEvidence.decode(raw);
  } on FormatException {
    return null;
  }
}
