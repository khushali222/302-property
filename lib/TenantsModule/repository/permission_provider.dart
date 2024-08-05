import 'package:flutter/material.dart';
import '../model/permission.dart';
import '../repository/permission_repo.dart';

class PermissionProvider with ChangeNotifier {
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
