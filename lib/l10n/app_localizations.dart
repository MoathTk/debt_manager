import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Debt Management'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @totalDebts.
  ///
  /// In en, this message translates to:
  /// **'Total Debts'**
  String get totalDebts;

  /// No description provided for @totalPayments.
  ///
  /// In en, this message translates to:
  /// **'Total Payments'**
  String get totalPayments;

  /// No description provided for @pendingReminders.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingReminders;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @searchCustomers.
  ///
  /// In en, this message translates to:
  /// **'Search customers...'**
  String get searchCustomers;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomer;

  /// No description provided for @editCustomer.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer'**
  String get editCustomer;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// No description provided for @customerPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get customerPhone;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @phoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get phoneOptional;

  /// No description provided for @noCustomersYet.
  ///
  /// In en, this message translates to:
  /// **'No customers yet'**
  String get noCustomersYet;

  /// No description provided for @noCustomersMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your first customer to get started'**
  String get noCustomersMessage;

  /// No description provided for @debt.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get debt;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get payment;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @owes.
  ///
  /// In en, this message translates to:
  /// **'Owes'**
  String get owes;

  /// No description provided for @overpaid.
  ///
  /// In en, this message translates to:
  /// **'Overpaid'**
  String get overpaid;

  /// No description provided for @settled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get settled;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @customerDetail.
  ///
  /// In en, this message translates to:
  /// **'Customer Detail'**
  String get customerDetail;

  /// No description provided for @addDebt.
  ///
  /// In en, this message translates to:
  /// **'Add Debt'**
  String get addDebt;

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get recordPayment;

  /// No description provided for @noTransactionsForCustomer.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsForCustomer;

  /// No description provided for @noTransactionsMessage.
  ///
  /// In en, this message translates to:
  /// **'Record a debt or payment to get started'**
  String get noTransactionsMessage;

  /// No description provided for @totalOwed.
  ///
  /// In en, this message translates to:
  /// **'Total Owed'**
  String get totalOwed;

  /// No description provided for @totalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get totalPaid;

  /// No description provided for @deleteCustomer.
  ///
  /// In en, this message translates to:
  /// **'Delete Customer'**
  String get deleteCustomer;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this customer?'**
  String get confirmDelete;

  /// No description provided for @selectDebt.
  ///
  /// In en, this message translates to:
  /// **'Select a debt to pay'**
  String get selectDebt;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @paidTo.
  ///
  /// In en, this message translates to:
  /// **'Paid to'**
  String get paidTo;

  /// No description provided for @fullyPaid.
  ///
  /// In en, this message translates to:
  /// **'Fully Paid'**
  String get fullyPaid;

  /// No description provided for @noOutstandingDebts.
  ///
  /// In en, this message translates to:
  /// **'No outstanding debts'**
  String get noOutstandingDebts;

  /// No description provided for @noOutstandingDebtsMessage.
  ///
  /// In en, this message translates to:
  /// **'All debts are settled'**
  String get noOutstandingDebtsMessage;

  /// No description provided for @editPayment.
  ///
  /// In en, this message translates to:
  /// **'Edit Payment'**
  String get editPayment;

  /// No description provided for @deletePayment.
  ///
  /// In en, this message translates to:
  /// **'Delete Payment'**
  String get deletePayment;

  /// No description provided for @amountCannotExceedRemaining.
  ///
  /// In en, this message translates to:
  /// **'Amount cannot exceed remaining balance'**
  String get amountCannotExceedRemaining;

  /// No description provided for @editRecords.
  ///
  /// In en, this message translates to:
  /// **'Edit '**
  String get editRecords;

  /// No description provided for @editDebt.
  ///
  /// In en, this message translates to:
  /// **'Edit Debt'**
  String get editDebt;

  /// No description provided for @deleteDebt.
  ///
  /// In en, this message translates to:
  /// **'Delete Debt'**
  String get deleteDebt;

  /// No description provided for @allTransactions.
  ///
  /// In en, this message translates to:
  /// **'All Transactions'**
  String get allTransactions;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @debts.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get debts;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @searchTransactions.
  ///
  /// In en, this message translates to:
  /// **'Search transactions...'**
  String get searchTransactions;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @netBalance.
  ///
  /// In en, this message translates to:
  /// **'Net Balance'**
  String get netBalance;

  /// No description provided for @dateNewest.
  ///
  /// In en, this message translates to:
  /// **'Date (newest first)'**
  String get dateNewest;

  /// No description provided for @dateOldest.
  ///
  /// In en, this message translates to:
  /// **'Date (oldest first)'**
  String get dateOldest;

  /// No description provided for @amountHighest.
  ///
  /// In en, this message translates to:
  /// **'Amount (highest first)'**
  String get amountHighest;

  /// No description provided for @amountLowest.
  ///
  /// In en, this message translates to:
  /// **'Amount (lowest first)'**
  String get amountLowest;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @collectionRate.
  ///
  /// In en, this message translates to:
  /// **'Collection Rate'**
  String get collectionRate;

  /// No description provided for @topDebtors.
  ///
  /// In en, this message translates to:
  /// **'Top Debtors'**
  String get topDebtors;

  /// No description provided for @monthlyTrend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get monthlyTrend;

  /// No description provided for @outstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get outstanding;

  /// No description provided for @noChartData.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noChartData;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @noTopDebtors.
  ///
  /// In en, this message translates to:
  /// **'No outstanding debts'**
  String get noTopDebtors;

  /// No description provided for @ofTotalDebts.
  ///
  /// In en, this message translates to:
  /// **'of total debts'**
  String get ofTotalDebts;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @seedDemoData.
  ///
  /// In en, this message translates to:
  /// **'Seed Demo Data'**
  String get seedDemoData;

  /// No description provided for @clearDemoData.
  ///
  /// In en, this message translates to:
  /// **'Clear Demo Data'**
  String get clearDemoData;

  /// No description provided for @demoDataSeeded.
  ///
  /// In en, this message translates to:
  /// **'Demo data loaded!'**
  String get demoDataSeeded;

  /// No description provided for @demoDataCleared.
  ///
  /// In en, this message translates to:
  /// **'Demo data cleared!'**
  String get demoDataCleared;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @periodDebts.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get periodDebts;

  /// No description provided for @periodPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get periodPayments;

  /// No description provided for @periodTotals.
  ///
  /// In en, this message translates to:
  /// **'Period Totals'**
  String get periodTotals;

  /// No description provided for @currentPeriod.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get currentPeriod;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due Today'**
  String get dueToday;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @completedReminders.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedReminders;

  /// No description provided for @noReminders.
  ///
  /// In en, this message translates to:
  /// **'No reminders'**
  String get noReminders;

  /// No description provided for @noRemindersMessage.
  ///
  /// In en, this message translates to:
  /// **'All debts are settled!'**
  String get noRemindersMessage;

  /// No description provided for @daysOverdue.
  ///
  /// In en, this message translates to:
  /// **'days overdue'**
  String get daysOverdue;

  /// No description provided for @daysUntilDue.
  ///
  /// In en, this message translates to:
  /// **'days until due'**
  String get daysUntilDue;

  /// No description provided for @reminderDetails.
  ///
  /// In en, this message translates to:
  /// **'Reminder Details'**
  String get reminderDetails;

  /// No description provided for @outstandingAmount.
  ///
  /// In en, this message translates to:
  /// **'Outstanding Amount'**
  String get outstandingAmount;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @markCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark Completed'**
  String get markCompleted;

  /// No description provided for @deleteReminder.
  ///
  /// In en, this message translates to:
  /// **'Delete Reminder'**
  String get deleteReminder;

  /// No description provided for @confirmDeleteReminder.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this reminder?'**
  String get confirmDeleteReminder;

  /// No description provided for @reminderDate.
  ///
  /// In en, this message translates to:
  /// **'Reminder Date'**
  String get reminderDate;

  /// No description provided for @confirmMarkCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark this reminder as completed?'**
  String get confirmMarkCompleted;

  /// No description provided for @confirmMarkPending.
  ///
  /// In en, this message translates to:
  /// **'Reopen this reminder?'**
  String get confirmMarkPending;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @confirmDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all reminders in this section?'**
  String get confirmDeleteAll;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @reminderDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Reminder Date (optional)'**
  String get reminderDateOptional;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick Date'**
  String get pickDate;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @afterOneWeek.
  ///
  /// In en, this message translates to:
  /// **'After 1 week'**
  String get afterOneWeek;

  /// No description provided for @afterOneMonth.
  ///
  /// In en, this message translates to:
  /// **'After 1 month'**
  String get afterOneMonth;

  /// No description provided for @searchReminders.
  ///
  /// In en, this message translates to:
  /// **'Search reminders...'**
  String get searchReminders;

  /// No description provided for @sortByDateNewest.
  ///
  /// In en, this message translates to:
  /// **'Date (newest)'**
  String get sortByDateNewest;

  /// No description provided for @sortByDateOldest.
  ///
  /// In en, this message translates to:
  /// **'Date (oldest)'**
  String get sortByDateOldest;

  /// No description provided for @sortByAmountHighest.
  ///
  /// In en, this message translates to:
  /// **'Amount (highest)'**
  String get sortByAmountHighest;

  /// No description provided for @sortByAmountLowest.
  ///
  /// In en, this message translates to:
  /// **'Amount (lowest)'**
  String get sortByAmountLowest;

  /// No description provided for @sortByNameAZ.
  ///
  /// In en, this message translates to:
  /// **'Name (A-Z)'**
  String get sortByNameAZ;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferences;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'DATA MANAGEMENT'**
  String get dataManagement;

  /// No description provided for @administrator.
  ///
  /// In en, this message translates to:
  /// **'administrator'**
  String get administrator;

  /// No description provided for @autoSettledViaReminder.
  ///
  /// In en, this message translates to:
  /// **'Auto-settled via reminder'**
  String get autoSettledViaReminder;

  /// No description provided for @autoSettledViaReminderDelete.
  ///
  /// In en, this message translates to:
  /// **'Auto-settled via reminder delete'**
  String get autoSettledViaReminderDelete;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Phone must be 11 digits'**
  String get phoneInvalid;

  /// No description provided for @joined.
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String joined(Object date);

  /// No description provided for @billion.
  ///
  /// In en, this message translates to:
  /// **'Billion'**
  String get billion;

  /// No description provided for @million.
  ///
  /// In en, this message translates to:
  /// **'Million'**
  String get million;

  /// No description provided for @thousand.
  ///
  /// In en, this message translates to:
  /// **'Thousand'**
  String get thousand;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @cloudSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get cloudSync;

  /// No description provided for @syncStatusConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get syncStatusConnected;

  /// No description provided for @syncStatusSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncStatusSyncing;

  /// No description provided for @syncStatusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get syncStatusOffline;

  /// No description provided for @syncStatusError.
  ///
  /// In en, this message translates to:
  /// **'Sync Error'**
  String get syncStatusError;

  /// No description provided for @lastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last synced'**
  String get lastSynced;

  /// No description provided for @pendingSync.
  ///
  /// In en, this message translates to:
  /// **'Pending sync'**
  String get pendingSync;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// No description provided for @notSynced.
  ///
  /// In en, this message translates to:
  /// **'Not synced'**
  String get notSynced;

  /// No description provided for @signInCancelled.
  ///
  /// In en, this message translates to:
  /// **'Sign in was cancelled'**
  String get signInCancelled;

  /// No description provided for @deleteLocalDatabase.
  ///
  /// In en, this message translates to:
  /// **'Delete Local Database'**
  String get deleteLocalDatabase;

  /// No description provided for @confirmDeleteLocalDatabase.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all local data (customers, debts, payments, reminders). Your cloud data is safe. Continue?'**
  String get confirmDeleteLocalDatabase;

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get welcomeTo;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Manage your debts with ease'**
  String get tagline;

  /// No description provided for @subtitle.
  ///
  /// In en, this message translates to:
  /// **'Digital debt tracking for your business'**
  String get subtitle;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
