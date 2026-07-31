import 'package:three_zero_two_property/services/app_log.dart';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'dart:convert';

import '../Model/rentalownerreport.dart';
 // Import your model class here

class RentalOwnerReportService {
  final String baseUrl = '$Api_url/api/rental_owner';

  Future<List<RentalOwnerReport>> fetchRentalOwnerReport(String adminId, String selectedStartDate, String selectedEndDate,{String? rentalownerid , String? chargetype}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final String endpoint = '/todayspaymentrentalownerpdf/$adminId';
    String url = '$baseUrl$endpoint?selectedStartDate=$selectedStartDate&selectedEndDate=$selectedEndDate';
    if(rentalownerid != null){
      url = '$url&rentalowner_id=$rentalownerid';
    }
    if(chargetype != null){
      url = '$url&selectedChargeType=$chargetype';
    }

    try {
      final response = await apiGet(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        "authorization": "CRM $token",
        "id": "CRM $id",
      },);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body)["data"];

        // If the response is a list of RentalOwnerReport objects, map them to the model class
        return jsonData.map((data) => RentalOwnerReport.fromJson(data)).toList();
      } else {
        // Handle error response
        return [];
      }
    } catch (error) {
      // Handle error during fetch
      logError('Error fetching rental owner reportsd: $error');
      return [];
    }
  }
}
