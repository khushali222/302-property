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
      // Same reason as the tenant provider: leaving this null offline hides
      // every permission-gated control until the app is restarted online.
      _permissions ??= await PermissionService.cachedPermissions();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
