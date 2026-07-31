import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/widgets/CustomTableShimmer.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

import 'package:html/parser.dart' as htmlParser;
import '../../../../Model/TenantCommunication.dart';
import '../../../../constant/constant.dart';
import '../../../../provider/dateProvider.dart';

import '../../../../repository/Communication/tenant_communication_repo.dart';
import '../../../../widgets/custom_drawer.dart';

class Tenant_communication extends StatefulWidget {
  String? lease_id;
  Tenant_communication({this.lease_id});
  @override
  _Tenant_communicationState createState() => _Tenant_communicationState();
}

class _Tenant_communicationState extends State<Tenant_communication> {
  int totalrecords = 0;
  Future<TenantCommunation>? futureEmailss;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  int currentPage = 1;
  int itemsPerPage = 10;
  List<int> itemsPerPageOptions = [
    10,
    25,
    50,
    100,
  ]; // Options for items per page

  void sortData(List<Emails> data) {
    if (sorting1) {
      data.sort((a, b) => ascending1
          ? a.subject!.compareTo(b.subject!)
          : b.subject!.compareTo(a.subject!));
    } else if (sorting2) {
      data.sort((a, b) => ascending2
          ? a.subject!.compareTo(b.subject!)
          : b.subject!.compareTo(a.subject!));
    } else if (sorting3) {
      data.sort((a, b) => ascending3
          ? a.createdAt!.compareTo(b.createdAt!)
          : b.createdAt!.compareTo(a.createdAt!));
    }
  }

  int? expandedIndex;
  Set<int> expandedIndices = {};
  late bool isExpanded;
  bool sorting1 = false;
  bool sorting2 = false;
  bool sorting3 = false;
  bool ascending1 = false;
  bool ascending2 = false;
  bool ascending3 = false;
  Widget _buildHeaders() {
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
          color: Color(0xFFF4F8FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFFDBE0E5))),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        // leading: Container(
        //   child: Icon(
        //     Icons.expand_less,
        //     color: Colors.transparent,
        //   ),
        // ),
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
                    width < 400
                        ? Text("Rental Address",
                            style: TextStyle(
                                color: blueColor, fontWeight: FontWeight.bold))
                        : Text("Rental Address",
                            style: TextStyle(
                                color: blueColor, fontWeight: FontWeight.bold)),
                    // Text("Property", style: TextStyle(color: Colors.white)),
                    // SizedBox(width: 3),
                    // ascending1
                    //     ? Padding(
                    //   padding: const EdgeInsets.only(top: 7, left: 2),
                    //   child: FaIcon(
                    //     FontAwesomeIcons.sortUp,
                    //     size: 20,
                    //     color: Colors.white,
                    //   ),
                    // )
                    //     : Padding(
                    //   padding: const EdgeInsets.only(bottom: 7, left: 2),
                    //   child: FaIcon(
                    //     FontAwesomeIcons.sortDown,
                    //     size: 20,
                    //     color: Colors.white,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              flex: 3,
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
                    Text("         Sent",
                        style: TextStyle(
                            color: blueColor, fontWeight: FontWeight.bold)),
                    SizedBox(width: 3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<String> items = ['Residential', "Commercial", "All"];
  String? selectedValue;
  String searchvalue = "";
  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectivityResult = result;
        if (_connectivityResult != ConnectivityResult.none)
          futureEmailss = EmailLogRepository().fetchEmailLog(widget.lease_id!);
      });
    });
    checkInternet();
  }

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });

    if (_connectivityResult != ConnectivityResult.none)
      futureEmailss = EmailLogRepository().fetchEmailLog(widget.lease_id!);
  }

  bool _errorText = false;
  // void _showAlert(BuildContext context, String id, Emails data) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         child: SingleChildScrollView(
  //           child: Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Column(
  //               children: [
  //                 SizedBox(
  //                   height: 10,
  //                 ),
  //                 Row(
  //                   children: [
  //                     Text(
  //                       "Email Logs Details",
  //                       style: TextStyle(
  //                           fontSize: 17,
  //                           fontWeight: FontWeight.bold,
  //                           color: blueColor),
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(
  //                   height: 10,
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.all(4.0),
  //                   child: Table(
  //
  //                     columnWidths: const {
  //                       0: FlexColumnWidth(2), // First column takes 2x space
  //                       1: FlexColumnWidth(3), // Second column takes 1x space
  //                     },
  //                     border: TableBorder.all(
  //                         color: blueColor), // Table border
  //                     children: [
  //                       _buildTableRow(
  //                           "Open Status",
  //                           data.isAccepted == true ? "✔ " : "✖ ",
  //                           data.isAccepted == true ? Colors.green : Colors.red),
  //                       _buildTableRow(
  //                           "Subject", '${data.subject}', Colors.black),
  //                       _buildTableRow(
  //                           "Recipient Email", '${data.email}', Colors.black),
  //                       _buildTableRow(
  //                           "From Email", '${data.from}', Colors.black),
  //                       _buildTableRow(
  //                           "Created Time", '${data.createdAt}', Colors.black),
  //                       _buildTableRow(
  //                           "Open Time",
  //                           '${data.isOpened == true ? data.openedAt : "Not Opened"}',
  //                           Colors.black),
  //                     ],
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   height: 10,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
  void _showAlert(BuildContext context, String id, Emails data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Section
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: blueColor, // Customize color
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Center(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          "Email Details",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                            )),
                        SizedBox(
                          width: 8,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildField("Subject", '${data.subject}', Colors.black),
                        _buildField(
                            "Recipient Email", '${data.email}', Colors.black),
                        _buildField("From Email", '${data.from}', Colors.black),
                        _buildField(
                            "Created Time",
                            Provider.of<DateProvider>(context, listen: false)
                                .formatCurrentDateTime('${data.createdAt}'),
                            Colors.black),
                        _buildFieldhtml("Body", '${data.body}', Colors.black),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Field-like container function
  Widget _buildField(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: blueColor),
          ),
          SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200], // Light background like input field
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 14, color: grey, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldhtml(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: blueColor),
          ),
          SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200], // Light background like input field
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Html(
              data: value,
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String title, String value, Color textColor) {
    return TableRow(
      children: [
        Padding(
          padding: EdgeInsets.all(4.0),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: blueColor),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(4.0),
          child: Text(
            value,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: grey),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  List<Emails> _tableData = [];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<Emails> get _pagedData {
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

  void _sort<T>(Comparable<T> Function(Emails d) getField, int columnIndex,
      bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _tableData.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        final result = aValue.compareTo(bValue as T);
        return _sortAscending ? result : -result;
      });
    });
  }

  void _showDeleteAlert(BuildContext context, String id) {
    TextEditingController reason = TextEditingController();
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this email history!",
      style: AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            deletemail(noteid: id);
            Navigator.pop(context);
            setState(() {
              futureEmailss =
                  EmailLogRepository().fetchEmailLog(widget.lease_id!);
            });
          },
          color: blueColor,
        ),
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(
                color: blueColor, fontSize: 18, fontWeight: FontWeight.bold),
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

  Future<Map<String, dynamic>> deletemail({
    required String noteid,
  }) async {
    try {
      final Uri uri = Uri.parse('$Api_url/api/email-logs/$noteid');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? id = prefs.getString('adminId');
      String? staffid = prefs.getString("staff_id");
      final http.Response response = await apiDelete(
        uri,
        headers: <String, String>{
          "authorization": "CRM $token",
          "id": "CRM $id",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({}),
      );

      var responseData = json.decode(response.body);
      // print(renters_insurance_id);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: responseData["message"]);
        return json.decode(response.body);
      } else {
        Fluttertoast.showToast(msg: responseData["message"]);
        throw Exception('Failed to delete Insurance');
      }
    } catch (e) {
      throw Exception('Failed to delete Insurance: $e');
    }
  }

  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(Emails d)? getField) {
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
          'Page ${_currentPage + 1} of $numorpages',
          style: TextStyle(fontSize: 18),
        ),
        IconButton(
          icon: FaIcon(
            size: 30,
            FontAwesomeIcons.circleChevronRight,
            color: (_currentPage + 1) * _rowsPerPage >= _tableData.length
                ? Colors.grey
                : blueColor, // Change color based on availability
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

  ConnectivityResult? _connectivityResult;
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    //final themeProvider = Provider.of<ThemeProvider>(context);
    return _connectivityResult != ConnectivityResult.none
        ? SingleChildScrollView(
            child: Column(
              children: [
                if (MediaQuery.of(context).size.width < 500)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: FutureBuilder<TenantCommunation>(
                      future: futureEmailss,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ColabShimmerLoadingWidget();
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.totalPages == null) {
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
                          var data = snapshot.data!.emails;
                          if (selectedValue == null && searchvalue!.isEmpty) {
                            data = snapshot.data!.emails;
                          } else if (selectedValue == "All") {
                            data = snapshot.data!.emails;
                          } else if (searchvalue!.isNotEmpty) {
                            data = snapshot.data!.emails!
                                .where((property) => property.subject!
                                    .toLowerCase()
                                    .contains(searchvalue!.toLowerCase()))
                                .toList();
                          } else {
                            data = snapshot.data!.emails!
                                .where((property) =>
                                    property.subject == selectedValue)
                                .toList();
                          }
                          if (data!.isEmpty) {
                            return Center(
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
                            );
                          }
                          sortData(data);
                          final totalPages = snapshot.data!.totalPages;
                          final currentPageData = data;
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildHeaders(),
                                SizedBox(height: 20),
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
                                      bool isExpanded = expandedIndex == index;
                                      Emails Propertytype = entry.value;

                                      //return CustomExpansionTile(data: Propertytype, index: index);
                                      return Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 6),
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
                                                            expandedIndex =
                                                                null;
                                                          } else {
                                                            expandedIndex =
                                                                index;
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
                                                        child: Text(
                                                          Propertytype.rentalAddress
                                                                      ?.isNotEmpty ==
                                                                  true
                                                              ? '${Propertytype.rentalAddress}'
                                                              : 'N/A',
                                                          style: TextStyle(
                                                            color: blueColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .05),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        // '${widget.data.createdAt}',
                                                        // formatDate(
                                                        //     '${Propertytype.createdAt}'),
                                                        dateProvider
                                                            .formatCurrentDateTime(
                                                                '${Propertytype.createdAt}'),

                                                        style: TextStyle(
                                                          color: blueColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .01),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (isExpanded)
                                              Container(
                                                // padding: EdgeInsets.symmetric(
                                                //     horizontal: 2.0),
                                                // margin: EdgeInsets.only(
                                                //     bottom: 2),
                                                padding: EdgeInsets.all(16),
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
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          FaIcon(
                                                            isExpanded
                                                                ? FontAwesomeIcons
                                                                    .sortUp
                                                                : FontAwesomeIcons
                                                                    .sortDown,
                                                            size: 50,
                                                            color: Colors
                                                                .transparent,
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
                                                                            'Subject   :  ',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: blueColor), // Bold and black
                                                                      ),
                                                                      TextSpan(
                                                                        // text: formatDate(
                                                                        //     '${Propertytype.updatedAt}'),
                                                                        text: Propertytype.subject?.isNotEmpty ==
                                                                                true
                                                                            ? Propertytype.subject
                                                                            : 'N/A',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                            color: grey), // Light and grey
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                // Text.rich(
                                                                //   TextSpan(
                                                                //     children: [
                                                                //       TextSpan(
                                                                //         text:
                                                                //         'Opened  :  ',
                                                                //         style: TextStyle(
                                                                //             fontWeight: FontWeight.bold,
                                                                //             color: blueColor), // Bold and black
                                                                //       ),
                                                                //       TextSpan(
                                                                //         // text: formatDate(
                                                                //         //     '${Propertytype.updatedAt}'),
                                                                //         text: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.fromMillisecondsSinceEpoch(int.parse('${Propertytype.openedAt}')).toLocal())
                                                                //             ,
                                                                //         style: TextStyle(
                                                                //             fontWeight: FontWeight.w700,
                                                                //             color: grey), // Light and grey
                                                                //       ),
                                                                //     ],
                                                                //   ),
                                                                // ),
                                                                SizedBox(
                                                                  height: 15,
                                                                ),
                                                                Text.rich(
                                                                  TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            'Body : ',
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              blueColor, // Bold and black
                                                                        ),
                                                                      ),
                                                                      TextSpan(
                                                                        text: Propertytype.body!.isNotEmpty
                                                                            ? extractText(Propertytype.body!)
                                                                            : 'N/A',
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                          color:
                                                                              grey, // Light and grey
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  maxLines:
                                                                      1, // Restrict to 2 lines
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis, // Show "..." if the text is too long
                                                                ),
                                                                SizedBox(
                                                                  height: 15,
                                                                ),
                                                                Text.rich(
                                                                  TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            'Opened On : ',
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              blueColor,
                                                                        ),
                                                                      ),
                                                                      TextSpan(
                                                                        text: Propertytype.isOpened ??
                                                                                false
                                                                            ? (() {
                                                                                try {
                                                                                  final timestamp = int.parse(Propertytype.openedAt ?? Propertytype.createdAt!);
                                                                                  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
                                                                                  return DateFormat('yyyy-MM-dd hh:mm:ss a').format(date);
                                                                                } catch (e) {
                                                                                  return 'Date not available';
                                                                                }
                                                                              })()
                                                                            : 'Not Opened',
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                          color:
                                                                              grey,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  maxLines:
                                                                      1, // Restrict to 2 lines
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis, // Show "..." if the text is too long
                                                                ),
                                                                SizedBox(
                                                                  height: 15,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                _showDeleteAlert(
                                                                    context,
                                                                    Propertytype
                                                                        .emailId!);
                                                              },
                                                              child: Container(
                                                                height: 40,
                                                                decoration: BoxDecoration(
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
                                                                              FontWeight.bold),
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
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                _showAlert(
                                                                    context,
                                                                    Propertytype
                                                                        .emailId!,
                                                                    Propertytype);
                                                              },
                                                              child: Container(
                                                                height: 40,
                                                                decoration: BoxDecoration(
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
                                                                    Image.asset(
                                                                      'assets/icons/view.png',
                                                                      color:
                                                                          blueColor,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Text(
                                                                      "Details",
                                                                      style: TextStyle(
                                                                          color:
                                                                              blueColor,
                                                                          fontWeight:
                                                                              FontWeight.bold),
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
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<int>(
                                                value: itemsPerPage,
                                                items: itemsPerPageOptions
                                                    .map((int value) {
                                                  return DropdownMenuItem<int>(
                                                    value: value,
                                                    child:
                                                        Text(value.toString()),
                                                  );
                                                }).toList(),
                                                onChanged: snapshot.data!
                                                            .totalEmails! >
                                                        itemsPerPageOptions
                                                            .first // Condition to check if dropdown should be enabled
                                                    ? (newValue) {
                                                        setState(() {
                                                          itemsPerPage =
                                                              newValue!;
                                                          currentPage =
                                                              1; // Reset to first page when items per page change
                                                          futureEmailss = EmailLogRepository()
                                                              .fetchEmailLog(
                                                                  widget
                                                                      .lease_id!,
                                                                  page:
                                                                      currentPage,
                                                                  limit:
                                                                      itemsPerPage);
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
                                            color: currentPage == 1
                                                ? Colors.grey
                                                : blueColor,
                                          ),
                                          onPressed: currentPage == 1
                                              ? null
                                              : () {
                                                  setState(() {
                                                    currentPage--;
                                                    futureEmailss =
                                                        EmailLogRepository()
                                                            .fetchEmailLog(
                                                                widget
                                                                    .lease_id!,
                                                                page:
                                                                    currentPage,
                                                                limit:
                                                                    itemsPerPage);
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
                                            'Page ${currentPage} of $totalPages'),
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
                                            color: currentPage < totalPages!
                                                ? blueColor
                                                : Colors.grey,
                                          ),
                                          onPressed: currentPage < totalPages
                                              ? () {
                                                  setState(() {
                                                    currentPage++;
                                                    futureEmailss =
                                                        EmailLogRepository()
                                                            .fetchEmailLog(
                                                                widget
                                                                    .lease_id!,
                                                                page:
                                                                    currentPage,
                                                                limit:
                                                                    itemsPerPage);
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
          );
  }

  String extractText(String htmlString) {
    var document = htmlParser.parse(htmlString);
    return document.body?.text.trim().replaceAll(RegExp(r'\s+'), ' ') ?? '';
  }
}
