import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/applicant_summery_model.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/screens/Leasing/Applicants/Summary/applicant_summery2.dart';

class ApplicantSummeryRepository {
  Future<bool> addApplicantSummaryForm(Data data, String applicantId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    print(jsonEncode(data.toJson()));
    try {
      final response = await http.post(
        Uri.parse('$Api_url/api/applicant/application/$applicantId'),
        headers: {
          'Content-Type': 'application/json',
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
        body: jsonEncode(data.toJson()),
      );

      var responseData = jsonDecode(response.body);
      print(responseData);

      if (response.statusCode == 200) {
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

  Future<bool> editApplicantSummaryForm(Data data, String applicantId) async {
    print(applicantId);
    print('data.toJson() ${data.toJson()}');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    print(jsonEncode(data.toJson()));
    try {
      final response = await http.post(
        Uri.parse('$Api_url/api/applicant/application/$applicantId'),
        headers: {
          'Content-Type': 'application/json',
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
        body: jsonEncode(data.toJson()),
      );

      var responseData = jsonDecode(response.body);
      print(response.body);

      if (response.statusCode == 200) {
        if (responseData['statusCode'] == 200) {
          print('Response successfully: ${responseData['data']}');
          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Successfully updated tenant');

          return true;
        } else {
          print('Failed to update tenant: ${responseData}');
          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Failed to update tenant');
          return false;
        }
      } else {
        print('Failed to update tenant: ${responseData}');
        Fluttertoast.showToast(
            msg: responseData['message'] ?? 'Failed to update tenant');
        return false;
      }
    } catch (error) {
      print('Exception occurred: $error');
      Fluttertoast.showToast(msg: 'An error occurred');
      return false;
    }
  }

  // static Future<applicant_summery_details> getApplicantSummary(
  //     String applicantId) async {
  //   print('entry');
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? id = prefs.getString('adminId');
  //   String? token = prefs.getString('token');
  //   print('token $token');

  //   final url =
  //       Uri.parse('$Api_url/api/applicant/applicant_summary/$applicantId');

  //   final response = await http.get(url, headers: {
  //     "authorization": "CRM $token",
  //     "id": "CRM $id",
  //   });

  //   if (response.statusCode == 200) {
  //     print('entry 200');
  //     final Map<String, dynamic> data = jsonDecode(response.body)["data"][0];
  //     print("response.body : ${response.body}");

  //     return applicant_summery_details.fromJson(data);
  //   } else {
  //     throw Exception('Failed to fetch applicant summary: ${response.body}');
  //   }
  // }
  static Future<applicant_summery_details> getApplicantSummary(
      String applicantId) async {
    print('entry');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    print('token $token');

    final url =
        Uri.parse('$Api_url/api/applicant/applicant_summary/$applicantId');

    try {
      final response = await http.get(url, headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      });

      if (response.statusCode == 200) {
        print('entry 200');
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Check if the "data" field is present and is a list
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          final List<dynamic> dataList = jsonResponse['data'] as List;
          if (dataList.isNotEmpty) {
            final Map<String, dynamic> data =
                dataList[0] as Map<String, dynamic>;
            print("response.body : ${response.body}");
            return applicant_summery_details.fromJson(data);
          } else {
            throw Exception('Data list is empty');
          }
        } else {
          throw Exception('Invalid response format: ${response.body}');
        }
      } else {
        throw Exception(
            'Failed to fetch applicant summary: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching applicant summary: $e');
      throw Exception('Error fetching applicant summary: $e');
    }
  }

  Future<int> noteAndFilePost(NoteFile noteFile, String applicantId) async {
    print(applicantId);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    final body = jsonEncode(noteFile.toJson());

    final response = await http.put(
      Uri.parse(
          '$Api_url/api/applicant/applicant/note_attachment/$applicantId'),
      headers: {
        "id": "CRM $id",
        "authorization": "CRM $token",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return response.statusCode;
      print('Note and files posted successfully');
    } else {
      print('Failed to post note and files: ${response.body}');
      throw Exception('Failed to post note and files');
    }
  }

  Future<int> deleteNoteAndFiles(String applicantId, String note__id) async {
    print(" ${applicantId} ${note__id} ");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    print('token ${token}');

    final response = await http.delete(
        Uri.parse(
            '$Api_url/api/applicant/applicant/note_attachment/$applicantId/$note__id'),
        headers: {
          "id": "CRM $id",
          "authorization": "CRM $token",
          'Content-Type': 'application/json; charset=UTF-8',
        });

    if (response.statusCode == 200) {
      print('Note and File Delete sucessfully');
      return response.statusCode;
    } else {
      print('Failed To delete a note');
      return response.statusCode;
    }
  }

  Future<ApplicantContentDetails> fetchApplicantDetails(
      String applicantId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    try {
      final response = await http.get(
          Uri.parse('$Api_url/api/applicant/applicant_details/$applicantId'),
          headers: {
            "id": "CRM $id",
            "authorization": "CRM $token",
            'Content-Type': 'application/json; charset=UTF-8',
          });

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');
        return ApplicantContentDetails.fromJson(json.decode(response.body));
      } else {
        print(
            'Failed to load applicant details, status code: ${response.statusCode}');
        throw Exception('Failed to load applicant details');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load applicant details');
    }
  }

  Future<int> sendMail(String applicantId) async {
    final reponse = await http
        .get(Uri.parse('$Api_url/api/applicant/applicant/mail/$applicantId'));

    if (reponse.statusCode == 200) {
      print(reponse.body);
      print('Mail Send Successfully');
      return reponse.statusCode;
    } else {
      print('Failed to send the mail ${reponse.body}');
      return reponse.statusCode;
    }
  }

  Future<ApproveRejectApplicantDetail> fetchApprovedDetail(
      String applicantId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    final response = await http.get(
        Uri.parse('$Api_url/api/applicant/status_data/$applicantId/Approved'),
        headers: {
          "id": "CRM $id",
          "authorization": "CRM $token",
          'Content-Type': 'application/json; charset=UTF-8',
        });
    if (response.statusCode == 200) {
      print(response.body);
      var jsonData = json.decode(response.body);
      var data = jsonData['data'];
      if (data != null && data is List && data.isNotEmpty) {
        return ApproveRejectApplicantDetail.fromJson(data[0]);
      } else {
        throw Exception('No data found');
      }
    } else {
      throw Exception('Failed to load applicant details');
    }
  }

  Future<ApproveRejectApplicantDetail> fetchRejectedDetail(
      String applicantId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    final response = await http.get(
        Uri.parse('$Api_url/api/applicant/status_data/$applicantId/Rejected'),
        headers: {
          "id": "CRM $id",
          "authorization": "CRM $token",
          'Content-Type': 'application/json; charset=UTF-8',
        });
    if (response.statusCode == 200) {
      print(response.body);
      var jsonData = json.decode(response.body);
      var data = jsonData['data'];
      if (data != null && data is List && data.isNotEmpty) {
        return ApproveRejectApplicantDetail.fromJson(data[0]);
      } else {
        throw Exception('No data found');
      }
    } else {
      throw Exception('Failed to load applicant details');
    }
  }

  Future<void> updateApplicantStatus(String applicantId, String status) async {
    final url =
        Uri.parse('$Api_url/api/applicant/applicant/$applicantId/status');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'statusUpdatedBy': 'Admin',
        'status': status,
        'rental_id': '',
        'unit_id': '',
      }),
    );

    if (response.statusCode == 200) {
      print('Status updated successfully');
    } else {
      print('Failed to update status');
    }
  }
}
