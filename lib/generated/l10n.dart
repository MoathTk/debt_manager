// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Debt Management`
  String get appTitle {
    return Intl.message(
      'Debt Management',
      name: 'appTitle',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Customers`
  String get customers {
    return Intl.message('Customers', name: 'customers', desc: '', args: []);
  }

  /// `Reminders`
  String get reminders {
    return Intl.message('Reminders', name: 'reminders', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Dashboard`
  String get dashboard {
    return Intl.message('Dashboard', name: 'dashboard', desc: '', args: []);
  }

  /// `Total Debts`
  String get totalDebts {
    return Intl.message('Total Debts', name: 'totalDebts', desc: '', args: []);
  }

  /// `Total Payments`
  String get totalPayments {
    return Intl.message(
      'Total Payments',
      name: 'totalPayments',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get pendingReminders {
    return Intl.message(
      'Pending',
      name: 'pendingReminders',
      desc: '',
      args: [],
    );
  }

  /// `Recent Transactions`
  String get recentTransactions {
    return Intl.message(
      'Recent Transactions',
      name: 'recentTransactions',
      desc: '',
      args: [],
    );
  }

  /// `No transactions yet`
  String get noTransactionsYet {
    return Intl.message(
      'No transactions yet',
      name: 'noTransactionsYet',
      desc: '',
      args: [],
    );
  }

  /// `Search customers...`
  String get searchCustomers {
    return Intl.message(
      'Search customers...',
      name: 'searchCustomers',
      desc: '',
      args: [],
    );
  }

  /// `Add Customer`
  String get addCustomer {
    return Intl.message(
      'Add Customer',
      name: 'addCustomer',
      desc: '',
      args: [],
    );
  }

  /// `Edit Customer`
  String get editCustomer {
    return Intl.message(
      'Edit Customer',
      name: 'editCustomer',
      desc: '',
      args: [],
    );
  }

  /// `Customer Name`
  String get customerName {
    return Intl.message(
      'Customer Name',
      name: 'customerName',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number`
  String get customerPhone {
    return Intl.message(
      'Phone Number',
      name: 'customerPhone',
      desc: '',
      args: [],
    );
  }

  /// `Name is required`
  String get nameRequired {
    return Intl.message(
      'Name is required',
      name: 'nameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Phone (optional)`
  String get phoneOptional {
    return Intl.message(
      'Phone (optional)',
      name: 'phoneOptional',
      desc: '',
      args: [],
    );
  }

  /// `No customers yet`
  String get noCustomersYet {
    return Intl.message(
      'No customers yet',
      name: 'noCustomersYet',
      desc: '',
      args: [],
    );
  }

  /// `Add your first customer to get started`
  String get noCustomersMessage {
    return Intl.message(
      'Add your first customer to get started',
      name: 'noCustomersMessage',
      desc: '',
      args: [],
    );
  }

  /// `Debt`
  String get debt {
    return Intl.message('Debt', name: 'debt', desc: '', args: []);
  }

  /// `Payment`
  String get payment {
    return Intl.message('Payment', name: 'payment', desc: '', args: []);
  }

  /// `Amount`
  String get amount {
    return Intl.message('Amount', name: 'amount', desc: '', args: []);
  }

  /// `Note`
  String get note {
    return Intl.message('Note', name: 'note', desc: '', args: []);
  }

  /// `Note (optional)`
  String get noteOptional {
    return Intl.message(
      'Note (optional)',
      name: 'noteOptional',
      desc: '',
      args: [],
    );
  }

  /// `Balance`
  String get balance {
    return Intl.message('Balance', name: 'balance', desc: '', args: []);
  }

  /// `Owes`
  String get owes {
    return Intl.message('Owes', name: 'owes', desc: '', args: []);
  }

  /// `Overpaid`
  String get overpaid {
    return Intl.message('Overpaid', name: 'overpaid', desc: '', args: []);
  }

  /// `Settled`
  String get settled {
    return Intl.message('Settled', name: 'settled', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Phone`
  String get phone {
    return Intl.message('Phone', name: 'phone', desc: '', args: []);
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Customer Detail`
  String get customerDetail {
    return Intl.message(
      'Customer Detail',
      name: 'customerDetail',
      desc: '',
      args: [],
    );
  }

  /// `Add Debt`
  String get addDebt {
    return Intl.message('Add Debt', name: 'addDebt', desc: '', args: []);
  }

  /// `Record Payment`
  String get recordPayment {
    return Intl.message(
      'Record Payment',
      name: 'recordPayment',
      desc: '',
      args: [],
    );
  }

  /// `No transactions yet`
  String get noTransactionsForCustomer {
    return Intl.message(
      'No transactions yet',
      name: 'noTransactionsForCustomer',
      desc: '',
      args: [],
    );
  }

  /// `Record a debt or payment to get started`
  String get noTransactionsMessage {
    return Intl.message(
      'Record a debt or payment to get started',
      name: 'noTransactionsMessage',
      desc: '',
      args: [],
    );
  }

  /// `Total Owed`
  String get totalOwed {
    return Intl.message('Total Owed', name: 'totalOwed', desc: '', args: []);
  }

  /// `Total Paid`
  String get totalPaid {
    return Intl.message('Total Paid', name: 'totalPaid', desc: '', args: []);
  }

  /// `Delete Customer`
  String get deleteCustomer {
    return Intl.message(
      'Delete Customer',
      name: 'deleteCustomer',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this customer?`
  String get confirmDelete {
    return Intl.message(
      'Are you sure you want to delete this customer?',
      name: 'confirmDelete',
      desc: '',
      args: [],
    );
  }

  /// `Select a debt to pay`
  String get selectDebt {
    return Intl.message(
      'Select a debt to pay',
      name: 'selectDebt',
      desc: '',
      args: [],
    );
  }

  /// `Remaining`
  String get remaining {
    return Intl.message('Remaining', name: 'remaining', desc: '', args: []);
  }

  /// `Paid to`
  String get paidTo {
    return Intl.message('Paid to', name: 'paidTo', desc: '', args: []);
  }

  /// `Fully Paid`
  String get fullyPaid {
    return Intl.message('Fully Paid', name: 'fullyPaid', desc: '', args: []);
  }

  /// `No outstanding debts`
  String get noOutstandingDebts {
    return Intl.message(
      'No outstanding debts',
      name: 'noOutstandingDebts',
      desc: '',
      args: [],
    );
  }

  /// `All debts are settled`
  String get noOutstandingDebtsMessage {
    return Intl.message(
      'All debts are settled',
      name: 'noOutstandingDebtsMessage',
      desc: '',
      args: [],
    );
  }

  /// `Edit Payment`
  String get editPayment {
    return Intl.message(
      'Edit Payment',
      name: 'editPayment',
      desc: '',
      args: [],
    );
  }

  /// `Delete Payment`
  String get deletePayment {
    return Intl.message(
      'Delete Payment',
      name: 'deletePayment',
      desc: '',
      args: [],
    );
  }

  /// `Amount cannot exceed remaining balance`
  String get amountCannotExceedRemaining {
    return Intl.message(
      'Amount cannot exceed remaining balance',
      name: 'amountCannotExceedRemaining',
      desc: '',
      args: [],
    );
  }

  /// `Edit Records`
  String get editRecords {
    return Intl.message(
      'Edit Records',
      name: 'editRecords',
      desc: '',
      args: [],
    );
  }

  /// `Edit Debt`
  String get editDebt {
    return Intl.message('Edit Debt', name: 'editDebt', desc: '', args: []);
  }

  /// `Delete Debt`
  String get deleteDebt {
    return Intl.message('Delete Debt', name: 'deleteDebt', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[Locale.fromSubtags(languageCode: 'en')];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
