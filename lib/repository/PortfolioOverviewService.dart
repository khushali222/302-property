import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class PortfolioOverviewData {
  final int properties;
  final double totalEstimatedValue;
  final double totalLoanBalance;
  final double portfolioLtv;
  final double avgDscrLoanWeighted;

  PortfolioOverviewData({
    required this.properties,
    required this.totalEstimatedValue,
    required this.totalLoanBalance,
    required this.portfolioLtv,
    required this.avgDscrLoanWeighted,
  });

  factory PortfolioOverviewData.fromJson(Map<String, dynamic> json) {
    return PortfolioOverviewData(
      properties: (json['properties'] ?? 0).toInt(),
      totalEstimatedValue: (json['totalEstimatedValue'] ?? 0).toDouble(),
      totalLoanBalance: (json['totalLoanBalance'] ?? 0).toDouble(),
      portfolioLtv: (json['portfolioLtv'] ?? 0).toDouble(),
      avgDscrLoanWeighted: (json['avgDscrLoanWeighted'] ?? 0).toDouble(),
    );
  }
}

class PortfolioOverviewService {
  Future<PortfolioOverviewData?> fetchPortfolioOverview(String adminId,
      {bool isStaff = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');

    final uri = Uri.parse('$Api_url/api/portfolio/overview/$adminId');

    final headerId = isStaff ? (prefs.getString('staff_id') ?? id) : id;

    final response = await apiGet(uri, headers: {
      'Content-Type': 'application/json',
      'authorization': 'CRM $token',
      'id': 'CRM $headerId',
    });

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        return PortfolioOverviewData.fromJson(json['data']);
      }
    }
    return null;
  }
}
