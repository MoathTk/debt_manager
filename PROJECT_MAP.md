# Local Debt Management System - Project Map

## Project Overview
A mobile Flutter application for local merchants in Al-Anbar, Iraq to digitize paper-based debt records. Offline-first architecture with SQLite, bilingual (AR/EN) support, and a roadmap to cloud sync via Firebase.

- **State Management**: Riverpod
- **Database**: SQLite (sqflite)
- **UI Framework**: Material 3
- **Language**: Bilingual (Arabic + English) with RTL support
- **Number Format**: Western numerals (0-9)

---

## Directory Structure

```
lib/
  main.dart                          # App entry point with ProviderScope
  data/
    database_helper.dart              # SQLite singleton (init, create, close)
    models/
      customer.dart                   # Customer model
      transaction.dart                # Transaction model (aliased as 'model' in repos)
      debt_reminder.dart              # DebtReminder model
    repositories/
      customer_repository.dart        # Customer CRUD + search
      transaction_repository.dart     # Transaction CRUD + balance/stats queries
      debt_reminder_repository.dart   # Reminder CRUD + due/pending queries
  Providers/
    database_provider.dart            # Riverpod providers for DB, repos, stats
  Modules/                            # (empty - future feature modules)
  screens/                            # (empty - future UI screens)
  widgets/                            # (empty - future shared widgets)
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
- Fields: `id?`, `name`, `phone`, `createdAt`, `firebaseId?`
- Methods: `toMap()`, `fromMap()`, `copyWith()`

### Transaction (`lib/data/models/transaction.dart`)
- Fields: `id?`, `customerId`, `amount`, `type`, `note?`, `date`, `firebaseId?`
- Constants: `Transaction.debt = 0`, `Transaction.payment = 1`
- Getters: `isDebt`, `isPayment`
- Methods: `toMap()`, `fromMap()`, `copyWith()`
- **Note**: Imported with alias `as model` in repositories to avoid name collision with sqflite's Transaction

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
| `search(query)` | `List<Customer>` | Search by name or phone (LIKE) |
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
| `getCustomerBalance(customerId)` | `double` | Net balance (debts - payments) for a customer |
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

## Riverpod Providers (`lib/Providers/database_provider.dart`)

### Infrastructure Providers
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
- `customerCount` (int)
- `totalDebts` (double)
- `totalPayments` (double)
- `pendingReminders` (int)

---

## Dependencies (`pubspec.yaml`)
| Package | Version | Purpose |
|---|---|---|
| `sqflite` | ^2.4.2 | SQLite database |
| `path` | ^1.9.1 | File path utilities |
| `flutter_riverpod` | ^2.6.1 | State management |
| `intl` | ^0.20.2 | Date/number formatting |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

---

## Key Design Decisions
1. **`firebase_id` columns** exist in customers and transactions tables, reserved for future cloud sync migration
2. **Transaction model** is imported as `model` alias everywhere to avoid conflict with sqflite's internal `Transaction` class
3. **Cascade deletes** ensure referential integrity — deleting a customer removes all associated data
4. **Indexes** on foreign keys and commonly queried columns (type, reminder_date) for performance
5. **All dates stored as TEXT** in ISO 8601 format for SQLite compatibility

---

## Current Status
- Database layer: COMPLETE (models, helper, repositories, providers)
- UI/Screens: NOT STARTED
- Cloud sync: NOT STARTED (firebase_id fields ready)

## Next Steps
- Build UI screens (Dashboard, Customer list, Transaction entry, Reminders)
- Add Provider-based state notifier layers for reactive UI updates
- Local notifications for debt reminders
- Export/backup functionality
- Firebase integration for cloud sync
