import 'package:flutter/material.dart';
import 'package:three_zero_two_property/StaffModule/repository/staffpermission_repo.dart';

import '../model/staffpermission.dart';

class StaffPermissionProvider with ChangeNotifier {
  StaffPermission? _permissions;
  bool _isLoading = true;

  StaffPermission? get permissions => _permissions;
  bool get isLoading => _isLoading;
  StaffPermissionProvider() {
    fetchPermissions();
  }
  Future<void> fetchPermissions() async {
    try {
      StaffPermission fetchedPermissions =
          await StaffPermissionService.fetchPermissions();
      _permissions = fetchedPermissions;
    } catch (e) {
      // Offline-safe: only fall back to the locked-down default when we have
      // nothing at all. Clobbering ALREADY-LOADED permissions on a transient
      // network failure emptied the drawer (Properties/Tenants/Leasing all
      // gone) with no way back short of restarting the app.
      _permissions ??= StaffPermission();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
