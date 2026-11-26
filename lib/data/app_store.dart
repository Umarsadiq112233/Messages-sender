import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../core/config/supabase_config.dart';
import '../core/utils/formatters.dart';
import '../core/utils/phone.dart';
import 'models.dart';
import 'remote/gateway_intent.dart';
import 'remote/gateway_service.dart';
import 'remote/sms_channel.dart';
import 'remote/supabase_repo.dart';
import 'sample_data.dart';

enum LoginResult { ok, wrongCredentials, network }

/// App state. Every screen talks only to this class.
///
/// * **Live mode** (Supabase key configured): data is loaded from Supabase
///   after login and every change is written through to the database
///   (in order, see [_push]). Gateway / queue updates arrive via realtime.
/// * **Demo mode** (no key): in-memory sample data, admin / admin123.
///
/// Sending: with Test Mode ON the queue is simulated locally. With Test
/// Mode OFF the panel only enqueues — logs stay `pending` in Supabase
/// and the Android gateway phone (this same app: Gateway screen →
/// Connect) sends them from its own SIM and writes the results back;
/// they arrive here via realtime. Results land in `delivery_logs`
/// either way.
class AppStore extends ChangeNotifier with WidgetsBindingObserver {
  AppStore._() {
    if (!isLive) loadSample(notify: false);
    try {
      // So the gateway can reconnect itself when the app comes back to
      // the foreground (see didChangeAppLifecycleState).
      WidgetsBinding.instance.addObserver(this);
    } catch (_) {
      // No binding (e.g. unit tests) — resume auto-connect just won't fire.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The gateway service only sends while the app process is alive; if
    // Android killed it in the background, reconnect on return — under
    // exactly the same conditions as the launch auto-connect.
    if (state == AppLifecycleState.resumed) unawaited(_maybeAutoConnectGateway());
  }

  /// True when a Supabase key is configured.
  bool get isLive => SupabaseConfig.isConfigured;

  /// True when the gateway is connected AND its heartbeat is fresh.
  /// The stored `connected` flag alone can be stale-true: if the
  /// gateway phone dies, is swiped away or loses network, its
  /// disconnect write never happens and the row keeps claiming
  /// "connected" while nothing would actually send — the panel then
  /// happily enqueues campaigns that sit pending forever. In live
  /// mode the heartbeat (every 2s while the gateway runs) is the
  /// truth: no beat for a minute means not online. Demo mode has no
  /// real heartbeat, so there the flag alone decides.
  bool get gatewayOnline {
    if (!gateway.connected) return false;
    if (!isLive) return true;
    return DateTime.now().difference(gateway.lastSeen) < const Duration(seconds: 60);
  }

  SupabaseRepo? _repo;
  GatewayService? _gatewayService;
  RealtimeChannel? _channel;

  /// The gateway service for this device, once the backend is loaded.
  GatewayService? get _gateway {
    final repo = _repo;
    if (repo == null) return null;
    return _gatewayService ??= GatewayService(repo)..onTakenOver = (_) {
      // Another phone took over as the gateway: this phone is no
      // longer the sender, and the UI must say so — not keep showing
      // a green "connected" for a gateway that will never send again.
      gateway
        ..connected = false
        ..disconnectReason = DisconnectReason.lostConnection;
      notifyListeners();
    };
  }

  Future<void> _chain = Future<void>.value();

  /// Called when a write to Supabase fails (shown as a toast).
  void Function(Object error)? onSyncError;

  /// Session restore started at app launch; the splash waits for it.
  Future<void> boot = Future<void>.value();

  static final AppStore instance = AppStore._();

  // ───────────────────────── Auth ─────────────────────────
  /// Demo login (until the backend exists): admin / admin123
  static const demoUsername = 'admin';
  static const demoPassword = 'admin123';

  final auth = ValueNotifier<bool>(false);
  String _password = demoPassword;
  String displayName = 'Shakir';

  Future<LoginResult> login(String username, String password) async {
    if (!isLive) {
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      final ok = username.trim().toLowerCase() == demoUsername && password == _password;
      if (ok) auth.value = true;
      return ok ? LoginResult.ok : LoginResult.wrongCredentials;
    }
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: SupabaseConfig.emailFor(username),
        password: password,
      );
    } on AuthException catch (e) {
      final wrong = e.code == 'invalid_credentials' || (e.statusCode == '400' && e.code == null);
      return wrong ? LoginResult.wrongCredentials : LoginResult.network;
    } catch (_) {
      return LoginResult.network;
    }
    if (!await _loadRemote()) return LoginResult.network;
    auth.value = true;
    return LoginResult.ok;
  }

  /// Restores a saved Supabase session (app reopened / page refreshed).
  Future<void> restore() async {
    if (!isLive || Supabase.instance.client.auth.currentSession == null) return;
    if (await _loadRemote()) auth.value = true;
  }

  void logout() {
    auth.value = false;
    clearSelection();
    if (!isLive) return;
    _gatewayService?.stop(); // cancels its timer synchronously
    _stopTimer();
    _channel?.unsubscribe();
    _channel = null;
    Supabase.instance.client.auth.signOut().ignore();
    groups.clear();
    contacts.clear();
    campaigns.clear();
    activities.clear();
    focusCampaign = null;
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (isLive) {
      final auth = Supabase.instance.client.auth;
      final email = auth.currentUser?.email;
      if (email == null) return false;
      try {
        await auth.signInWithPassword(email: email, password: oldPassword);
        await auth.updateUser(UserAttributes(password: newPassword));
      } catch (_) {
        return false;
      }
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (oldPassword != _password) return false;
      _password = newPassword;
    }
    _log(ActivityEvent.passwordChanged);
    notifyListeners();
    return true;
  }

  // ───────────────────────── Supabase sync ─────────────────────────

  /// Runs database writes one after another, in the order they happened.
  void _push(Future<void> Function(SupabaseRepo repo) op) {
    final repo = _repo;
    if (!isLive || repo == null) return;
    _chain = _chain.then((_) => op(repo)).catchError((Object e) {
      onSyncError?.call(e);
    });
  }

  Future<bool> _loadRemote() async {
    final repo = _repo ??= SupabaseRepo(Supabase.instance.client);
    try {
      final results = await Future.wait<Object?>([
        repo.groups(),
        repo.contacts(),
        repo.campaigns(),
        repo.activities(),
        repo.settings(),
        repo.gateway(),
      ]);
      _stopTimer();
      groups
        ..clear()
        ..addAll(results[0]! as List<Group>);
      contacts
        ..clear()
        ..addAll(results[1]! as List<Contact>);
      campaigns
        ..clear()
        ..addAll(results[2]! as List<Campaign>);
      activities
        ..clear()
        ..addAll(results[3]! as List<Activity>);
      if (results[4] case final Map<String, dynamic> row) SupabaseRepo.applySettings(settings, row);
      if (results[5] case final Map<String, dynamic> row) SupabaseRepo.applyGateway(gateway, row);
      // On the gateway phone itself the database row can be stale: a
      // previous run that was killed (app swiped away, phone restarted)
      // never wrote its disconnect, so the row still claims "connected"
      // while no GatewayService is running in this app instance and
      // nothing would actually send. Trust the local service instead.
      // (A browser panel is unaffected — it has no local service.)
      if (SmsChannel.isSupported && _gatewayService?.isRunning != true) {
        gateway.connected = false;
      }
      selectedIds.clear();
      final meta = Supabase.instance.client.auth.currentUser?.userMetadata;
      displayName = (meta?['display_name'] ?? meta?['name'] ?? displayName).toString();
      // A campaign whose logs are ALL final but whose state is still
      // "running" (the gateway sent everything but its completion write
      // was lost, or the app closed at the wrong moment) would otherwise
      // stay active forever and block Compose with "already running".
      for (final c in campaigns.where((c) => c.state == CampaignState.running)) {
        if (c.logs.isNotEmpty &&
            c.logs.every((l) => l.status == DeliveryStatus.sent || l.status == DeliveryStatus.failed)) {
          c
            ..state = CampaignState.completed
            ..finishedAt = c.finishedAt ?? DateTime.now();
          _push((r) => r.updateCampaign(c));
        }
      }
      // Test mode is driven by this panel, so a campaign left "running"
      // by a closed tab is paused; Resume continues it. In real mode the
      // gateway phone is the driver — running campaigns are left alone.
      if (settings.testMode) {
        for (final c in campaigns.where((c) => c.state == CampaignState.running)) {
          c
            ..state = CampaignState.paused
            ..pauseReason = PauseReason.user;
          for (final l in c.logs) {
            if (l.status == DeliveryStatus.sending) l.status = DeliveryStatus.pending;
          }
          _push((r) => r.updateCampaign(c));
        }
      }
      focusCampaign = activeCampaign;
      _subscribeRealtime();
      notifyListeners();
      // The gateway phone should not need a manual Connect after every
      // app start / APK update — reconnect it by default (real mode,
      // permission already granted, user hasn't disconnected manually).
      unawaited(_maybeAutoConnectGateway());
      return true;
    } catch (e) {
      onSyncError?.call(e);
      return false;
    }
  }

  /// Manual reload behind pull-to-refresh: re-runs the exact same
  /// full load used at login ([_loadRemote]) so every screen shows
  /// fresh database state. The returned future completes only when
  /// the load has finished (or failed — failures already surface via
  /// [onSyncError]'s toast inside [_loadRemote]). Demo mode has
  /// nothing remote to fetch, so it just settles briefly and
  /// re-notifies, which still gives the indicator honest work.
  Future<void> refresh() async {
    if (!isLive) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      notifyListeners();
      return;
    }
    await _loadRemote();
  }

  void _subscribeRealtime() {
    _channel?.unsubscribe();
    final client = Supabase.instance.client;
    _channel = client.channel('paigham-panel')
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'gateway',
        callback: (p) {
          SupabaseRepo.applyGateway(gateway, p.newRecord);
          notifyListeners();
        },
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'campaigns',
        callback: (p) {
          // State changes written by the gateway phone (e.g. completed
          // once every message has been sent).
          final c = campaigns.where((c) => c.id == p.newRecord['id']).firstOrNull;
          if (c == null) return;
          SupabaseRepo.applyCampaignUpdate(c, p.newRecord);
          notifyListeners();
        },
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'delivery_logs',
        callback: (p) {
          // Updates from another device / the gateway app. Our own running
          // campaign is driven locally, so only final results are applied.
          final r = p.newRecord;
          final status = r['status'];
          if (status != 'sent' && status != 'failed') return;
          for (final c in campaigns) {
            if (c.id != r['campaign_id']) continue;
            final log = c.logs.where((l) => l.id == r['id']).firstOrNull;
            if (log == null || log.status == DeliveryStatus.sent || log.status == DeliveryStatus.failed) return;
            final fresh = SupabaseRepo.logFromRow(r);
            log
              ..status = fresh.status
              ..reason = fresh.reason
              ..time = fresh.time;
            notifyListeners();
            return;
          }
        },
      )
      ..subscribe();
  }

  // ───────────────────────── Data ─────────────────────────
  final List<Group> groups = [];
  final List<Contact> contacts = [];
  final List<Campaign> campaigns = []; // newest first
  final List<Activity> activities = []; // newest first
  final Set<String> selectedIds = {};
  final AppSettings settings = AppSettings();
  late final GatewayInfo gateway = GatewayInfo(
    connected: true,
    deviceName: 'Samsung Galaxy A14',
    model: 'SM-A145F · Android 14',
    simNumber: '0301-5550123',
    operator: 'Jazz',
    signal: 3,
    battery: 78,
    charging: true,
    lastSeen: DateTime.now(),
    pairCode: '482-913',
  );

  final _rng = Random();
  static const _uuid = Uuid();
  String _id(String prefix) => _uuid.v4();

  void loadSample({bool notify = true}) {
    if (isLive) return; // never overwrite the real database with samples
    _stopTimer();
    final s = SampleData.generate();
    groups
      ..clear()
      ..addAll(s.groups);
    contacts
      ..clear()
      ..addAll(s.contacts);
    campaigns
      ..clear()
      ..addAll(s.campaigns);
    activities
      ..clear()
      ..addAll(s.activities);
    selectedIds.clear();
    if (notify) notifyListeners();
  }

  void clearAll() {
    if (isLive) return;
    _stopTimer();
    groups.clear();
    contacts.clear();
    campaigns.clear();
    activities.clear();
    selectedIds.clear();
    notifyListeners();
  }

  void _log(ActivityEvent event, [List<String> args = const []]) {
    final a = Activity(event, DateTime.now(), args);
    activities.insert(0, a);
    _push((r) => r.insertActivity(a));
    if (activities.length > 60) activities.removeLast();
  }

  // ───────────────────────── Lookups ─────────────────────────
  Group? groupById(String? id) => id == null ? null : groups.where((g) => g.id == id).firstOrNull;
  Contact? contactById(String id) => contacts.where((c) => c.id == id).firstOrNull;
  int groupCount(String groupId) => contacts.where((c) => c.groupId == groupId).length;
  int get ungroupedCount => contacts.where((c) => c.groupId == null).length;

  Contact? findByPhone(String phone, {String? excludeId}) {
    final n = Phone.normalize(phone);
    return contacts.where((c) => c.phone == n && c.id != excludeId).firstOrNull;
  }

  List<DeliveryLog> logsForContact(String contactId) {
    final list = campaigns.expand((c) => c.logs).where((l) => l.contactId == contactId && l.time != null).toList()
      ..sort((a, b) => b.time!.compareTo(a.time!));
    return list;
  }

  Campaign? campaignById(String id) => campaigns.where((c) => c.id == id).firstOrNull;

  // ───────────────────────── Contacts ─────────────────────────
  Contact addContact({required String name, required String phone, String? groupId, String note = ''}) {
    final c = Contact(
      id: _id('c'),
      name: name.trim().isEmpty ? Phone.format(phone) : name.trim(),
      phone: Phone.normalize(phone),
      groupId: groupId,
      note: note.trim(),
      createdAt: DateTime.now(),
    );
    contacts.insert(0, c);
    _push((r) => r.insertContacts([c]));
    _log(ActivityEvent.contactAdded, [c.name, Phone.format(c.phone)]);
    notifyListeners();
    return c;
  }

  void updateContact(Contact c, {required String name, required String phone, String? groupId, String note = ''}) {
    c
      ..name = name.trim().isEmpty ? Phone.format(phone) : name.trim()
      ..phone = Phone.normalize(phone)
      ..groupId = groupId
      ..note = note.trim();
    _push((r) => r.updateContact(c));
    _log(ActivityEvent.contactEdited, [c.name, Phone.format(c.phone)]);
    notifyListeners();
  }

  void deleteContacts(Iterable<String> ids) {
    final set = ids.toSet();
    final removed = contacts.where((c) => set.contains(c.id)).toList();
    if (removed.isEmpty) return;
    contacts.removeWhere((c) => set.contains(c.id));
    selectedIds.removeAll(set);
    _push((r) => r.deleteContacts(set.toList()));
    if (removed.length == 1) {
      _log(ActivityEvent.contactDeleted, [removed.first.name]);
    } else {
      _log(ActivityEvent.contactsDeleted, ['${removed.length}']);
    }
    notifyListeners();
  }

  ImportResult importRows(List<ImportRow> rows, String? groupId) {
    var added = 0;
    var dup = 0;
    var bad = 0;
    final now = DateTime.now();
    final fresh = <Contact>[];
    for (final r in rows) {
      switch (r.status) {
        case ImportRowStatus.invalid:
          bad++;
        case ImportRowStatus.duplicate:
          dup++;
        case ImportRowStatus.valid:
          if (findByPhone(r.phone) != null) {
            dup++;
            continue;
          }
          final c = Contact(
            id: _id('c'),
            name: r.name.isEmpty ? Phone.format(r.phone) : r.name,
            phone: r.phone,
            groupId: groupId,
            createdAt: now,
          );
          contacts.insert(0, c);
          fresh.add(c);
          added++;
      }
    }
    if (fresh.isNotEmpty) _push((r) => r.insertContacts(fresh));
    final g = groupById(groupId);
    _log(ActivityEvent.imported, ['$added', g?.name ?? '']);
    notifyListeners();
    return ImportResult(total: rows.length, added: added, duplicates: dup, invalid: bad);
  }

  // ───────────────────────── Groups ─────────────────────────
  Group createGroup(String name) {
    final g = Group(
      id: _id('g'),
      name: name.trim(),
      colorIndex: groups.isEmpty ? 0 : (groups.map((g) => g.colorIndex).reduce(max) + 1),
      createdAt: DateTime.now(),
    );
    groups.add(g);
    _push((r) => r.insertGroup(g));
    _log(ActivityEvent.groupCreated, [g.name]);
    notifyListeners();
    return g;
  }

  void renameGroup(Group g, String name) {
    final old = g.name;
    g.name = name.trim();
    _push((r) => r.renameGroup(g));
    _log(ActivityEvent.groupRenamed, [old, g.name]);
    notifyListeners();
  }

  void deleteGroup(Group g) {
    for (final c in contacts) {
      if (c.groupId == g.id) c.groupId = null;
    }
    groups.remove(g);
    _push((r) => r.deleteGroup(g.id));
    _log(ActivityEvent.groupDeleted, [g.name]);
    notifyListeners();
  }

  bool groupNameExists(String name, {String? exceptId}) =>
      groups.any((g) => g.id != exceptId && g.name.toLowerCase() == name.trim().toLowerCase());

  // ───────────────────────── Selection ─────────────────────────
  void toggleSelect(String id) {
    if (!selectedIds.remove(id)) selectedIds.add(id);
    notifyListeners();
  }

  void setSelection(Iterable<String> ids, bool selected) {
    if (selected) {
      selectedIds.addAll(ids);
    } else {
      selectedIds.removeAll(ids);
    }
    notifyListeners();
  }

  void clearSelection() {
    if (selectedIds.isEmpty) return;
    selectedIds.clear();
    notifyListeners();
  }

  List<Contact> get selectedContacts => contacts.where((c) => selectedIds.contains(c.id)).toList();

  // ───────────────────────── Stats ─────────────────────────
  int get totalNumbers => contacts.length;

  Iterable<DeliveryLog> get allLogs => campaigns.expand((c) => c.logs);

  int get todaySent {
    final now = DateTime.now();
    return allLogs.where((l) => l.status == DeliveryStatus.sent && l.time != null && l.time!.isSameDay(now)).length;
  }

  /// SMS units actually sent today. Each delivered message counts by
  /// its campaign's segment count — the same unit the daily limit and
  /// the Compose total are measured in (a 2-segment message is 2 SMS).
  int get todaySentSms {
    final now = DateTime.now();
    var total = 0;
    for (final c in campaigns) {
      final segs = c.segments < 1 ? 1 : c.segments;
      for (final l in c.logs) {
        if (l.status == DeliveryStatus.sent && l.time != null && l.time!.isSameDay(now)) {
          total += segs;
        }
      }
    }
    return total;
  }

  /// SMS still available today under the daily limit:
  /// daily limit − SMS sent today, never below zero. A limit of 0 or
  /// less means no limit has been set and returns null (unlimited).
  int? get todayRemaining {
    final limit = settings.dailyLimit;
    if (limit <= 0) return null;
    return max(0, limit - todaySentSms);
  }

  int get totalSent => allLogs.where((l) => l.status == DeliveryStatus.sent).length;
  int get totalFailed => allLogs.where((l) => l.status == DeliveryStatus.failed).length;

  List<DayStat> last7Days() {
    final today = DateTime.now().dateOnly;
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      var sent = 0;
      var failed = 0;
      for (final l in allLogs) {
        if (l.time == null || !l.time!.isSameDay(day)) continue;
        if (l.status == DeliveryStatus.sent) sent++;
        if (l.status == DeliveryStatus.failed) failed++;
      }
      return DayStat(day, sent, failed);
    });
  }

  // ───────────────────────── Queue ─────────────────────────
  Timer? _timer;
  DateTime? nextSendAt;

  Campaign? get activeCampaign => campaigns.where((c) => c.isActive).firstOrNull;

  /// The campaign the Queue screen should show: the active one, else the
  /// most recent one finished in this session.
  Campaign? focusCampaign;
  Campaign? get queueCampaign => activeCampaign ?? focusCampaign;

  Campaign startCampaign({
    required List<Contact> recipients,
    required String message,
    required int segments,
    required Audience audience,
  }) {
    final cid = _id('cmp');
    final c = Campaign(
      id: cid,
      message: message,
      createdAt: DateTime.now(),
      audience: audience,
      segments: segments,
      logs: [
        for (final r in recipients)
          DeliveryLog(id: _id('l'), campaignId: cid, contactId: r.id, name: r.name, phone: r.phone),
      ],
    );
    campaigns.insert(0, c);
    focusCampaign = c;
    _push((r) => r.insertCampaign(c));
    _log(ActivityEvent.campaignStarted, ['${c.total}']);
    notifyListeners();
    _scheduleNext(first: true);
    return c;
  }

  void pauseQueue({PauseReason? reason}) {
    final c = activeCampaign;
    if (c == null || c.state != CampaignState.running) return;
    _stopTimer();
    for (final l in c.logs) {
      if (l.status == DeliveryStatus.sending) l.status = DeliveryStatus.pending;
    }
    c
      ..state = CampaignState.paused
      ..pauseReason = reason;
    _push((r) => r.updateCampaign(c));
    notifyListeners();
  }

  void resumeQueue() {
    final c = activeCampaign;
    if (c == null || c.state != CampaignState.paused) return;
    c
      ..state = CampaignState.running
      ..pauseReason = null;
    _push((r) => r.updateCampaign(c));
    notifyListeners();
    _scheduleNext(first: true);
  }

  void stopQueue() {
    final c = activeCampaign;
    if (c == null) return;
    _stopTimer();
    for (final l in c.logs) {
      if (l.status == DeliveryStatus.pending || l.status == DeliveryStatus.sending) {
        l
          ..status = DeliveryStatus.failed
          ..reason = FailReason.stopped
          ..time = DateTime.now();
      }
    }
    c
      ..state = CampaignState.stopped
      ..finishedAt = DateTime.now();
    final stoppedAt = c.finishedAt!;
    _push((r) async {
      await r.stopLogs(c.id, stoppedAt);
      await r.updateCampaign(c);
    });
    _log(ActivityEvent.campaignStopped, ['${c.sent}', '${c.total - c.sent}']);
    notifyListeners();
  }

  /// Re-queues the failed numbers of [c] as a new campaign.
  Campaign? retryFailed(Campaign c) {
    final failed = c.logs.where((l) => l.status == DeliveryStatus.failed).toList();
    if (failed.isEmpty || activeCampaign != null) return null;
    final recipients = [
      for (final l in failed)
        contactById(l.contactId ?? '') ??
            Contact(id: l.contactId ?? _id('c'), name: l.name, phone: l.phone, createdAt: DateTime.now()),
    ];
    return startCampaign(
      recipients: recipients,
      message: c.message,
      segments: c.segments,
      audience: Audience(AudienceKind.retry, count: failed.length),
    );
  }

  void setDelay(int seconds) {
    settings.delaySeconds = seconds.clamp(1, 5);
    _push((r) => r.saveSettings(settings));
    notifyListeners();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    nextSendAt = null;
  }

  void _scheduleNext({bool first = false}) {
    _timer?.cancel();
    final c = activeCampaign;
    if (c == null || c.state != CampaignState.running) {
      nextSendAt = null;
      return;
    }
    final next = c.logs.where((l) => l.status == DeliveryStatus.pending).firstOrNull;
    if (next == null) {
      c
        ..state = CampaignState.completed
        ..finishedAt = DateTime.now();
      nextSendAt = null;
      _push((r) => r.updateCampaign(c));
      _log(ActivityEvent.campaignCompleted, ['${c.sent}', '${c.failed}']);
      notifyListeners();
      return;
    }
    if (!settings.testMode) {
      // Real mode: the panel only enqueues. The logs stay pending in
      // Supabase; the Android gateway phone sends them from its SIM and
      // the results come back through realtime (see _subscribeRealtime).
      nextSendAt = null;
      return;
    }
    if (!gateway.connected) {
      pauseQueue(reason: PauseReason.gateway);
      return;
    }
    final wait = first
        ? const Duration(milliseconds: 700)
        : settings.testMode
        ? const Duration(milliseconds: 420)
        : Duration(seconds: settings.delaySeconds);
    nextSendAt = DateTime.now().add(wait);
    notifyListeners();
    _timer = Timer(wait, () {
      next.status = DeliveryStatus.sending;
      notifyListeners();
      _timer = Timer(Duration(milliseconds: settings.testMode ? 320 : 1400), () {
        final fail = _rng.nextDouble() < .04;
        next
          ..status = fail ? DeliveryStatus.failed : DeliveryStatus.sent
          ..reason = fail ? SampleData.randomFailure(_rng) : null
          ..time = DateTime.now();
        _push((r) => r.updateLog(next));
        if (!fail && !settings.testMode) {
          settings.packageRemaining = max(0, settings.packageRemaining - c.segments);
          _push((r) => r.saveSettings(settings));
        }
        _scheduleNext();
      });
    });
  }

  // ───────────────────────── Settings ─────────────────────────
  void saveLimits({required int dailyLimit, required int packageRemaining}) {
    settings
      ..dailyLimit = dailyLimit
      ..packageRemaining = packageRemaining;
    _push((r) => r.saveSettings(settings));
    _log(ActivityEvent.limitsSaved, ['$dailyLimit', '$packageRemaining']);
    notifyListeners();
  }

  void saveSending({required int delaySeconds, required bool testMode, required int simSlot}) {
    settings
      ..delaySeconds = delaySeconds
      ..testMode = testMode
      ..simSlot = simSlot;
    _push((r) => r.saveSettings(settings));
    _log(ActivityEvent.sendingSaved, ['$delaySeconds', testMode ? 'ON' : 'OFF']);
    notifyListeners();
  }

  // ───────────────────────── Gateway ─────────────────────────
  bool _autoConnectBusy = false;

  /// Starts the real gateway with no user action when ALL of these hold:
  /// live mode on the Android gateway phone, signed in, Test Mode OFF,
  /// the gateway not already running, the user has not manually
  /// disconnected on this device ([GatewayIntent]), and the SEND_SMS
  /// permission is already granted. It never prompts and never toasts —
  /// without the permission, the Gateway screen's manual Connect runs
  /// the permission flow instead. Best-effort: any failure leaves the
  /// manual Connect path untouched.
  Future<void> _maybeAutoConnectGateway() async {
    if (_autoConnectBusy) return;
    _autoConnectBusy = true;
    try {
      if (!isLive || !SmsChannel.isSupported) return;
      if (Supabase.instance.client.auth.currentSession == null) return;
      if (settings.testMode) return;
      if (_gatewayService?.isRunning ?? false) return;
      if (!await GatewayIntent.load()) return;
      if (!await const SmsChannel().hasPermission()) return;
      await connectGateway();
    } catch (_) {
      // Auto-connect must never break startup or resume.
    } finally {
      _autoConnectBusy = false;
    }
  }

  /// Connects the gateway. On the Android phone itself (live mode) this
  /// really starts the [GatewayService] — it asks for the SMS permission
  /// and begins sending queued messages from this phone's SIM; false is
  /// returned when the permission is denied. Everywhere else the
  /// previous simulated connect is kept.
  Future<bool> connectGateway() async {
    if (isLive && SmsChannel.isSupported) {
      // One-tap flow: pressing Connect on the gateway phone IS the
      // intent to send for real, so leave Test Mode as part of the
      // same tap instead of sending the user to Settings first.
      if (settings.testMode) {
        saveSending(delaySeconds: settings.delaySeconds, testMode: false, simSlot: settings.simSlot);
      }
      final service = _gateway;
      if (service == null || !await service.start()) return false;
      // "Connected" must be confirmed, not assumed: the service only
      // confirms once its first heartbeat has actually landed in the
      // database, so every panel can see this phone as the gateway.
      // Unconfirmed reports failure here — the service keeps retrying
      // in the background and realtime flips the panel to connected
      // the moment the heartbeat lands.
      if (!service.confirmed) return false;
      // Remember the intent on this device: connect by default at launch.
      unawaited(GatewayIntent.save(true));
      gateway
        ..connected = true
        ..disconnectReason = null
        ..lastSeen = DateTime.now();
      if (service.deviceName != null) gateway.deviceName = service.deviceName!;
      if (service.deviceModel != null) gateway.model = service.deviceModel!;
      // The service's first heartbeat already read the real battery.
      final level = service.batteryLevel;
      if (level != null) {
        gateway
          ..battery = level
          ..charging = service.batteryCharging;
      }
      _log(ActivityEvent.gatewayConnected, [gateway.deviceName]);
      notifyListeners();
      return true;
    }
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    gateway
      ..connected = true
      ..disconnectReason = null
      ..lastSeen = DateTime.now()
      ..signal = 3 + _rng.nextInt(2)
      ..battery = 60 + _rng.nextInt(38);
    _push((r) => r.saveGateway(gateway));
    _log(ActivityEvent.gatewayConnected, [gateway.deviceName]);
    notifyListeners();
    return true;
  }

  Future<void> disconnectGateway({DisconnectReason reason = DisconnectReason.lostConnection}) async {
    // A manual disconnect is remembered on this device: the gateway
    // stays off across app restarts until the user connects again.
    if (reason == DisconnectReason.byUser) unawaited(GatewayIntent.save(false));
    if (isLive && SmsChannel.isSupported) {
      // Stops the polling loop and writes the disconnected heartbeat.
      await _gateway?.stop(reason: reason);
    }
    gateway
      ..connected = false
      ..disconnectReason = reason;
    _push((r) => r.saveGateway(gateway));
    _log(ActivityEvent.gatewayDisconnected);
    pauseQueue(reason: PauseReason.gateway);
    notifyListeners();
  }

  void regeneratePairCode() {
    final a = 100 + _rng.nextInt(900);
    final b = 100 + _rng.nextInt(900);
    gateway.pairCode = '$a-$b';
    _push((r) => r.saveGateway(gateway));
    notifyListeners();
  }

  /// Sends the Gateway screen's test SMS. The result carries the real
  /// outcome: in real mode the radio's verdict (and its failure reason,
  /// e.g. low balance) from this phone's own SIM; in test mode the old
  /// simulated outcome (`code: 'sendFailed'` when not connected).
  Future<SmsSendResult> sendTestSms(String phone) async {
    if (!settings.testMode) {
      // Real mode: an actual SMS from this phone's own SIM (Android
      // only) — no provider and no separate gateway device involved.
      if (!SmsChannel.isSupported) return const SmsSendResult(ok: false, code: 'sendFailed');
      const channel = SmsChannel();
      if (!await channel.requestPermission()) {
        return const SmsSendResult(ok: false, code: 'noPermission');
      }
      final res = await channel.sendResult(
        phone,
        'Paigham test SMS — your SMS panel is working.',
        simSlot: settings.simSlot,
      );
      if (!res.ok) return res;
      _log(ActivityEvent.testSms, [Phone.format(phone)]);
      notifyListeners();
      return res;
    }
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!gateway.connected) return const SmsSendResult(ok: false, code: 'sendFailed');
    _log(ActivityEvent.testSms, [Phone.format(phone)]);
    notifyListeners();
    return const SmsSendResult(ok: true, code: 'ok');
  }
}

/// Makes the store available to the widget tree; dependents rebuild on change.
class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({super.key, required AppStore store, required super.child}) : super(notifier: store);

  static AppStore watch(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppStore read(BuildContext context) => context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

extension StoreContext on BuildContext {
  /// Listen to the store (rebuild on change).
  AppStore get store => AppScope.watch(this);

  /// Read the store without listening (event handlers).
  AppStore get readStore => AppScope.read(this);
}
