import '../../../../core/models/shared_space.dart';
import '../../../../core/models/user_profile.dart';
import '../codec_support.dart';
import '../sync_codec.dart';

/// Canonical codec for [SharedSpace] (data-model §2.6, FR-010).
class SharedSpaceCodec extends SyncCodec<SharedSpace> {
  const SharedSpaceCodec();

  @override
  String get entityType => 'SharedSpace';

  @override
  Map<String, Object?> toJson(SharedSpace value) => {
        'id': value.id,
        'name': value.name,
        'avatar': value.avatar,
        'currency': value.currency.name,
        'defaultIncome': value.defaultIncome,
        'createdByProfileId': value.createdByProfileId,
        'createdAt': encodeDate(value.createdAt),
      };

  @override
  SharedSpace fromJson(Map<String, Object?> json) => SharedSpace()
    ..id = decodeInt(json['id'])
    ..name = (json['name'] as String?) ?? ''
    ..avatar = (json['avatar'] as String?) ?? '👨‍👩‍👧'
    ..currency = decodeEnum(PrimaryCurrency.values, json['currency'])
    ..defaultIncome = decodeInt(json['defaultIncome'])
    ..createdByProfileId = decodeInt(json['createdByProfileId'])
    ..createdAt = decodeDateRequired(json['createdAt']);
}
