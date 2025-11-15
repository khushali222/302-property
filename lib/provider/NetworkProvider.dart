import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class CheckConnection extends ChangeNotifier {
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // Broadcast stream to support multiple listeners
  final StreamController<bool> _connectivityController =
  StreamController<bool>.broadcast();

  Stream<bool> get connectivityStream => _connectivityController.stream;

  CheckConnection() {
    _initializeConnectivity();
  }

  void _initializeConnectivity() async {
    await _checkInitialConnectivity(); // Check initial connectivity.
    _listenForConnectivityChanges(); // Listen for changes in connectivity.
  }

  Future<void> _checkInitialConnectivity() async {
    // Check the initial connectivity status
    ConnectivityResult result = await Connectivity().checkConnectivity();
    _updateConnectivityStatus(result);
  }

  void _listenForConnectivityChanges() {
    // Listen to connectivity changes
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _updateConnectivityStatus(result);
    });
  }

  void _updateConnectivityStatus(ConnectivityResult result) {
    // Update connectivity based on the result
    bool isConnected = result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;

    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      _connectivityController.add(_isConnected); // Add to the stream
      notifyListeners(); // Notify listeners of change
    }
  }

  @override
  void dispose() {
    _connectivityController.close();
    super.dispose();
  }
}
