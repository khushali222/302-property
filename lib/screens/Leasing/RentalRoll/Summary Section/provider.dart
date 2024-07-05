import 'package:flutter/material.dart';
import 'package:three_zero_two_property/repository/lease.dart';
import 'package:three_zero_two_property/screens/Leasing/RentalRoll/Summary%20Section/LeaseLedgerModel.dart';

class LeaseLedgerProvider with ChangeNotifier {
  LeaseLedger? _leaseLedger;
  bool _isLoading = false;
  String? _errorMessage;

  LeaseLedger? get leaseLedger => _leaseLedger;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final LeaseRepository _apiService = LeaseRepository();

  Future<void> fetchLeaseLedger(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _leaseLedger = await _apiService.fetchLeaseLedger(id);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
