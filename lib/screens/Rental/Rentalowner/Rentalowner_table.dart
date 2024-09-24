import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/screens/Rental/Rentalowner/Edit_RentalOwners.dart';
import 'package:three_zero_two_property/screens/Rental/Rentalowner/rentalowner_summery.dart';
import 'package:three_zero_two_property/widgets/CustomTableShimmer.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

import '../../../Model/RentalOwnersData.dart';
import '../../../constant/constant.dart';
import '../../../model/rentalOwner.dart';
import '../../../model/rentalowners_summery.dart';
import '../../../model/staffmember.dart';
import '../../../repository/Rental_ownersData.dart';
import '../../../repository/Staffmember.dart';
import '../../../repository/rentalowner.dart';
import '../../../widgets/drawer_tiles.dart';
import '../../Staff_Member/Add_staffmember.dart';
import '../../Staff_Member/Edit_staff_member.dart';
import 'Add_RentalOwners.dart';
import 'package:http/http.dart' as http;
import '../../../widgets/custom_drawer.dart';

class Rentalowner_table extends StatefulWidget {
  // RentalOwner? rentalownersummery;
  // Rentalowner_table({super.key,this.rentalownersummery});

  @override
  State<Rentalowner_table> createState() => _Rentalowner_tableState();
}

class _Rentalowner_tableState extends State<Rentalowner_table> {
  late Future<List<RentalOwnerData>> futureRentalOwners;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  final List<String> roles = ['Manager', 'Employee', 'All'];
  String? selectedRole;
  String searchValue = "";
  int currentPage = 0;
  int itemsPerPage = 10;
  int? expandedIndex;
  Set<int> expandedIndices = {};

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

  void sortData(List<RentalOwnerData> data) {
    if (sorting1) {
      data.sort((a, b) => ascending1
          ? a.rentalOwnername!.compareTo(b.rentalOwnername!)
          : b.rentalOwnername!.compareTo(a.rentalOwnername!));
    } else if (sorting2) {
      data.sort((a, b) => ascending2
          ? a.rentalOwnerPhoneNumber!.compareTo(b.rentalOwnerPhoneNumber!)
          : b.rentalOwnerPhoneNumber!.compareTo(a.rentalOwnerPhoneNumber!));
    } else if (sorting3) {
      data.sort((a, b) => ascending3
          ? a.rentalOwnerPrimaryEmail!.compareTo(b.rentalOwnerPrimaryEmail!)
          : b.rentalOwnerPrimaryEmail!.compareTo(a.rentalOwnerPrimaryEmail!));
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
              flex: 3,
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
                            style: TextStyle(color: Colors.white, fontSize: 18))
                        : Text("Name",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
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
              flex: 3,
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
                    SizedBox(width: 15),
                    Text("Phone",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
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
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    futureRentalOwners = RentalOwnerService().fetchRentalOwners("");

    fetchRentalOwneradded();
  }

  List<RentalOwnerData> _tableData = [];
  int totalrecords = 0;
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<RentalOwnerData> get _pagedData {
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

  void _sort<T>(Comparable<T> Function(RentalOwnerData d) getField,
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

  void handleEdit(RentalOwnerData rentalOwner) async {
    // Handle edit action
    print('Edit ${rentalOwner.rentalownerId}');
    var check = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Edit_rentalowners(
                  rentalOwner: rentalOwner,
                )));
    if (check == true) {
      setState(() {});
    }
    // final result = await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => Edit_rentalowners(rentalOwner: rentalOwner,)));
    /* if (result == true) {
      setState(() {
        futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
      });
    }*/
  }

  void _showDeleteAlert(BuildContext context, String id) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this RentalOwner!",
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
            await RentalOwnerService().DeleteRentalOwners(rentalownerId: id);
            setState(() {
              futureRentalOwners = RentalOwnerService().fetchRentalOwners("");
            });
            fetchRentalOwneradded();
            Navigator.pop(context);
          },
          color: Colors.red,
        ),
      ],
    ).show();
  }

  void handleDelete(RentalOwnerData rental) {
    _showDeleteAlert(context, rental.rentalownerId!);
    // Handle delete action
    print('Delete ${rental.rentalownerId}');
  }

  final _scrollController = ScrollController();
  void handleTap(RentalOwnerData rental) async {
    // Handle edit action
    print('Edit ${rental.rentalownerId}');
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ResponsiveRentalSummary(
                  rentalowners: rental,
                  rentalOwnersid: '',
                )));
    /* if (result == true) {
      setState(() {
        futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
      });
    }*/
  }

  String? rentalOwnersid;
  int rentalownerCount = 0;
  int rentalOwnerCountLimit = 0;
  Future<void> fetchRentalOwneradded() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${Api_url}/api/rental_owner/limitation/$id'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    final jsonData = json.decode(response.body);
    print(jsonData);
    if (jsonData["statusCode"] == 200 || jsonData["statusCode"] == 201) {
      print(rentalownerCount);
      print(rentalOwnerCountLimit);
      setState(() {
        rentalownerCount = jsonData['rentalownerCount'];
        print(rentalownerCount);
        rentalOwnerCountLimit = jsonData['rentalOwnerCountLimit'];
        print(rentalOwnerCountLimit);
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
          "The limit for adding rentalowners according to the plan has been reached.",
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
      drawer: CustomDrawer(
        currentpage: "RentalOwner",
        dropdown: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(0),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: titleBar(
                      width: MediaQuery.of(context).size.width * .65,
                      title: 'Rental Owner',
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (rentalownerCount < rentalOwnerCountLimit) {
                        final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => Add_rentalowners()));
                        if (result == true) {
                          setState(() {
                            futureRentalOwners =
                                RentalOwnerService().fetchRentalOwners("");
                            //  futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
                          });
                          fetchRentalOwneradded();
                        }
                      } else {
                        _showAlertforLimit(context);
                      }
                    },
                    child: Container(
                      height: (MediaQuery.of(context).size.width < 500)
                          ? 50
                          : MediaQuery.of(context).size.width * 0.065,
                      width: (MediaQuery.of(context).size.width < 500)
                          ? MediaQuery.of(context).size.width * 0.25
                          : MediaQuery.of(context).size.width * 0.25,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(21, 43, 81, 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          "+ Add",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width < 500
                                ? 16
                                : 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (MediaQuery.of(context).size.width < 500)
                    SizedBox(width: 6),
                  if (MediaQuery.of(context).size.width > 500)
                    SizedBox(width: 22),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 11, right: 11),
              child: Row(
                children: [
                  if (MediaQuery.of(context).size.width < 500)
                    SizedBox(width: 2),
                  if (MediaQuery.of(context).size.width > 500)
                    SizedBox(width: 19),
                  Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height:
                          (MediaQuery.of(context).size.width < 500) ? 45 : 50,
                      width: MediaQuery.of(context).size.width < 500
                          ? MediaQuery.of(context).size.width * .52
                          : MediaQuery.of(context).size.width * .49,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
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
                              (EdgeInsets.only(left: 8, bottom: 13, top: 5)),
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Text(
                        'Added : ${rentalownerCount.toString()}',
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
                        'Total: ${rentalOwnerCountLimit.toString()}',
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
                    SizedBox(width: 5),
                  if (MediaQuery.of(context).size.width > 500)
                    SizedBox(width: 25),
                ],
              ),
            ),
            if (MediaQuery.of(context).size.width > 500) SizedBox(height: 25),
            if (MediaQuery.of(context).size.width < 500)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: FutureBuilder<List<RentalOwnerData>>(
                  future: futureRentalOwners,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ColabShimmerLoadingWidget();
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Container(
                        height: MediaQuery.of(context).size.height * .5,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/no_data.jpg",
                                height: 200,
                                width: 200,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "No Data Available",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: blueColor,
                                    fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      );
                    } else {
                      var data = snapshot.data!;
                      if (searchValue == null || searchValue!.isEmpty) {
                        data = snapshot.data!;
                      } else if (searchValue == "All") {
                        data = snapshot.data!;
                      } else if (searchValue!.isNotEmpty) {
                        data = snapshot.data!
                            .where((rentals) => rentals.rentalOwnername!
                                .toLowerCase()
                                .contains(searchValue!.toLowerCase()))
                            .toList();
                      } else {
                        data = snapshot.data!
                            .where((rentals) =>
                                rentals.rentalOwnername == searchValue)
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
                            SizedBox(height: 10),
                            _buildHeaders(),
                            SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          Color.fromRGBO(152, 162, 179, .5))),
                              // decoration: BoxDecoration(
                              //     border: Border.all(color: blueColor)),
                              child: Column(
                                children: currentPageData
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  bool isExpanded = expandedIndex == index;
                                  RentalOwnerData rentals = entry.value;
                                  //return CustomExpansionTile(data: Propertytype, index: index);
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: index % 2 != 0
                                          ? Colors.white
                                          : blueColor.withOpacity(0.09),
                                      border: Border.all(
                                          color: Color.fromRGBO(
                                              152, 162, 179, .5)),
                                    ),
                                    // decoration: BoxDecoration(
                                    //   border: Border.all(color: blueColor),
                                    // ),
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
                                                        left: 5, right: 5),
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
                                                  flex: 3,
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        if (expandedIndex ==
                                                            index) {
                                                          expandedIndex = null;
                                                        } else {
                                                          expandedIndex = index;
                                                        }
                                                      });
                                                    },
                                                    child: Text(
                                                      '${rentals.rentalOwnername}',
                                                      style: TextStyle(
                                                        color: blueColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
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
                                                  flex: 3,
                                                  child: Text(
                                                    '${rentals.rentalOwnerPhoneNumber}',
                                                    style: TextStyle(
                                                      color: blueColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (isExpanded)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 2),
                                            margin: EdgeInsets.only(bottom: 2),
                                            child: SingleChildScrollView(
                                              child: Column(
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
                                                        size: 40,
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        'Primery E-mail: ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color:
                                                                            blueColor), // Bold and black
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        '${rentals.rentalOwnerPrimaryEmail}',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w700,
                                                                        color:
                                                                            grey), // Light and grey
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  .01,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            var check = await Navigator
                                                                .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            Edit_rentalowners(
                                                                              rentalOwner: rentals,
                                                                            )));
                                                            if (check == true) {
                                                              setState(() {});
                                                            }
                                                          },
                                                          child: Container(
                                                            height: 40,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                        .grey[
                                                                    350]), // color:Colors.grey[100],
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                FaIcon(
                                                                  FontAwesomeIcons
                                                                      .edit,
                                                                  size: 15,
                                                                  color:
                                                                      blueColor,
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  "Edit",
                                                                  style: TextStyle(
                                                                      color:
                                                                          blueColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
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
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            _showDeleteAlert(
                                                                context,
                                                                rentals
                                                                    .rentalownerId!);
                                                          },
                                                          child: Container(
                                                            height: 40,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                            .grey[
                                                                        350]),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                FaIcon(
                                                                  FontAwesomeIcons
                                                                      .trashCan,
                                                                  size: 15,
                                                                  color:
                                                                      blueColor,
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  "Delete",
                                                                  style: TextStyle(
                                                                      color:
                                                                          blueColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            ResponsiveRentalSummary(
                                                                              rentalOwnersid: rentals.rentalownerId!,
                                                                              rentalowners: rentals,
                                                                            )));
                                                          },
                                                          child: Container(
                                                            height: 40,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                            .grey[
                                                                        350]),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Image.asset(
                                                                    'assets/icons/view.png'),
                                                                // FaIcon(
                                                                //   FontAwesomeIcons.trashCan,
                                                                //   size: 15,
                                                                //   color:blueColor,
                                                                // ),
                                                                SizedBox(
                                                                  width: 8,
                                                                ),
                                                                Text(
                                                                  "View Summery",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color:
                                                                          blueColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                )
                                                              ],
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
                                            onChanged: data.length >
                                                    itemsPerPageOptions
                                                        .first // Condition to check if dropdown should be enabled
                                                ? (newValue) {
                                                    setState(() {
                                                      itemsPerPage = newValue!;
                                                      currentPage =
                                                          0; // Reset to first page when items per page change
                                                    });
                                                  }
                                                : null,
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
              FutureBuilder<List<RentalOwnerData>>(
                future: futureRentalOwners,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ShimmerTabletTable();
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Container(
                      height: MediaQuery.of(context).size.height * .5,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/no_data.jpg",
                              height: 200,
                              width: 200,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "No Data Available",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: blueColor,
                                  fontSize: 16),
                            )
                          ],
                        ),
                      ),
                    );
                  } else {
                    List<RentalOwnerData>? filteredData = [];
                    _tableData = snapshot.data!;
                    if (selectedRole == null && searchValue == "") {
                      filteredData = snapshot.data;
                    } else if (selectedRole == "All") {
                      filteredData = snapshot.data;
                    } else if (searchValue.isNotEmpty) {
                      filteredData = snapshot.data!
                          .where((staff) =>
                              staff.rentalOwnername!
                                  .toLowerCase()
                                  .contains(searchValue.toLowerCase()) ||
                              staff.rentalOwnername!
                                  .toLowerCase()
                                  .contains(searchValue.toLowerCase()))
                          .toList();
                    }
                    _tableData = filteredData!;
                    totalrecords = _tableData.length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                                      // TableCell(child: Text('yash')),
                                      // TableCell(child: Text('yash')),
                                      // TableCell(child: Text('yash')),
                                      // TableCell(child: Text('yash')),
                                      _buildHeader('Name', 0,
                                          (rental) => rental.rentalOwnername!),
                                      _buildHeader(
                                          'Phone',
                                          1,
                                          (rental) =>
                                              rental.rentalOwnerPhoneNumber!),
                                      _buildHeader(
                                          'Email',
                                          2,
                                          (rental) =>
                                              rental.rentalOwnerPrimaryEmail!),
                                      _buildHeader('Actions', 3, null),
                                    ],
                                  ),
                                  TableRow(
                                    decoration: BoxDecoration(
                                      border: Border.symmetric(
                                          horizontal: BorderSide.none),
                                    ),
                                    children: List.generate(
                                        4,
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
                                            _pagedData[i].rentalOwnername ?? "",
                                            _pagedData[i].rentalownerId!),
                                        // _buildDataCell('${_pagedData[i].rentalOwnerFirstName ?? ''} ${_pagedData[i].rentalOwnerLastName ?? ''}'),
                                        _buildDataCell(
                                            _pagedData[i]
                                                .rentalOwnerPhoneNumber!,
                                            _pagedData[i].rentalownerId!),
                                        _buildDataCell(
                                            _pagedData[i]
                                                .rentalOwnerPrimaryEmail!,
                                            _pagedData[i].rentalownerId!),

                                        // TableCell(child: Text('yash')),
                                        // TableCell(child: Text('yash')),
                                        // TableCell(child: Text('yash')),

                                        _buildActionsCell(_pagedData[i]),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (_tableData.isEmpty)
                            Text("No Search Records Found"),
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
      Comparable<T> Function(RentalOwnerData d)? getField) {
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

  Widget _buildDataCell(String text, String inkText) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 16),
        child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ResponsiveRentalSummary(
                            rentalOwnersid: inkText,
                          )));
            },
            child: Text(text, style: const TextStyle(fontSize: 18))),
      ),
    );
  }

  Widget _buildActionsCell(RentalOwnerData data) {
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
                items: [10, 2, 5, 1].map((int value) {
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
            size: 30,
            FontAwesomeIcons.circleChevronLeft,
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
