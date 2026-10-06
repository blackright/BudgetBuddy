import 'user_profile.dart';

/// The single source of truth for a currency the app supports.
///
/// Exactly four values are representable — adding one is a single enum entry,
/// and every `switch` over this type is exhaustiveness-checked by the compiler
/// (FR-001). Persisted currency strings are *not* this enum: they are read back
/// through [CurrencyCode.tryParse] so a legacy value the app no longer
/// understands (e.g. `GBP`) is preserved verbatim instead of being silently
/// re-coded (FR-021, data-model §4.4).
enum CurrencyCode {
  huf(symbol: 'Ft', exponent: 0, displayName: 'Forint'),
  usd(symbol: r'$', exponent: 2, displayName: 'US Dollar'),
  cad(symbol: r'C$', exponent: 2, displayName: 'Canadian Dollar'),
  eur(symbol: '€', exponent: 2, displayName: 'Euro');

  const CurrencyCode({
    required this.symbol,
    required this.exponent,
    required this.displayName,
  });

  /// Rendering symbol, from this enum only — no screen may hardcode one
  /// (contract currency-conversion §4).
  final String symbol;

  /// Decimal places in the major unit: HUF has none (fixes the phantom-cents
  /// defect D10), the rest have two.
  final int exponent;

  /// Human-readable name for pickers and settings.
  final String displayName;

  /// ISO-style lowercase code (`huf`, `usd`, `cad`, `eur`).
  String get code => name;

  /// Minor units in one major unit: 1 for HUF, 100 for the rest.
  int get minorUnitsPerMajor {
    var factor = 1;
    for (var i = 0; i < exponent; i++) {
      factor *= 10;
    }
    return factor;
  }

  /// Coerces a persisted string to a supported code, case-insensitively.
  ///
  /// Returns `null` for anything outside the four codes (including legacy
  /// `GBP`): the caller keeps the raw record and excludes it from converted
  /// totals — never a fabricated re-code (FR-021, data-model §4.4).
  static CurrencyCode? tryParse(String? raw) {
    if (raw == null) return null;
    final normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    for (final code in values) {
      if (code.name == normalized) return code;
    }
    return null;
  }

  /// Like [tryParse] but falls back to [fallback] for legacy display paths that
  /// must not show an "unsupported" label for a merely-missing value.
  static CurrencyCode parseOr(String? raw, {CurrencyCode fallback = huf}) =>
      tryParse(raw) ?? fallback;
}

/// Bridge from the persisted [PrimaryCurrency] enum to [CurrencyCode].
///
/// Both enums carry the same four members in the same order; the switches are
/// exhaustive in both directions so a future member cannot pair up wrongly.
extension PrimaryCurrencyCode on PrimaryCurrency {
  CurrencyCode get code => switch (this) {
        PrimaryCurrency.huf => CurrencyCode.huf,
        PrimaryCurrency.usd => CurrencyCode.usd,
        PrimaryCurrency.cad => CurrencyCode.cad,
        PrimaryCurrency.eur => CurrencyCode.eur,
      };
}

extension CurrencyCodePrimary on CurrencyCode {
  PrimaryCurrency get primary => switch (this) {
        CurrencyCode.huf => PrimaryCurrency.huf,
        CurrencyCode.usd => PrimaryCurrency.usd,
        CurrencyCode.cad => PrimaryCurrency.cad,
        CurrencyCode.eur => PrimaryCurrency.eur,
      };
}
