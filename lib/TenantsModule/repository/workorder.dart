import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/TenantsModule/model/workorder_summery_model.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../model/workorder_model.dart';

class WorkOrderRepository {

  Future<List<WorkOrder>> fetchWorkOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final response = await apiGet(
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
  //   final http.Response response = await apiPost(
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
 List? workOrder_images,
    bool? entry,
    String? notificationTime,
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
      'workOrder_images': workOrder_images,
      'notificationTime':notificationTime,
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    // Logging the request data

    // Sending the request
    final http.Response response = await apiPost(
      Uri.parse('$Api_url/api/work-order/work-order'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id": "CRM $id",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "workOrder":data,
        'notificationTime':notificationTime,
      }),
    );

    // Logging the response status and body

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

  static Future<WorkOrderData_summery> getworkorderSummary(String workorderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final url = Uri.parse('$Api_url/api/work-order/workorder_details/$workorderId');
    final response = await apiGet(
        url,
        headers: {"authorization" : "CRM $token","id":"CRM $id",}
    );

    if (response.statusCode == 200) {
      final dynamic dataRaw = jsonDecode(response.body)["data"];
      Map<String, dynamic> data;
      if (dataRaw is List) {
        data = dataRaw.isNotEmpty ? dataRaw[0] as Map<String, dynamic> : {};
      } else if (dataRaw is Map<String, dynamic>) {
        // API may return data.result (e.g. from details) or flat object
        final result = dataRaw["result"];
        data = result is Map<String, dynamic> ? result : dataRaw;
      } else {
        data = {};
      }
      return WorkOrderData_summery.fromJson(data);
    } else {
      throw Exception('Failed to fetch workorder summary: ${response.body}');
    }
  }
  static Future<bool> updateworkorderSummary(
    Map<String, dynamic> workorder,
    String workorderId, {
    String? notificationTime,
    String? categoryId,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? token = prefs.getString('token');
    final url = Uri.parse('$Api_url/api/work-order/work-order/$workorderId');
    final body = <String, dynamic>{"workOrder": workorder};
    if (notificationTime != null) body['notificationTime'] = notificationTime;
    if (categoryId != null) body['category_id'] = categoryId;
    final response = await apiPut(
      url,
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update work order: ${response.body}');
    }
  }
}
