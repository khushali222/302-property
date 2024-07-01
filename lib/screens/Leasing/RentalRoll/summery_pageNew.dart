import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/provider/property_summery.dart';
import 'package:three_zero_two_property/screens/Rental/Properties/unit.dart';
import 'package:three_zero_two_property/widgets/rental_widget.dart';

import '../../../Model/unit.dart';
import '../../../constant/constant.dart';
import '../../../model/properties.dart';
import '../../../model/properties_summery.dart';
import '../../../model/unitsummery_propeties.dart';
import '../../../repository/properties_summery.dart';
import 'package:http/http.dart' as http;

import '../../../repository/unit_data.dart';

class Summery_pageLease extends StatefulWidget {
  Rentals properties;
  TenantData? tenants;
  unit_properties? unit;

  //RentalSummary? tenantsummery;

  Summery_pageLease({super.key, required this.properties, this.tenants, this.unit});
  @override
  _Summery_pageLeaseState createState() => _Summery_pageLeaseState();
}

class _Summery_pageLeaseState extends State<Summery_pageLease>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  late Future<List<TenantData>> futurePropertysummery;
  late Future<List<unit_properties>> futureUnitsummery;
  //late Future<List<RentalSummary>> futuresummery;

  unit_properties? unit;
  DateTime? startdate;
  DateTime? enddate;
  TextEditingController startdateController = TextEditingController();
  TextEditingController enddateController = TextEditingController();
  TextEditingController unitnum = TextEditingController();
  TextEditingController street3 = TextEditingController();
  TextEditingController sqft3 = TextEditingController();
  TextEditingController bath3 = TextEditingController();
  TextEditingController bed3 = TextEditingController();

  bool isLoading = false;
  bool iserror = false;
  Future<void> _startDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startdate ?? DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != startdate) {
      setState(() {
        startdate = picked;
        startdateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _endDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: enddate ?? DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != enddate) {
      setState(() {
        enddate = picked;
        enddateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    futureUnitsummery =
        Properies_summery_Repo().fetchunit(widget.properties.rentalId!);
    futurePropertysummery = Properies_summery_Repo()
        .fetchPropertiessummery(widget.properties.rentalId!);
    // futuresummery = Properies_summery_Repo().fetchPropertiessummery(widget.properties.rentalId!);
    _tabController = TabController(length: 3, vsync: this);
    // street3.text = widget.unit!.rentalunitadress!;
    _fetchData();
    fetchunits1();
    fetchLeases();
  }

  File? _image;
  String? _uploadedFileName;
  Future<String?> uploadImage(File imageFile) async {
    print(imageFile.path);
    final String uploadUrl = '${Api_url}/api/images/upload';

    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
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
      });
      _uploadImage(File(image.path));
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      String? fileName = await uploadImage(imageFile);
      setState(() {
        _uploadedFileName = fileName;
      });
    } catch (e) {
      print('Image upload failed: $e');
    }
  }

  bool showdetails = false;
  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  List<List<Widget>> propertyGroups = [];
//  List<List<TextEditingController>> propertyGroupControllers = [];
  List<File?> propertyGroupImages = [];
  List<String?> propertyGroupImagenames = [];
  Widget customTextField(String label, TextEditingController Controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: TextFormField(
        controller: Controller,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          hintText: label,
          // labelText: label,
          // labelStyle: TextStyle(color: Colors.grey[700]),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: BorderSide(color: Color(0xFF8A95A8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: BorderSide(color: Color(0xFF8A95A8), width: 2),
          ),
          contentPadding:
              EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        ),
      ),
    );
  }

  final Properies_summery_Repo unitRepository = Properies_summery_Repo();
  int unitCount = 0;
  int tenentCount = 0;
  Future<void> _fetchData() async {
    try {
      final data = await unitRepository.fetchunit(widget.properties.rentalId!);
      final data1 = await Properies_summery_Repo()
          .fetchPropertiessummery(widget.properties.rentalId!);
      // final data1 = await unitRepository.fetchunit(widget.properties.rentalId!);
      setState(() {
        unitCount = data.length;
        tenentCount = data1.length;
      });
    } catch (e) {
      // Handle error
      print(e);
    }
  }

  List<unit_properties> data = [];
  final Properies_summery_Repo unit1Repository = Properies_summery_Repo();
  Future<void> fetchunits1() async {
    //  try {
    final fetchedunit1 = await unit1Repository.fetchunit(widget.unit!.unitId!);
    print(widget.unit!.unitId!);
    print('hello');
    setState(() {
      print(widget.unit!.unitId!);
      print('hello');
      data = fetchedunit1;
      isLoading = false;
    });
    //} catch (e) {
    setState(() {
      isLoading = false;
    });
    //print('Failed to load leases: $e');
    //}
  }

  //lease table

  final UnitData leaseRepository = UnitData();

  List<unit_lease> leases = [];

  bool isloading = true;

  Future<void> fetchLeases() async {
    //  try {
    final fetchedLeases =
        await leaseRepository.fetchUnitLeases(widget.unit!.unitId!);
    print(widget.unit!.unitId!);
    print('hello');
    setState(() {
      print(widget.unit!.unitId!);
      print('hello');
      leases = fetchedLeases;
      isloading = false;
    });
    //} catch (e) {
    setState(() {
      isloading = false;
    });
    //print('Failed to load leases: $e');
    //}
  }

  String getStatus(String startDate, String endDate) {
    final now = DateTime.now();
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    return (now.isAfter(start) && now.isBefore(end)) ? 'Active' : 'Inactive';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Custom Tabs'),
      // ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Text('${widget.properties.rentalAddress}',
                  style: TextStyle(
                      color: Color.fromRGBO(21, 43, 81, 1),
                      fontWeight: FontWeight.bold)),
              Spacer(),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Material(
                      elevation: 3,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                      child: Container(
                        height: 40,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(21, 43, 81, 1),
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                        child: Center(
                            child: Text(
                          "Back",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, color: Colors.white),
                        )),
                      ),
                    ),
                  ),
                ],
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
              Text('${widget.properties.propertyTypeData?.propertyType}',
                  style: TextStyle(
                      color: Color(0xFF8A95A8),
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            height: 60,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
              // color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorWeight: 5,
              //indicatorPadding: EdgeInsets.symmetric(horizontal: 1),
              indicatorColor: Color.fromRGBO(21, 43, 81, 1),
              labelColor: Color.fromRGBO(21, 43, 81, 1),
              unselectedLabelColor: Color.fromRGBO(21, 43, 81, 1),
              tabs: [
                Tab(text: 'Summary'),
                Tab(
                  text: 'Units($unitCount)',
                ),
                StatefulBuilder(
                  builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    return Tab(text: 'Tenant($tenentCount)');
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Summary_page(),

                // showdetails
                //     ? unitScreen(properties: widget.properties
                //         //properties: widget.properties,
                //       //  unit: unit,
                //       )
                //     : Unit_page(),
                showdetails ? unitScreen1(context, unit!) : Unit_page(context),
                // unitScreen(),
                // Center(child: Text('Content of Tab 2')),
                //  Container(color:Colors.blue),
                Tenants(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Summary_page() {
    print("$image_url${widget.properties.rentalImage}");
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              height: 250,
              width: MediaQuery.of(context).size.width * .94,
              decoration: BoxDecoration(
                border: Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      // Container(
                      //   // height: 150,
                      //   width: 150,
                      //   decoration: BoxDecoration(color: Colors.blue),
                      //   child: Image.network(
                      //     "$image_url${widget.properties.rentalImage}"??'https://st.depositphotos.com/1763233/3344/i/450/depositphotos_33445577-stock-photo-wooden-house.jpg',
                      //     fit: BoxFit.fill,
                      //     height: 100,
                      //   ),
                      // ),
                      Container(
                        width: 150,
                        decoration: BoxDecoration(color: Colors.blue),
                        child: Image.network(
                          widget.properties.rentalImage != null &&
                                  widget.properties.rentalImage!.isNotEmpty
                              ? "$image_url${widget.properties.rentalImage}"
                              : 'https://i.pinimg.com/originals/59/11/81/591181790b40c5e1f8cc04b55ebdbf25.jpg',
                          fit: BoxFit.fill,
                          height: 100,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Property Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(21, 43, 81, 1),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3),
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text('Address',
                          style: TextStyle(
                              color: Color(0xFF8A95A8),
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 3),
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                          '${widget.properties.propertyTypeData?.propertyType}',
                          style: TextStyle(
                              color: Color.fromRGBO(21, 43, 81, 1),
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 3),
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text('${widget.properties.rentalAddress}',
                          style: TextStyle(
                            color: Color.fromRGBO(21, 43, 81, 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          )),
                    ],
                  ),
                  SizedBox(height: 3),
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '${widget.properties.rentalCity},',
                        style: TextStyle(
                            color: Color.fromRGBO(21, 43, 81, 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                      SizedBox(width: 3),
                      Text(
                        '${widget.properties.rentalState},',
                        style: TextStyle(
                            color: Color.fromRGBO(21, 43, 81, 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '${widget.properties.rentalCountry},',
                        style: TextStyle(
                            color: Color.fromRGBO(21, 43, 81, 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                      SizedBox(width: 3),
                      Text(
                        '${widget.properties.rentalPostcode}',
                        style: TextStyle(
                            color: Color.fromRGBO(21, 43, 81, 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Rental Owners",
              style: TextStyle(
                  color: Color.fromRGBO(21, 43, 81, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                defaultColumnWidth: IntrinsicColumnWidth(),
                border: TableBorder.all(color: Colors.black),
                children: [
                  TableRow(
                    decoration: BoxDecoration(),
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Field Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(21, 43, 81, 1),
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Company Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 43, 81, 1),
                              )),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('E-mail',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 43, 81, 1),
                              )),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Phone Number',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 43, 81, 1),
                              )),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Home Number',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 43, 81, 1),
                              )),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Business Number',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 43, 81, 1),
                              )),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    decoration: BoxDecoration(
                      border: Border.symmetric(horizontal: BorderSide.none),
                    ),
                    children: [
                      TableCell(
                        child: Container(
                          height: 40,
                          child: Center(
                              child: Text(
                            '${widget.properties.rentalOwnerData?.rentalOwnerFirstName}',
                            style: TextStyle(
                              color: Color.fromRGBO(21, 43, 81, 1),
                            ),
                          )),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          height: 40,
                          child: Center(
                            child: Text(
                              '${widget.properties.rentalOwnerData?.rentalOwnerCompanyName}',
                              style: TextStyle(
                                color: Color.fromRGBO(21, 43, 81, 1),
                              ),
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          height: 40,
                          child: Center(
                              child: Text(
                            '${widget.properties.rentalOwnerData?.rentalOwnerPrimaryEmail}',
                            style: TextStyle(
                              color: Color.fromRGBO(21, 43, 81, 1),
                            ),
                          )),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          height: 40,
                          child: Center(
                              child: Text(
                            '${widget.properties.rentalOwnerData?.rentalOwnerPhoneNumber}',
                            style: TextStyle(
                              color: Color.fromRGBO(21, 43, 81, 1),
                            ),
                          )),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          height: 40,
                          child: Center(
                              child: Text(
                            '${widget.properties.rentalOwnerData?.rentalOwnerHomeNumber}',
                            style: TextStyle(
                              color: Color.fromRGBO(21, 43, 81, 1),
                            ),
                          )),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          height: 40,
                          child: Center(
                              child: Text(
                            '${widget.properties.rentalOwnerData?.rentalOwnerBuisinessNumber}',
                            style: TextStyle(
                              color: Color.fromRGBO(21, 43, 81, 1),
                            ),
                          )),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Staff Details",
              style: TextStyle(
                  color: Color.fromRGBO(21, 43, 81, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Table(
              border: TableBorder.all(),
              children: [
                TableRow(children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Staff Member'),
                    ),
                  ),
                ]),
                TableRow(children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          '${widget.properties.staffMemberData!.staffmemberName}'),
                    ),
                  ),
                ])
              ],
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Tenants(BuildContext context) {
    return FutureBuilder<List<TenantData>>(
      future: Properies_summery_Repo()
          .fetchPropertiessummery(widget.properties.rentalId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Center(
                child: SpinKitFadingCircle(
              color: Colors.black,
              size: 40.0,
            )),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<TenantData> tenants = snapshot.data ?? [];
          print(snapshot.data!.length);
          //   Provider.of<Tenants_counts>(context).setOwnerDetails(tenants.length);
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 5),
            itemCount: tenants.length,
            itemBuilder: (context, index) {
              // String fullName = '${tenants[index].leaseTenantData} ${tenants[index].tenantLastName}';
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 165,
                  width: MediaQuery.of(context).size.width * .9,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Color.fromRGBO(21, 43, 81, 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 15,
                          ),
                          Container(
                            height: 30,
                            width: 30,
                            // width: MediaQuery.of(context).size.width * .4,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(21, 43, 81, 1),
                              border: Border.all(
                                  color: Color.fromRGBO(21, 43, 81, 1)),
                              // color: Colors.blue,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: FaIcon(
                                FontAwesomeIcons.user,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 4,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    // ('Tenant: ${rentalSummary.leaseTenantData[0].tenantData.tenantFirstName} ${rentalSummary.leaseTenantData[0].tenantData.tenantLastName}')
                                    //  '${tenants[index].leaseTenantData![0].tenantData?.tenantFirstName} ${tenants[index].leaseTenantData![0].tenantData?.
                                    //  tenantLastName}'
                                    '${tenants[index].firstName} ${tenants[index].lastName}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(21, 43, 81, 1),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    formatDate2(tenants[index].updatedAt!),
                                    // '${widget.properties.rentalAddress}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF8A95A8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Spacer(),
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  bool isChecked =
                                      false; // Moved isChecked inside the StatefulBuilder
                                  return StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter setState) {
                                      return AlertDialog(
                                        backgroundColor: Colors.white,
                                        surfaceTintColor: Colors.white,
                                        content: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 0,
                                                  ),
                                                  Text(
                                                    "Move out Tenants",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color.fromRGBO(
                                                            21, 43, 81, 1),
                                                        fontSize: 15),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 0,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "Select tenants to move out. If everyone is moving, the lease will end on the last move-out date. If some tenants are staying, you’ll need to renew the lease. Note: Renters insurance policies will be permanently deleted upon move-out.",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 13,
                                                        color:
                                                            Color(0xFF8A95A8),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 0,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 15,
                                              ),
                                              Material(
                                                elevation: 3,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Container(
                                                  // height: 280,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .65,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Color.fromRGBO(
                                                            21, 43, 81, 1)),
                                                    // color: Colors.blue,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 5,
                                                                right: 5),
                                                        child: Table(
                                                          border:
                                                              TableBorder.all(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1)),
                                                          children: [
                                                            TableRow(children: [
                                                              TableCell(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    'Address/Unit',
                                                                    style: TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            13),
                                                                  ),
                                                                ),
                                                              ),
                                                              TableCell(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    'Lease Type',
                                                                    style: TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            13),
                                                                  ),
                                                                ),
                                                              ),
                                                              TableCell(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    'Start End',
                                                                    style: TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            13),
                                                                  ),
                                                                ),
                                                              ),
                                                            ]),
                                                            TableRow(children: [
                                                              TableCell(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    '${widget.properties.rentalAddress}',
                                                                    style: TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                ),
                                                              ),
                                                              TableCell(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    ' ${tenants[index].leaseType}',
                                                                    style: TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                ),
                                                              ),
                                                              TableCell(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    ' ${tenants[index].createdAt} ${tenants[index].updatedAt}',
                                                                    style: TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                ),
                                                              ),
                                                            ])
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 5,
                                                                right: 5),
                                                        child: Table(
                                                          border:
                                                              TableBorder.all(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1)),
                                                          children: [
                                                            TableRow(children: [
                                                              TableCell(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    'Tenants',
                                                                    style: TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            13),
                                                                  ),
                                                                ),
                                                              ),
                                                              TableCell(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    'Notice Given Date',
                                                                    style: TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            13),
                                                                  ),
                                                                ),
                                                              ),
                                                              TableCell(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    'Move-Out Date',
                                                                    style: TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            13),
                                                                  ),
                                                                ),
                                                              ),
                                                            ]),
                                                            TableRow(children: [
                                                              TableCell(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    ' ${tenants[index].firstName} ${tenants[index].lastName}',
                                                                    style: TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                ),
                                                              ),
                                                              TableCell(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Row(
                                                                    children: [
                                                                      SizedBox(
                                                                          width:
                                                                              2),
                                                                      Expanded(
                                                                        child:
                                                                            Material(
                                                                          elevation:
                                                                              4,
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                50,
                                                                            width:
                                                                                MediaQuery.of(context).size.width * .4,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(2),
                                                                              border: Border.all(
                                                                                color: Color(0xFF8A95A8),
                                                                              ),
                                                                            ),
                                                                            child:
                                                                                Stack(
                                                                              children: [
                                                                                Positioned.fill(
                                                                                  child: TextField(
                                                                                    onChanged: (value) {
                                                                                      setState(() {
                                                                                        // startdatederror = false;
                                                                                        // _selectDate(context);
                                                                                      });
                                                                                    },
                                                                                    controller: startdateController,
                                                                                    cursorColor: Color.fromRGBO(21, 43, 81, 1),
                                                                                    decoration: InputDecoration(
                                                                                      hintText: "mm/dd/yyyy",
                                                                                      hintStyle: TextStyle(
                                                                                        fontSize: MediaQuery.of(context).size.width * .037,
                                                                                        color: Color(0xFF8A95A8),
                                                                                      ),
                                                                                      // enabledBorder: startdatederror
                                                                                      //     ? OutlineInputBorder(
                                                                                      //   borderRadius:
                                                                                      //   BorderRadius.circular(3),
                                                                                      //   borderSide: BorderSide(
                                                                                      //     color: Colors.red,
                                                                                      //   ),
                                                                                      // )
                                                                                      //     : InputBorder.none,
                                                                                      border: InputBorder.none,
                                                                                      contentPadding: EdgeInsets.all(12),
                                                                                      suffixIcon: IconButton(
                                                                                        icon: Icon(Icons.calendar_today),
                                                                                        onPressed: () => _startDate(context),
                                                                                      ),
                                                                                    ),
                                                                                    readOnly: true,
                                                                                    onTap: () {
                                                                                      _startDate(context);
                                                                                      setState(() {
                                                                                        //startdatederror = false;
                                                                                      });
                                                                                    },
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              2),
                                                                    ],
                                                                  ),
                                                                  // Text(
                                                                  //   '${widget.properties.staffMemberData!.staffmemberName}',
                                                                  //   style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1),fontWeight: FontWeight.w500,fontSize: 12),
                                                                  // ),
                                                                ),
                                                              ),
                                                              TableCell(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Row(
                                                                    children: [
                                                                      SizedBox(
                                                                          width:
                                                                              2),
                                                                      Expanded(
                                                                        child:
                                                                            Material(
                                                                          elevation:
                                                                              4,
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                50,
                                                                            //width: MediaQuery.of(context).size.width * .6,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(2),
                                                                              border: Border.all(
                                                                                color: Color(0xFF8A95A8),
                                                                              ),
                                                                            ),
                                                                            child:
                                                                                Stack(
                                                                              children: [
                                                                                Positioned.fill(
                                                                                  child: TextField(
                                                                                    onChanged: (value) {
                                                                                      setState(() {
                                                                                        // startdatederror = false;
                                                                                        // _selectDate(context);
                                                                                      });
                                                                                    },
                                                                                    controller: enddateController,
                                                                                    cursorColor: Color.fromRGBO(21, 43, 81, 1),
                                                                                    decoration: InputDecoration(
                                                                                      hintText: "mm/dd/yyyy",
                                                                                      hintStyle: TextStyle(
                                                                                        fontSize: MediaQuery.of(context).size.width * .037,
                                                                                        color: Color(0xFF8A95A8),
                                                                                      ),
                                                                                      // enabledBorder: startdatederror
                                                                                      //     ? OutlineInputBorder(
                                                                                      //   borderRadius:
                                                                                      //   BorderRadius.circular(3),
                                                                                      //   borderSide: BorderSide(
                                                                                      //     color: Colors.red,
                                                                                      //   ),
                                                                                      // )
                                                                                      //     : InputBorder.none,
                                                                                      border: InputBorder.none,
                                                                                      contentPadding: EdgeInsets.all(12),
                                                                                      suffixIcon: IconButton(
                                                                                        icon: Icon(Icons.calendar_today),
                                                                                        onPressed: () => _endDate(context),
                                                                                      ),
                                                                                    ),
                                                                                    readOnly: true,
                                                                                    onTap: () {
                                                                                      _endDate(context);
                                                                                      setState(() {
                                                                                        //startdatederror = false;
                                                                                      });
                                                                                    },
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              2),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ])
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Material(
                                                      elevation: 3,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(5),
                                                      ),
                                                      child: Container(
                                                        height: 30,
                                                        width: 60,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(5),
                                                          ),
                                                        ),
                                                        child: Center(
                                                            child: Text(
                                                          "Close",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Color
                                                                  .fromRGBO(
                                                                      21,
                                                                      43,
                                                                      81,
                                                                      1)),
                                                        )),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Material(
                                                    elevation: 3,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                    child: Container(
                                                      height: 30,
                                                      width: 80,
                                                      decoration: BoxDecoration(
                                                        color: Color.fromRGBO(
                                                            21, 43, 81, 1),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(5),
                                                        ),
                                                      ),
                                                      child: Center(
                                                          child: Text(
                                                        "Move Out",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                            fontSize: 13),
                                                      )),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 15,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            child: Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.rightFromBracket,
                                  size: 17,
                                  color: Color.fromRGBO(21, 43, 81, 1),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "Move out",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 65,
                          ),
                          Text(
                            '${tenants[index].createdAt}  to',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(21, 43, 81, 1),
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 65,
                          ),
                          Text(
                            // '${tenants[index].updatedAt}',
                            '${tenants[index].updatedAt}',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(21, 43, 81, 1),
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 65,
                          ),
                          FaIcon(
                            FontAwesomeIcons.phone,
                            size: 15,
                            color: Color.fromRGBO(21, 43, 81, 1),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            '${tenants[index].phoneNumber}',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(21, 43, 81, 1),
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 65,
                          ),
                          FaIcon(
                            FontAwesomeIcons.solidEnvelope,
                            size: 15,
                            color: Color.fromRGBO(21, 43, 81, 1),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            '${tenants[index].email}',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(21, 43, 81, 1),
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Unit_page(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            if (!showdetails &&
                widget.properties.propertyTypeData!.isMultiunit! == false)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: FutureBuilder<List<unit_properties>>(
                  future: Properies_summery_Repo()
                      .fetchunit(widget.properties.rentalId!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: SpinKitFadingCircle(
                        color: Colors.black,
                        size: 40.0,
                      ));
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No data available'));
                    }
                    final data = snapshot.data!;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                            color: Color.fromRGBO(21, 43, 83, 1),
                          )),
                          child: DataTable(
                            // headingRowColor: MaterialStateColor.resolveWith(
                            //         (states) => Color.fromRGBO(21, 43, 83, 1)),
                            headingTextStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            columnSpacing: 20,
                            dataRowHeight: 60,
                            columns: [
                              DataColumn(
                                label: Text(
                                  'TENANTS',
                                  style: TextStyle(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'ACTION',
                                  style: TextStyle(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            rows: data.map((unitData) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      ' ${tenentCount}',
                                      style:
                                          TextStyle(color: Color(0xFF8A95A8)),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        // showdetails = !showdetails;
                                        showdetails = true;
                                        unit = unitData;
                                      });

                                      // if (showdetails) {
                                      //   // Navigator.push(
                                      //   //   context,
                                      //   //   MaterialPageRoute(builder: (context) => unitScreen()),
                                      //   // );
                                      //   // unitScreen();
                                      //   Container(
                                      //       color: Colors.blue,
                                      //     child: Text("data"),
                                      //   );
                                      // }
                                    },
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: FaIcon(
                                        FontAwesomeIcons.edit,
                                        size: 15,
                                        color: Color(0xFF8A95A8),
                                      ),
                                      onPressed: () {
                                        sqft3.text = unitData.rentalsqft!;
                                        if (widget.properties.propertyTypeData!
                                                    .isMultiunit! ==
                                                false &&
                                            widget.properties.propertyTypeData!
                                                    .propertyType ==
                                                'Residential')
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              bool isChecked =
                                                  false; // Moved isChecked inside the StatefulBuilder
                                              return StatefulBuilder(
                                                builder: (BuildContext context,
                                                    StateSetter setState) {
                                                  return AlertDialog(
                                                    backgroundColor:
                                                        Colors.white,
                                                    surfaceTintColor:
                                                        Colors.white,
                                                    content:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "Add Unit Details",
                                                                style:
                                                                    TextStyle(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              Spacer(),
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: Icon(
                                                                      Icons
                                                                          .close,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "SQFT",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            child: Material(
                                                              elevation: 3,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    sqft3,
                                                                cursorColor:
                                                                    Colors
                                                                        .black,
                                                                decoration:
                                                                    InputDecoration(
                                                                  //  hintText: label,
                                                                  // labelText: label,
                                                                  // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                Color(0xFF8A95A8)),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide: BorderSide(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  contentPadding: EdgeInsets.symmetric(
                                                                      vertical:
                                                                          10.0,
                                                                      horizontal:
                                                                          10.0),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "bath",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            child: Material(
                                                              elevation: 3,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    bath3,
                                                                cursorColor:
                                                                    Colors
                                                                        .black,
                                                                decoration:
                                                                    InputDecoration(
                                                                  //  hintText: label,
                                                                  // labelText: label,
                                                                  // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                Color(0xFF8A95A8)),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide: BorderSide(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  contentPadding: EdgeInsets.symmetric(
                                                                      vertical:
                                                                          10.0,
                                                                      horizontal:
                                                                          10.0),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "bed",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            child: Material(
                                                              elevation: 3,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    bed3,
                                                                cursorColor:
                                                                    Colors
                                                                        .black,
                                                                decoration:
                                                                    InputDecoration(
                                                                  //  hintText: label,
                                                                  // labelText: label,
                                                                  // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                Color(0xFF8A95A8)),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide: BorderSide(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  contentPadding: EdgeInsets.symmetric(
                                                                      vertical:
                                                                          10.0,
                                                                      horizontal:
                                                                          10.0),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Photo',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 8.0),
                                                          Row(
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  _pickImage()
                                                                      .then(
                                                                          (_) {
                                                                    setState(
                                                                        () {}); // Rebuild the widget after selecting the image
                                                                  });
                                                                },
                                                                child: Text(
                                                                  '+ Add',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .green),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          _image != null
                                                              ? Column(
                                                                  children: [
                                                                    Image.file(
                                                                      _image!,
                                                                      height:
                                                                          80,
                                                                      width: 80,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                    Text(
                                                                        _uploadedFileName ??
                                                                            ""),
                                                                  ],
                                                                )
                                                              : Text(''),
                                                          SizedBox(height: 8.0),
                                                          Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 0,
                                                              ),
                                                              GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  if (sqft3.text
                                                                      .isEmpty) {
                                                                    setState(
                                                                        () {
                                                                      iserror =
                                                                          true;
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      isLoading =
                                                                          true;
                                                                      iserror =
                                                                          false;
                                                                    });
                                                                    SharedPreferences
                                                                        prefs =
                                                                        await SharedPreferences
                                                                            .getInstance();

                                                                    String? id =
                                                                        prefs.getString(
                                                                            "adminId");
                                                                    Properies_summery_Repo()
                                                                        .Editunit(
                                                                            rentalsqft: sqft3
                                                                                .text,
                                                                            rentalunitadress: street3
                                                                                .text,
                                                                            rentalbath: bath3
                                                                                .text,
                                                                            rentalbed: bed3
                                                                                .text,
                                                                            unitId: unitData
                                                                                .unitId,
                                                                            adminId:
                                                                                id,
                                                                            rentalId: unitData
                                                                                .rentalId)
                                                                        .then(
                                                                            (value) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            false;
                                                                      });
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(
                                                                              true);
                                                                      reload_Screen();
                                                                    }).catchError(
                                                                            (e) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            false;
                                                                      });
                                                                    });
                                                                  }
                                                                },
                                                                child: Material(
                                                                  elevation: 3,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            5),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width: 80,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                        Radius.circular(
                                                                            5),
                                                                      ),
                                                                    ),
                                                                    child: Center(
                                                                        child: Text(
                                                                      "Save",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color:
                                                                              Colors.white),
                                                                    )),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 10),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Material(
                                                                  elevation: 3,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            5),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width: 80,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                        Radius.circular(
                                                                            5),
                                                                      ),
                                                                    ),
                                                                    child: Center(
                                                                        child: Text(
                                                                      "Cancel",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color: Color.fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1)),
                                                                    )),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 8.0),
                                                          if (iserror)
                                                            Text(
                                                              "Please fill in all fields correctly.",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .redAccent),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        if (widget.properties.propertyTypeData!
                                                    .isMultiunit! ==
                                                false &&
                                            widget.properties.propertyTypeData!
                                                    .propertyType ==
                                                'Commercial')
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              bool isChecked =
                                                  false; // Moved isChecked inside the StatefulBuilder
                                              return StatefulBuilder(
                                                builder: (BuildContext context,
                                                    StateSetter setState) {
                                                  return AlertDialog(
                                                    backgroundColor:
                                                        Colors.white,
                                                    surfaceTintColor:
                                                        Colors.white,
                                                    content:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "Add Unit Details",
                                                                style:
                                                                    TextStyle(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              Spacer(),
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: Icon(
                                                                      Icons
                                                                          .close,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "SQFT",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            child: Material(
                                                              elevation: 3,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    sqft3,
                                                                cursorColor:
                                                                    Colors
                                                                        .black,
                                                                decoration:
                                                                    InputDecoration(
                                                                  //  hintText: label,
                                                                  // labelText: label,
                                                                  // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                Color(0xFF8A95A8)),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide: BorderSide(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  contentPadding: EdgeInsets.symmetric(
                                                                      vertical:
                                                                          10.0,
                                                                      horizontal:
                                                                          10.0),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Photo',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 8.0),
                                                          Row(
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  _pickImage()
                                                                      .then(
                                                                          (_) {
                                                                    setState(
                                                                        () {}); // Rebuild the widget after selecting the image
                                                                  });
                                                                },
                                                                child: Text(
                                                                  '+ Add',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .green),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 8.0),
                                                          _image != null
                                                              ? Column(
                                                                  children: [
                                                                    Image.file(
                                                                      _image!,
                                                                      height:
                                                                          80,
                                                                      width: 80,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                    Text(
                                                                        _uploadedFileName ??
                                                                            ""),
                                                                  ],
                                                                )
                                                              : Text(''),
                                                          SizedBox(height: 8.0),
                                                          Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 0,
                                                              ),
                                                              GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  if (sqft3.text
                                                                      .isEmpty) {
                                                                    setState(
                                                                        () {
                                                                      iserror =
                                                                          true;
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      isLoading =
                                                                          true;
                                                                      iserror =
                                                                          false;
                                                                    });
                                                                    SharedPreferences
                                                                        prefs =
                                                                        await SharedPreferences
                                                                            .getInstance();
                                                                    String? id =
                                                                        prefs.getString(
                                                                            "adminId");
                                                                    Properies_summery_Repo()
                                                                        .Editunit(
                                                                      rentalsqft:
                                                                          sqft3
                                                                              .text,
                                                                      unitId: unitData
                                                                          .unitId!,
                                                                    )
                                                                        .then(
                                                                            (value) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            false;
                                                                      });

                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(
                                                                              true);
                                                                    }).catchError(
                                                                            (e) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            false;
                                                                      });
                                                                    });
                                                                  }
                                                                },
                                                                child: Material(
                                                                  elevation: 3,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            5),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width: 80,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                        Radius.circular(
                                                                            5),
                                                                      ),
                                                                    ),
                                                                    child: Center(
                                                                        child: Text(
                                                                      "Save",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color:
                                                                              Colors.white),
                                                                    )),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 10),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Material(
                                                                  elevation: 3,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            5),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width: 80,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                        Radius.circular(
                                                                            5),
                                                                      ),
                                                                    ),
                                                                    child: Center(
                                                                        child: Text(
                                                                      "Cancel",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color: Color.fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1)),
                                                                    )),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 8.0),
                                                          if (iserror)
                                                            Text(
                                                              "Please fill in all fields correctly.",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .redAccent),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (widget.properties.propertyTypeData!.isMultiunit!)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (widget.properties.propertyTypeData!.isMultiunit! &&
                          widget.properties.propertyTypeData!.propertyType ==
                              'Residential')
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            bool isChecked =
                                false; // Moved isChecked inside the StatefulBuilder
                            return StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  surfaceTintColor: Colors.white,
                                  content: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Add Unit Details",
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Spacer(),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Unit Number",
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 1),
                                          child: Material(
                                            elevation: 3,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            child: TextFormField(
                                              controller: unitnum,
                                              cursorColor: Colors.black,
                                              decoration: InputDecoration(
                                                //  hintText: label,
                                                // labelText: label,
                                                // labelStyle: TextStyle(color: Colors.grey[700]),
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide.none,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Street Address",
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 1),
                                          child: Material(
                                            elevation: 3,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            child: TextFormField(
                                              controller: street3,
                                              cursorColor: Colors.black,
                                              decoration: InputDecoration(
                                                //  hintText: label,
                                                // labelText: label,
                                                // labelStyle: TextStyle(color: Colors.grey[700]),
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide.none,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "SQFT",
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 1),
                                          child: Material(
                                            elevation: 3,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            child: TextFormField(
                                              controller: sqft3,
                                              cursorColor: Colors.black,
                                              decoration: InputDecoration(
                                                //  hintText: label,
                                                // labelText: label,
                                                // labelStyle: TextStyle(color: Colors.grey[700]),
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide.none,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "bath",
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 1),
                                          child: Material(
                                            elevation: 3,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            child: TextFormField(
                                              controller: bath3,
                                              cursorColor: Colors.black,
                                              decoration: InputDecoration(
                                                //  hintText: label,
                                                // labelText: label,
                                                // labelStyle: TextStyle(color: Colors.grey[700]),
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide.none,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "bed",
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 1),
                                          child: Material(
                                            elevation: 3,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            child: TextFormField(
                                              controller: bed3,
                                              cursorColor: Colors.black,
                                              decoration: InputDecoration(
                                                //  hintText: label,
                                                // labelText: label,
                                                // labelStyle: TextStyle(color: Colors.grey[700]),
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide.none,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Photo',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _pickImage().then((_) {
                                                  setState(
                                                      () {}); // Rebuild the widget after selecting the image
                                                });
                                              },
                                              child: Text(
                                                '+ Add',
                                                style: TextStyle(
                                                    color: Colors.green),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        _image != null
                                            ? Column(
                                                children: [
                                                  Image.file(
                                                    _image!,
                                                    height: 80,
                                                    width: 80,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  Text(_uploadedFileName ?? ""),
                                                ],
                                              )
                                            : Text(''),
                                        SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 0,
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                if (unitnum.text.isEmpty ||
                                                    street3.text.isEmpty ||
                                                    sqft3.text.isEmpty ||
                                                    bath3.text.isEmpty ||
                                                    bed3.text.isEmpty) {
                                                  setState(() {
                                                    iserror = true;
                                                  });
                                                } else {
                                                  setState(() {
                                                    isLoading = true;
                                                    iserror = false;
                                                  });
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  String? id = prefs
                                                      .getString("adminId");
                                                  Properies_summery_Repo()
                                                      .addUnit(
                                                    adminId: id!,
                                                    rentalId: widget
                                                        .properties.rentalId,
                                                    rentalunit: unitnum.text,
                                                    rentalunitadress:
                                                        street3.text,
                                                    rentalsqft: sqft3.text,
                                                    rentalbath: bath3.text,
                                                    rentalbed: bed3.text,
                                                  )
                                                      .then((value) {
                                                    setState(() {
                                                      isLoading = false;
                                                      data.add(unit_properties(
                                                        adminId: id!,
                                                        rentalId: widget
                                                            .properties
                                                            .rentalId,
                                                        rentalunit:
                                                            unitnum.text,
                                                        rentalunitadress:
                                                            street3.text,
                                                        rentalsqft: sqft3.text,
                                                        rentalbath: bath3.text,
                                                        rentalbed: bed3.text,
                                                      ));
                                                    });
                                                    Navigator.pop(
                                                        context, true);
                                                  }).catchError((e) {
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                  });
                                                }
                                              },
                                              child: Material(
                                                elevation: 3,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                                child: Container(
                                                  height: 30,
                                                  width: 80,
                                                  decoration: BoxDecoration(
                                                    color: Color.fromRGBO(
                                                        21, 43, 81, 1),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                  ),
                                                  child: Center(
                                                      child: Text(
                                                    "Save",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white),
                                                  )),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Material(
                                                elevation: 3,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                                child: Container(
                                                  height: 30,
                                                  width: 80,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                  ),
                                                  child: Center(
                                                      child: Text(
                                                    "Cancel",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Color.fromRGBO(
                                                            21, 43, 81, 1)),
                                                  )),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.0),
                                        if (iserror)
                                          Text(
                                            "Please fill in all fields correctly.",
                                            style: TextStyle(
                                                color: Colors.redAccent),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      if (widget.properties.propertyTypeData!.isMultiunit! &&
                          widget.properties.propertyTypeData!.propertyType ==
                              'Commercial')
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            bool isChecked =
                                false; // Moved isChecked inside the StatefulBuilder
                            return StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  surfaceTintColor: Colors.white,
                                  content: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Add Unit Details",
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Spacer(),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Unit Number",
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 1),
                                          child: Material(
                                            elevation: 3,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            child: TextFormField(
                                              controller: unitnum,
                                              cursorColor: Colors.black,
                                              decoration: InputDecoration(
                                                //  hintText: label,
                                                // labelText: label,
                                                // labelStyle: TextStyle(color: Colors.grey[700]),
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide.none,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Street Address",
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 1),
                                          child: Material(
                                            elevation: 3,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            child: TextFormField(
                                              controller: street3,
                                              cursorColor: Colors.black,
                                              decoration: InputDecoration(
                                                //  hintText: label,
                                                // labelText: label,
                                                // labelStyle: TextStyle(color: Colors.grey[700]),
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide.none,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "SQFT",
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 1),
                                          child: Material(
                                            elevation: 3,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            child: TextFormField(
                                              controller: sqft3,
                                              cursorColor: Colors.black,
                                              decoration: InputDecoration(
                                                //  hintText: label,
                                                // labelText: label,
                                                // labelStyle: TextStyle(color: Colors.grey[700]),
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide.none,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF8A95A8),
                                                      width: 2),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Photo',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _pickImage().then((_) {
                                                  setState(
                                                      () {}); // Rebuild the widget after selecting the image
                                                });
                                              },
                                              child: Text(
                                                '+ Add',
                                                style: TextStyle(
                                                    color: Colors.green),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.0),
                                        _image != null
                                            ? Column(
                                                children: [
                                                  Image.file(
                                                    _image!,
                                                    height: 80,
                                                    width: 80,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  Text(_uploadedFileName ?? ""),
                                                ],
                                              )
                                            : Text(''),
                                        SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 0,
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                if (unitnum.text.isEmpty ||
                                                    street3.text.isEmpty ||
                                                    sqft3.text.isEmpty) {
                                                  setState(() {
                                                    iserror = true;
                                                  });
                                                } else {
                                                  setState(() {
                                                    isLoading = true;
                                                    iserror = false;
                                                  });
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  String? id = prefs
                                                      .getString("adminId");
                                                  Properies_summery_Repo()
                                                      .addUnit(
                                                    adminId: id!,
                                                    rentalId: widget
                                                        .properties.rentalId,
                                                    rentalunitadress:
                                                        street3.text,
                                                    rentalsqft: sqft3.text,
                                                    rentalunit: unitnum.text,
                                                  )
                                                      .then((value) {
                                                    setState(() {
                                                      isLoading = false;
                                                      data.add(unit_properties(
                                                        adminId: id!,
                                                        rentalId: widget
                                                            .properties
                                                            .rentalId,
                                                        rentalunitadress:
                                                            street3.text,
                                                        rentalsqft: sqft3.text,
                                                        rentalunit:
                                                            unitnum.text,
                                                      ));
                                                    });
                                                    Navigator.pop(
                                                        context, true);
                                                  }).catchError((e) {
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                  });
                                                }
                                              },
                                              child: Material(
                                                elevation: 3,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                                child: Container(
                                                  height: 30,
                                                  width: 80,
                                                  decoration: BoxDecoration(
                                                    color: Color.fromRGBO(
                                                        21, 43, 81, 1),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                  ),
                                                  child: Center(
                                                      child: Text(
                                                    "Save",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white),
                                                  )),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Material(
                                                elevation: 3,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                                child: Container(
                                                  height: 30,
                                                  width: 80,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                  ),
                                                  child: Center(
                                                      child: Text(
                                                    "Cancel",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Color.fromRGBO(
                                                            21, 43, 81, 1)),
                                                  )),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.0),
                                        if (iserror)
                                          Text(
                                            "Please fill in all fields correctly.",
                                            style: TextStyle(
                                                color: Colors.redAccent),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                    },
                    child: Material(
                      elevation: 3,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                      child: Container(
                        height: 35,
                        width: 95,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                          border: Border.all(
                            color: Color.fromRGBO(21, 43, 81, 1),
                          ),
                        ),
                        child: Center(
                            child: Text(
                          "Add Unit",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(21, 43, 81, 1)),
                        )),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                ],
              ),
            SizedBox(height: 20),
            if (!showdetails &&
                widget.properties.propertyTypeData!.isMultiunit! == true)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: FutureBuilder<List<unit_properties>>(
                  future: Properies_summery_Repo()
                      .fetchunit(widget.properties.rentalId!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: SpinKitFadingCircle(
                        color: Colors.black,
                        size: 40.0,
                      ));
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No data available'));
                    }
                    final data = snapshot.data!;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                            color: Color.fromRGBO(21, 43, 83, 1),
                          )),
                          child: DataTable(
                            // headingRowColor: MaterialStateColor.resolveWith(
                            //         (states) => Color.fromRGBO(21, 43, 83, 1)),
                            headingTextStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            columnSpacing: 20,
                            dataRowHeight: 60,
                            columns: [
                              DataColumn(
                                label: Text(
                                  'UNIT',
                                  style: TextStyle(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'ADDRESS',
                                  style: TextStyle(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'TENANTS',
                                  style: TextStyle(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'ACTION',
                                  style: TextStyle(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            rows: data.map((unitData) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      ' ${unitData.rentalunit}',
                                      style:
                                          TextStyle(color: Color(0xFF8A95A8)),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        // showdetails = !showdetails;
                                        showdetails = true;
                                        unit = unitData;
                                      });

                                      // if (showdetails) {
                                      //   // Navigator.push(
                                      //   //   context,
                                      //   //   MaterialPageRoute(builder: (context) => unitScreen()),
                                      //   // );
                                      //   // unitScreen();
                                      //   Container(
                                      //       color: Colors.blue,
                                      //     child: Text("data"),
                                      //   );
                                      // }
                                    },
                                  ),
                                  DataCell(
                                    Text(
                                      ' ${unitData.rentalunitadress}',
                                      style:
                                          TextStyle(color: Color(0xFF8A95A8)),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      ' ${tenentCount}',
                                      style:
                                          TextStyle(color: Color(0xFF8A95A8)),
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: FaIcon(
                                        FontAwesomeIcons.edit,
                                        size: 15,
                                        color: Color(0xFF8A95A8),
                                      ),
                                      onPressed: () {
                                        unitnum.text = unitData.rentalunit!;
                                        street3.text =
                                            unitData.rentalunitadress!;
                                        sqft3.text = unitData.rentalsqft!;
                                        bath3.text = unitData.rentalbath!;
                                        bed3.text = unitData.rentalbed!;
                                        if (widget.properties.propertyTypeData!
                                                .isMultiunit! &&
                                            widget.properties.propertyTypeData!
                                                    .propertyType ==
                                                'Residential')
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              bool isChecked =
                                                  false; // Moved isChecked inside the StatefulBuilder
                                              return StatefulBuilder(
                                                builder: (BuildContext context,
                                                    StateSetter setState) {
                                                  return AlertDialog(
                                                    backgroundColor:
                                                        Colors.white,
                                                    surfaceTintColor:
                                                        Colors.white,
                                                    content:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "Add Unit Details",
                                                                style:
                                                                    TextStyle(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              Spacer(),
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: Icon(
                                                                      Icons
                                                                          .close,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "Unit Number",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            child: Material(
                                                              elevation: 3,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    unitnum,
                                                                cursorColor:
                                                                    Colors
                                                                        .black,
                                                                decoration:
                                                                    InputDecoration(
                                                                  //  hintText: label,
                                                                  // labelText: label,
                                                                  // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                Color(0xFF8A95A8)),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide: BorderSide(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  contentPadding: EdgeInsets.symmetric(
                                                                      vertical:
                                                                          10.0,
                                                                      horizontal:
                                                                          10.0),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "Street Address",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            child: Material(
                                                              elevation: 3,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    street3,
                                                                cursorColor:
                                                                    Colors
                                                                        .black,
                                                                decoration:
                                                                    InputDecoration(
                                                                  //  hintText: label,
                                                                  // labelText: label,
                                                                  // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                Color(0xFF8A95A8)),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide: BorderSide(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  contentPadding: EdgeInsets.symmetric(
                                                                      vertical:
                                                                          10.0,
                                                                      horizontal:
                                                                          10.0),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "SQFT",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            child: Material(
                                                              elevation: 3,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    sqft3,
                                                                cursorColor:
                                                                    Colors
                                                                        .black,
                                                                decoration:
                                                                    InputDecoration(
                                                                  //  hintText: label,
                                                                  // labelText: label,
                                                                  // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                Color(0xFF8A95A8)),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide: BorderSide(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  contentPadding: EdgeInsets.symmetric(
                                                                      vertical:
                                                                          10.0,
                                                                      horizontal:
                                                                          10.0),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "bath",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            child: Material(
                                                              elevation: 3,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    bath3,
                                                                cursorColor:
                                                                    Colors
                                                                        .black,
                                                                decoration:
                                                                    InputDecoration(
                                                                  //  hintText: label,
                                                                  // labelText: label,
                                                                  // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                Color(0xFF8A95A8)),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide: BorderSide(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  contentPadding: EdgeInsets.symmetric(
                                                                      vertical:
                                                                          10.0,
                                                                      horizontal:
                                                                          10.0),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "bed",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            child: Material(
                                                              elevation: 3,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    bed3,
                                                                cursorColor:
                                                                    Colors
                                                                        .black,
                                                                decoration:
                                                                    InputDecoration(
                                                                  //  hintText: label,
                                                                  // labelText: label,
                                                                  // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                Color(0xFF8A95A8)),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide: BorderSide(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  contentPadding: EdgeInsets.symmetric(
                                                                      vertical:
                                                                          10.0,
                                                                      horizontal:
                                                                          10.0),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Photo',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 8.0),
                                                          Row(
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  _pickImage()
                                                                      .then(
                                                                          (_) {
                                                                    setState(
                                                                        () {}); // Rebuild the widget after selecting the image
                                                                  });
                                                                },
                                                                child: Text(
                                                                  '+ Add',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .green),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          _image != null
                                                              ? Column(
                                                                  children: [
                                                                    Image.file(
                                                                      _image!,
                                                                      height:
                                                                          80,
                                                                      width: 80,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                    Text(
                                                                        _uploadedFileName ??
                                                                            ""),
                                                                  ],
                                                                )
                                                              : Text(''),
                                                          SizedBox(height: 8.0),
                                                          Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 0,
                                                              ),
                                                              GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  if (unitnum.text.isEmpty ||
                                                                      street3
                                                                          .text
                                                                          .isEmpty ||
                                                                      sqft3.text
                                                                          .isEmpty ||
                                                                      bath3.text
                                                                          .isEmpty ||
                                                                      bed3.text
                                                                          .isEmpty) {
                                                                    setState(
                                                                        () {
                                                                      iserror =
                                                                          true;
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      isLoading =
                                                                          true;
                                                                      iserror =
                                                                          false;
                                                                    });
                                                                    SharedPreferences
                                                                        prefs =
                                                                        await SharedPreferences
                                                                            .getInstance();

                                                                    String? id =
                                                                        prefs.getString(
                                                                            "adminId");
                                                                    Properies_summery_Repo()
                                                                        .Editunit(
                                                                            rentalunit: unitnum
                                                                                .text,
                                                                            rentalsqft: sqft3
                                                                                .text,
                                                                            rentalunitadress: street3
                                                                                .text,
                                                                            rentalbath: bath3
                                                                                .text,
                                                                            rentalbed: bed3
                                                                                .text,
                                                                            unitId: unitData
                                                                                .unitId,
                                                                            adminId:
                                                                                id,
                                                                            rentalId: unitData
                                                                                .rentalId)
                                                                        .then(
                                                                            (value) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            false;
                                                                      });

                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(
                                                                              true);
                                                                      reload_Screen();
                                                                    }).catchError(
                                                                            (e) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            false;
                                                                      });
                                                                    });
                                                                  }
                                                                },
                                                                child: Material(
                                                                  elevation: 3,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            5),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width: 80,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                        Radius.circular(
                                                                            5),
                                                                      ),
                                                                    ),
                                                                    child: Center(
                                                                        child: Text(
                                                                      "Save",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color:
                                                                              Colors.white),
                                                                    )),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 10),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Material(
                                                                  elevation: 3,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            5),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width: 80,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                        Radius.circular(
                                                                            5),
                                                                      ),
                                                                    ),
                                                                    child: Center(
                                                                        child: Text(
                                                                      "Cancel",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color: Color.fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1)),
                                                                    )),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 8.0),
                                                          if (iserror)
                                                            Text(
                                                              "Please fill in all fields correctly.",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .redAccent),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        if (widget.properties.propertyTypeData!
                                                .isMultiunit! &&
                                            widget.properties.propertyTypeData!
                                                    .propertyType ==
                                                'Commercial')
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              bool isChecked =
                                                  false; // Moved isChecked inside the StatefulBuilder
                                              return StatefulBuilder(
                                                builder: (BuildContext context,
                                                    StateSetter setState) {
                                                  return AlertDialog(
                                                    backgroundColor:
                                                        Colors.white,
                                                    surfaceTintColor:
                                                        Colors.white,
                                                    content:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "Add Unit Details",
                                                                style:
                                                                    TextStyle(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              Spacer(),
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: Icon(
                                                                      Icons
                                                                          .close,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "Unit Number",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            child: Material(
                                                              elevation: 3,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    unitnum,
                                                                cursorColor:
                                                                    Colors
                                                                        .black,
                                                                decoration:
                                                                    InputDecoration(
                                                                  //  hintText: label,
                                                                  // labelText: label,
                                                                  // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                Color(0xFF8A95A8)),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide: BorderSide(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  contentPadding: EdgeInsets.symmetric(
                                                                      vertical:
                                                                          10.0,
                                                                      horizontal:
                                                                          10.0),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "Street Address",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            child: Material(
                                                              elevation: 3,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    street3,
                                                                cursorColor:
                                                                    Colors
                                                                        .black,
                                                                decoration:
                                                                    InputDecoration(
                                                                  //  hintText: label,
                                                                  // labelText: label,
                                                                  // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                Color(0xFF8A95A8)),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide: BorderSide(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  contentPadding: EdgeInsets.symmetric(
                                                                      vertical:
                                                                          10.0,
                                                                      horizontal:
                                                                          10.0),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "SQFT",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        1),
                                                            child: Material(
                                                              elevation: 3,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    sqft3,
                                                                cursorColor:
                                                                    Colors
                                                                        .black,
                                                                decoration:
                                                                    InputDecoration(
                                                                  //  hintText: label,
                                                                  // labelText: label,
                                                                  // labelStyle: TextStyle(color: Colors.grey[700]),
                                                                  filled: true,
                                                                  fillColor:
                                                                      Colors
                                                                          .white,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                Color(0xFF8A95A8)),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(3),
                                                                    borderSide: BorderSide(
                                                                        color: Color(
                                                                            0xFF8A95A8),
                                                                        width:
                                                                            2),
                                                                  ),
                                                                  contentPadding: EdgeInsets.symmetric(
                                                                      vertical:
                                                                          10.0,
                                                                      horizontal:
                                                                          10.0),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Photo',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 8.0),
                                                          Row(
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  _pickImage()
                                                                      .then(
                                                                          (_) {
                                                                    setState(
                                                                        () {}); // Rebuild the widget after selecting the image
                                                                  });
                                                                },
                                                                child: Text(
                                                                  '+ Add',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .green),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 8.0),
                                                          _image != null
                                                              ? Column(
                                                                  children: [
                                                                    Image.file(
                                                                      _image!,
                                                                      height:
                                                                          80,
                                                                      width: 80,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                    Text(
                                                                        _uploadedFileName ??
                                                                            ""),
                                                                  ],
                                                                )
                                                              : Text(''),
                                                          SizedBox(height: 8.0),
                                                          Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 0,
                                                              ),
                                                              GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  if (unitnum.text.isEmpty ||
                                                                      street3
                                                                          .text
                                                                          .isEmpty ||
                                                                      sqft3.text
                                                                          .isEmpty) {
                                                                    setState(
                                                                        () {
                                                                      iserror =
                                                                          true;
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      isLoading =
                                                                          true;
                                                                      iserror =
                                                                          false;
                                                                    });
                                                                    SharedPreferences
                                                                        prefs =
                                                                        await SharedPreferences
                                                                            .getInstance();
                                                                    String? id =
                                                                        prefs.getString(
                                                                            "adminId");
                                                                    Properies_summery_Repo()
                                                                        .Editunit(
                                                                      rentalunit:
                                                                          unitnum
                                                                              .text,
                                                                      rentalsqft:
                                                                          sqft3
                                                                              .text,
                                                                      rentalunitadress:
                                                                          street3
                                                                              .text,
                                                                      unitId: unitData
                                                                          .unitId!,
                                                                    )
                                                                        .then(
                                                                            (value) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            false;
                                                                      });
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(
                                                                              true);
                                                                    }).catchError(
                                                                            (e) {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            false;
                                                                      });
                                                                    });
                                                                  }
                                                                },
                                                                child: Material(
                                                                  elevation: 3,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            5),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width: 80,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                        Radius.circular(
                                                                            5),
                                                                      ),
                                                                    ),
                                                                    child: Center(
                                                                        child: Text(
                                                                      "Save",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color:
                                                                              Colors.white),
                                                                    )),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 10),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Material(
                                                                  elevation: 3,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            5),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    height: 30,
                                                                    width: 80,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                        Radius.circular(
                                                                            5),
                                                                      ),
                                                                    ),
                                                                    child: Center(
                                                                        child: Text(
                                                                      "Cancel",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color: Color.fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1)),
                                                                    )),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 8.0),
                                                          if (iserror)
                                                            Text(
                                                              "Please fill in all fields correctly.",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .redAccent),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  unitScreen1(BuildContext context, unit_properties unit) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              //height: screenHeight * 0.82,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.white,
                border: Border.all(
                  color: const Color.fromRGBO(21, 43, 83, 1),
                  width: 1,
                ),
              ),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 36,
                          width: 76,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                showdetails = false;
                              });
                              // Navigator.pop(context);
                            },
                            child: const Text(
                              'Back',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(21, 43, 83, 1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0))),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 36,
                          width: 126,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(21, 43, 83, 1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0))),
                            onPressed: () async {
                              var data = Properies_summery_Repo()
                                  .Deleteunit(unitId: unit?.unitId!);
                              // Add your delete logic here
                              setState(() {
                                futureUnitsummery = Properies_summery_Repo()
                                    .fetchunit(widget.properties.rentalId!);
                              });
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Delete unit',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    //  height: screenHeight * 0.30,
                    //width: screenWidth * 0.8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: const Image(
                        image: NetworkImage(
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRe_jcaXNfnjMStYxu0ScZHngqxm-cTA9lJbB9DrbhxHQ6G-aAvZFZFu9-xSz31R5gKgjM&usqp=CAU'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Text(
                              'ADDRESS',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[800]),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Text(
                              '${widget.properties?.rentalAddress}',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[800]),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Text(
                              '${widget.properties?.rentalCity} ${widget.properties?.rentalState}',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[800]),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Text(
                              '${widget.properties?.rentalCountry} ${widget.properties?.rentalPostcode}',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[800]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      // height: screenHeight * 0.26,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.white,
                        border: Border.all(
                          color: const Color.fromRGBO(21, 43, 83, 1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                'Add Lease',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color.fromRGBO(21, 43, 83, 1),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 36,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                child: const Text(
                                  'Add Lease',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromRGBO(21, 43, 83, 1),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0))),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                'Rental Applicant',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color.fromRGBO(21, 43, 83, 1),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 36,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                child: const Text(
                                  'Create Applicant',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromRGBO(21, 43, 83, 1),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0))),
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
          ),
          LeasesTable(
            unit: unit,
          ),
          // LeasesTable1(context,unit!),
          // LeasesTable(context),
          AppliancesPart(unit: unit),
        ],
      ),
    );
  }

  reload_Screen() {
    setState(() {});
  }
}
