import 'package:flutter/foundation.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/model/rental_properties.dart';

import '../Model/tenants.dart';
import '../model/LeaseLedgerModel.dart';
import '../model/cosigner.dart';
import '../repository/lease.dart';
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

  void setTenants(List<Tenant> tenants) {
    _selectedTenants = tenants;
    notifyListeners();
  }

  void removeTenant(Tenant tenant) {
    _selectedTenants.remove(tenant);
    notifyListeners();
  }

  void clearTenant(){
    _selectedTenants.clear();
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
  void clearCosigner(){
    _cosigners.clear();
    notifyListeners();
  }
}

//List<data,List<map<String,dynamic>



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



