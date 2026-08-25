import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/StaffModule/repository/staffpermission_repo.dart';

import '../model/staffpermission.dart';

class StaffPermissionProvider with ChangeNotifier {
  StaffPermission? _permissions;
  bool _isLoading = true;

  StaffPermission? get permissions => _permissions;
  bool get isLoading => _isLoading;

  /// Where the last known-good permissions are kept, scoped to the staff member
  /// they belong to. Scoping matters: without the id in the key, signing in as
  /// a different staff member would inherit the previous one's menu.
  static Future<String?> _cacheKey() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('staff_id');
    if (id == null || id.isEmpty) return null;
    return 'staff_permissions_cache_$id';
  }

  StaffPermissionProvider() {
    fetchPermissions();
  }

  Future<void> fetchPermissions() async {
    try {
      StaffPermission fetchedPermissions =
          await StaffPermissionService.fetchPermissions();
      _permissions = fetchedPermissions;
      // Remembered for the next launch that cannot reach the server. A
      // successful fetch always overwrites, so a permission removed on the web
      // disappears here the moment the user is online again.
      await _cache(fetchedPermissions);
    } catch (e) {
      // Only decide anything when we have nothing at all — clobbering
      // ALREADY-LOADED permissions on a transient failure emptied the drawer
      // (Properties/Tenants/Leasing gone) with no way back short of a restart.
      if (_permissions == null) {
        // Prefer the user's OWN last-known permissions over a blank default.
        // The blank default is not the safe choice, it is simply the WRONG one:
        // it matches nobody, so opening the app offline used to strip most of
        // the menu. The drawer is navigation, not the security boundary — the
        // server is — and the cached copy is replaced by the real answer on
        // the next successful fetch.
        _permissions = await _cached() ?? StaffPermission();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _cache(StaffPermission permissions) async {
    try {
      final key = await _cacheKey();
      if (key == null) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(permissions.toJson()));
    } catch (_) {
      // Caching is a convenience; never let it break a successful fetch.
    }
  }

  Future<StaffPermission?> _cached() async {
    try {
      final key = await _cacheKey();
      if (key == null) return null;
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) return null;
      return StaffPermission.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Unreadable or from an older shape — fall through to the default.
      return null;
    }
  }
}
