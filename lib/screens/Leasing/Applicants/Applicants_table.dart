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
import 'package:three_zero_two_property/screens/Leasing/Applicants/addApplicant.dart';
import 'package:three_zero_two_property/screens/Leasing/Applicants/editApplicant.dart';
import 'package:three_zero_two_property/screens/Property_Type/Edit_property_type.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

import '../../../model/ApplicantModel.dart';
import 'applicant_summery.dart';

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
                    const Text("Email", style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 5),
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
            await ApplicantRepository().DeleteApplicant(id: id);
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
            var data = ApplicantRepository().DeleteApplicant(id: id);
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

  Widget _buildDataCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 16),
        child: Text(text, style: const TextStyle(fontSize: 18)),
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
    final response =
        await http.get(Uri.parse('${Api_url}/api/applicant/limitation/$id'),headers: {"authorization" : "CRM $token","id":"CRM $id",});
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

  final _scrollController = ScrollController();
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
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo.png"),
              ),
              const SizedBox(height: 40),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.circle_grid_3x3,
                    color: Colors.black,
                  ),
                  "Dashboard",
                  false),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.house,
                    color: Colors.white,
                  ),
                  "Add Property Type",
                  true),
              buildListTile(context, const Icon(CupertinoIcons.person_add),
                  "Add Staff Member", false),
              buildDropdownListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.key,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Rental",
                  ["Properties", "RentalOwner", "Tenants"]),
              buildDropdownListTile(
                  context,
                  const FaIcon(
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            //add propertytype
            Padding(
              padding: const EdgeInsets.only(left: 13, right: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
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
                                builder: (context) => AddApplicant()));
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
                          ? 40
                          : MediaQuery.of(context).size.width * 0.065,

                      // height:  MediaQuery.of(context).size.width * 0.07,
                      // height:  40,
                      width: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(21, 43, 81, 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Add Applicant",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.034,
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

            titleBar(
              width: MediaQuery.of(context).size.width * .91,
              title: 'Applicants',
            ),
            const SizedBox(height: 10),
            //search
            // Padding(
            //   padding: const EdgeInsets.only(left: 13, right: 13),
            //   child: Row(
            //     children: [
            //       if (MediaQuery.of(context).size.width < 500)
            //         const SizedBox(width: 5),
            //       if (MediaQuery.of(context).size.width > 500)
            //         const SizedBox(width: 22),
            //       Material(
            //         elevation: 3,
            //         borderRadius: BorderRadius.circular(2),
            //         child: Container(
            //           padding: const EdgeInsets.symmetric(horizontal: 10),
            //           // height: 40,
            //           height: MediaQuery.of(context).size.width < 500 ? 40 : 50,
            //           width: MediaQuery.of(context).size.width < 500
            //               ? MediaQuery.of(context).size.width * .52
            //               : MediaQuery.of(context).size.width * .49,
            //           decoration: BoxDecoration(
            //               color: Colors.white,
            //               borderRadius: BorderRadius.circular(2),
            //               // border: Border.all(color: Colors.grey),
            //               border: Border.all(color: const Color(0xFF8A95A8))),
            //           child: Stack(
            //             children: [
            //               Positioned.fill(
            //                 child: TextField(
            //                   // onChanged: (value) {
            //                   //   setState(() {
            //                   //     cvverror = false;
            //                   //   });
            //                   // },
            //                   // controller: cvv,
            //                   onChanged: (value) {
            //                     setState(() {
            //                       searchvalue = value;
            //                     });
            //                   },
            //                   cursorColor: const Color.fromRGBO(21, 43, 81, 1),
            //                   decoration: const InputDecoration(
            //                     border: InputBorder.none,
            //                     hintText: "Search here...",
            //                     hintStyle: TextStyle(
            //                       // fontWeight: FontWeight.bold,
            //                       color: Color(0xFF8A95A8),
            //                     ),
            //                     // contentPadding:
            //                     //     EdgeInsets.symmetric(horizontal: 5),
            //                   ),
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //       const SizedBox(width: 15),
            //       // DropdownButtonHideUnderline(
            //       //   child: Material(
            //       //     elevation: 3,
            //       //     child: DropdownButton2<String>(
            //       //       isExpanded: true,
            //       //       hint: const Row(
            //       //         children: [
            //       //           SizedBox(
            //       //             width: 4,
            //       //           ),
            //       //           Expanded(
            //       //             child: Text(
            //       //               'Type',
            //       //               style: TextStyle(
            //       //                 fontSize: 14,
            //       //                 // fontWeight: FontWeight.bold,
            //       //                 color: Color(0xFF8A95A8),
            //       //               ),
            //       //               overflow: TextOverflow.ellipsis,
            //       //             ),
            //       //           ),
            //       //         ],
            //       //       ),
            //       //       items: items
            //       //           .map((String item) => DropdownMenuItem<String>(
            //       //                 value: item,
            //       //                 child: Text(
            //       //                   item,
            //       //                   style: const TextStyle(
            //       //                     fontSize: 14,
            //       //                     fontWeight: FontWeight.bold,
            //       //                     color: Colors.black,
            //       //                   ),
            //       //                   overflow: TextOverflow.ellipsis,
            //       //                 ),
            //       //               ))
            //       //           .toList(),
            //       //       value: selectedValue,
            //       //       onChanged: (value) {
            //       //         setState(() {
            //       //           selectedValue = value;
            //       //         });
            //       //       },
            //       //       buttonStyleData: ButtonStyleData(
            //       //         height:
            //       //             MediaQuery.of(context).size.width < 500 ? 40 : 50,
            //       //         // width: 180,
            //       //         width: MediaQuery.of(context).size.width < 500
            //       //             ? MediaQuery.of(context).size.width * .35
            //       //             : MediaQuery.of(context).size.width * .4,
            //       //         padding: const EdgeInsets.only(left: 14, right: 14),
            //       //         decoration: BoxDecoration(
            //       //           borderRadius: BorderRadius.circular(2),
            //       //           border: Border.all(
            //       //             // color: Colors.black26,
            //       //             color: const Color(0xFF8A95A8),
            //       //           ),
            //       //           color: Colors.white,
            //       //         ),
            //       //         elevation: 0,
            //       //       ),
            //       //       dropdownStyleData: DropdownStyleData(
            //       //         maxHeight: 200,
            //       //         width: 200,
            //       //         decoration: BoxDecoration(
            //       //           borderRadius: BorderRadius.circular(14),
            //       //           //color: Colors.redAccent,
            //       //         ),
            //       //         offset: const Offset(-20, 0),
            //       //         scrollbarTheme: ScrollbarThemeData(
            //       //           radius: const Radius.circular(40),
            //       //           thickness: MaterialStateProperty.all(6),
            //       //           thumbVisibility: MaterialStateProperty.all(true),
            //       //         ),
            //       //       ),
            //       //       menuItemStyleData: const MenuItemStyleData(
            //       //         height: 40,
            //       //         padding: EdgeInsets.only(left: 14, right: 14),
            //       //       ),
            //       //     ),
            //       //   ),
            //       // ),
            //     ],
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.only(left: 19, right: 13),
              child: Row(
                children: [
                  if (MediaQuery.of(context).size.width < 500)
                    const SizedBox(width: 2),
                  if (MediaQuery.of(context).size.width > 500)
                    const SizedBox(width: 22),
                  Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      // height: 40,
                      height: MediaQuery.of(context).size.width < 500 ? 40 : 50,
                      width: MediaQuery.of(context).size.width < 500
                          ? MediaQuery.of(context).size.width * .45
                          : MediaQuery.of(context).size.width * .4,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
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
                          // contentPadding: EdgeInsets.all(10),
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
                    const SizedBox(width: 10),
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
                      return const Center(
                        child: SpinKitFadingCircle(
                          color: Colors.black,
                          size: 40.0,
                        ),
                      );
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

                      sortData(data);
                      final totalPages = (data.length / itemsPerPage).ceil();
                      final currentPageData = data
                          .skip(currentPage * itemsPerPage)
                          .take(itemsPerPage)
                          .toList();
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            _buildHeaders(),
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          const Color.fromRGBO(21, 43, 83, 1))),
                              child: Column(
                                children: currentPageData
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  bool isExpanded = expandedIndex == index;
                                  Datum applicant = entry.value;
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color.fromRGBO(
                                              21, 43, 83, 1)),
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
                                                    onTap:(){
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                              applicant_summery(applicant_id: applicant.applicantId,)));
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
                                                    '${applicant.applicantEmail}',
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
                                                horizontal: 8.0),
                                            margin: const EdgeInsets.only(
                                                bottom: 20),
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
                                                                        'Phone Number : ',
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
                                                                    text: applicant.applicantPhoneNumber !=
                                                                            null
                                                                        ? applicant
                                                                            .applicantPhoneNumber
                                                                            .toString()
                                                                        : 'N/A',
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w700,
                                                                        color: Colors
                                                                            .grey),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 40,
                                                        child: Column(
                                                          children: [
                                                            IconButton(
                                                              icon:
                                                                  const FaIcon(
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
                                                                // handleEdit(applicant);
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
                                                                      () {});
                                                                }
                                                              },
                                                            ),
                                                            IconButton(
                                                              icon:
                                                                  const FaIcon(
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
                                                                // handleDelete(applicant);
                                                                _showDeleteAlert(
                                                                    context,
                                                                    applicant
                                                                        .applicantId!);
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
                    return const Center(
                      child: SpinKitFadingCircle(
                        color: Colors.black,
                        size: 55.0,
                      ),
                    );
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
                    totalrecords = _tableData.length;
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 5),
                              child: Column(
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .91,
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
                                                    .applicantFirstName!),
                                                _buildDataCell(_pagedData[i]
                                                    .applicantEmail!),
                                                _buildDataCell(
                                                  _pagedData[i]
                                                              .applicantHomeNumber ==
                                                          null
                                                      ? ''
                                                      : _pagedData[i]
                                                          .applicantHomeNumber!
                                                          .toString(),
                                                ),
                                                _buildDataCell(
                                                  _pagedData[i]
                                                              .applicantHomeNumber ==
                                                          null
                                                      ? ''
                                                      : _pagedData[i]
                                                          .applicantHomeNumber!
                                                          .toString(),
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
