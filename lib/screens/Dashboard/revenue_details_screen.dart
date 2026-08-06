import 'package:three_zero_two_property/services/app_log.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'dart:convert';
import 'package:three_zero_two_property/constant/constant.dart';

int _parseMonthKey(dynamic raw) {
  if (raw == null) return -1;
  final n = raw is num ? raw.toInt() : int.tryParse(raw.toString());
  if (n == null) return -1;
  if (n >= 1 && n <= 12) return n;
  if (n >= 0 && n <= 11) return n + 1; // Some APIs use 0-based months
  return -1;
}

double _parseAmount(dynamic raw) {
  if (raw == null) return 0.0;
  if (raw is num) return raw.toDouble();
  return double.tryParse(raw.toString()) ?? 0.0;
}

class RevenueDetailsScreen extends StatefulWidget {
  final String selectedYear;

  const RevenueDetailsScreen({Key? key, required this.selectedYear})
      : super(key: key);

  @override
  State<RevenueDetailsScreen> createState() => _RevenueDetailsScreenState();
}

class _RevenueDetailsScreenState extends State<RevenueDetailsScreen> {
  List<MonthlyRevenue> monthlyData = [];
  bool isLoading = true;

  /// Calendar years for labels (matches how the API buckets currentYear / lastYear).
  String get _calendarCurrentYear => DateTime.now().year.toString();
  String get _calendarPreviousYear => (DateTime.now().year - 1).toString();

  @override
  void initState() {
    super.initState();
    fetchRevenueDetails();
  }

  Future<void> fetchRevenueDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("adminId");
      String? token = prefs.getString('token');
      final url = Uri.parse('$Api_url/api/payment/monthly-summary/$id');
      final response = await http
          .get(url, headers: {"id": "CRM $id", "authorization": "CRM $token"});

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        List<MonthlyRevenue> newData = [];

        // Get current year data
        final List currentYearData = data['currentYear'] ?? [];
        final List previousYearData = data['lastYear'] ?? [];

        // Create a map for easy lookup (month keys normalized — JSON may send int or String)
        Map<int, double> currentYearMap = {};
        Map<int, double> previousYearMap = {};

        for (var item in currentYearData) {
          final m = _parseMonthKey(item['month']);
          if (m >= 1) currentYearMap[m] = _parseAmount(item['totalAmount']);
        }

        for (var item in previousYearData) {
          final m = _parseMonthKey(item['month']);
          if (m >= 1) previousYearMap[m] = _parseAmount(item['totalAmount']);
        }

        // Generate data for all 12 months based on selected year
        for (int i = 1; i <= 12; i++) {
          double displayAmount = 0.0;
          double comparisonAmount = 0.0;
          double percentageChange = 0.0;

          if (widget.selectedYear == 'Current Year') {
            displayAmount = currentYearMap[i] ?? 0.0;
            comparisonAmount = previousYearMap[i] ?? 0.0;
          } else {
            displayAmount = previousYearMap[i] ?? 0.0;
            comparisonAmount = currentYearMap[i] ?? 0.0;
          }

          // Calculate percentage change
          if (comparisonAmount > 0) {
            percentageChange =
                ((displayAmount - comparisonAmount) / comparisonAmount) * 100;
          } else if (displayAmount > 0) {
            percentageChange = 100.0; // New revenue
          }

          newData.add(MonthlyRevenue(
            month: i,
            monthName: getMonthName(i),
            fullMonthName: getFullMonthName(i),
            currentAmount: displayAmount,
            previousAmount: comparisonAmount,
            percentageChange: percentageChange,
          ));
        }

        setState(() {
          monthlyData = newData;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      logError('Error fetching revenue details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  String getFullMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Details',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.selectedYear == 'Current Year'
                  ? 'Current Year - $_calendarCurrentYear'
                  : 'Previous Year - $_calendarPreviousYear',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Breakdown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: monthlyData.length,
                    itemBuilder: (context, index) {
                      final data = monthlyData[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Month abbreviation button
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    data.monthName,
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              // Month details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${data.fullMonthName} ${widget.selectedYear == 'Current Year' ? _calendarCurrentYear : _calendarPreviousYear}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Monthly Revenue',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Revenue amount and percentage
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formatMoney(data.currentAmount),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class MonthlyRevenue {
  final int month;
  final String monthName;
  final String fullMonthName;
  final double currentAmount;
  final double previousAmount;
  final double percentageChange;

  MonthlyRevenue({
    required this.month,
    required this.monthName,
    required this.fullMonthName,
    required this.currentAmount,
    required this.previousAmount,
    required this.percentageChange,
  });
}
