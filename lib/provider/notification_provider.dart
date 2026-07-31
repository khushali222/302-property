import 'package:three_zero_two_property/services/app_log.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';

import '../constant/constant.dart';
class NotificationProvider with ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  BuildContext? AppBarTitle;
  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;


  Future<void> fetchNotifications(BuildContext title) async {
    if(title == AppBarTitle) return;
    if (_isLoading) return; // Avoid multiple API calls
    _isLoading = true;
   // notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("adminId");
      String? token = prefs.getString("token");

      final response = await apiGet(
        Uri.parse('${Api_url}/api/notification/admin/$id'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );

      final jsonData = json.decode(response.body);
      if (jsonData["statusCode"] == 200 || jsonData["statusCode"] == 201) {
        _notifications = List<Map<String, dynamic>>.from(jsonData["data"]);
      }
    } catch (error) {
      logError("Error fetching notifications: $error");
    }
    AppBarTitle = title;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchNotificationsStaff(BuildContext title) async {
    if(title == AppBarTitle) return;
    if (_isLoading) return; // Avoid multiple API calls
    _isLoading = true;
    // notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? adminid = prefs.getString("adminId");
      String? token = prefs.getString("token");
      String? id = prefs.getString("staff_id");
      final response = await apiGet(
        Uri.parse('${Api_url}/api/notification/staff/$id'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );

      final jsonData = json.decode(response.body);
      if (jsonData["statusCode"] == 200 || jsonData["statusCode"] == 201) {
        _notifications = List<Map<String, dynamic>>.from(jsonData["data"]);
      }
    } catch (error) {
      logError("Error fetching notifications: $error");
    }
    AppBarTitle = title;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchNotificationsTenant(BuildContext title) async {
    if(title == AppBarTitle) return;
    if (_isLoading) return; // Avoid multiple API calls
    _isLoading = true;
    // notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? adminid = prefs.getString("adminId");
      String? token = prefs.getString("token");
      String? id = prefs.getString("tenant_id");

      final response = await apiGet(
        Uri.parse('${Api_url}/api/notification/tenant/$id'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );

      final jsonData = json.decode(response.body);
      if (jsonData["statusCode"] == 200 || jsonData["statusCode"] == 201) {
        _notifications = List<Map<String, dynamic>>.from(jsonData["data"]);
      }
    } catch (error) {
      logError("Error fetching notifications: $error");
    }
    AppBarTitle = title;
    _isLoading = false;
    notifyListeners();
  }
  Future<void> fetchNotificationsVendor(BuildContext title) async {
    if(title == AppBarTitle) return;
    if (_isLoading) return; // Avoid multiple API calls
    _isLoading = true;
    // notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? adminid = prefs.getString("adminId");
      String? token = prefs.getString("token");
      String? id = prefs.getString("vendor_id");

      final response = await apiGet(
        Uri.parse('${Api_url}/api/notification/vendor/$id'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );

      final jsonData = json.decode(response.body);
      if (jsonData["statusCode"] == 200 || jsonData["statusCode"] == 201) {
        _notifications = List<Map<String, dynamic>>.from(jsonData["data"]);
      }
    } catch (error) {
      logError("Error fetching notifications: $error");
    }
    AppBarTitle = title;
    _isLoading = false;
    notifyListeners();
  }
}