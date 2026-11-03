import 'dart:convert';
import 'package:timezone/data/latest.dart' as zones;
import 'package:timezone/timezone.dart' as tz;
import '../models/currency_code.dart';
import '../models/fx_revision.dart';
import '../models/money.dart';
import '../../features/expenses/models/reimbursement.dart';

class MedicalReceiptException extends FormatException {
  const MedicalReceiptException(this.code) : super(code);
  final String code;
  @override
  String toString() => 'MedicalReceiptException: $code';
}

class MedicalReceiptValuation {
  const MedicalReceiptValuation(this.principalMinor, this.principalBaseMinor,
      this.excessMinor, this.excessBaseMinor);
  final int principalMinor, principalBaseMinor, excessMinor, excessBaseMinor;
  int get baseMinor => checkedFxMinor(principalBaseMinor + excessBaseMinor);
}

/// Reverses only the original booked principal, with exact cumulative rounding.
/// Legitimate same-accounting-currency excess is separately classified.
class MedicalReceiptBookingService {
  const MedicalReceiptBookingService();
  MedicalReceiptValuation book(
      {required int paidMinor,
      required int paidBaseMinor,
      required int priorPrincipalMinor,
      required int priorPrincipalBaseMinor,
      required int amountMinor,
      required CurrencyCode original,
      required CurrencyCode accounting}) {
    for (final value in [
      paidMinor,
      paidBaseMinor,
      priorPrincipalMinor,
      priorPrincipalBaseMinor,
      amountMinor
    ]) {
      checkedFxMinor(value);
      if (value < 0) throw const MedicalReceiptException('invalidMoney');
    }
    if (paidMinor <= 0 ||
        amountMinor <= 0 ||
        priorPrincipalMinor > paidMinor ||
        priorPrincipalBaseMinor > paidBaseMinor) {
      throw const MedicalReceiptException('invalidBooking');
    }
    final remaining = paidMinor - priorPrincipalMinor;
    final principal = amountMinor < remaining ? amountMinor : remaining;
    final excess = amountMinor - principal;
    if (excess > 0 && original != accounting) {
      throw const MedicalReceiptException('foreignExcessNeedsReview');
    }
    final cumulative = fxRound(
        BigInt.from(paidBaseMinor) *
            BigInt.from(priorPrincipalMinor + principal),
        BigInt.from(paidMinor));
    final base = cumulative - priorPrincipalBaseMinor;
    if (base < 0) throw const MedicalReceiptException('invalidBooking');
    return MedicalReceiptValuation(principal, base, excess, excess);
  }
}

/// Portable version2 attribution/valuation evidence. Original FX envelopes are
/// never repurposed to encode the date or destination of a later cash receipt.
class MedicalReceiptEvidence {
  MedicalReceiptEvidence(Map<String, Object?> json)
      : json = Map.unmodifiable(json) {
    validate();
  }
  final Map<String, Object?> json;
  String text(String key) => json[key] as String;
  int number(String key) => json[key] as int;
  DateTime get receivedAt => DateTime.parse(text('receivedAt')).toUtc();
  String get fundingMonth => text('fundingMonth');
  CurrencyCode get accounting =>
      CurrencyCode.tryParse(text('accountingCurrency'))!;
  Money get money => Money(number('baseMinor'), accounting);
  String encode() => jsonEncode(json);
  static MedicalReceiptEvidence? of(Reimbursement row) {
    if (row.medicalReceiptJson == null) return null;
    final raw = row.medicalReceiptJson!;
    if (raw.length > 32768) {
      throw const MedicalReceiptException('invalidReceiptEvidence');
    }
    try {
      final evidence = MedicalReceiptEvidence(
          Map<String, Object?>.from(jsonDecode(raw) as Map));
      if (evidence.text('receiptGuid') != row.syncGuid ||
          evidence.number('amountMinor') != row.amount ||
          evidence.text('currency') != row.currency.toUpperCase() ||
          evidence.fundingMonth != row.originYearMonth ||
          !evidence.receivedAt.isAtSameMomentAs(row.date) ||
          row.orphaned) {
        throw const MedicalReceiptException('invalidReceiptEvidence');
      }
      return evidence;
    } on MedicalReceiptException {
      rethrow;
    } catch (_) {
      throw const MedicalReceiptException('invalidReceiptEvidence');
    }
  }

  void validate() {
    try {
      if (json['version'] != 2) throw const FormatException();
      const allowed = {
        'version',
        'receiptGuid',
        'revisionGuid',
        'revision',
        'sequence',
        'billGuid',
        'expenseGuid',
        'approvalGuid',
        'approvalMinor',
        'receivedAt',
        'receivedLocalDate',
        'localZone',
        'fundingMonth',
        'costMonth',
        'groupGuid',
        'currency',
        'accountingCurrency',
        'amountMinor',
        'paidMinor',
        'paidBaseMinor',
        'priorPrincipalMinor',
        'priorPrincipalBaseMinor',
        'principalMinor',
        'principalBaseMinor',
        'excessMinor',
        'excessBaseMinor',
        'baseMinor',
        'originalFxHash',
        'alreadyIncluded',
        'checkpointGuid',
        'previousRevisionGuid',
        'correctionReason'
      };
      if (json.keys.any((key) => !allowed.contains(key)) ||
          json['alreadyIncluded'] is! bool ||
          text('checkpointGuid').isEmpty) {
        throw const FormatException();
      }
      for (final key in [
        'receiptGuid',
        'revisionGuid',
        'billGuid',
        'expenseGuid',
        'approvalGuid',
        'originalFxHash',
        'localZone'
      ]) {
        if (text(key).trim().isEmpty || text(key).length > 256) {
          throw const FormatException();
        }
      }
      final original = CurrencyCode.tryParse(text('currency')),
          account = CurrencyCode.tryParse(text('accountingCurrency'));
      if (original == null ||
          account == null ||
          text('currency') != original.code.toUpperCase() ||
          text('accountingCurrency') != account.code.toUpperCase() ||
          !RegExp(r'^[1-9][0-9]{3}-(0[1-9]|1[0-2])$').hasMatch(fundingMonth) ||
          !RegExp(r'^[1-9][0-9]{3}-(0[1-9]|1[0-2])$')
              .hasMatch(text('costMonth')) ||
          DateTime.tryParse(text('receivedAt')) == null ||
          DateTime.tryParse(text('receivedLocalDate')) == null) {
        throw const FormatException();
      }
      for (final key in [
        'amountMinor',
        'paidMinor',
        'paidBaseMinor',
        'priorPrincipalMinor',
        'priorPrincipalBaseMinor',
        'principalMinor',
        'principalBaseMinor',
        'excessMinor',
        'excessBaseMinor',
        'baseMinor',
        'approvalMinor',
        'revision',
        'sequence'
      ]) {
        checkedFxMinor(number(key));
        if (number(key) < 0) throw const FormatException();
      }
      if (number('revision') < 1 ||
          number('sequence') < 1 ||
          number('amountMinor') <= 0 ||
          number('approvalMinor') < number('amountMinor')) {
        throw const FormatException();
      }
      if (number('revision') > 1 &&
          (json['previousRevisionGuid'] is! String ||
              (json['previousRevisionGuid'] as String).isEmpty ||
              json['correctionReason'] is! String ||
              (json['correctionReason'] as String).trim().isEmpty)) {
        throw const FormatException();
      }
      final expected = const MedicalReceiptBookingService().book(
          paidMinor: number('paidMinor'),
          paidBaseMinor: number('paidBaseMinor'),
          priorPrincipalMinor: number('priorPrincipalMinor'),
          priorPrincipalBaseMinor: number('priorPrincipalBaseMinor'),
          amountMinor: number('amountMinor'),
          original: original,
          accounting: account);
      if (number('principalMinor') != expected.principalMinor ||
          number('principalBaseMinor') != expected.principalBaseMinor ||
          number('excessMinor') != expected.excessMinor ||
          number('excessBaseMinor') != expected.excessBaseMinor ||
          number('baseMinor') != expected.baseMinor) {
        throw const FormatException();
      }
      if (json['groupGuid'] == null &&
          fundingMonth != text('receivedLocalDate').substring(0, 7)) {
        throw const FormatException();
      }
      if (!tz.timeZoneDatabase.isInitialized) zones.initializeTimeZones();
      final zone = text('localZone');
      final local = tz.TZDateTime.from(receivedAt,
          zone == 'UTC' || zone == 'Etc/UTC' ? tz.UTC : tz.getLocation(zone));
      final date =
          '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
      if (date != text('receivedLocalDate')) throw const FormatException();
      if (json['groupGuid'] != null &&
          (json['groupGuid'] is! String ||
              (json['groupGuid'] as String).isEmpty)) {
        throw const FormatException();
      }
    } on MedicalReceiptException {
      rethrow;
    } catch (_) {
      throw const MedicalReceiptException('invalidReceiptEvidence');
    }
  }
}

/// Version2 Medical returns release actual funding to the common reserve;
/// they do not erase the original month's recorded profile cost.
int medicalRecoveryForMonth(Iterable<Reimbursement> rows, String month,
    {required int Function(Reimbursement) convert}) {
  var total = 0;
  final seen = <String>{};
  for (final row in rows) {
    if (row.medicalReceiptJson == null || row.originYearMonth != month) {
      continue;
    }
    MedicalReceiptEvidence.of(row);
    if (!seen.add(row.syncGuid)) {
      throw const MedicalReceiptException('duplicateReceipt');
    }
    total = checkedFxMinor(total + convert(row));
  }
  return total;
}
