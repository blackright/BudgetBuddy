import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/currency_code.dart';
import 'rate_types.dart';

final exchangeRateClientProvider = Provider<ExchangeRateClient>((ref) {
  return ExchangeRateClient();
});

/// Frankfurter-backed rate client (research R1).
///
/// Free, no API key, and empirically verified on 2026-10-06 to serve the four
/// currencies this app supports, both live (`/v1/latest?base=USD`) and for
/// historical dates (`/v1/{yyyy-MM-dd}?base=USD`).
///
/// Frankfurter answers 404 for non-business days (weekends, holidays —
/// verified for 2026-09-26 and 2026-10-04), so historical fetches walk back up
/// to [_maxWalkBackDays] days to the previous business day. A walk-back is
/// silent and correct: the table's `asOf` records the date actually served.
class ExchangeRateClient {
  ExchangeRateClient([Dio? dio])
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  static const String _baseUrl = 'https://api.frankfurter.dev/v1';

  /// Weekend/holiday tolerance for historical lookups.
  static const int _maxWalkBackDays = 7;

  final Dio _dio;

  /// Live table for today, referenced to USD. `null` when the provider is
  /// unreachable or the response cannot satisfy the four-currency invariant.
  Future<RateSnapshot?> fetchLatest() async {
    final data = await _getJson('$_baseUrl/latest?base=USD');
    if (data == null) return null;
    return _toSnapshot(data, source: RateSource.live);
  }

  /// Table for [date]'s business day, referenced to USD. Walks back up to
  /// [_maxWalkBackDays] days when the provider 404s (weekends/holidays) and
  /// gives up — `null` — when no day in that window is a business day.
  Future<RateSnapshot?> fetchHistorical(DateTime date) async {
    for (var offset = 0; offset <= _maxWalkBackDays; offset++) {
      final attempt = DateTime(date.year, date.month, date.day - offset);
      final data = await _getJson(
        '$_baseUrl/${_isoDate(attempt)}?base=USD',
      );
      if (data == null) continue;
      return _toSnapshot(data, source: RateSource.historical);
    }
    return null;
  }

  /// Legacy broad fetch used by the old rate cache until User Story 1 removes
  /// it. Returns every currency the provider quoted against [baseCurrency],
  /// or an empty map on failure (same contract as before the rewrite).
  Future<Map<String, double>> fetchLatestRates(String baseCurrency) async {
    final data = await _getJson('$_baseUrl/latest?base=$baseCurrency');
    if (data == null) return {};
    final rates = data['rates'];
    if (rates is! Map) return {};
    return rates.map(
      (key, value) => MapEntry(
        key.toString(),
        value is num ? value.toDouble() : 0.0,
      ),
    );
  }

  Future<Map<String, dynamic>?> _getJson(String url) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(url);
      if (response.statusCode != 200) return null;
      return response.data;
    } on DioException {
      // 404 on non-business days, timeouts, offline — all collapse to null so
      // callers decide what degradation means for them (FR-014).
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Converts a provider payload into a validated four-currency snapshot.
  /// Missing any supported currency yields `null`: a partial table can never
  /// reach the registry (FR-014, data-model §2.1 invariants).
  RateSnapshot? _toSnapshot(
    Map<String, dynamic> data, {
    required RateSource source,
  }) {
    final rawRates = data['rates'];
    if (rawRates is! Map) return null;

    final quoted = <CurrencyCode, double>{};
    for (final code in CurrencyCode.values) {
      if (code == CurrencyCode.usd) continue; // base ≡ 1, never quoted
      final value = rawRates[code.name.toUpperCase()] ??
          rawRates[code.name.toLowerCase()];
      if (value is! num) return null;
      quoted[code] = value.toDouble();
    }

    final asOf = DateTime.tryParse('${data['date']}') ?? DateTime.now();
    final usdRates = <CurrencyCode, double>{
      CurrencyCode.usd: 1.0,
      ...quoted,
    };

    return RateSnapshot.tryCreate(
      usdRates: usdRates,
      asOf: asOf,
      fetchedAt: DateTime.now(),
      source: source,
    );
  }

  String _isoDate(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

/// A validated provider response: four USD-based rates plus provenance.
class RateSnapshot {
  RateSnapshot._({
    required this.usdRates,
    required this.asOf,
    required this.fetchedAt,
    required this.source,
  });

  /// `null` when the table fails the four-currency invariants — a bad payload
  /// is refused at the edge, never repaired into something plausible.
  static RateSnapshot? tryCreate({
    required Map<CurrencyCode, double> usdRates,
    required DateTime asOf,
    required DateTime fetchedAt,
    required RateSource source,
  }) {
    final table = RateTable.tryCreate(
      usdRates: usdRates,
      asOf: asOf,
      fetchedAt: fetchedAt,
      source: source,
    );
    if (table == null) return null;
    return RateSnapshot._(
      usdRates: Map.unmodifiable(usdRates),
      asOf: asOf,
      fetchedAt: fetchedAt,
      source: source,
    );
  }

  final Map<CurrencyCode, double> usdRates;
  final DateTime asOf;
  final DateTime fetchedAt;
  final RateSource source;
}
