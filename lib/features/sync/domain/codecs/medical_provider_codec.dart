import '../../../../core/models/insurance_profile.dart';
import '../codec_support.dart';
import '../sync_codec.dart';

/// Canonical codec for [MedicalProvider] (data-model §2.6, FR-010).
class MedicalProviderCodec extends SyncCodec<MedicalProvider> {
  const MedicalProviderCodec();

  @override
  String get entityType => 'MedicalProvider';

  @override
  Map<String, Object?> toJson(MedicalProvider value) => {
        'id': value.id,
        'profileId': value.profileId,
        'sharedSpaceId': value.sharedSpaceId,
        'name': value.name,
        'specialty': value.specialty,
        'autoCreated': value.autoCreated,
      };

  @override
  MedicalProvider fromJson(Map<String, Object?> json) => MedicalProvider()
    ..id = decodeInt(json['id'])
    ..profileId = decodeIntOrNull(json['profileId'])
    ..sharedSpaceId = decodeIntOrNull(json['sharedSpaceId'])
    ..name = (json['name'] as String?) ?? ''
    ..specialty = json['specialty'] as String?
    ..autoCreated = (json['autoCreated'] as bool?) ?? false;
}
