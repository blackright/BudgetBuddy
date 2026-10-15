import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/isar_helper.dart';
import '../database/money_integrity.dart';

/// Scans the open database for money fields the step-9 type cut made unreadable.
///
/// The gate at `main.dart` watches this before showing the app: an empty list
/// means the database is safe to use, a non-empty one routes to the reset screen
/// instead of rendering garbage or crashing on a `clamp`.
///
/// Invalidate it after a successful reset to re-run the scan.
final moneyIntegrityIssuesProvider = FutureProvider<List<MoneyIntegrityIssue>>(
  (ref) => findCorruptedMoney(IsarHelper.instance),
);
