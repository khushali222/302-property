import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../../../model/payments/fetch_payment_table.dart';
import 'package:http/http.dart'as http;
class ChargeRepositorys {

  // Future<List<ChargeResponses>> fetchChargesTable(String leaseId, String tenantId) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //  // adminId = prefs.getString("adminId");
  //   String?  id = prefs.getString('adminId');
  //   String? token = prefs.getString('token');
  //   final response = await http.get(Uri.parse('$Api_url/api/charge/charges/$leaseId/$tenantId'),
  //     headers: {"authorization" : "CRM $token","id":"CRM $id",},);
  //   print('charge ${response.body}');
  //   print('$Api_url/api/charge/charges/$leaseId/$tenantId');
  //   print(jsonEncode.hashCode);
  //   //  print('$baseUrl/rental-owners/$adminId');
  //   if (response.statusCode == 200) {
  //     List jsonResponse = json.decode(response.body);
  //     return jsonResponse.map((data) => ChargeResponses.fromJson(data)).toList();
  //   } else {
  //     throw Exception('Failed to load rental owners');
  //   }
  // }

  Future<List<Entrycharge>?> fetchChargesTable(String leaseId, String tenantId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? adminid = prefs.getString("adminId");
      String? id = prefs.getString("staff_id");
      String? token = prefs.getString('token');
      print(tenantId);

      final response = await http.get(
        Uri.parse('$Api_url/api/charge/tenant_charges/$leaseId/$tenantId'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );



      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
       // log(jsonResponse.toString());

        // Check if 'totalCharges' exists in the response
        if (jsonResponse.containsKey('totalCharges') && jsonResponse['totalCharges'] is List) {
          List<Entrycharge> allEntries = [];

          // Extract 'totalCharges'
          List<dynamic> totalCharges = jsonResponse['totalCharges'];

          // Loop through 'totalCharges' to get all 'entry' objects
          for (var charge in totalCharges) {
            if (charge.containsKey('entry') && charge['entry'] is List) {
              List<dynamic> entryList = charge['entry'];

              // Loop through the entry list and add each entry to allEntries
              for (var entry in entryList) {
                allEntries.add(Entrycharge.fromJson(entry));
              }
            }
          }
          print("Total entry charges: ${allEntries.length}");
          return allEntries;
        } else {
          throw Exception('No charges found');
        }
      } else {
        throw Exception('Failed to load');
      }
    } catch (e) {
      print('Error fetching charges: $e');
      throw Exception('Failed to load charges');
    }
  }

}