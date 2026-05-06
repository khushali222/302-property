import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:three_zero_two_property/Model/propertytype.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import '../../../model/staffpermission.dart';
import '../../../repository/Property_type.dart';
import '../../../repository/applicants.dart';
import '../../../repository/staffpermission_provider.dart';
import 'Summary/applicant_summery2.dart';
import 'addApplicant.dart';
import 'editApplicant.dart';
import 'package:three_zero_two_property/screens/Property_Type/Edit_property_type.dart';
import 'package:three_zero_two_property/widgets/CustomTableShimmer.dart';
import '../../../widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

import '../../../../model/ApplicantModel.dart';
import '../../../widgets/custom_drawer.dart';

class Applicants_table extends StatefulWidget {
  @override
  _Applicants_tableState createState() => _Applicants_tableState();
}

class _Applicants_tableState extends State<Applicants_table>
    with TickerProviderStateMixin {
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
          color: Color(0xFFF4F8FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFFDBE0E5))),
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
                        ? Text("Name",
                            style: TextStyle(
                                color: blueColor, fontWeight: FontWeight.bold))
                        : Text("Name",
                            style: TextStyle(
                                color: blueColor, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 3),
                    ascending1
                        ? Padding(
                            padding: EdgeInsets.only(top: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.sortUp,
                              size: 20,
                              color: blueColor,
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.only(bottom: 7, left: 2),
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
                    Text("   Phone Number",
                        style: TextStyle(
                            color: blueColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    SizedBox(width: 5),
                    ascending2
                        ? Padding(
                            padding: EdgeInsets.only(top: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.sortUp,
                              size: 20,
                              color: blueColor,
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.only(bottom: 7, left: 2),
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
                    Text("Status",
                        style: TextStyle(
                            color: blueColor, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 5),
                    ascending3
                        ? Padding(
                            padding: EdgeInsets.only(top: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.sortUp,
                              size: 20,
                              color: blueColor,
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.only(bottom: 7, left: 2),
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

  final List<String> items = ['Approved', "Rejected", 'Undecided', "All"];
  String? selectedValue = "Undecided";
  String searchvalue = "";

  // Date filter options ('All' shows all dates; 'All Time' kept for backwards compatibility)
  final List<String> dateFilterItems = [
    'All',
    'Last 15 Days',
    'Last 30 Days',
    'Last 45 Days',
    'Last 60 Days',
    'All Time'
  ];
  String? selectedDateFilter = "All";
  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        print(result);
        _connectivityResult = result;
      });
    });
    checkInternet();
    Provider.of<StaffPermissionProvider>(context, listen: false)
        .fetchPermissions();
    futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
    futureApplicantdata = ApplicantRepository().fetchApplicants();
    fetchapplicantadded();
    // NEW
    _tabController = TabController(length: 2, vsync: this);
    fetchPendingInvites();
    fetchDeletedInvites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  ConnectivityResult? _connectivityResult;

  // ── Tab controller ──
  late TabController _tabController;

  // ── Pending & Deleted invites state ──
  List<Map<String, dynamic>> _pendingInvites = [];
  List<Map<String, dynamic>> _deletedInvites = [];
  bool _loadingPending = true;
  bool _loadingDeleted = true;
  int? _expandedPendingIndex;
  int? _expandedDeletedIndex;
  String _pendingSearch = '';
  String _deletedSearch = '';

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
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
    TextEditingController reason = TextEditingController();
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this applicant!",
      style: const AlertStyle(
        backgroundColor: Colors.white,
      ),
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
              await ApplicantRepository()
                  .DeleteApplicant(Applicantid: id, reason: reason.text);
              setState(() {
                futureApplicantdata = ApplicantRepository().fetchApplicants();
              });
              fetchapplicantadded();
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
    if (applicant.applicantId != null) {
      _showDeleteAlert(context, applicant.applicantId!);
    }
    // _showAlert(context, applicant.applicantId!);
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

  Widget _buildDataCell(String text, Datum applicant) {
    return TableCell(
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => applicant_summery(
                        applicant_id: applicant.applicantId,
                      )));
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 16),
          child: Text(text.isEmpty ? "N/A" : text,
              style: const TextStyle(fontSize: 18)),
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
          // color: blueColor,
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
          style: const TextStyle(fontSize: 18),
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

  int applicantCountLimit = 0;
  int applicantCount = 0;
  Future<void> fetchapplicantadded() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    final response = await http.get(
        Uri.parse('${Api_url}/api/applicant/limitation/$adminid'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        });
    final jsonData = json.decode(response.body);
    print(jsonData);
    if (jsonData["statusCode"] == 200 || jsonData["statusCode"] == 201) {
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

  // ── NEW fetch methods + builders (same as admin module) ──
  Future<void> fetchPendingInvites() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("adminId");
      String? token = prefs.getString('token');
      final response = await http.get(
          Uri.parse('${Api_url}/api/applicant/pending-invites/$id'),
          headers: {"authorization": "CRM $token", "id": "CRM $id"});
      final jsonData = json.decode(response.body);
      if ((jsonData["statusCode"] == 200 || jsonData["statusCode"] == 201) &&
          jsonData["data"] != null) {
        if (mounted)
          setState(() {
            _pendingInvites =
                List<Map<String, dynamic>>.from(jsonData["data"]);
            _loadingPending = false;
          });
      } else {
        if (mounted) setState(() => _loadingPending = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loadingPending = false);
    }
  }

  Future<void> fetchDeletedInvites() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("adminId");
      String? token = prefs.getString('token');
      final response = await http.get(
          Uri.parse('${Api_url}/api/applicant/deleted-invites/$id'),
          headers: {"authorization": "CRM $token", "id": "CRM $id"});
      final jsonData = json.decode(response.body);
      if ((jsonData["statusCode"] == 200 || jsonData["statusCode"] == 201) &&
          jsonData["data"] != null) {
        if (mounted)
          setState(() {
            _deletedInvites =
                List<Map<String, dynamic>>.from(jsonData["data"]);
            _loadingDeleted = false;
          });
      } else {
        if (mounted) setState(() => _loadingDeleted = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loadingDeleted = false);
    }
  }

  Future<void> _resendInviteEmail(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? adminId = prefs.getString('adminId');
      final String? token = prefs.getString('token');
      if (adminId == null || token == null) return;
      final response = await http.post(
        Uri.parse('$Api_url/api/applicant/invite'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'CRM $token',
          'id': 'CRM $adminId',
        },
        body: jsonEncode({
          'emails': [trimmed],
          'admin_id': adminId,
          'forceResend': true,
          'is_web': true,
          'user_active_recently': true,
        }),
      );
      final dynamic jsonData = json.decode(response.body);
      if (!mounted) return;
      final bool ok = response.statusCode == 200 ||
          (jsonData is Map &&
              (jsonData['statusCode'] == 200 ||
                  jsonData['statusCode'] == 201));
      if (ok) {
        final msg = jsonData is Map && jsonData['message'] != null
            ? jsonData['message'].toString()
            : 'Invitation sent successfully.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.green),
        );
        await fetchPendingInvites();
      } else {
        final err = jsonData is Map && jsonData['message'] != null
            ? jsonData['message'].toString()
            : 'Failed to resend invitation.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: Colors.red),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to resend invitation.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatInviteDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('MM/dd/yyyy').format(dt);
    } catch (_) {
      return raw.split(' ').first;
    }
  }

  Widget _buildInviteSearchField(ValueChanged<String> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDBE0E5)),
      ),
      child: TextField(
        onChanged: onChanged,
        cursorColor: blueColor,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(fontSize: 13, height: 1.25),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: 'Search by email...',
          hintStyle:
              const TextStyle(color: Color(0xFF8A95A8), fontSize: 13),
          prefixIcon:
              Icon(Icons.search, color: blueColor, size: 20),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 44, minHeight: 44),
          contentPadding:
              const EdgeInsets.only(right: 14, top: 12, bottom: 12),
        ),
      ),
    );
  }

  Widget _buildPendingHeader() {
    final cellHeader =
        TextStyle(color: blueColor, fontWeight: FontWeight.bold, fontSize: 12);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDBE0E5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 30),
            Expanded(flex: 3, child: Text('Email', style: cellHeader)),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Text(
                'Invited Date',
                style: cellHeader,
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildDeletedHeader() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDBE0E5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 30),
            Expanded(
              flex: 3,
              child: Text('Email',
                  style: TextStyle(
                      color: blueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: Text('Deleted By',
                  style: TextStyle(
                      color: blueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  // ── pending expand list ──
  Widget _buildPendingList() {
    final filtered = _pendingSearch.isEmpty
        ? _pendingInvites
        : _pendingInvites
            .where((p) => (p['email'] ?? '')
                .toString()
                .toLowerCase()
                .contains(_pendingSearch.toLowerCase()))
            .toList();

    if (_loadingPending)
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(20), child: CircularProgressIndicator()));

    if (filtered.isEmpty)
      return Container(
          height: 100,
          child: Center(
              child: Text("No pending invites",
                  style: TextStyle(
                      color: blueColor, fontWeight: FontWeight.bold))));

    return Column(
      children: filtered.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> invite = entry.value;
        bool isRowExpanded = _expandedPendingIndex == index;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: index % 2 != 0 ? const Color(0xFFF4F8FF) : Colors.white,
            border: Border.all(color: const Color(0xFFDBE0E5)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => setState(() =>
                    _expandedPendingIndex = isRowExpanded ? null : index),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 13),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 5, right: 5),
                        padding: !isRowExpanded
                            ? const EdgeInsets.only(bottom: 10)
                            : const EdgeInsets.only(top: 10),
                        child: FaIcon(
                          isRowExpanded
                              ? FontAwesomeIcons.sortUp
                              : FontAwesomeIcons.sortDown,
                          size: 20,
                          color: blueColor,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          invite['email'] ?? 'N/A',
                          style: TextStyle(
                              color: blueColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                          softWrap: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _formatInviteDate(invite['invited_date']),
                          style: TextStyle(
                              color: blueColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                          softWrap: true,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ),
              if (isRowExpanded)
                Padding(
                  padding: const EdgeInsets.only(
                      left: 36, right: 8, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => _resendInviteEmail(
                            '${invite['email'] ?? ''}'),
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: FaIcon(FontAwesomeIcons.envelope,
                                size: 15, color: blueColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: FaIcon(FontAwesomeIcons.trashCan,
                                size: 15, color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── deleted expand list ──
  Widget _buildDeletedList() {
    final filtered = _deletedSearch.isEmpty
        ? _deletedInvites
        : _deletedInvites
            .where((d) =>
                (d['email'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains(_deletedSearch.toLowerCase()) ||
                (d['deleted_by'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains(_deletedSearch.toLowerCase()))
            .toList();

    if (_loadingDeleted)
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(20), child: CircularProgressIndicator()));

    if (filtered.isEmpty)
      return Container(
          height: 100,
          child: Center(
              child: Text("No deleted invitations",
                  style: TextStyle(
                      color: blueColor, fontWeight: FontWeight.bold))));

    return Column(
      children: filtered.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> invite = entry.value;
        bool isRowExpanded = _expandedDeletedIndex == index;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: index % 2 != 0 ? const Color(0xFFF4F8FF) : Colors.white,
            border: Border.all(color: const Color(0xFFDBE0E5)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => setState(() =>
                    _expandedDeletedIndex = isRowExpanded ? null : index),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 13),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 5, right: 5),
                        padding: !isRowExpanded
                            ? const EdgeInsets.only(bottom: 10)
                            : const EdgeInsets.only(top: 10),
                        child: FaIcon(
                          isRowExpanded
                              ? FontAwesomeIcons.sortUp
                              : FontAwesomeIcons.sortDown,
                          size: 20,
                          color: blueColor,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          invite['email'] ?? 'N/A',
                          style: TextStyle(
                              color: blueColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                          softWrap: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: Text(
                          invite['deleted_by'] ?? 'N/A',
                          style: TextStyle(
                              color: blueColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                          softWrap: true,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ),
              if (isRowExpanded)
                Padding(
                  padding: const EdgeInsets.only(
                      left: 36, right: 8, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text.rich(TextSpan(children: [
                        TextSpan(
                          text: 'Deleted Date : ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: blueColor),
                        ),
                        TextSpan(
                          text: _formatInviteDate(invite['deleted_at']),
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: grey),
                        ),
                      ])),
                      const SizedBox(height: 4),
                      Text.rich(TextSpan(children: [
                        TextSpan(
                          text: 'Reason : ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: blueColor),
                        ),
                        TextSpan(
                          text: invite['reason'] ?? 'N/A',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: grey),
                        ),
                      ])),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  final _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final permissionProvider = Provider.of<StaffPermissionProvider>(context);
    StaffPermission? permissions = permissionProvider.permissions;
    return Scaffold(
      appBar: widget_302_Staff.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawerStaff(
        currentpage: "Applicants",
        dropdown: true,
      ),
      body: _connectivityResult != ConnectivityResult.none
          ? Column(
              children: [
                  const SizedBox(
                    height: 20,
                  ),
                  //add propertytype
                  // Header Section with Title and Add Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        if (MediaQuery.of(context).size.width > 500)
                          SizedBox(
                            width: 13,
                          ),
                        Expanded(
                          flex: permissions!.applicantAdd! ? 2 : 1,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: titleBar(
                              width: double.infinity,
                              title: 'Applicants',
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                            child: GestureDetector(
                              onTap: () async {
                                final result = await Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AddApplicant()));
                                if (result == true) {
                                  setState(() {
                                    futureApplicantdata =
                                        ApplicantRepository().fetchApplicants();
                                  });
                                }
                              },
                              child: Container(
                                height:
                                    (MediaQuery.of(context).size.width < 768)
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
                       Flexible(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: GestureDetector(
                              onTap: () async {
                                _showInviteApplicantsDialog();
                              },
                              child: Container(
                                height:
                                    (MediaQuery.of(context).size.width < 768)
                                        ? 50
                                        : 60,
                                decoration: BoxDecoration(
                                  color: blueColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.mail_outline,
                                          color: Colors.white, size: 16),
                                      SizedBox(width: 3),
                                      Text(
                                        " Invite",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
             
                     if (MediaQuery.of(context).size.width > 500)
                          SizedBox(width: 13),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  /* ── TabBar: Applicants / Pending — kept for future use; uncomment block and remove/disable day filter Padding below when restoring ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F8FF),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: const Color(0xFFDBE0E5)),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: false,
                        dividerColor: Colors.transparent,
                        splashBorderRadius: BorderRadius.circular(10),
                        labelColor: blueColor,
                        unselectedLabelColor: const Color(0xFF8A95A8),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorPadding:
                            const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 2),
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFDBE0E5)),
                          boxShadow: [
                            BoxShadow(
                              color: blueColor.withOpacity(0.07),
                              blurRadius: 5,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        labelPadding: EdgeInsets.zero,
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13),
                        unselectedLabelStyle: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13),
                        tabs: [
                          const Tab(height: 44, text: 'Applicants'),
                          Tab(
                            height: 44,
                            child: AnimatedBuilder(
                              animation: _tabController,
                              builder: (context, _) {
                                final selected = _tabController.index == 1;
                                final c = selected
                                    ? blueColor
                                    : const Color(0xFF8A95A8);
                                final w = selected
                                    ? FontWeight.w700
                                    : FontWeight.w500;
                                return Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Pending Applicants',
                                          style: TextStyle(
                                            color: c,
                                            fontWeight: w,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 7,
                                              vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _pendingInvites.isEmpty
                                                ? const Color(0xFF8A95A8)
                                                : blueColor,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '${_pendingInvites.length}',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  */

                  const SizedBox(height: 8),

                  // ── TabBarView ──
                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _tabController,
                      children: [
                        // TAB 1 — Applicants (existing)
                        SingleChildScrollView(
                          child: Column(
                            children: [

                  // Date filter + Status filter dropdowns — shown FIRST
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 11, right: 11),
                    child: Row(
                      children: [
                        if (MediaQuery.of(context).size.width < 500)
                          const SizedBox(width: 2),
                        if (MediaQuery.of(context).size.width > 500)
                          const SizedBox(width: 19),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: Material(
                              elevation: 0,
                              color: Colors.transparent,
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
                                        'Time Range',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF8A95A8),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                items: dateFilterItems
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
                                value: selectedDateFilter,
                                onChanged: (value) {
                                  setState(() {
                                    selectedDateFilter = value;
                                    if (currentPage != 0) currentPage = 0;
                                  });
                                },
                                buttonStyleData: ButtonStyleData(
                                  height:
                                      MediaQuery.of(context).size.width < 500
                                          ? 45
                                          : 50,
                                  padding: const EdgeInsets.only(
                                      left: 14, right: 14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFDBE0E5),
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
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: Material(
                              elevation: 0,
                              color: Colors.transparent,
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
                                        'Type',
                                        style: TextStyle(
                                          fontSize: 14,
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
                                    if (currentPage != 0) currentPage = 0;
                                  });
                                },
                                buttonStyleData: ButtonStyleData(
                                  height:
                                      MediaQuery.of(context).size.width < 500
                                          ? 45
                                          : 50,
                                  padding: const EdgeInsets.only(
                                      left: 14, right: 14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFDBE0E5),
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
                        if (MediaQuery.of(context).size.width < 500)
                          const SizedBox(width: 2),
                        if (MediaQuery.of(context).size.width > 500)
                          const SizedBox(width: 25),
                      ],
                    ),
                  ),

                  // Search bar — shown BELOW the filter dropdowns
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 11, right: 11),
                    child: Row(
                      children: [
                        if (MediaQuery.of(context).size.width < 500)
                          const SizedBox(width: 2),
                        if (MediaQuery.of(context).size.width > 500)
                          const SizedBox(width: 19),
                        Expanded(
                          child: Material(
                            elevation: 0,
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              height: MediaQuery.of(context).size.width < 500
                                  ? 45
                                  : 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFFDBE0E5)),
                              ),
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    searchvalue = value;
                                    if (currentPage != 0) currentPage = 0;
                                  });
                                },
                                cursorColor: Colors.blue,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Search here...",
                                  hintStyle:
                                      TextStyle(color: Color(0xFF8A95A8)),
                                  contentPadding: EdgeInsets.all(11),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (MediaQuery.of(context).size.width < 500)
                          const SizedBox(width: 2),
                        if (MediaQuery.of(context).size.width > 500)
                          const SizedBox(width: 25),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width < 500 ? 11 : 28),
                    child: FutureBuilder<List<Datum>>(
                      future: futureApplicantdata,
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

                          if (selectedValue == null && searchvalue.isEmpty) {
                            data = snapshot.data!;
                          } else if (selectedValue == "All") {
                            data = snapshot.data!;
                          } else if (searchvalue.isNotEmpty) {
                            data = snapshot.data!
                                .where((applicant) =>
                                    (applicant.applicantFirstName?.toLowerCase() ?? '')
                                        .contains(searchvalue.toLowerCase()) ||
                                    (applicant.applicantLastName?.toLowerCase() ?? '')
                                        .contains(searchvalue.toLowerCase()) ||
                                    (applicant.applicantPhoneNumber
                                                ?.toLowerCase() ??
                                            '')
                                        .contains(searchvalue.toLowerCase()) ||
                                    (applicant.applicantEmail?.toLowerCase() ?? '')
                                        .contains(searchvalue.toLowerCase()) ||
                                    (applicant.rentalData?.rentalAdress
                                                ?.toLowerCase() ??
                                            '')
                                        .contains(searchvalue.toLowerCase()) ||
                                    (applicant.applicantStatus.isNotEmpty &&
                                        applicant.applicantStatus.last.status
                                            .toString()
                                            .toLowerCase()
                                            .contains(searchvalue.toLowerCase())))
                                .toList();
                          } else {
                            data = snapshot.data!.where((applicant) {
                              // If "Undecided" is selected, include applicants with no status
                              if (selectedValue == "Undecided") {
                                return applicant.applicantStatus == null ||
                                    applicant.applicantStatus.isEmpty;
                              }

                              return applicant.applicantStatus.isNotEmpty &&
                                  applicant.applicantStatus.last.status ==
                                      selectedValue;
                            }).toList();
                          }

                          // Apply date filter (15, 30, 45, 60 days; skip for All / All Time)
                          if (selectedDateFilter != null &&
                              selectedDateFilter != "All Time" &&
                              selectedDateFilter != "All") {
                            int? daysAgo;
                            if (selectedDateFilter == "Last 15 Days") {
                              daysAgo = 15;
                            } else if (selectedDateFilter == "Last 30 Days") {
                              daysAgo = 30;
                            } else if (selectedDateFilter == "Last 45 Days") {
                              daysAgo = 45;
                            } else if (selectedDateFilter == "Last 60 Days") {
                              daysAgo = 60;
                            }

                            if (daysAgo != null) {
                              final cutoffDate = DateTime.now()
                                  .subtract(Duration(days: daysAgo));
                              final cutoffDateStart = DateTime(cutoffDate.year,
                                  cutoffDate.month, cutoffDate.day);

                              data = data.where((applicant) {
                                if (applicant.createdAt == null) return false;
                                try {
                                  final applicantDate = DateTime.parse(
                                      applicant.createdAt.toString());
                                  final applicantDateStart = DateTime(
                                      applicantDate.year,
                                      applicantDate.month,
                                      applicantDate.day);
                                  return applicantDateStart
                                          .isAfter(cutoffDateStart) ||
                                      applicantDateStart
                                          .isAtSameMomentAs(cutoffDateStart);
                                } catch (e) {
                                  return false;
                                }
                              }).toList();
                            }
                          }

                          // Filter out applicants who have moved in or have leases created
                          data = data.where((applicant) {
                            // Exclude applicants with isMovedin: true (moved in/became tenants)
                            if (applicant.isMovedin == true) {
                              return false;
                            }
                            // Exclude applicants with lease != null (have leases created)
                            if (applicant.lease != null) {
                              return false;
                            }
                            return true;
                          }).toList();

                          // Print filtered applicant count
                          print("Filtered Applicant Count: ${data.length}");
                          print(
                              "Total Applicants (before filters): ${snapshot.data!.length}");
                          print("Date Filter: $selectedDateFilter");
                          print("Status Filter: $selectedValue");
                          print("Search Value: $searchvalue");

                          if (data.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 50,
                                  ),
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
                          // data = data.reversed.toList();
                          sortData(data);
                          final totalPages =
                              (data.length / itemsPerPage).ceil();
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
                                  // decoration: BoxDecoration(
                                  //     border: Border.all(
                                  //         color:
                                  //             blueColor)
                                  // ),

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
                                                        margin: const EdgeInsets
                                                            .only(
                                                            left: 5, right: 5),
                                                        padding: !isExpanded
                                                            ? const EdgeInsets
                                                                .only(
                                                                bottom: 10)
                                                            : const EdgeInsets
                                                                .only(top: 10),
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
                                                                  left: 0.0),
                                                          child: Text(
                                                            '${applicant.applicantFirstName} ${applicant.applicantLastName}',
                                                            style: TextStyle(
                                                              color: blueColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .02),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                        formatPhoneNumber(
                                                            '${applicant.applicantPhoneNumber ?? "---------"}'),
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
                                                            .05),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 15.0),
                                                        child: Text(
                                                          '   ${applicant.applicantStatus.isNotEmpty ? applicant.applicantStatus.first.status.toString() : 'Undecided'}',
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
                                                            .02),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (isExpanded)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 2.0),
                                                margin: const EdgeInsets.only(
                                                    bottom: 2),
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
                                                                            'Email : ',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: blueColor),
                                                                      ),
                                                                      TextSpan(
                                                                        text: applicant.applicantEmail !=
                                                                                null
                                                                            ? applicant.applicantEmail.toString()
                                                                            : 'N/A',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                            color: grey),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Text.rich(
                                                                  TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            'Property : ',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: blueColor),
                                                                      ),
                                                                      TextSpan(
                                                                        text: applicant.rentalData?.rentalAdress ??
                                                                            'N/A',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                            color: grey),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
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
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          if (permissions!
                                                              .applicantView!)
                                                            GestureDetector(
                                                              onTap: () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            applicant_summery(
                                                                              applicant_id: applicant.applicantId,
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
                                                          if (permissions!
                                                              .applicantEdit!)
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                          if (permissions!
                                                              .applicantEdit!)
                                                            GestureDetector(
                                                              onTap: () async {
                                                                var check = await Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => EditApplicant(
                                                                              applicant: applicant,
                                                                              applicantId: applicant.applicantId!,
                                                                            )));
                                                                if (check ==
                                                                    true) {
                                                                  setState(() {
                                                                    futureApplicantdata =
                                                                        ApplicantRepository()
                                                                            .fetchApplicants();
                                                                  });
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
                                                          if (permissions!
                                                              .applicantDelete!)
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                          if (permissions!
                                                              .applicantDelete!)
                                                            GestureDetector(
                                                              onTap: () {
                                                                _showDeleteAlert(
                                                                    context,
                                                                    applicant
                                                                        .applicantId
                                                                        .toString());
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
                                                            width: 10,
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 8,
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
                                                onChanged: data.length >
                                                        itemsPerPageOptions
                                                            .first // Condition to check if dropdown should be enabled
                                                    ? (newValue) {
                                                        setState(() {
                                                          itemsPerPage =
                                                              newValue!;
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
                                          onPressed:
                                              currentPage < totalPages - 1
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
                  // if (MediaQuery.of(context).size.width > 500)
                  //   FutureBuilder<List<Datum>>(
                  //     future: futureApplicantdata,
                  //     builder: (context, snapshot) {
                  //       if (snapshot.connectionState ==
                  //           ConnectionState.waiting) {
                  //         return ShimmerTabletTable();
                  //       } else if (snapshot.hasError) {
                  //         return Center(
                  //             child: Text('Error: ${snapshot.error}'));
                  //       } else if (!snapshot.hasData ||
                  //           snapshot.data!.isEmpty) {
                  //         return const Center(child: Text('No data available'));
                  //       } else {
                  //         _tableData = snapshot.data!;
                  //         if (selectedValue == null && searchvalue.isEmpty) {
                  //           _tableData = snapshot.data!;
                  //         } else if (selectedValue == "All") {
                  //           _tableData = snapshot.data!;
                  //         } else if (searchvalue.isNotEmpty) {
                  //           _tableData = snapshot.data!
                  //               .where((applicant) =>
                  //                   !applicant.applicantFirstName!
                  //                       .toLowerCase()
                  //                       .contains(searchvalue.toLowerCase()) ||
                  //                   applicant.applicantLastName!
                  //                       .toLowerCase()
                  //                       .contains(searchvalue.toLowerCase()))
                  //               .toList();
                  //         } else {
                  //           _tableData = snapshot.data!
                  //               .where((applicant) =>
                  //                   applicant.applicantFirstName ==
                  //                   selectedValue)
                  //               .toList();
                  //         }
                  //         _tableData = _tableData.reversed.toList();
                  //         totalrecords = _tableData.length;
                  //         return SingleChildScrollView(
                  //           child: Column(
                  //             children: [
                  //               Container(
                  //                 child: Padding(
                  //                   padding: const EdgeInsets.symmetric(
                  //                       horizontal: 40.0, vertical: 5),
                  //                   child: Column(
                  //                     children: [
                  //                       SingleChildScrollView(
                  //                         scrollDirection: Axis.horizontal,
                  //                         child: SizedBox(
                  //                           child: Table(
                  //                             defaultColumnWidth:
                  //                                 const IntrinsicColumnWidth(),
                  //                             children: [
                  //                               TableRow(
                  //                                 decoration: BoxDecoration(
                  //                                   border: Border.all(
                  //                                       // color: blueColor
                  //                                       ),
                  //                                 ),
                  //                                 children: [
                  //                                   _buildHeader(
                  //                                       'Name',
                  //                                       0,
                  //                                       (property) => property
                  //                                           .applicantFirstName!),
                  //                                   _buildHeader(
                  //                                       'Email',
                  //                                       1,
                  //                                       (property) => property
                  //                                           .applicantEmail!),
                  //                                   _buildHeader(
                  //                                       'Phone ..', 2, null),
                  //                                   _buildHeader(
                  //                                       'Home ..', 3, null),
                  //                                   _buildHeader(
                  //                                       'Actions', 4, null),
                  //                                 ],
                  //                               ),
                  //                               TableRow(
                  //                                 decoration:
                  //                                     const BoxDecoration(
                  //                                   border: Border.symmetric(
                  //                                       horizontal:
                  //                                           BorderSide.none),
                  //                                 ),
                  //                                 children: List.generate(
                  //                                     5,
                  //                                     (index) => TableCell(
                  //                                         child: Container(
                  //                                             height: 20))),
                  //                               ),
                  //                               for (var i = 0;
                  //                                   i < _pagedData.length;
                  //                                   i++)
                  //                                 TableRow(
                  //                                   decoration: BoxDecoration(
                  //                                     border: Border(
                  //                                       left: BorderSide(
                  //                                           color: blueColor),
                  //                                       right: BorderSide(
                  //                                           color: blueColor),
                  //                                       top: BorderSide(
                  //                                           color: blueColor),
                  //                                       bottom: i ==
                  //                                               _pagedData
                  //                                                       .length -
                  //                                                   1
                  //                                           ? BorderSide(
                  //                                               color:
                  //                                                   blueColor)
                  //                                           : BorderSide.none,
                  //                                     ),
                  //                                   ),
                  //                                   children: [
                  //                                     _buildDataCell(
                  //                                         _pagedData[i]
                  //                                             .applicantFirstName!,
                  //                                         _pagedData[i]),
                  //                                     _buildDataCell(
                  //                                         _pagedData[i]
                  //                                             .applicantEmail!,
                  //                                         _pagedData[i]),
                  //                                     _buildDataCell(
                  //                                         _pagedData[i]
                  //                                                     .applicantHomeNumber ==
                  //                                                 null
                  //                                             ? ''
                  //                                             : _pagedData[i]
                  //                                                 .applicantHomeNumber!
                  //                                                 .toString(),
                  //                                         _pagedData[i]),
                  //                                     _buildDataCell(
                  //                                         _pagedData[i]
                  //                                                     .applicantHomeNumber ==
                  //                                                 null
                  //                                             ? ''
                  //                                             : _pagedData[i]
                  //                                                 .applicantHomeNumber!
                  //                                                 .toString(),
                  //                                         _pagedData[i]),
                  //                                     // _buildDataCell(
                  //                                     //   _pagedData[i]
                  //                                     //       .applicantLastName!,
                  //                                     // ),
                  //                                     _buildActionsCell(
                  //                                         _pagedData[i]),
                  //                                   ],
                  //                                 ),
                  //                             ],
                  //                           ),
                  //                         ),
                  //                       ),
                  //                       const SizedBox(height: 25),
                  //                       _buildPaginationControls(),
                  //                     ],
                  //                   ),
                  //                 ),
                  //               ),
                  //               const SizedBox(height: 25),
                  //             ],
                  //           ),
                  //         );
                  //       }
                  //     },
                  //   ),
                    ], // closes Tab1 Column children
                  ),   // closes Tab1 Column
                ),     // closes Tab1 SingleChildScrollView

                // TAB 2 — Pending Applicants (NEW)
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 11, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text('Pending',
                            style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        const SizedBox(height: 8),
                        _buildInviteSearchField(
                            (v) => setState(() => _pendingSearch = v)),
                        const SizedBox(height: 10),
                        _buildPendingHeader(),
                        const SizedBox(height: 4),
                        _buildPendingList(),
                        const SizedBox(height: 24),
                        Text('Deleted Invitations',
                            style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        const SizedBox(height: 8),
                        _buildInviteSearchField(
                            (v) => setState(() => _deletedSearch = v)),
                        const SizedBox(height: 10),
                        _buildDeletedHeader(),
                        const SizedBox(height: 8),
                        _buildDeletedList(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],   // closes TabBarView children
            ),     // closes TabBarView
          ),       // closes Expanded
        ],         // closes outer Column children
      )            // closes outer Column
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
  void _showInviteApplicantsDialog() {
    TextEditingController emailController = TextEditingController();
    List<String> emails = [];
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void addEmail(String email) {
              print(email);
              email = email.trim().replaceAll(",", "");
              if (email.isEmpty) {
                setState(() {
                  errorMessage = 'Please enter an email address';
                });
              } else if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}")
                  .hasMatch(email)) {
                setState(() {
                  errorMessage = 'Please enter a valid email address';
                });
              } else if (emails.contains(email)) {
                setState(() {
                  errorMessage = 'This email has already been added';
                });
              } else {
                setState(() {
                  errorMessage = null;
                  emails.add(email);
                });
                emailController.clear();
              }
            }

            Future<void> sendInvites() async {
              try {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? adminId = prefs.getString('adminId');
                String? staffId = prefs.getString('staff_id');
                String? token = prefs.getString('token');

                final response = await http.post(
                  Uri.parse('$Api_url/api/applicant/invite'),
                  headers: {
                    'Content-Type': 'application/json',
                    'authorization': 'CRM $token',
                    "id": "CRM $staffId",
                  },
                  body: jsonEncode({
                    'emails': emails,
                    'admin_id': adminId,
                  }),
                );
                print(response.body);
                if (response.statusCode == 200) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invitations sent successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  throw Exception('Failed to send invites');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to send invites. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            double screenWidth = MediaQuery.of(context).size.width;
            double maxWidth = screenWidth - 48;
            double minWidth = 400.0;
            // Ensure maxWidth is at least minWidth to avoid clamp errors
            if (maxWidth < minWidth) maxWidth = minWidth;
            double dialogWidth = (screenWidth * 0.5).clamp(minWidth, maxWidth);
            
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: dialogWidth,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                padding: EdgeInsets.all(24),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with close button

                    Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.grey[700]),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFE0F2F7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person_add,
                                    color: Color(0xFF3399FF),
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Invite Applicants',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                    
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          
                        ],
                      ),
                    SizedBox(height: 24),
                    // Email Address Label
                    Text(
                      'Email Address',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Email Input Field with Add Button - Reserve space for error
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  hintText: 'example@email.com',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: errorMessage != null ? Colors.red : Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: errorMessage != null ? Colors.red : blueColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  errorText: null, // Don't show error here
                                ),
                                onSubmitted: (value) => addEmail(emailController.text),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: blueColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => addEmail(emailController.text),
                                  child: Center(
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Fixed height error message container to prevent layout shift
                        Container(
                          height: errorMessage != null ? 20 : 0,
                          padding: EdgeInsets.only(top: 4, left: 4),
                          child: errorMessage != null
                              ? Text(
                                  errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                )
                              : SizedBox.shrink(),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    // Added Emails Section
                    if (emails.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Added Emails',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                          Text(
                            '${emails.length} ${emails.length == 1 ? 'recipient' : 'recipients'}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: emails
                            .map((email) => ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: dialogWidth - 48, // Account for padding
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF0F0F0),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            email,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                              color: Color(0xFF333333),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              emails.remove(email);
                                            });
                                          },
                                          child: Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      SizedBox(height: 24),
                    ],
                      // Action Buttons - Side by side
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: emails.isEmpty ? null : sendInvites,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blueColor,
                              disabledBackgroundColor: Colors.grey[300],
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Send ${emails.length} ${emails.length == 1 ? 'Invite' : 'Invites'}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            );
          },
        );
      },
    );
  }
}
