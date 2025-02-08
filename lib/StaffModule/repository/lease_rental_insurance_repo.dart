import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/RentarsInsuranceModel.dart';
import 'package:three_zero_two_property/Model/Renters_Insurnce/Edit_insurnce.dart';
import 'package:three_zero_two_property/Model/lease_renter_insurance.dart';
import 'package:three_zero_two_property/constant/constant.dart';



class RentersInsuranceService {
  Future<List<lease_renter_insurance>> fetchRentersInsurance( String leaseid) async {
    print('entry');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    try {
      final response = await http.get(
          Uri.parse('$Api_url/api/renter-insurance/policies/$leaseid'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
          });

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON

        final parsedJson = jsonDecode(response.body);
        print(parsedJson);
        List leasesJson = parsedJson['data'];
        return leasesJson.map((data) => lease_renter_insurance.fromJson(data)).toList();
      } else {
        // If the server did not return a 200 OK response, throw an exception
        throw Exception('Failed to load renters insurance');
      }
    } catch (e) {
      // Handle any other exceptions
      print('Error fetching data: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> deleteInsurance({
    required String renters_insurance_id,
  }) async {
    try {
      final Uri uri = Uri.parse('$Api_url/api/renter-insurance/delete-policy/$renters_insurance_id');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? adminid = prefs.getString('adminId');
      String? id = prefs.getString("staff_id");
      final http.Response response = await http.delete(
          uri,
          headers: <String, String>{
            "authorization": "CRM $token",
            "id": "CRM $id",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({}),
      );

      var responseData = json.decode(response.body);
      print(response.body);
      print(renters_insurance_id);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: responseData["message"]);
        return json.decode(response.body);
      } else {
        Fluttertoast.showToast(msg: responseData["message"]);
        throw Exception('Failed to delete Insurance');
      }
    } catch (e) {
      throw Exception('Failed to delete Insurance: $e');
    }
  }

  Future<RentersEdit> fetchRentersDetails(String renters_insurance_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? adminid = prefs.getString('adminId');
    String? id = prefs.getString("staff_id");
    final response = await http.get(
      Uri.parse('${Api_url}/api/renter-insurance/policy/$renters_insurance_id'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    ); // Update with your actual API URL
    //print('hello${response.body}');
    print(renters_insurance_id);
    print(renters_insurance_id);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // List leasesJson = jsonResponse['data'];
      return RentersEdit.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to load rentersdata');
    }
  }

}
