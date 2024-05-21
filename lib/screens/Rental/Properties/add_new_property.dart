import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/model/staffmember.dart';
import 'package:three_zero_two_property/repository/Staffmember.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../../repository/Property_type.dart';
import '../../../widgets/drawer_tiles.dart';

class Add_new_property extends StatefulWidget {
  const Add_new_property({super.key});

  @override
  State<Add_new_property> createState() => _Add_new_propertyState();
}

class _Add_new_propertyState extends State<Add_new_property> {
  List<String> months = ['Residential', "Commercial"];
  final List<String> items = [
    'Residential',
    "Commercial",
  ];
  bool isLoading = false;
  String? selectedValue;
  bool isChecked = false;
  bool isChecked2 = false;
  String selectedMonth = 'Residential';

  TextEditingController city = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController postalcode = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController subtype = TextEditingController();

  bool addresserror = false;
  bool cityerror = false;
  bool stateerror = false;
  bool countryerror = false;
  bool postalcodeerror = false;
  bool subtypeerror = false;
  bool propertyTypeError = false;

  String addressmessage = "";
  String citymessage = "";
  String statemessage = "";
  String countrymessage = "";
  String postalcodemessage = "";
  String subtypemessage = "";
  String propertyTypeErrorMessage = "";
  //add rental owner
  TextEditingController firstname = TextEditingController();
  TextEditingController lastname = TextEditingController();
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

  bool firstnameerror = false;
  bool lastnameerror = false;
  bool comnameerror = false;
  bool primaryemailerror = false;
  bool alternativeerror = false;
  bool emailerror = false;
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
  String lastnamemessage = "";
  String comnamemessage = "";
  String primaryemailmessage = "";
  String alternativemessage = "";
  String emailmessage = "";
  String phonenummessage = "";
  String homenummessage = "";
  String businessnummessage = "";
  String street2message = "";
  String city2message = "";
  String state2message = "";
  String county2message = "";
  String code2message = "";
  String proidmessage = "";

  List<RentalOwner> owners = [
    RentalOwner(name: 'Michal Patrick', id: '23456789', processorIds: ['ccprocessora', 'ccprocessorb']),
    RentalOwner(name: 'Erik Ohline', id: '3023790401', processorIds: []),
    RentalOwner(name: 'Brian Raboin', id: '15551234567', processorIds: []),
    RentalOwner(name: 'NDG 302 LLC', id: '4596235689', processorIds: []),
  ];

  late List<RentalOwner> filteredOwners;
  late List<bool> selected;
  TextEditingController searchController = TextEditingController();

  Future<List<Staffmembers>>? futureProperties;
  String? selectedProperty;



  @override
  void initState() {
    super.initState();
    filteredOwners = owners;
    selected = List<bool>.generate(owners.length, (index) => false);
    searchController.addListener(_filterOwners);
    futureProperties = StaffMemberRepository().fetchStaffmembers();
  }

  void _filterOwners() {
    setState(() {
      filteredOwners = owners
          .where((owner) =>
      owner.name.toLowerCase().contains(searchController.text.toLowerCase()) ||
          owner.id.contains(searchController.text))
          .toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  bool iserror = false;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: Drawer(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo.png"),
              ),
              SizedBox(height: 40),
              buildListTile(
                  context,
                  Icon(
                    CupertinoIcons.circle_grid_3x3,
                    color: Colors.black,
                  ),
                  "Dashboard",
                  false),
              buildListTile(
                  context,
                  Icon(
                    CupertinoIcons.house,
                    color: Colors.black,
                  ),
                  "Add Property Type",
                  false),
              buildListTile(
                  context,
                  Icon(
                    CupertinoIcons.person_add,
                    color: Colors.black,
                  ),
                  "Add Staff Member",
                  false),
              buildDropdownListTile(
                  context,
                  FaIcon(
                    FontAwesomeIcons.key,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Rental",
                  ["Properties", "RentalOwner", "Tenants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  FaIcon(
                    FontAwesomeIcons.thumbsUp,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Leasing",
                  ["Rent Roll", "Applicants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"],
                  selectedSubtopic: "Properties"),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child:
        Padding(
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
                    padding: EdgeInsets.only(top: 8, left: 10),
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
                      "Add Property",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                "New Property ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(21, 43, 81, 1),
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
                                width: 15,
                              ),
                              Text(
                                "Property information",
                                style: TextStyle(
                                    color: Color(0xFF8A95A8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                "What is the property Type?",
                                style: TextStyle(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 15,
                              ),
                              DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: const Row(
                                    children: [
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Property Type',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF8A95A8),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  items: items
                                      .map((String item) =>
                                          DropdownMenuItem<String>(
                                            value: item,
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ))
                                      .toList(),
                                  value: selectedValue,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedValue = value;
                                    });
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    height: 30,
                                    width: 134,
                                    padding: const EdgeInsets.only(
                                        left: 14, right: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(
                                        color: Colors.black26,
                                      ),
                                      color: Colors.white,
                                    ),
                                    elevation: 3,
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 200,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      //color: Colors.redAccent,
                                    ),
                                    offset: const Offset(-20, 0),
                                    scrollbarTheme: ScrollbarThemeData(
                                      radius: const Radius.circular(40),
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
                                ),
                              ),
                            ],
                          ),
                          propertyTypeError
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Text(
                                      propertyTypeErrorMessage,
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .03),
                                    ),
                                  ],
                                )
                              : Container(),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                "What is the street  address?",
                                style: TextStyle(
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                "Address*",
                                style: TextStyle(
                                    color: Color(0xFF8A95A8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
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
                                child: Material(
                                  elevation: 3,
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                      5),
                                  child:
                                  Container(
                                    height: 35,
                                    decoration:
                                    BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(
                                          5),
                                      color: Colors
                                          .white,
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
                                            onChanged:
                                                (value) {
                                              setState(() {
                                                addresserror = false;
                                              });
                                            },
                                            controller:
                                            address,
                                            //  keyboardType: TextInputType.emailAddress,
                                            cursorColor: Color.fromRGBO(
                                                21,
                                                43,
                                                81,
                                                1),
                                            decoration:
                                            InputDecoration(
                                              border: InputBorder.none,
                                              enabledBorder: addresserror
                                                  ? OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(5),
                                                borderSide: BorderSide(color: Colors.red), // Set border color here
                                              )
                                                  : InputBorder.none,
                                              contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                              // prefixIcon: Padding(
                                              //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                              //   child: FaIcon(
                                              //     FontAwesomeIcons.envelope,
                                              //     size: 18,
                                              //     color: Color(0xFF8A95A8),
                                              //   ),
                                              // ),
                                              hintText: "Enter address here...",
                                              hintStyle: TextStyle(
                                                color: Color(0xFF8A95A8),
                                                fontSize: 13,
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
                                width: 15,
                              ),
                            ],
                          ),
                          addresserror
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Text(
                                      addressmessage,
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .04),
                                    ),
                                  ],
                                )
                              : Container(),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .043,
                              ),
                              Text(
                                "City*",
                                style: TextStyle(
                                    color: Color(0xFF8A95A8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .29,
                              ),
                              Text(
                                "State*",
                                style: TextStyle(
                                    color: Color(0xFF8A95A8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 9,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Material(
                                  elevation: 3,
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                      5),
                                  child:
                                  Container(
                                    height: 35,
                                    decoration:
                                    BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(
                                          5),
                                      color: Colors
                                          .white,
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
                                            onChanged:
                                                (value) {
                                              setState(() {
                                                cityerror = false;
                                              });
                                            },
                                            controller:
                                            city,
                                            //  keyboardType: TextInputType.emailAddress,
                                            cursorColor: Color.fromRGBO(
                                                21,
                                                43,
                                                81,
                                                1),
                                            decoration:
                                            InputDecoration(
                                              border: InputBorder.none,
                                              enabledBorder: cityerror
                                                  ? OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(5),
                                                borderSide: BorderSide(color: Colors.red), // Set border color here
                                              )
                                                  : InputBorder.none,
                                              contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                              // prefixIcon: Padding(
                                              //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                              //   child: FaIcon(
                                              //     FontAwesomeIcons.envelope,
                                              //     size: 18,
                                              //     color: Color(0xFF8A95A8),
                                              //   ),
                                              // ),
                                              hintText: "Enter city here...",
                                              hintStyle: TextStyle(
                                                color: Color(0xFF8A95A8),
                                                fontSize: 13,
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
                                width: 5,
                              ),
                              Expanded(
                                child: Material(
                                  elevation: 3,
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                      5),
                                  child:
                                  Container(
                                    height: 35,
                                    decoration:
                                    BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(
                                          5),
                                      color: Colors
                                          .white,
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
                                            onChanged:
                                                (value) {
                                              setState(() {
                                                stateerror = false;
                                              });
                                            },
                                            controller:
                                            state,
                                            //  keyboardType: TextInputType.emailAddress,
                                            cursorColor: Color.fromRGBO(
                                                21,
                                                43,
                                                81,
                                                1),
                                            decoration:
                                            InputDecoration(
                                              border: InputBorder.none,
                                              enabledBorder: stateerror
                                                  ? OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(5),
                                                borderSide: BorderSide(color: Colors.red), // Set border color here
                                              )
                                                  : InputBorder.none,
                                              contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                              // prefixIcon: Padding(
                                              //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                              //   child: FaIcon(
                                              //     FontAwesomeIcons.envelope,
                                              //     size: 18,
                                              //     color: Color(0xFF8A95A8),
                                              //   ),
                                              // ),
                                              hintText: "Enter state here...",
                                              hintStyle: TextStyle(
                                                color: Color(0xFF8A95A8),
                                                fontSize: 13,
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
                                width: 15,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              cityerror
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          citymessage,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .04),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              SizedBox(
                                width: 45,
                              ),
                              stateerror
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          statemessage,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .04),
                                        ),
                                      ],
                                    )
                                  : Container(),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .043,
                              ),
                              Text(
                                "Country*",
                                style: TextStyle(
                                    color: Color(0xFF8A95A8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .23,
                              ),
                              Text(
                                "Postal Code*",
                                style: TextStyle(
                                    color: Color(0xFF8A95A8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 9,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Material(
                                  elevation: 3,
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                      5),
                                  child:
                                  Container(
                                    height: 35,
                                    decoration:
                                    BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(
                                          5),
                                      color: Colors
                                          .white,
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
                                            onChanged:
                                                (value) {
                                              setState(() {
                                                countryerror = false;
                                              });
                                            },
                                            controller:
                                            country,
                                            //  keyboardType: TextInputType.emailAddress,
                                            cursorColor: Color.fromRGBO(
                                                21,
                                                43,
                                                81,
                                                1),
                                            decoration:
                                            InputDecoration(
                                              border: InputBorder.none,
                                              enabledBorder: countryerror
                                                  ? OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(5),
                                                borderSide: BorderSide(color: Colors.red), // Set border color here
                                              )
                                                  : InputBorder.none,
                                              contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                              // prefixIcon: Padding(
                                              //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                              //   child: FaIcon(
                                              //     FontAwesomeIcons.envelope,
                                              //     size: 18,
                                              //     color: Color(0xFF8A95A8),
                                              //   ),
                                              // ),
                                              hintText: "Enter country here...",
                                              hintStyle: TextStyle(
                                                color: Color(0xFF8A95A8),
                                                fontSize: 13,
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
                                width: 5,
                              ),
                              Expanded(
                                child: Material(
                                  elevation: 3,
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                      5),
                                  child:
                                  Container(
                                    height: 35,
                                    decoration:
                                    BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(
                                          5),
                                      color: Colors
                                          .white,
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
                                            onChanged:
                                                (value) {
                                              setState(() {
                                                postalcodeerror = false;
                                              });
                                            },
                                            controller:
                                            postalcode,
                                            //  keyboardType: TextInputType.emailAddress,
                                            cursorColor: Color.fromRGBO(
                                                21,
                                                43,
                                                81,
                                                1),
                                            decoration:
                                            InputDecoration(
                                              border: InputBorder.none,
                                              enabledBorder: postalcodeerror
                                                  ? OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(5),
                                                borderSide: BorderSide(color: Colors.red), // Set border color here
                                              )
                                                  : InputBorder.none,
                                              contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                              // prefixIcon: Padding(
                                              //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                              //   child: FaIcon(
                                              //     FontAwesomeIcons.envelope,
                                              //     size: 18,
                                              //     color: Color(0xFF8A95A8),
                                              //   ),
                                              // ),
                                              hintText: "Enter postal code here...",
                                              hintStyle: TextStyle(
                                                color: Color(0xFF8A95A8),
                                                fontSize: 13,
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
                                width: 15,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              countryerror
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          countrymessage,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .04),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              SizedBox(
                                width: 45,
                              ),
                              postalcodeerror
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          postalcodemessage,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .04),
                                        ),
                                      ],
                                    )
                                  : Container(),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  "Owner information",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(21, 43, 81, 1),
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
                                  width: 15,
                                ),
                                Text(
                                  "Who is the Property Owner ? (Required)",
                                  style: TextStyle(
                                      color: Color(0xFF8A95A8),
                                      //  fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Text(
                                    "This information will be used to help prepare owner drawns and 1099s",
                                    style: TextStyle(
                                        color: Color(0xFF8A95A8),
                                        //  fontWeight: FontWeight.bold,
                                        fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
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
                                          title: Text(
                                            "Add Rental Owner",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
                                                fontSize: 15),
                                          ),
                                          content: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    // SizedBox(width: 5,),
                                                    SizedBox(
                                                      width:
                                                          24.0, // Standard width for checkbox
                                                      height: 24.0,
                                                      child: Checkbox(
                                                        value: isChecked,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            isChecked =
                                                                value ?? false;
                                                          });
                                                        },
                                                        activeColor: isChecked
                                                            ? Color.fromRGBO(
                                                                21, 43, 81, 1)
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
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xFF8A95A8),
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                isChecked
                                                    ? Column(
                                                        children: [
                                                          SizedBox(
                                                              height: 16.0),
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
                                                                    height: 35,
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
                                                                            controller:
                                                                            searchController,
                                                                            //keyboardType: TextInputType.emailAddress,
                                                                            cursorColor: Color.fromRGBO(
                                                                                21,
                                                                                43,
                                                                                81,
                                                                                1),
                                                                            decoration:
                                                                            InputDecoration(
                                                                              border: InputBorder.none,
                                                                              contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                              // prefixIcon: Padding(
                                                                              //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                              //   child: FaIcon(
                                                                              //     FontAwesomeIcons.envelope,
                                                                              //     size: 18,
                                                                              //     color: Color(0xFF8A95A8),
                                                                              //   ),
                                                                              // ),
                                                                              hintText: "Search by first and last name",
                                                                              hintStyle: TextStyle(
                                                                                color: Color(0xFF8A95A8),
                                                                                fontSize: 13,
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
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(5),
                                                              border: Border.all(color: Colors.grey),
                                                            ),
                                                            child: DataTable(
                                                              columnSpacing: 10,
                                                              headingRowHeight: 29,
                                                              dataRowHeight: 30,
                                                              // horizontalMargin: 10,
                                                              columns: [
                                                                DataColumn(
                                                                    label: Expanded(
                                                                      child: Text(
                                                                        'Rentalowner \nName',style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),),
                                                                    )),
                                                                DataColumn(
                                                                    label: Expanded(
                                                                      child: Text(
                                                                        'Processor \nID',style: TextStyle(fontSize: 11,fontWeight: FontWeight.bold),),
                                                                    )),
                                                                DataColumn(
                                                                    label: Expanded(
                                                                      child: Text(
                                                                        'Select \n',style: TextStyle(fontSize: 11,fontWeight: FontWeight.bold),),
                                                                    )),
                                                              ],
                                                              rows: List<
                                                                  DataRow>.generate(
                                                                filteredOwners
                                                                    .length,
                                                                    (index) =>
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(Text(
                                                                          '${filteredOwners[index].name} '
                                                                              '(${filteredOwners[index].id})',style: TextStyle(fontSize: 10),),),
                                                                        DataCell(
                                                                          Text(filteredOwners[
                                                                          index]
                                                                              .processorIds
                                                                              .join(
                                                                            '\n',),style: TextStyle(fontSize: 10),
                                                                          ),
                                                                        ),
                                                                        DataCell(

                                                                          SizedBox(
                                                                            height: 10,
                                                                            width: 10,
                                                                            child: Checkbox(
                                                                              value: selected[
                                                                              owners.indexOf(filteredOwners[index])],
                                                                              onChanged:
                                                                                  (bool?
                                                                              value) {
                                                                                setState(
                                                                                        () {
                                                                                      selected[owners.indexOf(filteredOwners[index])] =
                                                                                      value!;
                                                                                    });
                                                                              },
                                                                              activeColor: Color.fromRGBO(
                                                                                  21, 43, 81, 1),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                              ),
                                                            ),
                                                          ),

                                                          SizedBox(
                                                              height: 16.0),
                                                          Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                            children: [
                                                              GestureDetector(
                                                                // onTap: () async {
                                                                //   if (selectedValue == null || subtype.text.isEmpty) {
                                                                //     setState(() {
                                                                //       iserror = true;
                                                                //     });
                                                                //   } else {
                                                                //     setState(() {
                                                                //       isLoading = true;
                                                                //       iserror = false;
                                                                //     });
                                                                //     SharedPreferences prefs =
                                                                //     await SharedPreferences.getInstance();
                                                                //
                                                                //     String? id = prefs.getString("adminId");
                                                                //     PropertyTypeRepository()
                                                                //         .addPropertyType(
                                                                //       adminId: id!,
                                                                //       propertyType: selectedValue,
                                                                //       propertySubType: subtype.text,
                                                                //       isMultiUnit: isChecked,
                                                                //     )
                                                                //         .then((value) {
                                                                //       setState(() {
                                                                //         isLoading = false;
                                                                //       });
                                                                //     }).catchError((e) {
                                                                //       setState(() {
                                                                //         isLoading = false;
                                                                //       });
                                                                //     });
                                                                //   }
                                                                //   print(selectedValue);
                                                                // },
                                                                child:
                                                                ClipRRect(
                                                                  borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                      5.0),
                                                                  child:
                                                                  Container(
                                                                    height:
                                                                    30.0,
                                                                    width: 50,
                                                                    decoration:
                                                                    BoxDecoration(
                                                                      borderRadius:
                                                                      BorderRadius.circular(
                                                                          5.0),
                                                                      color: Color
                                                                          .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color:
                                                                          Colors.grey,
                                                                          offset: Offset(
                                                                              0.0,
                                                                              1.0), //(x,y)
                                                                          blurRadius:
                                                                          6.0,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child:
                                                                    Center(
                                                                      child: isLoading
                                                                          ? SpinKitFadingCircle(
                                                                        color: Colors.white,
                                                                        size: 25.0,
                                                                      )
                                                                          : Text(
                                                                        "Add",
                                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: MediaQuery.of(
                                                                      context)
                                                                      .size
                                                                      .width *
                                                                      0.03),
                                                              GestureDetector(
                                                              onTap:(){
                                                                Navigator.pop(context);
                                                              },
                                                                child:
                                                                ClipRRect(
                                                                  borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                      5.0),
                                                                  child:
                                                                  Container(
                                                                    height:
                                                                    30.0,
                                                                    width: 50,
                                                                    decoration:
                                                                    BoxDecoration(
                                                                      borderRadius:
                                                                      BorderRadius.circular(
                                                                          5.0),
                                                                      color: Colors
                                                                          .white,
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color:
                                                                          Colors.grey,
                                                                          offset: Offset(
                                                                              0.0,
                                                                              1.0), //(x,y)
                                                                          blurRadius:
                                                                          6.0,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child:
                                                                    Center(
                                                                      child: isLoading
                                                                          ? SpinKitFadingCircle(
                                                                        color: Colors.white,
                                                                        size: 25.0,
                                                                      )
                                                                          : Text(
                                                                        "Cancel",
                                                                        style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold, fontSize: 10),
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
                                                Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 25,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "Name*",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          //firstname
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
                                                                    height: 35,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      color: Colors
                                                                          .white,
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
                                                                            onChanged:
                                                                                (value) {
                                                                              setState(() {
                                                                                firstnameerror = false;
                                                                              });
                                                                            },
                                                                            controller:
                                                                                firstname,
                                                                            //  keyboardType: TextInputType.emailAddress,
                                                                            cursorColor: Color.fromRGBO(
                                                                                21,
                                                                                43,
                                                                                81,
                                                                                1),
                                                                            decoration:
                                                                                InputDecoration(
                                                                              border: InputBorder.none,
                                                                              enabledBorder: firstnameerror
                                                                                  ? OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.circular(5),
                                                                                      borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                    )
                                                                                  : InputBorder.none,
                                                                              contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                              // prefixIcon: Padding(
                                                                              //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                              //   child: FaIcon(
                                                                              //     FontAwesomeIcons.envelope,
                                                                              //     size: 18,
                                                                              //     color: Color(0xFF8A95A8),
                                                                              //   ),
                                                                              // ),
                                                                              hintText: "Enter first name here...",
                                                                              hintStyle: TextStyle(
                                                                                color: Color(0xFF8A95A8),
                                                                                fontSize: 13,
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
                                                          firstnameerror
                                                              ? Center(
                                                                  child: Text(
                                                                  firstnamemessage,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ))
                                                              : Container(),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.02),
                                                          //lastname
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
                                                                    height: 35,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      color: Colors
                                                                          .white,
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
                                                                            onChanged:
                                                                                (value) {
                                                                              setState(() {
                                                                                lastnameerror = false;
                                                                              });
                                                                            },
                                                                            controller:
                                                                                lastname,
                                                                            //  keyboardType: TextInputType.emailAddress,
                                                                            cursorColor: Color.fromRGBO(
                                                                                21,
                                                                                43,
                                                                                81,
                                                                                1),
                                                                            decoration:
                                                                                InputDecoration(
                                                                              border: InputBorder.none,
                                                                              enabledBorder: lastnameerror
                                                                                  ? OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.circular(5),
                                                                                      borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                    )
                                                                                  : InputBorder.none,
                                                                              contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                              // prefixIcon: Padding(
                                                                              //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                              //   child: FaIcon(
                                                                              //     FontAwesomeIcons.envelope,
                                                                              //     size: 18,
                                                                              //     color: Color(0xFF8A95A8),
                                                                              //   ),
                                                                              // ),
                                                                              hintText: "Enter last name here...",
                                                                              hintStyle: TextStyle(
                                                                                color: Color(0xFF8A95A8),
                                                                                fontSize: 13,
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
                                                          lastnameerror
                                                              ? Center(
                                                                  child: Text(
                                                                  lastnamemessage,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ))
                                                              : Container(),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.02),
                                                          //company name
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "Company Name*",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
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
                                                                    height: 35,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      color: Colors
                                                                          .white,
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
                                                                            onChanged:
                                                                                (value) {
                                                                              setState(() {
                                                                                comnameerror = false;
                                                                              });
                                                                            },
                                                                            controller:
                                                                                comname,
                                                                            //keyboardType: TextInputType.emailAddress,
                                                                            cursorColor: Color.fromRGBO(
                                                                                21,
                                                                                43,
                                                                                81,
                                                                                1),
                                                                            decoration:
                                                                                InputDecoration(
                                                                              border: InputBorder.none,
                                                                              enabledBorder: comnameerror
                                                                                  ? OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.circular(5),
                                                                                      borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                    )
                                                                                  : InputBorder.none,
                                                                              contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                              // prefixIcon: Padding(
                                                                              //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                              //   child: FaIcon(
                                                                              //     FontAwesomeIcons.envelope,
                                                                              //     size: 18,
                                                                              //     color: Color(0xFF8A95A8),
                                                                              //   ),
                                                                              // ),
                                                                              hintText: "Enter company name here...",
                                                                              hintStyle: TextStyle(
                                                                                color: Color(0xFF8A95A8),
                                                                                fontSize: 13,
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
                                                          comnameerror
                                                              ? Center(
                                                                  child: Text(
                                                                  comnamemessage,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ))
                                                              : Container(),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.02),
                                                          //primary email
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "Primary Email*",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
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
                                                                    height: 35,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      color: Colors
                                                                          .white,
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
                                                                            onChanged:
                                                                                (value) {
                                                                              setState(() {
                                                                                primaryemailerror = false;
                                                                              });
                                                                            },
                                                                            controller:
                                                                                primaryemail,
                                                                            keyboardType:
                                                                                TextInputType.emailAddress,
                                                                            cursorColor: Color.fromRGBO(
                                                                                21,
                                                                                43,
                                                                                81,
                                                                                1),
                                                                            decoration:
                                                                                InputDecoration(
                                                                              border: InputBorder.none,
                                                                              enabledBorder: primaryemailerror
                                                                                  ? OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.circular(5),
                                                                                      borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                    )
                                                                                  : InputBorder.none,
                                                                              contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5),
                                                                              prefixIcon: Padding(
                                                                                padding: const EdgeInsets.only(left: 15, top: 7, bottom: 8),
                                                                                child: FaIcon(
                                                                                  FontAwesomeIcons.envelope,
                                                                                  size: 18,
                                                                                  color: Color(0xFF8A95A8),
                                                                                ),
                                                                              ),
                                                                              hintText: "Enter primery email here...",
                                                                              hintStyle: TextStyle(
                                                                                color: Color(0xFF8A95A8),
                                                                                fontSize: 13,
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
                                                          primaryemailerror
                                                              ? Center(
                                                                  child: Text(
                                                                  primaryemailmessage,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ))
                                                              : Container(),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.02),
                                                          //Alternative Email
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "Alternative Email*",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
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
                                                                    height: 35,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      color: Colors
                                                                          .white,
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
                                                                            onChanged:
                                                                                (value) {
                                                                              setState(() {
                                                                                alternativeerror = false;
                                                                              });
                                                                            },
                                                                            controller:
                                                                                alternativeemail,
                                                                            keyboardType:
                                                                                TextInputType.emailAddress,
                                                                            cursorColor: Color.fromRGBO(
                                                                                21,
                                                                                43,
                                                                                81,
                                                                                1),
                                                                            decoration:
                                                                                InputDecoration(
                                                                              border: InputBorder.none,
                                                                              enabledBorder: alternativeerror
                                                                                  ? OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.circular(5),
                                                                                      borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                    )
                                                                                  : InputBorder.none,
                                                                              contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5),
                                                                              prefixIcon: Padding(
                                                                                padding: const EdgeInsets.only(left: 15, top: 7, bottom: 8),
                                                                                child: FaIcon(
                                                                                  FontAwesomeIcons.envelope,
                                                                                  size: 18,
                                                                                  color: Color(0xFF8A95A8),
                                                                                ),
                                                                              ),
                                                                              hintText: "Enter alternative email here...",
                                                                              hintStyle: TextStyle(
                                                                                color: Color(0xFF8A95A8),
                                                                                fontSize: 13,
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
                                                          alternativeerror
                                                              ? Center(
                                                                  child: Text(
                                                                  alternativemessage,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ))
                                                              : Container(),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.02),
                                                          //Phone Numbers
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "Phone Numbers*",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
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
                                                                    height: 35,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      color: Colors
                                                                          .white,
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
                                                                            onChanged:
                                                                                (value) {
                                                                              setState(() {
                                                                                phonenumerror = false;
                                                                              });
                                                                            },
                                                                            controller:
                                                                                phonenum,
                                                                            keyboardType:
                                                                                TextInputType.phone,
                                                                            cursorColor: Color.fromRGBO(
                                                                                21,
                                                                                43,
                                                                                81,
                                                                                1),
                                                                            decoration:
                                                                                InputDecoration(
                                                                              border: InputBorder.none,
                                                                              enabledBorder: phonenumerror
                                                                                  ? OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.circular(5),
                                                                                      borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                    )
                                                                                  : InputBorder.none,
                                                                              contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5),
                                                                              prefixIcon: Padding(
                                                                                padding: const EdgeInsets.only(left: 15, top: 7, bottom: 8),
                                                                                child: FaIcon(
                                                                                  FontAwesomeIcons.phone,
                                                                                  size: 18,
                                                                                  color: Color(0xFF8A95A8),
                                                                                ),
                                                                              ),
                                                                              hintText: "Enter phone number here...",
                                                                              hintStyle: TextStyle(
                                                                                color: Color(0xFF8A95A8),
                                                                                fontSize: 13,
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
                                                          phonenumerror
                                                              ? Center(
                                                                  child: Text(
                                                                  phonenummessage,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ))
                                                              : Container(),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.01),
                                                          //homenumber
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
                                                                    height: 35,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      color: Colors
                                                                          .white,
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
                                                                            onChanged:
                                                                                (value) {
                                                                              setState(() {
                                                                                homenumerror = false;
                                                                              });
                                                                            },
                                                                            controller:
                                                                                homenum,
                                                                            keyboardType:
                                                                                TextInputType.phone,
                                                                            cursorColor: Color.fromRGBO(
                                                                                21,
                                                                                43,
                                                                                81,
                                                                                1),
                                                                            decoration:
                                                                                InputDecoration(
                                                                              border: InputBorder.none,
                                                                              enabledBorder: homenumerror
                                                                                  ? OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.circular(5),
                                                                                      borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                    )
                                                                                  : InputBorder.none,
                                                                              contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5),
                                                                              prefixIcon: Padding(
                                                                                padding: const EdgeInsets.only(left: 15, top: 7, bottom: 8),
                                                                                child: FaIcon(
                                                                                  FontAwesomeIcons.home,
                                                                                  size: 18,
                                                                                  color: Color(0xFF8A95A8),
                                                                                ),
                                                                              ),
                                                                              hintText: "Enter home number here...",
                                                                              hintStyle: TextStyle(
                                                                                color: Color(0xFF8A95A8),
                                                                                fontSize: 13,
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
                                                          homenumerror
                                                              ? Center(
                                                                  child: Text(
                                                                  homenummessage,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ))
                                                              : Container(),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.01),
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
                                                                    height: 35,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      color: Colors
                                                                          .white,
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
                                                                            onChanged:
                                                                                (value) {
                                                                              setState(() {
                                                                                businessnumerror = false;
                                                                              });
                                                                            },
                                                                            controller:
                                                                                businessnum,
                                                                            keyboardType:
                                                                                TextInputType.phone,
                                                                            cursorColor: Color.fromRGBO(
                                                                                21,
                                                                                43,
                                                                                81,
                                                                                1),
                                                                            decoration:
                                                                                InputDecoration(
                                                                              border: InputBorder.none,
                                                                              enabledBorder: businessnumerror
                                                                                  ? OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.circular(5),
                                                                                      borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                    )
                                                                                  : InputBorder.none,
                                                                              contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5),
                                                                              prefixIcon: Padding(
                                                                                padding: const EdgeInsets.only(left: 15, top: 7, bottom: 8),
                                                                                child: FaIcon(
                                                                                  FontAwesomeIcons.businessTime,
                                                                                  size: 18,
                                                                                  color: Color(0xFF8A95A8),
                                                                                ),
                                                                              ),
                                                                              hintText: "Enter business number here...",
                                                                              hintStyle: TextStyle(
                                                                                color: Color(0xFF8A95A8),
                                                                                fontSize: 13,
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
                                                          businessnumerror
                                                              ? Center(
                                                                  child: Text(
                                                                  businessnummessage,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ))
                                                              : Container(),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.02),
                                                          //Address information
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "Address information*",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          //Street Address
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
                                                                    height: 35,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      color: Colors
                                                                          .white,
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
                                                                            onChanged:
                                                                                (value) {
                                                                              setState(() {
                                                                                street2error = false;
                                                                              });
                                                                            },
                                                                            controller:
                                                                                street2,
                                                                            //  keyboardType: TextInputType.emailAddress,
                                                                            cursorColor: Color.fromRGBO(
                                                                                21,
                                                                                43,
                                                                                81,
                                                                                1),
                                                                            decoration:
                                                                                InputDecoration(
                                                                              border: InputBorder.none,
                                                                              enabledBorder: street2error
                                                                                  ? OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.circular(5),
                                                                                      borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                    )
                                                                                  : InputBorder.none,
                                                                              contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                              // prefixIcon: Padding(
                                                                              //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                              //   child: FaIcon(
                                                                              //     FontAwesomeIcons.envelope,
                                                                              //     size: 18,
                                                                              //     color: Color(0xFF8A95A8),
                                                                              //   ),
                                                                              // ),
                                                                              hintText: "Enter street address here...",
                                                                              hintStyle: TextStyle(
                                                                                color: Color(0xFF8A95A8),
                                                                                fontSize: 13,
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
                                                          street2error
                                                              ? Center(
                                                                  child: Text(
                                                                  street2message,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ))
                                                              : Container(),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.01),
                                                          //city and state
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
                                                                    height: 35,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      color: Colors
                                                                          .white,
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
                                                                            onChanged:
                                                                                (value) {
                                                                              setState(() {
                                                                                city2error = false;
                                                                              });
                                                                            },
                                                                            controller:
                                                                                city2,
                                                                            //  keyboardType: TextInputType.emailAddress,
                                                                            cursorColor: Color.fromRGBO(
                                                                                21,
                                                                                43,
                                                                                81,
                                                                                1),
                                                                            decoration:
                                                                                InputDecoration(
                                                                              border: InputBorder.none,
                                                                              enabledBorder: city2error
                                                                                  ? OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.circular(5),
                                                                                      borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                    )
                                                                                  : InputBorder.none,
                                                                              contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                              // prefixIcon: Padding(
                                                                              //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                              //   child: FaIcon(
                                                                              //     FontAwesomeIcons.envelope,
                                                                              //     size: 18,
                                                                              //     color: Color(0xFF8A95A8),
                                                                              //   ),
                                                                              // ),
                                                                              hintText: "Enter city here...",
                                                                              hintStyle: TextStyle(
                                                                                color: Color(0xFF8A95A8),
                                                                                fontSize: 13,
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
                                                                    .03,
                                                              ),
                                                              Expanded(
                                                                child: Material(
                                                                  elevation: 3,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  child:
                                                                      Container(
                                                                    height: 35,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      color: Colors
                                                                          .white,
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
                                                                            onChanged:
                                                                                (value) {
                                                                              setState(() {
                                                                                state2error = false;
                                                                              });
                                                                            },
                                                                            controller:
                                                                                state2,
                                                                            // keyboardType: TextInputType.emailAddress,
                                                                            cursorColor: Color.fromRGBO(
                                                                                21,
                                                                                43,
                                                                                81,
                                                                                1),
                                                                            decoration:
                                                                                InputDecoration(
                                                                              border: InputBorder.none,
                                                                              enabledBorder: state2error
                                                                                  ? OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.circular(5),
                                                                                      borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                    )
                                                                                  : InputBorder.none,
                                                                              contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                              // prefixIcon: Padding(
                                                                              //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                              //   child: FaIcon(
                                                                              //     FontAwesomeIcons.envelope,
                                                                              //     size: 18,
                                                                              //     color: Color(0xFF8A95A8),
                                                                              //   ),
                                                                              // ),
                                                                              hintText: "Enter state here...",
                                                                              hintStyle: TextStyle(
                                                                                color: Color(0xFF8A95A8),
                                                                                fontSize: 13,
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
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.01),
                                                          Row(
                                                            children: [
                                                              city2error
                                                                  ? Center(
                                                                      child:
                                                                          Text(
                                                                      city2message,
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.red),
                                                                    ))
                                                                  : Container(),
                                                              SizedBox(
                                                                width: 70,
                                                              ),
                                                              state2error
                                                                  ? Center(
                                                                      child:
                                                                          Text(
                                                                      state2message,
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.red),
                                                                    ))
                                                                  : Container(),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.01),
                                                          // counrty and postal code
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
                                                                    height: 35,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      color: Colors
                                                                          .white,
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
                                                                            onChanged:
                                                                                (value) {
                                                                              setState(() {
                                                                                county2error = false;
                                                                              });
                                                                            },
                                                                            controller:
                                                                                county2,
                                                                            // keyboardType: TextInputType.emailAddress,
                                                                            cursorColor: Color.fromRGBO(
                                                                                21,
                                                                                43,
                                                                                81,
                                                                                1),
                                                                            decoration:
                                                                                InputDecoration(
                                                                              border: InputBorder.none,
                                                                              enabledBorder: county2error
                                                                                  ? OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.circular(5),
                                                                                      borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                    )
                                                                                  : InputBorder.none,
                                                                              contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                              // prefixIcon: Padding(
                                                                              //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                              //   child: FaIcon(
                                                                              //     FontAwesomeIcons.envelope,
                                                                              //     size: 18,
                                                                              //     color: Color(0xFF8A95A8),
                                                                              //   ),
                                                                              // ),
                                                                              hintText: "Enter country here...",
                                                                              hintStyle: TextStyle(
                                                                                color: Color(0xFF8A95A8),
                                                                                fontSize: 13,
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
                                                                    .03,
                                                              ),
                                                              Expanded(
                                                                child: Material(
                                                                  elevation: 3,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  child:
                                                                      Container(
                                                                    height: 35,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      color: Colors
                                                                          .white,
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
                                                                            onChanged:
                                                                                (value) {
                                                                              setState(() {
                                                                                code2error = false;
                                                                              });
                                                                            },
                                                                            controller:
                                                                                code2,
                                                                            //  keyboardType: TextInputType.emailAddress,
                                                                            cursorColor: Color.fromRGBO(
                                                                                21,
                                                                                43,
                                                                                81,
                                                                                1),
                                                                            decoration:
                                                                                InputDecoration(
                                                                              border: InputBorder.none,
                                                                              enabledBorder: code2error
                                                                                  ? OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.circular(5),
                                                                                      borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                    )
                                                                                  : InputBorder.none,
                                                                              contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                              // prefixIcon: Padding(
                                                                              //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                              //   child: FaIcon(
                                                                              //     FontAwesomeIcons.envelope,
                                                                              //     size: 18,
                                                                              //     color: Color(0xFF8A95A8),
                                                                              //   ),
                                                                              // ),
                                                                              hintText: "Enter postal code here...",
                                                                              hintStyle: TextStyle(
                                                                                color: Color(0xFF8A95A8),
                                                                                fontSize: 13,
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
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.01),
                                                          Row(
                                                            children: [
                                                              county2error
                                                                  ? Center(
                                                                      child:
                                                                          Text(
                                                                      county2message,
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.red),
                                                                    ))
                                                                  : Container(),
                                                              SizedBox(
                                                                width: 70,
                                                              ),
                                                              code2error
                                                                  ? Center(
                                                                      child:
                                                                          Text(
                                                                      code2message,
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.red),
                                                                    ))
                                                                  : Container(),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.01),
                                                          //merchant id
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "Merchant id*",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color(
                                                                        0xFF8A95A8),
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Row(
                                                            children: [
                                                              SizedBox(
                                                                width:
                                                                    20.0, // Standard width for checkbox
                                                                height: 20.0,
                                                                child: Checkbox(
                                                                  value:
                                                                      isChecked2,
                                                                  onChanged:
                                                                      (value) {
                                                                    setState(
                                                                        () {
                                                                      isChecked2 =
                                                                          value ??
                                                                              false;
                                                                    });
                                                                  },
                                                                  activeColor: isChecked2
                                                                      ? Color.fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1)
                                                                      : Colors
                                                                          .black,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .02,
                                                              ),
                                                              Expanded(
                                                                child: Material(
                                                                  elevation: 3,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  child:
                                                                      Container(
                                                                    height: 35,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                      color: Colors
                                                                          .white,
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
                                                                            onChanged:
                                                                                (value) {
                                                                              setState(() {
                                                                                proiderror = false;
                                                                              });
                                                                            },
                                                                            controller:
                                                                                proid,
                                                                            // keyboardType: TextInputType.emailAddress,
                                                                            cursorColor: Color.fromRGBO(
                                                                                21,
                                                                                43,
                                                                                81,
                                                                                1),
                                                                            decoration:
                                                                                InputDecoration(
                                                                              border: InputBorder.none,
                                                                              enabledBorder: proiderror
                                                                                  ? OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.circular(5),
                                                                                      borderSide: BorderSide(color: Colors.red), // Set border color here
                                                                                    )
                                                                                  : InputBorder.none,
                                                                              contentPadding: EdgeInsets.only(top: 12.5, bottom: 12.5, left: 15),
                                                                              // prefixIcon: Padding(
                                                                              //   padding: const EdgeInsets.only(left: 15,top: 7,bottom: 8),
                                                                              //   child: FaIcon(
                                                                              //     FontAwesomeIcons.envelope,
                                                                              //     size: 18,
                                                                              //     color: Color(0xFF8A95A8),
                                                                              //   ),
                                                                              // ),
                                                                              hintText: "Enter proccesor here...",
                                                                              hintStyle: TextStyle(
                                                                                color: Color(0xFF8A95A8),
                                                                                fontSize: 13,
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
                                                                    .02,
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  // onDelete(property);
                                                                },
                                                                child:
                                                                    Container(
                                                                  //    color: Colors.redAccent,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
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
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.01),
                                                          Row(
                                                            children: [
                                                              proiderror
                                                                  ? Center(
                                                                      child:
                                                                          Text(
                                                                      proidmessage,
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.red),
                                                                    ))
                                                                  : Container(),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.01),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  if (firstname
                                                                      .text
                                                                      .isEmpty) {
                                                                    setState(
                                                                        () {
                                                                      firstnameerror =
                                                                          true;
                                                                      firstnamemessage =
                                                                          "required";
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      firstnameerror =
                                                                          false;
                                                                    });
                                                                  }
                                                                  if (lastname
                                                                      .text
                                                                      .isEmpty) {
                                                                    setState(
                                                                        () {
                                                                      lastnameerror =
                                                                          true;
                                                                      lastnamemessage =
                                                                          "required";
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      lastnameerror =
                                                                          false;
                                                                    });
                                                                  }
                                                                  if (comname
                                                                      .text
                                                                      .isEmpty) {
                                                                    setState(
                                                                        () {
                                                                      comnameerror =
                                                                          true;
                                                                      comnamemessage =
                                                                          "required";
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      comnameerror =
                                                                          false;
                                                                    });
                                                                  }
                                                                  if (primaryemail
                                                                      .text
                                                                      .isEmpty) {
                                                                    setState(
                                                                        () {
                                                                      primaryemailerror =
                                                                          true;
                                                                      primaryemailmessage =
                                                                          "required";
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      primaryemailerror =
                                                                          false;
                                                                    });
                                                                  }
                                                                  if (alternativeemail
                                                                      .text
                                                                      .isEmpty) {
                                                                    setState(
                                                                        () {
                                                                      alternativeerror =
                                                                          true;
                                                                      alternativemessage =
                                                                          "required";
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      alternativeerror =
                                                                          false;
                                                                    });
                                                                  }
                                                                  if (phonenum
                                                                      .text
                                                                      .isEmpty) {
                                                                    setState(
                                                                        () {
                                                                      phonenumerror =
                                                                          true;
                                                                      phonenummessage =
                                                                          "required";
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      phonenumerror =
                                                                          false;
                                                                    });
                                                                  }
                                                                  if (homenum
                                                                      .text
                                                                      .isEmpty) {
                                                                    setState(
                                                                        () {
                                                                      homenumerror =
                                                                          true;
                                                                      homenummessage =
                                                                          "required";
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      homenumerror =
                                                                          false;
                                                                    });
                                                                  }
                                                                  if (businessnum
                                                                      .text
                                                                      .isEmpty) {
                                                                    setState(
                                                                        () {
                                                                      businessnumerror =
                                                                          true;
                                                                      businessnummessage =
                                                                          "required";
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      businessnumerror =
                                                                          false;
                                                                    });
                                                                  }
                                                                  if (street2
                                                                      .text
                                                                      .isEmpty) {
                                                                    setState(
                                                                        () {
                                                                      street2error =
                                                                          true;
                                                                      street2message =
                                                                          "required";
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      street2error =
                                                                          false;
                                                                    });
                                                                  }
                                                                  if (city2.text
                                                                      .isEmpty) {
                                                                    setState(
                                                                        () {
                                                                      city2error =
                                                                          true;
                                                                      city2message =
                                                                          "required";
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      city2error =
                                                                          false;
                                                                    });
                                                                  }
                                                                  if (state2
                                                                      .text
                                                                      .isEmpty) {
                                                                    setState(
                                                                        () {
                                                                      state2error =
                                                                          true;
                                                                      state2message =
                                                                          "required";
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      state2error =
                                                                          false;
                                                                    });
                                                                  }
                                                                  if (county2
                                                                      .text
                                                                      .isEmpty) {
                                                                    setState(
                                                                        () {
                                                                      county2error =
                                                                          true;
                                                                      county2message =
                                                                          "required";
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      county2error =
                                                                          false;
                                                                    });
                                                                  }
                                                                  if (code2.text
                                                                      .isEmpty) {
                                                                    setState(
                                                                        () {
                                                                      code2error =
                                                                          true;
                                                                      code2message =
                                                                          "required";
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      code2error =
                                                                          false;
                                                                    });
                                                                  }
                                                                  if (proid.text
                                                                      .isEmpty) {
                                                                    setState(
                                                                        () {
                                                                      proiderror =
                                                                          true;
                                                                      proidmessage =
                                                                          "required";
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      proiderror =
                                                                          false;
                                                                    });
                                                                  }

                                                                  if (!firstnameerror &&
                                                                      !lastnameerror &&
                                                                      !comnameerror &&
                                                                      !primaryemailerror &&
                                                                      !alternativeerror &&
                                                                      !phonenumerror &&
                                                                      !homenumerror &&
                                                                      !businessnumerror &&
                                                                      !street2error &&
                                                                      !city2error &&
                                                                      !state2error &&
                                                                      !countryerror &&
                                                                      !code2error &&
                                                                      !proiderror) {}
                                                                },
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5.0),
                                                                  child:
                                                                      Container(
                                                                    height:
                                                                        30.0,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        .3,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color:
                                                                              Colors.grey,
                                                                          offset: Offset(
                                                                              0.0,
                                                                              1.0), //(x,y)
                                                                          blurRadius:
                                                                              6.0,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child: isLoading
                                                                          ? SpinKitFadingCircle(
                                                                              color: Colors.white,
                                                                              size: 25.0,
                                                                            )
                                                                          : Text(
                                                                              "Add Property Type",
                                                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                                                                            ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.05),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              GestureDetector(
                                                                // onTap: () async {
                                                                //   if (selectedValue == null || subtype.text.isEmpty) {
                                                                //     setState(() {
                                                                //       iserror = true;
                                                                //     });
                                                                //   } else {
                                                                //     setState(() {
                                                                //       isLoading = true;
                                                                //       iserror = false;
                                                                //     });
                                                                //     SharedPreferences prefs =
                                                                //     await SharedPreferences.getInstance();
                                                                //
                                                                //     String? id = prefs.getString("adminId");
                                                                //     PropertyTypeRepository()
                                                                //         .addPropertyType(
                                                                //       adminId: id!,
                                                                //       propertyType: selectedValue,
                                                                //       propertySubType: subtype.text,
                                                                //       isMultiUnit: isChecked,
                                                                //     )
                                                                //         .then((value) {
                                                                //       setState(() {
                                                                //         isLoading = false;
                                                                //       });
                                                                //     }).catchError((e) {
                                                                //       setState(() {
                                                                //         isLoading = false;
                                                                //       });
                                                                //     });
                                                                //   }
                                                                //   print(selectedValue);
                                                                // },
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5.0),
                                                                  child:
                                                                      Container(
                                                                    height:
                                                                        30.0,
                                                                    width: 50,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              21,
                                                                              43,
                                                                              81,
                                                                              1),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color:
                                                                              Colors.grey,
                                                                          offset: Offset(
                                                                              0.0,
                                                                              1.0), //(x,y)
                                                                          blurRadius:
                                                                              6.0,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child: isLoading
                                                                          ? SpinKitFadingCircle(
                                                                              color: Colors.white,
                                                                              size: 25.0,
                                                                            )
                                                                          : Text(
                                                                              "Add",
                                                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                                                                            ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.03),
                                                              GestureDetector(
                                                                // onTap: () async {
                                                                //   if (selectedValue == null || subtype.text.isEmpty) {
                                                                //     setState(() {
                                                                //       iserror = true;
                                                                //     });
                                                                //   } else {
                                                                //     setState(() {
                                                                //       isLoading = true;
                                                                //       iserror = false;
                                                                //     });
                                                                //     SharedPreferences prefs =
                                                                //     await SharedPreferences.getInstance();
                                                                //
                                                                //     String? id = prefs.getString("adminId");
                                                                //     PropertyTypeRepository()
                                                                //         .addPropertyType(
                                                                //       adminId: id!,
                                                                //       propertyType: selectedValue,
                                                                //       propertySubType: subtype.text,
                                                                //       isMultiUnit: isChecked,
                                                                //     )
                                                                //         .then((value) {
                                                                //       setState(() {
                                                                //         isLoading = false;
                                                                //       });
                                                                //     }).catchError((e) {
                                                                //       setState(() {
                                                                //         isLoading = false;
                                                                //       });
                                                                //     });
                                                                //   }
                                                                //   print(selectedValue);
                                                                // },
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5.0),
                                                                  child:
                                                                      Container(
                                                                    height:
                                                                        30.0,
                                                                    width: 50,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
                                                                      color: Colors
                                                                          .white,
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color:
                                                                              Colors.grey,
                                                                          offset: Offset(
                                                                              0.0,
                                                                              1.0), //(x,y)
                                                                          blurRadius:
                                                                              6.0,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child: isLoading
                                                                          ? SpinKitFadingCircle(
                                                                              color: Colors.white,
                                                                              size: 25.0,
                                                                            )
                                                                          : Text(
                                                                              "Cancel",
                                                                              style: TextStyle(color: Color.fromRGBO(21, 43, 81, 1), fontWeight: FontWeight.bold, fontSize: 10),
                                                                            ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
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
                                  SizedBox(width: 15),
                                  Icon(Icons.add,
                                      size: 20, color: Colors.green[400]),
                                  SizedBox(width: 9),
                                  Text(
                                    "Add Rental Owner",
                                    style: TextStyle(
                                      color: Colors.green[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                  ),
                ),
                SizedBox(height: 25),
                Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  "Who will be primary manager of this Property ?",
                                  style: TextStyle(
                                      color: Color(0xFF8A95A8),
                                      //  fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Text(
                                    "If staff member has not yet been added as user in your account ,they can be added to the account"
                                    ",than as the manager later through the property's summary details.",
                                    style: TextStyle(
                                        color: Color(0xFF8A95A8),
                                        //  fontWeight: FontWeight.bold,
                                        fontSize: 10),
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
                                  width: 15,
                                ),
                                Text(
                                  "Manage (Optional)",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(21, 43, 81, 1),
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
                                  width: 15,
                                ),
                                DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    isExpanded: true,
                                    hint: const Row(
                                      children: [
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Select',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF8A95A8),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    items: items
                                        .map((String item) =>
                                            DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(
                                                item,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ))
                                        .toList(),
                                    value: selectedValue,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = value;
                                      });
                                    },
                                    buttonStyleData: ButtonStyleData(
                                      height: 30,
                                      width: 90,
                                      padding: const EdgeInsets.only(
                                          left: 14, right: 14),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(
                                          color: Colors.black26,
                                        ),
                                        color: Colors.white,
                                      ),
                                      elevation: 3,
                                    ),
                                    dropdownStyleData: DropdownStyleData(
                                      maxHeight: 200,
                                      width: 200,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        //color: Colors.redAccent,
                                      ),
                                      offset: const Offset(-20, 0),
                                      scrollbarTheme: ScrollbarThemeData(
                                        radius: const Radius.circular(40),
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
                                  ),
                                ),
                              ],
                            ),
                    // FutureBuilder<List<staff_member>>(
                    //   future: futureProperties,
                    //   builder: (context, snapshot) {
                    //     if (snapshot.connectionState == ConnectionState.waiting) {
                    //       return Center(child: CircularProgressIndicator());
                    //     } else if (snapshot.hasError) {
                    //       return Center(child: Text('Error: ${snapshot.error}'));
                    //     } else if (snapshot.hasData) {
                    //       List<staff_member> staffMembers = snapshot.data!;
                    //       List<dynamic> items = staffMembers.map((e) => e.sName).toList();
                    //       return Row(
                    //         children: [
                    //           SizedBox(
                    //             width: 15,
                    //           ),
                    //           DropdownButtonHideUnderline(
                    //             child: DropdownButton2<String>(
                    //               isExpanded: true,
                    //               hint: const Row(
                    //                 children: [
                    //                   SizedBox(
                    //                     width: 4,
                    //                   ),
                    //                   Expanded(
                    //                     child: Text(
                    //                       'Select',
                    //                       style: TextStyle(
                    //                         fontSize: 10,
                    //                         fontWeight: FontWeight.bold,
                    //                         color: Color(0xFF8A95A8),
                    //                       ),
                    //                       overflow: TextOverflow.ellipsis,
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //               items: items
                    //                   .map((dynamic item) => DropdownMenuItem<String>(
                    //                 value: item,
                    //                 child: Text(
                    //                   item,
                    //                   style: const TextStyle(
                    //                     fontSize: 14,
                    //                     fontWeight: FontWeight.bold,
                    //                     color: Colors.black,
                    //                   ),
                    //                   overflow: TextOverflow.ellipsis,
                    //                 ),
                    //               ))
                    //                   .toList(),
                    //               value: selectedValue,
                    //               onChanged: (value) {
                    //                 setState(() {
                    //                   selectedValue = value;
                    //                 });
                    //               },
                    //               buttonStyleData: ButtonStyleData(
                    //                 height: 30,
                    //                 width: 90,
                    //                 padding: const EdgeInsets.only(left: 14, right: 14),
                    //                 decoration: BoxDecoration(
                    //                   borderRadius: BorderRadius.circular(3),
                    //                   border: Border.all(
                    //                     color: Colors.black26,
                    //                   ),
                    //                   color: Colors.white,
                    //                 ),
                    //                 elevation: 3,
                    //               ),
                    //               dropdownStyleData: DropdownStyleData(
                    //                 maxHeight: 200,
                    //                 width: 200,
                    //                 decoration: BoxDecoration(
                    //                   borderRadius: BorderRadius.circular(14),
                    //                   //color: Colors.redAccent,
                    //                 ),
                    //                 offset: const Offset(-20, 0),
                    //                 scrollbarTheme: ScrollbarThemeData(
                    //                   radius: const Radius.circular(40),
                    //                   thickness: MaterialStateProperty.all(6),
                    //                   thumbVisibility: MaterialStateProperty.all(true),
                    //                 ),
                    //               ),
                    //               menuItemStyleData: const MenuItemStyleData(
                    //                 height: 40,
                    //                 padding: EdgeInsets.only(left: 14, right: 14),
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       );
                    //     } else {
                    //       return Center(child: Text('No staff members found'));
                    //     }
                    //   },
                    // ),
                          ],
                        )),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () async {
                    if (selectedValue == null) {
                      setState(() {
                        propertyTypeError = true;
                        propertyTypeErrorMessage = "required";
                      });
                    } else {
                      setState(() {
                        propertyTypeError = false;
                      });
                    }
                    if (address.text.isEmpty) {
                      setState(() {
                        addresserror = true;
                        addressmessage = "required";
                      });
                    } else {
                      setState(() {
                        addresserror = false;
                      });
                    }
                    if (city.text.isEmpty) {
                      setState(() {
                        cityerror = true;
                        citymessage = "required";
                      });
                    } else {
                      setState(() {
                        cityerror = false;
                      });
                    }
                    if (state.text.isEmpty) {
                      setState(() {
                        stateerror = true;
                        statemessage = "required";
                      });
                    } else {
                      setState(() {
                        stateerror = false;
                      });
                    }
                    if (country.text.isEmpty) {
                      setState(() {
                        countryerror = true;
                        countrymessage = "required";
                      });
                    } else {
                      setState(() {
                        countryerror = false;
                      });
                    }
                    if (postalcode.text.isEmpty) {
                      setState(() {
                        postalcodeerror = true;
                        postalcodemessage = "required";
                      });
                    } else {
                      setState(() {
                        postalcodeerror = false;
                      });
                    }
                    if (addresserror &&
                        cityerror &&
                        stateerror &&
                        countryerror &&
                        postalcodeerror) {}
                  },
                  child: Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Container(
                          height: 30,
                          width: MediaQuery.of(context).size.width * .3,
                          decoration: BoxDecoration(
                            // borderRadius: BorderRadius.circular(3),
                            color: Color.fromRGBO(21, 43, 81, 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, 1.0), //(x,y)
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "Create Property",
                              style: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text("Cancel"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RentalOwner {
  final String name;
  final String id;
  final List<String> processorIds;

  RentalOwner({
    required this.name,
    required this.id,
    required this.processorIds,
  });
}
