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
  TextEditingController subtype = TextEditingController();
  bool iserror = false;
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
                  ["Vendor", "Work Order"]),
            ],
          ),
        ),
      ),
      body:
          // SingleChildScrollView(
          //   child: Column(
          //     children: [
          //       Padding(
          //         padding: const EdgeInsets.all(25.0),
          //         child: ClipRRect(
          //           borderRadius: BorderRadius.circular(5.0),
          //           child: Container(
          //             height: 50.0,
          //             padding: EdgeInsets.only(top: 8, left: 10),
          //             width: MediaQuery.of(context).size.width * .91,
          //             margin: const EdgeInsets.only(
          //                 bottom: 6.0), //Same as `blurRadius` i guess
          //             decoration: BoxDecoration(
          //               borderRadius: BorderRadius.circular(5.0),
          //               color: Color.fromRGBO(21, 43, 81, 1),
          //               boxShadow: [
          //                 BoxShadow(
          //                   color: Colors.grey,
          //                   offset: Offset(0.0, 1.0), //(x,y)
          //                   blurRadius: 6.0,
          //                 ),
          //               ],
          //             ),
          //             child: Text(
          //               "Add Property",
          //               style: TextStyle(
          //                   color: Colors.white,
          //                   fontWeight: FontWeight.bold,
          //                   fontSize: 22),
          //             ),
          //           ),
          //         ),
          //       ),
          //       Padding(
          //         padding: const EdgeInsets.only(left: 25, right: 25),
          //         child: Material(
          //           elevation: 6,
          //           borderRadius: BorderRadius.circular(10),
          //           child: Container(
          //             height: MediaQuery.of(context).size.height * .62,
          //             width: MediaQuery.of(context).size.width * .99,
          //             decoration: BoxDecoration(
          //                 color: Colors.white,
          //                 borderRadius: BorderRadius.circular(10),
          //                 border: Border.all(
          //                   color: Color.fromRGBO(21, 43, 81, 1),
          //                 )),
          //             child: Column(
          //               children: [
          //                 SizedBox(
          //                   height: 20,
          //                 ),
          //                 Row(
          //                   children: [
          //                     SizedBox(
          //                       width: 15,
          //                     ),
          //                     Text(
          //                       "New Property ",
          //                       style: TextStyle(
          //                           fontWeight: FontWeight.bold,
          //                           color: Color.fromRGBO(21, 43, 81, 1),
          //                           fontSize: 15),
          //                     ),
          //                   ],
          //                 ),
          //                 SizedBox(
          //                   height: 10,
          //                 ),
          //                 Row(
          //                   children: [
          //                     SizedBox(
          //                       width: 15,
          //                     ),
          //                     Text(
          //                       "Property information",
          //                       style: TextStyle(
          //                           color: Colors.grey,
          //                           fontWeight: FontWeight.bold,
          //                           fontSize: 14),
          //                     ),
          //                   ],
          //                 ),
          //                 SizedBox(
          //                   height: 10,
          //                 ),
          //                 Row(
          //                   children: [
          //                     SizedBox(
          //                       width: 15,
          //                     ),
          //                     Text(
          //                       "What is the property Type?",
          //                       style: TextStyle(
          //                           color: Color.fromRGBO(21, 43, 81, 1),
          //                           fontWeight: FontWeight.bold,
          //                           fontSize: 14),
          //                     ),
          //                   ],
          //                 ),
          //                 SizedBox(
          //                   height: 10,
          //                 ),
          //                 Row(
          //                   children: [
          //                     SizedBox(
          //                       width: 15,
          //                     ),
          //                     DropdownButtonHideUnderline(
          //                       child: DropdownButton2<String>(
          //                         isExpanded: true,
          //                         hint: const Row(
          //                           children: [
          //                             SizedBox(
          //                               width: 4,
          //                             ),
          //                             Expanded(
          //                               child: Text(
          //                                 'Property Type',
          //                                 style: TextStyle(
          //                                   fontSize: 10,
          //                                   fontWeight: FontWeight.bold,
          //                                   color: Color(0xFF8A95A8),
          //                                 ),
          //                                 overflow: TextOverflow.ellipsis,
          //                               ),
          //                             ),
          //                           ],
          //                         ),
          //                         items: items
          //                             .map(
          //                                 (String item) => DropdownMenuItem<String>(
          //                                       value: item,
          //                                       child: Text(
          //                                         item,
          //                                         style: const TextStyle(
          //                                           fontSize: 14,
          //                                           fontWeight: FontWeight.bold,
          //                                           color: Colors.black,
          //                                         ),
          //                                         overflow: TextOverflow.ellipsis,
          //                                       ),
          //                                     ))
          //                             .toList(),
          //                         value: selectedValue,
          //                         onChanged: (value) {
          //                           setState(() {
          //                             selectedValue = value;
          //                           });
          //                         },
          //                         buttonStyleData: ButtonStyleData(
          //                           height: 30,
          //                           width: 134,
          //                           padding:
          //                               const EdgeInsets.only(left: 14, right: 14),
          //                           decoration: BoxDecoration(
          //                             borderRadius: BorderRadius.circular(3),
          //                             border: Border.all(
          //                               color: Colors.black26,
          //                             ),
          //                             color: Colors.white,
          //                           ),
          //                           elevation: 3,
          //                         ),
          //                         dropdownStyleData: DropdownStyleData(
          //                           maxHeight: 200,
          //                           width: 200,
          //                           decoration: BoxDecoration(
          //                             borderRadius: BorderRadius.circular(14),
          //                             //color: Colors.redAccent,
          //                           ),
          //                           offset: const Offset(-20, 0),
          //                           scrollbarTheme: ScrollbarThemeData(
          //                             radius: const Radius.circular(40),
          //                             thickness: MaterialStateProperty.all(6),
          //                             thumbVisibility:
          //                                 MaterialStateProperty.all(true),
          //                           ),
          //                         ),
          //                         menuItemStyleData: const MenuItemStyleData(
          //                           height: 40,
          //                           padding: EdgeInsets.only(left: 14, right: 14),
          //                         ),
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //                 SizedBox(
          //                   height: 10,
          //                 ),
          //                 Row(
          //                   children: [
          //                     SizedBox(
          //                       width: 15,
          //                     ),
          //                     Text(
          //                       "What is the street  address?",
          //                       style: TextStyle(
          //                           color: Color.fromRGBO(21, 43, 81, 1),
          //                           fontWeight: FontWeight.bold,
          //                           fontSize: 14),
          //                     ),
          //                   ],
          //                 ),
          //                 SizedBox(
          //                   height: 5,
          //                 ),
          //                 Row(
          //                   children: [
          //                     SizedBox(
          //                       width: 15,
          //                     ),
          //                     Text(
          //                       "Address*",
          //                       style: TextStyle(
          //                           color: Color(0xFF8A95A8),
          //                           fontWeight: FontWeight.bold,
          //                           fontSize: 12),
          //                     ),
          //                   ],
          //                 ),
          //                 SizedBox(
          //                   height: 8,
          //                 ),
          //                 Row(
          //                   children: [
          //                     SizedBox(
          //                       width: 15,
          //                     ),
          //                     Material(
          //                       elevation: 2,
          //                       borderRadius: BorderRadius.circular(3),
          //                       child: Container(
          //                         width: MediaQuery.of(context).size.width * .6,
          //                         height: 30,
          //                         padding: EdgeInsets.only(left: 10),
          //                         decoration: BoxDecoration(
          //                           color: Colors.white,
          //                           borderRadius: BorderRadius.circular(3),
          //                           border: Border.all(
          //                             color: Color(0xFF8A95A8),
          //                           ),
          //                         ),
          //                         child: Center(
          //                           child: TextFormField(
          //                             controller: subtype,
          //                             decoration: InputDecoration(
          //                               contentPadding: EdgeInsets.all(12),
          //                               border: InputBorder.none,
          //                               hintText: "Townhome",
          //                               hintStyle: TextStyle(
          //                                   color: Color(0xFF8A95A8), fontSize: 12),
          //                             ),
          //                           ),
          //                         ),
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //                 SizedBox(
          //                   height: 10,
          //                 ),
          //                 Row(
          //
          //                   children: [
          //                     SizedBox(width: MediaQuery.of(context).size.width * .043,),
          //                     Text(
          //                       "City*",
          //                       style: TextStyle(
          //                           color: Color(0xFF8A95A8),
          //                           fontWeight: FontWeight.bold,
          //                           fontSize: 12),
          //                     ),
          //                     SizedBox(width: MediaQuery.of(context).size.width * .23,),
          //                     Text(
          //                       "State*",
          //                       style: TextStyle(
          //                           color: Color(0xFF8A95A8),
          //                           fontWeight: FontWeight.bold,
          //                           fontSize: 12),
          //                     ),
          //                   ],
          //                 ),
          //                 SizedBox(
          //                   height: 9,
          //                 ),
          //                 Row(
          //                   children: [
          //                     Row(
          //                       children: [
          //                         SizedBox(
          //                           width: 15,
          //                         ),
          //                         Material(
          //                           elevation: 2,
          //                           borderRadius: BorderRadius.circular(3),
          //                           child: Container(
          //                             width: MediaQuery.of(context).size.width * .29,
          //                             height: 30,
          //                             padding: EdgeInsets.only(left: 10),
          //                             decoration: BoxDecoration(
          //                               color: Colors.white,
          //                               borderRadius: BorderRadius.circular(3),
          //                               border: Border.all(
          //                                 color: Color(0xFF8A95A8),
          //                               ),
          //                             ),
          //                             child: Center(
          //                               child: TextFormField(
          //                                 controller: subtype,
          //                                 decoration: InputDecoration(
          //                                   contentPadding: EdgeInsets.all(12),
          //                                   border: InputBorder.none,
          //                                   hintText: "Enter CIty here",
          //                                   hintStyle: TextStyle(
          //                                       color: Color(0xFF8A95A8),
          //                                       fontSize: 10),
          //                                 ),
          //                               ),
          //                             ),
          //                           ),
          //                         ),
          //
          //                       ],
          //                     ),
          //                     SizedBox(width: 5,),
          //                     Row(
          //                       children: [
          //                         Material(
          //                           elevation: 2,
          //                           borderRadius: BorderRadius.circular(3),
          //                           child: Container(
          //                             width: MediaQuery.of(context).size.width * .29,
          //                             height: 30,
          //                             padding: EdgeInsets.only(left: 10),
          //                             decoration: BoxDecoration(
          //                               color: Colors.white,
          //                               borderRadius: BorderRadius.circular(3),
          //                               border: Border.all(
          //                                 color: Color(0xFF8A95A8),
          //                               ),
          //                             ),
          //                             child: Center(
          //                               child: TextFormField(
          //                                 controller: subtype,
          //                                 decoration: InputDecoration(
          //                                   contentPadding: EdgeInsets.all(12),
          //                                   border: InputBorder.none,
          //                                   hintText: "Enter State here",
          //                                   hintStyle: TextStyle(
          //                                       color: Color(0xFF8A95A8),
          //                                       fontSize: 10),
          //                                 ),
          //                               ),
          //                             ),
          //                           ),
          //                         ),
          //                         SizedBox(
          //                           width: 15,
          //                         ),
          //                       ],
          //                     ),
          //                   ],
          //                 ),
          //                 SizedBox(
          //                   height: 20,
          //                 ),
          //                 Row(
          //
          //                   children: [
          //                     SizedBox(width: MediaQuery.of(context).size.width * .043,),
          //                     Text(
          //                       "Country*",
          //                       style: TextStyle(
          //                           color: Color(0xFF8A95A8),
          //                           fontWeight: FontWeight.bold,
          //                           fontSize: 12),
          //                     ),
          //                     SizedBox(width: MediaQuery.of(context).size.width * .21,),
          //                     Text(
          //                       "Postal Code*",
          //                       style: TextStyle(
          //                           color: Color(0xFF8A95A8),
          //                           fontWeight: FontWeight.bold,
          //                           fontSize: 12),
          //                     ),
          //                   ],
          //                 ),
          //                 SizedBox(
          //                   height: 9,
          //                 ),
          //                 Row(
          //                   children: [
          //                     Row(
          //                       children: [
          //                         SizedBox(
          //                           width: 15,
          //                         ),
          //                         Material(
          //                           elevation: 3,
          //                           borderRadius: BorderRadius.circular(3),
          //                           child: Container(
          //                             width: MediaQuery.of(context).size.width * .33,
          //                             height: 30,
          //                             padding: EdgeInsets.only(left: 10),
          //                             decoration: BoxDecoration(
          //                               color: Colors.white,
          //                               borderRadius: BorderRadius.circular(3),
          //                               border: Border.all(
          //                                 color: Color(0xFF8A95A8),
          //                               ),
          //                             ),
          //                             child: Center(
          //                               child: TextFormField(
          //                                 controller: subtype,
          //                                 decoration: InputDecoration(
          //                                   contentPadding: EdgeInsets.all(12),
          //                                   border: InputBorder.none,
          //                                   hintText: "Enter Country here",
          //                                   hintStyle: TextStyle(
          //                                       color: Color(0xFF8A95A8),
          //                                       fontSize: 10),
          //                                 ),
          //                               ),
          //                             ),
          //                           ),
          //                         ),
          //
          //                       ],
          //                     ),
          //                     SizedBox(width: 5,),
          //                     Row(
          //                       children: [
          //                         Material(
          //                           elevation: 3,
          //                           borderRadius: BorderRadius.circular(3),
          //                           child: Container(
          //                             width: MediaQuery.of(context).size.width * .34,
          //                             height: 30,
          //                             padding: EdgeInsets.only(left: 10),
          //                             decoration: BoxDecoration(
          //                               color: Colors.white,
          //                               borderRadius: BorderRadius.circular(3),
          //                               border: Border.all(
          //                                 color: Color(0xFF8A95A8),
          //                               ),
          //                             ),
          //                             child: Center(
          //                               child: TextFormField(
          //                                 controller: subtype,
          //                                 decoration: InputDecoration(
          //                                   contentPadding: EdgeInsets.all(12),
          //                                   border: InputBorder.none,
          //                                   hintText: "Enter Pstal Code here",
          //                                   hintStyle: TextStyle(
          //                                       color: Color(0xFF8A95A8),
          //                                       fontSize: 10),
          //                                 ),
          //                               ),
          //                             ),
          //                           ),
          //                         ),
          //                         SizedBox(
          //                           width: 15,
          //                         ),
          //                       ],
          //                     ),
          //                   ],
          //                 ),
          //                 SizedBox(
          //                   height: 20,
          //                 ),
          //
          //               ],
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
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
                    padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
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
                                    controller: subtype,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(12),
                                      border: InputBorder.none,
                                      hintText: "Townhome",
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
                                        controller: subtype,
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
                                        controller: subtype,
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
                                        controller: subtype,
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
                                        controller: subtype,
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
                       Row(
                         children: [
                           SizedBox(
                             width: 15,
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
                // onTap: () async {
                //   if (name.text.isEmpty) {
                //     setState(() {
                //       nameerror = true;
                //       namemessage = "name is required";
                //     });
                //   } else {
                //     setState(() {
                //       nameerror = false;
                //     });
                //   }
                //   if (designation.text.isEmpty) {
                //     setState(() {
                //       designationerror = true;
                //       designationmessage = "designation is required";
                //     });
                //   } else {
                //     setState(() {
                //       designationerror = false;
                //     });
                //   }
                //   if (phonenumber.text.isEmpty) {
                //     setState(() {
                //       phonenumbererror = true;
                //       phonenumbermessage = "number is required";
                //     });
                //   } else {
                //     setState(() {
                //       phonenumbererror = false;
                //     });
                //   }
                //   if (email.text.isEmpty) {
                //     setState(() {
                //       emailerror = true;
                //       emailmessage = "email is required";
                //     });
                //   } else {
                //     setState(() {
                //       emailerror = false;
                //     });
                //   }
                //   if (password.text.isEmpty) {
                //     setState(() {
                //       passworderror = true;
                //       passwordmessage = "password is required";
                //     });
                //   } else {
                //     setState(() {
                //       passworderror = false;
                //     });
                //   }
                //   if (!nameerror &&
                //       designationerror &&
                //       phonenumbererror &&
                //       emailerror &&
                //       phonenumbererror) {
                //     setState(() {
                //       loading = true;
                //     });
                //   }
                //   SharedPreferences prefs =
                //   await SharedPreferences.getInstance();
                //   String? adminId = prefs.getString("adminId");
                //
                //   if (adminId != null) {
                //     try {
                //       await StaffMemberRepository().addStaffMember(
                //         adminId: adminId,
                //         staffmemberName: name.text,
                //         staffmemberDesignation: designation.text,
                //         staffmemberPhoneNumber: phonenumber.text,
                //         staffmemberEmail: email.text,
                //         staffmemberPassword: password.text,
                //       );
                //       setState(() {
                //         loading = false;
                //       });
                //     } catch (e) {
                //       setState(() {
                //         loading = false;
                //       });
                //       // Handle error
                //     }
                //   }
                // },
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
    );
  }
}
