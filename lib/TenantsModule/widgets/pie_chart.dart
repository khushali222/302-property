import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

/*void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pie Chart Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blueGrey,
        brightness: Brightness.dark,
      ),
      home:  PieCharts(),
    );
  }
}*/

class PieCharts extends StatelessWidget {
  Map<String, double> dataMap = <String, double>{
    "New Work Orders": 5,
    "Overdue Work Orders": 5,
  };
  final colorList = <Color>[

    Color.fromRGBO(21,43,81,1),
    Color.fromRGBO(90,134,213,1),

  ];

   PieCharts({Key? key,required this.dataMap}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return  Container(
          height: 250,
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: PieChart(
            dataMap: dataMap,
            chartRadius: MediaQuery.of(context).size.width / 2,
            colorList: colorList,
            chartLegendSpacing: 20,
            legendOptions: const LegendOptions(
              legendPosition: LegendPosition.bottom, // Adjust this as needed
              showLegendsInRow: false, // Set to false to display in column
              legendTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              showLegends: true,
            ),
              chartValuesOptions:ChartValuesOptions(
                  showChartValuesInPercentage:false,
                  showChartValues:false
              )
          ),

    );
  }
}
