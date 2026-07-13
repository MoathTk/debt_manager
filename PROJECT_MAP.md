# Local Debt Management System - Project Map

## Project Overview
A mobile Flutter application for local merchants in Al-Anbar, Iraq to digitize paper-based debt records. Offline-first architecture with SQLite, bilingual (AR/EN) support with RTL, and a roadmap to cloud sync via Firebase.

- **State Management**: Riverpod
- **Database**: SQLite (sqflite) with 3 tables
- **UI Framework**: Material 3, teal seed color
- **Language**: Bilingual (Arabic + English) with RTL/LTR switching
- **Number Format**: Western numerals (0-9), smart decimal formatting
- **Theme**: Light + Dark mode via themeProvider
- **Locale**: Defaults to Arabic (ar), toggleable via localeProvider
- **Accessibility**: Large text (18px body), high contrast, generous tap targets

---

## Directory Structure

```
lib/
  main.dart                              # App entry point, MaterialApp config
  l10n/
    intl_en.arb                          # English translation keys (57 keys)
    app_ar.arb                           # Arabic translation keys (57 keys)
    app_localizations.dart               # GENERATED: AppLocalizations class
    app_localizations_en.dart            # GENERATED: English delegate
    app_localizations_ar.dart            # GENERATED: Arabic delegate
  data/
    database_helper.dart                 # SQLite singleton (v2, migrations)
    models/
      customer.dart                      # Customer model
      transaction.dart                   # Transaction model (has debtId field)
      debt_reminder.dart                 # DebtReminder model
    repositories/
      customer_repository.dart           # Customer CRUD + search
      transaction_repository.dart        # Transaction CRUD + balance/stats + debt allocation
      debt_reminder_repository.dart      # Reminder CRUD + due/pending
  Providers/
    database_provider.dart               # Riverpod providers + mutations + DashboardStats
    theme_provider.dart                  # Light/Dark ThemeMode provider + ThemeData
    locale_provider.dart                 # AR/EN Locale provider
  screens/
    home_screen.dart                     # Bottom nav shell + settings drawer
    dashboard_screen.dart                # Stats grid + recent transactions
    customers_screen.dart                # Customer list + search + FAB → Customer Detail
    customer_detail_screen.dart          # Header, balance, transactions, action bar
  widgets/
    animated_counter.dart                # Smooth number counter animation
    stat_card.dart                       # Reusable stat card (icon, label, value)
    customer_tile.dart                   # Customer list tile with balance badge
    empty_state.dart                     # Empty state placeholder
    recent_transactions_list.dart        # Last 5 transactions section
    add_customer_sheet.dart              # Bottom sheet form for new customer
    customer_header.dart                 # Gradient avatar, name, phone, join date
    balance_card.dart                    # Net balance with owes/overpaid/settled status
    transaction_tile.dart                # Transaction row with type icon, amount, remaining
    debt_selector_tile.dart              # Radio-selectable debt tile for payment linking
    add_debt_sheet.dart                  # Simple debt entry (amount + note)
    record_payment_sheet.dart            # DraggableScrollableSheet with debt selector
    action_bar.dart                      # 3-button floating bar (Debt, Payment, Edit Records)
    records_list_sheet.dart              # List of all debts + payments, tappable to edit
    edit_debt_sheet.dart                 # Edit/delete debt (validates amount >= total paid)
    edit_payment_sheet.dart              # Edit/delete payment (validates amount <= debt remaining)
    app_snackbar.dart                    # Reusable themed SnackBar helpers
  generated/                             # GENERATED: intl message files
test/
  widget_test.dart                       # Basic smoke test
```

---

## Database Schema (SQLite v2)

### Table: `customers`
| Column | Type | Constraints |
|---|---|---|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| name | TEXT | NOT NULL |
| phone | TEXT | NULL (optional) |
| created_at | TEXT | NOT NULL |
| firebase_id | TEXT | NULL (reserved for cloud sync) |

### Table: `transactions` (v2 — has `debt_id` column)
| Column | Type | Constraints |
|---|---|---|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| customer_id | INTEGER | NOT NULL, FK -> customers(id) ON DELETE CASCADE |
| amount | REAL | NOT NULL |
| type | INTEGER | NOT NULL (0=Debt, 1=Payment) |
| note | TEXT | NULL |
| date | TEXT | NOT NULL |
| debt_id | INTEGER | NULL, FK -> transactions(id) — links payment to specific debt |
| firebase_id | TEXT | NULL (reserved for cloud sync) |

**Indexes**: `idx_transactions_customer_id`, `idx_transactions_type`
**Migration**: v1→v2 adds `debt_id` column via `onUpgrade`

### Table: `debt_reminders`
| Column | Type | Constraints |
|---|---|---|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| customer_id | INTEGER | NOT NULL, FK -> customers(id) ON DELETE CASCADE |
| reminder_date | TEXT | NOT NULL |
| is_completed | INTEGER | NOT NULL DEFAULT 0 |
| message | TEXT | NULL |

**Indexes**: `idx_debt_reminders_customer_id`, `idx_debt_reminders_date`

### ERD Relationships
```
customers (1) ----< (many) transactions
customers (1) ----< (many) debt_reminders
transactions (1) ----< (many) transactions [via debt_id]
```
Deleting a customer cascade-deletes all their transactions and reminders.

---

## Models

### Customer (`lib/data/models/customer.dart`)
- Fields: `id?`, `name`, `phone` (nullable), `createdAt`, `firebaseId?`
- Methods: `toMap()`, `fromMap()`, `copyWith()`

### Transaction (`lib/data/models/transaction.dart`)
- Fields: `id?`, `customerId`, `amount`, `type`, `note?`, `date`, `debtId?`, `firebaseId?`
- Constants: `Transaction.debt = 0`, `Transaction.payment = 1`
- Getters: `isDebt`, `isPayment`
- Methods: `toMap()`, `fromMap()`, `copyWith()`
- **Note**: Imported as `import '../models/transaction.dart' as model` in repositories and widgets

### DebtReminder (`lib/data/models/debt_reminder.dart`)
- Fields: `id?`, `customerId`, `reminderDate`, `isCompleted`, `message?`
- Getter: `completed` (bool from int)
- Methods: `toMap()`, `fromMap()`, `copyWith()`

---

## Repositories

### CustomerRepository (`lib/data/repositories/customer_repository.dart`)
| Method | Returns | Description |
|---|---|---|
| `insert(customer)` | `int` | Insert new customer, returns ID |
| `update(customer)` | `int` | Update by customer.id |
| `delete(id)` | `int` | Delete by ID (cascades) |
| `getAll()` | `List<Customer>` | All customers, ordered by created_at DESC |
| `getById(id)` | `Customer?` | Single customer by ID |
| `search(query)` | `List<Customer>` | Search by name or phone (LIKE), handles null phone |
| `getCustomerCount()` | `int` | Total customer count |

### TransactionRepository (`lib/data/repositories/transaction_repository.dart`)
| Method | Returns | Description |
|---|---|---|
| `insert(transaction)` | `int` | Insert new transaction |
| `update(transaction)` | `int` | Update by transaction.id |
| `delete(id)` | `int` | Delete by ID |
| `getAll()` | `List<Transaction>` | All transactions, ordered by date DESC |
| `getById(id)` | `Transaction?` | Single transaction by ID |
| `getByCustomer(customerId)` | `List<Transaction>` | All transactions for a customer |
| `getByType(type)` | `List<Transaction>` | Filter by debt (0) or payment (1) |
| `getByDateRange(start, end)` | `List<Transaction>` | Filter by date range |
| `getCustomerBalance(customerId)` | `double` | Net balance (debts - payments) |
| `getTotalDebts()` | `double` | Sum of all debt amounts (all customers) |
| `getTotalPayments()` | `double` | Sum of all payment amounts (all customers) |
| `getTransactionCount()` | `int` | Total transaction count |
| `getDebtsWithRemaining(customerId)` | `List<Map>` | Debts with remaining balance (subquery, unpaid only) |
| `getPaymentsForDebt(debtId)` | `double` | Total payments linked to a specific debt |

### DebtReminderRepository (`lib/data/repositories/debt_reminder_repository.dart`)
| Method | Returns | Description |
|---|---|---|
| `insert(reminder)` | `int` | Insert new reminder |
| `update(reminder)` | `int` | Update by reminder.id |
| `delete(id)` | `int` | Delete by ID |
| `getAll()` | `List<DebtReminder>` | All reminders, ordered by reminder_date ASC |
| `getById(id)` | `DebtReminder?` | Single reminder by ID |
| `getByCustomer(customerId)` | `List<DebtReminder>` | All reminders for a customer |
| `getPending()` | `List<DebtReminder>` | Uncompleted reminders |
| `getCompleted()` | `List<DebtReminder>` | Completed reminders |
| `markCompleted(id)` | `int` | Set is_completed = 1 |
| `markPending(id)` | `int` | Set is_completed = 0 |
| `getDueToday()` | `List<DebtReminder>` | Pending reminders where date <= today |
| `getPendingCount()` | `int` | Count of uncompleted reminders |

---

## Riverpod Providers

### Infrastructure Providers (`lib/Providers/database_provider.dart`)
| Provider | Type | Description |
|---|---|---|
| `databaseProvider` | `Provider<DatabaseHelper>` | Database singleton instance |
| `customerRepositoryProvider` | `Provider<CustomerRepository>` | Customer CRUD access |
| `transactionRepositoryProvider` | `Provider<TransactionRepository>` | Transaction CRUD access |
| `debtReminderRepositoryProvider` | `Provider<DebtReminderRepository>` | Reminder CRUD access |

### Data Providers (FutureProvider)
| Provider | Type | Description |
|---|---|---|
| `customersProvider` | `FutureProvider<List<Customer>>` | All customers |
| `customerByIdProvider` | `FutureProvider.family<Customer?, int>` | Customer by ID |
| `transactionsProvider` | `FutureProvider<List<Transaction>>` | All transactions |
| `transactionsByCustomerProvider` | `FutureProvider.family<List<Transaction>, int>` | Transactions per customer |
| `customerBalanceProvider` | `FutureProvider.family<double, int>` | Balance per customer |
| `debtsWithRemainingProvider` | `FutureProvider.family<List<Map>, int>` | Debts with remaining balance per customer |
| `pendingRemindersProvider` | `FutureProvider<List<DebtReminder>>` | All pending reminders |
| `dueTodayProvider` | `FutureProvider<List<DebtReminder>>` | Reminders due today |
| `dashboardStatsProvider` | `FutureProvider<DashboardStats>` | Aggregated dashboard stats |

### DashboardStats class
- `customerCount` (int), `totalDebts` (double), `totalPayments` (double), `pendingReminders` (int)

### Mutation Helpers
- `addCustomer(ref, {name, phone})` — inserts customer and invalidates providers

### Theme Provider (`lib/Providers/theme_provider.dart`)
| Provider | Type | Description |
|---|---|---|
| `themeProvider` | `StateNotifierProvider<ThemeNotifier, ThemeMode>` | Light/Dark mode |
- `ThemeNotifier.toggleTheme()` — switch between light and dark
- `lightTheme` / `darkTheme` — Material 3 themes with teal seed, large text

### Locale Provider (`lib/Providers/locale_provider.dart`)
| Provider | Type | Description |
|---|---|---|
| `localeProvider` | `StateNotifierProvider<LocaleNotifier, Locale>` | AR/EN locale |
- `LocaleNotifier.toggleLocale()` — switch between Arabic and English
- Defaults to Arabic (ar) for local Iraqi merchants
- Full RTL/LTR switching

---

## Localization (i18n)

### Configuration
- `l10n.yaml` — config for `flutter gen-l10n`
- ARB files: `lib/l10n/intl_en.arb` (English), `lib/l10n/app_ar.arb` (Arabic)
- Generated: `AppLocalizations` class in `lib/l10n/`

### Translation Keys (57 keys)
| Key | English | Arabic |
|---|---|---|
| appTitle | Debt Management | إدارة الديون |
| home | Home | الرئيسية |
| customers | Customers | العملاء |
| reminders | Reminders | التذكيرات |
| language | Language | اللغة |
| dashboard | Dashboard | لوحة التحكم |
| totalDebts | Total Debts | إجمالي الديون |
| totalPayments | Total Payments | إجمالي المدفوعات |
| pendingReminders | Pending | المعلقة |
| recentTransactions | Recent Transactions | آخر المعاملات |
| noTransactionsYet | No transactions yet | لا توجد معاملات بعد |
| searchCustomers | Search customers... | البحث عن عملاء... |
| addCustomer | Add Customer | إضافة عميل |
| editCustomer | Edit Customer | تعديل العميل |
| customerName | Customer Name | اسم العميل |
| customerPhone | Phone Number | رقم الهاتف |
| nameRequired | Name is required | الاسم مطلوب |
| phoneOptional | Phone (optional) | الهاتف (اختياري) |
| noCustomersYet | No customers yet | لا يوجد عملاء بعد |
| noCustomersMessage | Add your first customer to get started | أضف أول عميل للبدء |
| debt | Debt | دين |
| payment | Payment | دفعة |
| amount | Amount | المبلغ |
| note | Note | ملاحظة |
| noteOptional | Note (optional) | ملاحظة (اختياري) |
| balance | Balance | الرصيد |
| owes | Owes | عليه |
| overpaid | Overpaid | زائد |
| settled | Settled | مساوي |
| save | Save | حفظ |
| cancel | Cancel | إلغاء |
| phone | Phone | الهاتف |
| name | Name | الاسم |
| customerDetail | Customer Detail | تفاصيل العميل |
| addDebt | Add Debt | إضافة دين |
| recordPayment | Record Payment | تسجيل دفعة |
| noTransactionsForCustomer | No transactions yet | لا توجد معاملات بعد |
| noTransactionsMessage | Record a debt or payment to get started | سجّل ديناً أو دفعة للبدء |
| totalOwed | Total Owed | إجمالي المستحق |
| totalPaid | Total Paid | إجمالي المدفوع |
| deleteCustomer | Delete Customer | حذف العميل |
| confirmDelete | Are you sure you want to delete this customer? | هل أنت متأكد من حذف هذا العميل؟ |
| selectDebt | Select a debt to pay | اختر الدين للسداد |
| remaining | Remaining | المتبقي |
| paidTo | Paid to | مدفوع لـ |
| fullyPaid | Fully Paid | مدفوع بالكامل |
| noOutstandingDebts | No outstanding debts | لا توجد ديون مستحقة |
| noOutstandingDebtsMessage | All debts are settled | جميع الديون مسددة |
| editPayment | Edit Payment | تعديل الدفعة |
| deletePayment | Delete Payment | حذف الدفعة |
| amountCannotExceedRemaining | Amount cannot exceed remaining balance | المبلغ لا يمكن أن يتجاوز المتبقي |
| editRecords | Edit Records | تعديل السجلات |
| editDebt | Edit Debt | تعديل الدين |
| deleteDebt | Delete Debt | حذف الدين |

---

## Screens

### HomeScreen (`lib/screens/home_screen.dart`)
- Custom floating bottom nav bar (`_ModernNavBar`) with animated pill indicator
- Settings drawer (half-width) with language + theme segmented buttons
- IndexedStack preserves scroll state across tabs

### DashboardScreen (`lib/screens/dashboard_screen.dart`)
- 2x2 GridView of StatCard widgets (Total Debts, Total Payments, Pending Reminders, Customers)
- Recent transactions section below
- Pull-to-refresh support

### CustomersScreen (`lib/screens/customers_screen.dart`)
- Search bar at top (filters by name/phone)
- ListView.builder with CustomerTile widgets
- EmptyState when no customers
- FAB opens AddCustomerSheet
- Tap tile → navigates to Customer Detail

### CustomerDetailScreen (`lib/screens/customer_detail_screen.dart`)
- CustomScrollView with CustomerHeader, BalanceCard, transaction list
- Professional action bar at bottom (3 buttons: Debt, Payment, Edit Records)
- Balance card shows net balance with owes/overpaid/settled status
- Transaction list shows remaining for debts, "Paid to" for payments

---

## Widgets

### AnimatedCounter (`lib/widgets/animated_counter.dart`)
- Smooth number counter animation with TweenAnimationBuilder

### StatCard (`lib/widgets/stat_card.dart`)
- Rounded card with icon, label, value, color
- Used in the dashboard stats grid

### CustomerTile (`lib/widgets/customer_tile.dart`)
- ListTile with avatar, name, phone, balance
- Color-coded balance: red (owes), green (settled), teal (overpaid)
- Watches `customerBalanceProvider` for live balance

### EmptyState (`lib/widgets/empty_state.dart`)
- Icon + title + optional message centered on screen
- Used for empty lists

### RecentTransactionsList (`lib/widgets/recent_transactions_list.dart`)
- Shows last 5 transactions
- Color-coded by type (red=debt, green=payment)

### AddCustomerSheet (`lib/widgets/add_customer_sheet.dart`)
- Bottom sheet form with name (required) + phone (optional)
- Form validation on name field
- Inserts customer and shows success SnackBar

### CustomerHeader (`lib/widgets/customer_header.dart`)
- Gradient avatar circle, name, phone, join date

### BalanceCard (`lib/widgets/balance_card.dart`)
- Net balance display with owes/overpaid/settled status and color coding

### TransactionTile (`lib/widgets/transaction_tile.dart`)
- Single transaction row with type icon, amount, date, optional note
- Shows "Remaining: X" for unpaid debts
- Shows "Paid to #id" for linked payments
- Shows "Fully Paid" badge for settled debts

### DebtSelectorTile (`lib/widgets/debt_selector_tile.dart`)
- Radio-selectable debt tile for payment linking
- Shows remaining amount badge

### AddDebtSheet (`lib/widgets/add_debt_sheet.dart`)
- Simple debt entry: amount + note
- Inserts debt transaction

### RecordPaymentSheet (`lib/widgets/record_payment_sheet.dart`)
- DraggableScrollableSheet (0.5→0.85) with debt selector + amount input
- Validates amount > 0 and amount <= remaining
- Shows error SnackBar when amount exceeds remaining

### ActionBar (`lib/widgets/action_bar.dart`)
- 3-button floating bar: Debt (red), Payment (primary), Edit Records (teal)
- Opens respective sheets on tap

### RecordsListSheet (`lib/widgets/records_list_sheet.dart`)
- DraggableScrollableSheet listing all debts + payments
- Each row tappable → opens edit debt or edit payment sheet
- Shows type icon, amount, date, note preview, chevron

### EditDebtSheet (`lib/widgets/edit_debt_sheet.dart`)
- Edit/delete existing debt
- Validates new amount >= total payments already linked
- Shows error SnackBar on validation failure

### EditPaymentSheet (`lib/widgets/edit_payment_sheet.dart`)
- Edit/delete existing payment
- Validates new amount <= debt remaining + old amount (can't overpay)
- Shows error SnackBar on validation failure

### AppSnackBar (`lib/widgets/app_snackbar.dart`)
- `showSuccessSnackBar(context, message)` — floating, primary color, check icon
- `showErrorSnackBar(context, message)` — floating, error color, error icon
- Reusable across all widgets, theme-aware

---

## Number Formatting
Smart decimal format used across all display files:
- `50` → `"50"`, `50.5` → `"50.50"`, `1000.25` → `"1,000.25"`
- Pattern: `n % 1 == 0 ? toStringAsFixed(0) : toStringAsFixed(2)`
- Thousands separator: `replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')`

---

## Design Decisions
1. **`firebase_id` columns** exist in customers and transactions, reserved for future cloud sync
2. **Transaction model** imported as `model` alias to avoid sqflite's internal `Transaction` conflict
3. **Cascade deletes** ensure referential integrity
4. **Indexes** on foreign keys and commonly queried columns for performance
5. **All dates stored as TEXT** in ISO 8601 format
6. **phone field nullable** — not all merchants collect phone numbers
7. **Arabic default locale** — targets local Iraqi merchants first
8. **Screen files under 100 lines** — split into small, focused widgets
9. **IndexedStack** in HomeScreen preserves scroll state across tabs
10. **Large text sizes** (18px body) for readability across all age groups
11. **Debt allocation** — payments linked to specific debts via `debt_id` column
12. **getDebtsWithRemaining** uses subquery (not HAVING without GROUP BY)
13. **DraggableScrollableSheet** for payment and records sheets (expands with content)
14. **Action bar** with 3 gradient buttons replaces stacked FABs
15. **Reusable SnackBar** via `app_snackbar.dart` instead of inline SnackBar code

---

## Dependencies (`pubspec.yaml`)
| Package | Version | Purpose |
|---|---|---|
| `flutter_localizations` (SDK) | — | Official Flutter i18n + RTL |
| `sqflite` | ^2.4.2 | SQLite database |
| `path` | ^1.9.1 | File path utilities |
| `flutter_riverpod` | ^2.6.1 | State management |
| `intl` | ^0.20.2 | Date/number formatting |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

---

## Config Files
| File | Purpose |
|---|---|
| `l10n.yaml` | `flutter gen-l10n` configuration |
| `analysis_options.yaml` | Dart linting rules |

---

## Current Status
- Database layer: ✅ COMPLETE (models, helper v2, repositories, providers, debt allocation)
- Localization: ✅ COMPLETE (57 keys, ARB files, generated AppLocalizations, locale provider)
- Theme: ✅ COMPLETE (Light + Dark mode, theme provider)
- Dashboard screen: ✅ COMPLETE
- Customers screen: ✅ COMPLETE (list, search, add customer)
- Customer Detail screen: ✅ COMPLETE (header, balance card, transaction list)
- Transaction entry: ✅ COMPLETE (add debt, record payment with debt linking)
- Edit Records: ✅ COMPLETE (records list, edit/delete debt, edit/delete payment)
- Reusable SnackBar: ✅ COMPLETE
- Reminders screen: NOT STARTED
- Cloud sync: NOT STARTED (firebase_id fields ready)

## Next Steps
- Reminders screen + scheduling
- Local notifications for debt reminders
- Export/backup functionality
- Firebase integration for cloud sync
