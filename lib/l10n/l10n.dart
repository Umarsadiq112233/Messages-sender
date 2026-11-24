import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/formatters.dart';
import '../core/utils/phone.dart';
import '../data/models.dart';
import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

/// The three languages of the panel.
///
/// Texts live in `lib/l10n/*.arb`:
///   * app_ur_Latn.arb — Roman Urdu (default)
///   * app_en.arb      — English
///   * app_ur.arb      — Urdu (اردو, right-to-left)
enum AppLanguage {
  romanUrdu(
    Locale.fromSubtags(languageCode: 'ur', scriptCode: 'Latn'),
    'Roman Urdu',
    'Assalam-o-Alaikum! SMS bhejna ab aasan.',
    'en',
  ),
  english(Locale('en'), 'English', 'Hello! Sending SMS made easy.', 'en'),
  urdu(Locale('ur'), 'اردو', 'السلام علیکم! ایس ایم ایس بھیجنا آسان۔', 'ur');

  const AppLanguage(this.locale, this.nativeName, this.sample, this.dateLocale);

  final Locale locale;

  /// Name written in the language itself.
  final String nativeName;

  /// Short sample sentence shown on the language picker.
  final String sample;

  /// intl locale used for dates (month / weekday names).
  final String dateLocale;

  bool get isRtl => this == AppLanguage.urdu;

  static const fallback = AppLanguage.romanUrdu;
}

/// Holds and persists the selected language.
class LanguageController extends ValueNotifier<AppLanguage> {
  LanguageController._() : super(AppLanguage.fallback);

  static final LanguageController instance = LanguageController._();
  static const _prefsKey = 'app_language';

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      value = AppLanguage.values.where((l) => l.name == saved).firstOrNull ?? AppLanguage.fallback;
    } catch (_) {
      value = AppLanguage.fallback;
    }
    Fmt.locale = value.dateLocale;
  }

  Future<void> select(AppLanguage language) async {
    Fmt.locale = language.dateLocale;
    value = language;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, language.name);
    } catch (_) {
      // Not persisted (e.g. tests) — the choice still applies for this session.
    }
  }
}

/// Roman Urdu uses the `ur` language code, but Flutter's built-in widgets
/// (date picker, tooltips…) should stay English and left-to-right for it.
class LatinScriptFallbackDelegate<T> extends LocalizationsDelegate<T> {
  const LatinScriptFallbackDelegate(this.inner);

  final LocalizationsDelegate<T> inner;

  @override
  bool isSupported(Locale locale) => locale.scriptCode == 'Latn';

  @override
  Future<T> load(Locale locale) => inner.load(const Locale('en'));

  @override
  bool shouldReload(covariant LocalizationsDelegate<T> old) => false;

  @override
  Type get type => inner.type;
}

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Texts that depend on app data (codes, durations, dates).
extension AppLocalizationsX on AppLocalizations {
  String ago(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inSeconds < 45) return agoNow;
    if (diff.inMinutes < 60) return agoMinutes(diff.inMinutes);
    if (diff.inHours < 24) return agoHours(diff.inHours);
    if (diff.inDays == 1) return agoYesterday;
    if (diff.inDays < 7) return agoDays(diff.inDays);
    return Fmt.date(d);
  }

  String greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return greetMorning;
    if (h < 17) return greetDay;
    return greetEvening;
  }

  String duration(Duration d) {
    if (d.inHours > 0) return durHoursMinutes(d.inHours, d.inMinutes % 60);
    if (d.inMinutes > 0) return durMinutesSeconds(d.inMinutes, d.inSeconds % 60);
    return durSeconds(d.inSeconds);
  }

  String phoneIssue(PhoneIssue i) => switch (i.kind) {
    PhoneIssueKind.empty => phoneEmpty,
    PhoneIssueKind.prefix => phonePrefix,
    PhoneIssueKind.tooShort => phoneTooShort(i.digits),
    PhoneIssueKind.tooLong => phoneTooLong,
  };

  String failReason(FailReason r) => switch (r) {
    FailReason.networkBusy => failNetworkBusy,
    FailReason.numberOff => failNumberOff,
    FailReason.timeout => failTimeout,
    FailReason.lowBalance => failLowBalance,
    FailReason.notExist => failNotExist,
    FailReason.stopped => failStopped,
  };

  String audience(Audience a) => switch (a.kind) {
    AudienceKind.all => audAll,
    AudienceKind.group => audGroup(a.name ?? ''),
    AudienceKind.selected => audSelected(a.count),
    AudienceKind.retry => audRetry(a.count),
    AudienceKind.test => audTest,
  };

  String pauseReason(PauseReason r) => switch (r) {
    PauseReason.user => pauseUser,
    PauseReason.gateway => pauseGateway,
  };

  String disconnectReason(DisconnectReason r) => switch (r) {
    DisconnectReason.lostConnection => discLost,
    DisconnectReason.byUser => discByUser,
  };

  String importIssue(ImportRow r) {
    if (r.phoneIssue != null) return phoneIssue(r.phoneIssue!);
    return switch (r.issue) {
      ImportIssue.noNumber => impNoNumber,
      ImportIssue.inDatabase => impInDatabase,
      ImportIssue.repeated => impRepeated,
      ImportIssue.badFormat || null => '',
    };
  }

  String deliveryStatus(DeliveryStatus s) => switch (s) {
    DeliveryStatus.sent => statusSent,
    DeliveryStatus.failed => statusFailed,
    DeliveryStatus.pending => statusPending,
    DeliveryStatus.sending => statusSending,
  };

  String activityTitle(Activity a) {
    final n = a.args.isEmpty ? 0 : int.tryParse(a.args.first) ?? 0;
    return switch (a.event) {
      ActivityEvent.contactAdded => actContactAdded,
      ActivityEvent.contactEdited => actContactEdited,
      ActivityEvent.contactDeleted => actContactDeleted,
      ActivityEvent.contactsDeleted => actContactsDeleted(n),
      ActivityEvent.imported => actImported,
      ActivityEvent.groupCreated => actGroupCreated,
      ActivityEvent.groupRenamed => actGroupRenamed,
      ActivityEvent.groupDeleted => actGroupDeleted,
      ActivityEvent.campaignStarted => actCampaignStarted,
      ActivityEvent.campaignSent => actCampaignSent,
      ActivityEvent.campaignStopped => actCampaignStopped,
      ActivityEvent.campaignCompleted => actCampaignCompleted,
      ActivityEvent.passwordChanged => actPasswordChanged,
      ActivityEvent.limitsSaved => actLimitsSaved,
      ActivityEvent.sendingSaved => actSendingSaved,
      ActivityEvent.gatewayConnected => actGatewayConnected,
      ActivityEvent.gatewayDisconnected => actGatewayDisconnected,
      ActivityEvent.testSms => actTestSms,
    };
  }

  String activitySubtitle(Activity a) {
    String arg(int i) => i < a.args.length ? a.args[i] : '';
    int num(int i) => int.tryParse(arg(i)) ?? 0;
    return switch (a.event) {
      ActivityEvent.contactAdded || ActivityEvent.contactEdited => '${arg(0)} · ${arg(1)}',
      ActivityEvent.contactDeleted => arg(0),
      ActivityEvent.contactsDeleted => actContactsDeletedSub,
      ActivityEvent.imported => actImportedSub(num(0)) + (arg(1).isEmpty ? '' : ' · ${arg(1)}'),
      ActivityEvent.groupCreated || ActivityEvent.groupDeleted => arg(0),
      ActivityEvent.groupRenamed => '${arg(0)} → ${arg(1)}',
      ActivityEvent.campaignStarted => actCampaignStartedSub(num(0)),
      ActivityEvent.campaignSent => actCampaignSentSub(num(0), num(1)),
      ActivityEvent.campaignStopped => actCampaignStoppedSub(num(0), num(1)),
      ActivityEvent.campaignCompleted => actCampaignCompletedSub(num(0), num(1)),
      ActivityEvent.passwordChanged => actPasswordChangedSub,
      ActivityEvent.limitsSaved => actLimitsSavedSub(num(0), num(1)),
      ActivityEvent.sendingSaved => actSendingSavedSub(num(0), arg(1) == 'ON' ? on : off),
      ActivityEvent.gatewayConnected => actGatewayConnectedSub(arg(0)),
      ActivityEvent.gatewayDisconnected => actGatewayDisconnectedSub,
      ActivityEvent.testSms => arg(0),
    };
  }

  List<String> get groupSuggestionList => groupSuggestions.split('|');

  List<String> get splashSteps => [splashStep1, splashStep2, splashStep3, splashStep4];

  List<String> get passwordStrengths => [strength0, strength1, strength2, strength3, strength4];
}
