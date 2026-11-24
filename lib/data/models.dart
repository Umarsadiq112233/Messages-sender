import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/phone.dart';

class Group {
  Group({required this.id, required this.name, required this.colorIndex, required this.createdAt});

  final String id;
  String name;
  final int colorIndex;
  final DateTime createdAt;

  Color get color => AppColors.groupColor(colorIndex);

  static const _icons = <IconData>[
    Icons.storefront_rounded,
    Icons.school_rounded,
    Icons.badge_rounded,
    Icons.local_shipping_rounded,
    Icons.star_rounded,
    Icons.groups_rounded,
    Icons.favorite_rounded,
  ];

  IconData get icon => _icons[colorIndex % _icons.length];
}

class Contact {
  Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
    this.groupId,
    this.note = '',
  });

  final String id;
  String name;

  /// 11 digits, e.g. 03001234567.
  String phone;
  String? groupId;
  String note;
  final DateTime createdAt;
}

enum DeliveryStatus { pending, sending, sent, failed }

class DeliveryLog {
  DeliveryLog({
    required this.id,
    required this.campaignId,
    required this.name,
    required this.phone,
    this.contactId,
    this.status = DeliveryStatus.pending,
    this.reason,
    this.time,
  });

  final String id;
  final String campaignId;
  final String? contactId;
  final String name;
  final String phone;
  DeliveryStatus status;
  FailReason? reason;
  DateTime? time;
}

enum CampaignState { running, paused, stopped, completed }

class Campaign {
  Campaign({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.audience,
    required this.segments,
    required this.logs,
    this.state = CampaignState.running,
    this.finishedAt,
  });

  final String id;
  final String message;
  final DateTime createdAt;

  /// "All Numbers", "Group: Customers", "Selected (12)".
  final Audience audience;
  final int segments;
  final List<DeliveryLog> logs;
  CampaignState state;
  DateTime? finishedAt;
  PauseReason? pauseReason;

  int _count(DeliveryStatus s) {
    var n = 0;
    for (final l in logs) {
      if (l.status == s) n++;
    }
    return n;
  }

  int get total => logs.length;
  int get sent => _count(DeliveryStatus.sent);
  int get failed => _count(DeliveryStatus.failed);
  int get pending => total - sent - failed;
  int get done => sent + failed;
  double get progress => total == 0 ? 0 : done / total;
  bool get isActive => state == CampaignState.running || state == CampaignState.paused;

  String get title {
    final flat = message.replaceAll('\n', ' ');
    return flat.length > 42 ? '${flat.substring(0, 42).trimRight()}…' : flat;
  }
}

enum ActivityKind { contactAdded, contactEdited, contactDeleted, imported, campaign, group, gateway, settings }

/// Every activity is stored as an event code + arguments so it can be shown
/// in whichever language is selected (see l10n/l10n_ext.dart).
enum ActivityEvent {
  contactAdded(ActivityKind.contactAdded),
  contactEdited(ActivityKind.contactEdited),
  contactDeleted(ActivityKind.contactDeleted),
  contactsDeleted(ActivityKind.contactDeleted),
  imported(ActivityKind.imported),
  groupCreated(ActivityKind.group),
  groupRenamed(ActivityKind.group),
  groupDeleted(ActivityKind.group),
  campaignStarted(ActivityKind.campaign),
  campaignSent(ActivityKind.campaign),
  campaignStopped(ActivityKind.campaign),
  campaignCompleted(ActivityKind.campaign),
  passwordChanged(ActivityKind.settings),
  limitsSaved(ActivityKind.settings),
  sendingSaved(ActivityKind.settings),
  gatewayConnected(ActivityKind.gateway),
  gatewayDisconnected(ActivityKind.gateway),
  testSms(ActivityKind.gateway);

  const ActivityEvent(this.kind);
  final ActivityKind kind;
}

class Activity {
  Activity(this.event, this.time, [this.args = const []]);

  final ActivityEvent event;
  final DateTime time;

  /// Event-specific values (names, counts…), already formatted as text.
  final List<String> args;

  ActivityKind get kind => event.kind;
}

enum FailReason { networkBusy, numberOff, timeout, lowBalance, notExist, stopped }

enum PauseReason { user, gateway }

enum DisconnectReason { lostConnection, byUser }

enum AudienceKind { all, group, selected, retry, test }

/// Who a campaign went to ("All Numbers", "Group: Customers"…).
class Audience {
  const Audience(this.kind, {this.name, this.count = 0});

  final AudienceKind kind;

  /// Group name for [AudienceKind.group].
  final String? name;
  final int count;
}

class AppSettings {
  AppSettings({this.dailyLimit = 100, this.packageRemaining = 2450, this.delaySeconds = 20, this.testMode = true});

  int dailyLimit;
  int packageRemaining;
  int delaySeconds;
  bool testMode;
}

class GatewayInfo {
  GatewayInfo({
    required this.connected,
    required this.deviceName,
    required this.model,
    required this.simNumber,
    required this.operator,
    required this.signal,
    required this.battery,
    required this.charging,
    required this.lastSeen,
    required this.pairCode,
    this.disconnectReason,
    this.appVersion = 'Gateway App v2.3',
  });

  bool connected;
  String deviceName;
  String model;
  String simNumber;
  String operator;

  /// 0‥4 bars.
  int signal;
  int battery;
  bool charging;
  DateTime lastSeen;
  String pairCode;
  DisconnectReason? disconnectReason;
  String appVersion;
}

class DayStat {
  const DayStat(this.day, this.sent, this.failed);
  final DateTime day;
  final int sent;
  final int failed;
  int get total => sent + failed;
}

enum ImportRowStatus { valid, duplicate, invalid }

enum ImportIssue { noNumber, inDatabase, repeated, badFormat }

class ImportRow {
  ImportRow({
    required this.raw,
    required this.name,
    required this.phone,
    required this.status,
    this.issue,
    this.phoneIssue,
  });

  final String raw;
  final String name;
  final String phone;
  final ImportRowStatus status;
  final ImportIssue? issue;
  final PhoneIssue? phoneIssue;
}

class ImportResult {
  const ImportResult({required this.total, required this.added, required this.duplicates, required this.invalid});
  final int total;
  final int added;
  final int duplicates;
  final int invalid;
}
