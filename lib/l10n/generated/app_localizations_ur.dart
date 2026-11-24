// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get cancel => 'منسوخ';

  @override
  String get save => 'محفوظ کریں';

  @override
  String get create => 'بنائیں';

  @override
  String get back => 'واپس';

  @override
  String get close => 'بند کریں';

  @override
  String get confirmDelete => 'ہاں، ڈیلیٹ کریں';

  @override
  String get keepIt => 'نہیں، رہنے دیں';

  @override
  String get edit => 'ترمیم';

  @override
  String get delete => 'ڈیلیٹ';

  @override
  String get rename => 'نام بدلیں';

  @override
  String get actions => 'اقدامات';

  @override
  String get copy => 'کاپی';

  @override
  String get clear => 'صاف کریں';

  @override
  String get searchHint => 'نام یا نمبر سے تلاش کریں…';

  @override
  String get decrease => 'کم کریں';

  @override
  String get increase => 'بڑھائیں';

  @override
  String get noGroup => 'بغیر گروپ';

  @override
  String get toastSuccess => 'کامیاب';

  @override
  String get toastError => 'مسئلہ';

  @override
  String get toastWarning => 'توجہ';

  @override
  String get toastInfo => 'معلومات';

  @override
  String get statusSent => 'بھیجا گیا';

  @override
  String get statusFailed => 'ناکام';

  @override
  String get statusPending => 'زیرِ التوا';

  @override
  String get statusSending => 'جا رہا ہے';

  @override
  String get on => 'آن';

  @override
  String get off => 'آف';

  @override
  String get sec => 'سیکنڈ';

  @override
  String get appTagline => 'ایک کلک — ہر نمبر تک پیغام';

  @override
  String get navDashboard => 'ڈیش بورڈ';

  @override
  String get navDatabase => 'ڈیٹا بیس';

  @override
  String get navGroups => 'گروپس';

  @override
  String get navSend => 'ایس ایم ایس بھیجیں';

  @override
  String get navSendShort => 'بھیجیں';

  @override
  String get navQueue => 'بھیجنے کی قطار';

  @override
  String get navReports => 'رپورٹس';

  @override
  String get navGateway => 'گیٹ وے';

  @override
  String get navSettings => 'سیٹنگز';

  @override
  String get navSectionMain => 'مین';

  @override
  String get navSectionMessaging => 'پیغامات';

  @override
  String get navSectionSystem => 'سسٹم';

  @override
  String get navAddNumber => 'نمبر شامل کریں';

  @override
  String get navBulkImport => 'بلک امپورٹ';

  @override
  String get navEditNumber => 'نمبر میں ترمیم';

  @override
  String get navHome => 'ہوم';

  @override
  String get navMore => 'مزید';

  @override
  String get moreTitle => 'مزید آپشنز';

  @override
  String get moreSubtitle => 'پینل کے باقی حصے یہاں سے کھولیں';

  @override
  String get logoutTitle => 'لاگ آؤٹ کرنا ہے؟';

  @override
  String get logoutMessage =>
      'آپ پینل سے باہر آ جائیں گے۔ دوبارہ اندر آنے کے لیے لاگ اِن کرنا ہوگا۔';

  @override
  String get logoutConfirm => 'ہاں، لاگ آؤٹ';

  @override
  String get logoutDone => 'آپ لاگ آؤٹ ہو گئے۔ پھر ملیں گے!';

  @override
  String get logout => 'لاگ آؤٹ';

  @override
  String get gatewayOnlineLower => 'گیٹ وے آن لائن';

  @override
  String get gatewayOfflineLower => 'گیٹ وے آف لائن';

  @override
  String get gatewayOnline => 'گیٹ وے آن لائن';

  @override
  String get gatewayOffline => 'گیٹ وے آف لائن';

  @override
  String get roleAdmin => 'ایڈمن';

  @override
  String get topSearchHint => 'نمبر یا نام تلاش کریں…';

  @override
  String livePaused(int done, int total) {
    return 'رکا ہوا $done/$total';
  }

  @override
  String liveSending(int done, int total) {
    return 'بھیج رہے ہیں $done/$total';
  }

  @override
  String get gatewayStatusTooltip => 'گیٹ وے / ڈیوائس کی حالت';

  @override
  String get account => 'اکاؤنٹ';

  @override
  String get adminSubtitle => 'admin · ایڈمنسٹریٹر';

  @override
  String get gatewayDevice => 'گیٹ وے / ڈیوائس';

  @override
  String get backTooltip => 'واپس';

  @override
  String get language => 'زبان';

  @override
  String get languageSub => 'پینل کس زبان میں دکھے، وہ منتخب کریں';

  @override
  String get languageChanged => 'زبان بدل دی گئی';

  @override
  String get languageDefault => 'ڈیفالٹ';

  @override
  String get splashStep1 => 'پینل تیار ہو رہا ہے…';

  @override
  String get splashStep2 => 'ڈیٹا بیس لوڈ ہو رہا ہے…';

  @override
  String get splashStep3 => 'گیٹ وے چیک ہو رہا ہے…';

  @override
  String get splashStep4 => 'بس ایک لمحہ…';

  @override
  String get agoNow => 'ابھی ابھی';

  @override
  String agoMinutes(int count) {
    return '$count منٹ پہلے';
  }

  @override
  String agoHours(int count) {
    return '$count گھنٹے پہلے';
  }

  @override
  String get agoYesterday => 'کل';

  @override
  String agoDays(int count) {
    return '$count دن پہلے';
  }

  @override
  String get greetMorning => 'صبح بخیر';

  @override
  String get greetDay => 'السلام علیکم';

  @override
  String get greetEvening => 'شام بخیر';

  @override
  String durHoursMinutes(int hours, int minutes) {
    return '$hours گھنٹہ $minutes منٹ';
  }

  @override
  String durMinutesSeconds(int minutes, int seconds) {
    return '$minutes منٹ $seconds سیکنڈ';
  }

  @override
  String durSeconds(int seconds) {
    return '$seconds سیکنڈ';
  }

  @override
  String get phoneEmpty => 'موبائل نمبر لکھنا ضروری ہے';

  @override
  String get phonePrefix => 'نمبر 03 سے شروع ہونا چاہیے';

  @override
  String phoneTooShort(int count) {
    return '11 ہندسے چاہئیں — ابھی $count ہیں';
  }

  @override
  String get phoneTooLong => 'نمبر 11 ہندسوں سے لمبا ہے';

  @override
  String get actContactAdded => 'نیا نمبر شامل ہوا';

  @override
  String get actContactEdited => 'نمبر اپ ڈیٹ ہوا';

  @override
  String get actContactDeleted => 'نمبر ڈیلیٹ ہوا';

  @override
  String actContactsDeleted(int count) {
    return '$count نمبر ڈیلیٹ ہوئے';
  }

  @override
  String get actContactsDeletedSub => 'ڈیٹا بیس سے ہٹا دیے گئے';

  @override
  String get actImported => 'بلک امپورٹ مکمل';

  @override
  String actImportedSub(int count) {
    return '$count نمبر شامل ہوئے';
  }

  @override
  String get actGroupCreated => 'نیا گروپ بنا';

  @override
  String get actGroupRenamed => 'گروپ کا نام بدلا';

  @override
  String get actGroupDeleted => 'گروپ ڈیلیٹ ہوا';

  @override
  String get actCampaignStarted => 'کیمپین شروع ہوئی';

  @override
  String actCampaignStartedSub(int count) {
    return '$count نمبروں کو جا رہی ہے';
  }

  @override
  String get actCampaignSent => 'کیمپین بھیجی گئی';

  @override
  String actCampaignSentSub(int sent, int failed) {
    return '$sent نمبروں کو گیا · $failed ناکام';
  }

  @override
  String get actCampaignStopped => 'کیمپین روک دی گئی';

  @override
  String actCampaignStoppedSub(int sent, int notSent) {
    return '$sent گئے · $notSent نہیں گئے';
  }

  @override
  String get actCampaignCompleted => 'کیمپین مکمل';

  @override
  String actCampaignCompletedSub(int sent, int failed) {
    return '$sent گئے · $failed ناکام';
  }

  @override
  String get actPasswordChanged => 'پاس ورڈ تبدیل ہوا';

  @override
  String get actPasswordChangedSub => 'اکاؤنٹ سیکیورٹی اپ ڈیٹ';

  @override
  String get actLimitsSaved => 'پیکج / حد اپ ڈیٹ';

  @override
  String actLimitsSavedSub(int limit, int left) {
    return 'روزانہ حد $limit · باقی $left';
  }

  @override
  String get actSendingSaved => 'سینڈنگ سیٹنگز اپ ڈیٹ';

  @override
  String actSendingSavedSub(int secs, String mode) {
    return 'وقفہ $secs سیکنڈ · ٹیسٹ موڈ $mode';
  }

  @override
  String get actGatewayConnected => 'گیٹ وے کنیکٹ ہوا';

  @override
  String actGatewayConnectedSub(String device) {
    return '$device آن لائن';
  }

  @override
  String get actGatewayDisconnected => 'گیٹ وے ڈس کنیکٹ ہوا';

  @override
  String get actGatewayDisconnectedSub => 'فون سے رابطہ ٹوٹ گیا';

  @override
  String get actTestSms => 'ٹیسٹ ایس ایم ایس بھیجا';

  @override
  String get failNetworkBusy => 'نیٹ ورک مصروف — دوبارہ کوشش';

  @override
  String get failNumberOff => 'نمبر بند ہے';

  @override
  String get failTimeout => 'ڈیلیوری ٹائم آؤٹ';

  @override
  String get failLowBalance => 'سم بیلنس کم ہے';

  @override
  String get failLowBalanceHint => 'بیلنس کم ہے — اپنی سم کا پیکیج/بیلنس چیک کریں';

  @override
  String get failNoPermission =>
      'ایس ایم ایس کی اجازت نہیں — Android سیٹنگز میں اس ایپ کو ایس ایم ایس کی اجازت دیں';

  @override
  String get failNoSim => 'منتخب سم نہیں ملی — Settings میں بھیجنے والی سم چیک کریں';

  @override
  String get sendingSim => 'بھیجنے والی سم';

  @override
  String get simPhoneDefault => 'فون کی ڈیفالٹ';

  @override
  String simSlot(int slot) {
    return 'سم $slot';
  }

  @override
  String simSlotCarrier(int slot, String carrier) {
    return 'سم $slot · $carrier';
  }

  @override
  String get simChoiceCaption => 'منتخب کریں کہ پیغامات کس سم سے جائیں گے۔ یہ Android گیٹ وے فون پر لاگو ہوتا ہے۔';

  @override
  String get loadSims => 'سمیں لوڈ کریں';

  @override
  String get failNotExist => 'نمبر موجود نہیں';

  @override
  String get failStopped => 'روک دیا گیا (اسٹاپ)';

  @override
  String get audAll => 'تمام نمبر';

  @override
  String audGroup(String name) {
    return 'گروپ: $name';
  }

  @override
  String audSelected(int count) {
    return 'منتخب ($count)';
  }

  @override
  String audRetry(int count) {
    return 'ناکام دوبارہ ($count)';
  }

  @override
  String get audTest => 'ٹیسٹ';

  @override
  String get pauseUser => 'آپ نے روکا';

  @override
  String get pauseGateway => 'گیٹ وے منقطع — فون چیک کریں';

  @override
  String get discLost => 'فون سے رابطہ ٹوٹ گیا (انٹرنیٹ یا ایپ بند ہے)';

  @override
  String get discByUser => 'آپ نے پینل سے ڈس کنیکٹ کیا';

  @override
  String get impNoNumber => 'نمبر نہیں ملا';

  @override
  String get impInDatabase => 'پہلے سے ڈیٹا بیس میں';

  @override
  String get impRepeated => 'فہرست میں دو بار';

  @override
  String get loginFeat1Title => 'بلک امپورٹ';

  @override
  String get loginFeat1Sub => 'ایکسل / CSV یا فہرست پیسٹ — سیکنڈوں میں';

  @override
  String get loginFeat2Title => 'لائیو سینڈنگ قطار';

  @override
  String get loginFeat2Sub => 'ہر ایس ایم ایس کی حالت سامنے';

  @override
  String get loginFeat3Title => 'رپورٹس اور ایکسپورٹ';

  @override
  String get loginFeat3Sub => 'ایک کلک میں ایکسل رپورٹ';

  @override
  String get loginHeadline => 'ایک کلک میں\nہزاروں تک پیغام۔';

  @override
  String get loginHeadlineSub =>
      'نمبروں کا ڈیٹا بیس، گروپس، لائیو سینڈنگ اور رپورٹس — سب ایک جگہ۔';

  @override
  String get usernameRequired => 'یوزر نیم لکھیں';

  @override
  String get passwordRequired => 'پاس ورڈ لکھیں';

  @override
  String loginWelcomeToast(String name) {
    return 'خوش آمدید، $name! پینل تیار ہے۔';
  }

  @override
  String get loginSuccess => 'لاگ اِن کامیاب';

  @override
  String get loginWrong => 'یوزر نیم یا پاس ورڈ غلط ہے۔ دوبارہ کوشش کریں۔';

  @override
  String get loginTitle => 'دوبارہ خوش آمدید';

  @override
  String loginSubtitle(String app) {
    return 'اپنے $app ایس ایم ایس پینل میں لاگ اِن کریں';
  }

  @override
  String get loginFailed => 'لاگ اِن نہیں ہوا';

  @override
  String get username => 'یوزر نیم';

  @override
  String get usernameHint => 'اپنا یوزر نیم لکھیں';

  @override
  String get password => 'پاس ورڈ';

  @override
  String get hidePassword => 'پاس ورڈ چھپائیں';

  @override
  String get showPassword => 'پاس ورڈ دکھائیں';

  @override
  String get forgotPassword => 'پاس ورڈ بھول گئے؟';

  @override
  String get loggingIn => 'لاگ اِن ہو رہا ہے…';

  @override
  String get login => 'لاگ اِن';

  @override
  String get forgotTitle => 'پاس ورڈ بھول گئے؟';

  @override
  String get forgotSubtitle =>
      'فکر نہ کریں — ری سیٹ کوڈ ایس ایم ایس پر آ جائے گا';

  @override
  String get registeredMobile => 'رجسٹرڈ موبائل نمبر';

  @override
  String get forgotAdminHint =>
      'یا ایڈمن (عمر) سے رابطہ کریں — وہ پاس ورڈ ری سیٹ کر سکتے ہیں۔';

  @override
  String get sendResetCode => 'ری سیٹ کوڈ بھیجیں';

  @override
  String get enterValidMobile => 'درست موبائل نمبر لکھیں (03XX-XXXXXXX)';

  @override
  String resetCodeSent(String phone) {
    return 'ری سیٹ کوڈ $phone پر بھیج دیا گیا (ڈیمو)۔';
  }

  @override
  String get codeSent => 'کوڈ بھیج دیا';

  @override
  String get demoLogin => 'ڈیمو لاگ اِن:';

  @override
  String get fill => 'بھریں';

  @override
  String greetingName(String greeting, String name) {
    return '$greeting، $name';
  }

  @override
  String dashSubtitle(String weekday, String date) {
    return '$weekday، $date — پورے پینل کا حال ایک نظر میں';
  }

  @override
  String get statTotalNumbers => 'کل نمبر';

  @override
  String statInGroups(int count) {
    return '$count گروپس میں';
  }

  @override
  String get statToday => 'آج بھیجے گئے ایس ایم ایس';

  @override
  String statDailyLimit(int today, int limit) {
    return '$today / $limit روزانہ حد';
  }

  @override
  String get statTotalSent => 'کل بھیجے گئے';

  @override
  String statSuccessRate(int rate) {
    return '$rate% کامیابی';
  }

  @override
  String get statNoFailures => 'کوئی ناکامی نہیں';

  @override
  String get statRetryFromReports => 'رپورٹس سے دوبارہ بھیجیں';

  @override
  String get quickAction => 'فوری کام';

  @override
  String get quickTitle => 'نیا ایس ایم ایس بھیجنا ہے؟';

  @override
  String get quickSubtitle => 'گروپ چنیں، پیغام لکھیں — ایک کلک میں سب تک۔';

  @override
  String get sendNewSms => 'نیا ایس ایم ایس بھیجیں';

  @override
  String get chartTitle => 'پچھلے 7 دن کے ایس ایم ایس';

  @override
  String chartSubtitleData(String amount) {
    return '$amount ایس ایم ایس کامیابی سے گئے';
  }

  @override
  String get chartSubtitleEmpty => 'روزانہ کا گراف یہاں نظر آئے گا';

  @override
  String get emptyNoSmsTitle => 'ابھی کوئی ایس ایم ایس نہیں گیا';

  @override
  String get emptyNoSmsMsg =>
      'پہلا ایس ایم ایس بھیجیں — پھر یہاں روزانہ کا گراف نظر آئے گا۔';

  @override
  String countSent(int count) {
    return '$count بھیجے';
  }

  @override
  String countFailed(int count) {
    return '$count ناکام';
  }

  @override
  String get today => 'آج';

  @override
  String get todayLower => 'آج';

  @override
  String get recentActivity => 'حالیہ سرگرمی';

  @override
  String get last5 => 'آخری 5 کام';

  @override
  String get noActivityTitle => 'ابھی کوئی سرگرمی نہیں';

  @override
  String get noActivityMsg =>
      'نمبر شامل کریں یا ایس ایم ایس بھیجیں — یہاں سب نظر آئے گا۔';

  @override
  String get packageLimit => 'پیکج اور حد';

  @override
  String get packageLimitSub => 'آج کی حد اور باقی ایس ایم ایس';

  @override
  String get sentToday => 'آج بھیجے';


  @override
  String get leftToday => 'آج باقی';

  @override
  String smsCount(int count) {
    return '$count ایس ایم ایس';
  }

  @override
  String get packageLeft => 'پیکج میں باقی';

  @override
  String get changeLimit => 'حد بدلیں';

  @override
  String get gatewayConnected => 'گیٹ وے کنیکٹڈ';

  @override
  String get gatewayNotConnected => 'گیٹ وے کنیکٹ نہیں';

  @override
  String deviceBattery(String device, int battery) {
    return '$device · $battery% بیٹری';
  }

  @override
  String get checkPhoneQueueStops => 'فون چیک کریں — قطار رک جائے گی';

  @override
  String get deleteConfirmTitle => 'کیا واقعی ڈیلیٹ کرنا ہے؟';

  @override
  String deleteConfirmMsg(String name, String phone) {
    return '\"$name\" ($phone) ڈیٹا بیس سے ہٹ جائے گا۔ یہ واپس نہیں آئے گا۔';
  }

  @override
  String deletedOne(String name) {
    return '$name ڈیٹا بیس سے ہٹا دیا گیا';
  }

  @override
  String get numberDeleted => 'نمبر ڈیلیٹ ہو گیا';

  @override
  String deleteManyTitle(int count) {
    return '$count نمبر ڈیلیٹ کرنے ہیں؟';
  }

  @override
  String deleteManyMsg(int count) {
    return 'منتخب $count نمبر ڈیٹا بیس سے ہمیشہ کے لیے ہٹ جائیں گے۔ یہ واپس نہیں آئیں گے۔';
  }

  @override
  String deleteManyConfirm(int count) {
    return 'ہاں، $count ڈیلیٹ کریں';
  }

  @override
  String deletedMany(int count) {
    return '$count نمبر ڈیٹا بیس سے ہٹا دیے گئے';
  }

  @override
  String get deletedManyTitle => 'ڈیلیٹ ہو گئے';

  @override
  String numbersSummary(String numbers, String groups) {
    return '$numbers نمبر · $groups گروپس';
  }

  @override
  String get importAction => 'امپورٹ';

  @override
  String get sort => 'ترتیب';

  @override
  String get sortNewest => 'نئے پہلے';

  @override
  String get sortOldest => 'پرانے پہلے';

  @override
  String get sortName => 'نام (A–Z)';

  @override
  String get colName => 'نام';

  @override
  String get colMobile => 'موبائل نمبر';

  @override
  String get colGroup => 'گروپ';

  @override
  String get colAdded => 'شامل ہونے کی تاریخ';

  @override
  String get colActions => 'اقدامات';

  @override
  String showingRange(int from, int to, int total) {
    return 'دکھا رہے ہیں $from–$to / $total';
  }

  @override
  String get group => 'گروپ';

  @override
  String get allGroups => 'تمام گروپس';

  @override
  String get dbEmptyTitle => 'ڈیٹا بیس ابھی خالی ہے';

  @override
  String get dbEmptyMsg =>
      'پہلا نمبر شامل کریں یا ایکسل / فہرست سے ایک ساتھ امپورٹ کریں۔';

  @override
  String get noResultsTitle => 'اس تلاش پر کوئی نمبر نہیں ملا';

  @override
  String get noResultsGroup => 'اس گروپ میں ابھی کوئی نمبر نہیں۔';

  @override
  String noResultsQuery(String query) {
    return '\"$query\" سے ملتا جلتا کوئی نام یا نمبر نہیں ہے۔';
  }

  @override
  String get clearFilter => 'فلٹر صاف کریں';

  @override
  String get all => 'سب';

  @override
  String numbersFound(int count) {
    return '$count نمبر ملے';
  }

  @override
  String loadMore(int count) {
    return 'مزید دکھائیں ($count باقی)';
  }

  @override
  String selectedCount(int count) {
    return '$count منتخب';
  }

  @override
  String get clearSelection => 'انتخاب ختم کریں';

  @override
  String get sendSmsShort => 'ایس ایم ایس بھیجیں';

  @override
  String get prev => 'پچھلا';

  @override
  String get next => 'اگلا';

  @override
  String dupWithName(String name) {
    return 'یہ نمبر پہلے سے ڈیٹا بیس میں ہے ($name)۔';
  }

  @override
  String get checkForm => 'فارم چیک کریں';

  @override
  String get notSaved => 'محفوظ نہیں ہوا';

  @override
  String get numberSaved => 'نمبر محفوظ ہو گیا';

  @override
  String get numberInfo => 'نمبر کی معلومات';

  @override
  String get onlyMobileRequired => 'صرف موبائل نمبر ضروری ہے';

  @override
  String addedHere(int count) {
    return '$count شامل ہوئے';
  }

  @override
  String get saveAndAddAnother => 'محفوظ کریں اور ایک اور';

  @override
  String get addAnotherShort => '+ ایک اور';

  @override
  String get newNumber => 'نیا نمبر';

  @override
  String get newNumberSub => 'ڈیٹا بیس میں ایک نمبر ڈالیں';

  @override
  String get addNumberTitle => 'نیا نمبر شامل کریں';

  @override
  String dbHasNumbers(int count) {
    return 'ڈیٹا بیس میں ابھی $count نمبر ہیں';
  }

  @override
  String get tip1 => 'نمبر 03 سے شروع ہو اور 11 ہندسوں کا ہو';

  @override
  String get tip2 => '+92 300… لکھیں تو بھی خود 0300… بن جائے گا';

  @override
  String get tip3 => 'گروپ چننے سے بعد میں گروپ کو ایس ایم ایس بھیجنا آسان';

  @override
  String get tips => 'مشورے';

  @override
  String get manyNumbersQ => 'بہت سارے نمبر ہیں؟';

  @override
  String get useBulkImport => 'بلک امپورٹ سے ایک ساتھ ڈالیں';

  @override
  String detailsUpdated(String name) {
    return '$name کی معلومات اپ ڈیٹ ہو گئیں';
  }

  @override
  String get changesSaved => 'تبدیلیاں محفوظ ہو گئیں';

  @override
  String get numberNotFound => 'نمبر نہیں ملا';

  @override
  String get maybeDeleted => 'یہ نمبر شاید ڈیلیٹ ہو چکا ہے۔';

  @override
  String get backToDb => 'ڈیٹا بیس پر واپس';

  @override
  String get editDetails => 'معلومات بدلیں';

  @override
  String get unsavedChanges => 'آپ نے کچھ تبدیلی کی ہے — محفوظ کرنا نہ بھولیں';

  @override
  String get editHint => 'کوئی بھی خانہ بدل کر محفوظ کریں';

  @override
  String get saveChanges => 'تبدیلیاں محفوظ کریں';

  @override
  String get numberDetails => 'اس نمبر کی تفصیل';

  @override
  String get dateAdded => 'شامل ہونے کی تاریخ';

  @override
  String get smsSentCount => 'کتنے ایس ایم ایس گئے';

  @override
  String get lastSms => 'آخری ایس ایم ایس';

  @override
  String get smsHistory => 'ایس ایم ایس ہسٹری';

  @override
  String lastNSms(int count) {
    return 'آخری $count ایس ایم ایس';
  }

  @override
  String get historyEmptyMsg =>
      'اس نمبر کو بھیجے گئے ایس ایم ایس یہاں نظر آئیں گے۔';

  @override
  String get dangerZone => 'خطرناک حصہ';

  @override
  String get removedForever => 'نمبر ہمیشہ کے لیے ہٹ جائے گا';

  @override
  String get deleteNumber => 'نمبر ڈیلیٹ کریں';

  @override
  String get noChanges => 'کوئی تبدیلی نہیں';

  @override
  String get dupNumber => 'یہ نمبر پہلے سے ڈیٹا بیس میں ہے';

  @override
  String get name => 'نام';

  @override
  String get nameHint => 'مثلاً: علی رضا';

  @override
  String get mobileNumber => 'موبائل نمبر';

  @override
  String get mobileHelper => '11 ہندسے — ڈیش خود لگ جائے گا';

  @override
  String savedUnder(String name, String group) {
    return '\"$name\" کے نام سے $group میں محفوظ ہے۔';
  }

  @override
  String get openThatNumber => 'وہ نمبر کھولیں';

  @override
  String get noteOptional => 'نوٹ (اختیاری)';

  @override
  String get noteHint => 'کوئی ضروری بات… (مثلاً: فیس باقی)';

  @override
  String get typeName => 'نام لکھیں…';

  @override
  String get livePreview => 'لائیو پیش منظر';

  @override
  String get previewSub => 'ڈیٹا بیس میں ایسے نظر آئے گا';

  @override
  String get chooseFile => 'ایکسل / CSV فائل چنیں';

  @override
  String fileRows(String file, int count) {
    return '$file سے $count قطاریں ملیں';
  }

  @override
  String get fileRead => 'فائل پڑھ لی';

  @override
  String get fileError =>
      'یہ فائل پڑھی نہیں جا سکی۔ CSV یا .xlsx فائل آزمائیں۔';

  @override
  String get fileProblem => 'فائل کا مسئلہ';

  @override
  String importedToDb(int count) {
    return '$count نمبر ڈیٹا بیس میں شامل ہو گئے';
  }

  @override
  String get importDone => 'امپورٹ مکمل';

  @override
  String get importBtn => 'امپورٹ کریں';

  @override
  String importBtnCount(int count) {
    return 'امپورٹ کریں ($count نمبر)';
  }

  @override
  String get importSub => 'ایک ساتھ بہت سارے نمبر ڈالیں';

  @override
  String get noValidNumbers => 'کوئی درست نمبر نہیں ملا — فہرست چیک کریں';

  @override
  String get importSubDesktop =>
      'فہرست پیسٹ کریں یا ایکسل / CSV فائل اپ لوڈ کریں — وقت بچائیں';

  @override
  String get whereFrom => 'نمبر کہاں سے؟';

  @override
  String get twoWays => 'دو طریقے — جو آسان لگے';

  @override
  String get listPaste => 'فہرست پیسٹ';

  @override
  String get fileUpload => 'فائل اپ لوڈ';

  @override
  String get whichGroup => 'یہ نمبر کس گروپ میں جائیں؟';

  @override
  String get newGroupShort => 'نیا گروپ';

  @override
  String get pasteHint =>
      'ہر لائن میں ایک نمبر…\n0300-1234567\nAli Raza, 0321-7654321\n+92 333 1112223';

  @override
  String get pasteTip => '\"نام، نمبر\" بھی لکھ سکتے ہیں';

  @override
  String get fillSample => 'نمونہ بھریں';

  @override
  String get dropHere => 'چھوڑ دیں — ہم پڑھ لیں گے';

  @override
  String get dropFileDesktop => 'ایکسل / CSV فائل یہاں چھوڑیں';

  @override
  String get fileFormatsHint =>
      '.xlsx، .csv یا .txt — پہلا کالم نام، دوسرا نمبر';

  @override
  String get reading => 'پڑھ رہے ہیں…';

  @override
  String get pickFile => 'فائل چنیں';

  @override
  String rowsCount(int count) {
    return '$count قطاریں';
  }

  @override
  String get removeFile => 'فائل ہٹائیں';

  @override
  String get preview => 'پیش منظر';

  @override
  String get previewEmptySub => 'نمبر ڈالتے ہی یہاں چیک ہو جائیں گے';

  @override
  String rowsFound(int count) {
    return '$count قطاریں ملیں';
  }

  @override
  String get nothingYet => 'ابھی کچھ نہیں';

  @override
  String get previewEmptyMsg =>
      'فہرست پیسٹ کریں یا فائل چنیں — ہر نمبر یہاں چیک ہوگا۔';

  @override
  String get found => 'ملے';

  @override
  String get valid => 'درست';

  @override
  String get duplicate => 'دہرا';

  @override
  String get badFormat => 'غلط فارمیٹ';

  @override
  String moreRows(int count) {
    return '…اور $count قطاریں';
  }

  @override
  String get step1 => 'نمبر دیں';

  @override
  String get step2 => 'پیش منظر چیک کریں';

  @override
  String get step3 => 'امپورٹ کریں';

  @override
  String get invalidShort => 'غلط';

  @override
  String get importComplete => 'امپورٹ مکمل!';

  @override
  String importSummary(int total, int added, int dup, int bad) {
    return '$total میں سے $added شامل ہوئے، $dup دہرے، $bad غلط';
  }

  @override
  String groupSuffix(String name) {
    return ' · گروپ: $name';
  }

  @override
  String get addedLabel => 'شامل ہوئے';

  @override
  String get importMore => 'مزید امپورٹ کریں';

  @override
  String get viewDatabase => 'ڈیٹا بیس دیکھیں';

  @override
  String groupDeleteTitle(String name) {
    return '\"$name\" ڈیلیٹ کرنا ہے؟';
  }

  @override
  String get groupDeleteEmpty =>
      'یہ گروپ خالی ہے۔ ڈیلیٹ کرنے کے بعد واپس نہیں آئے گا۔';

  @override
  String groupDeleteWithNumbers(int count) {
    return 'اس گروپ میں $count نمبر ہیں۔ نمبر ڈیلیٹ نہیں ہوں گے — وہ \"بغیر گروپ\" میں چلے جائیں گے۔ گروپ واپس نہیں آئے گا۔';
  }

  @override
  String get groupDeleteConfirm => 'ہاں، گروپ ڈیلیٹ کریں';

  @override
  String groupRemoved(String name) {
    return '\"$name\" ہٹا دیا گیا';
  }

  @override
  String groupRemovedMoved(String name, int count) {
    return '\"$name\" ہٹا دیا — $count نمبر \"بغیر گروپ\" میں';
  }

  @override
  String get groupDeleted => 'گروپ ڈیلیٹ ہو گیا';

  @override
  String get newGroup => 'نیا گروپ';

  @override
  String groupsSubtitle(int count) {
    return '$count گروپس · نمبروں کو گروپس میں رکھیں تاکہ ایس ایم ایس بھیجنا آسان ہو';
  }

  @override
  String get noGroupsTitle => 'ابھی کوئی گروپ نہیں';

  @override
  String get noGroupsMsg =>
      'گروپس بنائیں — مثلاً \"کسٹمرز\"، \"طلبہ\" — پھر پورے گروپ کو ایک کلک میں ایس ایم ایس بھیجیں۔';

  @override
  String get firstGroup => 'پہلا گروپ بنائیں';

  @override
  String get numbersWord => ' نمبر';

  @override
  String createdOn(String date) {
    return 'بنا: $date';
  }

  @override
  String get noNumbersYet => 'ابھی کوئی نمبر نہیں';

  @override
  String get smsShort => 'ایس ایم ایس';

  @override
  String get smsThisGroup => 'اس گروپ کو ایس ایم ایس بھیجیں';

  @override
  String ungroupedCount(int count) {
    return '$count نمبر کسی گروپ میں نہیں';
  }

  @override
  String get createNewGroup => 'نیا گروپ بنائیں';

  @override
  String get groupNameRequired => 'گروپ کا نام لکھیں';

  @override
  String groupNameExists(String name) {
    return '\"$name\" نام کا گروپ پہلے سے ہے';
  }

  @override
  String groupCreatedMsg(String name) {
    return '\"$name\" گروپ بن گیا';
  }

  @override
  String get groupCreated => 'گروپ بن گیا';

  @override
  String newNameMsg(String name) {
    return 'نیا نام: \"$name\"';
  }

  @override
  String get groupRenamed => 'گروپ کا نام بدل گیا';

  @override
  String get renameGroup => 'گروپ کا نام بدلیں';

  @override
  String get newGroupTitle => 'نیا گروپ';

  @override
  String currentName(String name) {
    return 'موجودہ نام: $name';
  }

  @override
  String get newGroupSub =>
      'نمبروں کو گروپ میں رکھیں — گروپ کو ایس ایم ایس بھیجنا آسان';

  @override
  String get groupName => 'گروپ کا نام';

  @override
  String get groupNameHint => 'مثلاً: کسٹمرز';

  @override
  String get groupSuggestions =>
      'کسٹمرز|طلبہ|وی آئی پی کلائنٹس|فیملی|ہول سیل|اسٹاف';

  @override
  String get tplSaleTitle => 'سیل / آفر';

  @override
  String get tplSale =>
      'السلام علیکم! ہماری خصوصی آفر شروع ہو گئی ہے — ہر چیز پر 20% رعایت۔ آج ہی تشریف لائیں۔ شکریہ!';

  @override
  String get tplPaymentTitle => 'ادائیگی کی یاد دہانی';

  @override
  String get tplPayment =>
      'یاد دہانی: براہِ کرم اپنی ادائیگی 25 تاریخ تک جمع کروا دیں۔ کسی سوال کے لیے اسی نمبر پر رابطہ کریں۔ شکریہ۔';

  @override
  String get tplClassTitle => 'کلاس / میٹنگ';

  @override
  String get tplClass =>
      'عزیز طالب علم، کل کی کلاس صبح 10 بجے ہوگی۔ وقت پر پہنچیں اور اسائنمنٹ ساتھ لائیں۔';

  @override
  String get tplEidTitle => 'عید مبارک';

  @override
  String get tplEid =>
      'عید مبارک! آپ اور آپ کے اہل خانہ کو دلی مبارکباد۔ اللہ آپ کو ڈھیروں خوشیاں دے۔';

  @override
  String get blockNoMessage => 'پہلے پیغام لکھیں';

  @override
  String get blockNoRecipients => 'کوئی وصول کنندہ نہیں — نمبر چنیں';

  @override
  String get blockGateway => 'گیٹ وے کنیکٹ نہیں — پہلے فون کنیکٹ کریں';

  @override
  String get blockRunning => 'پچھلی سینڈنگ ابھی چل رہی ہے — قطار دیکھیں';

  @override
  String get blockPackage => 'پیکج میں اتنے ایس ایم ایس باقی نہیں';

  @override
  String get sendConfirmTitle => 'بھیج دوں؟';

  @override
  String sendConfirmMsg(int count, int segments, int total) {
    return '$count نمبر، ہر ایک کو $segments ایس ایم ایس حصے — کل $total ایس ایم ایس۔';
  }

  @override
  String get sendConfirmTestNote =>
      '\n\nٹیسٹ موڈ آن ہے — اصل ایس ایم ایس نہیں جائیں گے، صرف نقل۔';

  @override
  String get yesSend => 'ہاں، بھیجیں';

  @override
  String get notNow => 'ابھی نہیں';

  @override
  String queueCreated(int count) {
    return '$count نمبروں کی قطار بن گئی — لائیو پیش رفت دیکھیں';
  }

  @override
  String get sendingStarted => 'بھیجنا شروع!';

  @override
  String get buildingQueue => 'قطار بن رہی ہے…';

  @override
  String get composeSubMobile => 'پیغام لکھیں اور ایک کلک میں بھیجیں';

  @override
  String get phonePreviewQ => 'فون پر کیسا لگے گا؟';

  @override
  String stickySummary(int count, int total) {
    return '$count نمبر · $total ایس ایم ایس';
  }

  @override
  String get composeSubDesktop =>
      'وصول کنندگان چنیں، پیغام لکھیں — ایک کلک میں سب تک';

  @override
  String get gatewayNotConnectedShort => 'گیٹ وے کنیکٹ نہیں';

  @override
  String get gatewayWarnMsg =>
      'اینڈرائیڈ فون سے رابطہ نہیں — ایس ایم ایس قطار رک جائے گی۔ پہلے گیٹ وے کنیکٹ کریں۔';

  @override
  String get openGateway => 'گیٹ وے کھولیں';

  @override
  String get modeSelected => 'منتخب';

  @override
  String countNumbers(int count) {
    return '$count نمبر';
  }

  @override
  String countGroups(int count) {
    return '$count گروپس';
  }

  @override
  String get whoToSend => 'کس کو بھیجنا ہے؟';

  @override
  String get threeWays => 'تین طریقے — سب، گروپ، یا منتخب';

  @override
  String get noGroupMade => 'ابھی کوئی گروپ نہیں بنا۔';

  @override
  String get makeGroup => 'گروپ بنائیں';

  @override
  String get noneSelectedTitle => 'ابھی کوئی نمبر منتخب نہیں';

  @override
  String get noneSelectedMsg =>
      'ڈیٹا بیس میں چیک باکس سے نمبر چنیں، پھر یہاں واپس آئیں۔';

  @override
  String get openDatabase => 'ڈیٹا بیس کھولیں';

  @override
  String get willGoToSuffix => ' نمبروں کو جائے گا';

  @override
  String get message => 'پیغام';

  @override
  String get smsRule =>
      'انگریزی: 160 = 1 ایس ایم ایس · اردو: 70 = 1 ایس ایم ایس';

  @override
  String get templates => 'ٹیمپلیٹس';

  @override
  String get messageHint =>
      'یہاں اپنا پیغام لکھیں…\n\nمثلاً: السلام علیکم! ہماری نئی آفر…';

  @override
  String get encUnicode => 'اردو / یونیکوڈ';

  @override
  String get encGsm => 'انگریزی (GSM)';

  @override
  String charsCount(int count) {
    return '$count حروف';
  }

  @override
  String charsLeft(int count) {
    return 'اس ایس ایم ایس میں $count حروف باقی';
  }

  @override
  String longMessage(int segments, int per) {
    return 'لمبا پیغام $segments حصوں میں جائے گا (ہر حصہ $per حروف) — خرچہ $segments گنا۔';
  }

  @override
  String get summary => 'خلاصہ';

  @override
  String get summarySub => 'بھیجنے سے پہلے ایک نظر';

  @override
  String get recipients => 'وصول کنندگان';

  @override
  String get perNumber => 'ہر نمبر کو';

  @override
  String segmentsValue(int count) {
    return '$count ایس ایم ایس حصے';
  }

  @override
  String get totalSms => 'کل ایس ایم ایس (اندازاً خرچہ)';

  @override
  String get packageLeftShort => 'پیکج باقی';

  @override
  String get estTime => 'اندازاً وقت';

  @override
  String estTimeValue(String duration, int secs) {
    return '~$duration ($secs سیکنڈ وقفہ)';
  }

  @override
  String dailyLimitWarn(int limit, int left) {
    return 'روزانہ حد $limit ہے — آج صرف $left باقی۔ باقی ایس ایم ایس حد کے بعد جائیں گے۔';
  }

  @override
  String get testModeOnNote =>
      'ٹیسٹ موڈ آن — اصل ایس ایم ایس نہیں جائیں گے (سیٹنگز سے بند کریں)۔';

  @override
  String get simLabel => 'ایس ایم ایس · سم 1';

  @override
  String get stopTitle => 'بھیجنا روکنا ہے؟';

  @override
  String stopMsg(int count) {
    return 'باقی $count نمبروں کو ایس ایم ایس نہیں جائے گا۔ یہ دوبارہ شروع نہیں ہوگی — پھر سے بھیجنا پڑے گا۔';
  }

  @override
  String get stopConfirm => 'ہاں، روکیں';

  @override
  String stoppedMsg(int count) {
    return '$count ایس ایم ایس گئے، باقی روک دیے گئے';
  }

  @override
  String get sendingStopped => 'بھیجنا روک دیا گیا';

  @override
  String get pausedHint => 'جب چاہیں دوبارہ شروع دبائیں';

  @override
  String get sendingPaused => 'بھیجنا روکا گیا';

  @override
  String get connectGatewayFirst => 'پہلے گیٹ وے کنیکٹ کریں';

  @override
  String get resumeFailed => 'دوبارہ شروع نہیں ہو سکا';

  @override
  String get sendingResumed => 'بھیجنا دوبارہ شروع';

  @override
  String get resume => 'دوبارہ شروع';

  @override
  String retryQueued(int count) {
    return '$count ناکام نمبر دوبارہ قطار میں';
  }

  @override
  String get retrying => 'دوبارہ بھیج رہے ہیں';

  @override
  String get queueSub => 'بھیجتے ہوئے لائیو دیکھیں کہ کیا ہو رہا ہے';

  @override
  String get queueEmptyTitle => 'ابھی کوئی سینڈنگ نہیں چل رہی';

  @override
  String get queueEmptyMsg =>
      'نیا ایس ایم ایس بھیجیں — یہاں ہر نمبر کی لائیو حالت نظر آئے گی۔';

  @override
  String get stop => 'روکیں';

  @override
  String get pause => 'وقفہ';

  @override
  String startedAgo(String audience, String ago) {
    return '$audience · شروع $ago';
  }

  @override
  String get newSmsShort => 'نیا ایس ایم ایس';

  @override
  String get queueStoppedTitle => 'سینڈنگ رکی ہوئی ہے';

  @override
  String get stateRunning => 'بھیج رہے ہیں';

  @override
  String get statePaused => 'رکا ہوا';

  @override
  String get stateStopped => 'روک دی گئی';

  @override
  String get stateCompleted => 'مکمل';

  @override
  String get testModeFast => 'ٹیسٹ موڈ · تیز نقل';

  @override
  String nextSmsIn(int secs) {
    return 'اگلا ایس ایم ایس $secs سیکنڈ میں';
  }

  @override
  String doneOfTotalNumbers(int done, int total) {
    return '$done / $total نمبر';
  }

  @override
  String get delayTitle => 'وقفہ';

  @override
  String get delaySub => 'سم بلاک ہونے سے بچنے کے لیے';

  @override
  String get afterEachSms => 'ہر ایس ایم ایس کے بعد';

  @override
  String get delayBest => 'بہترین: 20–30 سیکنڈ';

  @override
  String get delayLow => 'کم وقفہ — سم بلاک کا خطرہ';

  @override
  String get delayHigh => 'لمبا وقفہ — سینڈنگ سست';

  @override
  String get liveList => 'لائیو فہرست';

  @override
  String get liveListSub => 'جو گیا اس پر ٹک لگ جاتا ہے';

  @override
  String get filterEmpty => 'اس فلٹر میں کچھ نہیں';

  @override
  String moreNumbers(int count) {
    return '…اور $count نمبر';
  }

  @override
  String get doneTitle => 'سینڈنگ مکمل!';

  @override
  String doneSummary(int total, int sent, int failed) {
    return '$total میں سے $sent گئے، $failed ناکام';
  }

  @override
  String tookTime(String duration) {
    return ' · $duration لگا';
  }

  @override
  String get viewReport => 'رپورٹ دیکھیں';

  @override
  String retryFailedCount(int count) {
    return 'ناکام دوبارہ بھیجیں ($count)';
  }

  @override
  String get rangeWeek => 'پچھلے 7 دن';

  @override
  String get rangeMonth => 'پچھلے 30 دن';

  @override
  String get rangeAll => 'تمام وقت';

  @override
  String get rangeCustom => 'مرضی کی';

  @override
  String get pickRange => 'تاریخیں چنیں';

  @override
  String get apply => 'لاگو کریں';

  @override
  String get exportEmpty => 'اس فلٹر میں ایکسپورٹ کرنے کو کچھ نہیں';

  @override
  String get emptyReport => 'خالی رپورٹ';

  @override
  String get csvHeader => 'تاریخ,وقت,نام,نمبر,پیغام,حالت,ناکامی کی وجہ,کیمپین';

  @override
  String exportDone(String file, int count) {
    return '$file ($count قطاریں) — ایکسل میں کھلے گی۔ اب کلائنٹ کو بھیج دیں۔';
  }

  @override
  String get reportExported => 'رپورٹ ایکسپورٹ ہو گئی';

  @override
  String get exportFailed => 'ایکسپورٹ نہیں ہو سکا۔ دوبارہ کوشش کریں۔';

  @override
  String get exportBtn => 'ایکسپورٹ (ایکسل/CSV)';

  @override
  String get total => 'کل';

  @override
  String reportsMobileSub(String range, int count) {
    return '$range · $count ایس ایم ایس';
  }

  @override
  String get campaignDetail => 'کیمپین کی تفصیل';

  @override
  String get filter => 'فلٹر';

  @override
  String get reportsSub =>
      'پرانی سینڈنگ کی تفصیل — ایکسپورٹ کر کے کلائنٹ کو بھیجیں';

  @override
  String get allShort => 'سب';

  @override
  String get colDateTime => 'تاریخ اور وقت';

  @override
  String get colNumber => 'نمبر';

  @override
  String get colMessage => 'پیغام';

  @override
  String get colStatus => 'حالت';

  @override
  String get colFailReason => 'ناکامی کی وجہ';

  @override
  String rangeOfSms(int from, int to, int total) {
    return '$from–$to / $total ایس ایم ایس';
  }

  @override
  String pageOf(int page, int pages) {
    return 'صفحہ $page / $pages';
  }

  @override
  String get reportEmptyTitle => 'اس فلٹر میں کوئی ایس ایم ایس نہیں';

  @override
  String get reportEmptyMsg => 'تاریخیں یا حالت بدل کر دیکھیں۔';

  @override
  String get campaign => 'کیمپین';

  @override
  String get allCampaigns => 'تمام کیمپینز';

  @override
  String get filters => 'فلٹرز';

  @override
  String get filtersSub => 'رپورٹ کو محدود کریں';

  @override
  String get dateRange => 'تاریخیں';

  @override
  String get days7 => '7 دن';

  @override
  String get days30 => '30 دن';

  @override
  String get customEllipsis => 'مرضی کی…';

  @override
  String get status => 'حالت';

  @override
  String get customRange => 'مرضی کی تاریخیں…';

  @override
  String get campaignDates => 'کیمپین کی تاریخیں';

  @override
  String get campaignsHeader => 'کیمپینز — تفصیل کے لیے کلک کریں';

  @override
  String sentFailed(int sent, int failed) {
    return '$sent بھیجے · $failed ناکام';
  }

  @override
  String get closeDetail => 'تفصیل بند کریں';

  @override
  String smsPerNumber(int count) {
    return '$count ایس ایم ایس/نمبر';
  }

  @override
  String get resendFailed => 'ناکام دوبارہ بھیجیں';

  @override
  String get campaignTooltip => 'اس کیمپین کی تفصیل';

  @override
  String get secPackage => 'ایس ایم ایس پیکج اور روزانہ حد';

  @override
  String get secPackageSub => 'سم پیکج میں باقی ایس ایم ایس اور روزانہ بھیجنے کی حد';

  @override
  String get secSending => 'سینڈنگ';

  @override
  String get secSendingSub => 'پیغامات کا وقفہ، ٹیسٹ موڈ اور بھیجنے والی سم';

  @override
  String get secAccountSub => 'آپ کی پروفائل اور پاس ورڈ';

  @override
  String get secDemo => 'ڈیمو ڈیٹا';

  @override
  String get secDemoSub => 'پینل آزمانے کے لیے نمونہ ڈیٹا لوڈ یا صاف کریں';

  @override
  String get settingsSub => 'زبان، ایس ایم ایس پیکج، سینڈنگ اور اکاؤنٹ کی سیٹنگز';

  @override
  String get settingsSubDesktop =>
      'زبان، ایس ایم ایس پیکج، سینڈنگ اور اکاؤنٹ کی سیٹنگز — ہر حصہ الگ محفوظ ہوتا ہے';

  @override
  String limitsSavedMsg(int limit, int left) {
    return 'روزانہ حد $limit · پیکج میں $left ایس ایم ایس';
  }

  @override
  String get limitsSavedTitle => 'پیکج اور حد محفوظ ہو گئی';

  @override
  String get dailyLimit => 'روزانہ ایس ایم ایس حد';

  @override
  String get dailyLimitHint => 'ایپ ایک دن میں اس سے زیادہ ایس ایم ایس نہیں بھیجے گی۔ اس سے آپ کا سم پیکج اور بیلنس محفوظ رہتا ہے۔';

  @override
  String get packageRemaining => 'پیکج میں باقی ایس ایم ایس';

  @override
  String get packageHelper => 'آپ کے سم پیکج میں کتنے ایس ایم ایس باقی ہیں۔ جب بھی پیکج ری چارج یا تجدید کریں، یہاں اپ ڈیٹ کر دیں۔';

  @override
  String get sendingSavedTitle => 'سینڈنگ سیٹنگز محفوظ';

  @override
  String get defaultDelay => 'پیغامات کے درمیان وقفہ';

  @override
  String get best => 'بہترین';

  @override
  String get recommended => 'تجویز: 20–30 سیکنڈ';

  @override
  String testModeLabel(String mode) {
    return 'ٹیسٹ موڈ $mode';
  }

  @override
  String get testModeOnSub => 'آن — پیغامات صرف نقل ہوں گے، اصل ایس ایم ایس نہیں جائے گا';

  @override
  String get testModeOffSub => 'آف — اصل ایس ایم ایس گیٹ وے فون کی سم سے جائیں گے';

  @override
  String get oldPasswordRequired => 'پرانا پاس ورڈ لکھیں';

  @override
  String get min6 => 'کم از کم 6 حروف';

  @override
  String get passwordsMismatch => 'دونوں نئے پاس ورڈ ایک جیسے نہیں';

  @override
  String get oldPasswordWrong => 'پرانا پاس ورڈ غلط ہے';

  @override
  String get passwordNotChanged => 'پاس ورڈ نہیں بدلا';

  @override
  String get loginWithNew => 'اگلی بار نئے پاس ورڈ سے لاگ اِن کریں';

  @override
  String get passwordChanged => 'پاس ورڈ تبدیل ہو گیا';

  @override
  String get strength0 => 'بہت کمزور';

  @override
  String get strength1 => 'کمزور';

  @override
  String get strength2 => 'ٹھیک';

  @override
  String get strength3 => 'مضبوط';

  @override
  String get strength4 => 'بہت مضبوط';

  @override
  String get hide => 'چھپائیں';

  @override
  String get show => 'دکھائیں';

  @override
  String get usernameLine => 'یوزر نیم: admin · ایڈمنسٹریٹر';

  @override
  String get oldPassword => 'پرانا پاس ورڈ';

  @override
  String get newPassword => 'نیا پاس ورڈ';

  @override
  String get newPasswordAgain => 'نیا پاس ورڈ دوبارہ';

  @override
  String get changePassword => 'پاس ورڈ بدلیں';

  @override
  String get demoInfo =>
      'ابھی پینل نمونہ ڈیٹا پر چل رہا ہے۔ فیز 3 میں اصل ڈیٹا بیس (بیک اینڈ) لگے گا۔';

  @override
  String demoCounts(String numbers, String groups, String campaigns) {
    return '$numbers نمبر · $groups گروپس · $campaigns کیمپینز';
  }

  @override
  String get loadSample => 'نمونہ ڈیٹا لوڈ کریں';

  @override
  String get sampleLoadedMsg => 'نمونہ نمبر، گروپس اور کیمپینز واپس آ گئے';

  @override
  String get sampleData => 'نمونہ ڈیٹا';

  @override
  String get clearAll => 'سب صاف کریں';

  @override
  String get clearAllTitle => 'سارا ڈیٹا صاف کرنا ہے؟';

  @override
  String get clearAllMsg =>
      'سارے نمبر، گروپس اور رپورٹس ہٹ جائیں گے (خالی اسکرینیں دیکھنے کے لیے)۔ نمونہ ڈیٹا دوبارہ لوڈ کر سکتے ہیں۔';

  @override
  String get clearAllConfirm => 'ہاں، صاف کریں';

  @override
  String get clearedMsg => 'پینل اب خالی ہے — خالی حالتیں دیکھ سکتے ہیں';

  @override
  String get dataCleared => 'ڈیٹا صاف';

  @override
  String versionLine(String version) {
    return 'ورژن $version · براؤزر + موبائل';
  }

  @override
  String get gwConnectedMsg => 'فون آن لائن ہے — ایس ایم ایس بھیج سکتے ہیں';

  @override
  String get gwConnectedTitle => 'گیٹ وے کنیکٹ ہو گیا';

  @override
  String get gwDisconnectTitle => 'گیٹ وے ڈس کنیکٹ کرنا ہے؟';

  @override
  String get gwDisconnectMsg =>
      'فون سے رابطہ ختم ہو جائے گا اور چلتی قطار رک جائے گی۔ دوبارہ کنیکٹ کرنے کے لیے پیئرنگ کرنی ہوگی۔';

  @override
  String get gwDisconnectConfirm => 'ہاں، ڈس کنیکٹ';

  @override
  String get gwQueueStopsUntil => 'قطار رکی رہے گی جب تک دوبارہ کنیکٹ نہ ہو';

  @override
  String get gwDisconnected => 'گیٹ وے ڈس کنیکٹ';

  @override
  String get important => 'ضروری';

  @override
  String get keepPhoneOn =>
      'فون آن، چارج اور انٹرنیٹ پر رکھیں — ورنہ قطار رک جائے گی۔';

  @override
  String get gwSubMobile => 'جس فون/سم سے ایس ایم ایس جاتا ہے';

  @override
  String get gwSubDesktop =>
      'جس اینڈرائیڈ فون اور سم سے اصل ایس ایم ایس جاتا ہے، اس کی حالت';

  @override
  String get connecting => 'کنیکٹ ہو رہا ہے…';

  @override
  String get noPhoneConnection => 'فون سے رابطہ نہیں';

  @override
  String get sim => 'سم';

  @override
  String get signal => 'سگنل';

  @override
  String get battery => 'بیٹری';

  @override
  String get charging => ' · چارج ہو رہی';

  @override
  String get lastSeen => 'آخری بار';

  @override
  String get disconnect => 'ڈس کنیکٹ';

  @override
  String get reconnect => 'دوبارہ کنیکٹ کریں';

  @override
  String get guide1 => 'فون آن کریں اور چارجر لگائیں';

  @override
  String get guide2 => 'انٹرنیٹ (وائی فائی یا موبائل ڈیٹا) آن کریں';

  @override
  String guide3(String app) {
    return 'فون پر \"$app Gateway\" ایپ کھولیں';
  }

  @override
  String get guide4 => 'پیئرنگ QR اسکین کریں یا کوڈ ڈالیں';

  @override
  String get guide5 => 'سبز \"Connected\" کا انتظار کریں';

  @override
  String get guideTitle => 'دوبارہ کنیکٹ کیسے کریں؟';

  @override
  String get guideSub => 'ان مراحل پر عمل کریں';

  @override
  String get pairing => 'پیئرنگ';

  @override
  String get pairingSub =>
      'اینڈرائیڈ گیٹ وے ایپ میں یہ QR اسکین کریں یا کوڈ ڈالیں';

  @override
  String get orEnterCode => 'یا یہ کوڈ لکھیں';

  @override
  String get codeCopied => 'پیئرنگ کوڈ کاپی ہو گیا';

  @override
  String get newCode => 'نیا کوڈ بنائیں';

  @override
  String get oldCodeInvalid => 'پرانا کوڈ اب کام نہیں کرے گا';

  @override
  String get newPairingCode => 'نیا پیئرنگ کوڈ';

  @override
  String get checkNumber => 'نمبر چیک کریں';

  @override
  String testSent(String phone) {
    return 'ٹیسٹ ایس ایم ایس $phone پر بھیجا — فون چیک کریں';
  }

  @override
  String get testSentTitle => 'ٹیسٹ ایس ایم ایس گیا';

  @override
  String get testFailedMsg => 'گیٹ وے کنیکٹ نہیں — ٹیسٹ نہیں جا سکا';

  @override
  String get testFailed => 'ٹیسٹ ناکام';

  @override
  String get yourNumber => 'اپنا نمبر';

  @override
  String get sendingNow => 'بھیج رہے ہیں…';

  @override
  String get sendTestSms => 'ٹیسٹ ایس ایم ایس بھیجیں';

  @override
  String get testSms => 'ٹیسٹ ایس ایم ایس';

  @override
  String get testSmsSub => 'اپنے نمبر پر 1 ٹیسٹ ایس ایم ایس بھیج کر چیک کریں';

  @override
  String get loginNetwork =>
      'سرور سے رابطہ نہیں ہو سکا — انٹرنیٹ چیک کر کے دوبارہ کوشش کریں۔';

  @override
  String get syncFailed => 'سرور پر محفوظ نہیں ہوا — انٹرنیٹ چیک کریں';

  @override
  String get modeLive => 'لائیو · Supabase';

  @override
  String get modeDemo => 'ڈیمو موڈ';
}

/// The translations for Urdu, using the Latin script (`ur_Latn`).
class AppLocalizationsUrLatn extends AppLocalizationsUr {
  AppLocalizationsUrLatn() : super('ur_Latn');

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get create => 'Create';

  @override
  String get back => 'Back';

  @override
  String get close => 'Band karo';

  @override
  String get confirmDelete => 'Haan, delete karo';

  @override
  String get keepIt => 'Nahi, rehne do';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get rename => 'Rename';

  @override
  String get actions => 'Actions';

  @override
  String get copy => 'Copy';

  @override
  String get clear => 'Saaf karo';

  @override
  String get searchHint => 'Name ya number se dhoondo…';

  @override
  String get decrease => 'Kam karo';

  @override
  String get increase => 'Barhao';

  @override
  String get noGroup => 'Bina group';

  @override
  String get toastSuccess => 'Kamyab';

  @override
  String get toastError => 'Masla';

  @override
  String get toastWarning => 'Tawajjo';

  @override
  String get toastInfo => 'Maloomat';

  @override
  String get statusSent => 'Sent';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusSending => 'Ja raha hai';

  @override
  String get on => 'ON';

  @override
  String get off => 'OFF';

  @override
  String get sec => 'sec';

  @override
  String get appTagline => 'Ek click — har number tak paigham';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navDatabase => 'Database';

  @override
  String get navGroups => 'Groups';

  @override
  String get navSend => 'Send SMS';

  @override
  String get navSendShort => 'Send SMS';

  @override
  String get navQueue => 'Sending Queue';

  @override
  String get navReports => 'Reports';

  @override
  String get navGateway => 'Gateway';

  @override
  String get navSettings => 'Settings';

  @override
  String get navSectionMain => 'MAIN';

  @override
  String get navSectionMessaging => 'MESSAGING';

  @override
  String get navSectionSystem => 'SYSTEM';

  @override
  String get navAddNumber => 'Add Number';

  @override
  String get navBulkImport => 'Bulk Import';

  @override
  String get navEditNumber => 'Edit Number';

  @override
  String get navHome => 'Home';

  @override
  String get navMore => 'More';

  @override
  String get moreTitle => 'Aur options';

  @override
  String get moreSubtitle => 'Panel ke baqi hissay yahan se kholein';

  @override
  String get logoutTitle => 'Logout karna hai?';

  @override
  String get logoutMessage =>
      'Aap panel se bahar aa jayenge. Dobara andar aane ke liye login karna hoga.';

  @override
  String get logoutConfirm => 'Haan, logout';

  @override
  String get logoutDone => 'Aap logout ho gaye. Phir milenge!';

  @override
  String get logout => 'Logout';

  @override
  String get gatewayOnlineLower => 'Gateway online';

  @override
  String get gatewayOfflineLower => 'Gateway offline';

  @override
  String get gatewayOnline => 'Gateway Online';

  @override
  String get gatewayOffline => 'Gateway Offline';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get topSearchHint => 'Number ya naam dhoondo…';

  @override
  String livePaused(int done, int total) {
    return 'Paused $done/$total';
  }

  @override
  String liveSending(int done, int total) {
    return 'Sending $done/$total';
  }

  @override
  String get gatewayStatusTooltip => 'Gateway / Device status';

  @override
  String get account => 'Account';

  @override
  String get adminSubtitle => 'admin · Administrator';

  @override
  String get gatewayDevice => 'Gateway / Device';

  @override
  String get backTooltip => 'Wapas';

  @override
  String get language => 'Zaban / Language';

  @override
  String get languageSub => 'Panel kis zaban mein dikhe, woh chunein';

  @override
  String get languageChanged => 'Zaban badal di gayi';

  @override
  String get languageDefault => 'Default';

  @override
  String get splashStep1 => 'Panel tayyar ho raha hai…';

  @override
  String get splashStep2 => 'Database load ho raha hai…';

  @override
  String get splashStep3 => 'Gateway check ho raha hai…';

  @override
  String get splashStep4 => 'Bas aik lamha…';

  @override
  String get agoNow => 'abhi abhi';

  @override
  String agoMinutes(int count) {
    return '$count min pehle';
  }

  @override
  String agoHours(int count) {
    return '$count ghante pehle';
  }

  @override
  String get agoYesterday => 'kal';

  @override
  String agoDays(int count) {
    return '$count din pehle';
  }

  @override
  String get greetMorning => 'Subah bakhair';

  @override
  String get greetDay => 'Assalam-o-Alaikum';

  @override
  String get greetEvening => 'Shaam bakhair';

  @override
  String durHoursMinutes(int hours, int minutes) {
    return '$hours ghanta $minutes min';
  }

  @override
  String durMinutesSeconds(int minutes, int seconds) {
    return '$minutes min $seconds sec';
  }

  @override
  String durSeconds(int seconds) {
    return '$seconds sec';
  }

  @override
  String get phoneEmpty => 'Mobile number likhna zaroori hai';

  @override
  String get phonePrefix => 'Number 03 se shuru hona chahiye';

  @override
  String phoneTooShort(int count) {
    return '11 digits chahiye — abhi $count hain';
  }

  @override
  String get phoneTooLong => 'Number 11 digits se lamba hai';

  @override
  String get actContactAdded => 'Naya number add hua';

  @override
  String get actContactEdited => 'Number update hua';

  @override
  String get actContactDeleted => 'Number delete hua';

  @override
  String actContactsDeleted(int count) {
    return '$count numbers delete hue';
  }

  @override
  String get actContactsDeletedSub => 'Database se hata diye gaye';

  @override
  String get actImported => 'Bulk import mukammal';

  @override
  String actImportedSub(int count) {
    return '$count numbers add hue';
  }

  @override
  String get actGroupCreated => 'Naya group bana';

  @override
  String get actGroupRenamed => 'Group ka naam badla';

  @override
  String get actGroupDeleted => 'Group delete hua';

  @override
  String get actCampaignStarted => 'Campaign shuru hui';

  @override
  String actCampaignStartedSub(int count) {
    return '$count numbers ko ja rahi hai';
  }

  @override
  String get actCampaignSent => 'Campaign bheji gayi';

  @override
  String actCampaignSentSub(int sent, int failed) {
    return '$sent numbers ko gaya · $failed failed';
  }

  @override
  String get actCampaignStopped => 'Campaign rok di gayi';

  @override
  String actCampaignStoppedSub(int sent, int notSent) {
    return '$sent gaye · $notSent nahi gaye';
  }

  @override
  String get actCampaignCompleted => 'Campaign mukammal';

  @override
  String actCampaignCompletedSub(int sent, int failed) {
    return '$sent gaye · $failed failed';
  }

  @override
  String get actPasswordChanged => 'Password tabdeel hua';

  @override
  String get actPasswordChangedSub => 'Account security update';

  @override
  String get actLimitsSaved => 'Package / limit update';

  @override
  String actLimitsSavedSub(int limit, int left) {
    return 'Roz ki limit $limit · baqi $left';
  }

  @override
  String get actSendingSaved => 'Sending settings update';

  @override
  String actSendingSavedSub(int secs, String mode) {
    return 'Waqfa ${secs}s · Test mode $mode';
  }

  @override
  String get actGatewayConnected => 'Gateway connect hua';

  @override
  String actGatewayConnectedSub(String device) {
    return '$device online';
  }

  @override
  String get actGatewayDisconnected => 'Gateway disconnect hua';

  @override
  String get actGatewayDisconnectedSub => 'Phone se rabta toot gaya';

  @override
  String get actTestSms => 'Test SMS bheja';

  @override
  String get failNetworkBusy => 'Network busy — dobara koshish';

  @override
  String get failNumberOff => 'Number band hai';

  @override
  String get failTimeout => 'Delivery timeout';

  @override
  String get failLowBalance => 'SIM balance kam';

  @override
  String get failLowBalanceHint =>
      'Balance kam hai — apni SIM ka package/balance check karein';

  @override
  String get failNoPermission =>
      'SMS permission allowed nahi — Android settings mein is app ko SMS ki ijazat dein';

  @override
  String get failNoSim => 'Muntakhab SIM nahi mili — Settings mein Sending SIM check karein';

  @override
  String get sendingSim => 'Bhejne wali SIM';

  @override
  String get simPhoneDefault => 'Phone default';

  @override
  String simSlot(int slot) {
    return 'SIM $slot';
  }

  @override
  String simSlotCarrier(int slot, String carrier) {
    return 'SIM $slot · $carrier';
  }

  @override
  String get simChoiceCaption => 'Chunein ke messages kis SIM se jayenge. Ye Android gateway phone par apply hota hai.';

  @override
  String get loadSims => 'SIMs load karein';

  @override
  String get failNotExist => 'Number mojood nahi';

  @override
  String get failStopped => 'Rok diya gaya (Stop)';

  @override
  String get audAll => 'All Numbers';

  @override
  String audGroup(String name) {
    return 'Group: $name';
  }

  @override
  String audSelected(int count) {
    return 'Selected ($count)';
  }

  @override
  String audRetry(int count) {
    return 'Failed dobara ($count)';
  }

  @override
  String get audTest => 'Test';

  @override
  String get pauseUser => 'Aap ne pause kiya';

  @override
  String get pauseGateway => 'Gateway disconnected — phone check karein';

  @override
  String get discLost => 'Phone se rabta toot gaya (internet band ya app band)';

  @override
  String get discByUser => 'Aap ne panel se disconnect kiya';

  @override
  String get impNoNumber => 'Number nahi mila';

  @override
  String get impInDatabase => 'Pehle se database mein';

  @override
  String get impRepeated => 'List mein do baar';

  @override
  String get loginFeat1Title => 'Bulk import';

  @override
  String get loginFeat1Sub => 'Excel / CSV ya list paste — seconds mein';

  @override
  String get loginFeat2Title => 'Live sending queue';

  @override
  String get loginFeat2Sub => 'Har SMS ki halat saamne';

  @override
  String get loginFeat3Title => 'Reports & export';

  @override
  String get loginFeat3Sub => 'Ek click mein Excel report';

  @override
  String get loginHeadline => 'Ek click mein\nhazaron tak paigham.';

  @override
  String get loginHeadlineSub =>
      'Numbers ka database, groups, live sending aur reports — sab ek jagah.';

  @override
  String get usernameRequired => 'Username likhein';

  @override
  String get passwordRequired => 'Password likhein';

  @override
  String loginWelcomeToast(String name) {
    return 'Khush aamdeed, $name! Panel tayyar hai.';
  }

  @override
  String get loginSuccess => 'Login kamyab';

  @override
  String get loginWrong =>
      'Username ya password galat hai. Dobara koshish karein.';

  @override
  String get loginTitle => 'Wapas khush aamdeed';

  @override
  String loginSubtitle(String app) {
    return 'Apne $app SMS panel mein login karein';
  }

  @override
  String get loginFailed => 'Login nahi hua';

  @override
  String get username => 'Username';

  @override
  String get usernameHint => 'apna username likhein';

  @override
  String get password => 'Password';

  @override
  String get hidePassword => 'Password chhupao';

  @override
  String get showPassword => 'Password dikhao';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loggingIn => 'Login ho raha hai…';

  @override
  String get login => 'Login';

  @override
  String get forgotTitle => 'Password bhool gaye?';

  @override
  String get forgotSubtitle => 'Fikar na karein — reset code SMS par aa jayega';

  @override
  String get registeredMobile => 'Registered mobile number';

  @override
  String get forgotAdminHint =>
      'Ya admin (Umar) se rabta karein — woh password reset kar sakte hain.';

  @override
  String get sendResetCode => 'Reset code bhejo';

  @override
  String get enterValidMobile => 'Sahi mobile number likhein (03XX-XXXXXXX)';

  @override
  String resetCodeSent(String phone) {
    return 'Reset code $phone par bhej diya gaya (demo).';
  }

  @override
  String get codeSent => 'Code bhej diya';

  @override
  String get demoLogin => 'Demo login:';

  @override
  String get fill => 'Bharo';

  @override
  String greetingName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String dashSubtitle(String weekday, String date) {
    return '$weekday, $date — panel ka poora haal ek nazar mein';
  }

  @override
  String get statTotalNumbers => 'Total Numbers';

  @override
  String statInGroups(int count) {
    return '$count groups mein';
  }

  @override
  String get statToday => 'Aaj Bhejay Gaye SMS';

  @override
  String statDailyLimit(int today, int limit) {
    return '$today / $limit roz ki limit';
  }

  @override
  String get statTotalSent => 'Total Sent';

  @override
  String statSuccessRate(int rate) {
    return '$rate% kamyabi';
  }

  @override
  String get statNoFailures => 'Koi failure nahi';

  @override
  String get statRetryFromReports => 'Reports se dobara bhejein';

  @override
  String get quickAction => 'QUICK ACTION';

  @override
  String get quickTitle => 'Naya SMS bhejna hai?';

  @override
  String get quickSubtitle =>
      'Group chunein, message likhein — ek click mein sab tak.';

  @override
  String get sendNewSms => 'Naya SMS Bhejo';

  @override
  String get chartTitle => 'Pichle 7 din ke SMS';

  @override
  String chartSubtitleData(String amount) {
    return '$amount SMS kamyabi se gaye';
  }

  @override
  String get chartSubtitleEmpty => 'Roz ka graph yahan nazar aayega';

  @override
  String get emptyNoSmsTitle => 'Abhi koi SMS nahi gaya';

  @override
  String get emptyNoSmsMsg =>
      'Pehla SMS bhejein — phir yahan roz ka graph nazar aayega.';

  @override
  String countSent(int count) {
    return '$count sent';
  }

  @override
  String countFailed(int count) {
    return '$count failed';
  }

  @override
  String get today => 'Aaj';

  @override
  String get todayLower => 'aaj';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get last5 => 'Aakhri 5 kaam';

  @override
  String get noActivityTitle => 'Abhi koi activity nahi';

  @override
  String get noActivityMsg =>
      'Number add karein ya SMS bhejein — yahan sab nazar aayega.';

  @override
  String get packageLimit => 'Package & Limit';

  @override
  String get packageLimitSub => 'Aaj ki limit aur baqi SMS';

  @override
  String get sentToday => 'Aaj bheje';


  @override
  String get leftToday => 'Aaj baqi';

  @override
  String smsCount(int count) {
    return '$count SMS';
  }

  @override
  String get packageLeft => 'Package mein baqi';

  @override
  String get changeLimit => 'Limit badlo';

  @override
  String get gatewayConnected => 'Gateway Connected';

  @override
  String get gatewayNotConnected => 'Gateway Not Connected';

  @override
  String deviceBattery(String device, int battery) {
    return '$device · $battery% battery';
  }

  @override
  String get checkPhoneQueueStops => 'Phone check karein — queue ruk jayegi';

  @override
  String get deleteConfirmTitle => 'Pakka delete karna hai?';

  @override
  String deleteConfirmMsg(String name, String phone) {
    return '\"$name\" ($phone) database se hat jayega. Ye wapas nahi aayega.';
  }

  @override
  String deletedOne(String name) {
    return '$name database se hata diya gaya';
  }

  @override
  String get numberDeleted => 'Number delete ho gaya';

  @override
  String deleteManyTitle(int count) {
    return '$count numbers delete karne hain?';
  }

  @override
  String deleteManyMsg(int count) {
    return 'Chune hue $count numbers database se hamesha ke liye hat jayenge. Ye wapas nahi aayenge.';
  }

  @override
  String deleteManyConfirm(int count) {
    return 'Haan, $count delete karo';
  }

  @override
  String deletedMany(int count) {
    return '$count numbers database se hata diye gaye';
  }

  @override
  String get deletedManyTitle => 'Delete ho gaye';

  @override
  String numbersSummary(String numbers, String groups) {
    return '$numbers numbers · $groups groups';
  }

  @override
  String get importAction => 'Import';

  @override
  String get sort => 'Sort';

  @override
  String get sortNewest => 'Naye pehle';

  @override
  String get sortOldest => 'Purane pehle';

  @override
  String get sortName => 'Naam A–Z';

  @override
  String get colName => 'NAME';

  @override
  String get colMobile => 'MOBILE NUMBER';

  @override
  String get colGroup => 'GROUP';

  @override
  String get colAdded => 'ADD HONE KI DATE';

  @override
  String get colActions => 'ACTIONS';

  @override
  String showingRange(int from, int to, int total) {
    return 'Dikha rahe hain $from–$to / $total';
  }

  @override
  String get group => 'Group';

  @override
  String get allGroups => 'Saare groups';

  @override
  String get dbEmptyTitle => 'Database abhi khaali hai';

  @override
  String get dbEmptyMsg =>
      'Pehla number add karein ya Excel / list se ek saath import karein.';

  @override
  String get noResultsTitle => 'Is query par koi number nahi mila';

  @override
  String get noResultsGroup => 'Is group mein abhi koi number nahi.';

  @override
  String noResultsQuery(String query) {
    return '\"$query\" se milta julta koi naam ya number nahi hai.';
  }

  @override
  String get clearFilter => 'Filter saaf karo';

  @override
  String get all => 'Sab';

  @override
  String numbersFound(int count) {
    return '$count numbers mile';
  }

  @override
  String loadMore(int count) {
    return 'Load more ($count baqi)';
  }

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get clearSelection => 'Selection hatao';

  @override
  String get sendSmsShort => 'SMS bhejo';

  @override
  String get prev => 'Pichla';

  @override
  String get next => 'Agla';

  @override
  String dupWithName(String name) {
    return 'Ye number pehle se database mein hai ($name).';
  }

  @override
  String get checkForm => 'Form check karein';

  @override
  String get notSaved => 'Save nahi hua';

  @override
  String get numberSaved => 'Number save ho gaya';

  @override
  String get numberInfo => 'Number ki maloomat';

  @override
  String get onlyMobileRequired => 'Sirf mobile number zaroori hai';

  @override
  String addedHere(int count) {
    return '$count add hue';
  }

  @override
  String get saveAndAddAnother => 'Save & Add Another';

  @override
  String get addAnotherShort => '+ Aur';

  @override
  String get newNumber => 'Naya Number';

  @override
  String get newNumberSub => 'Database mein ek number daalein';

  @override
  String get addNumberTitle => 'Naya Number Add Karo';

  @override
  String dbHasNumbers(int count) {
    return 'Database mein abhi $count numbers hain';
  }

  @override
  String get tip1 => 'Number 03 se shuru ho aur 11 digits ka ho';

  @override
  String get tip2 => '+92 300… likhein to bhi khud 0300… ban jayega';

  @override
  String get tip3 => 'Group chunne se baad mein group ko SMS bhejna aasan';

  @override
  String get tips => 'Tips';

  @override
  String get manyNumbersQ => 'Bohat saare numbers hain?';

  @override
  String get useBulkImport => 'Bulk import se ek saath daalein';

  @override
  String detailsUpdated(String name) {
    return '$name ki maloomat update ho gayi';
  }

  @override
  String get changesSaved => 'Changes save ho gaye';

  @override
  String get numberNotFound => 'Number nahi mila';

  @override
  String get maybeDeleted => 'Ye number shayad delete ho chuka hai.';

  @override
  String get backToDb => 'Database par wapas';

  @override
  String get editDetails => 'Maloomat badlein';

  @override
  String get unsavedChanges =>
      'Aap ne kuch tabdeeli ki hai — save karna na bhoolein';

  @override
  String get editHint => 'Koi bhi field badal kar save karein';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get numberDetails => 'Is number ki tafseel';

  @override
  String get dateAdded => 'Add hone ki date';

  @override
  String get smsSentCount => 'Kitne SMS gaye';

  @override
  String get lastSms => 'Aakhri SMS';

  @override
  String get smsHistory => 'SMS history';

  @override
  String lastNSms(int count) {
    return 'Aakhri $count SMS';
  }

  @override
  String get historyEmptyMsg =>
      'Is number ko bheje gaye SMS yahan nazar aayenge.';

  @override
  String get dangerZone => 'Danger zone';

  @override
  String get removedForever => 'Number hamesha ke liye hat jayega';

  @override
  String get deleteNumber => 'Delete Number';

  @override
  String get noChanges => 'Koi tabdeeli nahi';

  @override
  String get dupNumber => 'Ye number pehle se database mein hai';

  @override
  String get name => 'Name';

  @override
  String get nameHint => 'Masalan: Ali Raza';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get mobileHelper => '11 digits — dash khud lag jayega';

  @override
  String savedUnder(String name, String group) {
    return '\"$name\" ke naam se $group mein save hai.';
  }

  @override
  String get openThatNumber => 'Woh number kholo';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get noteHint => 'Koi zaroori baat… (masalan: fee pending)';

  @override
  String get typeName => 'Naam likhein…';

  @override
  String get livePreview => 'Live preview';

  @override
  String get previewSub => 'Database mein aise nazar aayega';

  @override
  String get chooseFile => 'Excel / CSV file chunein';

  @override
  String fileRows(String file, int count) {
    return '$file se $count rows mili';
  }

  @override
  String get fileRead => 'File parh li';

  @override
  String get fileError =>
      'Ye file parhi nahi ja saki. CSV ya .xlsx file try karein.';

  @override
  String get fileProblem => 'File ka masla';

  @override
  String importedToDb(int count) {
    return '$count numbers database mein add ho gaye';
  }

  @override
  String get importDone => 'Import mukammal';

  @override
  String get importBtn => 'Import Karo';

  @override
  String importBtnCount(int count) {
    return 'Import Karo ($count numbers)';
  }

  @override
  String get importSub => 'Ek saath bohat saare numbers daalein';

  @override
  String get noValidNumbers => 'Koi theek number nahi mila — list check karein';

  @override
  String get importSubDesktop =>
      'List paste karein ya Excel / CSV file upload karein — waqt bachayein';

  @override
  String get whereFrom => 'Numbers kahan se?';

  @override
  String get twoWays => 'Do tareeqay — jo aasan lage';

  @override
  String get listPaste => 'List Paste';

  @override
  String get fileUpload => 'File Upload';

  @override
  String get whichGroup => 'Ye numbers kis group mein jayen?';

  @override
  String get newGroupShort => 'Naya group';

  @override
  String get pasteHint =>
      'Ek line mein ek number…\n0300-1234567\nAli Raza, 0321-7654321\n+92 333 1112223';

  @override
  String get pasteTip => '\"Naam, Number\" bhi likh sakte hain';

  @override
  String get fillSample => 'Sample bharo';

  @override
  String get dropHere => 'Chhor dein — hum parh lenge';

  @override
  String get dropFileDesktop => 'Excel / CSV file yahan chhorein';

  @override
  String get fileFormatsHint =>
      '.xlsx, .csv ya .txt — pehla column naam, doosra number';

  @override
  String get reading => 'Parh rahe hain…';

  @override
  String get pickFile => 'File chunein';

  @override
  String rowsCount(int count) {
    return '$count rows';
  }

  @override
  String get removeFile => 'File hatao';

  @override
  String get preview => 'Preview';

  @override
  String get previewEmptySub => 'Numbers daalte hi yahan check ho jayenge';

  @override
  String rowsFound(int count) {
    return '$count rows mili';
  }

  @override
  String get nothingYet => 'Abhi kuch nahi';

  @override
  String get previewEmptyMsg =>
      'List paste karein ya file chunein — har number yahan check hoga.';

  @override
  String get found => 'Mile';

  @override
  String get valid => 'Theek';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get badFormat => 'Galat format';

  @override
  String moreRows(int count) {
    return '…aur $count rows';
  }

  @override
  String get step1 => 'Numbers do';

  @override
  String get step2 => 'Preview check karo';

  @override
  String get step3 => 'Import karo';

  @override
  String get invalidShort => 'Galat';

  @override
  String get importComplete => 'Import mukammal!';

  @override
  String importSummary(int total, int added, int dup, int bad) {
    return '$total mein se $added add hue, $dup duplicate, $bad galat';
  }

  @override
  String groupSuffix(String name) {
    return ' · Group: $name';
  }

  @override
  String get addedLabel => 'Add hue';

  @override
  String get importMore => 'Aur import karo';

  @override
  String get viewDatabase => 'Database dekho';

  @override
  String groupDeleteTitle(String name) {
    return '\"$name\" delete karna hai?';
  }

  @override
  String get groupDeleteEmpty =>
      'Ye group khaali hai. Delete karne ke baad wapas nahi aayega.';

  @override
  String groupDeleteWithNumbers(int count) {
    return 'Is group mein $count numbers hain. Numbers delete NAHI honge — woh \"Bina group\" mein chale jayenge. Group wapas nahi aayega.';
  }

  @override
  String get groupDeleteConfirm => 'Haan, group delete karo';

  @override
  String groupRemoved(String name) {
    return '\"$name\" hata diya gaya';
  }

  @override
  String groupRemovedMoved(String name, int count) {
    return '\"$name\" hata diya — $count numbers \"Bina group\" mein';
  }

  @override
  String get groupDeleted => 'Group delete ho gaya';

  @override
  String get newGroup => 'New Group';

  @override
  String groupsSubtitle(int count) {
    return '$count groups · numbers ko groups mein rakhein taake SMS bhejna aasan ho';
  }

  @override
  String get noGroupsTitle => 'Abhi koi group nahi';

  @override
  String get noGroupsMsg =>
      'Groups banayein — masalan \"Customers\", \"Students\" — phir poore group ko ek click mein SMS bhejein.';

  @override
  String get firstGroup => 'Pehla group banao';

  @override
  String get numbersWord => ' numbers';

  @override
  String createdOn(String date) {
    return 'Bana: $date';
  }

  @override
  String get noNumbersYet => 'Abhi koi number nahi';

  @override
  String get smsShort => 'SMS';

  @override
  String get smsThisGroup => 'Is group ko SMS bhejo';

  @override
  String ungroupedCount(int count) {
    return '$count numbers kisi group mein nahi';
  }

  @override
  String get createNewGroup => 'Naya group banao';

  @override
  String get groupNameRequired => 'Group ka naam likhein';

  @override
  String groupNameExists(String name) {
    return '\"$name\" naam ka group pehle se hai';
  }

  @override
  String groupCreatedMsg(String name) {
    return '\"$name\" group ban gaya';
  }

  @override
  String get groupCreated => 'Group create ho gaya';

  @override
  String newNameMsg(String name) {
    return 'Naya naam: \"$name\"';
  }

  @override
  String get groupRenamed => 'Group rename ho gaya';

  @override
  String get renameGroup => 'Group rename karo';

  @override
  String get newGroupTitle => 'Naya Group';

  @override
  String currentName(String name) {
    return 'Abhi naam: $name';
  }

  @override
  String get newGroupSub =>
      'Numbers ko group mein rakhein — group ko SMS bhejna aasan';

  @override
  String get groupName => 'Group ka naam';

  @override
  String get groupNameHint => 'Masalan: Customers';

  @override
  String get groupSuggestions =>
      'Customers|Students|VIP Clients|Family|Wholesale|Staff';

  @override
  String get tplSaleTitle => 'Sale / Offer';

  @override
  String get tplSale =>
      'Assalam-o-Alaikum! Hamari special offer shuru ho gayi hai — har cheez par 20% off. Aaj hi tashreef layen. Shukriya!';

  @override
  String get tplPaymentTitle => 'Payment reminder';

  @override
  String get tplPayment =>
      'Reminder: Aap ki payment 25 tareekh tak jama karwa dein. Kisi sawal ke liye isi number par rabta karein. Shukriya.';

  @override
  String get tplClassTitle => 'Class / Meeting';

  @override
  String get tplClass =>
      'Dear Student, kal ki class subah 10 baje hogi. Waqt par pohanchein aur assignment saath layen.';

  @override
  String get tplEidTitle => 'Eid Mubarak (Urdu)';

  @override
  String get tplEid =>
      'عید مبارک! آپ اور آپ کے اہل خانہ کو دلی مبارکباد۔ اللہ آپ کو ڈھیروں خوشیاں دے۔';

  @override
  String get blockNoMessage => 'Pehle message likhein';

  @override
  String get blockNoRecipients => 'Koi recipient nahi — numbers chunein';

  @override
  String get blockGateway =>
      'Gateway connected nahi — pehle phone connect karein';

  @override
  String get blockRunning => 'Pehli sending abhi chal rahi hai — Queue dekhein';

  @override
  String get blockPackage => 'Package mein itne SMS baqi nahi';

  @override
  String get sendConfirmTitle => 'Send karun?';

  @override
  String sendConfirmMsg(int count, int segments, int total) {
    return '$count numbers, $segments SMS segment each — kul $total SMS.';
  }

  @override
  String get sendConfirmTestNote =>
      '\n\nTest mode ON hai — asal SMS nahi jayenge, sirf simulation.';

  @override
  String get yesSend => 'Haan, Send karo';

  @override
  String get notNow => 'Abhi nahi';

  @override
  String queueCreated(int count) {
    return '$count numbers ki queue ban gayi — live progress dekhein';
  }

  @override
  String get sendingStarted => 'Sending shuru!';

  @override
  String get buildingQueue => 'Queue ban rahi hai…';

  @override
  String get composeSubMobile => 'Message likhein aur ek click mein bhejein';

  @override
  String get phonePreviewQ => 'Phone par kaisa lagega?';

  @override
  String stickySummary(int count, int total) {
    return '$count numbers · $total SMS';
  }

  @override
  String get composeSubDesktop =>
      'Recipients chunein, message likhein — ek click mein sab tak';

  @override
  String get gatewayNotConnectedShort => 'Gateway connected nahi';

  @override
  String get gatewayWarnMsg =>
      'Android phone se rabta nahi — SMS queue ruk jayegi. Pehle gateway connect karein.';

  @override
  String get openGateway => 'Gateway kholo';

  @override
  String get modeSelected => 'Selected';

  @override
  String countNumbers(int count) {
    return '$count numbers';
  }

  @override
  String countGroups(int count) {
    return '$count groups';
  }

  @override
  String get whoToSend => 'Kisko bhejna hai?';

  @override
  String get threeWays => 'Teen tareeqay — sab, group, ya chune hue';

  @override
  String get noGroupMade => 'Abhi koi group nahi bana.';

  @override
  String get makeGroup => 'Group banao';

  @override
  String get noneSelectedTitle => 'Abhi koi number chuna nahi';

  @override
  String get noneSelectedMsg =>
      'Database mein checkbox se numbers chunein, phir yahan wapas aayen.';

  @override
  String get openDatabase => 'Database kholo';

  @override
  String get willGoToSuffix => ' numbers ko jayega';

  @override
  String get message => 'Message';

  @override
  String get smsRule => 'English: 160 = 1 SMS · Urdu: 70 = 1 SMS';

  @override
  String get templates => 'Templates';

  @override
  String get messageHint =>
      'Yahan apna message likhein…\n\nMasalan: Assalam-o-Alaikum! Hamari nayi offer…';

  @override
  String get encUnicode => 'Urdu / Unicode';

  @override
  String get encGsm => 'English (GSM)';

  @override
  String charsCount(int count) {
    return '$count characters';
  }

  @override
  String charsLeft(int count) {
    return '$count characters baqi is SMS mein';
  }

  @override
  String longMessage(int segments, int per) {
    return 'Lamba message $segments hisson mein jayega (har hissa $per characters) — kharcha ${segments}x.';
  }

  @override
  String get summary => 'Summary';

  @override
  String get summarySub => 'Bhejne se pehle ek nazar';

  @override
  String get recipients => 'Recipients';

  @override
  String get perNumber => 'Har number ko';

  @override
  String segmentsValue(int count) {
    return '$count SMS segment';
  }

  @override
  String get totalSms => 'Kul SMS (andazan kharcha)';

  @override
  String get packageLeftShort => 'Package baqi';

  @override
  String get estTime => 'Andazan waqt';

  @override
  String estTimeValue(String duration, int secs) {
    return '~$duration (${secs}s waqfa)';
  }

  @override
  String dailyLimitWarn(int limit, int left) {
    return 'Roz ki limit $limit hai — aaj sirf $left baqi. Baqi SMS limit ke baad jayenge.';
  }

  @override
  String get testModeOnNote =>
      'Test mode ON — asal SMS nahi jayenge (Settings se band karein).';

  @override
  String get simLabel => 'SMS · SIM 1';

  @override
  String get stopTitle => 'Sending rokni hai?';

  @override
  String stopMsg(int count) {
    return 'Baqi $count numbers ko SMS nahi jayega. Ye dobara shuru nahi hogi — phir se bhejna padega.';
  }

  @override
  String get stopConfirm => 'Haan, Stop karo';

  @override
  String stoppedMsg(int count) {
    return '$count SMS gaye, baqi rok diye gaye';
  }

  @override
  String get sendingStopped => 'Sending rok di gayi';

  @override
  String get pausedHint => 'Jab chahein Resume dabayein';

  @override
  String get sendingPaused => 'Sending pause';

  @override
  String get connectGatewayFirst => 'Pehle gateway connect karein';

  @override
  String get resumeFailed => 'Resume nahi ho saka';

  @override
  String get sendingResumed => 'Sending dobara shuru';

  @override
  String get resume => 'Resume';

  @override
  String retryQueued(int count) {
    return '$count failed numbers dobara queue mein';
  }

  @override
  String get retrying => 'Dobara bhej rahe hain';

  @override
  String get queueSub => 'Bhejte hue live dekhein ke kya ho raha hai';

  @override
  String get queueEmptyTitle => 'Abhi koi sending nahi chal rahi';

  @override
  String get queueEmptyMsg =>
      'Naya SMS bhejein — yahan har number ki live halat nazar aayegi.';

  @override
  String get stop => 'Stop';

  @override
  String get pause => 'Pause';

  @override
  String startedAgo(String audience, String ago) {
    return '$audience · shuru $ago';
  }

  @override
  String get newSmsShort => 'Naya SMS';

  @override
  String get queueStoppedTitle => 'Sending ruki hui hai';

  @override
  String get stateRunning => 'Bhej rahe hain';

  @override
  String get statePaused => 'Paused';

  @override
  String get stateStopped => 'Rok di gayi';

  @override
  String get stateCompleted => 'Mukammal';

  @override
  String get testModeFast => 'Test mode · tez simulation';

  @override
  String nextSmsIn(int secs) {
    return 'Agla SMS ${secs}s mein';
  }

  @override
  String doneOfTotalNumbers(int done, int total) {
    return '$done / $total numbers';
  }

  @override
  String get delayTitle => 'Waqfa (delay)';

  @override
  String get delaySub => 'SIM block hone se bachne ke liye';

  @override
  String get afterEachSms => 'Har SMS ke baad';

  @override
  String get delayBest => 'Behtareen: 20–30 sec';

  @override
  String get delayLow => 'Kam waqfa — SIM block ka khatra';

  @override
  String get delayHigh => 'Lamba waqfa — sending sust';

  @override
  String get liveList => 'Live list';

  @override
  String get liveListSub => 'Jo gaya woh tick ho jata hai';

  @override
  String get filterEmpty => 'Is filter mein kuch nahi';

  @override
  String moreNumbers(int count) {
    return '…aur $count numbers';
  }

  @override
  String get doneTitle => 'Sending mukammal!';

  @override
  String doneSummary(int total, int sent, int failed) {
    return '$total mein $sent gaye, $failed failed';
  }

  @override
  String tookTime(String duration) {
    return ' · $duration laga';
  }

  @override
  String get viewReport => 'Report dekho';

  @override
  String retryFailedCount(int count) {
    return 'Failed dobara bhejo ($count)';
  }

  @override
  String get rangeWeek => 'Pichle 7 din';

  @override
  String get rangeMonth => 'Pichle 30 din';

  @override
  String get rangeAll => 'Sab waqt';

  @override
  String get rangeCustom => 'Custom';

  @override
  String get pickRange => 'Date range chunein';

  @override
  String get apply => 'Lagao';

  @override
  String get exportEmpty => 'Is filter mein export karne ko kuch nahi';

  @override
  String get emptyReport => 'Khaali report';

  @override
  String get csvHeader =>
      'Date,Time,Name,Number,Message,Status,Failed reason,Campaign';

  @override
  String exportDone(String file, int count) {
    return '$file ($count rows) — Excel mein khulegi. Ab client ko bhej dein.';
  }

  @override
  String get reportExported => 'Report export ho gayi';

  @override
  String get exportFailed => 'Export nahi ho saka. Dobara koshish karein.';

  @override
  String get exportBtn => 'Export (Excel/CSV)';

  @override
  String get total => 'Total';

  @override
  String reportsMobileSub(String range, int count) {
    return '$range · $count SMS';
  }

  @override
  String get campaignDetail => 'Campaign detail';

  @override
  String get filter => 'Filter';

  @override
  String get reportsSub =>
      'Purani sending ki tafseel — export karke client ko bhejein';

  @override
  String get allShort => 'All';

  @override
  String get colDateTime => 'DATE & TIME';

  @override
  String get colNumber => 'NUMBER';

  @override
  String get colMessage => 'MESSAGE';

  @override
  String get colStatus => 'STATUS';

  @override
  String get colFailReason => 'FAILED KI WAJAH';

  @override
  String rangeOfSms(int from, int to, int total) {
    return '$from–$to / $total SMS';
  }

  @override
  String pageOf(int page, int pages) {
    return 'Page $page / $pages';
  }

  @override
  String get reportEmptyTitle => 'Is filter mein koi SMS nahi';

  @override
  String get reportEmptyMsg => 'Date range ya status badal kar dekhein.';

  @override
  String get campaign => 'Campaign';

  @override
  String get allCampaigns => 'Saari campaigns';

  @override
  String get filters => 'Filters';

  @override
  String get filtersSub => 'Report ko chhota karein';

  @override
  String get dateRange => 'Date range';

  @override
  String get days7 => '7 din';

  @override
  String get days30 => '30 din';

  @override
  String get customEllipsis => 'Custom…';

  @override
  String get status => 'Status';

  @override
  String get customRange => 'Custom range…';

  @override
  String get campaignDates => 'Campaign ki dates';

  @override
  String get campaignsHeader => 'CAMPAIGNS — detail ke liye click karein';

  @override
  String sentFailed(int sent, int failed) {
    return '$sent sent · $failed failed';
  }

  @override
  String get closeDetail => 'Detail band karo';

  @override
  String smsPerNumber(int count) {
    return '$count SMS/number';
  }

  @override
  String get resendFailed => 'Failed dobara bhejo';

  @override
  String get campaignTooltip => 'Is campaign ki detail';

  @override
  String get secPackage => 'SMS Package aur Roz ki Limit';

  @override
  String get secPackageSub => 'SIM package mein baqi SMS aur roz ki sending limit';

  @override
  String get secSending => 'Sending';

  @override
  String get secSendingSub => 'Message ka waqfa, test mode aur bhejne wali SIM';

  @override
  String get secAccountSub => 'Aap ki profile aur password';

  @override
  String get secDemo => 'Demo data';

  @override
  String get secDemoSub => 'Panel try karne ke liye sample data load ya clear karein';

  @override
  String get settingsSub => 'Zaban, SMS package, sending aur account ki settings';

  @override
  String get settingsSubDesktop =>
      'Zaban, SMS package, sending aur account ki settings — har section alag save hota hai';

  @override
  String limitsSavedMsg(int limit, int left) {
    return 'Roz ki limit $limit · package mein $left SMS';
  }

  @override
  String get limitsSavedTitle => 'Package aur limit save ho gayi';

  @override
  String get dailyLimit => 'Roz ki SMS Limit';

  @override
  String get dailyLimitHint => 'App aik din mein is se zyada SMS nahi bhejegi. Is se aap ka SIM package aur balance mehfooz rehta hai.';

  @override
  String get packageRemaining => 'Package mein Baqi SMS';

  @override
  String get packageHelper =>
      'Aap ke SIM package mein kitne SMS baqi hain. Jab bhi package recharge ya renew karein, yahan update kar dein.';

  @override
  String get sendingSavedTitle => 'Sending settings save';

  @override
  String get defaultDelay => 'Messages ke darmiyan waqfa';

  @override
  String get best => 'Behtareen';

  @override
  String get recommended => 'Tajweez: 20–30 sec';

  @override
  String testModeLabel(String mode) {
    return 'Test mode $mode';
  }

  @override
  String get testModeOnSub => 'On — messages sirf simulate honge, asal SMS nahi jayega';

  @override
  String get testModeOffSub => 'Off — asal SMS gateway phone ki SIM se jayenge';

  @override
  String get oldPasswordRequired => 'Purana password likhein';

  @override
  String get min6 => 'Kam az kam 6 characters';

  @override
  String get passwordsMismatch => 'Dono naye password ek jaise nahi';

  @override
  String get oldPasswordWrong => 'Purana password galat hai';

  @override
  String get passwordNotChanged => 'Password nahi badla';

  @override
  String get loginWithNew => 'Agli dafa naye password se login karein';

  @override
  String get passwordChanged => 'Password tabdeel ho gaya';

  @override
  String get strength0 => 'Bohat kamzor';

  @override
  String get strength1 => 'Kamzor';

  @override
  String get strength2 => 'Theek';

  @override
  String get strength3 => 'Mazboot';

  @override
  String get strength4 => 'Bohat mazboot';

  @override
  String get hide => 'Chhupao';

  @override
  String get show => 'Dikhao';

  @override
  String get usernameLine => 'Username: admin · Administrator';

  @override
  String get oldPassword => 'Purana password';

  @override
  String get newPassword => 'Naya password';

  @override
  String get newPasswordAgain => 'Naya password dobara';

  @override
  String get changePassword => 'Password badlo';

  @override
  String get demoInfo =>
      'Abhi panel sample data par chal raha hai. Phase 3 mein asal database (backend) lagega.';

  @override
  String demoCounts(String numbers, String groups, String campaigns) {
    return '$numbers numbers · $groups groups · $campaigns campaigns';
  }

  @override
  String get loadSample => 'Sample data load karo';

  @override
  String get sampleLoadedMsg =>
      'Sample numbers, groups aur campaigns wapas aa gaye';

  @override
  String get sampleData => 'Sample data';

  @override
  String get clearAll => 'Sab saaf karo';

  @override
  String get clearAllTitle => 'Sara data saaf karna hai?';

  @override
  String get clearAllMsg =>
      'Saare numbers, groups aur reports hat jayenge (khaali screens dekhne ke liye). Sample data dobara load kar sakte hain.';

  @override
  String get clearAllConfirm => 'Haan, saaf karo';

  @override
  String get clearedMsg => 'Panel ab khaali hai — empty states dekh sakte hain';

  @override
  String get dataCleared => 'Data saaf';

  @override
  String versionLine(String version) {
    return 'Version $version · Browser + Mobile';
  }

  @override
  String get gwConnectedMsg => 'Phone online hai — SMS bhej sakte hain';

  @override
  String get gwConnectedTitle => 'Gateway connect ho gaya';

  @override
  String get gwDisconnectTitle => 'Gateway disconnect karna hai?';

  @override
  String get gwDisconnectMsg =>
      'Phone se rabta khatam ho jayega aur chalti queue ruk jayegi. Dobara connect karne ke liye pairing karni hogi.';

  @override
  String get gwDisconnectConfirm => 'Haan, disconnect';

  @override
  String get gwQueueStopsUntil =>
      'Queue ruk jayegi jab tak dobara connect na ho';

  @override
  String get gwDisconnected => 'Gateway disconnect';

  @override
  String get important => 'Zaroori';

  @override
  String get keepPhoneOn =>
      'Phone on, charged aur internet par rakho — warna queue ruk jayegi.';

  @override
  String get gwSubMobile => 'Jis phone/SIM se SMS jata hai';

  @override
  String get gwSubDesktop =>
      'Jis Android phone aur SIM se asal SMS jata hai, us ki halat';

  @override
  String get connecting => 'Connect ho raha hai…';

  @override
  String get noPhoneConnection => 'Phone se rabta nahi';

  @override
  String get sim => 'SIM';

  @override
  String get signal => 'Signal';

  @override
  String get battery => 'Battery';

  @override
  String get charging => ' · charging';

  @override
  String get lastSeen => 'Last seen';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get reconnect => 'Dobara connect karo';

  @override
  String get guide1 => 'Phone on karein aur charger lagayein';

  @override
  String get guide2 => 'Internet (WiFi ya mobile data) on karein';

  @override
  String guide3(String app) {
    return 'Phone par \"$app Gateway\" app kholein';
  }

  @override
  String get guide4 => 'Pairing QR scan karein ya code daalein';

  @override
  String get guide5 => 'Green \"Connected\" ka intezar karein';

  @override
  String get guideTitle => 'Dobara connect kaise karein?';

  @override
  String get guideSub => 'In steps par amal karein';

  @override
  String get pairing => 'Pairing';

  @override
  String get pairingSub =>
      'Android gateway app mein ye QR scan karein ya code daalein';

  @override
  String get orEnterCode => 'Ya ye code likhein';

  @override
  String get codeCopied => 'Pairing code copy ho gaya';

  @override
  String get newCode => 'Naya code banao';

  @override
  String get oldCodeInvalid => 'Purana code ab kaam nahi karega';

  @override
  String get newPairingCode => 'Naya pairing code';

  @override
  String get checkNumber => 'Number check karein';

  @override
  String testSent(String phone) {
    return 'Test SMS $phone par bheja — phone check karein';
  }

  @override
  String get testSentTitle => 'Test SMS gaya';

  @override
  String get testFailedMsg => 'Gateway connected nahi — test nahi ja saka';

  @override
  String get testFailed => 'Test fail';

  @override
  String get yourNumber => 'Apna number';

  @override
  String get sendingNow => 'Bhej rahe hain…';

  @override
  String get sendTestSms => 'Test SMS bhejo';

  @override
  String get testSms => 'Test SMS';

  @override
  String get testSmsSub => 'Apne number par 1 test SMS bhej kar check karein';

  @override
  String get loginNetwork =>
      'Server se rabta nahi ho saka — internet check karke dobara koshish karein.';

  @override
  String get syncFailed => 'Server par save nahi hua — internet check karein';

  @override
  String get modeLive => 'Live · Supabase';

  @override
  String get modeDemo => 'Demo mode';
}
