import 'dart:convert';
import '../../core/models/currency_code.dart';
import '../../core/models/money.dart';
import '../../core/network/rate_types.dart';
import '../engine/currency_conversion.dart';

const maxVaultMinor = 9007199254740991;
bool validVaultAmount(int value) => value >= 0 && value <= maxVaultMinor;
bool validVaultSignedAmount(int value) =>
    value >= -maxVaultMinor && value <= maxVaultMinor;

/// Bounds are checked BEFORE arithmetic/conversion, not after a native integer
/// may have overflowed or a double-to-integer conversion may have saturated.
int vaultSum(int left, int right) {
  if (!validVaultSignedAmount(left) || !validVaultSignedAmount(right)) {
    throw const FormatException('A source amount needs review.');
  }
  final sum = BigInt.from(left) + BigInt.from(right);
  if (sum < BigInt.from(-maxVaultMinor) || sum > BigInt.from(maxVaultMinor)) {
    throw const FormatException(
        'The calculation exceeds the supported amount range.');
  }
  return sum.toInt();
}

Money? vaultOpening(double major, CurrencyCode currency) {
  final raw = major * currency.minorUnitsPerMajor;
  if (!raw.isFinite || raw < -maxVaultMinor || raw > maxVaultMinor) return null;
  final value = Money.fromMajor(major, currency);
  return validVaultSignedAmount(value.minorUnits) ? value : null;
}

Money? vaultConvert(Money amount, CurrencyCode target, RateTable? table) {
  if (!validVaultSignedAmount(amount.minorUnits)) return null;
  final rate = amount.currency == target
      ? 1.0
      : table?.crossRate(amount.currency, target);
  if (rate == null || !rate.isFinite || rate <= 0) return null;
  final raw = amount.minorUnits *
      rate *
      target.minorUnitsPerMajor /
      amount.currency.minorUnitsPerMajor;
  if (!raw.isFinite || raw < -maxVaultMinor || raw > maxVaultMinor) return null;
  final result = convert(amount, target, table);
  return !result.isDegraded && validVaultSignedAmount(result.amount.minorUnits)
      ? result.amount
      : null;
}

/// Reject corrupt snapshot structures before any UI casts or money formatting.
Map<String, dynamic>? vaultBreakdown(String json) {
  try {
    final value = jsonDecode(json);
    if (value is! Map<String, dynamic> ||
        CurrencyCode.tryParse(value['currency'] is String
                ? value['currency'] as String
                : '') ==
            null) {
      return null;
    }
    for (final key in ['opening', 'spent', 'returned', 'carry', 'available']) {
      final amount = value[key];
      if (amount is! int ||
          !validVaultSignedAmount(amount) ||
          (['spent', 'returned', 'carry'].contains(key) && amount < 0)) {
        return null;
      }
    }
    final conversions = value['conversions'] ?? [];
    if (conversions is! List) return null;
    for (final c in conversions) {
      if (c is! Map ||
          c['from'] is! String ||
          c['to'] is! String ||
          CurrencyCode.tryParse(c['from'] as String) == null ||
          CurrencyCode.tryParse(c['to'] as String) == null ||
          c['original'] is! int ||
          c['converted'] is! int ||
          !validVaultSignedAmount(c['original'] as int) ||
          !validVaultSignedAmount(c['converted'] as int) ||
          c['rate'] is! num ||
          !(c['rate'] as num).isFinite ||
          (c['rate'] as num) <= 0) {
        return null;
      }
    }
    final transfer = value['vaultTransfers'] ?? 0;
    if (transfer is! int || !validVaultSignedAmount(transfer)) return null;
    var calculated = BigInt.from(value['opening'] as int) -
        BigInt.from(value['spent'] as int) +
        BigInt.from(value['returned'] as int) -
        BigInt.from(value['carry'] as int) +
        BigInt.from(transfer);
    if (value['formulaVersion'] == 2) {
      for (final key in ['income', 'unused', 'incoming', 'released']) {
        if (value[key] is! int || !validVaultAmount(value[key] as int)) {
          return null;
        }
      }
      calculated = BigInt.from(value['income'] as int) -
          BigInt.from(value['spent'] as int) +
          BigInt.from(value['returned'] as int) -
          BigInt.from(value['unused'] as int) -
          BigInt.from(value['carry'] as int) +
          BigInt.from(value['incoming'] as int) +
          BigInt.from(value['released'] as int) +
          BigInt.from(transfer);
    } else if (value['formulaVersion'] != null &&
        value['formulaVersion'] != 1) {
      return null;
    }
    return calculated == BigInt.from(value['available'] as int) ? value : null;
  } on FormatException {
    return null;
  }
}
