import 'dart:convert';

import 'package:device_preview/device_preview.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/screens/Staff_Member/Add_staffmember.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../Model/propertytype.dart';
import '../../constant/constant.dart';
import '../../model/staffmember.dart';
import '../../repository/Property_type.dart';
import '../../repository/Staffmember.dart';
import '../../widgets/drawer_tiles.dart';
import '../Property_Type/Add_property_type.dart';
import '../Property_Type/Edit_property_type.dart';
import '../Staff_Member/Edit_staff_member.dart';
import 'package:http/http.dart'as http;


void main() {
  runApp(
    DevicePreview(
      enabled: true,
      tools: [
        ...DevicePreview.defaultTools,
      ],
      builder: (context) => Staff_table(),
    ),
  );
}

class Staff_table extends StatefulWidget {
  // final propertytype data;
  // final int index;
  // Staff_table({required this.data, required this.index});
  @override
  State<Staff_table> createState() => _Staff_tableState();
}

class _Staff_tableState extends State<Staff_table> {
  late Future<List<Staffmembers>> futureStaffmembers;
  int currentPage = 0;
  int itemsPerPage = 10; // Adjust the number of items per page as needed
  @override
  void initState() {
    super.initState();
    futureStaffmembers = StaffMemberRepository().fetchStaffmembers();
    isExpanded = false;
    fetchstaffadded();
  }

  List<int> itemsPerPageOptions = [
    10,
    25,
    50,
    100,
  ]; // Options for items per page

  late bool isExpanded;
  bool sorting1 = false;
  bool sorting2 = false;
  bool sorting3 = false;
  bool ascending1 = false;
  bool ascending2 = false;
  bool ascending3 = false;
  void handleEdit(Staffmembers staff) async {
    // Handle edit action
    print('Edit ${staff.sId}');
    // final result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => Edit_property_type(
    //       property: property,
    //     ),
    //   ),
    // );
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Edit_staff_member(
            staff: staff,
          ),
        ));
    /* if (result == true) {
      setState(() {
        futureStaffmemberss = StaffmembersRepository().fetchStaffmemberss();
      });
    }*/
  }

  void _showAlert(BuildContext context, String id) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this property!",
      style: AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.grey,
        ),
        DialogButton(
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            var data = StaffMemberRepository().DeleteStaffMember(id: id);

            // Add your delete logic here
            setState(() {
              futureStaffmembers = StaffMemberRepository().fetchStaffmembers();
            });
            Navigator.pop(context);
          },
          color: Colors.red,
        )
      ],
    ).show();
  }

  void sortData(List<Staffmembers> data) {
    if (sorting1) {
      data.sort((a, b) => ascending1
          ? a.staffmemberName!.compareTo(b.staffmemberName!)
          : b.staffmemberName!.compareTo(a.staffmemberName!));
    } else if (sorting2) {
      data.sort((a, b) => ascending2
          ? a.staffmemberDesignation!.compareTo(b.staffmemberDesignation!)
          : b.staffmemberDesignation!.compareTo(a.staffmemberDesignation!));
    } else if (sorting3) {
      data.sort((a, b) => ascending3
          ? a.createdAt!.compareTo(b.createdAt!)
          : b.createdAt!.compareTo(a.createdAt!));
    }
  }

  void handleDelete(Staffmembers staff) {
    _showAlert(context, staff.staffmemberId!);
    // Handle delete action
    print('Delete ${staff.sId}');
  }

  int? expandedIndex;
  Set<int> expandedIndices = {};
  String? selectedValue;
  String searchvalue = "";
  final List<String> items = ['Residential', "Commercial", "All"];
  int staffCountLimit = 0;
  int rentalCount = 0;
  Future<void> fetchstaffadded() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    final response =
    await http.get(Uri.parse('${Api_url}/api/staffmember/limitation/$id'));
    final jsonData = json.decode(response.body);
    print(jsonData);
    if (jsonData["statusCode"] == 200 || jsonData["statusCode"] == 201 ) {
      print(rentalCount);
      print(staffCountLimit);
      setState(() {
        rentalCount = jsonData['rentalCount'];
        print(rentalCount);
        staffCountLimit = jsonData['staffCountLimit'];
        print(staffCountLimit);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }
  void _showAlertforLimit(BuildContext context) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Plan Limitation",
      desc: "The limit for adding staffmember according to the plan has been reached.",
      style: AlertStyle(
          backgroundColor: Color.fromRGBO(255, 255, 255, 1),
          descStyle: TextStyle(fontSize: 14)
        //  overlayColor: Colors.black.withOpacity(.8)
      ),
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: Color.fromRGBO(21, 43, 83, 1),
        ),
        /* DialogButton(
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
             var data = PropertiesRepository().DeleteProperties(id: id);

            setState(() {
              futureRentalOwners = PropertiesRepository().fetchProperties();
              //  futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
            });
            Navigator.pop(context);
          },
          color: Colors.red,
        )*/
      ],
    ).show();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: widget_302.App_Bar(context: context),
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
                      color: Colors.white,
                    ),
                    "Add Property Type",
                    true),
                buildListTile(context, Icon(CupertinoIcons.person_add),
                    "Add Staff Member", false),
                buildDropdownListTile(
                    context,
                    FaIcon(
                      FontAwesomeIcons.key,
                      size: 20,
                      color: Colors.black,
                    ),
                    "Rental",
                    ["Properties", "RentalOwner", "Tenants"]),
                buildDropdownListTile(
                    context,
                    FaIcon(
                      FontAwesomeIcons.thumbsUp,
                      size: 20,
                      color: Colors.black,
                    ),
                    "Leasing",
                    ["Rent Roll", "Applicants"]),
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
        SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.only(left: 13, right: 13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => Add_staffmember()));
                        if (result == true) {
                          setState(() {
                            futureStaffmembers = StaffMemberRepository().fetchStaffmembers();
                          });
                        }
                      },
                      child: Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.4,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(21, 43, 81, 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Add Staff Member",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                  MediaQuery.of(context).size.width *
                                      0.034,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: Container(
                    height: 50.0,
                    padding: EdgeInsets.only(top: 8, left: 10),
                    width: MediaQuery.of(context).size.width * .91,
                    margin: const EdgeInsets.only(
                        bottom: 6.0), //Same as `blurRadius` i guess
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
                    child: Text('Staff Member',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              //search
              Padding(
                padding: const EdgeInsets.only(left: 2, right: 2),
                child: Row(
                  children: [
                    SizedBox(width: 13),
                    Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(2),
                      child: Container(
                        height: 40,
                        width: 140,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            // border: Border.all(color: Colors.grey),
                            border: Border.all(color: Color(0xFF8A95A8))),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: TextField(
                                // onChanged: (value) {
                                //   setState(() {
                                //     cvverror = false;
                                //   });
                                // },
                                // controller: cvv,
                                onChanged: (value) {
                                  setState(() {
                                    searchvalue = value;
                                  });
                                },
                                cursorColor:
                                Color.fromRGBO(21, 43, 81, 1),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Search here...",
                                  hintStyle: TextStyle(
                                    // fontWeight: FontWeight.bold,
                                    color: Color(0xFF8A95A8),
                                  ),
                                  contentPadding: EdgeInsets.all(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Text(
                          'Added : ${rentalCount.toString()}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8A95A8),
                              fontSize: 13),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        //  Text("rentalOwnerCountLimit: ${response['rentalOwnerCountLimit']}"),
                        Text(
                          'Total: ${staffCountLimit.toString()}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8A95A8),
                              fontSize: 13),
                        ),
                      ],
                    ),
                    SizedBox(width: 20),
                  ],
                ),
              ),
              // SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: FutureBuilder<List<Staffmembers>>(
                  future: futureStaffmembers,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No data available'));
                    } else {
                      var data = snapshot.data!;
                      if (selectedValue == null && searchvalue!.isEmpty) {
                        data = snapshot.data!;
                      } else if (selectedValue == "All") {
                        data = snapshot.data!;
                      } else if (searchvalue!.isNotEmpty) {
                        data = snapshot.data!
                            .where((staff) =>
                        staff.staffmemberName!
                            .toLowerCase()
                            .contains(searchvalue!.toLowerCase()))
                            .toList();
                      } else {
                        data = snapshot.data!
                            .where((staff) =>
                        staff.staffmemberName == selectedValue)
                            .toList();
                      }
                      sortData(data);
                      final totalPages = (data.length / itemsPerPage).ceil();
                      final currentPageData = data
                          .skip(currentPage * itemsPerPage)
                          .take(itemsPerPage)
                          .toList();
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            _buildHeader(),
                            SizedBox(height: 20),
                            Container(
                              decoration:
                              BoxDecoration(border: Border.all(color: blueColor)),
                              child: Column(
                                children: currentPageData.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  bool isExpanded = expandedIndex == index;
                                  Staffmembers staffmembers = entry.value;
                                  //return CustomExpansionTile(data: Propertytype, index: index);
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: blueColor),
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: InkWell(
                                            onTap: () {
                                              // setState(() {
                                              //    isExpanded = !isExpanded;
                                              // //  expandedIndex = !expandedIndex;
                                              //
                                              // });
                                              // setState(() {
                                              //   if (isExpanded) {
                                              //     expandedIndex = null;
                                              //     isExpanded = !isExpanded;
                                              //   } else {
                                              //     expandedIndex = index;
                                              //   }
                                              // });
                                              setState(() {
                                                if (expandedIndex == index) {
                                                  expandedIndex = null;
                                                } else {
                                                  expandedIndex = index;
                                                }
                                              });
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(left: 5),
                                              padding: !isExpanded
                                                  ? EdgeInsets.only(bottom: 10)
                                                  : EdgeInsets.only(top: 10),
                                              child: FaIcon(
                                                isExpanded
                                                    ? FontAwesomeIcons.sortUp
                                                    : FontAwesomeIcons.sortDown,
                                                size: 20,
                                                color: Color.fromRGBO(21, 43, 83, 1),
                                              ),
                                            ),
                                          ),
                                          title: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Expanded(
                                                  child: Text(
                                                    '${staffmembers.staffmemberName}',
                                                    style: TextStyle(
                                                      color: blueColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                        .08),
                                                Expanded(
                                                  child: Text(
                                                    '${staffmembers.staffmemberDesignation}',
                                                    style: TextStyle(
                                                      color: blueColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                        .08),
                                                Expanded(
                                                  child: Text(
                                                    '${staffmembers.staffmemberPhoneNumber}',
                                                    style: TextStyle(
                                                      color: blueColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                        .02),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (isExpanded)
                                          Container(
                                            padding:
                                            EdgeInsets.symmetric(horizontal: 8.0),
                                            margin: EdgeInsets.only(bottom: 20),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    children: [
                                                      FaIcon(
                                                        isExpanded
                                                            ? FontAwesomeIcons.sortUp
                                                            : FontAwesomeIcons.sortDown,
                                                        size: 50,
                                                        color: Colors.transparent,
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                    'Mail-Id : ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        color:
                                                                        blueColor), // Bold and black
                                                                  ),
                                                                  TextSpan(
                                                                    text: '${staffmembers.staffmemberEmail}',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                        color: Colors
                                                                            .grey), // Light and grey
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(height: MediaQuery.of(context).size.height * .01,),
                                                            Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                    'Updated At : ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        color:
                                                                        blueColor), // Bold and black
                                                                  ),
                                                                  TextSpan(
                                                                    text: formatDate('${staffmembers.updatedAt}'),
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                        color: Colors
                                                                            .grey), // Light and grey
                                                                  ),
                                                                ],
                                                              ),
                                                            ),

                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(width: 7),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                    'Created At: ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        color:
                                                                        blueColor), // Bold and black
                                                                  ),
                                                                  TextSpan(
                                                                    text: formatDate('${staffmembers.createdAt}'),
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                        color: Colors
                                                                            .grey), // Light and grey
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 40,
                                                        child: Column(
                                                          children: [
                                                            IconButton(
                                                              icon: FaIcon(
                                                                FontAwesomeIcons.edit,
                                                                size: 20,
                                                                color: Color.fromRGBO(
                                                                    21, 43, 83, 1),
                                                              ),
                                                              onPressed: () {
                                                                // handleEdit(Propertytype);
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                Edit_staff_member(
                                                                              staff:
                                                                              staffmembers,
                                                                            )));
                                                              },
                                                            ),
                                                            IconButton(
                                                              icon: FaIcon(
                                                                FontAwesomeIcons
                                                                    .trashCan,
                                                                size: 20,
                                                                color: Color.fromRGBO(
                                                                    21, 43, 83, 1),
                                                              ),
                                                              onPressed: () {
                                                                //handleDelete(Propertytype);
                                                                _showAlert(
                                                                    context,
                                                                    staffmembers
                                                                        .staffmemberId!);
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
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
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    // Text('Rows per page:'),
                                    SizedBox(width: 10),
                                    Material(
                                      elevation: 3,
                                      child: Container(
                                        height: 40,
                                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<int>(
                                            value: itemsPerPage,
                                            items: itemsPerPageOptions.map((int value) {
                                              return DropdownMenuItem<int>(
                                                value: value,
                                                child: Text(value.toString()),
                                              );
                                            }).toList(),
                                            onChanged: (newValue) {
                                              setState(() {
                                                itemsPerPage = newValue!;
                                                currentPage =
                                                0; // Reset to first page when items per page change
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: FaIcon(
                                        FontAwesomeIcons.circleChevronLeft,
                                        color: currentPage == 0
                                            ? Colors.grey
                                            : Color.fromRGBO(21, 43, 83, 1),
                                      ),
                                      onPressed: currentPage == 0
                                          ? null
                                          : () {
                                        setState(() {
                                          currentPage--;
                                        });
                                      },
                                    ),
                                    // IconButton(
                                    //   icon: Icon(Icons.arrow_back),
                                    //   onPressed: currentPage > 0
                                    //       ? () {
                                    //     setState(() {
                                    //       currentPage--;
                                    //     });
                                    //   }
                                    //       : null,
                                    // ),
                                    Text('Page ${currentPage + 1} of $totalPages'),
                                    // IconButton(
                                    //   icon: Icon(Icons.arrow_forward),
                                    //   onPressed: currentPage < totalPages - 1
                                    //       ? () {
                                    //     setState(() {
                                    //       currentPage++;
                                    //     });
                                    //   }
                                    //       : null,
                                    // ),
                                    IconButton(
                                      icon: FaIcon(
                                        FontAwesomeIcons.circleChevronRight,
                                        color: currentPage < totalPages - 1
                                            ? Color.fromRGBO(21, 43, 83, 1)
                                            : Colors.grey,
                                      ),
                                      onPressed: currentPage < totalPages - 1
                                          ? () {
                                        setState(() {
                                          currentPage++;
                                        });
                                      }
                                          : null,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
  Widget _buildHeader() {
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: blueColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(13),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          child: Icon(
            Icons.expand_less,
            color: Colors.transparent,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (sorting1 == true) {
                      sorting2 = false;
                      sorting3 = false;
                      ascending1 = sorting1 ? !ascending1 : true;
                      ascending2 = false;
                      ascending3 = false;
                    } else {
                      sorting1 = !sorting1;
                      sorting2 = false;
                      sorting3 = false;
                      ascending1 = sorting1 ? !ascending1 : true;
                      ascending2 = false;
                      ascending3 = false;
                    }

                    // Sorting logic here
                  });
                },
                child: Row(
                  children: [
                    width < 400
                        ? Text("Name",
                        style: TextStyle(color: Colors.white))
                        : Text("Name",
                        style: TextStyle(color: Colors.white)),
                    // Text("Property", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 3),
                    ascending1
                        ? Padding(
                      padding: const EdgeInsets.only(top: 7, left: 2),
                      child: FaIcon(
                        FontAwesomeIcons.sortUp,
                        size: 20,
                        color: Colors.white,
                      ),
                    )
                        : Padding(
                      padding: const EdgeInsets.only(bottom: 7, left: 2),
                      child: FaIcon(
                        FontAwesomeIcons.sortDown,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (sorting2) {
                      sorting1 = false;
                      sorting2 = sorting2;
                      sorting3 = false;
                      ascending2 = sorting2 ? !ascending2 : true;
                      ascending1 = false;
                      ascending3 = false;
                    } else {
                      sorting1 = false;
                      sorting2 = !sorting2;
                      sorting3 = false;
                      ascending2 = sorting2 ? !ascending2 : true;
                      ascending1 = false;
                      ascending3 = false;
                    }
                    // Sorting logic here
                  });
                },
                child: Row(
                  children: [
                    Text("Designation", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 5),
                    ascending2
                        ? Padding(
                      padding: const EdgeInsets.only(top: 7, left: 2),
                      child: FaIcon(
                        FontAwesomeIcons.sortUp,
                        size: 20,
                        color: Colors.white,
                      ),
                    )
                        : Padding(
                      padding: const EdgeInsets.only(bottom: 7, left: 2),
                      child: FaIcon(
                        FontAwesomeIcons.sortDown,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (sorting3) {
                      sorting1 = false;
                      sorting2 = false;
                      sorting3 = sorting3;
                      ascending3 = sorting3 ? !ascending3 : true;
                      ascending2 = false;
                      ascending1 = false;
                    } else {
                      sorting1 = false;
                      sorting2 = false;
                      sorting3 = !sorting3;
                      ascending3 = sorting3 ? !ascending3 : true;
                      ascending2 = false;
                      ascending1 = false;
                    }

                    // Sorting logic here
                  });
                },
                child: Row(
                  children: [
                    Text("   Contact", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 5),
                    ascending3
                        ? Padding(
                      padding: const EdgeInsets.only(top: 7, left: 2),
                      child: FaIcon(
                        FontAwesomeIcons.sortUp,
                        size: 20,
                        color: Colors.white,
                      ),
                    )
                        : Padding(
                      padding: const EdgeInsets.only(bottom: 7, left: 2),
                      child: FaIcon(
                        FontAwesomeIcons.sortDown,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}