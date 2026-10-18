import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/features/spaces/domain/shared_member_key.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../medical/repositories/medical_test_harness.dart';

/// T061: membership reads match the key the write paths actually store.
///
/// A membership row is stored under the fingerprint-derived `sharedMemberKey`
/// whenever its profile owns an `Identity` (every paired/syncing phone), and
/// under the raw `UserProfile.id` only for a pre-012 profile with no identity.
/// These tests drive the real providers against a real Isar and prove both cases
/// resolve — the bug was that the reads matched only the raw id, so a synced
/// phone could not see its own spaces or role.
void main() {
  late MedicalTestHarness harness;

  setUp(() async {
    harness = await MedicalTestHarness.create();
    // Point the app's providers (`IsarHelper.instance`) at the test database.
    IsarHelper.instance = harness.isar;
  });

  tearDown(() async {
    await harness.close();
  });

  Future<int> addProfile(String name) async {
    final now = DateTime(2026, 1, 1);
    final profile = UserProfile()
      ..name = name
      ..avatar = '👤'
      ..primaryCurrency = PrimaryCurrency.usd
      ..monthlyAvailableAmount = 0
      ..defaultNetSalary = 0
      ..createdAt = now
      ..updatedAt = now;
    return harness.isar.writeTxn(() => harness.isar.userProfiles.put(profile));
  }

  Future<void> addIdentity(int localProfileId, String fingerprint) async {
    final now = DateTime(2026, 1, 1);
    final identity = Identity()
      ..username = 'me'
      ..publicKey = 'pk'
      ..fingerprint = fingerprint
      ..localProfileId = localProfileId
      ..createdAt = now
      ..updatedAt = now;
    await harness.isar.writeTxn(() => harness.isar.identitys.put(identity));
  }

  /// Creates a space whose single member row is keyed by [memberProfileKey].
  Future<int> addSpaceWithMember(
    String name,
    int memberProfileKey,
    SharedMemberRole role,
  ) async {
    late int spaceId;
    await harness.isar.writeTxn(() async {
      spaceId = await harness.isar.sharedSpaces.put(
        SharedSpace()
          ..name = name
          ..currency = PrimaryCurrency.usd
          ..defaultIncome = 0
          ..createdByProfileId = 0
          ..createdAt = DateTime(2026),
      );
      await harness.isar.sharedMembers.put(
        SharedMember()
          ..sharedSpaceId = spaceId
          ..profileId = memberProfileKey
          ..role = role
          ..joinedAt = DateTime(2026)
          ..updatedAt = DateTime(2026),
      );
    });
    return spaceId;
  }

  ProviderContainer containerFor({required int profileId, int? spaceId}) {
    final container = ProviderContainer(overrides: [
      activeProfileIdProvider.overrideWith((ref) => profileId),
      activeSpaceIdProvider.overrideWith((ref) => spaceId),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  /// Resolves the async upstreams the space providers read, so a later
  /// `mySpacesProvider.future` reflects the loaded profile rather than the
  /// empty first frame.
  Future<void> settle(ProviderContainer container, int profileId) async {
    await container.read(activeProfileProvider.future);
    await container.read(profileMembershipKeyProvider(profileId).future);
    await container.read(activeSpaceMembersProvider.future);
  }

  test('an identity-bearing profile resolves its space and role (T060)',
      () async {
    final profileId = await addProfile('Owner');
    // The profile owns an Identity, so the write paths key its membership row by
    // the fingerprint-derived key — not the raw id.
    const fingerprint = 'FINGERPRINT_OWNER';
    await addIdentity(profileId, fingerprint);
    final spaceId = await addSpaceWithMember(
        'Home', sharedMemberKey(fingerprint), SharedMemberRole.owner);

    final container = containerFor(profileId: profileId, spaceId: spaceId);
    // Let the async membership-key lookup and the members stream resolve first.
    await settle(container, profileId);

    final spaces = await container.read(mySpacesProvider.future);
    expect(spaces.map((s) => s.id), contains(spaceId),
        reason: 'the space the identity was granted is visible to them');

    final role = container.read(activeSpaceMyRoleProvider);
    expect(role, isNotNull, reason: 'their own membership resolves');
    expect(role!.role, SharedMemberRole.owner);
  });

  test('a pre-012 profile with no Identity still resolves by raw id (T060)',
      () async {
    final profileId = await addProfile('Local');
    // No Identity: the write path keeps the raw profile id as the membership key.
    final spaceId = await addSpaceWithMember(
        'Personal', profileId, SharedMemberRole.viewer);

    final container = containerFor(profileId: profileId, spaceId: spaceId);
    await settle(container, profileId);

    final spaces = await container.read(mySpacesProvider.future);
    expect(spaces.map((s) => s.id), contains(spaceId));

    final role = container.read(activeSpaceMyRoleProvider);
    expect(role, isNotNull);
    expect(role!.role, SharedMemberRole.viewer);
  });
}
