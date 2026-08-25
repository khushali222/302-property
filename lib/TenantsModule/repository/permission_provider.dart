import 'package:three_zero_two_property/services/app_log.dart';
import 'package:flutter/material.dart';
import '../model/permission.dart';
import '../repository/permission_repo.dart';

class PermissionProvider with ChangeNotifier {
  UserPermissions? _permissions;
  bool _isLoading = true;
  Future<void>? _inFlight;

  UserPermissions? get permissions => _permissions;
  bool get isLoading => _isLoading;

  // Load permissions as soon as the provider is created, the same way
  // StaffPermissionProvider does, so the provider stands on its own even if a
  // route reaches a tenant screen without priming it first.
  PermissionProvider() {
    fetchPermissions();
  }

  /// Login and Splash both await this before opening a tenant screen, and the
  /// constructor starts one too. Sharing the in-flight future keeps that to a
  /// single network call; a later call still refetches.
  Future<void> fetchPermissions() => _inFlight ??= _fetch();

  Future<void> _fetch() async {
    try {
      UserPermissions fetchedPermissions =
          await PermissionService.fetchPermissions();
      _permissions = fetchedPermissions;
    } catch (e) {
      logError(e);
      // Opening the app offline used to leave this null, and the drawer gates on
      // `permissions?.propertyView == true` — so Property, Financial, Work
      // Orders and Documents all vanished with no way back short of a restart.
      // Fall back to this account's last known permissions; a later successful
      // fetch overwrites them.
      _permissions ??= await PermissionService.cachedPermissions();
    } finally {
      _isLoading = false;
      _inFlight = null;
      notifyListeners();
    }
  }
}
