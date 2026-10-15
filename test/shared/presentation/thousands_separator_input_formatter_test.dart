import 'package:budget_buddy/shared/presentation/input_formatters/thousands_separator_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the grouping contract every amount field inherits (FR-001/FR-002):
/// separators are visual only, extra/soft characters are dropped, and the caret
/// keeps its logical spot so editing mid-number does not jump to the end.
void main() {
  const formatter = ThousandsSeparatorInputFormatter();

  TextEditingValue at(String text, {int? caret}) => TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: caret ?? text.length),
      );

  String formatted(String text) =>
      formatter.formatEditUpdate(const TextEditingValue(), at(text)).text;

  group('groups the integer part in threes', () {
    test('short numbers are unchanged', () {
      expect(formatted('1'), '1');
      expect(formatted('12'), '12');
      expect(formatted('123'), '123');
    });

    test('four digits and up gain commas', () {
      expect(formatted('1234'), '1,234');
      expect(formatted('12345'), '12,345');
      expect(formatted('123456'), '123,456');
      expect(formatted('1234567'), '1,234,567');
      expect(formatted('1000000'), '1,000,000');
    });
  });

  group('normalizes stray input', () {
    test('an empty field stays empty', () {
      expect(formatted(''), '');
      expect(formatted(',,'), '');
    });

    test('leading zeros collapse but a lone zero is kept', () {
      expect(formatted('007'), '7');
      expect(formatted('000'), '0');
      expect(formatted('0'), '0');
    });

    test('a single decimal separator is allowed', () {
      expect(formatted('1234.5'), '1,234.5');
      expect(formatted('1234.56'), '1,234.56');
      expect(formatted('0.5'), '0.5');
    });

    test('a second decimal separator is dropped', () {
      expect(formatted('1.2.3'), '1.23');
    });

    test('non-numeric characters are dropped', () {
      expect(formatted('12a3'), '123');
      expect(formatted(r'$1,000'), '1,000');
    });

    test('a leading minus is kept, a dangling one is dropped', () {
      expect(formatted('-1234'), '-1,234');
      expect(formatted('1234-'), '1,234');
      expect(formatted('-0'), '0');
    });
  });

  group('preserves the caret logical position', () {
    test('typing at the end leaves the caret at the end', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        at('1000000'),
      );
      expect(result.text, '1,000,000');
      expect(result.selection.baseOffset, 9);
    });

    test('a caret after the first digit stays after the first digit', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        at('1000000', caret: 1),
      );
      expect(result.text, '1,000,000');
      expect(result.selection.baseOffset, 1);
    });

    test('a caret mid-number maps across the inserted separators', () {
      // "1000|000": four meaningful chars are to the left of the caret.
      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        at('1000000', caret: 4),
      );
      expect(result.text, '1,000,000');
      expect(result.selection.baseOffset, 5); // after "1,000"
    });
  });

  group('typing one character at a time builds the grouped number', () {
    test('1000000 typed digit by digit reads 1,000,000', () {
      var value = const TextEditingValue();
      for (final char in '1000000'.split('')) {
        final next = TextEditingValue(
          text: value.text + char,
          selection: TextSelection.collapsed(offset: value.text.length + 1),
        );
        value = formatter.formatEditUpdate(value, next);
      }
      expect(value.text, '1,000,000');
      expect(value.selection.baseOffset, 9);
    });
  });
}
