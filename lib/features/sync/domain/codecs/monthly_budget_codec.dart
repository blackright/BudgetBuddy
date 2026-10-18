import '../../../../core/models/monthly_budget.dart';
import '../codec_support.dart';
import '../sync_codec.dart';

/// Canonical codec for [MonthlyBudget] (data-model §2.6, FR-010).
class MonthlyBudgetCodec extends SyncCodec<MonthlyBudget> {
  const MonthlyBudgetCodec();

  @override
  String get entityType => 'MonthlyBudget';

  @override
  Map<String, Object?> toJson(MonthlyBudget value) => {
        'syncGuid': value.syncGuid,
        'yearMonth': value.yearMonth,
        'profileId': value.profileId,
        'sharedIncomeOverride': value.sharedIncomeOverride,
        'baseAvailableAmount': value.baseAvailableAmount,
        'openingBalanceConfirmed': value.openingBalanceConfirmed,
        'netSalaryOverride': value.netSalaryOverride,
        'currency': value.currency,
        'createdAt': encodeDate(value.createdAt),
        'updatedAt': encodeDate(value.updatedAt),
      };

  @override
  MonthlyBudget fromJson(Map<String, Object?> json) => MonthlyBudget()
    ..syncGuid = decodeGuid(json['syncGuid'])
    ..yearMonth = (json['yearMonth'] as String?) ?? ''
    ..profileId = decodeIntOrNull(json['profileId'])
    ..sharedIncomeOverride = decodeIntOrNull(json['sharedIncomeOverride'])
    ..baseAvailableAmount = decodeDouble(json['baseAvailableAmount'])
    ..openingBalanceConfirmed =
        (json['openingBalanceConfirmed'] as bool?) ?? false
    ..netSalaryOverride = decodeDoubleOrNull(json['netSalaryOverride'])
    ..currency = json['currency'] as String?
    ..createdAt = decodeDateRequired(json['createdAt'])
    ..updatedAt = decodeDateRequired(json['updatedAt']);
}
