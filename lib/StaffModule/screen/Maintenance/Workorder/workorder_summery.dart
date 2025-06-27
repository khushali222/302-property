import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/Model/tenants.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/repository/lease.dart';
import 'package:three_zero_two_property/screens/Leasing/RentalRoll/newModel.dart';

// import 'package:three_zero_two_property/repository/properties_summery.dart';
import '../../../../model/summery_workorder.dart';
import '../../../../provider/dateProvider.dart';
import '../../../../widgets/VideoPlayerWidget.dart';
import '../../../repository/workorder.dart';
import '../../../widgets/drawer_tiles.dart';
import '../../../../widgets/titleBar.dart';
import '../../../widgets/custom_drawer.dart';
import '../../../widgets/appbar.dart';

class Workorder_summery extends StatefulWidget {
  String? workorder_id;
  Workorder_summery({super.key, this.workorder_id});

  @override
  State<Workorder_summery> createState() => _Workorder_summeryState();
}

class _Workorder_summeryState extends State<Workorder_summery>
    with SingleTickerProviderStateMixin {
  List<String> applicantCheckedChecklist = [
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
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        print(result);
        _connectivityResult = result;
      });
    });
    checkInternet();
    futureworkorderSummary =
        WorkOrderRepository.getworkorderSummary(widget.workorder_id!);

    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    _loadStaff();
  }

  ConnectivityResult? _connectivityResult;
  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
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
    String? staffid = prefs.getString("staff_id");
    //  String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    setState(() {
      _isLoadingstaff = true;
    });
    try {
      final response = await http.get(
          Uri.parse('${Api_url}/api/staffmember/staff_member/$id'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $staffid",
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

  //for image
  File? _image;
  bool isLoading = false;
  List<File> _images = [];
  String? _uploadedFileName;
  List<String> _uploadedFileNames = [];
  Future<String?> uploadImage(File imageFile) async {
    print(imageFile.path);
    final String uploadUrl = '${image_upload_url}/api/images/upload';
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          uploadUrl,
        ));
    request.files
        .add(await http.MultipartFile.fromPath('files', imageFile.path));

    var response = await request.send();
    var responseData = await http.Response.fromStream(response);
    print(responseData.body);

    var responseBody = json.decode(responseData.body);
    if (responseBody['status'] == 'ok') {
      List file = responseBody['files'];
      return file.first["filename"];
    } else {
      throw Exception('Failed to upload file: ${responseBody['message']}');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        _images.add(File(image.path));
      });
      _uploadImage(File(image.path));
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      String? fileName = await uploadImage(imageFile);
      setState(() {
        _uploadedFileNames.add(fileName!);
        _uploadedFileName = fileName;
        _imageUrls.add(fileName!);
      });
    } catch (e) {
      print('Image upload failed: $e');
    }
  }

  List<String> _imageUrls = [];
  int visibleCount = 5;
  int selectedTabIndex = 0;
  bool showAllImages = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: widget302.,
      key: key,
      appBar: widget_302_Staff.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawerStaff(
        currentpage: "Work Order",
        dropdown: true,
      ),
      body: _connectivityResult != ConnectivityResult.none
          ? Column(
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
                          decoration: BoxDecoration(
                            color: blueColor,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          child: const Center(
                              child: Text(
                            "Back",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
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
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: SpinKitFadingCircle(
                                color: Colors.black,
                                size: 55.0,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data == null) {
                            return Center(child: Text('No data found.'));
                          } else {
                            // _selectedValue = snapshot.data!.applicantStatus!.last!.status;
                            return Column(
                              children: <Widget>[
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  height: 50,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: TabBar(
                                    controller: _tabController,
                                    labelPadding: const EdgeInsets.symmetric(
                                        horizontal: 0),
                                    indicator: BoxDecoration(
                                      color: blueColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    labelColor: Colors.white,
                                    unselectedLabelColor: blueColor,
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    tabs: const [
                                      Tab(text: 'Summary'),
                                      Tab(text: 'Task'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 0),
                                Expanded(
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      Summery_page(snapshot.data!),
                                      Task(snapshot.data!),
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

  List<String> titles = [' Account', 'Qty', '  Price', 'Amount'];
  Map<int, TableColumnWidth> columnWidth = {
    0: FlexColumnWidth(3.3),
    1: FlexColumnWidth(1),
    2: FlexColumnWidth(1.9),
    3: FlexColumnWidth(1.81),
  };
  // int getTotalPrice() {
  //   //return products.fold(0, (sum, item) => sum + item.totalAmount);
  //   return 0;
  // }

  double getTotalPrice(List<PartsandchargeData>? partsList) {
    if (partsList == null || partsList.isEmpty) return 0.0;

    return partsList.fold(
        0.0,
            (sum, item) =>
        sum + ((item.partsQuantity ?? 0) * (item.partsPrice ?? 0)));
  }

  Widget tableView(
      bool isHeader,
      ) {
    return Table(
      columnWidths: columnWidth,
      children: [
        isHeader
            ? TableRow(
            decoration: BoxDecoration(color: Color.fromRGBO(21, 43, 83, 1)),
            children: titles
                .map(
                  (item) => Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(item,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            )
                .toList())
            : TableRow(
          decoration: BoxDecoration(color: Color.fromRGBO(21, 43, 83, 1)),
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Total',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(''),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(''),
            ),
            // Padding(
            //   padding: EdgeInsets.all(8.0),
            //   child: Text(
            //     "\$${getTotalPrice()}",
            //     style: TextStyle(
            //         color: Colors.white,
            //         fontWeight: FontWeight.bold,
            //         fontSize: 13),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  Summery_page(WorkOrderData_summery summery) {
    print(' update image ${summery.workorderUpdates}');
    print(' update tenant ${summery.vendorData?.companyName}');
    final dateProvider = Provider.of<DateProvider>(context);
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
                        border: Border.all(color: blueColor),
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
                                  border: Border.all(color: blueColor),
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
                                        dateProvider
                                            .formatCurrentDate(
                                            '${summery.workorderUpdates?.last.date}')
                                            .isEmpty
                                            ? 'N/A'
                                            : dateProvider.formatCurrentDate(
                                            '${summery.workorderUpdates?.last.date}'),
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
                                  SizedBox(
                                    width:
                                    MediaQuery.of(context).size.width > 500
                                        ? 200
                                        : 150,
                                    child: Text(
                                      '${summery.vendorNotes}',
                                      maxLines:
                                      4, // Set maximum number of lines
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign
                                          .justify, // Handle overflow with ellipsis
                                      style: TextStyle(
                                        fontSize:
                                        MediaQuery.of(context).size.width <
                                            500
                                            ? 13
                                            : 18,
                                        color: blueColor,
                                      ),
                                    ),
                                  ),
                                  // Container(
                                  //     child: Text(
                                  //   '${summery.vendorNotes}',
                                  //   style: TextStyle(color: blueColor),
                                  // )),
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
                              TableRow(children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('QTY',
                                      style: TextStyle(
                                          color: blueColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Account',
                                      style: TextStyle(
                                          color: blueColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Description',
                                      style: TextStyle(
                                          color: blueColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Price',
                                      style: TextStyle(
                                          color: blueColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Amount',
                                      style: TextStyle(
                                          color: blueColor,
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
                      border: Border.all(color: blueColor),
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
                                    '${update.statusUpdatedBy ?? ""} updated this work order (${dateProvider.formatCurrentDate('${update.date}')})',
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
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Billing Information
                      Expanded(
                        child: Material(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Container(
                                  height: 50,
                                  width: double.infinity,
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF7F9FC),
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(10)),
                                  ),
                                  child: Text(
                                    'Billing Information',
                                    style: TextStyle(
                                      color: blueColor,
                                      fontSize:
                                      MediaQuery.of(context).size.width <
                                          400
                                          ? 14
                                          : 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 1,
                                  color: grey,
                                  width: double.infinity,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                // Body
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 1,
                                    ),
                                    Checkbox(
                                      value: summery.isBillable ?? false,
                                      onChanged: (val) {
                                        setState(
                                                () => isChecked = val ?? false);
                                      },
                                      activeColor: blueColor,
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Billable to Tenant',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: blueColor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 1,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      // Contacts
                      Expanded(
                        child: Material(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Container(
                                  height: 50,
                                  width: double.infinity,
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF7F9FC),
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(10)),
                                  ),
                                  child: Text(
                                    'Contacts',
                                    style: TextStyle(
                                      color: blueColor,
                                      fontSize:
                                      MediaQuery.of(context).size.width <
                                          400
                                          ? 14
                                          : 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 1,
                                  color: grey,
                                  width: double.infinity,
                                ),
                                // Body
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.person, color: blueColor),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Vendor',
                                                  style: TextStyle(
                                                    color: blueColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  summery.vendorData
                                                      ?.companyName ??
                                                      'N/A',
                                                  style: TextStyle(
                                                      color: blueColor,
                                                      fontSize: 13),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (summery.tenantData != null) ...[
                                        SizedBox(height: 12),
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.person,
                                                color: blueColor),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Tenant',
                                                    style: TextStyle(
                                                      color: blueColor,
                                                      fontWeight:
                                                      FontWeight.w500,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${summery.tenantData?.firstname ?? ''} ${summery.tenantData?.lastname ?? ''}',
                                                    style: TextStyle(
                                                        color: blueColor,
                                                        fontSize: 13),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
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
                SizedBox(
                  height: 10,
                ),
                Material(
                  borderOnForeground: true,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: grey),
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
                            color: Color(0xFFF7F9FC),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(10),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 5,
                                ),
                                Padding(
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
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          color: grey,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (summery.propertyData!.rental_image != null &&
                                summery.propertyData!.rental_image!.isNotEmpty)
                              Column(
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Container(
                                      child:
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: CachedNetworkImage(
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
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 14,
                                ),
                                Text(
                                  "${summery.propertyData!.rentaladress} ",
                                  textAlign: TextAlign.start,
                                  style:
                                  TextStyle(color: Color(0xFF3A4A57), fontSize: 13,fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 14,
                                ),
                                SizedBox(
                                  width: 300,
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    spacing:
                                    4.0, // Space between texts horizontally
                                    runSpacing:
                                    4.0, // Space between lines when wrapping
                                    children: [
                                      Text(
                                        "${summery.propertyData!.rental_city}, ",
                                        style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: Color(0xFF3A4A57)),
                                      ),
                                      Text(
                                        "${summery.propertyData!.rental_state}, ",
                                        style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: Color(0xFF3A4A57)),
                                      ),
                                      Text(
                                        "${summery.propertyData!.rental_country}, ",
                                        style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: Color(0xFF3A4A57)),
                                      ),
                                      Text(
                                        "${summery.propertyData!.rental_postcode}",
                                        style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: Color(0xFF3A4A57)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(color: grey),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Title Row: Work Subject and Address
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              '${summery.workSubject}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${summery.propertyData!.rentaladress} ${summery.unitData?.rental_unit != null ? '(${summery.unitData?.rental_unit})' : ''}',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 13,
                                color: blueColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      /// Assignee & Due Date
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Assignees", style: labelStyle),
                                SizedBox(height: 4),
                                Text(
                                  summery.staffData?.firstname ?? 'N/A',
                                  style: valueStyle,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Due Date", style: labelStyle),
                                SizedBox(height: 4),
                                Text(
                                  summery.workorderUpdates?.last.date
                                      ?.isEmpty ==
                                      true
                                      ? 'N/A'
                                      : '${summery.workorderUpdates?.last.date}',
                                  style: valueStyle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      /// Description
                      Text("Description", style: labelStyle),
                      SizedBox(height: 4),
                      Text(
                        summery.workPerformed?.isNotEmpty == true
                            ? summery.workPerformed!
                            : "N/A",
                        style: valueStyle,
                        textAlign: TextAlign.justify,
                      ),

                      SizedBox(height: 5),
                      Divider(color: grey),
                      SizedBox(height: 5),

                      /// Permission & Status
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Permission to enter", style: labelStyle),
                                SizedBox(height: 4),
                                Text(
                                  summery.entryAllowed! ? "Yes" : "No",
                                  style: valueStyle,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Status",
                                  style: labelStyle,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${summery.status}',
                                  style:
                                  valueStyle.copyWith(color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      /// Vendor Notes
                      Text("Vendor Notes", style: labelStyle),
                      SizedBox(height: 4),
                      Text(
                        summery.vendorNotes ?? "N/A",
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.justify,
                        style: valueStyle,
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: grey),
                        // color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                          CustomTableView(
                            titles: titles,
                            data: [],
                            isHeader: true,
                            columnWidths: columnWidth,
                            description: "",
                            showDescription: false,
                          ),

                          Column(
                            children: summery.partsandchargeData!
                                .map((item) => Container(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  CustomTableView(
                                    titles: [],
                                    data: [
                                      [
                                        item.account!,
                                        item.partsQuantity.toString(),
                                        "\$${item.partsPrice!.toStringAsFixed(2)}",
                                        "\$${item.amount!.toStringAsFixed(2)}",
                                      ]
                                    ],
                                    isHeader: false,
                                    columnWidths: columnWidth,
                                    description: item.description!,
                                    showDescription: true,
                                  ),
                                ],
                              ),
                            ))
                                .toList(),
                          ),
                          CustomTableView(
                            titles: [],
                            data: [
                              [
                                "Total",
                                "",
                                "",
                                "\$${getTotalPrice(summery.partsandchargeData).toStringAsFixed(2)}"
                              ]
                            ],
                            isHeader: false,
                            columnWidths: columnWidth,
                            description: "",
                            showDescription: false,
                          ),
                          // tableView(false),
                        ],
                      ),
                    ),
                  ),
                if (summery.partsandchargeData!.length > 0)
                  SizedBox(
                    height: 10,
                  ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row with title and button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Updates History',
                            style: TextStyle(
                              fontSize: 16,
                              color: blueColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              showUpdateDialog(context);
                            },
                            child: Material(
                              elevation: 1,
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              child: Container(
                                height: 30,
                                width: 85,
                                decoration: BoxDecoration(
                                  color: blueColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                    child: Text(
                                      "Update",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    )),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...summery.workorderUpdates!.reversed
                          .take(visibleCount)
                          .map((update) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFF7F9FC),
                            border: Border.all(color: grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Assignees & Due Date
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildLabelValue("Assignees",
                                      update.staffmemberName ?? "N/A",
                                      valueColor: blueColor),
                                  _buildLabelValue(
                                      "Due Date", update.date ?? "N/A",
                                      valueColor: blueColor),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Status & Updated By
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildLabelValue(
                                    "Status",
                                    update.status ?? "N/A",
                                    valueColor: Colors.green,
                                  ),
                                  _buildLabelValue("Updated By",
                                      update.statusUpdatedBy ?? "N/A",
                                      valueColor: blueColor),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildLabelValue("Message",
                                  '${update.statusUpdatedBy ?? ""} updated this work order (${update.updatedAt != null ? update.updatedAt : update.createdAt ?? "N/A"})',
                                  valueColor: blueColor),
                              if (update.workOrderUpdateimages != null &&
                                  update.workOrderUpdateimages!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: update.workOrderUpdateimages!
                                      .map((imageUrl) {
                                    return GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => Dialog(
                                            backgroundColor: Colors.transparent,
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  top: 10,
                                                  right: 10,
                                                  child: IconButton(
                                                    icon: const Icon(
                                                        Icons.close,
                                                        size: 30,
                                                        color: Colors.black),
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                  ),
                                                ),
                                                Center(
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets.all(
                                                        20),
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                      "$image_url$imageUrl",
                                                      placeholder: (context,
                                                          url) =>
                                                      const CircularProgressIndicator(),
                                                      errorWidget: (context,
                                                          url, error) =>
                                                      const Icon(
                                                          Icons.error),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width:
                                        (MediaQuery.of(context).size.width /
                                            3) -
                                            16,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(10),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            imageUrl: "$image_url$imageUrl",
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                SpinKitFadingCircle(
                                                  color: blueColor,
                                                  size: 55.0,
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                            const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ] else ...[
                                const SizedBox(height: 10),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   children:  [
                                //     Text(
                                //       "No Images Provided",
                                //       style: TextStyle(color: Colors.transparent),
                                //     ),
                                //   ],
                                // ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                      if (summery.workorderUpdates!.length > 5)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              visibleCount = visibleCount == 5
                                  ? summery.workorderUpdates!.length
                                  : 5;
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                visibleCount == 5 ? 'View More' : 'View Less',
                                style: TextStyle(
                                  color: blueColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(
                                visibleCount == 5
                                    ? Icons.keyboard_arrow_down_outlined
                                    : Icons.keyboard_arrow_up,
                                color: blueColor,
                              ),
                            ],
                          ),
                        ),
                    ],
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

  Widget _buildLabelValue(String label, String value,
      {Color valueColor = Colors.black}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
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
                        border: Border.all(color: blueColor),
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
                                  border: Border.all(color: blueColor),
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
                                        '${summery.workPerformed!.isNotEmpty ? summery.workPerformed : "N/A"}',
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
                                        '${summery.workorderUpdates!.last.date!.isEmpty == true ? "N/A" : summery.workorderUpdates?.last.date?.toString()}',
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
                                      width: 150,
                                      child: Text(
                                        '${summery.vendorNotes!.isNotEmpty ? summery.vendorNotes : "N/A"}',
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
                      elevation: 7,
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
                                elevation: 4,
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
                                      Text("No Images Provided"),
                                      // Text("(${summery.unitData!.unitName})"),
                                    ],
                                  ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "${summery.propertyData!.rentaladress} (${summery.unitData!.unitName})",
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: 300,
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing:
                                    4.0, // Space between texts horizontally
                                    runSpacing:
                                    4.0, // Space between lines when wrapping
                                    children: [
                                      Text(
                                          "${summery.propertyData!.rental_city}, "),
                                      Text(
                                          "${summery.propertyData!.rental_state}, "),
                                      Text(
                                          "${summery.propertyData!.rental_country}, "),
                                      Text(
                                          "${summery.propertyData!.rental_postcode}"),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            )
                            /*  ListTile(
                              title: Text(
                                "Vendor",
                              ),
                              subtitle: Text(
                                "Vendor Company Name",
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
                    border: Border.all(color: grey),
                    // color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 5),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '${summery.workSubject}',
                              maxLines: 2, // Or increase if needed
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize:
                                MediaQuery.of(context).size.width < 500
                                    ? 14
                                    : 18,
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 5), // Spacing between the two
                          Expanded(
                            flex: 1,
                            child: Text(
                              '${summery.propertyData!.rentaladress} ${summery.unitData?.rental_unit != null ? '(${summery.unitData?.rental_unit})' : ''}',
                              maxLines: 2, // Or increase if needed
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize:
                                MediaQuery.of(context).size.width < 500
                                    ? 12
                                    : 18,
                                color: blueColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Container(
                              //  height: 70,
                              width: MediaQuery.of(context).size.width * .3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "Assignees",
                                    style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  summery.staffData != null
                                      ? Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                            '${summery.staffData?.firstname}',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              color: blueColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            )),
                                      ),
                                    ],
                                  )
                                      : Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: [
                                      Text('N/A',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            color: blueColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          )),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Spacer(),
                          Expanded(
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      '${summery.workorderUpdates!.last.date!.isEmpty == true ? "N/A" : summery.workorderUpdates?.last.date?.toString()}',
                                      style: TextStyle(
                                          color: blueColor,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    child: Text(
                                      'Permission to enter',
                                      style: TextStyle(color: blueColor),
                                    )),
                                SizedBox(
                                  height: 8,
                                ),
                                Container(
                                    child: Text(
                                      '${summery.entryAllowed! ? "Yes" : "No"}',
                                      style: TextStyle(
                                        color: blueColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          Spacer(),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
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
                                        color: Colors.green,
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
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    child: Text(
                                      'Description',
                                      style: TextStyle(
                                        color: blueColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    )),
                                SizedBox(
                                  height: 8,
                                ),
                                Container(
                                    width: 250,
                                    child: Text(
                                      '${summery.workPerformed!.isNotEmpty ? summery.workPerformed : "N/A"}',
                                      style: TextStyle(
                                          color: blueColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                    )),
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
                    // elevation: 7,
                    borderOnForeground: true,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: grey),
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
                              elevation: 4,
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Padding(
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
                                ],
                              ),
                            ),
                          ),

                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     if (summery.workorderUpdates != null)
                          //       Column(
                          //         children: [
                          //           SizedBox(height: 10),
                          //           Wrap(
                          //             spacing: 10,
                          //             runSpacing: 10,
                          //             alignment: WrapAlignment.start,
                          //             children: summery.workOrderImages!
                          //                 .map((fileUrl) {
                          //               bool isMp4 = isVideo(fileUrl);
                          //               return Container(
                          //                 width:
                          //                     summery.workOrderImages!
                          //                                 .length ==
                          //                             1
                          //                         ? MediaQuery.of(context)
                          //                                 .size
                          //                                 .width /
                          //                             3
                          //                         : (MediaQuery.of(context)
                          //                                     .size
                          //                                     .width /
                          //                                 3) -
                          //                             10,
                          //                 decoration: BoxDecoration(
                          //                   borderRadius:
                          //                       BorderRadius.circular(10),
                          //                 ),
                          //                 child: ClipRRect(
                          //                   borderRadius:
                          //                       BorderRadius.circular(10),
                          //                   child: isMp4
                          //                       ? Container(
                          //                           height: 80,
                          //                           width: 80,
                          //                           child: GestureDetector(
                          //                             onTap: () {
                          //                               _showVideoDialog(
                          //                                   '$image_url$fileUrl');
                          //                             },
                          //                             child: Stack(
                          //                               alignment:
                          //                                   Alignment.center,
                          //                               children: [
                          //                                 // Image.file(
                          //                                 //   File(snapshot.data!),
                          //                                 //   height: 100,
                          //                                 //   width: 100,
                          //                                 //   fit: BoxFit.cover,
                          //                                 // ),
                          //                                 VideoItem(
                          //                                   url:
                          //                                       '$image_url$fileUrl',
                          //                                 ),
                          //                                 Icon(
                          //                                     Icons
                          //                                         .play_circle_fill,
                          //                                     color:
                          //                                         Colors.white,
                          //                                     size: 40),
                          //                               ],
                          //                             ),
                          //                           ),
                          //                         )
                          //                       // FutureBuilder<String?>(
                          //                       //   future: generateNetworkVideoThumbnail("$image_url$fileUrl"),
                          //                       //   builder: (context, snapshot) {
                          //                       //     if (snapshot.connectionState == ConnectionState.waiting) {
                          //                       //       return Center(
                          //                       //           child: SpinKitFadingCircle(
                          //                       //             color: Colors.black,
                          //                       //             size: 40.0,
                          //                       //           ));
                          //                       //     } else if (snapshot.hasData && snapshot.data != null) {
                          //                       //       return
                          //                       //         GestureDetector(
                          //                       //         onTap: (){
                          //                       //           _showVideoDialog('$image_url$fileUrl');
                          //                       //         },
                          //                       //         child: Stack(
                          //                       //           alignment: Alignment.center,
                          //                       //           children: [
                          //                       //             Image.file(
                          //                       //               File(snapshot.data!),
                          //                       //               height: 100,
                          //                       //               width: 100,
                          //                       //               fit: BoxFit.cover,
                          //                       //             ),
                          //                       //             Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
                          //                       //           ],
                          //                       //         ),
                          //                       //       );
                          //                       //
                          //                       //     } else {
                          //                       //       return Icon(Icons.error);
                          //                       //     }
                          //                       //   },
                          //                       // )
                          //                       : CachedNetworkImage(
                          //                           height: 140,
                          //                           imageUrl:
                          //                               "$image_url$fileUrl",
                          //                           placeholder: (context,
                          //                                   url) =>
                          //                               Center(
                          //                                   child:
                          //                                       SpinKitFadingCircle(
                          //                             color: Colors.black,
                          //                             size: 40.0,
                          //                           )),
                          //                           errorWidget:
                          //                               (context, url, error) =>
                          //                                   Icon(Icons.error),
                          //                           fit: BoxFit.cover,
                          //                         ),
                          //                 ),
                          //               );
                          //             }).toList(),
                          //           ),
                          //         ],
                          //       ),
                          //     if (summery.workOrderImages!.length == 0)
                          //       Row(
                          //         mainAxisAlignment: MainAxisAlignment.center,
                          //         children: [
                          //           Text("No Images Provided"),
                          //           // Text("(${summery.unitData!.unitName})"),
                          //         ],
                          //       ),
                          //     SizedBox(
                          //       height: 10,
                          //     ),
                          //   ],
                          // )
                          // Declare this in your state

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (summery.workOrderImages != null &&
                                  summery.workOrderImages!.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 18),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 13),
                                        child: SizedBox(
                                          height: 150,
                                          child: Row(
                                            children: summery.workOrderImages!
                                                .take(showAllImages
                                                ? summery
                                                .workOrderImages!.length
                                                : 2)
                                                .map((fileUrl) {
                                              bool isMp4 = isVideo(fileUrl);
                                              return Padding(
                                                padding:
                                                const EdgeInsets.all(4),
                                                child: Container(
                                                  width: 150,
                                                  height: 150,
                                                  // color: Colors.blue,
                                                  margin:
                                                  EdgeInsets.only(right: 8),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                                    child: isMp4
                                                        ? GestureDetector(
                                                      onTap: () {
                                                        _showVideoDialog(
                                                            '$image_url$fileUrl');
                                                      },
                                                      child: Stack(
                                                        alignment:
                                                        Alignment
                                                            .center,
                                                        children: [
                                                          VideoItem(
                                                              url:
                                                              '$image_url$fileUrl'),
                                                          Icon(
                                                            Icons
                                                                .play_circle_fill,
                                                            color: Colors
                                                                .white,
                                                            size: 40,
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                        : CachedNetworkImage(
                                                      imageUrl:
                                                      "$image_url$fileUrl",
                                                      fit: BoxFit.fill,
                                                      placeholder:
                                                          (context,
                                                          url) =>
                                                          Center(
                                                            child:
                                                            SpinKitFadingCircle(
                                                              color: Colors
                                                                  .black,
                                                              size: 30.0,
                                                            ),
                                                          ),
                                                      errorWidget:
                                                          (context, url,
                                                          error) =>
                                                          Icon(Icons
                                                              .error),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (summery.workOrderImages!.length > 2)
                                      SizedBox(height: 15),

                                    /// View More / View Less Button
                                    if (summery.workOrderImages!.length > 2)
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(left: 18),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              showAllImages = !showAllImages;
                                            });
                                          },
                                          child: Text(
                                            showAllImages
                                                ? "View Less"
                                                : "View More",
                                            style: TextStyle(
                                                color: blueColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    SizedBox(height: 18),
                                  ],
                                ),

                              /// If no images
                              if (summery.workOrderImages == null ||
                                  summery.workOrderImages!.isEmpty)
                                Center(
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      "No Images Provided",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black54),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                IntrinsicHeight(
                  child: Material(
                    // elevation: 7,
                    borderOnForeground: true,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: grey),
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
                              elevation: 4,
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Padding(
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
                                ],
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "${summery.propertyData!.rentaladress} ${summery.unitData?.rental_unit != null ? '(${summery.unitData?.rental_unit})' : ''}",
                                textAlign: TextAlign.start,
                                style:
                                TextStyle(fontSize: 13, color: blueColor),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 50,
                                width: 300,
                                child: Wrap(
                                  alignment: WrapAlignment.start,
                                  spacing:
                                  4.0, // Space between texts horizontally
                                  runSpacing:
                                  4.0, // Space between lines when wrapping
                                  children: [
                                    Text(
                                      "${summery.propertyData!.rental_city}, ",
                                      style: TextStyle(
                                          fontSize: 13, color: blueColor),
                                    ),
                                    Text(
                                      "${summery.propertyData!.rental_state}, ",
                                      style: TextStyle(
                                          fontSize: 13, color: blueColor),
                                    ),
                                    Text(
                                      "${summery.propertyData!.rental_country}, ",
                                      style: TextStyle(
                                          fontSize: 13, color: blueColor),
                                    ),
                                    Text(
                                      "${summery.propertyData!.rental_postcode}",
                                      style: TextStyle(
                                          fontSize: 13, color: blueColor),
                                    ),
                                  ],
                                ),
                              ),
                              // SizedBox(
                              //   height: 10,
                              // ),
                            ],
                          )
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

  String imageUrl = "";
  bool isVideo(String url) {
    return url.toLowerCase().endsWith(".mp4");
  }

  // void showUpdateDialog(BuildContext context) {
  //   // Initialize variables to store user input
  //   String? selectedStatus;
  //   //  DateTime? selectedDate;
  //   //String? message;
  //   TextEditingController message = TextEditingController();
  //   TextEditingController selectedDate = TextEditingController();
  //
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setState) {
  //           return Dialog(
  //             child: Container(
  //               // width: double.maxFinite,
  //               child: Padding(
  //                 padding: const EdgeInsets.only(
  //                     left: 10, right: 10, top: 15, bottom: 10),
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: <Widget>[
  //                     Row(
  //                       children: [
  //                         Text(
  //                           'Update Work Order',
  //                           style: TextStyle(
  //                               color: blueColor,
  //                               fontWeight: FontWeight.bold,
  //                               fontSize: 18),
  //                         ),
  //                         Spacer(),
  //                         GestureDetector(
  //                           onTap: (){
  //                             Navigator.pop(context);
  //                           },
  //                             child: Icon(Icons.close,)),
  //
  //                       ],
  //                     ),
  //                     SizedBox(height: 10.0),
  //                     Text('Status',
  //                         style: TextStyle(
  //                             color: blueColor, fontWeight: FontWeight.bold)),
  //                     DropdownButtonHideUnderline(
  //                       child: DropdownButtonFormField2<String>(
  //                         decoration: InputDecoration(border: InputBorder.none),
  //                         isExpanded: true,
  //                         hint: const Row(
  //                           children: [
  //                             Expanded(
  //                               child: Text(
  //                                 'Select Status',
  //                                 style: TextStyle(
  //                                   fontSize: 14,
  //                                   fontWeight: FontWeight.w400,
  //                                   color: Color(0xFFb0b6c3),
  //                                 ),
  //                                 overflow: TextOverflow.ellipsis,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                         items: ['New', 'In Progress', 'On Hold', 'Completed']
  //                             .map((status) {
  //                           return DropdownMenuItem<String>(
  //                             value: status,
  //                             child: Text(
  //                               status,
  //                               style: const TextStyle(
  //                                 fontSize: 14,
  //                                 fontWeight: FontWeight.w400,
  //                                 color: Colors.black87,
  //                               ),
  //                               overflow: TextOverflow.ellipsis,
  //                             ),
  //                           );
  //                         }).toList(),
  //                         value: selectedStatus,
  //                         onChanged: (value) {
  //                           selectedStatus = value;
  //                         },
  //                         buttonStyleData: ButtonStyleData(
  //                           height: 45,
  //                           width: double.infinity,
  //                           padding: const EdgeInsets.only(left: 14, right: 14),
  //                           decoration: BoxDecoration(
  //                             borderRadius: BorderRadius.circular(6),
  //                             color: Colors.white,
  //                           ),
  //                           elevation: 2,
  //                         ),
  //                         iconStyleData: const IconStyleData(
  //                           icon: Icon(Icons.arrow_drop_down),
  //                           iconSize: 24,
  //                           iconEnabledColor: Color(0xFFb0b6c3),
  //                           iconDisabledColor: Colors.grey,
  //                         ),
  //                         dropdownStyleData: DropdownStyleData(
  //                           decoration: BoxDecoration(
  //                             borderRadius: BorderRadius.circular(6),
  //                             color: Colors.white,
  //                           ),
  //                           scrollbarTheme: ScrollbarThemeData(
  //                             radius: const Radius.circular(6),
  //                             thickness: MaterialStateProperty.all(6),
  //                             thumbVisibility: MaterialStateProperty.all(true),
  //                           ),
  //                         ),
  //                         menuItemStyleData: const MenuItemStyleData(
  //                           height: 40,
  //                           padding: EdgeInsets.only(left: 14, right: 14),
  //                         ),
  //                         validator: (value) {
  //                           if (value == null || value.isEmpty) {
  //                             return 'Please select an option';
  //                           }
  //                           return null;
  //                         },
  //                       ),
  //                     ),
  //                     Text('Due Date',
  //                         style: TextStyle(
  //                             color: blueColor, fontWeight: FontWeight.bold)),
  //                     SizedBox(height: 8.0),
  //                     Material(
  //                       elevation: 3,
  //                       borderRadius: BorderRadius.circular(8.0),
  //                       child: Container(
  //                         height: 45,
  //                         padding: EdgeInsets.symmetric(
  //                             horizontal: 16.0, vertical: 0),
  //                         decoration: BoxDecoration(
  //                           color: Colors.white,
  //                           borderRadius: BorderRadius.circular(8.0),
  //                         ),
  //                         child: TextFormField(
  //                           onTap: () async {
  //                             DateTime? pickedDate = await showDatePicker(
  //                               context: context,
  //                               initialDate: DateTime.now(),
  //                               firstDate: DateTime(2000),
  //                               lastDate: DateTime(2101),
  //                               helpText: "Due Date",
  //                               locale: const Locale('en', 'US'),
  //                               builder: (BuildContext context, Widget? child) {
  //                                 return Theme(
  //                                   data: ThemeData.light().copyWith(
  //                                     colorScheme: const ColorScheme.light(
  //                                       primary: Color.fromRGBO(21, 43, 83,
  //                                           1), // header background color
  //                                       onPrimary:
  //                                           Colors.white, // header text color
  //                                       onSurface: Color.fromRGBO(
  //                                           21, 43, 83, 1), // body text color
  //                                     ),
  //                                     textButtonTheme: TextButtonThemeData(
  //                                       style: TextButton.styleFrom(
  //                                         foregroundColor: Colors.white,
  //                                         backgroundColor: const Color.fromRGBO(
  //                                             21,
  //                                             43,
  //                                             83,
  //                                             1), // button text color
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   child: child!,
  //                                 );
  //                               },
  //                             );
  //
  //                             if (pickedDate != null) {
  //                               String formattedDate =
  //                                   "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
  //                               setState(() {
  //                                 selectedDate.text = formattedDate;
  //                               });
  //                             }
  //                           },
  //                           //  obscureText: widget.obscureText,
  //                           readOnly: true,
  //                           controller: selectedDate,
  //                           decoration: InputDecoration(
  //                             suffixIcon:
  //                                 Icon(Icons.calendar_today, color: blueColor),
  //                             // hintStyle:
  //                             // TextStyle(fontSize: 13, color: blueColor),
  //                             border: InputBorder.none,
  //                             hintText: "dd-mm-yyyy",
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     /* ElevatedButton(
  //                   onPressed: () async {
  //                     final DateTime? pickedDate = await showDatePicker(
  //                       context: context,
  //                       initialDate: DateTime.now(),
  //                       firstDate: DateTime(2000),
  //                       lastDate: DateTime(2100),
  //                     );
  //                     if (pickedDate != null) {
  //                       selectedDate = pickedDate;
  //                     }
  //                   },
  //                   child: Text(selectedDate == null
  //                       ? 'Select Date'
  //                       : '${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}'),
  //                 ),*/
  //                     SizedBox(height: 16.0),
  //                     Text('Assigned To',
  //                         style: TextStyle(
  //                             color: blueColor, fontWeight: FontWeight.bold)),
  //                     SizedBox(height: 8.0),
  //                     _isLoadingstaff
  //                         ? const Center(
  //                             child: SpinKitFadingCircle(
  //                               color: Colors.black,
  //                               size: 50.0,
  //                             ),
  //                           )
  //                         : Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               DropdownButtonHideUnderline(
  //                                 child: DropdownButtonFormField2<String>(
  //                                   decoration: InputDecoration(
  //                                       border: InputBorder.none),
  //                                   isExpanded: true,
  //                                   hint: const Row(
  //                                     children: [
  //                                       Expanded(
  //                                         child: Text(
  //                                           'Select here',
  //                                           style: TextStyle(
  //                                             fontSize: 14,
  //                                             fontWeight: FontWeight.w400,
  //                                             color: Color(0xFFb0b6c3),
  //                                           ),
  //                                           overflow: TextOverflow.ellipsis,
  //                                         ),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                   items: staffs.keys.map((staffmember_id) {
  //                                     return DropdownMenuItem<String>(
  //                                       value: staffmember_id,
  //                                       child: Text(
  //                                         staffs[staffmember_id]!,
  //                                         style: const TextStyle(
  //                                           fontSize: 14,
  //                                           fontWeight: FontWeight.w400,
  //                                           color: Colors.black87,
  //                                         ),
  //                                         overflow: TextOverflow.ellipsis,
  //                                       ),
  //                                     );
  //                                   }).toList(),
  //                                   value: _selectedstaffId,
  //                                   onChanged: (value) {
  //                                     setState(() {
  //                                       // _selectedUnitId = null;
  //                                       _selectedstaffId = value;
  //                                       _selectedStaffs = staffs[
  //                                           value]; // Store selected rental_adress

  //                                       //StaffId = value.toString();
  //                                       print(
  //                                           'Selected Staffs: $_selectedStaffs');
  //                                       // Fetch units for the selected property
  //                                     });
  //                                   },
  //                                   buttonStyleData: ButtonStyleData(
  //                                     height: 45,
  //                                     width: 160,
  //                                     padding: const EdgeInsets.only(
  //                                         left: 14, right: 14),
  //                                     decoration: BoxDecoration(
  //                                       borderRadius: BorderRadius.circular(6),
  //                                       color: Colors.white,
  //                                     ),
  //                                     elevation: 2,
  //                                   ),
  //                                   iconStyleData: const IconStyleData(
  //                                     icon: Icon(
  //                                       Icons.arrow_drop_down,
  //                                     ),
  //                                     iconSize: 24,
  //                                     iconEnabledColor: Color(0xFFb0b6c3),
  //                                     iconDisabledColor: Colors.grey,
  //                                   ),
  //                                   dropdownStyleData: DropdownStyleData(
  //                                     decoration: BoxDecoration(
  //                                       borderRadius: BorderRadius.circular(6),
  //                                       color: Colors.white,
  //                                     ),
  //                                     scrollbarTheme: ScrollbarThemeData(
  //                                       radius: const Radius.circular(6),
  //                                       thickness: MaterialStateProperty.all(6),
  //                                       thumbVisibility:
  //                                           MaterialStateProperty.all(true),
  //                                     ),
  //                                   ),
  //                                   menuItemStyleData: const MenuItemStyleData(
  //                                     height: 40,
  //                                     padding:
  //                                         EdgeInsets.only(left: 14, right: 14),
  //                                   ),
  //                                   validator: (value) {
  //                                     if (value == null || value.isEmpty) {
  //                                       return 'Please select an option';
  //                                     }
  //                                     return null;
  //                                   },
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                     SizedBox(height: 8.0),
  //                     Text('Photo ',
  //                         style: TextStyle(
  //                             fontSize: 13,
  //                             fontWeight: FontWeight.bold,
  //                             color: blueColor)),
  //                     SizedBox(
  //                       height: 10,
  //                     ),
  //                     SizedBox(height: 8.0),
  //                     Row(
  //                       children: [
  //                         GestureDetector(
  //                           onTap: () {
  //                             _pickImage().then((_) {
  //                               setState(
  //                                   () {}); // Rebuild the widget after selecting the image
  //                             });
  //                           },
  //                           child: Text(
  //                             '+ Add',
  //                             style: TextStyle(color: Colors.green),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     SizedBox(
  //                       height: 10,
  //                     ),
  //                     _images.isNotEmpty
  //                         ? Row(
  //                             children: [
  //                               Expanded(
  //                                 child: Container(
  //                                   //color: Colors.blue,
  //                                   child: Wrap(
  //                                     spacing:
  //                                         8.0, // Horizontal spacing between items
  //                                     runSpacing:
  //                                         8.0, // Vertical spacing between rows
  //                                     children: List.generate(
  //                                       _images.length,
  //                                       (index) {
  //                                         return Container(
  //                                           // color: Colors.green,
  //                                           width: 85,
  //                                           child: Column(
  //                                             mainAxisAlignment:
  //                                                 MainAxisAlignment.start,
  //                                             crossAxisAlignment:
  //                                                 CrossAxisAlignment.start,
  //                                             children: [
  //                                               Row(
  //                                                 children: [
  //                                                   SizedBox(
  //                                                     width: 60,
  //                                                   ),
  //                                                   GestureDetector(
  //                                                     onTap: () {
  //                                                       setState(() {
  //                                                         _images
  //                                                             .removeAt(index);
  //                                                       });
  //                                                     },
  //                                                     child: Icon(
  //                                                       Icons.close,
  //                                                       color: Colors.grey,
  //                                                     ),
  //                                                   ),
  //                                                 ],
  //                                               ),
  //                                               Row(
  //                                                 mainAxisAlignment:
  //                                                     MainAxisAlignment.start,
  //                                                 crossAxisAlignment:
  //                                                     CrossAxisAlignment.start,
  //                                                 children: [
  //                                                   Container(
  //                                                     // color:Colors.blue,
  //                                                     child: Image.file(
  //                                                       _images[index],
  //                                                       height: 80,
  //                                                       width: 80,
  //                                                       fit: BoxFit.cover,
  //                                                     ),
  //                                                   ),
  //                                                 ],
  //                                               ),
  //                                             ],
  //                                           ),
  //                                         );
  //                                       },
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           )
  //                         : Center(
  //                             child: Text("No images selected."),
  //                           ),
  //                     SizedBox(height: 16.0),
  //                     Text('Message',
  //                         style: TextStyle(
  //                             color: blueColor, fontWeight: FontWeight.bold)),
  //                     Material(
  //                       elevation: 3,
  //                       borderRadius: BorderRadius.circular(8.0),
  //                       child: Container(
  //                         height: 50,
  //                         padding: EdgeInsets.symmetric(
  //                             horizontal: 16.0, vertical: 0),
  //                         decoration: BoxDecoration(
  //                           color: Colors.white,
  //                           borderRadius: BorderRadius.circular(8.0),
  //                           //border: Border.all(color: blueColor),
  //                           // boxShadow: [
  //                           //   BoxShadow(
  //                           //     color: Colors.black.withOpacity(0.2),
  //                           //     offset: Offset(4, 4),
  //                           //     blurRadius: 3,
  //                           //   ),
  //                           // ],
  //                         ),
  //                         child: TextFormField(
  //                           /*    onTap: ()async{
  //                         final DateTime? pickedDate = await showDatePicker(
  //                           context: context,
  //                           initialDate: DateTime.now(),
  //                           firstDate: DateTime(2000),
  //                           lastDate: DateTime(2100),
  //                         );
  //                         if (pickedDate != null) {
  //                           selectedDate = pickedDate;
  //                         }
  //                       },*/
  //                           //  obscureText: widget.obscureText,
  //                           // readOnly: true,
  //                           //keyboardType: widget.keyboardType,
  //                           /* validator: (value) {
  //                         if (value == null || value.isEmpty) {
  //                           state.validate();
  //                         }
  //                         return null;
  //                       },*/
  //                           controller: message,
  //
  //                           decoration: InputDecoration(
  //                             //  suffixIcon: widget.suffixIcon,
  //                             hintStyle:
  //                                 TextStyle(fontSize: 13, color: blueColor),
  //                             border: InputBorder.none,
  //                             //   hintText: widget.hintText,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     SizedBox(height: 16.0),
  //                     Row(
  //                       children: [
  //                         ElevatedButton(
  //                           style: ElevatedButton.styleFrom(
  //                               backgroundColor: blueColor),
  //                           onPressed: () async {
  //                             setState(() {
  //                               isLoading = true;
  //                             });
  //                             SharedPreferences prefs =
  //                                 await SharedPreferences.getInstance();
  //                             String? firstName = prefs.getString("first_name");
  //                             String? lastName = prefs.getString("last_name");
  //                             final DateFormat formatter =
  //                                 DateFormat('yyyy-MM-dd HH:mm:ss');
  //                             String notificationTime =
  //                                 formatter.format(DateTime.now());
  //                             Map<String, dynamic> values = {
  //                               "date":
  //                                   reverseFormatDate(selectedDate.text.trim()),
  //                               "message": message.text.trim(),
  //                               "status": selectedStatus,
  //                               "statusUpdatedBy": "Admin",
  //                               "staffmember_name": _selectedStaffs,
  //                               "staffmember_id": _selectedstaffId,
  //                               "workOrderUpdate_images": _uploadedFileNames!,
  //                               'notificationTime': notificationTime,
  //                             };
  //                             print('normal date ${selectedDate.text.trim()}');
  //                             print(
  //                                 'revers date ${reverseFormatDate(selectedDate.text.trim())}');
  //                             await WorkOrderRepository.updateworkorderSummary(
  //                                     values, widget.workorder_id!)
  //                                 .then((value) {
  //                               setState(() {
  //                                 futureworkorderSummary =
  //                                     WorkOrderRepository.getworkorderSummary(
  //                                         widget.workorder_id!);
  //                               });
  //                             });
  //
  //                             // Save the data and close the dialog
  //                             /*  WorkorderUpdates update = WorkorderUpdates(
  //                                             status: selectedStatus,
  //                                             date: selectedDate,
  //                                             message: message,
  //                                           );*/
  //                             // Here you can handle saving the update data
  //                             // print('Status: ${update.status}');
  //                             // print('Date: ${update.date}');
  //                             // print('Message: ${update.message}');
  //                             Navigator.of(context).pop();
  //                             setState(() {
  //                               isLoading = false;
  //                             }); // Close the dialog
  //                           },
  //                           child: isLoading
  //                               ? Center(
  //                                   child: SpinKitFadingCircle(
  //                                     color: Colors.white,
  //                                     size: 25.0,
  //                                   ),
  //                                 )
  //                               : Text('Save'),
  //                         ),
  //                         TextButton(
  //                           onPressed: () {
  //                             Navigator.of(context).pop(); // Close the dialog
  //                           },
  //                           child: Text(
  //                             'Cancel',
  //                             style: TextStyle(color: blueColor),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
  void showUpdateDialog(BuildContext context) {
    String? selectedStatus;
    TextEditingController message = TextEditingController();
    TextEditingController selectedDate = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.99,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Header with title and close button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Update Work Order',
                            style: TextStyle(
                              color: Color(0xFF101828),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: blueColor),
                                ),
                                child: Icon(Icons.close, color: blueColor)),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      //assined and Due date
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Assigned',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                _isLoadingstaff
                                    ? const Center(
                                  child: SpinKitFadingCircle(
                                    color: Colors.black,
                                    size: 50.0,
                                  ),
                                )
                                    : Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    DropdownButtonHideUnderline(
                                      child: DropdownButtonFormField2<
                                          String>(
                                        decoration: InputDecoration(
                                            border: InputBorder.none),
                                        isExpanded: true,
                                        hint: const Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Select here',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight:
                                                  FontWeight.w400,
                                                  color:
                                                  Color(0xFFb0b6c3),
                                                ),
                                                overflow:
                                                TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        items: staffs.keys
                                            .map((staffmember_id) {
                                          return DropdownMenuItem<String>(
                                            value: staffmember_id,
                                            child: Text(
                                              staffs[staffmember_id]!,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight:
                                                FontWeight.w400,
                                                color: Colors.black87,
                                              ),
                                              overflow:
                                              TextOverflow.ellipsis,
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
                                            print(
                                                'Selected Staffs: $_selectedStaffs');
                                            // Fetch units for the selected property
                                          });
                                        },
                                        buttonStyleData: ButtonStyleData(
                                          height: 50,
                                          width: 160,
                                          padding: const EdgeInsets.only(
                                              left: 14, right: 14),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(8),
                                            border: Border.all(
                                                color:
                                                Colors.grey.shade300),
                                            color: Colors.white,
                                          ),
                                          elevation: 0,
                                        ),
                                        iconStyleData:
                                        const IconStyleData(
                                          icon: Icon(
                                            Icons.arrow_drop_down,
                                          ),
                                          iconSize: 24,
                                          iconEnabledColor:
                                          Color(0xFFb0b6c3),
                                          iconDisabledColor: Colors.grey,
                                        ),
                                        dropdownStyleData:
                                        DropdownStyleData(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(6),
                                            color: Colors.white,
                                          ),
                                          scrollbarTheme:
                                          ScrollbarThemeData(
                                            radius:
                                            const Radius.circular(6),
                                            thickness:
                                            MaterialStateProperty.all(
                                                6),
                                            thumbVisibility:
                                            MaterialStateProperty.all(
                                                true),
                                          ),
                                        ),
                                        menuItemStyleData:
                                        const MenuItemStyleData(
                                          height: 40,
                                          padding: EdgeInsets.only(
                                              left: 14, right: 14),
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.isEmpty) {
                                            return 'Please select an option';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Due Date',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 11),
                                Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border:
                                    Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextFormField(
                                    controller: selectedDate,
                                    readOnly: true,
                                    onTap: () async {
                                      DateTime? pickedDate =
                                      await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2101),
                                        locale: const Locale('en', 'US'),
                                        builder: (BuildContext context,
                                            Widget? child) {
                                          return Theme(
                                            data: ThemeData.light().copyWith(
                                              colorScheme: ColorScheme.light(
                                                primary:
                                                blueColor, // header background color
                                                onPrimary: Colors
                                                    .white, // header text color
                                                onSurface:
                                                blueColor, // body text color
                                              ),
                                              textButtonTheme:
                                              TextButtonThemeData(
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor:
                                                  blueColor, // button text color
                                                ),
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (pickedDate != null) {
                                        setState(() {
                                          selectedDate.text =
                                          "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 16),
                                      hintText: "dd-mm-yyyy",
                                      hintStyle:
                                      TextStyle(color: Colors.grey[400]),
                                      suffixIcon: Icon(Icons.calendar_today,
                                          size: 20, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                DropdownButtonHideUnderline(
                                  child: DropdownButtonFormField2<String>(
                                    decoration: InputDecoration(
                                        border: InputBorder.none),
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
                                    items: [
                                      'New',
                                      'In Progress',
                                      'On Hold',
                                      'Completed'
                                    ].map((status) {
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
                                      height: 50,
                                      width: 160,
                                      padding: const EdgeInsets.only(
                                          left: 14, right: 14),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        color: Colors.white,
                                      ),
                                      elevation: 0,
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
                                        thumbVisibility:
                                        MaterialStateProperty.all(true),
                                      ),
                                    ),
                                    menuItemStyleData: const MenuItemStyleData(
                                      height: 40,
                                      padding:
                                      EdgeInsets.only(left: 14, right: 14),
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
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Message',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 11),
                                Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border:
                                    Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextFormField(
                                    controller: message,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 16),
                                      hintText: "Some description here",
                                      hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Upload Photo Section
                      if (_images.isEmpty)
                        GestureDetector(
                          onTap: () {
                            _pickImage().then((_) {
                              setState(() {});
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.shade300,
                                  style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                // Icon(Icons.upload,
                                //     size: 40, color: Colors.grey[600]),
                                Image.asset(
                                  'assets/icons/Upload.png',
                                  height: 50,
                                  width: 50,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Upload your Photo here',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Maximum File Size is 20MB',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  'Supported File Types are .png, .jpeg, .pdf, .csv',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_images.isEmpty) SizedBox(height: 16),
                      if (_images.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.shade300,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                // crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                      onTap: () {
                                        _pickImage().then((_) {
                                          setState(() {});
                                        });
                                      },
                                      child: Container(
                                          height: 20,
                                          width: 20,
                                          decoration: BoxDecoration(
                                            color: blueColor,
                                            borderRadius:
                                            BorderRadius.circular(7),
                                          ),
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 15,
                                          ))),
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 10, right: 10),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                    WrapCrossAlignment.start,
                                    spacing: 8,
                                    runSpacing: 8,
                                    children:
                                    List.generate(_images.length, (index) {
                                      return Stack(
                                        clipBehavior: Clip.none, //
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(4.0),
                                            child: Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(8),
                                                border: Border.all(
                                                    color:
                                                    Colors.grey.shade300),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                BorderRadius.circular(8),
                                                child: Image.file(
                                                  _images[index],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 0, //
                                            right: 0, //
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _images.removeAt(index);
                                                });
                                              },
                                              child: Container(
                                                width: 18,
                                                height: 18,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black,
                                                      blurRadius: 4,
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  Icons.close,
                                                  size: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: 24),
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: blueColor),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: blueColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  isLoading = true;
                                });

                                SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                                final DateFormat formatter =
                                DateFormat('yyyy-MM-dd HH:mm:ss');
                                String notificationTime =
                                formatter.format(DateTime.now());

                                Map<String, dynamic> values = {
                                  "date": reverseFormatDate(
                                      selectedDate.text.trim()),
                                  "message": message.text.trim(),
                                  "status": selectedStatus,
                                  "statusUpdatedBy": "Admin",
                                  "staffmember_name": _selectedStaffs,
                                  "staffmember_id": _selectedstaffId,
                                  "workOrderUpdate_images": _uploadedFileNames!,
                                  'notificationTime': notificationTime,
                                };

                                await WorkOrderRepository
                                    .updateworkorderSummary(
                                    values, widget.workorder_id!)
                                    .then((value) {
                                  setState(() {
                                    futureworkorderSummary =
                                        WorkOrderRepository.getworkorderSummary(
                                            widget.workorder_id!);
                                  });
                                });

                                Navigator.of(context).pop();
                                setState(() {
                                  isLoading = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blueColor,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: isLoading
                                  ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
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
            );
          },
        );
      },
    );
  }

  final labelStyle = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

  final valueStyle = TextStyle(
    color: blueColor,
    fontWeight: FontWeight.bold,
    fontSize: 13,
  );
  void _showVideoDialog(String videoFile) {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          child: VideoPlayerDialog(
            videoUrl: videoFile,
          ),
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
