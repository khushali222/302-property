import 'package:flutter/material.dart';
import 'package:three_zero_two_property/screens/pie_chart.dart';

import '../widgets/appbar.dart';
import 'barchart.dart';

class Dashbaord extends StatefulWidget {
  const Dashbaord({Key? key}) : super(key: key);

  @override
  State<Dashbaord> createState() => _DashbaordState();
}

class _DashbaordState extends State<Dashbaord> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget_302.App_Bar(),
      body: Column(
        children: [
          PieCharts(),
          Barchart()
        ],
      )
    );
  }
}
