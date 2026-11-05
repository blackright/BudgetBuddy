import 'package:budget_buddy/shared/presentation/profile_identity_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the same profile keeps the same colour', () {
    expect(profileIdentityColor('p1', brightness: Brightness.light),
        profileIdentityColor('p1', brightness: Brightness.light));
    expect(profileIdentityColor(' p1 ', brightness: Brightness.dark),
        profileIdentityColor('p1', brightness: Brightness.dark));
  });

  test('different profiles do not all share one colour', () {
    final colours = {
      for (final key in ['p1', 'p2', 'p3', 'p4', 'p5', 'p6'])
        profileIdentityColor(key, brightness: Brightness.light)
    };
    expect(colours.length, greaterThan(1));
  });

  test('dark mode lifts the tone', () {
    expect(profileIdentityColor('p1', brightness: Brightness.dark),
        isNot(profileIdentityColor('p1', brightness: Brightness.light)));
  });

  test('the unbudgeted colour is the error colour', () {
    final scheme = ThemeData().colorScheme;
    expect(mainProfileColor(scheme), scheme.error);
  });
}
