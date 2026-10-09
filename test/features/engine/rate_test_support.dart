import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/live_rate_set.dart';
import 'package:budget_buddy/core/models/month_rate_seal.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/network/exchange_rate_client.dart';
import 'package:budget_buddy/core/network/rate_types.dart';
import 'package:dio/dio.dart';
import 'package:isar/isar.dart';

/// Builds a validated four-currency snapshot for tests (base USD).
RateSnapshot snapshot({
  Map<CurrencyCode, double>? usdRates,
  DateTime? asOf,
  DateTime? fetchedAt,
  RateSource source = RateSource.historical,
}) =>
    RateSnapshot.tryCreate(
      usdRates: usdRates ??
          const {
            CurrencyCode.usd: 1.0,
            CurrencyCode.eur: 0.86,
            CurrencyCode.huf: 345.0,
            CurrencyCode.cad: 1.36,
          },
      asOf: asOf ?? DateTime(2026, 1, 31),
      fetchedAt: fetchedAt ?? DateTime(2026, 2, 1),
      source: source,
    )!;

/// A `MonthRateSeal` row with sensible defaults, for seeding seal state.
MonthRateSeal rateSeal({
  required String yearMonth,
  required SealStatus status,
  DateTime? closedAt,
  RateSource source = RateSource.lastKnown,
  int attemptCount = 1,
  Map<CurrencyCode, double>? rates,
  DateTime? updatedAt,
}) =>
    MonthRateSeal()
      ..yearMonth = yearMonth
      ..status = status
      ..applyUsdRates(rates ??
          const {
            CurrencyCode.usd: 1.0,
            CurrencyCode.eur: 0.86,
            CurrencyCode.huf: 345.0,
            CurrencyCode.cad: 1.36,
          })
      ..asOf = DateTime(2026, 2, 28)
      ..fetchedAt = DateTime(2026, 3, 1)
      ..source = source
      ..closedAt = closedAt
      ..attemptCount = attemptCount
      ..updatedAt = updatedAt ?? DateTime(2026, 3, 1);

/// An `ExchangeRateClient` whose network is replaced by scripted responses.
class FakeRateClient extends ExchangeRateClient {
  FakeRateClient({
    this.latest,
    this.historical = const {},
    this.failLatest = false,
    this.failHistorical = false,
  });

  RateSnapshot? latest;

  /// Historical result keyed by `yyyy-MM-dd`; a missing key is a 404/offline.
  Map<String, RateSnapshot> historical;
  bool failLatest;
  bool failHistorical;

  int latestCalls = 0;
  final List<DateTime> historicalCalls = [];

  @override
  Future<RateSnapshot?> fetchLatest() async {
    latestCalls++;
    return failLatest ? null : latest;
  }

  @override
  Future<RateSnapshot?> fetchHistorical(DateTime date) async {
    historicalCalls.add(date);
    if (failHistorical) return null;
    return historical[_key(date)];
  }

  static String _key(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

/// A Dio adapter that returns 404 for the [businessDays] it is not given and a
/// valid Frankfurter payload otherwise — enough to exercise the client's
/// weekend/holiday walk-back without real network.
class ScriptedRateAdapter implements HttpClientAdapter {
  ScriptedRateAdapter(this.payloadForUrl);

  /// Returns the JSON body for a URL, or `null` to answer 404.
  final Map<String, dynamic>? Function(String url) payloadForUrl;

  final List<String> requestedUrls = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestedUrls.add(options.uri.toString());
    final payload = payloadForUrl(options.uri.toString());
    if (payload == null) {
      return ResponseBody.fromString('', 404);
    }
    return ResponseBody.fromString(
      jsonEncode(payload),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Frankfurter-shaped body for a business day, containing all four currencies.
Map<String, dynamic> frankfurterBody(String date) => {
      'amount': 1.0,
      'base': 'USD',
      'date': date,
      'rates': {
        'HUF': 345.0,
        'CAD': 1.36,
        'EUR': 0.86,
      },
    };

/// Real-Isar harness for the seal coordinator. Opens only the collections the
/// coordinator touches.
class RateTestHarness {
  RateTestHarness._(this.isar, this.directory);

  static bool _coreReady = false;
  static int _next = 0;

  final Isar isar;
  final Directory directory;

  static Future<RateTestHarness> create() async {
    if (!_coreReady) {
      await Isar.initializeIsarCore(download: true);
      _coreReady = true;
    }
    final directory =
        Directory.systemTemp.createTempSync('budget_buddy_rates_');
    final isar = await Isar.open(
      [
        MonthlyBudgetSchema,
        MonthRateSealSchema,
        LiveRateSetSchema,
      ],
      directory: directory.path,
      name: 'rates_${_next++}',
    );
    return RateTestHarness._(isar, directory);
  }

  Future<MonthlyBudget> seedBudget(String yearMonth) async {
    final budget = MonthlyBudget()
      ..yearMonth = yearMonth
      ..baseAvailableAmount = 1000
      ..currency = 'huf'
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    await isar.writeTxn(() async {
      budget.id = await isar.monthlyBudgets.put(budget);
    });
    return budget;
  }

  Future<MonthRateSeal> putSeal(MonthRateSeal seal) async {
    await isar.writeTxn(() async {
      seal.id = await isar.monthRateSeals.put(seal);
    });
    return seal;
  }

  Future<MonthRateSeal?> sealFor(String yearMonth) =>
      isar.monthRateSeals.filter().yearMonthEqualTo(yearMonth).findFirst();

  Future<LiveRateSet?> live() => isar.liveRateSets.where().findFirst();

  Future<void> close() async {
    await isar.close(deleteFromDisk: true);
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  }
}
