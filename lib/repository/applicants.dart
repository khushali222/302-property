import 'dart:convert';
import 'package:d_chart/d_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/lease.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../model/ApplicantModel.dart';

class ApplicantRepository {
  static Future<Map<String, dynamic>> postApplicant({
    required Datum applicantData,
  }) async {
    final Map<String, dynamic> postData = applicantData.toJson();

    // Log the postData for debugging
    print('Posting data: ${jsonEncode(postData)}');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('$Api_url/api/applicant/applicant'),
      headers: <String, String>{
        "id": "CRM $id",
        "authorization": "CRM $token",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(postData),
    );
    print(response.body);
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: 'Applicant Added Successfully');
      return jsonDecode(response.body);
    } else {
      // Log the response body for debugging
      print('Failed to post data: ${response.body}');
      throw Exception('Failed to post applicant and lease data');
    }
  }

  Future<List<Datum>> fetchApplicants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await http
        .get(Uri.parse('$Api_url/api/applicant/applicant/$id'), headers: {
      "authorization": "CRM $token",
      "id": "CRM $id",
    });
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> applicantJson = data['data'];
      print(applicantJson);
      return applicantJson.map((json) => Datum.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load applicants');
    }
  }

  static Future<Map<String, dynamic>> updateApplicants({
    required String applicantId,
    required Map<String, dynamic> applicantData,
  }) async {
    print('Update Yash :${jsonEncode(applicantData)}');
    print('id is that :${applicantId}');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await http.put(
      Uri.parse('$Api_url/api/applicant/applicant/$applicantId'),
      headers: <String, String>{
        "id": "CRM $id",
        "authorization": "CRM $token",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(applicantData),
    );

    if (response.statusCode == 200) {
      // Fluttertoast.showToast(msg: 'Applicant Updated Successfully');
      return jsonDecode(response.body);
    } else {
      // Log the response body for debugging
      print('Failed to update data: ${response.body}');
      throw Exception('Failed to update applicant data');
    }
  }

  Future<Map<String, dynamic>> DeleteApplicant(
      {required String? Applicantid}) async {
    print('id is $Applicantid');
    // print('$apiUrl/$id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final http.Response response = await http.delete(
      Uri.parse('$Api_url/api/applicant/applicant/$Applicantid'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
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
}
