import '../../../../core/models/shared_member.dart';
import '../codec_support.dart';
import '../sync_codec.dart';

/// Canonical codec for [SharedMember] (data-model §2.6/§3.1).
///
/// Carries the signing columns too, so a membership change travels as a signed,
/// versioned authorization record (role-authorization §2).
class SharedMemberCodec extends SyncCodec<SharedMember> {
  const SharedMemberCodec();

  @override
  String get entityType => 'SharedMember';

  @override
  Map<String, Object?> toJson(SharedMember value) => {
        'id': value.id,
        'sharedSpaceId': value.sharedSpaceId,
        'profileId': value.profileId,
        'role': value.role.name,
        'joinedAt': encodeDate(value.joinedAt),
        'version': value.version,
        'updatedAt': encodeDate(value.updatedAt),
        'authorIdentityId': value.authorIdentityId,
        'signature': value.signature,
        'revokedAt': encodeDate(value.revokedAt),
      };

  @override
  SharedMember fromJson(Map<String, Object?> json) => SharedMember()
    ..id = decodeInt(json['id'])
    ..sharedSpaceId = decodeInt(json['sharedSpaceId'])
    ..profileId = decodeInt(json['profileId'])
    ..role = decodeEnum(SharedMemberRole.values, json['role'])
    ..joinedAt = decodeDateRequired(json['joinedAt'])
    ..version = decodeInt(json['version'])
    ..updatedAt = decodeDate(json['updatedAt'])
    ..authorIdentityId = json['authorIdentityId'] as String?
    ..signature = json['signature'] as String?
    ..revokedAt = decodeDate(json['revokedAt']);
}
