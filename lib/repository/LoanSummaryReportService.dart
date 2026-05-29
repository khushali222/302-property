import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class LoanSummaryItem {
  final String mortgageId;
  final String mortgageNo;
  final String bankName;
  final double loanAmount;
  final double remainingBalance;
  final double monthlyPayment;
  final String startDate;
  final String endDate;
  final int propertyCount;
  final List<String> properties;
  final double propertyValue;
  final double? ltvPercent;
  final double noi;
  final double debtService;
  final double dscr;

  LoanSummaryItem({
    required this.mortgageId,
    required this.mortgageNo,
    required this.bankName,
    required this.loanAmount,
    required this.remainingBalance,
    required this.monthlyPayment,
    required this.startDate,
    required this.endDate,
    required this.propertyCount,
    required this.properties,
    required this.propertyValue,
    required this.ltvPercent,
    required this.noi,
    required this.debtService,
    required this.dscr,
  });

  factory LoanSummaryItem.fromJson(Map<String, dynamic> json) {
    return LoanSummaryItem(
      mortgageId: json['mortgage_id'] ?? '',
      mortgageNo: json['mortgage_no'] ?? '',
      bankName: json['bank_name'] ?? '',
      loanAmount: (json['loan_amount'] ?? 0).toDouble(),
      remainingBalance: (json['remaining_balance'] ?? 0).toDouble(),
      monthlyPayment: (json['monthly_payment'] ?? 0).toDouble(),
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      propertyCount: (json['property_count'] ?? 0).toInt(),
      properties: List<String>.from(json['properties'] ?? []),
      propertyValue: (json['property_value'] ?? 0).toDouble(),
      ltvPercent: json['ltvPercent'] != null
          ? (json['ltvPercent'] as num).toDouble()
          : null,
      noi: (json['noi'] ?? 0).toDouble(),
      debtService: (json['debt_service'] ?? 0).toDouble(),
      dscr: (json['dscr'] ?? 0).toDouble(),
    );
  }
}

class LoanSummaryReportService {
  Future<List<LoanSummaryItem>?> fetchLoanSummary(String adminId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final id = prefs.getString('adminId') ?? '';

    final uri =
        Uri.parse('$Api_url/api/portfolio/loan-summary-report/$adminId');

    final response = await apiGet(uri, headers: {
      'Content-Type': 'application/json',
      'authorization': 'CRM $token',
      'id': 'CRM $id',
    });

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true && json['data'] is List) {
        return (json['data'] as List)
            .map((e) => LoanSummaryItem.fromJson(e))
            .toList();
      }
    }
    return null;
  }
}
