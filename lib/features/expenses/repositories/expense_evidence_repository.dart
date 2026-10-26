import 'dart:typed_data';
import 'package:isar/isar.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/expense_purchase.dart';
import '../../../core/models/budget_profile.dart';
import '../../../core/models/direct_expense_profile.dart';
import '../../../core/services/expense_profile_identity.dart';
import '../../../core/models/expense_evidence_chunk.dart';
import '../../../core/services/expense_evidence.dart';
import '../../../core/services/evidence_staging.dart';
import '../../sync/domain/codecs/expense_evidence_chunk_codec.dart';
import '../../sync/repositories/sync_recorder.dart';
import '../../sync/domain/sync_guid.dart';

class ExpenseEvidenceRepository {
  const ExpenseEvidenceRepository(this.isar, {this.recorder, this.actorId});
  final Isar isar;
  final SyncRecorder? recorder;
  final int? actorId;

  Future<List<PreparedEvidence>> prepareContextMove(Expense expense) async {
    final manifest = ExpenseEvidence.decode(expense.paymentEvidenceJson);
    final result = <PreparedEvidence>[];
    for (final document in manifest?.documents ?? const <EvidenceDocument>[]) {
      final bytes = await readDocument(expense, document);
      if (bytes == null) {
        throw StateError(
            'Wait for payment documents to arrive before moving this month.');
      }
      result.add(PreparedEvidence(
          EvidenceDocument(
              guid: newSyncGuid(),
              role: document.role,
              name: document.name,
              mediaType: document.mediaType,
              length: document.length,
              hash: document.hash),
          bytes));
    }
    return result;
  }

  /// A context move creates new document identities, retaining the source
  /// versions for the source audit. It never reassigns an immutable chunk.
  Future<void> finishContextMoveInTxn(
      Expense expense, List<PreparedEvidence> documents) async {
    final old = ExpenseEvidence.decode(expense.paymentEvidenceJson);
    if (old == null) return;
    expense.paymentEvidenceJson = ExpenseEvidence(
            profileChosen: old.profileChosen,
            documents: documents.map((d) => d.document).toList(),
            cashActor: old.cashActor,
            cashAt: old.cashAt,
            cashFingerprint: old.cashFingerprint)
        .encode();
    for (final document in documents) {
      if (expense.purchaseEvidenceOwnerGuid != null &&
          expense.purchaseEvidenceOwnerGuid != expense.syncGuid) {
        continue;
      }
      for (final chunk in chunks(expense, document)) {
        chunk.id = await isar.expenseEvidenceChunks.put(chunk);
        await recorder?.recordEvidenceChunk(chunk);
      }
    }
  }

  static List<ExpenseEvidenceChunk> chunks(
      Expense expense, PreparedEvidence prepared) {
    final doc = prepared.document;
    final count = (doc.length + evidenceChunkBytes - 1) ~/ evidenceChunkBytes;
    return List.generate(
        count,
        (index) => ExpenseEvidenceChunk()
          ..syncGuid = '${doc.guid}:$index'
          ..documentGuid = doc.guid
          ..expenseSyncGuid =
              expense.purchaseEvidenceOwnerGuid ?? expense.syncGuid
          ..profileId = expense.profileId
          ..sharedSpaceId = expense.sharedSpaceId
          ..yearMonth = expense.yearMonth
          ..role = doc.role
          ..mediaType = doc.mediaType
          ..fileName = doc.name
          ..sha256 = doc.hash
          ..byteLength = doc.length
          ..chunkIndex = index
          ..chunkCount = count
          ..bytes = prepared.bytes.sublist(index * evidenceChunkBytes,
              ((index + 1) * evidenceChunkBytes).clamp(0, doc.length)));
  }

  Future<Uint8List?> readDocument(Expense expense, EvidenceDocument document,
      {List<ExpenseEvidenceChunk> pending = const []}) async {
    final stored = await isar.expenseEvidenceChunks
        .filter()
        .documentGuidEqualTo(document.guid)
        .findAll();
    final byIndex = <int, ExpenseEvidenceChunk>{};
    for (final chunk in [
      ...stored,
      ...pending.where((c) => c.documentGuid == document.guid)
    ]) {
      validateChunk(chunk);
      if (chunk.expenseSyncGuid !=
              (expense.purchaseEvidenceOwnerGuid ?? expense.syncGuid) ||
          chunk.yearMonth != expense.yearMonth ||
          chunk.sharedSpaceId != expense.sharedSpaceId ||
          (expense.sharedSpaceId == null &&
              chunk.profileId != expense.profileId) ||
          chunk.role != document.role ||
          chunk.mediaType != document.mediaType ||
          chunk.sha256 != document.hash ||
          chunk.byteLength != document.length ||
          chunk.fileName != document.name) {
        throw const FormatException(
            'Document ownership or identity does not match.');
      }
      final prior = byIndex[chunk.chunkIndex];
      if (prior != null &&
          const ExpenseEvidenceChunkCodec().toPayload(prior) !=
              const ExpenseEvidenceChunkCodec().toPayload(chunk)) {
        throw const FormatException('Conflicting document content.');
      }
      byIndex[chunk.chunkIndex] = chunk;
    }
    final count =
        (document.length + evidenceChunkBytes - 1) ~/ evidenceChunkBytes;
    if (byIndex.length != count) return null;
    final builder = BytesBuilder(copy: false);
    for (var index = 0; index < count; index++) {
      final chunk = byIndex[index];
      if (chunk == null) return null;
      builder.add(chunk.bytes);
    }
    final bytes = builder.takeBytes();
    if (bytes.length != document.length ||
        await evidenceHash(bytes) != document.hash ||
        evidenceMediaType(bytes) != document.mediaType) {
      throw const FormatException('Document integrity check failed.');
    }
    return bytes;
  }

  /// Caller owns the financial transaction. All required content must be local
  /// before a new local payment can commit; remote manifests may be pending.
  Future<void> saveInTxn(Expense expense,
      {Expense? previous, bool purchaseWrite = false}) async {
    if (previous?.purchaseSyncGuid != null && !purchaseWrite) {
      throw StateError(
          'Open the purchase to change its items or payment details.');
    }
    if (expense.purchaseSyncGuid != null) {
      final purchase = await isar.expensePurchases
          .filter()
          .syncGuidEqualTo(expense.purchaseSyncGuid!)
          .findFirst();
      if (!purchaseWrite ||
          purchase == null ||
          !purchase.itemGuids.contains(expense.syncGuid) ||
          purchase.itemGuids.first != expense.purchaseEvidenceOwnerGuid ||
          purchase.sharedSpaceId != expense.sharedSpaceId ||
          purchase.profileId != expense.profileId ||
          purchase.yearMonth != expense.yearMonth) {
        if (previous == null || purchaseWrite) {
          throw StateError('Invalid purchase membership.');
        }
      }
    } else if (expense.purchaseEvidenceOwnerGuid != null) {
      throw StateError('Invalid purchase document owner.');
    }
    if (expense.sharedSpaceId == null &&
        actorId != null &&
        actorId != expense.profileId) {
      throw StateError('This expense belongs to another personal profile.');
    }
    if (previous != null &&
        (expense.profileId != previous.profileId ||
            expense.sharedSpaceId != previous.sharedSpaceId ||
            expense.yearMonth != previous.yearMonth ||
            expense.budgetId != previous.budgetId ||
            expense.type != previous.type)) {
      throw StateError(
          'The expense destination changed. Reopen its owning month.');
    }
    if (expense.type == ExpenseType.medical) {
      if (previous == null) {
        throw StateError('Use the medical bill workflow for medical expenses.');
      }
      return;
    }
    if (previous != null &&
        !paymentDetailsChanged(expense, previous) &&
        expense.paymentEvidenceJson == previous.paymentEvidenceJson &&
        expense.pendingEvidenceChunks.isEmpty &&
        expense.pendingEvidenceFiles.isEmpty) {
      return;
    }
    if (requiresCurrentEvidence(expense, previous)) {
      final isMain = expense.budgetProfileId == null &&
          expense.financialProfileType == null &&
          expense.financialProfileSyncGuid == null;
      if (!isMain &&
          (expense.financialProfileType == null ||
              expense.financialProfileSyncGuid == null ||
              !resolveExpenseProfileIdentity(
                  expense,
                  await isar.budgetProfiles.where().findAll(),
                  await isar.directExpenseProfiles.where().findAll()))) {
        throw StateError(
            'Choose a valid financial profile in this month and context.');
      }
    }
    final problems = expenseEvidenceProblems(expense, previous: previous);
    if (problems.isNotEmpty) throw StateError(problems.join(' '));
    final manifest = ExpenseEvidence.decode(expense.paymentEvidenceJson);
    if (manifest == null) return;
    final pending = [...expense.pendingEvidenceChunks];
    for (final document in manifest.documents) {
      final path = expense.pendingEvidenceFiles[document.guid];
      if (path != null) {
        final bytes = await EvidenceStaging.read(path);
        if (bytes.length != document.length ||
            await evidenceHash(bytes) != document.hash) {
          throw const FormatException(
              'Temporary payment document changed. Choose it again.');
        }
        pending.addAll(chunks(expense, PreparedEvidence(document, bytes)));
      }
    }
    for (final document in manifest.documents) {
      if (await readDocument(expense, document, pending: pending) == null) {
        throw StateError(
            'Payment document is unavailable. Attach it before saving.');
      }
    }
    final active = manifest.documents.map((d) => d.guid).toSet();
    for (final chunk in pending.where((c) => active.contains(c.documentGuid))) {
      final old = await isar.expenseEvidenceChunks
          .filter()
          .syncGuidEqualTo(chunk.syncGuid)
          .findFirst();
      if (old != null) {
        if (const ExpenseEvidenceChunkCodec().toPayload(old) !=
            const ExpenseEvidenceChunkCodec().toPayload(chunk)) {
          throw StateError('Existing evidence cannot be overwritten.');
        }
        continue;
      }
      chunk.id = await isar.expenseEvidenceChunks.put(chunk);
      await recorder?.recordEvidenceChunk(chunk);
    }
  }
}

void validateChunk(ExpenseEvidenceChunk chunk) {
  EvidenceDocument.fromJson({
    'id': chunk.documentGuid,
    'role': chunk.role,
    'name': chunk.fileName,
    'type': chunk.mediaType,
    'length': chunk.byteLength,
    'sha256': chunk.sha256
  });
  final count =
      (chunk.byteLength + evidenceChunkBytes - 1) ~/ evidenceChunkBytes;
  if (chunk.expenseSyncGuid.isEmpty ||
      chunk.syncGuid != '${chunk.documentGuid}:${chunk.chunkIndex}' ||
      chunk.chunkCount != count ||
      chunk.chunkIndex < 0 ||
      chunk.chunkIndex >= count ||
      chunk.bytes.length !=
          (chunk.chunkIndex == count - 1
              ? chunk.byteLength - chunk.chunkIndex * evidenceChunkBytes
              : evidenceChunkBytes)) {
    throw const FormatException('Invalid document chunk.');
  }
}
