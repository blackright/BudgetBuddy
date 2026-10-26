import 'package:isar/isar.dart';
import '../database/schema_migrations.dart';
import '../models/change_record.dart';
import '../models/context_kind.dart';
import '../models/expense_evidence_chunk.dart';
import '../models/expense_purchase.dart';
import '../models/shared_space.dart';

/// Caller owns the whole-space deletion transaction. Removing only the content
/// collection would leave a second copy of every file in the signed journal.
Future<void> purgeSpaceEvidenceInTxn(Isar isar, int spaceId) async {
  await isar.expensePurchases
      .filter()
      .sharedSpaceIdEqualTo(spaceId)
      .deleteAll();
  final space = await isar.sharedSpaces.get(spaceId);
  await isar.expenseEvidenceChunks
      .filter()
      .sharedSpaceIdEqualTo(spaceId)
      .deleteAll();
  await isar.changeRecords
      .filter()
      .contextKindEqualTo(ContextKind.shared)
      .contextLocalIdEqualTo(spaceId)
      .entityTypeEqualTo('ExpenseEvidenceChunk')
      .deleteAll();
  if (space != null) {
    await isar.schemaMigrationStamps
        .filter()
        .keyStartsWith('evidence:sent:')
        .keyEndsWith(':${space.syncGuid}')
        .deleteAll();
  }
}
