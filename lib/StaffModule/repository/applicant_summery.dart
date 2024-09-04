import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import '../Model/applicant_summery.dart';


class ApplicantSummeryRepository {




  static Future<applicant_summery_details> getApplicantSummary(String applicantId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    final url = Uri.parse('$Api_url/api/applicant/applicant_summary/$applicantId');
    print('$Api_url/api/applicant/applicant_summary/$applicantId');
    final response = await http.get(
      url,
        headers: {"authorization" : "CRM $token","id":"CRM $id",}
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body)["data"][0];
      return applicant_summery_details.fromJson(data);
    } else {
      throw Exception('Failed to fetch applicant summary: ${response.body}');
    }
  }
}
