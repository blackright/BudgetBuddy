import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/services/medical_receipt_booking_service.dart';

void main() {
  const service = MedicalReceiptBookingService();
  test(
      'partial booked reversals add exactly to original base with final rounding',
      () {
    var original = 0, base = 0;
    final parts = <int>[];
    for (var i = 0; i < 3; i++) {
      final value = service.book(
          paidMinor: 3,
          paidBaseMinor: 10,
          priorPrincipalMinor: original,
          priorPrincipalBaseMinor: base,
          amountMinor: 1,
          original: CurrencyCode.eur,
          accounting: CurrencyCode.huf);
      original += value.principalMinor;
      base += value.principalBaseMinor;
      parts.add(value.principalBaseMinor);
    }
    expect(parts, [3, 4, 3]);
    expect(base, 10);
  });
  test('same-currency actual excess remains separate from booked principal',
      () {
    final value = service.book(
        paidMinor: 30000,
        paidBaseMinor: 30000,
        priorPrincipalMinor: 0,
        priorPrincipalBaseMinor: 0,
        amountMinor: 35000,
        original: CurrencyCode.huf,
        accounting: CurrencyCode.huf);
    expect(value.principalMinor, 30000);
    expect(value.excessMinor, 5000);
    expect(value.baseMinor, 35000);
  });
  test(
      'foreign excess blocks the whole proposal without principal-only success',
      () {
    expect(
        () => service.book(
            paidMinor: 2000,
            paidBaseMinor: 8000,
            priorPrincipalMinor: 0,
            priorPrincipalBaseMinor: 0,
            amountMinor: 2100,
            original: CurrencyCode.eur,
            accounting: CurrencyCode.huf),
        throwsA(isA<MedicalReceiptException>()
            .having((e) => e.code, 'code', 'foreignExcessNeedsReview')));
  });
  test('invalid prior booking and integer extremes fail before conversion', () {
    expect(
        () => service.book(
            paidMinor: 10,
            paidBaseMinor: 10,
            priorPrincipalMinor: 11,
            priorPrincipalBaseMinor: 0,
            amountMinor: 1,
            original: CurrencyCode.huf,
            accounting: CurrencyCode.huf),
        throwsFormatException);
    expect(
        () => service.book(
            paidMinor: 10,
            paidBaseMinor: 10,
            priorPrincipalMinor: 0,
            priorPrincipalBaseMinor: 0,
            amountMinor: 9223372036854775807,
            original: CurrencyCode.huf,
            accounting: CurrencyCode.huf),
        throwsFormatException);
  });
}
