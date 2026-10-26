import 'package:intl/intl.dart';
import 'dart:async';
import 'package:intl/date_symbol_data_local.dart';

final _formatter = _createFormatter();
DateFormat _createFormatter() {
  // The installed local-data implementation registers symbols synchronously
  // and returns an already-completed future; no network or file I/O occurs.
  unawaited(initializeDateFormatting('en'));
  return DateFormat('d MMM yyyy, HH:mm', 'en');
}

/// Presentation only; retain full original timestamps in the stored evidence.
String formatVaultTime(DateTime value) => _formatter.format(value.toLocal());
