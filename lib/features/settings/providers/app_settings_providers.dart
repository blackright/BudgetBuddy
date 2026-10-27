import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/app_settings.dart';
import '../../../core/models/monthly_budget.dart';
import '../../budget_setup/domain/onboarding_state.dart';

class StaleOnboardingRevisionException implements Exception {
  const StaleOnboardingRevisionException();
  @override
  String toString() => 'Setup changed. Reload it and review before saving.';
}

final appSettingsRepositoryProvider = Provider<AppSettingsRepository>((ref) {
  return AppSettingsRepository(IsarHelper.instance);
});

class AppSettingsRepository {
  final Isar _isar;

  AppSettingsRepository(this._isar);

  Stream<AppSettings?> watch() {
    return _isar.appSettings.watchObject(1, fireImmediately: true);
  }

  Future<AppSettings> getOrCreate() => _isar.writeTxn(getOrCreateInTxn);

  /// Caller owns the write transaction. Always reload; never patch a cached row.
  Future<AppSettings> getOrCreateInTxn() async {
    final existing = await _isar.appSettings.get(1);
    if (existing != null) return existing;
    final now = DateTime.now();
    final settings = AppSettings()
      ..id = 1
      ..transferToggle = false
      ..createdAt = now
      ..updatedAt = now;
    await _isar.appSettings.put(settings);
    return settings;
  }

  Future<void> setTransferToggle(bool value) async {
    await _isar.writeTxn(() async {
      final settings = await getOrCreateInTxn();
      settings.transferToggle = value;
      settings.updatedAt = DateTime.now();
      await _isar.appSettings.put(settings);
    });
  }

  Future<void> setDecimalPreferences(String? value) => _isar.writeTxn(() async {
        final settings = await getOrCreateInTxn();
        settings.decimalPreferences = value;
        settings.updatedAt = DateTime.now();
        await _isar.appSettings.put(settings);
      });

  Future<void> saveOnboardingState(OnboardingState next,
          {required String? expectedFlowId, required int? expectedRevision}) =>
      _isar.writeTxn(() => saveOnboardingStateInTxn(next,
          expectedFlowId: expectedFlowId, expectedRevision: expectedRevision));

  /// Compare-and-set inside the caller's transaction. No partial settings write
  /// occurs before shape/revision validation. Financial coordination comes later.
  Future<void> saveOnboardingStateInTxn(OnboardingState next,
      {required String? expectedFlowId, required int? expectedRevision}) async {
    await _saveProgressInTxn(next,
        expectedFlowId: expectedFlowId, expectedRevision: expectedRevision);
  }

  /// Only the reviewed financial amendment transaction may move the same month
  /// row. Ordinary settings/progress patches retain their immutable-owner guard.
  Future<void> saveReviewedAmendmentInTxn(OnboardingState next,
      {required String expectedFlowId, required int expectedRevision}) async {
    final receipt = next.committed;
    final month = receipt == null
        ? null
        : await _isar.monthlyBudgets.get(receipt.budgetId);
    if (receipt == null ||
        month == null ||
        month.profileId != receipt.profileId ||
        month.sharedSpaceId != null ||
        month.syncGuid != receipt.budgetSyncGuid ||
        month.yearMonth != receipt.yearMonth) {
      throw const StaleOnboardingRevisionException();
    }
    await _saveProgressInTxn(next,
        expectedFlowId: expectedFlowId,
        expectedRevision: expectedRevision,
        reviewedMonthChange: true);
  }

  Future<void> _saveProgressInTxn(OnboardingState next,
      {required String? expectedFlowId,
      required int? expectedRevision,
      bool reviewedMonthChange = false}) async {
    final encoded = next.encode();
    final existing = await _isar.appSettings.get(1);
    final raw = existing?.onboardingStateJson;
    final current = raw == null ? null : OnboardingState.decode(raw);
    if (current == null) {
      if (expectedFlowId != null ||
          expectedRevision != null ||
          next.revision != 0 ||
          next.stage != OnboardingStage.draft) {
        throw const StaleOnboardingRevisionException();
      }
    } else if (expectedFlowId != current.flowId ||
        expectedRevision != current.revision ||
        next.flowId != current.flowId ||
        next.revision != current.revision + 1 ||
        !next.createdAt.isAtSameMomentAs(current.createdAt) ||
        next.updatedAt.isBefore(current.updatedAt)) {
      throw const StaleOnboardingRevisionException();
    }
    final previousReference = current?.committed;
    final nextReference = next.committed;
    if (previousReference != null &&
        (nextReference == null ||
            nextReference.profileId != previousReference.profileId ||
            nextReference.budgetId != previousReference.budgetId ||
            nextReference.budgetSyncGuid != previousReference.budgetSyncGuid ||
            (!reviewedMonthChange &&
                nextReference.yearMonth != previousReference.yearMonth) ||
            (current!.stage == OnboardingStage.completed &&
                next.stage != OnboardingStage.completed))) {
      throw const StaleOnboardingRevisionException();
    }
    final settings = existing ?? await getOrCreateInTxn();
    settings.onboardingStateJson = encoded;
    settings.updatedAt = DateTime.now();
    await _isar.appSettings.put(settings);
  }
}

final appSettingsProvider = StreamProvider<AppSettings?>((ref) {
  return ref.watch(appSettingsRepositoryProvider).watch();
});

final transferToggleProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).value?.transferToggle ?? false;
});
