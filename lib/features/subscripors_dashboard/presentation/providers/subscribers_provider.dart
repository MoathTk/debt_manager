import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/subscribers_datasource.dart';
import '../../data/models/subscriber_model.dart';

final _datasourceProvider = Provider<SubscribersDatasource>((_) {
  return SubscribersDatasource(FirebaseFirestore.instance);
});

final subscribersStreamProvider = StreamProvider<List<SubscriberModel>>((ref) {
  return ref.watch(_datasourceProvider).watchAll();
});

class SubscribersNotifier extends StateNotifier<AsyncValue<List<SubscriberModel>>> {
  final SubscribersDatasource _ds;

  SubscribersNotifier(this._ds) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final list = await _ds.getAll();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateExpiry(String uid, DateTime newExpiry) async {
    await _ds.updateExpiry(uid, newExpiry);
    await load();
  }

  Future<void> expireNow(String uid) async {
    await _ds.expireNow(uid);
    await load();
  }
}

final subscribersProvider = StateNotifierProvider<SubscribersNotifier,
    AsyncValue<List<SubscriberModel>>>((ref) {
  return SubscribersNotifier(ref.watch(_datasourceProvider));
});
