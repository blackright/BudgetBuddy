import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/live_rate_set.dart';
import '../../../core/models/money.dart';
import '../../../core/models/month_rate_seal.dart';
import '../../../core/network/baseline_rates.dart';
import '../../../core/network/rate_types.dart';
import '../currency_conversion.dart' as conversion;

/// In-memory rate lookup: `yearMonth → RateTable` plus the current live table
/// (research R4). Every read is synchronous — no I/O runs inside an engine
/// reduce; the provider layer keeps this snapshot fresh as Isar changes.
class RateTableRegistry {
  RateTableRegistry({
    Map<String, RateTable> sealedTables = const {},
    RateTable? liveTable,
  })  : _sealedTables = Map.unmodifiable(sealedTables),
        _liveTable = liveTable;

  final Map<String, RateTable> _sealedTables;
  final RateTable? _liveTable;

  /// A conservative bundled table so a brand-new offline install still has a
  /// table; it is always labelled [RateSource.bundled] (research R11).
  static final RateTable _bundled = RateTable(
    usdRates: Map.unmodifiable(kBundledUsdRates),
    asOf: DateTime.utc(2000),
    fetchedAt: DateTime.utc(2000),
    source: RateSource.bundled,
  );

  /// Sealed/provisional month tables, keyed by `yyyy-MM`.
  Map<String, RateTable> get sealedTables => _sealedTables;

  /// The current live table, if a fetch (or its last-known fallback) exists.
  RateTable? get liveTable => _liveTable;

  /// The table that governs [yearMonth]: its own seal when one exists,
  /// otherwise the live table, otherwise the bundled baseline. Returns `null`
  /// only if even the bundled table were somehow invalid.
  RateTable? tableFor(String yearMonth) =>
      _sealedTables[yearMonth] ?? _liveTable ?? _bundled;

  /// Whether [yearMonth] already has a persisted seal (final or provisional).
  bool isSealedMonth(String yearMonth) => _sealedTables.containsKey(yearMonth);

  /// Converts [amount] into [to] using [yearMonth]'s table.
  ///
  /// The registry only selects which table governs [yearMonth] (its seal,
  /// otherwise live, otherwise bundled); the arithmetic lives in the pure
  /// [convert] function. A missing table yields a degraded result — never a
  /// fabricated `1.0` (FR-014).
  ConversionResult convert({
    required Money amount,
    required CurrencyCode to,
    String? yearMonth,
  }) {
    final table =
        yearMonth == null ? (_liveTable ?? _bundled) : tableFor(yearMonth);
    return conversion.convert(amount, to, table);
  }
}

/// Every persisted seal, hydrated live from Isar so writes (new seals, status
/// upgrades) flow straight into the registry.
final sealedRateTablesProvider = StreamProvider<Map<String, RateTable>>((ref) {
  final isar = IsarHelper.instance;
  return isar.monthRateSeals.where().watch(fireImmediately: true).map((rows) {
    final tables = <String, RateTable>{};
    for (final row in rows) {
      final table = row.toRateTable();
      if (table != null) tables[row.yearMonth] = table;
    }
    return tables;
  });
});

/// The device-singleton live table, hydrated live from Isar.
final liveRateTableProvider = StreamProvider<RateTable?>((ref) {
  final isar = IsarHelper.instance;
  return isar.liveRateSets.where().watch(fireImmediately: true).map((rows) {
    final row = rows.isEmpty ? null : rows.first;
    return row?.toRateTable();
  });
});

/// The registry engine code watches and folds over synchronously.
final rateRegistryProvider = Provider<RateTableRegistry>((ref) {
  final sealed = ref.watch(sealedRateTablesProvider).value ?? const {};
  final live = ref.watch(liveRateTableProvider).value;
  return RateTableRegistry(sealedTables: sealed, liveTable: live);
});
