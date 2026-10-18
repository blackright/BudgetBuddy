import '../../../../core/models/medical_service_type.dart';
import '../codec_support.dart';
import '../sync_codec.dart';

/// Canonical codec for [MedicalServiceType] (data-model §2.6, FR-010).
class MedicalServiceTypeCodec extends SyncCodec<MedicalServiceType> {
  const MedicalServiceTypeCodec();

  @override
  String get entityType => 'MedicalServiceType';

  @override
  Map<String, Object?> toJson(MedicalServiceType value) => {
        'syncGuid': value.syncGuid,
        'profileId': value.profileId,
        'name': value.name,
        'isDefault': value.isDefault,
        'sortOrder': value.sortOrder,
        'archived': value.archived,
      };

  @override
  MedicalServiceType fromJson(Map<String, Object?> json) => MedicalServiceType()
    ..syncGuid = decodeGuid(json['syncGuid'])
    ..profileId = decodeIntOrNull(json['profileId'])
    ..name = (json['name'] as String?) ?? ''
    ..isDefault = (json['isDefault'] as bool?) ?? false
    ..sortOrder = decodeInt(json['sortOrder'])
    ..archived = (json['archived'] as bool?) ?? false;
}
