import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../Model/schduled_charge.dart';


class ScheduledChargesRepository {
  final String baseUrl = 'https://saas.cloudrentalmanager.com/api';

  Future<List<ScheduledCharges>> fetchScheduledCharges({String? leaseid}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String?  adminid = prefs.getString('adminId');
      String url = "";
      if(leaseid == null) {
        url = '$Api_url/api/charge/scheduled-charges/$adminid';
      } else {
        url = '$Api_url/api/charge/lease-scheduled-charges/$leaseid';
      }

      print(url);
      final response = await http.get(Uri.parse(url), headers: <String, String>{
        "authorization" : "CRM $token",
        "id":"CRM $adminid",
        'Content-Type': 'application/json; charset=UTF-8',
      },);
      print(response.body);
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        // Parse the data array into a list of ScheduledCharges
        final List<dynamic> data = responseBody['data'];
        return data.map((json) => ScheduledCharges.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load scheduled charges');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
