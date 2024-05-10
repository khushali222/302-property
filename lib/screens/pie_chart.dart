import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

void main() {
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
      home: const PieCharts(),
    );
  }
}

class PieCharts extends StatelessWidget {
  const PieCharts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataMap = <String, double>{
      "Properties": 5,
      "Tenants": 5,
      "Applicants": 5,
      "Vendors": 5,
      "Work Orders": 5,
    };

    final colorList = <Color>[
       Color.fromRGBO(50,75,119,1),
       Color.fromRGBO(40,60,95,1),
       Color.fromRGBO(21,43,81,1),
       Color.fromRGBO(90,134,213,1),
       Color.fromRGBO(60,89,142,1),

    ];

    return  Container(
          height: 250,
          margin: EdgeInsets.all(10),
          child: Card(
            color: Colors.white,
            elevation: 3,
            child: PieChart(
              dataMap: dataMap,
              chartRadius: MediaQuery.of(context).size.width / 3.2,
              colorList: colorList,
              legendOptions: const LegendOptions(
                showLegends: true,
              ),
                chartValuesOptions:ChartValuesOptions(
                    showChartValuesInPercentage:false,
                    showChartValues:false
                )
            ),
          ),

    );
  }
}
