import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/phone.dart';

/// Real SMS sending, used when Test Mode is OFF.
///
/// The app never talks to the SMS provider directly: it invokes the
/// `send-sms` Supabase Edge Function, which holds the provider API key as a
/// secret and performs the actual send. One recipient per call.
class SmsSender {
  const SmsSender();

  /// Sends [message] to [phone] (any Pakistani format: 0300…, +92…, 92…).
  /// Returns true only when the provider accepted the message; every error
  /// (network, function down, provider rejection) is reported as false.
  Future<bool> send(String phone, String message) async {
    final to = toInternational(phone);
    if (to == null || message.trim().isEmpty) return false;
    try {
      final res = await Supabase.instance.client.functions.invoke(
        'send-sms',
        body: {'to': to, 'message': message},
      );
      final data = res.data;
      return data is Map && data['ok'] == true;
    } catch (_) {
      // functions.invoke throws on non-2xx responses — that is a failed send.
      return false;
    }
  }

  /// 03001234567 → +923001234567, or null when the number is not a valid
  /// Pakistani mobile number.
  static String? toInternational(String phone) {
    final n = Phone.normalize(phone);
    if (!Phone.isValid(n)) return null;
    return '+92${n.substring(1)}';
  }
}
