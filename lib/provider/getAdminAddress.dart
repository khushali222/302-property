import 'package:flutter/material.dart';
import 'package:three_zero_two_property/Model/profile.dart';

import 'package:three_zero_two_property/repository/GetAdminAddressPdf.dart';

class ProfileProvider with ChangeNotifier {
  profile? _profileAddress;

  profile? get profileAddress => _profileAddress;

  set profileAddress(profile? profileAddress) {
    _profileAddress = profileAddress;
    notifyListeners();
  }

  Future<void> loadProfile(GetAddressAdminPdfService service) async {
    try {
      _profileAddress = await service.fetchAdminAddress();
    } catch (e) {
      // Handle error
      print(e);
    }
    notifyListeners();
  }
}
