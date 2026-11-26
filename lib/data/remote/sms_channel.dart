import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models.dart';

/// The typed outcome of one SIM send, as reported by the Android radio
/// through the sent PendingIntent (see MainActivity.sendSms).
class SmsSendResult {
  const SmsSendResult({required this.ok, required this.code});

  /// True only when the radio accepted the message (RESULT_OK for every
  /// part of a multipart message).
  final bool ok;

  /// Stable native code: ok | genericFailure | noService | nullPdu |
  /// radioOff | limitExceeded | noPermission | sendFailed | timeout |
  /// noSim (a SIM slot was chosen but has no active subscription).
  final String code;

  /// The user-facing failure reason for this code, or null when [ok].
  FailReason? get failReason => ok ? null : failReasonForCode(code);

  /// Native code → FailReason. On prepaid Pakistani SIMs the carrier
  /// reports "generic failure" when there is no balance / no SMS package,
  /// and the platform rate-limit error likewise means the SIM cannot send
  /// right now — both surface as [FailReason.lowBalance], whose label
  /// tells the user to check the SIM balance/package.
  static FailReason failReasonForCode(String code) => switch (code) {
    'genericFailure' => FailReason.lowBalance,
    'limitExceeded' => FailReason.lowBalance,
    'noService' => FailReason.networkBusy,
    'radioOff' => FailReason.networkBusy,
    'nullPdu' => FailReason.notExist,
    'timeout' => FailReason.timeout,
    // These two used to fall through to networkBusy, which sent the
    // user chasing a network problem when the real cause was on the
    // gateway phone itself (permission revoked / chosen SIM missing).
    'noPermission' => FailReason.noPermission,
    'noSim' => FailReason.noSim,
    _ => FailReason.networkBusy,
  };
}

/// The gateway phone's real battery right now, as read by Android's
/// BatteryManager (see MainActivity.batteryInfo).
class BatteryStatus {
  const BatteryStatus({required this.level, required this.charging});

  /// Charge percentage, 0–100.
  final int level;

  /// True while the phone is plugged in / fully charged.
  final bool charging;
}

/// One active SIM on the gateway phone, as reported by Android's
/// SubscriptionManager.
class SimInfo {
  const SimInfo({required this.slot, required this.subscriptionId, required this.carrier, required this.number});

  /// Physical SIM slot, 0-based (0 = SIM 1, 1 = SIM 2).
  final int slot;

  /// Android subscription id for this SIM.
  final int subscriptionId;

  /// Carrier/display name ('' when Android doesn't provide one).
  final String carrier;

  /// The SIM's own number — best-effort, often '' on modern Android.
  final String number;
}

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

  /// True when SEND_SMS is already granted. A check only — it never
  /// shows the permission dialog, so startup code can use it to decide
  /// whether an automatic gateway connect is possible without asking.
  Future<bool> hasPermission() async {
    if (!isSupported) return false;
    try {
      return await _channel.invokeMethod<bool>('hasSmsPermission') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Asks the user for the READ_PHONE_STATE permission (needed to list
  /// the phone's SIMs); true when granted.
  Future<bool> requestPhoneStatePermission() async {
    if (!isSupported) return false;
    try {
      return await _channel.invokeMethod<bool>('requestPhoneStatePermission') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// The phone's active SIMs, sorted by slot. Empty off-Android, when
  /// the phone-state permission isn't granted, or on any error.
  Future<List<SimInfo>> listSims() async {
    if (!isSupported) return const [];
    try {
      final raw = await _channel.invokeMethod<List<Object?>>('listSims');
      if (raw == null) return const [];
      return [
        for (final e in raw)
          if (e is Map)
            SimInfo(
              slot: (e['slot'] as num?)?.toInt() ?? 0,
              subscriptionId: (e['subscriptionId'] as num?)?.toInt() ?? -1,
              carrier: e['carrier']?.toString() ?? '',
              number: e['number']?.toString() ?? '',
            ),
      ];
    } catch (_) {
      return const [];
    }
  }

  /// True when the SIM that would send is actually present: the
  /// chosen slot's SIM when [simSlot] >= 0, otherwise any active SIM.
  /// Only a definite "no SIM" returns false — when Android can't tell
  /// (e.g. the phone-state permission is missing) this returns true and
  /// the per-message send path reports its own precise outcome instead.
  Future<bool> simAvailable({int simSlot = -1}) async {
    if (!isSupported) return true;
    try {
      final raw = await _channel.invokeMethod<Map<Object?, Object?>>('simState', {'simSlot': simSlot});
      if (raw == null) return true;
      final known = raw['known'] == true;
      final available = raw['available'] == true;
      return !known || available;
    } catch (_) {
      return true;
    }
  }

  /// Sends [message] to [phone] (stored 03XXXXXXXXX format) via the SIM
  /// and reports the radio's real outcome — a send the carrier rejects
  /// (no balance/package, no service, radio off…) comes back with
  /// `ok == false` and the matching [SmsSendResult.code].
  ///
  /// [simSlot] is the physical SIM slot to send from (0 = SIM 1);
  /// -1 (the default) keeps the phone-default behavior. A chosen slot
  /// with no active SIM fails with code 'noSim' — the message is never
  /// sent from a different SIM instead.
  Future<SmsSendResult> sendResult(String phone, String message, {int simSlot = -1}) async {
    if (!isSupported || message.trim().isEmpty) {
      return const SmsSendResult(ok: false, code: 'sendFailed');
    }
    try {
      final raw = await _channel.invokeMethod<Object?>('sendSms', {
        'to': phone,
        'message': message,
        'simSlot': simSlot,
      });
      // Tolerate a plain bool from an older native side.
      if (raw is bool) return SmsSendResult(ok: raw, code: raw ? 'ok' : 'sendFailed');
      if (raw is Map) {
        final ok = raw['ok'] == true;
        final code = raw['code']?.toString() ?? (ok ? 'ok' : 'sendFailed');
        return SmsSendResult(ok: ok, code: code);
      }
      return const SmsSendResult(ok: false, code: 'sendFailed');
    } on PlatformException catch (e) {
      return SmsSendResult(
        ok: false,
        code: switch (e.code) {
          'no_permission' => 'noPermission',
          'send_failed' => 'sendFailed',
          'bad_args' => 'nullPdu',
          _ => 'sendFailed',
        },
      );
    } catch (_) {
      return const SmsSendResult(ok: false, code: 'sendFailed');
    }
  }

  /// Sends [message] to [phone] via the SIM. True only when the radio
  /// accepted the message; false on any failure. Kept for callers that
  /// don't need the reason — new code should use [sendResult].
  Future<bool> send(String phone, String message, {int simSlot = -1}) async =>
      (await sendResult(phone, message, simSlot: simSlot)).ok;

  /// The phone's real battery level and charging state, read fresh on
  /// every call. Null off-Android, on any error, or when Android can't
  /// report a level — callers keep their last known value then.
  Future<BatteryStatus?> batteryStatus() async {
    if (!isSupported) return null;
    try {
      final raw = await _channel.invokeMethod<Map<Object?, Object?>>('batteryInfo');
      if (raw == null) return null;
      final level = (raw['battery'] as num?)?.toInt();
      if (level == null || level < 0 || level > 100) return null;
      return BatteryStatus(level: level, charging: raw['charging'] == true);
    } catch (_) {
      return null;
    }
  }

  /// {'name': 'Samsung SM-A145F', 'model': 'SM-A145F · Android 14',
  /// 'operator': 'Jazz', 'battery': '82', 'charging': 'false'} —
  /// empty off-Android or on error.
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
