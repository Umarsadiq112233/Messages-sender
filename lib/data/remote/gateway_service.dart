import 'dart:async';

import '../models.dart';
import 'sms_channel.dart';
import 'supabase_repo.dart';

/// The Android gateway: runs inside this same app on the phone whose SIM
/// sends the SMS. While running it polls Supabase for pending delivery
/// logs of running campaigns, sends each one through the phone's SIM
/// (see [SmsChannel]) and writes the result back — so every panel,
/// browser included, sees live status through realtime.
///
/// It also heartbeats the `gateway` row (connected / last_seen / device
/// name / real battery) so the panel's Gateway screen shows this phone
/// as online with its current charge.
class GatewayService {
  GatewayService(this._repo);

  final SupabaseRepo _repo;
  final SmsChannel _channel = const SmsChannel();

  static const _pollInterval = Duration(seconds: 5);

  Timer? _timer;
  bool _running = false;
  bool _tickBusy = false;
  Map<String, String> _info = const {};
  int? _battery;
  bool _charging = false;

  /// Device identity from the last successful [start].
  String? get deviceName => _info['name'];
  String? get deviceModel => _info['model'];

  /// The phone's real battery from the latest heartbeat read
  /// (null until the first successful read).
  int? get batteryLevel => _battery;
  bool get batteryCharging => _charging;

  bool get isRunning => _running;

  /// Requests the SMS permission and starts polling. Returns false when
  /// this platform can't send SMS or the permission was denied.
  Future<bool> start() async {
    if (_running) return true;
    if (!SmsChannel.isSupported) return false;
    if (!await _channel.requestPermission()) return false;
    _info = await _channel.deviceInfo();
    _running = true;
    try {
      // A previous run may have died mid-send; its logs can be sent again.
      await _repo.resetStaleSending();
      await _heartbeat(true);
    } catch (_) {
      // The first poll retries — sending must not wait on the heartbeat.
    }
    _timer = Timer.periodic(_pollInterval, (_) => unawaited(_tick()));
    unawaited(_tick());
    return true;
  }

  /// Stops polling and marks the gateway row disconnected. The timer is
  /// cancelled synchronously; the final heartbeat is best-effort.
  Future<void> stop({DisconnectReason reason = DisconnectReason.byUser}) async {
    if (!_running) return;
    _running = false;
    _timer?.cancel();
    _timer = null;
    try {
      await _heartbeat(false, reason: reason);
    } catch (_) {
      // Signing out / offline — panels notice the stale last_seen anyway.
    }
  }

  /// Every heartbeat re-reads the phone's real battery first, so the
  /// panel's Gateway card always shows the current charge — never a
  /// stale value written once long ago.
  Future<void> _heartbeat(bool connected, {DisconnectReason? reason}) async {
    final b = await _channel.batteryStatus();
    if (b != null) {
      _battery = b.level;
      _charging = b.charging;
    }
    await _repo.gatewayHeartbeat(
      connected: connected,
      deviceName: _info['name'],
      model: _info['model'],
      operator: _info['operator'],
      battery: _battery,
      charging: _battery == null ? null : _charging,
      disconnectReason: reason,
    );
  }

  Future<void> _tick() async {
    if (!_running || _tickBusy) return;
    _tickBusy = true;
    try {
      await _heartbeat(true);
      final settings = await _repo.settings();
      final delaySeconds = (settings?['delay_seconds'] as num?)?.toInt() ?? 20;
      // The chosen sending SIM, re-read every tick so a Settings change
      // takes effect on the next message without restarting the gateway.
      // Tolerant default: an un-migrated row has no sim_slot key.
      final simSlot = (settings?['sim_slot'] as num?)?.toInt() ?? -1;
      final campaigns = await _repo.runningCampaigns();
      var firstSend = true;
      for (final c in campaigns) {
        for (final log in c.logs) {
          if (!_running) return;
          // The panel may have paused/stopped this campaign since the fetch.
          if (await _repo.campaignState(c.id) != CampaignState.running) break;
          if (!firstSend) {
            await Future<void>.delayed(Duration(seconds: delaySeconds));
            if (!_running) return;
          }
          firstSend = false;
          // Keep last_seen fresh while a long campaign sends (the tick
          // can run for many minutes with the per-message delay).
          try {
            await _heartbeat(true);
          } catch (_) {
            // Best-effort — a failed heartbeat must not stop the send.
          }
          await _repo.markLogSending(log.id);
          final res = await _channel.sendResult(log.phone, c.message, simSlot: simSlot);
          log
            ..status = res.ok ? DeliveryStatus.sent : DeliveryStatus.failed
            ..reason = res.failReason
            ..time = DateTime.now();
          await _repo.updateLog(log);
        }
        if (!_running) return;
        // The campaign is finished once nothing is pending or in flight.
        if (await _repo.campaignState(c.id) == CampaignState.running &&
            !await _repo.hasUnfinishedLogs(c.id)) {
          await _repo.completeCampaign(c.id);
        }
      }
    } catch (_) {
      // Network hiccup etc. — the next poll retries; pending logs are safe.
    } finally {
      _tickBusy = false;
    }
  }
}
