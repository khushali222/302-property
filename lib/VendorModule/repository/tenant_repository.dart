import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../model/tenant_property.dart';

class TenantPropertyRepository {

  Future<List<tenant_property>> fetchTenantProperties() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await http.get(Uri.parse('$Api_url/api/tenant/tenant_property/$id'), headers: {
    "id":"CRM $id",
    "authorization": "CRM $token",
    "Content-Type": "application/json"
    });
    print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => tenant_property.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tenant properties');
    }
  }

/*  Future<tenant_property> fetchTenantPropertyById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/tenant_properties/$id'));

    if (response.statusCode == 200) {
      return tenant_property.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load tenant property');
    }
  }

  Future<void> createTenantProperty(tenant_property property) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tenant_properties'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(property.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create tenant property');
    }
  }

  Future<void> updateTenantProperty(String id, tenant_property property) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tenant_properties/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(property.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update tenant property');
    }
  }

  Future<void> deleteTenantProperty(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/tenant_properties/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete tenant property');
    }
  }*/
}