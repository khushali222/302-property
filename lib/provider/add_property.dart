import 'package:flutter/foundation.dart';
import 'package:three_zero_two_property/model/rental_properties.dart';

class OwnerDetailsProvider with ChangeNotifier {
  RentalOwner? OwnerDetails;

  RentalOwner? get ownerDetails => OwnerDetails;

  void setOwnerDetails(RentalOwner ownerDetails) {
    print("object is set");
    OwnerDetails = ownerDetails;
    notifyListeners();
  }
  void clearOwners() {
    OwnerDetails = null;
    notifyListeners();
  }
}
