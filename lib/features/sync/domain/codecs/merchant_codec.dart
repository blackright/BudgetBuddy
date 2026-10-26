import '../../../../core/models/merchant.dart';
import '../codec_support.dart';
import '../sync_codec.dart';

class MerchantCodec extends SyncCodec<Merchant> {
  const MerchantCodec();
  @override
  String get entityType => 'Merchant';
  @override
  Map<String, Object?> toJson(Merchant value) => {
        'syncGuid': value.syncGuid,
        'canonicalName': value.canonicalName,
        'aliases': value.aliases,
        'createdAt': encodeDate(value.createdAt),
        'updatedAt': encodeDate(value.updatedAt),
      };
  @override
  Merchant fromJson(Map<String, Object?> json) => Merchant()
    ..syncGuid = decodeGuid(json['syncGuid'])
    ..canonicalName = json['canonicalName'] as String
    ..aliases = (json['aliases'] as List? ?? []).cast<String>()
    ..createdAt = decodeDateRequired(json['createdAt'])
    ..updatedAt = decodeDateRequired(json['updatedAt']);
}
