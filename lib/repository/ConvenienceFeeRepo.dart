import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/AccountTotalsReports.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'dart:convert';

import '../Model/ConvenienceFeeModel.dart';
import '../Model/rentalownerreport.dart';
// Import your model class here

import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../constant/constant.dart';

class ConvenienceFeeReportsServices {
  final String baseUrl = '$Api_url/api/leases/convenience-fee-override';

  Future<List<Data>> fetchConvenienceFeeReports() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    // Debugging prints
    print('API URL: $Api_url');
    print('Admin ID: $id');
    print('Token: $token');

    String url = '$baseUrl/$id';
    print('Full URL: $url');

    try {
      final response = await apiGet(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        "authorization": "CRM $token",
        "id": "CRM $id",
      });

      // Print the response body
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body)["data"];
        //for tenant frome list
        // List<Data> filteredData = jsonData
        //     .map((data) => Data.fromJson(data))
        //     .where((data) => data.tenantData != null && data.tenantData!.isNotEmpty)
        //     .toList();
        //
        // return filteredData;
        return jsonData.map((data) => Data.fromJson(data)).toList();
      } else {
        print('Failed to load report. Status code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        return [];
      }
    } catch (error) {
      print('Error fetching ConvenienceFee reports: $error');
      return [];
    }
  }
}