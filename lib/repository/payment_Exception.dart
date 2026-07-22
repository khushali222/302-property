// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:three_zero_two_property/Model/AccountTotalsReports.dart';
// import 'package:three_zero_two_property/Model/payment_exception.dart';
// import 'package:three_zero_two_property/constant/constant.dart';
// import 'dart:convert';
//
// import '../Model/rentalownerreport.dart';
// // Import your model class here
//
// class PaymentExceptionReportsServices {
//   final String baseUrl = '$Api_url/payment/exception-payments';
//
//   Future<List<Data>> fetchPaymentExceptionReports() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? id = prefs.getString("adminId");
//     String? token = prefs.getString('token');
//     String url = '$Api_url/payment/exception-payments/${id}';
//
//     // if(chargetype != null){
//     //   url = '$url&selectedChargeType=$chargetype';
//     // }
//     print(url);
//     try {
//       final response = await apiGet(Uri.parse(url), headers: {
//         'Content-Type': 'application/json',
//         "authorization": "CRM $token",
//         "id": "CRM $id",
//       },);
//       print('payment report ${response.body}');
//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body)["data"];
//
//         // If the response is a list of AccountTotalsReports objects, map them to the model class
//         return jsonData.map((data) => Data.fromJson(data)).toList();
//
//       } else {
//         // Handle error response
//         print('Failed to load report. Status code: ${response.statusCode}');
//         return [];
//       }
//     } catch (error) {
//       // Handle error during fetch
//       print('Error fetching Payment Exception reports: $error');
//       return [];
//     }
//   }
// }

import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../Model/payment_exception.dart';
import '../constant/constant.dart';

class PaymentExceptionReportsServices {
  final String baseUrl = '$Api_url/api/payment/exception-payments';

  Future<List<Data>> fetchPaymentExceptionReports({
    required String startDate,
    required String endDate,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    // Debugging prints
    print('API URL: $Api_url');
    print('Admin ID: $id');
    print('Token: $token');

    // Server (CRM-3761) requires startDate & endDate (YYYY-MM-DD) and filters
    // the exception payments by date server-side.
    String url = '$baseUrl/$id?startDate=$startDate&endDate=$endDate';
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
        return jsonData.map((data) => Data.fromJson(data)).toList();
      } else {
        print('Failed to load report. Status code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        return [];
      }
    } catch (error) {
      print('Error fetching Payment Exception reports: $error');
      return [];
    }
  }
}