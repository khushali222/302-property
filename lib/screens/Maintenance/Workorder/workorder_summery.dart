import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/Model/tenants.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/repository/lease.dart';
import 'package:three_zero_two_property/repository/workorder.dart';
import 'package:three_zero_two_property/screens/Leasing/RentalRoll/newModel.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
// import 'package:three_zero_two_property/repository/properties_summery.dart';
import '../../../model/summery_workorder.dart';
import '../../../widgets/drawer_tiles.dart';
import '../../../widgets/titleBar.dart';
import '../../../widgets/custom_drawer.dart';

class Workorder_summery extends StatefulWidget {
  String? workorder_id;
  Workorder_summery({super.key, this.workorder_id});

  @override
  State<Workorder_summery> createState() => _Workorder_summeryState();
}

class _Workorder_summeryState extends State<Workorder_summery>
    with SingleTickerProviderStateMixin {
  List<String> applicantCheckedChecklist =
  [
    "CreditCheck",
    "EmploymentVerification",
    "ApplicationFee",
    "IncomeVerification",
    "LandlordVerification"
  ];

  List<String> applicantChecklist = [];
  final Map<String, String> displayNames = {
    "CreditCheck": "Credit and background check",
    "EmploymentVerification": "Employment verification",
    "ApplicationFee": "Application fee collected",
    "IncomeVerification": "Income verification",
    "LandlordVerification": "Landlord verification",
  };

  bool addcheckbox = false;
  TextEditingController startdateController = TextEditingController();
  TextEditingController enddateController = TextEditingController();
  TextEditingController checkvalue = TextEditingController();
  List formDataRecurringList = [];
  late Future<WorkOrderData_summery> futureworkorderSummary;
  String? _selectedValue;
  TabController? _tabController;
  List<String> items = ["Approved", "Rejected"];
  @override
  void initState() {
    print(widget.workorder_id);
    // TODO: implement initState
    futureworkorderSummary =
        WorkOrderRepository.getworkorderSummary(widget.workorder_id!);

    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    _loadStaff();
  }

  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  bool isChecked = false;
  //for Staffmember
  Map<String, String> staffs = {};
  String? _selectedstaffId;
  String? _selectedStaffs;
  bool _isLoadingstaff = false;

  Future<void> _loadStaff() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    setState(() {
      _isLoadingstaff = true;
    });
    try {
      final response = await http.get(
          Uri.parse('${Api_url}/api/staffmember/staff_member/$id'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
          });
      print('${Api_url}/api/staffmember/staff_member/$id');

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> staffnames = {};
        jsonResponse.forEach((data) {
          staffnames[data['staffmember_id'].toString()] =
              data['staffmember_name'].toString();
        });

        setState(() {
          staffs = staffnames;
          _isLoadingstaff = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoadingstaff = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch vendors: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: widget302.,
      key: key,
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Work Order",
        dropdown: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Material(
                  elevation: 3,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(5),
                  ),
                  child: Container(
                    height: 40,
                    width: 80,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(21, 43, 81, 1),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: const Center(
                        child: Text(
                      "Back",
                      style: TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.white),
                    )),
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          titleBar(
            width: MediaQuery.of(context).size.width * .91,
            title: 'Work Order Details',
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: FutureBuilder<WorkOrderData_summery>(
                  future: futureworkorderSummary,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SpinKitFadingCircle(
                          color: Colors.black,
                          size: 55.0,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return Center(child: Text('No data found.'));
                    } else {
                      // _selectedValue = snapshot.data!.applicantStatus!.last!.status;
                      return Column(
                        children: <Widget>[
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            height: 60,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color.fromRGBO(21, 43, 81, 1)),
                              // color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              dividerColor: Colors.transparent,
                              indicatorWeight: 5,
                              //indicatorPadding: EdgeInsets.symmetric(horizontal: 1),
                              indicatorColor:
                                  const Color.fromRGBO(21, 43, 81, 1),
                              labelColor: const Color.fromRGBO(21, 43, 81, 1),
                              unselectedLabelColor:
                                  const Color.fromRGBO(21, 43, 81, 1),
                              tabs: [
                                const Tab(text: 'Summary'),
                                const Tab(
                                  text: 'Application',
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                Summery_page(snapshot.data!),
                                Task(snapshot.data!),
                                // Summery_page(snapshot.data!),
                                // Summery_page(snapshot.data!),
                                /*  SummaryPage(),
                                FinancialTable(
                                    leaseId: widget.leaseId,
                                    status:
                                    '${determineStatus(snapshot.data!.data!.startDate, snapshot.data!.data!.endDate).toString()}'),
                                Tenant(context),*/
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Summery_page(WorkOrderData_summery summery) {
    double grandTotal = 0;
    // applicantChecklist = List<String>.from(summery.applicantCheckedChecklist!);
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * .48,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromRGBO(21, 43, 81, 1)),
                        // color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: blueColor,
                                  border: Border.all(
                                      color:
                                          const Color.fromRGBO(21, 43, 81, 1)),
                                  // color: Colors.blue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.menu,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      child: Text(
                                    '${summery.workSubject}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  )),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                      child: Text(
                                    '${summery.propertyData?.rentaladress}',
                                    style: TextStyle(color: blueColor),
                                  )),
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      child: Text(
                                    'Description',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  )),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Container(
                                      child: Text(
                                    '${summery.workPerformed}',
                                    style: TextStyle(color: blueColor),
                                  )),
                                ],
                              ),
                              Spacer(),
                              Container(
                                height: 70,
                                width: MediaQuery.of(context).size.width * .2,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Column(
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  // mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Status",
                                      style: TextStyle(
                                        color: blueColor,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Text('${summery.status}',
                                        style: TextStyle(
                                            color: blueColor,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      child: Text(
                                    'Permission to enter',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  )),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Container(
                                      child: Text(
                                    '${summery.entryAllowed}',
                                    style: TextStyle(color: blueColor),
                                  )),
                                ],
                              ),
                              Spacer(),
                              Container(
                                height: 70,
                                width: MediaQuery.of(context).size.width * .2,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Column(
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  // mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Due Date",
                                      style: TextStyle(
                                        color: blueColor,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                        '${summery.workorderUpdates?.last.date ?? "N/A"} ',
                                        style: TextStyle(
                                            color: blueColor,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      child: Text(
                                    'Vendors Notes',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  )),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Container(
                                      child: Text(
                                    '${summery.vendorNotes}',
                                    style: TextStyle(color: blueColor),
                                  )),
                                ],
                              ),
                              Spacer(),
                              Container(
                                height: 70,
                                width: MediaQuery.of(context).size.width * .2,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Column(
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  // mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Assignees",
                                      style: TextStyle(
                                        color: blueColor,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    summery.staffData != null
                                        ? Text(
                                            '${summery.staffData?.firstname}',
                                            style: TextStyle(
                                                color: blueColor,
                                                fontWeight: FontWeight.bold))
                                        : Text('N/A',
                                            style: TextStyle(
                                                color: blueColor,
                                                fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * .45,
                      child: Column(
                        children: [
                          if (summery.tenantData != null)
                            SizedBox(
                              height: 220,
                              child: Material(
                                borderOnForeground: true,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 220,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        flex: 2, // 40%
                                        child: Container(
                                          decoration: BoxDecoration(
                                            // color: Colors.blue,
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(10),
                                            ),
                                            /*   boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: Offset(0, 3), // changes position of shadow
                                ),
                              ],*/
                                          ),
                                          child: Material(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(10),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'Contacts',
                                                style: TextStyle(
                                                    color: blueColor,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 7, // 60%
                                        child: Column(
                                          children: [
                                            Container(
                                                decoration: BoxDecoration(
                                                  //  color: Colors.green,
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                    bottom: Radius.circular(10),
                                                  ),
                                                ),
                                                child: ListTile(
                                                  title: Text(
                                                    "Vendor",
                                                    style: TextStyle(
                                                        color: blueColor,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  subtitle: summery
                                                              .vendorData !=
                                                          null
                                                      ? Text(
                                                          summery.vendorData!
                                                                  .companyName ??
                                                              "N/A",
                                                          style: TextStyle(
                                                              color: blueColor),
                                                        )
                                                      : Text(
                                                          "N/A",
                                                          style: TextStyle(
                                                              color: blueColor),
                                                        ),
                                                  leading: Container(
                                                    padding:
                                                        EdgeInsets.only(top: 3),
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 30,
                                                    ),
                                                  ),
                                                )),
                                            Divider(
                                              thickness: 3,
                                            ),
                                            Container(
                                                decoration: BoxDecoration(
                                                  //  color: Colors.green,
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                    bottom: Radius.circular(10),
                                                  ),
                                                ),
                                                child: ListTile(
                                                  title: Text(
                                                    "Tenant",
                                                    style: TextStyle(
                                                        color: blueColor,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  subtitle: summery
                                                              .tenantData !=
                                                          null
                                                      ? Text(
                                                          "${summery.tenantData!.firstname ?? "N/A"} ${summery.tenantData!.lastname ?? "N/A"}",
                                                          style: TextStyle(
                                                              color: blueColor),
                                                        )
                                                      : Text(
                                                          "N/A",
                                                          style: TextStyle(
                                                              color: blueColor),
                                                        ),
                                                  leading: Container(
                                                    padding:
                                                        EdgeInsets.only(top: 3),
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 30,
                                                    ),
                                                  ),
                                                )),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (summery.tenantData == null)
                            SizedBox(
                              height: 120,
                              child: Material(
                                borderOnForeground: true,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        flex: 3, // 40%
                                        child: Container(
                                          decoration: BoxDecoration(
                                            // color: Colors.blue,
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(10),
                                            ),
                                            /*   boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: Offset(0, 3), // changes position of shadow
                                ),
                              ],*/
                                          ),
                                          child: Material(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(10),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'Contacts',
                                                style: TextStyle(
                                                    color: blueColor,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Divider(
                                        color: blueColor,
                                      ),
                                      Expanded(
                                        flex: 7, // 60%
                                        child: Container(
                                            decoration: BoxDecoration(
                                              //  color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                bottom: Radius.circular(10),
                                              ),
                                            ),
                                            child: ListTile(
                                              title: Text(
                                                "Vendor",
                                                style: TextStyle(
                                                    color: blueColor,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              subtitle:
                                                  summery.vendorData != null
                                                      ? Text(
                                                          summery.vendorData!
                                                                  .companyName ??
                                                              "N/A",
                                                          style: TextStyle(
                                                              color: blueColor),
                                                        )
                                                      : Text(
                                                          "N/A",
                                                          style: TextStyle(
                                                              color: blueColor),
                                                        ),
                                              leading: Container(
                                                padding:
                                                    EdgeInsets.only(top: 3),
                                                child: Icon(
                                                  Icons.person,
                                                  size: 30,
                                                ),
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(
                            height: 10,
                          ),
                          Material(
                            borderOnForeground: true,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(10),
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(10),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Property',
                                            style: TextStyle(
                                              color: blueColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    color: blueColor,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      if (summery.propertyData!.rental_image !=
                                          null)
                                        Column(
                                          children: [
                                            SizedBox(
                                              height: 10,
                                            ),
                                            CachedNetworkImage(
                                              imageUrl:
                                                  "$image_url${summery.propertyData!.rental_image}",
                                              placeholder: (context, url) => Text(
                                                  "${summery.propertyData!.rental_image}"),
                                              errorWidget:
                                                  (context, url, error) => Icon(
                                                      Icons.error,
                                                      color: blueColor),
                                              /*  imageBuilder: (context, imageProvider) => Container(
                                      width: 40.0,
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),*/
                                            ),
                                          ],
                                        ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "${summery.propertyData!.rentaladress} (${summery.unitData!.unitName})",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: blueColor),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "${summery.propertyData!.rental_city}, ",
                                            style: TextStyle(color: blueColor),
                                          ),
                                          Text(
                                            "${summery.propertyData!.rental_state}, ",
                                            style: TextStyle(color: blueColor),
                                          ),
                                          Text(
                                            "${summery.propertyData!.rental_country}, ",
                                            style: TextStyle(color: blueColor),
                                          ),
                                          Text(
                                            "${summery.propertyData!.rental_postcode} ",
                                            style: TextStyle(color: blueColor),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  )
                                  /*  ListTile(
                            title: Text(
                              "Vendor",
                              style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              "Vendor Company Name",
                              style: TextStyle(color: blueColor),
                            ),
                            leading: Container(
                              padding: EdgeInsets.only(top: 3),
                              child: Icon(
                                Icons.person,
                                size: 30,
                              ),
                            )

                          ),*/
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                if (summery.partsandchargeData!.length > 0)
                  IntrinsicHeight(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: blueColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      // padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Parts and Labor',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: blueColor,
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          /*Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Column(
                                      children: summery.partsandchargeData!.map((part) {
                                        int partTotal =
                                        (part.partsPrice! * part.partsQuantity!);
                                        print(partTotal);
                                        grandTotal += partTotal;
                                        print(grandTotal);
                                        return PartWidget(part: part, total: 0.0);
                                      }).toList(),
                                    ),
                                    */ /*  Column(
                                  children: summery.partsandchargeData!.map((part) {
                                    int partTotal = (part.partsPrice! * part.partsQuantity!);
                                    print(partTotal);
                                    grandTotal += partTotal;
                                    print(grandTotal);
                                    return PartWidget(part: part, total:0.0);
                                  }).toList(),
                                ),*/ /*
                                    // Divider(color: Colors.grey),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        Text(
                                          '\$${grandTotal.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),*/
                          Table(
                            border: TableBorder.all(width: 1),
                            columnWidths: const {
                              0: FlexColumnWidth(1),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(2),
                              3: FlexColumnWidth(2),
                              4: FlexColumnWidth(2),
                            },
                            children: [
                              const TableRow(children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('QTY',
                                      style: TextStyle(
                                          color: Color.fromRGBO(21, 43, 83, 1),
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Account',
                                      style: TextStyle(
                                          color: Color.fromRGBO(21, 43, 83, 1),
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Description',
                                      style: TextStyle(
                                          color: Color.fromRGBO(21, 43, 83, 1),
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Price',
                                      style: TextStyle(
                                          color: Color.fromRGBO(21, 43, 83, 1),
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Amount',
                                      style: TextStyle(
                                          color: Color.fromRGBO(21, 43, 83, 1),
                                          fontWeight: FontWeight.bold)),
                                ),
                              ]),
                              ...summery.partsandchargeData!
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                int index = entry.key;
                                PartsandchargeData row = entry.value;
                                grandTotal +=
                                    (row.partsQuantity! * row.partsPrice!);
                                return TableRow(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("${row.partsQuantity}"),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("${row.account}"),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("${row.description}"),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("\$${row.partsPrice}"),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        "\$${(row.partsPrice! * row.partsQuantity!)}"),
                                  ),
                                ]);
                              }).toList(),
                              TableRow(children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Total',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("\$${grandTotal.toString()}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ]),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromRGBO(21, 43, 81, 1)),
                      // color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Text("Updates",
                                style: TextStyle(
                                    color: blueColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(
                              width: 20,
                            ),
                            InkWell(
                              onTap: () {
                                showUpdateDialog(context);
                              },
                              child: Material(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                child: Container(
                                  height: 30,
                                  width: 80,
                                  child: Center(child: Text("Update")),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: summery.workorderUpdates!.map((entry) {
                            final update = entry;
                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    '${update.statusUpdatedBy ?? ""} updated this work order (${update.date ?? "N/A"})',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  Divider(color: Colors.black),
                                  Text(
                                    'Work Order Is Updated',
                                    style: TextStyle(color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    )),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        );
      } else {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color.fromRGBO(21, 43, 81, 1)),
                    // color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: blueColor,
                              border: Border.all(
                                  color: const Color.fromRGBO(21, 43, 81, 1)),
                              // color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.menu,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  width: MediaQuery.of(context).size.width * .6,
                                  child: Text(
                                '${summery.workSubject}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: blueColor),
                              )),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                  child: Text(
                                '${summery.propertyData?.rentaladress}',
                                style: TextStyle(color: blueColor),
                              )),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(

                                  child: Text(
                                'Description',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: blueColor),
                              )),
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                  width: 180,
                                  child: Text(
                                '${summery.workPerformed}',
                                style: TextStyle(color: blueColor),
                              )),
                            ],
                          ),
                          Spacer(),
                          Container(
                            height: 70,
                            width: MediaQuery.of(context).size.width * .3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Column(
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              // mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Status",
                                  style: TextStyle(
                                    color: blueColor,
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text('${summery.status}',
                                    style: TextStyle(
                                        color: blueColor,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  child: Text(
                                'Permission to enter',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: blueColor),
                              )),
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                  child: Text(
                                '${summery.entryAllowed}',
                                style: TextStyle(color: blueColor),
                              )),
                            ],
                          ),
                          Spacer(),
                          Container(
                            height: 70,
                            width: MediaQuery.of(context).size.width * .3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Column(
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              // mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Due Date",
                                  style: TextStyle(
                                    color: blueColor,
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                    '${summery.workorderUpdates?.last.date ?? "N/A"} ',
                                    style: TextStyle(
                                        color: blueColor,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  child: Text(
                                'Vendors Notes',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: blueColor),
                              )),
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                  child: Text(
                                '${summery.vendorNotes}',
                                style: TextStyle(color: blueColor),
                              )),
                            ],
                          ),
                          Spacer(),
                          Container(
                            height: 70,
                            width: MediaQuery.of(context).size.width * .3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Column(
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              // mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Assignees",
                                  style: TextStyle(
                                    color: blueColor,
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                summery.staffData != null
                                    ? Text('${summery.staffData?.firstname}',
                                        style: TextStyle(
                                            color: blueColor,
                                            fontWeight: FontWeight.bold))
                                    : Text('N/A',
                                        style: TextStyle(
                                            color: blueColor,
                                            fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                if (summery.partsandchargeData!.length > 0)
                  IntrinsicHeight(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: blueColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      // padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Parts and Labor',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: blueColor,
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Column(
                                  children:
                                      summery.partsandchargeData!.map((part) {
                                    int partTotal = (part.partsPrice! *
                                        part.partsQuantity!);
                                    print(partTotal);
                                    grandTotal += partTotal;
                                    print(grandTotal);
                                    return PartWidget(part: part, total: 0.0);
                                  }).toList(),
                                ),
                                /*  Column(
                                  children: summery.partsandchargeData!.map((part) {
                                    int partTotal = (part.partsPrice! * part.partsQuantity!);
                                    print(partTotal);
                                    grandTotal += partTotal;
                                    print(grandTotal);
                                    return PartWidget(part: part, total:0.0);
                                  }).toList(),
                                ),*/
                                // Divider(color: Colors.grey),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      '\$${grandTotal.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
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
                  ),
                Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromRGBO(21, 43, 81, 1)),
                      // color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Text("Updates",
                                style: TextStyle(
                                    color: blueColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(
                              width: 20,
                            ),
                            InkWell(
                              onTap: () {
                                showUpdateDialog(context);
                              },
                              child: Material(
                                elevation: 1,
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                child: Container(
                                  height: 30,
                                  width: 80,
                                  child: Center(child: Text("Update")),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: summery.workorderUpdates!.map((entry) {
                            final update = entry;
                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    '${update.statusUpdatedBy ?? ""} updated this work order (${update.date ?? "N/A"})',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  Divider(color: Colors.black),
                                  Text(
                                    'Work Order Is Updated',
                                    style: TextStyle(color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    )),
                SizedBox(
                  height: 10,
                ),
                Material(
                  borderOnForeground: true,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(10),
                            ),
                          ),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(10),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Billing Information',
                                  style: TextStyle(
                                    color: blueColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          color: blueColor,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                SizedBox(
                                  width: 24.0, // Standard width for checkbox
                                  height: 24.0,
                                  child: Checkbox(
                                    value: summery.isBillable == true
                                        ? true
                                        : false,
                                    onChanged: (value) {
                                      setState(() {
                                        isChecked = value ?? false;
                                      });
                                    },
                                    activeColor: isChecked
                                        ? Colors.black
                                        : Color.fromRGBO(21, 43, 81, 1),
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  "Billable To Tenants",
                                  style: TextStyle(
                                    color: greyColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                if (summery.tenantData != null)
                  SizedBox(
                    height: 220,
                    child: Material(
                      borderOnForeground: true,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 220,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                // color: Colors.blue,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10),
                                ),
                                /*   boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                                                        ],*/
                              ),
                              child: Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'Contactses',
                                    style: TextStyle(
                                        color: blueColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                              color: blueColor,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        //  color: Colors.green,
                                        borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(10),
                                        ),
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          "Vendor",
                                          style: TextStyle(
                                              color: blueColor,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        subtitle: summery.vendorData != null
                                            ? Text(
                                                summery.vendorData!
                                                        .companyName ??
                                                    "N/A",
                                                style:
                                                    TextStyle(color: blueColor),
                                              )
                                            : Text(
                                                "N/A",
                                                style:
                                                    TextStyle(color: blueColor),
                                              ),
                                        leading: Container(
                                          padding: EdgeInsets.only(top: 3),
                                          child: Icon(
                                            Icons.person,
                                            size: 30,
                                          ),
                                        ),
                                      )),
                                  Divider(
                                    thickness: 3,
                                  ),
                                  Container(
                                      decoration: BoxDecoration(
                                        //  color: Colors.green,
                                        borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(10),
                                        ),
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          "Tenant",
                                          style: TextStyle(
                                              color: blueColor,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        subtitle: summery.tenantData != null
                                            ? Text(
                                                "${summery.tenantData!.firstname ?? "N/A"} ${summery.tenantData!.lastname ?? "N/A"}",
                                                style:
                                                    TextStyle(color: blueColor),
                                              )
                                            : Text(
                                                "N/A",
                                                style:
                                                    TextStyle(color: blueColor),
                                              ),
                                        leading: Container(
                                          padding: EdgeInsets.only(top: 3),
                                          child: Icon(
                                            Icons.person,
                                            size: 30,
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (summery.tenantData == null)
                  SizedBox(
                    height: 140,
                    child: Material(
                      borderOnForeground: true,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 3, // 40%
                              child: Container(
                                decoration: BoxDecoration(
                                  // color: Colors.blue,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                  /*   boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ],*/
                                ),
                                child: Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Contacts',
                                      style: TextStyle(
                                          color: blueColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                              color: blueColor,
                            ),
                            Expanded(
                              flex: 6, // 60%
                              child: Container(
                                  decoration: BoxDecoration(
                                    //  color: Colors.green,
                                    borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(10),
                                    ),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      "Vendor",
                                      style: TextStyle(
                                          color: blueColor,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: summery.vendorData != null
                                        ? Text(
                                            summery.vendorData!.companyName ??
                                                "N/A",
                                            style: TextStyle(color: blueColor),
                                          )
                                        : Text(
                                            "N/A",
                                            style: TextStyle(color: blueColor),
                                          ),
                                    leading: Container(
                                      padding: EdgeInsets.only(top: 3),
                                      child: Icon(
                                        Icons.person,
                                        size: 30,
                                      ),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                SizedBox(
                  height: 10,
                ),
                Material(
                  borderOnForeground: true,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(10),
                            ),
                          ),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(10),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Property',
                                  style: TextStyle(
                                    color: blueColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          color: blueColor,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (summery.propertyData!.rental_image != null)
                              Column(
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  CachedNetworkImage(
                                    imageUrl:
                                        "$image_url${summery.propertyData!.rental_image}",
                                    placeholder: (context, url) => Text(
                                        "${summery.propertyData!.rental_image}"),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.error,
                                      color: blueColor,
                                    ),
                                    /*  imageBuilder: (context, imageProvider) => Container(
                                    width: 40.0,
                                    height: 40.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),*/
                                  ),
                                ],
                              ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "${summery.propertyData!.rentaladress} ",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: blueColor),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${summery.propertyData!.rental_city}, ",
                                  style: TextStyle(color: blueColor),
                                ),
                                Text(
                                  "${summery.propertyData!.rental_state}, ",
                                  style: TextStyle(color: blueColor),
                                ),
                                Text(
                                  "${summery.propertyData!.rental_country}, ",
                                  style: TextStyle(color: blueColor),
                                ),
                                Text(
                                  "${summery.propertyData!.rental_postcode} ",
                                  style: TextStyle(color: blueColor),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        )
                        /*  ListTile(
                          title: Text(
                            "Vendor",
                            style: TextStyle(
                              color: blueColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            "Vendor Company Name",
                            style: TextStyle(color: blueColor),
                          ),
                          leading: Container(
                            padding: EdgeInsets.only(top: 3),
                            child: Icon(
                              Icons.person,
                              size: 30,
                            ),
                          )

                        ),*/
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        );
      }
    });
  }

  Task(WorkOrderData_summery summery) {
    print(summery.workOrderImages);
    double grandTotal = 0;
    // applicantChecklist = List<String>.from(summery.applicantCheckedChecklist!);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 500) {
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * .5,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromRGBO(21, 43, 81, 1)),
                        // color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: blueColor,
                                  border: Border.all(
                                      color:
                                          const Color.fromRGBO(21, 43, 81, 1)),
                                  // color: Colors.blue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.menu,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      width: 150,
                                      child: Text(
                                        '${summery.workSubject}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: blueColor),
                                      )),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                      child: Text(
                                    '${summery.propertyData?.rentaladress}',
                                    style: TextStyle(color: blueColor),
                                  )),
                                ],
                              ),
                              Spacer(),
                              if (summery.priority == "High")
                                Container(
                                  height: 35,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: Colors.red, width: 3),
                                  ),
                                  child: Center(
                                      child: Text("High",
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w400))),
                                ),
                              if (summery.priority == "Medium")
                                Container(
                                  height: 35,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: blueColor, width: 3),
                                  ),
                                  child: Center(
                                      child: Text("Medium",
                                          style: TextStyle(
                                              color: blueColor,
                                              fontWeight: FontWeight.w400))),
                                ),
                              if (summery.priority == "Normal")
                                Container(
                                  height: 35,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.grey, width: 3),
                                  ),
                                  child: Center(
                                      child: Text("Normal",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w400))),
                                )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      child: Text(
                                    'Description',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  )),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Container(
                                      child: Text(
                                    '${summery.workPerformed}',
                                    style: TextStyle(color: blueColor),
                                  )),
                                ],
                              ),
                              Spacer(),
                              Container(
                                height: 70,
                                width: MediaQuery.of(context).size.width * .2,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Column(
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  // mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Status",
                                      style: TextStyle(
                                        color: blueColor,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Text('${summery.status}',
                                        style: TextStyle(
                                            color: blueColor,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      child: Text(
                                    'Permission to enter',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  )),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Container(
                                      child: Text(
                                    '${summery.entryAllowed}',
                                    style: TextStyle(color: blueColor),
                                  )),
                                ],
                              ),
                              Spacer(),
                              Container(
                                height: 70,
                                width: MediaQuery.of(context).size.width * .2,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Column(
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  // mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Due Date",
                                      style: TextStyle(
                                        color: blueColor,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                        '${summery.workorderUpdates?.last.date ?? "N/A"}',
                                        style: TextStyle(
                                            color: blueColor,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      child: Text(
                                    'Vendors Notes',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  )),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Container(
                                      child: Text(
                                    '${summery.vendorNotes}',
                                    style: TextStyle(color: blueColor),
                                  )),
                                ],
                              ),
                              Spacer(),
                              Container(
                                height: 70,
                                width: MediaQuery.of(context).size.width * .2,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Column(
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  // mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Assignees",
                                      style: TextStyle(
                                        color: blueColor,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    summery.staffData != null
                                        ? Text(
                                            '${summery.staffData?.firstname}',
                                            style: TextStyle(
                                                color: blueColor,
                                                fontWeight: FontWeight.bold))
                                        : Text('N/A',
                                            style: TextStyle(
                                                color: blueColor,
                                                fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Material(
                      borderOnForeground: true,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.43,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10),
                                ),
                              ),
                              child: Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Images',
                                      style: TextStyle(
                                        color: blueColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                              color: blueColor,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (summery.workorderUpdates != null)
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Wrap(
                                        spacing: 10,
                                        runSpacing: 10,
                                        children: summery.workOrderImages!
                                            .map((imageUrl) {
                                          return Container(
                                            width:
                                                summery.workOrderImages!
                                                            .length ==
                                                        1
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        3
                                                    : (MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            3) -
                                                        10,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: CachedNetworkImage(
                                                imageUrl: "$image_url$imageUrl",
                                                placeholder: (context, url) =>
                                                    Center(
                                                        child:
                                                            CircularProgressIndicator()),
                                                errorWidget:
                                                    (context, url, error) {
                                                  print(error);
                                                  return Container();
                                                },
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                if (summery.workOrderImages!.length == 0)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "No Images Provided",
                                        style: TextStyle(color: blueColor),
                                      ),
                                      // Text("(${summery.unitData!.unitName})"),
                                    ],
                                  ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "${summery.propertyData!.rentaladress} (${summery.unitData!.unitName})",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: blueColor),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${summery.propertyData!.rental_city}, ",
                                      style: TextStyle(color: blueColor),
                                    ),
                                    Text(
                                      "${summery.propertyData!.rental_state}, ",
                                      style: TextStyle(color: blueColor),
                                    ),
                                    Text(
                                      "${summery.propertyData!.rental_country}, ",
                                      style: TextStyle(color: blueColor),
                                    ),
                                    Text(
                                      "${summery.propertyData!.rental_postcode} ",
                                      style: TextStyle(color: blueColor),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            )
                            /*  ListTile(
                              title: Text(
                                "Vendor",
                                style: TextStyle(
                                  color: blueColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                "Vendor Company Name",
                                style: TextStyle(color: blueColor),
                              ),
                              leading: Container(
                                padding: EdgeInsets.only(top: 3),
                                child: Icon(
                                  Icons.person,
                                  size: 30,
                                ),
                              )

                            ),*/
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ],
            ),
          );
        } else {
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color.fromRGBO(21, 43, 81, 1)),
                    // color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: blueColor,
                              border: Border.all(
                                  color: const Color.fromRGBO(21, 43, 81, 1)),
                              // color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.menu,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  width: 150,
                                  child: Text(
                                    '${summery.workSubject}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  )),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                  child: Text(
                                '${summery.propertyData?.rentaladress}',
                                style: TextStyle(color: blueColor),
                              )),
                            ],
                          ),
                          Spacer(),
                          if (summery.priority == "High")
                            Container(
                              height: 35,
                              width: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.red, width: 3),
                              ),
                              child: Center(
                                  child: Text("High",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w400))),
                            ),
                          if (summery.priority == "Medium")
                            Container(
                              height: 35,
                              width: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: blueColor, width: 3),
                              ),
                              child: Center(
                                  child: Text("Medium",
                                      style: TextStyle(
                                          color: blueColor,
                                          fontWeight: FontWeight.w400))),
                            ),
                          if (summery.priority == "Normal")
                            Container(
                              height: 35,
                              width: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.grey, width: 3),
                              ),
                              child: Center(
                                  child: Text("Normal",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w400))),
                            )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  child: Text(
                                'Description',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: blueColor),
                              )),
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                  width: 180,
                                  child: Text(
                                '${summery.workPerformed}',
                                style: TextStyle(color: blueColor),
                              )),
                            ],
                          ),
                          Spacer(),
                          Container(
                            height: 70,
                            width: MediaQuery.of(context).size.width * .3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Column(
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              // mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Status",
                                  style: TextStyle(
                                    color: blueColor,
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text('${summery.status}',
                                    style: TextStyle(
                                        color: blueColor,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  child: Text(
                                'Permission to enter',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: blueColor),
                              )),
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                  child: Text(
                                '${summery.entryAllowed}',
                                style: TextStyle(color: blueColor),
                              )),
                            ],
                          ),
                          Spacer(),
                          Container(
                            height: 70,
                            width: MediaQuery.of(context).size.width * .3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Column(
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              // mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Due Date",
                                  style: TextStyle(
                                    color: blueColor,
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                    '${summery.workorderUpdates?.last.date ?? "N/A"}',
                                    style: TextStyle(
                                        color: blueColor,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  child: Text(
                                'Vendors Notes',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: blueColor),
                              )),
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                  child: Text(
                                '${summery.vendorNotes}',
                                style: TextStyle(color: blueColor),
                              )),
                            ],
                          ),
                          Spacer(),
                          Container(
                            height: 70,
                            width: MediaQuery.of(context).size.width * .3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Column(
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              // mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Assignees",
                                  style: TextStyle(
                                    color: blueColor,
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                summery.staffData != null
                                    ? Text('${summery.staffData?.firstname}',
                                        style: TextStyle(
                                            color: blueColor,
                                            fontWeight: FontWeight.bold))
                                    : Text('N/A',
                                        style: TextStyle(
                                            color: blueColor,
                                            fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                IntrinsicHeight(
                  child: Material(
                    borderOnForeground: true,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                            ),
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Images',
                                    style: TextStyle(
                                      color: blueColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Divider(
                            color: blueColor,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (summery.workorderUpdates != null)
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: summery.workOrderImages!
                                          .map((imageUrl) {
                                        return Container(
                                          width:
                                              summery.workOrderImages!
                                                          .length ==
                                                      1
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3
                                                  : (MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          3) -
                                                      10,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: CachedNetworkImage(
                                              imageUrl: "$image_url$imageUrl",
                                              placeholder: (context, url) => Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                              errorWidget:
                                                  (context, url, error) {
                                                print(error);
                                                return Container();
                                              },
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              if (summery.workOrderImages!.length == 0)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "No Images Provided",
                                      style: TextStyle(color: blueColor),
                                    ),
                                    // Text("(${summery.unitData!.unitName})"),
                                  ],
                                ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "${summery.propertyData!.rentaladress} ",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: blueColor),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${summery.propertyData!.rental_city}, ",
                                    style: TextStyle(color: blueColor),
                                  ),
                                  Text(
                                    "${summery.propertyData!.rental_state}, ",
                                    style: TextStyle(color: blueColor),
                                  ),
                                  Text(
                                    "${summery.propertyData!.rental_country}, ",
                                    style: TextStyle(color: blueColor),
                                  ),
                                  Text(
                                    "${summery.propertyData!.rental_postcode} ",
                                    style: TextStyle(color: blueColor),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          )
                          /*  ListTile(
                            title: Text(
                              "Vendor",
                              style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              "Vendor Company Name",
                              style: TextStyle(color: blueColor),
                            ),
                            leading: Container(
                              padding: EdgeInsets.only(top: 3),
                              child: Icon(
                                Icons.person,
                                size: 30,
                              ),
                            )

                          ),*/
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          );
        }
      }),
    );
  }

  void showUpdateDialog(BuildContext context) {
    // Initialize variables to store user input
    String? selectedStatus;
    //  DateTime? selectedDate;
    //String? message;
    TextEditingController message = TextEditingController();
    TextEditingController selectedDate = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Update Work Order',
            style: TextStyle(color: blueColor),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Status', style: TextStyle(color: blueColor)),
                DropdownButtonHideUnderline(
                  child: DropdownButtonFormField2<String>(
                    decoration: InputDecoration(border: InputBorder.none),
                    isExpanded: true,
                    hint: const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Select Status',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFb0b6c3),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    items: ['New', 'In Progress', 'On Hold', 'Completed']
                        .map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(
                          status,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    value: selectedStatus,
                    onChanged: (value) {
                      selectedStatus = value;
                    },
                    buttonStyleData: ButtonStyleData(
                      height: 45,
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 14, right: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.white,
                      ),
                      elevation: 2,
                    ),
                    iconStyleData: const IconStyleData(
                      icon: Icon(Icons.arrow_drop_down),
                      iconSize: 24,
                      iconEnabledColor: Color(0xFFb0b6c3),
                      iconDisabledColor: Colors.grey,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.white,
                      ),
                      scrollbarTheme: ScrollbarThemeData(
                        radius: const Radius.circular(6),
                        thickness: MaterialStateProperty.all(6),
                        thumbVisibility: MaterialStateProperty.all(true),
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                      padding: EdgeInsets.only(left: 14, right: 14),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an option';
                      }
                      return null;
                    },
                  ),
                ),
                Text('Due Date', style: TextStyle(color: blueColor)),
                SizedBox(height: 8.0),
                Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    height: 45,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextFormField(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                          helpText: "Due Date",
                          locale: const Locale('en', 'US'),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color.fromRGBO(
                                      21, 43, 83, 1), // header background color
                                  onPrimary: Colors.white, // header text color
                                  onSurface: Color.fromRGBO(
                                      21, 43, 83, 1), // body text color
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color.fromRGBO(
                                        21, 43, 83, 1), // button text color
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (pickedDate != null) {
                          String formattedDate =
                              "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                          setState(() {
                            selectedDate.text = formattedDate;
                          });
                        }
                      },
                      //  obscureText: widget.obscureText,
                      readOnly: true,
                      controller: selectedDate,
                      decoration: InputDecoration(
                        suffixIcon:
                            Icon(Icons.calendar_today, color: blueColor),
                        // hintStyle:
                        // TextStyle(fontSize: 13, color: blueColor),
                        border: InputBorder.none,
                        hintText: "dd-mm-yyyy",
                      ),
                    ),
                  ),
                ),
                /* ElevatedButton(
                  onPressed: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      selectedDate = pickedDate;
                    }
                  },
                  child: Text(selectedDate == null
                      ? 'Select Date'
                      : '${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}'),
                ),*/
                SizedBox(height: 16.0),
                _isLoadingstaff
                    ? const Center(
                        child: SpinKitFadingCircle(
                          color: Colors.black,
                          size: 50.0,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonHideUnderline(
                            child: DropdownButtonFormField2<String>(
                              decoration:
                                  InputDecoration(border: InputBorder.none),
                              isExpanded: true,
                              hint: const Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Select here',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFFb0b6c3),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              items: staffs.keys.map((staffmember_id) {
                                return DropdownMenuItem<String>(
                                  value: staffmember_id,
                                  child: Text(
                                    staffs[staffmember_id]!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              value: _selectedstaffId,
                              onChanged: (value) {
                                setState(() {
                                  // _selectedUnitId = null;
                                  _selectedstaffId = value;
                                  _selectedStaffs = staffs[
                                      value]; // Store selected rental_adress

                                  //StaffId = value.toString();
                                  print('Selected Staffs: $_selectedStaffs');
                                  // Fetch units for the selected property
                                });
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 45,
                                width: 160,
                                padding:
                                    const EdgeInsets.only(left: 14, right: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.white,
                                ),
                                elevation: 2,
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                ),
                                iconSize: 24,
                                iconEnabledColor: Color(0xFFb0b6c3),
                                iconDisabledColor: Colors.grey,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.white,
                                ),
                                scrollbarTheme: ScrollbarThemeData(
                                  radius: const Radius.circular(6),
                                  thickness: MaterialStateProperty.all(6),
                                  thumbVisibility:
                                      MaterialStateProperty.all(true),
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                                padding: EdgeInsets.only(left: 14, right: 14),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select an option';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                SizedBox(height: 16.0),
                Text('Message', style: TextStyle(color: blueColor)),
                Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    height: 50,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      //border: Border.all(color: blueColor),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black.withOpacity(0.2),
                      //     offset: Offset(4, 4),
                      //     blurRadius: 3,
                      //   ),
                      // ],
                    ),
                    child: TextFormField(
                      /*    onTap: ()async{
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          selectedDate = pickedDate;
                        }
                      },*/
                      //  obscureText: widget.obscureText,
                      // readOnly: true,
                      //keyboardType: widget.keyboardType,
                      /* validator: (value) {
                        if (value == null || value.isEmpty) {
                          state.validate();
                        }
                        return null;
                      },*/
                      controller: message,

                      decoration: InputDecoration(
                        //  suffixIcon: widget.suffixIcon,
                        hintStyle: TextStyle(fontSize: 13, color: blueColor),
                        border: InputBorder.none,
                        //   hintText: widget.hintText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: blueColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: blueColor),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? firstName = prefs.getString("first_name");
                String? lastName = prefs.getString("last_name");
                Map<String, dynamic> values = {
                  "date": selectedDate.text,
                  "message": message.text,
                  "status": selectedStatus,
                  "statusUpdatedBy": "Admin",
                  "staffmember_name": _selectedStaffs,
                  "staffmember_id": _selectedstaffId
                };
                await WorkOrderRepository.updateworkorderSummary(
                        values, widget.workorder_id!)
                    .then((value) {
                  setState(() {
                    futureworkorderSummary =
                        WorkOrderRepository.getworkorderSummary(
                            widget.workorder_id!);
                  });
                });

                // Save the data and close the dialog
                /*  WorkorderUpdates update = WorkorderUpdates(
                  status: selectedStatus,
                  date: selectedDate,
                  message: message,
                );*/
                // Here you can handle saving the update data
                // print('Status: ${update.status}');
                // print('Date: ${update.date}');
                // print('Message: ${update.message}');
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class PartWidget extends StatelessWidget {
  final PartsandchargeData part;
  final double total;

  PartWidget({required this.part, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            part.account!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${part.partsPrice} x ${part.partsQuantity}',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              Text(
                '\$${(part.partsPrice! * part.partsQuantity!).toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(
            "${part.description}",
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Divider(color: Colors.grey),
          /* Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '\$${(part.partsPrice! * part.partsQuantity!).toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),*/
        ],
      ),
    );
  }
}
