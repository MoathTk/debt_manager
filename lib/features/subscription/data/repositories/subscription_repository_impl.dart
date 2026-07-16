/// SUBSCRIPTION FEATURE — DATA LAYER: REPOSITORY IMPLEMENTATION
///
/// This is where everything connects:
/// - Implements the abstract [SubscriptionRepository] interface (from domain)
/// - Delegates to [SubscriptionLocalDatasource] (SQLite) for offline reads/writes
/// - Delegates to [SubscriptionRemoteDatasource] (Firestore) for online reads/writes
///
/// ERROR HANDLING:
/// - Exceptions from datasources propagate up to use cases
/// - Use cases decide how to handle (retry, fallback, show error)
/// - This layer does NOT swallow errors — failures are always reported
/// ---------------------------------------------------------------------------
library;

import 'package:local_debt_management/features/subscription/domain/entities/subscription.dart';
import 'package:local_debt_management/features/subscription/domain/repositories/subscription_repository.dart';
import '../datasources/subscription_local_datasource.dart';
import '../datasources/subscription_remote_datasource.dart';
import '../models/subscription_model.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionLocalDatasource _local;
  final SubscriptionRemoteDatasource _remote;

  SubscriptionRepositoryImpl(this._local, this._remote);

  @override
  Future<Subscription?> getLocal() async => _local.get();

  @override
  Future<Subscription?> getRemote(String uid) async => _remote.get(uid);

  /// Converts domain entity → data model, then saves to SQLite.
  /// Throws [SubscriptionLocalException] if write fails.
  @override
  Future<void> saveLocal(Subscription sub) async {
    final model = SubscriptionModel(
      plan: sub.plan,
      expiresAt: sub.expiresAt,
      activatedAt: sub.activatedAt,
      isActive: sub.isActive,
    );
    await _local.save(model, '');
  }

  /// Converts domain entity → data model, then saves to Firestore.
  /// Throws [SubscriptionRemoteException] if write fails.
  @override
  Future<void> saveRemote(String uid, Subscription sub) async {
    final model = SubscriptionModel(
      plan: sub.plan,
      expiresAt: sub.expiresAt,
      activatedAt: sub.activatedAt,
      isActive: sub.isActive,
    );
    await _remote.save(uid, model);
  }

  /// Throws [SubscriptionLocalException] if delete fails.
  @override
  Future<void> deleteLocal() => _local.delete();
}
