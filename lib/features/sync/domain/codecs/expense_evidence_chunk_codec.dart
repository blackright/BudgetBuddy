import 'dart:convert';
import '../../../../core/models/expense_evidence_chunk.dart';
import '../sync_codec.dart';

class ExpenseEvidenceChunkCodec extends SyncCodec<ExpenseEvidenceChunk> {
  const ExpenseEvidenceChunkCodec();
  @override
  String get entityType => 'ExpenseEvidenceChunk';
  @override
  Map<String, Object?> toJson(ExpenseEvidenceChunk value) => {
        'syncGuid': value.syncGuid,
        'documentGuid': value.documentGuid,
        'expenseSyncGuid': value.expenseSyncGuid,
        'yearMonth': value.yearMonth,
        'role': value.role,
        'mediaType': value.mediaType,
        'fileName': value.fileName,
        'sha256': value.sha256,
        'byteLength': value.byteLength,
        'chunkIndex': value.chunkIndex,
        'chunkCount': value.chunkCount,
        'bytes': base64Encode(value.bytes),
      };
  @override
  ExpenseEvidenceChunk fromJson(Map<String, Object?> json) {
    final encoded = json['bytes'] as String;
    if (encoded.length > 90000) {
      throw const FormatException('Document chunk too large.');
    }
    return ExpenseEvidenceChunk()
      ..syncGuid = json['syncGuid'] as String
      ..documentGuid = json['documentGuid'] as String
      ..expenseSyncGuid = json['expenseSyncGuid'] as String
      ..profileId = 0
      ..yearMonth = json['yearMonth'] as String
      ..role = json['role'] as String
      ..mediaType = json['mediaType'] as String
      ..fileName = json['fileName'] as String
      ..sha256 = json['sha256'] as String
      ..byteLength = json['byteLength'] as int
      ..chunkIndex = json['chunkIndex'] as int
      ..chunkCount = json['chunkCount'] as int
      ..bytes = base64Decode(encoded);
  }
}
