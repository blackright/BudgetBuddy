import 'dart:convert';
import 'package:isar/isar.dart';
import '../../core/models/currency_code.dart';
import 'models/vault_entry.dart';
import 'vault_math.dart';

const vaultTransferKinds = {'deposit', 'withdrawal', 'reversal'};

/// Both legs are represented by one immutable record: +vault / -monthly funds.
/// No opening balance, income, expense or allocation is rewritten.
Map<String, dynamic>? transferDetails(VaultEntry entry) {
  try {
    if (!vaultTransferKinds.contains(entry.kind) ||
        !validVaultSignedAmount(entry.amountMinor) ||
        entry.amountMinor == 0 ||
        !validVaultAmount(entry.balanceAfterMinor) ||
        CurrencyCode.tryParse(entry.currency) == null ||
        !RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(entry.yearMonth ?? '')) {
      return null;
    }
    final data = jsonDecode(entry.breakdownJson);
    if (data is! Map<String, dynamic> ||
        !{1, 2}.contains(data['version']) ||
        data['vaultDelta'] != entry.amountMinor ||
        data['monthDelta'] != -entry.amountMinor ||
        data['month'] != entry.yearMonth ||
        data['currency'] != entry.currency ||
        data['vaultBefore'] is! int ||
        !validVaultAmount(data['vaultBefore'] as int) ||
        BigInt.from(data['vaultBefore'] as int) +
                BigInt.from(entry.amountMinor) !=
            BigInt.from(entry.balanceAfterMinor) ||
        data['bankBefore'] is! int ||
        data['bankAfter'] is! int ||
        !validVaultSignedAmount(data['bankBefore'] as int) ||
        !validVaultSignedAmount(data['bankAfter'] as int) ||
        BigInt.from(data['bankBefore'] as int) -
                BigInt.from(entry.amountMinor) !=
            BigInt.from(data['bankAfter'] as int) ||
        data['reserveBefore'] is! int ||
        data['reserveAfter'] is! int ||
        !validVaultSignedAmount(data['reserveBefore'] as int) ||
        !validVaultSignedAmount(data['reserveAfter'] as int) ||
        BigInt.from(data['reserveBefore'] as int) -
                BigInt.from(entry.amountMinor) !=
            BigInt.from(data['reserveAfter'] as int) ||
        data['note'] is! String ||
        (data['note'] as String).length > 120 ||
        (entry.kind == 'deposit' && entry.amountMinor < 0) ||
        (entry.kind == 'withdrawal' && entry.amountMinor > 0) ||
        (entry.kind == 'reversal' &&
            (data['reverses'] is! String ||
                (data['note'] as String).trim().isEmpty)) ||
        (entry.kind != 'reversal' && data['reverses'] != null)) {
      return null;
    }
    if (data['version'] == 2 &&
        (data['freeBefore'] is! int ||
            data['freeAfter'] is! int ||
            !validVaultSignedAmount(data['freeBefore'] as int) ||
            !validVaultSignedAmount(data['freeAfter'] as int) ||
            BigInt.from(data['freeBefore'] as int) -
                    BigInt.from(entry.amountMinor) !=
                BigInt.from(data['freeAfter'] as int))) {
      return null;
    }
    return data;
  } on FormatException {
    return null;
  }
}

int monthlyVaultCredit(
    Iterable<VaultEntry> entries, String month, CurrencyCode currency) {
  var total = 0;
  for (final entry in entries) {
    if (entry.yearMonth != month || !vaultTransferKinds.contains(entry.kind)) {
      continue;
    }
    if (transferDetails(entry) == null || entry.currency != currency.code) {
      throw const FormatException('Vault transfers need review.');
    }
    total = vaultSum(total, -entry.amountMinor);
  }
  return total;
}

/// Caller may already hold the source ledger's read/write transaction.
Future<int> readMonthlyVaultCredit(
        Isar db, int profileId, String month, CurrencyCode currency) async =>
    monthlyVaultCredit(
        await db.vaultEntrys.filter().profileIdEqualTo(profileId).findAll(),
        month,
        currency);
