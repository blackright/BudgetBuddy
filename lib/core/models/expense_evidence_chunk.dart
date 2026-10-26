import 'package:isar/isar.dart';

part 'expense_evidence_chunk.g.dart';

/// Immutable private document content. Small chunks also bound sync messages.
/// Retained independently of expense deletion for historical evidence.
@collection
class ExpenseEvidenceChunk {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late String syncGuid;
  @Index()
  late String documentGuid;
  @Index()
  late String expenseSyncGuid;
  @Index()
  late int profileId;
  @Index()
  int? sharedSpaceId;
  late String yearMonth;
  late String role;
  late String mediaType;
  late String fileName;
  late String sha256;
  late int byteLength;
  late int chunkIndex;
  late int chunkCount;
  List<byte> bytes = [];
}
