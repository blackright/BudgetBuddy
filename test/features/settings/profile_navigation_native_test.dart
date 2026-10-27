import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/lock_setting.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:budget_buddy/features/spaces/domain/shared_member_key.dart';
import 'package:budget_buddy/core/services/context_navigation.dart';
import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/settings/presentation/profile_switcher_section.dart';
import 'package:budget_buddy/features/settings/repositories/profile_name_repository.dart';
import 'package:budget_buddy/features/budget_setup/providers/budget_setup_provider.dart';
import '../medical/repositories/medical_test_harness.dart';

void main() {
  late Isar db;
  late Directory dir;
  int serial = 0;
  setUp(() async {
    await Isar.initializeIsarCore(download: false);
    dir = await Directory.systemTemp.createTemp('phase14_');
    db = await Isar.open(MedicalTestHarness.schemas,
        directory: dir.path, name: 'p14_${serial++}');
    IsarHelper.instance = db;
  });
  tearDown(() async {
    await db.close(deleteFromDisk: true);
    await dir.delete(recursive: true);
  });
  UserProfile profile(String name) => UserProfile()
    ..name = name
    ..primaryCurrency = PrimaryCurrency.huf
    ..monthlyAvailableAmount = 100
    ..createdAt = DateTime(2026)
    ..updatedAt = DateTime(2026);
  test('setup saves chosen name once and never overwrites another owner month',
      () async {
    await db.writeTxn(() async {
      await db.userProfiles.put(profile('Existing')..id = 7);
      await db.monthlyBudgets.put(MonthlyBudget()
        ..id = 8
        ..profileId = 7
        ..yearMonth = '2026-10'
        ..baseAvailableAmount = 500
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026));
    });
    final notifier = BudgetSetupNotifier()
      ..setName(' Jason ')
      ..setAmount(1000)
      ..setCurrency(PrimaryCurrency.huf)
      ..setYearMonth('2026-10');
    addTearDown(notifier.dispose);
    expect(await notifier.saveBudget(), isTrue);
    expect(await notifier.saveBudget(), isTrue);
    expect(await db.userProfiles.count(), 2);
    expect(await db.monthlyBudgets.count(), 2);
    final saved =
        (await db.userProfiles.where().findAll()).singleWhere((p) => p.id != 7);
    expect(saved.name, 'Jason');
    expect((await db.monthlyBudgets.get(8))!.baseAvailableAmount, 500);
    expect(
        (await db.monthlyBudgets.filter().profileIdEqualTo(saved.id).findAll())
            .length,
        1);
  });
  test(
      'blank name cannot create a profile; rename preserves id and money owner',
      () async {
    final setup = BudgetSetupNotifier()
      ..setAmount(100)
      ..setCurrency(PrimaryCurrency.huf)
      ..setYearMonth('2026-10');
    addTearDown(setup.dispose);
    expect(await setup.saveBudget(), isFalse);
    expect(await db.userProfiles.count(), 0);
    final controller = ProfileSwitcherController(db);
    await expectLater(controller.createProfile('  '), throwsArgumentError);
    final id = await controller.createProfile('User');
    await db.writeTxn(() async {
      await db.expenses.put(Expense(
          profileId: id,
          yearMonth: '2026-10',
          title: 'Rice',
          amount: 100,
          currency: 'HUF',
          categoryId: 'food',
          date: DateTime(2026, 10, 1),
          budgetId: 1));
    });
    await db.writeTxn(() async {
      await db.identitys.put(Identity()
        ..localProfileId = id
        ..username = 'Pairing Jason'
        ..fingerprint = 'stable-key'
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026));
      await db.auditEvents.put(AuditEvent()
        ..profileId = id
        ..timestamp = DateTime(2026)
        ..createdAt = DateTime(2026)
        ..userIdentity = 'User'
        ..action = 'legacy.action'
        ..objectType = 'Expense'
        ..hash = 'legacy'
        ..previousHash = '');
    });
    await ProfileNameRepository(db).rename(id, ' José ');
    expect((await db.userProfiles.get(id))!.name, 'José');
    expect((await db.expenses.where().findFirst())!.profileId, id);
    expect(await db.userProfiles.count(), 1);
    expect((await db.identitys.where().findFirst())!.username, 'Pairing Jason');
    expect((await db.identitys.where().findFirst())!.fingerprint, 'stable-key');
    expect((await db.auditEvents.where().findFirst())!.userIdentity, 'User');
    var checks = 0;
    await expectLater(
        ProfileNameRepository(db).rename(id, 'Wrong owner',
            assertCanRename: () {
          if (++checks == 2) throw StateError('Context changed');
        }),
        throwsStateError);
    expect((await db.userProfiles.get(id))!.name, 'José');
  });
  test(
      'identity-keyed removal cannot fall back to a stale active legacy membership',
      () async {
    await db.writeTxn(() async {
      await db.userProfiles.put(profile('Jason')..id = 1);
      await db.identitys.put(Identity()
        ..localProfileId = 1
        ..username = 'Jason sharing'
        ..fingerprint = 'key-123'
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026));
      await db.sharedSpaces.put(SharedSpace()
        ..id = 7
        ..name = 'Family'
        ..currency = PrimaryCurrency.huf
        ..createdByProfileId = 1
        ..createdAt = DateTime(2026));
      for (final id in [1, sharedMemberKey('key-123')]) {
        await db.sharedMembers.put(SharedMember()
          ..profileId = id
          ..sharedSpaceId = 7
          ..role = SharedMemberRole.viewer
          ..joinedAt = DateTime(2026)
          ..revokedAt = (id == 1 ? null : DateTime(2026)));
      }
    });
    expect(
        (await ContextNavigationRepository(db).choices(1))
            .map((c) => c.spaceId),
        [null]);
  });
  test(
      'chooser exposes permitted contexts, lock metadata and rejects revoked selection',
      () async {
    await db.writeTxn(() async {
      await db.userProfiles.put(profile('Jason')..id = 1);
      await db.userProfiles.put(profile('Other')..id = 2);
      for (final id in [3, 4, 5]) {
        await db.sharedSpaces.put(SharedSpace()
          ..id = id
          ..name = 'Space $id'
          ..currency = PrimaryCurrency.huf
          ..createdByProfileId = 1
          ..createdAt = DateTime(2026)
          ..requirePin = (id == 3));
      }
      await db.sharedMembers.put(SharedMember()
        ..profileId = 1
        ..sharedSpaceId = 3
        ..role = SharedMemberRole.viewer
        ..joinedAt = DateTime(2026));
      await db.sharedMembers.put(SharedMember()
        ..profileId = 1
        ..sharedSpaceId = 4
        ..role = SharedMemberRole.owner
        ..joinedAt = DateTime(2026)
        ..revokedAt = DateTime(2026));
      await db.sharedMembers.put(SharedMember()
        ..profileId = 2
        ..sharedSpaceId = 5
        ..role = SharedMemberRole.owner
        ..joinedAt = DateTime(2026));
      await db.lockSettings.put(
          LockSetting.forSubject(LockSubject.profile(id: 1, name: 'Jason'))
            ..lockEnabled = true);
    });
    final repo = ContextNavigationRepository(db),
        choices = await ContextNavigationRepository(db).choices(1);
    expect(choices.map((c) => c.spaceId), [null, 3]);
    expect(choices.every((c) => c.locked), isTrue);
    await db.writeTxn(() async {
      final member = (await db.sharedMembers
          .filter()
          .sharedSpaceIdEqualTo(3)
          .findFirst())!
        ..revokedAt = DateTime(2026);
      await db.sharedMembers.put(member);
    });
    await expectLater(repo.require(1, 3), throwsStateError);
  });
}
