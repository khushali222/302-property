import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../repository/Property_type.dart';
import '../widgets/drawer_tiles.dart';

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
  bool  propertyTypeError = false;

  String addressmessage = "";
  String citymessage = "";
  String statemessage = "";
  String countrymessage = "";
  String postalcodemessage = "";
  String subtypemessage = "";
  String propertyTypeErrorMessage = "";

  bool iserror = false;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      drawer: Drawer(
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
                    color: Colors.white,
                  ),
                  "Add Property Type",
                  true),
              buildListTile(
                  context,
                  Icon(
                    CupertinoIcons.person_add,
                    color: Colors.black,
                  ),
                  "Add Staff Member",
                  false),
              buildDropdownListTile(context, Icon(Icons.key), "Rental",
                  ["Properties", "RentalOwner", "Tenants"]),
              buildDropdownListTile(context, Icon(Icons.thumb_up_alt_outlined),
                  "Leasing", ["Rent Roll", "Applicants"]),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"],),
            ],
          ),
        ),
      ),
      body:
      SingleChildScrollView(
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
                      padding: const EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
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
                                    padding: EdgeInsets.only(left: 14, right: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          propertyTypeError
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 15,),
                              Text(
                                propertyTypeErrorMessage,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: MediaQuery.of(context).size.width * .03
                                ),
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
                                  SizedBox(width: 15,),
                                  Text(
                                    addressmessage,
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: MediaQuery.of(context).size.width * .04
                                    ),
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
                                      width:
                                          MediaQuery.of(context).size.width * .29,
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
                                      width:
                                          MediaQuery.of(context).size.width * .29,
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 15,),
                                  Text(
                                    addressmessage,
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: MediaQuery.of(context).size.width * .04
                                    ),
                                  ),
                                ],
                              )
                                  : Container(),
                              SizedBox(width: 45,),
                              addresserror
                                  ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 15,),
                                  Text(
                                    addressmessage,
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: MediaQuery.of(context).size.width * .04
                                    ),
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
                                      width:
                                          MediaQuery.of(context).size.width * .30,
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
                                      width:
                                          MediaQuery.of(context).size.width * .33,
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 15,),
                                  Text(
                                    addressmessage,
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: MediaQuery.of(context).size.width * .04
                                    ),
                                  ),
                                ],
                              )
                                  : Container(),
                              SizedBox(width: 45,),
                              addresserror
                                  ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(width: 15,),
                                  Text(
                                    addressmessage,
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: MediaQuery.of(context).size.width * .04
                                    ),
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
                      padding: const EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
                      child:
                     Column(
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
                                 return Padding(
                                   padding: const EdgeInsets.only(top: 90, bottom: 90, left: 30, right: 30),
                                   child: Material(
                                     type: MaterialType.transparency,
                                     child: Container(
                                       decoration: BoxDecoration(
                                         color: Colors.white,
                                         borderRadius: BorderRadius.circular(20),
                                       ),
                                       child: Padding(
                                         padding: const EdgeInsets.only(left: 20, right: 20,top: 20,bottom: 20),
                                         child: Column(
                                           children: [
                                             Row(
                                               children: [
                                                 Text("Add rental owner",
                                                     style: TextStyle(
                                                       color: Color.fromRGBO(21, 43, 81, 1),
                                                       fontWeight: FontWeight.bold
                                                     )),],
                                             ),
                                             SizedBox(
                                               height: 10,
                                             ),
                                             Row(
                                               children: [
                                                 Container(
                                                   height: MediaQuery.of(context).size.height * 0.03,
                                                   width: MediaQuery.of(context).size.height * 0.03,
                                                   decoration: BoxDecoration(
                                                     color: Colors.white,
                                                     borderRadius: BorderRadius.circular(5),
                                                   ),
                                                   child: Checkbox(
                                                     activeColor: isChecked ? Colors.black : Colors.white,
                                                     checkColor: Colors.white,
                                                     value: isChecked, // assuming _isChecked is a boolean variable indicating whether the checkbox is checked or not
                                                     onChanged: ( value) {
                                                       setState(() {
                                                         isChecked = value ?? false; // ensure value is not null
                                                       });
                                                     },
                                                   ),
                                                 ),
                                               ],
                                             ),
                                             SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                                             Row(
                                               children: [
                                                 SizedBox(
                                                   width: MediaQuery.of(context).size.width * .099,
                                                 ),
                                                 Expanded(
                                                   child: Container(
                                                     height: 50,
                                                     decoration: BoxDecoration(
                                                       borderRadius: BorderRadius.circular(10),
                                                       color: Color.fromRGBO(196, 196, 196, .3),
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
                                                               prefixIcon: Container(
                                                                   height: 20,
                                                                   width: 20,
                                                                   padding: EdgeInsets.all(13),
                                                                   child: Image.asset(
                                                                       "assets/icons/user_icon.png")),
                                                               hintText: "First Name",
                                                             ),
                                                           ),
                                                         ),
                                                       ],
                                                     ),
                                                   ),
                                                 ),
                                                 SizedBox(
                                                   width: MediaQuery.of(context).size.width * .099,
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
                                               height: MediaQuery.of(context).size.height * 0.025,
                                             ),
                                             // Last name
                                             Row(
                                               children: [
                                                 SizedBox(
                                                   width: MediaQuery.of(context).size.width * .099,
                                                 ),
                                                 Expanded(
                                                   child: Container(
                                                     height: 50,
                                                     decoration: BoxDecoration(
                                                       borderRadius: BorderRadius.circular(10),
                                                       color: Color.fromRGBO(196, 196, 196, .3),
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
                                                               contentPadding: EdgeInsets.all(10),
                                                               prefixIcon: Container(
                                                                   height: 20,
                                                                   width: 20,
                                                                   padding: EdgeInsets.all(13),
                                                                   child: Image.asset(
                                                                       "assets/icons/user_icon.png")),
                                                               hintText: "Last Name",
                                                             ),
                                                           ),
                                                         ),
                                                       ],
                                                     ),
                                                   ),
                                                 ),
                                                 SizedBox(
                                                   width: MediaQuery.of(context).size.width * .099,
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
                                           ],
                                         ),
                                       ),
                                     ),
                                   ),
                                 );
                               },
                             );
                           },
                           child: Row(
                             children: [
                               SizedBox(
                                 width: 15,
                               ),
                               Icon(Icons.add,size: 10,color: Colors.green[400],),
                               SizedBox(
                                 width: 9,
                               ),
                               Text(
                                 "Add Rental Owner",
                                 style: TextStyle(
                                   //  color: Color(0xFF8A95A8),
                                   color: Colors.green[400],
                                     //  fontWeight: FontWeight.bold,
                                     fontSize: 10),
                               ),
                             ],
                           ),
                         ),
                       ],
                     )
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
                        padding: const EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
                        child:
                        Column(
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
                                      padding: EdgeInsets.only(left: 14, right: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                    ),
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
                    }if (address.text.isEmpty) {
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
                        postalcodeerror) {

                    }
                    },
                  child: Row(
                    children: [
                      SizedBox(
                          width:
                          MediaQuery.of(context).size.width * 0.01),
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



