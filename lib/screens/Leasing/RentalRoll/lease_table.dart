import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/repository/lease.dart';
import 'package:three_zero_two_property/screens/Leasing/RentalRoll/SummeryPageLease.dart';
import 'package:three_zero_two_property/screens/Leasing/RentalRoll/edit_lease.dart';
import 'package:three_zero_two_property/screens/Rental/Rentalowner/Edit_RentalOwners.dart';
import 'package:three_zero_two_property/screens/Rental/Rentalowner/rentalowner_summery.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

import '../../../Model/RentalOwnersData.dart';
import '../../../constant/constant.dart';
import '../../../model/get_lease.dart';
import '../../../model/rentalOwner.dart';
import '../../../model/rentalowners_summery.dart';
import '../../../model/staffmember.dart';
import '../../../provider/lease_provider.dart';
import '../../../repository/Rental_ownersData.dart';
import '../../../repository/Staffmember.dart';
import '../../../repository/rentalowner.dart';
import '../../../widgets/drawer_tiles.dart';
import '../../Staff_Member/Add_staffmember.dart';
import '../../Staff_Member/Edit_staff_member.dart';

import 'package:http/http.dart' as http;

import 'newAddLease.dart';

class Lease_table extends StatefulWidget {
  // RentalOwner? rentalownersummery;
  // Lease_table({super.key,this.rentalownersummery});

  @override
  State<Lease_table> createState() => _Lease_tableState();
}

class _Lease_tableState extends State<Lease_table> {
  late Future<List<Lease1>> futureLease;
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

  void sortData(List<Lease1> data) {
    if (sorting1) {
      data.sort((a, b) => ascending1
          ? a.tenantNames!.compareTo(b.tenantNames!)
          : b.tenantNames!.compareTo(a.tenantNames!));
    } else if (sorting2) {
      data.sort((a, b) => ascending2
          ? a.startDate!.compareTo(b.startDate!)
          : b.startDate!.compareTo(a.startDate!));
    } else if (sorting3) {
      data.sort((a, b) => ascending3
          ? a.endDate!.compareTo(b.endDate!)
          : b.endDate!.compareTo(a.endDate!));
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
                        ? Text("Lease", style: TextStyle(color: Colors.white))
                        : Text("Lease", style: TextStyle(color: Colors.white)),
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
              flex: 2,
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
                    Text("Lease Start",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width < 350
                              ? 12.0
                              : 14.0,
                        )),
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
              flex: 2,
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
                    Text("  Lease End",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width < 350
                              ? 12.0
                              : 14.0,
                        )),
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

  @override
  void initState() {
    super.initState();
    futureLease = LeaseRepository().fetchLease("");

    fetchLeaseadded();
  }

  List<Lease1> _tableData = [];
  int totalrecords = 0;
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<Lease1> get _pagedData {
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

  void _sort<T>(Comparable<T> Function(Lease1 d) getField, int columnIndex,
      bool ascending) {
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

  void handleEdit(Lease1 lease) async {
    // Handle edit action
    print('Edit ${lease.leaseId}');
    var check = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Edit_lease(
                  lease: lease,
                  leaseId: lease.leaseId!,
                )));
    if (check == true) {
      setState(() {});
    }
    //this above is used
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
            await LeaseRepository()
                .deleteLease(leaseId: id, companyName: companyName);
            setState(() {
              futureLease = LeaseRepository().fetchLease("");
            });
            Navigator.pop(context);
          },
          color: Colors.red,
        ),
      ],
    ).show();
  }

  String companyName = '';
  Future<void> fetchCompany() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");

    if (adminId != null) {
      try {
        String fetchedCompanyName =
            await LeaseRepository().fetchCompanyName(adminId);
        setState(() {
          companyName = fetchedCompanyName;
        });
      } catch (e) {
        print('Failed to fetch company name: $e');
        // Handle error state, e.g., show error message to user
      }
    }
  }

  void handleDelete(Lease1 lease) {
    _showDeleteAlert(context, lease.leaseId!);
    // Handle delete action
    print('Delete ${lease.leaseId}');
  }

  final _scrollController = ScrollController();
  void handleTap(RentalOwnerSummey rentalownersummery) async {
    // Handle edit action
    print('Edit ${rentalownersummery.rentalownerId}');
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Rentalowners_summery(
                  rentalOwnersid: '',
                )));
    /* if (result == true) {
      setState(() {
        futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
      });
    }*/
  }

  String? rentalOwnersid;
  int leaseCount = 0;
  int leaseCountLimit = 0;
  Future<void> fetchLeaseadded() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await http
        .get(Uri.parse('${Api_url}/api/leases/limitation/$id'), headers: {
      "authorization": "CRM $token",
      "id": "CRM $id",
    });
    final jsonData = json.decode(response.body);
    print(jsonData);
    if (jsonData["statusCode"] == 200 || jsonData["statusCode"] == 201) {
      print(leaseCount);
      print(leaseCountLimit);
      setState(() {
        leaseCount = jsonData['leaseCount'];
        print(leaseCount);
        leaseCountLimit = jsonData['leaseCountLimit'];
        print(leaseCountLimit);
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
                  selectedSubtopic: "Rent Roll"),
              buildDropdownListTile(
                  context,
                  FaIcon(
                    FontAwesomeIcons.thumbsUp,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Leasing",
                  ["Rent Roll", "Applicants"],
                  selectedSubtopic: "Rent Roll"),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"],
                  selectedSubtopic: "Rent Roll"),
              buildListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.letterboxd,
                    color: Colors.black,
                  ),
                  "Reports",
                  false),
            ],
          ),
        ),
      ),
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
                      Provider.of<SelectedTenantsProvider>(context,
                              listen: false)
                          .clearTenant();
                      Provider.of<SelectedCosignersProvider>(context,
                              listen: false)
                          .clearCosigner();
                      if (leaseCount < leaseCountLimit) {
                        final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => addLease3()));
                        if (result == true) {
                          setState(() {
                            futureLease = LeaseRepository().fetchLease("");
                            //  futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
                          });
                        }
                      } else {
                        _showAlertforLimit(context);
                      }
                    },
                    child: Container(
                      height: (MediaQuery.of(context).size.width < 500)
                          ? 40
                          : MediaQuery.of(context).size.width * 0.065,
                      width: MediaQuery.of(context).size.width * 0.5,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(21, 43, 81, 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          "Add Lease",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.034,
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
            // Padding(
            //   padding: const EdgeInsets.only(left: 13,right: 13),
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(5.0),
            //     child: Container(
            //       height: (MediaQuery.of(context).size.width < 500) ?
            //       50 :60,
            //       padding: EdgeInsets.only(top: 8, left: 10),
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
            //         "Rental Owner",
            //         style: TextStyle(
            //             color: Colors.white,
            //             fontWeight: FontWeight.bold,
            //           fontSize: MediaQuery.of(context).size.width < 500 ?22 : MediaQuery.of(context).size.width * 0.035,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            titleBar(
              width: MediaQuery.of(context).size.width * .91,
              title: 'RentRoll',
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 19, right: 13),
              child: Row(
                children: [
                  if (MediaQuery.of(context).size.width < 500)
                    SizedBox(width: 2),
                  if (MediaQuery.of(context).size.width > 500)
                    SizedBox(width: 22),
                  Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(2),
                    child: Container(
                      height:
                          (MediaQuery.of(context).size.width < 500) ? 40 : 50,
                      width: MediaQuery.of(context).size.width < 500
                          ? MediaQuery.of(context).size.width * .52
                          : MediaQuery.of(context).size.width * .49,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: Color(0xFF8A95A8)),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchValue = value;
                          });
                        },
                        cursorColor: Colors.blue,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search here...",
                          hintStyle: TextStyle(color: Color(0xFF8A95A8)),
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Text(
                        'Added : ${leaseCount.toString()}',
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
                        'Total: ${leaseCountLimit.toString()}',
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
                child: FutureBuilder<List<Lease1>>(
                  future: futureLease,
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
                    } else {
                      var data = snapshot.data!;
                      if (searchValue == null || searchValue!.isEmpty) {
                        data = snapshot.data!;
                      } else if (searchValue == "All") {
                        data = snapshot.data!;
                      } else if (searchValue!.isNotEmpty) {
                        data = snapshot.data!
                            .where((lease) =>
                                lease.rentalAddress!
                                    .toLowerCase()
                                    .contains(searchValue!.toLowerCase()) ||
                                lease.tenantNames!
                                    .toLowerCase()
                                    .contains(searchValue!.toLowerCase()))
                            .toList();
                      } else {
                        data = snapshot.data!
                            .where((lease) => lease.tenantNames == searchValue)
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
                                  Lease1 lease = entry.value;
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
                                                  flex:
                                                      4, // Larger size for the first field
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    SummeryPageLease(
                                                                        leaseId:
                                                                            lease.leaseId!)));
                                                      },
                                                      child: Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  ' ${lease.rentalAddress} \n',
                                                              style: TextStyle(
                                                                color:
                                                                    blueColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: lease
                                                                  .tenantNames,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .lightBlue, // Light blue color for tenant names
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
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
                                                  flex:
                                                      2, // Smaller size for the second field
                                                  child: Text(
                                                    formatDate(
                                                        '${lease.startDate}'),
                                                    style: TextStyle(
                                                      color: blueColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
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
                                                  flex:
                                                      2, // Smaller size for the third field
                                                  child: Text(
                                                    formatDate(
                                                        '${lease.endDate}'),
                                                    style: TextStyle(
                                                      color: blueColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
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
                                        if (isExpanded)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.0),
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
                                                            ? FontAwesomeIcons
                                                                .sortUp
                                                            : FontAwesomeIcons
                                                                .sortDown,
                                                        size: 50,
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .08),
                                                            Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        'Rent Cycle: ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color:
                                                                            blueColor), // Bold and black
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        '${lease.rentCycle ?? ''}',
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
                                                            SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  .01,
                                                            ),
                                                            Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        'Rent Start: ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color:
                                                                            blueColor), // Bold and black
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        '${lease.rentDueDate}',
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
                                                            SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  .01,
                                                            ),
                                                            Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        'Rent',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color:
                                                                            blueColor), // Bold and black
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        '${lease.amount}',
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
                                                            SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  .01,
                                                            ),
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
                                                                    text: formatDate(
                                                                        '${lease.createdAt}'),
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
                                                      SizedBox(width: 5),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  .01,
                                                            ),
                                                            Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        'Deposit Held ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color:
                                                                            blueColor), // Bold and black
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        '${lease.deposit}',
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
                                                            SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  .01,
                                                            ),
                                                            Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        'Charges: ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color:
                                                                            blueColor), // Bold and black
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        '${lease.recurringCharge}',
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
                                                            SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  .01,
                                                            ),
                                                            Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        'Updated At: ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color:
                                                                            blueColor), // Bold and black
                                                                  ),
                                                                  TextSpan(
                                                                    text: formatDate(
                                                                        '${lease.updatedAt}'),
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
                                                      Container(
                                                        width: 40,
                                                        child: Column(
                                                          children: [
                                                            IconButton(
                                                              icon: FaIcon(
                                                                FontAwesomeIcons
                                                                    .edit,
                                                                size: 20,
                                                                color: Color
                                                                    .fromRGBO(
                                                                        21,
                                                                        43,
                                                                        83,
                                                                        1),
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                Provider.of<SelectedCosignersProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .clearCosigner();
                                                                Provider.of<SelectedTenantsProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .clearTenant();
                                                                // handleEdit(Propertytype);
                                                                var check = await Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => Edit_lease(
                                                                              lease: lease,
                                                                              leaseId: lease.leaseId!,
                                                                            )));
                                                                if (check ==
                                                                    true) {
                                                                  setState(
                                                                      () {});
                                                                }
                                                              },
                                                            ),
                                                            IconButton(
                                                              icon: FaIcon(
                                                                FontAwesomeIcons
                                                                    .trashCan,
                                                                size: 20,
                                                                color: Color
                                                                    .fromRGBO(
                                                                        21,
                                                                        43,
                                                                        83,
                                                                        1),
                                                              ),
                                                              onPressed: () {
                                                                //handleDelete(Propertytype);
                                                                _showDeleteAlert(
                                                                    context,
                                                                    lease
                                                                        .leaseId!);
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
              FutureBuilder<List<Lease1>>(
                future: futureLease,
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
                  } else {
                    List<Lease1>? filteredData = [];
                    _tableData = snapshot.data!;
                    if (selectedRole == null && searchValue == "") {
                      filteredData = snapshot.data;
                    } else if (selectedRole == "All") {
                      filteredData = snapshot.data;
                    } else if (searchValue.isNotEmpty) {
                      filteredData = snapshot.data!
                          .where((lease) =>
                              lease.rentalAddress!
                                  .toLowerCase()
                                  .contains(searchValue.toLowerCase()) ||
                              lease.tenantNames!
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
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Container(
                                // width: MediaQuery.of(context).size.width * .91,
                                child: Table(
                                  defaultColumnWidth: IntrinsicColumnWidth(),
                                  children: [
                                    TableRow(
                                      decoration:
                                          BoxDecoration(border: Border.all()),
                                      children: [
                                        //_buildHeader('FirstName', 0, (staff) => staff.rentalOwnerFirstName!),
                                        //  _buildHeader('LastName', 1, (staff) => staff.rentalOwnerLastName!),
                                        _buildHeader(
                                            'Lease',
                                            0,
                                            (lease) =>
                                                '${lease.rentalAddress ?? ''}'
                                                '${lease.tenantNames ?? ''}'),
                                        // _buildHeader('Lease', 0,
                                        //         (lease) => '${lease.rentalAddress!} '),
                                        _buildHeader('Lease Start', 1,
                                            (lease) => lease.startDate!),
                                        _buildHeader('Lease End', 2,
                                            (lease) => lease.endDate!),
                                        _buildHeader('Rent Cycle', 3,
                                            (lease) => lease.rentCycle!),
                                        _buildHeader('Rent Start', 4,
                                            (lease) => lease.rentDueDate!),
                                        _buildHeader('Rent', 5,
                                            (lease) => lease.rentalUnit!),
                                        _buildHeader('Deposit Held', 6,
                                            (lease) => lease.deposit!),
                                        _buildHeader('Charges', 7,
                                            (lease) => lease.recurringCharge!),
                                        _buildHeader('Created At', 8,
                                            (lease) => lease.createdAt!),
                                        _buildHeader('Updated At', 9,
                                            (lease) => lease.updatedAt!),
                                        _buildHeader('Actions', 10, null),
                                      ],
                                    ),
                                    TableRow(
                                      decoration: BoxDecoration(
                                        border: Border.symmetric(
                                            horizontal: BorderSide.none),
                                      ),
                                      children: List.generate(
                                          11,
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
                                          //_buildDataCell(_pagedData[i].rentalOwnerFirstName!),
                                          _buildDataCell(
                                              '${_pagedData[i].rentalAddress ?? ''}${_pagedData[i].tenantNames ?? ''}'),
                                          // _buildDataCell('${_pagedData[i].rentalOwnerFirstName ?? ''} ${_pagedData[i].rentalOwnerLastName ?? ''}'),
                                          _buildDataCell(
                                              _pagedData[i].startDate!),
                                          _buildDataCell(
                                              _pagedData[i].endDate!),
                                          _buildDataCell(
                                              _pagedData[i].rentCycle!),
                                          _buildDataCell(
                                              _pagedData[i].rentDueDate!),
                                          _buildDataCell(
                                              _pagedData[i].rentalUnit!),
                                          _buildDataCell((_pagedData[i]
                                                  .deposit
                                                  ?.toString() ??
                                              "")),
                                          _buildDataCell((_pagedData[i]
                                                  .recurringCharge
                                                  ?.toString() ??
                                              "")),
                                          _buildDataCell(formatDate(
                                              _pagedData[i].createdAt!)),
                                          _buildDataCell(formatDate(
                                              _pagedData[i].updatedAt!)),
                                          _buildActionsCell(_pagedData[i]),
                                        ],
                                      ),
                                  ],
                                ),
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
      Comparable<T> Function(Lease1 d)? getField) {
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

  Widget _buildActionsCell(Lease1 data) {
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

  // Widget _buildHeader<T>(String text, int columnIndex,
  //     Comparable<T> Function(Lease1 d)? getField) {
  //   return Container(
  //     height: 70,
  //     child: TableCell(
  //       child: InkWell(
  //         onTap: getField != null
  //             ? () {
  //                 _sort(getField, columnIndex, !_sortAscending);
  //               }
  //             : null,
  //         child: Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Row(
  //             children: [
  //               Text(text,
  //                   style:
  //                       TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
  //               if (getField != null)
  //                 Icon(
  //                   _sortColumnIndex == columnIndex
  //                       ? (_sortAscending
  //                           ? Icons.arrow_drop_up_outlined
  //                           : Icons.arrow_drop_down_outlined)
  //                       : Icons
  //                           .arrow_drop_down_outlined, // Default icon for unsorted columns
  //                 ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildDataCell(String text) {
  //   return Padding(
  //     padding: const EdgeInsets.all(5.0),
  //     child: Container(
  //       height: 60,
  //       child: TableCell(
  //         child: Padding(
  //           padding: const EdgeInsets.all(10.0),
  //           child: Center(child: Text(text, style: TextStyle(fontSize: 18))),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildActionsCell(Lease1 data) {
  //   return Padding(
  //     padding: const EdgeInsets.all(5.0),
  //     child: Container(
  //       height: 50,
  //       child: TableCell(
  //         child: Row(
  //           children: [
  //             InkWell(
  //               onTap: () {
  //                 handleEdit(data);
  //               },
  //               child: Container(
  //                 margin: EdgeInsets.only(top: 8, left: 8),
  //                 child: FaIcon(
  //                   FontAwesomeIcons.edit,
  //                   size: 30,
  //                 ),
  //               ),
  //             ),
  //             SizedBox(
  //               width: 6,
  //             ),
  //             InkWell(
  //               onTap: () {
  //                 handleDelete(data);
  //               },
  //               child: Container(
  //                 margin: EdgeInsets.only(top: 8, left: 8),
  //                 child: FaIcon(
  //                   FontAwesomeIcons.trashCan,
  //                   size: 30,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
