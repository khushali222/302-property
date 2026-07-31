import 'package:three_zero_two_property/services/app_log.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../../Model/rentrollreportmodel.dart';



class RentRollReportService {
  Future<rentrollreportmodel> fetchRentRollreport({String? rentalOwnerId, List<String>? rentalOwnerIds}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    Uri uri;

    // Handle multiple rental owner IDs
    if (rentalOwnerIds != null && rentalOwnerIds.isNotEmpty) {
      // Filter out "all" from the list
      final filteredIds = rentalOwnerIds.where((id) => id != "all").toList();
      if (filteredIds.isNotEmpty) {
        // Build query parameters for multiple IDs as array
        final queryParams = <String, dynamic>{};
        for (int i = 0; i < filteredIds.length; i++) {
          queryParams["rentalowner_id[$i]"] = filteredIds[i];
        }
        uri = Uri.parse('$Api_url/api/rental_owner/rent-roll-report/$adminId')
            .replace(queryParameters: queryParams);
      } else {
        // If only "all" was selected, make normal API call
        uri = Uri.parse('$Api_url/api/rental_owner/rent-roll-report/$adminId');
      }
    } else if (rentalOwnerId != null && rentalOwnerId != "all") {
      // If single rentalOwnerId is provided, add it as a query parameter
      uri = Uri.parse('$Api_url/api/rental_owner/rent-roll-report/$adminId')
          .replace(queryParameters: {"rentalowner_id[]": rentalOwnerId});
    } else {
      // Normal API call without the rentalOwnerId parameter
      uri = Uri.parse('$Api_url/api/rental_owner/rent-roll-report/$adminId');
    }

    try {
      final response = await apiGet(
          uri,
         // Uri.parse("http://192.168.1.10:4000/api/"),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
          });

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON

        final parsedJson = jsonDecode(response.body);
        final completedWorkOrders = rentrollreportmodel.fromJson(parsedJson["data"]);
        return completedWorkOrders ;
      } else {

        // If the server did not return a 200 OK response, throw an exception
        throw Exception('Failed to load renters insurance');
      }
    } catch (e) {
      // Handle any other exceptions
      logError('Error fetching data: $e');
      throw Exception('Failed to load renters insurance');
    }
  }
}
