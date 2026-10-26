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
        'syncGuid': value.syncGuid,
        'name': value.name,
        'avatar': value.avatar,
        'currency': value.currency.name,
        'defaultIncome': value.defaultIncome,
        'createdByProfileId': value.createdByProfileId,
        'createdAt': encodeDate(value.createdAt),
        // Owner's security requirement (FR-027, FR-030). Carried so every
        // member learns the Owner's choice; the member's own stricter choice
        // is never sent (FR-028).
        'requirePin': value.requirePin,
        'forbidBiometrics': value.forbidBiometrics,
        'awayTimeIndex': value.awayTimeIndex,
      };

  @override
  SharedSpace fromJson(Map<String, Object?> json) => SharedSpace()
    ..syncGuid = decodeGuid(json['syncGuid'])
    ..name = (json['name'] as String?) ?? ''
    ..avatar = (json['avatar'] as String?) ?? '👨‍👩‍👧'
    ..currency = decodeEnum(PrimaryCurrency.values, json['currency'])
    ..defaultIncome = decodeInt(json['defaultIncome'])
    ..createdByProfileId = decodeInt(json['createdByProfileId'])
    ..createdAt = decodeDateRequired(json['createdAt'])
    ..requirePin = (json['requirePin'] as bool?) ?? false
    ..forbidBiometrics = (json['forbidBiometrics'] as bool?) ?? false
    ..awayTimeIndex = (json['awayTimeIndex'] as int?) ?? -1;
}
