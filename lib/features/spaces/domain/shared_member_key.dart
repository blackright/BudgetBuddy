import 'package:isar/isar.dart';

import '../../../core/models/identity.dart';
import '../../identity/domain/identity_profile_key.dart';

/// The **uniform** key for a shared-space membership (T044a, data-model §3.1).
///
/// Every shared-space membership is keyed by [sharedMemberKey] of the member's
/// identity — including the local Owner's own row — so an author can always be
/// resolved from `ChangeRecord.authorIdentityId` the same way on every device
/// (`role-authorization.md` §3). A profile with no [Identity] on this device (a
/// pre-012 install or a purely local member) keeps its raw `UserProfile.id`, so
/// 011's local-only behaviour and its tests are unchanged.
int sharedMemberKey(String identityId) => remoteProfileIdFor(identityId);

/// [sharedMemberKey] for a local `UserProfile.id`.
///
/// Looks the profile's [Identity] up by `localProfileId`; when none exists (the
/// common 011 case) the raw id is returned unchanged, which is the safe fallback
/// that keeps every pre-012 membership row keyed exactly as before.
Future<int> sharedMemberKeyForLocalProfile(Isar isar, int profileId) async {
  final identity = await isar.identitys.getByLocalProfileId(profileId);
  if (identity == null) return profileId;
  return sharedMemberKey(identity.fingerprint);
}
