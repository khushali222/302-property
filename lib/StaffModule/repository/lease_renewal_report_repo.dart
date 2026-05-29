import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/lease_renewal_report.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class LeaseRenewalReportRepository {
  final String baseUrl = '$Api_url/api/leases/lease-renewal-report';

  Future<LeaseRenewalReport> fetchLeaseRenewalReport({
    String? startDate,
    String? endDate,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? staffId = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    if (adminId == null || token == null) {
      throw Exception('Admin ID or token not found');
    }

    String url = '$baseUrl/$adminId';
    
    // Add query parameters if provided
    List<String> queryParams = [];
    if (startDate != null && startDate.isNotEmpty) {
      queryParams.add('start_date=$startDate');
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams.add('end_date=$endDate');
    }
    
    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    try {
      final response = await apiGet(
        Uri.parse(url),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM ${staffId ?? adminId}",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['statusCode'] == 200) {
          return LeaseRenewalReport.fromJson(jsonData['data']);
        } else {
          throw Exception('Failed to load report: ${jsonData['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to load report. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching lease renewal report: $e');
    }
  }
}

