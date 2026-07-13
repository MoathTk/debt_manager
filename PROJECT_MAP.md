# Local Debt Management System - Project Map

## Project Overview
A mobile Flutter application for local merchants in Al-Anbar, Iraq to digitize paper-based debt records. Offline-first architecture with SQLite, bilingual (AR/EN) support with RTL, and a roadmap to cloud sync via Firebase.

- **State Management**: Riverpod
- **Database**: SQLite (sqflite)
- **UI Framework**: Material 3
- **Language**: Bilingual (Arabic + English) with RTL/LTR switching
- **Number Format**: Western numerals (0-9)
- **Theme**: Light + Dark mode with teal seed color
- **Accessibility**: Large text (18px body), high contrast, generous tap targets

---

## Directory Structure

```
lib/
  main.dart                              # App entry point, MaterialApp config
  l10n/
    app_en.arb                           # English translation keys
    app_ar.arb                           # Arabic translation keys
    app_localizations.dart               # GENERATED: AppLocalizations class
    app_localizations_en.dart            # GENERATED: English delegate
    app_localizations_ar.dart            # GENERATED: Arabic delegate
  data/
    database_helper.dart                 # SQLite singleton (init, create, close)
    models/
      customer.dart                      # Customer model
      transaction.dart                   # Transaction model (aliased as 'model')
      debt_reminder.dart                 # DebtReminder model
    repositories/
      customer_repository.dart           # Customer CRUD + search
      transaction_repository.dart        # Transaction CRUD + balance/stats
      debt_reminder_repository.dart      # Reminder CRUD + due/pending
  Providers/
    database_provider.dart               # Riverpod providers + addCustomer helper
    theme_provider.dart                  # Light/Dark ThemeMode provider + ThemeData
    locale_provider.dart                 # AR/EN Locale provider
  screens/
    home_screen.dart                     # Bottom nav shell (2 tabs: Home, Customers)
    dashboard_screen.dart                # Stats grid + recent transactions
    customers_screen.dart                # Customer list + search + FAB
  widgets/
    stat_card.dart                       # Reusable stat card (icon, label, value)
    customer_tile.dart                   # Customer list tile with balance
    empty_state.dart                     # Empty state placeholder
    recent_transactions_list.dart        # Last 5 transactions section
    add_customer_sheet.dart              # Bottom sheet form for new customer
  Modules/                               # (empty - future feature modules)
test/
  widget_test.dart                       # Basic smoke test
```

---

## Database Schema (SQLite v1)

### Table: `customers`
| Column | Type | Constraints |
|---|---|---|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| name | TEXT | NOT NULL |
| phone | TEXT | NULL (optional) |
| created_at | TEXT | NOT NULL |
| firebase_id | TEXT | NULL (reserved for cloud sync) |

### Table: `transactions`
| Column | Type | Constraints |
|---|---|---|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| customer_id | INTEGER | NOT NULL, FK -> customers(id) ON DELETE CASCADE |
| amount | REAL | NOT NULL |
| type | INTEGER | NOT NULL (0=Debt, 1=Payment) |
| note | TEXT | NULL |
| date | TEXT | NOT NULL |
| firebase_id | TEXT | NULL (reserved for cloud sync) |

**Indexes**: `idx_transactions_customer_id`, `idx_transactions_type`

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
```
Deleting a customer cascade-deletes all their transactions and reminders.

---

## Models

### Customer (`lib/data/models/customer.dart`)
- Fields: `id?`, `name`, `phone` (nullable), `createdAt`, `firebaseId?`
- Methods: `toMap()`, `fromMap()`, `copyWith()`

### Transaction (`lib/data/models/transaction.dart`)
- Fields: `id?`, `customerId`, `amount`, `type`, `note?`, `date`, `firebaseId?`
- Constants: `Transaction.debt = 0`, `Transaction.payment = 1`
- Getters: `isDebt`, `isPayment`
- Methods: `toMap()`, `fromMap()`, `copyWith()`
- **Note**: Imported as `import '../models/transaction.dart' as model` in repositories to avoid collision with sqflite

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
| `getTotalDebts()` | `double` | Sum of all debt amounts |
| `getTotalPayments()` | `double` | Sum of all payment amounts |
| `getTransactionCount()` | `int` | Total transaction count |

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

### Translation Keys (35 keys)
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

---

## Screens

### HomeScreen (`lib/screens/home_screen.dart`) ~45 lines
- BottomNavigationBar with 2 tabs (Home, Customers)
- IndexedStack preserves scroll state across tabs
- AppBar with app title

### DashboardScreen (`lib/screens/dashboard_screen.dart`) ~85 lines
- 2x2 GridView of StatCard widgets
- Recent transactions section below
- Pull-to-refresh support

### CustomersScreen (`lib/screens/customers_screen.dart`) ~85 lines
- Search bar at top (filters by name/phone)
- ListView.builder with CustomerTile widgets
- EmptyState when no customers
- FAB opens AddCustomerSheet

---

## Widgets

### StatCard (`lib/widgets/stat_card.dart`) ~45 lines
- Rounded card with icon, label, value, color
- Used in the dashboard stats grid

### CustomerTile (`lib/widgets/customer_tile.dart`) ~85 lines
- ListTile with avatar, name, phone, balance
- Color-coded balance: red (owes), green (settled), teal (overpaid)
- Watches `customerBalanceProvider` for live balance

### EmptyState (`lib/widgets/empty_state.dart`) ~40 lines
- Icon + title + optional message centered on screen
- Used for empty lists

### RecentTransactionsList (`lib/widgets/recent_transactions_list.dart`) ~75 lines
- Shows last 5 transactions
- Color-coded by type (red=debt, green=payment)
- Empty state when no transactions

### AddCustomerSheet (`lib/widgets/add_customer_sheet.dart`) ~85 lines
- Bottom sheet form with name (required) + phone (optional)
- Form validation on name field
- Inserts customer and shows confirmation SnackBar

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
- Database layer: COMPLETE (models, helper, repositories, providers)
- Localization: COMPLETE (ARB files, generated AppLocalizations, locale provider)
- Theme: COMPLETE (Light + Dark mode, theme provider)
- Dashboard screen: COMPLETE
- Customers screen: COMPLETE (list, search, add customer)
- Customer Detail screen: NOT STARTED
- Transaction entry: NOT STARTED
- Reminders screen: NOT STARTED
- Cloud sync: NOT STARTED (firebase_id fields ready)

## Next Steps
- Customer Detail screen (profile, balance, transaction history)
- Transaction entry form (add debt / record payment)
- Reminders screen + scheduling
- Local notifications for debt reminders
- Language/theme toggle button in AppBar
- Export/backup functionality
- Firebase integration for cloud sync
