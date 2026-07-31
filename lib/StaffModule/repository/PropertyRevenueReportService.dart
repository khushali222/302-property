import 'package:three_zero_two_property/services/app_log.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/PropertyRevenueReportModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class PropertyRevenueReportService {
  Future<PropertyRevenueReportModel> fetchPropertyRevenueReport({
    required String adminId,
    required String currentStartDate,
    required String currentEndDate,
    required String previousStartDate,
    required String previousEndDate,
  }) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? staffId = prefs.getString('staff_id');

    try {
      // Build query parameters
      Map<String, String> queryParams = {
        'current_start_date': currentStartDate,
        'current_end_date': currentEndDate,
        'previous_start_date': previousStartDate,
        'previous_end_date': previousEndDate,
      };

      // Build the URL with query parameters
      Uri uri =
          Uri.parse('$Api_url/api/rentals/property_revenue_report/$adminId')
              .replace(queryParameters: queryParams);


      final response = await apiGet(uri, headers: {
        "authorization": "CRM $token",
        "id": "CRM $staffId", // Use staff_id instead of adminId
        "Content-Type": "application/json",
      });


      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);

        final propertyRevenueReport =
            PropertyRevenueReportModel.fromJson(parsedJson);
        return propertyRevenueReport;
      } else if (response.statusCode == 401) {
        return PropertyRevenueReportModel(
          statusCode: 401,
          message:
              'User session is expired or invalid, please login and try again.',
        );
      } else {
        return PropertyRevenueReportModel(
          statusCode: response.statusCode,
          message: 'Failed to load property revenue report data',
        );
      }
    } catch (e) {
      logError('Error fetching data: $e');
      return PropertyRevenueReportModel(
        statusCode: 0,
        message: 'Error fetching data: $e',
      );
    }
  }
}
