import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class checkConnection extends ChangeNotifier {
  bool _isConnect = false;

  bool get isConnect => _isConnect;

  final StreamController<bool> _connectivityController =
  StreamController<bool>();

  Stream<bool> get connectivityStream => _connectivityController.stream;

  checkConnection() {
    _checkConnectivity();
  }

  void _checkConnectivity() async {
    print('Entry');
    List<ConnectivityResult> connectivityResult =
    await (Connectivity().checkConnectivity());

    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      _connectivityController.add(true);
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      _connectivityController.add(true);
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      _connectivityController.add(true);
    } else {
      _connectivityController.add(false);
    }

    // Listen to the connectivity changes
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      bool isConnected = results.any((result) =>
      result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet);
      _connectivityController.add(isConnected);
    });
  }
}
