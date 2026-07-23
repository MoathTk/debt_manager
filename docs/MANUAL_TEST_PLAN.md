# Manual Testing Plan — Local Debt Management System

> **Total: ~185 test cases across 13 phases**
> Execute phases **in order** — each phase assumes previous phases pass.
> For each test case, verify the **expected result** exactly.
> Mark result: **PASS** / **FAIL** (with notes).
> Any FAIL blocks dependent tests — stop and fix before continuing.

---

## PHASE 1: Authentication & Onboarding

### 1.1 First-Time Launch

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 1.1.1 | App launches clean | Uninstall app, install fresh | Shows `LoginScreen` with animated welcome |  **PASS**
| 1.1.2 | Google Sign-In flow | Tap Google Sign-In button, select Google account | Authenticated, DB initializes, redirected to `SubscriptionCheckScreen` |**PASS**
| 1.1.3 | Per-user DB created | After sign-in, check app documents | File `debt_management_{uid}.db` exists; no shared `debt_management.db` |
| 1.1.4 | Auth loading state | During sign-in, observe UI | Shows `CircularProgressIndicator` while auth resolves |**PASS**

### 1.2 Sign Out

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 1.2.1 | Sign out from drawer | Open drawer, tap sign out | Returns to `LoginScreen`. Sync listeners stopped. DB closed. |**PASS**
| 1.2.2 | Provider invalidation | After sign-out, check state | All 8 data providers invalidated. No stale data from previous user. |**PASS**
| 1.2.3 | Sign in as different user | Sign out, sign in with different Google account | New per-user DB created (`debt_management_{newUid}.db`). Empty customer list. No data leaked from Account A. |**PASS**

### 1.3 Account A Legacy Data Migration

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 1.3.1 | Old shared DB migration | If old `debt_management.db` exists with data, sign in | Data auto-copies to per-user DB. Old file deleted. Customer list shows migrated data. |**PASS**
| 1.3.2 | No old DB present | Fresh install, sign in | No migration runs. No errors. Empty customer list. |**PASS**

---

## PHASE 2: Subscription Feature

### 2.1 Subscription Check Screen

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 2.1.1 | Loading state | Sign in for first time (no subscription) | Shows pulsing wallet icon + `LinearProgressIndicator` |**PASS**
| 2.1.2 | No subscription, plan picker | After loading completes with no subscription | Smooth animated transition (fade+scale) to `SubscriptionPlanPickerScreen` |**PASS**
| 2.1.3 | Subscription exists, Home | Sign in with active subscription | Smooth animated transition to `HomeScreen` |**PASS**
| 2.1.4 | Error state with retry | Simulate network error, tap "Sync Now" | Shows error view. Tapping "Sync Now" retries loading. |

### 2.2 Plan Picker Screen

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 2.2.1 | Trial card visible | View plan picker | "Free Trial" card shown with highlighted style |**PASS**
| 2.2.2 | Activate trial | Tap "Free Trial" card | Trial activated (1-minute test duration). Redirected to `HomeScreen`. |**PASS**
| 2.2.3 | Weekly plan card | Tap "Weekly" card | AlertDialog "Contact Admin" shown. OK dismisses it. No subscription created. |**PASS**
| 2.2.4 | Monthly plan card | Tap "Monthly" card | Same "Contact Admin" dialog. No subscription created. |**PASS**
| 2.2.5 | Plan picker not revisitable | After activating trial, go back | Cannot navigate back to plan picker while subscription is active. |**PASS**

### 2.3 Subscription Status Icon (AppBar)

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 2.3.1 | Icon visible when subscribed | Sign in with active subscription | Shield icon with colored dot appears in AppBar | **PASS**
| 2.3.2 | Green dot (active) | Subscription has >1 day remaining | Green dot on shield icon | **PASS**
| 2.3.3 | Orange dot (expiring) | Subscription has <1 day remaining | Orange dot on shield icon | **PASS**
| 2.3.4 | Tap opens popup | Tap the shield icon | Animated popup dialog (fade+scale 350ms) shows subscription details | **PASS**
| 2.3.5 | Dialog content correct | View popup dialog | Shows: plan name, expiry date, time remaining, status badge | **PASS**
| 2.3.6 | Dialog auto-dismiss | Open dialog, wait 4 seconds | Dialog automatically closes | **PASS**
| 2.3.7 | Dialog dismiss by tap outside | Open dialog, tap barrier (outside) | Dialog closes. Screen does NOT go black. | **FAIL**
| 2.3.8 | Pulsing animation | Observe shield icon in header | Pulsing animation (scale 0.92 to 1.0) visible |**PASS**
| 2.3.9 | No subscription, icon hidden | Sign out, sign in with no subscription | Shield icon is `SizedBox.shrink()` (invisible) | **PASS**

### 2.4 Subscription Status Lifecycle

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 2.4.1 | Active status | Trial just activated (within 1 min) | Status: `active`. Green dot. Dialog shows time in minutes. | **PASS**
| 2.4.2 | Expiring status | Wait until <1 min before trial expires | Status: `expiring`. Orange dot. Dialog shows time in minutes. |**PASS**
| 2.4.3 | Grace status | Wait until trial expires (within 1 min after) | Status: `grace`. Red dot. Mutations still allowed. | **PASS**
| 2.4.4 | Blocked status | Wait >1 min after trial expires | Status: `blocked`. Dark red dot. Mutations blocked. | **PASS**
| 2.4.5 | Red dot (blocked) | Subscription blocked | Red.shade900 dot on shield icon | **PASS**

### 2.5 Mutation Guard (Blocked Subscription)

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 2.5.1 | Add customer blocked | Subscription blocked, tap + FAB in Customers | SnackBar: "Subscription expired — read-only mode". No add sheet shown. | **PASS**
| 2.5.2 | Edit customer blocked | Subscription blocked, try to edit customer | SnackBar shown. No edit sheet. |**PASS**
| 2.5.3 | Add debt blocked | Subscription blocked, try to add debt | SnackBar shown. Debt not created. |**PASS**
| 2.5.4 | Record payment blocked | Subscription blocked, try to record payment | SnackBar shown. Payment not recorded. | **PASS**
| 2.5.5 | Add reminder blocked | Subscription blocked, try to add reminder | SnackBar shown. Reminder not created. | **PASS**
| 2.5.6 | Grace period allows writes | Subscription in grace status, try adding customer | Customer added successfully. Grace does NOT block. |**PASS**
| 2.5.7 | Expiring allows writes | Subscription in expiring status, try adding customer | Customer added successfully. Expiring does NOT block. | **FAIL**

### 2.6 Subscription Real-Time Listener

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 2.6.1 | Firebase change reflected | Admin changes expiry in Firebase Console for user doc | App updates subscription state within seconds (real-time) |
| 2.6.2 | No dual-listener overwrite | Admin changes only user doc, NOT admin mirror | App shows new expiry (not overwritten by stale admin mirror). |
| 2.6.3 | Subscription deleted remotely | Admin deletes user's subscription doc from Firestore | App shows plan picker (no subscription) |
| 2.6.4 | Stale cache cleanup | Online + Firestore returns null | Local SQLite subscription deleted + admin mirror deleted. Plan picker shown. |

### 2.7 Subscription on Account Switch

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 2.7.1 | Sign out, sign in | Account A (has subscription) -> sign out -> sign in Account B (no subscription) | Clean slate. Shows plan picker. No Account A data. |
| 2.7.2 | Provider recreated | After switching accounts | `subscriptionProvider` watches `authStateProvider` stream, auto-recreates. New user's subscription loaded. |
| 2.7.3 | Ghost update prevention | Rapidly switch between accounts | No state updates on disposed notifiers. `mounted` guard prevents stale writes. |

### 2.8 Trial Activation

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 2.8.1 | Trial saves locally first | Activate trial with network on | SQLite subscription row created BEFORE Firestore write |
| 2.8.2 | Trial works offline | Turn off network, activate trial | Trial saved to SQLite. User can use app. Firestore write queued for later sync. |
| 2.8.3 | Trial remote failure silent | Simulate Firestore write failure | Trial still works. User sees HomeScreen. Error logged but not shown. |

---

## PHASE 3: Dashboard

### 3.1 Dashboard Overview

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 3.1.1 | Empty state | Fresh account, no data | All stats show 0. "No recent transactions" message. |
| 3.1.2 | Stats grid (2x2) | Add some customers/debts | Total Debts, Total Payments, Customers, Pending Reminders cards show correct counts |
| 3.1.3 | Collection rate | Add debts + payments | Rate = (payments/debts)x100, clamped 0-100% |
| 3.1.4 | Pull-to-refresh | Pull down on dashboard | Data refreshes. Spin indicator visible briefly. |

### 3.2 Dashboard Navigation (Tappable Cards)

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 3.2.1 | Tap Total Debts card | Tap red debts card | Navigates to `AllTransactionsScreen` with debt filter pre-selected |
| 3.2.2 | Tap Total Payments card | Tap green payments card | Navigates to `AllTransactionsScreen` with payment filter pre-selected |
| 3.2.3 | Tap Customers card | Tap blue customers card | Bottom nav switches to Tab 1 (Customers) |
| 3.2.4 | Tap Pending card | Tap yellow pending card | Bottom nav switches to Tab 2 (Reminders) |
| 3.2.5 | Tap Analytics card | Tap analytics/collection rate card | Navigates to `AnalyticsScreen` |
| 3.2.6 | Tap Recent Transactions arrow | Tap forward arrow in recent section | Navigates to `AllTransactionsScreen` (unfiltered) |

### 3.3 Recent Transactions

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 3.3.1 | Shows last transactions | Add 5+ transactions | Dashboard shows most recent transactions |
| 3.3.2 | Tappable transaction opens action sheet | Tap a transaction in recent list | Bottom action sheet with 3 options: Debt, Payment, Edit Records (scoped to that customer) |
| 3.3.3 | Action sheet option 1 - Debt | Tap "Debt" in action sheet | Add debt sheet opens for that customer |
| 3.3.4 | Action sheet option 2 - Payment | Tap "Payment" in action sheet | Record payment sheet opens for that customer |
| 3.3.5 | Action sheet option 3 - Edit | Tap "Edit Records" in action sheet | Navigates to customer detail screen |

---

## PHASE 4: Customer Management

### 4.1 Add Customer

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 4.1.1 | Open add sheet | Tap + FAB in Customers tab | `AddCustomerSheet` slides up |
| 4.1.2 | Add with name only | Enter name, leave phone empty, save | Customer created. Phone is null. |
| 4.1.3 | Add with name + phone | Enter name + phone, save | Customer created with both fields |
| 4.1.4 | Empty name validation | Leave name empty, tap save | Validation error. Customer NOT created. |
| 4.1.5 | Duplicate phone allowed | Add two customers with same phone | Both saved (no unique constraint on phone) |
| 4.1.6 | Owner ID set | Add customer while signed in | `ownerId` field set to current user's UID |
| 4.1.7 | UpdatedAt set | Add customer | `updatedAt` timestamp set automatically |
| 4.1.8 | Sync triggered | Add customer | `schedulePush()` called. Unsynced count increases. |

### 4.2 Customer List

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 4.2.1 | List sorted by newest | Add 3 customers at different times | Most recently added shown first |
| 4.2.2 | Search by name | Type in search bar | Filters customers by name (case-insensitive) |
| 4.2.3 | Search by phone | Type phone number in search bar | Filters customers by phone |
| 4.2.4 | Clear search | Tap X button in search bar | Search cleared. Full list shown. |
| 4.2.5 | Empty state | No customers exist | "No customers yet" with `EmptyState` widget |
| 4.2.6 | Search no results | Search for nonexistent name | "No results" message |

### 4.3 Customer Detail

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 4.3.1 | Open customer detail | Tap customer tile | Opens `CustomerDetailScreen` with customer info |
| 4.3.2 | Balance card shows correct balance | Customer has 100 debt + 30 payment | Balance shows 70 |
| 4.3.3 | Transaction list | Customer has transactions | All transactions listed chronologically |
| 4.3.4 | Empty transaction list | New customer, no transactions | "No transactions for customer" message |
| 4.3.5 | Customer not found | Navigate with invalid ID | "Customer not found" text shown |

### 4.4 Edit Customer

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 4.4.1 | Open edit sheet | Tap edit icon in customer detail AppBar | `EditCustomerSheet` opens with pre-filled values |
| 4.4.2 | Update name | Change name, save | Name updated. `updatedAt` refreshed. |
| 4.4.3 | Update phone | Change phone, save | Phone updated |
| 4.4.4 | Clear phone | Set phone to empty, save | Phone becomes null |
| 4.4.5 | Blocked subscription | Subscription blocked, tap edit | SnackBar "read-only". Edit sheet NOT shown. |

### 4.5 Delete Customer

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 4.5.1 | Cascading delete | Delete customer with debts + reminders | Customer deleted. ALL their transactions deleted. ALL their reminders deleted. |
| 4.5.2 | Dashboard reflects delete | Delete customer, go to dashboard | Stats update (customer count, debt totals decrease) |
| 4.5.3 | Reminders list reflects delete | Delete customer with reminders, go to Reminders tab | Reminders removed from list |

---

## PHASE 5: Transaction Management

### 5.1 Add Debt

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 5.1.1 | Add debt from customer detail | Open customer detail, tap "Debt" in action bar | Add debt sheet opens |
| 5.1.2 | Enter amount | Enter 500, save | Debt of 500 created. Balance increases by 500. |
| 5.1.3 | Enter amount with note | Enter 500, note "Rent", save | Debt created with note |
| 5.1.4 | Amount validation (zero) | Enter 0, save | Validation error |
| 5.1.5 | Amount validation (negative) | Enter negative, save | Validation error |
| 5.1.6 | Create linked reminder | Add debt with "Create reminder" checkbox | Debt + reminder created linked by `debtId` |
| 5.1.7 | Owner ID set | Add debt while signed in | `ownerId` = current UID |
| 5.1.8 | Format display | Debt of 1500 | Displayed as "1,500" (comma-formatted) |

### 5.2 Record Payment

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 5.2.1 | Record payment | Open customer detail, tap "Payment", enter 200, save | Payment of 200 recorded. Balance decreases by 200. |
| 5.2.2 | Balance badge update | Record payment, return to list | Balance badge on customer tile updates |
| 5.2.3 | Partial payment | Customer has 500 debt, pay 200 | Debt remaining: 300. Balance: 300. |
| 5.2.4 | Auto-complete reminder | Pay full amount of debt with linked reminder | Reminder auto-marked as completed |
| 5.2.5 | Payment amount validation | Enter 0, save | Validation error |

### 5.3 Settle Debt

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 5.3.1 | Settle full debt | Customer has 500 debt, 0 payments, tap "Settle" | Payment of 500 auto-created. Balance: 0. |
| 5.3.2 | Settle partial debt | Customer has 500 debt, 200 paid, tap "Settle" | Payment of 300 (remaining) auto-created. Balance: 0. |
| 5.3.3 | Settle with reminders | Settle debt that has linked incomplete reminders | Reminders auto-completed |
| 5.3.4 | Already settled | Customer with 0 balance, "Settle" action | No action / already settled indication |

### 5.4 Update Transaction

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 5.4.1 | Edit debt amount | Edit debt from 500 to 750 | Amount updated. Balance recalculated. |
| 5.4.2 | Edit payment amount | Edit payment from 200 to 300 | Amount updated. Balance recalculated. |
| 5.4.3 | Edit note | Change transaction note | Note updated |
| 5.4.4 | Re-check auto-complete | Edit payment to make total >= debt | Linked reminders auto-completed |

### 5.5 Delete Transaction

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 5.5.1 | Delete debt | Delete a debt transaction | Balance recalculated. Debt removed from list. |
| 5.5.2 | Delete payment | Delete a payment | Balance increases (debt re-opens). Payment removed. |
| 5.5.3 | Soft delete | Delete transaction | `is_deleted=1` in SQLite. `is_synced=0`. Sync will push deletion to Firestore. |

### 5.6 All Transactions Screen

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 5.6.1 | Search by note | Search transaction note text | Filters correctly |
| 5.6.2 | Search by amount | Search "500" | Shows transactions with 500 |
| 5.6.3 | Filter by type - debts | Tap debt filter | Only debts shown |
| 5.6.4 | Filter by type - payments | Tap payment filter | Only payments shown |
| 5.6.5 | Filter by type - all | Tap all | Both types shown |
| 5.6.6 | Sort by date newest | Select sort option | Most recent first |
| 5.6.7 | Sort by amount highest | Select sort option | Highest amount first |
| 5.6.8 | Date range filter | Pick date range | Only transactions in range shown |
| 5.6.9 | Clear date filter | Tap clear | All transactions shown |
| 5.6.10 | Empty - no data | No transactions at all | "No transactions yet" |
| 5.6.11 | Empty - no results | Filters match nothing | "No results" |
| 5.6.12 | Pre-filtered from dashboard | Tap "Total Debts" card on dashboard | Opens with debt filter pre-selected |

---

## PHASE 6: Debt Reminders

### 6.1 Reminder Management

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 6.1.1 | Create reminder (standalone) | Open Reminders tab, add reminder | Reminder created |
| 6.1.2 | Create reminder linked to debt | Add debt with "Create reminder" checkbox | Reminder created with `debtId` linked |
| 6.1.3 | Reminder card color - late | Reminder date is in the past, uncompleted | Red accent |
| 6.1.4 | Reminder card color - today | Reminder date is today, uncompleted | Orange accent |
| 6.1.5 | Reminder card color - future | Reminder date is in the future, uncompleted | Blue accent |
| 6.1.6 | Reminder card color - completed | Completed reminder | Grey accent |

### 6.2 Reminder Filters

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 6.2.1 | Filter: All | Select "All" filter | All reminders shown |
| 6.2.2 | Filter: Late | Select "Late" filter | Only overdue + uncompleted shown |
| 6.2.3 | Filter: Pending | Select "Pending" filter | Only future + uncompleted shown |
| 6.2.4 | Filter: Completed | Select "Completed" filter | Only completed shown |
| 6.2.5 | Status counts | View filter bar | Counts shown for each category |
| 6.2.6 | Search by customer name | Type customer name | Filters correctly |
| 6.2.7 | Search by reminder text | Type reminder message | Filters correctly |
| 6.2.8 | Sort options | Try all sort options | Date newest, oldest, amount highest/lowest, name A-Z |

### 6.3 Mark Reminder Completed

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 6.3.1 | Mark completed from card | Tap "Mark Completed" on reminder card | Reminder marked as completed. Color turns grey. |
| 6.3.2 | Mark completed from detail sheet | Open reminder detail, tap "Mark Completed" | Same result |
| 6.3.3 | Completed triggers payment | Mark completed when debt has remaining balance | Payment auto-created for remaining debt amount |
| 6.3.4 | Disabled when settled | Reminder linked to fully-paid debt | "Mark Completed" button is greyed out / disabled. Tapping does nothing. Shows "Settled" label. |
| 6.3.5 | Disabled when already completed | Reminder already completed | Button disabled. No action on tap. |

### 6.4 Auto-Complete on Full Payment

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 6.4.1 | Pay full debt, reminder auto-complete | Customer has 500 debt with reminder, record payment of 500 | Reminder auto-completed. No manual action needed. |
| 6.4.2 | Settle, reminder auto-complete | Customer has 500 debt with reminder, settle | Reminder auto-completed |
| 6.4.3 | Multiple reminders auto-complete | Debt has 3 linked reminders, pay full amount | All 3 reminders auto-completed |
| 6.4.4 | Edit payment to settle, auto-complete | Edit payment so total payments = debt amount | Reminders auto-completed |

### 6.5 Reminder Detail Sheet

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 6.5.1 | Open detail sheet | Tap reminder card | Bottom sheet with full details |
| 6.5.2 | Shows customer name | View sheet | Correct customer name displayed |
| 6.5.3 | Shows amount | View sheet | Correct debt amount shown |
| 6.5.4 | Shows reminder date | View sheet | Correct date displayed |

### 6.6 Reminders Tab Badge

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 6.6.1 | Badge shows overdue count | Have 3 overdue reminders | Red badge on Tab 2 showing "3" |
| 6.6.2 | Badge clears | Mark all overdue as completed | Badge disappears |
| 6.6.3 | Future reminders not counted | Have future reminders only | No badge |

---

## PHASE 7: Analytics Screen

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 7.1.1 | Open from dashboard | Tap analytics card | `AnalyticsScreen` opens |
| 7.1.2 | Collection progress ring | Has debts + payments | Ring shows correct collection rate percentage |
| 7.1.3 | Period totals | View period section | Correct totals for current period |
| 7.1.4 | Weekly view | Toggle to weekly | Shows weekly aggregated data |
| 7.1.5 | Monthly view | Toggle to monthly | Shows monthly aggregated data |
| 7.1.6 | Debt-to-payment ratio | View chart | Visual comparison of debts vs payments |
| 7.1.7 | Top debtors chart | Have multiple debtors | Shows highest-debt customers |
| 7.1.8 | Empty state | No data | Charts show 0 values, no errors |

---

## PHASE 8: Settings & Drawer

### 8.1 Drawer

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 8.1.1 | Open drawer | Tap gear icon in AppBar | Drawer slides from right, 85% screen width |
| 8.1.2 | User profile | View drawer header | Shows current user's name, email, avatar |
| 8.1.3 | Close drawer | Tap outside drawer or swipe | Drawer closes smoothly |
| 8.1.4 | Sync section visible | View drawer | Sync controls shown |

### 8.2 Language Switching

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 8.2.1 | Switch to Arabic | Open drawer, select Arabic | Entire UI switches to Arabic (RTL layout) |
| 8.2.2 | Switch to English | Open drawer, select English | UI switches to English (LTR layout) |
| 8.2.3 | Arabic persistence | Switch to Arabic, close app, reopen | App remembers Arabic |
| 8.2.4 | Arabic content | Switch to Arabic, navigate all screens | All text in Arabic. No English strings leaked. |
| 8.2.5 | RTL layout correctness | Arabic mode, check all screens | Text aligns right. Layout is mirrored. Icons in correct positions. |

### 8.3 Theme Switching

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 8.3.1 | Switch to dark | Open drawer, select dark theme | App switches to dark theme |
| 8.3.2 | Switch to light | Open drawer, select light theme | App switches to light theme |
| 8.3.3 | Theme persistence | Switch to dark, close app, reopen | Dark theme persists |
| 8.3.4 | Dark theme consistency | Dark mode, navigate all screens | All screens use dark theme. No light-theme elements. |
| 8.3.5 | Light theme consistency | Light mode, navigate all screens | All screens use light theme. |

---

## PHASE 9: Sync (Offline-First)

### 9.1 Online Sync

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 9.1.1 | Initial sync | Sign in with data in Firestore | Data pulled from Firestore to local SQLite. UI populated. |
| 9.1.2 | Add data, push | Add customer while online | Customer synced to Firestore. `is_synced=1` after sync. |
| 9.1.3 | Sync indicator | Observe sync icon in AppBar | Shows syncing animation during push/pull |
| 9.1.4 | Unsynced count | Add data, check sync state | Unsynced count increases before sync, decreases after |
| 9.1.5 | Manual sync | Tap sync button in drawer | Triggers `syncNow()`. Pushes all unsynced data. |

### 9.2 Real-Time Firestore Listeners

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 9.2.1 | Customer added in Firestore | Have 2 devices. Add customer on Device A | Device B shows customer within seconds (via WebSocket listener) |
| 9.2.2 | Transaction changed in Firestore | Device A adds transaction | Device B shows updated data |
| 9.2.3 | Reminder changed in Firestore | Device A adds reminder | Device B shows updated reminder |
| 9.2.4 | Provider invalidation on listener | Firestore data changes | All relevant Riverpod providers invalidated. UI updates. |
| 9.2.5 | Family provider invalidation | Transaction added for customer X | `customerByIdProvider(X)`, `customerBalanceProvider(X)`, `debtsWithRemainingProvider(X)` all invalidated |

### 9.3 Offline Mode

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 9.3.1 | Offline, add customer | Turn off network, add customer | Customer saved to SQLite. `is_synced=0`. |
| 9.3.2 | Offline, add debt | Turn off network, add debt | Debt saved locally. `is_synced=0`. |
| 9.3.3 | Offline, record payment | Turn off network, record payment | Payment saved locally. `is_synced=0`. |
| 9.3.4 | Offline, read data | Turn off network, navigate app | All existing local data readable. No errors. |
| 9.3.5 | Offline indicator | Turn off network | Sync status shows `offline` |

### 9.4 Sync Recovery

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 9.4.1 | Reconnect, auto-sync | Go offline, add data, reconnect | Auto-sync triggers. All unsynced data pushed to Firestore. `is_synced=1`. |
| 9.4.2 | Retry on failure | Simulate network failure during sync | Status goes to `error`. Auto-retry with backoff (30s, 60s, 120s). |
| 9.4.3 | Debounced push | Add multiple customers quickly | Push debounced (2s). Only one sync triggered. |

### 9.5 Owner Scoping

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 9.5.1 | Data isolation | Account A adds customer, sign out, sign in as Account B | Account B does NOT see Account A's customers |
| 9.5.2 | Firestore scoping | Check Firestore structure | Data under `users/{uid}/customers/`, `users/{uid}/transactions/`, `users/{uid}/reminders/` |

---

## PHASE 10: Admin — Subscribers Dashboard

### 10.1 Access Control

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 10.1.1 | Admin sees admin section | Sign in as admin user, open drawer | "ADMIN" section visible in drawer |
| 10.1.2 | Non-admin cannot see section | Sign in as regular user, open drawer | "ADMIN" section NOT visible |
| 10.1.3 | Non-admin direct access | Non-admin navigates to subscribers dashboard URL | "Access Denied" view with lock icon |
| 10.1.4 | Admin role from Firestore | Check Firestore `users/{uid}` doc | `role: "admin"` field present |

### 10.2 Subscribers List

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 10.2.1 | List displays subscribers | Open subscribers dashboard | All subscribers listed, sorted by expiry date (soonest first) |
| 10.2.2 | Stats row | View top of screen | Shows Total, Active, Expiring, Expired counts |
| 10.2.3 | Refresh | Tap refresh button in AppBar | Stream reloads |
| 10.2.4 | Empty state | No subscribers exist | "No subscribers" message |
| 10.2.5 | Subscriber status badge | View subscriber tile | Correct status badge (active=green, expiring=orange, expired=red) |
| 10.2.6 | Plan label | View subscriber tile | Shows plan name (Trial/Weekly/Monthly) |

### 10.3 Update Expiry Sheet

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 10.3.1 | Open update sheet | Tap edit on subscriber tile | Bottom sheet with date picker + quick buttons |
| 10.3.2 | Date picker | Tap calendar row, select date | Date updates in field |
| 10.3.3 | Quick button +15 min | Tap "+15 min" | Expiry extended by 15 minutes from now/current |
| 10.3.4 | Quick button +1 week | Tap "+1 week" | Expiry extended by 7 days |
| 10.3.5 | Quick button +1 month | Tap "+1 month" | Expiry extended by 30 days |
| 10.3.6 | Save | Select new date, save | Both Firestore docs updated (user doc + admin mirror). SnackBar "Expiry updated". |
| 10.3.7 | Cancel | Tap outside or back | No changes saved |
| 10.3.8 | Expired subscriber base | Subscriber is expired, open sheet | Quick buttons extend from `DateTime.now()` (not from old expiry) |

### 10.4 Expire Now

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 10.4.1 | Expire now button | Tap red block icon on subscriber tile | Confirmation dialog |
| 10.4.2 | Confirm expire | Confirm in dialog | Expiry set to now. Both docs updated. Subscriber status goes to expired. |
| 10.4.3 | Cancel expire | Cancel in dialog | No changes |

### 10.5 Subscription Mirror Consistency

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 10.5.1 | Admin changes, user sees it | Admin updates expiry, check user's app | User's app shows new expiry (via real-time listener) |
| 10.5.2 | Both docs updated | Admin updates via subscribers dashboard | Both `users/{uid}/subscription/status` AND `subscriptions/{uid}` updated via batch write |

---

## PHASE 11: Localization (EN/AR)

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 11.1 | All EN strings | English mode, navigate all screens | Every string in English. No Arabic text. |
| 11.2 | All AR strings | Arabic mode, navigate all screens | Every string in Arabic. No English text. |
| 11.3 | Subscription strings EN | English, subscription screens | All subscription strings localized |
| 11.4 | Subscription strings AR | Arabic, subscription screens | All subscription strings localized |
| 11.5 | Status dialog strings | Open status icon popup in both langs | All 6 status dialog strings localized (EN+AR) |
| 11.6 | Error messages | Trigger errors in both langs | Error messages localized |
| 11.7 | Number formatting | Arabic mode, view amounts | Thousands separators correct for locale |
| 11.8 | Date formatting | Both modes, view dates | Dates displayed in correct format |

---

## PHASE 12: Edge Cases & Error Handling

### 12.1 Data Integrity

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 12.1.1 | Balance calculation | Customer has multiple debts and payments | Balance = sum(debts) - sum(payments) for non-deleted records |
| 12.1.2 | Balance excludes soft-deleted | Delete a payment, check balance | Balance recalculated without deleted payment |
| 12.1.3 | Dashboard stats consistency | Add/delete data, check dashboard | Stats match actual data |
| 12.1.4 | Debt remaining calculation | Debt of 500, payment of 200 | `remaining` = 300. Displayed correctly in customer detail. |

### 12.2 UI Edge Cases

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 12.2.1 | InfoRow overflow | Long customer name in info row | `Flexible` prevents overflow. Text truncated with ellipsis. |
| 12.2.2 | Balance badge large number | Balance of 1,998,000,000,250 | Shows compact format: "1998 billion" (EN) / "1998 مليار" (AR) |
| 12.2.3 | Balance badge small number | Balance of 500 | Shows "500" (no truncation) |
| 12.2.4 | Add Customer FAB | View customers screen with data | Circle FAB with `Icons.add` |
| 12.2.5 | Subscription dialog double-pop | Open status icon, tap barrier to dismiss | Dialog closes. Screen does NOT go black. |

### 12.3 App Lifecycle

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 12.3.1 | Background to foreground | Open app, switch to another app, return | App resumes. Data still present. Sync resumes. |
| 12.3.2 | Kill and reopen | Kill app, reopen | Data persists (SQLite). Auth state persists. Subscription check runs. |
| 12.3.3 | Low memory | Open app with large dataset | App doesn't crash. No data loss. |

---

## PHASE 13: Charts & Visuals

| # | Test | Steps | Expected Result |
|---|------|-------|----------------|
| 13.1 | Line chart (analytics) | Add data over time, view analytics | Line chart renders with data points |
| 13.2 | Bar chart | View debt-to-payment ratio | Bar chart renders correctly |
| 13.3 | Pie/donut chart | View collection distribution | Pie/donut chart renders |
| 13.4 | Empty charts | No data | Charts show empty state, no errors |

---

## Summary

| Phase | Area | Test Cases |
|-------|------|------------|
| 1 | Auth & Onboarding | 9 |
| 2 | **Subscription** | **30** |
| 3 | Dashboard | 14 |
| 4 | Customer Management | 16 |
| 5 | Transaction Management | 22 |
| 6 | Debt Reminders | 19 |
| 7 | Analytics | 8 |
| 8 | Settings & Drawer | 13 |
| 9 | Sync | 18 |
| 10 | Admin Dashboard | 16 |
| 11 | Localization | 8 |
| 12 | Edge Cases | 8 |
| 13 | Charts & Visuals | 4 |
| **Total** | | **~185** |
