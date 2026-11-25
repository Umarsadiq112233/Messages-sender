import 'package:supabase_flutter/supabase_flutter.dart';

import '../models.dart';

/// Everything the panel reads from / writes to Supabase.
/// Table layout: supabase/schema.sql.
class SupabaseRepo {
  SupabaseRepo(this.db);

  final SupabaseClient db;

  static const _page = 1000; // PostgREST returns at most 1000 rows per request

  // ───────────────────────── Load ─────────────────────────

  Future<List<Map<String, dynamic>>> _all(
    String table, {
    String columns = '*',
    String orderBy = 'created_at',
    bool ascending = false,
  }) async {
    final rows = <Map<String, dynamic>>[];
    for (var from = 0; ; from += _page) {
      final chunk = await db
          .from(table)
          .select(columns)
          .order(orderBy, ascending: ascending)
          .range(from, from + _page - 1);
      rows.addAll(chunk);
      if (chunk.length < _page) break;
    }
    return rows;
  }

  Future<List<Group>> groups() async => (await _all('groups', ascending: true)).map(groupFromRow).toList();

  Future<List<Contact>> contacts() async => (await _all('contacts')).map(contactFromRow).toList();

  Future<List<Campaign>> campaigns() async {
    final camps = await _all('campaigns');
    final logs = await _all('delivery_logs', orderBy: 'position', ascending: true);
    final byCampaign = <String, List<DeliveryLog>>{};
    for (final r in logs) {
      byCampaign.putIfAbsent(r['campaign_id'] as String, () => []).add(logFromRow(r));
    }
    return [for (final c in camps) campaignFromRow(c, byCampaign[c['id']] ?? [])];
  }

  Future<List<Activity>> activities({int limit = 60}) async {
    final rows = await db.from('activities').select().order('created_at', ascending: false).limit(limit);
    return rows.map(activityFromRow).whereType<Activity>().toList();
  }

  Future<Map<String, dynamic>?> settings() => db.from('app_settings').select().eq('id', 1).maybeSingle();

  Future<Map<String, dynamic>?> gateway() => db.from('gateway').select().eq('id', 1).maybeSingle();

  // ───────────────────────── Contacts & groups ─────────────────────────

  Future<void> insertContacts(List<Contact> list) async {
    for (var i = 0; i < list.length; i += 500) {
      await db.from('contacts').insert(list.skip(i).take(500).map(contactToRow).toList());
    }
  }

  Future<void> updateContact(Contact c) => db.from('contacts').update(contactToRow(c)).eq('id', c.id);

  Future<void> deleteContacts(List<String> ids) async {
    for (var i = 0; i < ids.length; i += 200) {
      await db.from('contacts').delete().inFilter('id', ids.skip(i).take(200).toList());
    }
  }

  Future<void> insertGroup(Group g) => db.from('groups').insert(groupToRow(g));

  Future<void> renameGroup(Group g) => db.from('groups').update({'name': g.name}).eq('id', g.id);

  /// Contacts in the group become "no group" (FK on delete set null).
  Future<void> deleteGroup(String id) => db.from('groups').delete().eq('id', id);

  // ───────────────────────── Campaigns & queue ─────────────────────────

  Future<void> insertCampaign(Campaign c) async {
    await db.from('campaigns').insert(campaignToRow(c));
    final rows = [for (final (i, l) in c.logs.indexed) logToRow(l, i)];
    for (var i = 0; i < rows.length; i += 500) {
      await db.from('delivery_logs').insert(rows.skip(i).take(500).toList());
    }
  }

  Future<void> updateCampaign(Campaign c) => db
      .from('campaigns')
      .update({
        'state': c.state.name,
        'pause_reason': c.pauseReason?.name,
        'finished_at': c.finishedAt?.toUtc().toIso8601String(),
      })
      .eq('id', c.id);

  Future<void> updateLog(DeliveryLog l) => db
      .from('delivery_logs')
      .update({
        'status': l.status == DeliveryStatus.sending ? 'pending' : l.status.name,
        'reason': l.reason?.name,
        'sent_at': l.time?.toUtc().toIso8601String(),
      })
      .eq('id', l.id);

  /// Marks every unfinished log of a stopped campaign as failed/stopped.
  Future<void> stopLogs(String campaignId, DateTime at) => db
      .from('delivery_logs')
      .update({'status': 'failed', 'reason': FailReason.stopped.name, 'sent_at': at.toUtc().toIso8601String()})
      .eq('campaign_id', campaignId)
      .inFilter('status', ['pending', 'sending']);

  // ─────────────────── Gateway phone (the sending side) ───────────────────

  /// Running campaigns (oldest first) carrying only their pending logs,
  /// in send order — the work list for the Android gateway phone.
  Future<List<Campaign>> runningCampaigns() async {
    final rows = await db.from('campaigns').select().eq('state', 'running').order('created_at', ascending: true);
    final result = <Campaign>[];
    for (final r in rows) {
      final logs = await db
          .from('delivery_logs')
          .select()
          .eq('campaign_id', r['id'] as String)
          .eq('status', 'pending')
          .order('position', ascending: true);
      result.add(campaignFromRow(r, logs.map(logFromRow).toList()));
    }
    return result;
  }

  Future<CampaignState?> campaignState(String campaignId) async {
    final row = await db.from('campaigns').select('state').eq('id', campaignId).maybeSingle();
    return row == null ? null : _enum(CampaignState.values, row['state']);
  }

  /// True while the campaign still has logs waiting or in flight.
  Future<bool> hasUnfinishedLogs(String campaignId) async {
    final rows = await db
        .from('delivery_logs')
        .select('id')
        .eq('campaign_id', campaignId)
        .inFilter('status', ['pending', 'sending'])
        .limit(1);
    return rows.isNotEmpty;
  }

  /// Claims a log for sending. Unlike [updateLog] this writes the real
  /// `sending` status — the gateway phone owns that transition.
  Future<void> markLogSending(String logId) =>
      db.from('delivery_logs').update({'status': 'sending'}).eq('id', logId);

  /// Logs left `sending` by a gateway that died mid-send become pending
  /// again (only for campaigns that are still running).
  Future<void> resetStaleSending() async {
    final rows = await db.from('campaigns').select('id').eq('state', 'running');
    if (rows.isEmpty) return;
    await db
        .from('delivery_logs')
        .update({'status': 'pending'})
        .inFilter('campaign_id', [for (final r in rows) r['id'] as String])
        .eq('status', 'sending');
  }

  Future<void> completeCampaign(String campaignId) => db
      .from('campaigns')
      .update({
        'state': 'completed',
        'pause_reason': null,
        'finished_at': DateTime.now().toUtc().toIso8601String(),
      })
      .eq('id', campaignId)
      .eq('state', 'running');

  /// Heartbeat from the gateway phone: liveness, device identity and
  /// the phone's real battery (read fresh by the phone on every beat).
  /// Pair code / signal / SIM number are deliberately not written —
  /// the phone does not genuinely report them, so no stale values.
  Future<void> gatewayHeartbeat({
    required bool connected,
    String? deviceName,
    String? model,
    String? operator,
    int? battery,
    bool? charging,
    DisconnectReason? disconnectReason,
  }) => db
      .from('gateway')
      .update({
        'connected': connected,
        'last_seen': DateTime.now().toUtc().toIso8601String(),
        if (deviceName != null) 'device_name': deviceName,
        if (model != null) 'model': model,
        if (operator != null && operator.isNotEmpty) 'operator': operator,
        if (battery != null) 'battery': battery,
        if (charging != null) 'charging': charging,
        'disconnect_reason': connected ? null : disconnectReason?.name,
      })
      .eq('id', 1);

  // ───────────────────────── Activity, settings, gateway ─────────────────────────

  Future<void> insertActivity(Activity a) => db.from('activities').insert({
    'event': a.event.name,
    'args': a.args,
    'created_at': a.time.toUtc().toIso8601String(),
  });

  Future<void> saveSettings(AppSettings s) async {
    final values = <String, dynamic>{
      'daily_limit': s.dailyLimit,
      'package_remaining': s.packageRemaining,
      'delay_seconds': s.delaySeconds,
      'test_mode': s.testMode,
      'sim_slot': s.simSlot,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    try {
      await db.from('app_settings').update(values).eq('id', 1);
    } catch (_) {
      // A database that hasn't run the sim_slot migration yet would
      // reject the whole update — retry without sim_slot so the other
      // settings still save exactly as before.
      values.remove('sim_slot');
      await db.from('app_settings').update(values).eq('id', 1);
    }
  }

  Future<void> saveGateway(GatewayInfo g) => db
      .from('gateway')
      .update({
        'connected': g.connected,
        'signal': g.signal,
        'battery': g.battery,
        'charging': g.charging,
        'last_seen': g.lastSeen.toUtc().toIso8601String(),
        'pair_code': g.pairCode,
        'disconnect_reason': g.disconnectReason?.name,
      })
      .eq('id', 1);

  // ───────────────────────── Row mapping ─────────────────────────

  static DateTime _t(Object? v) => DateTime.parse(v as String).toLocal();
  static DateTime? _tn(Object? v) => v == null ? null : _t(v);

  static T? _enum<T extends Enum>(List<T> values, Object? name) =>
      name == null ? null : values.where((e) => e.name == name).firstOrNull;

  static Group groupFromRow(Map<String, dynamic> r) => Group(
    id: r['id'] as String,
    name: r['name'] as String,
    colorIndex: (r['color_index'] as num?)?.toInt() ?? 0,
    createdAt: _t(r['created_at']),
  );

  static Map<String, dynamic> groupToRow(Group g) => {
    'id': g.id,
    'name': g.name,
    'color_index': g.colorIndex,
    'created_at': g.createdAt.toUtc().toIso8601String(),
  };

  static Contact contactFromRow(Map<String, dynamic> r) => Contact(
    id: r['id'] as String,
    name: r['name'] as String,
    phone: r['phone'] as String,
    groupId: r['group_id'] as String?,
    note: (r['note'] as String?) ?? '',
    createdAt: _t(r['created_at']),
  );

  static Map<String, dynamic> contactToRow(Contact c) => {
    'id': c.id,
    'name': c.name,
    'phone': c.phone,
    'group_id': c.groupId,
    'note': c.note,
    'created_at': c.createdAt.toUtc().toIso8601String(),
  };

  static DeliveryLog logFromRow(Map<String, dynamic> r) => DeliveryLog(
    id: r['id'] as String,
    campaignId: r['campaign_id'] as String,
    contactId: r['contact_id'] as String?,
    name: r['name'] as String,
    phone: r['phone'] as String,
    status: _enum(DeliveryStatus.values, r['status']) ?? DeliveryStatus.pending,
    reason: _enum(FailReason.values, r['reason']),
    time: _tn(r['sent_at']),
  );

  static Map<String, dynamic> logToRow(DeliveryLog l, int position) => {
    'id': l.id,
    'campaign_id': l.campaignId,
    'contact_id': l.contactId,
    'name': l.name,
    'phone': l.phone,
    'status': l.status == DeliveryStatus.sending ? 'pending' : l.status.name,
    'reason': l.reason?.name,
    'sent_at': l.time?.toUtc().toIso8601String(),
    'position': position,
  };

  static Campaign campaignFromRow(Map<String, dynamic> r, List<DeliveryLog> logs) {
    final c = Campaign(
      id: r['id'] as String,
      message: r['message'] as String,
      createdAt: _t(r['created_at']),
      audience: Audience(
        _enum(AudienceKind.values, r['audience_kind']) ?? AudienceKind.all,
        name: r['audience_name'] as String?,
        count: (r['audience_count'] as num?)?.toInt() ?? 0,
      ),
      segments: (r['segments'] as num?)?.toInt() ?? 1,
      logs: logs,
      state: _enum(CampaignState.values, r['state']) ?? CampaignState.completed,
      finishedAt: _tn(r['finished_at']),
    );
    c.pauseReason = _enum(PauseReason.values, r['pause_reason']);
    return c;
  }

  static Map<String, dynamic> campaignToRow(Campaign c) => {
    'id': c.id,
    'message': c.message,
    'audience_kind': c.audience.kind.name,
    'audience_name': c.audience.name,
    'audience_count': c.audience.count,
    'segments': c.segments,
    'state': c.state.name,
    'pause_reason': c.pauseReason?.name,
    'created_at': c.createdAt.toUtc().toIso8601String(),
    'finished_at': c.finishedAt?.toUtc().toIso8601String(),
  };

  static Activity? activityFromRow(Map<String, dynamic> r) {
    final event = _enum(ActivityEvent.values, r['event']);
    if (event == null) return null;
    return Activity(event, _t(r['created_at']), List<String>.from((r['args'] as List?) ?? const []));
  }

  static void applySettings(AppSettings s, Map<String, dynamic> r) {
    s
      ..dailyLimit = (r['daily_limit'] as num).toInt()
      ..packageRemaining = (r['package_remaining'] as num).toInt()
      // Older saved rows can still hold the retired slow default (20s);
      // clamp into the fast range so sending stays quick.
      ..delaySeconds = (r['delay_seconds'] as num).toInt().clamp(1, 5)
      ..testMode = r['test_mode'] as bool
      // Tolerant: a row from an un-migrated database has no sim_slot
      // key at all — that means "phone default".
      ..simSlot = (r['sim_slot'] as num?)?.toInt() ?? -1;
  }

  /// Applies a campaigns-row update (realtime) to a loaded campaign —
  /// e.g. the gateway phone marking it completed.
  static void applyCampaignUpdate(Campaign c, Map<String, dynamic> r) {
    final state = _enum(CampaignState.values, r['state']);
    if (state != null) c.state = state;
    c
      ..pauseReason = _enum(PauseReason.values, r['pause_reason'])
      ..finishedAt = _tn(r['finished_at']);
  }

  static void applyGateway(GatewayInfo g, Map<String, dynamic> r) {
    g
      ..connected = r['connected'] as bool
      ..deviceName = r['device_name'] as String
      ..model = r['model'] as String
      ..simNumber = r['sim_number'] as String
      ..operator = r['operator'] as String
      ..signal = (r['signal'] as num).toInt()
      ..battery = (r['battery'] as num).toInt()
      ..charging = r['charging'] as bool
      ..lastSeen = _t(r['last_seen'])
      ..pairCode = r['pair_code'] as String
      ..disconnectReason = _enum(DisconnectReason.values, r['disconnect_reason']);
  }
}
