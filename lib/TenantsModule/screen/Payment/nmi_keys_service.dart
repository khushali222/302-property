// lib/TenantsModule/screen/Payment/nmi_keys_service.dart
// Service to fetch NMI keys (merchant ID and terminal ID) from API

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class NmiKeysService {
  /// Fetch NMI keys (merchant ID and terminal ID) from API
  /// GET /api/nmi-keys/nmi-keys/:admin_id
  Future<Map<String, dynamic>> fetchNmiKeys() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');

    if (adminId == null || token == null) {
      throw Exception('Admin ID or token not found');
    }

    final url = Uri.parse('$Api_url/api/nmi-keys/nmi-keys/$adminId');

    // For admin-level APIs (like NMI keys), use adminId in the "id" header
    // Even when called from tenant module, admin APIs need adminId
    final response = await http.get(
      url,
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $adminId", // Use adminId for admin-level API
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // API response structure: { "statusCode": 200, "data": { "merchant_id": "...", ... } }
      // Return the inner data object
      if (data['data'] != null) {
        final extractedData = data['data'] as Map<String, dynamic>;
        return extractedData;
      }

      // Fallback: return the whole response if structure is different
      return data;
    } else {
      print('NMI Keys API Error: ${response.statusCode} - ${response.body}');
      throw Exception(
          'Failed to load NMI keys: ${response.statusCode} - ${response.body}');
    }
  }
}
