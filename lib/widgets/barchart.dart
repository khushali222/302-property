import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:three_zero_two_property/constant/constant.dart';

class Barchart extends StatefulWidget {
  @override
  State<Barchart> createState() => _BarchartState();
}

class _BarchartState extends State<Barchart> {
  List<RevenueData> chartData = [];
  final List<String> items = [
    'This Year',
    'Previous Year',
  ];
  String? selectedValue = 'This Year'; // Default selection
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

   // final url = Uri.parse('http://192.168.1.12:4000/api/payment/monthly-summary');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("adminId");
      String? token = prefs.getString('token');
      final url = Uri.parse('$Api_url/api/payment/monthly-summary');
      final response = await http.get(url,headers: {
        "id":"CRM $id",
        "authorization" : "CRM $token"
      } );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        Map<int, double> revenueMap = {};

        // Process data for the selected year
        if (year == 'This Year') {
          for (var item in data['currentYear']) {
            revenueMap[item['month']] = item['totalAmount'].toDouble();
          }
        } else if (year == 'Previous Year') {
          for (var item in data['lastYear']) {
            revenueMap[item['month']] = item['totalAmount'].toDouble();
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Card(
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
                    width: 110,
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
                    width: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
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
                primaryXAxis: CategoryAxis(
                  majorGridLines: MajorGridLines(width: 0),
                  isVisible: true, // Show X-axis labels
                  majorTickLines: MajorTickLines(size: 0), // Hide tick lines
                  axisLine: AxisLine(width: 0), // Hide X-axis line
                  labelIntersectAction: AxisLabelIntersectAction.rotate45,
                  title: AxisTitle(
                      text: "Total Revenue",
                      textStyle: TextStyle(
                          fontFamily: "mulish",
                          fontSize: 14,
                          color: Colors.black,
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
                    color: Color.fromRGBO(60, 89, 142, 1),
                    xValueMapper: (RevenueData data, _) => data.month,
                    yValueMapper: (RevenueData data, _) => data.revenue,
                    dataLabelSettings: DataLabelSettings(isVisible: false),
                    borderRadius: BorderRadius.circular(10),
                    width: .4, // Rounded corners for bars
                  )
                ],
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
