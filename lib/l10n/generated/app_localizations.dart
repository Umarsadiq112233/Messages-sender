import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur'),
    Locale.fromSubtags(languageCode: 'ur', scriptCode: 'Latn'),
  ];

  /// No description provided for @cancel.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @create.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @back.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Band karo'**
  String get close;

  /// No description provided for @confirmDelete.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Haan, delete karo'**
  String get confirmDelete;

  /// No description provided for @keepIt.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Nahi, rehne do'**
  String get keepIt;

  /// No description provided for @edit.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @rename.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @actions.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @copy.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @clear.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Saaf karo'**
  String get clear;

  /// No description provided for @searchHint.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Name ya number se dhoondo…'**
  String get searchHint;

  /// No description provided for @decrease.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Kam karo'**
  String get decrease;

  /// No description provided for @increase.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Barhao'**
  String get increase;

  /// No description provided for @noGroup.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Bina group'**
  String get noGroup;

  /// No description provided for @toastSuccess.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Kamyab'**
  String get toastSuccess;

  /// No description provided for @toastError.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Masla'**
  String get toastError;

  /// No description provided for @toastWarning.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Tawajjo'**
  String get toastWarning;

  /// No description provided for @toastInfo.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Maloomat'**
  String get toastInfo;

  /// No description provided for @statusSent.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sent'**
  String get statusSent;

  /// No description provided for @statusFailed.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @statusPending.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusSending.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Ja raha hai'**
  String get statusSending;

  /// No description provided for @on.
  ///
  /// In ur_Latn, this message translates to:
  /// **'ON'**
  String get on;

  /// No description provided for @off.
  ///
  /// In ur_Latn, this message translates to:
  /// **'OFF'**
  String get off;

  /// No description provided for @sec.
  ///
  /// In ur_Latn, this message translates to:
  /// **'sec'**
  String get sec;

  /// No description provided for @appTagline.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Ek click — har number tak paigham'**
  String get appTagline;

  /// No description provided for @navDashboard.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navDatabase.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Database'**
  String get navDatabase;

  /// No description provided for @navGroups.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Groups'**
  String get navGroups;

  /// No description provided for @navSend.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Send SMS'**
  String get navSend;

  /// No description provided for @navSendShort.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Send SMS'**
  String get navSendShort;

  /// No description provided for @navQueue.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sending Queue'**
  String get navQueue;

  /// No description provided for @navReports.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navGateway.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Gateway'**
  String get navGateway;

  /// No description provided for @navSettings.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navSectionMain.
  ///
  /// In ur_Latn, this message translates to:
  /// **'MAIN'**
  String get navSectionMain;

  /// No description provided for @navSectionMessaging.
  ///
  /// In ur_Latn, this message translates to:
  /// **'MESSAGING'**
  String get navSectionMessaging;

  /// No description provided for @navSectionSystem.
  ///
  /// In ur_Latn, this message translates to:
  /// **'SYSTEM'**
  String get navSectionSystem;

  /// No description provided for @navAddNumber.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Add Number'**
  String get navAddNumber;

  /// No description provided for @navBulkImport.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Bulk Import'**
  String get navBulkImport;

  /// No description provided for @navEditNumber.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Edit Number'**
  String get navEditNumber;

  /// No description provided for @navHome.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navMore.
  ///
  /// In ur_Latn, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @moreTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Aur options'**
  String get moreTitle;

  /// No description provided for @moreSubtitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Panel ke baqi hissay yahan se kholein'**
  String get moreSubtitle;

  /// No description provided for @logoutTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Logout karna hai?'**
  String get logoutTitle;

  /// No description provided for @logoutMessage.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Aap panel se bahar aa jayenge. Dobara andar aane ke liye login karna hoga.'**
  String get logoutMessage;

  /// No description provided for @logoutConfirm.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Haan, logout'**
  String get logoutConfirm;

  /// No description provided for @logoutDone.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Aap logout ho gaye. Phir milenge!'**
  String get logoutDone;

  /// No description provided for @logout.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @gatewayOnlineLower.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Gateway online'**
  String get gatewayOnlineLower;

  /// No description provided for @gatewayOfflineLower.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Gateway offline'**
  String get gatewayOfflineLower;

  /// No description provided for @gatewayOnline.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Gateway Online'**
  String get gatewayOnline;

  /// No description provided for @gatewayOffline.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Gateway Offline'**
  String get gatewayOffline;

  /// No description provided for @roleAdmin.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @topSearchHint.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Number ya naam dhoondo…'**
  String get topSearchHint;

  /// No description provided for @livePaused.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Paused {done}/{total}'**
  String livePaused(int done, int total);

  /// No description provided for @liveSending.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sending {done}/{total}'**
  String liveSending(int done, int total);

  /// No description provided for @gatewayStatusTooltip.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Gateway / Device status'**
  String get gatewayStatusTooltip;

  /// No description provided for @account.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @adminSubtitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'admin · Administrator'**
  String get adminSubtitle;

  /// No description provided for @gatewayDevice.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Gateway / Device'**
  String get gatewayDevice;

  /// No description provided for @backTooltip.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Wapas'**
  String get backTooltip;

  /// No description provided for @language.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Zaban / Language'**
  String get language;

  /// No description provided for @languageSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Panel kis zaban mein dikhe'**
  String get languageSub;

  /// No description provided for @languageChanged.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Zaban badal di gayi'**
  String get languageChanged;

  /// No description provided for @languageDefault.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Default'**
  String get languageDefault;

  /// No description provided for @splashStep1.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Panel tayyar ho raha hai…'**
  String get splashStep1;

  /// No description provided for @splashStep2.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Database load ho raha hai…'**
  String get splashStep2;

  /// No description provided for @splashStep3.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Gateway check ho raha hai…'**
  String get splashStep3;

  /// No description provided for @splashStep4.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Bas aik lamha…'**
  String get splashStep4;

  /// No description provided for @agoNow.
  ///
  /// In ur_Latn, this message translates to:
  /// **'abhi abhi'**
  String get agoNow;

  /// No description provided for @agoMinutes.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} min pehle'**
  String agoMinutes(int count);

  /// No description provided for @agoHours.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} ghante pehle'**
  String agoHours(int count);

  /// No description provided for @agoYesterday.
  ///
  /// In ur_Latn, this message translates to:
  /// **'kal'**
  String get agoYesterday;

  /// No description provided for @agoDays.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} din pehle'**
  String agoDays(int count);

  /// No description provided for @greetMorning.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Subah bakhair'**
  String get greetMorning;

  /// No description provided for @greetDay.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Assalam-o-Alaikum'**
  String get greetDay;

  /// No description provided for @greetEvening.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Shaam bakhair'**
  String get greetEvening;

  /// No description provided for @durHoursMinutes.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{hours} ghanta {minutes} min'**
  String durHoursMinutes(int hours, int minutes);

  /// No description provided for @durMinutesSeconds.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{minutes} min {seconds} sec'**
  String durMinutesSeconds(int minutes, int seconds);

  /// No description provided for @durSeconds.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{seconds} sec'**
  String durSeconds(int seconds);

  /// No description provided for @phoneEmpty.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Mobile number likhna zaroori hai'**
  String get phoneEmpty;

  /// No description provided for @phonePrefix.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Number 03 se shuru hona chahiye'**
  String get phonePrefix;

  /// No description provided for @phoneTooShort.
  ///
  /// In ur_Latn, this message translates to:
  /// **'11 digits chahiye — abhi {count} hain'**
  String phoneTooShort(int count);

  /// No description provided for @phoneTooLong.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Number 11 digits se lamba hai'**
  String get phoneTooLong;

  /// No description provided for @actContactAdded.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Naya number add hua'**
  String get actContactAdded;

  /// No description provided for @actContactEdited.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Number update hua'**
  String get actContactEdited;

  /// No description provided for @actContactDeleted.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Number delete hua'**
  String get actContactDeleted;

  /// No description provided for @actContactsDeleted.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} numbers delete hue'**
  String actContactsDeleted(int count);

  /// No description provided for @actContactsDeletedSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Database se hata diye gaye'**
  String get actContactsDeletedSub;

  /// No description provided for @actImported.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Bulk import mukammal'**
  String get actImported;

  /// No description provided for @actImportedSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} numbers add hue'**
  String actImportedSub(int count);

  /// No description provided for @actGroupCreated.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Naya group bana'**
  String get actGroupCreated;

  /// No description provided for @actGroupRenamed.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Group ka naam badla'**
  String get actGroupRenamed;

  /// No description provided for @actGroupDeleted.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Group delete hua'**
  String get actGroupDeleted;

  /// No description provided for @actCampaignStarted.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Campaign shuru hui'**
  String get actCampaignStarted;

  /// No description provided for @actCampaignStartedSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} numbers ko ja rahi hai'**
  String actCampaignStartedSub(int count);

  /// No description provided for @actCampaignSent.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Campaign bheji gayi'**
  String get actCampaignSent;

  /// No description provided for @actCampaignSentSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{sent} numbers ko gaya · {failed} failed'**
  String actCampaignSentSub(int sent, int failed);

  /// No description provided for @actCampaignStopped.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Campaign rok di gayi'**
  String get actCampaignStopped;

  /// No description provided for @actCampaignStoppedSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{sent} gaye · {notSent} nahi gaye'**
  String actCampaignStoppedSub(int sent, int notSent);

  /// No description provided for @actCampaignCompleted.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Campaign mukammal'**
  String get actCampaignCompleted;

  /// No description provided for @actCampaignCompletedSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{sent} gaye · {failed} failed'**
  String actCampaignCompletedSub(int sent, int failed);

  /// No description provided for @actPasswordChanged.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Password tabdeel hua'**
  String get actPasswordChanged;

  /// No description provided for @actPasswordChangedSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Account security update'**
  String get actPasswordChangedSub;

  /// No description provided for @actLimitsSaved.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Package / limit update'**
  String get actLimitsSaved;

  /// No description provided for @actLimitsSavedSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Roz ki limit {limit} · baqi {left}'**
  String actLimitsSavedSub(int limit, int left);

  /// No description provided for @actSendingSaved.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sending settings update'**
  String get actSendingSaved;

  /// No description provided for @actSendingSavedSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Waqfa {secs}s · Test mode {mode}'**
  String actSendingSavedSub(int secs, String mode);

  /// No description provided for @actGatewayConnected.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Gateway connect hua'**
  String get actGatewayConnected;

  /// No description provided for @actGatewayConnectedSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{device} online'**
  String actGatewayConnectedSub(String device);

  /// No description provided for @actGatewayDisconnected.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Gateway disconnect hua'**
  String get actGatewayDisconnected;

  /// No description provided for @actGatewayDisconnectedSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Phone se rabta toot gaya'**
  String get actGatewayDisconnectedSub;

  /// No description provided for @actTestSms.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Test SMS bheja'**
  String get actTestSms;

  /// No description provided for @failNetworkBusy.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Network busy — dobara koshish'**
  String get failNetworkBusy;

  /// No description provided for @failNumberOff.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Number band hai'**
  String get failNumberOff;

  /// No description provided for @failTimeout.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Delivery timeout'**
  String get failTimeout;

  /// No description provided for @failLowBalance.
  ///
  /// In ur_Latn, this message translates to:
  /// **'SIM balance kam'**
  String get failLowBalance;

  /// No description provided for @failLowBalanceHint.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Balance kam hai — apni SIM ka package/balance check karein'**
  String get failLowBalanceHint;

  /// No description provided for @failNoPermission.
  ///
  /// In ur_Latn, this message translates to:
  /// **'SMS permission allowed nahi — Android settings mein is app ko SMS ki ijazat dein'**
  String get failNoPermission;

  /// No description provided for @failNoSim.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Muntakhab SIM nahi mili — Settings mein Sending SIM check karein'**
  String get failNoSim;

  /// No description provided for @sendingSim.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Bhejne wali SIM'**
  String get sendingSim;

  /// No description provided for @simPhoneDefault.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Phone default'**
  String get simPhoneDefault;

  /// No description provided for @simSlot.
  ///
  /// In ur_Latn, this message translates to:
  /// **'SIM {slot}'**
  String simSlot(int slot);

  /// No description provided for @simSlotCarrier.
  ///
  /// In ur_Latn, this message translates to:
  /// **'SIM {slot} · {carrier}'**
  String simSlotCarrier(int slot, String carrier);

  /// No description provided for @simChoiceCaption.
  ///
  /// In ur_Latn, this message translates to:
  /// **'SIM ka intekhab Android gateway phone par nazar ayega'**
  String get simChoiceCaption;

  /// No description provided for @loadSims.
  ///
  /// In ur_Latn, this message translates to:
  /// **'SIMs load karein'**
  String get loadSims;

  /// No description provided for @failNotExist.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Number mojood nahi'**
  String get failNotExist;

  /// No description provided for @failStopped.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Rok diya gaya (Stop)'**
  String get failStopped;

  /// No description provided for @audAll.
  ///
  /// In ur_Latn, this message translates to:
  /// **'All Numbers'**
  String get audAll;

  /// No description provided for @audGroup.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Group: {name}'**
  String audGroup(String name);

  /// No description provided for @audSelected.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Selected ({count})'**
  String audSelected(int count);

  /// No description provided for @audRetry.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Failed dobara ({count})'**
  String audRetry(int count);

  /// No description provided for @audTest.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Test'**
  String get audTest;

  /// No description provided for @pauseUser.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Aap ne pause kiya'**
  String get pauseUser;

  /// No description provided for @pauseGateway.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Gateway disconnected — phone check karein'**
  String get pauseGateway;

  /// No description provided for @discLost.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Phone se rabta toot gaya (internet band ya app band)'**
  String get discLost;

  /// No description provided for @discByUser.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Aap ne panel se disconnect kiya'**
  String get discByUser;

  /// No description provided for @impNoNumber.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Number nahi mila'**
  String get impNoNumber;

  /// No description provided for @impInDatabase.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Pehle se database mein'**
  String get impInDatabase;

  /// No description provided for @impRepeated.
  ///
  /// In ur_Latn, this message translates to:
  /// **'List mein do baar'**
  String get impRepeated;

  /// No description provided for @loginFeat1Title.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Bulk import'**
  String get loginFeat1Title;

  /// No description provided for @loginFeat1Sub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Excel / CSV ya list paste — seconds mein'**
  String get loginFeat1Sub;

  /// No description provided for @loginFeat2Title.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Live sending queue'**
  String get loginFeat2Title;

  /// No description provided for @loginFeat2Sub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Har SMS ki halat saamne'**
  String get loginFeat2Sub;

  /// No description provided for @loginFeat3Title.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Reports & export'**
  String get loginFeat3Title;

  /// No description provided for @loginFeat3Sub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Ek click mein Excel report'**
  String get loginFeat3Sub;

  /// No description provided for @loginHeadline.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Ek click mein\nhazaron tak paigham.'**
  String get loginHeadline;

  /// No description provided for @loginHeadlineSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Numbers ka database, groups, live sending aur reports — sab ek jagah.'**
  String get loginHeadlineSub;

  /// No description provided for @usernameRequired.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Username likhein'**
  String get usernameRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Password likhein'**
  String get passwordRequired;

  /// No description provided for @loginWelcomeToast.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Khush aamdeed, {name}! Panel tayyar hai.'**
  String loginWelcomeToast(String name);

  /// No description provided for @loginSuccess.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Login kamyab'**
  String get loginSuccess;

  /// No description provided for @loginWrong.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Username ya password galat hai. Dobara koshish karein.'**
  String get loginWrong;

  /// No description provided for @loginTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Wapas khush aamdeed'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Apne {app} SMS panel mein login karein'**
  String loginSubtitle(String app);

  /// No description provided for @loginFailed.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Login nahi hua'**
  String get loginFailed;

  /// No description provided for @username.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @usernameHint.
  ///
  /// In ur_Latn, this message translates to:
  /// **'apna username likhein'**
  String get usernameHint;

  /// No description provided for @password.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @hidePassword.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Password chhupao'**
  String get hidePassword;

  /// No description provided for @showPassword.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Password dikhao'**
  String get showPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @loggingIn.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Login ho raha hai…'**
  String get loggingIn;

  /// No description provided for @login.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @forgotTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Password bhool gaye?'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Fikar na karein — reset code SMS par aa jayega'**
  String get forgotSubtitle;

  /// No description provided for @registeredMobile.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Registered mobile number'**
  String get registeredMobile;

  /// No description provided for @forgotAdminHint.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Ya admin (Umar) se rabta karein — woh password reset kar sakte hain.'**
  String get forgotAdminHint;

  /// No description provided for @sendResetCode.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Reset code bhejo'**
  String get sendResetCode;

  /// No description provided for @enterValidMobile.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sahi mobile number likhein (03XX-XXXXXXX)'**
  String get enterValidMobile;

  /// No description provided for @resetCodeSent.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Reset code {phone} par bhej diya gaya (demo).'**
  String resetCodeSent(String phone);

  /// No description provided for @codeSent.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Code bhej diya'**
  String get codeSent;

  /// No description provided for @demoLogin.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Demo login:'**
  String get demoLogin;

  /// No description provided for @fill.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Bharo'**
  String get fill;

  /// No description provided for @greetingName.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{greeting}, {name}'**
  String greetingName(String greeting, String name);

  /// No description provided for @dashSubtitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{weekday}, {date} — panel ka poora haal ek nazar mein'**
  String dashSubtitle(String weekday, String date);

  /// No description provided for @statTotalNumbers.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Total Numbers'**
  String get statTotalNumbers;

  /// No description provided for @statInGroups.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} groups mein'**
  String statInGroups(int count);

  /// No description provided for @statToday.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Aaj Bhejay Gaye SMS'**
  String get statToday;

  /// No description provided for @statDailyLimit.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{today} / {limit} roz ki limit'**
  String statDailyLimit(int today, int limit);

  /// No description provided for @statTotalSent.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Total Sent'**
  String get statTotalSent;

  /// No description provided for @statSuccessRate.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{rate}% kamyabi'**
  String statSuccessRate(int rate);

  /// No description provided for @statNoFailures.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Koi failure nahi'**
  String get statNoFailures;

  /// No description provided for @statRetryFromReports.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Reports se dobara bhejein'**
  String get statRetryFromReports;

  /// No description provided for @quickAction.
  ///
  /// In ur_Latn, this message translates to:
  /// **'QUICK ACTION'**
  String get quickAction;

  /// No description provided for @quickTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Naya SMS bhejna hai?'**
  String get quickTitle;

  /// No description provided for @quickSubtitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Group chunein, message likhein — ek click mein sab tak.'**
  String get quickSubtitle;

  /// No description provided for @sendNewSms.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Naya SMS Bhejo'**
  String get sendNewSms;

  /// No description provided for @chartTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Pichle 7 din ke SMS'**
  String get chartTitle;

  /// No description provided for @chartSubtitleData.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{amount} SMS kamyabi se gaye'**
  String chartSubtitleData(String amount);

  /// No description provided for @chartSubtitleEmpty.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Roz ka graph yahan nazar aayega'**
  String get chartSubtitleEmpty;

  /// No description provided for @emptyNoSmsTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Abhi koi SMS nahi gaya'**
  String get emptyNoSmsTitle;

  /// No description provided for @emptyNoSmsMsg.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Pehla SMS bhejein — phir yahan roz ka graph nazar aayega.'**
  String get emptyNoSmsMsg;

  /// No description provided for @countSent.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} sent'**
  String countSent(int count);

  /// No description provided for @countFailed.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} failed'**
  String countFailed(int count);

  /// No description provided for @today.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Aaj'**
  String get today;

  /// No description provided for @todayLower.
  ///
  /// In ur_Latn, this message translates to:
  /// **'aaj'**
  String get todayLower;

  /// No description provided for @recentActivity.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @last5.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Aakhri 5 kaam'**
  String get last5;

  /// No description provided for @noActivityTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Abhi koi activity nahi'**
  String get noActivityTitle;

  /// No description provided for @noActivityMsg.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Number add karein ya SMS bhejein — yahan sab nazar aayega.'**
  String get noActivityMsg;

  /// No description provided for @packageLimit.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Package & Limit'**
  String get packageLimit;

  /// No description provided for @packageLimitSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Aaj ki limit aur baqi SMS'**
  String get packageLimitSub;

  /// No description provided for @sentToday.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Aaj bheje'**
  String get sentToday;

  /// No description provided for @leftToday.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Aaj baqi'**
  String get leftToday;

  /// No description provided for @smsCount.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} SMS'**
  String smsCount(int count);

  /// No description provided for @packageLeft.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Package mein baqi'**
  String get packageLeft;

  /// No description provided for @changeLimit.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Limit badlo'**
  String get changeLimit;

  /// No description provided for @gatewayConnected.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Gateway Connected'**
  String get gatewayConnected;

  /// No description provided for @gatewayNotConnected.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Gateway Not Connected'**
  String get gatewayNotConnected;

  /// No description provided for @deviceBattery.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{device} · {battery}% battery'**
  String deviceBattery(String device, int battery);

  /// No description provided for @checkPhoneQueueStops.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Phone check karein — queue ruk jayegi'**
  String get checkPhoneQueueStops;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Pakka delete karna hai?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMsg.
  ///
  /// In ur_Latn, this message translates to:
  /// **'\"{name}\" ({phone}) database se hat jayega. Ye wapas nahi aayega.'**
  String deleteConfirmMsg(String name, String phone);

  /// No description provided for @deletedOne.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{name} database se hata diya gaya'**
  String deletedOne(String name);

  /// No description provided for @numberDeleted.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Number delete ho gaya'**
  String get numberDeleted;

  /// No description provided for @deleteManyTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} numbers delete karne hain?'**
  String deleteManyTitle(int count);

  /// No description provided for @deleteManyMsg.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Chune hue {count} numbers database se hamesha ke liye hat jayenge. Ye wapas nahi aayenge.'**
  String deleteManyMsg(int count);

  /// No description provided for @deleteManyConfirm.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Haan, {count} delete karo'**
  String deleteManyConfirm(int count);

  /// No description provided for @deletedMany.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} numbers database se hata diye gaye'**
  String deletedMany(int count);

  /// No description provided for @deletedManyTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Delete ho gaye'**
  String get deletedManyTitle;

  /// No description provided for @numbersSummary.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{numbers} numbers · {groups} groups'**
  String numbersSummary(String numbers, String groups);

  /// No description provided for @importAction.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Import'**
  String get importAction;

  /// No description provided for @sort.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @sortNewest.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Naye pehle'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Purane pehle'**
  String get sortOldest;

  /// No description provided for @sortName.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Naam A–Z'**
  String get sortName;

  /// No description provided for @colName.
  ///
  /// In ur_Latn, this message translates to:
  /// **'NAME'**
  String get colName;

  /// No description provided for @colMobile.
  ///
  /// In ur_Latn, this message translates to:
  /// **'MOBILE NUMBER'**
  String get colMobile;

  /// No description provided for @colGroup.
  ///
  /// In ur_Latn, this message translates to:
  /// **'GROUP'**
  String get colGroup;

  /// No description provided for @colAdded.
  ///
  /// In ur_Latn, this message translates to:
  /// **'ADD HONE KI DATE'**
  String get colAdded;

  /// No description provided for @colActions.
  ///
  /// In ur_Latn, this message translates to:
  /// **'ACTIONS'**
  String get colActions;

  /// No description provided for @showingRange.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Dikha rahe hain {from}–{to} / {total}'**
  String showingRange(int from, int to, int total);

  /// No description provided for @group.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @allGroups.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Saare groups'**
  String get allGroups;

  /// No description provided for @dbEmptyTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Database abhi khaali hai'**
  String get dbEmptyTitle;

  /// No description provided for @dbEmptyMsg.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Pehla number add karein ya Excel / list se ek saath import karein.'**
  String get dbEmptyMsg;

  /// No description provided for @noResultsTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Is query par koi number nahi mila'**
  String get noResultsTitle;

  /// No description provided for @noResultsGroup.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Is group mein abhi koi number nahi.'**
  String get noResultsGroup;

  /// No description provided for @noResultsQuery.
  ///
  /// In ur_Latn, this message translates to:
  /// **'\"{query}\" se milta julta koi naam ya number nahi hai.'**
  String noResultsQuery(String query);

  /// No description provided for @clearFilter.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Filter saaf karo'**
  String get clearFilter;

  /// No description provided for @all.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sab'**
  String get all;

  /// No description provided for @numbersFound.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} numbers mile'**
  String numbersFound(int count);

  /// No description provided for @loadMore.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Load more ({count} baqi)'**
  String loadMore(int count);

  /// No description provided for @selectedCount.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @clearSelection.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Selection hatao'**
  String get clearSelection;

  /// No description provided for @sendSmsShort.
  ///
  /// In ur_Latn, this message translates to:
  /// **'SMS bhejo'**
  String get sendSmsShort;

  /// No description provided for @prev.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Pichla'**
  String get prev;

  /// No description provided for @next.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Agla'**
  String get next;

  /// No description provided for @dupWithName.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Ye number pehle se database mein hai ({name}).'**
  String dupWithName(String name);

  /// No description provided for @checkForm.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Form check karein'**
  String get checkForm;

  /// No description provided for @notSaved.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Save nahi hua'**
  String get notSaved;

  /// No description provided for @numberSaved.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Number save ho gaya'**
  String get numberSaved;

  /// No description provided for @numberInfo.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Number ki maloomat'**
  String get numberInfo;

  /// No description provided for @onlyMobileRequired.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sirf mobile number zaroori hai'**
  String get onlyMobileRequired;

  /// No description provided for @addedHere.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} add hue'**
  String addedHere(int count);

  /// No description provided for @saveAndAddAnother.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Save & Add Another'**
  String get saveAndAddAnother;

  /// No description provided for @addAnotherShort.
  ///
  /// In ur_Latn, this message translates to:
  /// **'+ Aur'**
  String get addAnotherShort;

  /// No description provided for @newNumber.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Naya Number'**
  String get newNumber;

  /// No description provided for @newNumberSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Database mein ek number daalein'**
  String get newNumberSub;

  /// No description provided for @addNumberTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Naya Number Add Karo'**
  String get addNumberTitle;

  /// No description provided for @dbHasNumbers.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Database mein abhi {count} numbers hain'**
  String dbHasNumbers(int count);

  /// No description provided for @tip1.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Number 03 se shuru ho aur 11 digits ka ho'**
  String get tip1;

  /// No description provided for @tip2.
  ///
  /// In ur_Latn, this message translates to:
  /// **'+92 300… likhein to bhi khud 0300… ban jayega'**
  String get tip2;

  /// No description provided for @tip3.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Group chunne se baad mein group ko SMS bhejna aasan'**
  String get tip3;

  /// No description provided for @tips.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Tips'**
  String get tips;

  /// No description provided for @manyNumbersQ.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Bohat saare numbers hain?'**
  String get manyNumbersQ;

  /// No description provided for @useBulkImport.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Bulk import se ek saath daalein'**
  String get useBulkImport;

  /// No description provided for @detailsUpdated.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{name} ki maloomat update ho gayi'**
  String detailsUpdated(String name);

  /// No description provided for @changesSaved.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Changes save ho gaye'**
  String get changesSaved;

  /// No description provided for @numberNotFound.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Number nahi mila'**
  String get numberNotFound;

  /// No description provided for @maybeDeleted.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Ye number shayad delete ho chuka hai.'**
  String get maybeDeleted;

  /// No description provided for @backToDb.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Database par wapas'**
  String get backToDb;

  /// No description provided for @editDetails.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Maloomat badlein'**
  String get editDetails;

  /// No description provided for @unsavedChanges.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Aap ne kuch tabdeeli ki hai — save karna na bhoolein'**
  String get unsavedChanges;

  /// No description provided for @editHint.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Koi bhi field badal kar save karein'**
  String get editHint;

  /// No description provided for @saveChanges.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @numberDetails.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Is number ki tafseel'**
  String get numberDetails;

  /// No description provided for @dateAdded.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Add hone ki date'**
  String get dateAdded;

  /// No description provided for @smsSentCount.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Kitne SMS gaye'**
  String get smsSentCount;

  /// No description provided for @lastSms.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Aakhri SMS'**
  String get lastSms;

  /// No description provided for @smsHistory.
  ///
  /// In ur_Latn, this message translates to:
  /// **'SMS history'**
  String get smsHistory;

  /// No description provided for @lastNSms.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Aakhri {count} SMS'**
  String lastNSms(int count);

  /// No description provided for @historyEmptyMsg.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Is number ko bheje gaye SMS yahan nazar aayenge.'**
  String get historyEmptyMsg;

  /// No description provided for @dangerZone.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Danger zone'**
  String get dangerZone;

  /// No description provided for @removedForever.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Number hamesha ke liye hat jayega'**
  String get removedForever;

  /// No description provided for @deleteNumber.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Delete Number'**
  String get deleteNumber;

  /// No description provided for @noChanges.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Koi tabdeeli nahi'**
  String get noChanges;

  /// No description provided for @dupNumber.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Ye number pehle se database mein hai'**
  String get dupNumber;

  /// No description provided for @name.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nameHint.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Masalan: Ali Raza'**
  String get nameHint;

  /// No description provided for @mobileNumber.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @mobileHelper.
  ///
  /// In ur_Latn, this message translates to:
  /// **'11 digits — dash khud lag jayega'**
  String get mobileHelper;

  /// No description provided for @savedUnder.
  ///
  /// In ur_Latn, this message translates to:
  /// **'\"{name}\" ke naam se {group} mein save hai.'**
  String savedUnder(String name, String group);

  /// No description provided for @openThatNumber.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Woh number kholo'**
  String get openThatNumber;

  /// No description provided for @noteOptional.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @noteHint.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Koi zaroori baat… (masalan: fee pending)'**
  String get noteHint;

  /// No description provided for @typeName.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Naam likhein…'**
  String get typeName;

  /// No description provided for @livePreview.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Live preview'**
  String get livePreview;

  /// No description provided for @previewSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Database mein aise nazar aayega'**
  String get previewSub;

  /// No description provided for @chooseFile.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Excel / CSV file chunein'**
  String get chooseFile;

  /// No description provided for @fileRows.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{file} se {count} rows mili'**
  String fileRows(String file, int count);

  /// No description provided for @fileRead.
  ///
  /// In ur_Latn, this message translates to:
  /// **'File parh li'**
  String get fileRead;

  /// No description provided for @fileError.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Ye file parhi nahi ja saki. CSV ya .xlsx file try karein.'**
  String get fileError;

  /// No description provided for @fileProblem.
  ///
  /// In ur_Latn, this message translates to:
  /// **'File ka masla'**
  String get fileProblem;

  /// No description provided for @importedToDb.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} numbers database mein add ho gaye'**
  String importedToDb(int count);

  /// No description provided for @importDone.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Import mukammal'**
  String get importDone;

  /// No description provided for @importBtn.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Import Karo'**
  String get importBtn;

  /// No description provided for @importBtnCount.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Import Karo ({count} numbers)'**
  String importBtnCount(int count);

  /// No description provided for @importSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Ek saath bohat saare numbers daalein'**
  String get importSub;

  /// No description provided for @noValidNumbers.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Koi theek number nahi mila — list check karein'**
  String get noValidNumbers;

  /// No description provided for @importSubDesktop.
  ///
  /// In ur_Latn, this message translates to:
  /// **'List paste karein ya Excel / CSV file upload karein — waqt bachayein'**
  String get importSubDesktop;

  /// No description provided for @whereFrom.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Numbers kahan se?'**
  String get whereFrom;

  /// No description provided for @twoWays.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Do tareeqay — jo aasan lage'**
  String get twoWays;

  /// No description provided for @listPaste.
  ///
  /// In ur_Latn, this message translates to:
  /// **'List Paste'**
  String get listPaste;

  /// No description provided for @fileUpload.
  ///
  /// In ur_Latn, this message translates to:
  /// **'File Upload'**
  String get fileUpload;

  /// No description provided for @whichGroup.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Ye numbers kis group mein jayen?'**
  String get whichGroup;

  /// No description provided for @newGroupShort.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Naya group'**
  String get newGroupShort;

  /// No description provided for @pasteHint.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Ek line mein ek number…\n0300-1234567\nAli Raza, 0321-7654321\n+92 333 1112223'**
  String get pasteHint;

  /// No description provided for @pasteTip.
  ///
  /// In ur_Latn, this message translates to:
  /// **'\"Naam, Number\" bhi likh sakte hain'**
  String get pasteTip;

  /// No description provided for @fillSample.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sample bharo'**
  String get fillSample;

  /// No description provided for @dropHere.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Chhor dein — hum parh lenge'**
  String get dropHere;

  /// No description provided for @dropFileDesktop.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Excel / CSV file yahan chhorein'**
  String get dropFileDesktop;

  /// No description provided for @fileFormatsHint.
  ///
  /// In ur_Latn, this message translates to:
  /// **'.xlsx, .csv ya .txt — pehla column naam, doosra number'**
  String get fileFormatsHint;

  /// No description provided for @reading.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Parh rahe hain…'**
  String get reading;

  /// No description provided for @pickFile.
  ///
  /// In ur_Latn, this message translates to:
  /// **'File chunein'**
  String get pickFile;

  /// No description provided for @rowsCount.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} rows'**
  String rowsCount(int count);

  /// No description provided for @removeFile.
  ///
  /// In ur_Latn, this message translates to:
  /// **'File hatao'**
  String get removeFile;

  /// No description provided for @preview.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @previewEmptySub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Numbers daalte hi yahan check ho jayenge'**
  String get previewEmptySub;

  /// No description provided for @rowsFound.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} rows mili'**
  String rowsFound(int count);

  /// No description provided for @nothingYet.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Abhi kuch nahi'**
  String get nothingYet;

  /// No description provided for @previewEmptyMsg.
  ///
  /// In ur_Latn, this message translates to:
  /// **'List paste karein ya file chunein — har number yahan check hoga.'**
  String get previewEmptyMsg;

  /// No description provided for @found.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Mile'**
  String get found;

  /// No description provided for @valid.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Theek'**
  String get valid;

  /// No description provided for @duplicate.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @badFormat.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Galat format'**
  String get badFormat;

  /// No description provided for @moreRows.
  ///
  /// In ur_Latn, this message translates to:
  /// **'…aur {count} rows'**
  String moreRows(int count);

  /// No description provided for @step1.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Numbers do'**
  String get step1;

  /// No description provided for @step2.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Preview check karo'**
  String get step2;

  /// No description provided for @step3.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Import karo'**
  String get step3;

  /// No description provided for @invalidShort.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Galat'**
  String get invalidShort;

  /// No description provided for @importComplete.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Import mukammal!'**
  String get importComplete;

  /// No description provided for @importSummary.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{total} mein se {added} add hue, {dup} duplicate, {bad} galat'**
  String importSummary(int total, int added, int dup, int bad);

  /// No description provided for @groupSuffix.
  ///
  /// In ur_Latn, this message translates to:
  /// **' · Group: {name}'**
  String groupSuffix(String name);

  /// No description provided for @addedLabel.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Add hue'**
  String get addedLabel;

  /// No description provided for @importMore.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Aur import karo'**
  String get importMore;

  /// No description provided for @viewDatabase.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Database dekho'**
  String get viewDatabase;

  /// No description provided for @groupDeleteTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'\"{name}\" delete karna hai?'**
  String groupDeleteTitle(String name);

  /// No description provided for @groupDeleteEmpty.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Ye group khaali hai. Delete karne ke baad wapas nahi aayega.'**
  String get groupDeleteEmpty;

  /// No description provided for @groupDeleteWithNumbers.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Is group mein {count} numbers hain. Numbers delete NAHI honge — woh \"Bina group\" mein chale jayenge. Group wapas nahi aayega.'**
  String groupDeleteWithNumbers(int count);

  /// No description provided for @groupDeleteConfirm.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Haan, group delete karo'**
  String get groupDeleteConfirm;

  /// No description provided for @groupRemoved.
  ///
  /// In ur_Latn, this message translates to:
  /// **'\"{name}\" hata diya gaya'**
  String groupRemoved(String name);

  /// No description provided for @groupRemovedMoved.
  ///
  /// In ur_Latn, this message translates to:
  /// **'\"{name}\" hata diya — {count} numbers \"Bina group\" mein'**
  String groupRemovedMoved(String name, int count);

  /// No description provided for @groupDeleted.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Group delete ho gaya'**
  String get groupDeleted;

  /// No description provided for @newGroup.
  ///
  /// In ur_Latn, this message translates to:
  /// **'New Group'**
  String get newGroup;

  /// No description provided for @groupsSubtitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} groups · numbers ko groups mein rakhein taake SMS bhejna aasan ho'**
  String groupsSubtitle(int count);

  /// No description provided for @noGroupsTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Abhi koi group nahi'**
  String get noGroupsTitle;

  /// No description provided for @noGroupsMsg.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Groups banayein — masalan \"Customers\", \"Students\" — phir poore group ko ek click mein SMS bhejein.'**
  String get noGroupsMsg;

  /// No description provided for @firstGroup.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Pehla group banao'**
  String get firstGroup;

  /// No description provided for @numbersWord.
  ///
  /// In ur_Latn, this message translates to:
  /// **' numbers'**
  String get numbersWord;

  /// No description provided for @createdOn.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Bana: {date}'**
  String createdOn(String date);

  /// No description provided for @noNumbersYet.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Abhi koi number nahi'**
  String get noNumbersYet;

  /// No description provided for @smsShort.
  ///
  /// In ur_Latn, this message translates to:
  /// **'SMS'**
  String get smsShort;

  /// No description provided for @smsThisGroup.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Is group ko SMS bhejo'**
  String get smsThisGroup;

  /// No description provided for @ungroupedCount.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} numbers kisi group mein nahi'**
  String ungroupedCount(int count);

  /// No description provided for @createNewGroup.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Naya group banao'**
  String get createNewGroup;

  /// No description provided for @groupNameRequired.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Group ka naam likhein'**
  String get groupNameRequired;

  /// No description provided for @groupNameExists.
  ///
  /// In ur_Latn, this message translates to:
  /// **'\"{name}\" naam ka group pehle se hai'**
  String groupNameExists(String name);

  /// No description provided for @groupCreatedMsg.
  ///
  /// In ur_Latn, this message translates to:
  /// **'\"{name}\" group ban gaya'**
  String groupCreatedMsg(String name);

  /// No description provided for @groupCreated.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Group create ho gaya'**
  String get groupCreated;

  /// No description provided for @newNameMsg.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Naya naam: \"{name}\"'**
  String newNameMsg(String name);

  /// No description provided for @groupRenamed.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Group rename ho gaya'**
  String get groupRenamed;

  /// No description provided for @renameGroup.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Group rename karo'**
  String get renameGroup;

  /// No description provided for @newGroupTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Naya Group'**
  String get newGroupTitle;

  /// No description provided for @currentName.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Abhi naam: {name}'**
  String currentName(String name);

  /// No description provided for @newGroupSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Numbers ko group mein rakhein — group ko SMS bhejna aasan'**
  String get newGroupSub;

  /// No description provided for @groupName.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Group ka naam'**
  String get groupName;

  /// No description provided for @groupNameHint.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Masalan: Customers'**
  String get groupNameHint;

  /// No description provided for @groupSuggestions.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Customers|Students|VIP Clients|Family|Wholesale|Staff'**
  String get groupSuggestions;

  /// No description provided for @tplSaleTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sale / Offer'**
  String get tplSaleTitle;

  /// No description provided for @tplSale.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Assalam-o-Alaikum! Hamari special offer shuru ho gayi hai — har cheez par 20% off. Aaj hi tashreef layen. Shukriya!'**
  String get tplSale;

  /// No description provided for @tplPaymentTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Payment reminder'**
  String get tplPaymentTitle;

  /// No description provided for @tplPayment.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Reminder: Aap ki payment 25 tareekh tak jama karwa dein. Kisi sawal ke liye isi number par rabta karein. Shukriya.'**
  String get tplPayment;

  /// No description provided for @tplClassTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Class / Meeting'**
  String get tplClassTitle;

  /// No description provided for @tplClass.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Dear Student, kal ki class subah 10 baje hogi. Waqt par pohanchein aur assignment saath layen.'**
  String get tplClass;

  /// No description provided for @tplEidTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Eid Mubarak (Urdu)'**
  String get tplEidTitle;

  /// No description provided for @tplEid.
  ///
  /// In ur_Latn, this message translates to:
  /// **'عید مبارک! آپ اور آپ کے اہل خانہ کو دلی مبارکباد۔ اللہ آپ کو ڈھیروں خوشیاں دے۔'**
  String get tplEid;

  /// No description provided for @blockNoMessage.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Pehle message likhein'**
  String get blockNoMessage;

  /// No description provided for @blockNoRecipients.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Koi recipient nahi — numbers chunein'**
  String get blockNoRecipients;

  /// No description provided for @blockGateway.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Gateway connected nahi — pehle phone connect karein'**
  String get blockGateway;

  /// No description provided for @blockRunning.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Pehli sending abhi chal rahi hai — Queue dekhein'**
  String get blockRunning;

  /// No description provided for @blockPackage.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Package mein itne SMS baqi nahi'**
  String get blockPackage;

  /// No description provided for @sendConfirmTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Send karun?'**
  String get sendConfirmTitle;

  /// No description provided for @sendConfirmMsg.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} numbers, {segments} SMS segment each — kul {total} SMS.'**
  String sendConfirmMsg(int count, int segments, int total);

  /// No description provided for @sendConfirmTestNote.
  ///
  /// In ur_Latn, this message translates to:
  /// **'\n\nTest mode ON hai — asal SMS nahi jayenge, sirf simulation.'**
  String get sendConfirmTestNote;

  /// No description provided for @yesSend.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Haan, Send karo'**
  String get yesSend;

  /// No description provided for @notNow.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Abhi nahi'**
  String get notNow;

  /// No description provided for @queueCreated.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} numbers ki queue ban gayi — live progress dekhein'**
  String queueCreated(int count);

  /// No description provided for @sendingStarted.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sending shuru!'**
  String get sendingStarted;

  /// No description provided for @buildingQueue.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Queue ban rahi hai…'**
  String get buildingQueue;

  /// No description provided for @composeSubMobile.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Message likhein aur ek click mein bhejein'**
  String get composeSubMobile;

  /// No description provided for @phonePreviewQ.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Phone par kaisa lagega?'**
  String get phonePreviewQ;

  /// No description provided for @stickySummary.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} numbers · {total} SMS'**
  String stickySummary(int count, int total);

  /// No description provided for @composeSubDesktop.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Recipients chunein, message likhein — ek click mein sab tak'**
  String get composeSubDesktop;

  /// No description provided for @gatewayNotConnectedShort.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Gateway connected nahi'**
  String get gatewayNotConnectedShort;

  /// No description provided for @gatewayWarnMsg.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Android phone se rabta nahi — SMS queue ruk jayegi. Pehle gateway connect karein.'**
  String get gatewayWarnMsg;

  /// No description provided for @openGateway.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Gateway kholo'**
  String get openGateway;

  /// No description provided for @modeSelected.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Selected'**
  String get modeSelected;

  /// No description provided for @countNumbers.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} numbers'**
  String countNumbers(int count);

  /// No description provided for @countGroups.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} groups'**
  String countGroups(int count);

  /// No description provided for @whoToSend.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Kisko bhejna hai?'**
  String get whoToSend;

  /// No description provided for @threeWays.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Teen tareeqay — sab, group, ya chune hue'**
  String get threeWays;

  /// No description provided for @noGroupMade.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Abhi koi group nahi bana.'**
  String get noGroupMade;

  /// No description provided for @makeGroup.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Group banao'**
  String get makeGroup;

  /// No description provided for @noneSelectedTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Abhi koi number chuna nahi'**
  String get noneSelectedTitle;

  /// No description provided for @noneSelectedMsg.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Database mein checkbox se numbers chunein, phir yahan wapas aayen.'**
  String get noneSelectedMsg;

  /// No description provided for @openDatabase.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Database kholo'**
  String get openDatabase;

  /// No description provided for @willGoToSuffix.
  ///
  /// In ur_Latn, this message translates to:
  /// **' numbers ko jayega'**
  String get willGoToSuffix;

  /// No description provided for @message.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @smsRule.
  ///
  /// In ur_Latn, this message translates to:
  /// **'English: 160 = 1 SMS · Urdu: 70 = 1 SMS'**
  String get smsRule;

  /// No description provided for @templates.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Templates'**
  String get templates;

  /// No description provided for @messageHint.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Yahan apna message likhein…\n\nMasalan: Assalam-o-Alaikum! Hamari nayi offer…'**
  String get messageHint;

  /// No description provided for @encUnicode.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Urdu / Unicode'**
  String get encUnicode;

  /// No description provided for @encGsm.
  ///
  /// In ur_Latn, this message translates to:
  /// **'English (GSM)'**
  String get encGsm;

  /// No description provided for @charsCount.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} characters'**
  String charsCount(int count);

  /// No description provided for @charsLeft.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} characters baqi is SMS mein'**
  String charsLeft(int count);

  /// No description provided for @longMessage.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Lamba message {segments} hisson mein jayega (har hissa {per} characters) — kharcha {segments}x.'**
  String longMessage(int segments, int per);

  /// No description provided for @summary.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @summarySub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Bhejne se pehle ek nazar'**
  String get summarySub;

  /// No description provided for @recipients.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Recipients'**
  String get recipients;

  /// No description provided for @perNumber.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Har number ko'**
  String get perNumber;

  /// No description provided for @segmentsValue.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} SMS segment'**
  String segmentsValue(int count);

  /// No description provided for @totalSms.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Kul SMS (andazan kharcha)'**
  String get totalSms;

  /// No description provided for @packageLeftShort.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Package baqi'**
  String get packageLeftShort;

  /// No description provided for @estTime.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Andazan waqt'**
  String get estTime;

  /// No description provided for @estTimeValue.
  ///
  /// In ur_Latn, this message translates to:
  /// **'~{duration} ({secs}s waqfa)'**
  String estTimeValue(String duration, int secs);

  /// No description provided for @dailyLimitWarn.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Roz ki limit {limit} hai — aaj sirf {left} baqi. Baqi SMS limit ke baad jayenge.'**
  String dailyLimitWarn(int limit, int left);

  /// No description provided for @testModeOnNote.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Test mode ON — asal SMS nahi jayenge (Settings se band karein).'**
  String get testModeOnNote;

  /// No description provided for @simLabel.
  ///
  /// In ur_Latn, this message translates to:
  /// **'SMS · SIM 1'**
  String get simLabel;

  /// No description provided for @stopTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sending rokni hai?'**
  String get stopTitle;

  /// No description provided for @stopMsg.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Baqi {count} numbers ko SMS nahi jayega. Ye dobara shuru nahi hogi — phir se bhejna padega.'**
  String stopMsg(int count);

  /// No description provided for @stopConfirm.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Haan, Stop karo'**
  String get stopConfirm;

  /// No description provided for @stoppedMsg.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} SMS gaye, baqi rok diye gaye'**
  String stoppedMsg(int count);

  /// No description provided for @sendingStopped.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sending rok di gayi'**
  String get sendingStopped;

  /// No description provided for @pausedHint.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Jab chahein Resume dabayein'**
  String get pausedHint;

  /// No description provided for @sendingPaused.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sending pause'**
  String get sendingPaused;

  /// No description provided for @connectGatewayFirst.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Pehle gateway connect karein'**
  String get connectGatewayFirst;

  /// No description provided for @resumeFailed.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Resume nahi ho saka'**
  String get resumeFailed;

  /// No description provided for @sendingResumed.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sending dobara shuru'**
  String get sendingResumed;

  /// No description provided for @resume.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @retryQueued.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} failed numbers dobara queue mein'**
  String retryQueued(int count);

  /// No description provided for @retrying.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Dobara bhej rahe hain'**
  String get retrying;

  /// No description provided for @queueSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Bhejte hue live dekhein ke kya ho raha hai'**
  String get queueSub;

  /// No description provided for @queueEmptyTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Abhi koi sending nahi chal rahi'**
  String get queueEmptyTitle;

  /// No description provided for @queueEmptyMsg.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Naya SMS bhejein — yahan har number ki live halat nazar aayegi.'**
  String get queueEmptyMsg;

  /// No description provided for @stop.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @pause.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @startedAgo.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{audience} · shuru {ago}'**
  String startedAgo(String audience, String ago);

  /// No description provided for @newSmsShort.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Naya SMS'**
  String get newSmsShort;

  /// No description provided for @queueStoppedTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sending ruki hui hai'**
  String get queueStoppedTitle;

  /// No description provided for @stateRunning.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Bhej rahe hain'**
  String get stateRunning;

  /// No description provided for @statePaused.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Paused'**
  String get statePaused;

  /// No description provided for @stateStopped.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Rok di gayi'**
  String get stateStopped;

  /// No description provided for @stateCompleted.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Mukammal'**
  String get stateCompleted;

  /// No description provided for @testModeFast.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Test mode · tez simulation'**
  String get testModeFast;

  /// No description provided for @nextSmsIn.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Agla SMS {secs}s mein'**
  String nextSmsIn(int secs);

  /// No description provided for @doneOfTotalNumbers.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{done} / {total} numbers'**
  String doneOfTotalNumbers(int done, int total);

  /// No description provided for @delayTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Waqfa (delay)'**
  String get delayTitle;

  /// No description provided for @delaySub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'SIM block hone se bachne ke liye'**
  String get delaySub;

  /// No description provided for @afterEachSms.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Har SMS ke baad'**
  String get afterEachSms;

  /// No description provided for @delayBest.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Behtareen: 20–30 sec'**
  String get delayBest;

  /// No description provided for @delayLow.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Kam waqfa — SIM block ka khatra'**
  String get delayLow;

  /// No description provided for @delayHigh.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Lamba waqfa — sending sust'**
  String get delayHigh;

  /// No description provided for @liveList.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Live list'**
  String get liveList;

  /// No description provided for @liveListSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Jo gaya woh tick ho jata hai'**
  String get liveListSub;

  /// No description provided for @filterEmpty.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Is filter mein kuch nahi'**
  String get filterEmpty;

  /// No description provided for @moreNumbers.
  ///
  /// In ur_Latn, this message translates to:
  /// **'…aur {count} numbers'**
  String moreNumbers(int count);

  /// No description provided for @doneTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sending mukammal!'**
  String get doneTitle;

  /// No description provided for @doneSummary.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{total} mein {sent} gaye, {failed} failed'**
  String doneSummary(int total, int sent, int failed);

  /// No description provided for @tookTime.
  ///
  /// In ur_Latn, this message translates to:
  /// **' · {duration} laga'**
  String tookTime(String duration);

  /// No description provided for @viewReport.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Report dekho'**
  String get viewReport;

  /// No description provided for @retryFailedCount.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Failed dobara bhejo ({count})'**
  String retryFailedCount(int count);

  /// No description provided for @rangeWeek.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Pichle 7 din'**
  String get rangeWeek;

  /// No description provided for @rangeMonth.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Pichle 30 din'**
  String get rangeMonth;

  /// No description provided for @rangeAll.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sab waqt'**
  String get rangeAll;

  /// No description provided for @rangeCustom.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Custom'**
  String get rangeCustom;

  /// No description provided for @pickRange.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Date range chunein'**
  String get pickRange;

  /// No description provided for @apply.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Lagao'**
  String get apply;

  /// No description provided for @exportEmpty.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Is filter mein export karne ko kuch nahi'**
  String get exportEmpty;

  /// No description provided for @emptyReport.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Khaali report'**
  String get emptyReport;

  /// No description provided for @csvHeader.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Date,Time,Name,Number,Message,Status,Failed reason,Campaign'**
  String get csvHeader;

  /// No description provided for @exportDone.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{file} ({count} rows) — Excel mein khulegi. Ab client ko bhej dein.'**
  String exportDone(String file, int count);

  /// No description provided for @reportExported.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Report export ho gayi'**
  String get reportExported;

  /// No description provided for @exportFailed.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Export nahi ho saka. Dobara koshish karein.'**
  String get exportFailed;

  /// No description provided for @exportBtn.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Export (Excel/CSV)'**
  String get exportBtn;

  /// No description provided for @total.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @reportsMobileSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{range} · {count} SMS'**
  String reportsMobileSub(String range, int count);

  /// No description provided for @campaignDetail.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Campaign detail'**
  String get campaignDetail;

  /// No description provided for @filter.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @reportsSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Purani sending ki tafseel — export karke client ko bhejein'**
  String get reportsSub;

  /// No description provided for @allShort.
  ///
  /// In ur_Latn, this message translates to:
  /// **'All'**
  String get allShort;

  /// No description provided for @colDateTime.
  ///
  /// In ur_Latn, this message translates to:
  /// **'DATE & TIME'**
  String get colDateTime;

  /// No description provided for @colNumber.
  ///
  /// In ur_Latn, this message translates to:
  /// **'NUMBER'**
  String get colNumber;

  /// No description provided for @colMessage.
  ///
  /// In ur_Latn, this message translates to:
  /// **'MESSAGE'**
  String get colMessage;

  /// No description provided for @colStatus.
  ///
  /// In ur_Latn, this message translates to:
  /// **'STATUS'**
  String get colStatus;

  /// No description provided for @colFailReason.
  ///
  /// In ur_Latn, this message translates to:
  /// **'FAILED KI WAJAH'**
  String get colFailReason;

  /// No description provided for @rangeOfSms.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{from}–{to} / {total} SMS'**
  String rangeOfSms(int from, int to, int total);

  /// No description provided for @pageOf.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Page {page} / {pages}'**
  String pageOf(int page, int pages);

  /// No description provided for @reportEmptyTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Is filter mein koi SMS nahi'**
  String get reportEmptyTitle;

  /// No description provided for @reportEmptyMsg.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Date range ya status badal kar dekhein.'**
  String get reportEmptyMsg;

  /// No description provided for @campaign.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Campaign'**
  String get campaign;

  /// No description provided for @allCampaigns.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Saari campaigns'**
  String get allCampaigns;

  /// No description provided for @filters.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @filtersSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Report ko chhota karein'**
  String get filtersSub;

  /// No description provided for @dateRange.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Date range'**
  String get dateRange;

  /// No description provided for @days7.
  ///
  /// In ur_Latn, this message translates to:
  /// **'7 din'**
  String get days7;

  /// No description provided for @days30.
  ///
  /// In ur_Latn, this message translates to:
  /// **'30 din'**
  String get days30;

  /// No description provided for @customEllipsis.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Custom…'**
  String get customEllipsis;

  /// No description provided for @status.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @customRange.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Custom range…'**
  String get customRange;

  /// No description provided for @campaignDates.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Campaign ki dates'**
  String get campaignDates;

  /// No description provided for @campaignsHeader.
  ///
  /// In ur_Latn, this message translates to:
  /// **'CAMPAIGNS — detail ke liye click karein'**
  String get campaignsHeader;

  /// No description provided for @sentFailed.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{sent} sent · {failed} failed'**
  String sentFailed(int sent, int failed);

  /// No description provided for @closeDetail.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Detail band karo'**
  String get closeDetail;

  /// No description provided for @smsPerNumber.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{count} SMS/number'**
  String smsPerNumber(int count);

  /// No description provided for @resendFailed.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Failed dobara bhejo'**
  String get resendFailed;

  /// No description provided for @campaignTooltip.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Is campaign ki detail'**
  String get campaignTooltip;

  /// No description provided for @secPackage.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Package / Limit'**
  String get secPackage;

  /// No description provided for @secPackageSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Roz ki limit aur baqi SMS'**
  String get secPackageSub;

  /// No description provided for @secSending.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sending'**
  String get secSending;

  /// No description provided for @secSendingSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Waqfa aur test mode'**
  String get secSendingSub;

  /// No description provided for @secAccountSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Password tabdeel karein'**
  String get secAccountSub;

  /// No description provided for @secDemo.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Demo data'**
  String get secDemo;

  /// No description provided for @secDemoSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Backend lagne tak sample data'**
  String get secDemoSub;

  /// No description provided for @settingsSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Panel ki bunyadi settings ek jagah'**
  String get settingsSub;

  /// No description provided for @settingsSubDesktop.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Panel ki bunyadi settings ek jagah — har section ka apna Save'**
  String get settingsSubDesktop;

  /// No description provided for @limitsSavedMsg.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Roz ki limit {limit} · package mein {left} SMS'**
  String limitsSavedMsg(int limit, int left);

  /// No description provided for @limitsSavedTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Package / Limit save'**
  String get limitsSavedTitle;

  /// No description provided for @dailyLimit.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Roz ki SMS limit'**
  String get dailyLimit;

  /// No description provided for @dailyLimitHint.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Is se zyada aik din mein nahi jayenge'**
  String get dailyLimitHint;

  /// No description provided for @packageRemaining.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Package mein baqi SMS'**
  String get packageRemaining;

  /// No description provided for @packageHelper.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Package recharge ke baad yahan update karein (manual)'**
  String get packageHelper;

  /// No description provided for @sendingSavedTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sending settings save'**
  String get sendingSavedTitle;

  /// No description provided for @defaultDelay.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Har SMS ke baad default waqfa'**
  String get defaultDelay;

  /// No description provided for @best.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Behtareen'**
  String get best;

  /// No description provided for @recommended.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Tajweez: 20–30 sec'**
  String get recommended;

  /// No description provided for @testModeLabel.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Test mode {mode}'**
  String testModeLabel(String mode);

  /// No description provided for @testModeOnSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Asal SMS nahi jayenge — sirf simulation'**
  String get testModeOnSub;

  /// No description provided for @testModeOffSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Asal SMS gateway se jayenge'**
  String get testModeOffSub;

  /// No description provided for @oldPasswordRequired.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Purana password likhein'**
  String get oldPasswordRequired;

  /// No description provided for @min6.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Kam az kam 6 characters'**
  String get min6;

  /// No description provided for @passwordsMismatch.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Dono naye password ek jaise nahi'**
  String get passwordsMismatch;

  /// No description provided for @oldPasswordWrong.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Purana password galat hai'**
  String get oldPasswordWrong;

  /// No description provided for @passwordNotChanged.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Password nahi badla'**
  String get passwordNotChanged;

  /// No description provided for @loginWithNew.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Agli dafa naye password se login karein'**
  String get loginWithNew;

  /// No description provided for @passwordChanged.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Password tabdeel ho gaya'**
  String get passwordChanged;

  /// No description provided for @strength0.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Bohat kamzor'**
  String get strength0;

  /// No description provided for @strength1.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Kamzor'**
  String get strength1;

  /// No description provided for @strength2.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Theek'**
  String get strength2;

  /// No description provided for @strength3.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Mazboot'**
  String get strength3;

  /// No description provided for @strength4.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Bohat mazboot'**
  String get strength4;

  /// No description provided for @hide.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Chhupao'**
  String get hide;

  /// No description provided for @show.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Dikhao'**
  String get show;

  /// No description provided for @usernameLine.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Username: admin · Administrator'**
  String get usernameLine;

  /// No description provided for @oldPassword.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Purana password'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Naya password'**
  String get newPassword;

  /// No description provided for @newPasswordAgain.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Naya password dobara'**
  String get newPasswordAgain;

  /// No description provided for @changePassword.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Password badlo'**
  String get changePassword;

  /// No description provided for @demoInfo.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Abhi panel sample data par chal raha hai. Phase 3 mein asal database (backend) lagega.'**
  String get demoInfo;

  /// No description provided for @demoCounts.
  ///
  /// In ur_Latn, this message translates to:
  /// **'{numbers} numbers · {groups} groups · {campaigns} campaigns'**
  String demoCounts(String numbers, String groups, String campaigns);

  /// No description provided for @loadSample.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sample data load karo'**
  String get loadSample;

  /// No description provided for @sampleLoadedMsg.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sample numbers, groups aur campaigns wapas aa gaye'**
  String get sampleLoadedMsg;

  /// No description provided for @sampleData.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sample data'**
  String get sampleData;

  /// No description provided for @clearAll.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sab saaf karo'**
  String get clearAll;

  /// No description provided for @clearAllTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Sara data saaf karna hai?'**
  String get clearAllTitle;

  /// No description provided for @clearAllMsg.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Saare numbers, groups aur reports hat jayenge (khaali screens dekhne ke liye). Sample data dobara load kar sakte hain.'**
  String get clearAllMsg;

  /// No description provided for @clearAllConfirm.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Haan, saaf karo'**
  String get clearAllConfirm;

  /// No description provided for @clearedMsg.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Panel ab khaali hai — empty states dekh sakte hain'**
  String get clearedMsg;

  /// No description provided for @dataCleared.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Data saaf'**
  String get dataCleared;

  /// No description provided for @versionLine.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Version {version} · Browser + Mobile'**
  String versionLine(String version);

  /// No description provided for @gwConnectedMsg.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Phone online hai — SMS bhej sakte hain'**
  String get gwConnectedMsg;

  /// No description provided for @gwConnectedTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Gateway connect ho gaya'**
  String get gwConnectedTitle;

  /// No description provided for @gwDisconnectTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Gateway disconnect karna hai?'**
  String get gwDisconnectTitle;

  /// No description provided for @gwDisconnectMsg.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Phone se rabta khatam ho jayega aur chalti queue ruk jayegi. Dobara connect karne ke liye pairing karni hogi.'**
  String get gwDisconnectMsg;

  /// No description provided for @gwDisconnectConfirm.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Haan, disconnect'**
  String get gwDisconnectConfirm;

  /// No description provided for @gwQueueStopsUntil.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Queue ruk jayegi jab tak dobara connect na ho'**
  String get gwQueueStopsUntil;

  /// No description provided for @gwDisconnected.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Gateway disconnect'**
  String get gwDisconnected;

  /// No description provided for @important.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Zaroori'**
  String get important;

  /// No description provided for @keepPhoneOn.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Phone on, charged aur internet par rakho — warna queue ruk jayegi.'**
  String get keepPhoneOn;

  /// No description provided for @gwSubMobile.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Jis phone/SIM se SMS jata hai'**
  String get gwSubMobile;

  /// No description provided for @gwSubDesktop.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Jis Android phone aur SIM se asal SMS jata hai, us ki halat'**
  String get gwSubDesktop;

  /// No description provided for @connecting.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Connect ho raha hai…'**
  String get connecting;

  /// No description provided for @noPhoneConnection.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Phone se rabta nahi'**
  String get noPhoneConnection;

  /// No description provided for @sim.
  ///
  /// In ur_Latn, this message translates to:
  /// **'SIM'**
  String get sim;

  /// No description provided for @signal.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Signal'**
  String get signal;

  /// No description provided for @battery.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Battery'**
  String get battery;

  /// No description provided for @charging.
  ///
  /// In ur_Latn, this message translates to:
  /// **' · charging'**
  String get charging;

  /// No description provided for @lastSeen.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Last seen'**
  String get lastSeen;

  /// No description provided for @disconnect.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @reconnect.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Dobara connect karo'**
  String get reconnect;

  /// No description provided for @guide1.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Phone on karein aur charger lagayein'**
  String get guide1;

  /// No description provided for @guide2.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Internet (WiFi ya mobile data) on karein'**
  String get guide2;

  /// No description provided for @guide3.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Phone par \"{app} Gateway\" app kholein'**
  String guide3(String app);

  /// No description provided for @guide4.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Pairing QR scan karein ya code daalein'**
  String get guide4;

  /// No description provided for @guide5.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Green \"Connected\" ka intezar karein'**
  String get guide5;

  /// No description provided for @guideTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Dobara connect kaise karein?'**
  String get guideTitle;

  /// No description provided for @guideSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'In steps par amal karein'**
  String get guideSub;

  /// No description provided for @pairing.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Pairing'**
  String get pairing;

  /// No description provided for @pairingSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Android gateway app mein ye QR scan karein ya code daalein'**
  String get pairingSub;

  /// No description provided for @orEnterCode.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Ya ye code likhein'**
  String get orEnterCode;

  /// No description provided for @codeCopied.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Pairing code copy ho gaya'**
  String get codeCopied;

  /// No description provided for @newCode.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Naya code banao'**
  String get newCode;

  /// No description provided for @oldCodeInvalid.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Purana code ab kaam nahi karega'**
  String get oldCodeInvalid;

  /// No description provided for @newPairingCode.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Naya pairing code'**
  String get newPairingCode;

  /// No description provided for @checkNumber.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Number check karein'**
  String get checkNumber;

  /// No description provided for @testSent.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Test SMS {phone} par bheja — phone check karein'**
  String testSent(String phone);

  /// No description provided for @testSentTitle.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Test SMS gaya'**
  String get testSentTitle;

  /// No description provided for @testFailedMsg.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Gateway connected nahi — test nahi ja saka'**
  String get testFailedMsg;

  /// No description provided for @testFailed.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Test fail'**
  String get testFailed;

  /// No description provided for @yourNumber.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Apna number'**
  String get yourNumber;

  /// No description provided for @sendingNow.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Bhej rahe hain…'**
  String get sendingNow;

  /// No description provided for @sendTestSms.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Test SMS bhejo'**
  String get sendTestSms;

  /// No description provided for @testSms.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Test SMS'**
  String get testSms;

  /// No description provided for @testSmsSub.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Apne number par 1 test SMS bhej kar check karein'**
  String get testSmsSub;

  /// No description provided for @loginNetwork.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Server se rabta nahi ho saka — internet check karke dobara koshish karein.'**
  String get loginNetwork;

  /// No description provided for @syncFailed.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Server par save nahi hua — internet check karein'**
  String get syncFailed;

  /// No description provided for @modeLive.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Live · Supabase'**
  String get modeLive;

  /// No description provided for @modeDemo.
  ///
  /// In ur_Latn, this message translates to:
  /// **'Demo mode'**
  String get modeDemo;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'ur':
      {
        switch (locale.scriptCode) {
          case 'Latn':
            return AppLocalizationsUrLatn();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
