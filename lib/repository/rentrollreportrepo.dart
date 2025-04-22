import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/RentarsInsuranceModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../Model/rentrollreportmodel.dart';

class RentRollReportService {
  Future<rentrollreportmodel> fetchRentRollreport() async {
    print('entry');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');
    try {
      final response = await http.get(
          Uri.parse('$Api_url/api/rental_owner/rent-roll-report/$adminId'),
         // Uri.parse("http://192.168.1.10:4000/api/"),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $adminId",
          });

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON

        final parsedJson = jsonDecode(response.body);
        print(parsedJson);
        final completedWorkOrders = rentrollreportmodel.fromJson(parsedJson["data"]);
        return completedWorkOrders ;
      } else {

        // If the server did not return a 200 OK response, throw an exception
        throw Exception('Failed to load renters insurance');
      }
    } catch (e) {
      // Handle any other exceptions
      print('Error fetching data: $e');
      throw Exception('Failed to load renters insurance');
    }
  }
}
