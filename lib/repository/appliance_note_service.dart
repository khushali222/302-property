import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constant/constant.dart';

class ApplianceNoteService {
  Future<Map<String, dynamic>> addNote({
    required String applianceId,
    required String noteText,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? adminId = prefs.getString('adminId');

      if (token == null || adminId == null) {
        throw Exception('Authentication credentials not found');
      }

      final Map<String, dynamic> requestBody = {
        'note_text': noteText,
        'appliance_id': applianceId,
        'admin_id': adminId,
      };

      print('Request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$Api_url/api/appliance/add_note'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'authorization': 'CRM $token',
          'id': 'CRM $adminId',
        },
        body: json.encode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to add note');
      }
    } catch (e) {
      print('Error adding note: $e');
      throw Exception('Failed to add note: $e');
    }
  }

  Future<Map<String, dynamic>> deleteNote({
    required String noteId,
    required String applianceId,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? adminId = prefs.getString('adminId');

      if (token == null || adminId == null) {
        throw Exception('Authentication credentials not found');
      }

      final response = await http.delete(
        Uri.parse('$Api_url/api/appliance/delete_note/$noteId'),
        headers: {
          'authorization': 'CRM $token',
          'id': 'CRM $adminId',
        },
      );

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to delete note');
      }
    } catch (e) {
      print('Error deleting note: $e');
      throw Exception('Failed to delete note: $e');
    }
  }

  Future<Map<String, dynamic>> updateNote({
    required String noteId,
    required String noteText,
    required String applianceId,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? adminId = prefs.getString('adminId');

      if (token == null || adminId == null) {
        throw Exception('Authentication credentials not found');
      }

      final Map<String, dynamic> requestBody = {
        'note_text': noteText,
        'appliance_id': applianceId,
        'note_id': noteId,
      };
      print('Request body: ${json.encode(requestBody)}');

      final response = await http.put(
        Uri.parse('$Api_url/api/appliance/update_note'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'authorization': 'CRM $token',
          'id': 'CRM $adminId',
        },
        body: json.encode(requestBody),
      );

      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to update note');
      }
    } catch (e) {
      print('Error updating note: $e');
      throw Exception('Failed to update note: $e');
    }
  }
} 