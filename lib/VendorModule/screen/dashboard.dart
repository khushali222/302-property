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
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constant/geolocation_data_filter.dart';
import '../../provider/dateProvider.dart';
import '../screen/work_order/workorder_table.dart';
import 'package:three_zero_two_property/screens/Maintenance/Workorder/Workorder_table.dart';
import '../widgets/pie_chart.dart';
import 'package:three_zero_two_property/screens/Rental/Properties/properties.dart';

import '../widgets/appbar.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import '../../constant/constant.dart';
import '../widgets/drawer_tiles.dart';

import '../widgets/barchart.dart';
import '../model/workorder_model.dart';
import '../repository/workorder.dart';

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

  Dashboard_vendors({this.onWorkOrderSelected});
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

      final response = await http
          .get(Uri.parse('${Api_url}/api/tenant/count/${id!}'), headers: {
        "id": "CRM $id",
        "authorization": "CRM $token",
        "Content-Type": "application/json"
      });
      //   print(response.body);
      final jsonData = json.decode(response.body);
      if (jsonData["statusCode"] == 200) {
        //  print(jsonData);
        setState(() {
          //countList[0] = jsonData["data"]['all_workorders'];
          //  countList[1] = jsonData['rentalCount'];
          countList[2] = jsonData["data"]['rent'];
          countList[3] =
              convertDateFormat(jsonData["data"]['due_date'].toString());
          countList[4] =
              convertDateFormat(jsonData["data"]['end_date'].toString());
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
      final response = await apiGet(
          Uri.parse('${Api_url}/api/payment/tenant_financial/${id!}'),
          headers: {
            "id": "CRM $id",
            "authorization": "CRM $token",
            "Content-Type": "application/json"
          });
      //  print(response.body);
      final jsonData = json.decode(response.body);
      if (jsonData["statusCode"] == 200) {
        //  print(jsonData);
        // print(jsonData["totalBalance"]);
        setState(() {
          // countList[0] = jsonData['property_staffMember'];
          countList[1] = double.parse(jsonData['totalBalance'].toString())
              .toStringAsFixed(2) ??
              0;
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
    final response = await apiGet(
        Uri.parse('${Api_url}/api/vendor/dashboard_workorder/$id/$admin_id'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json"
        });
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
  List<dynamic> countList = [0, 0];
  List<int> amountList = List.filled(2, 0);
  String convertDateFormat(String dateStr) {
    DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(dateStr);
    String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
    return formattedDate;
  }

  Widget _buildHeaders() {
    var width = MediaQuery.of(context).size.width;
    return Container(
      // decoration: BoxDecoration(
      //   color: blueColor,
      //   borderRadius: const BorderRadius.only(
      //     topLeft: Radius.circular(10),
      //     topRight: Radius.circular(10),
      //   ),
      // ),
      decoration: BoxDecoration(
          color: Color(0xFFF4F8FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFFDBE0E5))),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        // leading: Container(
        //   child: Icon(
        //     Icons.expand_less,
        //     color: Colors.transparent,
        //   ),
        // ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: const Icon(
                Icons.expand_less,
                color: Colors.transparent,
              ),
            ),
            Expanded(
              flex: 4,
              child: InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    width < 400
                        ? Text("  Work Order ",
                        style: TextStyle(
                            color: blueColor, fontWeight: FontWeight.bold))
                        : Text("  Work Order",
                        style: TextStyle(
                            color: blueColor, fontWeight: FontWeight.bold)),
                    // Text("Property", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Text("Status",
                        style: TextStyle(
                            color: blueColor, fontWeight: FontWeight.bold)),
                    SizedBox(width: 5),
                  ],
                ),
              ),
            ),
            // Expanded(
            //   flex: 3,
            //   child: InkWell(
            //     onTap: () {},
            //     child: Row(
            //       children: [
            //         const Text("      Billable ",
            //             style: TextStyle(color: Colors.white)),
            //         const SizedBox(width: 5),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // List to store all rental data
  List<RentalData> allRentalData = [];
  List<RentalData> nearbyProperties = [];
  List<WorkOrder> allworkorder = [];
  List<WorkOrder> nearestPropertyWorkOrders = [];
  RentalData? nearestProperty;
  // Function to fetch work order data and extract rental data
  Future<void> fetchWorkOrdersAndRentalData() async {
    setState(() {
      loading = true;
    });
    try {
      Position userLocation = await getCurrentLocation();
      final workOrders = await WorkOrderRepository().fetchWorkOrders();
      allRentalData.clear();
      final Map<String, RentalData> uniqueRentals = {};
      workOrders
          .removeWhere((r) => r.status == "Completed" || r.status == "Closed");
      for (var workOrder in workOrders) {
        if (workOrder.rentalData != null &&
            workOrder.rentalData!.rentalId != null) {
          uniqueRentals[workOrder.rentalData!.rentalId!] =
          workOrder.rentalData!;
        }
      }
      allRentalData.addAll(uniqueRentals.values);
      allworkorder = workOrders;
      double minDistance = double.infinity;
      nearbyProperties.clear();
      nearestProperty = null;

      for (RentalData rental in allRentalData) {
        final coords = await getCoordinatesFromAddressforvendor(rental);
        if (coords != null) {
          double distanceInMeters = Geolocator.distanceBetween(
            // 39.6613845,
            // -75.6339627,
            userLocation.latitude,
            userLocation.longitude,
            coords.latitude,
            coords.longitude,
          );
          double distanceInKm = distanceInMeters / 1000;
          print("${rental.rentalAddress} $distanceInKm");
          if (distanceInKm <= 5) {
            if (distanceInMeters < minDistance) {
              minDistance = distanceInMeters;
              nearestProperty = rental;
            }
            nearbyProperties.add(rental);
          }
        }
      }

      if (nearestProperty != null) {
        nearestPropertyWorkOrders = workOrders
            .where((workOrder) =>
        workOrder.rentalData!.rentalId == nearestProperty!.rentalId! &&
            workOrder.status != "Completed")
            .toList();
        nearbyProperties
            .removeWhere((r) => r.rentalId == nearestProperty!.rentalId);
      }
      print(
          'Fetched \\${allRentalData.length} rental records from work orders.');
      setState(() {
        loading = false;
      });
    } catch (e) {
      print('Error fetching work orders or rental data: \\${e}');
    }
  }

  @override
  void initState() {
    super.initState();
    dashboardData = DashboardData(countList: [0, 0], amountList: [0, 0]);
    //  fetchDatacount();
    fetchWorkOrdersAndRentalData();
    fetchData();
    _loadName();
    // Fetch work orders and rental data
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
        titleStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        descStyle: const TextStyle(
          fontSize: 16,
          color: Colors.black54,
        ),
        animationType: AnimationType.grow,
        isOverlayTapDismiss: false,
        overlayColor: Colors.black.withOpacity(0.5),
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: const BorderSide(color: Colors.blue, width: 2),
        ),
        alertPadding: const EdgeInsets.all(16.0),
      ),
      buttons: [
        DialogButton(
          child: const Text(
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
          child: const Text(
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

  int? expandedIndex;
  int? expandedIndexrow;
  var appBarHeight = AppBar().preferredSize.height;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final dateProvider = Provider.of<DateProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        return await _showExitPopup(context);
      },
      child: Scaffold(
        key: key,
        backgroundColor: Colors.white,
        appBar: widget_302.App_Bar(
          context: context,
          onDrawerIconPressed: () {
            print("calling appbar");
            key.currentState!.openDrawer();
            // Scaffold.of(context).openDrawer();
          },
        ),
        drawer: Icon(Icons.menu,color: Colors.white,),
        body: loading
            ? Center(
          child: Lottie.asset('assets/images/loader.json',
              height: 150, width: 100),
        )
            : nearestProperty != null || nearbyProperties.length > 0
            ? SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 11, right: 11),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                LayoutBuilder(
                  builder: (BuildContext context,
                      BoxConstraints constraints) {
                    final isWide =
                        MediaQuery.of(context).size.width > 500;
                    final titleSize = isWide ? width * 0.032 : 22.0;
                    final greetingSize =
                    isWide ? width * 0.028 : 15.0;
                    return Padding(
                      padding: EdgeInsets.only(
                        left: width * 0.01,
                        right: width * 0.01,
                        top: MediaQuery.of(context).size.height *
                            0.012,
                        bottom: 4,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello $firstname $lastname, Welcome back",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: greetingSize,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 4,
                                height: titleSize + 4,
                                decoration: BoxDecoration(
                                  color: blueColor,
                                  borderRadius:
                                  BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "My Dashboard",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: titleSize,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(
                    height:
                    MediaQuery.of(context).size.height * 0.01),
                if (nearestPropertyWorkOrders.length > 0)
                  Column(
                    children: [
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F9FC),
                          border: Border.all(
                              color: const Color(0xFF8A95A8)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: blueColor,
                                  fontSize: MediaQuery.of(context)
                                      .size
                                      .width >
                                      500
                                      ? MediaQuery.of(context)
                                      .size
                                      .width *
                                      0.03
                                      : 14,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                    "${nearestProperty!.rentalAddress!} ",
                                    style: const TextStyle(
                                        fontWeight:
                                        FontWeight.bold),
                                  ),
                                  const TextSpan(
                                    text:
                                    "is your current property. See open work orders below.",
                                    style: TextStyle(
                                        fontWeight:
                                        FontWeight.normal),
                                  ),
                                ],
                              ),
                            )),
                      ),
                      
                      const SizedBox(height: 5),
                      _buildHeaders(),
                      const SizedBox(height: 10),
                      Container(
                        // decoration: BoxDecoration(
                        //     border: Border.all(
                        //         color: const Color.fromRGBO(
                        //             152, 162, 179, .5))),
                        // decoration: BoxDecoration(
                        //     border: Border.all(color: blueColor)),
                        child: Column(
                          children: nearestPropertyWorkOrders
                          //  .where((workOrder) => workOrder!.rentalAddress!.rentalId == nearstProperty!.rentalId).toList()
                              .asMap()
                              .entries
                              .map((entry) {
                            int index = entry.key;
                            bool isExpanded = expandedIndex == index;
                            WorkOrder workOrder = entry.value;
                            //return CustomExpansionTile(data: Data, index: index);
                            return Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 6),
                              decoration: BoxDecoration(
                                color: index % 2 != 0
                                    ? Color(0xFFF4F8FF)
                                    : Colors.white,
                                border: Border.all(
                                    color: Color(0xFFDBE0E5)),
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Padding(
                                      padding:
                                      const EdgeInsets.all(2.0),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: <Widget>[
                                          InkWell(
                                            onTap: () {
                                              // setState(() {
                                              //    isExpanded = !isExpanded;
                                              // //  expandedIndex = !expandedIndex;
                                              //
                                              // });
                                              // setState(() {
                                              //   if (isExpanded) {
                                              //     expandedIndex = null;
                                              //     isExpanded = !isExpanded;
                                              //   } else {
                                              //     expandedIndex = index;
                                              //   }
                                              // });
                                              setState(() {
                                                if (expandedIndex ==
                                                    index) {
                                                  expandedIndex =
                                                  null;
                                                } else {
                                                  expandedIndex =
                                                      index;
                                                }
                                              });
                                            },
                                            child: Container(
                                              margin: const EdgeInsets
                                                  .only(
                                                  left: 5, right: 8),
                                              padding: !isExpanded
                                                  ? const EdgeInsets
                                                  .only(
                                                  bottom: 10)
                                                  : const EdgeInsets
                                                  .only(top: 10),
                                              child: FaIcon(
                                                isExpanded
                                                    ? FontAwesomeIcons
                                                    .sortUp
                                                    : FontAwesomeIcons
                                                    .sortDown,
                                                size: 20,
                                                color: blueColor,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              '${workOrder!.workSubject}',
                                              style: TextStyle(
                                                color: blueColor,
                                                fontWeight:
                                                FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                              width: MediaQuery.of(
                                                  context)
                                                  .size
                                                  .width *
                                                  .06),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              '${workOrder!.status}',
                                              style: TextStyle(
                                                color: blueColor,
                                                fontWeight:
                                                FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                              width: MediaQuery.of(
                                                  context)
                                                  .size
                                                  .width *
                                                  .03),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isExpanded)
                                    Container(
                                      padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 2),
                                      margin: const EdgeInsets.only(
                                          bottom: 1),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                FaIcon(
                                                  isExpanded
                                                      ? FontAwesomeIcons
                                                      .sortUp
                                                      : FontAwesomeIcons
                                                      .sortDown,
                                                  size: 30,
                                                  color: Colors
                                                      .transparent,
                                                ),
                                                Expanded(
                                                  child: Table(
                                                    columnWidths: {
                                                      0: const FlexColumnWidth(), // Distribute columns equally
                                                      1: const FlexColumnWidth(),
                                                      // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                                      // 1: FlexColumnWidth(),
                                                    },
                                                    children: [
                                                      // _buildTableRow(
                                                      //     'Created At:',
                                                      //     formatDate(
                                                      //         '${workOrder!.createdAt}'),
                                                      //     'Updated At:',
                                                      //     formatDate(
                                                      //         '${workOrder!.updatedAt}}')),
                                                      _buildTableRow(
                                                          ' Created On : ',
                                                          workOrder.createdAt?.isNotEmpty ==
                                                              true
                                                              ? dateProvider.formatCurrentDate('${workOrder.createdAt}')
                                                              : 'N/A',
                                                          '',
                                                          '')
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                // Column(
                                                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                //   children: [
                                                //     IconButton(
                                                //       icon: FaIcon(
                                                //         FontAwesomeIcons.edit,
                                                //         size: 20,
                                                //         color:blueColor,
                                                //       ),
                                                //       onPressed: () async {
                                                //         // handleEdit(Propertytype);
                                                //
                                                //                       var check = await Navigator.push(
                                                //                           context,
                                                //                           MaterialPageRoute(
                                                //                               builder: (context) => ResponsiveEditWorkOrder(
                                                //                                     workorderId: workOrder.workOrderData!.workOrderId!,
                                                //                                   )));
                                                //                       if (check ==
                                                //                           true) {
                                                //                         setState(() {
                                                //                           futureworkorders =
                                                //                               WorkOrderRepository()
                                                //                                   .fetchWorkOrders();
                                                //                         });
                                                //                       }
                                                //       },
                                                //     ),
                                                //     IconButton(
                                                //       icon: FaIcon(
                                                //         FontAwesomeIcons.trashCan,
                                                //         size: 20,
                                                //         color:blueColor,
                                                //       ),
                                                //       onPressed: () {
                                                //         //handleDelete(Propertytype);
                                                //                       _showAlert(
                                                //                           context,
                                                //                           workOrder
                                                //                               .workOrderData!
                                                //                               .workOrderId!);
                                                //       },
                                                //     ),
                                                //   ],
                                                // ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  //SizedBox(height: 13,),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
               
                if (nearbyProperties.length > 0)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Open Work Orders At Nearby Properties",
                          style: TextStyle(
                              color: blueColor, fontSize: 16,fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0.0, vertical: 0.0),
                          child: Column(
                            children: nearbyProperties
                                .asMap()
                                .entries
                                .map((entry) {
                              int index = entry.key;
                              RentalData rental = entry.value;
                              return PropertyCard(
                                rental: rental,
                                index: index,
                                nearestPropertyWorkOrders:
                                allworkorder,
                              );
                            }).toList(),
                          )),
                    ],
                  ),
              ],
            ),
          ),
        )
            : Center(
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
                const SizedBox(
                  height: 10,
                ),
                LayoutBuilder(
                  builder: (BuildContext context,
                      BoxConstraints constraints) {
                    final isWide =
                        MediaQuery.of(context).size.width > 500;
                    final titleSize =
                    isWide ? width * 0.032 : 22.0;
                    final greetingSize =
                    isWide ? width * 0.028 : 15.0;
                    return Padding(
                      padding: EdgeInsets.only(
                        left: width * 0.05,
                        right: width * 0.05,
                        top: height * 0.012,
                        bottom: 4,
                      ),
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.start,
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello $firstname $lastname, Welcome back",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: greetingSize,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 4,
                                height: titleSize + 4,
                                decoration: BoxDecoration(
                                  color: blueColor,
                                  borderRadius:
                                  BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "My Dashboard",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: titleSize,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 220,
                                  child:
                                  _VendorDashboardSummaryCard(
                                    cardColor:
                                    const Color.fromRGBO(
                                        45, 55, 72, 1),
                                    iconPath:
                                    dashboardData.icons[0],
                                    count:
                                    countList[0].toString(),
                                    label: "New Work Orders",
                                    buttonLabel: "View All",
                                    buttonColor:
                                    const Color.fromRGBO(
                                        75, 85, 99, 1),
                                    onViewAll: () => widget
                                        .onWorkOrderSelected!(
                                        "New"),
                                  ),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context)
                                        .size
                                        .width *
                                        0.03),
                                SizedBox(
                                  width: 220,
                                  child:
                                  _VendorDashboardSummaryCard(
                                    cardColor:
                                    const Color.fromRGBO(
                                        59, 130, 246, 1),
                                    iconPath:
                                    dashboardData.icons[1],
                                    count:
                                    countList[1].toString(),
                                    label: "Overdue Work Orders",
                                    buttonLabel: "View All",
                                    buttonColor:
                                    const Color.fromRGBO(
                                        66, 165, 245, 1),
                                    onViewAll: () => widget
                                        .onWorkOrderSelected!(
                                        "Over Due"),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 0, right: 8),
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets
                                        .symmetric(
                                        horizontal: 20.0),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        const Text(
                                          "Statistics",
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight:
                                              FontWeight
                                                  .bold),
                                        ),
                                        const SizedBox(
                                          width: 30,
                                        ),
                                        Container(
                                          height: 50,
                                          width: 220,
                                          decoration:
                                          BoxDecoration(
                                            borderRadius:
                                            BorderRadius
                                                .circular(6),
                                            color: const Color
                                                .fromRGBO(
                                                206, 233, 255, 1),
                                          ),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                height: 20,
                                                width: 20,
                                                decoration:
                                                BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                      2),
                                                  color:
                                                  blueColor,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              const Text(
                                                "New Work Orders",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 30,
                                        ),
                                        Container(
                                          height: 50,
                                          width: 250,
                                          decoration:
                                          BoxDecoration(
                                            borderRadius:
                                            BorderRadius
                                                .circular(6),
                                            color: const Color
                                                .fromRGBO(
                                                206, 233, 255, 1),
                                          ),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                height: 20,
                                                width: 20,
                                                decoration:
                                                BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                      2),
                                                  color: const Color
                                                      .fromRGBO(
                                                      90,
                                                      134,
                                                      213,
                                                      1),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              const Text(
                                                "Overdue Work Orders",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
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
                              height: MediaQuery.of(context)
                                  .size
                                  .width *
                                  0.05),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15, right: 15),
                            child: Row(
                              children: [
                                Expanded(
                                  child:
                                  _VendorDashboardSummaryCard(
                                    cardColor:
                                    const Color.fromRGBO(
                                        45, 55, 72, 1),
                                    iconPath:
                                    dashboardData.icons[0],
                                    count:
                                    countList[0].toString(),
                                    label: "New Work Orders",
                                    buttonLabel: "View All",
                                    buttonColor:
                                    const Color.fromRGBO(
                                        75, 85, 99, 1),
                                    onViewAll: () => widget
                                        .onWorkOrderSelected!(
                                        "New"),
                                  ),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context)
                                        .size
                                        .width *
                                        0.04),
                                Expanded(
                                  child:
                                  _VendorDashboardSummaryCard(
                                    cardColor:
                                    const Color.fromRGBO(
                                        59, 130, 246, 1),
                                    iconPath:
                                    dashboardData.icons[1],
                                    count:
                                    countList[1].toString(),
                                    label: "Overdue Work Orders",
                                    buttonLabel: "View All",
                                    buttonColor:
                                    const Color.fromRGBO(
                                        99, 155, 248, 1),
                                    onViewAll: () => widget
                                        .onWorkOrderSelected!(
                                        "Over Due"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 5, right: 8),
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.start,
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(
                                      left: 12, bottom: 10),
                                  child: Text(
                                    "Statistics",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                        FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Wrap(
                                    spacing:
                                    10.0, // Horizontal space between children
                                    runSpacing:
                                    10.0, // Vertical space between rows
                                    children: [
                                      Container(
                                        height: 40,
                                        width: 162,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius
                                              .circular(6),
                                          color: const Color
                                              .fromRGBO(
                                              206, 233, 255, 1),
                                        ),
                                        child: Row(
                                          children: [
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Container(
                                              height: 15,
                                              width: 15,
                                              decoration:
                                              BoxDecoration(
                                                borderRadius:
                                                BorderRadius
                                                    .circular(
                                                    2),
                                                color: blueColor,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            const Text(
                                              "New Work Orders",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 40,
                                        width: 192,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius
                                              .circular(6),
                                          color: const Color
                                              .fromRGBO(
                                              206, 233, 255, 1),
                                        ),
                                        child: Row(
                                          children: [
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Container(
                                              height: 15,
                                              width: 15,
                                              decoration:
                                              BoxDecoration(
                                                borderRadius:
                                                BorderRadius
                                                    .circular(
                                                    2),
                                                color: const Color
                                                    .fromRGBO(90,
                                                    134, 213, 1),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            const Text(
                                              "Overdue Work Orders",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Barchart(),
                              ],
                            ),
                          ),
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
                                          color: blueColor,
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
                                          color: blueColor,
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
                                          color: blueColor,
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
                                          color: blueColor,
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

                /*   LayoutBuilder(
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
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 150,
                                    margin: EdgeInsets.symmetric(horizontal: width * .025), // Adjusted for equal spacing
                                    decoration:  BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(7)),
                                        border: Border.all(color: blueColor )
                                    ),
                                    child: Material(
                                      //   elevation: 3,
                                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Color.fromRGBO(50, 75, 119, 1),
                                                borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  "New Work Order",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 7,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        const Text(
                                                          "Total: ",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                            color: Color.fromRGBO(90, 134, 213, 1),),
                                                        ),
                                                        Text(
                                                          "${newworkorder}",
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              color: Color.fromRGBO(90, 134, 213, 1),
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                      ],
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => WorkOrderTable()));
                                                      },
                                                      child: Container(
                                                        margin: EdgeInsets.symmetric(vertical: 12),
                                                        width: 100,
                                                        height: 30,
                                                        decoration: BoxDecoration(
                                                          color: blueColor,
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                        child: const Center(
                                                          child: Text(
                                                            "View All",
                                                            style: TextStyle(color: Colors.white),
                                                          ),
                                                        ),
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
                                ),
                                Expanded(
                                  child: Container(
                                    height: 150,
                                    margin: EdgeInsets.symmetric(horizontal: width * .025), // Adjusted for equal spacing
                                    decoration:  BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(7)),
                                        border: Border.all(color: Color.fromRGBO(91, 134, 213, 1) )
                                    ),
                                    child: Material(
                                      //  elevation: 3,
                                      borderRadius: const BorderRadius.all(Radius.circular(7)),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Color.fromRGBO(91, 134, 213, 1),
                                                borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  "Overdue Work Order",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 7,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        const Text(
                                                          "Total: ",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                            color: Color.fromRGBO(90, 134, 213, 1),),
                                                        ),
                                                        Text(
                                                          "${overdueworkorder}",
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              color: Color.fromRGBO(90, 134, 213, 1),
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                      ],
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => WorkOrderTable()));
                                                      },
                                                      child: Container(
                                                        margin: EdgeInsets.symmetric(vertical: 12),
                                                        width: 100,
                                                        height: 30,
                                                        decoration: BoxDecoration(
                                                          color: Color.fromRGBO(91, 134, 213, 1),
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                        child: const Center(
                                                          child: Text(
                                                            "View All",
                                                            style: TextStyle(color: Colors.white),
                                                          ),
                                                        ),
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
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
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
                PieCharts(dataMap: {
                  "New Work Orders": newworkorder.toDouble(),
                  "Overdue Work Orders":overdueworkorder.toDouble()
                },),*/
                /* Container(
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
                ),*/
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
      ),
    );
  }

  TableRow _buildTableRow(String leftLabel, String leftValue, String rightLabel,
      String rightValue) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leftLabel,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                      fontSize: 13),
                ),
                const SizedBox(height: 2.0), // Space between label and value
                Text(
                  leftValue,
                  style: TextStyle(color: grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        // TableCell(
        //   child: Padding(
        //     padding: EdgeInsets.only(left: 25),
        //     child: Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           Text(
        //             rightLabel,
        //             style:
        //                 TextStyle(fontWeight: FontWeight.bold, color: blueColor,fontSize: 14),
        //           ),
        //           const SizedBox(height: 2.0), // Space between label and value
        //           Text(
        //             rightValue,
        //             style: TextStyle(color: grey,fontSize: 13),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  String _getDisplayValue(String? value) {
    // Return 'N/A' if the value is null or empty, otherwise return the value
    return (value == null || value.trim().isEmpty) ? 'N/A' : value;
  }

/* Widget buildListTile(BuildContext context,Widget leadingIcon, String title,bool active) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: active?blueColor:Colors.transparent,
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

class PropertyCard extends StatefulWidget {
  final RentalData rental;
  final int index;
  final List<WorkOrder> nearestPropertyWorkOrders;

  const PropertyCard(
      {super.key,
        required this.rental,
        required this.index,
        required this.nearestPropertyWorkOrders});

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  bool _isExpanded = false;
  int? expandedIndexrow;
  Widget _buildHeaders() {
    var width = MediaQuery.of(context).size.width;
    return Container(
      //  height: 50,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        // leading: Container(
        //   child: Icon(
        //     Icons.expand_less,
        //     color: Colors.transparent,
        //   ),
        // ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: const Icon(
                Icons.expand_less,
                color: Colors.transparent,
              ),
            ),
            Expanded(
              flex: 4,
              child: InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    width < 400
                        ? Text("Work Order ",
                        style: TextStyle(
                            color: blueColor, fontWeight: FontWeight.bold))
                        : Text("Work Order",
                        style: TextStyle(
                            color: blueColor, fontWeight: FontWeight.bold)),
                    // Text("Property", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Text("Status",
                        style: TextStyle(
                            color: blueColor, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    final matchingWorkOrders = widget.nearestPropertyWorkOrders
        .where((workOrder) =>
    workOrder != null &&
        workOrder.rentalData?.rentalId == widget.rental.rentalId &&
        workOrder!.status != "Completed")
        .toList();

    bool hasWorkOrders = matchingWorkOrders.isNotEmpty;
    final rental = widget.rental;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color:
        widget.index % 2 != 0 ? Colors.white : Color(0xFFF4F8FF),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color.fromRGBO(152, 162, 179, .5)),
        // border: Border.all(color: Colors.grey.shade300),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black12,
        //     blurRadius: 4,
        //     offset: Offset(0, 2),
        //   ),
        //],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        rental.rentalAddress ?? 'No Address',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey[700],
                    ),
                  ],
                ),
              ),

              // Expanded section
              if (_isExpanded) ...[
                if (hasWorkOrders)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const SizedBox(height: 5),
                      const Divider(),
                      const SizedBox(height: 10),
                      _buildHeaders(),
                      const SizedBox(height: 10),
                      Container(
                        // decoration: BoxDecoration(
                        //     border: Border.all(
                        //         color:
                        //             const Color.fromRGBO(152, 162, 179, .5))),
                        // decoration: BoxDecoration(
                        //     border: Border.all(color: blueColor)),
                        child: Column(
                          children: widget.nearestPropertyWorkOrders
                              .where((workOrder) =>
                          workOrder!.rentalData!.rentalId ==
                              widget.rental!.rentalId &&
                              workOrder!.status != "Completed")
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                            int index = entry.key;
                            bool isExpanded = expandedIndexrow == index;
                            WorkOrder workOrder = entry.value;
                            //return CustomExpansionTile(data: Data, index: index);
                            return Container(
                              decoration: BoxDecoration(
                                color: index % 2 != 0
                                    ? Colors.white
                                    : blueColor.withOpacity(0.09),
                                border:
                                Border.all(color: const Color(0xFFDBE0E5)),
                              ),
                              // decoration: BoxDecoration(
                              //   border: Border.all(color: blueColor),
                              // ),
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    onTap: () {
                                      setState(() {
                                        if (expandedIndexrow == index) {
                                          expandedIndexrow = null;
                                        } else {
                                          expandedIndexrow = index;
                                        }
                                      });
                                    },
                                    contentPadding: EdgeInsets.zero,
                                    title: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: <Widget>[
                                          InkWell(
                                            onTap: () {
                                              // setState(() {
                                              //    isExpanded = !isExpanded;
                                              // //  expandedIndex = !expandedIndex;
                                              //
                                              // });
                                              // setState(() {
                                              //   if (isExpanded) {
                                              //     expandedIndex = null;
                                              //     isExpanded = !isExpanded;
                                              //   } else {
                                              //     expandedIndex = index;
                                              //   }
                                              // });
                                              setState(() {
                                                if (expandedIndexrow == index) {
                                                  expandedIndexrow = null;
                                                } else {
                                                  expandedIndexrow = index;
                                                }
                                              });
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  left: 5, right: 8),
                                              padding: !isExpanded
                                                  ? const EdgeInsets.only(
                                                  bottom: 10)
                                                  : const EdgeInsets.only(
                                                  top: 10),
                                              child: FaIcon(
                                                isExpanded
                                                    ? FontAwesomeIcons.sortUp
                                                    : FontAwesomeIcons.sortDown,
                                                size: 20,
                                                color: blueColor,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              '${workOrder!.workSubject}',
                                              style: TextStyle(
                                                color: blueColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                                  .02),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              '${workOrder!.status}',
                                              style: TextStyle(
                                                color: blueColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          // SizedBox(
                                          //     width: MediaQuery.of(context)
                                          //             .size
                                          //             .width *
                                          //         .03),
                                          // Expanded(
                                          //   flex: 3,
                                          //   child: Row(
                                          //     mainAxisAlignment:
                                          //         MainAxisAlignment.center,
                                          //     crossAxisAlignment:
                                          //         CrossAxisAlignment.center,
                                          //     children: [
                                          //       if (workOrder!.isBillable ==
                                          //           true)
                                          //         Icon(
                                          //           Icons.check,
                                          //           color: blueColor,
                                          //         ),
                                          //       if (workOrder!.isBillable ==
                                          //           false)
                                          //         Icon(
                                          //           Icons.close,
                                          //           color: blueColor,
                                          //         ),
                                          //     ],
                                          //   ),
                                          // ),
                                          // SizedBox(
                                          //     width: MediaQuery.of(context)
                                          //             .size
                                          //             .width *
                                          //         .02),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isExpanded)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2),
                                      margin: const EdgeInsets.only(bottom: 1),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                FaIcon(
                                                  isExpanded
                                                      ? FontAwesomeIcons.sortUp
                                                      : FontAwesomeIcons
                                                      .sortDown,
                                                  size: 30,
                                                  color: Colors.transparent,
                                                ),
                                                Expanded(
                                                  child: Table(
                                                    columnWidths: {
                                                      0: const FlexColumnWidth(), // Distribute columns equally
                                                      1: const FlexColumnWidth(),
                                                      // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                                      // 1: FlexColumnWidth(),
                                                    },
                                                    children: [
                                                      // _buildTableRow(
                                                      //     'Created At:',
                                                      //     formatDate(
                                                      //         '${workOrder!.createdAt}'),
                                                      //     'Updated At:',
                                                      //     formatDate(
                                                      //         '${workOrder!.updatedAt}}')),
                                                      _buildTableRow(
                                                          ' Created On : ',
                                                          workOrder.createdAt
                                                              ?.isNotEmpty ==
                                                              true
                                                              ? dateProvider
                                                              .formatCurrentDate(
                                                              '${workOrder.createdAt}')
                                                              : 'N/A',
                                                          '',
                                                          '')
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.end,
                                              children: [
                                                // if(permissions!.workorderView!)
                                                GestureDetector(
                                                  onTap: () {
                                                    // Navigator.push(
                                                    //     context,
                                                    //     MaterialPageRoute(
                                                    //         builder: (context) =>
                                                    //             Workorder_summery(
                                                    //               workorder_id:
                                                    //               workOrder
                                                    //                   .workOrderData
                                                    //                   ?.workOrderId,
                                                    //             )));
                                                  },
                                                  child:
                                                  Container(
                                                    height: 40,
                                                    // width: 35,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .center,
                                                      children: [
                                                        const FaIcon(
                                                          FontAwesomeIcons.eye,
                                                          size: 15,
                                                          color: Colors.black,
                                                        ),
                                                        // SizedBox(
                                                        //     width:
                                                        //     2),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          "View Summary",
                                                          style: TextStyle(
                                                              fontSize: 11,
                                                              color: blueColor,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 8,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  //SizedBox(height: 13,),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                if (!hasWorkOrders)
                  const Column(
                    children: [
                      SizedBox(height: 5),
                      Divider(),
                      SizedBox(height: 10),
                      Text("No Work Orders",
                          style: TextStyle(color: Colors.blueGrey)),
                      SizedBox(height: 10),
                    ],
                  ),
                // Add more fields if needed
              ]
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(String leftLabel, String leftValue, String rightLabel,
      String rightValue) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leftLabel,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                      fontSize: 13),
                ),
                const SizedBox(height: 2.0), // Space between label and value
                Text(
                  leftValue,
                  style: TextStyle(color: grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        // TableCell(
        //   child: Padding(
        //     padding: const EdgeInsets.all(4.0),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         Text(
        //           rightLabel,
        //           style:
        //               TextStyle(fontWeight: FontWeight.bold, color: blueColor),
        //         ),
        //         const SizedBox(height: 2.0), // Space between label and value
        //         Text(
        //           rightValue,
        //           style: TextStyle(color: grey),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }

  String _getDisplayValue(String? value) {
    // Return 'N/A' if the value is null or empty, otherwise return the value
    return (value == null || value.trim().isEmpty) ? 'N/A' : value;
  }
}

class _VendorDashboardSummaryCard extends StatelessWidget {
  final Color cardColor;
  final String iconPath;
  final String count;
  final String label;
  final String buttonLabel;
  final Color buttonColor;
  final VoidCallback onViewAll;

  const _VendorDashboardSummaryCard({
    required this.cardColor,
    required this.iconPath,
    required this.count,
    required this.label,
    required this.buttonLabel,
    required this.buttonColor,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              padding: EdgeInsets.all(8),
              child: SvgPicture.asset(
                iconPath,
                height: 32,
                width: 32,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            Material(
              color: buttonColor,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: onViewAll,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  child: Text(
                    buttonLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}