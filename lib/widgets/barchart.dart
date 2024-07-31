import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Barchart extends StatefulWidget {
  @override
  State<Barchart> createState() => _BarchartState();
}

class _BarchartState extends State<Barchart> {
  final List<RevenueData> chartData = [
    RevenueData('Jan', 5000),
    RevenueData('Feb', 6000),
    RevenueData('Mar', 7000),
    RevenueData('Apr', 8000),
    RevenueData('May', 9000),
    RevenueData('Jun', 10000),
    RevenueData('Jul', 11000),
    RevenueData('Aug', 12000),
    RevenueData('Sep', 13000),
    RevenueData('Oct', 14000),
    RevenueData('Nov', 15000),
    RevenueData('Dec', 16000),
  ];

  final List<String> items = [
    'This Year',
    'Previous Year',
  ];

  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.white,
      // color: Colors.deepPurple,
      height: 250,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 4,
        // color: Colors.white.withOpacity(1),
        color: Colors.white,
        surfaceTintColor: Colors.white,
        child: Column(
          children: [
            Container(
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
              child: SfCartesianChart(
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

                    // xAxisName: "Total Revenue",
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
