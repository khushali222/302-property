import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Model/Dashbord_table/lease_expiring_table.dart';
import '../../constant/constant.dart';

class LeaseExpiryService {
  Future<ExpiringLeasesResponse?> fetchExpiringLeases({
    int page = 1,
    int limit = 5,
    String sort = 'asc',
    int days = 30,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? staffId = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    final url = Uri.parse(
        '$Api_url/api/leases/expiring_leases/$adminId?page=$page&limit=$limit&sort=$sort&days=$days');

    try {
      final response = await apiGet(url, headers: {
        "authorization": "CRM $token",
        "id": "CRM $staffId",
      });

      if (response.statusCode == 200) {
        return ExpiringLeasesResponse.fromJson(jsonDecode(response.body));
      } else {
        print('Error fetching expiring leases: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception fetching expiring leases: $e');
      return null;
    }
  }

  Future<ExpiringLeasesResponse?> fetchExpiredLeases({
    int page = 1,
    int limit = 5,
    String sort = 'asc',
    int days = 30,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? staffId = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    final url = Uri.parse(
        '$Api_url/api/leases/expired_leases/$adminId?page=$page&limit=$limit&sort=$sort&days=$days');

    try {
      final response = await apiGet(url, headers: {
        "authorization": "CRM $token",
        "id": "CRM $staffId",
      });

      if (response.statusCode == 200) {
        return ExpiringLeasesResponse.fromJson(jsonDecode(response.body));
      } else {
        print('Error fetching expired leases: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception fetching expired leases: $e');
      return null;
    }
  }
}
