// Keeps the three language files in sync: every text must exist in Roman
// Urdu, English and Urdu with the same {placeholders}.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _arb(String name) => jsonDecode(File('lib/l10n/$name').readAsStringSync()) as Map<String, dynamic>;

Set<String> _keys(Map<String, dynamic> arb) => arb.keys.where((k) => !k.startsWith('@')).toSet();

Set<String> _placeholders(String text) => RegExp(r'\{(\w+)[,}]').allMatches(text).map((m) => m.group(1)!).toSet();

void main() {
  final roman = _arb('app_ur_Latn.arb');
  final english = _arb('app_en.arb');
  final urdu = _arb('app_ur.arb');

  test('all languages have the same keys', () {
    expect(_keys(english), _keys(roman));
    expect(_keys(urdu), _keys(roman));
  });

  test('placeholders match in every language', () {
    for (final key in _keys(roman)) {
      final expected = _placeholders(roman[key] as String);
      expect(_placeholders(english[key] as String), containsAll(expected), reason: 'en: $key');
      expect(_placeholders(urdu[key] as String), containsAll(expected), reason: 'ur: $key');
    }
  });

  test('no empty translations', () {
    for (final arb in [roman, english, urdu]) {
      for (final key in _keys(arb)) {
        expect((arb[key] as String).trim(), isNotEmpty, reason: key);
      }
    }
  });
}
