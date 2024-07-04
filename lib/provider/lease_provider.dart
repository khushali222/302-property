import 'package:flutter/foundation.dart';
import 'package:three_zero_two_property/model/rental_properties.dart';
import 'package:three_zero_two_property/model/tenants.dart';

import '../model/cosigner.dart';
import '../screens/Leasing/RentalRoll/add_RentRoll.dart';
import '../screens/Leasing/RentalRoll/newAddLease.dart';

class SelectedTenantsProvider extends ChangeNotifier {
  List<Tenant> _selectedTenants = [];

  List<Tenant> get selectedTenants => _selectedTenants;
  // bool isSelected(Tenant tenant) {
  //   return _selectedTenants.contains(tenant); // Check if tenant is in selected set
  // }
  void addTenant(Tenant tenant) {
    _selectedTenants.add(tenant);
    notifyListeners();
  }

  void removeTenant(Tenant tenant) {
    _selectedTenants.remove(tenant);
    notifyListeners();
  }

}



class SelectedCosignersProvider extends ChangeNotifier {
  List<Cosigner> _cosigners = [];

  List<Cosigner> get cosigners => _cosigners;

  void addCosigner(Cosigner cosigner) {
    _cosigners.add(cosigner);
    notifyListeners();
  }
  void removeConsigner(Cosigner cosigner) {
    _cosigners.remove(cosigner);
    notifyListeners();
  }
  void updateCosigner(Cosigner updatedCosigner,int index) {
    print("update calling");
    _cosigners[index] = updatedCosigner;
        notifyListeners();
    // for (int i = 0; i < _cosigners.length; i++) {
    //
    //   if (_cosigners[i].c_id == updatedCosigner.c_id) {
    //     print("update");
    //     _cosigners[i] = updatedCosigner;
    //     notifyListeners();
    //     break;
    //   }
    // }
  }
}

//List<data,List<map<String,dynamic>




