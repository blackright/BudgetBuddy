import 'package:isar/isar.dart';
part 'legacy_savings_vault.g.dart';

/// Actual pre-minor-unit storage shape, for native close/reopen upgrade tests.
@Collection(accessor: 'legacyVaults')
@Name('SavingsVault')
class LegacySavingsVault {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late int profileId;
  double totalAmount = 0;
  late String lastSweepYearMonth;
  late DateTime updatedAt;
}
