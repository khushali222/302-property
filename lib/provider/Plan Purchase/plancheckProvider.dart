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
  /// True when the last attempt could not reach the server, as opposed to
  /// reaching it and being told there is no active plan. The two must not be
  /// confused: a launch that cannot ASK about the plan is not the same as a
  /// launch that has been told the plan expired.
  bool planCheckFailed = false;

  Future<void> fetchPlanPurchaseDetail() async {
    _isLoading = true;
    planCheckFailed = false;
    notifyListeners();
    try {
      _checkPlanPurchaseModel = await _service.fetchPlanPurchaseDetail();
    } catch (_) {
      // This used to throw straight out of the splash screen's launch path.
      // Nothing there caught it, so `Navigator.pushReplacement` was never
      // reached and an Admin opening the app offline sat on the splash screen
      // forever — turning the network back on did not help, because the launch
      // had already been abandoned. Only a full restart recovered.
      planCheckFailed = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
