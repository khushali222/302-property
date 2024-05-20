import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  TextEditingController firstname = TextEditingController();
  TextEditingController lastname = TextEditingController();
  TextEditingController email = TextEditingController();

  bool firstnameerror = false;
  bool lastnameerror = false;
  bool emailerror = false;

  String firstnamemessage = "";
  String lastnamemessage = "";
  String emailmessage = "";
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
              buildDropdownListTile(context, FaIcon(
                FontAwesomeIcons.key,
                size: 20,
                color: Colors.black,
              ), "Rental",
                  ["Properties", "RentalOwner", "Tenants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(context, FaIcon(
                FontAwesomeIcons.thumbsUp,
                size: 20,
                color: Colors.black,
              ),
                  "Leasing", ["Rent Roll", "Applicants"],
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
                              Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(3),
                                child: Container(
                                  width: MediaQuery.of(context).size.width * .6,
                                  height: 30,
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(
                                      color: Color(0xFF8A95A8),
                                    ),
                                  ),
                                  child: Center(
                                    child: TextFormField(
                                      controller: address,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(12),
                                        border: InputBorder.none,
                                        hintText: "Enter address here",
                                        hintStyle: TextStyle(
                                            color: Color(0xFF8A95A8),
                                            fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ),
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
                                width: MediaQuery.of(context).size.width * .23,
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
                              Row(
                                children: [
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Material(
                                    elevation: 2,
                                    borderRadius: BorderRadius.circular(3),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          .29,
                                      height: 30,
                                      padding: EdgeInsets.only(left: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(
                                          color: Color(0xFF8A95A8),
                                        ),
                                      ),
                                      child: Center(
                                        child: TextFormField(
                                          controller: city,
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(12),
                                            border: InputBorder.none,
                                            hintText: "Enter CIty here",
                                            hintStyle: TextStyle(
                                                color: Color(0xFF8A95A8),
                                                fontSize: 10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Row(
                                children: [
                                  Material(
                                    elevation: 2,
                                    borderRadius: BorderRadius.circular(3),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          .29,
                                      height: 30,
                                      padding: EdgeInsets.only(left: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(
                                          color: Color(0xFF8A95A8),
                                        ),
                                      ),
                                      child: Center(
                                        child: TextFormField(
                                          controller: state,
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(12),
                                            border: InputBorder.none,
                                            hintText: "Enter State here",
                                            hintStyle: TextStyle(
                                                color: Color(0xFF8A95A8),
                                                fontSize: 10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              addresserror
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                width: 45,
                              ),
                              addresserror
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                width: MediaQuery.of(context).size.width * .21,
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
                              Row(
                                children: [
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Material(
                                    elevation: 3,
                                    borderRadius: BorderRadius.circular(3),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          .30,
                                      height: 30,
                                      padding: EdgeInsets.only(left: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(
                                          color: Color(0xFF8A95A8),
                                        ),
                                      ),
                                      child: Center(
                                        child: TextFormField(
                                          controller: country,
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(12),
                                            border: InputBorder.none,
                                            hintText: "Enter Country here",
                                            hintStyle: TextStyle(
                                                color: Color(0xFF8A95A8),
                                                fontSize: 10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Row(
                                children: [
                                  Material(
                                    elevation: 3,
                                    borderRadius: BorderRadius.circular(3),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          .33,
                                      height: 30,
                                      padding: EdgeInsets.only(left: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(
                                          color: Color(0xFF8A95A8),
                                        ),
                                      ),
                                      child: Center(
                                        child: TextFormField(
                                          controller: postalcode,
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(12),
                                            border: InputBorder.none,
                                            hintText: "Enter Postal Code here",
                                            hintStyle: TextStyle(
                                                color: Color(0xFF8A95A8),
                                                fontSize: 10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              addresserror
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                width: 45,
                              ),
                              addresserror
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                            // GestureDetector(
                            //   onTap: () {
                            //     showDialog(
                            //       context: context,
                            //       builder: (BuildContext context) {
                            //         return StatefulBuilder(builder:
                            //             (BuildContext context,
                            //                 StateSetter setState) {
                            //           return Padding(
                            //             padding: const EdgeInsets.only(
                            //                 top: 90,
                            //                 bottom: 90,
                            //                 left: 30,
                            //                 right: 30),
                            //             child: Material(
                            //               type: MaterialType.transparency,
                            //               child: Container(
                            //                 decoration: BoxDecoration(
                            //                   color: Colors.white,
                            //                   borderRadius:
                            //                       BorderRadius.circular(20),
                            //                 ),
                            //                 child: Padding(
                            //                   padding: const EdgeInsets.only(
                            //                       left: 20,
                            //                       right: 20,
                            //                       top: 20,
                            //                       bottom: 20),
                            //                   child: Column(
                            //                     children: [
                            //                       Row(
                            //                         children: [
                            //                           Text("Add rental owner",
                            //                               style: TextStyle(
                            //                                 color:
                            //                                     Color.fromRGBO(
                            //                                         21,
                            //                                         43,
                            //                                         81,
                            //                                         1),
                            //                                 fontWeight:
                            //                                     FontWeight.bold,
                            //                                 fontSize: 17,
                            //                               )),
                            //                         ],
                            //                       ),
                            //                       SizedBox(
                            //                         height: 12,
                            //                       ),
                            //                       Row(
                            //                         children: [
                            //                           SizedBox(
                            //                             width: 5,
                            //                           ),
                            //                           Checkbox(
                            //                             value: isChecked,
                            //                             onChanged: (value) {
                            //                               setState(() {
                            //                                 isChecked =
                            //                                     value ?? false;
                            //                               });
                            //                             },
                            //                             activeColor: isChecked
                            //                                 ? Colors.blue
                            //                                 : Colors.black,
                            //                           ),
                            //                         ],
                            //                       ),
                            //                       SizedBox(
                            //                           height:
                            //                               MediaQuery.of(context)
                            //                                       .size
                            //                                       .height *
                            //                                   0.02),
                            //                       isChecked // Check the value of isChecked
                            //                           ? Column(
                            //                               children: [
                            //                                 TextFormField(
                            //                                   decoration:
                            //                                       InputDecoration(
                            //                                     labelText:
                            //                                         "Additional Field 1",
                            //                                   ),
                            //                                 ),
                            //                                 TextFormField(
                            //                                   decoration:
                            //                                       InputDecoration(
                            //                                     labelText:
                            //                                         "Additional Field 2",
                            //                                   ),
                            //                                 ),
                            //                               ],
                            //                             )
                            //                           : Column(
                            //                               children: [
                            //                                 Row(
                            //                                   children: [
                            //                                     Text(
                            //                                       "Name*",
                            //                                       style: TextStyle(
                            //                                           fontWeight:
                            //                                               FontWeight
                            //                                                   .bold,
                            //                                           color: Color(
                            //                                               0xFF8A95A8),
                            //                                           fontSize:
                            //                                               14),
                            //                                     ),
                            //                                   ],
                            //                                 ),
                            //                                 SizedBox(
                            //                                   height: 5,
                            //                                 ),
                            //                                 Row(
                            //                                   children: [
                            //                                     Expanded(
                            //                                       child:
                            //                                           Material(
                            //                                         elevation:
                            //                                             3,
                            //                                         borderRadius:
                            //                                             BorderRadius
                            //                                                 .circular(5),
                            //                                         child:
                            //                                             Container(
                            //                                           height:
                            //                                               35,
                            //                                           decoration: BoxDecoration(
                            //                                               borderRadius: BorderRadius.circular(5),
                            //                                               // color: Color.fromRGBO(196, 196, 196, .3),
                            //                                               border: Border.all(color: Color(0xFF8A95A8))),
                            //                                           child:
                            //                                               Stack(
                            //                                             children: [
                            //                                               Positioned
                            //                                                   .fill(
                            //                                                 child:
                            //                                                     TextField(
                            //                                                   onChanged: (value) {
                            //                                                     setState(() {
                            //                                                       firstnameerror = false;
                            //                                                     });
                            //                                                   },
                            //                                                   controller: firstname,
                            //                                                   cursorColor: Color.fromRGBO(21, 43, 81, 1),
                            //                                                   decoration: InputDecoration(
                            //                                                     enabledBorder: firstnameerror
                            //                                                         ? OutlineInputBorder(
                            //                                                             borderRadius: BorderRadius.circular(10),
                            //                                                             borderSide: BorderSide(color: Colors.red), // Set border color here
                            //                                                           )
                            //                                                         : InputBorder.none,
                            //                                                     border: InputBorder.none,
                            //                                                     contentPadding: EdgeInsets.all(12),
                            //                                                     hintText: " Enter first name here...",
                            //                                                     hintStyle: TextStyle(
                            //                                                       color: Color(0xFF8A95A8),
                            //                                                       fontSize: 14,
                            //                                                       fontWeight: FontWeight.w400,
                            //                                                     ),
                            //                                                   ),
                            //                                                 ),
                            //                                               ),
                            //                                             ],
                            //                                           ),
                            //                                         ),
                            //                                       ),
                            //                                     ),
                            //                                     SizedBox(
                            //                                       width: MediaQuery.of(
                            //                                                   context)
                            //                                               .size
                            //                                               .width *
                            //                                           .099,
                            //                                     ),
                            //                                   ],
                            //                                 ),
                            //                                 firstnameerror
                            //                                     ? Center(
                            //                                         child: Text(
                            //                                         firstnamemessage,
                            //                                         style: TextStyle(
                            //                                             color: Colors
                            //                                                 .red),
                            //                                       ))
                            //                                     : Container(),
                            //                                 SizedBox(
                            //                                     height: MediaQuery.of(
                            //                                                 context)
                            //                                             .size
                            //                                             .height *
                            //                                         0.02),
                            //                                 Row(
                            //                                   children: [
                            //                                     Expanded(
                            //                                       child:
                            //                                           Material(
                            //                                         elevation:
                            //                                             3,
                            //                                         borderRadius:
                            //                                             BorderRadius
                            //                                                 .circular(5),
                            //                                         child:
                            //                                             Container(
                            //                                           height:
                            //                                               35,
                            //                                           decoration: BoxDecoration(
                            //                                               borderRadius: BorderRadius.circular(5),
                            //                                               // color: Color.fromRGBO(196, 196, 196, .3),
                            //                                               border: Border.all(color: Color(0xFF8A95A8))),
                            //                                           child:
                            //                                               Stack(
                            //                                             children: [
                            //                                               Positioned
                            //                                                   .fill(
                            //                                                 child:
                            //                                                     TextField(
                            //                                                   onChanged: (value) {
                            //                                                     setState(() {
                            //                                                       lastnameerror = false;
                            //                                                     });
                            //                                                   },
                            //                                                   controller: lastname,
                            //                                                   cursorColor: Color.fromRGBO(21, 43, 81, 1),
                            //                                                   decoration: InputDecoration(
                            //                                                     enabledBorder: lastnameerror
                            //                                                         ? OutlineInputBorder(
                            //                                                             borderRadius: BorderRadius.circular(10),
                            //                                                             borderSide: BorderSide(color: Colors.red), // Set border color here
                            //                                                           )
                            //                                                         : InputBorder.none,
                            //                                                     border: InputBorder.none,
                            //                                                     contentPadding: EdgeInsets.all(12),
                            //                                                     hintText: " Enter last name here...",
                            //                                                     hintStyle: TextStyle(
                            //                                                       color: Color(0xFF8A95A8),
                            //                                                       fontSize: 14,
                            //                                                       fontWeight: FontWeight.w400,
                            //                                                     ),
                            //                                                   ),
                            //                                                 ),
                            //                                               ),
                            //                                             ],
                            //                                           ),
                            //                                         ),
                            //                                       ),
                            //                                     ),
                            //                                     SizedBox(
                            //                                       width: MediaQuery.of(
                            //                                                   context)
                            //                                               .size
                            //                                               .width *
                            //                                           .099,
                            //                                     ),
                            //                                   ],
                            //                                 ),
                            //                                 lastnameerror
                            //                                     ? Center(
                            //                                         child: Text(
                            //                                         lastnamemessage,
                            //                                         style: TextStyle(
                            //                                             color: Colors
                            //                                                 .red),
                            //                                       ))
                            //                                     : Container(),
                            //                                 SizedBox(
                            //                                     height: MediaQuery.of(
                            //                                                 context)
                            //                                             .size
                            //                                             .height *
                            //                                         0.02),
                            //                                 Row(
                            //                                   children: [
                            //                                     Text(
                            //                                       "Company Name*",
                            //                                       style: TextStyle(
                            //                                           fontWeight:
                            //                                               FontWeight
                            //                                                   .bold,
                            //                                           color: Color(
                            //                                               0xFF8A95A8),
                            //                                           fontSize:
                            //                                               14),
                            //                                     ),
                            //                                   ],
                            //                                 ),
                            //                                 SizedBox(
                            //                                   height: 5,
                            //                                 ),
                            //                                 Row(
                            //                                   children: [
                            //                                     Expanded(
                            //                                       child:
                            //                                           Material(
                            //                                         elevation:
                            //                                             3,
                            //                                         borderRadius:
                            //                                             BorderRadius
                            //                                                 .circular(5),
                            //                                         child:
                            //                                             Container(
                            //                                           height:
                            //                                               35,
                            //                                           decoration: BoxDecoration(
                            //                                               borderRadius: BorderRadius.circular(5),
                            //                                               // color: Color.fromRGBO(196, 196, 196, .3),
                            //                                               border: Border.all(color: Color(0xFF8A95A8))),
                            //                                           child:
                            //                                               Stack(
                            //                                             children: [
                            //                                               Positioned
                            //                                                   .fill(
                            //                                                 child:
                            //                                                     TextField(
                            //                                                   onChanged: (value) {
                            //                                                     setState(() {
                            //                                                       firstnameerror = false;
                            //                                                     });
                            //                                                   },
                            //                                                   controller: firstname,
                            //                                                   cursorColor: Color.fromRGBO(21, 43, 81, 1),
                            //                                                   decoration: InputDecoration(
                            //                                                     enabledBorder: firstnameerror
                            //                                                         ? OutlineInputBorder(
                            //                                                             borderRadius: BorderRadius.circular(10),
                            //                                                             borderSide: BorderSide(color: Colors.red), // Set border color here
                            //                                                           )
                            //                                                         : InputBorder.none,
                            //                                                     border: InputBorder.none,
                            //                                                     contentPadding: EdgeInsets.all(12),
                            //                                                     hintText: " Enter company name here...",
                            //                                                     hintStyle: TextStyle(
                            //                                                       color: Color(0xFF8A95A8),
                            //                                                       fontSize: 14,
                            //                                                       fontWeight: FontWeight.w400,
                            //                                                     ),
                            //                                                   ),
                            //                                                 ),
                            //                                               ),
                            //                                             ],
                            //                                           ),
                            //                                         ),
                            //                                       ),
                            //                                     ),
                            //                                     SizedBox(
                            //                                       width: MediaQuery.of(
                            //                                                   context)
                            //                                               .size
                            //                                               .width *
                            //                                           .099,
                            //                                     ),
                            //                                   ],
                            //                                 ),
                            //                                 firstnameerror
                            //                                     ? Center(
                            //                                         child: Text(
                            //                                         firstnamemessage,
                            //                                         style: TextStyle(
                            //                                             color: Colors
                            //                                                 .red),
                            //                                       ))
                            //                                     : Container(),
                            //                                 SizedBox(
                            //                                     height: MediaQuery.of(
                            //                                                 context)
                            //                                             .size
                            //                                             .height *
                            //                                         0.02),
                            //                               ],
                            //                             ),
                            //
                            //                       //   Row(
                            //                       //     children: [
                            //                       //       Text(
                            //                       //         "Name*",
                            //                       //         style: TextStyle(
                            //                       //             fontWeight: FontWeight.bold,
                            //                       //             color: Color(0xFF8A95A8),
                            //                       //             fontSize: 14),
                            //                       //       ),
                            //                       //     ],
                            //                       //   ),
                            //                       // SizedBox(
                            //                       //   height: 5,
                            //                       // ),
                            //                       //   Row(
                            //                       //     children: [
                            //                       //       Expanded(
                            //                       //         child: Material(
                            //                       //           elevation:3,
                            //                       //           borderRadius: BorderRadius.circular(5),
                            //                       //           child: Container(
                            //                       //             height: 35,
                            //                       //             decoration: BoxDecoration(
                            //                       //               borderRadius: BorderRadius.circular(5),
                            //                       //              // color: Color.fromRGBO(196, 196, 196, .3),
                            //                       //               border: Border.all(color: Color(0xFF8A95A8))
                            //                       //             ),
                            //                       //             child: Stack(
                            //                       //               children: [
                            //                       //                 Positioned.fill(
                            //                       //                   child: TextField(
                            //                       //                     onChanged: (value) {
                            //                       //                       setState(() {
                            //                       //                         firstnameerror = false;
                            //                       //                       });
                            //                       //                     },
                            //                       //                     controller: firstname,
                            //                       //                     cursorColor: Color.fromRGBO(21, 43, 81, 1),
                            //                       //                     decoration: InputDecoration(
                            //                       //                       enabledBorder: firstnameerror
                            //                       //                           ? OutlineInputBorder(
                            //                       //                         borderRadius: BorderRadius.circular(10),
                            //                       //                         borderSide: BorderSide(
                            //                       //                             color: Colors
                            //                       //                                 .red), // Set border color here
                            //                       //                       )
                            //                       //                           : InputBorder.none,
                            //                       //                       border: InputBorder.none,
                            //                       //                       contentPadding: EdgeInsets.all(12),
                            //                       //                       hintText: " Enter first name here...",
                            //                       //                       hintStyle: TextStyle(
                            //                       //                         color: Color(0xFF8A95A8),
                            //                       //                         fontSize: 14,
                            //                       //                         fontWeight: FontWeight.w400,
                            //                       //                       ),
                            //                       //                     ),
                            //                       //                   ),
                            //                       //                 ),
                            //                       //               ],
                            //                       //             ),
                            //                       //           ),
                            //                       //         ),
                            //                       //       ),
                            //                       //       SizedBox(
                            //                       //         width: MediaQuery.of(context).size.width * .099,
                            //                       //       ),
                            //                       //     ],
                            //                       //   ),
                            //                       //   firstnameerror
                            //                       //       ? Center(
                            //                       //       child: Text(
                            //                       //         firstnamemessage,
                            //                       //         style: TextStyle(color: Colors.red),
                            //                       //       ))
                            //                       //       : Container(),
                            //                       //   SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                            //                       //   Row(
                            //                       //     children: [
                            //                       //       Expanded(
                            //                       //         child: Material(
                            //                       //           elevation:3,
                            //                       //           borderRadius: BorderRadius.circular(5),
                            //                       //           child: Container(
                            //                       //             height: 35,
                            //                       //             decoration: BoxDecoration(
                            //                       //                 borderRadius: BorderRadius.circular(5),
                            //                       //                 // color: Color.fromRGBO(196, 196, 196, .3),
                            //                       //                 border: Border.all(color: Color(0xFF8A95A8))
                            //                       //             ),
                            //                       //             child: Stack(
                            //                       //               children: [
                            //                       //                 Positioned.fill(
                            //                       //                   child: TextField(
                            //                       //                     onChanged: (value) {
                            //                       //                       setState(() {
                            //                       //                         lastnameerror = false;
                            //                       //                       });
                            //                       //                     },
                            //                       //                     controller: lastname,
                            //                       //                     cursorColor: Color.fromRGBO(21, 43, 81, 1),
                            //                       //                     decoration: InputDecoration(
                            //                       //                       enabledBorder: lastnameerror
                            //                       //                           ? OutlineInputBorder(
                            //                       //                         borderRadius: BorderRadius.circular(10),
                            //                       //                         borderSide: BorderSide(
                            //                       //                             color: Colors
                            //                       //                                 .red), // Set border color here
                            //                       //                       )
                            //                       //                           : InputBorder.none,
                            //                       //                       border: InputBorder.none,
                            //                       //                       contentPadding: EdgeInsets.all(12),
                            //                       //                       hintText: " Enter last name here...",
                            //                       //                       hintStyle: TextStyle(
                            //                       //                         color: Color(0xFF8A95A8),
                            //                       //                         fontSize: 14,
                            //                       //                         fontWeight: FontWeight.w400,
                            //                       //                       ),
                            //                       //                     ),
                            //                       //                   ),
                            //                       //                 ),
                            //                       //               ],
                            //                       //             ),
                            //                       //           ),
                            //                       //         ),
                            //                       //       ),
                            //                       //       SizedBox(
                            //                       //         width: MediaQuery.of(context).size.width * .099,
                            //                       //       ),
                            //                       //     ],
                            //                       //   ),
                            //                       //   lastnameerror
                            //                       //       ? Center(
                            //                       //       child: Text(
                            //                       //         lastnamemessage,
                            //                       //         style: TextStyle(color: Colors.red),
                            //                       //       ))
                            //                       //       : Container(),
                            //                       //   SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                            //                       //   Row(
                            //                       //     children: [
                            //                       //       Text(
                            //                       //         "Company Name*",
                            //                       //         style: TextStyle(
                            //                       //             fontWeight: FontWeight.bold,
                            //                       //             color: Color(0xFF8A95A8),
                            //                       //             fontSize: 14),
                            //                       //       ),
                            //                       //     ],
                            //                       //   ),
                            //                       //   SizedBox(
                            //                       //     height: 5,
                            //                       //   ),
                            //                       //   Row(
                            //                       //     children: [
                            //                       //       Expanded(
                            //                       //         child: Material(
                            //                       //           elevation:3,
                            //                       //           borderRadius: BorderRadius.circular(5),
                            //                       //           child: Container(
                            //                       //             height: 35,
                            //                       //             decoration: BoxDecoration(
                            //                       //                 borderRadius: BorderRadius.circular(5),
                            //                       //                 // color: Color.fromRGBO(196, 196, 196, .3),
                            //                       //                 border: Border.all(color: Color(0xFF8A95A8))
                            //                       //             ),
                            //                       //             child: Stack(
                            //                       //               children: [
                            //                       //                 Positioned.fill(
                            //                       //                   child: TextField(
                            //                       //                     onChanged: (value) {
                            //                       //                       setState(() {
                            //                       //                         firstnameerror = false;
                            //                       //                       });
                            //                       //                     },
                            //                       //                     controller: firstname,
                            //                       //                     cursorColor: Color.fromRGBO(21, 43, 81, 1),
                            //                       //                     decoration: InputDecoration(
                            //                       //                       enabledBorder: firstnameerror
                            //                       //                           ? OutlineInputBorder(
                            //                       //                         borderRadius: BorderRadius.circular(10),
                            //                       //                         borderSide: BorderSide(
                            //                       //                             color: Colors
                            //                       //                                 .red), // Set border color here
                            //                       //                       )
                            //                       //                           : InputBorder.none,
                            //                       //                       border: InputBorder.none,
                            //                       //                       contentPadding: EdgeInsets.all(12),
                            //                       //                       hintText: " Enter company name here...",
                            //                       //                       hintStyle: TextStyle(
                            //                       //                         color: Color(0xFF8A95A8),
                            //                       //                         fontSize: 14,
                            //                       //                         fontWeight: FontWeight.w400,
                            //                       //                       ),
                            //                       //                     ),
                            //                       //                   ),
                            //                       //                 ),
                            //                       //               ],
                            //                       //             ),
                            //                       //           ),
                            //                       //         ),
                            //                       //       ),
                            //                       //       SizedBox(
                            //                       //         width: MediaQuery.of(context).size.width * .099,
                            //                       //       ),
                            //                       //     ],
                            //                       //   ),
                            //                       //   firstnameerror
                            //                       //       ? Center(
                            //                       //       child: Text(
                            //                       //         firstnamemessage,
                            //                       //         style: TextStyle(color: Colors.red),
                            //                       //       ))
                            //                       //       : Container(),
                            //                       //   SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                            //                     ],
                            //                   ),
                            //                 ),
                            //               ),
                            //             ),
                            //           );
                            //         });
                            //       },
                            //     );
                            //   },
                            //   child: Row(
                            //     children: [
                            //       SizedBox(
                            //         width: 15,
                            //       ),
                            //       Icon(
                            //         Icons.add,
                            //         size: 10,
                            //         color: Colors.green[400],
                            //       ),
                            //       SizedBox(
                            //         width: 9,
                            //       ),
                            //       Text(
                            //         "Add Rental Owner",
                            //         style: TextStyle(
                            //             //  color: Color(0xFF8A95A8),
                            //             color: Colors.green[400],
                            //             //  fontWeight: FontWeight.bold,
                            //             fontSize: 10),
                            //       ),
                            //     ],
                            //   ),
                            // ),
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
                                          title: Text("Add Rental Owner",style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromRGBO(21, 43, 81, 1) ,
                                              fontSize: 15),),
                                          content: SingleChildScrollView(
                                            child:
                                            Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    // SizedBox(width: 5,),
                                                    SizedBox(
                                                      width: 24.0, // Standard width for checkbox
                                                      height: 24.0,
                                                      child: Checkbox(
                                                        value: isChecked,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            isChecked =
                                                                value ?? false;
                                                          });
                                                        },
                                                        activeColor: isChecked ?  Color.fromRGBO(21, 43, 81, 1) : Colors.black,
                                                      ),
                                                    ),
                                                    SizedBox(width: 5,),
                                                     Expanded(
                                                       child: Text(
                                                         "choose an existing rental owner",
                                                         style: TextStyle(
                                                             fontWeight: FontWeight.bold,
                                                            color: Color(0xFF8A95A8),
                                                             fontSize: 12),
                                                       ),
                                                     ),
                                                  ],
                                                ),
                                                isChecked
                                                    ? Column(
                                                        children: [
                                                          SizedBox(height: 25,),
                                                          TextFormField(
                                                            decoration:
                                                                InputDecoration(
                                                              labelText:
                                                                  "Additional Field 1",
                                                            ),
                                                          ),
                                                          TextFormField(
                                                            decoration:
                                                                InputDecoration(
                                                              labelText:
                                                                  "Additional Field 2",
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    :
                                                Column(
                                                  children: [
                                                    SizedBox(height: 25,),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Name*",
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: Color(0xFF8A95A8),
                                                              fontSize: 14),
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
                                                            elevation:3,
                                                            borderRadius: BorderRadius.circular(5),
                                                            child: Container(
                                                              height: 35,
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  // color: Color.fromRGBO(196, 196, 196, .3),
                                                                  border: Border.all(color: Color(0xFF8A95A8))
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  Positioned.fill(
                                                                    child: TextField(
                                                                      onChanged: (value) {
                                                                        setState(() {
                                                                          firstnameerror = false;
                                                                        });
                                                                      },
                                                                      controller: firstname,
                                                                      cursorColor: Color.fromRGBO(21, 43, 81, 1),
                                                                      decoration: InputDecoration(
                                                                        enabledBorder: firstnameerror
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(10),
                                                                          borderSide: BorderSide(
                                                                              color: Colors
                                                                                  .red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        border: InputBorder.none,
                                                                        contentPadding: EdgeInsets.all(12),
                                                                        hintText: " Enter first name here...",
                                                                        hintStyle: TextStyle(
                                                                          color: Color(0xFF8A95A8),
                                                                          fontSize: 14,
                                                                          fontWeight: FontWeight.w400,
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
                                                          style: TextStyle(color: Colors.red),
                                                        ))
                                                        : Container(),
                                                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                                    //lastname
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Material(
                                                            elevation:3,
                                                            borderRadius: BorderRadius.circular(5),
                                                            child: Container(
                                                              height: 35,
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  // color: Color.fromRGBO(196, 196, 196, .3),
                                                                  border: Border.all(color: Color(0xFF8A95A8))
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  Positioned.fill(
                                                                    child: TextField(
                                                                      onChanged: (value) {
                                                                        setState(() {
                                                                          lastnameerror = false;
                                                                        });
                                                                      },
                                                                      controller: lastname,
                                                                      cursorColor: Color.fromRGBO(21, 43, 81, 1),
                                                                      decoration: InputDecoration(
                                                                        enabledBorder: lastnameerror
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(10),
                                                                          borderSide: BorderSide(
                                                                              color: Colors
                                                                                  .red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        border: InputBorder.none,
                                                                        contentPadding: EdgeInsets.all(12),
                                                                        hintText: " Enter last name here...",
                                                                        hintStyle: TextStyle(
                                                                          color: Color(0xFF8A95A8),
                                                                          fontSize: 14,
                                                                          fontWeight: FontWeight.w400,
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
                                                          style: TextStyle(color: Colors.red),
                                                        ))
                                                        : Container(),
                                                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                                    //company name
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Company Name*",
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: Color(0xFF8A95A8),
                                                              fontSize: 14),
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
                                                            elevation:3,
                                                            borderRadius: BorderRadius.circular(5),
                                                            child: Container(
                                                              height: 35,
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  // color: Color.fromRGBO(196, 196, 196, .3),
                                                                  border: Border.all(color: Color(0xFF8A95A8))
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  Positioned.fill(
                                                                    child: TextField(
                                                                      onChanged: (value) {
                                                                        setState(() {
                                                                          firstnameerror = false;
                                                                        });
                                                                      },
                                                                      controller: firstname,
                                                                      cursorColor: Color.fromRGBO(21, 43, 81, 1),
                                                                      decoration: InputDecoration(
                                                                        enabledBorder: firstnameerror
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(10),
                                                                          borderSide: BorderSide(
                                                                              color: Colors
                                                                                  .red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        border: InputBorder.none,
                                                                        contentPadding: EdgeInsets.all(10),
                                                                        hintText: " Enter company name here...",
                                                                        hintStyle: TextStyle(
                                                                          color: Color(0xFF8A95A8),
                                                                          fontSize: 14,
                                                                          fontWeight: FontWeight.w400,
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
                                                          style: TextStyle(color: Colors.red),
                                                        ))
                                                        : Container(),
                                                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                                    //primary email
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Primary Email*",
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: Color(0xFF8A95A8),
                                                              fontSize: 14),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                            height: 40,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(10),
                                                              color: Colors.white,
                                                            ),
                                                            child: Stack(
                                                              children: [
                                                                Positioned.fill(
                                                                  child: TextField(
                                                                    onChanged: (value) {
                                                                      setState(() {
                                                                        emailerror = false;
                                                                      });
                                                                    },
                                                                    controller: email,
                                                                    keyboardType: TextInputType.emailAddress,
                                                                    cursorColor: Color.fromRGBO(21, 43, 81, 1),
                                                                    decoration: InputDecoration(
                                                                      border: InputBorder.none,
                                                                      enabledBorder: emailerror
                                                                          ? OutlineInputBorder(
                                                                        borderRadius: BorderRadius.circular(10),
                                                                        borderSide: BorderSide(
                                                                            color: Colors
                                                                                .red), // Set border color here
                                                                      )
                                                                          : InputBorder.none,
                                                                      contentPadding: EdgeInsets.all(1),
                                                                      prefixIcon: Container(
                                                                          height: 20,
                                                                          width: 20,
                                                                          padding: EdgeInsets.all(13),
                                                                          child: Image.asset(
                                                                              "assets/icons/email_icon.png")),
                                                                      hintText: "Primaery Email",
                                                                      hintStyle: TextStyle(
                                                                        color: Color(0xFF8A95A8),
                                                                          fontSize: 14,
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
                                                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                                    //Alternative Email
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Alternative Email*",
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: Color(0xFF8A95A8),
                                                              fontSize: 14),
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
                                                            elevation:3,
                                                            borderRadius: BorderRadius.circular(5),
                                                            child: Container(
                                                              height: 35,
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  // color: Color.fromRGBO(196, 196, 196, .3),
                                                                  border: Border.all(color: Color(0xFF8A95A8))
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  Positioned.fill(
                                                                    child: TextField(
                                                                      onChanged: (value) {
                                                                        setState(() {
                                                                          firstnameerror = false;
                                                                        });
                                                                      },
                                                                      controller: firstname,
                                                                      cursorColor: Color.fromRGBO(21, 43, 81, 1),
                                                                      decoration: InputDecoration(
                                                                        enabledBorder: firstnameerror
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(10),
                                                                          borderSide: BorderSide(
                                                                              color: Colors
                                                                                  .red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        border: InputBorder.none,
                                                                        contentPadding: EdgeInsets.all(12),
                                                                        hintText: " Enter alternative email here...",
                                                                        hintStyle: TextStyle(
                                                                          color: Color(0xFF8A95A8),
                                                                          fontSize: 14,
                                                                          fontWeight: FontWeight.w400,
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
                                                          style: TextStyle(color: Colors.red),
                                                        ))
                                                        : Container(),
                                                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                                    //Phone Numbers
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Phone Numbers*",
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: Color(0xFF8A95A8),
                                                              fontSize: 14),
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
                                                            elevation:3,
                                                            borderRadius: BorderRadius.circular(5),
                                                            child: Container(
                                                              height: 35,
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  // color: Color.fromRGBO(196, 196, 196, .3),
                                                                  border: Border.all(color: Color(0xFF8A95A8))
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  Positioned.fill(
                                                                    child: TextField(
                                                                      onChanged: (value) {
                                                                        setState(() {
                                                                          firstnameerror = false;
                                                                        });
                                                                      },
                                                                      controller: firstname,
                                                                      cursorColor: Color.fromRGBO(21, 43, 81, 1),
                                                                      decoration: InputDecoration(
                                                                        enabledBorder: firstnameerror
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(10),
                                                                          borderSide: BorderSide(
                                                                              color: Colors
                                                                                  .red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        border: InputBorder.none,
                                                                        contentPadding: EdgeInsets.all(12),
                                                                        hintText: " Enter phone number here...",
                                                                        prefixIcon: Padding(
                                                                          padding: const EdgeInsets.only(top: 6,left: 8),
                                                                          child: FaIcon(
                                                                            FontAwesomeIcons.phone,
                                                                            color: Colors.grey,
                                                                            size: 15,
                                                                          ),
                                                                        ),
                                                                        hintStyle: TextStyle(
                                                                          color: Color(0xFF8A95A8),
                                                                          fontSize: 14,
                                                                          fontWeight: FontWeight.w400,
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
                                                          style: TextStyle(color: Colors.red),
                                                        ))
                                                        : Container(),
                                                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                                                    //homenumber
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Material(
                                                            elevation:3,
                                                            borderRadius: BorderRadius.circular(5),
                                                            child: Container(
                                                              height: 35,
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  // color: Color.fromRGBO(196, 196, 196, .3),
                                                                  border: Border.all(color: Color(0xFF8A95A8))
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  Positioned.fill(
                                                                    child: TextField(
                                                                      onChanged: (value) {
                                                                        setState(() {
                                                                          firstnameerror = false;
                                                                        });
                                                                      },
                                                                      controller: firstname,
                                                                      cursorColor: Color.fromRGBO(21, 43, 81, 1),
                                                                      decoration: InputDecoration(
                                                                        enabledBorder: firstnameerror
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(10),
                                                                          borderSide: BorderSide(
                                                                              color: Colors
                                                                                  .red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        border: InputBorder.none,
                                                                        contentPadding: EdgeInsets.all(12),
                                                                        hintText: " Enter home number here...",
                                                                        hintStyle: TextStyle(
                                                                          color: Color(0xFF8A95A8),
                                                                          fontSize: 14,
                                                                          fontWeight: FontWeight.w400,
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
                                                          style: TextStyle(color: Colors.red),
                                                        ))
                                                        : Container(),
                                                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Material(
                                                            elevation:3,
                                                            borderRadius: BorderRadius.circular(5),
                                                            child: Container(
                                                              height: 35,
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  // color: Color.fromRGBO(196, 196, 196, .3),
                                                                  border: Border.all(color: Color(0xFF8A95A8))
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  Positioned.fill(
                                                                    child: TextField(
                                                                      onChanged: (value) {
                                                                        setState(() {
                                                                          firstnameerror = false;
                                                                        });
                                                                      },
                                                                      controller: firstname,
                                                                      cursorColor: Color.fromRGBO(21, 43, 81, 1),
                                                                      decoration: InputDecoration(
                                                                        enabledBorder: firstnameerror
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(10),
                                                                          borderSide: BorderSide(
                                                                              color: Colors
                                                                                  .red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        border: InputBorder.none,
                                                                        contentPadding: EdgeInsets.all(12),
                                                                        hintText: " Enter business number here...",
                                                                        hintStyle: TextStyle(
                                                                          color: Color(0xFF8A95A8),
                                                                          fontSize: 14,
                                                                          fontWeight: FontWeight.w400,
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
                                                          style: TextStyle(color: Colors.red),
                                                        ))
                                                        : Container(),
                                                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                                    //Address information
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Address information*",
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: Color(0xFF8A95A8),
                                                              fontSize: 14),
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
                                                            elevation:3,
                                                            borderRadius: BorderRadius.circular(5),
                                                            child: Container(
                                                              height: 35,
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  // color: Color.fromRGBO(196, 196, 196, .3),
                                                                  border: Border.all(color: Color(0xFF8A95A8))
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  Positioned.fill(
                                                                    child: TextField(
                                                                      onChanged: (value) {
                                                                        setState(() {
                                                                          firstnameerror = false;
                                                                        });
                                                                      },
                                                                      controller: firstname,
                                                                      cursorColor: Color.fromRGBO(21, 43, 81, 1),
                                                                      decoration: InputDecoration(
                                                                        enabledBorder: firstnameerror
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(10),
                                                                          borderSide: BorderSide(
                                                                              color: Colors
                                                                                  .red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        border: InputBorder.none,
                                                                        contentPadding: EdgeInsets.all(12),
                                                                        hintText: " Enter Street Address here...",
                                                                        hintStyle: TextStyle(
                                                                          color: Color(0xFF8A95A8),
                                                                          fontSize: 14,
                                                                          fontWeight: FontWeight.w400,
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
                                                          style: TextStyle(color: Colors.red),
                                                        ))
                                                        : Container(),
                                                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                                               //city and state
                                                    Row(
                                                      children: [

                                                        Expanded(
                                                          child: Material(
                                                            elevation:3,
                                                            borderRadius: BorderRadius.circular(5),
                                                            child: Container(
                                                              height: 35,
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  // color: Color.fromRGBO(196, 196, 196, .3),
                                                                  border: Border.all(color: Color(0xFF8A95A8))
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  Positioned.fill(
                                                                    child: TextField(
                                                                      onChanged: (value) {
                                                                        setState(() {
                                                                          firstnameerror = false;
                                                                        });
                                                                      },
                                                                      controller: firstname,
                                                                      cursorColor: Color.fromRGBO(21, 43, 81, 1),
                                                                      decoration: InputDecoration(
                                                                        enabledBorder: firstnameerror
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(10),
                                                                          borderSide: BorderSide(
                                                                              color: Colors
                                                                                  .red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        border: InputBorder.none,
                                                                        contentPadding: EdgeInsets.all(12),
                                                                        hintText: " Enter city here...",
                                                                        hintStyle: TextStyle(
                                                                          color: Color(0xFF8A95A8),
                                                                          fontSize: 14,
                                                                          fontWeight: FontWeight.w400,
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
                                                          width: MediaQuery.of(context).size.width * .03,
                                                        ),
                                                        Expanded(
                                                          child: Material(
                                                            elevation:3,
                                                            borderRadius: BorderRadius.circular(5),
                                                            child: Container(
                                                              height: 35,
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  // color: Color.fromRGBO(196, 196, 196, .3),
                                                                  border: Border.all(color: Color(0xFF8A95A8))
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  Positioned.fill(
                                                                    child: TextField(
                                                                      onChanged: (value) {
                                                                        setState(() {
                                                                          firstnameerror = false;
                                                                        });
                                                                      },
                                                                      controller: firstname,
                                                                      cursorColor: Color.fromRGBO(21, 43, 81, 1),
                                                                      decoration: InputDecoration(
                                                                        enabledBorder: firstnameerror
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(10),
                                                                          borderSide: BorderSide(
                                                                              color: Colors
                                                                                  .red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        border: InputBorder.none,
                                                                        contentPadding: EdgeInsets.all(12),
                                                                        hintText: " Enter state here...",
                                                                        hintStyle: TextStyle(
                                                                          color: Color(0xFF8A95A8),
                                                                          fontSize: 14,
                                                                          fontWeight: FontWeight.w400,
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
                                                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                                                    // counrty and postal code
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Material(
                                                            elevation:3,
                                                            borderRadius: BorderRadius.circular(5),
                                                            child: Container(
                                                              height: 35,
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  // color: Color.fromRGBO(196, 196, 196, .3),
                                                                  border: Border.all(color: Color(0xFF8A95A8))
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  Positioned.fill(
                                                                    child: TextField(
                                                                      onChanged: (value) {
                                                                        setState(() {
                                                                          firstnameerror = false;
                                                                        });
                                                                      },
                                                                      controller: firstname,
                                                                      cursorColor: Color.fromRGBO(21, 43, 81, 1),
                                                                      decoration: InputDecoration(
                                                                        enabledBorder: firstnameerror
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(10),
                                                                          borderSide: BorderSide(
                                                                              color: Colors
                                                                                  .red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        border: InputBorder.none,
                                                                        contentPadding: EdgeInsets.all(12),
                                                                        hintText: " Enter country here...",
                                                                        hintStyle: TextStyle(
                                                                          color: Color(0xFF8A95A8),
                                                                          fontSize: 14,
                                                                          fontWeight: FontWeight.w400,
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
                                                          width: MediaQuery.of(context).size.width * .03,
                                                        ),
                                                        Expanded(
                                                          child: Material(
                                                            elevation:3,
                                                            borderRadius: BorderRadius.circular(5),
                                                            child: Container(
                                                              height: 35,
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  // color: Color.fromRGBO(196, 196, 196, .3),
                                                                  border: Border.all(color: Color(0xFF8A95A8))
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  Positioned.fill(
                                                                    child: TextField(
                                                                      onChanged: (value) {
                                                                        setState(() {
                                                                          firstnameerror = false;
                                                                        });
                                                                      },
                                                                      controller: firstname,
                                                                      cursorColor: Color.fromRGBO(21, 43, 81, 1),
                                                                      decoration: InputDecoration(
                                                                        enabledBorder: firstnameerror
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(10),
                                                                          borderSide: BorderSide(
                                                                              color: Colors
                                                                                  .red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        border: InputBorder.none,
                                                                        contentPadding: EdgeInsets.all(12),
                                                                        hintText: " Enter postal code here...",
                                                                        hintStyle: TextStyle(
                                                                          color: Color(0xFF8A95A8),
                                                                          fontSize: 14,
                                                                          fontWeight: FontWeight.w400,
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
                                                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                                                    //merchant id
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Merchant id*",
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: Color(0xFF8A95A8),
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
                                                          width: 24.0, // Standard width for checkbox
                                                          height: 24.0,
                                                          child: Checkbox(
                                                            value: isChecked,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                isChecked =
                                                                    value ?? false;
                                                              });
                                                            },
                                                            activeColor: isChecked ?  Color.fromRGBO(21, 43, 81, 1) : Colors.black,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width * .02,
                                                        ),
                                                        Expanded(
                                                          child: Material(
                                                            elevation:3,
                                                            borderRadius: BorderRadius.circular(5),
                                                            child: Container(
                                                              height: 35,
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  // color: Color.fromRGBO(196, 196, 196, .3),
                                                                  border: Border.all(color: Color(0xFF8A95A8))
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  Positioned.fill(
                                                                    child: TextField(
                                                                      onChanged: (value) {
                                                                        setState(() {
                                                                          firstnameerror = false;
                                                                        });
                                                                      },
                                                                      controller: firstname,
                                                                      cursorColor: Color.fromRGBO(21, 43, 81, 1),
                                                                      decoration: InputDecoration(
                                                                        enabledBorder: firstnameerror
                                                                            ? OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(10),
                                                                          borderSide: BorderSide(
                                                                              color: Colors
                                                                                  .red), // Set border color here
                                                                        )
                                                                            : InputBorder.none,
                                                                        border: InputBorder.none,
                                                                        contentPadding: EdgeInsets.all(12),
                                                                        hintText: " Enter processor id here...",
                                                                        hintStyle: TextStyle(
                                                                          color: Color(0xFF8A95A8),
                                                                          fontSize: 14,
                                                                          fontWeight: FontWeight.w400,
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
                                                          width: MediaQuery.of(context).size.width * .02,
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                           // onDelete(property);
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
                                                    ),
                                                    firstnameerror
                                                        ? Center(
                                                        child: Text(
                                                          firstnamemessage,
                                                          style: TextStyle(color: Colors.red),
                                                        ))
                                                        : Container(),
                                                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
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
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(5.0),
                                                            child: Container(
                                                              height: 30.0,
                                                              width: MediaQuery.of(context).size.width * .3,
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(5.0),
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
                                                                child: isLoading
                                                                    ? SpinKitFadingCircle(
                                                                  color: Colors.white,
                                                                  size: 25.0,
                                                                )
                                                                    : Text(
                                                                  "Add Property Type",
                                                                  style: TextStyle(
                                                                      color: Colors.white,
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 12),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
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
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(5.0),
                                                            child: Container(
                                                              height: 30.0,
                                                              width: 50,
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(5.0),
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
                                                                      fontSize: 12),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
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
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(5.0),
                                                            child: Container(
                                                              height: 30.0,
                                                              width: 50,
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
                                                                      fontSize: 12),
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
