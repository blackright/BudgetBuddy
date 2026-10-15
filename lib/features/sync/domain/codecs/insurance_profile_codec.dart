import '../../../../core/models/insurance_profile.dart';
import '../codec_support.dart';
import '../sync_codec.dart';

/// Canonical codec for [InsuranceProfile] (data-model §2.6, FR-010).
class InsuranceProfileCodec extends SyncCodec<InsuranceProfile> {
  const InsuranceProfileCodec();

  @override
  String get entityType => 'InsuranceProfile';

  @override
  Map<String, Object?> toJson(InsuranceProfile value) => {
        'id': value.id,
        'profileId': value.profileId,
        'sharedSpaceId': value.sharedSpaceId,
        'defaultPatientPercent': value.defaultPatientPercent,
        'insurerName': value.insurerName,
        'planName': value.planName,
      };

  @override
  InsuranceProfile fromJson(Map<String, Object?> json) => InsuranceProfile()
    ..id = decodeInt(json['id'])
    ..profileId = decodeIntOrNull(json['profileId'])
    ..sharedSpaceId = decodeIntOrNull(json['sharedSpaceId'])
    ..defaultPatientPercent = decodeDouble(json['defaultPatientPercent'])
    ..insurerName = json['insurerName'] as String?
    ..planName = json['planName'] as String?;
}
