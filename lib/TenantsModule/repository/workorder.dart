import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../model/workorder_model.dart';

class WorkOrderRepository {

  Future<List<WorkOrder>> fetchWorkOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${Api_url}/api/work-order/tenant_work/$id'),
      headers: {
        'authorization': 'CRM $token',
        'id': 'CRM $id',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];

      return jsonResponse.map((data) => WorkOrder.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load work orders');
    }
  }
  // Future<Map<String, dynamic>> addWorkOrder({
  //    String? adminId,
  //    String? workSubject,
  //    String? staffMemberName,
  //    String? workCategory,
  //    String? workPerformed,
  //    String? status,
  //    String? rentalAddress,
  //    String? rentalUnit,
  //    String? tenant,
  //    bool? entry,
  //
  // }) async {
  //   // Constructing the request data
  //   final Map<String, dynamic> data = {
  //     'admin_id': adminId,
  //     'work_subject': workSubject,
  //     'staffmember_name': staffMemberName,
  //     'work_category': workCategory,
  //     'work_performed': workPerformed,
  //     'status': status,
  //     'rental_adress': rentalAddress,
  //     'rental_unit': rentalUnit,
  //     'entry_allowed': entry, // Assuming this is a boolean
  //     'statusUpdatedBy': tenant,
  //     'workOrderImage': [],
  //   };
  //
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? id = prefs.getString("tenant_id");
  //   String? admin_id = prefs.getString("adminId");
  //   String? token = prefs.getString('token');
  //
  //   // Sending the request
  //   final http.Response response = await http.post(
  //     Uri.parse('$Api_url/api/work-order/work-order'),
  //     headers: <String, String>{
  //       "authorization": "CRM $token",
  //       "id": "CRM $id",
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(data),
  //   );
  //
  //   // Handling the response
  //   var responseData = json.decode(response.body);
  //
  //   if (responseData["statusCode"] == 200) {
  //     Fluttertoast.showToast(msg: responseData["message"]);
  //     return json.decode(response.body);
  //   } else {
  //     Fluttertoast.showToast(msg: responseData["message"]);
  //     throw Exception('Failed to add work order');
  //   }
  // }
  Future<Map<String, dynamic>> addWorkOrder({
    String? adminId,
    String? workSubject,
    String? staffMemberName,
    String? workCategory,
    String? workPerformed,
    String? status,
    String? rentalAddress,
    String? rentalUnit,
    String? tenant,
    String? rentalid,
    String? unitid,
    bool? entry,
  }) async {
    // Constructing the request data
    final Map<String, dynamic> data = {
      'admin_id': adminId,
      'work_subject': workSubject,
      'staffmember_name': staffMemberName,
      'work_category': workCategory,
      'work_performed': workPerformed,
      'status': status,
      'rental_adress': rentalAddress,
      'rental_unit': rentalUnit,
      'entry_allowed': entry, // Assuming this is a boolean
      'statusUpdatedBy': tenant,
      'rental_id': rentalid,
      'unit_id': unitid,
      'workOrderImage': [],
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    // Logging the request data
    print('Request data: $data');

    // Sending the request
    final http.Response response = await http.post(
      Uri.parse('$Api_url/api/work-order/work-order'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id": "CRM $id",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({"workOrder":data}),
    );

    // Logging the response status and body
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    // Handling the response
    var responseData = json.decode(response.body);

    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return responseData;
    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to add work order');
    }
  }


}
