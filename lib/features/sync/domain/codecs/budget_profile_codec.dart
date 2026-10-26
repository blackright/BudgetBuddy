import '../../../../core/models/budget_profile.dart';
import '../codec_support.dart';
import '../sync_codec.dart';

class BudgetProfileCodec extends SyncCodec<BudgetProfile> {
  const BudgetProfileCodec();
  @override
  String get entityType => 'BudgetProfile';
  @override
  Map<String, Object?> toJson(BudgetProfile p) => {
        'syncGuid': p.syncGuid,
        'yearMonth': p.yearMonth,
        'name': p.name,
        'familyGuid': p.familyGuid,
        'defaultAllocationMinor': p.defaultAllocationMinor,
        'monthEndOriginGuid': p.monthEndOriginGuid,
        'monthEndFingerprint': p.monthEndFingerprint,
        'allocation': p.allocation,
        'spent': p.spent,
        'monthEndRule': p.monthEndRule.name,
        'createdAt': encodeDate(p.createdAt),
        'updatedAt': encodeDate(p.updatedAt),
      };
  @override
  BudgetProfile fromJson(Map<String, Object?> j) => BudgetProfile()
    ..syncGuid = decodeGuid(j['syncGuid'])
    ..yearMonth = j['yearMonth'] as String
    ..name = j['name'] as String
    ..familyGuid = j['familyGuid'] as String? ?? ''
    ..defaultAllocationMinor = decodeIntOrNull(j['defaultAllocationMinor'])
    ..monthEndOriginGuid = decodeGuidOrNull(j['monthEndOriginGuid'])
    ..monthEndFingerprint = j['monthEndFingerprint'] as String?
    ..allocation = decodeInt(j['allocation'])
    ..spent = decodeInt(j['spent'])
    ..monthEndRule = decodeEnum(MonthEndRule.values, j['monthEndRule'])
    ..createdAt = decodeDateRequired(j['createdAt'])
    ..updatedAt = decodeDateRequired(j['updatedAt']);
}
