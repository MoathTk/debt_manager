/// REMINDERS FEATURE — PRESENTATION LAYER: PROVIDERS
///
/// Riverpod wiring for the reminders feature. Exposes the repository
/// (so the app can construct it once) plus:
///   - [debtReminderRepositoryProvider] → single entry point to the feature
///   - the read providers the UI watches (all reminders, pending, due today,
///     per customer)
///   - the use cases as providers, so widgets and actions depend on
///     behaviour, never on the concrete repository/SQLite.
///
/// OWNERSHIP: when a user is signed in, lists are filtered to that
/// owner's records and cross-owner reads return null/empty. This is the
/// exact behaviour that lived in the global database_provider before the
/// feature extraction.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/core/services/auth_service.dart';
import '../../data/repositories/debt_reminder_repository_impl.dart';
import '../../domain/entities/debt_reminder.dart';
import '../../domain/repositories/debt_reminder_repository.dart';
import '../../domain/usecases/add_reminder.dart';
import '../../domain/usecases/delete_reminder.dart';
import '../../domain/usecases/delete_reminders_batch.dart';
import '../../domain/usecases/mark_completed.dart';
import '../../domain/usecases/mark_pending.dart';
import '../../domain/usecases/update_reminder.dart';

/// Single entry point to the reminders data source.
final debtReminderRepositoryProvider = Provider<DebtReminderRepository>((ref) {
  return DebtReminderRepositoryImpl();
});

final _ownerIdProvider = Provider<String>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return user?.uid ?? '';
});

/// All non-deleted reminders, nearest date first (owner-scoped when signed in).
final allRemindersProvider = FutureProvider<List<DebtReminder>>((ref) async {
  final repo = ref.watch(debtReminderRepositoryProvider);
  final ownerId = ref.watch(_ownerIdProvider);
  return repo.getAll(ownerId: ownerId.isEmpty ? null : ownerId);
});

/// Pending (not-yet-completed) reminders, nearest date first.
final pendingRemindersProvider = FutureProvider<List<DebtReminder>>((
  ref,
) async {
  final repo = ref.watch(debtReminderRepositoryProvider);
  final ownerId = ref.watch(_ownerIdProvider);
  return repo.getPending(ownerId: ownerId.isEmpty ? null : ownerId);
});

/// Pending reminders due on or before today.
final dueTodayProvider = FutureProvider<List<DebtReminder>>((ref) async {
  final repo = ref.watch(debtReminderRepositoryProvider);
  return repo.getDueToday();
});

/// A single customer's reminders, nearest date first.
final remindersByCustomerProvider = FutureProvider.autoDispose
    .family<List<DebtReminder>, String>((ref, customerId) async {
      final repo = ref.watch(debtReminderRepositoryProvider);
      return repo.getByCustomer(customerId);
    });

// ---- USE CASES ----

final addReminderUseCaseProvider = Provider<AddReminder>((ref) {
  return AddReminder(ref.watch(debtReminderRepositoryProvider));
});

final updateReminderUseCaseProvider = Provider<UpdateReminder>((ref) {
  return UpdateReminder(ref.watch(debtReminderRepositoryProvider));
});

final markCompletedUseCaseProvider = Provider<MarkCompleted>((ref) {
  return MarkCompleted(ref.watch(debtReminderRepositoryProvider));
});

final markPendingUseCaseProvider = Provider<MarkPending>((ref) {
  return MarkPending(ref.watch(debtReminderRepositoryProvider));
});

final deleteReminderUseCaseProvider = Provider<DeleteReminder>((ref) {
  return DeleteReminder(ref.watch(debtReminderRepositoryProvider));
});

final deleteRemindersBatchUseCaseProvider = Provider<DeleteRemindersBatch>((
  ref,
) {
  return DeleteRemindersBatch(ref.watch(debtReminderRepositoryProvider));
});
