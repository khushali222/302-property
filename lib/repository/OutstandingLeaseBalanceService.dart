import 'package:three_zero_two_property/services/app_log.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
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


      final response = await apiGet(uri, headers: {
        "authorization": "CRM $token",
        "id": "CRM $adminId",
        "Content-Type": "application/json",
      });


      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        final parsedJson = jsonDecode(response.body);

        final outstandingLeaseBalance =
            OutstandingLeaseBalanceModel.fromJson(parsedJson);
        return outstandingLeaseBalance;
      } else if (response.statusCode == 401) {
        // Handle authentication error
        return OutstandingLeaseBalanceModel(
          success: false,
          statusCode: 401,
          message:
              'User session is expired or invalid, please login and try again.',
        );
      } else {
        // If the server did not return a 200 OK response, throw an exception
        return OutstandingLeaseBalanceModel(
          success: false,
          statusCode: response.statusCode,
          message: 'Failed to load outstanding lease balance data',
        );
      }
    } catch (e) {
      // Handle any other exceptions
      logError('Error fetching data: $e');
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
