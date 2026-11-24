import 'package:flutter/services.dart';

/// Pakistani mobile numbers: stored as 11 digits (03XXXXXXXXX),
/// shown as 03XX-XXXXXXX.
abstract final class Phone {
  static final _valid = RegExp(r'^03\d{9}$');

  static String digits(String input) => input.replaceAll(RegExp(r'\D'), '');

  /// Accepts 03001234567, 0300-1234567, +92 300 1234567, 923001234567,
  /// 3001234567 and returns 03001234567 (or the raw digits if it can't).
  static String normalize(String input) {
    var d = digits(input);
    if (d.startsWith('0092')) d = d.substring(4);
    if (d.startsWith('92') && d.length == 12) d = '0${d.substring(2)}';
    if (d.length == 10 && d.startsWith('3')) d = '0$d';
    return d;
  }

  static bool isValid(String input) => _valid.hasMatch(normalize(input));

  static String format(String input) {
    final d = normalize(input);
    if (d.length <= 4) return d;
    return '${d.substring(0, 4)}-${d.substring(4, d.length.clamp(4, 11))}';
  }

  /// Why a number is not valid (null when valid). Shown via l10n.
  static PhoneIssue? issue(String input) {
    final d = digits(input);
    if (d.isEmpty) return const PhoneIssue(PhoneIssueKind.empty);
    final n = normalize(input);
    if (!n.startsWith('03')) return const PhoneIssue(PhoneIssueKind.prefix);
    if (n.length < 11) return PhoneIssue(PhoneIssueKind.tooShort, n.length);
    if (n.length > 11) return const PhoneIssue(PhoneIssueKind.tooLong);
    return null;
  }
}

enum PhoneIssueKind { empty, prefix, tooShort, tooLong }

class PhoneIssue {
  const PhoneIssue(this.kind, [this.digits = 0]);
  final PhoneIssueKind kind;
  final int digits;
}

/// Auto-formats typing into 03XX-XXXXXXX.
class PkPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var d = Phone.digits(newValue.text);
    if (d.length > 11) d = d.substring(0, 11);
    final text = d.length > 4 ? '${d.substring(0, 4)}-${d.substring(4)}' : d;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
