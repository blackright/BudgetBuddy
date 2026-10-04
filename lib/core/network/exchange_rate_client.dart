import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final exchangeRateClientProvider = Provider<ExchangeRateClient>((ref) {
  return ExchangeRateClient(Dio());
});

class ExchangeRateClient {
  final Dio _dio;

  ExchangeRateClient(this._dio);

  Future<Map<String, double>> fetchLatestRates(String baseCurrency) async {
    try {
      // Using a free, open API for exchange rates as an example.
      // Usually, this should be configured via environment variables.
      final response = await _dio
          .get('https://api.exchangerate-api.com/v4/latest/$baseCurrency');
      if (response.statusCode == 200) {
        final rates = response.data['rates'] as Map<String, dynamic>;
        return rates
            .map((key, value) => MapEntry(key, (value as num).toDouble()));
      }
      return {};
    } catch (e) {
      return {};
    }
  }
}
