// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:three_zero_two_property/Model/RentarsInsuranceModel.dart';
// import 'package:three_zero_two_property/constant/constant.dart';
//
// import '../Model/Home_System_Report_model.dart';
// import '../Model/rentrollreportmodel.dart';
//
// class Home_system_reportService {
//   Future<List<Home_system_report>> fetchHomeSystemData(String rentalId) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('token');
//     String?  id = prefs.getString('adminId');
//     final url = Uri.parse("$Api_url/api/appliance/appliance-report/$rentalId");
//     print(url);
//
//     try {
//       final response = await http.get(url,headers: {"authorization" : "CRM $token","id":"CRM $id",},);
//       print("check the home applience data ${response.body}");
//       print(["data"].first.length);
//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body)["data"];
//         return data.map((item) => Home_system_report.fromJson(item)).toList();
//       } else {
//         print('Failed to fetch data: ${response.statusCode}');
//         return [];
//       }
//     } catch (e) {
//       print('Error: $e');
//       return [];
//     }
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/RentarsInsuranceModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../../Model/Home_System_Report_model.dart';


class Home_system_reportService {
  Future<Home_system_report> fetchHomeSystemData(String rentalId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    final url = Uri.parse("$Api_url/api/appliance/appliance-report/$rentalId");
    print(url);

    try {
      final response = await http.get(
        url,
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );
      print("check the home applience data ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey("data")) {
          return Home_system_report.fromJson(responseData["data"]);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        print('Failed to fetch data: ${response.statusCode}');
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error fetching data: $e');
    }
  }
}
