import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/upcoming_renewal.dart';
import '../constant/constant.dart';

class Upcoming_renewal_repo{

  Future<List<upcoming_renewal>> fetchupcomingrenewal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString("adminId");

    final response = await apiGet(Uri.parse('${Api_url}/api/leases/renewal_leases/$id'),
        headers: {
          "authorization": "CRM $token",
          "id":"CRM $id",
        }
    );
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      return jsonResponse.map((data) => upcoming_renewal.fromJson(data)).toList();
    } else {
      return [];
      // throw Exception('Failed to load data');
    }
  }
}