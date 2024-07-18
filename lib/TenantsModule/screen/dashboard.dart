import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/widgets/pie_chart.dart';
import 'package:three_zero_two_property/screens/Rental/Properties/properties.dart';
import 'property/property_table.dart';
import '../widgets/appbar.dart';
import 'package:http/http.dart' as http;
import '../../constant/constant.dart';
import '../widgets/drawer_tiles.dart';

import '../../widgets/barchart.dart';
import '../widgets/chart.dart';
import 'profile.dart';
class DashboardData {
  // int tenantCount = 0;
  // int rentalCount = 0;
  // int vendorCount = 0;
  // int applicantCount = 0;
  // int workOrderCount = 0;

  List<dynamic> countList = [];
  List<int> amountList = [];

  List<String> icons = [
    "assets/images/Properti-icon.svg",
    "assets/images/workorder-icon.svg",
        "assets/images/Properti-icon.svg",
    "assets/images/workorder-icon.svg",
        "assets/images/Properti-icon.svg"
  ];

  List<String> titles = [

    "Work Orders",
    "Balance",
    "Monthly Rent",
        "Due Date",
    "Lease End Date",


  ];

  List<Color> colorc = [
    const Color.fromRGBO(21, 43, 81, 1),
    const Color.fromRGBO(40, 60, 95, 1),
    const Color.fromRGBO(50, 75, 119, 1),
    const Color.fromRGBO(60, 89, 142, 1),
    const Color.fromRGBO(90, 134, 213, 1),
  ];

  List<Color> colors = [
    const Color.fromRGBO(21, 43, 81, 1),
    const Color.fromRGBO(40, 60, 95, 1),
    const Color.fromRGBO(50, 75, 119, 1),
    const Color.fromRGBO(60, 89, 142, 1),
    const Color.fromRGBO(90, 134, 213, 1),
  ];

  DashboardData({required this.countList, required this.amountList});
}

class Dashboard_tenants extends StatefulWidget {
  Dashboard_tenants({super.key});

  @override
  State<Dashboard_tenants> createState() => _Dashboard_tenantsState();
}

class _Dashboard_tenantsState extends State<Dashboard_tenants> {
  String firstname = '';
  String lastname = '';
  bool loading = false;
  Future<void> fetchDatacount() async {
    /*setState(() {
      loading = true;
    });*/
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("tenant_id");
      String? admin_id = prefs.getString("adminId");
      String? token = prefs.getString('token');

      final response =
      await http.get(
          Uri.parse('${Api_url}/api/tenant/count/${id!}'),
          headers: {
           "id":"CRM $id",
           "authorization": "CRM $token",
            "Content-Type": "application/json"
          }

      );
      print(response.body);
      final jsonData = json.decode(response.body);
      if (jsonData["statusCode"] == 200) {
        print(jsonData);
        setState(() {
          //countList[0] = jsonData["data"]['all_workorders'];
        //  countList[1] = jsonData['rentalCount'];
          countList[2] = jsonData["data"]['rent'];
          countList[3] = jsonData["data"]['due_date'];
          countList[4] = jsonData["data"]['end_date'];
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
  Future<void> fetchDatafinancial() async {
    /*setState(() {
      loading = true;
    });*/
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("tenant_id");
      String? admin_id = prefs.getString("adminId");
      String? token = prefs.getString('token');
      print(id);
      print(token);
      final response =
      await http.get(
          Uri.parse('${Api_url}/api/payment/tenant_financial/${id!}'),
          headers: {
            "id":"CRM $id",
            "authorization": "CRM $token",
            "Content-Type": "application/json"
          }

      );
      print(response.body);
      final jsonData = json.decode(response.body);
      if (jsonData["statusCode"] == 200) {
        print(jsonData);
        print(jsonData["totalBalance"]);
        setState(() {
         // countList[0] = jsonData['property_staffMember'];
          countList[1] = jsonData['totalBalance'];
        /*  countList[2] = jsonData['vendorCount'];
          countList[3] = jsonData['applicantCount'];
          countList[1] = jsonData['workorder_staffMember'];*/
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
  int newworkorder = 0;
  int overdueworkorder = 0;
  double currentMonthRentDue = 0.0;
  double lastMonthRentDue = 0.0;
  double currentMonthRentPaid = 0.0;
  double lastMonthRentPaid = 0.0;
  double totalRentPastDue = 0.0;

  Future<void> fetchData() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    print(admin_id);
    final response =
    await http.get(
        Uri.parse('${Api_url}/api/tenant/dashboard_workorder/$id'),
        headers: {
          "authorization": "CRM $token",
          "id":"CRM $id",
          "Content-Type": "application/json"
        }
    );
   //print('${Api_url}/api/payment/admin_balance/$id');
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print(jsonData);
      if (jsonData["statusCode"] == 200) {
        final data = jsonData["data"];
        setState(() {
         var newwork = data["new_workorders"];
         var overdue = data["overdue_workorders"];
         print(newwork);
         newworkorder = newwork;
         overdueworkorder = overdue;
         countList[0] = data["all_workorders"];
         print(data);
        });
      } else {
        throw Exception('Failed to load data');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  late DashboardData dashboardData;
  List<dynamic> countList = [0,0,0,"",""];
  List<int> amountList = List.filled(2, 0);

  @override
  void initState() {
    super.initState();
    dashboardData =
        DashboardData(countList: [0,0,0,"",""], amountList: [0, 0]);
    fetchDatacount();
    fetchData();
    _loadName();
    fetchDatafinancial();
  }

  Future<void> _loadName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      firstname = prefs.getString('first_name') ?? '';
      lastname = prefs.getString('last_name') ?? '';
    });
  }

  var appBarHeight = AppBar().preferredSize.height;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo.png"),
              ),
              const SizedBox(height: 40),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.circle_grid_3x3,
                    color: Colors.white,
                  ),
                  "Dashboard",
                  true),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.person,
                    color: Colors.black,
                  ),
                  "Profile",
                  false),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.home,
                    color: Colors.black,
                  ),
                  "Properties",
                  false),
              buildListTile(
                  context,
                  const Icon(
                  Icons.bar_chart,
                    color: Colors.black,
                  ),
                  "Financial",
                  false),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.square_list,
                    color: Colors.black,
                  ),
                  "Work Order",
                  false),
             /* buildDropdownListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.key,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Rental",
                  ["Properties", "RentalOwner", "Tenants"]),
              buildDropdownListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.thumbsUp,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Leasing",
                  ["Rent Roll", "Applicants"]),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"]),*/
            ],
          ),
        ),
      ),
      appBar: widget_302.App_Bar(context: context),
      body: Center(
          child: loading
              ? const SpinKitFadingCircle(
            color: Colors.black,
            size: 50.0,
          )
              : ListView(
            children: [
              // Material(
              //   elevation: 3,
              //   child: Divider(
              //     height: 1,
              //     color: Colors.transparent,
              //   ),
              // ),
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.012),
              //welcome
              Row(
                children: [
                  SizedBox(
                    width: width * 0.05,
                  ),
                  Text(
                    "Hello $firstname $lastname, Welcome back",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize:
                        MediaQuery.of(context).size.width * 0.04),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              //my dashboard
              Row(
                children: [
                  SizedBox(
                    width: width * 0.05,
                  ),
                  Text(
                    "My Dashboard",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize:
                        MediaQuery.of(context).size.width * 0.05),
                  ),
                ],
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    // Tablet layout - horizontal
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 35, right: 80, top: 20),
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: MediaQuery.of(context).size.width * 0.02,
                        runSpacing:
                        MediaQuery.of(context).size.width * 0.02,
                        children: List.generate(
                          5,
                              (index) => SizedBox(
                            width:
                            160, // Ensure SizedBox has defined width
                            height:
                            160, // Ensure SizedBox has defined height
                            child: Material(
                              elevation: 3,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: dashboardData.colorc[index],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        Material(
                                          elevation: 5,
                                          borderRadius:
                                          BorderRadius.circular(20),
                                          child: Container(
                                            height: 40,
                                            width: 40,
                                            padding:
                                            const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: dashboardData
                                                  .colors[index],
                                              borderRadius:
                                              BorderRadius.circular(
                                                  20),
                                            ),
                                            child: SvgPicture.asset(
                                              "${dashboardData.icons[index]}",
                                              fit: BoxFit.cover,
                                              height: 27,
                                              width: 27,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        Text(
                                          countList[index].toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        Text(
                                          dashboardData.titles[index],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
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
                        SizedBox(
                            height:
                            MediaQuery.of(context).size.width * 0.05),
                        Padding(
                          padding:
                          const EdgeInsets.only(left: 25, right: 25),
                          child: GridView.builder(
                            itemCount: 5,
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                              2, // Number of items per row
                              crossAxisSpacing:
                              MediaQuery.of(context).size.width *
                                  0.02,
                              mainAxisSpacing:
                              MediaQuery.of(context).size.width *
                                  0.02,
                              childAspectRatio:
                              1.2, // Adjust as needed for your design
                            ),
                            itemBuilder: (context, index) {
                              return Material(
                                elevation: 3,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: dashboardData.colorc[index],
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const SizedBox(width: 10),
                                          Material(
                                            elevation: 10,
                                            borderRadius:
                                            BorderRadius.circular(30),
                                            child: Container(
                                                height: 50,
                                                width: 50,
                                                padding:
                                                const EdgeInsets.all(
                                                    10),
                                                decoration: BoxDecoration(
                                                  color: dashboardData
                                                      .colors[index],
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(20),
                                                ),
                                                child: SvgPicture.asset(
                                                  "${dashboardData.icons[index]}",
                                                  fit: BoxFit.cover,
                                                  height: 27,
                                                  width: 27,
                                                )),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const SizedBox(width: 10),
                                          Text(
                                            countList[index].toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const SizedBox(width: 10),
                                          Text(
                                            dashboardData.titles[index],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            shrinkWrap:
                            true, // If you want the GridView to take only the space it needs
                            physics:
                            const NeverScrollableScrollPhysics(), // If you don't want it to scroll
                          ),
                        )
                      ],
                    );
                  }
                },
              ),

              /*  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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
                                  // Text(
                                  //   // "1200",
                                  //   // nextMonthCharge.toString(),
                                  //   '\$${nextMonthCharge.toStringAsFixed(2)}',
                                  //  //   nextMonthCharge.toStringAsFixed(2),
                                  //   style: TextStyle(
                                  //       color: Colors.blue,
                                  //       fontSize:
                                  //       MediaQuery.of(context).size.width *
                                  //           0.034),
                                  // ),
                                  Text(
                                    nextMonthCharge != 0 ? '\$${nextMonthCharge.toStringAsFixed(2)}' : '0',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: MediaQuery.of(context).size.width * 0.034,
                                    ),
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
                                  // Text(
                                  //   // "2500",
                                  //   //   countList[1].toString(),
                                  //   '\$${totalCollectedAmount.toString()}',
                                  //   style: TextStyle(
                                  //       color: Colors.blue,
                                  //       fontSize:
                                  //       MediaQuery.of(context).size.width *
                                  //           0.034),
                                  // ),
                                  Text(
                                    totalCollectedAmount != 0 ? '\$${totalCollectedAmount.toString()}' : '0',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: MediaQuery.of(context).size.width * 0.034,
                                    ),
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
                                  // Text(
                                  //   // "1000",
                                  //   "\$${pastDueAmount.toStringAsFixed(2).toString()}",
                                  //   //  pastDueAmount.toStringAsFixed(2),
                                  //   style: TextStyle(
                                  //       color: Colors.blue,
                                  //       fontSize:
                                  //       MediaQuery.of(context).size.width *
                                  //           0.034),
                                  // ),
                                  Text(
                                    pastDueAmount != 0 ? '\$${pastDueAmount.toStringAsFixed(2)}' : '0',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: MediaQuery.of(context).size.width * 0.034,
                                    ),
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
                                                0.022,
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
                                  // Text(
                                  //   // "1800",
                                  //  "\$${ lastMonthCollectedAmount.toString()}",
                                  //   // amountList[3].toString(),
                                  //   style: TextStyle(
                                  //       color: Colors.blue,
                                  //       fontSize:
                                  //       MediaQuery.of(context).size.width *
                                  //           0.034),
                                  // ),
                                  Text(
                                    lastMonthCollectedAmount != 0 ? '\$${lastMonthCollectedAmount.toString()}' : '0',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: MediaQuery.of(context).size.width * 0.034,
                                    ),
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

              ),*/
              // LayoutBuilder(builder: (context, BoxConstraints) {
              //   if (BoxConstraints.maxWidth > 500) {
              //     return Container();
              //   } else {
              //     return Container();
              //   }
              // }),

              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    // Tablet layout - horizontal
                    return Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 360,
                              height: 110,
                              margin: EdgeInsets.symmetric(
                                  horizontal: width * .040),
                              decoration: const BoxDecoration(
                                borderRadius:
                                BorderRadius.all(Radius.circular(15)),
                              ),
                              child: Material(
                                elevation: 3,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(15)),
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Color.fromRGBO(
                                              50, 75, 119, 1),
                                          borderRadius:
                                          BorderRadius.vertical(
                                              top: Radius.circular(
                                                  15)),
                                        ),
                                        child: const Center(
                                            child: Text(
                                              "Rent Due",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight:
                                                  FontWeight.bold),
                                            )),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 8,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                          BorderRadius.vertical(
                                              bottom: Radius.circular(
                                                  15)),
                                        ),
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceEvenly,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .center,
                                                children: [
                                                  const Text(
                                                    "Current Month",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                        color: Color
                                                            .fromRGBO(
                                                            138,
                                                            149,
                                                            168,
                                                            1)),
                                                  ),
                                                  // SizedBox(height: 8), // Space between the text
                                                  Text(
                                                    "\$${newworkorder}",
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Color
                                                            .fromRGBO(
                                                            90,
                                                            134,
                                                            213,
                                                            1),
                                                        fontWeight:
                                                        FontWeight
                                                            .bold),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .center,
                                                children: [
                                                  const Text(
                                                    "Last Month",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                        color: Color
                                                            .fromRGBO(
                                                            138,
                                                            149,
                                                            168,
                                                            1)),
                                                  ),
                                                  // SizedBox(height: 8), // Space between the text
                                                  Text(
                                                    "\$${overdueworkorder}",
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Color
                                                            .fromRGBO(
                                                            90,
                                                            134,
                                                            213,
                                                            1),
                                                        fontWeight:
                                                        FontWeight
                                                            .bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 360,
                              height: 110,
                              margin: EdgeInsets.symmetric(
                                  horizontal: width * .00),
                              decoration: const BoxDecoration(
                                borderRadius:
                                BorderRadius.all(Radius.circular(15)),
                              ),
                              child: Material(
                                elevation: 3,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(15)),
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Color.fromRGBO(
                                              50, 75, 119, 1),
                                          borderRadius:
                                          BorderRadius.vertical(
                                              top: Radius.circular(
                                                  15)),
                                        ),
                                        child: const Center(
                                            child: Text(
                                              "Rent Paid",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight:
                                                  FontWeight.bold),
                                            )),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 8,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                          BorderRadius.vertical(
                                              bottom: Radius.circular(
                                                  15)),
                                        ),
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceEvenly,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .center,
                                                children: [
                                                  const Text(
                                                    "Current Month",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                        color: Color
                                                            .fromRGBO(
                                                            138,
                                                            149,
                                                            168,
                                                            1)),
                                                  ),
                                                  // SizedBox(height: 8), // Space between the text
                                                  Text(
                                                    "\$${currentMonthRentPaid}",
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Color
                                                            .fromRGBO(
                                                            90,
                                                            134,
                                                            213,
                                                            1),
                                                        fontWeight:
                                                        FontWeight
                                                            .bold),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .center,
                                                children: [
                                                  const Text(
                                                    "Last Month",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                        color: Color
                                                            .fromRGBO(
                                                            138,
                                                            149,
                                                            168,
                                                            1)),
                                                  ),
                                                  // SizedBox(height: 8), // Space between the text
                                                  Text(
                                                    "\$${lastMonthRentPaid}",
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Color
                                                            .fromRGBO(
                                                            90,
                                                            134,
                                                            213,
                                                            1),
                                                        fontWeight:
                                                        FontWeight
                                                            .bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 360,
                              height: 110,
                              margin: EdgeInsets.symmetric(
                                  horizontal: width * .040),
                              decoration: const BoxDecoration(
                                borderRadius:
                                BorderRadius.all(Radius.circular(15)),
                              ),
                              child: Material(
                                elevation: 3,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(15)),
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Color.fromRGBO(
                                              50, 75, 119, 1),
                                          borderRadius:
                                          BorderRadius.vertical(
                                              top: Radius.circular(
                                                  15)),
                                        ),
                                        child: const Center(
                                            child: Text(
                                              "Rent Past Due",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight:
                                                  FontWeight.bold),
                                            )),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 8,
                                      child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                            BorderRadius.vertical(
                                                bottom:
                                                Radius.circular(
                                                    15)),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "\$${totalRentPastDue}",
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  color: Color.fromRGBO(
                                                      90, 134, 213, 1),
                                                  fontWeight:
                                                  FontWeight.bold),
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 350,
                              height: 110,
                              margin: EdgeInsets.symmetric(
                                  horizontal: width * .00),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    // Phone layout - vertical
                    return Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 150,
                          margin: EdgeInsets.symmetric(
                              horizontal: width * .05),
                          decoration: const BoxDecoration(
                            borderRadius:
                            BorderRadius.all(Radius.circular(15)),
                          ),
                          child: Material(
                            elevation: 3,
                            borderRadius: const BorderRadius.all(
                                Radius.circular(15)),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color:
                                      Color.fromRGBO(50, 75, 119, 1),
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(15)),
                                    ),
                                    child: const Center(
                                        child: Text(
                                          "New Work Order",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ),
                                ),
                                Expanded(
                                  flex: 7,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(15)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "Total: ",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: Color.fromRGBO(
                                                        138,
                                                        149,
                                                        168,
                                                        1)),
                                              ),
                                              // SizedBox(height: 8), // Space between the text
                                              Text(
                                                "${newworkorder}",
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Color.fromRGBO(
                                                        90, 134, 213, 1),
                                                    fontWeight:
                                                    FontWeight.bold),
                                              ),
                                            ],
                                          ),


                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(builder: (context) => Profile_screen()));
                                            },
                                            child: Container(
                                              margin: EdgeInsets.symmetric(vertical: 12),
                                              width: 100,
                                              height:30,
                                              decoration: BoxDecoration(
                                                color: Color.fromRGBO(21, 43, 81, 1),
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              child: Center(
                                                  child: Text(
                                                    "View All",
                                                    style: TextStyle(color: Colors.white),
                                                  )),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      /*  Container(
                          height: 110,
                          margin: EdgeInsets.symmetric(
                              horizontal: width * .05),
                          decoration: const BoxDecoration(
                            borderRadius:
                            BorderRadius.all(Radius.circular(15)),
                          ),
                          child: Material(
                            elevation: 3,
                            borderRadius: const BorderRadius.all(
                                Radius.circular(15)),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color:
                                      Color.fromRGBO(50, 75, 119, 1),
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(15)),
                                    ),
                                    child: const Center(
                                        child: Text(
                                          "Rent Paid",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ),
                                ),
                                Expanded(
                                  flex: 8,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(15)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "Current Month",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: Color.fromRGBO(
                                                        138,
                                                        149,
                                                        168,
                                                        1)),
                                              ),
                                              // SizedBox(height: 8), // Space between the text
                                              Text(
                                                "\$${currentMonthRentPaid}",
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Color.fromRGBO(
                                                        90, 134, 213, 1),
                                                    fontWeight:
                                                    FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "Last Month",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: Color.fromRGBO(
                                                        138,
                                                        149,
                                                        168,
                                                        1)),
                                              ),
                                              // SizedBox(height: 8), // Space between the text
                                              Text(
                                                "\$${lastMonthRentPaid}",
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Color.fromRGBO(
                                                        90, 134, 213, 1),
                                                    fontWeight:
                                                    FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 110,
                          margin: EdgeInsets.symmetric(
                              horizontal: width * .05),
                          decoration: const BoxDecoration(
                            borderRadius:
                            BorderRadius.all(Radius.circular(15)),
                          ),
                          child: Material(
                            elevation: 3,
                            borderRadius: const BorderRadius.all(
                                Radius.circular(15)),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color:
                                      Color.fromRGBO(50, 75, 119, 1),
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(15)),
                                    ),
                                    child: const Center(
                                        child: Text(
                                          "Rent Past Due",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ),
                                ),
                                Expanded(
                                  flex: 8,
                                  child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.vertical(
                                            bottom:
                                            Radius.circular(15)),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "\$${totalRentPastDue}",
                                          style: const TextStyle(
                                              fontSize: 18,
                                              color: Color.fromRGBO(
                                                  90, 134, 213, 1),
                                              fontWeight:
                                              FontWeight.bold),
                                        ),
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),*/
                        Container(
                          height: 150,
                          margin: EdgeInsets.symmetric(
                              horizontal: width * .05),
                          decoration: const BoxDecoration(
                            borderRadius:
                            BorderRadius.all(Radius.circular(15)),
                          ),
                          child: Material(
                            elevation: 3,
                            borderRadius: const BorderRadius.all(
                                Radius.circular(15)),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color:
                                      Color.fromRGBO(91, 134, 213, 1),
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(15)),
                                    ),
                                    child: const Center(
                                        child: Text(
                                          "Overdue Work Order",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ),
                                ),
                                Expanded(
                                  flex: 7,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(15)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "Total: ",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: Color.fromRGBO(
                                                        138,
                                                        149,
                                                        168,
                                                        1)),
                                              ),
                                              // SizedBox(height: 8), // Space between the text
                                              Text(
                                                "${overdueworkorder}",
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Color.fromRGBO(
                                                        90, 134, 213, 1),
                                                    fontWeight:
                                                    FontWeight.bold),
                                              ),
                                            ],
                                          ),


                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(builder: (context) => PropertyTable()));
                                              /*   Navigator.of(context)
                                                  .push(MaterialPageRoute(builder: (context) => Plan_screen()));*/
                                            },
                                            child: Container(
                                              margin: EdgeInsets.symmetric(vertical: 12),
                                              width: 100,
                                              height:30,
                                              decoration: BoxDecoration(
                                                color: Color.fromRGBO(91, 134, 213, 1),
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              child: Center(
                                                  child: Text(
                                                    "View All",
                                                    style: TextStyle(color: Colors.white),
                                                  )),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),

              // SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              // PieCharts(),
              // SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              // Barchart()
              const SizedBox(
                height: 20,
              ),
              Container(
                height: 180,
                margin: EdgeInsets.symmetric(horizontal:
                   width * 0.05,
                ),

                child: Material(
                  color: Colors.white,
borderRadius:  BorderRadius.all(Radius.circular(15)),
                //  color: Colors.white,
                  elevation: 5,
                  child: Container(

                    child: DonutChart(
                      newWorkOrders: newworkorder,
                      overdueWorkOrders: overdueworkorder,
                    ),
                  ),
                ),
              ),
            /*  LayoutBuilder(
                builder:
                    (BuildContext context, BoxConstraints constraints) {
                  // Check if the device width is less than 600 (considered as phone screen)
                  if (constraints.maxWidth < 500) {
                    // Phone layout
                    return Column(
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.only(left: 10, right: 10),
                          child: PieCharts(dataMap: {
                            "Properties": countList[0].toDouble(),

                            "Work Orders": countList[1].toDouble(),
                          }),
                        ), // Vertical layout for phone
                        SizedBox(
                            height: MediaQuery.of(context).size.height *
                                0.015),
                        Padding(
                          padding:
                          const EdgeInsets.only(left: 0, right: 8),
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
                          const SizedBox(
                            width: 20,
                          ),
                          PieCharts(dataMap: {
                            "Properties": countList[0].toDouble(),

                            "Work Orders": countList[2].toDouble(),
                          }),
                          const SizedBox(
                            width: 10,
                          ),
                          Barchart(),
                        ],
                      ),
                    );
                  }
                },
              ),*/
            ],
          )),
    );
  }

/* Widget buildListTile(BuildContext context,Widget leadingIcon, String title,bool active) {
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
  }*/
/* Widget buildDropdownListTile(
      BuildContext context,Widget leadingIcon, String title, List<String> subTopics) {
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
  }*/
}
