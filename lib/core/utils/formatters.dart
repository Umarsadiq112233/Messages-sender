import 'package:intl/intl.dart';

/// Number / date formatting. [locale] follows the selected app language
/// (set by LanguageController): English month names for Roman Urdu and
/// English, Urdu month names for Urdu. Digits stay Latin everywhere.
abstract final class Fmt {
  static String locale = 'en';

  static final _num = NumberFormat.decimalPattern('en_US');
  static final _cache = <String, DateFormat>{};

  static DateFormat _f(String pattern) => _cache.putIfAbsent('$locale|$pattern', () => DateFormat(pattern, locale));

  static String number(num n) => _num.format(n);
  static String date(DateTime d) => _f('d MMM yyyy').format(d);
  static String dateShort(DateTime d) => _f('d MMM').format(d);
  static String time(DateTime d) => _f('h:mm a').format(d);
  static String dateTime(DateTime d) => _f('d MMM, h:mm a').format(d);
  static String weekday(DateTime d) => _f('EEE').format(d);
}

extension DateOnly on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);
  bool isSameDay(DateTime o) => year == o.year && month == o.month && day == o.day;
}
