import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constant/constant.dart';

class DonutChart extends StatelessWidget {
  final int newWorkOrders;
  final int overdueWorkOrders;

  DonutChart({required this.newWorkOrders, required this.overdueWorkOrders});

  @override
  Widget build(BuildContext context) {
    int totalWorkOrders = newWorkOrders + overdueWorkOrders;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // Tablet view
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sections: showingSections(),
                        centerSpaceRadius: 80,
                        sectionsSpace: 5,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$totalWorkOrders',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Total Work \nOrders',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LegendItem(
                    color: blueColor,
                    text: 'New Work Orders',
                    size: 20,
                  ),
                  SizedBox(height: 10),
                  LegendItem(
                    color: Color.fromRGBO(41, 134, 213, 1),
                    text: 'Overdue Work Orders',
                    size: 20,
                  ),
                ],
              ),
            ],
          );
        } else {
          // Mobile view
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sections: showingSectionsmobile(),
                        centerSpaceRadius: 50,
                        sectionsSpace: 5,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$totalWorkOrders',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Total Work \nOrders',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LegendItem(
                    color: blueColor,
                    text: 'New Work\nOrders',

                  ),
                  SizedBox(height: 10),
                  LegendItem(
                    color: Color.fromRGBO(41, 134, 213, 1),
                    text: 'Overdue Work\nOrders',
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  List<PieChartSectionData> showingSections() {
    return [
      PieChartSectionData(
        color: blueColor,
        value: newWorkOrders.toDouble(),
        showTitle: false,
        radius: 25,
      ),
      PieChartSectionData(
        color: Color.fromRGBO(41, 134, 213, 1),
        value: overdueWorkOrders.toDouble(),
        showTitle: false,
        radius: 25,
      ),
    ];
  }
  List<PieChartSectionData> showingSectionsmobile() {
    return [
      PieChartSectionData(
        color: blueColor,
        value: newWorkOrders.toDouble(),
        showTitle: false,
        radius: 15,
      ),
      PieChartSectionData(
        color: Color.fromRGBO(41, 134, 213, 1),
        value: overdueWorkOrders.toDouble(),
        showTitle: false,
        radius: 15,
      ),
    ];
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  final double? size;


  LegendItem({required this.color, required this.text,this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: size ?? 14),
        ),
      ],
    );
  }
}
