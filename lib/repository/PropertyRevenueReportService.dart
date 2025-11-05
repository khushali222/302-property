import 'dart:convert';
import 'package:http/http.dart' as http;
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
    print('Fetching property revenue report');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      // Build query parameters
      Map<String, String> queryParams = {
        'current_start_date': currentStartDate,
        'current_end_date': currentEndDate,
        'previous_start_date': previousStartDate,
        'previous_end_date': previousEndDate,
      };

      // Build the URL with query parameters
      Uri uri = Uri.parse(
              '$Api_url/api/rentals/property_revenue_report/$adminId')
          .replace(queryParameters: queryParams);

      print('API URL: $uri');

      final response = await http.get(uri, headers: {
        "authorization": "CRM $token",
        "id": "CRM $adminId",
        "Content-Type": "application/json",
      });

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);
        print('Parsed JSON: $parsedJson');

        final propertyRevenueReport =
            PropertyRevenueReportModel.fromJson(parsedJson);
        return propertyRevenueReport;
      } else if (response.statusCode == 401) {
        print('Authentication failed: ${response.body}');
        return PropertyRevenueReportModel(
          statusCode: 401,
          message:
              'User session is expired or invalid, please login and try again.',
        );
      } else {
        print('Failed to fetch property revenue report: ${response.body}');
        return PropertyRevenueReportModel(
          statusCode: response.statusCode,
          message: 'Failed to load property revenue report data',
        );
      }
    } catch (e) {
      print('Error fetching data: $e');
      return PropertyRevenueReportModel(
        statusCode: 0,
        message: 'Error fetching data: $e',
      );
    }
  }
}

