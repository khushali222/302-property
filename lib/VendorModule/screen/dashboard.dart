import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen/work_order/workorder_table.dart';
import 'package:three_zero_two_property/screens/Maintenance/Workorder/Workorder_table.dart';
import '../widgets/pie_chart.dart';
import 'package:three_zero_two_property/screens/Rental/Properties/properties.dart';

import '../widgets/appbar.dart';
import 'package:http/http.dart' as http;
import '../../constant/constant.dart';
import '../widgets/drawer_tiles.dart';


import '../widgets/barchart.dart';

class DashboardData {
  // int tenantCount = 0;
  // int rentalCount = 0;
  // int vendorCount = 0;
  // int applicantCount = 0;
  // int workOrderCount = 0;

  List<dynamic> countList = [];
  List<int> amountList = [];

  List<String> icons = [
    // "assets/images/Properti-icon.svg",
    "assets/images/workorder-icon.svg",
    /* "assets/images/tenants/balance.svg",
    "assets/images/tenants/rent.svg",*/
    "assets/images/tenants/duedate.svg",
    //"assets/images/tenants/leaseicon.svg",
  ];

  List<String> titles = [

    "New Work\nOrders",
    "OverDue Work\nOrders",
    // "Monthly Rent",
    // "Due Date",
    // "Lease End Date",


  ];

  List<Color> colorc = [
   blueColor,
    /*const Color.fromRGBO(40, 60, 95, 1),
    const Color.fromRGBO(50, 75, 119, 1),
    const Color.fromRGBO(60, 89, 142, 1),*/
    const Color.fromRGBO(90, 134, 213, 1),
  ];

  List<Color> colors = [
   blueColor,
    /*const Color.fromRGBO(40, 60, 95, 1),
    const Color.fromRGBO(50, 75, 119, 1),
    const Color.fromRGBO(60, 89, 142, 1),*/
    const Color.fromRGBO(90, 134, 213, 1),
  ];

  DashboardData({required this.countList, required this.amountList});
}

class Dashboard_vendors extends StatefulWidget {
  Function(String)? onWorkOrderSelected;

  Dashboard_vendors({ this.onWorkOrderSelected});
  //Dashboard_vendors({super.key});

  @override
  State<Dashboard_vendors> createState() => _Dashboard_vendorsState();
}

class _Dashboard_vendorsState extends State<Dashboard_vendors> {
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
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
      //   print(response.body);
      final jsonData = json.decode(response.body);
      if (jsonData["statusCode"] == 200) {
        //  print(jsonData);
        setState(() {
          //countList[0] = jsonData["data"]['all_workorders'];
          //  countList[1] = jsonData['rentalCount'];
          countList[2] = jsonData["data"]['rent'];
          countList[3] = convertDateFormat( jsonData["data"]['due_date'].toString());
          countList[4] = convertDateFormat(jsonData["data"]['end_date'].toString());
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
      //print(id);
      /// print(token);
      final response =
      await http.get(
          Uri.parse('${Api_url}/api/payment/tenant_financial/${id!}'),
          headers: {
            "id":"CRM $id",
            "authorization": "CRM $token",
            "Content-Type": "application/json"
          }

      );
      //  print(response.body);
      final jsonData = json.decode(response.body);
      if (jsonData["statusCode"] == 200) {
        //  print(jsonData);
        // print(jsonData["totalBalance"]);
        setState(() {
          // countList[0] = jsonData['property_staffMember'];
          countList[1] = double.parse(jsonData['totalBalance'].toString()).toStringAsFixed(2) ??0;
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
    String? id = prefs.getString("vendor_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    print(admin_id);
    final response =
    await http.get(
        Uri.parse('${Api_url}/api/vendor/dashboard_workorder/$id/$admin_id'),
        headers: {
          "authorization": "CRM $token",
          "id":"CRM $id",
          "Content-Type": "application/json"
        }
    );
    //print('${Api_url}/api/payment/admin_balance/$id');
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      //  print(jsonData);
      if (jsonData["statusCode"] == 200) {
        final data = jsonData["data"];
        setState(() {
          var newwork = data["new_workorder"];
          var overdue = data["overdue_workorder"];
          // print(newwork);
          /*newworkorder = newwork;
          overdueworkorder = overdue;*/
          countList[0] = newwork.length;
          countList[1] = overdue.length;
          // print(data);
        });
      } else {
        throw Exception('Failed to load data');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  late DashboardData dashboardData;
  List<dynamic> countList = [0,0];
  List<int> amountList = List.filled(2, 0);
  String convertDateFormat(String dateStr) {
    DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(dateStr);
    String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
    return formattedDate;
  }
  @override
  void initState() {
    super.initState();
    dashboardData =
        DashboardData(countList: [0,0], amountList: [0, 0]);
    //  fetchDatacount();
    fetchData();
    _loadName();
    // fetchDatafinancial();
  }

  Future<void> _loadName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      firstname = prefs.getString('first_name') ?? '';
      lastname = prefs.getString('last_name') ?? '';
    });
  }
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
        key: key,
        backgroundColor: Colors.white,

        appBar: widget_302.App_Bar(context: context,onDrawerIconPressed: () {
          print("calling appbar");
          key.currentState!.openDrawer();
          // Scaffold.of(context).openDrawer();
        },),
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
                SizedBox(height: 10,),
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
                                    fontSize: MediaQuery.of(context).size.width > 500?MediaQuery.of(context).size.width * 0.03 : MediaQuery.of(context).size.width * 0.04,

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
                //welcome

                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 600) {
                      // Tablet layout - horizontal
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 35, right: 35, top: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.start,
                              spacing: MediaQuery.of(context).size.width * 0.02,
                              runSpacing:
                              MediaQuery.of(context).size.width * 0.02,
                              children: List.generate(
                                2,
                                    (index) => InkWell(
                                  onTap: (){
                                    /*  if(dashboardData.titles[index] == "Work Orders"){
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>WorkOrderTable()));
                                    }
                                    if(dashboardData.titles[index] == "Balance"){
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>FinancialTable()));
                                    }*/
                                  },
                                  child: SizedBox(
                                    width:
                                    200, // Ensure SizedBox has defined width
                                    height:
                                    200, // Ensure SizedBox has defined height
                                    child: Material(
                                      elevation: 3,
                                      borderRadius: BorderRadius.circular(1),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: dashboardData.colorc[index],
                                          borderRadius: BorderRadius.circular(1),
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
                                                    height: 50,
                                                    width: 50,
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
                                                    fontSize: 23,
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
                            ),
                            const SizedBox(height: 20),
                            Container(
                              // color: Colors.cyan,
                              // padding: const EdgeInsets.only(left: 15, right: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap:(){
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>WorkOrderTable(filter: "New",)));
                                    },
                                    child: Material(
                                      elevation: 3,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        //  color: dashboardData.colorc[0],
                                        decoration: BoxDecoration(
                                          color: dashboardData.colorc[0],
                                          borderRadius:
                                          BorderRadius.circular(6),
                                        ),
                                        height: 50,
                                        width: 200,
                                        child: Center(child: Text("View All",style: TextStyle(color: Colors.white,fontSize: 18),)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                                  InkWell(
                                    onTap:(){
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>WorkOrderTable(filter: "Over Due",)));
                                    },
                                    child: Material(
                                      elevation: 3,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: dashboardData.colorc[1],
                                          borderRadius:
                                          BorderRadius.circular(6),
                                        ),
                                        // color: dashboardData.colorc[1],
                                        height: 50,
                                        width:200,
                                        child: Center(child: Text("View All",style: TextStyle(color: Colors.white,fontSize: 18),)),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                              const EdgeInsets.only(left: 0, right: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Statistics",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
                                        SizedBox(width: 30,),
                                        Container(
                                          height: 50,
                                          width: 220,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(6),
                                            color: Color.fromRGBO(206, 233, 255, 1),
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(width: 10,),
                                              Container(height: 20,width: 20,

                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(2),
                                                  color:  blueColor,
                                                ),
                                              ),
                                              SizedBox(width: 10,),
                                              Text("New Work Orders",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 30,),
                                        Container(
                                          height: 50,
                                          width: 250,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(6),
                                            color: Color.fromRGBO(206, 233, 255, 1),
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(width: 10,),
                                              Container(height:20 ,width: 20,

                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(2),
                                                  color:  Color.fromRGBO(90, 134, 213, 1),
                                                ),
                                              ),
                                              SizedBox(width: 10,),
                                              Text("OverDue Work Orders",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                      ],
                                    ),
                                  ),
                                  BarchartTablet(),
                                ],
                              ),
                            ),
                          ],
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
                            const EdgeInsets.only(left: 15, right: 15),
                            child: GridView.builder(
                              itemCount: 2,
                              gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                2, // Number of items per row
                                crossAxisSpacing:
                                MediaQuery.of(context).size.width *
                                    0.05,
                                mainAxisSpacing:
                                MediaQuery.of(context).size.width *
                                    0.05,
                                childAspectRatio:
                                1, // Adjust as needed for your design
                              ),
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: (){
                                    /*   print("calling");
                                    if(dashboardData.titles[index] == "Work Orders"){
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>WorkOrderTable()));
                                    }
                                    if(dashboardData.titles[index] == "Balance"){
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>FinancialTable()));
                                    }*/
                                  },
                                  child: Material(
                                    elevation: 3,
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: dashboardData.colorc[index],
                                        borderRadius:
                                        BorderRadius.circular(6),
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
                                                color: dashboardData
                                                    .colors[index],
                                                child: Container(
                                                    height: 45,
                                                    width: 45,
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
                                          const SizedBox(height: 20),
                                          Row(
                                            children: [
                                              const SizedBox(width: 10),

                                              Text(
                                                countList[index].toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
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
                                                  // fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              /* if(index == 0 || index ==1)
                                                Icon(Icons.arrow_forward_outlined,color: Colors.white,)*/
                                            ],
                                          ),
                                        ],
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
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap:(){
                                      widget.onWorkOrderSelected!("New");
                                      //   Navigator.of(context).push(MaterialPageRoute(builder: (context)=>WorkOrderTable(filter: "New",)));
                                    },
                                    child: Material(
                                      elevation: 3,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        //  color: dashboardData.colorc[0],
                                        decoration: BoxDecoration(
                                          color: dashboardData.colorc[0],
                                          borderRadius:
                                          BorderRadius.circular(6),
                                        ),
                                        height: 50,
                                        child: Center(child: Text("View All",style: TextStyle(color: Colors.white),)),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                                Expanded(
                                  child: InkWell(
                                    onTap:(){
                                      widget.onWorkOrderSelected!("Over Due");
                                      // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>WorkOrderTable(filter: "Over Due",)));
                                    },
                                    child: Material(
                                      elevation: 3,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: dashboardData.colorc[1],
                                          borderRadius:
                                          BorderRadius.circular(6),
                                        ),
                                        // color: dashboardData.colorc[1],
                                        height: 50,
                                        child: Center(child: Text("View All",style: TextStyle(color: Colors.white),)),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding:
                            const EdgeInsets.only(left: 10, right: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left:8.0,bottom: 10),
                                  child: Text("Statistics",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                  child: Wrap(
                                    spacing: 10.0, // Horizontal space between children
                                    runSpacing: 10.0, // Vertical space between rows
                                    children: [
                                      Container(
                                        height: 40,
                                        width: 160,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6),
                                          color: Color.fromRGBO(206, 233, 255, 1),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 10,),
                                            Container(
                                              height: 15,
                                              width: 15,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(2),
                                                color: blueColor,
                                              ),
                                            ),
                                            SizedBox(width: 10,),
                                            Text(
                                              "New Work Orders",
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 40,
                                        width: 190,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6),
                                          color: Color.fromRGBO(206, 233, 255, 1),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 10,),
                                            Container(
                                              height: 15,
                                              width: 15,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(2),
                                                color: Color.fromRGBO(90, 134, 213, 1),
                                              ),
                                            ),
                                            SizedBox(width: 10,),
                                            Text(
                                              "OverDue Work Orders",
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10,),



                                Barchart(),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),


              ],
            )),
      ),
    );
  }

}
