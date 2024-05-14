import 'dart:convert';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:three_zero_two_property/screens/pie_chart.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:http/http.dart' as http;
import 'barchart.dart';


class DashboardData {
  // int tenantCount = 0;
  // int rentalCount = 0;
  // int vendorCount = 0;
  // int applicantCount = 0;
  // int workOrderCount = 0;

  List<int> countList = [

  ];
  List<int> amountList = [];

  List<IconData> icons = [
    Icons.home,
    Icons.work,
    Icons.shopping_cart,
    Icons.school,
    Icons.restaurant,
  ];

  List<String> titles = [
    "Properties",
    "Tenants",
    "Applicants",
    "Vendors",
    "Work order"
  ];

  List<Color> colorc = [
    Color.fromRGBO(21, 43, 81, 1),
    Color.fromRGBO(40, 60, 95, 1),
    Color.fromRGBO(50, 75, 119, 1),
    Color.fromRGBO(60, 89, 142, 1),
    Color.fromRGBO(90, 134, 213, 1),
  ];

  List<Color> colors = [
    Color.fromRGBO(21, 43, 81, 1),
    Color.fromRGBO(40, 60, 95, 1),
    Color.fromRGBO(50, 75, 119, 1),
    Color.fromRGBO(60, 89, 142, 1),
    Color.fromRGBO(90, 134, 213, 1),
  ];

  DashboardData({required this.countList,required this.amountList});


}
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool loading = false;

  // Future<void> fetchDatacount() async {
  //
  //   final response = await http.get(Uri.parse(
  //       'https://saas.cloudrentalmanager.com/api/admin/counts/1707921596879'));
  //   final jsonData = json.decode(response.body);
  //   if (jsonData["statusCode"] == 200) {
  //     setState(() {
  //       countList[0] = jsonData['tenantCount'];
  //       countList[1] = jsonData['rentalCount'];
  //       countList[2] = jsonData['vendorCount'];
  //       countList[3] = jsonData['applicantCount'];
  //       countList[4] = jsonData['workOrderCount'];
  //     });
  //
  //   } else {
  //     throw Exception('Failed to load data');
  //   }
  // }
  Future<void> fetchDatacount() async {
    setState(() {
      loading = true;
    });
    try {
      final response = await http.get(Uri.parse(
          'https://saas.cloudrentalmanager.com/api/admin/counts/1707921596879'));
      final jsonData = json.decode(response.body);
      if (jsonData["statusCode"] == 200) {
        setState(() {
          countList[0] = jsonData['tenantCount'];
          countList[1] = jsonData['rentalCount'];
          countList[2] = jsonData['vendorCount'];
          countList[3] = jsonData['applicantCount'];
          countList[4] = jsonData['workOrderCount'];
          loading = false;
        });

      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  // Future<void> fetchData() async {
  //   // setState(() {
  //   //   loading = true;
  //   // });
  //   try {
  //     final response = await http.get(Uri.parse(
  //         'https://saas.cloudrentalmanager.com/api/payment/admin_balance/1707921596879'));
  //     final jsonData = json.decode(response.body);
  //     if (jsonData["statusCode"] == 200) {
  //       setState(() {
  //         pastDueAmount = double.parse(jsonData['PastDueAmount'].toString());
  //         totalCollectedAmount = jsonData['TotalCollectedAmount'];
  //         lastMonthCollectedAmount = jsonData['LastMonthCollectedAmount'];
  //         nextMonthCharge = double.parse(jsonData['NextMonthCharge'].toString());
  //         loading = false;
  //       });
  //
  //     } else {
  //       throw Exception('Failed to load data');
  //     }
  //   } catch (e) {
  //     print('Error fetching data: $e');
  //   } finally {
  //     setState(() {
  //       loading = false;
  //     });
  //   }
  // }

  double pastDueAmount = 0.0;
  int totalCollectedAmount = 0;
  int lastMonthCollectedAmount = 0;
  double nextMonthCharge = 0.0;

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://saas.cloudrentalmanager.com/api/payment/admin_balance/1707921596879'));
    final jsonData = json.decode(response.body);
    if (jsonData["statusCode"] == 200) {
      // setState(() {
      //   pastDueAmount = jsonData['PastDueAmount'];
      //   totalCollectedAmount = jsonData['TotalCollectedAmount'];
      //   lastMonthCollectedAmount = jsonData['LastMonthCollectedAmount'];
      //   nextMonthCharge = jsonData['NextMonthCharge'];
      // });
      setState(() {
        pastDueAmount = double.parse(jsonData['PastDueAmount'].toString());
        totalCollectedAmount = jsonData['TotalCollectedAmount'];
        lastMonthCollectedAmount = jsonData['LastMonthCollectedAmount'];
        nextMonthCharge = double.parse(jsonData['NextMonthCharge'].toString());
      });
    } else {
      throw Exception('Failed to load data');
    }
  }
  late DashboardData dashboardData;
  List<int> countList = List.filled(5, 0);
  List<int> amountList = List.filled(5, 0);
  @override
  void initState() {
    super.initState();
    dashboardData = DashboardData(countList: [0, 0, 0, 0, 0], amountList: [0, 0, 0, 0, 0]);
    fetchDatacount();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    fetchData();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo.png"),
              ),
              SizedBox(height: 40),
              buildListTile(Icon(CupertinoIcons.circle_grid_3x3,color: Colors.white,), "Dashboard",true),
              buildListTile(Icon(CupertinoIcons.house), "Add Property Type",false),
              buildListTile(Icon(CupertinoIcons.person_add), "Add Staff Member",false),
              buildDropdownListTile(
                  Icon(Icons.key), "Rental", ["Properties", "RentalOwner", "Tenants"]),
              buildDropdownListTile(Icon(Icons.thumb_up_alt_outlined), "Leasing",
                  ["Rent Roll", "Applicants"]),
              buildDropdownListTile(
                  Image.asset("assets/icons/maintence.png", height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"]),
            ],
          ),
        ),
      ),
      appBar: widget_302.App_Bar(context: context),
      body:
        Center(
          child: loading ? SpinKitFadingCircle(
            color: Colors.black,
            size: 50.0,
          ):
          ListView(
            children: [
              Material(
                elevation: 3,
                child: Divider(
                  height: 1,
                  color: Colors.transparent,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.012),
              //welcome
              Row(
                children: [
                  SizedBox(
                    width: width * 0.1,
                  ),
                  Text(
                    "Hello Lou ,Welcome back",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.width * 0.04),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              //my dashboard
              Row(
                children: [
                  SizedBox(
                    width: width * 0.1,
                  ),
                  Text(
                    "My Dashboard",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.05),
                  ),
                ],
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    // Tablet layout - horizontal
                    return Padding(
                      padding: const EdgeInsets.only(left: 80, right: 80, top: 20),
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: MediaQuery.of(context).size.width * 0.02,
                        runSpacing: MediaQuery.of(context).size.width * 0.02,
                        children: List.generate(
                          5,
                              (index) => SizedBox(
                            child: Material(
                              elevation: 3,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: dashboardData.colorc[index],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Material(
                                          elevation: 5,
                                          borderRadius: BorderRadius.circular(20),
                                          child: Container(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                              color: dashboardData.colors[index],
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                dashboardData.icons[index],
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Text(
                                          countList[index].toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Text(
                                          dashboardData.titles[index],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    // Phone layout - vertical
                    return Column(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.width * 0.05),
                        Padding(
                          padding: const EdgeInsets.only(left: 25, right: 25),
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            spacing: MediaQuery.of(context).size.width * 0.02,
                            runSpacing: MediaQuery.of(context).size.width * 0.02,
                            children: List.generate(
                              5,
                                  (index) {
                                return Material(
                                  elevation: 3,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 95,
                                    height: 95,
                                    decoration: BoxDecoration(
                                      color: dashboardData.colorc[index],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      children: [
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            SizedBox(width: 10),
                                            Material(
                                              elevation: 5,
                                              borderRadius: BorderRadius.circular(20),
                                              child: Container(
                                                height: 20,
                                                width: 20,
                                                decoration: BoxDecoration(
                                                  color: dashboardData.colors[index],
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    dashboardData.icons[index],
                                                    color: Colors.white,
                                                    size: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            SizedBox(width: 10),
                                            Text(
                                              countList[index].toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            SizedBox(width: 10),
                                            Text(
                                              dashboardData.titles[index],
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Row(
                children: [
                  SizedBox(
                    width: width * 0.1,
                  ),
                  Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * .37,
                          // height: 50,
                          height: height * 0.071,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    height: height * 0.03,
                                    decoration: BoxDecoration(
                                        color: Color.fromRGBO(21, 43, 81, 1),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        )),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        "Due rent for the month",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.024,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 25,
                                  ),
                                  Text(
                                    // "1200",
                                    // nextMonthCharge.toString(),
                                    '\$${nextMonthCharge.toStringAsFixed(2)}',
                                   //   nextMonthCharge.toStringAsFixed(2),
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.034),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.06,
                  ),
                  Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * .37,
                          height: height * 0.071,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    height: height * 0.03,
                                    decoration: BoxDecoration(
                                        color: Color.fromRGBO(21, 43, 81, 1),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        )),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        "Total collected amount",
                                        style: TextStyle(
                                            color: Colors.white,
                                            // fontSize: 9,
                                            fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.024,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 25,
                                  ),
                                  Text(
                                    // "2500",
                                    //   countList[1].toString(),
                                    '\$${totalCollectedAmount.toString()}',
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.034),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: width * 0.1,
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                children: [
                  SizedBox(
                    width: width * 0.1,
                  ),
                  Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * .37,
                          // height: 50,
                          height: height * 0.071,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    // height:
                                    //    20,
                                    height: height * 0.03,
                                    decoration: BoxDecoration(
                                        color: Color.fromRGBO(21, 43, 81, 1),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        )),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        "Total past due amount",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.024,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 25,
                                  ),
                                  Text(
                                    // "1000",
                                    "\$${pastDueAmount.toStringAsFixed(2).toString()}",
                                    //  pastDueAmount.toStringAsFixed(2),
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.034),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.06,
                  ),
                  Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * .37,
                          // height:50,
                          height: height * 0.071,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    // height:
                                    //     20,
                                    height: height * 0.03,
                                    decoration: BoxDecoration(
                                        color: Color.fromRGBO(21, 43, 81, 1),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        )),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        "Last month collected amount",
                                        style: TextStyle(
                                            color: Colors.white,
                                            // fontSize: 9,
                                            fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.024,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 25,
                                  ),
                                  Text(
                                    // "1800",
                                   "\$${ lastMonthCollectedAmount.toString()}",
                                    // amountList[3].toString(),
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.034),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: width * 0.1,
                  ),
                ],
              ),
              // SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              // PieCharts(),
              // SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              // Barchart()
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  // Check if the device width is less than 600 (considered as phone screen)
                  if (constraints.maxWidth < 500) {
                    // Phone layout
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: PieCharts(),
                        ), // Vertical layout for phone
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015),
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Barchart(),
                        ),
                      ],
                    );
                  } else {
                    // Tablet layout
                    return Padding(
                      padding: const EdgeInsets.only(
                        top: 35,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          PieCharts(),
                          SizedBox(
                            width: 10,
                          ),
                          Barchart(),
                        ],
                      ),
                    );
                  }
                },
              ),

            ],
          )
        ),

    );
  }

  Widget buildListTile(Widget leadingIcon, String title,bool active) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: active?Color.fromRGBO(21, 43, 81, 1):Colors.transparent,
          borderRadius: BorderRadius.circular(10)
      ),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(

        leading: leadingIcon,
        title: Text(title,style: TextStyle(
            color: active?Colors.white:Colors.black
        ),),
      ),
    );
  }
  Widget buildDropdownListTile(
      Widget leadingIcon, String title, List<String> subTopics) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ExpansionTile(
        leading: leadingIcon,
        title: Text(title),
        children: subTopics.map((subTopic) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              title: Text(subTopic),
              onTap: () {
                // Handle sub-topic selection
                Navigator.pop(
                    context); // Close drawer after selecting a sub-topic
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
