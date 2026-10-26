import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'currency_code.dart';
import 'money.dart';

const fxMoneyBound = 9007199254740991;

int checkedFxMinor(int value) {
  if (BigInt.from(value).abs() > BigInt.from(fxMoneyBound)) {
    throw const FormatException('FX amount exceeds the exact money range.');
  }
  return value;
}

/// Decimal rate input is converted to a rational before any money arithmetic.
/// BigInt avoids losing a cent at intermediate multiplication boundaries.
(BigInt, BigInt) fxDecimal(String text) {
  if (text.length > 80 ||
      !RegExp(r'^\d+(\.\d+)?([eE][+-]?\d+)?$').hasMatch(text)) {
    throw const FormatException('Invalid FX rate.');
  }
  final parts = text.toLowerCase().split('e');
  final exponent = parts.length == 2 ? int.parse(parts[1]) : 0;
  if (exponent.abs() > 60) {
    throw const FormatException('FX rate outside supported range.');
  }
  final decimal = parts.first.split('.');
  final digits = decimal.join();
  var n = BigInt.parse(digits),
      d = BigInt.from(10).pow(decimal.length == 2 ? decimal[1].length : 0);
  if (exponent >= 0) {
    n *= BigInt.from(10).pow(exponent);
  } else {
    d *= BigInt.from(10).pow(-exponent);
  }
  if (n <= BigInt.zero) {
    throw const FormatException('FX rate must be positive.');
  }
  final gcd = n.gcd(d);
  return (n ~/ gcd, d ~/ gcd);
}

int fxRound(BigInt numerator, BigInt denominator) {
  if (denominator <= BigInt.zero) {
    throw const FormatException('Invalid FX denominator.');
  }
  final absolute = numerator.abs();
  final rounded = (absolute + denominator ~/ BigInt.two) ~/ denominator;
  if (rounded > BigInt.from(fxMoneyBound)) {
    throw const FormatException(
        'Converted FX amount exceeds the exact money range.');
  }
  return (numerator.isNegative ? -rounded : rounded).toInt();
}

int fxConvertMinor(int original, CurrencyCode from, CurrencyCode to,
    String numerator, String denominator) {
  checkedFxMinor(original);
  if (!RegExp(r'^[1-9][0-9]{0,149}$').hasMatch(numerator) ||
      !RegExp(r'^[1-9][0-9]{0,149}$').hasMatch(denominator)) {
    throw const FormatException('Invalid booked FX rate.');
  }
  final n = BigInt.tryParse(numerator), d = BigInt.tryParse(denominator);
  if (n == null ||
      d == null ||
      n <= BigInt.zero ||
      d <= BigInt.zero ||
      numerator.length > 150 ||
      denominator.length > 150) {
    throw const FormatException('Invalid booked FX rate.');
  }
  if (from == to && n != d) {
    throw const FormatException('Same-currency FX must be one to one.');
  }
  return fxRound(BigInt.from(original) * n * BigInt.from(to.minorUnitsPerMajor),
      d * BigInt.from(from.minorUnitsPerMajor));
}

/// An immutable paid-value revision. Previous revisions remain in its envelope
/// and are also retained in immutable audit events and signed change history.
class FxRevision {
  FxRevision(
      {required this.id,
      required this.target,
      required this.context,
      required this.kind,
      required this.originalMinor,
      required this.originalCurrency,
      required this.baseMinor,
      required this.baseCurrency,
      required this.numerator,
      required this.denominator,
      required this.source,
      required this.asOf,
      required this.capturedAt,
      required this.previousHash,
      this.expenseRevision,
      this.parentOriginalMinor,
      this.parentBaseMinor,
      this.cumulativeOriginalMinor,
      this.priorRefundBaseMinor});
  final String id,
      target,
      context,
      kind,
      originalCurrency,
      baseCurrency,
      numerator,
      denominator,
      source,
      asOf,
      capturedAt,
      previousHash;
  final int originalMinor, baseMinor;
  final String? expenseRevision;
  final int? parentOriginalMinor,
      parentBaseMinor,
      cumulativeOriginalMinor,
      priorRefundBaseMinor;
  Map<String, Object?> get json => {
        'version': 1,
        'id': id,
        'target': target,
        'context': context,
        'kind': kind,
        'originalMinor': originalMinor,
        'originalCurrency': originalCurrency,
        'baseMinor': baseMinor,
        'baseCurrency': baseCurrency,
        'numerator': numerator,
        'denominator': denominator,
        'source': source,
        'asOf': asOf,
        'capturedAt': capturedAt,
        'previousHash': previousHash,
        'expenseRevision': expenseRevision,
        'parentOriginalMinor': parentOriginalMinor,
        'parentBaseMinor': parentBaseMinor,
        'cumulativeOriginalMinor': cumulativeOriginalMinor,
        'priorRefundBaseMinor': priorRefundBaseMinor
      };
  String get hash => sha256.convert(utf8.encode(jsonEncode(json))).toString();
  Money get money => Money(baseMinor, CurrencyCode.tryParse(baseCurrency)!);
  void validate() {
    final from = CurrencyCode.tryParse(originalCurrency),
        to = CurrencyCode.tryParse(baseCurrency);
    if (id.isEmpty ||
        target.isEmpty ||
        context.isEmpty ||
        source.isEmpty ||
        from == null ||
        to == null ||
        originalCurrency != from.code.toUpperCase() ||
        baseCurrency != to.code.toUpperCase() ||
        DateTime.tryParse(asOf) == null ||
        DateTime.tryParse(capturedAt) == null ||
        originalMinor < 0 ||
        baseMinor < 0) {
      throw const FormatException('Booked FX evidence needs review.');
    }
    checkedFxMinor(originalMinor);
    checkedFxMinor(baseMinor);
    final expected =
        fxConvertMinor(originalMinor, from, to, numerator, denominator);
    if (kind == 'expense') {
      if (expected != baseMinor || expenseRevision != null) {
        throw const FormatException('Booked expense FX does not reconcile.');
      }
    } else if (kind == 'refund') {
      final total = parentOriginalMinor,
          base = parentBaseMinor,
          cumulative = cumulativeOriginalMinor,
          prior = priorRefundBaseMinor;
      if (expenseRevision == null ||
          total == null ||
          base == null ||
          cumulative == null ||
          prior == null ||
          total <= 0 ||
          base < 0 ||
          originalMinor <= 0 ||
          cumulative < originalMinor ||
          cumulative > total ||
          prior < 0 ||
          prior > base) {
        throw const FormatException('Refund FX parent evidence needs review.');
      }
      checkedFxMinor(total);
      checkedFxMinor(base);
      checkedFxMinor(cumulative);
      checkedFxMinor(prior);
      if (fxConvertMinor(total, from, to, numerator, denominator) != base ||
          fxRound(BigInt.from(base) * BigInt.from(cumulative - originalMinor),
                  BigInt.from(total)) !=
              prior) {
        throw const FormatException(
            'Refund FX cumulative evidence is inconsistent.');
      }
      if (fxRound(BigInt.from(base) * BigInt.from(cumulative),
                  BigInt.from(total)) -
              prior !=
          baseMinor) {
        throw const FormatException('Booked refund FX does not reconcile.');
      }
    } else {
      throw const FormatException('Unsupported FX evidence kind.');
    }
  }

  static FxRevision fromJson(Map<String, dynamic> j) {
    if (j['version'] != 1) {
      throw const FormatException('Unsupported FX evidence version.');
    }
    try {
      final row = FxRevision(
          id: j['id'] as String,
          target: j['target'] as String,
          context: j['context'] as String,
          kind: j['kind'] as String,
          originalMinor: j['originalMinor'] as int,
          originalCurrency: j['originalCurrency'] as String,
          baseMinor: j['baseMinor'] as int,
          baseCurrency: j['baseCurrency'] as String,
          numerator: j['numerator'] as String,
          denominator: j['denominator'] as String,
          source: j['source'] as String,
          asOf: j['asOf'] as String,
          capturedAt: j['capturedAt'] as String,
          previousHash: j['previousHash'] as String,
          expenseRevision: j['expenseRevision'] as String?,
          parentOriginalMinor: j['parentOriginalMinor'] as int?,
          parentBaseMinor: j['parentBaseMinor'] as int?,
          cumulativeOriginalMinor: j['cumulativeOriginalMinor'] as int?,
          priorRefundBaseMinor: j['priorRefundBaseMinor'] as int?);
      row.validate();
      return row;
    } on TypeError {
      throw const FormatException('Malformed booked FX evidence.');
    }
  }
}

class FxHistory {
  FxHistory(Iterable<FxRevision> rows) : revisions = List.unmodifiable(rows) {
    if (revisions.isEmpty || revisions.length > 512) {
      throw const FormatException('FX history length needs review.');
    }
    var previous = '';
    final ids = <String>{};
    for (final row in revisions) {
      row.validate();
      if (!ids.add(row.id) ||
          row.previousHash != previous ||
          row.target != revisions.first.target ||
          row.context != revisions.first.context ||
          row.kind != revisions.first.kind) {
        throw const FormatException('FX revision chain is inconsistent.');
      }
      previous = row.hash;
    }
  }
  final List<FxRevision> revisions;
  FxRevision get current => revisions.last;
  String encode() => jsonEncode(
      {'version': 1, 'revisions': revisions.map((r) => r.json).toList()});
  static FxHistory? decode(String? value) {
    if (value == null) return null;
    if (value.length > 512 * 1024) {
      throw const FormatException('FX evidence exceeds supported size.');
    }
    try {
      final json = jsonDecode(value) as Map<String, dynamic>;
      if (json['version'] != 1) {
        throw const FormatException('Unsupported FX history.');
      }
      return FxHistory((json['revisions'] as List).map(
          (r) => FxRevision.fromJson(Map<String, dynamic>.from(r as Map))));
    } on TypeError {
      throw const FormatException('Malformed FX history.');
    }
  }

  void matches(String target, int amount, String currency, String kind) {
    if (current.target != target ||
        current.originalMinor != amount ||
        current.originalCurrency != currency.toUpperCase() ||
        current.kind != kind) {
      throw const FormatException('FX evidence differs from its transaction.');
    }
  }

  void extendsHistory(FxHistory? previous) {
    if (previous == null) return;
    if (revisions.length < previous.revisions.length) {
      throw const FormatException('FX history cannot be removed.');
    }
    for (var i = 0; i < previous.revisions.length; i++) {
      if (previous.revisions[i].hash != revisions[i].hash) {
        throw const FormatException('FX history cannot be rewritten.');
      }
    }
  }
}
