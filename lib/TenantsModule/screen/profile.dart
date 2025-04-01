import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/Model/profile.dart';

import '../../constant/constant.dart';
import '../../provider/dateProvider.dart';
import '../../repository/profile_repository.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/drawer_tiles.dart';
import '../../widgets/titleBar.dart';
import '../widgets/appbar.dart';

class Profile_screen extends StatefulWidget {
  const Profile_screen({Key? key}) : super(key: key);

  @override
  State<Profile_screen> createState() => _Profile_screenState();
}

class _Profile_screenState extends State<Profile_screen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  profile? _profile;
  Map<String, dynamic> profiledata = {};
  ConnectivityResult? _connectivityResult;
  List<dynamic> leaseData = [];
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
    _fetchProfile();
  }

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
  }

  Future<void> fetchProfile() async {
    setState(() {
      _isLoading = true;
    });
    //  String? token = prefs.getString('token');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final String apiUrl = "${Api_url}/api/tenant/tenant_profile/$id";
    final response = await http.get(
      Uri.parse('$apiUrl'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    print('hello$apiUrl');
    print(response.body);
    final response_Data = jsonDecode(response.body);
    if (response_Data["statusCode"] == 200) {
      print("hello");
      setState(() {
        profiledata = response_Data["data"];
        leaseData = response_Data["data"]["leaseData"] ?? [];
        _isLoading = false;
      });
      // return profile.fromJson(jsonDecode(response.body)["data"]);
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load profile');
    }
  }

  Future<void> _fetchProfile() async {
    try {
      await fetchProfile();
      /* final profileData = await fetchProfile();
      setState(() {
        _profile = profileData;
        _firstNameController.text = profileData.firstName ?? '';
        _lastNameController.text = profileData.lastName ?? '';
        _emailController.text = profileData.email ?? '';
        _phoneNumberController.text = profileData.phoneNumber?.toString() ?? '';
        _companyNameController.text = profileData.companyName ?? '';
        _isLoading = false;
      });*/
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context,listen: false);

    return Scaffold(
      key: key,
      appBar: widget_302.App_Bar(
        context: context,
        onDrawerIconPressed: () {
          print("calling appbar");
          key.currentState!.openDrawer();
        },
      ),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: 'Profile',
      ),
      body: _connectivityResult != ConnectivityResult.none
          ? _isLoading
              ? Center(
                  child: SpinKitSpinningLines(
                    color: blueColor,
                    size: 50.0,
                  ),
                )
              : _hasError
                  ? Center(
                      child: Text('Error: $_errorMessage'),
                    )
                  : SingleChildScrollView(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 500) {
                            // Horizontal layout for tablet screens
                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(height: 30),
                                  titleBar(
                                      title: 'Personal Details',
                                      width: MediaQuery.of(context).size.width *
                                          0.90),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                        vertical: 10),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Table(
                                        border: TableBorder.all(),
                                        columnWidths: const {
                                          0: FlexColumnWidth(2),
                                          1: FlexColumnWidth(2),
                                          2: FlexColumnWidth(3),
                                        },
                                        children: [
                                          TableRow(
                                            children: [
                                              TableCell(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                        'Name',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20,
                                                            color: blueColor),
                                                      ))),
                                              TableCell(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                          'Phone Number',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                              color:
                                                                  blueColor)))),
                                              TableCell(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text('Email',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                              color:
                                                                  blueColor)))),
                                            ],
                                          ),
                                          TableRow(
                                            children: [
                                              TableCell(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                          "${profiledata['tenant_firstName']} ${profiledata['tenant_lastName']}",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 20,
                                                              color:
                                                                  greyColor)))),
                                              TableCell(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                          profiledata[
                                                              'tenant_phoneNumber'],
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 20,
                                                              color:
                                                                  greyColor)))),
                                              TableCell(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                          profiledata[
                                                              'tenant_email'],
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 20,
                                                              color:
                                                                  greyColor)))),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  titleBar(
                                      title: 'Lease Details',
                                      width: MediaQuery.of(context).size.width *
                                          0.90),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                        vertical: 10),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Table(
                                        border: TableBorder.all(),
                                        children: [
                                          TableRow(
                                            children: [
                                              TableCell(
                                                child: Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Text('Lease Type',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20,
                                                            color: blueColor))),
                                              ),
                                              TableCell(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text('Property',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                              color:
                                                                  blueColor)))),
                                              TableCell(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text('Start Date',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                              color:
                                                                  blueColor)))),
                                              TableCell(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text('End Date',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                              color:
                                                                  blueColor)))),
                                              TableCell(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text('Rent Cycle',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                              color:
                                                                  blueColor)))),
                                              TableCell(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text('Rent Amount',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                              color:
                                                                  blueColor)))),
                                              TableCell(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                          'Next Due Date',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                              color:
                                                                  blueColor)))),
                                            ],
                                          ),
                                          TableRow(
                                            children: [
                                              TableCell(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                          "${profiledata['leaseData']['lease_type']}",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 20,
                                                              color:
                                                                  greyColor)))),
                                              TableCell(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                          profiledata['leaseData']
                                                                  [
                                                                  'rental_adress'] ??
                                                              "N/A",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 20,
                                                              color:
                                                                  greyColor)))),
                                              TableCell(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                          dateProvider.formatCurrentDate(profiledata[
                                                                      'leaseData']
                                                                  [
                                                                  'start_date']) ??
                                                              "N/A",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 20,
                                                              color:
                                                                  greyColor)))),
                                              TableCell(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                          dateProvider.formatCurrentDate(profiledata[
                                                                      'leaseData']
                                                                  [
                                                                  'end_date']) ??
                                                              "N/A",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 20,
                                                              color:
                                                                  greyColor)))),
                                              TableCell(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                          profiledata['leaseData']
                                                                  [
                                                                  'rent_cycle'] ??
                                                              "N/A",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 20,
                                                              color:
                                                                  greyColor)))),
                                              TableCell(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                          profiledata['leaseData']
                                                                  ['amount']
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 20,
                                                              color:
                                                                  greyColor)))),
                                              TableCell(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                          profiledata['leaseData']
                                                                  ['date'] ??
                                                              "N/A",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 20,
                                                              color:
                                                                  greyColor)))),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // Vertical layout for phone screens
                            return Container(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  titleBar(
                                    title: 'Personal Details',
                                    width: MediaQuery.of(context).size.width *
                                        0.91,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    child: Card(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: blueColor),
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          children: [
                                            buildWidget('Name',
                                                "${profiledata['tenant_firstName']}${profiledata['tenant_lastName']}"),
                                            buildWidget(
                                                'Phone Number',
                                                profiledata[
                                                    'tenant_phoneNumber']),
                                            buildWidget('Email',
                                                profiledata['tenant_email']),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  if (leaseData != null) ...[
                                    titleBar(
                                      title: 'Lease Details',
                                      width: MediaQuery.of(context).size.width *
                                          0.91,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    // Padding(
                                    //   padding: const EdgeInsets.symmetric(
                                    //       horizontal: 20.0),
                                    //   child: Card(
                                    //     elevation: 0,
                                    //     shape: RoundedRectangleBorder(
                                    //       borderRadius:
                                    //           BorderRadius.circular(6),
                                    //     ),
                                    //     child: Container(
                                    //       decoration: BoxDecoration(
                                    //           border:
                                    //               Border.all(color: blueColor),
                                    //           borderRadius:
                                    //               BorderRadius.circular(6)),
                                    //       padding: const EdgeInsets.all(16.0),
                                    //       child: Column(
                                    //         children: [
                                    //           buildWidget('Lease Type',
                                    //               "${profiledata['leaseData']['lease_type']}"),
                                    //           buildWidget(
                                    //               'Property',
                                    //               profiledata['leaseData']
                                    //                       ['rental_adress'] ??
                                    //                   "N/A"),
                                    //           buildWidget(
                                    //               'Start Date',
                                    //               formatDate4(profiledata[
                                    //                           'leaseData']
                                    //                       ['start_date']) ??
                                    //                   "N/A"),
                                    //           buildWidget(
                                    //               'End Date',
                                    //               formatDate4(profiledata[
                                    //                           'leaseData']
                                    //                       ['end_date']) ??
                                    //                   "N/A"),
                                    //           buildWidget(
                                    //               'Rent Cycle',
                                    //               profiledata['leaseData']
                                    //                       ['rent_cycle'] ??
                                    //                   "N/A"),
                                    //           buildWidget(
                                    //               'Rent Amount',
                                    //               profiledata['leaseData']
                                    //                       ['amount']
                                    //                   .toString()),
                                    //           buildWidget(
                                    //               'Next Due Date',
                                    //               formatDate4(profiledata[
                                    //                           'leaseData']
                                    //                       ['date']) ??
                                    //                   "N/A"),
                                    //         ],
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),

                                    leaseData == null
                                        ? Center(
                                            child: Text("No lease data found"))
                                        : buildLeaseTable(leaseData),
                                  ],
                                  SizedBox(
                                    height: 30,
                                  ),
                                ],
                              ),
                            );
                          }
                        },
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Check your internet connection',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
    );
  }

  int? expandedIndex; // Declare this at the top of your StatefulWidget

  Widget buildLeaseTable(List<dynamic> leaseData) {
    final dateProvider = Provider.of<DateProvider>(context,listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: blueColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: tableHeaderCell(
                  "Lease Type",
                )),
                Expanded(child: tableHeaderCell("   Property")),
                Expanded(child: tableHeaderCell("    Start Date")),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: leaseData.asMap().entries.map((entry) {
              int index = entry.key;
              bool isExpanded = expandedIndex == index;
              var lease = entry.value;

              //return CustomExpansionTile(data: Data, index: index);
              return Container(
                decoration: BoxDecoration(
                  color: index % 2 != 0
                      ? Colors.white
                      : blueColor.withOpacity(0.09),
                  border: Border.all(color: Color.fromRGBO(152, 162, 179, .5)),
                ),
                // decoration: BoxDecoration(
                //   border: Border.all(color: blueColor),
                // ),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (expandedIndex == index) {
                                    expandedIndex = null;
                                  } else {
                                    expandedIndex = index;
                                  }
                                });
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.only(left: 5, right: 5),
                                padding: !isExpanded
                                    ? const EdgeInsets.only(bottom: 10)
                                    : const EdgeInsets.only(top: 10),
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
                              flex: 2,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    if (expandedIndex == index) {
                                      expandedIndex = null;
                                    } else {
                                      expandedIndex = index;
                                    }
                                  });
                                },
                                child: Text(
                                  '${lease['lease_type'] ?? "N/A"}',
                                  style: TextStyle(
                                    color: blueColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                                width: MediaQuery.of(context).size.width * .04),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${lease['rental_adress'] ?? "N/A"}',
                                style: TextStyle(
                                  color: blueColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            SizedBox(
                                width: MediaQuery.of(context).size.width * .06),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${dateProvider.formatCurrentDate(lease['start_date']) ?? "N/A"}',
                                style: TextStyle(
                                  color: blueColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            // SizedBox(
                            //     width: MediaQuery.of(context).size.width * .01),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        margin: const EdgeInsets.only(bottom: 2),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  FaIcon(
                                    isExpanded
                                        ? FontAwesomeIcons.sortUp
                                        : FontAwesomeIcons.sortDown,
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
                                        buildTableRow(
                                            "End Date",
                                            dateProvider.formatCurrentDate(lease['end_date']) ??
                                                "N/A"),
                                        buildTableRow("Rent Cycle",
                                            lease['rent_cycle'] ?? "N/A"),
                                        buildTableRow("Rent Amount",
                                            lease['amount'].toString()),
                                        buildTableRow(
                                            "Next Due Date",
                                            dateProvider.formatCurrentDate(lease['date']) ??
                                                "N/A"),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
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
        ],
      ),
    );
  }

  Widget tableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text, overflow: TextOverflow.ellipsis),
    );
  }

  TableRow buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(label,
              style: TextStyle(fontWeight: FontWeight.bold, color: blueColor)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            value,
            style: TextStyle(color: grey),
          ),
        ),
      ],
    );
  }

  buildWidget(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(
          height: 5,
        ),
        Material(
          //elevation: 3,
          borderRadius: BorderRadius.circular(6.0),
          child: Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  const BoxShadow(
                    color: Colors.black26,
                    offset:
                        Offset(1.0, 1.0), // Shadow offset to the bottom right
                    blurRadius: 8.0, // How much to blur the shadow
                    spreadRadius: 0.0, // How much the shadow should spread
                  ),
                ],
                border: Border.all(width: 0, color: Colors.white),
                borderRadius: BorderRadius.circular(6.0)),
            child: TextFormField(
              style: const TextStyle(
                color: Color(0xFF8898aa), // Text color
                fontSize: 16.0, // Text size
                fontWeight: FontWeight.w400, // Text weight
              ),
              //  controller: _dateController,
              initialValue: value,
              decoration: const InputDecoration(
                hintStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: Color(0xFFb0b6c3)),
                border: InputBorder.none,
                // labelText: 'Select Date',
                hintText: 'dd-mm-yyyy',
              ),
              readOnly: true,
              onTap: () {
                //_selectDate(context);
              },
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
