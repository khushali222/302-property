import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:three_zero_two_property/constant/constant.dart';

import '../model/Edit_workorder.dart';
/*import '../model/workordr.dart';*/

class WorkOrderRepository {


/*
  Future<List<Data>> fetchWorkOrders() async {
    // Retrieve admin ID and token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    // Define the URL and headers for the request
    final response = await http.get(
      Uri.parse('$Api_url/api/work-order/work-orders/$id'),
      headers: {
        'authorization': 'CRM $token',
        'id': 'CRM $id',
      },
    );

    // Check the response status
    //print(response.body);
    if (response.statusCode == 200) {
      // Parse the JSON response
      List jsonResponse = json.decode(response.body)['data'];
      // Map the JSON data to List<Data> and return
      return jsonResponse.map((data) => Data.fromJson(data)).toList();
    } else {
      // Throw an exception if the request failed
      throw Exception('Failed to load work orders');
    }
  }
*/


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
    List<String>? workOrderImages,
    bool? entry,
    String? vendorId,
    String? vendorNotes,
    String? priority,
    bool? workChargeTo,
    String? date,
    bool? isBillable,
    List<Map<String, dynamic>>? parts,
  }) async {
    // Constructing the request data
    final Map<String, dynamic> data = {
      'admin_id': adminId,
      'work_subject': workSubject,
      'staffmember_name': staffMemberName,
      'work_category': workCategory,
      'work_performed': workPerformed,
      'status': status,
      'rental_address': rentalAddress,
      'rental_unit': rentalUnit,
      'entry_allowed': entry, // Assuming this is a boolean
      'tenant_id': tenant,
      'rental_id': rentalid,
      'unit_id': unitid,
      'workOrder_images': workOrderImages,
      'vendor_id': vendorId,
      'vendor_notes': vendorNotes,
      'priority': priority,
      'work_charge_to': workChargeTo,
      'date': date,
      'is_billable': isBillable,
      // 'parts': parts,
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    // Logging the request data
    //  print('Request data: $data');

    // Sending the request
    //print(jsonEncode({"workOrder": data}));
    final http.Response response = await http.post(
      Uri.parse('${Api_url}/api/work-order/work-order'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id": "CRM $id",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({"workOrder": data,'parts': parts,}),
    );


    //print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');


    var responseData = json.decode(response.body);

    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return responseData;
    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to add work order');
    }
  }

  Future<EditData> fetchWorkordersDetails(String workorderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('vendor_id');
    final response = await http.get(Uri.parse('${Api_url}/api/work-order/workorder_details/$workorderId'),
      headers: {"authorization" : "CRM $token",
        "id":"CRM $id",},); // Update with your actual API URL
    //print('hello${response.body}');
    print(workorderId);
    print(workorderId);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // List leasesJson = jsonResponse['data'];
      return  EditData.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to load workorder');
    }
  }

  Future<Map<String, dynamic>> EditWorkOrder({
    String? adminId,
    String? workOrderid,
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
    List<String>? workOrderImages,
    bool? entry,
    String? vendorId,
    String? vendorNotes,
    String? priority,
    bool? workChargeTo,
    String? date,
    bool? isBillable,
    List<Map<String, dynamic>>? parts,
  }) async {
    print(parts!.length);
    // Constructing the request data
    final Map<String, dynamic> data = {
      'admin_id': adminId,
      'workOrder_id': workOrderid,
      'work_subject': workSubject,
      'staffmember_name': staffMemberName,
      'work_category': workCategory,
      'work_performed': workPerformed,
      'status': status,
      'rental_address': rentalAddress,
      'rental_unit': rentalUnit,
      'entry_allowed': entry, // Assuming this is a boolean
      'tenant_id': tenant,
      'rental_id': rentalid,
      'unit_id': unitid,
      'workOrder_images': workOrderImages,
      'vendor_id': vendorId,
      'vendor_notes': vendorNotes,
      'priority': priority,
      'work_charge_to': workChargeTo,
      'date': date,
      'is_billable': isBillable,
      // 'parts': parts,
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("vendor_id");
    String? token = prefs.getString('token');



    final http.Response response = await http.put(
      Uri.parse('${Api_url}/api/work-order/work-order/$workOrderid'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id": "CRMss $id",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({"workOrder": data,'parts': parts,}),
    );

    print('data length${data.length}');
    // print('Response body: ${response.body}');
    // print(workOrderid);
    var responseData = json.decode(response.body);
    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return responseData;
    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to update work order');
    }
  }

  Future<Map<String, dynamic>> DeleteWorkOrder({
    required String? workOrderid
  }) async {

    //print('$apiUrl/$id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');

    final http.Response response = await http.delete(
      Uri.parse('$Api_url/api/work-order/delete_workorder/$workOrderid'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id":"CRM $id",
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    var responseData = json.decode(response.body);
    print('$Api_url/work-order/delete_workorder/$workOrderid');
    print(workOrderid);
    //  print(response.body);
    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return json.decode(response.body);

    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to delete workorder');
    }
  }

}
