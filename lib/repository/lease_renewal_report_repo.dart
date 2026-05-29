import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/lease_renewal_report.dart';
import '../constant/constant.dart';

class LeaseRenewalReportRepository {
  Future<LeaseRenewalReport> fetchLeaseRenewalReport({
    String? startDate,
    String? endDate,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');

    if (adminId == null || token == null) {
      throw Exception('Admin ID or token not found');
    }

    String url = '${Api_url}/api/leases/lease-renewal-report/$adminId';
    
    // Add query parameters if provided
    if (startDate != null && endDate != null) {
      url += '?start_date=$startDate&end_date=$endDate';
    }

    final response = await apiGet(
      Uri.parse(url),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $adminId",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['statusCode'] == 200) {
        return LeaseRenewalReport.fromJson(jsonData['data']);
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to fetch lease renewal report');
      }
    } else if (response.statusCode == 401) {
      throw Exception('User session is expired or invalid, please login and try again.');
    } else {
      throw Exception('Failed to load lease renewal report: ${response.statusCode}');
    }
  }
}

