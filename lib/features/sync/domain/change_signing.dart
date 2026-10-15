import 'dart:convert';

import '../../../core/models/change_record.dart';
import '../../../core/models/shared_member.dart';
import 'sync_codec.dart';

/// The canonical byte string every peer signs and verifies for a [ChangeRecord]
/// (`contracts/sync-protocol.md` §1).
///
/// It covers every field of the record **except** [ChangeRecord.signature]
/// itself, in a key-sorted canonical JSON form, so a signature computed on one
/// device verifies byte-for-byte on another.
String changeCanonicalString(ChangeRecord record) => canonicalJsonEncode({
      'contextKind': record.contextKind.name,
      'contextLocalId': record.contextLocalId,
      'entityType': record.entityType,
      'entityLocalId': record.entityLocalId,
      'op': record.op,
      'payload': record.payload,
      'hlcMillis': record.hlcMillis,
      'hlcCounter': record.hlcCounter,
      'deviceId': record.deviceId,
      'authorIdentityId': record.authorIdentityId,
    });

/// [changeCanonicalString] as UTF-8 bytes, the input to ed25519.
List<int> changeCanonicalBytes(ChangeRecord record) =>
    utf8.encode(changeCanonicalString(record));

/// The canonical byte string the acting Owner signs for a [SharedMember]
/// authorization row (`data-model.md` §3.1, `contracts/role-authorization.md` §2).
///
/// It covers the membership's stable fields plus its [SharedMember.version], in
/// key-sorted canonical JSON, so a signature computed at pairing verifies on any
/// peer that later receives the membership as a change.
String membershipCanonicalString(SharedMember member) => canonicalJsonEncode({
      'sharedSpaceId': member.sharedSpaceId,
      'profileId': member.profileId,
      'role': member.role.name,
      'joinedAt': member.joinedAt.toUtc().millisecondsSinceEpoch,
      'version': member.version,
      'authorIdentityId': member.authorIdentityId,
      'revokedAt': member.revokedAt?.toUtc().millisecondsSinceEpoch,
    });

/// [membershipCanonicalString] as UTF-8 bytes, the input to ed25519.
List<int> membershipCanonicalBytes(SharedMember member) =>
    utf8.encode(membershipCanonicalString(member));
