import 'package:flutter/material.dart';
import 'package:three_zero_two_property/StaffModule/repository/staffpermission_repo.dart';

import '../model/staffpermission.dart';


class StaffPermissionProvider with ChangeNotifier {
  StaffPermission? _permissions;
  bool _isLoading = true;

  StaffPermission? get permissions => _permissions;
  bool get isLoading => _isLoading;

  Future<void> fetchPermissions() async {
    try {
      StaffPermission fetchedPermissions = await StaffPermissionService.fetchPermissions();
      _permissions = fetchedPermissions;
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
