import 'dart:async';

import '../../core/utils/phone.dart';
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

  static const _pollInterval = Duration(seconds: 2);

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

  /// Fails every (pending) log of [c] with [reason] and stamps the
  /// time — used by the pre-send condition checks, where the honest
  /// outcome is "not sent, and here is exactly why", written back so
  /// every panel shows it instead of a queue that silently stalls.
  Future<void> _failAll(Campaign c, FailReason reason) async {
    for (final log in c.logs) {
      log
        ..status = DeliveryStatus.failed
        ..reason = reason
        ..time = DateTime.now();
      try {
        await _repo.updateLog(log);
      } catch (_) {
        // One failed write must not stop the rest being marked.
      }
    }
  }

  Future<void> _tick() async {
    if (!_running || _tickBusy) return;
    _tickBusy = true;
    try {
      await _heartbeat(true);
      // Self-heal on every tick, not only in start(): a log left in
      // 'sending' by a run that died mid-send would otherwise block
      // its campaign forever (the work list only fetches 'pending',
      // and the completion check counts 'sending' as unfinished).
      // Safe mid-run: this service sends serially, so at tick start
      // none of its own sends are in flight.
      try {
        await _repo.resetStaleSending();
      } catch (_) {
        // Best-effort — the sends below still proceed.
      }
      final settings = await _repo.settings();
      // Clamp into the fast range: rows saved before the fast-sending
      // change can still hold the retired slow default (20s).
      final delaySeconds = ((settings?['delay_seconds'] as num?)?.toInt() ?? 2).clamp(1, 5);
      // The chosen sending SIM, re-read every tick so a Settings change
      // takes effect on the next message without restarting the gateway.
      // Tolerant default: an un-migrated row has no sim_slot key.
      final simSlot = (settings?['sim_slot'] as num?)?.toInt() ?? -1;
      final dailyLimit = (settings?['daily_limit'] as num?)?.toInt() ?? 0;
      final campaigns = await _repo.runningCampaigns();
      if (campaigns.isEmpty) return;

      // ── Pre-send condition checks, once per tick ──────────────────
      // Each one fails the queued logs with its real reason instead of
      // letting every message bounce off the radio and come back with
      // a misleading generic error (or stall silently).
      if (!await _channel.hasPermission()) {
        // Granted at start(), but revoked since (system settings, a
        // permission reset…). Nothing can send: fail the queue with
        // the true reason and disconnect, so the panel stops showing
        // a live gateway that cannot actually send.
        for (final c in campaigns) {
          await _failAll(c, FailReason.noPermission);
          await _repo.completeCampaign(c.id);
        }
        await stop(reason: DisconnectReason.lostConnection);
        return;
      }
      if (!await _channel.simAvailable(simSlot: simSlot)) {
        // The SIM that should send is not in the phone (removed, or
        // the other slot chosen). Fail fast with the real reason
        // instead of a radio error per message.
        for (final c in campaigns) {
          await _failAll(c, FailReason.noSim);
          await _repo.completeCampaign(c.id);
        }
        return;
      }
      // SMS units already sent today, for the daily-limit check below.
      var sentToday = dailyLimit > 0 ? await _repo.sentSmsToday() : 0;

      var firstSend = true;
      for (final c in campaigns) {
        final segments = c.segments < 1 ? 1 : c.segments;
        for (var i = 0; i < c.logs.length; i++) {
          final log = c.logs[i];
          if (!_running) return;
          // The panel may have paused/stopped this campaign since the fetch.
          if (await _repo.campaignState(c.id) != CampaignState.running) break;
          // A stored number that is not a valid Pakistani mobile can
          // never be delivered. Fail it here with a clear reason
          // instead of handing it to the radio, whose generic failure
          // would be misreported as a balance problem.
          if (!Phone.isValid(log.phone)) {
            log
              ..status = DeliveryStatus.failed
              ..reason = FailReason.notExist
              ..time = DateTime.now();
            await _repo.updateLog(log);
            continue;
          }
          // Daily limit: once today's allowance is used up, this and
          // every remaining message of the campaign fail with the
          // limit reason — the panel used to only warn while the
          // gateway kept sending into carrier throttling.
          if (dailyLimit > 0 && sentToday + segments > dailyLimit) {
            for (final rest in c.logs.skip(i)) {
              rest
                ..status = DeliveryStatus.failed
                ..reason = FailReason.limitReached
                ..time = DateTime.now();
              await _repo.updateLog(rest);
            }
            break;
          }
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
          // Atomic claim: if another gateway (same account, second
          // phone) already took this log, skip it — never send twice.
          if (!await _repo.claimLog(log.id)) continue;
          final res = await _channel.sendResult(log.phone, c.message, simSlot: simSlot);
          if (res.ok) sentToday += segments;
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
