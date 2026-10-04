import 'package:isar/isar.dart';

part 'savings_vault.g.dart';

@collection
class SavingsVault {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int profileId;

  double totalAmount = 0.0;

  late String lastSweepYearMonth;
}
