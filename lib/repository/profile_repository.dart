import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../Model/profile.dart';
import 'package:http/http.dart'as http;

import '../constant/constant.dart';
class ProfileRepository {
  final String apiUrl = "${Api_url}/api/admin/admin_profile/";

  Future<profile> fetchProfile() async {

  //  String? token = prefs.getString('token');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final response = await http.get(Uri.parse('$apiUrl$id'), headers: {"authorization" : "CRM $token","id":"CRM $id",},);
    print('hello$apiUrl$id');
    print(response.body);
    final response_Data = jsonDecode(response.body);
    if (response_Data["statusCode"] == 200) {
      print("hello");
      return profile.fromJson(jsonDecode(response.body)["data"]);
    } else {
      throw Exception('Failed to load profile');
    }
  }
  Future<profile> Edit_profile(Map<String,dynamic> data) async {
    final String apiUrl = "${Api_url}/api/admin/admin_edit/";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(jsonEncode(data));
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await http.put(Uri.parse('$apiUrl$id'),body: data, headers: {"authorization" : "CRM $token","id":"CRM $id",},);
    print('abc$apiUrl$id');
    print(response.body);
    final response_Data = jsonDecode(response.body);
    if (response_Data["statusCode"] == 200) {
      //print("hello");
      return profile.fromJson(jsonDecode(response.body)["data"]);
    } else {
      throw Exception('Failed to load profile');

    }
  }
}
