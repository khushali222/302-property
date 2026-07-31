import 'package:three_zero_two_property/services/app_log.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/AccountTotalsReports.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'dart:convert';


// Import your model class here

class AccountTotalsReportsServices {
  final String baseUrl = '$Api_url/api/rental_owner';

  Future<List<AccountTotalsReport>> fetchAccountTotalsReports(String adminId, String selectedStartDate, String selectedEndDate,{String? rentalownerid }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? staffid = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    final String endpoint = '/accounts-report/$adminId';
    String url = '$baseUrl$endpoint?start_date=$selectedStartDate&end_date=$selectedEndDate';
    if(rentalownerid != null){
      url = '$url&rentalowner_id=$rentalownerid';
    }
    // if(chargetype != null){
    //   url = '$url&selectedChargeType=$chargetype';
    // }
    try {
      final response = await apiGet(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        "authorization": "CRM $token",
        "id": "CRM $staffid",
      },);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body)["data"];

        // If the response is a list of AccountTotalsReports objects, map them to the model class
        return jsonData.map((data) => AccountTotalsReport.fromJson(data)).toList();

      } else {
        // Handle error response
        return [];
      }
    } catch (error) {
      // Handle error during fetch
      logError('Error fetching rental owner reports: $error');
      return [];
    }
  }
}
