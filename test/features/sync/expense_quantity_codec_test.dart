import 'package:budget_buddy/features/sync/domain/codecs/expense_codec.dart';
import 'package:flutter_test/flutter_test.dart';

import '../expenses/support/quantity_fixtures.dart';

void main() {
  const codec = ExpenseCodec();

  test('quantity round-trips through the canonical payload', () {
    final expense = quantityExpense(amount: 1500, quantity: 3);
    final payload = codec.toPayload(expense);
    final decoded = codec.fromPayload(payload);

    expect(decoded.amount, 1500);
    expect(decoded.quantity, 3);
    expect(codec.toPayload(decoded), payload);
    expect(codec.toJson(expense)['quantity'], 3);
  });

  test('a payload without quantity applies as 1', () {
    final json = codec.toJson(quantityExpense(quantity: 3))..remove('quantity');

    expect(codec.fromJson(json).quantity, 1);
  });

  test('non-positive quantities normalize to 1', () {
    expect(
        codec.fromJson(codec.toJson(quantityExpense(quantity: 0))).quantity, 1);
    expect(codec.fromJson(codec.toJson(quantityExpense(quantity: -4))).quantity,
        1);
  });
}
