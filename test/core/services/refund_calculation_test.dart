import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/services/refund_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('refund clears deficit then borrowing without reducing spending twice',
      () {
    final impact = RefundImpact.calculate(
      spent: 130000,
      allocation: 100000,
      reserve: 10000,
      refund: 25000,
    );
    expect(impact.spentAfter, 105000);
    expect(impact.deficitBefore, 20000);
    expect(impact.deficitAfter, 0);
    expect(impact.borrowedBefore, 10000);
    expect(impact.borrowedAfter, 5000);
    expect(impact.deficitReduction, 20000);
    expect(impact.borrowingReduction, 5000);
    expect(impact.spendingReduction, 0);
  });
  test('larger refund also restores money within the allocation', () {
    final impact = RefundImpact.calculate(
      spent: 130000,
      allocation: 100000,
      reserve: 10000,
      refund: 40000,
    );
    expect(impact.spentAfter, 90000);
    expect(
        impact.deficitReduction +
            impact.borrowingReduction +
            impact.spendingReduction,
        40000);
    expect(impact.spendingReduction, 10000);
  });
  test('direct spending restores reserve without creating borrowing', () {
    final impact = RefundImpact.calculate(
      spent: 150,
      allocation: 0,
      reserve: 100,
      refund: 75,
      direct: true,
    );
    expect(impact.borrowedBefore, 0);
    expect(impact.borrowedAfter, 0);
    expect(impact.deficitReduction, 50);
    expect(impact.spendingReduction, 25);
  });
  test('exhausted reserve never produces negative borrowing', () {
    final impact = RefundImpact.calculate(
      spent: 130,
      allocation: 100,
      reserve: -10,
      refund: 20,
    );
    expect(impact.borrowedBefore, 0);
    expect(impact.deficitAfter, 10);
  });
  test('negative, zero and excessive refunds are rejected', () {
    for (final amount in [-1, 0, 101]) {
      expect(
          () => RefundImpact.calculate(
              spent: 100, allocation: 50, reserve: 20, refund: amount),
          throwsA(isA<RefundException>()));
    }
  });
  test('input parses exact minor units and rejects excess precision', () {
    for (final currency in [
      CurrencyCode.usd,
      CurrencyCode.eur,
      CurrencyCode.cad
    ]) {
      expect(parseRefundAmount('1,234.56', currency), 123456);
      expect(parseRefundAmount('0.01', currency), 1);
      expect(parseRefundAmount('1.001', currency), isNull);
    }
    expect(parseRefundAmount('5,500', CurrencyCode.huf), 5500);
    for (final value in ['1.1', '-1', '0', 'NaN', '1e3', '1,2', '']) {
      expect(parseRefundAmount(value, CurrencyCode.huf), isNull);
    }
  });
}
