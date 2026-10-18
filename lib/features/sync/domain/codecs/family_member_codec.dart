import '../../../../core/models/insurance_profile.dart';
import '../codec_support.dart';
import '../sync_codec.dart';

/// Canonical codec for [FamilyMember] (data-model §2.6, FR-010).
class FamilyMemberCodec extends SyncCodec<FamilyMember> {
  const FamilyMemberCodec();

  @override
  String get entityType => 'FamilyMember';

  @override
  Map<String, Object?> toJson(FamilyMember value) => {
        'syncGuid': value.syncGuid,
        'profileId': value.profileId,
        'name': value.name,
        'relation': value.relation,
      };

  @override
  FamilyMember fromJson(Map<String, Object?> json) => FamilyMember()
    ..syncGuid = decodeGuid(json['syncGuid'])
    ..profileId = decodeIntOrNull(json['profileId'])
    ..name = (json['name'] as String?) ?? ''
    ..relation = (json['relation'] as String?) ?? '';
}
