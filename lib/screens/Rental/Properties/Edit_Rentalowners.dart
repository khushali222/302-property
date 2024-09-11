import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:keyboard_actions/keyboard_actions_config.dart';
import 'package:keyboard_actions/keyboard_actions_item.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../../constant/constant.dart';
import '../../../model/properties.dart';
import '../../../model/rental_properties.dart';
import '../../../provider/add_property.dart';
import '../../../repository/properties_summery.dart';
import '../../../repository/rental_properties.dart';
import '../../../widgets/drawer_tiles.dart';
import 'package:http/http.dart' as http;
import '../../../widgets/custom_drawer.dart';
class EditRentalowners extends StatefulWidget {
  final String rentalId;
  final String pro_id;

  const EditRentalowners({super.key, required this.rentalId,required this.pro_id});

  @override
  State<EditRentalowners> createState() => _EditRentalownersState();
}

class _EditRentalownersState extends State<EditRentalowners> {
  String? processor_id ;
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
    fetchDetails1(widget.rentalId);

  }

  Future<void> fetchDetails1(String rentalId) async {
 //   try {
      Rentals fetchedDetails =
          await Properies_summery_Repo().fetchrentalDetails(rentalId);
      print(fetchedDetails);
      print(rentalId);
      print(fetchedDetails.rentalCountry);
      print(fetchedDetails.rentalOwnerData?.rentalOwnerName);
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        print(fetchedDetails.rentalAddress);
        // selectedpropertytype = fetchedDetails.propertyTypeData?.propertyType;
        Ownersdetails = RentalOwner(
          rentalOwnerId: fetchedDetails.rentalOwnerId,
          rentalOwnerPhoneNumber:
              fetchedDetails.rentalOwnerData!.rentalOwnerPhoneNumber,
          rentalOwnerName: fetchedDetails.rentalOwnerData!.rentalOwnerName,
        );
        firstname.text = fetchedDetails.rentalOwnerData!.rentalOwnerName!;
        comname.text = fetchedDetails.rentalOwnerData!.rentalOwnerCompanyName!;
        primaryemail.text =
            fetchedDetails.rentalOwnerData!.rentalOwnerPrimaryEmail!;
        alternativeemail.text =
            fetchedDetails.rentalOwnerData!.rentalOwnerAlternativeEmail!;
        print(alternativeemail);
        phonenum.text = fetchedDetails.rentalOwnerData!.rentalOwnerPhoneNumber!;
        print(phonenum);
        homenum.text = fetchedDetails.rentalOwnerData!.rentalOwnerHomeNumber!;
        print(homenum);
        businessnum.text =
            fetchedDetails.rentalOwnerData!.rentalOwnerBuisinessNumber!;

        street2.text = fetchedDetails.rentalOwnerData!.Address!;
        city2.text = fetchedDetails.rentalOwnerData!.city!;
        state2.text = fetchedDetails.rentalOwnerData!.state!;
        county2.text = fetchedDetails.rentalOwnerData!.country!;
        code2.text = fetchedDetails.rentalOwnerData!.postalCode!;
        _processorGroups.clear();
        var processorList = fetchedDetails.rentalOwnerData!.processorList;
        for (var processor in processorList!) {
          var controller = TextEditingController(text: processor["processor_id"] ?? 'N/A');
          _processorGroups.add(ProcessorGroup(isChecked: processor["processor_id"] == widget.pro_id, controller: controller));
        }
        print(_processorGroups.length);
        // _selectedProperty = fetchedDetails.rentalId; // Uncomment and update based on your use case
      });
   /* } catch (e) {
      print('Failed to fetch property details: $e');
    }*/
  }

  Owner? selectedOwner ;
  Owner? rentalOwnerId;
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
      isLoading = false;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await http
        .get(Uri.parse('${Api_url}/api/rentals/rental-owners/$id'), headers: {
      "id": "CRM $id",
      "authorization": "CRM $token",
    });

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
      drawer:CustomDrawer(currentpage: "Properties",dropdown: true,),
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
                      color: Color.fromRGBO(21, 43, 81, 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: Text(
                      "Edit RentalOwners",
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
                      width: 24.0, // Standard width for checkbox
                      height: 24.0,
                      child: Checkbox(
                        value: isChecked,
                        onChanged: (value) {
                          setState(() {
                            isChecked = value ?? false;
                          });
                        },
                        activeColor: isChecked
                            ? Color.fromRGBO(21, 43, 81, 1)
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
                    ?
                Column(
                  children: [
                    SizedBox(
                        height: 2.0),
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            elevation: 3,
                            borderRadius:
                            BorderRadius
                                .circular(
                                5),
                            child:
                            Container(
                              height: MediaQuery.of(context).size.width < 500 ?50:60,
                              decoration:
                              BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(
                                    5),
                                // color: Colors
                                //     .white,
                                border: Border.all(
                                    color:
                                    Color(0xFF8A95A8)),
                              ),
                              child:
                              Stack(
                                children: [
                                  Positioned
                                      .fill(
                                    child:
                                    TextField(
                                      style:  TextStyle(
                                        color:
                                        Colors.black,
                                        fontSize:
                                        13,
                                      ),
                                      controller:
                                      searchController,
                                      //keyboardType: TextInputType.emailAddress,
                                      onChanged:
                                          (value) {
                                        setState(() {
                                          if (value != "") filteredOwners = owners.where((element) => element.rentalOwnername.toLowerCase().contains(value.toLowerCase())).toList();
                                          if (value == "") {
                                            filteredOwners = owners;
                                          }
                                        });
                                      },
                                      cursorColor: Color.fromRGBO(
                                          21,
                                          43,
                                          81,
                                          1),
                                      decoration:
                                      InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.only(top: 13, bottom: 13, left: 14),
                                        hintText: "Search by first and last name",
                                        hintStyle: TextStyle(
                                          color: Color(0xFF8A95A8),
                                          fontSize: MediaQuery.of(context).size.width < 500 ?14:17,
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
                    SizedBox(
                        height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration:
                            BoxDecoration(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                  5),

                              border: Border.all(
                                  color: blueColor),
                            ),
                            child: DataTable(
                              border: TableBorder(
                                horizontalInside: BorderSide(
                                  color: Color.fromRGBO(21, 43, 81, 1),
                                  width: 1.0,
                                ),

                              ),
                              columnSpacing: 10,
                              headingRowHeight:
                              MediaQuery.of(context).size.width < 500 ?55:60,
                              dataRowHeight:  MediaQuery.of(context).size.width < 500 ?50:60,
                              // horizontalMargin: 10,
                              columns: [
                                DataColumn(
                                    label:
                                    Expanded(
                                      child: Text(
                                        'Rentalowner \nName',
                                        style: TextStyle(
                                            fontSize:
                                            MediaQuery.of(context).size.width < 500 ? 14 : 18,
                                            fontWeight:
                                            FontWeight.bold,color: blueColor
                                        ),
                                      ),
                                    )),
                                DataColumn(
                                    label:
                                    Expanded(
                                      child: Text(
                                        'Processor ID  ',
                                        style: TextStyle(
                                            fontSize:
                                            MediaQuery.of(context).size.width < 500 ? 14 : 18,
                                            fontWeight:
                                            FontWeight.bold,
                                            color: blueColor
                                        ),
                                      ),
                                    )),
                                DataColumn(
                                    label:
                                    Expanded(
                                      child: Text(
                                        'Select ',
                                        style: TextStyle(
                                            fontSize:
                                            MediaQuery.of(context).size.width < 500 ? 14 : 18,
                                            fontWeight:
                                            FontWeight.bold,
                                            color: blueColor
                                        ),
                                      ),
                                    )),
                              ],
                              rows: List<
                                  DataRow>.generate(
                                filteredOwners
                                    .length,
                                    (index) =>
                                    DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            '${filteredOwners[index].rentalOwnername} '
                                                '(${filteredOwners[index].phoneNumber})',
                                            style: TextStyle(
                                                fontSize:
                                                MediaQuery.of(context).size.width < 500 ? 13 : 18),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            filteredOwners[index]
                                                .processorList
                                                .map((processor) =>
                                            processor.processorId)
                                                .join('\n'), // Join processor IDs with newline
                                            style: TextStyle(
                                                fontSize:
                                                MediaQuery.of(context).size.width < 500 ? 13 : 18),
                                          ),
                                        ),
                                        DataCell(

                                          SizedBox(
                                            height:
                                            10,
                                            width:
                                            35,
                                            child:
                                            Checkbox(
                                              value:
                                              selectedIndex == index,
                                              onChanged:
                                                  (bool? value) {
                                                setState(() {
                                                  if (value != null && value) {
                                                    selectedIndex = index;
                                                    selectedOwner = filteredOwners[index];
                                                    firstname.text = selectedOwner!.rentalOwnername;
                                                    comname.text = selectedOwner!.companyName;
                                                    primaryemail.text = selectedOwner!.primaryEmail;
                                                    alternativeemail.text = selectedOwner!.alternateEmail;
                                                    homenum.text = selectedOwner!.homeNumber ?? '';
                                                    phonenum.text = selectedOwner!.phoneNumber;
                                                    businessnum.text = selectedOwner!.businessNumber ?? '';
                                                    street2.text = selectedOwner!.streetAddress;
                                                    city2.text = selectedOwner!.city;
                                                    state2.text = selectedOwner!.state;
                                                    county2.text = selectedOwner!.country;
                                                    code2.text = selectedOwner!.postalCode;
                                                    proid.text = selectedOwner!.processorList.map((processor) => processor.processorId).join(', ');
                                                  } else {
                                                    selectedIndex = null;
                                                  }
                                                  isChecked2 = true;
                                                  isChecked = false;
                                                  _processorGroups.clear();
                                                  for (Processor processor in selectedOwner!.processorList) {
                                                    _processorGroups.add(ProcessorGroup(isChecked: false, controller: TextEditingController(text: processor.processorId)));
                                                  }
                                                });
                                              },
                                              activeColor: Color.fromRGBO(
                                                  21,
                                                  43,
                                                  81,
                                                  1),
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
                    :
                Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Color.fromRGBO(21, 43, 81, 1)),
                          ),
                          child: Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: 10,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        "Contact Name",
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
                                                  cursorColor: Color.fromRGBO(
                                                      21, 43, 81, 1),
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
                                      ? Center(
                                          child: Text(
                                          firstnamemessage,
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
                                        "Company Name",
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
                                                  cursorColor: Color.fromRGBO(
                                                      21, 43, 81, 1),
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
                                      ? Center(
                                          child: Text(
                                          comnamemessage,
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
                                        "Primary Email",
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
                                                  cursorColor: Color.fromRGBO(
                                                      21, 43, 81, 1),
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
                                      ? Center(
                                          child: Text(
                                          primaryemailmessage,
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
                                                  cursorColor: Color.fromRGBO(
                                                      21, 43, 81, 1),
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
                                        "Phone Numbers",
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
                                                  keyboardType: TextInputType.numberWithOptions(signed: true,decimal: true), // Adjust as needed
                                                  onChanged: (value) {
                                                    setState(() {
                                                      phonenumerror = false;
                                                    });
                                                  },
                                                  controller: phonenum,
                                                  cursorColor: Color.fromRGBO(
                                                      21, 43, 81, 1),
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
                                      ? Center(
                                          child: Text(
                                          phonenummessage,
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
                                                  keyboardType: TextInputType.numberWithOptions(signed: true,decimal: true), // Adjust as needed
                                                  onChanged: (value) {
                                                    setState(() {
                                                      homenumerror = false;
                                                    });
                                                  },
                                                  controller: homenum,
                                                  cursorColor: Color.fromRGBO(
                                                      21, 43, 81, 1),
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
                                                  keyboardType: TextInputType.numberWithOptions(signed: true,decimal: true), // Adjust as needed
                                                  onChanged: (value) {
                                                    setState(() {
                                                      businessnumerror = false;
                                                    });
                                                  },
                                                  controller: businessnum,
                                                  cursorColor: Color.fromRGBO(
                                                      21, 43, 81, 1),
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
                                                  cursorColor: Color.fromRGBO(
                                                      21, 43, 81, 1),
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
                                                        keyboardType: TextInputType.numberWithOptions(signed: true,decimal: true),
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
                               /* //  if (selectedOwner != null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 13),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [

                                            Row(
                                              children: [
                                                Text(
                                                  "Merchant Id",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF8A95A8),
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Column(
                                              children: [
                                                Column(
                                                    children: _processorGroups
                                                        .map((group) {
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 8.0),
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                          width: 20.0,
                                                          height: 20.0,
                                                          child: Checkbox(
                                                            value: group
                                                                ?.isChecked,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                group?.isChecked =
                                                                    value ??
                                                                        false;
                                                                processor_id = group.controller.text;
                                                              });
                                                            },
                                                            activeColor:
                                                                Color.fromRGBO(
                                                                    21,
                                                                    43,
                                                                    81,
                                                                    1),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .02),
                                                        Expanded(
                                                          child: Material(
                                                            elevation: 3,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            child: Container(
                                                              height: 50,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                color: Colors
                                                                    .white,
                                                                border: Border.all(
                                                                    color: Color(
                                                                        0xFF8A95A8)),
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  Positioned
                                                                      .fill(
                                                                    child:
                                                                        TextField(
                                                                      controller:
                                                                          group
                                                                              .controller,
                                                                      cursorColor:
                                                                          Color.fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                      decoration:
                                                                          InputDecoration(
                                                                        border:
                                                                            InputBorder.none,
                                                                        contentPadding: EdgeInsets.only(
                                                                            top:
                                                                                12.5,
                                                                            bottom:
                                                                                12.5,
                                                                            left:
                                                                                15),
                                                                        hintText:
                                                                            "Enter processor",
                                                                        hintStyle:
                                                                            TextStyle(
                                                                          color:
                                                                              Color(0xFF8A95A8),
                                                                          fontSize:
                                                                              13,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .02),
                                                        InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              _processorGroups
                                                                  .remove(
                                                                      group);
                                                            });
                                                          },
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            child: FaIcon(
                                                              FontAwesomeIcons
                                                                  .trashCan,
                                                              size: 20,
                                                              color: Color
                                                                  .fromRGBO(
                                                                      21,
                                                                      43,
                                                                      81,
                                                                      1),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList())
                                              ],
                                            ),
                                            SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.01),
                                            Row(
                                              children: [
                                                // Handle error display here if needed
                                              ],
                                            ),

                                        ],
                                      ),
                                    ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 13,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            print("calling");
                                            _processorGroups.add(ProcessorGroup(
                                                isChecked: false,
                                                controller:
                                                    TextEditingController()));
                                            print(_processorGroups.length);
                                          });
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          child: Container(
                                            height: 40.0,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .3,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              color:
                                                  Color.fromRGBO(21, 43, 81, 1),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey,
                                                  offset:
                                                      Offset(0.0, 1.0), //(x,y)
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
                                                      "Add another",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 10),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),*/
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.05),
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


                        List<ProcessorList> selectedProcessors = _processorGroups
                        //  .where((group) => group.isChecked)
                            .map((group) => ProcessorList(processorId: group.controller.text.trim())) // Create ProcessorList objects
                            .where((processor) => processor.processorId!.isNotEmpty) // Filter out empty IDs
                            .toList();
                        Ownersdetails = RentalOwner(
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
                        context
                            .read<
                            OwnerDetailsProvider>()
                            .selectedprocessid(
                            processor_id!);
                        context.read<OwnerDetailsProvider>().setOwnerDetails(Ownersdetails!);
                        Fluttertoast.showToast(
                          msg: "Rental Owner Added Successfully!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.TOP,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                        setState(() {
                          hasError = false; // Set error state if needed
                        });
                        Navigator.pop(context);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Container(
                         height:  40.0,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Color.fromRGBO(21, 43, 81, 1),
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
                          height:
                          40.0,
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
                                        color: Color.fromRGBO(21, 43, 81, 1),
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
      id: json['_id'],
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

class RentalOwnerSource extends DataTableSource {
  final List<RentalOwner> rentalowner;
  final Function(RentalOwner) onEdit;
  final Function(RentalOwner) onDelete;

  RentalOwnerSource(this.rentalowner,
      {required this.onEdit, required this.onDelete});

  @override
  DataRow getRow(int index) {
    final rental = rentalowner[index];
    return DataRow(cells: [
      DataCell(Text(rental.rentalOwnerName!)),
      DataCell(Text(rental.rentalOwnerPhoneNumber!)),
      DataCell(Row(
        children: [
          InkWell(
            onTap: () {
              onEdit(rental);
            },
            child: Container(
              //  color: Colors.redAccent,
              padding: EdgeInsets.zero,
              child: FaIcon(
                FontAwesomeIcons.edit,
                size: 20,
              ),
            ),
          ),
          SizedBox(
            width: 4,
          ),
          InkWell(
            onTap: () {
              onDelete(rental);
            },
            child: Container(
              //    color: Colors.redAccent,
              padding: EdgeInsets.zero,
              child: FaIcon(
                FontAwesomeIcons.trashCan,
                size: 20,
              ),
            ),
          ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => rentalowner.length;

  @override
  int get selectedRowCount => 0;
}
