import 'package:isar/isar.dart';
import '../../features/sync/domain/sync_guid.dart';

part 'expense_purchase.g.dart';

/// A receipt and its item membership, never an additional spending row.
@collection
class ExpensePurchase {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String syncGuid = newSyncGuid();
  @Index()
  late int profileId;
  @Index()
  int? sharedSpaceId;
  late String yearMonth;
  late int budgetId;
  int receiptTotalMinor = 0;
  String currency = '';
  String merchantName = '';
  List<String> itemGuids = [];

  /// Optimistic revision prevents an editor overwriting another saved change.
  int revision = 1;
  String versionToken = newSyncGuid();
  void advanceRevision() {
    revision += 1;
    versionToken = newSyncGuid();
  }
}
