import 'package:flutter/widgets.dart' show StringCharacters;

/// Local display names are independent of pairing usernames and stable IDs.
String? profileNameProblem(String value) {
  final name = value.trim();
  if (name.isEmpty) return 'Enter the name you would like to use.';
  if (RegExp(r'[\x00-\x1f\x7f-\x9f\u200b\u202a-\u202e\u2066-\u2069\ufeff]')
      .hasMatch(name)) {
    return 'Use a visible name without control characters.';
  }
  if (name.characters.length > 50) return 'Use 50 characters or fewer.';
  if (name
      .replaceAll(
          RegExp(
              r'[\s\u00ad\u034f\u061c\u115f\u1160\u17b4\u17b5\u180b-\u180f\u200b-\u200f\u202a-\u202e\u2060-\u206f\u3164\ufe00-\ufe0f\ufeff\uffa0]'),
          '')
      .isEmpty) {
    return 'Enter a visible name.';
  }
  return null;
}

String checkedProfileName(String value) {
  final problem = profileNameProblem(value);
  if (problem != null) throw ArgumentError(problem);
  return value.trim();
}

String profileInitial(String name) {
  final trimmed = name.trim();
  return trimmed.isEmpty || profileNameProblem(trimmed) != null
      ? '?'
      : trimmed.characters.first.toUpperCase();
}
