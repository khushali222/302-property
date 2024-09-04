import 'package:flutter/material.dart';
import 'package:three_zero_two_property/Model/Preminum%20Plans/checkPlanPurchaseModel.dart';
import 'package:three_zero_two_property/repository/Preminum%20Plans/checkPlanPurchaseService.dart';

class checkPlanPurchaseProiver extends ChangeNotifier {
  checkPlanPurchaseModel? _checkPlanPurchaseModel;
  bool _isLoading = false;

  bool isPlanActive = false;
  String? planName;

  checkPlanPurchaseModel? get checkplanpurchaseModel => _checkPlanPurchaseModel;
  bool get isLoading => _isLoading;

  CheckPlanPurchaseService _service = CheckPlanPurchaseService();
  Future<void> fetchPlanPurchaseDetail() async {
    _isLoading = true;
    notifyListeners();
    _checkPlanPurchaseModel = await _service.fetchPlanPurchaseDetail();

    

    _isLoading = false;
    notifyListeners();
  }
}
