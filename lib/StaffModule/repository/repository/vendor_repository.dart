import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../../../Model/vendor.dart';


class VendorRepository {
  final String baseUrl;

  VendorRepository({required this.baseUrl});

  Future<bool> addVendor(Vendor vendor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final url = Uri.parse('$Api_url/api/vendor/vendor');
    print("$Api_url/api/vendor/vendor");
    print(vendor.toJson());
    final response = await http.post(
      url,
        headers: {"authorization" : "CRM $token","id":"CRM $id",},

      body: vendor.toJson(),
    );
    print(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to add vendor: ${response.body}');
      return false;
    }
  }
  Future<List<Vendor>> getVendors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    print("$Api_url/api/vendor/vendors/$id");
    print("CRM $token");
    print("CRM $id");
    final url = Uri.parse('$Api_url/api/vendor/vendors/$id');
    final response = await http.get(url,  headers: {"authorization" : "CRM $token","id":"CRM $id",},);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)["data"];
      return data.map((json) => Vendor.fromJson(json)).toList();
    } else {
      print('Failed to fetch vendors: ${response.body}');
      return [];
    }
  }
  Future<Vendor> getVendor(String vender_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    print("$Api_url/api/vendor/vendors/$vender_id");
    print("CRM $token");
    print("CRM $id");
    final url = Uri.parse('$Api_url/api/vendor/get_vendor/$vender_id');
    final response = await http.get(url,  headers: {"authorization" : "CRM $token","id":"CRM $id",},);

    if (response.statusCode == 200) {
      final Map<String,dynamic> data = jsonDecode(response.body)["data"];
      return  Vendor.fromJson(data);
    } else {
      print('Failed to fetch vendors: ${response.body}');
      return Vendor();
    }
  }
  Future<bool> update_vendor(Vendor vendor,String vender_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final url = Uri.parse('$Api_url/api/vendor/update_vendor/${vender_id}');
    print('$Api_url/api/vendor/update_vendor/${vender_id}');
    print(vendor.toJson());
    final response = await http.put(
      url,
      headers: {"authorization" : "CRM $token","id":"CRM $id",},

      body: vendor.toJson(),
    );
    print(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to edit vendor: ${response.body}');
      return false;
    }
  }
  Future<bool> DeleteVender({
    required String? vender_id
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    print('$Api_url/api/vendor/update_vendor/${vender_id}');

    final http.Response response = await http.delete(
      Uri.parse('$Api_url/api/vendor/delete_vendor/${vender_id}'),
        headers: {"authorization" : "CRM $token","id":"CRM $id",}
    );
    var responseData = json.decode(response.body);
    print(response.body);
    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return true;

    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to add property type');
      return false;
    }
  }

}
