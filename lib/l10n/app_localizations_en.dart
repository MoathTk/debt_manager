// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Debt Management';

  @override
  String get home => 'Home';

  @override
  String get customers => 'Customers';

  @override
  String get reminders => 'Reminders';

  @override
  String get language => 'Language';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get totalDebts => 'Total Debts';

  @override
  String get totalPayments => 'Total Payments';

  @override
  String get pendingReminders => 'Pending';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get searchCustomers => 'Search customers...';

  @override
  String get addCustomer => 'Add Customer';

  @override
  String get editCustomer => 'Edit Customer';

  @override
  String get customerName => 'Customer Name';

  @override
  String get customerPhone => 'Phone Number';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get phoneOptional => 'Phone (optional)';

  @override
  String get noCustomersYet => 'No customers yet';

  @override
  String get noCustomersMessage => 'Add your first customer to get started';

  @override
  String get debt => 'Debt';

  @override
  String get payment => 'Payment';

  @override
  String get amount => 'Amount';

  @override
  String get note => 'Note';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get balance => 'Balance';

  @override
  String get owes => 'Owes';

  @override
  String get overpaid => 'Overpaid';

  @override
  String get settled => 'Settled';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get phone => 'Phone';

  @override
  String get name => 'Name';

  @override
  String get customerDetail => 'Customer Detail';

  @override
  String get addDebt => 'Add Debt';

  @override
  String get recordPayment => 'Record Payment';

  @override
  String get noTransactionsForCustomer => 'No transactions yet';

  @override
  String get noTransactionsMessage => 'Record a debt or payment to get started';

  @override
  String get totalOwed => 'Total Owed';

  @override
  String get totalPaid => 'Total Paid';

  @override
  String get deleteCustomer => 'Delete Customer';

  @override
  String get confirmDelete => 'Are you sure you want to delete this customer?';

  @override
  String get selectDebt => 'Select a debt to pay';

  @override
  String get remaining => 'Remaining';

  @override
  String get paidTo => 'Paid to';

  @override
  String get fullyPaid => 'Fully Paid';

  @override
  String get noOutstandingDebts => 'No outstanding debts';

  @override
  String get noOutstandingDebtsMessage => 'All debts are settled';

  @override
  String get editPayment => 'Edit Payment';

  @override
  String get deletePayment => 'Delete Payment';

  @override
  String get amountCannotExceedRemaining =>
      'Amount cannot exceed remaining balance';

  @override
  String get editRecords => 'Edit Records';

  @override
  String get editDebt => 'Edit Debt';

  @override
  String get deleteDebt => 'Delete Debt';
}
