import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constant/constant.dart';

class MaintenanceHistoryService {

  Future<bool> addMaintenanceHistory({
    required String applianceId,
    required String adminId,
    required String token,
    required String vendor,
    required String event,
    List<File>? files,
  }) async {
    try {

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$Api_url/api/appliance/add_maintenance_history'),
      );

      // Add headers
      request.headers.addAll({
        'authorization': 'CRM $token',
        'id': 'CRM $adminId',
        'Content-Type': 'multipart/form-data',
      });

      // Add form fields
      request.fields['appliance_id'] = applianceId;
      request.fields['admin_id'] = adminId;
      request.fields['vendor'] = vendor;
      request.fields['event'] = event;

      // Add files if provided
      if (files != null && files.isNotEmpty) {
        for (int i = 0; i < files.length; i++) {
          File file = files[i];
          if (await file.exists()) {
            var stream = http.ByteStream(file.openRead());
            var length = await file.length();
            var multipartFile = http.MultipartFile(
              'files[]', // Use array notation for multiple files
              stream,
              length,
              filename: file.path.split('/').last,
            );
            request.files.add(multipartFile);
          }
        }
      }

      // print('Sending request to: ${request.url}');
      // print('Form fields: ${request.fields}');
      // print('Files count: ${request.files.length}');

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      // print('Response status: ${response.statusCode}');
      // print('Response body: $responseData');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to add maintenance history');
      }
    } catch (e) {
      // print('Error adding maintenance history: $e');
      rethrow;
    }
  }
} 