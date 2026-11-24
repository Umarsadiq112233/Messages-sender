import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Talks to the Android side (MainActivity, channel `paigham/sms`) for
/// everything the phone's SIM can do: the SEND_SMS permission, sending,
/// and device identity. Android only — off-Android every call is a safe
/// false / empty result.
class SmsChannel {
  const SmsChannel();

  static const _channel = MethodChannel('paigham/sms');

  /// True on a real Android build (not web, desktop or iOS).
  static bool get isSupported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Asks the user for the SEND_SMS permission; true when granted.
  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    try {
      return await _channel.invokeMethod<bool>('requestSmsPermission') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Sends [message] to [phone] (stored 03XXXXXXXXX format) via the SIM.
  /// True when the message was handed to the radio; false on any error
  /// (no permission, no signal, invalid number…).
  Future<bool> send(String phone, String message) async {
    if (!isSupported || message.trim().isEmpty) return false;
    try {
      return await _channel.invokeMethod<bool>('sendSms', {'to': phone, 'message': message}) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// {'name': 'Samsung SM-A145F', 'model': 'SM-A145F · Android 14',
  /// 'operator': 'Jazz'} — empty off-Android or on error.
  Future<Map<String, String>> deviceInfo() async {
    if (!isSupported) return const {};
    try {
      final raw = await _channel.invokeMethod<Map<Object?, Object?>>('deviceInfo');
      if (raw == null) return const {};
      return {for (final e in raw.entries) e.key.toString(): e.value?.toString() ?? ''};
    } catch (_) {
      return const {};
    }
  }
}
