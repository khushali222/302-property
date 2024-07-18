import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DonutChart extends StatelessWidget {
  final int newWorkOrders;
  final int overdueWorkOrders;

  DonutChart({required this.newWorkOrders, required this.overdueWorkOrders});

  @override
  Widget build(BuildContext context) {
    int totalWorkOrders = newWorkOrders + overdueWorkOrders;

    return Row(
      children: [
        Container(
          //margin  :EdgeInsets.symmetric(),
          width: 150,
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(

                child: PieChart(
                  PieChartData(
                    sections: showingSections(),
                    centerSpaceRadius: 50,
                    sectionsSpace: 0,
                  ),
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
              SizedBox(height: 20),

            ],
          ),
        ),
       // SizedBox(width: 25,),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start
          ,
          children: [
            LegendItem(color: Color.fromRGBO(21, 43, 83, 1), text: 'New Work\nOrders'),
            SizedBox(height: 10),
            LegendItem(color: Color.fromRGBO(41, 134, 213, 1), text: 'Overdue Work\nOrders'),
          ],
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections() {
    return [
      PieChartSectionData(
        color:  Color.fromRGBO(21, 43, 83, 1),
        value: newWorkOrders.toDouble(),
        showTitle: false,
        //title: '$newWorkOrders\nNew',
        radius: 15,
       // titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color:Color.fromRGBO(41, 134, 213, 1),
        value: overdueWorkOrders.toDouble(),
        showTitle: false,
      //  title: '$overdueWorkOrders\nOverdue',
        radius: 15,
       // titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }
}
class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  LegendItem({required this.color, required this.text});

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
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}