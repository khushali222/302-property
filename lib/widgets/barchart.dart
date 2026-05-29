import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'dart:convert';

import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/screens/Dashboard/revenue_details_screen.dart';

int _barChartParseMonthKey(dynamic raw) {
  if (raw == null) return -1;
  final n = raw is num ? raw.toInt() : int.tryParse(raw.toString());
  if (n == null) return -1;
  if (n >= 1 && n <= 12) return n;
  if (n >= 0 && n <= 11) return n + 1;
  return -1;
}

double _barChartParseAmount(dynamic raw) {
  if (raw == null) return 0.0;
  if (raw is num) return raw.toDouble();
  return double.tryParse(raw.toString()) ?? 0.0;
}

class Barchart extends StatefulWidget {
  @override
  State<Barchart> createState() => _BarchartState();
}

class _BarchartState extends State<Barchart> {
  List<RevenueData> chartData = [];
  final List<String> items = [
    'Current Year',
    'Previous Year',
  ];
  String? selectedValue = 'Current Year'; // Default selection
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChartData(selectedValue);
  }

  Future<void> fetchChartData(String? year) async {
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
        Map<int, double> revenueMap = {};
        bool hasCurrentYearData = false;

        // Only auto-switch to previous year on initial load
        final List currentYearList = data['currentYear'] ?? [];
        final List lastYearList = data['lastYear'] ?? [];

        if (year == 'Current Year' && selectedValue == 'Current Year') {
          double totalCurrentYear = 0;
          for (var item in currentYearList) {
            totalCurrentYear += _barChartParseAmount(item['totalAmount']);
          }
          hasCurrentYearData = totalCurrentYear > 0;

          // Auto-switch to previous year only on initial load when no current year data
          if (!hasCurrentYearData && chartData.isEmpty) {
            setState(() {
              selectedValue = 'Previous Year';
            });
            year = 'Previous Year';
          }
        }

        // Process data for the selected year
        if (year == 'Current Year') {
          for (var item in currentYearList) {
            final m = _barChartParseMonthKey(item['month']);
            if (m >= 1) revenueMap[m] = _barChartParseAmount(item['totalAmount']);
          }
        } else if (year == 'Previous Year') {
          for (var item in lastYearList) {
            final m = _barChartParseMonthKey(item['month']);
            if (m >= 1) revenueMap[m] = _barChartParseAmount(item['totalAmount']);
          }
        }

        // Ensure all months are represented
        List<RevenueData> newData = [];
        for (int i = 1; i <= 12; i++) {
          newData.add(RevenueData(getMonthName(i), revenueMap[i] ?? 0));
        }

        setState(() {
          chartData = newData;
          isLoading = false;
        });
      } else {
        // Handle error response
        print('Failed to load data');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle exception
      print('Error fetching data: $e');
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        elevation: 4,
        color: Colors.white,
        surfaceTintColor: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              //  color: Colors.red,
              height: 30,
              // width: 120,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              alignment: Alignment.topRight,
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: const Row(
                    children: [
                      SizedBox(
                        width: 4,
                      ),
                      Expanded(
                        child: Text(
                          'This Year',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  items: items
                      .map((String item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  value: selectedValue,
                  onChanged: (String? value) {
                    setState(() {
                      selectedValue = value;
                    });
                    fetchChartData(selectedValue);
                  },
                  buttonStyleData: ButtonStyleData(
                    height: 50,
                    width: 130,
                    padding: const EdgeInsets.only(left: 14, right: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.black26,
                      ),
                      color: Color.fromRGBO(50, 75, 119, 1),
                    ),
                    elevation: 2,
                  ),
                  iconStyleData: const IconStyleData(
                    icon: Icon(
                      Icons.arrow_forward_ios_outlined,
                    ),
                    iconSize: 14,
                    iconEnabledColor: Colors.white,
                    iconDisabledColor: Colors.grey,
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 200,
                    width: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Color.fromRGBO(50, 75, 119, 1),
                    ),
                    offset: const Offset(0, -5),
                    scrollbarTheme: ScrollbarThemeData(
                      radius: const Radius.circular(40),
                      thickness: MaterialStateProperty.all<double>(6),
                      thumbVisibility: MaterialStateProperty.all<bool>(true),
                    ),
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                    padding: EdgeInsets.only(left: 14, right: 14),
                  ),
                ),
              ),
            ),
            Container(
              height: 190,
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SfCartesianChart(
                      onChartTouchInteractionDown:
                          (ChartTouchInteractionArgs args) {
                        // Navigate to revenue details when chart is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RevenueDetailsScreen(
                              selectedYear: selectedValue ?? 'Current Year',
                            ),
                          ),
                        );
                      },
                      primaryXAxis: CategoryAxis(
                        majorGridLines: MajorGridLines(width: 0),
                        isVisible: true, // Show X-axis labels
                        majorTickLines:
                            MajorTickLines(size: 0), // Hide tick lines
                        axisLine: AxisLine(width: 0), // Hide X-axis line
                        labelIntersectAction: AxisLabelIntersectAction.rotate45,
                        labelStyle: TextStyle(
                          //  fontFamily: "mulish",
                          fontSize: 14,
                          fontWeight:
                              FontWeight.bold, // Make X-axis labels bold
                          color: Colors.black, // Optional: Set label color
                        ),
                        title: AxisTitle(
                            text: "Total Revenue",
                            textStyle: TextStyle(
                                // fontFamily: "mulish",
                                fontSize: 14,
                                color: blueColor,
                                fontWeight: FontWeight.bold)),
                      ),
                      primaryYAxis: NumericAxis(
                        isVisible: false, // Hide Y-axis labels
                        majorGridLines:
                            MajorGridLines(width: 0), // Remove Y-axis gridlines
                        axisLine: AxisLine(width: 0), // Hide Y-axis line
                      ),
                      plotAreaBorderWidth: 0, // Remove border around plot area
                      series: <CartesianSeries>[
                        ColumnSeries<RevenueData, String>(
                          dataSource: chartData,
                          pointColorMapper: (RevenueData data, _) =>
                              data.revenue > 0
                                  ? Color.fromRGBO(
                                      60, 89, 142, 1) // Normal color for data
                                  : Color.fromRGBO(60, 89, 142,
                                      0.3), // Lighter color for no data
                          xValueMapper: (RevenueData data, _) => data.month,
                          yValueMapper: (RevenueData data, _) => data.revenue,
                          dataLabelSettings:
                              DataLabelSettings(isVisible: false),
                          borderRadius: BorderRadius.circular(10),
                          width: .4, // Rounded corners for bars
                        )
                      ],
                      tooltipBehavior: TooltipBehavior(
                        enable: true,
                        color: Colors.white,
                        borderColor: Colors.black,
                        builder: (dynamic data, dynamic point, dynamic series,
                            int pointIndex, int seriesIndex) {
                          return Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              //  color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${point.x}', // Display the month
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  point.y > 0
                                      ? '${selectedValue}: \$${point.y.toStringAsFixed(2)}'
                                      : 'No revenue data available',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: point.y > 0
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class RevenueData {
  final String month;
  final double revenue;

  RevenueData(this.month, this.revenue);
}
