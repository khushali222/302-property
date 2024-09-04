import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Model/propertytype.dart';
import '../../../constant/constant.dart';

class PropertyTypeRepository {
  final String apiUrl = '${Api_url}/api/propertytype/property_type';

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
     String? token = prefs.getString('token');
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
     final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id":"CRM $id",
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

  Future<List<propertytype>> fetchPropertyTypes() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
     String? token = prefs.getString('token');
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");

    final response = await http.get(Uri.parse('${Api_url}/api/propertytype/property_type/$adminid'),
        headers: {
          "authorization": "CRM $token",
          "id":"CRM $id",
        }
    );
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      return jsonResponse.map((data) => propertytype.fromJson(data)).toList();
    } else {
      print('Failed to fetch property type: ${response.body}');
      return [];
      // throw Exception('Failed to load data');
    }
  }

  Future<Map<String, dynamic>> EditPropertyType({
    required String? adminId,
    required String? propertyType,
    required String? propertySubType,
    required bool isMultiUnit,
    required String? id
  }) async {
    final Map<String, dynamic> data = {
      'admin_id': adminId,
      'property_type': propertyType,
      'propertysub_type': propertySubType,
      'is_multiunit': isMultiUnit,
    };

   // print('$apiUrl/$id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
     String? token = prefs.getString('token');
    String? adminid = prefs.getString("adminId");
    String? s_id = prefs.getString("staff_id");

    final http.Response response = await http.put(
      Uri.parse('$apiUrl/$id'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id":"CRM $s_id",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    print(data);
    var responseData = json.decode(response.body);
    print(response.body);
    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return json.decode(response.body);

    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to add property type');
    }
  }
  Future<Map<String, dynamic>> DeletePropertyType({
    required String? pro_id
  }) async {

    //print('$apiUrl/$id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
     String? token = prefs.getString('token');
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");

    final http.Response response = await http.delete(
      Uri.parse('$apiUrl/$pro_id'),
      headers: <String, String>{

          "authorization": "CRM $token",
        "id":"CRM $id",
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    var responseData = json.decode(response.body);
    print(response.body);
    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return json.decode(response.body);

    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to delete property type');
    }
  }
}
