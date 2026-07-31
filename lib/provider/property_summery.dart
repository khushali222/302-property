import 'package:flutter/material.dart';

class Tenants_counts with ChangeNotifier {
  int count = 0;
  //RentalOwner? OwnerDetails;

//  RentalOwner? get ownerDetails => OwnerDetails;

  void setOwnerDetails(int countassign) {
    count = countassign;
    notifyListeners();
  }


}