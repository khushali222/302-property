import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/screens/Rental/Properties/add_new_property.dart';
import 'package:three_zero_two_property/screens/Rental/Properties/summery_page.dart';
import 'package:three_zero_two_property/widgets/CustomTableShimmer.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import '../../../Model/propertytype.dart';
import '../../../constant/constant.dart';
import '../../../model/properties.dart';
import '../../../model/properties_summery.dart';
import '../../../model/rental_properties.dart';
import '../../../provider/add_property.dart';
import '../../../provider/dateProvider.dart';
import '../../../repository/properties.dart';
import '../../../repository/rental_properties.dart';
import '../../../widgets/drawer_tiles.dart';
import 'package:http/http.dart' as http;

import 'EditProperties.dart';
import '../../../widgets/custom_drawer.dart';

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

class PropertiesTable extends StatefulWidget {
  @override
  _PropertiesTableState createState() => _PropertiesTableState();
}

class _PropertiesTableState extends State<PropertiesTable> {
  late Future<List<Rentals>> futureRentalOwners;
  // late Future<List<propertytype>> futurePropertyTypes;
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  List<Rentals> _tableData = [];
  int totalrecords = 0;
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
  bool sorting3 = true;
  bool ascending1 = false;
  bool ascending2 = false;
  bool ascending3 = false;
  final List<String> applicantStatusOptions = [
    'All',
    'Accepting Applicant',
    'Not Accepting Applicant',
  ];
  final List<String> applicantoccupiedOptions = [
    'All',
    'Occupied',
    'Vacant',
  ];
  String? selectedApplicantStatus;
  String? selectedApplicantOcuupied;

  void sortData(List<Rentals> data) {
    if (sorting1) {
      data.sort((a, b) => ascending1
          ? a.rentalAddress!.compareTo(b.rentalAddress!)
          : b.rentalAddress!.compareTo(a.rentalAddress!));
    } else if (sorting2) {
      data.sort((a, b) => ascending2
          ? a.propertyTypeData!.propertyType!
              .compareTo(b.propertyTypeData!.propertyType!)
          : b.propertyTypeData!.propertyType!
              .compareTo(a.propertyTypeData!.propertyType!));
    } else if (sorting3) {
      data.sort((a, b) {
        if (a!.is_available! == b!.is_available!) return 0;
        return a!.is_available! ? -1 : 1; // true comes before false
      });
    } else {
      // Default sorting by createdAt in descending order (newest first)
      data.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return DateTime.parse(b.createdAt!)
            .compareTo(DateTime.parse(a.createdAt!));
      });
      // Then sort by property name in ascending order
      data.sort((a, b) => a.rentalAddress!.compareTo(b.rentalAddress!));
    }
  }

  Widget _buildHeaders() {
    var width = MediaQuery.of(context).size.width;
    return Container(
      // decoration: BoxDecoration(
      //   color: blueColor,
      //   borderRadius: BorderRadius.only(
      //     topLeft: Radius.circular(13),
      //     topRight: Radius.circular(13),
      //   ),
      // ),
      decoration: BoxDecoration(
          color: Color(0xFFF4F8FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFFDBE0E5))),
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
              flex: 4,
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
                    SizedBox(width: 6),
                    width < 400
                        ? Text("Property",
                            style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14))
                        : Text("Property",
                            style: TextStyle(
                                color: blueColor, fontWeight: FontWeight.bold)),
                    // Text("Property", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 3),
                    ascending1
                        ? Padding(
                            padding: const EdgeInsets.only(top: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.sortUp,
                              size: 20,
                              color: blueColor,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.sortDown,
                              size: 20,
                              color: blueColor,
                            ),
                          ),
                  ],
                ),
              ),
            ),
            // Expanded(
            //   child: InkWell(
            //     onTap: () {
            //       setState(() {
            //         if (sorting2) {
            //           sorting1 = false;
            //           sorting2 = sorting2;
            //           sorting3 = false;
            //           ascending2 = sorting2 ? !ascending2 : true;
            //           ascending1 = false;
            //           ascending3 = false;
            //         } else {
            //           sorting1 = false;
            //           sorting2 = !sorting2;
            //           sorting3 = false;
            //           ascending2 = sorting2 ? !ascending2 : true;
            //           ascending1 = false;
            //           ascending3 = false;
            //         }
            //         // Sorting logic here
            //       });
            //     },
            //     child: Row(
            //       children: [
            //         Text("     Type",
            //             style: TextStyle(color: blueColor, fontWeight: FontWeight.bold , fontSize: 15)),
            //         SizedBox(width: 2),
            //         ascending2
            //             ? Padding(
            //                 padding: const EdgeInsets.only(top: 7, left: 2),
            //                 child: FaIcon(
            //                   FontAwesomeIcons.sortUp,
            //                   size: 20,
            //                   color: Colors.white,
            //                 ),
            //               )
            //             : Padding(
            //                 padding: const EdgeInsets.only(bottom: 7, left: 2),
            //                 child: FaIcon(
            //                   FontAwesomeIcons.sortDown,
            //                   size: 20,
            //                   color: Colors.white,
            //                 ),
            //               ),
            //       ],
            //     ),
            //   ),
            // ),
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
                    Text("Accepting\nApplication",
                        style: TextStyle(
                            color: blueColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    SizedBox(width: 5),
                    // ascending3
                    //     ? Padding(
                    //         padding: const EdgeInsets.only(top: 7, left: 2),
                    //         child: FaIcon(
                    //           FontAwesomeIcons.sortUp,
                    //           size: 20,
                    //           color: Colors.white,
                    //         ),
                    //       )
                    //     : Padding(
                    //         padding: const EdgeInsets.only(bottom: 7, left: 2),
                    //         child: FaIcon(
                    //           FontAwesomeIcons.sortDown,
                    //           size: 20,
                    //           color: Colors.white,
                    //         ),
                    //       ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Rentals> get _pagedData {
    if (_tableData.isEmpty) return [];

    int startIndex = _currentPage * _rowsPerPage;
    int endIndex = startIndex + _rowsPerPage;

    // Ensure startIndex is within bounds
    if (startIndex >= _tableData.length) {
      _currentPage = (_tableData.length / _rowsPerPage).floor() - 1;
      startIndex = _currentPage * _rowsPerPage;
      endIndex = startIndex + _rowsPerPage;
    }

    // Ensure endIndex doesn't exceed the array length
    endIndex = endIndex > _tableData.length ? _tableData.length : endIndex;

    return _tableData.sublist(startIndex, endIndex);
  }

  void _changeRowsPerPage(int selectedRowsPerPage) {
    setState(() {
      _rowsPerPage = selectedRowsPerPage;
      _currentPage = 0; // Reset to the first page when changing rows per page
    });
  }

  final List<String> items = ['Residential', "Commercial", "All"];
  String? selectedValue;
  String searchvalue = "";
  ConnectivityResult? _connectivityResult;
  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectivityResult = result;
      });
    });
    checkInternet();
    futureRentalOwners = PropertiesRepository().fetchProperties().then((data) {
      // Sort by createdAt in descending order first
      data.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return DateTime.parse(b.createdAt!)
            .compareTo(DateTime.parse(a.createdAt!));
      });
      // Then sort by property name in ascending order
      data.sort((a, b) => a.rentalAddress!.compareTo(b.rentalAddress!));
      return data;
    });
    fetchRentaladded();
    // Set initial sorting to createdAt
    sorting1 = false;
    sorting2 = false;
    sorting3 = false;
  }

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
  }

  void handleEdit(Rentals properties) async {
    // Handle edit action
    // print('Edit ${properties.staffMemberId}');
    var check = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Edit_properties(
                  properties: properties,
                  rentalId: properties.rentalId!,
                )));
    if (check == true) {
      setState(() {
        futureRentalOwners = PropertiesRepository().fetchProperties();
      });
    }
    // final result = await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => Edit_properties(properties: properties,)));
    /* if (result == true) {
      setState(() {
        futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
      });
    }*/
  }

  void handleTap(Rentals properties) async {
    // Handle edit action
    // print('Edit ${properties.rentalId}');
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Summery_page(
                  properties: properties,
            )));
    /* if (result == true) {
      setState(() {
        futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
      });
    }*/
  }

  void _showAlert(BuildContext context, String id) {
    TextEditingController reason = TextEditingController();
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this property!",
      content: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 45,
            child: TextField(
              controller: reason,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter reason for deletion',
                  contentPadding: EdgeInsets.only(top: 8, left: 15)),
            ),
          ),
        ],
      ),
      style: AlertStyle(
        backgroundColor: Colors.white,
        //  overlayColor: Colors.black.withOpacity(.8)
      ),
      buttons: [
        DialogButton(
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            if (reason.text.isEmpty) {
              Fluttertoast.showToast(msg: "Please enter a reason for deletion");
            } else {
              // print(id);
              var data = await PropertiesRepository()
                  .DeleteProperties(id: id, reason: reason.text);
              if (data != null)
                setState(() {
                  futureRentalOwners = PropertiesRepository().fetchProperties();
                  //  futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
                });
              fetchRentaladded();
              Navigator.pop(context);
            }
          },
          color: blueColor,
        ),
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: blueColor, fontSize: 18,fontWeight: FontWeight.bold),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
          radius: BorderRadius.circular(8), // Rounded corners
          border: Border.all(
            color: blueColor, // Blue border
            width: 1.5,
          ),
        ),
      ],
    ).show();
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
          color: blueColor,
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

  void _sort<T>(Comparable<T> Function(Rentals) getField, int columnIndex,
      bool ascending) {
    futureRentalOwners.then((Rentals) {
      Rentals.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
      setState(() {
        _sortColumnIndex = columnIndex;
        _sortAscending = ascending;
      });
    });
  }

  void handleDelete(Rentals properties) {
    // print(properties.propertyId);
    // _showAlert(context,property.propertyId!);
    _showAlert(context, properties.rentalId!);

    // Handle delete action
    // print('Delete ${properties.propertyId}');
  }

  final _scrollController = ScrollController();
  int rentalCount = 0;
  int propertyCountLimit = 0;
  Future<void> fetchRentaladded() async {
    // print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${Api_url}/api/rentals/limitation/$id'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    final jsonData = json.decode(response.body);
    // print(jsonData);
    if (jsonData["statusCode"] == 200 || jsonData["statusCode"] == 201) {
      // print(rentalCount);
      // print(propertyCountLimit);
      setState(() {
        rentalCount = jsonData['rentalCount'];
        // print(rentalCount);
        propertyCountLimit = jsonData['propertyCountLimit'];
        // print(propertyCountLimit);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Properties",
        dropdown: true,
      ),
      body: _connectivityResult != ConnectivityResult.none
          ? SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0, right: 0),
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: titleBar(
                            width: MediaQuery.of(context).size.width * .65,
                            title: 'Properties',
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            // if (rentalCount < propertyCountLimit) {
                            //   final ownerDetailsProvider =
                            //       Provider.of<OwnerDetailsProvider>(context,
                            //           listen: false);
                            //   ownerDetailsProvider.clearOwners();
                            //   final result = await Navigator.of(context).push(
                            //       MaterialPageRoute(
                            //           builder: (context) => Add_new_property()));
                            //   if (result == true) {
                            //     setState(() {
                            //       futureRentalOwners =
                            //           PropertiesRepository().fetchProperties();
                            //       //  futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
                            //     });
                            //     fetchRentaladded();
                            //   }
                            // } else {
                            //   _showAlertforLimit(context);
                            // }
                            final ownerDetailsProvider =
                                Provider.of<OwnerDetailsProvider>(context,
                                    listen: false);
                            ownerDetailsProvider.clearOwners();
                            final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => Add_new_property()));
                            if (result == true) {
                              setState(() {
                                futureRentalOwners =
                                    PropertiesRepository().fetchProperties();
                                //  futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
                              });
                            }
                          },
                          child: Container(
                            //  height: 45,
                            height: (MediaQuery.of(context).size.width < 500)
                                ? 50
                                : 45,
                            width: (MediaQuery.of(context).size.width < 500)
                                ? MediaQuery.of(context).size.width * 0.25
                                : MediaQuery.of(context).size.width * 0.25,
                            decoration: BoxDecoration(
                              color: blueColor,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: Offset(0.0, 1.0),
                                  blurRadius: 6.0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "+ Add",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 18
                                              : 20,
                                    ),
                                  ),
                                ],
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
                  // SizedBox(height: 10),
                  SizedBox(height: 10),
                  // search and type
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 11,
                      right: 11,
                    ),
                    child: Row(
                      children: [
                        if (MediaQuery.of(context).size.width < 500)
                          SizedBox(width: 2),
                        if (MediaQuery.of(context).size.width > 500)
                          SizedBox(width: 22),
                        Expanded(
                          child: Material(
                            elevation: 3,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              // height: 40,
                              height: MediaQuery.of(context).size.width < 500
                                  ? 45
                                  : 50,
                              // width: MediaQuery.of(context).size.width < 500
                              //     ? MediaQuery.of(context).size.width * .52
                              //     : MediaQuery.of(context).size.width * .49,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  // border: Border.all(color: Colors.grey),
                                  border: Border.all(color: Color(0xFF8A95A8))),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: TextField(
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 12
                                              : 14),
                                      // onChanged: (value) {
                                      //   setState(() {
                                      //     cvverror = false;
                                      //   });
                                      // },
                                      // controller: cvv,
                                      onChanged: (value) {
                                        setState(() {
                                          searchvalue = value;
                                          if (_currentPage != 0)
                                            _currentPage = 0;
                                        });
                                      },
                                      cursorColor: blueColor,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Search here...",
                                        hintStyle: TextStyle(
                                            color: Color(0xFF495160),
                                            fontWeight: FontWeight.bold,
                                            // fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 14
                                                : 18),
                                        contentPadding: (EdgeInsets.only(
                                            left: 5, bottom: 12, top: 5)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: Material(
                              elevation: 3,
                              borderRadius: BorderRadius.circular(8),
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: const Row(
                                  children: [
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Select Type',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF495160),
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
                                  // height: 40,
                                  height:
                                      MediaQuery.of(context).size.width < 500
                                          ? 45
                                          : 50,
                                  width: MediaQuery.of(context).size.width < 500
                                      ? MediaQuery.of(context).size.width * .37
                                      : MediaQuery.of(context).size.width * .4,
                                  padding: const EdgeInsets.only(
                                      left: 14, right: 14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      // color: Colors.black26,
                                      color: Color(0xFF8A95A8),
                                    ),
                                    color: Colors.white,
                                  ),
                                  elevation: 0,
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
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 11,
                      right: 11,
                    ),
                    child: Row(
                      children: [
                        if (MediaQuery.of(context).size.width < 500)
                          SizedBox(width: 2),
                        if (MediaQuery.of(context).size.width > 500)
                          SizedBox(width: 22),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: Material(
                              elevation: 3,
                              borderRadius: BorderRadius.circular(8),
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: const Row(
                                  children: [
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Select Availability',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF495160),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                buttonStyleData: ButtonStyleData(
                                  // height: 40,
                                  height:
                                      MediaQuery.of(context).size.width < 500
                                          ? 45
                                          : 50,
                                  width: MediaQuery.of(context).size.width < 500
                                      ? MediaQuery.of(context).size.width * .37
                                      : MediaQuery.of(context).size.width * .4,
                                  padding: const EdgeInsets.only(
                                      left: 14, right: 14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      // color: Colors.black26,
                                      color: Color(0xFF8A95A8),
                                    ),
                                    color: Colors.white,
                                  ),
                                  elevation: 0,
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
                                items: applicantStatusOptions
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
                                value: selectedApplicantStatus,
                                onChanged: (value) {
                                  setState(() {
                                    selectedApplicantStatus = value;
                                    if (_currentPage != 0)
                                      _currentPage =
                                          0; // Reset to first page when filter changes
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: Material(
                              elevation: 3,
                              borderRadius: BorderRadius.circular(8),
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: const Row(
                                  children: [
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Select Occupancy',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF495160),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                buttonStyleData: ButtonStyleData(
                                  // height: 40,
                                  height:
                                      MediaQuery.of(context).size.width < 500
                                          ? 45
                                          : 50,
                                  width: MediaQuery.of(context).size.width < 500
                                      ? MediaQuery.of(context).size.width * .37
                                      : MediaQuery.of(context).size.width * .4,
                                  padding: const EdgeInsets.only(
                                      left: 14, right: 14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      // color: Colors.black26,
                                      color: Color(0xFF8A95A8),
                                    ),
                                    color: Colors.white,
                                  ),
                                  elevation: 0,
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
                                items: applicantoccupiedOptions
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
                                value: selectedApplicantOcuupied,
                                onChanged: (value) {
                                  setState(() {
                                    selectedApplicantOcuupied = value;
                                    if (_currentPage != 0)
                                      _currentPage =
                                          0; // Reset to first page when filter changes
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // Row(
                  //   children: [
                  //     Spacer(),
                  //     Row(
                  //       children: [
                  //         Text(
                  //           'Added : ${rentalCount.toString()}',
                  //           style: TextStyle(
                  //             fontWeight: FontWeight.bold,
                  //             color: Color(0xFF8A95A8),
                  //             fontSize:
                  //                 MediaQuery.of(context).size.width < 500 ? 13 : 18,
                  //           ),
                  //         ),
                  //         SizedBox(
                  //           width: 5,
                  //         ),
                  //         Text(
                  //           "/",
                  //           style: TextStyle(color: greyColor),
                  //         ),
                  //         SizedBox(
                  //           width: 5,
                  //         ),
                  //         //  Text("rentalOwnerCountLimit: ${response['rentalOwnerCountLimit']}"),
                  //         Text(
                  //           'Total: ${propertyCountLimit.toString()}',
                  //           style: TextStyle(
                  //             fontWeight: FontWeight.bold,
                  //             color: Color(0xFF8A95A8),
                  //             fontSize:
                  //                 MediaQuery.of(context).size.width < 500 ? 13 : 18,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     if (MediaQuery.of(context).size.width < 500)
                  //       SizedBox(width: 15),
                  //     if (MediaQuery.of(context).size.width > 500)
                  //       SizedBox(width: 39),
                  //   ],
                  // ),
                  if (MediaQuery.of(context).size.width > 500)
                    SizedBox(height: 25),
                  if (MediaQuery.of(context).size.width < 500)
                    Padding(
                      padding: const EdgeInsets.all(11.0),
                      child: FutureBuilder<List<Rentals>>(
                        future: futureRentalOwners,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ColabShimmerLoadingWidget();
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
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

                            // Apply filters
                            if (selectedValue != null &&
                                selectedValue != "All") {
                              data = data
                                  .where((properties) =>
                                      properties
                                          .propertyTypeData?.propertyType ==
                                      selectedValue)
                                  .toList();
                            }

                            if (searchvalue.isNotEmpty) {
                              data = data
                                  .where((properties) =>
                                      properties.rentalAddress!.toLowerCase().contains(searchvalue.toLowerCase()) ||
                                      properties.propertyTypeData!.propertyType!
                                          .toLowerCase()
                                          .contains(
                                              searchvalue.toLowerCase()) ||
                                      properties.propertyTypeData!.propertySubType!
                                          .toLowerCase()
                                          .contains(
                                              searchvalue.toLowerCase()) ||
                                      properties.rentalOwnerData!.rentalOwnerName!
                                          .toLowerCase()
                                          .contains(
                                              searchvalue.toLowerCase()) ||
                                      properties.rentalOwnerData!.rentalOwnerPhoneNumber!
                                          .toLowerCase()
                                          .contains(
                                              searchvalue.toLowerCase()) ||
                                      properties.rentalOwnerData!.rentalOwnerCompanyName!
                                          .toLowerCase()
                                          .contains(
                                              searchvalue.toLowerCase()) ||
                                      properties.rentalOwnerData!.rentalOwnerPrimaryEmail!
                                          .toLowerCase()
                                          .contains(searchvalue.toLowerCase()) ||
                                      properties.rentalOwnerData!.Address!.toLowerCase().contains(searchvalue.toLowerCase())
                                  ||
                                          (properties.tenantsData != null &&
                                  properties.tenantsData!.any((tenant) =>
                              (tenant.tenantFirstName ?? '')
                                  .toLowerCase()
                                  .contains(searchvalue.toLowerCase()) ||
                                  (tenant.tenantLastName ?? '')
                                      .toLowerCase()
                                      .contains(searchvalue.toLowerCase())))

                              )
                                  .toList();
                            }

                            if (selectedApplicantStatus ==
                                'Accepting Applicant') {
                              data = data
                                  .where((properties) =>
                                      properties.is_available == true)
                                  .toList();
                            } else if (selectedApplicantStatus ==
                                'Not Accepting Applicant') {
                              data = data
                                  .where((properties) =>
                                      properties.is_available == false)
                                  .toList();
                            }

                            if (selectedApplicantOcuupied == 'Occupied') {
                              data = data
                                  .where((properties) =>
                                      properties.tenantsData != null &&
                                      properties.tenantsData!.length > 0)
                                  .toList();
                            } else if (selectedApplicantOcuupied == 'Vacant') {
                              data = data
                                  .where((properties) =>
                                      properties.tenantsData == null ||
                                      properties.tenantsData!.length == 0)
                                  .toList();
                            }

                            sortData(data);

                            // Update the total data
                            _tableData = List<Rentals>.from(data);

                            // Calculate total pages
                            final totalPages =
                                (_tableData.length / _rowsPerPage).ceil();

                            // Ensure current page is valid
                            if (_currentPage >= totalPages && totalPages > 0) {
                              _currentPage = totalPages - 1;
                            }

                            // Calculate start and end indices for current page
                            final startIndex = _currentPage * _rowsPerPage;
                            final endIndex =
                                startIndex + _rowsPerPage > _tableData.length
                                    ? _tableData.length
                                    : startIndex + _rowsPerPage;

                            // Get current page data
                            final currentPageData =
                                _tableData.sublist(startIndex, endIndex);
                            print("data for check  table $data");
                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(height: 2),
                                  _buildHeaders(),
                                  SizedBox(height: 10),
                                  Container(
                                    // decoration: BoxDecoration(
                                    //     border: Border.all(
                                    //         color: Color.fromRGBO(
                                    //             152, 162, 179, .5))),
                                    // decoration: BoxDecoration(
                                    //     border: Border.all(color: blueColor)),
                                    child: Column(
                                      children: currentPageData
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        int index = entry.key;
                                        bool isExpanded =
                                            expandedIndex == index;
                                        Rentals rentals = entry.value;
                                        //return CustomExpansionTile(data: Propertytype, index: index);
                                        return Container(
                                          margin:
                                              EdgeInsets.symmetric(vertical: 6),
                                          // decoration: BoxDecoration(
                                          //   border: Border.all(color: blueColor),
                                          // ),
                                          decoration: BoxDecoration(
                                            color: index % 2 != 0
                                                ? Color(0xFFF4F8FF)
                                                : Colors.white,
                                            border: Border.all(
                                                color: Color(0xFFDBE0E5)),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            children: <Widget>[
                                              ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                title: Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
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
                                                              expandedIndex =
                                                                  null;
                                                            } else {
                                                              expandedIndex =
                                                                  index;
                                                            }
                                                          });
                                                        },
                                                        child: Container(
                                                          //width: 25,
                                                          // color: Colors.blue,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 5,
                                                                  right: 2),
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
                                                            color: blueColor,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 4,
                                                        child: InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              if (expandedIndex ==
                                                                  index) {
                                                                expandedIndex =
                                                                    null;
                                                              } else {
                                                                expandedIndex =
                                                                    index;
                                                              }
                                                            });
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 10.0),
                                                            child: Text(
                                                              '${(rentals.rentalAddress ?? '').isEmpty ? 'N/A' : rentals.rentalAddress}',
                                                              style: TextStyle(
                                                                color:
                                                                    blueColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // SizedBox(
                                                      //     width: MediaQuery.of(
                                                      //                 context)
                                                      //             .size
                                                      //             .width *
                                                      //         .01),
                                                      // Expanded(
                                                      //   child: Text(
                                                      //     '${(rentals.propertyTypeData!.propertyType ?? '').isEmpty ? 'N/A' : rentals.propertyTypeData!.propertyType} - \n ${(rentals.propertyTypeData!.propertySubType ?? '').isEmpty ? 'N/A' : rentals.propertyTypeData!.propertySubType}  ',
                                                      //     style: TextStyle(
                                                      //       color: blueColor,
                                                      //       fontWeight:
                                                      //           FontWeight.bold,
                                                      //       fontSize: 13,
                                                      //     ),
                                                      //   ),
                                                      // ),
                                                      // SizedBox(
                                                      //     width:
                                                      //         MediaQuery.of(context)
                                                      //                 .size
                                                      //                 .width *
                                                      //             .08),
                                                      rentals!.is_available!
                                                          ? Expanded(
                                                              flex: 2,
                                                              child: Row(
                                                                children: [
                                                                  SizedBox(
                                                                    width: 20,
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      _publishRentAmount(
                                                                          rentals
                                                                              .rentalId!,
                                                                          "0",
                                                                          isAvailable:
                                                                              true);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          35,
                                                                      width: 35,
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              5),
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(
                                                                              8),
                                                                          color: Colors
                                                                              .greenAccent
                                                                              .shade100),
                                                                      child: Center(
                                                                          child: Icon(
                                                                        Icons
                                                                            .check_circle,
                                                                        color: Colors
                                                                            .green,
                                                                      )),
                                                                    ),
                                                                  ),
                                                                  Spacer()
                                                                ],
                                                              ))
                                                          : Expanded(
                                                              flex: 2,
                                                              child: Row(
                                                                children: [
                                                                  SizedBox(
                                                                    width: 20,
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      _showPublishRentDialog(
                                                                          rentals
                                                                              .rentalId!);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          35,
                                                                      width: 35,
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              5),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .redAccent
                                                                            .withOpacity(0.3),
                                                                        borderRadius:
                                                                            BorderRadius.circular(8),
                                                                      ),
                                                                      child: Center(
                                                                          child: Icon(
                                                                        Icons
                                                                            .lock_rounded,
                                                                        color: Colors
                                                                            .red,
                                                                      )),
                                                                    ),
                                                                  ),
                                                                  Spacer()
                                                                ],
                                                              )),
                                                      // SizedBox(
                                                      //     width:
                                                      //         MediaQuery.of(context)
                                                      //                 .size
                                                      //                 .width *
                                                      //             .02),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (isExpanded)
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      top: BorderSide(
                                                          color:
                                                              Color(0xFFDBE0E5),
                                                          width: 1),
                                                    ),
                                                  ),
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            FaIcon(
                                                              isExpanded
                                                                  ? FontAwesomeIcons
                                                                      .sortUp
                                                                  : FontAwesomeIcons
                                                                      .sortDown,
                                                              size: 20,
                                                              color: Colors
                                                                  .transparent,
                                                            ),
                                                            Expanded(
                                                              child: Table(
                                                                columnWidths: {
                                                                  // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                                                  // 1: FlexColumnWidth(),
                                                                  0: FlexColumnWidth(), // Distribute columns equally
                                                                  1: FlexColumnWidth(),
                                                                },
                                                                children: [
                                                                  _buildTableRow(
                                                                      'Rental Company Name :',
                                                                      _getDisplayValue(rentals
                                                                          .rentalOwnerData
                                                                          ?.rentalOwnerCompanyName),
                                                                      'City :',
                                                                      _getDisplayValue(
                                                                          rentals
                                                                              .rentalCity)),
                                                                  _buildTableRow(
                                                                    'Property Type :',
                                                                    '${_getDisplayValue(rentals.propertyTypeData?.propertyType)} - ${_getDisplayValue(rentals.propertyTypeData?.propertySubType)}',
                                                                    'Tenants :',
                                                                    rentals.tenantsData !=
                                                                                null &&
                                                                            rentals
                                                                                .tenantsData!.isNotEmpty
                                                                        ? rentals
                                                                            .tenantsData!
                                                                            .map((tenant) =>
                                                                                "${tenant.tenantFirstName ?? ''} ${tenant.tenantLastName ?? ''}".trim())
                                                                            .join(", ")
                                                                        : "-----",
                                                                  ),
                                                                ],
                                                              ),
                                                            ),

                                                            // FaIcon(
                                                            //   isExpanded
                                                            //       ? FontAwesomeIcons
                                                            //       .sortUp
                                                            //       : FontAwesomeIcons
                                                            //       .sortDown,
                                                            //   size: 20,
                                                            //   color:
                                                            //   Colors.transparent,
                                                            // ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            SizedBox(
                                                              width: 12,
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  _showAlert(
                                                                      context,
                                                                      rentals
                                                                          .rentalId!);
                                                                });
                                                              },
                                                              child: Container(
                                                                height: 35,
                                                                width: 35,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                8),
                                                                    color: Colors
                                                                        .red
                                                                        .shade50),
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
                                                                      color: Colors
                                                                          .red,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            GestureDetector(
                                                              onTap: () async {
                                                                var check =
                                                                    await Navigator
                                                                        .push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            Edit_properties(
                                                                      properties:
                                                                          rentals,
                                                                      rentalId:
                                                                          rentals
                                                                              .rentalId!,
                                                                    ),
                                                                  ),
                                                                );
                                                                if (check ==
                                                                    true) {
                                                                  setState(() {
                                                                    futureRentalOwners =
                                                                        PropertiesRepository()
                                                                            .fetchProperties();
                                                                  });
                                                                  // Update State
                                                                }
                                                              },
                                                              child: Container(
                                                                height: 35,
                                                                width: 35,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                8),
                                                                    color: Colors
                                                                        .green
                                                                        .shade50), // color:Colors.grey[100],
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
                                                                      color: Colors
                                                                          .green,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                // Check if property is multi-unit based on property type data
                                                                bool
                                                                    isMultiUnit =
                                                                    rentals.propertyTypeData
                                                                            ?.isMultiunit ??
                                                                        false;

                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            Summery_page(
                                                                              properties: rentals,
                                                                            )));
                                                              },
                                                              child: Container(
                                                                height: 35,
                                                                width: 35,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade200,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
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
                                                                          .eye,
                                                                      size: 15,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                    SizedBox(
                                                                        width:
                                                                            2),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 12,
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 15,
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
                                  if (data.length > _rowsPerPage)
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
                                                  border: Border.all(
                                                      color: Colors.grey),
                                                ),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child: DropdownButton<int>(
                                                    value: _rowsPerPage,
                                                    items: itemsPerPageOptions
                                                        .map((int value) {
                                                      return DropdownMenuItem<
                                                          int>(
                                                        value: value,
                                                        child: Text(
                                                            value.toString()),
                                                      );
                                                    }).toList(),
                                                    onChanged: _tableData
                                                                .length >
                                                            itemsPerPageOptions
                                                                .first
                                                        ? (newValue) {
                                                            setState(() {
                                                              _rowsPerPage =
                                                                  newValue!;
                                                              _currentPage =
                                                                  0; // Reset to first page when items per page change
                                                            });
                                                          }
                                                        : null,
                                                    icon: Icon(
                                                      Icons.arrow_drop_down,
                                                      size: 40,
                                                    ),
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17),
                                                    dropdownColor: Colors.white,
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
                                                FontAwesomeIcons
                                                    .circleChevronLeft,
                                                color: _currentPage == 0
                                                    ? Colors.grey
                                                    : blueColor,
                                              ),
                                              onPressed: _currentPage == 0
                                                  ? null
                                                  : () {
                                                      setState(() {
                                                        _currentPage--;
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
                                                'Page ${_currentPage + 1} of $totalPages'),
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
                                                FontAwesomeIcons
                                                    .circleChevronRight,
                                                color: _currentPage <
                                                        totalPages - 1
                                                    ? blueColor
                                                    : Colors.grey,
                                              ),
                                              onPressed:
                                                  _currentPage < totalPages - 1
                                                      ? () {
                                                          setState(() {
                                                            _currentPage++;
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
                    FutureBuilder<List<Rentals>>(
                      future: futureRentalOwners,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ShimmerTabletTable();
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
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
                          List<Rentals>? filteredData = [];
                          _tableData = snapshot.data!;
                          // Filter by property type
                          if (selectedValue != null && selectedValue != "All") {
                            _tableData = _tableData
                                .where((property) =>
                                    property.propertyTypeData?.propertyType ==
                                    selectedValue)
                                .toList();
                          }

                          // Filter by search value
                          if (searchvalue.isNotEmpty) {
                            _tableData = _tableData
                                .where((property) =>
                                    property.rentalAddress!
                                        .toLowerCase()
                                        .contains(searchvalue.toLowerCase()) ||
                                    property.propertyTypeData!.propertyType!
                                        .toLowerCase()
                                        .contains(searchvalue.toLowerCase()) ||
                                    property.propertyTypeData!.propertySubType!
                                        .toLowerCase()
                                        .contains(searchvalue.toLowerCase()) ||
                                    property.rentalOwnerData!.rentalOwnerName!
                                        .toLowerCase()
                                        .contains(searchvalue.toLowerCase()) ||
                                    property.rentalOwnerData!
                                        .rentalOwnerPhoneNumber!
                                        .toLowerCase()
                                        .contains(searchvalue.toLowerCase()) ||
                                    property.rentalOwnerData!
                                        .rentalOwnerCompanyName!
                                        .toLowerCase()
                                        .contains(searchvalue.toLowerCase()) ||
                                    property.rentalOwnerData!
                                        .rentalOwnerPrimaryEmail!
                                        .toLowerCase()
                                        .contains(searchvalue.toLowerCase()))
                                .toList();
                          }

                          // Filter by applicant status
                          if (selectedApplicantStatus ==
                              'Accepting Applicant') {
                            _tableData = _tableData
                                .where(
                                    (property) => property.is_available == true)
                                .toList();
                          } else if (selectedApplicantStatus ==
                              'Not Accepting Applicant') {
                            _tableData = _tableData
                                .where((property) =>
                                    property.is_available == false)
                                .toList();
                          }

                          // Filter by occupancy status
                          if (selectedApplicantOcuupied == 'Occupied') {
                            _tableData = _tableData
                                .where((property) =>
                                    property.tenantsData != null &&
                                    property.tenantsData!.length > 0)
                                .toList();
                          } else if (selectedApplicantOcuupied == 'Vacant') {
                            _tableData = _tableData
                                .where((property) =>
                                    property.tenantsData == null ||
                                    property.tenantsData!.length == 0)
                                .toList();
                          }
                          totalrecords = _tableData.length;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 16),
                                    child: Table(
                                      defaultColumnWidth:
                                          IntrinsicColumnWidth(),
                                      children: [
                                        TableRow(
                                          decoration: BoxDecoration(
                                              border: Border.all()),
                                          children: [
                                            _buildHeader(
                                                'Property',
                                                0,
                                                (staff) =>
                                                    staff.rentalAddress!),
                                            _buildHeader(
                                                'PropertyType',
                                                1,
                                                (staff) => staff
                                                    .propertyTypeData!
                                                    .propertyType!),
                                            _buildHeader(
                                                'PropertySubTYpe',
                                                2,
                                                (staff) => staff
                                                    .propertyTypeData!
                                                    .propertySubType!),
                                            _buildHeader(
                                                'RentalOwnersName',
                                                3,
                                                (staff) => staff
                                                    .rentalOwnerData!
                                                    .rentalOwnerName!),
                                            _buildHeader(
                                                'RentalCompanyName',
                                                4,
                                                (staff) => staff
                                                    .rentalOwnerData!
                                                    .rentalOwnerCompanyName!),
                                            _buildHeader('Locality', 5,
                                                (staff) => staff.rentalCity!),
                                            _buildHeader(
                                                'PrimaryEmail',
                                                6,
                                                (staff) => staff
                                                    .rentalOwnerData!
                                                    .rentalOwnerPrimaryEmail!),
                                            _buildHeader(
                                                'PhoneNumber',
                                                7,
                                                (staff) => staff
                                                    .rentalOwnerData!
                                                    .rentalOwnerPhoneNumber!),
                                            //  _buildHeader('Created At', 8, (staff) => staff.rentalOwnerData!.rentalOwnerPhoneNumber!),
                                            //_buildHeader('Last Updated At', 9, (staff) => staff.rentalOwnerData!.rentalOwnerPhoneNumber!),
                                            _buildHeader('Actions', 8, null),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: BoxDecoration(
                                            border: Border.symmetric(
                                                horizontal: BorderSide.none),
                                          ),
                                          children: List.generate(
                                              9,
                                              (index) => TableCell(
                                                  child:
                                                      Container(height: 20))),
                                        ),
                                        for (var i = 0;
                                            i < _pagedData.length;
                                            i++)
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
                                                bottom:
                                                    i == _pagedData.length - 1
                                                        ? BorderSide(
                                                            color: blueColor)
                                                        : BorderSide.none,
                                              ),
                                            ),
                                            children: [
                                              _buildDataCell(
                                                  _pagedData[i].rentalAddress!,
                                                  _pagedData[i]),
                                              _buildDataCell(
                                                  _pagedData[i]
                                                      .propertyTypeData!
                                                      .propertyType!,
                                                  _pagedData[i]),
                                              _buildDataCell(
                                                  _pagedData[i]
                                                      .propertyTypeData!
                                                      .propertySubType!,
                                                  _pagedData[i]),
                                              // _buildDataCell(_pagedData[i].rentalOwnerData!.rentalOwnerFirstName!),
                                              _buildDataCell(
                                                  '${_pagedData[i].rentalOwnerData?.rentalOwnerName ?? ''} ',
                                                  _pagedData[i]),
                                              _buildDataCell(
                                                  _pagedData[i]
                                                      .rentalOwnerData!
                                                      .rentalOwnerCompanyName!,
                                                  _pagedData[i]),

                                              _buildDataCell(
                                                  _pagedData[i].rentalCity!,
                                                  _pagedData[i]),
                                              _buildDataCell(
                                                  _pagedData[i]
                                                      .rentalOwnerData!
                                                      .rentalOwnerPrimaryEmail!,
                                                  _pagedData[i]),
                                              _buildDataCell(
                                                  _pagedData[i]
                                                      .rentalOwnerData!
                                                      .rentalOwnerPhoneNumber!,
                                                  _pagedData[i]),
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
            )
          : SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/no_internet.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.fill,
                  ),
                  Text(
                    'No Internet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Check your internet connection',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
    );
  }

  void _showPublishRentDialog(String rentalId) {
    TextEditingController rentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Published Rent Amount'),
          content: TextField(
            controller: rentController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Rent Amount',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String rentAmount = rentController.text.trim();
                if (rentAmount.isEmpty) {
                  Fluttertoast.showToast(msg: "Please enter a rent amount");
                  return;
                }
                Navigator.of(context).pop();
                await _publishRentAmount(rentalId, rentAmount);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _publishRentAmount(String rentalId, String rentAmount,
      {bool isAvailable = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    try {
      final response = await http.put(
        Uri.parse('${Api_url}/api/rentals/rental/$rentalId/availability'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "is_available": !isAvailable ? true : false,
          "published_rent_amount": double.parse(rentAmount),
        }),
      );
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Fluttertoast.showToast(msg: "Rent amount published successfully");
        // Optionally refresh data here
        setState(() {
          futureRentalOwners = PropertiesRepository().fetchProperties();
        });
      } else {
        Fluttertoast.showToast(msg: "Failed to publish rent amount");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }
  // Widget _buildHeader<T>(String text, int columnIndex,
  //     Comparable<T> Function(Rentals d)? getField) {
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

  TableRow _buildTableRow(String leftLabel, String leftValue, String rightLabel,
      String rightValue) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leftLabel,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                ),
                SizedBox(height: 4.0), // Space between label and value
                Text(
                  leftValue,
                  style: TextStyle(color: grey),
                ),
              ],
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: EdgeInsets.only(left: 65, top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  rightLabel,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                ),
                SizedBox(height: 4.0), // Space between label and value
                Text(
                  rightValue,
                  style: TextStyle(color: grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getDisplayValue(String? value) {
    // Return 'N/A' if the value is null or empty, otherwise return the value
    return (value == null || value.trim().isEmpty) ? 'N/A' : value;
  }

  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(Rentals d)? getField) {
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

  Widget _buildDataCell(String text, Rentals inkText) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 16),
        child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Summery_page(
                            properties: inkText,
                      )));
            },
            child: Text(text?.isNotEmpty == true ? text! : 'N/A',
                style: const TextStyle(fontSize: 18))),
      ),
    );
  }

  Widget _buildActionsCell(Rentals data) {
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
                  color: Colors.green,
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
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    int totalPages = (_tableData.length / _rowsPerPage).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
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
                items: itemsPerPageOptions.map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: _tableData.length > itemsPerPageOptions.first
                    ? (newValue) {
                        setState(() {
                          _rowsPerPage = newValue!;
                          _currentPage = 0; // Reset to first page
                        });
                      }
                    : null,
                icon: Icon(Icons.arrow_drop_down, size: 40),
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
            color: _currentPage == 0 ? Colors.grey : blueColor,
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
          'Page ${_currentPage + 1} of $totalPages',
          style: TextStyle(fontSize: 18),
        ),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.circleChevronRight,
            color: _currentPage >= totalPages - 1 ? Colors.grey : blueColor,
          ),
          onPressed: _currentPage >= totalPages - 1
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
