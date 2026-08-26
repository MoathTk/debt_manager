# Plan: Premium Deep Navy + Gold Theme Redesign

## Context
The app currently uses a deep indigo seed color (`Color(0xFF394486)`) with `ColorScheme.fromSeed`, but has 15+ hardcoded hex colors scattered across 40+ files. The goal is to create a premium, professional "Deep Navy + Gold" color scheme and replace ALL hardcoded colors with centralized semantic tokens.

## Design Direction
**Deep Navy + Gold** — classic finance/banking aesthetic conveying trust, prestige, and value.

---

## Step 1 — Create `lib/core/theme/app_colors.dart`

A centralized color token file with a `ThemeExtension`-compatible class. Provides semantic color access via `Theme.of(context).extension<AppColors>()!`.

### Light Palette
| Token | Hex | Usage |
|-------|-----|-------|
| `navy` | `#0F1D3D` | Primary brand color |
| `gold` | `#C49A3C` | Accent, secondary actions |
| `surface` | `#FAFAF8` | Background |
| `surfaceContainer` | `#F2F0EC` | Cards, containers |
| `debt` | `#C62828` | Debt amounts, negative |
| `debtBg` | `#FDE8E8` | Debt tile backgrounds |
| `payment` | `#2E7D32` | Payments, positive |
| `paymentBg` | `#E8F5E9` | Payment tile backgrounds |
| `customer` | `#1565C0` | Customer accents |
| `reminder` | `#E8A317` | Reminder accents |
| `success` | `#2E7D32` | Completed states |
| `warning` | `#E65100` | Expiring/warning |
| `error` | `#C62828` | Errors, overdue |
| `expired` | `#B71C1C` | Expired/blocked |

### Dark Palette
| Token | Hex | Usage |
|-------|-----|-------|
| `navy` | `#6B8FC7` | Primary (lighter for dark bg) |
| `gold` | `#E0B94D` | Accent (brighter for dark bg) |
| `surface` | `#0A1628` | Background |
| `surfaceContainer` | `#132238` | Cards, containers |
| `debt` | `#EF5350` | Debt amounts (lighter red) |
| `debtBg` | `#3A1518` | Debt tile backgrounds |
| `payment` | `#66BB6A` | Payments (lighter green) |
| `paymentBg` | `#152718` | Payment tile backgrounds |
| `customer` | `#42A5F5` | Customer accents |
| `reminder` | `#FFB74D` | Reminder accents |
| `success` | `#66BB6A` | Completed states |
| `warning` | `#FF9800` | Expiring/warning |
| `error` | `#EF5350` | Errors, overdue |
| `expired` | `#E53935` | Expired/blocked |

---

## Step 2 — Update `lib/Providers/theme_provider.dart`

- Import `AppColors`
- Add `extensions: [AppColors.light, AppColors.dark]` to both `ThemeData`
- Update `ColorScheme.fromSeed` seed colors:
  - Light seed: `#0F1D3D` (deep navy)
  - Dark seed: `#1A2F52` (medium navy)
- Keep `useMaterial3: true`

---

## Step 3 — Replace Hardcoded Colors (40+ files)

### Semantic Mapping — Every hardcoded color → token

| Old Value | New Token | Files Affected |
|-----------|-----------|----------------|
| `Color(0xFFE53935)` | `appColors.debt` | 11 files (charts, tiles, stats) |
| `Color(0xFF43A047)` | `appColors.payment` | 9 files |
| `Color(0xFF2E7D32)` | `appColors.payment` (dark variant handled by theme) | 7 files |
| `Color(0xFFE8F5E9)` | `appColors.paymentBg` | 9 files |
| `Color(0xFFFFEBEE)` | `appColors.debtBg` | 2 files |
| `Color(0xFFF9A825)` | `appColors.reminder` | 2 files |
| `Color(0xFF1E88E5)` | `appColors.customer` | 1 file |
| `Colors.red` | `appColors.error` or `appColors.expired` | 7 files |
| `Colors.orange` | `appColors.warning` | 7 files |
| `Colors.green` | `appColors.success` | 5 files |
| `Colors.blue` | `appColors.customer` | 2 files |
| `Colors.grey` | `cs.outline` or `cs.onSurfaceVariant` | 2 files |
| `Colors.amber.shade*` | `appColors.gold` + tints | 1 file (add_debt_review) |
| `Colors.teal.shade*` | `appColors.customer` + tints | 1 file (add_debt_review) |
| `Colors.white` on gradient | `Colors.white` (keep — always white on dark bg) | 14 files |
| `Colors.transparent` | `Colors.transparent` (keep — literal) | 8 files |
| Dark-mode `0xFFFFB4AB` etc. | Handled by AppColors dark variant | 1 file (balance_badge) |

### Files To Modify (grouped by area)

**Dashboard & Charts (8 files):**
- `lib/screens/dashboard_screen.dart` — 4 stat card colors
- `lib/widgets/charts/debt_payment_ratio_chart.dart` — pie chart colors
- `lib/widgets/charts/debt_payment_trend_chart.dart` — line chart colors
- `lib/widgets/charts/top_debtors_chart.dart` — bar/text colors
- `lib/widgets/charts/collection_progress_ring.dart` — ring colors
- `lib/widgets/charts/monthly_breakdown_chart.dart` — bar chart colors
- `lib/widgets/period_totals_section.dart` — mini card colors
- `lib/widgets/period_navigator.dart` — transparent (no change needed)

**Transactions (5 files):**
- `lib/widgets/recent_transactions_list.dart` — icon bg + text colors
- `lib/widgets/all_transactions_tile.dart` — amount + bg colors
- `lib/widgets/transaction_tile.dart` — payment + badge colors
- `lib/widgets/records_list_sheet.dart` — payment record colors
- `lib/widgets/balance_card.dart` — overpaid text + bg

**Customer & Balance (2 files):**
- `lib/widgets/customerTile/balance_badge.dart` — dark/light mode badge colors
- `lib/widgets/debt_detail_dialog.dart` — paid status + progress colors

**Reminders (4 files):**
- `lib/screens/reminders_screen.dart` — status accent colors
- `lib/widgets/reminder_card.dart` — action button colors
- `lib/widgets/reminder_detail_info.dart` — paid text color
- `lib/widgets/reminder_filters.dart` — filter chip dot colors

**Voice Command (5 files):**
- `lib/features/voice_command/presentation/widgets/add_debt_review.dart` — amber/red/teal
- `lib/features/voice_command/presentation/widgets/record_payment_review.dart` — orange warning
- `lib/features/voice_command/presentation/widgets/find_customer_review.dart` — orange warning
- `lib/features/voice_command/presentation/widgets/delete_debt_review.dart` — white spinner
- `lib/features/voice_command/presentation/widgets/view_history_review.dart` — payment colors

**Subscription (5 files):**
- `lib/features/subscription/presentation/widgets/subscription_status_dialog.dart` — status dots
- `lib/features/subscription/presentation/widgets/subscription_banner.dart` — banner colors
- `lib/features/subscription/presentation/widgets/subscription_status_header.dart` — white icon (keep)
- `lib/features/subscription/presentation/screens/subscription_plan_picker_screen.dart` — trial badge
- `lib/features/subscription/presentation/screens/subscription_check_screen.dart` — white icon (keep)

**Subscribers Dashboard (3 files):**
- `lib/features/subscripors_dashboard/presentation/widgets/subscriber_tile.dart` — status colors
- `lib/features/subscripors_dashboard/presentation/widgets/subscriber_stats_row.dart` — stat card colors
- `lib/features/subscripors_dashboard/presentation/screens/subscribers_dashboard_screen.dart` — lock icon

**Shared Widgets (4 files):**
- `lib/widgets/stat_card.dart` — white text on gradient (keep)
- `lib/widgets/action_bar.dart` — white icon/text on gradient (keep)
- `lib/widgets/app_snackbar.dart` — white icon/text (keep)
- `lib/widgets/sync_status_indicator.dart` — white text (keep)

**Auth Screens (5 files):**
- `lib/features/authentication/presentation/screens/phone_number_screen.dart` — white on primary
- `lib/features/authentication/presentation/screens/pin_screen.dart` — white on primary
- `lib/features/authentication/presentation/widgets/otp/otp_verify_button.dart` — white on primary
- `lib/features/authentication/presentation/widgets/login/animated_logo.dart` — white icon
- `lib/features/authentication/presentation/widgets/login/language_selector.dart` — transparent

---

## Step 4 — Update `uiux_rules.md`

Add explicit rule: "All semantic colors MUST use `AppColors.of(context)` — never inline hex values or `Colors.*` constants for domain-meaningful colors."

---

## What Stays As-Is
- `Colors.white` on gradient backgrounds (buttons, cards, icons) — always white, not theme-dependent
- `Colors.transparent` — literal transparent, not semantic
- `Theme.of(context).colorScheme.*` usages — already correct
- Gradient patterns using `cs.primary.withValues(alpha: 0.06)` — already theme-aware

---

## Files Affected Summary

| Action | Count |
|--------|-------|
| Create | 1 (`app_colors.dart`) |
| Modify theme | 1 (`theme_provider.dart`) |
| Replace colors | ~35 files |
| Rules doc | 1 (`uiux_rules.md`) |
| **Total** | **~38 files** |

## Verification
- `flutter analyze` — 0 errors
- Visual check: light mode on device (navy primary, gold accents, warm surfaces)
- Visual check: dark mode on device (lighter navy, bright gold, deep dark surfaces)
- Verify semantic colors: debt=red, payment=green, customer=blue, reminder=amber in both themes
