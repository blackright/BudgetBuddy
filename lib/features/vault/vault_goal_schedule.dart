import 'vault_math.dart';

bool validGoalMonth(String? month) =>
    month != null && RegExp(r'^[1-9]\d{3}-(0[1-9]|1[0-2])$').hasMatch(month);

String vaultYearMonth(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';

class VaultGoalSchedule {
  VaultGoalSchedule(
      {required int target,
      required int saved,
      required String? targetMonth,
      required DateTime now}) {
    if (!validVaultAmount(target) || target == 0 || !validVaultAmount(saved)) {
      throw const FormatException('The savings goal needs review.');
    }
    remaining = target > saved ? target - saved : 0;
    invalid = targetMonth != null && !validGoalMonth(targetMonth);
    if (targetMonth == null || invalid) return;
    months = (int.parse(targetMonth.substring(0, 4)) - now.year) * 12 +
        int.parse(targetMonth.substring(5)) -
        now.month +
        1;
    overdue = months! <= 0 && remaining > 0;
    if (months! > 0) {
      suggested = (remaining ~/ months!) + (remaining % months! == 0 ? 0 : 1);
    }
    if (remaining == 0) suggested = 0;
  }
  late final int remaining;
  late final bool invalid;
  int? months, suggested;
  bool overdue = false;
}
