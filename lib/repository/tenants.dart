import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/model/tenants.dart';

import '../constant/constant.dart';
import 'package:http/http.dart'as http;

class TenantsRepository {
  final String apiUrl = '${Api_url}/api//tenant/tenants';


  Future<Map<String, dynamic>> addPropertyType({
    required String? adminId,
    required String? propertyType,
    required String? propertySubType,
    required bool isMultiUnit,
  }) async {
    final Map<String, dynamic> data = {
      'admin_id': adminId,
      'property_type': propertyType,
      'propertysub_type': propertySubType,
      'is_multiunit': isMultiUnit,
    };

    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    var responseData = json.decode(response.body);

    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return json.decode(response.body);

    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to add property type');
    }
  }

  Future<List<Tenant>> fetchTenants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    final response = await http.get(Uri.parse('${Api_url}/api/tenant/tenants/$id'));
    print(response.body);
    print('${Api_url}/api//tenant/tenants/$id');
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      return jsonResponse.map((data) => Tenant.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }
  Future<bool> addTenant(Tenant tenant) async {
    final url = Uri.parse('${Api_url}/api/tenant/tenants');
    print(url);
      print(jsonEncode(tenant.toJson()));
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(tenant.toJson()),
      );

      var responseData = jsonDecode(response.body);
      print(responseData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['statusCode'] == 200) {
          print('Response successfully: ${responseData['data']}');
          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Successfully added tenant');

          return true;
        } else {
          print('Failed to add tenant: ${responseData}');
          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Failed to add tenant');
          return false;
        }
      } else {
        print('Failed to add tenant: ${responseData}');
        Fluttertoast.showToast(
            msg: responseData['message'] ?? 'Failed to add tenant');
        return false;
      }
    } catch (error) {
      print('Exception occurred: $error');
      Fluttertoast.showToast(msg: 'An error occurred');
      return false;
    }
  }
  // Future<Map<String, dynamic>> EditPropertyType({
  //   required String? adminId,
  //   required String? propertyType,
  //   required String? propertySubType,
  //   required bool isMultiUnit,
  //   required String? id
  // }) async {
  //   final Map<String, dynamic> data = {
  //     'admin_id': adminId,
  //     'property_type': propertyType,
  //     'propertysub_type': propertySubType,
  //     'is_multiunit': isMultiUnit,
  //   };
  //
  //   print('$apiUrl/$id');
  //
  //   final http.Response response = await http.put(
  //     Uri.parse('$apiUrl/$id'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(data),
  //   );
  //   var responseData = json.decode(response.body);
  //   print(response.body);
  //   if (responseData["statusCode"] == 200) {
  //     Fluttertoast.showToast(msg: responseData["message"]);
  //     return json.decode(response.body);
  //
  //   } else {
  //     Fluttertoast.showToast(msg: responseData["message"]);
  //     throw Exception('Failed to add property type');
  //   }
  // }
  // Future<Map<String, dynamic>> DeletePropertyType({
  //   required String? id
  // }) async {
  //
  //   print('$apiUrl/$id');
  //
  //   final http.Response response = await http.delete(
  //     Uri.parse('$apiUrl/$id'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //   );
  //   var responseData = json.decode(response.body);
  //   print(response.body);
  //   if (responseData["statusCode"] == 200) {
  //     Fluttertoast.showToast(msg: responseData["message"]);
  //     return json.decode(response.body);
  //
  //   } else {
  //     Fluttertoast.showToast(msg: responseData["message"]);
  //     throw Exception('Failed to add property type');
  //   }
  // }
}