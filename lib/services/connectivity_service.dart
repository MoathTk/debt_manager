import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService._();
  static final _instance = ConnectivityService._();
  factory ConnectivityService() => _instance;

  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _sub;

  Stream<bool> get isConnected => _controller.stream;

  void init() {
    _sub ??= _connectivity.onConnectivityChanged.listen((results) {
      final connected = results.any((result) => result != ConnectivityResult.none);
      _controller.add(connected);
    });
  }

  Future<bool> checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
    _controller.close();
  }
}
