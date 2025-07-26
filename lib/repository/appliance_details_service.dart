import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constant/constant.dart';
import '../Model/unit.dart';

class ApplianceDetailsService {
  Future<unit_appliance?> fetchApplianceDetails(String applianceId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? adminId = prefs.getString('adminId');

      if (token == null || adminId == null) {
        throw Exception('Authentication credentials not found');
      }

      print('Fetching appliance details for ID: $applianceId');
      print('API URL: $Api_url/api/appliance/appliance_details/$applianceId');

      final response = await http.get(
        Uri.parse('$Api_url/api/appliance/appliance_details/$applianceId'),
        headers: {
          'authorization': 'CRM $token',
          'id': 'CRM $adminId',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['data'] != null && responseData['data'].isNotEmpty) {
          // If data is an array, take the first item
          final applianceData = responseData['data'] is List 
              ? responseData['data'][0] 
              : responseData['data'];
          
          return unit_appliance.fromJson(applianceData);
        } else {
          throw Exception('No appliance data found');
        }
      } else {
        final responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Failed to fetch appliance details');
      }
    } catch (e) {
      print('Error fetching appliance details: $e');
      throw Exception('Failed to fetch appliance details: $e');
    }
  }
  //delete note
  Future<bool> deleteNote(String noteId, String applianceId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? adminId = prefs.getString('adminId');

    if (token == null || adminId == null) {
      throw Exception('Authentication credentials not found');
    }

    final response = await http.delete(
      Uri.parse('$Api_url/api/appliance/delete_note/$noteId/$applianceId'),
      headers: {
        'authorization': 'CRM $token',
        'id': 'CRM $adminId', 
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete note');
    }
  }
  Future<unit_appliance?> refreshApplianceDetails(String applianceId) async {
    return await fetchApplianceDetails(applianceId);
  }
} 