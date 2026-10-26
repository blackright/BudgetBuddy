// ignore_for_file: experimental_member_use
import 'package:isar/isar.dart';

import '../../../core/models/currency_code.dart';
import '../vault_math.dart';

part 'savings_vault.g.dart';

/// The personal "Savings Vault": money swept out of finished months.
///
/// Scoping (FR-015 of 011/012): the vault belongs to a `UserProfile` and is
/// **never** shared or synced. A shared space has no vault; the UI hides and
/// blocks it there.
///
/// Money is stored exactly like every other amount: whole minor units plus the
/// currency they are in. The vault keeps the currency it was created with, so a
/// later main-currency change does not rewrite saved history.
@collection
class SavingsVault {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int profileId;

  /// Current saved balance after sweeps and funded transfers, in minor units.
  int totalMinor = 0;

  @ignore
  bool get hasValidBalance => validVaultAmount(totalMinor);

  /// Informational only: a goal never reserves or transfers funds.
  String? goalName;
  int? goalTargetMinor;
  String? goalTargetYearMonth;

  /// The currency [totalMinor] is denominated in. Empty on a legacy row until
  /// migration step 22 stamps it from the owning profile.
  String currency = '';

  /// The last month whose sweep has been accounted for (`YYYY-MM`).
  ///
  /// The next sweep starts at this month and stops before the current one, so
  /// repeated starts cannot double-count. A newly created vault starts at the
  /// current month, deliberately avoiding a retroactive sweep.
  late String lastSweepYearMonth;

  /// True when a sweep could not value the next month (unconfirmed opening
  /// balance, unsupported currency, missing as-of rate). [pauseReason] says
  /// which, and the sweep resumes from the same month next time.
  bool sweepPaused = false;

  String? pauseReason;

  late DateTime updatedAt;

  /// The vault's currency, or `null` for an unsupported legacy code.
  @ignore
  CurrencyCode? get currencyCode => CurrencyCode.tryParse(currency);

  /// Legacy major-unit total (pre-minor-units). Read by migration step 22 and
  /// then zeroed; never written by new code.
  @Deprecated(
      'Use totalMinor; kept only so step 22 can read pre-migration rows.')
  double totalAmount = 0.0;
}
