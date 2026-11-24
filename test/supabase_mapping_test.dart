// Every model must survive model → row → model unchanged, using exactly the
// column names in supabase/schema.sql.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:messege_sender/data/models.dart';
import 'package:messege_sender/data/remote/supabase_repo.dart';

void main() {
  final schema = File('supabase/schema.sql').readAsStringSync();
  void columnsExist(Map<String, dynamic> row) {
    for (final col in row.keys) {
      expect(RegExp('\\b$col\\b').hasMatch(schema), isTrue, reason: 'column "$col" missing in schema.sql');
    }
  }

  final t = DateTime(2026, 11, 24, 10, 30);

  test('contact', () {
    final c = Contact(id: 'c', name: 'Ali', phone: '03001234567', groupId: 'g', note: 'VIP', createdAt: t);
    final row = SupabaseRepo.contactToRow(c);
    columnsExist(row);
    final back = SupabaseRepo.contactFromRow(row);
    expect(
      [back.id, back.name, back.phone, back.groupId, back.note, back.createdAt],
      [c.id, c.name, c.phone, c.groupId, c.note, t],
    );
  });

  test('group', () {
    final g = Group(id: 'g', name: 'Customers', colorIndex: 2, createdAt: t);
    final row = SupabaseRepo.groupToRow(g);
    columnsExist(row);
    final back = SupabaseRepo.groupFromRow(row);
    expect([back.id, back.name, back.colorIndex, back.createdAt], [g.id, g.name, 2, t]);
  });

  test('campaign + logs', () {
    final log = DeliveryLog(
      id: 'l',
      campaignId: 'k',
      contactId: 'c',
      name: 'Ali',
      phone: '03001234567',
      status: DeliveryStatus.failed,
      reason: FailReason.numberOff,
      time: t,
    );
    final c = Campaign(
      id: 'k',
      message: 'Hi',
      createdAt: t,
      audience: const Audience(AudienceKind.group, name: 'VIP', count: 3),
      segments: 2,
      logs: [log],
      state: CampaignState.paused,
    )..pauseReason = PauseReason.gateway;
    final row = SupabaseRepo.campaignToRow(c);
    final logRow = SupabaseRepo.logToRow(log, 0);
    columnsExist(row);
    columnsExist(logRow);
    final back = SupabaseRepo.campaignFromRow(row, [SupabaseRepo.logFromRow(logRow)]);
    expect(back.state, CampaignState.paused);
    expect(back.pauseReason, PauseReason.gateway);
    expect([back.audience.kind, back.audience.name, back.audience.count], [AudienceKind.group, 'VIP', 3]);
    expect(
      [back.logs.single.status, back.logs.single.reason, back.logs.single.time],
      [DeliveryStatus.failed, FailReason.numberOff, t],
    );
  });

  test('a transient "sending" status is stored as pending', () {
    final l = DeliveryLog(id: 'l', campaignId: 'k', name: 'A', phone: '03001234567', status: DeliveryStatus.sending);
    expect(SupabaseRepo.logToRow(l, 0)['status'], 'pending');
  });

  test('every enum value is allowed by the schema checks', () {
    for (final v in [
      ...FailReason.values,
      ...PauseReason.values,
      ...DisconnectReason.values,
      ...AudienceKind.values,
      ...CampaignState.values,
    ]) {
      expect(schema.contains("'${v.name}'"), isTrue, reason: v.toString());
    }
  });
}
