import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../models/expense.dart';
import '../../features/sync/domain/sync_guid.dart';

const evidenceMaximumBytes = 5 * 1024 * 1024;
const evidenceChunkBytes = 64 * 1024;

/// Portable immutable identity; never contains a device-local file path.
class EvidenceDocument {
  const EvidenceDocument(
      {required this.guid,
      required this.role,
      required this.name,
      required this.mediaType,
      required this.length,
      required this.hash});
  final String guid, role, name, mediaType, hash;
  final int length;
  @override
  bool operator ==(Object other) =>
      other is EvidenceDocument &&
      other.guid == guid &&
      other.role == role &&
      other.name == name &&
      other.mediaType == mediaType &&
      other.length == length &&
      other.hash == hash;
  @override
  int get hashCode => Object.hash(guid, role, name, mediaType, length, hash);
  Map<String, Object?> toJson() => {
        'id': guid,
        'role': role,
        'name': name,
        'type': mediaType,
        'length': length,
        'sha256': hash
      };
  factory EvidenceDocument.fromJson(Map<String, dynamic> json) {
    final doc = EvidenceDocument(
        guid: json['id'] as String,
        role: json['role'] as String,
        name: json['name'] as String,
        mediaType: json['type'] as String,
        length: json['length'] as int,
        hash: json['sha256'] as String);
    if (!RegExp(r'^[a-zA-Z0-9-]{16,80}$').hasMatch(doc.guid) ||
        !{'receipt', 'payment'}.contains(doc.role) ||
        doc.name.isEmpty ||
        doc.name.length > 200 ||
        !{'image/jpeg', 'image/png', 'application/pdf'}
            .contains(doc.mediaType) ||
        doc.length <= 0 ||
        doc.length > evidenceMaximumBytes ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(doc.hash)) {
      throw const FormatException('Invalid payment document.');
    }
    return doc;
  }
}

class PreparedEvidence {
  const PreparedEvidence(this.document, this.bytes, {this.stagedPath});
  final EvidenceDocument document;
  final Uint8List bytes;
  final String? stagedPath;
}

String evidenceMediaType(List<int> bytes) {
  bool starts(List<int> signature) =>
      bytes.length >= signature.length &&
      List.generate(signature.length, (i) => bytes[i] == signature[i])
          .every((match) => match);
  if (starts([137, 80, 78, 71, 13, 10, 26, 10])) return 'image/png';
  if (starts([255, 216, 255])) return 'image/jpeg';
  if (starts([37, 80, 68, 70, 45])) return 'application/pdf';
  throw const FormatException('Choose a JPEG, PNG or PDF document.');
}

Future<String> evidenceHash(List<int> bytes) async =>
    (await Sha256().hash(bytes))
        .bytes
        .map((v) => v.toRadixString(16).padLeft(2, '0'))
        .join();

Future<PreparedEvidence> prepareEvidence(
    {required List<int> bytes,
    required String name,
    required String role}) async {
  if (bytes.isEmpty || bytes.length > evidenceMaximumBytes) {
    throw const FormatException('Choose a nonempty file of 5 MB or less.');
  }
  final safeName = name.split(RegExp(r'[/\\]')).last.trim();
  final document = EvidenceDocument.fromJson({
    'id': newSyncGuid(),
    'role': role,
    'name': safeName.length > 200 ? safeName.substring(0, 200) : safeName,
    'type': evidenceMediaType(bytes),
    'length': bytes.length,
    'sha256': await evidenceHash(bytes),
  });
  return PreparedEvidence(document, Uint8List.fromList(bytes));
}

class ExpenseEvidence {
  const ExpenseEvidence(
      {required this.profileChosen,
      this.documents = const [],
      this.cashActor,
      this.cashAt,
      this.cashFingerprint});
  final bool profileChosen;
  final List<EvidenceDocument> documents;
  final String? cashActor, cashFingerprint;
  final DateTime? cashAt;
  String encode() => jsonEncode({
        'version': 1,
        'profileChosen': profileChosen,
        'documents': documents.map((d) => d.toJson()).toList(),
        'cashActor': cashActor,
        'cashAt': cashAt?.toUtc().toIso8601String(),
        'cashFingerprint': cashFingerprint
      });
  static ExpenseEvidence? decode(String? value) {
    if (value == null) return null;
    try {
      if (value.length > 16384) {
        throw const FormatException('Payment evidence is too large.');
      }
      final json = jsonDecode(value) as Map<String, dynamic>;
      if (json['version'] != 1 || json['profileChosen'] is! bool) {
        throw const FormatException('Unsupported payment evidence.');
      }
      final docs = (json['documents'] as List)
          .map((d) =>
              EvidenceDocument.fromJson(Map<String, dynamic>.from(d as Map)))
          .toList();
      if (docs.length > 3 ||
          docs.map((d) => d.guid).toSet().length != docs.length) {
        throw const FormatException('Use at most three separate documents.');
      }
      final actor = json['cashActor'] as String?;
      final fingerprint = json['cashFingerprint'] as String?;
      final confirmed = json['cashAt'] == null
          ? null
          : DateTime.parse(json['cashAt'] as String);
      if ((actor?.length ?? 0) > 256 ||
          (fingerprint?.length ?? 0) > 2048 ||
          (confirmed != null &&
              (confirmed.year < 1970 || confirmed.year > 9999))) {
        throw const FormatException('Invalid cash confirmation.');
      }
      return ExpenseEvidence(
          profileChosen: json['profileChosen'] as bool,
          documents: docs,
          cashActor: actor,
          cashAt: confirmed,
          cashFingerprint: fingerprint);
    } on Object {
      throw const FormatException('Payment evidence could not be read.');
    }
  }
}

/// Ties an explicit declaration to the purchase the user actually confirmed.
String cashPaymentFingerprint(Expense expense) => jsonEncode([
      expense.amount,
      expense.currency.toUpperCase(),
      expense.merchantName?.trim(),
      expense.paymentMethod,
      expense.date.millisecondsSinceEpoch,
      expense.paidAt?.millisecondsSinceEpoch,
      expense.financialProfileType,
      expense.financialProfileSyncGuid,
    ]);

/// Legacy notes/tags/refunds remain usable. New financial/payment edits must
/// satisfy the current requirements; this does not impose a spending limit.
bool requiresCurrentEvidence(Expense next, Expense? previous) =>
    previous == null ||
    previous.paymentEvidenceJson != null ||
    paymentDetailsChanged(next, previous);

bool paymentDetailsChanged(Expense next, Expense previous) =>
    previous.amount != next.amount ||
    previous.currency.toUpperCase() != next.currency.toUpperCase() ||
    previous.merchantName != next.merchantName ||
    previous.paymentMethod != next.paymentMethod ||
    previous.date != next.date ||
    previous.paidAt != next.paidAt ||
    previous.status != next.status ||
    previous.budgetProfileId != next.budgetProfileId ||
    previous.financialProfileType != next.financialProfileType ||
    previous.financialProfileSyncGuid != next.financialProfileSyncGuid;

List<String> expenseEvidenceProblems(Expense expense, {Expense? previous}) {
  if (expense.type == ExpenseType.medical ||
      !requiresCurrentEvidence(expense, previous)) {
    return const [];
  }
  final problems = <String>[];
  final evidence = ExpenseEvidence.decode(expense.paymentEvidenceJson);
  if (expense.title.trim().isEmpty) problems.add('Enter an expense name.');
  if (expense.amount <= 0 || expense.amount > 9007199254740991) {
    problems.add('Enter a positive amount within the supported range.');
  }
  if (expense.currencyCode == null) {
    problems.add('Choose a supported currency.');
  }
  if (expense.categoryId.trim().isEmpty) problems.add('Choose a category.');
  final month =
      '${expense.date.year.toString().padLeft(4, '0')}-${expense.date.month.toString().padLeft(2, '0')}';
  if (month != expense.yearMonth) {
    problems.add('Choose an expense date within ${expense.yearMonth}.');
  }
  if (expense.merchantName?.trim().isEmpty ?? true) {
    problems.add('Enter a merchant.');
  }
  if (!{'cash', 'card', 'bankTransfer', 'other'}
      .contains(expense.paymentMethod)) {
    problems.add('Choose a payment method.');
  }
  if (evidence?.profileChosen != true) {
    problems.add('Choose a financial profile.');
  }
  if (!isPaidExpenseStatus(expense.status)) {
    return problems;
  }
  if (!{'cash', 'card', 'bankTransfer'}.contains(expense.paymentMethod)) {
    problems.add('Paid expenses require Cash, Card or Bank transfer.');
  }
  final documents = evidence?.documents ?? const <EvidenceDocument>[];
  if (!documents.any((d) => d.role == 'receipt')) {
    problems.add('Add the merchant receipt or invoice.');
  }
  if (expense.paymentMethod == 'cash') {
    if (evidence?.cashActor?.isNotEmpty != true ||
        evidence?.cashAt == null ||
        evidence?.cashFingerprint != cashPaymentFingerprint(expense)) {
      problems.add('Confirm that you paid this purchase in cash.');
    }
  } else if (expense.paymentMethod == 'card' ||
      expense.paymentMethod == 'bankTransfer') {
    if (!documents.any((d) =>
        d.role == 'payment' &&
        (expense.paymentMethod != 'card' ||
            d.mediaType.startsWith('image/')))) {
      problems.add(expense.paymentMethod == 'card'
          ? 'Add a separate card-payment screenshot.'
          : 'Add separate bank-transfer proof.');
    }
  }
  return problems;
}

bool isPaidExpenseStatus(ExpenseStatus status) =>
    status == ExpenseStatus.paid ||
    status == ExpenseStatus.partiallyReimbursed ||
    status == ExpenseStatus.reimbursed;
