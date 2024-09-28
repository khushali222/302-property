import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

void main() {
  runApp( Fl_chart());
}


class Fl_chart extends StatelessWidget {
  const Fl_chart({super.key});

  @override
  Widget build(BuildContext context) {
   return MaterialApp(
     home: Scaffold(
       body: Center(
         child: AspectRatio(
           aspectRatio: 2.0,
           child: LineChart(
           LineChartData(
                   titlesData: FlTitlesData(
                     show: true,
                     bottomTitles: AxisTitles(
                       axisNameWidget: Text("X Axix"),
                        sideTitles: SideTitles(
                          getTitlesWidget: (value ,meta){
                            String text = "";
                            switch (value.toInt()){
                              case 0 :
                                text = "sep";
                                break;

                            }
                            return Text(text);

                          }
                        ),
                     ),
                     topTitles: AxisTitles(),
                     rightTitles: AxisTitles(),
                   ),

                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          FlSpot(0, 0),
                          FlSpot(1, 40),
                          FlSpot(2, 80),
                          FlSpot(3, 20),
                          FlSpot(4, 40),
                          FlSpot(5, 70),
                          FlSpot(6, 20),
                        ],
                        color: Colors.blue,
                        isCurved: true,
                        preventCurveOverShooting: true,
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withOpacity(0.3),
                        ),
                      ),
                    ]
                  ),
             duration: Duration(milliseconds: 150), // Optional
                  curve: Curves.linear,


                ),
         ),
       ),
     ),
   );
  }
}