import 'package:flutter/foundation.dart';
import 'package:three_zero_two_property/model/rental_properties.dart';
import 'package:three_zero_two_property/model/tenants.dart';

import '../screens/Leasing/RentalRoll/add_RentRoll.dart';

class SelectedTenantsProvider extends ChangeNotifier {
  List<Tenant> _selectedTenants = [];

  List<Tenant> get selectedTenants => _selectedTenants;

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
}

//List<data,List<map<String,dynamic>