import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../model/vendor_permission_model.dart';


class PermissionService {
  static Future<UserPermissions> fetchPermissions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("vendor_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final response = await apiGet(
        Uri.parse('$Api_url/api/permission/permission/$admin_id'),
        headers: {
          "id":"CRM $id",
          "authorization": "CRM $token",
          "Content-Type": "application/json"
        }
    );

    if (response.statusCode == 200) {
      log(response.body);
      final json = jsonDecode(response.body);

      if(json['data'] == null){
        return UserPermissions( workorderView: false,  workorderEdit: false,);
      }
      // Remembered for a later launch that cannot reach the server. The RAW
      // payload is stored, not a re-serialised model: this model has no
      // toJson, and replaying the server's own object through the same
      // fromJson cannot drift from what the parser expects.
      await _cache(jsonEncode(json['data']['vendor_permission']));
      return UserPermissions.fromJson(json['data']['vendor_permission']);
    } else {
      throw Exception('Failed to load permissions');
    }
  }

  static Future<String?> _cacheKey() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('vendor_id');
    if (id == null || id.isEmpty) return null;
    // Scoped to the account: without the id, signing in as someone else would
    // inherit the previous user's menu.
    return 'vendor_permissions_cache_$id';
  }

  static Future<void> _cache(String raw) async {
    try {
      final key = await _cacheKey();
      if (key == null) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, raw);
    } catch (_) {
      // Caching is a convenience; never let it break a successful fetch.
    }
  }

  /// The last known-good permissions for this account, or null if there are
  /// none. Used only when a fetch fails with nothing loaded — opening the app
  /// offline otherwise left permissions null, which hid every gated menu item.
  static Future<UserPermissions?> cachedPermissions() async {
    try {
      final key = await _cacheKey();
      if (key == null) return null;
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) return null;
      return UserPermissions.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }
}
