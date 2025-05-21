import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/StaffModule/screen/Dashboard/cronjob_payment_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Leasing/Applicants/Applicants_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Maintenance/Vendor/Vendor_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Maintenance/Workorder/Workorder_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Rental/Properties/Properties_table.dart';
import 'package:three_zero_two_property/StaffModule/screen/Rental/Tenants/Tenants_table.dart';
import 'package:three_zero_two_property/widgets/pie_chart.dart';
import 'package:three_zero_two_property/screens/Rental/Properties/properties.dart';
import '../../Model/properties.dart';
import '../../constant/geolocation_data_filter.dart';
import '../../model/properties_workorders.dart';
import '../../screens/Rental/Properties/summery_page.dart';
import '../model/staffpermission.dart';
import '../repository/staffpermission_provider.dart';
import '../widgets/appbar.dart';
import 'package:http/http.dart' as http;
import '../../constant/constant.dart';
import '../widgets/drawer_tiles.dart';
import '../widgets/custom_drawer.dart';
import '../../widgets/barchart.dart';
import '../widgets/chart.dart';
import '../../../../model/workordr.dart';
import '../screen/Maintenance/Workorder/workorder_summery.dart';
import 'profile.dart';

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

  List<Color> colorc = [
    blueColor,
    const Color.fromRGBO(40, 60, 95, 1),
    const Color.fromRGBO(50, 75, 119, 1),
    const Color.fromRGBO(60, 89, 142, 1),
    const Color.fromRGBO(90, 134, 213, 1),
  ];

  List<Color> colors = [
    blueColor,
    const Color.fromRGBO(40, 60, 95, 1),
    const Color.fromRGBO(50, 75, 119, 1),
    const Color.fromRGBO(60, 89, 142, 1),
    const Color.fromRGBO(90, 134, 213, 1),
  ];

  DashboardData({required this.countList, required this.amountList});
}

class Dashboard_staff extends StatefulWidget {
  Dashboard_staff({super.key});

  @override
  State<Dashboard_staff> createState() => _Dashboard_staffState();
}

class _Dashboard_staffState extends State<Dashboard_staff> {
  String firstname = '';
  String lastname = '';
  bool loading = false;
  List<Rentals> properties = [];
  Rentals? nearstProperty;
  final List<Widget> pages = [
    PropertiesTable(),
    Tenants_table(),
    Applicants_table(),
    Vendor_table(),
    Workorder_table(),
  ];
  List<Data> nearestWorkOrders = [];
  List<Data> nearestPropertyWorkOrders = [];
  StaffPermission? permissions;
  int totalWorkOrders = 0;
  Future<void> fetchDatacount() async {
    /*setState(() {
      loading = true;
    });*/
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("staff_id");
      String? admin_id = prefs.getString("adminId");
      String? token = prefs.getString('token');

      final response = await http.get(
          Uri.parse('${Api_url}/api/staffmember/count/${id!}/${admin_id}'),
          headers: {
            "id": "CRM $id",
            "authorization": "CRM $token",
            "Content-Type": "application/json"
          });
      print(response.body);
      final jsonData = json.decode(response.body);
      if (jsonData["statusCode"] == 200) {
        setState(() {
          countList[0] = jsonData['property_staffMember'];
          countList[1] = jsonData['tenant_staffMember'];
          countList[2] = jsonData['applicant_staffMember'];
          countList[3] = jsonData['vendor_staffMember'];
          countList[4] = jsonData['workorder_staffMember'];
          totalWorkOrders = jsonData['workorder_staffMember'] ?? 0;
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
  Future<Map<String, dynamic>> fetchProperties() async {
    setState(() {
      loading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${Api_url}/api/rentals/rentals/$adminid'),
      headers: {"authorization": "CRM $token", "id": "CRM $id"},
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      List<Rentals> rentals =
      jsonResponse.map((data) => Rentals.fromJson(data)).toList();

      try {
        Position userLocation = await getCurrentLocation();
        Rentals? nearestProperty;
        double minDistance = double.infinity;
        List<Rentals> nearbyProperties = [];

        for (Rentals rental in rentals) {
          final coords = await getCoordinatesFromAddress(rental);
          if (coords != null) {
            double distanceInMeters = Geolocator.distanceBetween(
              // userLocation.latitude,
              // userLocation.longitude,
              39.6613845,
              -75.6339627,
              coords.latitude,
              coords.longitude,
            );

            double distanceInKm = distanceInMeters / 1000;
            print("${rental.rentalAddress} $distanceInKm");
            if (distanceInKm <= 5) {
              // Track nearest
              if (distanceInMeters < minDistance) {
                minDistance = distanceInMeters;
                nearestProperty = rental;
              }
              // Add to nearby (will remove nearest later to avoid duplication)
              nearbyProperties.add(rental);
            }
          }
        }

        // Remove nearest from nearby list to avoid duplication
        if (nearestProperty != null) {
          nearbyProperties
              .removeWhere((r) => r.rentalId == nearestProperty!.rentalId);
        }

        print(nearbyProperties.length);
        return {
          "nearest": nearestProperty,
          "nearby": nearbyProperties,
        };
      } catch (e) {
        print('Error finding nearby properties: $e');
        setState(() {
          loading = false;
        });
        return {};
      }
    } else {
      print('Failed to fetch properties: ${response.body}');
      setState(() {
        loading = false;
      });
      return {};
    }
  }

  void fetchNearbyProperties() async {
    setState(() {
      loading = true;
    });
    final result = await fetchProperties();
    if (result != null) {
      List<Data> workOrders = await fetchWorkOrders("");
      print(result);
      nearstProperty = result["nearest"];
      if (nearstProperty != null) {
        nearestPropertyWorkOrders = workOrders
            .where((workOrder) =>
        workOrder.rentalAddress!.rentalId == nearstProperty!.rentalId! && workOrder.workOrderData!.status != "Completed")
            .toList();
      }
// Multiple near properties work orders
      List<dynamic> multipleRentalIds =
      result["nearby"].map((property) => property.rentalId!).toList();

      // List<Data> multiplePropertiesWorkOrders = workOrders
      //     .where((workOrder) => multipleRentalIds.contains(workOrder.rentalAddress!.rentalId))
      //     .toList();

      setState(() {
        // nearestProperty = nearest;
        properties = result["nearby"];
        nearestWorkOrders = workOrders;
        // nearestPropertyWorkOrders = nearestPropertyWorkOrders;
        loading = false;
      });
    }
    // setState(() {
    //   properties = data;
    // });
    fetchDatacount();
    fetchData();
    _loadName();
  }

  Future<void> fetchData() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("staff_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    print(admin_id);
    final response = await http.get(
        Uri.parse(
            '${Api_url}/api/staffmember/dashboard_workorder/$id/$admin_id'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json"
        });
    //print('${Api_url}/api/payment/admin_balance/$id');
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print(jsonData);
      if (jsonData["statusCode"] == 200) {
        final data = jsonData["data"];
        setState(() {
          List newwork = data["new_workorder"];
          List overdue = data["overdue_workorder"];
          print(newwork.length);
          newworkorder = newwork.length;
          overdueworkorder = overdue.length;
          print(data);
        });
      } else {
        throw Exception('Failed to load data');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<Data>> fetchWorkOrders(String rentalId) async {
    // Retrieve admin ID and token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    print(rentalId);
    // Define the URL and headers for the request
    final response = await http.get(
      Uri.parse('$Api_url/api/work-order/work-orders/$adminid'),
      headers: {
        'authorization': 'CRM $token',
        'id': 'CRM $id',
      },
    );
    // Check the response status
    print(response.body);
    print(rentalId);
    if (response.statusCode == 200) {
      // Parse the JSON response
      List jsonResponse = json.decode(response.body)['data'];
      // Map the JSON data to List<Data> and return
      return jsonResponse.map((data) => Data.fromJson(data)).toList();
    } else {
      // Throw an exception if the request failed
      throw Exception('No work order found');
    }
  }

  late DashboardData dashboardData;
  List<int> countList = List.filled(5, 0);
  List<int> amountList = List.filled(5, 0);

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        print(result);
        _connectivityResult = result;
      });
    });
    checkInternet();
    fetchNearbyProperties();
    dashboardData = DashboardData(countList: [0, 0], amountList: [0, 0]);
    // fetchDatacount();
    // fetchData();
    // _loadName();
  }

  ConnectivityResult? _connectivityResult;
  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
      print(_connectivityResult);
    });
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

  Widget _buildHeaders() {
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: blueColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(6),
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
                        ? const Text("Work Order ",
                        style: TextStyle(color: Colors.white))
                        : const Text("Work Order",
                        style: TextStyle(color: Colors.white)),
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
                    const Text("Status", style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 5),
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
                    const Text("      Billable ",
                        style: TextStyle(color: Colors.white)),
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

  int? expandedIndex;
  int? expandedIndexrow;
  var appBarHeight = AppBar().preferredSize.height;
  @override
  Widget build(BuildContext context) {
    final permissionProvider = Provider.of<StaffPermissionProvider>(context);
    permissions = permissionProvider.permissions;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        return await _showExitPopup(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: CustomDrawer(
          currentpage: 'Dashboard',
          dropdown: false,
        ),
        appBar: widget_302.App_Bar(context: context),
        body: _connectivityResult != ConnectivityResult.none
            ? loading
            ? Center(
          child: Lottie.asset('assets/images/loader.json',
              height: 150, width: 100),
        )
            : properties.length > 0 ||
            nearstProperty != null
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
                    return Row(
                      children: [
                        SizedBox(width: width * 0.03),
                        Container(
                          color: Color.fromRGBO(2, 121, 210, 1),
                          margin: EdgeInsets.only(
                            top: MediaQuery.of(context)
                                .size
                                .height *
                                0.012,
                          ),
                          width: 3,
                          child: Column(
                            children: [
                              Container(
                                height: MediaQuery.of(context)
                                    .size
                                    .height *
                                    0.012 +
                                    MediaQuery.of(context)
                                        .size
                                        .width *
                                        0.04 +
                                    3 +
                                    16,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                                height: MediaQuery.of(context)
                                    .size
                                    .height *
                                    0.012),
                            Row(
                              children: [
                                SizedBox(width: width * 0.05),
                                Text(
                                  "Hello $firstname $lastname, Welcome back",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: MediaQuery.of(
                                        context)
                                        .size
                                        .width >
                                        500
                                        ? MediaQuery.of(context)
                                        .size
                                        .width *
                                        0.03
                                        : MediaQuery.of(context)
                                        .size
                                        .width *
                                        0.04,
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
                                    fontSize: MediaQuery.of(
                                        context)
                                        .size
                                        .width >
                                        500
                                        ? MediaQuery.of(context)
                                        .size
                                        .width *
                                        0.03
                                        : MediaQuery.of(context)
                                        .size
                                        .width *
                                        0.04,
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
                SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.01),
                if (nearestPropertyWorkOrders.length > 0)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0),
                        child: Text(
                          "You are at ${nearstProperty!.rentalAddress!}.  Here are the current open work orders:",
                          style: TextStyle(
                            color: Colors.orange,
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
                        ),
                      ),
                      const SizedBox(height: 5),
                      _buildHeaders(),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Color.fromRGBO(
                                    152, 162, 179, .5))),
                        // decoration: BoxDecoration(
                        //     border: Border.all(color: blueColor)),
                        child: Column(
                          children: nearestPropertyWorkOrders
                          //  .where((workOrder) => workOrder!.rentalAddress!.rentalId == nearstProperty!.rentalId).toList()
                              .asMap()
                              .entries
                              .map((entry) {
                            int index = entry.key;
                            bool isExpanded =
                                expandedIndex == index;
                            Data workOrder = entry.value;
                            //return CustomExpansionTile(data: Data, index: index);
                            return Container(
                              decoration: BoxDecoration(
                                color: index % 2 != 0
                                    ? Colors.white
                                    : blueColor.withOpacity(0.09),
                                border: Border.all(
                                    color: Color.fromRGBO(
                                        152, 162, 179, .5)),
                              ),
                              // decoration: BoxDecoration(
                              //   border: Border.all(color: blueColor),
                              // ),
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    onTap:() {
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
                                    contentPadding:
                                    EdgeInsets.zero,
                                    title: Padding(
                                      padding:
                                      const EdgeInsets.all(
                                          2.0),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .start,
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .center,
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
                                              margin:
                                              EdgeInsets.only(
                                                  left: 5,
                                                  right: 8),
                                              padding: !isExpanded
                                                  ? EdgeInsets
                                                  .only(
                                                  bottom:
                                                  10)
                                                  : EdgeInsets
                                                  .only(
                                                  top:
                                                  10),
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
                                              '${workOrder.workOrderData!.workSubject}',
                                              style: TextStyle(
                                                color: blueColor,
                                                fontWeight:
                                                FontWeight
                                                    .bold,
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
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              '${workOrder.workOrderData!.status}',
                                              style: TextStyle(
                                                color: blueColor,
                                                fontWeight:
                                                FontWeight
                                                    .bold,
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
                                          Expanded(
                                            flex: 3,
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .center,
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .center,
                                              children: [
                                                if (workOrder
                                                    .workOrderData!
                                                    .isBillable ==
                                                    true)
                                                  Icon(
                                                    Icons.check,
                                                    color:
                                                    blueColor,
                                                  ),
                                                if (workOrder
                                                    .workOrderData!
                                                    .isBillable ==
                                                    false)
                                                  Icon(
                                                    Icons.close,
                                                    color:
                                                    blueColor,
                                                  ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                              width: MediaQuery.of(
                                                  context)
                                                  .size
                                                  .width *
                                                  .02),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isExpanded)
                                    Container(
                                      padding:
                                      EdgeInsets.symmetric(
                                          horizontal: 2),
                                      margin: EdgeInsets.only(
                                          bottom: 1),
                                      child:
                                      SingleChildScrollView(
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
                                                      0: FlexColumnWidth(), // Distribute columns equally
                                                      1: FlexColumnWidth(),
                                                      // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                                      // 1: FlexColumnWidth(),
                                                    },
                                                    children: [
                                                      _buildTableRow(
                                                          'Property :',
                                                          _getDisplayValue(workOrder
                                                              .rentalAddress!
                                                              .rentalAdress),
                                                          'Assign :',
                                                          _getDisplayValue(workOrder
                                                              .staffMember
                                                              ?.staffmemberName)),
                                                      _buildTableRow(
                                                          'Created At:',
                                                          formatDate(
                                                              '${workOrder.workOrderData!.createdAt}'),
                                                          'Updated At:',
                                                          formatDate(
                                                              '${workOrder.workOrderData!.updatedAt}}')),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),

                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                // if(permissions!.workorderView!)
                                                Expanded(
                                                  child:
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => Workorder_summery(
                                                                workorder_id: workOrder.workOrderData?.workOrderId,
                                                              )));
                                                    },
                                                    child:
                                                    Container(
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .grey[
                                                          350]),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                        children: [
                                                          SizedBox(
                                                            width:
                                                            5,
                                                          ),
                                                          Image
                                                              .asset(
                                                            'assets/icons/view.png',
                                                            color:
                                                            blueColor,
                                                          ),
                                                          // FaIcon(
                                                          //   FontAwesomeIcons.trashCan,
                                                          //   size: 15,
                                                          //   color:blueColor,
                                                          // ),
                                                          SizedBox(
                                                            width:
                                                            8,
                                                          ),
                                                          Text(
                                                            "View Summery",
                                                            style: TextStyle(
                                                                fontSize:
                                                                11,
                                                                color:
                                                                blueColor,
                                                                fontWeight:
                                                                FontWeight.bold),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
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
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),

                if (properties.length > 0)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Open Work Orders At Nearby Properties",
                          style: TextStyle(
                              color: Colors.orange, fontSize: 16),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0.0, vertical: 0.0),
                          child: Column(
                            children: properties
                                .asMap()
                                .entries
                                .map((entry) {
                              int index = entry.key;
                              Rentals rental = entry.value;
                              return PropertyCard(
                                rental: rental,
                                index: index,
                                nearestPropertyWorkOrders:
                                nearestWorkOrders,
                              );
                            }).toList(),
                          )),
                    ],
                  ),

                // Dynamically build Column items from properties list
              ],
            ),
          ),
        )
            : SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (BuildContext context,
                    BoxConstraints constraints) {
                  return Row(
                    children: [
                      SizedBox(width: width * 0.05),
                      Container(
                        color: Color.fromRGBO(2, 121, 210, 1),
                        margin: EdgeInsets.only(
                          top:
                          MediaQuery.of(context).size.height *
                              0.012,
                        ),
                        width: 3,
                        child: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context)
                                  .size
                                  .height *
                                  0.012 +
                                  MediaQuery.of(context)
                                      .size
                                      .width *
                                      0.04 +
                                  3 +
                                  16,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment:
                        MainAxisAlignment.start,
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context)
                                  .size
                                  .height *
                                  0.012),
                          Row(
                            children: [
                              SizedBox(width: width * 0.05),
                              Text(
                                "Hello $firstname $lastname, Welcome back",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: MediaQuery.of(context)
                                      .size
                                      .width >
                                      500
                                      ? MediaQuery.of(context)
                                      .size
                                      .width *
                                      0.03
                                      : MediaQuery.of(context)
                                      .size
                                      .width *
                                      0.04,
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
                                  fontSize: MediaQuery.of(context)
                                      .size
                                      .width >
                                      500
                                      ? MediaQuery.of(context)
                                      .size
                                      .width *
                                      0.03
                                      : MediaQuery.of(context)
                                      .size
                                      .width *
                                      0.04,
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
              SizedBox(
                  height:
                  MediaQuery.of(context).size.height * 0.01),
              //my dashboard

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
                        MediaQuery.of(context).size.width *
                            0.02,
                        runSpacing:
                        MediaQuery.of(context).size.width *
                            0.02,
                        children: List.generate(
                          2,
                              (index) => InkWell(
                            onTap: () {
                              if (index == 0 &&
                                  permissions!.propertyView!)
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PropertiesTable()));
                              else if (index == 1 &&
                                  permissions!.workorderView!)
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Workorder_table()));
                            },
                            child: SizedBox(
                              width:
                              180, // Ensure SizedBox has defined width
                              height:
                              180, // Ensure SizedBox has defined height
                              child: Material(
                                elevation: 3,
                                borderRadius:
                                BorderRadius.circular(10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: dashboardData
                                        .colorc[index],
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const SizedBox(
                                              width: 10),
                                          Material(
                                            elevation: 5,
                                            borderRadius:
                                            BorderRadius
                                                .circular(20),
                                            child: Container(
                                              height: 50,
                                              width: 50,
                                              padding:
                                              const EdgeInsets
                                                  .all(10),
                                              decoration:
                                              BoxDecoration(
                                                color: dashboardData
                                                    .colors[
                                                index],
                                                borderRadius:
                                                BorderRadius
                                                    .circular(
                                                    20),
                                              ),
                                              child: SvgPicture
                                                  .asset(
                                                "${dashboardData.icons[index]}",
                                                fit: BoxFit.cover,
                                                height: 27,
                                                width: 27,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 15),
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(
                                            left: 10),
                                        child: Text(
                                          countList[index]
                                              .toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 25,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(
                                            left: 10),
                                        child: Text(
                                          dashboardData
                                              .titles[index],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight:
                                            FontWeight.bold,
                                            fontSize: 22,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
                            height: MediaQuery.of(context)
                                .size
                                .width *
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
                              MediaQuery.of(context)
                                  .size
                                  .width *
                                  0.02,
                              mainAxisSpacing:
                              MediaQuery.of(context)
                                  .size
                                  .width *
                                  0.02,
                              childAspectRatio:
                              .99, // Adjust as needed for your design
                            ),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        pages[index]),
                                  );
                                },
                                child: Material(
                                  elevation: 3,
                                  borderRadius:
                                  BorderRadius.circular(10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: dashboardData
                                          .colorc[index],
                                      borderRadius:
                                      BorderRadius.circular(
                                          8),
                                    ),
                                    child: Padding(
                                      padding:
                                      const EdgeInsets.only(
                                          left: 5),
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                              height: 15),
                                          Row(
                                            children: [
                                              const SizedBox(
                                                  width: 10),
                                              Material(
                                                elevation: 5,
                                                borderRadius:
                                                BorderRadius
                                                    .circular(
                                                    15),
                                                child: Container(
                                                    height: 50,
                                                    width: 50,
                                                    padding:
                                                    const EdgeInsets
                                                        .all(
                                                        10),
                                                    decoration:
                                                    BoxDecoration(
                                                      color: dashboardData
                                                          .colors[
                                                      index],
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          15),
                                                    ),
                                                    child:
                                                    SvgPicture
                                                        .asset(
                                                      "${dashboardData.icons[index]}",
                                                      //fit: BoxFit.cover,
                                                      height: 30,
                                                      width: 30,
                                                    )),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                              height: 16),
                                          Row(
                                            children: [
                                              const SizedBox(
                                                  width: 10),
                                              Text(
                                                countList[index]
                                                    .toString(),
                                                style:
                                                const TextStyle(
                                                  color: Colors
                                                      .white,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                              height: 10),
                                          Row(
                                            children: [
                                              const SizedBox(
                                                  width: 10),
                                              Text(
                                                dashboardData
                                                    .titles[
                                                index],
                                                style:
                                                const TextStyle(
                                                  color: Colors
                                                      .white,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Icon(
                                                Icons
                                                    .arrow_forward_rounded,
                                                color:
                                                Colors.white,
                                              ),
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

              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    // Tablet layout - horizontal
                    return Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      height: 150,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: width *
                                              .025), // Adjusted for equal spacing
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.all(
                                              Radius.circular(
                                                  7)),
                                          border: Border.all(
                                              color: blueColor)),
                                      child: Material(
                                        //   elevation: 3,
                                        borderRadius:
                                        const BorderRadius
                                            .all(
                                            Radius.circular(
                                                5)),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                decoration:
                                                const BoxDecoration(
                                                  color: Color
                                                      .fromRGBO(
                                                      50,
                                                      75,
                                                      119,
                                                      1),
                                                  borderRadius:
                                                  BorderRadius
                                                      .vertical(
                                                      top:
                                                      Radius.circular(6)),
                                                ),
                                                child:
                                                const Center(
                                                  child: Text(
                                                    "New Work Order",
                                                    style: TextStyle(
                                                        color: Colors
                                                            .white,
                                                        fontSize:
                                                        20,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 7,
                                              child: Container(
                                                decoration:
                                                const BoxDecoration(
                                                  color: Colors
                                                      .white,
                                                  borderRadius: BorderRadius.vertical(
                                                      bottom: Radius
                                                          .circular(
                                                          15)),
                                                ),
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(
                                                      8.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                        children: [
                                                          const Text(
                                                            "Total: ",
                                                            style:
                                                            TextStyle(
                                                              fontSize:
                                                              18,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                              color: Color.fromRGBO(
                                                                  90,
                                                                  134,
                                                                  213,
                                                                  1),
                                                            ),
                                                          ),
                                                          Text(
                                                            "${newworkorder}",
                                                            style: const TextStyle(
                                                                fontSize: 18,
                                                                color: Color.fromRGBO(90, 134, 213, 1),
                                                                fontWeight: FontWeight.bold),
                                                          ),
                                                        ],
                                                      ),
                                                      InkWell(
                                                        onTap:
                                                            () {
                                                          if (permissions!
                                                              .workorderView!)
                                                            Navigator.of(context)
                                                                .push(MaterialPageRoute(builder: (context) => Workorder_table()));
                                                        },
                                                        child:
                                                        Container(
                                                          margin: EdgeInsets.symmetric(
                                                              vertical:
                                                              12),
                                                          width:
                                                          100,
                                                          height:
                                                          30,
                                                          decoration:
                                                          BoxDecoration(
                                                            color:
                                                            blueColor,
                                                            borderRadius:
                                                            BorderRadius.circular(5),
                                                          ),
                                                          child:
                                                          const Center(
                                                            child:
                                                            Text(
                                                              "View All",
                                                              style:
                                                              TextStyle(color: Colors.white),
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
                                    const SizedBox(height: 20),
                                    Container(
                                      height: 150,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: width *
                                              .025), // Adjusted for equal spacing
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.all(
                                              Radius.circular(
                                                  7)),
                                          border: Border.all(
                                              color:
                                              Color.fromRGBO(
                                                  91,
                                                  134,
                                                  213,
                                                  1))),
                                      child: Material(
                                        //  elevation: 3,
                                        borderRadius:
                                        const BorderRadius
                                            .all(
                                            Radius.circular(
                                                7)),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                decoration:
                                                const BoxDecoration(
                                                  color: Color
                                                      .fromRGBO(
                                                      91,
                                                      134,
                                                      213,
                                                      1),
                                                  borderRadius:
                                                  BorderRadius
                                                      .vertical(
                                                      top:
                                                      Radius.circular(6)),
                                                ),
                                                child:
                                                const Center(
                                                  child: Text(
                                                    "Overdue Work Order",
                                                    style: TextStyle(
                                                        color: Colors
                                                            .white,
                                                        fontSize:
                                                        20,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 7,
                                              child: Container(
                                                decoration:
                                                const BoxDecoration(
                                                  color: Colors
                                                      .white,
                                                  borderRadius: BorderRadius.vertical(
                                                      bottom: Radius
                                                          .circular(
                                                          15)),
                                                ),
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(
                                                      8.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                        children: [
                                                          const Text(
                                                            "Total: ",
                                                            style:
                                                            TextStyle(
                                                              fontSize:
                                                              16,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                              color: Color.fromRGBO(
                                                                  90,
                                                                  134,
                                                                  213,
                                                                  1),
                                                            ),
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
                                                        onTap:
                                                            () {

                                                          Navigator.of(context)
                                                              .push(MaterialPageRoute(builder: (context) => Workorder_table()));
                                                        },
                                                        child:
                                                        Container(
                                                          margin: EdgeInsets.symmetric(
                                                              vertical:
                                                              12),
                                                          width:
                                                          100,
                                                          height:
                                                          30,
                                                          decoration:
                                                          BoxDecoration(
                                                            color: Color.fromRGBO(
                                                                91,
                                                                134,
                                                                213,
                                                                1),
                                                            borderRadius:
                                                            BorderRadius.circular(5),
                                                          ),
                                                          child:
                                                          const Center(
                                                            child:
                                                            Text(
                                                              "View All",
                                                              style:
                                                              TextStyle(color: Colors.white),
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
                                  ],
                                ),
                              ),
                              Container(
                                height: 350,
                                margin: EdgeInsets.symmetric(
                                  horizontal: width * 0.05,
                                ),
                                child: Container(
                                  child: DonutChart(
                                    totalWorkOrders:
                                    totalWorkOrders,
                                    newWorkOrders: newworkorder,
                                    overdueWorkOrders:
                                    overdueworkorder,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    );
                  } else {
                    // Phone layout - vertical
                    return Container(
                      //    color: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8, right: 8),
                            child: Cronjob_payment_table(),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 150,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: width *
                                          .025), // Adjusted for equal spacing
                                  decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.all(
                                          Radius.circular(7)),
                                      border: Border.all(
                                          color: blueColor)),
                                  child: Material(
                                    //   elevation: 3,
                                    borderRadius:
                                    const BorderRadius.all(
                                        Radius.circular(5)),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            decoration:
                                            const BoxDecoration(
                                              color:
                                              Color.fromRGBO(
                                                  50,
                                                  75,
                                                  119,
                                                  1),
                                              borderRadius:
                                              BorderRadius.vertical(
                                                  top: Radius
                                                      .circular(
                                                      6)),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                "New Work Order",
                                                style: TextStyle(
                                                    color: Colors
                                                        .white,
                                                    fontSize: 14,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 7,
                                          child: Container(
                                            decoration:
                                            const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.vertical(
                                                  bottom: Radius
                                                      .circular(
                                                      15)),
                                            ),
                                            child: Padding(
                                              padding:
                                              const EdgeInsets
                                                  .all(8.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .center,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                    children: [
                                                      const Text(
                                                        "Total: ",
                                                        style:
                                                        TextStyle(
                                                          fontSize:
                                                          16,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: Color.fromRGBO(
                                                              90,
                                                              134,
                                                              213,
                                                              1),
                                                        ),
                                                      ),
                                                      Text(
                                                        "${newworkorder}",
                                                        style: const TextStyle(
                                                            fontSize:
                                                            16,
                                                            color: Color.fromRGBO(
                                                                90,
                                                                134,
                                                                213,
                                                                1),
                                                            fontWeight:
                                                            FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      if (permissions!
                                                          .workorderView!)
                                                        Navigator.of(context).push(MaterialPageRoute(
                                                            builder: (context) => Workorder_table(
                                                              filter: "New",
                                                            )));
                                                    },
                                                    child:
                                                    Container(
                                                      margin: EdgeInsets.symmetric(
                                                          vertical:
                                                          12),
                                                      width: 100,
                                                      height: 30,
                                                      decoration:
                                                      BoxDecoration(
                                                        color:
                                                        blueColor,
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                      ),
                                                      child:
                                                      const Center(
                                                        child:
                                                        Text(
                                                          "View All",
                                                          style: TextStyle(
                                                              color:
                                                              Colors.white),
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
                                  margin: EdgeInsets.symmetric(
                                      horizontal: width *
                                          .025), // Adjusted for equal spacing
                                  decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.all(
                                          Radius.circular(7)),
                                      border: Border.all(
                                          color: Color.fromRGBO(
                                              91, 134, 213, 1))),
                                  child: Material(
                                    //  elevation: 3,
                                    borderRadius:
                                    const BorderRadius.all(
                                        Radius.circular(7)),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            decoration:
                                            const BoxDecoration(
                                              color:
                                              Color.fromRGBO(
                                                  91,
                                                  134,
                                                  213,
                                                  1),
                                              borderRadius:
                                              BorderRadius.vertical(
                                                  top: Radius
                                                      .circular(
                                                      6)),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                "Overdue Work Order",
                                                style: TextStyle(
                                                    color: Colors
                                                        .white,
                                                    fontSize: 14,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 7,
                                          child: Container(
                                            decoration:
                                            const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.vertical(
                                                  bottom: Radius
                                                      .circular(
                                                      15)),
                                            ),
                                            child: Padding(
                                              padding:
                                              const EdgeInsets
                                                  .all(8.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .center,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                    children: [
                                                      const Text(
                                                        "Total: ",
                                                        style:
                                                        TextStyle(
                                                          fontSize:
                                                          16,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: Color.fromRGBO(
                                                              90,
                                                              134,
                                                              213,
                                                              1),
                                                        ),
                                                      ),
                                                      Text(
                                                        "${overdueworkorder}",
                                                        style: const TextStyle(
                                                            fontSize:
                                                            16,
                                                            color: Color.fromRGBO(
                                                                90,
                                                                134,
                                                                213,
                                                                1),
                                                            fontWeight:
                                                            FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      if (permissions!
                                                          .workorderView!)
                                                        Navigator.of(context).push(MaterialPageRoute(
                                                            builder: (context) => Workorder_table(
                                                              filter: "Over Due",
                                                            )));
                                                    },
                                                    child:
                                                    Container(
                                                      margin: EdgeInsets.symmetric(
                                                          vertical:
                                                          12),
                                                      width: 100,
                                                      height: 30,
                                                      decoration:
                                                      BoxDecoration(
                                                        color: Color.fromRGBO(
                                                            91,
                                                            134,
                                                            213,
                                                            1),
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                      ),
                                                      child:
                                                      const Center(
                                                        child:
                                                        Text(
                                                          "View All",
                                                          style: TextStyle(
                                                              color:
                                                              Colors.white),
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
                          Container(
                            height: 220,
                            margin: EdgeInsets.symmetric(
                              horizontal: width * 0.05,
                            ),
                            child: Container(
                              child: DonutChart(
                                totalWorkOrders: totalWorkOrders,
                                newWorkOrders: newworkorder,
                                overdueWorkOrders:
                                overdueworkorder,
                              ),
                            ),
                          ),
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

              /*     const SizedBox(
                              height: 60,
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
          ),
        )
            : SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/no_internet.json',
                width: 200,
                height: 200,
                fit: BoxFit.fill,
              ),
              Text(
                'No Internet',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Check your internet connection',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
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
            padding: EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leftLabel,
                  style:
                  TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                ),
                SizedBox(height: 2.0), // Space between label and value
                Text(
                  leftValue,
                  style: TextStyle(color: grey),
                ),
              ],
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rightLabel,
                  style:
                  TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                ),
                SizedBox(height: 2.0), // Space between label and value
                Text(
                  rightValue,
                  style: TextStyle(color: grey),
                ),
              ],
            ),
          ),
        ),
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
  final Rentals rental;
  final int index;
  final List<Data> nearestPropertyWorkOrders;

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
      decoration: BoxDecoration(
        color: blueColor,
        borderRadius: const BorderRadius.only(
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
              flex: 6,
              child: InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    width < 400
                        ? const Text("Work Order ",
                        style: TextStyle(color: Colors.white))
                        : const Text("Work Order",
                        style: TextStyle(color: Colors.white)),
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
                    const Text("Status", style: TextStyle(color: Colors.white)),
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
    final matchingWorkOrders = widget.nearestPropertyWorkOrders
        .where((workOrder) =>
    workOrder != null &&
        workOrder.rentalAddress?.rentalId == widget.rental.rentalId && workOrder.workOrderData!.status != "Completed")
        .toList();

    bool hasWorkOrders = matchingWorkOrders.isNotEmpty;
    final rental = widget.rental;

    return hasWorkOrders?
    Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color:
        widget.index % 2 != 0 ? Colors.white : blueColor.withOpacity(0.09),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Color.fromRGBO(152, 162, 179, .5)),
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
                        style: TextStyle(
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
                      Divider(),
                      const SizedBox(height: 10),
                      _buildHeaders(),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Color.fromRGBO(152, 162, 179, .5))),
                        // decoration: BoxDecoration(
                        //     border: Border.all(color: blueColor)),
                        child: Column(
                          children: widget.nearestPropertyWorkOrders
                              .where((workOrder) =>
                          workOrder!.rentalAddress!.rentalId ==
                              widget.rental!.rentalId && workOrder.workOrderData!.status != "Completed")
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                            int index = entry.key;
                            bool isExpanded = expandedIndexrow == index;
                            Data workOrder = entry.value;
                            //return CustomExpansionTile(data: Data, index: index);
                            return Container(
                              decoration: BoxDecoration(
                                color: index % 2 != 0
                                    ? Colors.white
                                    : blueColor.withOpacity(0.09),
                                border: Border.all(
                                    color: Color.fromRGBO(152, 162, 179, .5)),
                              ),
                              // decoration: BoxDecoration(
                              //   border: Border.all(color: blueColor),
                              // ),
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    onTap: (){
                                      setState(() {
                                        if (expandedIndexrow ==
                                            index) {
                                          expandedIndexrow =
                                          null;
                                        } else {
                                          expandedIndexrow =
                                              index;
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
                                              margin: EdgeInsets.only(
                                                  left: 5, right: 8),
                                              padding: !isExpanded
                                                  ? EdgeInsets.only(bottom: 10)
                                                  : EdgeInsets.only(top: 10),
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
                                            flex: 6,
                                            child: Text(
                                              '${workOrder.workOrderData!.workSubject}',
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
                                                  .05),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              '${workOrder.workOrderData!.status}',
                                              style: TextStyle(
                                                color: blueColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isExpanded)
                                    Container(
                                      padding:
                                      EdgeInsets.symmetric(horizontal: 2),
                                      margin: EdgeInsets.only(bottom: 1),
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
                                                      0: FlexColumnWidth(), // Distribute columns equally
                                                      1: FlexColumnWidth(),
                                                      // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                                      // 1: FlexColumnWidth(),
                                                    },
                                                    children: [
                                                      // _buildTableRow(
                                                      //     'Property :',
                                                      //     _getDisplayValue(
                                                      //         workOrder
                                                      //             .rentalAddress!
                                                      //             .rentalAdress),
                                                      //     'Assign :',
                                                      //     _getDisplayValue(workOrder
                                                      //         .staffMember
                                                      //         ?.staffmemberName)),
                                                      _buildTableRow(
                                                          'Created On:',
                                                          formatDate(
                                                              '${workOrder.workOrderData!.createdAt}'),
                                                          'Updated On:',
                                                          formatDate(
                                                              '${workOrder.workOrderData!.updatedAt}}')),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                // if(permissions!.workorderView!)
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  Workorder_summery(
                                                                    workorder_id:
                                                                    workOrder
                                                                        .workOrderData
                                                                        ?.workOrderId,
                                                                  )));
                                                    },
                                                    child: Container(
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                          color:
                                                          Colors.grey[350]),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                        children: [
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Image.asset(
                                                            'assets/icons/view.png',
                                                            color: blueColor,
                                                          ),
                                                          // FaIcon(
                                                          //   FontAwesomeIcons.trashCan,
                                                          //   size: 15,
                                                          //   color:blueColor,
                                                          // ),
                                                          SizedBox(
                                                            width: 8,
                                                          ),
                                                          Text(
                                                            "View Summary",
                                                            style: TextStyle(
                                                                fontSize: 11,
                                                                color:
                                                                blueColor,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
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
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                if (!hasWorkOrders)
                  Column(
                    children: [
                      const SizedBox(height: 5),
                      Divider(),
                      const SizedBox(height: 10),
                      Text("No Work Orders",
                          style: TextStyle(color: Colors.blueGrey)),
                      const SizedBox(height: 10),
                    ],
                  ),
                // Add more fields if needed
              ]
            ],
          ),
        ),
      ),
    ):Container();
  }

  TableRow _buildTableRow(String leftLabel, String leftValue, String rightLabel,
      String rightValue) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leftLabel,
                  style:
                  TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                ),
                SizedBox(height: 2.0), // Space between label and value
                Text(
                  leftValue,
                  style: TextStyle(color: grey),
                ),
              ],
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rightLabel,
                  style:
                  TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                ),
                SizedBox(height: 2.0), // Space between label and value
                Text(
                  rightValue,
                  style: TextStyle(color: grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getDisplayValue(String? value) {
    // Return 'N/A' if the value is null or empty, otherwise return the value
    return (value == null || value.trim().isEmpty) ? 'N/A' : value;
  }
}