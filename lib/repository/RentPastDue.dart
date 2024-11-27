import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/RentPastDueModel.dart';

import '../constant/constant.dart';

class AdminBalanceRepository {
  final String baseUrl = '$Api_url/api/payment/admin_balance';



  // Future<List<RentPastDue>> fetchAdminBalance(String adminId, {bool report = true}) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString('token');
  //   String url = '$baseUrl/$adminId?report=${report.toString()}';
  //
  //   print('Fetching Admin Balance from: $url');
  //   try {
  //     final response = await http.get(
  //       Uri.parse(url),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         "Authorization": "Bearer $token",
  //       },
  //     );
  //
  //     print('Admin Balance response: ${response.body}');
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic>? jsonData = json.decode(response.body); // Decode as a Map
  //
  //       // Check if 'data' is null or does not contain the expected structure
  //       if (jsonData == null || jsonData["data"] == null || jsonData["data"]["currentDueRentCharges"] == null || jsonData["data"]["currentDueRentCharges"]["charges"] == null) {
  //         print('No charges found in the response.');
  //         return []; // Return an empty list or handle as needed
  //       }
  //
  //       // Access the list of charges
  //       final List<dynamic> charges = jsonData["data"]["currentDueRentCharges"]["charges"];
  //
  //       // Map the list of charges to your RentPastDue model
  //       return charges.map((data) => RentPastDue.fromJson(data)).toList();
  //     } else {
  //       print('Failed to load Admin Balance. Status code: ${response.statusCode}');
  //       throw Exception('Failed to load Admin Balance');
  //     }
  //   } catch (error) {
  //     print('Error fetching Admin Balance: $error');
  //     throw Exception('Error fetching Admin Balance');
  //   }
  // }
  // Future<List<RentPastDue>> fetchAdminBalance({bool report = true}) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString('token');
  //   String? id = prefs.getString("adminId");
  //   String url = '$baseUrl/$id?report=${report.toString()}';
  //
  //   print('Fetching Admin Balance from: $url');
  //   try {
  //     final response = await http.get(
  //       Uri.parse(url),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         "Authorization": "Bearer $token",
  //       },
  //     );
  //
  //     print('Admin Balance response: ${response.body}');
  //     if (response.statusCode == 200) {
  //       // Decode response body
  //       final Map<String, dynamic>? jsonData = json.decode(response.body);
  //
  //       // Ensure data structure is valid
  //       if (jsonData == null ||
  //           jsonData["data"] == null ||
  //           jsonData["data"]["currentDueRentCharges"] == null ||
  //           jsonData["data"]["currentDueRentCharges"]["charges"] == null) {
  //         print('No charges found in the response.');
  //         return []; // Return an empty list if structure is invalid
  //       }
  //
  //       // Safely parse the charges list
  //       final List<dynamic> charges = jsonData["data"]["currentDueRentCharges"]["charges"] ?? [];
  //
  //       // Map charges to the RentPastDue model
  //       return charges
  //           .map((charge) {
  //         try {
  //           return RentPastDue.fromJson(charge);
  //         } catch (e) {
  //           print('Error parsing charge: $charge, Error: $e');
  //           return null; // Handle invalid charge
  //         }
  //       })
  //           .whereType<RentPastDue>() // Filter out any null values
  //           .toList();
  //     } else {
  //       print('Failed to load Admin Balance. Status code: ${response.statusCode}');
  //       throw Exception('Failed to load Admin Balance');
  //     }
  //   } catch (error) {
  //     print('Error fetching Admin Balance: $error');
  //     throw Exception('Error fetching Admin Balance');
  //   }
  // }
  Future<RentPastDue> fetchAdminBalance({bool report = true}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString("adminId");
    String url = '$baseUrl/$id?report=${report.toString()}';

    print('Fetching Admin Balance from: $url');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "authorization": "CRM $token",
          "id":"CRM $id",
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print('Admin Balance response: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic>? jsonData = json.decode(response.body);
        return RentPastDue.fromJson(jsonData!["data"]);
       /* if (jsonData == null ||
            jsonData["data"] == null ||
            jsonData["data"]["currentDueRentCharges"] == null ||
            jsonData["data"]["currentDueRentCharges"]["charges"] == null) {
          print('No charges found in the response.');
          return [];
        }

        final List<dynamic> charges = jsonData["data"]["currentDueRentCharges"]["charges"] ?? [];
        return charges
            .map((charge) {
          try {
            return RentPastDue.fromJson(charge);
          } catch (e, stackTrace) {
            print('Error parsing charge: $charge, Error: $e, StackTrace: $stackTrace');
            return null;
          }
        })
            .whereType<RentPastDue>()
            .toList();*/
      } else {
        print('Failed to load Admin Balance. Status code: ${response.statusCode}');
        throw Exception('Failed to load Admin Balance');
      }
    } catch (error) {
      print('Error fetching Admin Balance: $error');
      throw Exception('Error fetching Admin Balance');
    }
  }


}