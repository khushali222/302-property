import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../../constant/constant.dart';
import '../../../model/rental_properties.dart';
import '../../../provider/add_property.dart';
import '../../../repository/rental_properties.dart';
import '../../../widgets/drawer_tiles.dart';
import 'package:http/http.dart' as http;
import '../../../widgets/custom_drawer.dart';

class AddRentalowners extends StatefulWidget {
  RentalOwner? OwnersDetails;
  bool? isEdit;
  AddRentalowners({super.key, this.OwnersDetails, this.isEdit});

  @override
  State<AddRentalowners> createState() => _AddRentalownersState();
}

class _AddRentalownersState extends State<AddRentalowners> {
  Owner? selectedOwner;
  Owner? rentalOwnerId;

  bool isEdit = false;
  Owner? getSelectedOwner() {
    for (int i = 0; i < selected.length; i++) {
      if (selected[i]) {
        return filteredOwners[i];
      }
    }
    return null;
  }

  void onAddButtonTapped() {
    for (int i = 0; i < selected.length; i++) {
      if (selected[i]) {
        setState(() {
          selectedOwner = filteredOwners[i];
        });
        return;
      }
    }
    // Show a message to select an owner
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Please select an owner.'),
    ));
  }

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //add rental owner

  TextEditingController firstname = TextEditingController();
  TextEditingController comname = TextEditingController();
  TextEditingController primaryemail = TextEditingController();
  TextEditingController alternativeemail = TextEditingController();
  TextEditingController phonenum = TextEditingController();
  TextEditingController homenum = TextEditingController();
  TextEditingController businessnum = TextEditingController();
  TextEditingController street2 = TextEditingController();
  TextEditingController city2 = TextEditingController();
  TextEditingController state2 = TextEditingController();
  TextEditingController county2 = TextEditingController();
  TextEditingController code2 = TextEditingController();
  TextEditingController proid = TextEditingController();
  TextEditingController searchController = TextEditingController();

  bool firstnameerror = false;

  bool comnameerror = false;
  bool primaryemailerror = false;
  bool alternativeerror = false;
  bool phonenumerror = false;
  bool homenumerror = false;
  bool businessnumerror = false;
  bool street2error = false;
  bool city2error = false;
  bool state2error = false;
  bool county2error = false;
  bool code2error = false;
  bool proiderror = false;

  String firstnamemessage = "";

  String comnamemessage = "";
  String primaryemailmessage = "";
  String alternativemessage = "";
  String phonenummessage = "";
  String homenummessage = "";
  String businessnummessage = "";
  String street2message = "";
  String city2message = "";
  String state2message = "";
  String county2message = "";
  String code2message = "";
  String proidmessage = "";
  bool isChecked = false;
  bool isChecked2 = false;
  bool isLoading = false;
  String? processor_id;

  List<Owner> owners = [];
  List<Owner> filteredOwners = [];
  List<bool> selected = [];
  int? selectedIndex;

  List<ProcessorGroup> _processorGroups = [];

  RentalOwner? Ownersdetails;
  //List<OwnersDetails> OwnersdetailsGroups = [];
  bool hasError = false;
  Future<void> fetchOwners() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await http
        .get(Uri.parse('${Api_url}/api/rentals/rental-owners/$id'), headers: {
      "id": "CRM $id",
      "authorization": "CRM $token",
    });
    // print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      owners = data.map((item) => Owner.fromJson(item)).toList();
      filteredOwners = List.from(owners);
      selected = List<bool>.filled(owners.length, false);
    } else {
      // Handle error
    }
    setState(() {
      isLoading = false;
    });
  }

  void filterOwners(String query) {
    setState(() {
      filteredOwners = owners.where((owner) {
        final fullName = '${owner.rentalOwnername} '.toLowerCase();
        return fullName.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    filteredOwners = owners;
    selected = List<bool>.generate(owners.length, (index) => false);
    // searchController.addListener(() { });
    // futureMember = StaffMemberRepository().fetchStaffmembers();
    //futureProperties = PropertyTypeRepository().fetchPropertyTypes();
    //futureStaffMembers = StaffMemberRepository().fetchStaffmembers();
    //propertyGroups = [];
    // Add property group based on selected subproperty type
    //addPropertyGroup();
    fetchOwners();
    firstname.text = widget.OwnersDetails?.rentalOwnerName ?? "";
    phonenum.text = widget.OwnersDetails?.rentalOwnerPhoneNumber ?? "";
    comname.text = widget.OwnersDetails?.rentalOwnerCompanyName ?? "";
    primaryemail.text = widget.OwnersDetails?.rentalOwnerPrimaryEmail ?? "";
    alternativeemail.text =
        widget.OwnersDetails?.rentalOwnerAlternateEmail ?? "";
    phonenum.text = widget.OwnersDetails?.rentalOwnerPhoneNumber ?? "";
    homenum.text = widget.OwnersDetails?.rentalOwnerHomeNumber ?? "";
    businessnum.text = widget.OwnersDetails?.rentalOwnerBusinessNumber ?? "";
    street2.text = widget.OwnersDetails?.streetAddress ?? "";
    city2.text = widget.OwnersDetails?.city ?? "";
    county2.text = widget.OwnersDetails?.country ?? "";
    code2.text = widget.OwnersDetails?.postalCode ?? "";
    proid.text = widget.OwnersDetails?.postalCode ?? "";

    if (widget.isEdit != null &&
        widget.OwnersDetails!.processorList != null &&
        widget.OwnersDetails!.processorList!.length > 0) {
      for (var i = 0; i < widget.OwnersDetails!.processorList!.length; i++) {
        _processorGroups.add(ProcessorGroup(
          isChecked: false,
          controller: TextEditingController(
              text: widget.OwnersDetails!.processorList![i].processorId),
        ));
      }
    } else {
      if (_processorGroups.isEmpty) {
        _processorGroups.add(ProcessorGroup(
          isChecked: false,
          controller: TextEditingController(),
        ));
      }
    }
  }

  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  final FocusNode _nodeText3 = FocusNode();
  final FocusNode _nodeText4 = FocusNode();

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
          focusNode: _nodeText1,
        ),
        KeyboardActionsItem(
          focusNode: _nodeText2,
          //  displayCloseWidget: false,
        ),
        KeyboardActionsItem(
          focusNode: _nodeText3,
        ),
        KeyboardActionsItem(
          focusNode: _nodeText4,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      drawer: CustomDrawer(
        currentpage: "Properties",
        dropdown: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: Container(
                    height: 50.0,
                    padding: EdgeInsets.only(top: 14, left: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: blueColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: Text(
                      "Add RentalOwners",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    SizedBox(
                      width: 24.0,
                      height: 24.0,
                      child: Checkbox(
                        value: isChecked,
                        onChanged: (value) {
                          setState(() {
                            isChecked = value ?? false;
                          });
                        },
                        activeColor: isChecked
                            ? blueColor
                            : Colors.black,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Text(
                        "choose an existing rental owner",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8A95A8),
                            fontSize: MediaQuery.of(context).size.width < 500
                                ? 16
                                : 18),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                isChecked
                    ? Column(
                        children: [
                          SizedBox(height: 2.0),
                          Row(
                            children: [
                              Expanded(
                                child: Material(
                                  elevation: 3,
                                  borderRadius: BorderRadius.circular(5),
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.width < 500
                                            ? 50
                                            : 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      // color: Colors
                                      //     .white,
                                      border:
                                          Border.all(color: Color(0xFF8A95A8)),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: TextField(
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13,
                                            ),
                                            controller: searchController,
                                            //keyboardType: TextInputType.emailAddress,
                                            onChanged: (value) {
                                              setState(() {
                                                if (value != "")
                                                  filteredOwners = owners
                                                      .where((element) => element
                                                          .rentalOwnername
                                                          .toLowerCase()
                                                          .contains(value
                                                              .toLowerCase()))
                                                      .toList();
                                                if (value == "") {
                                                  filteredOwners = owners;
                                                }
                                              });
                                            },
                                            cursorColor:
                                                blueColor,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.only(
                                                  top: 13,
                                                  bottom: 13,
                                                  left: 14),
                                              hintText:
                                                  "Search by first and last name",
                                              hintStyle: TextStyle(
                                                color: Color(0xFF8A95A8),
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        500
                                                    ? 14
                                                    : 17,
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
                          SizedBox(height: 16.0),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: blueColor),
                                  ),
                                  child: DataTable(
                                    border: TableBorder(
                                      horizontalInside: BorderSide(
                                        color: blueColor,
                                        width: 1.0,
                                      ),
                                    ),
                                    columnSpacing: 10,
                                    headingRowHeight:
                                        MediaQuery.of(context).size.width < 500
                                            ? 55
                                            : 60,
                                    dataRowHeight:
                                        MediaQuery.of(context).size.width < 500
                                            ? 50
                                            : 60,
                                    // horizontalMargin: 10,
                                    columns: [
                                      DataColumn(
                                          label: Expanded(
                                        child: Text(
                                          'Rentalowner \nName',
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      500
                                                  ? 14
                                                  : 18,
                                              fontWeight: FontWeight.bold,
                                              color: blueColor),
                                        ),
                                      )),
                                      DataColumn(
                                          label: Expanded(
                                        child: Text(
                                          'Processor ID  ',
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      500
                                                  ? 14
                                                  : 18,
                                              fontWeight: FontWeight.bold,
                                              color: blueColor),
                                        ),
                                      )),
                                      DataColumn(
                                          label: Expanded(
                                        child: Text(
                                          'Select ',
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      500
                                                  ? 14
                                                  : 18,
                                              fontWeight: FontWeight.bold,
                                              color: blueColor),
                                        ),
                                      )),
                                    ],
                                    rows: List<DataRow>.generate(
                                      filteredOwners.length,
                                      (index) => DataRow(
                                        cells: [
                                          DataCell(
                                            Text(
                                              '${filteredOwners[index].rentalOwnername} '
                                              '(${filteredOwners[index].phoneNumber})',
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 13
                                                          : 18),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              filteredOwners[index]
                                                  .processorList
                                                  .map((processor) =>
                                                      processor.processorId)
                                                  .join(
                                                      '\n'), // Join processor IDs with newline
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 13
                                                          : 18),
                                            ),
                                          ),
                                          DataCell(
                                            SizedBox(
                                              height: 10,
                                              width: 35,
                                              child: Checkbox(
                                                value: selectedIndex == index,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    if (value != null &&
                                                        value) {
                                                      selectedIndex = index;
                                                      selectedOwner =
                                                          filteredOwners[index];
                                                      firstname.text =
                                                          selectedOwner!
                                                              .rentalOwnername;
                                                      comname.text =
                                                          selectedOwner!
                                                              .companyName;
                                                      primaryemail.text =
                                                          selectedOwner!
                                                              .primaryEmail;
                                                      alternativeemail.text =
                                                          selectedOwner!
                                                              .alternateEmail;
                                                      homenum.text =
                                                          selectedOwner!
                                                                  .homeNumber ??
                                                              '';
                                                      phonenum.text =
                                                          selectedOwner!
                                                              .phoneNumber;
                                                      businessnum
                                                          .text = selectedOwner!
                                                              .businessNumber ??
                                                          '';
                                                      street2.text =
                                                          selectedOwner!
                                                              .streetAddress;
                                                      city2.text =
                                                          selectedOwner!.city;
                                                      state2.text =
                                                          selectedOwner!.state;
                                                      county2.text =
                                                          selectedOwner!
                                                              .country;
                                                      code2.text =
                                                          selectedOwner!
                                                              .postalCode;
                                                      proid.text = selectedOwner!
                                                          .processorList
                                                          .map((processor) =>
                                                              processor
                                                                  .processorId)
                                                          .join(', ');
                                                    } else {
                                                      selectedIndex = null;
                                                    }
                                                    isChecked2 = true;
                                                    isChecked = false;
                                                    _processorGroups.clear();
                                                    for (Processor processor
                                                        in selectedOwner!
                                                            .processorList) {
                                                      _processorGroups.add(ProcessorGroup(
                                                          isChecked: false,
                                                          controller:
                                                              TextEditingController(
                                                                  text: processor
                                                                      .processorId)));
                                                    }
                                                  });
                                                },
                                                activeColor: blueColor


,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: blueColor),
                          ),
                          child: Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: 10,
                              ),
                              child:
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        "Contact Name *",
                                        style: TextStyle(
                                            color: Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 14
                                                : 18),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                              border:
                                                  Border.all(color: greyColor)
                                              // color: Color.fromRGBO(196, 196, 196, .3),
                                              ),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: TextField(
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 14
                                                            : 15,
                                                  ),
                                                  keyboardType: TextInputType
                                                      .text, // Adjust as needed
                                                  onChanged: (value) {
                                                    setState(() {
                                                      firstnameerror = false;
                                                    });
                                                  },
                                                  controller: firstname,
                                                  cursorColor: blueColor


,
                                                  decoration: InputDecoration(
                                                    enabledBorder: firstnameerror
                                                        ? OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .red), // Set border color here
                                                          )
                                                        : InputBorder.none,
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.all(14),
                                                    hintText: "Enter name",
                                                    hintStyle: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                    ],
                                  ),
                                  firstnameerror
                                      ? Row(
                                          children: [
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Text(
                                              firstnamemessage,
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        "Company Name *",
                                        style: TextStyle(
                                            color: Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 14
                                                : 18),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                              border:
                                                  Border.all(color: greyColor)
                                              // color: Color.fromRGBO(196, 196, 196, .3),
                                              ),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: TextField(
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 14
                                                            : 15,
                                                  ),
                                                  keyboardType: TextInputType
                                                      .text, // Adjust as needed
                                                  onChanged: (value) {
                                                    setState(() {
                                                      comnameerror = false;
                                                    });
                                                  },
                                                  controller: comname,
                                                  cursorColor: blueColor


,
                                                  decoration: InputDecoration(
                                                    enabledBorder: comnameerror
                                                        ? OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .red), // Set border color here
                                                          )
                                                        : InputBorder.none,
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.all(14),
                                                    hintText:
                                                        "Enter company name",
                                                    hintStyle: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                    ],
                                  ),
                                  comnameerror
                                      ? Row(
                                          children: [
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Text(
                                              comnamemessage,
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        "Primary Email *",
                                        style: TextStyle(
                                            color: Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 14
                                                : 18),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                              border:
                                                  Border.all(color: greyColor)
                                              // color: Color.fromRGBO(196, 196, 196, .3),
                                              ),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: TextField(
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 14
                                                            : 15,
                                                  ),
                                                  keyboardType: TextInputType
                                                      .emailAddress, // Adjust as needed
                                                  onChanged: (value) {
                                                    setState(() {
                                                      primaryemailerror = false;
                                                    });
                                                  },

                                                  controller: primaryemail,
                                                  cursorColor: blueColor


,
                                                  decoration: InputDecoration(
                                                    enabledBorder:
                                                        primaryemailerror
                                                            ? OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .red), // Set border color here
                                                              )
                                                            : InputBorder.none,
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.all(14),
                                                    hintText:
                                                        "Enter primary email",
                                                    hintStyle: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                    ],
                                  ),
                                  primaryemailerror
                                      ? Row(
                                          children: [
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Text(
                                              primaryemailmessage,
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        "Alternative Email",
                                        style: TextStyle(
                                            color: Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 14
                                                : 18),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                              border:
                                                  Border.all(color: greyColor)
                                              // color: Color.fromRGBO(196, 196, 196, .3),
                                              ),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: TextField(
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 14
                                                            : 15,
                                                  ),
                                                  keyboardType: TextInputType
                                                      .emailAddress, // Adjust as needed
                                                  onChanged: (value) {
                                                    setState(() {
                                                      alternativeerror = false;
                                                    });
                                                  },
                                                  controller: alternativeemail,
                                                  cursorColor: blueColor


,
                                                  decoration: InputDecoration(
                                                    enabledBorder:
                                                        alternativeerror
                                                            ? OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .red), // Set border color here
                                                              )
                                                            : InputBorder.none,
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.all(14),
                                                    hintText:
                                                        "Enter alternative email",
                                                    hintStyle: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                    ],
                                  ),
                                  alternativeerror
                                      ? Center(
                                          child: Text(
                                          alternativemessage,
                                          style: TextStyle(color: Colors.red),
                                        ))
                                      : Container(),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        "Phone Numbers *",
                                        style: TextStyle(
                                            color: Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 14
                                                : 18),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                              border:
                                                  Border.all(color: greyColor)
                                              // color: Color.fromRGBO(196, 196, 196, .3),
                                              ),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: TextField(
                                                  focusNode: _nodeText1,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 14
                                                            : 15,
                                                  ),
                                                  keyboardType: TextInputType
                                                      .numberWithOptions(
                                                          signed: true,
                                                          decimal:
                                                              true), // Adjust as needed
                                                  onChanged: (value) {
                                                    setState(() {
                                                      phonenumerror = false;
                                                    });
                                                  },
                                                  controller: phonenum,
                                                  cursorColor: blueColor


,
                                                  decoration: InputDecoration(
                                                    enabledBorder: phonenumerror
                                                        ? OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .red), // Set border color here
                                                          )
                                                        : InputBorder.none,
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.all(14),
                                                    hintText:
                                                        "Enter phone number",
                                                    hintStyle: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                    ],
                                  ),
                                  phonenumerror
                                      ? Row(
                                          children: [
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Text(
                                              phonenummessage,
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                              border:
                                                  Border.all(color: greyColor)
                                              // color: Color.fromRGBO(196, 196, 196, .3),
                                              ),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: TextField(
                                                  focusNode: _nodeText2,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 14
                                                            : 15,
                                                  ),
                                                  keyboardType: TextInputType
                                                      .numberWithOptions(
                                                          signed: true,
                                                          decimal:
                                                              true), // Adjust as needed
                                                  onChanged: (value) {
                                                    setState(() {
                                                      homenumerror = false;
                                                    });
                                                  },
                                                  controller: homenum,
                                                  cursorColor: blueColor


,
                                                  decoration: InputDecoration(
                                                    enabledBorder: homenumerror
                                                        ? OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .red), // Set border color here
                                                          )
                                                        : InputBorder.none,
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.all(14),
                                                    hintText:
                                                        "Enter home number",
                                                    hintStyle: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                    ],
                                  ),
                                  homenumerror
                                      ? Center(
                                          child: Text(
                                          homenummessage,
                                          style: TextStyle(color: Colors.red),
                                        ))
                                      : Container(),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                              border:
                                                  Border.all(color: greyColor)
                                              // color: Color.fromRGBO(196, 196, 196, .3),
                                              ),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: TextField(
                                                  focusNode: _nodeText3,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 14
                                                            : 15,
                                                  ),
                                                  keyboardType: TextInputType
                                                      .numberWithOptions(
                                                          signed: true,
                                                          decimal:
                                                              true), // Adjust as needed
                                                  onChanged: (value) {
                                                    setState(() {
                                                      businessnumerror = false;
                                                    });
                                                  },
                                                  controller: businessnum,
                                                  cursorColor: blueColor


,
                                                  decoration: InputDecoration(
                                                    enabledBorder:
                                                        businessnumerror
                                                            ? OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .red), // Set border color here
                                                              )
                                                            : InputBorder.none,
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.all(14),
                                                    hintText:
                                                        "Enter business number",
                                                    hintStyle: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                    ],
                                  ),
                                  businessnumerror
                                      ? Center(
                                          child: Text(
                                          businessnummessage,
                                          style: TextStyle(color: Colors.red),
                                        ))
                                      : Container(),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        "Address Information",
                                        style: TextStyle(
                                            color: Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 14
                                                : 18),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                              border:
                                                  Border.all(color: greyColor)
                                              // color: Color.fromRGBO(196, 196, 196, .3),
                                              ),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: TextField(
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 14
                                                            : 15,
                                                  ),
                                                  keyboardType: TextInputType
                                                      .text, // Adjust as needed
                                                  onChanged: (value) {
                                                    setState(() {
                                                      street2error = false;
                                                    });
                                                  },
                                                  controller: street2,
                                                  cursorColor: blueColor


,
                                                  decoration: InputDecoration(
                                                    enabledBorder: street2error
                                                        ? OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .red), // Set border color here
                                                          )
                                                        : InputBorder.none,
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.all(14),
                                                    hintText:
                                                        "Enter street address",
                                                    hintStyle: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                    ],
                                  ),
                                  street2error
                                      ? Center(
                                          child: Text(
                                          street2message,
                                          style: TextStyle(color: Colors.red),
                                        ))
                                      : Container(),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // First Column
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "City",
                                                style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 14.5
                                                          : 18,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Container(
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    Positioned.fill(
                                                      child: TextField(
                                                        controller: city2,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 15,
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            city2error = false;
                                                          });
                                                        },
                                                        cursorColor:
                                                            Color.fromRGBO(
                                                                21, 43, 81, 1),
                                                        decoration:
                                                            InputDecoration(
                                                          enabledBorder:
                                                              city2error
                                                                  ? OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.red), // Error border color
                                                                    )
                                                                  : InputBorder
                                                                      .none,
                                                          border:
                                                              InputBorder.none,
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                  14),
                                                          hintText:
                                                              "Enter city",
                                                          hintStyle: TextStyle(
                                                            color: Color(
                                                                0xFF8A95A8),
                                                            fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width <
                                                                    500
                                                                ? 14
                                                                : 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              city2error
                                                  ? Center(
                                                      child: Text(
                                                      city2message,
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ))
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        // Second Column
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "State",
                                                style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 14.5
                                                          : 18,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Container(
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    Positioned.fill(
                                                      child: TextField(
                                                        controller: state2,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 15,
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            state2error = false;
                                                          });
                                                        },
                                                        cursorColor:
                                                            Color.fromRGBO(
                                                                21, 43, 81, 1),
                                                        decoration:
                                                            InputDecoration(
                                                          enabledBorder:
                                                              state2error
                                                                  ? OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.red), // Error border color
                                                                    )
                                                                  : InputBorder
                                                                      .none,
                                                          border:
                                                              InputBorder.none,
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                  14),
                                                          hintText:
                                                              "Enter state",
                                                          hintStyle: TextStyle(
                                                            color: Color(
                                                                0xFF8A95A8),
                                                            fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width <
                                                                    500
                                                                ? 14
                                                                : 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              state2error
                                                  ? Center(
                                                      child: Text(
                                                      state2message,
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ))
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // First Column
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Country",
                                                style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 14.5
                                                          : 18,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Container(
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    Positioned.fill(
                                                      child: TextField(
                                                        controller: county2,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 15,
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            county2error =
                                                                false;
                                                          });
                                                        },
                                                        cursorColor:
                                                            Color.fromRGBO(
                                                                21, 43, 81, 1),
                                                        decoration:
                                                            InputDecoration(
                                                          enabledBorder:
                                                              county2error
                                                                  ? OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.red), // Error border color
                                                                    )
                                                                  : InputBorder
                                                                      .none,
                                                          border:
                                                              InputBorder.none,
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                  14),
                                                          hintText:
                                                              "Enter country",
                                                          hintStyle: TextStyle(
                                                            color: Color(
                                                                0xFF8A95A8),
                                                            fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width <
                                                                    500
                                                                ? 14
                                                                : 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              county2error
                                                  ? Center(
                                                      child: Text(
                                                      county2message,
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ))
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        // Second Column
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Postal Code",
                                                style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 14.5
                                                          : 18,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Container(
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color: Color(0xFF8A95A8)),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    Positioned.fill(
                                                      child: TextField(
                                                        focusNode: _nodeText4,
                                                        controller: code2,
                                                        keyboardType: TextInputType
                                                            .numberWithOptions(
                                                                signed: true,
                                                                decimal: true),
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width <
                                                                  500
                                                              ? 14
                                                              : 15,
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            code2error = false;
                                                          });
                                                        },
                                                        cursorColor:
                                                            Color.fromRGBO(
                                                                21, 43, 81, 1),
                                                        decoration:
                                                            InputDecoration(
                                                          enabledBorder:
                                                              code2error
                                                                  ? OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.red), // Error border color
                                                                    )
                                                                  : InputBorder
                                                                      .none,
                                                          border:
                                                              InputBorder.none,
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                  14),
                                                          hintText:
                                                              "Enter postal code",
                                                          hintStyle: TextStyle(
                                                            color: Color(
                                                                0xFF8A95A8),
                                                            fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width <
                                                                    500
                                                                ? 14
                                                                : 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              code2error
                                                  ? Center(
                                                      child: Text(
                                                      code2message,
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ))
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.05)
                                ],
                              )),
                        ),
                      ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (firstname.text.isEmpty) {
                          setState(() {
                            firstnameerror = true;
                            firstnamemessage = "required";
                          });
                        } else {
                          setState(() {
                            firstnameerror = false;
                          });
                        }
                        if (comname.text.isEmpty) {
                          setState(() {
                            comnameerror = true;
                            comnamemessage = "required";
                          });
                        } else {
                          setState(() {
                            comnameerror = false;
                          });
                        }
                        if (primaryemail.text.isEmpty) {
                          setState(() {
                            primaryemailerror = true;
                            primaryemailmessage = "required";
                          });
                        }else if (!EmailValidator.validate(primaryemail.text)) {
                          setState(() {
                            primaryemailerror = true;
                            primaryemailmessage = "Email is not valid";
                          });
                        } else {
                          setState(() {
                            primaryemailerror = false;
                          });
                        }
                        if (phonenum.text.isEmpty) {
                          setState(() {
                            phonenumerror = true;
                            phonenummessage = "required";
                          });
                        } else {
                          setState(() {
                            phonenumerror = false;
                          });
                        }
                        if (!firstnameerror &&
                            !comnameerror &&
                            !primaryemailerror &&
                            !phonenumerror) {
                          print('hello');
                          if (widget.isEdit == true || isChecked2) {
                            /* Fluttertoast.showToast(
                            msg:
                            "Rental Owner added Successfully!",
                            toastLength:
                            Toast
                                .LENGTH_SHORT,
                            gravity:
                            ToastGravity
                                .TOP,
                            timeInSecForIosWeb:
                            1,
                            backgroundColor:
                            Colors
                                .green,
                            textColor:
                            Colors
                                .white,
                            fontSize:
                            16.0,
                          );*/
                            print("callllllllling");
                            List<ProcessorList> selectedProcessors =
                                _processorGroups
                                    .map((group) => ProcessorList(
                                        processorId: group.controller.text
                                            .trim())) // Create ProcessorList objects
                                    .where((processor) => processor.processorId!
                                        .isNotEmpty) // Filter out empty IDs
                                    .toList();
                            print(selectedProcessors.length);
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            var adminId = prefs.getString("adminId");
                            Ownersdetails = RentalOwner(
                              rentalOwnerId: selectedOwner?.rentalOwnerId,
                              rentalOwnerPhoneNumber: phonenum.text,
                              rentalOwnerName: firstname.text,
                              rentalOwnerCompanyName: comname.text,
                              rentalOwnerPrimaryEmail: primaryemail.text,
                              rentalOwnerAlternateEmail: alternativeemail.text,
                              rentalOwnerHomeNumber: homenum.text,
                              rentalOwnerBusinessNumber: businessnum.text,
                              streetAddress: street2.text,
                              city: city2.text,
                              country: county2.text,
                              state: state2.text,
                              postalCode: code2.text,
                              processorList: selectedProcessors,
                            );
                            print(Ownersdetails!.toJson());
                            context
                                .read<OwnerDetailsProvider>()
                                .setOwnerDetails(Ownersdetails!);
                            // context
                            //     .read<
                            //     OwnerDetailsProvider>()
                            //     .selectedprocessid(
                            //     processor_id!);
                            /* context
                              .read<
                              OwnerDetailsProvider>()
                              .selectedprocessid(
                              processor_id!);*/
                            // Navigator.pop(
                            //     context);
                          } else {
                            var response = await Rental_PropertiesRepository()
                                .checkIfRentalOwnerExists(
                              rentalOwner_name: firstname.text,
                              rentalOwner_companyName: comname.text,
                              rentalOwner_primaryEmail: primaryemail.text,
                              rentalOwner_alternativeEmail:
                                  alternativeemail.text,
                              rentalOwner_phoneNumber: phonenum.text,
                              rentalOwner_homeNumber: homenum.text,
                              rentalOwner_businessNumber: businessnum.text,
                            );
                            if (response == true) {
                              List<ProcessorList> selectedProcessors =
                                  _processorGroups
                                      //  .where((group) => group.isChecked)
                                      .map((group) => ProcessorList(
                                          processorId: group.controller.text
                                              .trim())) // Create ProcessorList objects
                                      .where((processor) => processor
                                          .processorId!
                                          .isNotEmpty) // Filter out empty IDs
                                      .toList();
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              var adminId = prefs.getString("adminId");
                              Ownersdetails = RentalOwner(
                                adminId: adminId,
                                //  rentalOwnerId: selectedOwner!.rentalOwnerId,
                                rentalOwnerPhoneNumber: phonenum.text,
                                rentalOwnerName: firstname.text,
                                rentalOwnerCompanyName: comname.text,
                                rentalOwnerPrimaryEmail: primaryemail.text,
                                rentalOwnerAlternateEmail:
                                    alternativeemail.text,
                                rentalOwnerHomeNumber: homenum.text,
                                rentalOwnerBusinessNumber: businessnum.text,
                                streetAddress: street2.text,
                                city: city2.text,
                                country: county2.text,
                                state: state2.text,
                                postalCode: code2.text,
                                processorList: selectedProcessors,
                              );
                              print(selectedProcessors.length);
                              context
                                  .read<OwnerDetailsProvider>()
                                  .setOwnerDetails(Ownersdetails!);
                              // context
                              //     .read<OwnerDetailsProvider>()
                              //     .selectedprocessid(processor_id!);
                              /*Fluttertoast.showToast(
                              msg: "Rental Owner Added Successfully",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.TOP,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          } else {
                            Fluttertoast.showToast(
                              msg: "Rental Owner Already Exists!",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.TOP,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );*/
                            }
                          }
                          setState(() {
                            hasError = false; // Set error state if needed
                          });
                          Navigator.pop(context);
                        }
                        print("form is invalid");
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Container(
                          height: 40.0,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: blueColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, 1.0), // (x,y)
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: isLoading
                                ? SpinKitFadingCircle(
                                    color: Colors.white,
                                    size: 25.0,
                                  )
                                : Text(
                                    "Add",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Container(
                          height: 40.0,
                          width: 65,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, 1.0), //(x,y)
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: isLoading
                                ? SpinKitFadingCircle(
                                    color: Colors.white,
                                    size: 25.0,
                                  )
                                : Text(
                                    "Cancel",
                                    style: TextStyle(
                                        color: blueColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
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
      ),
    );
  }
}

class Owner {
  final String id;
  final String propertyid;
  final String rentalOwnerId;
  final String adminId;
  final String rentalOwnername;
  final String companyName;
  final String primaryEmail;
  final String alternateEmail;
  final String phoneNumber;
  final String? homeNumber;
  final String? businessNumber;
  final String birthDate;
  final String startDate;
  final String endDate;
  final String taxpayerId;
  final String identityType;
  final String streetAddress;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String createdAt;
  final String updatedAt;
  final bool isDelete;
  final List<Processor> processorList;

  Owner({
    required this.id,
    required this.propertyid,
    required this.rentalOwnerId,
    required this.adminId,
    required this.rentalOwnername,
    required this.companyName,
    required this.primaryEmail,
    required this.alternateEmail,
    required this.phoneNumber,
    required this.homeNumber,
    required this.businessNumber,
    required this.birthDate,
    required this.startDate,
    required this.endDate,
    required this.taxpayerId,
    required this.identityType,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.createdAt,
    required this.updatedAt,
    required this.isDelete,
    required this.processorList,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    var list = json['processor_list'] as List;
    List<Processor> processorList =
        list.map((i) => Processor.fromJson(i)).toList();

    return Owner(
      id: json['_id'] ?? "",
      propertyid: json['property_id'] ?? "",
      rentalOwnerId: json['rentalowner_id'] ?? "",
      adminId: json['admin_id'] ?? "",
      rentalOwnername: json['rentalOwner_name'] ?? "",

      companyName: json['rentalOwner_companyName'] ?? "",
      primaryEmail: json['rentalOwner_primaryEmail'] ?? "",
      alternateEmail: json['rentalOwner_alternateEmail'] ?? "",
      phoneNumber: json['rentalOwner_phoneNumber'] ?? "",
      homeNumber: json['rentalOwner_homeNumber'] ?? "", // Nullable field
      businessNumber:
          json['rentalOwner_businessNumber'] ?? "", // Nullable field
      birthDate: json['birth_date'] ?? "",
      startDate: json['start_date'] ?? "",
      endDate: json['end_date'] ?? "",
      taxpayerId: json['texpayer_id'] ?? "",
      identityType: json['text_identityType'] ?? "",
      streetAddress: json['street_address'] ?? "",
      city: json['city'] ?? "",
      state: json['state'] ?? "",
      country: json['country'] ?? "",
      postalCode: json['postal_code'] ?? "",
      createdAt: json['createdAt'] ?? "",
      updatedAt: json['updatedAt'] ?? "",
      isDelete: json['is_delete'],
      processorList: processorList,
    );
  }
}

class Processor {
  final String processorId;
  final String id;

  Processor({required this.processorId, required this.id});

  factory Processor.fromJson(Map<String, dynamic> json) {
    return Processor(
      processorId: json['processor_id'],
      id: json['_id'],
    );
  }
}

class ProcessorGroup {
  bool isChecked;
  TextEditingController controller;

  ProcessorGroup({required this.isChecked, required this.controller});
}

class OwnersDetails {
  RentalOwner? Ownersdetails;
  OwnersDetails({
    required this.Ownersdetails,
  });
}
