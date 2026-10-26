import 'dart:async';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/isar_helper.dart';
import '../../../core/models/financial_report.dart';
import '../../../core/models/lock_setting.dart';
import '../../../core/models/shared_member.dart';
import '../../../core/models/shared_space.dart';
import '../../../core/models/budget_profile.dart';
import '../../../core/models/direct_expense_profile.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/services/report_access.dart';
import '../../../core/services/report_service.dart';
import '../../../core/services/report_delivery.dart';
import '../../../core/services/report_format.dart';
import '../../security/providers/lock_providers.dart';

final reportPolicyEpochProvider = StreamProvider.autoDispose<int>((ref) {
  final db = IsarHelper.instance;
  final controller = StreamController<int>();
  var tick = 0;
  final subscriptions = [
    db.sharedMembers.watchLazy(fireImmediately: true),
    db.sharedSpaces.watchLazy(),
    db.lockSettings.watchLazy()
  ]
      .map((s) => s.listen((_) {
            if (!controller.isClosed) controller.add(++tick);
          }, onError: controller.addError))
      .toList();
  ref.onDispose(() {
    unawaited(Future.wait(subscriptions.map((s) => s.cancel()))
        .whenComplete(controller.close));
  });
  return controller.stream;
});

final reportServiceProvider = Provider.autoDispose<ReportService>((ref) {
  final owner = ref.watch(budgetContextProvider);
  final actor = ref.watch(actingProfileIdProvider);
  ref.watch(lockControllerProvider);
  bool alive = true;
  ref.onDispose(() => alive = false);
  void check() {
    if (!alive) throw StateError('The report session ended. Reopen Reports.');
    final current = ref.read(budgetContextProvider);
    final lock = ref.read(lockControllerProvider);
    if (actor == null ||
        ref.read(actingProfileIdProvider) != actor ||
        current.profileId != owner.profileId ||
        current.spaceId != owner.spaceId ||
        current.yearMonth != owner.yearMonth ||
        lock.isLocked ||
        ref.read(lockResolutionPendingProvider)) {
      throw StateError(
          'The context, lock or acting profile changed. Generate a new report.');
    }
  }

  return ReportService(IsarHelper.instance,
      access: ReportAccess(IsarHelper.instance, assertSession: check,
          isUnlocked: (key) {
        check();
        final state = ref.read(lockControllerProvider);
        return state.subject?.key == key && !state.isLocked;
      }));
});

final reportOwnersProvider =
    FutureProvider.autoDispose<List<ReportOwnerChoice>>((ref) {
  ref.watch(reportPolicyEpochProvider);
  final actor = ref.watch(actingProfileIdProvider);
  if (actor == null) return [];
  return ref.watch(reportServiceProvider).access.choices(actor);
});

final reportCurrentAccessProvider =
    FutureProvider.autoDispose.family<bool, FinancialReport>((ref, report) {
  ref.watch(reportPolicyEpochProvider);
  return ref
      .watch(reportServiceProvider)
      .access
      .authorize(report.request, report.actorId);
});

final reportFinancialProfilesProvider = FutureProvider.autoDispose
    .family<Map<String, String>, (ReportOwner, String, String)>(
        (ref, key) async {
  ref.watch(reportPolicyEpochProvider);
  final actor = ref.watch(actingProfileIdProvider);
  if (actor == null) return {};
  final (owner, first, last) = key;
  final service = ref.watch(reportServiceProvider);
  await service.access.authorize(
      ReportRequest(
          scope: ReportScope.financialProfile,
          personalProfileId: actor,
          owners: [owner],
          firstMonth: first,
          lastMonth: last,
          currency: CurrencyCode.huf),
      actor);
  final db = service.db;
  final budgets = await db.budgetProfiles
      .filter()
      .yearMonthBetween(first, last)
      .group((q) => owner.shared
          ? q.sharedSpaceIdEqualTo(owner.id)
          : q.sharedSpaceIdIsNull().profileIdEqualTo(owner.id))
      .sortByYearMonthDesc()
      .findAll();
  final directs = await db.directExpenseProfiles
      .filter()
      .yearMonthBetween(first, last)
      .group((q) => owner.shared
          ? q.sharedSpaceIdEqualTo(owner.id)
          : q.sharedSpaceIdIsNull().profileIdEqualTo(owner.id))
      .findAll();
  final result = <String, String>{'main': 'Main financial profile'};
  for (final p in budgets) {
    result.putIfAbsent(
        'budget:${p.familyGuid.isEmpty ? p.syncGuid : p.familyGuid}',
        () =>
            'Budget: ${p.name} (${p.familyGuid.isEmpty ? p.yearMonth : 'linked monthly profiles'})');
  }
  for (final p in directs) {
    result['direct:${p.syncGuid}'] = 'Direct: ${p.name} (${p.yearMonth})';
  }
  return Map.unmodifiable(result);
});

final reportDeliveryProvider = Provider.autoDispose<ReportDelivery>(
    (ref) => ReportDelivery(service: ref.watch(reportServiceProvider)));

typedef GenerateFinancialReport = Future<FinancialReport> Function(
    ReportRequest request, int actor);
final generateFinancialReportProvider =
    Provider.autoDispose<GenerateFinancialReport>(
        (ref) => ref.watch(reportServiceProvider).generate);
typedef SendFinancialReport = Future<ReportDeliveryResult> Function(
    FinancialReport report, ReportFileKind kind,
    {required bool share, ReportExportOptions options, Rect? origin});
final sendFinancialReportProvider = Provider.autoDispose<SendFinancialReport>(
    (ref) => ref.watch(reportDeliveryProvider).deliver);
