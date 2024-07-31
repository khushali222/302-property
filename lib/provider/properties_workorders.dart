import 'package:flutter/material.dart';

class WorkOrderCountProvider with ChangeNotifier {
  int count = 0;
  int completeCount = 0;
  bool isChecked = false;

  void updateCount(int newCount) {
    count = newCount;
    notifyListeners();
  }

  void updateCompleteCount(int newCompleteCount) {
    completeCount = newCompleteCount;
    notifyListeners();
  }

  void toggleChecked() {
    isChecked = !isChecked;
    notifyListeners();
  }

}
