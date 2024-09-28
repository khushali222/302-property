import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../constant/constant.dart';
void main() {
  List<Map<String, dynamic>> data = [
    {"month": "Sep", "rentals": 8, "leases": 9, "occupiedPercentage": 112.5},
    {"month": "Oct", "rentals": 0, "leases": 0, "occupiedPercentage": 0},
    {"month": "Nov", "rentals": 0, "leases": 0, "occupiedPercentage": 0},
    {"month": "Dec", "rentals": 0, "leases": 0, "occupiedPercentage": 0},
    {"month": "Jan", "rentals": 0, "leases": 0, "occupiedPercentage": 0},
    {"month": "Feb", "rentals": 3, "leases": 0, "occupiedPercentage": 0},
    {"month": "Mar", "rentals": 6, "leases": 0, "occupiedPercentage": 0},
    {"month": "Apr", "rentals": 6, "leases": 0, "occupiedPercentage": 0},
    {"month": "May", "rentals": 6, "leases": 0, "occupiedPercentage": 0},
    {"month": "Jun", "rentals": 7, "leases": 0, "occupiedPercentage": 0},
    {"month": "Jul", "rentals": 7, "leases": 0, "occupiedPercentage": 0},
    {"month": "Aug", "rentals": 8, "leases": 1, "occupiedPercentage": 12.5},

  ];
  runApp(FlChartApp(data: data,));
}

class FlChartApp extends StatefulWidget {
  List<Map<String, dynamic>>? data ;
   FlChartApp({super.key,this.data});

  @override
  State<FlChartApp> createState() => _FlChartAppState();
}

class _FlChartAppState extends State<FlChartApp> {
  List<Map<String, dynamic>> data = [
    {"month": "Oct", "rentals": 0, "leases": 0, "occupiedPercentage": 0},
    {"month": "Nov", "rentals": 0, "leases": 0, "occupiedPercentage": 0},
    {"month": "Dec", "rentals": 0, "leases": 0, "occupiedPercentage": 0},
    {"month": "Jan", "rentals": 0, "leases": 0, "occupiedPercentage": 0},
    {"month": "Feb", "rentals": 3, "leases": 0, "occupiedPercentage": 0},
    {"month": "Mar", "rentals": 6, "leases": 0, "occupiedPercentage": 0},
    {"month": "Apr", "rentals": 6, "leases": 0, "occupiedPercentage": 0},
    {"month": "May", "rentals": 6, "leases": 0, "occupiedPercentage": 0},
    {"month": "Jun", "rentals": 7, "leases": 0, "occupiedPercentage": 0},
    {"month": "Jul", "rentals": 7, "leases": 0, "occupiedPercentage": 0},
    {"month": "Aug", "rentals": 8, "leases": 1, "occupiedPercentage": 12.5},
    {"month": "Sep", "rentals": 8, "leases": 9, "occupiedPercentage": 112.5},
  ];
  bool loading = false;
  Future<void> fetchchartdata() async {
    print("calling");
    setState(() {
      loading = true;

    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await http
        .get(Uri.parse('${Api_url}/api/rentals/occupied_properties/$id'), headers: {
      "authorization": "CRM $token",
      "id": "CRM $id",
      "Content-Type": "application/json"
    });
  //  print('${Api_url}/api/payment/admin_balance/$id');
    print(response.body);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData["statusCode"] == 200) {
        final dataaa= jsonData["data"];
        print("dataaaaa ${dataaa.length}");
        setState(() {
          data = [];
          dataaa.forEach((element) {
            data.add(Map<String, dynamic>.from(element));
          });
          for (int i = 0; i < data.length; i++) {
            spots.add(FlSpot(i.toDouble(), data[i]["occupiedPercentage"].toDouble()));
            monthMap[i] = data[i]["month"];
            if(i == data.length - 1){
              leases = data[i]["leases"].toString();
              rentals = data[i]["rentals"].toString();
              occupancy = data[i]["occupiedPercentage"].toString();

            }
          }
          loading = false;
        });
      } else {
        throw Exception('Failed to load dataaaaaaaa');
      }
    } else {
      throw Exception('Failed to load datawwwwww');
    }
  }

  List<FlSpot> spots = [];
  String leases = "";
  String rentals = "";
  String occupancy = "";
  Map<int, String> monthMap = {};

  @override
  void initState() {
    data = widget.data!;
    super.initState();
    fetchchartdata();


  }

  @override
  Widget build(BuildContext context) {
    return
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            height: 220,
            margin: EdgeInsets.only(top: 20),
            child: Card(

              child: loading ? Center(child: CircularProgressIndicator()) :Column(
                children: [
                  SizedBox(

                    height: 180,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: double.tryParse(occupancy)! > 100 ?  double.tryParse(occupancy)!: 100.0,
                          titlesData: FlTitlesData(
                            show: true,

                            bottomTitles: AxisTitles(

                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() % 1 == 0) {
                                    final monthIndex = value.toInt();
                                    return Text(monthMap[monthIndex]!,style: TextStyle(fontSize: 10),);
                                  } else {
                                    return Text('');
                                  }
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(

                              sideTitles: SideTitles(

                                showTitles: true,
                                interval: 20,
                                getTitlesWidget: (value, meta) {
                                  return Text('${value.toInt()}',style: TextStyle(fontSize: 10),);
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              color: Colors.blue,
                              isCurved: true,
                              preventCurveOverShooting: true,
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.blue.withOpacity(0.3),
                              ),
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.blue,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),

                            ),
                          ],
                          lineTouchData: LineTouchData(
                            enabled: true,

                            touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                              if (!event.isInterestedForInteractions || touchResponse == null || touchResponse.lineBarSpots == null) {
                                setState(() {

                                });
                                return;
                              }


                              final touchedSpot = touchResponse.lineBarSpots!.first;
                              final month = monthMap[touchedSpot.x.toInt()];
                              final percentage = touchedSpot.y;


                            },

                            touchTooltipData: LineTouchTooltipData(

                              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                return touchedSpots.map((touchedSpot) {
                                  final month = monthMap[touchedSpot.x.toInt()];
                                  final percentage = touchedSpot.y;
                                  return LineTooltipItem(
                                    '$month\n${percentage.toStringAsFixed(1)}%',
                                    const TextStyle(color: Colors.white),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text('${leases} of ${rentals} Units currently occupied - ${occupancy}', style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),)
                ],
              ),
            ),
          
              );
  }
}