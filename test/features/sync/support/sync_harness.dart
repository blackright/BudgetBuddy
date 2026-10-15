import 'dart:convert';
import 'dart:io';

import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/category.dart';
import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/consent_record.dart';
import 'package:budget_buddy/core/models/context_kind.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/expense_template.dart';
import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/core/models/insurance_profile.dart';
import 'package:budget_buddy/core/models/live_rate_set.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_service_type.dart';
import 'package:budget_buddy/core/models/month_rate_seal.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/paired_context.dart';
import 'package:budget_buddy/core/models/paired_peer.dart';
import 'package:budget_buddy/core/models/pairing_token.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/sync_cursor.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/spaces/domain/shared_member_key.dart';
import 'package:budget_buddy/features/sync/domain/change_signing.dart';
import 'package:budget_buddy/features/vault/models/savings_vault.dart';
import 'package:cryptography/cryptography.dart';
import 'package:isar/isar.dart';

import 'change_factory.dart';
import 'fake_transport.dart';

/// An Isar + fake-transport harness for the cross-device sync tests.
///
/// Mirrors [MedicalTestHarness]: a real temporary Isar instance opened on the
/// full schema set, plus a [FakeTransportHub] so two in-memory peers can be wired
/// without sockets. Every instance gets a distinct Isar name (Isar 3 refuses to
/// open the same name twice in a process).
class SyncTestHarness {
  SyncTestHarness._(this.isar, this.directory);

  static bool _coreReady = false;
  static int _nextInstance = 0;

  final Isar isar;
  final Directory directory;
  final FakeTransportHub transport = FakeTransportHub();

  static Future<SyncTestHarness> create() async {
    if (!_coreReady) {
      await Isar.initializeIsarCore(download: true);
      _coreReady = true;
    }
    final directory = Directory.systemTemp.createTempSync('budget_buddy_sync_');
    final isar = await Isar.open(
      [
        UserProfileSchema,
        MonthlyBudgetSchema,
        ExpenseSchema,
        ExpenseTemplateSchema,
        ReimbursementSchema,
        SavingsVaultSchema,
        CategorySchema,
        MedicalBillSchema,
        InsuranceProfileSchema,
        FamilyMemberSchema,
        MedicalProviderSchema,
        MedicalServiceTypeSchema,
        SchemaMigrationStampSchema,
        MonthRateSealSchema,
        LiveRateSetSchema,
        SharedSpaceSchema,
        SharedMemberSchema,
        IdentitySchema,
        ConsentRecordSchema,
        PairedPeerSchema,
        PairedContextSchema,
        PairingTokenSchema,
        ChangeRecordSchema,
        SyncCursorSchema,
      ],
      directory: directory.path,
      name: 'sync_${_nextInstance++}',
    );
    await writeSchemaVersion(isar, schemaVersion);
    return SyncTestHarness._(isar, directory);
  }

  /// Creates a [SharedSpace] row, returning its id.
  Future<int> createSpace({String name = 'Home', int createdByProfileId = 1}) {
    return isar.writeTxn(() async {
      final space = SharedSpace()
        ..name = name
        ..currency = PrimaryCurrency.usd
        ..defaultIncome = 0
        ..createdByProfileId = createdByProfileId
        ..createdAt = DateTime(2026);
      return isar.sharedSpaces.put(space);
    });
  }

  /// Adds a membership row, returning its id.
  Future<int> addMember({
    required int spaceId,
    required int profileId,
    required SharedMemberRole role,
  }) {
    return isar.writeTxn(() async {
      final member = SharedMember()
        ..sharedSpaceId = spaceId
        ..profileId = profileId
        ..role = role
        ..joinedAt = DateTime(2026)
        ..updatedAt = DateTime(2026);
      return isar.sharedMembers.put(member);
    });
  }

  /// Adds a **signed** membership keyed by [keys]' identity (T044a/T045), which
  /// makes the space 012-managed so the sync engine enforces apply-time
  /// authorization (role-authorization §3). [version] and [revokedAt] seed the
  /// author's head the engine resolves, so a test can demote/remove a member
  /// before authoring a later change.
  Future<int> addSignedMember({
    required int spaceId,
    required DeviceKeys keys,
    required SharedMemberRole role,
    int version = 1,
    DateTime? revokedAt,
  }) async {
    final now = DateTime(2026);
    final member = SharedMember()
      ..sharedSpaceId = spaceId
      ..profileId = sharedMemberKey(keys.identityId)
      ..role = role
      ..joinedAt = now
      ..version = version
      ..updatedAt = now
      ..authorIdentityId = keys.identityId
      ..revokedAt = revokedAt;
    final signature = await Ed25519().sign(
      membershipCanonicalBytes(member),
      keyPair: keys.keyPair,
    );
    member.signature = base64Encode(signature.bytes);
    return isar.writeTxn(() => isar.sharedMembers.put(member));
  }

  /// Overwrites an existing membership's head so a test can demote or remove a
  /// member at a chosen HLC [version] (role-authorization §2).
  Future<void> setMemberHead({
    required int spaceId,
    required DeviceKeys keys,
    required SharedMemberRole role,
    required int version,
    DateTime? revokedAt,
  }) async {
    final existing = await isar.sharedMembers
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .profileIdEqualTo(sharedMemberKey(keys.identityId))
        .findFirst();
    final member = existing ??
        (SharedMember()
          ..sharedSpaceId = spaceId
          ..profileId = sharedMemberKey(keys.identityId)
          ..joinedAt = DateTime(2026));
    member
      ..role = role
      ..version = version
      ..authorIdentityId = keys.identityId
      ..revokedAt = revokedAt;
    final signature = await Ed25519().sign(
      membershipCanonicalBytes(member),
      keyPair: keys.keyPair,
    );
    member.signature = base64Encode(signature.bytes);
    await isar.writeTxn(() => isar.sharedMembers.put(member));
  }

  /// Seals a month by writing its [MonthRateSeal] row (R6), so the engine will
  /// refuse any further change targeting that month (T047).
  Future<void> sealMonth(String yearMonth) => isar.writeTxn(() async {
        await isar.monthRateSeals.put(
          MonthRateSeal()
            ..yearMonth = yearMonth
            ..status = SealStatus.sealed
            ..asOf = DateTime(2026)
            ..fetchedAt = DateTime(2026)
            ..updatedAt = DateTime(2026),
        );
      });

  /// Marks a context as paired with a peer (enables recording).
  Future<int> pairContext({
    required int peerId,
    required int spaceId,
    SharedMemberRole peerRole = SharedMemberRole.editor,
  }) {
    return isar.writeTxn(() async {
      final paired = PairedContext()
        ..peerId = peerId
        ..contextKind = ContextKind.shared
        ..contextLocalId = spaceId
        ..peerRole = peerRole
        ..pairedAt = DateTime(2026);
      return isar.pairedContexts.put(paired);
    });
  }

  Future<List<ChangeRecord>> changeRecords() =>
      isar.changeRecords.where().findAll();

  Future<void> close() async {
    await isar.close(deleteFromDisk: true);
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  }
}
