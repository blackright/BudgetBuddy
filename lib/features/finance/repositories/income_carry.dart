import '../../../core/models/currency_code.dart';
import '../../../core/models/money.dart';
import '../../../core/network/rate_types.dart';
import '../../engine/currency_conversion.dart' as conversion;

/// Carries a month's resolved income across a `moveMonth` boundary
/// (contracts/shared-income.md §3, FR-008).
///
/// Moving a month re-homes it between the personal "My income" pot and the
/// shared "Our income" pot. The resolved figure follows into the **target
/// pot's per-month override**, converted at the single boundary against the
/// month's governing table (its seal when sealed, otherwise live/bundled) and
/// rounded half-away-from-zero exactly once — inside [Money.scaledBy] via the
/// one [conversion.convert] path.
///
/// Same currency both sides carries the figure verbatim: the source and target
/// pot store the same value in different representations (major `double`
/// personal vs whole minor `int` shared), and [Money.fromMajor]/[majorValue]
/// round-trip it without inventing a rate.
class IncomeCarry {
  const IncomeCarry._();

  /// personal → shared: the resolved "My income" (major units of [profileMain])
  /// becomes an "Our income" override in whole minor units of [spaceCurrency].
  static int toSharedMinor({
    required double resolvedMyIncomeMajor,
    required CurrencyCode profileMain,
    required CurrencyCode spaceCurrency,
    required RateTable? table,
  }) {
    final source = Money.fromMajor(resolvedMyIncomeMajor, profileMain);
    return conversion.convert(source, spaceCurrency, table).amount.minorUnits;
  }

  /// shared → personal: the resolved "Our income" (whole minor units of
  /// [spaceCurrency]) becomes a "My income" override in major units of
  /// [profileMain].
  static double toPersonalMajor({
    required int resolvedOurIncomeMinor,
    required CurrencyCode spaceCurrency,
    required CurrencyCode profileMain,
    required RateTable? table,
  }) {
    final source = Money(resolvedOurIncomeMinor, spaceCurrency);
    return conversion.convert(source, profileMain, table).amount.majorValue;
  }
}
