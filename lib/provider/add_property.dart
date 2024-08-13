import 'package:flutter/foundation.dart';
import 'package:three_zero_two_property/model/rental_properties.dart';

class OwnerDetailsProvider with ChangeNotifier {
  RentalOwner? OwnerDetails;
  String? selectedprocessorlist;

  RentalOwner? get ownerDetails => OwnerDetails;

  void setOwnerDetails(RentalOwner ownerDetails) {
    print("object is set");
    OwnerDetails = ownerDetails;
    notifyListeners();
  }
  void selectedprocessid(String pro_id){
    selectedprocessorlist = pro_id;
    notifyListeners();
  }
  void clearOwners() {
    OwnerDetails = null;
    notifyListeners();
  }
}
