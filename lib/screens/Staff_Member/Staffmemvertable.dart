import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/widgets/CustomTableShimmer.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import '../../Model/propertytype.dart';
import '../../constant/constant.dart';
import '../../model/staffmember.dart';
import '../../repository/Property_type.dart';
import '../../repository/Staffmember.dart';
import '../../widgets/drawer_tiles.dart';
import '../Property_Type/Add_property_type.dart';
import 'Add_staffmember.dart';
import 'Edit_staff_member.dart';
import 'package:http/http.dart' as http;
import '../../widgets/custom_drawer.dart';
class _Dessert {
  _Dessert(
    this.name,
    this.property,
    this.subtype,
    this.rentalowenername,
  );

  final String name;
  final String property;
  final String subtype;
  final String rentalowenername;
  bool selected = false;
}

class StaffTable extends StatefulWidget {
  @override
  _StaffTableState createState() => _StaffTableState();
}

class _StaffTableState extends State<StaffTable> {
  late Future<List<Staffmembers>> futureStaffMembers;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  final List<String> roles = ['Manager', 'Employee', 'All'];
  String? selectedRole;
  String searchValue = "";
  int currentPage = 0;
  int itemsPerPage = 10;
  List<int> itemsPerPageOptions = [
    10,
    25,
    50,
    100,
  ];

  late bool isExpanded;
  bool sorting1 = false;
  bool sorting2 = false;
  bool sorting3 = false;
  bool ascending1 = false;
  bool ascending2 = false;
  bool ascending3 = false;

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

  Widget _buildHeaders() {
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Icon(
                Icons.expand_less,
                color: Colors.transparent,
              ),
            ),
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
                        ? Text("Name", style: TextStyle(color: Colors.white))
                        : Text("Name", style: TextStyle(color: Colors.white)),
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

  int? expandedIndex;
  Set<int> expandedIndices = {};

  @override
  void initState() {
    super.initState();
    futureStaffMembers = StaffMemberRepository().fetchStaffmembers();
    fetchstaffadded();
  }

  int totalrecords = 0;
  List<Staffmembers> _tableData = [];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<Staffmembers> get _pagedData {
    int startIndex = _currentPage * _rowsPerPage;
    int endIndex = startIndex + _rowsPerPage;
    return _tableData.sublist(startIndex,
        endIndex > _tableData.length ? _tableData.length : endIndex);
  }

  void _changeRowsPerPage(int selectedRowsPerPage) {
    setState(() {
      _rowsPerPage = selectedRowsPerPage;
      _currentPage = 0; // Reset to the first page when changing rows per page
    });
  }

  void _sort<T>(Comparable<T> Function(Staffmembers d) getField,
      int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _tableData.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        int result;
        if (aValue is String && bValue is String) {
          result = aValue
              .toString()
              .toLowerCase()
              .compareTo(bValue.toString().toLowerCase());
        } else {
          result = aValue.compareTo(bValue as T);
        }
        return _sortAscending ? result : -result;
      });
    });
  }

  void handleEdit(Staffmembers staff) async {
    // Handle edit action
    print('Edit ${staff.sId}');
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Edit_staff_member(
                  staff: staff,
                )));
    if (result == true) {
      setState(() {
        futureStaffMembers = StaffMemberRepository().fetchStaffmembers();
      });
    }
  }

  void _showDeleteAlert(BuildContext context, String id) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this staff member!",
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
            await StaffMemberRepository().DeleteStaffMember(id: id);
            setState(() {
              futureStaffMembers = StaffMemberRepository().fetchStaffmembers();
            });
            fetchstaffadded();
            Navigator.pop(context);
          },
          color: Colors.red,
        ),
      ],
    ).show();
  }

  /* void _sort<T>(Comparable<T> Function(Staffmembers) getField, int columnIndex, bool ascending) {
    futureStaffMembers.then((staffMembers) {
      staffMembers.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
      setState(() {
        sortColumnIndex = columnIndex;
        sortAscending = ascending;
      });
    });
  }
*/
  void handleDelete(Staffmembers staff) {
    _showDeleteAlert(context, staff.staffmemberId!);

    // Handle delete action
    print('Delete ${staff.staffmemberId}');
  }

  final _scrollController = ScrollController();

  int staffCountLimit = 0;
  int rentalCount = 0;
  Future<void> fetchstaffadded() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await http
        .get(Uri.parse('${Api_url}/api/staffmember/limitation/$id'), headers: {
      "authorization": "CRM $token",
      "id": "CRM $id",
    });
    final jsonData = json.decode(response.body);
    print(jsonData);
    if (jsonData["statusCode"] == 200 || jsonData["statusCode"] == 201) {
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
      desc:
          "The limit for adding staffmember according to the plan has been reached.",
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
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer:CustomDrawer(currentpage: "Add Staff Member",dropdown: false,),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () async {
                      print(rentalCount);
                      print(staffCountLimit);
                      // final result = await Navigator.of(context).push(MaterialPageRoute(
                      //     builder: (context) => Add_staffmember()));
                      // if (result == true) {
                      //   setState(() {
                      //     futureStaffMembers = StaffMemberRepository().fetchStaffmembers();
                      //   });
                      // }
                      if (rentalCount < staffCountLimit) {
                        final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => Add_staffmember()));
                        if (result == true) {
                          setState(() {
                            futureStaffMembers =
                                StaffMemberRepository().fetchStaffmembers();
                          });
                          fetchstaffadded();
                        }
                      } else {
                        _showAlertforLimit(context);
                      }
                    },
                    child: Container(
                      // height: 40,
                      height: (MediaQuery.of(context).size.width < 500)
                          ? 40
                          : MediaQuery.of(context).size.width * 0.062,
                      width: (MediaQuery.of(context).size.width < 500)
                          ? MediaQuery.of(context).size.width * 0.35
                          : MediaQuery.of(context).size.width * 0.25,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(21, 43, 81, 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          "Add Staff Member",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width < 500
                                ? 14
                                : 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  if (MediaQuery.of(context).size.width < 500)
                    SizedBox(width: 6),
                  if (MediaQuery.of(context).size.width > 500)
                    SizedBox(width: 22),
                ],
              ),
            ),
            SizedBox(height: 10),
            // Padding(
            //   padding: const EdgeInsets.only(left: 13, right: 13),
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(5.0),
            //     child: Container(
            //       // height: 50.0,
            //       height: (MediaQuery.of(context).size.width < 500) ? 50 : 60,
            //       padding: EdgeInsets.only(top: 12, left: 10),
            //       width: MediaQuery.of(context).size.width * .91,
            //       margin: const EdgeInsets.only(bottom: 6.0),
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(5.0),
            //         color: Color.fromRGBO(21, 43, 81, 1),
            //         boxShadow: [
            //           BoxShadow(
            //             color: Colors.grey,
            //             offset: Offset(0.0, 1.0),
            //             blurRadius: 6.0,
            //           ),
            //         ],
            //       ),
            //       child: Text(
            //         "Staff Members",
            //         style: TextStyle(
            //             color: Colors.white,
            //             fontWeight: FontWeight.bold,
            //             fontSize: MediaQuery.of(context).size.width < 500
            //                 ? 22
            //                 : MediaQuery.of(context).size.width * 0.035),
            //       ),
            //     ),
            //   ),
            // ),
            titleBar(
              width: MediaQuery.of(context).size.width * .91,
              title: 'Staff Members',
            ),
            SizedBox(height: 10),
            //search
            Padding(
              padding: EdgeInsets.only(left: 19, right: 13),
              child: Row(
                children: [
                  if (MediaQuery.of(context).size.width < 500)
                    SizedBox(width: 2),
                  if (MediaQuery.of(context).size.width > 500)
                    SizedBox(width: 19),
                  Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(2),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      // height: 40,
                      height: MediaQuery.of(context).size.width < 500 ? 40 : 50,
                      width: MediaQuery.of(context).size.width < 500
                          ? MediaQuery.of(context).size.width * .45
                          : MediaQuery.of(context).size.width * .4,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: Color(0xFF8A95A8)),
                      ),
                      child: TextField(
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width < 500
                                ? 12
                                : 14),
                        onChanged: (value) {
                          setState(() {
                            searchValue = value;
                          });
                        },
                        cursorColor: Colors.blue,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search here...",
                          hintStyle: TextStyle(
                              color: Color(0xFF8A95A8),
                              fontSize: MediaQuery.of(context).size.width < 500
                                  ? 14
                                  : 18),
                          contentPadding:
                              (EdgeInsets.only(left: 5, bottom: 10, top: 10)),
                        ),
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
                          fontSize:
                              MediaQuery.of(context).size.width < 500 ? 13 : 21,
                        ),
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
                          fontSize:
                              MediaQuery.of(context).size.width < 500 ? 13 : 21,
                        ),
                      ),
                    ],
                  ),
                  if (MediaQuery.of(context).size.width < 500)
                    SizedBox(width: 10),
                  if (MediaQuery.of(context).size.width > 500)
                    SizedBox(width: 25),
                ],
              ),
            ),
            if (MediaQuery.of(context).size.width > 500) SizedBox(height: 25),
            if (MediaQuery.of(context).size.width < 500)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: FutureBuilder<List<Staffmembers>>(
                  future: futureStaffMembers,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ColabShimmerLoadingWidget();
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No data available'));
                    } else {
                      var data = snapshot.data!;
                      if (searchValue == null || searchValue!.isEmpty) {
                        data = snapshot.data!;
                      } else if (searchValue == "All") {
                        data = snapshot.data!;
                      } else if (searchValue!.isNotEmpty) {
                        data = snapshot.data!
                            .where((staff) => staff.staffmemberName!
                                .toLowerCase()
                                .contains(searchValue!.toLowerCase()))
                            .toList();
                      } else {
                        data = snapshot.data!
                            .where(
                                (staff) => staff.staffmemberName == searchValue)
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
                            _buildHeaders(),
                            SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: blueColor)),
                              child: Column(
                                children: currentPageData
                                    .asMap()
                                    .entries
                                    .map((entry) {
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
                                          title: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                InkWell(
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
                                                      if (expandedIndex ==
                                                          index) {
                                                        expandedIndex = null;
                                                      } else {
                                                        expandedIndex = index;
                                                      }
                                                    });
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        left: 5),
                                                    padding: !isExpanded
                                                        ? EdgeInsets.only(
                                                            bottom: 10)
                                                        : EdgeInsets.only(
                                                            top: 10),
                                                    child: FaIcon(
                                                      isExpanded
                                                          ? FontAwesomeIcons
                                                              .sortUp
                                                          : FontAwesomeIcons
                                                              .sortDown,
                                                      size: 20,
                                                      color: Color.fromRGBO(
                                                          21, 43, 83, 1),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    '   ${staffmembers.staffmemberName}',
                                                    style: TextStyle(
                                                      color: blueColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .08),
                                                Expanded(
                                                  child: Text(
                                                    '${staffmembers.staffmemberDesignation}',
                                                    style: TextStyle(
                                                      color: blueColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .08),
                                                Expanded(
                                                  child: Text(
                                                    '${staffmembers.staffmemberPhoneNumber}',
                                                    style: TextStyle(
                                                      color: blueColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .02),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // if (isExpanded)
                                        //   Container(
                                        //     padding: EdgeInsets.symmetric(
                                        //         horizontal: 8.0),
                                        //     margin: EdgeInsets.only(bottom: 20),
                                        //     child: SingleChildScrollView(
                                        //       child: Column(
                                        //         children: [
                                        //           Row(
                                        //             mainAxisAlignment:
                                        //                 MainAxisAlignment.start,
                                        //             children: [
                                        //               FaIcon(
                                        //                 isExpanded
                                        //                     ? FontAwesomeIcons
                                        //                         .sortUp
                                        //                     : FontAwesomeIcons
                                        //                         .sortDown,
                                        //                 size: 50,
                                        //                 color:
                                        //                     Colors.transparent,
                                        //               ),
                                        //               Expanded(
                                        //                 child: Column(
                                        //                   crossAxisAlignment:
                                        //                       CrossAxisAlignment
                                        //                           .start,
                                        //                   children: <Widget>[
                                        //                     Text.rich(
                                        //                       TextSpan(
                                        //                         children: [
                                        //                           TextSpan(
                                        //                             text:
                                        //                                 'Mail-Id : ',
                                        //                             style: TextStyle(
                                        //                                 fontWeight:
                                        //                                     FontWeight
                                        //                                         .bold,
                                        //                                 color:
                                        //                                     blueColor), // Bold and black
                                        //                           ),
                                        //                           TextSpan(
                                        //                             text:
                                        //                                 '${staffmembers.staffmemberEmail}',
                                        //                             style: TextStyle(
                                        //                                 fontWeight:
                                        //                                     FontWeight
                                        //                                         .w700,
                                        //                                 color: Colors
                                        //                                     .grey), // Light and grey
                                        //                           ),
                                        //                         ],
                                        //                       ),
                                        //                     ),
                                        //                     Text.rich(
                                        //                       TextSpan(
                                        //                         children: [
                                        //                           TextSpan(
                                        //                             text:
                                        //                                 'Updated At : ',
                                        //                             style: TextStyle(
                                        //                                 fontWeight:
                                        //                                     FontWeight
                                        //                                         .bold,
                                        //                                 color:
                                        //                                     blueColor), // Bold and black
                                        //                           ),
                                        //                           TextSpan(
                                        //                             text: formatDate(
                                        //                                 '${staffmembers.updatedAt}'),
                                        //                             style: TextStyle(
                                        //                                 fontWeight:
                                        //                                     FontWeight
                                        //                                         .w700,
                                        //                                 color: Colors
                                        //                                     .grey), // Light and grey
                                        //                           ),
                                        //                         ],
                                        //                       ),
                                        //                     ),
                                        //                   ],
                                        //                 ),
                                        //               ),
                                        //               SizedBox(width: 7),
                                        //               Expanded(
                                        //                 child: Column(
                                        //                   crossAxisAlignment:
                                        //                       CrossAxisAlignment
                                        //                           .start,
                                        //                   children: <Widget>[
                                        //                     Text.rich(
                                        //                       TextSpan(
                                        //                         children: [
                                        //                           TextSpan(
                                        //                             text:
                                        //                                 'Created At: ',
                                        //                             style: TextStyle(
                                        //                                 fontWeight:
                                        //                                     FontWeight
                                        //                                         .bold,
                                        //                                 color:
                                        //                                     blueColor), // Bold and black
                                        //                           ),
                                        //                           TextSpan(
                                        //                             text: formatDate(
                                        //                                 '${staffmembers.createdAt}'),
                                        //                             style: TextStyle(
                                        //                                 fontWeight:
                                        //                                     FontWeight
                                        //                                         .w700,
                                        //                                 color: Colors
                                        //                                     .grey), // Light and grey
                                        //                           ),
                                        //                         ],
                                        //                       ),
                                        //                     ),
                                        //                   ],
                                        //                 ),
                                        //               ),
                                        //               Container(
                                        //                 width: 40,
                                        //                 child: Column(
                                        //                   children: [
                                        //                     IconButton(
                                        //                       icon: FaIcon(
                                        //                         FontAwesomeIcons
                                        //                             .edit,
                                        //                         size: 20,
                                        //                         color: Color
                                        //                             .fromRGBO(
                                        //                                 21,
                                        //                                 43,
                                        //                                 83,
                                        //                                 1),
                                        //                       ),
                                        //                       onPressed:
                                        //                           () async {
                                        //                         // handleEdit(Propertytype);
                                        //
                                        //                         var check = await Navigator.push(
                                        //                             context,
                                        //                             MaterialPageRoute(
                                        //                                 builder: (context) => Edit_staff_member(
                                        //                                       staff: staffmembers,
                                        //                                     )));
                                        //                         if (check ==
                                        //                             true) {
                                        //                           setState(
                                        //                               () {});
                                        //                         }
                                        //                       },
                                        //                     ),
                                        //                     IconButton(
                                        //                       icon: FaIcon(
                                        //                         FontAwesomeIcons
                                        //                             .trashCan,
                                        //                         size: 20,
                                        //                         color: Color
                                        //                             .fromRGBO(
                                        //                                 21,
                                        //                                 43,
                                        //                                 83,
                                        //                                 1),
                                        //                       ),
                                        //                       onPressed: () {
                                        //                         //handleDelete(Propertytype);
                                        //                         _showDeleteAlert(
                                        //                             context,
                                        //                             staffmembers
                                        //                                 .staffmemberId!);
                                        //                       },
                                        //                     ),
                                        //                   ],
                                        //                 ),
                                        //               ),
                                        //             ],
                                        //           ),
                                        //         ],
                                        //       ),
                                        //     ),
                                        //   ),
                                        //SizedBox(height: 13,),
                                        if (isExpanded)
                                          Container(
                                            padding: EdgeInsets.only(left: 2,right: 2),
                                            margin: EdgeInsets.only(bottom: 20),
                                            child: SingleChildScrollView(
                                              child: Container(
                                                //color: Colors.blue,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment.start,
                                                            children: [
                                                              FaIcon(
                                                                isExpanded
                                                                    ? FontAwesomeIcons
                                                                        .sortUp
                                                                    : FontAwesomeIcons
                                                                        .sortDown,
                                                                size: 50,
                                                                color:
                                                                    Colors.transparent,
                                                              ),
                                                ],
                                              ),
                                                    Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text.rich(
                                                          TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: 'Mail-Id: ',
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: blueColor, // Bold and blue
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text: '${staffmembers.staffmemberEmail}',
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.w700,
                                                                  color: Colors.grey, // Light and grey
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                5),
                                                        Text.rich(
                                                          TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: 'Created At: ',
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: blueColor, // Bold and blue
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text: formatDate('${staffmembers.createdAt}'),
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.w700,
                                                                  color: Colors.grey, // Light and grey
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                            5),
                                                        Text.rich(
                                                          TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: 'Updated At: ',
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: blueColor, // Bold and blue
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text: formatDate('${staffmembers.updatedAt}'),
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.w700,
                                                                  color: Colors.grey, // Light and grey
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Spacer(),
                                                    Container(
                                                      width: 40,
                                                      child: Column(
                                                        children: [
                                                          IconButton(
                                                            icon: FaIcon(
                                                              FontAwesomeIcons.edit,
                                                              size: 20,
                                                              color: Color.fromRGBO(21, 43, 83, 1),
                                                            ),
                                                            onPressed: () async {
                                                              var check = await Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => Edit_staff_member(
                                                                    staff: staffmembers,
                                                                  ),
                                                                ),
                                                              );
                                                              if (check == true) {
                                                                setState(() {});
                                                              }
                                                            },
                                                          ),
                                                          IconButton(
                                                            icon: FaIcon(
                                                              FontAwesomeIcons.trashCan,
                                                              size: 20,
                                                              color: Color.fromRGBO(21, 43, 83, 1),
                                                            ),
                                                            onPressed: () {
                                                              _showDeleteAlert(context, staffmembers.staffmemberId!);
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(width: 5),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
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
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12.0),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<int>(
                                            value: itemsPerPage,
                                            items: itemsPerPageOptions
                                                .map((int value) {
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
                                    Text(
                                        'Page ${currentPage + 1} of $totalPages'),
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
            if (MediaQuery.of(context).size.width > 500)
              FutureBuilder<List<Staffmembers>>(
                future: futureStaffMembers,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ShimmerTabletTable();
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data available'));
                  } else {
                    List<Staffmembers>? filteredData = [];
                    if (selectedRole == null && searchValue == "") {
                      filteredData = snapshot.data;
                    } else if (selectedRole == "All") {
                      filteredData = snapshot.data;
                    } else if (searchValue.isNotEmpty) {
                      filteredData = snapshot.data!
                          .where((staff) =>
                              staff.staffmemberName!
                                  .toLowerCase()
                                  .contains(searchValue.toLowerCase()) ||
                              staff.staffmemberDesignation!
                                  .toLowerCase()
                                  .contains(searchValue.toLowerCase()))
                          .toList();
                    } else {
                      filteredData = snapshot.data!
                          .where((staff) =>
                              staff.staffmemberDesignation == selectedRole)
                          .toList();
                    }
                    //_tableData = snapshot.data!;
                    // _tableData = snapshot.data!;
                    _tableData = filteredData!;
                    totalrecords = _tableData.length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 5),
                      child: Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              width: MediaQuery.of(context).size.width * .91,
                              child: Table(
                                defaultColumnWidth: IntrinsicColumnWidth(),
                                children: [
                                  TableRow(
                                    decoration:
                                        BoxDecoration(border: Border.all()),
                                    children: [
                                      _buildHeader('Name', 0,
                                          (staff) => staff.staffmemberName!),
                                      _buildHeader(
                                          'Role',
                                          1,
                                          (staff) =>
                                              staff.staffmemberDesignation!),
                                      _buildHeader('Email', 2, null),
                                      _buildHeader('Phone', 3, null),
                                      _buildHeader('Actions', 4, null),
                                    ],
                                  ),
                                  TableRow(
                                    decoration: BoxDecoration(
                                      border: Border.symmetric(
                                          horizontal: BorderSide.none),
                                    ),
                                    children: List.generate(
                                        5,
                                        (index) => TableCell(
                                            child: Container(height: 20))),
                                  ),
                                  for (var i = 0; i < _pagedData.length; i++)
                                    TableRow(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(
                                              color: Color.fromRGBO(
                                                  21, 43, 81, 1)),
                                          right: BorderSide(
                                              color: Color.fromRGBO(
                                                  21, 43, 81, 1)),
                                          top: BorderSide(
                                              color: Color.fromRGBO(
                                                  21, 43, 81, 1)),
                                          bottom: i == _pagedData.length - 1
                                              ? BorderSide(
                                                  color: Color.fromRGBO(
                                                      21, 43, 81, 1))
                                              : BorderSide.none,
                                        ),
                                      ),
                                      children: [
                                        _buildDataCell(
                                            _pagedData[i].staffmemberName!),
                                        _buildDataCell(_pagedData[i]
                                            .staffmemberDesignation!),
                                        _buildDataCell(
                                            _pagedData[i].staffmemberEmail!),
                                        _buildDataCell(_pagedData[i]
                                            .staffmemberPhoneNumber!),
                                        _buildActionsCell(_pagedData[i]),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 25),
                          _buildPaginationControls(),
                        ],
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(Staffmembers d)? getField) {
    return TableCell(
      child: InkWell(
        onTap: getField != null
            ? () {
                _sort(getField, columnIndex, !_sortAscending);
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              Text(text,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              if (_sortColumnIndex == columnIndex)
                Icon(_sortAscending
                    ? Icons.arrow_drop_down_outlined
                    : Icons.arrow_drop_up_outlined),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 16),
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildActionsCell(Staffmembers data) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          height: 50,
          // color: Colors.blue,
          child: Row(
            children: [
              const SizedBox(
                width: 20,
              ),
              InkWell(
                onTap: () {
                  handleEdit(data);
                },
                child: const FaIcon(
                  FontAwesomeIcons.edit,
                  size: 30,
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              InkWell(
                onTap: () {
                  handleDelete(data);
                },
                child: const FaIcon(
                  FontAwesomeIcons.trashCan,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    int numorpages = 1;
    numorpages = (totalrecords / _rowsPerPage).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Text('Rows per page: '),
        // SizedBox(width: 10),
        Material(
          elevation: 2,
          color: Colors.white,
          child: Container(
            height: 55,
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _rowsPerPage,
                items: [10, 25, 50, 100].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    _changeRowsPerPage(newValue);
                  }
                },
                icon: Icon(
                  Icons.arrow_drop_down,
                  size: 40,
                ),
                style: TextStyle(color: Colors.black, fontSize: 17),
                dropdownColor: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.circleChevronLeft,
            size: 30,
            color:
                _currentPage == 0 ? Colors.grey : Color.fromRGBO(21, 43, 83, 1),
          ),
          onPressed: _currentPage == 0
              ? null
              : () {
                  setState(() {
                    _currentPage--;
                  });
                },
        ),
        Text(
          'Page ${_currentPage + 1} of $numorpages',
          style: TextStyle(fontSize: 18),
        ),
        IconButton(
          icon: FaIcon(
            size: 30,
            FontAwesomeIcons.circleChevronRight,
            color: (_currentPage + 1) * _rowsPerPage >= _tableData.length
                ? Colors.grey
                : Color.fromRGBO(
                    21, 43, 83, 1), // Change color based on availability
          ),
          onPressed: (_currentPage + 1) * _rowsPerPage >= _tableData.length
              ? null
              : () {
                  setState(() {
                    _currentPage++;
                  });
                },
        ),
      ],
    );
  }
}

void main() => runApp(MaterialApp(home: StaffTable()));
