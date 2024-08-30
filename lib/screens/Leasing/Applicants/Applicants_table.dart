import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:three_zero_two_property/Model/propertytype.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/repository/Property_type.dart';
import 'package:three_zero_two_property/repository/applicants.dart';
import 'package:three_zero_two_property/screens/Leasing/Applicants/Summary/applicant_summery2.dart';
import 'package:three_zero_two_property/screens/Leasing/Applicants/addApplicant.dart';
import 'package:three_zero_two_property/screens/Leasing/Applicants/editApplicant.dart';
import 'package:three_zero_two_property/screens/Property_Type/Edit_property_type.dart';
import 'package:three_zero_two_property/widgets/CustomTableShimmer.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

import '../../../model/ApplicantModel.dart';
import '../../../widgets/custom_drawer.dart';
class Applicants_table extends StatefulWidget {
  @override
  _Applicants_tableState createState() => _Applicants_tableState();
}

class _Applicants_tableState extends State<Applicants_table> {
  int totalrecords = 0;
  late Future<List<propertytype>> futurePropertyTypes;
  late Future<List<Datum>> futureApplicantdata;

  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  int currentPage = 0;
  int itemsPerPage = 10;
  List<int> itemsPerPageOptions = [
    10,
    25,
    50,
    100,
  ]; // Options for items per page

  void sortData(List<Datum> data) {
    if (sorting1) {
      data.sort((a, b) => ascending1
          ? a.applicantFirstName!.compareTo(b.applicantFirstName!)
          : b.applicantFirstName!.compareTo(a.applicantFirstName!));
    } else if (sorting2) {
      data.sort((a, b) => ascending2
          ? a.applicantLastName!.compareTo(b.applicantLastName!)
          : b.applicantLastName!.compareTo(a.applicantLastName!));
    } else if (sorting3) {
      data.sort((a, b) => ascending3
          ? a.applicantEmail!.compareTo(b.applicantEmail!)
          : b.applicantEmail!.compareTo(a.applicantEmail!));
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
        color: blueColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(13),
        ),
      ),
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
              child: const Icon(
                Icons.expand_less,
                color: Colors.transparent,
              ),
            ),
            Expanded(
              flex: 2,
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
                        ? const Text("Name",
                            style: TextStyle(color: Colors.white))
                        : const Text("Name",
                            style: TextStyle(color: Colors.white)),
                    // Text("Property", style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 3),
                    ascending1
                        ? const Padding(
                            padding: EdgeInsets.only(top: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.sortUp,
                              size: 20,
                              color: Colors.white,
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.only(bottom: 7, left: 2),
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
                     Text("    Phone Number", style: TextStyle(color: Colors.white,fontSize: 14)),
                     SizedBox(width: 5),
                    ascending2
                        ? const Padding(
                            padding: EdgeInsets.only(top: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.sortUp,
                              size: 20,
                              color: Colors.white,
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.only(bottom: 7, left: 2),
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
                    SizedBox(width: 15),
                    const Text("Status", style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 5),
                    ascending3
                        ? const Padding(
                            padding: EdgeInsets.only(top: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.sortUp,
                              size: 20,
                              color: Colors.white,
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.only(bottom: 7, left: 2),
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

  final List<String> items = ['Residential', "Commercial", "All"];
  String? selectedValue;
  String searchvalue = "";
  @override
  void initState() {
    super.initState();
    futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
    futureApplicantdata = ApplicantRepository().fetchApplicants();
    fetchapplicantadded();
  }

  void handleEdit(Datum applicant) async {
    // Handle edit action
    print('Edit ${applicant.applicantId}');
    var check = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditApplicant(
                  applicant: applicant,
                  applicantId: '',
                )));
    if (check == true) {
      setState(() {});
    }
    // final result = await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => Edit_property_type(
    //               property: property,
    //             )));
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
      desc: "Once deleted, you will not be able to recover this applicant!",
      style: const AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
        DialogButton(
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.grey,
        ),
        DialogButton(
          child: const Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            await ApplicantRepository().DeleteApplicant(Applicantid: id);
            setState(() {
              futureApplicantdata = ApplicantRepository().fetchApplicants();
            });
            fetchapplicantadded();
            Navigator.pop(context);
          },
          color: Colors.red,
        ),
      ],
    ).show();
  }

  void _showAlert(BuildContext context, String id) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this applicant!",
      style: const AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
        DialogButton(
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.grey,
        ),
        DialogButton(
          child: const Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            var data = ApplicantRepository().DeleteApplicant(Applicantid: id);
            // Add your delete logic here
            setState(() {
              futureApplicantdata = ApplicantRepository().fetchApplicants();
            });
            Navigator.pop(context);
          },
          color: Colors.red,
        )
      ],
    ).show();
  }

  List<Datum> _tableData = [];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<Datum> get _pagedData {
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

  void _sort<T>(Comparable<T> Function(Datum d) getField, int columnIndex,
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

  void handleDelete(Datum applicant) {
    _showAlert(context, applicant.applicantId!);
    // Handle delete action
    print('Delete ${applicant.applicantId}');
  }

  Widget _buildHeader<T>(
      String text, int columnIndex, Comparable<T> Function(Datum d)? getField) {
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

  Widget _buildDataCell(String text,Datum applicant) {
    return TableCell(
      child: InkWell(
        onTap: (){
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      applicant_summery(
                        applicant_id:
                        applicant
                            .applicantId,
                      )));
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 16),
          child: Text(text.isEmpty ? "N/A": text, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  Widget _buildActionsCell(Datum data) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SizedBox(
          height: 50,
          // color: Color.fromRGBO(21, 43, 83, 1),
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
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                icon: const Icon(
                  Icons.arrow_drop_down,
                  size: 40,
                ),
                style: const TextStyle(color: Colors.black, fontSize: 17),
                dropdownColor: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.circleChevronLeft,
            size: 30,
            color: _currentPage == 0
                ? Colors.grey
                : const Color.fromRGBO(21, 43, 83, 1),
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
          style: const TextStyle(fontSize: 18),
        ),
        IconButton(
          icon: FaIcon(
            size: 30,
            FontAwesomeIcons.circleChevronRight,
            color: (_currentPage + 1) * _rowsPerPage >= _tableData.length
                ? Colors.grey
                : const Color.fromRGBO(
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

  int applicantCountLimit = 0;
  int applicantCount = 0;
  Future<void> fetchapplicantadded() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await http
        .get(Uri.parse('${Api_url}/api/applicant/limitation/$id'), headers: {
      "authorization": "CRM $token",
      "id": "CRM $id",
    });
    final jsonData = json.decode(response.body);
    print(jsonData);
    if (jsonData["statusCode"] == 200 || jsonData["statusCode"] == 200) {
      print("error ${applicantCount}");
      print("error ${applicantCountLimit}");
      setState(() {
        applicantCount = jsonData['applicantCount'];

        print(applicantCount);
        applicantCountLimit = jsonData['applicantCountLimit'];
        print(applicantCountLimit);
      });
    } else {
      throw Exception('Failed to load data the count');
    }
  }

  void _showAlertforLimit(BuildContext context) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Plan Limitation",
      desc:
          "The limit for adding applicant according to the plan has been reached.",
      style: const AlertStyle(
          backgroundColor: Color.fromRGBO(255, 255, 255, 1),
          descStyle: TextStyle(fontSize: 14)
          //  overlayColor: Colors.black.withOpacity(.8)
          ),
      buttons: [
        DialogButton(
          child: const Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: const Color.fromRGBO(21, 43, 83, 1),
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

  final _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer:CustomDrawer(currentpage: "Applicants",dropdown: true,),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            //add propertytype
            Padding(
              padding: const EdgeInsets.only(left: 0, right: 0),
              child: Row(
               // mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: titleBar(
                      width: MediaQuery.of(context).size.width * .65,
                      title: 'Applicants',
                    ),
                  ),                  GestureDetector(
                    onTap: () async {
                      print(applicantCount);
                      print(applicantCountLimit);
                      // final result = await Navigator.of(context).push(MaterialPageRoute(
                      //     builder: (context) => Add_staffmember()));
                      // if (result == true) {
                      //   setState(() {
                      //     futureStaffMembers = StaffMemberRepository().fetchStaffmembers();
                      //   });
                      // }
                      if (applicantCount < applicantCountLimit) {
                        final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const AddApplicant()));
                        if (result == true) {
                          setState(() {
                            futureApplicantdata =
                                ApplicantRepository().fetchApplicants();
                          });
                          fetchapplicantadded();
                        }
                      } else {
                        _showAlertforLimit(context);
                      }
                    },
                    child: Container(
                      height: (MediaQuery.of(context).size.width < 500)
                          ? 50
                          : MediaQuery.of(context).size.width * 0.063,

                      // height:  MediaQuery.of(context).size.width * 0.07,
                      // height:  40,
                      width:  (MediaQuery.of(context).size.width < 500)
                          ? MediaQuery.of(context).size.width * 0.25
                          : MediaQuery.of(context).size.width * 0.2,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(21, 43, 81, 1),
                        borderRadius: BorderRadius.circular(5),
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
                                MediaQuery.of(context).size.width < 500
                                    ? 16
                                    : 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (MediaQuery.of(context).size.width < 500)
                    const SizedBox(width: 6),
                  if (MediaQuery.of(context).size.width > 500)
                    const SizedBox(width: 22),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.only(left: 11, right: 11),
              child: Row(
                children: [
                  if (MediaQuery.of(context).size.width < 500)
                    const SizedBox(width: 2),
                  if (MediaQuery.of(context).size.width > 500)
                    const SizedBox(width: 19),
                  Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      // height: 40,
                      height: MediaQuery.of(context).size.width < 500 ? 45 : 50,
                      width: MediaQuery.of(context).size.width < 500
                          ? MediaQuery.of(context).size.width * .45
                          : MediaQuery.of(context).size.width * .4,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF8A95A8)),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchvalue = value;
                          });
                        },
                        cursorColor: Colors.blue,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search here...",
                          hintStyle: TextStyle(color: Color(0xFF8A95A8)),
                           contentPadding: EdgeInsets.all(11),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        'Added : ${applicantCount.toString()}',
                        // 'Added : 5',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8A95A8),
                          fontSize:
                              MediaQuery.of(context).size.width < 500 ? 13 : 21,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      //  Text("rentalOwnerCountLimit: ${response['rentalOwnerCountLimit']}"),
                      Text(
                        'Total: ${applicantCountLimit.toString()}',
                        // 'Total: 10',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8A95A8),
                          fontSize:
                              MediaQuery.of(context).size.width < 500 ? 13 : 21,
                        ),
                      ),
                    ],
                  ),
                  if (MediaQuery.of(context).size.width < 500)
                    const SizedBox(width: 5),
                  if (MediaQuery.of(context).size.width > 500)
                    const SizedBox(width: 25),
                ],
              ),
            ),
            if (MediaQuery.of(context).size.width > 500)
              const SizedBox(height: 25),
            if (MediaQuery.of(context).size.width < 500)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: FutureBuilder<List<Datum>>(
                  future: futureApplicantdata,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ColabShimmerLoadingWidget();
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No data available'));
                    } else {
                      var data = snapshot.data!;

                      if (selectedValue == null && searchvalue.isEmpty) {
                        data = snapshot.data!;
                      } else if (selectedValue == "All") {
                        data = snapshot.data!;
                      } else if (searchvalue.isNotEmpty) {
                        data = snapshot.data!
                            .where((applicant) =>
                                applicant.applicantFirstName!
                                    .toLowerCase()
                                    .contains(searchvalue.toLowerCase()) ||
                                applicant.applicantLastName!
                                    .toLowerCase()
                                    .contains(searchvalue.toLowerCase()))
                            .toList();
                      } else {
                        data = snapshot.data!
                            .where((applicant) =>
                                applicant.applicantFirstName == selectedValue)
                            .toList();
                      }
                     // data = data.reversed.toList();
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
                            const SizedBox(height: 20),
                            Container(
                              // decoration: BoxDecoration(
                              //     border: Border.all(
                              //         color:
                              //             const Color.fromRGBO(21, 43, 83, 1))
                              // ),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Color.fromRGBO(152, 162, 179, .5))),
                              child: Column(
                                children: currentPageData
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  bool isExpanded = expandedIndex == index;
                                  Datum applicant = entry.value;
                                  return Container(
                                    // decoration: BoxDecoration(
                                    //   border: Border.all(
                                    //       color: const Color.fromRGBO(
                                    //           21, 43, 83, 1)),
                                    // ),
                                    decoration: BoxDecoration(
                                      color: index %2 != 0 ? Colors.white : blueColor.withOpacity(0.09),
                                      border: Border.all(color: Color.fromRGBO(152, 162, 179, .5)),
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
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 5),
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
                                                      color:
                                                          const Color.fromRGBO(
                                                              21, 43, 83, 1),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
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
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0),
                                                      child: Text(
                                                        '${applicant.applicantFirstName} ${applicant.applicantLastName}',
                                                        style: const TextStyle(
                                                          color: Color.fromRGBO(
                                                              21, 43, 83, 1),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13,
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
                                                  child: Text(
                                                    '${applicant.applicantPhoneNumber}',
                                                    style: const TextStyle(
                                                      color: Color.fromRGBO(
                                                          21, 43, 83, 1),
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

                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left:15.0),
                                                    child: Text(
                                                      '${applicant.applicantStatus != null && applicant.applicantStatus.isNotEmpty ? applicant.applicantStatus.first.status.toString() : 'N/A'}',
                                                      style: const TextStyle(
                                                        color: Color.fromRGBO(
                                                            21, 43, 83, 1),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 2.0),
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
                                                            Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  const TextSpan(
                                                                    text:
                                                                        'Email : ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            83,
                                                                            1)),
                                                                  ),
                                                                  TextSpan(
                                                                    text: applicant.applicantEmail !=
                                                                            null
                                                                        ? applicant
                                                                            .applicantEmail
                                                                            .toString()
                                                                        : 'N/A',
                                                                    style:  TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w700,
                                                                        color: grey),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      // SizedBox(
                                                      //   width: 40,
                                                      //   child: Column(
                                                      //     children: [
                                                      //       IconButton(
                                                      //         icon:
                                                      //             const FaIcon(
                                                      //           FontAwesomeIcons
                                                      //               .edit,
                                                      //           size: 20,
                                                      //           color: Color
                                                      //               .fromRGBO(
                                                      //                   21,
                                                      //                   43,
                                                      //                   83,
                                                      //                   1),
                                                      //         ),
                                                      //         onPressed:
                                                      //             () async {
                                                      //           // handleEdit(applicant);
                                                      //           var check = await Navigator.push(
                                                      //               context,
                                                      //               MaterialPageRoute(
                                                      //                   builder: (context) => EditApplicant(
                                                      //                         applicant: applicant,
                                                      //                         applicantId: applicant.applicantId!,
                                                      //                       )));
                                                      //           if (check ==
                                                      //               true) {
                                                      //             setState(
                                                      //                 () {
                                                      //              futureApplicantdata =     ApplicantRepository().fetchApplicants();
                                                      //                 });
                                                      //           }
                                                      //         },
                                                      //       ),
                                                      //       IconButton(
                                                      //         icon:
                                                      //             const FaIcon(
                                                      //           FontAwesomeIcons
                                                      //               .trashCan,
                                                      //           size: 20,
                                                      //           color: Color
                                                      //               .fromRGBO(
                                                      //                   21,
                                                      //                   43,
                                                      //                   83,
                                                      //                   1),
                                                      //         ),
                                                      //         onPressed: () {
                                                      //           // handleDelete(applicant);
                                                      //           _showDeleteAlert(
                                                      //               context,
                                                      //               applicant
                                                      //                   .applicantId
                                                      //                   .toString());
                                                      //         },
                                                      //       ),
                                                      //     ],
                                                      //   ),
                                                      // ),
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
                                                          onTap:()async{
                                                            var check = await Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => EditApplicant(
                                                                      applicant: applicant,
                                                                      applicantId: applicant.applicantId!,
                                                                    )));
                                                            if (check ==
                                                                true) {
                                                              setState(
                                                                      () {
                                                                    futureApplicantdata =     ApplicantRepository().fetchApplicants();
                                                                  });
                                                            }
                                                          },
                                                          child: Container(
                                                            height:40,
                                                            decoration: BoxDecoration(
                                                                color: Colors.grey[350]
                                                            ),                                               // color:Colors.grey[100],
                                                            child: Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment.center,
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment.center,
                                                              children: [
                                                                FaIcon(
                                                                  FontAwesomeIcons.edit,
                                                                  size: 15,
                                                                  color:blueColor,
                                                                ),
                                                                SizedBox(width: 10,),
                                                                Text("Edit",style: TextStyle(color: blueColor,fontWeight: FontWeight.bold),),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 5,),
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap:(){
                                                            _showDeleteAlert(
                                                                context,
                                                                applicant
                                                                    .applicantId
                                                                    .toString());
                                                          },
                                                          child: Container(
                                                            height:40,
                                                            decoration: BoxDecoration(
                                                                color: Colors.grey[350]
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment.center,
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment.center,
                                                              children: [
                                                                FaIcon(
                                                                  FontAwesomeIcons.trashCan,
                                                                  size: 15,
                                                                  color:blueColor,
                                                                ),
                                                                SizedBox(width: 10,),
                                                                Text("Delete",style: TextStyle(color: blueColor,fontWeight: FontWeight.bold),)
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 5,),
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        applicant_summery(
                                                                          applicant_id:
                                                                          applicant
                                                                              .applicantId,
                                                                        )));

                                                          },
                                                          child: Container(
                                                            height:40,
                                                            decoration: BoxDecoration(
                                                                color: Colors.grey[350]
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment.center,
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment.center,
                                                              children: [
                                                                SizedBox(width: 5,),
                                                                Image.asset('assets/icons/view.png'),
                                                                // FaIcon(
                                                                //   FontAwesomeIcons.trashCan,
                                                                //   size: 15,
                                                                //   color:blueColor,
                                                                // ),
                                                                SizedBox(width: 8,),
                                                                Text("View Summery",style: TextStyle(fontSize: 11,color: blueColor,fontWeight: FontWeight.bold),)
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
                                            : const Color.fromRGBO(
                                                21, 43, 83, 1),
                                      ),
                                      onPressed: currentPage == 0
                                          ? null
                                          : () {
                                              setState(() {
                                                currentPage--;
                                              });
                                            },
                                    ),
                                    Text(
                                        'Page ${currentPage + 1} of $totalPages'),
                                    IconButton(
                                      icon: FaIcon(
                                        FontAwesomeIcons.circleChevronRight,
                                        color: currentPage < totalPages - 1
                                            ? const Color.fromRGBO(
                                                21, 43, 83, 1)
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
              FutureBuilder<List<Datum>>(
                future: futureApplicantdata,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ShimmerTabletTable();
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data available'));
                  } else {
                    _tableData = snapshot.data!;
                    if (selectedValue == null && searchvalue.isEmpty) {
                      _tableData = snapshot.data!;
                    } else if (selectedValue == "All") {
                      _tableData = snapshot.data!;
                    } else if (searchvalue.isNotEmpty) {
                      _tableData = snapshot.data!
                          .where((applicant) =>
                              !applicant.applicantFirstName!
                                  .toLowerCase()
                                  .contains(searchvalue.toLowerCase()) ||
                              applicant.applicantLastName!
                                  .toLowerCase()
                                  .contains(searchvalue.toLowerCase()))
                          .toList();
                    } else {
                      _tableData = snapshot.data!
                          .where((applicant) =>
                              applicant.applicantFirstName == selectedValue)
                          .toList();
                    }
                    _tableData = _tableData.reversed.toList();
                    totalrecords = _tableData.length;
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40.0, vertical: 5),
                              child: Column(
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SizedBox(

                                      child: Table(
                                        defaultColumnWidth:
                                            const IntrinsicColumnWidth(),
                                        children: [
                                          TableRow(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  // color: blueColor
                                                  ),
                                            ),
                                            children: [
                                              // TableCell(child: Text('yash')),
                                              // TableCell(child: Text('yash')),
                                              // TableCell(child: Text('yash')),
                                              // TableCell(child: Text('yash')),
                                              // TableCell(child: Text('yash')),
                                              _buildHeader(
                                                  'Name',
                                                  0,
                                                  (property) => property
                                                      .applicantFirstName!),
                                              _buildHeader(
                                                  'Email',
                                                  1,
                                                  (property) =>
                                                      property.applicantEmail!),
                                              _buildHeader('Phone ..', 2, null),
                                              _buildHeader('Home ..', 3, null),
                                              _buildHeader('Actions', 4, null),
                                            ],
                                          ),
                                          TableRow(
                                            decoration: const BoxDecoration(
                                              border: Border.symmetric(
                                                  horizontal: BorderSide.none),
                                            ),
                                            children: List.generate(
                                                5,
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
                                                  left: const BorderSide(
                                                      color: Color.fromRGBO(
                                                          21, 43, 81, 1)),
                                                  right: const BorderSide(
                                                      color: Color.fromRGBO(
                                                          21, 43, 81, 1)),
                                                  top: const BorderSide(
                                                      color: Color.fromRGBO(
                                                          21, 43, 81, 1)),
                                                  bottom: i ==
                                                          _pagedData.length - 1
                                                      ? const BorderSide(
                                                          color: Color.fromRGBO(
                                                              21, 43, 81, 1))
                                                      : BorderSide.none,
                                                ),
                                              ),
                                              children: [
                                                // TableCell(child: Text('yash')),
                                                // TableCell(child: Text('yash')),
                                                // TableCell(child: Text('yash')),
                                                // TableCell(child: Text('yash')),
                                                // TableCell(child: Text('yash')),
                                                // Text(
                                                //     '${_pagedData[i].propertyType!}'),
                                                // Text(
                                                //     '${_pagedData[i].propertysubType!}'),
                                                // Text(
                                                //     '${formatDate(_pagedData[i].createdAt!)}'),
                                                // Text(
                                                //     '${formatDate(_pagedData[i].updatedAt!)}'),
                                                _buildDataCell(_pagedData[i]
                                                    .applicantFirstName!,_pagedData[i]),
                                                _buildDataCell(_pagedData[i]
                                                    .applicantEmail!,_pagedData[i]),
                                                _buildDataCell(
                                                  _pagedData[i]
                                                              .applicantHomeNumber ==
                                                          null
                                                      ? ''
                                                      : _pagedData[i]
                                                          .applicantHomeNumber!
                                                          .toString(),_pagedData[i]
                                                ),
                                                _buildDataCell(
                                                  _pagedData[i]
                                                              .applicantHomeNumber ==
                                                          null
                                                      ? ''
                                                      : _pagedData[i]
                                                          .applicantHomeNumber!
                                                          .toString(),_pagedData[i]
                                                ),
                                                // _buildDataCell(
                                                //   _pagedData[i]
                                                //       .applicantLastName!,
                                                // ),
                                                _buildActionsCell(
                                                    _pagedData[i]),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                  _buildPaginationControls(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
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
}
