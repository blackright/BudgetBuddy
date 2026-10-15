import 'package:flutter/services.dart';

/// Formats a numeric text field with thousands separators (`1,000,000`) as the
/// user types, matching the app's display style (`money_format.dart`).
///
/// Rules this formatter owns:
/// - Groups the integer part in threes with `,`.
/// - Allows at most one decimal separator; extra dots are dropped.
/// - Keeps a single leading `-` (screens that forbid negatives validate it away).
/// - Drops every character that is not a digit, a `.` or a leading `-`.
/// - Collapses leading zeros (`007` → `7`) but keeps a lone `0` before a `.`.
/// - Preserves the caret's logical position across regrouping, so editing in
///   the middle of a long number does not jump the cursor to the end.
///
/// It never changes the value: separators are purely visual, and every amount
/// parser strips them (`parseMoneyInput`).
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  const ThousandsSeparatorInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final rawText = newValue.text;
    if (rawText.isEmpty) return newValue;

    // Count the meaningful (non-separator) characters left of the caret so we
    // can put the caret back in the same logical spot after regrouping.
    final meaningfulBeforeCaret = _meaningfulCount(rawText, newValue.selection);

    final formatted = _group(rawText);
    if (formatted.isEmpty) {
      return const TextEditingValue();
    }

    final caret = _offsetForMeaningful(formatted, meaningfulBeforeCaret);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: caret),
    );
  }

  /// Characters that are not grouping separators, up to the caret position.
  int _meaningfulCount(String text, TextSelection selection) {
    final caret = selection.baseOffset;
    final end = (caret < 0 || caret > text.length) ? text.length : caret;
    var count = 0;
    for (var i = 0; i < end; i++) {
      if (text[i] != ',') count++;
    }
    return count;
  }

  /// Index just after the [meaningful]th non-comma character in [text].
  int _offsetForMeaningful(String text, int meaningful) {
    if (meaningful <= 0) return 0;
    var seen = 0;
    for (var i = 0; i < text.length; i++) {
      if (text[i] != ',') {
        seen++;
        if (seen == meaningful) return i + 1;
      }
    }
    return text.length;
  }

  /// Strips separators and stray characters, normalizes the number, regroups.
  String _group(String input) {
    var digits = '';
    var hasDecimal = false;
    var negative = false;

    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      if (char == ',') continue;
      if (char == '-' && digits.isEmpty && !negative) {
        negative = true;
        continue;
      }
      if (char == '.') {
        if (hasDecimal) continue;
        hasDecimal = true;
        digits += char;
        continue;
      }
      final code = char.codeUnitAt(0);
      if (code >= 0x30 && code <= 0x39) digits += char;
    }

    if (digits.isEmpty) return '';

    final dotIndex = digits.indexOf('.');
    var intPart = dotIndex == -1 ? digits : digits.substring(0, dotIndex);
    final fracPart = dotIndex == -1 ? null : digits.substring(dotIndex + 1);

    // Drop leading zeros but keep a single zero (e.g. `0.5`).
    intPart = intPart.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (intPart.isEmpty) intPart = '0';

    final grouped = _groupInteger(intPart);

    final buffer = StringBuffer();
    final hasValue =
        grouped != '0' || (fracPart != null && fracPart.isNotEmpty);
    if (negative && hasValue) buffer.write('-');
    buffer.write(grouped);
    if (hasDecimal) {
      buffer.write('.');
      buffer.write(fracPart ?? '');
    }
    return buffer.toString();
  }

  String _groupInteger(String intPart) {
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
    }
    return buffer.toString();
  }
}
