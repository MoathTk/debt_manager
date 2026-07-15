import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get isConnected => _controller.stream;

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((results) {
      final connected = results.any((result) => result != ConnectivityResult.none);
      _controller.add(connected);
    });
  }

  Future<bool> checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  void dispose() => _controller.close();
}
