import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/constant.dart';

class ContactRepository {
  final String apiUrl = '${Api_url}/api/support/contact';

  Future<Map<String, dynamic>> submitContactForm({
    required String name,
    required String email,
    required String subject,
    required String category,
    required String priority,
    required String description,
    List<String>? attachments,
  }) async {
    // Constructing the request data (same as work order pattern)
    final Map<String, dynamic> data = {
      'name': name,
      'email': email,
      'subject': subject,
      'category': category,
      'priority': priority,
      'description': description,
      'attachments': attachments,
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // Get ID based on module (same pattern as work order)
    // Check which module is active by checking which ID exists
    String? id = prefs.getString("adminId"); // Default to admin

    // Check for tenant module
    String? tenantId = prefs.getString("tenant_id");
    if (tenantId != null && tenantId.isNotEmpty) {
      id = tenantId;
    }

    // Check for staff module
    String? staffId = prefs.getString("staff_id");
    if (staffId != null && staffId.isNotEmpty) {
      id = staffId;
    }

    // Check for vendor module
    String? vendorId = prefs.getString("vendor_id");
    if (vendorId != null && vendorId.isNotEmpty) {
      id = vendorId;
    }

    // Sending the request (same as work order pattern)
    final http.Response response = await apiPost(
      Uri.parse(apiUrl),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id": "CRM $id",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    print('Response body add: ${response.body}');

    var responseData = json.decode(response.body);

    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return responseData;
    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to submit contact form');
    }
  }
}
