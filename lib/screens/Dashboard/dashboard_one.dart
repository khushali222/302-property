import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/screens/Leasing/Applicants/Applicants_table.dart';
import 'package:three_zero_two_property/screens/Maintenance/Vendor/Vendor_table.dart';
import 'package:three_zero_two_property/screens/Maintenance/Workorder/Workorder_table.dart';
import 'package:three_zero_two_property/screens/Rental/Properties/Properties_table.dart';
import 'package:three_zero_two_property/screens/Rental/Tenants/Tenants_table.dart';
import 'package:three_zero_two_property/widgets/pie_chart.dart';
import 'package:three_zero_two_property/screens/Rental/Properties/properties.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:http/http.dart' as http;
import '../../constant/constant.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/drawer_tiles.dart';
import '../Rental/Properties/add_new_property.dart';
import '../../widgets/barchart.dart';

class DashboardData {
  // int tenantCount = 0;
  // int rentalCount = 0;
  // int vendorCount = 0;
  // int applicantCount = 0;
  // int workOrderCount = 0;

  List<int> countList = [];
  List<int> amountList = [];

  List<String> icons = [
    "assets/images/Properti-icon.svg",
    "assets/images/tenant-icon.svg",
    "assets/images/applicant-icon.svg",
    "assets/images/vendor-icon.svg",
    "assets/images/workorder-icon.svg"
  ];

  List<String> titles = [
    "Properties",
    "Tenants",
    "Applicants",
    "Vendors",
    "Work Orders"
  ];

  final List<Widget> pages = [
    PropertiesTable(),
    Tenants_table(),
    Applicants_table(),
    Vendor_table(),
    Workorder_table(),
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

class Dashboard extends StatefulWidget {
  Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String firstname = '';
  String lastname = '';
  bool loading = false;
  final List<Widget> pages = [
    PropertiesTable(),
    Tenants_table(),
    Applicants_table(),
    Vendor_table(),
    Workorder_table(),
  ];
  Future<void> fetchDatacount() async {
    setState(() {
      loading = true;
    });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("adminId");
      String? token = prefs.getString('token');

      final response = await http
          .get(Uri.parse('${Api_url}/api/admin/counts/${id!}'), headers: {
        "id": "CRM $id",
        "authorization": "CRM $token",
        "Content-Type": "application/json"
      });
      final jsonData = json.decode(response.body);
      if (jsonData["statusCode"] == 200) {
        setState(() {
          countList[1] = jsonData['tenantCount'];
          countList[0] = jsonData['rentalCount'];
          countList[3] = jsonData['vendorCount'];
          countList[2] = jsonData['applicantCount'];
          countList[4] = jsonData['workOrderCount'];
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
        throw Exception('Failed to load dataxxx');
      }
    } catch (e) {
      print('Error fetching data: $e');

    } finally {

    }
  }

  double currentMonthRentDue = 0.0;
  double lastMonthRentDue = 0.0;
  double currentMonthRentPaid = 0.0;
  double lastMonthRentPaid = 0.0;
  double totalRentPastDue = 0.0;

  Future<void> fetchData() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await http
        .get(Uri.parse('${Api_url}/api/payment/admin_balance/$id'), headers: {
      "authorization": "CRM $token",
      "id": "CRM $id",
      "Content-Type": "application/json"
    });
    print('${Api_url}/api/payment/admin_balance/$id');
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData["statusCode"] == 200) {
        final data = jsonData["data"];
        setState(() {
          currentMonthRentDue =
              double.parse(data['currentMonthRentDue'].toString());
          lastMonthRentDue = double.parse(data['lastMonthRentDue'].toString());
          currentMonthRentPaid =
              double.parse(data['currentMonthRentPaid'].toString());
          lastMonthRentPaid =
              double.parse(data['lastMonthRentPaid'].toString());
          totalRentPastDue = double.parse(data['totalRentPastDue'].toString());
        });
      } else {
        throw Exception('Failed to load dataaaaaaaa');
      }
    } else {
      throw Exception('Failed to load datawwwwww');
    }
  }

  late DashboardData dashboardData;
  List<int> countList = List.filled(5, 0);
  List<int> amountList = List.filled(5, 0);

  @override
  void initState() {
    super.initState();
    dashboardData =
        DashboardData(countList: [0, 0, 0, 0, 0], amountList: [0, 0, 0, 0, 0]);
    fetchDatacount();
    fetchData();
    _loadName();
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
    return WillPopScope(
      onWillPop: () async {
        return await _showExitPopup(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer:CustomDrawer(currentpage: "Dashboard",dropdown: false,),
        appBar: widget_302.App_Bar(context: context),
        body: Center(
            child: loading
                ?    Lottie.asset('assets/images/loader.json',height: 150,width: 100)
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
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Row(
                      children: [
                        SizedBox(width: width * 0.05),
                        Container(
                          color: Color.fromRGBO(2, 121, 210, 1),
                          margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.012,),
                          width: 3,
                          child: Column(
                            children: [

                              Container(
                                height: MediaQuery.of(context).size.height * 0.012 +
                                    MediaQuery.of(context).size.width * 0.04 +
                                    3 +
                                    16,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.012),
                            Row(
                              children: [
                                SizedBox(width: width * 0.05),
                                Text(
                                  "Hello $firstname $lastname, Welcome back",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: MediaQuery.of(context).size.width > 500?MediaQuery.of(context).size.width * 0.03 : MediaQuery.of(context).size.width * 0.04,
                                  ),
                                ),
                              ],
                            ),
                            //   SizedBox(height: 3),
                            // My Dashboard
                            Row(
                              children: [
                                SizedBox(width: width * 0.05),
                                Text(
                                  "My Dashboard",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  },
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
                          spacing:
                          MediaQuery.of(context).size.width * 0.02,
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
                                            elevation: 5,
                                            borderRadius:
                                            BorderRadius.circular(20),
                                            child: Container(
                                              height: 40,
                                              width: 40,
                                              padding:
                                              const EdgeInsets.all(
                                                  10),
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
                              height: MediaQuery.of(context).size.width *
                                  0.05),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 25, right: 25),
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
                                .99, // Adjust as needed for your design
                              ),
                              itemBuilder: (context, index) {
                                return
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => pages[index]),
                                      );
                                    },
                                    child: Material(
                                    elevation: 3,
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: dashboardData.colorc[index],
                                        borderRadius:
                                        BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 15),
                                            Row(
                                              children: [
                                                const SizedBox(width: 10),
                                                Material(
                                                  elevation: 5,
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      15),
                                                  child: Container(
                                                      height: 50,
                                                      width: 50,
                                                      padding:
                                                      const EdgeInsets
                                                          .all(10),
                                                      decoration:
                                                      BoxDecoration(
                                                        color: dashboardData
                                                            .colors[index],
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(15),
                                                      ),
                                                      child: SvgPicture.asset(
                                                        "${dashboardData.icons[index]}",
                                                        fit: BoxFit.cover,
                                                        height: 30,
                                                        width: 30,
                                                      )),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Row(
                                              children: [
                                                const SizedBox(width: 10),
                                                Text(
                                                  countList[index].toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    fontSize: 20,
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
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                SizedBox(width: 5,),
                                                Icon(Icons.arrow_forward_rounded,color: Colors.white,),

                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
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
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(15)),
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
                                                bottom:
                                                Radius.circular(
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
                                                      "\$${currentMonthRentDue}",
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
                                                      "\$${lastMonthRentDue}",
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
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(15)),
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
                                                bottom:
                                                Radius.circular(
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
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(15)),
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
                                            decoration:
                                            const BoxDecoration(
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
                                        color: Color.fromRGBO(
                                            50, 75, 119, 1),
                                        borderRadius:
                                        BorderRadius.vertical(
                                            top: Radius.circular(15)),
                                      ),
                                      child: const Center(
                                          child: Text(
                                            "Rent Due",
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
                                                      FontWeight.bold,
                                                      color:
                                                      Color.fromRGBO(
                                                          138,
                                                          149,
                                                          168,
                                                          1)),
                                                ),
                                                // SizedBox(height: 8), // Space between the text
                                                Text(
                                                  "\$${currentMonthRentDue}",
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      color:
                                                      Color.fromRGBO(
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
                                                      FontWeight.bold,
                                                      color:
                                                      Color.fromRGBO(
                                                          138,
                                                          149,
                                                          168,
                                                          1)),
                                                ),
                                                // SizedBox(height: 8), // Space between the text
                                                Text(
                                                  "\$${lastMonthRentDue}",
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      color:
                                                      Color.fromRGBO(
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
                                        color: Color.fromRGBO(
                                            50, 75, 119, 1),
                                        borderRadius:
                                        BorderRadius.vertical(
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
                                        borderRadius:
                                        BorderRadius.vertical(
                                            bottom:
                                            Radius.circular(15)),
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
                                                      FontWeight.bold,
                                                      color:
                                                      Color.fromRGBO(
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
                                                      color:
                                                      Color.fromRGBO(
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
                                                      FontWeight.bold,
                                                      color:
                                                      Color.fromRGBO(
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
                                                      color:
                                                      Color.fromRGBO(
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
                                        color: Color.fromRGBO(
                                            50, 75, 119, 1),
                                        borderRadius:
                                        BorderRadius.vertical(
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
                                              bottom: Radius.circular(
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
                        ],
                      );
                    }
                  },
                ),

                // SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                // PieCharts(),
                // SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                // Barchart()
              /*  const SizedBox(
                  height: 10,
                ),*/
                LayoutBuilder(
                  builder:
                      (BuildContext context, BoxConstraints constraints) {
                    // Check if the device width is less than 600 (considered as phone screen)
                    if (constraints.maxWidth < 500) {
                      // Phone layout
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10),
                            child: PieCharts(dataMap: {
                              "Properties": countList[0].toDouble(),
                              "Gap1": 0.2,
                              "Tenants": countList[1].toDouble(),
                              "Gap2": 0.2,
                              "Applicants": countList[2].toDouble(),
                              "Gap3": 0.2,
                              "Vendors": countList[3].toDouble(),
                              "Gap4": 0.2,
                              "Work Orders": countList[4].toDouble(),
                              "Gap5": 0.2,
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
                          top: 10,
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10),
                              child: PieCharts(dataMap: {
                                "Properties": countList[0].toDouble(),
                                "Gap1": 0.2,
                                "Tenants": countList[1].toDouble(),
                                "Gap2": 0.2,
                                "Applicants": countList[2].toDouble(),
                                "Gap3": 0.2,
                                "Vendors": countList[3].toDouble(),
                                "Gap4": 0.2,
                                "Work Orders": countList[4].toDouble(),
                                "Gap5": 0.2,
                              }),
                            ),
                            const SizedBox(
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
            )),
      ),
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

  Future<bool> _showExitPopup(BuildContext context) async {
    bool exitConfirmed = false;

    await Alert(
      context: context,
      type: AlertType.warning,
      title: "Exit App",
      desc: "Do you want to exit the app?",
      style: AlertStyle(
        backgroundColor: Colors.white,
        titleStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        descStyle: TextStyle(
          fontSize: 16,
          color: Colors.black54,
        ),
        animationType: AnimationType.grow,
        isOverlayTapDismiss: false,
        overlayColor: Colors.black.withOpacity(0.5),
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(color: Colors.blue, width: 2),
        ),
        alertPadding: EdgeInsets.all(16.0),
      ),
      buttons: [
        DialogButton(
          child: Text(
            "No",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.red,
          radius: BorderRadius.circular(8.0),
        ),
        DialogButton(
          child: Text(
            "Yes",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            exitConfirmed = true;
            if (Platform.isAndroid) {
              SystemNavigator.pop();
            } else if (Platform.isIOS) {
              exit(0);
            }
          },
          color: Colors.green,
          radius: BorderRadius.circular(8.0),
        ),
      ],
    ).show();

    return exitConfirmed;
  }
}
