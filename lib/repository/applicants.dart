import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/Model/ApplicantModel.dart';
import 'package:three_zero_two_property/Model/lease.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class ApplicantRepository {
  static Future<Map<String, dynamic>> postApplicant({
    required ApplicantData applicantData,
  }) async {
    final Map<String, dynamic> postData = applicantData.toJson();

    // Log the postData for debugging
    print('Posting data: ${jsonEncode(postData)}');

    final response = await http.post(
      Uri.parse('$Api_url/api/applicant/applicant'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(postData),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: 'Applicant Added Successfully');
      return jsonDecode(response.body);
    } else {
      // Log the response body for debugging
      print('Failed to post data: ${response.body}');
      throw Exception('Failed to post applicant and lease data');
    }
  }
}
