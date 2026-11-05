import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/features/finance/presentation/audit_values.dart';

void main() {
  test('claim correction audit keeps each amount in its own currency', () {
    final text = formatAuditValues(
        jsonEncode({
          'beforeMinor': 10000,
          'afterMinor': 2000,
          'currency': 'huf',
          'beforeJson': jsonEncode({'currency': 'huf'}),
          'afterJson': jsonEncode({'currency': 'eur'}),
          'reason': 'Correct invoice currency',
        }),
        objectType: 'MedicalClaimActivity');
    expect(text, contains('HUF 10,000'));
    expect(text, contains('EUR 20.00'));
    expect(text, contains('Correct invoice currency'));
    expect(text, isNot(contains('beforeJson')));
  });
}
