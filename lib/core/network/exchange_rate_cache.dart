import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'exchange_rate_client.dart';

final exchangeRateCacheProvider = Provider<ExchangeRateCache>((ref) {
  return ExchangeRateCache(ref.watch(exchangeRateClientProvider));
});

class ExchangeRateCache {
  final ExchangeRateClient _client;

  ExchangeRateCache(this._client);

  static const _cacheFileName = 'exchange_rates_cache.json';

  Future<File> get _cacheFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_cacheFileName');
  }

  Future<double> getRate(String baseCurrency, String targetCurrency) async {
    if (baseCurrency == targetCurrency) return 1.0;

    final file = await _cacheFile;
    if (await file.exists()) {
      try {
        final cachedData = await file.readAsString();
        final decoded = jsonDecode(cachedData);
        if (decoded[baseCurrency] != null) {
          final entry = decoded[baseCurrency] as Map<String, dynamic>;
          final timestamp = entry['timestamp'] as int;
          final now = DateTime.now().millisecondsSinceEpoch;

          if (now - timestamp < 24 * 60 * 60 * 1000) {
            final rates = entry['rates'] as Map<String, dynamic>;
            if (rates.containsKey(targetCurrency)) {
              return (rates[targetCurrency] as num).toDouble();
            }
          }
        }
      } catch (e) {
        // ignore
      }
    }

    // Fetch new
    final rates = await _client.fetchLatestRates(baseCurrency);
    if (rates.isNotEmpty) {
      try {
        Map<String, dynamic> fullCache = {};
        if (await file.exists()) {
          fullCache =
              jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        }
        fullCache[baseCurrency] = {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'rates': rates,
        };
        await file.writeAsString(jsonEncode(fullCache));

        if (rates.containsKey(targetCurrency)) {
          return rates[targetCurrency]!;
        }
      } catch (e) {
        // ignore
      }
    }

    return 1.0;
  }
}
