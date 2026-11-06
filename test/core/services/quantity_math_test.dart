import 'package:budget_buddy/core/services/quantity_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isValidQuantity', () {
    test('accepts the supported whole-number range', () {
      expect(isValidQuantity(1), isTrue);
      expect(isValidQuantity(999), isTrue);
      expect(isValidQuantity(0), isFalse);
      expect(isValidQuantity(-1), isFalse);
      expect(isValidQuantity(1000), isFalse);
    });
  });

  group('quantityLineTotalMinor', () {
    test('multiplies a unit price by the quantity', () {
      expect(quantityLineTotalMinor(unitMinor: 500, quantity: 2), 1000);
      expect(quantityLineTotalMinor(unitMinor: 1234, quantity: 1), 1234);
    });

    test('rejects invalid units and quantities', () {
      expect(quantityLineTotalMinor(unitMinor: 0, quantity: 2), isNull);
      expect(quantityLineTotalMinor(unitMinor: -1, quantity: 2), isNull);
      expect(quantityLineTotalMinor(unitMinor: 500, quantity: 0), isNull);
      expect(quantityLineTotalMinor(unitMinor: 500, quantity: 1000), isNull);
    });

    test('rejects a product above the supported monetary ceiling', () {
      expect(
        quantityLineTotalMinor(unitMinor: maximumMinorAmount, quantity: 1),
        maximumMinorAmount,
      );
      expect(
        quantityLineTotalMinor(unitMinor: maximumMinorAmount, quantity: 2),
        isNull,
      );
    });
  });

  group('quantityUnitMinor', () {
    test('divides an evenly divisible total exactly', () {
      expect(quantityUnitMinor(totalMinor: 1000, quantity: 2), 500);
      expect(quantityUnitMinor(totalMinor: 999, quantity: 1), 999);
    });

    test('returns null instead of rounding a non-divisible total', () {
      expect(quantityUnitMinor(totalMinor: 1001, quantity: 2), isNull);
      expect(quantityUnitMinor(totalMinor: 1000, quantity: 3), isNull);
    });

    test('rejects invalid totals and quantities', () {
      expect(quantityUnitMinor(totalMinor: 0, quantity: 2), isNull);
      expect(quantityUnitMinor(totalMinor: -1, quantity: 2), isNull);
      expect(quantityUnitMinor(totalMinor: 1000, quantity: 0), isNull);
      expect(quantityUnitMinor(totalMinor: 1000, quantity: 1000), isNull);
    });
  });
}
