import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/OutstandingLeaseBalanceModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class OutstandingLeaseBalanceService {
  // Define your API URL here

  Future<OutstandingLeaseBalanceModel> fetchOutstandingLeaseBalance({
    required String adminId,
    String statusFilter = 'all',
    String? rentalOwnerFilter,
    int page = 1,
    int limit = 10,
    String sortBy = 'property_address',
    String sortOrder = 'asc',
  }) async {
    print('Fetching outstanding lease balance');

    // Get SharedPreferences instance and retrieve token
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      // Build query parameters
      Map<String, String> queryParams = {
        'status_filter': statusFilter,
        'page': page.toString(),
        'limit': limit.toString(),
        'sort_by': sortBy,
        'sort_order': sortOrder,
      };

      // Add rental owner filter if provided
      if (rentalOwnerFilter != null && rentalOwnerFilter.isNotEmpty) {
        queryParams['rental_owner_filter'] = rentalOwnerFilter;
      }

      // Build the URL with query parameters
      Uri uri = Uri.parse('$Api_url/api/leases/outstanding-balance/$adminId')
          .replace(queryParameters: queryParams);

      print('API URL: $uri');

      final response = await http.get(uri, headers: {
        "authorization": "CRM $token",
        "id": "CRM $adminId",
        "Content-Type": "application/json",
      });

      print('Response status: ${response.statusCode}');
      print('Response body outstanding lease balance: ${response.body}');

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        final parsedJson = jsonDecode(response.body);
        print('Parsed JSON: $parsedJson');

        final outstandingLeaseBalance =
            OutstandingLeaseBalanceModel.fromJson(parsedJson);
        return outstandingLeaseBalance;
      } else if (response.statusCode == 401) {
        // Handle authentication error
        print('Authentication failed: ${response.body}');
        return OutstandingLeaseBalanceModel(
          success: false,
          statusCode: 401,
          message:
              'User session is expired or invalid, please login and try again.',
        );
      } else {
        // If the server did not return a 200 OK response, throw an exception
        print('Failed to fetch outstanding lease balance: ${response.body}');
        return OutstandingLeaseBalanceModel(
          success: false,
          statusCode: response.statusCode,
          message: 'Failed to load outstanding lease balance data',
        );
      }
    } catch (e) {
      // Handle any other exceptions
      print('Error fetching data: $e');
      return OutstandingLeaseBalanceModel(
        success: false,
        statusCode: 0,
        message: 'Error fetching data: $e',
      );
    }
  }

  // Method to get rental owner IDs from SharedPreferences
  Future<String?> getRentalOwnerFilter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('rentalOwnerFilter');
  }

  // Method to set rental owner filter in SharedPreferences
  Future<void> setRentalOwnerFilter(String rentalOwnerIds) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('rentalOwnerFilter', rentalOwnerIds);
  }

  // Method to clear rental owner filter
  Future<void> clearRentalOwnerFilter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('rentalOwnerFilter');
  }
}
