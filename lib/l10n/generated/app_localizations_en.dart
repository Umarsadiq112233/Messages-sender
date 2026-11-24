// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get create => 'Create';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get confirmDelete => 'Yes, delete';

  @override
  String get keepIt => 'No, keep it';

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
  String get clear => 'Clear';

  @override
  String get searchHint => 'Search by name or number…';

  @override
  String get decrease => 'Decrease';

  @override
  String get increase => 'Increase';

  @override
  String get noGroup => 'No group';

  @override
  String get toastSuccess => 'Success';

  @override
  String get toastError => 'Error';

  @override
  String get toastWarning => 'Attention';

  @override
  String get toastInfo => 'Info';

  @override
  String get statusSent => 'Sent';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusSending => 'Sending';

  @override
  String get on => 'ON';

  @override
  String get off => 'OFF';

  @override
  String get sec => 'sec';

  @override
  String get appTagline => 'One click — your message to every number';

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
  String get moreTitle => 'More options';

  @override
  String get moreSubtitle => 'Open the rest of the panel from here';

  @override
  String get logoutTitle => 'Log out?';

  @override
  String get logoutMessage =>
      'You will leave the panel. You\'ll need to log in again to come back.';

  @override
  String get logoutConfirm => 'Yes, log out';

  @override
  String get logoutDone => 'You\'ve been logged out. See you soon!';

  @override
  String get logout => 'Log out';

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
  String get topSearchHint => 'Search number or name…';

  @override
  String livePaused(int done, int total) {
    return 'Paused $done/$total';
  }

  @override
  String liveSending(int done, int total) {
    return 'Sending $done/$total';
  }

  @override
  String get gatewayStatusTooltip => 'Gateway / device status';

  @override
  String get account => 'Account';

  @override
  String get adminSubtitle => 'admin · Administrator';

  @override
  String get gatewayDevice => 'Gateway / Device';

  @override
  String get backTooltip => 'Back';

  @override
  String get language => 'Language';

  @override
  String get languageSub => 'Choose the panel language';

  @override
  String get languageChanged => 'Language changed';

  @override
  String get languageDefault => 'Default';

  @override
  String get splashStep1 => 'Getting the panel ready…';

  @override
  String get splashStep2 => 'Loading database…';

  @override
  String get splashStep3 => 'Checking gateway…';

  @override
  String get splashStep4 => 'Just a moment…';

  @override
  String get agoNow => 'just now';

  @override
  String agoMinutes(int count) {
    return '$count min ago';
  }

  @override
  String agoHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String get agoYesterday => 'yesterday';

  @override
  String agoDays(int count) {
    return '$count days ago';
  }

  @override
  String get greetMorning => 'Good morning';

  @override
  String get greetDay => 'Good afternoon';

  @override
  String get greetEvening => 'Good evening';

  @override
  String durHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
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
  String get phoneEmpty => 'Mobile number is required';

  @override
  String get phonePrefix => 'Number must start with 03';

  @override
  String phoneTooShort(int count) {
    return 'Needs 11 digits — you have $count';
  }

  @override
  String get phoneTooLong => 'Number is longer than 11 digits';

  @override
  String get actContactAdded => 'New number added';

  @override
  String get actContactEdited => 'Number updated';

  @override
  String get actContactDeleted => 'Number deleted';

  @override
  String actContactsDeleted(int count) {
    return '$count numbers deleted';
  }

  @override
  String get actContactsDeletedSub => 'Removed from the database';

  @override
  String get actImported => 'Bulk import complete';

  @override
  String actImportedSub(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count numbers added',
      one: '1 number added',
    );
    return '$_temp0';
  }

  @override
  String get actGroupCreated => 'New group created';

  @override
  String get actGroupRenamed => 'Group renamed';

  @override
  String get actGroupDeleted => 'Group deleted';

  @override
  String get actCampaignStarted => 'Campaign started';

  @override
  String actCampaignStartedSub(int count) {
    return 'Going to $count numbers';
  }

  @override
  String get actCampaignSent => 'Campaign sent';

  @override
  String actCampaignSentSub(int sent, int failed) {
    return 'Delivered to $sent · $failed failed';
  }

  @override
  String get actCampaignStopped => 'Campaign stopped';

  @override
  String actCampaignStoppedSub(int sent, int notSent) {
    return '$sent sent · $notSent not sent';
  }

  @override
  String get actCampaignCompleted => 'Campaign complete';

  @override
  String actCampaignCompletedSub(int sent, int failed) {
    return '$sent sent · $failed failed';
  }

  @override
  String get actPasswordChanged => 'Password changed';

  @override
  String get actPasswordChangedSub => 'Account security update';

  @override
  String get actLimitsSaved => 'Package / limit updated';

  @override
  String actLimitsSavedSub(int limit, int left) {
    return 'Daily limit $limit · $left left';
  }

  @override
  String get actSendingSaved => 'Sending settings updated';

  @override
  String actSendingSavedSub(int secs, String mode) {
    return 'Delay ${secs}s · Test mode $mode';
  }

  @override
  String get actGatewayConnected => 'Gateway connected';

  @override
  String actGatewayConnectedSub(String device) {
    return '$device online';
  }

  @override
  String get actGatewayDisconnected => 'Gateway disconnected';

  @override
  String get actGatewayDisconnectedSub => 'Lost connection to the phone';

  @override
  String get actTestSms => 'Test SMS sent';

  @override
  String get failNetworkBusy => 'Network busy — retry';

  @override
  String get failNumberOff => 'Phone is switched off';

  @override
  String get failTimeout => 'Delivery timeout';

  @override
  String get failLowBalance => 'Low SIM balance';

  @override
  String get failLowBalanceHint =>
      'Low balance — check your SIM package/balance';

  @override
  String get failNoPermission =>
      'SMS permission not allowed — allow SMS for this app in Android settings';

  @override
  String get failNoSim => 'Chosen SIM not found — check the Sending SIM in Settings';

  @override
  String get sendingSim => 'Sending SIM';

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
  String get simChoiceCaption => 'SIM choice appears on the Android gateway phone';

  @override
  String get loadSims => 'Load SIMs';

  @override
  String get failNotExist => 'Number doesn\'t exist';

  @override
  String get failStopped => 'Stopped by user';

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
    return 'Retry failed ($count)';
  }

  @override
  String get audTest => 'Test';

  @override
  String get pauseUser => 'You paused it';

  @override
  String get pauseGateway => 'Gateway disconnected — check the phone';

  @override
  String get discLost =>
      'Lost connection to the phone (internet or app is off)';

  @override
  String get discByUser => 'You disconnected it from the panel';

  @override
  String get impNoNumber => 'No number found';

  @override
  String get impInDatabase => 'Already in database';

  @override
  String get impRepeated => 'Repeated in list';

  @override
  String get loginFeat1Title => 'Bulk import';

  @override
  String get loginFeat1Sub => 'Excel / CSV or paste a list — in seconds';

  @override
  String get loginFeat2Title => 'Live sending queue';

  @override
  String get loginFeat2Sub => 'See the status of every SMS';

  @override
  String get loginFeat3Title => 'Reports & export';

  @override
  String get loginFeat3Sub => 'Excel report in one click';

  @override
  String get loginHeadline => 'One click,\nthousands reached.';

  @override
  String get loginHeadlineSub =>
      'Number database, groups, live sending and reports — all in one place.';

  @override
  String get usernameRequired => 'Enter your username';

  @override
  String get passwordRequired => 'Enter your password';

  @override
  String loginWelcomeToast(String name) {
    return 'Welcome, $name! Your panel is ready.';
  }

  @override
  String get loginSuccess => 'Logged in';

  @override
  String get loginWrong => 'Wrong username or password. Please try again.';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String loginSubtitle(String app) {
    return 'Log in to your $app SMS panel';
  }

  @override
  String get loginFailed => 'Login failed';

  @override
  String get username => 'Username';

  @override
  String get usernameHint => 'enter your username';

  @override
  String get password => 'Password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get showPassword => 'Show password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loggingIn => 'Logging in…';

  @override
  String get login => 'Log in';

  @override
  String get forgotTitle => 'Forgot your password?';

  @override
  String get forgotSubtitle => 'Don\'t worry — a reset code will come by SMS';

  @override
  String get registeredMobile => 'Registered mobile number';

  @override
  String get forgotAdminHint =>
      'Or contact the admin (Umar) — they can reset your password.';

  @override
  String get sendResetCode => 'Send reset code';

  @override
  String get enterValidMobile => 'Enter a valid mobile number (03XX-XXXXXXX)';

  @override
  String resetCodeSent(String phone) {
    return 'Reset code sent to $phone (demo).';
  }

  @override
  String get codeSent => 'Code sent';

  @override
  String get demoLogin => 'Demo login:';

  @override
  String get fill => 'Fill';

  @override
  String greetingName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String dashSubtitle(String weekday, String date) {
    return '$weekday, $date — your whole panel at a glance';
  }

  @override
  String get statTotalNumbers => 'Total Numbers';

  @override
  String statInGroups(int count) {
    return 'In $count groups';
  }

  @override
  String get statToday => 'SMS Sent Today';

  @override
  String statDailyLimit(int today, int limit) {
    return '$today / $limit daily limit';
  }

  @override
  String get statTotalSent => 'Total Sent';

  @override
  String statSuccessRate(int rate) {
    return '$rate% success';
  }

  @override
  String get statNoFailures => 'No failures';

  @override
  String get statRetryFromReports => 'Resend from Reports';

  @override
  String get quickAction => 'QUICK ACTION';

  @override
  String get quickTitle => 'Need to send an SMS?';

  @override
  String get quickSubtitle =>
      'Pick a group, write your message — reach everyone in one click.';

  @override
  String get sendNewSms => 'Send New SMS';

  @override
  String get chartTitle => 'SMS in the last 7 days';

  @override
  String chartSubtitleData(String amount) {
    return '$amount SMS delivered successfully';
  }

  @override
  String get chartSubtitleEmpty => 'Your daily graph will appear here';

  @override
  String get emptyNoSmsTitle => 'No SMS sent yet';

  @override
  String get emptyNoSmsMsg =>
      'Send your first SMS — then the daily graph will show here.';

  @override
  String countSent(int count) {
    return '$count sent';
  }

  @override
  String countFailed(int count) {
    return '$count failed';
  }

  @override
  String get today => 'Today';

  @override
  String get todayLower => 'today';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get last5 => 'Last 5 actions';

  @override
  String get noActivityTitle => 'No activity yet';

  @override
  String get noActivityMsg =>
      'Add a number or send an SMS — everything shows up here.';

  @override
  String get packageLimit => 'Package & Limit';

  @override
  String get packageLimitSub => 'Today\'s limit and remaining SMS';

  @override
  String get sentToday => 'Sent today';

  @override
  String get leftToday => 'Left today';

  @override
  String smsCount(int count) {
    return '$count SMS';
  }

  @override
  String get packageLeft => 'Left in package';

  @override
  String get changeLimit => 'Change limit';

  @override
  String get gatewayConnected => 'Gateway Connected';

  @override
  String get gatewayNotConnected => 'Gateway Not Connected';

  @override
  String deviceBattery(String device, int battery) {
    return '$device · $battery% battery';
  }

  @override
  String get checkPhoneQueueStops => 'Check the phone — the queue will stop';

  @override
  String get deleteConfirmTitle => 'Delete this number?';

  @override
  String deleteConfirmMsg(String name, String phone) {
    return '\"$name\" ($phone) will be removed from the database. This can\'t be undone.';
  }

  @override
  String deletedOne(String name) {
    return '$name was removed from the database';
  }

  @override
  String get numberDeleted => 'Number deleted';

  @override
  String deleteManyTitle(int count) {
    return 'Delete $count numbers?';
  }

  @override
  String deleteManyMsg(int count) {
    return 'The $count selected numbers will be permanently removed. This can\'t be undone.';
  }

  @override
  String deleteManyConfirm(int count) {
    return 'Yes, delete $count';
  }

  @override
  String deletedMany(int count) {
    return '$count numbers removed from the database';
  }

  @override
  String get deletedManyTitle => 'Deleted';

  @override
  String numbersSummary(String numbers, String groups) {
    return '$numbers numbers · $groups groups';
  }

  @override
  String get importAction => 'Import';

  @override
  String get sort => 'Sort';

  @override
  String get sortNewest => 'Newest first';

  @override
  String get sortOldest => 'Oldest first';

  @override
  String get sortName => 'Name A–Z';

  @override
  String get colName => 'NAME';

  @override
  String get colMobile => 'MOBILE NUMBER';

  @override
  String get colGroup => 'GROUP';

  @override
  String get colAdded => 'DATE ADDED';

  @override
  String get colActions => 'ACTIONS';

  @override
  String showingRange(int from, int to, int total) {
    return 'Showing $from–$to of $total';
  }

  @override
  String get group => 'Group';

  @override
  String get allGroups => 'All groups';

  @override
  String get dbEmptyTitle => 'Your database is empty';

  @override
  String get dbEmptyMsg =>
      'Add your first number or import many at once from Excel / a list.';

  @override
  String get noResultsTitle => 'No numbers match this search';

  @override
  String get noResultsGroup => 'This group has no numbers yet.';

  @override
  String noResultsQuery(String query) {
    return 'No name or number matches \"$query\".';
  }

  @override
  String get clearFilter => 'Clear filter';

  @override
  String get all => 'All';

  @override
  String numbersFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count numbers found',
      one: '1 number found',
    );
    return '$_temp0';
  }

  @override
  String loadMore(int count) {
    return 'Load more ($count left)';
  }

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get clearSelection => 'Clear selection';

  @override
  String get sendSmsShort => 'Send SMS';

  @override
  String get prev => 'Previous';

  @override
  String get next => 'Next';

  @override
  String dupWithName(String name) {
    return 'This number is already in the database ($name).';
  }

  @override
  String get checkForm => 'Please check the form';

  @override
  String get notSaved => 'Not saved';

  @override
  String get numberSaved => 'Number saved';

  @override
  String get numberInfo => 'Number details';

  @override
  String get onlyMobileRequired => 'Only the mobile number is required';

  @override
  String addedHere(int count) {
    return '$count added';
  }

  @override
  String get saveAndAddAnother => 'Save & Add Another';

  @override
  String get addAnotherShort => '+ Another';

  @override
  String get newNumber => 'New Number';

  @override
  String get newNumberSub => 'Add a number to the database';

  @override
  String get addNumberTitle => 'Add a New Number';

  @override
  String dbHasNumbers(int count) {
    return 'The database has $count numbers';
  }

  @override
  String get tip1 => 'Number starts with 03 and has 11 digits';

  @override
  String get tip2 => 'Typing +92 300… automatically becomes 0300…';

  @override
  String get tip3 => 'Choosing a group makes group SMS easy later';

  @override
  String get tips => 'Tips';

  @override
  String get manyNumbersQ => 'Have lots of numbers?';

  @override
  String get useBulkImport => 'Add them all at once with bulk import';

  @override
  String detailsUpdated(String name) {
    return '$name\'s details were updated';
  }

  @override
  String get changesSaved => 'Changes saved';

  @override
  String get numberNotFound => 'Number not found';

  @override
  String get maybeDeleted => 'This number may have been deleted.';

  @override
  String get backToDb => 'Back to database';

  @override
  String get editDetails => 'Edit details';

  @override
  String get unsavedChanges => 'You\'ve made changes — don\'t forget to save';

  @override
  String get editHint => 'Change any field, then save';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get numberDetails => 'Number details';

  @override
  String get dateAdded => 'Date added';

  @override
  String get smsSentCount => 'SMS sent';

  @override
  String get lastSms => 'Last SMS';

  @override
  String get smsHistory => 'SMS history';

  @override
  String lastNSms(int count) {
    return 'Last $count SMS';
  }

  @override
  String get historyEmptyMsg => 'SMS sent to this number will appear here.';

  @override
  String get dangerZone => 'Danger zone';

  @override
  String get removedForever => 'The number will be removed permanently';

  @override
  String get deleteNumber => 'Delete Number';

  @override
  String get noChanges => 'No changes';

  @override
  String get dupNumber => 'This number is already in the database';

  @override
  String get name => 'Name';

  @override
  String get nameHint => 'e.g. Ali Raza';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get mobileHelper => '11 digits — the dash is added automatically';

  @override
  String savedUnder(String name, String group) {
    return 'Saved as \"$name\" in $group.';
  }

  @override
  String get openThatNumber => 'Open that number';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get noteHint => 'Anything important… (e.g. fee pending)';

  @override
  String get typeName => 'Type a name…';

  @override
  String get livePreview => 'Live preview';

  @override
  String get previewSub => 'How it will look in the database';

  @override
  String get chooseFile => 'Choose an Excel / CSV file';

  @override
  String fileRows(String file, int count) {
    return 'Found $count rows in $file';
  }

  @override
  String get fileRead => 'File read';

  @override
  String get fileError =>
      'This file couldn\'t be read. Try a CSV or .xlsx file.';

  @override
  String get fileProblem => 'File problem';

  @override
  String importedToDb(int count) {
    return '$count numbers added to the database';
  }

  @override
  String get importDone => 'Import complete';

  @override
  String get importBtn => 'Import';

  @override
  String importBtnCount(int count) {
    return 'Import ($count numbers)';
  }

  @override
  String get importSub => 'Add many numbers at once';

  @override
  String get noValidNumbers => 'No valid numbers found — check the list';

  @override
  String get importSubDesktop =>
      'Paste a list or upload an Excel / CSV file — save time';

  @override
  String get whereFrom => 'Where are the numbers?';

  @override
  String get twoWays => 'Two ways — pick the easiest';

  @override
  String get listPaste => 'Paste List';

  @override
  String get fileUpload => 'File Upload';

  @override
  String get whichGroup => 'Which group should these go to?';

  @override
  String get newGroupShort => 'New group';

  @override
  String get pasteHint =>
      'One number per line…\n0300-1234567\nAli Raza, 0321-7654321\n+92 333 1112223';

  @override
  String get pasteTip => 'You can also write \"Name, Number\"';

  @override
  String get fillSample => 'Fill sample';

  @override
  String get dropHere => 'Drop it — we\'ll read it';

  @override
  String get dropFileDesktop => 'Drop an Excel / CSV file here';

  @override
  String get fileFormatsHint =>
      '.xlsx, .csv or .txt — first column name, second number';

  @override
  String get reading => 'Reading…';

  @override
  String get pickFile => 'Choose file';

  @override
  String rowsCount(int count) {
    return '$count rows';
  }

  @override
  String get removeFile => 'Remove file';

  @override
  String get preview => 'Preview';

  @override
  String get previewEmptySub =>
      'Numbers are checked here as soon as you add them';

  @override
  String rowsFound(int count) {
    return '$count rows found';
  }

  @override
  String get nothingYet => 'Nothing yet';

  @override
  String get previewEmptyMsg =>
      'Paste a list or choose a file — each number is checked here.';

  @override
  String get found => 'Found';

  @override
  String get valid => 'Valid';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get badFormat => 'Bad format';

  @override
  String moreRows(int count) {
    return '…and $count more rows';
  }

  @override
  String get step1 => 'Add numbers';

  @override
  String get step2 => 'Check preview';

  @override
  String get step3 => 'Import';

  @override
  String get invalidShort => 'Invalid';

  @override
  String get importComplete => 'Import complete!';

  @override
  String importSummary(int total, int added, int dup, int bad) {
    return '$added of $total added, $dup duplicate, $bad invalid';
  }

  @override
  String groupSuffix(String name) {
    return ' · Group: $name';
  }

  @override
  String get addedLabel => 'Added';

  @override
  String get importMore => 'Import more';

  @override
  String get viewDatabase => 'View database';

  @override
  String groupDeleteTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get groupDeleteEmpty =>
      'This group is empty. It can\'t be restored after deleting.';

  @override
  String groupDeleteWithNumbers(int count) {
    return 'This group has $count numbers. The numbers will NOT be deleted — they move to \"No group\". The group can\'t be restored.';
  }

  @override
  String get groupDeleteConfirm => 'Yes, delete group';

  @override
  String groupRemoved(String name) {
    return '\"$name\" was removed';
  }

  @override
  String groupRemovedMoved(String name, int count) {
    return '\"$name\" removed — $count numbers moved to \"No group\"';
  }

  @override
  String get groupDeleted => 'Group deleted';

  @override
  String get newGroup => 'New Group';

  @override
  String groupsSubtitle(int count) {
    return '$count groups · organise numbers into groups to make sending easy';
  }

  @override
  String get noGroupsTitle => 'No groups yet';

  @override
  String get noGroupsMsg =>
      'Create groups — e.g. \"Customers\", \"Students\" — then SMS a whole group in one click.';

  @override
  String get firstGroup => 'Create your first group';

  @override
  String get numbersWord => ' numbers';

  @override
  String createdOn(String date) {
    return 'Created $date';
  }

  @override
  String get noNumbersYet => 'No numbers yet';

  @override
  String get smsShort => 'SMS';

  @override
  String get smsThisGroup => 'Send SMS to this group';

  @override
  String ungroupedCount(int count) {
    return '$count numbers not in any group';
  }

  @override
  String get createNewGroup => 'Create new group';

  @override
  String get groupNameRequired => 'Enter a group name';

  @override
  String groupNameExists(String name) {
    return 'A group named \"$name\" already exists';
  }

  @override
  String groupCreatedMsg(String name) {
    return 'Group \"$name\" created';
  }

  @override
  String get groupCreated => 'Group created';

  @override
  String newNameMsg(String name) {
    return 'New name: \"$name\"';
  }

  @override
  String get groupRenamed => 'Group renamed';

  @override
  String get renameGroup => 'Rename group';

  @override
  String get newGroupTitle => 'New Group';

  @override
  String currentName(String name) {
    return 'Current name: $name';
  }

  @override
  String get newGroupSub => 'Keep numbers in a group — group SMS becomes easy';

  @override
  String get groupName => 'Group name';

  @override
  String get groupNameHint => 'e.g. Customers';

  @override
  String get groupSuggestions =>
      'Customers|Students|VIP Clients|Family|Wholesale|Staff';

  @override
  String get tplSaleTitle => 'Sale / Offer';

  @override
  String get tplSale =>
      'Hello! Our special offer has started — 20% off everything. Visit us today. Thank you!';

  @override
  String get tplPaymentTitle => 'Payment reminder';

  @override
  String get tplPayment =>
      'Reminder: Please submit your payment by the 25th. For any questions, contact this number. Thank you.';

  @override
  String get tplClassTitle => 'Class / Meeting';

  @override
  String get tplClass =>
      'Dear Student, tomorrow\'s class is at 10 AM. Please be on time and bring your assignment.';

  @override
  String get tplEidTitle => 'Eid Mubarak (Urdu)';

  @override
  String get tplEid =>
      'عید مبارک! آپ اور آپ کے اہل خانہ کو دلی مبارکباد۔ اللہ آپ کو ڈھیروں خوشیاں دے۔';

  @override
  String get blockNoMessage => 'Write a message first';

  @override
  String get blockNoRecipients => 'No recipients — choose numbers';

  @override
  String get blockGateway => 'Gateway not connected — connect the phone first';

  @override
  String get blockRunning => 'A sending is already running — check the queue';

  @override
  String get blockPackage => 'Not enough SMS left in the package';

  @override
  String get sendConfirmTitle => 'Send now?';

  @override
  String sendConfirmMsg(int count, int segments, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      segments,
      locale: localeName,
      other: '$segments SMS segments',
      one: '1 SMS segment',
    );
    return '$count numbers, $_temp0 each — $total SMS in total.';
  }

  @override
  String get sendConfirmTestNote =>
      '\n\nTest mode is ON — no real SMS will be sent, only a simulation.';

  @override
  String get yesSend => 'Yes, send';

  @override
  String get notNow => 'Not now';

  @override
  String queueCreated(int count) {
    return 'Queue created for $count numbers — watch live progress';
  }

  @override
  String get sendingStarted => 'Sending started!';

  @override
  String get buildingQueue => 'Building queue…';

  @override
  String get composeSubMobile => 'Write a message and send it in one click';

  @override
  String get phonePreviewQ => 'How will it look on a phone?';

  @override
  String stickySummary(int count, int total) {
    return '$count numbers · $total SMS';
  }

  @override
  String get composeSubDesktop =>
      'Choose recipients, write a message — reach everyone in one click';

  @override
  String get gatewayNotConnectedShort => 'Gateway not connected';

  @override
  String get gatewayWarnMsg =>
      'No connection to the Android phone — the SMS queue will stop. Connect the gateway first.';

  @override
  String get openGateway => 'Open gateway';

  @override
  String get modeSelected => 'Selected';

  @override
  String countNumbers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count numbers',
      one: '1 number',
    );
    return '$_temp0';
  }

  @override
  String countGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groups',
      one: '1 group',
    );
    return '$_temp0';
  }

  @override
  String get whoToSend => 'Who should get it?';

  @override
  String get threeWays => 'Three ways — everyone, a group, or selected';

  @override
  String get noGroupMade => 'No group has been created yet.';

  @override
  String get makeGroup => 'Create group';

  @override
  String get noneSelectedTitle => 'No numbers selected yet';

  @override
  String get noneSelectedMsg =>
      'Select numbers with the checkboxes in the database, then come back here.';

  @override
  String get openDatabase => 'Open database';

  @override
  String get willGoToSuffix => ' numbers will receive it';

  @override
  String get message => 'Message';

  @override
  String get smsRule => 'English: 160 = 1 SMS · Urdu: 70 = 1 SMS';

  @override
  String get templates => 'Templates';

  @override
  String get messageHint =>
      'Write your message here…\n\nFor example: Hello! Our new offer…';

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
    return '$count characters left in this SMS';
  }

  @override
  String longMessage(int segments, int per) {
    return 'Long message goes in $segments parts ($per characters each) — costs ${segments}x.';
  }

  @override
  String get summary => 'Summary';

  @override
  String get summarySub => 'A quick look before sending';

  @override
  String get recipients => 'Recipients';

  @override
  String get perNumber => 'Per number';

  @override
  String segmentsValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count SMS segments',
      one: '1 SMS segment',
    );
    return '$_temp0';
  }

  @override
  String get totalSms => 'Total SMS (estimated cost)';

  @override
  String get packageLeftShort => 'Package left';

  @override
  String get estTime => 'Estimated time';

  @override
  String estTimeValue(String duration, int secs) {
    return '~$duration (${secs}s delay)';
  }

  @override
  String dailyLimitWarn(int limit, int left) {
    return 'Daily limit is $limit — only $left left today. The rest will go after the limit resets.';
  }

  @override
  String get testModeOnNote =>
      'Test mode ON — no real SMS will be sent (turn it off in Settings).';

  @override
  String get simLabel => 'SMS · SIM 1';

  @override
  String get stopTitle => 'Stop sending?';

  @override
  String stopMsg(int count) {
    return 'The remaining $count numbers won\'t get the SMS. It can\'t be resumed — you\'ll have to send again.';
  }

  @override
  String get stopConfirm => 'Yes, stop';

  @override
  String stoppedMsg(int count) {
    return '$count SMS sent, the rest were stopped';
  }

  @override
  String get sendingStopped => 'Sending stopped';

  @override
  String get pausedHint => 'Press Resume whenever you like';

  @override
  String get sendingPaused => 'Sending paused';

  @override
  String get connectGatewayFirst => 'Connect the gateway first';

  @override
  String get resumeFailed => 'Couldn\'t resume';

  @override
  String get sendingResumed => 'Sending resumed';

  @override
  String get resume => 'Resume';

  @override
  String retryQueued(int count) {
    return '$count failed numbers queued again';
  }

  @override
  String get retrying => 'Resending';

  @override
  String get queueSub => 'Watch live while it sends';

  @override
  String get queueEmptyTitle => 'Nothing is sending right now';

  @override
  String get queueEmptyMsg =>
      'Send a new SMS — the live status of every number shows here.';

  @override
  String get stop => 'Stop';

  @override
  String get pause => 'Pause';

  @override
  String startedAgo(String audience, String ago) {
    return '$audience · started $ago';
  }

  @override
  String get newSmsShort => 'New SMS';

  @override
  String get queueStoppedTitle => 'Sending is paused';

  @override
  String get stateRunning => 'Sending';

  @override
  String get statePaused => 'Paused';

  @override
  String get stateStopped => 'Stopped';

  @override
  String get stateCompleted => 'Completed';

  @override
  String get testModeFast => 'Test mode · fast simulation';

  @override
  String nextSmsIn(int secs) {
    return 'Next SMS in ${secs}s';
  }

  @override
  String doneOfTotalNumbers(int done, int total) {
    return '$done / $total numbers';
  }

  @override
  String get delayTitle => 'Delay';

  @override
  String get delaySub => 'Helps avoid the SIM getting blocked';

  @override
  String get afterEachSms => 'After each SMS';

  @override
  String get delayBest => 'Best: 20–30 sec';

  @override
  String get delayLow => 'Short delay — risk of SIM block';

  @override
  String get delayHigh => 'Long delay — slower sending';

  @override
  String get liveList => 'Live list';

  @override
  String get liveListSub => 'Each sent SMS gets a tick';

  @override
  String get filterEmpty => 'Nothing in this filter';

  @override
  String moreNumbers(int count) {
    return '…and $count more numbers';
  }

  @override
  String get doneTitle => 'Sending complete!';

  @override
  String doneSummary(int total, int sent, int failed) {
    return '$sent of $total sent, $failed failed';
  }

  @override
  String tookTime(String duration) {
    return ' · took $duration';
  }

  @override
  String get viewReport => 'View report';

  @override
  String retryFailedCount(int count) {
    return 'Resend failed ($count)';
  }

  @override
  String get rangeWeek => 'Last 7 days';

  @override
  String get rangeMonth => 'Last 30 days';

  @override
  String get rangeAll => 'All time';

  @override
  String get rangeCustom => 'Custom';

  @override
  String get pickRange => 'Choose date range';

  @override
  String get apply => 'Apply';

  @override
  String get exportEmpty => 'Nothing to export in this filter';

  @override
  String get emptyReport => 'Empty report';

  @override
  String get csvHeader =>
      'Date,Time,Name,Number,Message,Status,Failure reason,Campaign';

  @override
  String exportDone(String file, int count) {
    return '$file ($count rows) — opens in Excel. You can now send it to the client.';
  }

  @override
  String get reportExported => 'Report exported';

  @override
  String get exportFailed => 'Export failed. Please try again.';

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
      'Past sending details — export and send to the client';

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
  String get colFailReason => 'FAILURE REASON';

  @override
  String rangeOfSms(int from, int to, int total) {
    return '$from–$to of $total SMS';
  }

  @override
  String pageOf(int page, int pages) {
    return 'Page $page of $pages';
  }

  @override
  String get reportEmptyTitle => 'No SMS in this filter';

  @override
  String get reportEmptyMsg => 'Try changing the date range or status.';

  @override
  String get campaign => 'Campaign';

  @override
  String get allCampaigns => 'All campaigns';

  @override
  String get filters => 'Filters';

  @override
  String get filtersSub => 'Narrow down the report';

  @override
  String get dateRange => 'Date range';

  @override
  String get days7 => '7 days';

  @override
  String get days30 => '30 days';

  @override
  String get customEllipsis => 'Custom…';

  @override
  String get status => 'Status';

  @override
  String get customRange => 'Custom range…';

  @override
  String get campaignDates => 'Campaign dates';

  @override
  String get campaignsHeader => 'CAMPAIGNS — click for details';

  @override
  String sentFailed(int sent, int failed) {
    return '$sent sent · $failed failed';
  }

  @override
  String get closeDetail => 'Close detail';

  @override
  String smsPerNumber(int count) {
    return '$count SMS/number';
  }

  @override
  String get resendFailed => 'Resend failed';

  @override
  String get campaignTooltip => 'View this campaign';

  @override
  String get secPackage => 'Package / Limit';

  @override
  String get secPackageSub => 'Daily limit and remaining SMS';

  @override
  String get secSending => 'Sending';

  @override
  String get secSendingSub => 'Delay and test mode';

  @override
  String get secAccountSub => 'Change password';

  @override
  String get secDemo => 'Demo data';

  @override
  String get secDemoSub => 'Sample data until the backend is connected';

  @override
  String get settingsSub => 'All basic panel settings in one place';

  @override
  String get settingsSubDesktop =>
      'All basic panel settings in one place — each section has its own Save';

  @override
  String limitsSavedMsg(int limit, int left) {
    return 'Daily limit $limit · $left SMS in package';
  }

  @override
  String get limitsSavedTitle => 'Package / Limit saved';

  @override
  String get dailyLimit => 'Daily SMS limit';

  @override
  String get dailyLimitHint => 'No more than this will go out in a day';

  @override
  String get packageRemaining => 'SMS left in package';

  @override
  String get packageHelper =>
      'Update here after recharging the package (manual)';

  @override
  String get sendingSavedTitle => 'Sending settings saved';

  @override
  String get defaultDelay => 'Default delay after each SMS';

  @override
  String get best => 'Best';

  @override
  String get recommended => 'Recommended: 20–30 sec';

  @override
  String testModeLabel(String mode) {
    return 'Test mode $mode';
  }

  @override
  String get testModeOnSub => 'No real SMS will be sent — simulation only';

  @override
  String get testModeOffSub => 'Real SMS will go through the gateway';

  @override
  String get oldPasswordRequired => 'Enter your current password';

  @override
  String get min6 => 'At least 6 characters';

  @override
  String get passwordsMismatch => 'The new passwords don\'t match';

  @override
  String get oldPasswordWrong => 'Current password is wrong';

  @override
  String get passwordNotChanged => 'Password not changed';

  @override
  String get loginWithNew => 'Use your new password next time you log in';

  @override
  String get passwordChanged => 'Password changed';

  @override
  String get strength0 => 'Very weak';

  @override
  String get strength1 => 'Weak';

  @override
  String get strength2 => 'Fair';

  @override
  String get strength3 => 'Strong';

  @override
  String get strength4 => 'Very strong';

  @override
  String get hide => 'Hide';

  @override
  String get show => 'Show';

  @override
  String get usernameLine => 'Username: admin · Administrator';

  @override
  String get oldPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get newPasswordAgain => 'Confirm new password';

  @override
  String get changePassword => 'Change password';

  @override
  String get demoInfo =>
      'The panel is running on sample data for now. The real database (backend) comes in Phase 3.';

  @override
  String demoCounts(String numbers, String groups, String campaigns) {
    return '$numbers numbers · $groups groups · $campaigns campaigns';
  }

  @override
  String get loadSample => 'Load sample data';

  @override
  String get sampleLoadedMsg => 'Sample numbers, groups and campaigns are back';

  @override
  String get sampleData => 'Sample data';

  @override
  String get clearAll => 'Clear everything';

  @override
  String get clearAllTitle => 'Clear all data?';

  @override
  String get clearAllMsg =>
      'All numbers, groups and reports will be removed (to see the empty screens). You can load sample data again.';

  @override
  String get clearAllConfirm => 'Yes, clear';

  @override
  String get clearedMsg =>
      'The panel is empty now — you can see the empty states';

  @override
  String get dataCleared => 'Data cleared';

  @override
  String versionLine(String version) {
    return 'Version $version · Browser + Mobile';
  }

  @override
  String get gwConnectedMsg => 'The phone is online — you can send SMS';

  @override
  String get gwConnectedTitle => 'Gateway connected';

  @override
  String get gwDisconnectTitle => 'Disconnect the gateway?';

  @override
  String get gwDisconnectMsg =>
      'The connection to the phone will end and any running queue will stop. You\'ll need to pair again to reconnect.';

  @override
  String get gwDisconnectConfirm => 'Yes, disconnect';

  @override
  String get gwQueueStopsUntil => 'The queue stays stopped until you reconnect';

  @override
  String get gwDisconnected => 'Gateway disconnected';

  @override
  String get important => 'Important';

  @override
  String get keepPhoneOn =>
      'Keep the phone on, charged and online — otherwise the queue will stop.';

  @override
  String get gwSubMobile => 'The phone/SIM that sends your SMS';

  @override
  String get gwSubDesktop =>
      'Status of the Android phone and SIM that actually send your SMS';

  @override
  String get connecting => 'Connecting…';

  @override
  String get noPhoneConnection => 'No connection to the phone';

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
  String get reconnect => 'Reconnect';

  @override
  String get guide1 => 'Turn the phone on and plug in the charger';

  @override
  String get guide2 => 'Turn on the internet (WiFi or mobile data)';

  @override
  String guide3(String app) {
    return 'Open the \"$app Gateway\" app on the phone';
  }

  @override
  String get guide4 => 'Scan the pairing QR or enter the code';

  @override
  String get guide5 => 'Wait for the green \"Connected\"';

  @override
  String get guideTitle => 'How to reconnect?';

  @override
  String get guideSub => 'Follow these steps';

  @override
  String get pairing => 'Pairing';

  @override
  String get pairingSub =>
      'Scan this QR in the Android gateway app or enter the code';

  @override
  String get orEnterCode => 'Or enter this code';

  @override
  String get codeCopied => 'Pairing code copied';

  @override
  String get newCode => 'Generate new code';

  @override
  String get oldCodeInvalid => 'The old code will no longer work';

  @override
  String get newPairingCode => 'New pairing code';

  @override
  String get checkNumber => 'Check the number';

  @override
  String testSent(String phone) {
    return 'Test SMS sent to $phone — check the phone';
  }

  @override
  String get testSentTitle => 'Test SMS sent';

  @override
  String get testFailedMsg => 'Gateway not connected — test couldn\'t be sent';

  @override
  String get testFailed => 'Test failed';

  @override
  String get yourNumber => 'Your number';

  @override
  String get sendingNow => 'Sending…';

  @override
  String get sendTestSms => 'Send test SMS';

  @override
  String get testSms => 'Test SMS';

  @override
  String get testSmsSub => 'Send 1 test SMS to your own number to check';

  @override
  String get loginNetwork =>
      'Couldn\'t reach the server — check your internet and try again.';

  @override
  String get syncFailed => 'Couldn\'t save to the server — check your internet';

  @override
  String get modeLive => 'Live · Supabase';

  @override
  String get modeDemo => 'Demo mode';
}
