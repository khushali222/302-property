import 'package:flutter/material.dart';
import 'package:three_zero_two_property/StaffModule/repository/staffpermission_repo.dart';

import '../model/vendor_permission_model.dart';

import 'vendor_permission_repo.dart';


class VendorPermission with ChangeNotifier {
  UserPermissions? _permissions;
  bool _isLoading = true;

  UserPermissions? get permissions => _permissions;
  bool get isLoading => _isLoading;

  Future<void> fetchPermissions() async {
    try {
      UserPermissions fetchedPermissions = await PermissionService.fetchPermissions();
      _permissions = fetchedPermissions;
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
