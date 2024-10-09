import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import '../constant/constant.dart';

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
  final Map<String, double> dataMap;
  final colorList = <Color>[
    blueColor,
    Colors.transparent, // Gap1
    Color.fromRGBO(40, 60, 95, 1),
    Colors.transparent, // Gap2
    Color.fromRGBO(50, 75, 119, 1),
    Colors.transparent, // Gap3
    Color.fromRGBO(60, 89, 142, 1),
    Colors.transparent, // Gap4
    Color.fromRGBO(90, 134, 213, 1),
    Colors.transparent, // Gap5
  ];
  PieCharts({Key? key, required this.dataMap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter out the gaps for the legend
    Map<String, double> legendDataMap = dataMap
        .map((key, value) => MapEntry(key, key.contains('Gap') ? -1.0 : value))
        .cast<String, double>();
    print(legendDataMap);
    legendDataMap.removeWhere((key, value) => value == -1.0);

    return LayoutBuilder(
        builder: (context,contraints) {

          if(contraints.maxWidth > 500){

            return Container(
              height: 250,
              width: 375,
              margin: EdgeInsets.all(10),
              child: Card(
                color: Colors.white,
                surfaceTintColor: Colors.white,
                elevation: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(

                        child: PieChart(
                          dataMap: dataMap,
                          chartRadius: MediaQuery.of(context).size.width / 3.2,
                          colorList: colorList,
                          chartType: ChartType.disc,
                          centerText: "",
                          initialAngleInDegree: 0,
                          legendOptions: LegendOptions(
                            showLegends: false,
                          ),
                          chartValuesOptions: ChartValuesOptions(
                            showChartValuesInPercentage: false,
                            showChartValues: false,
                          ),
                          emptyColor: Colors.transparent,
                          gradientList: null,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: legendDataMap.keys.map((key) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorList[dataMap.keys.toList().indexOf(key)],
                                ),

                              ),
                              SizedBox(width: 10),
                              Text(key,maxLines: 3,),
                            ],
                          );
                        }).toList(),
                      ),
                    )
                  ],
                ),
              ),
            );
          }

          return Container(
            height: 250,
            margin: EdgeInsets.all(10),
            child: Card(
              color: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(

                      child: PieChart(
                        dataMap: dataMap,
                        chartRadius: MediaQuery.of(context).size.width / 3.2,
                        colorList: colorList,
                        chartType: ChartType.disc,
                        centerText: "",
                        initialAngleInDegree: 0,
                        legendOptions: LegendOptions(
                          showLegends: false,
                        ),
                        chartValuesOptions: ChartValuesOptions(
                          showChartValuesInPercentage: false,
                          showChartValues: false,
                        ),
                        emptyColor: Colors.transparent,
                        gradientList: null,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: legendDataMap.keys.map((key) {
                        return Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                  // shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(3),
                                  color: colorList[dataMap.keys.toList().indexOf(key)],
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(key,maxLines: 3),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
            ),
          );
        }
    );
  }
}
