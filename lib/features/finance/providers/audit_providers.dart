import '../../../core/models/shared_space.dart';
import '../../../core/models/user_profile.dart';
import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/isar_helper.dart';
import '../../../core/database/schema_migrations.dart';
import '../../../core/models/audit_event.dart';
import '../../../core/models/identity.dart';
import '../../../core/models/paired_peer.dart';
import '../../../core/models/shared_member.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/services/audit_verify_service.dart';
import '../../spaces/repositories/space_write_guard.dart';

final auditMembershipProvider = StreamProvider((ref) {
  final context = ref.watch(budgetContextProvider);
  return IsarHelper.instance.sharedMembers
      .filter()
      .sharedSpaceIdEqualTo(context.spaceId ?? -1)
      .watch(fireImmediately: true);
});

final auditRowsProvider = StreamProvider.autoDispose<List<AuditEvent>>((ref) {
  // Establish reactive dependencies synchronously, before starting native reads.
  final context = ref.watch(budgetContextProvider);
  final actor = ref.watch(actingProfileIdProvider);
  if (context.isShared) ref.watch(auditMembershipProvider);
  final isar = IsarHelper.instance;
  var current = true;
  ref.onDispose(() => current = false);
  Stream<List<AuditEvent>> authorized() async* {
    if (actor == null) throw StateError('Select an acting profile.');
    if (context.isShared) {
      final member =
          await SpaceWriteGuard(isar).memberOf(context.spaceId!, actor);
      if (!current) return;
      if (member == null || member.revokedAt != null) {
        throw StateError('You do not have permission to read this history.');
      }
    } else if (context.profileId != actor) {
      throw StateError('Select the owning personal profile.');
    }
    if (!current) return;
    yield* (context.isShared
            ? isar.auditEvents.filter().sharedSpaceIdEqualTo(context.spaceId)
            : isar.auditEvents
                .filter()
                .sharedSpaceIdIsNull()
                .profileIdEqualTo(context.profileId))
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  return authorized();
});

final auditVerificationProvider =
    FutureProvider.autoDispose<AuditVerification>((ref) async {
  final source = ref.watch(auditRowsProvider);
  if (source.isLoading) {
    return const AuditVerification(
        AuditStatus.incomplete, 'Waiting for the current history snapshot.', 0);
  }
  if (source.hasError) {
    return const AuditVerification(AuditStatus.failed,
        'History could not be read with the current permissions.', 0);
  }
  final rows = source.requireValue;
  final isar = IsarHelper.instance;
  final keys = <String, SimplePublicKey>{};
  for (final identity in await isar.identitys.where().findAll()) {
    if (identity.publicKey.isNotEmpty) {
      keys[identity.fingerprint] = SimplePublicKey(
          base64Decode(identity.publicKey),
          type: KeyPairType.ed25519);
    }
  }
  for (final peer in await isar.pairedPeers.where().findAll()) {
    keys[peer.peerIdentityId] = SimplePublicKey(
        base64Decode(peer.peerPublicKey),
        type: KeyPairType.ed25519);
  }
  final context = ref.watch(budgetContextProvider);
  final contextGuid = context.isShared
      ? (await isar.sharedSpaces.get(context.spaceId!))?.syncGuid
      : 'personal:${context.profileId}';
  final heads = <String, String>{};
  for (final stamp in await isar.schemaMigrationStamps
      .filter()
      .keyStartsWith('audit:head:')
      .findAll()) {
    final chain = stamp.key.substring('audit:head:'.length);
    final parts = jsonDecode(chain) as List;
    final owner = parts[1];
    if (owner == contextGuid && parts.first == context.isShared) {
      heads[chain] = (jsonDecode(stamp.value) as Map)['hash'] as String;
    }
  }
  return const AuditVerifyService().verify(rows,
      trustedKeys: keys, expectedHeads: heads, expectedContext: contextGuid);
});

final auditAuthorNamesProvider =
    FutureProvider.autoDispose<Map<String, String>>((ref) async {
  ref.watch(auditRowsProvider);
  final db = IsarHelper.instance;
  final names = <String, String>{};
  for (final profile in await db.userProfiles.where().findAll()) {
    names['profile:${profile.id}'] = profile.name;
  }
  for (final identity in await db.identitys.where().findAll()) {
    names[identity.fingerprint] = identity.username;
  }
  for (final peer in await db.pairedPeers.where().findAll()) {
    names[peer.peerIdentityId] = peer.peerUsername;
  }
  return names;
});
