import '../../../../core/models/expense_purchase.dart';
import '../sync_codec.dart';
import '../codec_support.dart';

class ExpensePurchaseCodec extends SyncCodec<ExpensePurchase> {
  const ExpensePurchaseCodec();
  @override
  String get entityType => 'ExpensePurchase';
  @override
  Map<String, Object?> toJson(ExpensePurchase value) => {
        'syncGuid': value.syncGuid,
        'profileId': value.profileId,
        'yearMonth': value.yearMonth,
        'receiptTotalMinor': value.receiptTotalMinor,
        'currency': value.currency,
        'merchantName': value.merchantName,
        'itemGuids': value.itemGuids,
        'revision': value.revision,
        'versionToken': value.versionToken
      };
  @override
  ExpensePurchase fromJson(Map<String, Object?> json) => ExpensePurchase()
    ..syncGuid = decodeGuid(json['syncGuid'])
    ..profileId = decodeInt(json['profileId'])
    ..yearMonth = json['yearMonth'] as String
    ..receiptTotalMinor = decodeInt(json['receiptTotalMinor'])
    ..currency = json['currency'] as String
    ..merchantName = json['merchantName'] as String
    ..itemGuids = (json['itemGuids'] as List).cast<String>()
    ..revision = decodeInt(json['revision'])
    ..versionToken = decodeGuid(json['versionToken']);
}
