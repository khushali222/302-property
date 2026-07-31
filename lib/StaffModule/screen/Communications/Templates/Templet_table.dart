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
import 'package:three_zero_two_property/widgets/CustomTableShimmer.dart';
import '../../../widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import 'package:html/parser.dart' as htmlParser;

import '../../../../Model/Comunication_model/templet.dart';
import '../../../../constant/constant.dart';
import '../../../repository/Communication/Templet_Repo.dart';
import '../../../widgets/custom_drawer.dart';
import 'Add_mail.dart';

class TempletTable extends StatefulWidget {
  @override
  _TempletTableState createState() => _TempletTableState();
}

class _TempletTableState extends State<TempletTable> {
  late Future<List<EmailTemplate>> futureTemplet;
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

  void sortData(List<EmailTemplate> data) {
    if (sorting1) {
      data.sort((a, b) =>
          ascending1 ? a.name!.compareTo(b.name!) : b.name!.compareTo(a.name!));
    } else if (sorting2) {
      data.sort((a, b) =>
          ascending2 ? a.type!.compareTo(b.type!) : b.type!.compareTo(a.type!));
    } else if (sorting3) {
      data.sort((a, b) => ascending3
          ? a.subject!.compareTo(b.subject!)
          : b.subject!.compareTo(a.subject!));
    }
  }

  Widget _buildHeaders() {
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFF4F8FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFDBE0E5))),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: const Icon(
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
                            style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18))
                        : Text("Name",
                            style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                    // Text("Property", style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 3),
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
                    const SizedBox(width: 15),
                    Text("Type",
                        style: TextStyle(
                            color: blueColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    const SizedBox(width: 5),
                    ascending2
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
          ],
        ),
      ),
    );
  }

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
    futureTemplet = TempletRepository().fetchTemplets();
  }

  List<EmailTemplate> _tableData = [];
  int totalrecords = 0;
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<EmailTemplate> get _pagedData {
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

  void _sort<T>(Comparable<T> Function(EmailTemplate d) getField,
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

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
  }
  // void handleEdit(EmailTemplate rentalOwner) async {
  //   // Handle edit action
  //   print('Edit ${rentalOwner.rentalownerId}');
  //   var check = await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => Edit_rentalowners(
  //             rentalOwner: rentalOwner,
  //           )));
  //   if (check == true) {
  //     setState(() {});
  //   }
  //   // final result = await Navigator.push(
  //   //     context,
  //   //     MaterialPageRoute(
  //   //         builder: (context) => Edit_rentalowners(rentalOwner: rentalOwner,)));
  //   /* if (result == true) {
  //     setState(() {
  //       futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
  //     });
  //   }*/
  // }

  void _showDeleteAlert(BuildContext context, String id) {
    TextEditingController reason = TextEditingController();
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this template",
      content: Column(
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 45,
            child: TextField(
              controller: reason,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter reason for deletion',
                  contentPadding: EdgeInsets.only(top: 8, left: 15)),
            ),
          ),
        ],
      ),
      style: const AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
        DialogButton(
          child: const Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            if (reason.text.isEmpty) {
              Fluttertoast.showToast(msg: "Please enter a reason for deletion");
            } else {
              await TempletRepository()
                  .DeleteTemplet(reason: reason.text, id: id);
              setState(() {
                futureTemplet = TempletRepository().fetchTemplets();
              });

              Navigator.pop(context);
            }
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

  // void handleDelete(EmailTemplate rental) {
  //   _showDeleteAlert(context, rental.rentalownerId!);
  //   // Handle delete action
  //   print('Delete ${rental.rentalownerId}');
  // }
  //
  // final _scrollController = ScrollController();
  // void handleTap(EmailTemplate rental) async {
  //   // Handle edit action
  //   print('Edit ${rental.rentalownerId}');
  //   final result = await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => ResponsiveRentalSummary(
  //             rentalowners: rental,
  //             rentalOwnersid: '',
  //           )));
  //   /* if (result == true) {
  //     setState(() {
  //       futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
  //     });
  //   }*/
  // }

  String stripHtmlTags(String htmlText) {
    final RegExp exp =
        RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return htmlText.replaceAll(exp, '');
  }

  @override
  Widget build(BuildContext context) {
    // final dateProvider = Provider.of<DateProvider>(context);
    //final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: widget_302_Staff.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawerStaff(
        currentpage: "Templates",
        dropdown: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            // Header Section with Title and Add Button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Padding(
                        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width > 500? 12 : 0,right:  MediaQuery.of(context).size.width > 500? 12 : 0),
                        child: titleBar(
                          width: double.infinity,
                          title: 'Templates',
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: GestureDetector(
                        onTap: () async {
                          final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => Add_Email_templet()));
                          if (result == true) {
                            setState(() {
                              futureTemplet =
                                  TempletRepository().fetchTemplets();
                            });
                          }
                        },
                        child: Container(
                          height: (MediaQuery.of(context).size.width < 768)
                              ? 50
                              : 60,
                          decoration: BoxDecoration(
                            color: blueColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              "+ Add",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // if (MediaQuery.of(context).size.width > 500)
            //   const SizedBox(height: 25),
            // if (MediaQuery.of(context).size.width < 500)
              Padding(
                padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width < 500 ? 11 : 28),
                child: FutureBuilder<List<EmailTemplate>>(
                  future: futureTemplet,
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
                              const SizedBox(
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
                            .where((rentals) =>
                                rentals.name!
                                    .toLowerCase()
                                    .contains(searchValue!.toLowerCase()) ||
                                rentals.subject!
                                    .toLowerCase()
                                    .contains(searchValue!.toLowerCase()))
                            .toList();
                      } else {
                        data = snapshot.data!
                            .where((rentals) => rentals.name == searchValue)
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
                            const SizedBox(height: 10),
                            _buildHeaders(),
                            const SizedBox(height: 10),
                            Container(
                              child: Column(
                                children: currentPageData
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  bool isExpanded = expandedIndex == index;
                                  EmailTemplate rentals = entry.value;
                                  //  print(rentals.body);
                                  //return CustomExpansionTile(data: Propertytype, index: index);
                                  return Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      color: index % 2 != 0
                                          ? const Color(0xFFF4F8FF)
                                          : Colors.white,
                                      border: Border.all(
                                          color: const Color(0xFFDBE0E5)),
                                      borderRadius: BorderRadius.circular(10),
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
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 5, right: 5),
                                                    padding: !isExpanded
                                                        ? const EdgeInsets.only(
                                                            bottom: 10)
                                                        : const EdgeInsets.only(
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
                                                      rentals.name!.isEmpty
                                                          ? 'N/A'
                                                          : '${rentals.name}',
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
                                                    rentals.type!.isEmpty
                                                        ? 'N/A'
                                                        : '${rentals.type}',
                                                    // rentals.rentalOwnerPhoneNumber!.isEmpty ? 'N/A' :
                                                    // '${rentals.rentalOwnerPhoneNumber}',
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 2),
                                            margin: const EdgeInsets.only(
                                                bottom: 2),
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
                                                                        'Subject : ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color:
                                                                            blueColor), // Bold and black
                                                                  ),
                                                                  TextSpan(
                                                                    text: rentals
                                                                            .subject!
                                                                            .isEmpty
                                                                        ? 'N/A'
                                                                        : '${rentals.subject}',
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
                                                            Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        'Body : ',
                                                                    style:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          blueColor, // Bold and black
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: rentals
                                                                            .body!
                                                                            .isEmpty
                                                                        ? 'N/A'
                                                                        : extractText(
                                                                            rentals.body!),
                                                                    style:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color:
                                                                          grey, // Light and grey
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              maxLines:
                                                                  1, // Restrict to 2 lines
                                                              overflow: TextOverflow
                                                                  .ellipsis, // Show "..." if the text is too long
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
                                                      const SizedBox(
                                                        width: 2,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            var check = await Navigator
                                                                    .of(context)
                                                                .push(
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            Add_Email_templet(
                                                                              templetid: rentals.templateId,
                                                                            )));
                                                            if (check == true) {
                                                              setState(() {
                                                                futureTemplet =
                                                                    TempletRepository()
                                                                        .fetchTemplets();
                                                              });
                                                            }
                                                          },
                                                          child: Container(
                                                            height: 40,
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .green,
                                                                  width: 1.5),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child: const Row(
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
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  "Edit",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .green,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            _showDeleteAlert(
                                                                context,
                                                                rentals
                                                                    .templateId!);
                                                          },
                                                          child: Container(
                                                            height: 40,
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .red,
                                                                  width: 1.5),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child: const Row(
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
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  "Delete",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red,
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
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    // Text('Rows per page:'),
                                    const SizedBox(width: 10),
                                    Material(
                                      elevation: 3,
                                      child: Container(
                                        height: 40,
                                        padding: const EdgeInsets.symmetric(
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
                                            : blueColor,
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
                                            ? blueColor
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
    );
  }

  String extractText(String htmlString) {
    var document = htmlParser.parse(htmlString);
    return document.body?.text.trim().replaceAll(RegExp(r'\s+'), ' ') ?? '';
  }
}

void main() => runApp(MaterialApp(home: TempletTable()));
