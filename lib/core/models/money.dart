import 'currency_code.dart';
import 'allocation.dart';
import 'budget_profile.dart';
import 'direct_expense_profile.dart';
import 'income_source.dart';
import 'transfer.dart';

/// An exact amount of money: whole minor units plus the currency they are in.
///
/// All financial arithmetic in the app happens on this type (FR-015):
/// - `+`/`−` are exact integer operations and refuse to mix currencies.
/// - Scaling by an exchange rate is the *only* place a value is rounded, and
///   that rounding is half-away-from-zero (data-model §1.2).
/// - Display never rounds: the formatter renders [minorUnits] directly.
class Money {
  const Money(this.minorUnits, this.currency);

  /// Whole minor units — for HUF one unit is a forint, for the rest a cent.
  final int minorUnits;

  /// The unit [minorUnits] is denominated in.
  final CurrencyCode currency;

  /// Builds from a major-unit value (e.g. `12.34` dollars), rounding to the
  /// currency's exponent half away from zero — the input-parsing rounding
  /// boundary named in data-model §1.2.
  factory Money.fromMajor(double major, CurrencyCode currency) => Money(
      _roundHalfAwayFromZero(major * currency.minorUnitsPerMajor), currency);

  /// Zero in [currency].
  factory Money.zero(CurrencyCode currency) => Money(0, currency);

  /// Major-unit value as a double. Display paths should use the formatter
  /// instead; this exists for engine code still expressed in majors.
  double get majorValue => minorUnits / currency.minorUnitsPerMajor;

  /// Exact addition. Throws [ArgumentError] when currencies differ — a
  /// mixed-unit sum is a bug, not a rounding question (contract §3).
  Money operator +(Money other) {
    _requireSameCurrency(other, 'add');
    return Money(minorUnits + other.minorUnits, currency);
  }

  /// Exact subtraction, same rules as `+`.
  Money operator -(Money other) {
    _requireSameCurrency(other, 'subtract');
    return Money(minorUnits - other.minorUnits, currency);
  }

  /// Rescales this amount by a major-unit [rate] into [target].
  ///
  /// [rate] is the major-to-major cross-rate (`usdRate[target] /
  /// usdRate[currency]`). Minor-unit factors on both sides are applied here so
  /// the result is correct across differing exponents (HUF→USD and back), and
  /// the single rounding happens at the end, half away from zero.
  Money scaledBy(double rate, CurrencyCode target) {
    if (target == currency) return this;
    final raw = minorUnits *
        rate *
        target.minorUnitsPerMajor /
        currency.minorUnitsPerMajor;
    return Money(_roundHalfAwayFromZero(raw), target);
  }

  /// Round-half-away-from-zero; Dart's [num.round] rounds halves away from
  /// zero for both signs, which is exactly the rule data-model §1.2 asks for.
  static int _roundHalfAwayFromZero(double value) => value.round();

  void _requireSameCurrency(Money other, String operation) {
    if (other.currency != currency) {
      throw ArgumentError(
        'Cannot $operation money in different currencies: '
        '${currency.code} vs ${other.currency.code}',
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Money &&
      other.minorUnits == minorUnits &&
      other.currency == currency;

  @override
  int get hashCode => Object.hash(minorUnits, currency);

  @override
  String toString() => 'Money($minorUnits ${currency.code})';
}

/// Bridges the new financial entities to [Money] (T110).
///
/// Every new entity stores its money the same way the app already does: whole
/// **minor units** in an `int` plus the currency code as a `String`. The code
/// is a raw string on purpose (FR-021): a legacy or unsupported code must
/// survive verbatim instead of being silently re-coded.
///
/// These helpers turn that pair into a real [Money] so the exact-arithmetic
/// rules apply, and they return `null` for an unsupported code instead of
/// inventing one.
extension IncomeSourceMoney on IncomeSource {
  /// This source's amount as [Money], or `null` for an unsupported currency.
  Money? get money {
    final code = CurrencyCode.tryParse(currency);
    if (code == null) return null;
    return Money(amount, code);
  }
}

extension BudgetProfileMoney on BudgetProfile {
  /// This profile's allocation as [Money] in the context currency.
  ///
  /// A budget profile has no currency column of its own: it spends in the
  /// context's currency (the profile's or the space's), so the caller passes it.
  Money allocationIn(CurrencyCode currency) => Money(allocation, currency);

  /// This profile's spending as [Money] in the context currency.
  Money spentIn(CurrencyCode currency) => Money(spent, currency);
}

extension DirectExpenseProfileMoney on DirectExpenseProfile {
  /// This profile's spending as [Money] in the context currency.
  Money spentIn(CurrencyCode currency) => Money(spent, currency);
}

extension AllocationMoney on Allocation {
  /// This allocation as [Money], or `null` for an unsupported currency.
  Money? get money {
    final code = CurrencyCode.tryParse(currency);
    if (code == null) return null;
    return Money(amount, code);
  }
}

extension TransferMoney on Transfer {
  /// This transfer as [Money], or `null` for an unsupported currency.
  Money? get money {
    final code = CurrencyCode.tryParse(currency);
    if (code == null) return null;
    return Money(amount, code);
  }
}
