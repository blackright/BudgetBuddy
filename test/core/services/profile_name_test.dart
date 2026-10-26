import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/services/profile_name.dart';

void main() {
  test(
      'preferred names preserve languages, trim edges and use grapheme initials',
      () {
    for (final name in ['Jason', 'José', '李', 'Émilie', '👨‍👩‍👧']) {
      expect(profileNameProblem(name), isNull);
    }
    expect(checkedProfileName('  Jason  '), 'Jason');
    expect(profileInitial(' José '), 'J');
    expect(profileInitial('李'), '李');
    expect(profileInitial('e\u0301milie'), 'E\u0301');
    expect(profileInitial('👨‍👩‍👧 family'), '👨‍👩‍👧');
    expect(profileInitial(''), '?');
  });
  test(
      'rejects invisible, controls and overlong names without rewriting valid text',
      () {
    for (final name in [
      '',
      '   ',
      '\u200b',
      '\u200d',
      'Jason\nSmith',
      '\u202eJason',
      'a' * 51
    ]) {
      expect(profileNameProblem(name), isNotNull, reason: name);
      expect(() => checkedProfileName(name), throwsArgumentError);
    }
    expect(profileNameProblem('e\u0301' * 50), isNull);
    expect(profileNameProblem('👨‍👩‍👧' * 50), isNull);
  });
}
