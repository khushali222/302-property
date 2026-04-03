import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../model/staffpermission.dart';
import '../../../repository/staffpermission_provider.dart';
import '../../Rental/Rentalowner/rentalowner_summery.dart';
import '../../../repository/lease.dart';
import 'SummeryPageLease.dart';
import 'edit_lease.dart';
import 'package:three_zero_two_property/screens/Rental/Rentalowner/Edit_RentalOwners.dart';

import 'package:three_zero_two_property/widgets/CustomTableShimmer.dart';
import '../../../widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

import '../../../Model/RentalOwnersData.dart';
import '../../../../constant/constant.dart';
import '../../../../model/get_lease.dart';
import '../../../model/rentalOwner.dart';
import '../../../../model/rentalowners_summery.dart';
import '../../../model/staffmember.dart';
import '../../../../provider/lease_provider.dart';
import '../../../../provider/dateProvider.dart';
import '../../../repository/Rental_ownersData.dart';
import '../../../repository/Staffmember.dart';
import '../../../repository/rentalowner.dart';
import '../../../widgets/drawer_tiles.dart';

import 'package:http/http.dart' as http;

import 'newAddLease.dart';
import '../../../widgets/custom_drawer.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as syncXlsx;
import 'package:three_zero_two_property/repository/GetAdminAddressPdf.dart';
import 'package:three_zero_two_property/Model/profile.dart';

class Lease_table extends StatefulWidget {
  // RentalOwner? rentalownersummery;
  // Lease_table({super.key,this.rentalownersummery});

  @override
  State<Lease_table> createState() => _Lease_tableState();
}

class _Lease_tableState extends State<Lease_table> {
  late Future<LeasesPageResult> futureLease;
  Timer? _searchDebounce;
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

  /// Backend may send [end_date] as plain text e.g. "At Will" (any casing / hyphen).
  bool _leaseEndIsAtWill(String? raw) {
    if (raw == null) return false;
    final s = raw.trim().toLowerCase().replaceAll('-', ' ');
    if (s.isEmpty) return false;
    if (s == 'at will') return true;
    return s.contains('at will');
  }

  void _attemptDeleteLease(BuildContext context, Lease1 lease) {
    final currentDate = DateTime.now();
    final startDate = DateTime.parse(lease.startDate!);

    if (_leaseEndIsAtWill(lease.endDate)) {
      if (!currentDate.isBefore(startDate)) {
        Fluttertoast.showToast(
          backgroundColor: Colors.amberAccent.shade200,
          msg: "Active lease cannot be deleted.",
          toastLength: Toast.LENGTH_SHORT,
          textColor: Colors.black,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        _showDeleteAlert(context, lease.leaseId!);
      }
      return;
    }

    final endDate = DateTime.parse(lease.endDate!);
    if (currentDate.isAfter(startDate) && currentDate.isBefore(endDate)) {
      Fluttertoast.showToast(
        backgroundColor: Colors.amberAccent.shade200,
        msg: "Active lease cannot be deleted.",
        toastLength: Toast.LENGTH_SHORT,
        textColor: Colors.black,
        gravity: ToastGravity.BOTTOM,
      );
    } else {
      _showDeleteAlert(context, lease.leaseId!);
    }
  }

  void sortData(List<Lease1> data) {
    // Default sort by end date in descending order (newest end date first)
    data.sort((a, b) {
      String aEnd = a.endDate ?? "";
      String bEnd = b.endDate ?? "";
      bool aAtWill = aEnd.isEmpty || _leaseEndIsAtWill(aEnd);
      bool bAtWill = bEnd.isEmpty || _leaseEndIsAtWill(bEnd);
      if (aAtWill && bAtWill) return 0;
      if (aAtWill) return 1;
      if (bAtWill) return -1;
      return bEnd.compareTo(aEnd); // Descending: newest end date first
    });

    // Apply user-selected sorting only if explicitly chosen
    if (sorting1 && !sorting2 && !sorting3) {
      data.sort((a, b) => ascending1
          ? a.rentalAddress!.compareTo(b.rentalAddress!)
          : b.rentalAddress!.compareTo(a.rentalAddress!));
    } else if (sorting2 && !sorting1 && !sorting3) {
      data.sort((a, b) => ascending2
          ? a.startDate!.compareTo(b.startDate!)
          : b.startDate!.compareTo(a.startDate!));
    } else if (sorting3 && !sorting1 && !sorting2) {
      data.sort((a, b) => ascending3
          ? a.endDate!.compareTo(b.endDate!)
          : b.endDate!.compareTo(a.endDate!));
    }
  }

  bool _useServerLeasePagination() => selectedRentalOwners.isEmpty;

  String _apiLeaseStatus() {
    switch (selectedStatus) {
      case 'Expired':
        return 'expired';
      case 'Future':
        return 'future';
      case 'All':
        return 'all';
      case 'Active':
      default:
        return 'active';
    }
  }

  MapEntry<String, String> _leaseApiSortParams() {
    if (sorting1 && !sorting2 && !sorting3) {
      return MapEntry(
          'rental_adress', ascending1 ? 'ascending' : 'descending');
    }
    if (sorting2 && !sorting1 && !sorting3) {
      return MapEntry('start_date', ascending2 ? 'ascending' : 'descending');
    }
    if (sorting3 && !sorting1 && !sorting2) {
      return MapEntry('end_date', ascending3 ? 'ascending' : 'descending');
    }
    return const MapEntry('end_date', 'descending');
  }

  List<Lease1> _applyLocalLeaseFilters(List<Lease1> data) {
    var list = List<Lease1>.from(data);
    if (searchValue.isNotEmpty && searchValue != 'All') {
      list = list.where((lease) {
        final searchLower = searchValue.toLowerCase();
        return (lease.rentalAddress?.toLowerCase().contains(searchLower) ??
                false) ||
            (lease.tenantNames?.toLowerCase().contains(searchLower) ?? false) ||
            (lease.rentCycle?.toLowerCase().contains(searchLower) ?? false) ||
            (lease.startDate?.toLowerCase().contains(searchLower) ?? false) ||
            (lease.endDate?.toLowerCase().contains(searchLower) ?? false) ||
            (lease.amount != null
                ? lease.amount!
                    .toStringAsFixed(2)
                    .toLowerCase()
                    .contains(searchLower)
                : false) ||
            (lease.remainingDays?.toLowerCase().contains(searchLower) ??
                false) ||
            (lease.rentDueDate?.toLowerCase().contains(searchLower) ?? false) ||
            (lease.totalBalance != null
                ? lease.totalBalance!
                    .toStringAsFixed(2)
                    .toLowerCase()
                    .contains(searchLower)
                : false);
      }).toList();
    }
    if (selectedStatus == 'Active') {
      final today = DateTime.now().toIso8601String().split('T')[0];
      list = list.where((lease) {
        if (lease.startDate == null) return false;
        if (lease.endDate == null || _leaseEndIsAtWill(lease.endDate)) {
          return lease.startDate!.compareTo(today) <= 0;
        }
        return lease.startDate!.compareTo(today) <= 0 &&
            lease.endDate!.compareTo(today) >= 0;
      }).toList();
    } else if (selectedStatus == 'Expired') {
      final today = DateTime.now().toIso8601String().split('T')[0];
      list = list.where((lease) {
        if (lease.endDate == null || _leaseEndIsAtWill(lease.endDate)) {
          return false;
        }
        return lease.endDate!.compareTo(today) < 0;
      }).toList();
    } else if (selectedStatus == 'Future') {
      final today = DateTime.now().toIso8601String().split('T')[0];
      list = list.where((lease) {
        if (lease.startDate == null) return false;
        return lease.startDate!.compareTo(today) > 0;
      }).toList();
    }
    if (selectedRentalOwners.isNotEmpty) {
      list = list
          .where((lease) => selectedRentalOwners.contains(lease.rentalOwnerName))
          .toList();
    }
    return list;
  }

  Future<LeasesPageResult> _loadLeasesPage() async {
    if (!_useServerLeasePagination()) {
      var list = await LeaseRepository().fetchLease('');
      list = _applyLocalLeaseFilters(list);
      sortData(list);
      return LeasesPageResult(items: list, pagination: null);
    }
    final sort = _leaseApiSortParams();
    var result = await LeaseRepository().fetchLeasePage(
      page: currentPage + 1,
      limit: itemsPerPage,
      search: searchValue,
      status: _apiLeaseStatus(),
      sortBy: sort.key,
      sortOrder: sort.value,
    );
    final p = result.pagination;
    if (p != null && p.totalPages > 0 && currentPage >= p.totalPages) {
      final newPage = (p.totalPages - 1).clamp(0, p.totalPages - 1);
      if (mounted) {
        setState(() => currentPage = newPage);
      }
      result = await LeaseRepository().fetchLeasePage(
        page: newPage + 1,
        limit: itemsPerPage,
        search: searchValue,
        status: _apiLeaseStatus(),
        sortBy: sort.key,
        sortOrder: sort.value,
      );
    }
    return result;
  }

  void _scheduleLeaseLoad() {
    setState(() {
      futureLease = _loadLeasesPage();
    });
  }

  Future<void> _loadRentalOwnerDropdown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminId = prefs.getString('adminId');
      final owners = await RentalOwnerService().fetchRentalOwners(adminId);
      final names = owners
          .map((o) => o.rentalOwnername ?? '')
          .where((n) => n.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      if (mounted) {
        setState(() {
          availableRentalOwners = names;
          _selectedRentalOwnersNotifier.value = List.from(selectedRentalOwners);
        });
      }
    } catch (_) {}
  }

  void _maybeReloadAfterSortTap() {
    if (_useServerLeasePagination()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scheduleLeaseLoad();
      });
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
                  _maybeReloadAfterSortTap();
                },
                child: Row(
                  children: [
                    width < 400
                        ? Text("Lease",
                            style: TextStyle(
                                color: blueColor, fontWeight: FontWeight.bold,fontSize: 14.0,))
                        : Text("Lease",
                            style: TextStyle(
                                color: blueColor, fontWeight: FontWeight.bold,fontSize: 14.0,)),
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
            // const SizedBox(width: 16),
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
                  _maybeReloadAfterSortTap();
                },
                child: Row(
                  children: [
                    Text(" Rent Cycle",
                        style: TextStyle(
                          color: blueColor,
                          fontWeight: FontWeight.bold,
                          fontSize:14.0,
                        )),
                    // const SizedBox(width: 5),
                    /*  ascending2
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
                          ),*/
                  ],
                ),
              ),
            ),
            // const SizedBox(width: 16),
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
                  _maybeReloadAfterSortTap();
                },
                child: Row(
                  children: [
                    Text("Lease End",
                        style: TextStyle(
                          color: blueColor,
                          fontWeight: FontWeight.bold,
                          fontSize:14.0,
                        )),
                    // const SizedBox(width: 5),
                    /*  ascending3
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
                          ),*/
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
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        // result used for refresh
        _connectivityResult = result;
      });
    });
    checkInternet();
    futureLease = _loadLeasesPage();
    _loadRentalOwnerDropdown();
    Provider.of<StaffPermissionProvider>(context, listen: false)
        .fetchPermissions();
    fetchLeaseadded();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  ConnectivityResult? _connectivityResult;
  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
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
    // Edit lease
    Provider.of<SelectedCosignersProvider>(context, listen: false)
        .clearCosigner();
    Provider.of<SelectedTenantsProvider>(context, listen: false).clearTenant();
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
    TextEditingController reason = TextEditingController();
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this lease!",
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
              await LeaseRepository().deleteLease(
                  leaseId: id, companyName: companyName, reason: reason.text);
              _scheduleLeaseLoad();
              fetchLeaseadded();
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
        // Failed to fetch company name
        // Handle error state, e.g., show error message to user
      }
    }
  }

  void handleDelete(Lease1 lease) {
    _attemptDeleteLease(context, lease);
    //  _showDeleteAlert(context, lease.leaseId!);
    // Handle delete action
    // Delete lease
  }

  final _scrollController = ScrollController();
  void handleTap(RentalOwnerSummey rentalownersummery) async {
    // Handle edit action
    // Edit rental owner
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ResponsiveRentalSummary(
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
    // calling
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    final response = await http
        .get(Uri.parse('${Api_url}/api/leases/limitation/$adminid'), headers: {
      "authorization": "CRM $token",
      "id": "CRM $id",
    });
    final jsonData = json.decode(response.body);
    // jsonData
    if (jsonData["statusCode"] == 200 || jsonData["statusCode"] == 201) {
      setState(() {
        leaseCount = jsonData['leaseCount'];
        leaseCountLimit = jsonData['leaseCountLimit'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  String _formatDateSafely(String? dateValue, DateProvider dateProvider) {
    if (dateValue == null || dateValue.trim().isEmpty || dateValue == 'null') {
      return 'N/A';
    }
    if (_leaseEndIsAtWill(dateValue)) {
      return 'At Will';
    }

    try {
      String formattedDate = dateProvider.formatCurrentDate(dateValue);

      // Check if the formatted date is invalid (contains "Invalid" or is the same as input when input looks invalid)
      if (formattedDate.toLowerCase().contains('invalid') ||
          (formattedDate == dateValue &&
              !RegExp(r'^\d{1,2}[/-]\d{1,2}[/-]\d{4}').hasMatch(dateValue) &&
              !RegExp(r'^\d{4}[/-]\d{1,2}[/-]\d{1,2}').hasMatch(dateValue))) {
        return 'N/A';
      }

      return formattedDate;
    } catch (e) {
      return 'N/A';
    }
  }

  String selectedStatus = "Active";
  final List<String> statusOptions = ["Active", "Expired", "Future", "All"];
  List<String> selectedRentalOwners = [];
  List<String> availableRentalOwners = [];
  final GlobalKey _rentalOwnerDropdownKey = GlobalKey();
  final ValueNotifier<List<String>> _selectedRentalOwnersNotifier =
      ValueNotifier<List<String>>([]);
  List<Lease1>? _leasesForExport;

  void _showAlertforLimit(BuildContext context) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Plan Limitation",
      desc:
          "The limit for adding lease according to the plan has been reached.",
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

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    final permissionProvider = Provider.of<StaffPermissionProvider>(context);
    StaffPermission? permissions = permissionProvider.permissions;
    return Scaffold(
      appBar: widget_302_Staff.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawerStaff(
        currentpage: "Leases",
        dropdown: true,
      ),
      body: _connectivityResult != ConnectivityResult.none
          ? SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
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
                          flex: permissions!.leaseAdd! ? 3 : 1,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: titleBar(
                              width: double.infinity,
                              title: 'Leases',
                            ),
                          ),
                        ),
                        if (permissions!.leaseAdd!)
                          Flexible(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: GestureDetector(
                                onTap: () async {
                                  Provider.of<SelectedTenantsProvider>(context,
                                          listen: false)
                                      .clearTenant();
                                  Provider.of<SelectedCosignersProvider>(
                                          context,
                                          listen: false)
                                      .clearCosigner();
                                  Provider.of<SelectedApplicantProvider>(
                                          context,
                                          listen: false)
                                      .clearApplicant();
                                  final result = await Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) => addLease3()));
                                  if (result == true) {
                                    _scheduleLeaseLoad();
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
                        if (MediaQuery.of(context).size.width < 500)
                          SizedBox(width: 3),
                        if (MediaQuery.of(context).size.width > 500)
                          SizedBox(width: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  //         color: blueColor,
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
                  //SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 11, right: 11),
                    child: Column(
                      children: [
                        // First row: Search bar and Status dropdown
                        Row(
                          children: [
                            if (MediaQuery.of(context).size.width < 500)
                              const SizedBox(width: 2),
                            if (MediaQuery.of(context).size.width > 500)
                              const SizedBox(width: 19),
                            Material(
                              elevation: 0,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                height:
                                    (MediaQuery.of(context).size.width < 500)
                                        ? 45
                                        : 50,
                                width: MediaQuery.of(context).size.width < 500
                                    ? MediaQuery.of(context).size.width * .52
                                    : MediaQuery.of(context).size.width * .49,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFF8A95A8)),
                                ),
                                child: TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      searchValue = value;
                                    });
                                    _searchDebounce?.cancel();
                                    _searchDebounce = Timer(
                                        const Duration(milliseconds: 400), () {
                                      if (!mounted) return;
                                      setState(() {
                                        currentPage = 0;
                                        futureLease = _loadLeasesPage();
                                      });
                                    });
                                  },
                                  cursorColor: Colors.blue,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Search here...",
                                    hintStyle:
                                        TextStyle(color: Color(0xFF8A95A8),fontSize: 14),
                                    contentPadding: EdgeInsets.only(left: 15,bottom: 10,top: 4,right: 10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: Material(
                                  elevation: 0,
                                  borderRadius: BorderRadius.circular(8),
                                  child: DropdownButton2<String>(
                                    isExpanded: true,
                                    hint: const Text(
                                      '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF8A95A8),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    value: selectedStatus,
                                    items: statusOptions.map((String status) {
                                      return DropdownMenuItem<String>(
                                        value: status,
                                        child: Text(status,style: TextStyle(fontSize: 14),),
                                      );
                                    }).toList(),
                                    buttonStyleData: ButtonStyleData(
                                      height:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 45
                                              : 50,
                                      width: double.infinity,
                                      padding: const EdgeInsets.only(
                                          left: 14, right: 14),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFF8A95A8),
                                        ),
                                        color: Colors.white,
                                      ),
                                      elevation: 0,
                                    ),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedStatus = newValue!;
                                        currentPage = 0;
                                        futureLease = _loadLeasesPage();
                                      });
                                    },
                                    dropdownStyleData: DropdownStyleData(
                                      maxHeight: 250,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      offset: const Offset(0, 0),
                                      scrollbarTheme: ScrollbarThemeData(
                                        radius: const Radius.circular(20),
                                        thickness: MaterialStateProperty.all(6),
                                        thumbVisibility:
                                            MaterialStateProperty.all(true),
                                      ),
                                    ),
                                    menuItemStyleData: const MenuItemStyleData(
                                      height: 40,
                                      padding:
                                          EdgeInsets.only(left: 14, right: 14),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (MediaQuery.of(context).size.width < 500)
                              const SizedBox(width: 8),
                            if (MediaQuery.of(context).size.width > 500)
                              const SizedBox(width: 25),
                          ],
                        ),
                        // Second row: Rental Owner dropdown + Export button
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (MediaQuery.of(context).size.width < 500)
                              const SizedBox(width: 2),
                            if (MediaQuery.of(context).size.width > 500)
                              const SizedBox(width: 19),
                            SizedBox(
                              width: MediaQuery.of(context).size.width < 500
                                  ? MediaQuery.of(context).size.width * .52
                                  : MediaQuery.of(context).size.width * .49,
                              child: DropdownButtonHideUnderline(
                                child: Material(
                                  elevation: 0,
                                  borderRadius: BorderRadius.circular(8),
                                  child: _buildRentalOwnerDropdown(),
                                ),
                              ),
                              key: _rentalOwnerDropdownKey,
                            ),
                            const SizedBox(width: 8),
                            // // Export button - blue style, aligned next to dropdown
                            Expanded(
                              child: Container(
                                height:
                                    (MediaQuery.of(context).size.width < 768)
                                        ? 45
                                        : 50,
                                decoration: BoxDecoration(
                                  color: blueColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (_leasesForExport == null ||
                                        _leasesForExport!.isEmpty) {
                                      Fluttertoast.showToast(
                                        msg: 'No data to export',
                                        toastLength: Toast.LENGTH_SHORT,
                                      );
                                      return;
                                    }
                                    final dateProvider =
                                        Provider.of<DateProvider>(context,
                                            listen: false);
                                    if (value == 'pdf') {
                                      await _generatePdf(
                                          _leasesForExport!, dateProvider);
                                    } else if (value == 'excel') {
                                      await _generateExcel(
                                          _leasesForExport!, dateProvider);
                                    } else if (value == 'csv') {
                                      await _generateCsv(
                                          _leasesForExport!, dateProvider);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                        value: 'pdf',
                                        child: Text('Export as PDF')),
                                    const PopupMenuItem<String>(
                                        value: 'excel',
                                        child: Text('Export as Excel')),
                                    const PopupMenuItem<String>(
                                        value: 'csv',
                                        child: Text('Export as CSV')),
                                  ],
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.download,
                                            size: 20, color: Colors.white),
                                        const SizedBox(width: 8),
                                        Text('Export',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.keyboard_arrow_down,
                                            size: 20, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),


                            if (MediaQuery.of(context).size.width < 500)
                              const SizedBox(width: 8),
                            if (MediaQuery.of(context).size.width > 500)
                              const SizedBox(width: 25),
                          ],
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
                    child: FutureBuilder<LeasesPageResult>(
                      future: futureLease,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ColabShimmerLoadingWidget();
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.items.isEmpty) {
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
                          final pageResult = snapshot.data!;
                          late List<Lease1> data;
                          late int totalPages;
                          late List<Lease1> currentPageData;
                          late bool canChangePageSize;

                          if (_useServerLeasePagination() &&
                              pageResult.pagination != null) {
                            data = pageResult.items;
                            totalPages =
                                pageResult.pagination!.totalPages.clamp(1, 1 << 30);
                            currentPageData = data;
                            canChangePageSize = data.isNotEmpty ||
                                (pageResult.pagination!.totalItems > 0);
                          } else {
                            data = pageResult.items;
                            if (!_useServerLeasePagination() &&
                                data.isNotEmpty) {
                              final uniqueRentalOwners = data
                                  .map((lease) => lease.rentalOwnerName)
                                  .where((name) =>
                                      name != null &&
                                      name.isNotEmpty &&
                                      name != 'N/A')
                                  .cast<String>()
                                  .toSet()
                                  .toList()
                                ..sort();
                              if (availableRentalOwners.toString() !=
                                  uniqueRentalOwners.toString()) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (mounted) {
                                    setState(() {
                                      availableRentalOwners =
                                          uniqueRentalOwners;
                                      _selectedRentalOwnersNotifier.value =
                                          List.from(selectedRentalOwners);
                                    });
                                  }
                                });
                              }
                            }
                            totalPages = (data.length / itemsPerPage)
                                .ceil()
                                .clamp(1, 1 << 30);
                            currentPageData = data
                                .skip(currentPage * itemsPerPage)
                                .take(itemsPerPage)
                                .toList();
                            canChangePageSize = data.isNotEmpty;
                          }

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _leasesForExport = List.from(data);
                              });
                            }
                          });

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
                                      Lease1 lease = entry.value;
                                      final balance = lease.totalBalance ?? 0.0;
                                      final isNegative = balance < 0;
                                      final formattedBalance =
                                          "${isNegative ? '-' : ''}\$${balance.abs().toStringAsFixed(2)}";
                                      //return CustomExpansionTile(data: Propertytype, index: index);
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (expandedIndex == index) {
                                              expandedIndex = null;
                                            } else {
                                              expandedIndex = index;
                                            }
                                          });
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          decoration: BoxDecoration(
                                            color: index % 2 != 0
                                                ? const Color(0xFFF4F8FF)
                                                : Colors.white,
                                            border: Border.all(
                                                color: const Color(0xFFDBE0E5)),
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
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 5,
                                                                  right: 5),
                                                          padding: !isExpanded
                                                              ? const EdgeInsets
                                                                  .only(
                                                                  bottom: 10)
                                                              : const EdgeInsets
                                                                  .only(
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
                                                        flex:
                                                            3, // Larger size for the first field
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 8.0),
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
                                                            child: Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        '${lease.rentalAddress}',
                                                                    style:
                                                                        TextStyle(
                                                                      color:
                                                                          blueColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          11,
                                                                    ),
                                                                  ),
                                                                  if (lease
                                                                          .tenantNames
                                                                          ?.isNotEmpty ??
                                                                      false)
                                                                    TextSpan(
                                                                      text:
                                                                          "\n${lease.tenantNames}",
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .lightBlue, // Light blue color for tenant names
                                                                        // fontWeight:
                                                                        //     FontWeight.bold,
                                                                        fontSize:
                                                                            10,
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Expanded(
                                                        flex:
                                                            2, // Smaller size for the second field
                                                        child: Text(
                                                          lease.rentCycle!,
                                                          style: TextStyle(
                                                            color: blueColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        flex:
                                                            2, // Smaller size for the third field
                                                        child: Text(
                                                          _formatDateSafely(
                                                              lease.endDate,
                                                              dateProvider),
                                                          style: TextStyle(
                                                            color: blueColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (isExpanded)
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 2.0),
                                                  margin: const EdgeInsets.only(
                                                      bottom: 2),
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
                                                              size: 40,
                                                              color: Colors
                                                                  .transparent,
                                                            ),
                                                            Expanded(
                                                              child: Table(
                                                                columnWidths: {
                                                                  0: const FlexColumnWidth(), // Distribute columns equally
                                                                  1: const FlexColumnWidth(),
                                                                  // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                                                  // 1: FlexColumnWidth(),
                                                                },
                                                                children: [
                                                                  _buildTableRow(
                                                                    'Current Balance:',
                                                                    _getDisplayValue(
                                                                        formattedBalance),
                                                                    'Rent :',
                                                                    _getDisplayValue(
                                                                        _formatCurrencyForExport(
                                                                            lease.amount)),
                                                                  ),
                                                                  _buildTableRow(
                                                                      'Remaining Days:',
                                                                      _getDisplayValue(
                                                                          lease
                                                                              .remainingDays),
                                                                      '',
                                                                      ''),
                                                                  //_buildTableRow('Current Balance:', _getDisplayValue("${formattedBalance}"), '', '')
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            // Column(
                                                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            //   children: [
                                                            //     IconButton(
                                                            //       icon: FaIcon(
                                                            //         FontAwesomeIcons.edit,
                                                            //         size: 20,
                                                            //         color:blueColor,
                                                            //       ),
                                                            //       onPressed: () async {
                                                            //         Provider.of<SelectedCosignersProvider>(
                                                            //                                   context,
                                                            //                                   listen:
                                                            //                                       false)
                                                            //                               .clearCosigner();
                                                            //                           Provider.of<SelectedTenantsProvider>(
                                                            //                                   context,
                                                            //                                   listen:
                                                            //                                       false)
                                                            //                               .clearTenant();
                                                            //                           // handleEdit(Propertytype);
                                                            //                           var check = await Navigator.push(
                                                            //                               context,
                                                            //                               MaterialPageRoute(
                                                            //                                   builder: (context) => Edit_lease(
                                                            //                                         lease: lease,
                                                            //                                         leaseId: lease.leaseId!,
                                                            //                                       )));
                                                            //                           if (check ==
                                                            //                               true) {
                                                            //                             setState(() {
                                                            //                               futureLease = LeaseRepository().fetchLease("");
                                                            //                               //  futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
                                                            //                             });
                                                            //                           }
                                                            //       },
                                                            //     ),
                                                            //     IconButton(
                                                            //       icon: FaIcon(
                                                            //         FontAwesomeIcons.trashCan,
                                                            //         size: 20,
                                                            //         color:blueColor,
                                                            //       ),
                                                            //       onPressed: () {
                                                            //         _attemptDeleteLease(context,lease);
                                                            //         //               //handleDelete(Propertytype);
                                                            //       },
                                                            //     ),
                                                            //   ],
                                                            // ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            if (permissions!
                                                                .leaseView!)
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => SummeryPageLease(
                                                                                leaseId: lease.leaseId!,
                                                                                enddate: lease.endDate,
                                                                              )));
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 35,
                                                                  width: 35,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade200,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  child:
                                                                      const Row(
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
                                                                        size:
                                                                            15,
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
                                                                .leaseView!)
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                            if (permissions!
                                                                .leaseEdit!)
                                                              GestureDetector(
                                                                onTap:
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
                                                                    _scheduleLeaseLoad();
                                                                  }
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 35,
                                                                  width: 35,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                      color: Colors
                                                                          .green
                                                                          .shade50), // color:Colors.grey[100],
                                                                  child:
                                                                      const Row(
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
                                                                        size:
                                                                            15,
                                                                        color: Colors
                                                                            .green,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            if (permissions!
                                                                .leaseEdit!)
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                            if (permissions!
                                                                .leaseDelete!)
                                                              GestureDetector(
                                                                onTap: () {
                                                                  _attemptDeleteLease(
                                                                      context,
                                                                      lease);
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 35,
                                                                  width: 35,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                      color: Colors
                                                                          .red
                                                                          .shade50),
                                                                  child:
                                                                      const Row(
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
                                                                        size:
                                                                            15,
                                                                        color: Colors
                                                                            .red,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            const SizedBox(
                                                              width: 15,
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 15,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              //SizedBox(height: 13,),
                                            ],
                                          ),
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
                                                onChanged: canChangePageSize
                                                    ? (newValue) {
                                                        setState(() {
                                                          itemsPerPage =
                                                              newValue!;
                                                          currentPage = 0;
                                                          if (_useServerLeasePagination()) {
                                                            futureLease =
                                                                _loadLeasesPage();
                                                          }
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
                                                    if (_useServerLeasePagination()) {
                                                      futureLease =
                                                          _loadLeasesPage();
                                                    }
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
                                          onPressed:
                                              currentPage < totalPages - 1
                                                  ? () {
                                                      setState(() {
                                                        currentPage++;
                                                        if (_useServerLeasePagination()) {
                                                          futureLease =
                                                              _loadLeasesPage();
                                                        }
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
                  //   FutureBuilder<List<Lease1>>(
                  //     future: futureLease,
                  //     builder: (context, snapshot) {
                  //       if (snapshot.connectionState ==
                  //           ConnectionState.waiting) {
                  //         return ShimmerTabletTable();
                  //       } else if (snapshot.hasError) {
                  //         return Center(
                  //             child: Text('Error: ${snapshot.error}'));
                  //       } else if (!snapshot.hasData ||
                  //           snapshot.data!.isEmpty) {
                  //         return Container(
                  //           height: MediaQuery.of(context).size.height * .5,
                  //           child: Center(
                  //             child: Column(
                  //               mainAxisAlignment: MainAxisAlignment.center,
                  //               crossAxisAlignment: CrossAxisAlignment.center,
                  //               children: [
                  //                 Image.asset(
                  //                   "assets/images/no_data.jpg",
                  //                   height: 200,
                  //                   width: 200,
                  //                 ),
                  //                 const SizedBox(
                  //                   height: 10,
                  //                 ),
                  //                 Text(
                  //                   "No Data Available",
                  //                   style: TextStyle(
                  //                       fontWeight: FontWeight.bold,
                  //                       color: blueColor,
                  //                       fontSize: 16),
                  //                 )
                  //               ],
                  //             ),
                  //           ),
                  //         );
                  //       } else {
                  //         List<Lease1>? filteredData = [];
                  //         _tableData = snapshot.data!;
                  //         if (selectedRole == null && searchValue == "") {
                  //           filteredData = snapshot.data;
                  //         } else if (selectedRole == "All") {
                  //           filteredData = snapshot.data;
                  //         } else if (searchValue.isNotEmpty) {
                  //           filteredData = snapshot.data!
                  //               .where((lease) =>
                  //                   (lease.rentalAddress
                  //                           ?.toLowerCase()
                  //                           .contains(
                  //                               searchValue.toLowerCase()) ??
                  //                       false) ||
                  //                   (lease.tenantNames?.toLowerCase().contains(
                  //                           searchValue.toLowerCase()) ??
                  //                       false))
                  //               .toList();
                  //         }
                  //         // Remove filteredData?.reversed.toList() to let sortData handle the ordering
                  //         // filteredData = filteredData?.reversed.toList();
                  //         _tableData = filteredData!;
                  //         totalrecords = _tableData.length;
                  //         return Padding(
                  //           padding:
                  //               const EdgeInsets.symmetric(horizontal: 23.0),
                  //           child: Column(
                  //             children: [
                  //               SingleChildScrollView(
                  //                 scrollDirection: Axis.horizontal,
                  //                 child: Padding(
                  //                   padding: const EdgeInsets.only(left: 15),
                  //                   child: Container(
                  //                     // width: MediaQuery.of(context).size.width * .91,
                  //                     child: Table(
                  //                       defaultColumnWidth:
                  //                           const IntrinsicColumnWidth(),
                  //                       children: [
                  //                         TableRow(
                  //                           decoration: BoxDecoration(
                  //                               border: Border.all()),
                  //                           children: [
                  //                             //_buildHeader('FirstName', 0, (staff) => staff.rentalOwnerFirstName!),
                  //                             //  _buildHeader('LastName', 1, (staff) => staff.rentalOwnerLastName!),
                  //                             _buildHeader(
                  //                                 'Lease',
                  //                                 0,
                  //                                 (lease) =>
                  //                                     '${lease.rentalAddress ?? ''}'
                  //                                     '${lease.tenantNames ?? ''}'),
                  //                             // _buildHeader('Lease', 0,
                  //                             //         (lease) => '${lease.rentalAddress!} '),
                  //                             _buildHeader('Lease Start', 1,
                  //                                 (lease) => lease.startDate!),
                  //                             _buildHeader('Lease End', 2,
                  //                                 (lease) => lease.endDate!),
                  //                             _buildHeader('Rent Cycle', 3,
                  //                                 (lease) => lease.rentCycle!),
                  //                             _buildHeader(
                  //                                 'Balance Due',
                  //                                 4,
                  //                                 (lease) =>
                  //                                     lease.rentDueDate!),
                  //                             _buildHeader('Rent', 5,
                  //                                 (lease) => lease.amount!),
                  //                             _buildHeader('Deposit Held', 6,
                  //                                 (lease) => lease.deposit!),
                  //                             _buildHeader(
                  //                                 'Charges',
                  //                                 7,
                  //                                 (lease) =>
                  //                                     lease.recurringCharge!),
                  //                             _buildHeader('Created At', 8,
                  //                                 (lease) => lease.createdAt!),
                  //                             _buildHeader('Updated At', 9,
                  //                                 (lease) => lease.updatedAt!),
                  //                             _buildHeader('Actions', 10, null),
                  //                           ],
                  //                         ),
                  //                         TableRow(
                  //                           decoration: const BoxDecoration(
                  //                             border: Border.symmetric(
                  //                                 horizontal: BorderSide.none),
                  //                           ),
                  //                           children: List.generate(
                  //                               11,
                  //                               (index) => TableCell(
                  //                                   child:
                  //                                       Container(height: 20))),
                  //                         ),
                  //                         for (var i = 0;
                  //                             i < _pagedData.length;
                  //                             i++)
                  //                           TableRow(
                  //                             decoration: BoxDecoration(
                  //                               border: Border(
                  //                                 left: BorderSide(
                  //                                     color: blueColor),
                  //                                 right: BorderSide(
                  //                                     color: blueColor),
                  //                                 top: BorderSide(
                  //                                     color: blueColor),
                  //                                 bottom:
                  //                                     i == _pagedData.length - 1
                  //                                         ? BorderSide(
                  //                                             color: blueColor)
                  //                                         : BorderSide.none,
                  //                               ),
                  //                             ),
                  //                             children: [
                  //                               //_buildDataCell(_pagedData[i].rentalOwnerFirstName!),
                  //                               InkWell(
                  //                                 onTap: () {
                  //                                   Navigator.push(
                  //                                       context,
                  //                                       MaterialPageRoute(
                  //                                           builder: (context) =>
                  //                                               SummeryPageLease(
                  //                                                   leaseId: _pagedData[
                  //                                                           i]
                  //                                                       .leaseId!)));
                  //                                 },
                  //                                 child: _buildDataCell(
                  //                                     '${_pagedData[i].rentalAddress ?? ''}${_pagedData[i].tenantNames ?? ''}'),
                  //                               ),
                  //                               // _buildDataCell('${_pagedData[i].rentalOwnerFirstName ?? ''} ${_pagedData[i].rentalOwnerLastName ?? ''}'),
                  //                               _buildDataCell(
                  //                                   _pagedData[i].startDate!),
                  //                               _buildDataCell(
                  //                                   _pagedData[i].endDate!),
                  //                               _buildDataCell(
                  //                                   _pagedData[i].rentCycle!),
                  //                               _buildDataCell(_pagedData[i]
                  //                                           .totalBalance! <
                  //                                       0
                  //                                   ? ' - \$${_pagedData[i].totalBalance!.abs().toStringAsFixed(2)}'
                  //                                   : ' \$ ${_pagedData[i].totalBalance!.abs().toStringAsFixed(2)}'),
                  //                               _buildDataCell(_pagedData[i]
                  //                                   .amount
                  //                                   .toString()),
                  //                               _buildDataCell((_pagedData[i]
                  //                                       .deposit
                  //                                       ?.toString() ??
                  //                                   "")),
                  //                               _buildDataCell((_pagedData[i]
                  //                                       .recurringCharge
                  //                                       ?.toString() ??
                  //                                   "")),
                  //                               _buildDataCell(Provider.of<
                  //                                           DateProvider>(
                  //                                       context,
                  //                                       listen: false)
                  //                                   .formatCurrentDateTime(
                  //                                       '${_pagedData[i].createdAt}')),
                  //                               _buildDataCell(Provider.of<
                  //                                           DateProvider>(
                  //                                       context,
                  //                                       listen: false)
                  //                                   .formatCurrentDateTime(
                  //                                       '${_pagedData[i].updatedAt}')),
                  //                               _buildActionsCell(
                  //                                   _pagedData[i]),
                  //                             ],
                  //                           ),
                  //                       ],
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ),
                  //               if (_tableData.isEmpty)
                  //                 const Text("No Search Records Found"),
                  //               const SizedBox(height: 25),
                  //               _buildPaginationControls(),
                  //             ],
                  //           ),
                  //         );
                  //       }
                  //     },
                  //   ),
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
                  const Text(
                    'No Internet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Check your internet connection',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
    );
  }

  TableRow _buildTableRow(
      String leftLabel, String leftValue, String rightLabel, String rightValue,
      {bool rightAlignValues = false}) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leftLabel,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: blueColor, fontSize: 12),
                ),
                const SizedBox(height: 2.0),
                rightAlignValues
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          leftValue,
                          style: TextStyle(color: grey, fontSize: 13,fontWeight: FontWeight.bold),
                        ),
                      )
                    : Text(
                        leftValue,
                        style: TextStyle(color: grey, fontSize: 13,fontWeight: FontWeight.bold),
                      ),
              ],
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rightLabel,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: blueColor, fontSize: 12),
                ),
                const SizedBox(height: 2.0),
                rightAlignValues
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          rightValue,
                          style: TextStyle(color: grey, fontSize: 13,fontWeight: FontWeight.bold),
                        ),
                      )
                    : Text(
                        rightValue,
                        style: TextStyle(color: grey, fontSize: 13,fontWeight: FontWeight.bold),
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

  Widget _buildRentalOwnerDropdown() {
    // Use selectedRentalOwners directly for display text
    String displayText = selectedRentalOwners.isEmpty
        ? 'Select rental owners'
        : selectedRentalOwners.length == 1
            ? selectedRentalOwners.first
            : '${selectedRentalOwners.length} owners selected';

    return ValueListenableBuilder<List<String>>(
      valueListenable: _selectedRentalOwnersNotifier,
      builder: (context, currentSelected, _) {
        return DropdownButton2<String>(
          isExpanded: true,
          hint: Row(
            children: [
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  displayText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8A95A8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          value: null, // Always null for multi-select
          items: availableRentalOwners.map((owner) {
            return DropdownMenuItem<String>(
              value: owner,
              enabled: false, // Disable to prevent dropdown from closing
              child: ValueListenableBuilder<List<String>>(
                valueListenable: _selectedRentalOwnersNotifier,
                builder: (context, currentSelectedList, _) {
                  final isCurrentlySelected =
                      currentSelectedList.contains(owner);

                  return InkWell(
                    onTap: () {
                      if (isCurrentlySelected) {
                        selectedRentalOwners.remove(owner);
                      } else {
                        selectedRentalOwners.add(owner);
                      }
                      _selectedRentalOwnersNotifier.value =
                          List.from(selectedRentalOwners);
                      setState(() {
                        if (currentPage != 0) currentPage = 0;
                        futureLease = _loadLeasesPage();
                      });
                    },
                    child: Row(
                      children: [
                        Checkbox(
                          value: isCurrentlySelected,
                          onChanged: (bool? value) {
                            if (value == true) {
                              selectedRentalOwners.add(owner);
                            } else {
                              selectedRentalOwners.remove(owner);
                            }
                            _selectedRentalOwnersNotifier.value =
                                List.from(selectedRentalOwners);
                            setState(() {
                              if (currentPage != 0) currentPage = 0;
                              futureLease = _loadLeasesPage();
                            });
                          },
                          activeColor: blueColor,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        Expanded(
                          child: Text(
                            owner,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isCurrentlySelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }).toList(),
          onChanged: (value) {
            // Do nothing - selection handled in item's InkWell
          },
          buttonStyleData: ButtonStyleData(
            height: MediaQuery.of(context).size.width < 500 ? 45 : 50,
            width: double.infinity,
            padding: const EdgeInsets.only(left: 14, right: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF8A95A8),
              ),
              color: Colors.white,
            ),
            elevation: 0,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
            ),
            offset: const Offset(0, 0),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(40),
              thickness: MaterialStateProperty.all(6),
              thumbVisibility: MaterialStateProperty.all(true),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
            padding: EdgeInsets.only(left: 14, right: 14),
          ),
        );
      },
    );
  }

  void _showRentalOwnerFilterDialog(BuildContext context) {
    List<String> tempSelected = List.from(selectedRentalOwners);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Rental Owners'),
              content: Container(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: availableRentalOwners.map((owner) {
                      return CheckboxListTile(
                        title: Text(owner),
                        value: tempSelected.contains(owner),
                        activeColor: blueColor,
                        onChanged: (bool? value) {
                          setDialogState(() {
                            if (value == true) {
                              tempSelected.add(owner);
                            } else {
                              tempSelected.remove(owner);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      tempSelected.clear();
                    });
                  },
                  child: const Text('Clear All'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedRentalOwners = tempSelected;
                      if (currentPage != 0) currentPage = 0;
                    });
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: blueColor,
                  ),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
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
            size: 30,
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

  /// Format as -$X.XX for negative, $X.XX for positive.
  String _formatCurrencyForExport(double? value) {
    if (value == null) return '-';
    if (value < 0) return '-\$${value.abs().toStringAsFixed(2)}';
    return '\$${value.toStringAsFixed(2)}';
  }

  Future<void> _generatePdf(
      List<Lease1> leases, DateProvider dateProvider) async {
    try {
      profile? profileData;
      try {
        final service = GetAddressAdminPdfService();
        profileData = await service.fetchAdminAddress();
      } catch (_) {}

      final pdf = pw.Document();
      final image = pw.MemoryImage(
          (await rootBundle.load('assets/images/newlogo.png'))
              .buffer
              .asUint8List());

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          header: (pw.Context context) => pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Image(image, width: 50, height: 50),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('Leases Report',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                      'Active Leases as of ${dateProvider.formatCurrentDateTime(DateTime.now().toIso8601String())}',
                      style: pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.Text(
                  profileData?.companyName?.isNotEmpty == true
                      ? profileData!.companyName!
                      : '',
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          build: (pw.Context context) {
            final headers = [
              'Rental Address',
              'Rental Owner',
              'Tenant Names',
              'End Date',
              'Rent Cycle',
              'Remaining Days',
              'Current Balance',
              'Rent',
            ];
            return [
              pw.SizedBox(height: 20),
              pw.Table(
                border: null,
                columnWidths: {
                  0: pw.FlexColumnWidth(1.5),
                  1: pw.FlexColumnWidth(1.0),
                  2: pw.FlexColumnWidth(1.5),
                  3: pw.FlexColumnWidth(0.8),
                  4: pw.FlexColumnWidth(0.8),
                  5: pw.FlexColumnWidth(0.8),
                  6: pw.FlexColumnWidth(1.0),
                  7: pw.FlexColumnWidth(0.6),
                },
                children: [
                  pw.TableRow(
                    decoration:
                        pw.BoxDecoration(color: PdfColor.fromHex('#5A86D5')),
                    children: headers
                        .asMap()
                        .entries
                        .map((e) => pw.Padding(
                            padding: pw.EdgeInsets.all(6),
                            child: pw.Text(e.value,
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.white,
                                    fontSize: 10),
                                textAlign: (e.key == 6 || e.key == 7)
                                    ? pw.TextAlign.right
                                    : pw.TextAlign.left)))
                        .toList(),
                  ),
                  ...leases.map((lease) {
                    final balance = lease.totalBalance ?? 0.0;
                    final balanceStr = _formatCurrencyForExport(balance);
                    final rentStr = _formatCurrencyForExport(lease.amount);
                    final endDateStr =
                        _formatDateSafely(lease.endDate, dateProvider);
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                            padding: pw.EdgeInsets.all(6),
                            child: pw.Text(lease.rentalAddress ?? 'N/A',
                                style: pw.TextStyle(fontSize: 9))),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(6),
                            child: pw.Text(lease.rentalOwnerName ?? 'N/A',
                                style: pw.TextStyle(fontSize: 9))),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(6),
                            child: pw.Text(lease.tenantNames ?? 'N/A',
                                style: pw.TextStyle(fontSize: 9))),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(6),
                            child: pw.Text(endDateStr,
                                style: pw.TextStyle(fontSize: 9))),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(6),
                            child: pw.Text(lease.rentCycle ?? 'N/A',
                                style: pw.TextStyle(fontSize: 9))),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(6),
                            child: pw.Text(lease.remainingDays ?? 'N/A',
                                style: pw.TextStyle(fontSize: 9))),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(6),
                            child: pw.Text(balanceStr,
                                style: pw.TextStyle(fontSize: 9),
                                textAlign: pw.TextAlign.right)),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(6),
                            child: pw.Text(rentStr,
                                style: pw.TextStyle(fontSize: 9),
                                textAlign: pw.TextAlign.right)),
                      ],
                    );
                  }),
                ],
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
      //Fluttertoast.showToast(msg: 'PDF exported successfully');
      print('PDF exported successfully');
    } catch (e) {
      //Fluttertoast.showToast(msg: 'Error generating PDF: $e');
      print('Error generating PDF: $e');
    }
  }

  Future<void> _generateExcel(
      List<Lease1> leases, DateProvider dateProvider) async {
    try {
      final workbook = syncXlsx.Workbook();
      final worksheet = workbook.worksheets[0];
      worksheet.name = 'Leases Report';

      final headers = [
        'Rental Address',
        'Rental Owner',
        'Tenant Names',
        'End Date',
        'Rent Cycle',
        'Remaining Days',
        'Current Balance',
        'Rent',
      ];
      for (int i = 0; i < headers.length; i++) {
        worksheet.getRangeByIndex(1, i + 1).setText(headers[i]);
        worksheet.getRangeByIndex(1, i + 1).cellStyle.bold = true;
        if (i == 6 || i == 7) {
          worksheet.getRangeByIndex(1, i + 1).cellStyle.hAlign =
              syncXlsx.HAlignType.right;
        }
      }

      for (int i = 0; i < leases.length; i++) {
        final lease = leases[i];
        final balance = lease.totalBalance ?? 0.0;
        final balanceStr = _formatCurrencyForExport(balance);
        final endDateStr = _formatDateSafely(lease.endDate, dateProvider);
        worksheet.getRangeByIndex(i + 2, 1).setText(lease.rentalAddress ?? '');
        worksheet
            .getRangeByIndex(i + 2, 2)
            .setText(lease.rentalOwnerName ?? '');
        worksheet.getRangeByIndex(i + 2, 3).setText(lease.tenantNames ?? '');
        worksheet.getRangeByIndex(i + 2, 4).setText(endDateStr);
        worksheet.getRangeByIndex(i + 2, 5).setText(lease.rentCycle ?? '');
        worksheet.getRangeByIndex(i + 2, 6).setText(lease.remainingDays ?? '');
        worksheet.getRangeByIndex(i + 2, 7).setText(balanceStr);
        worksheet
            .getRangeByIndex(i + 2, 8)
            .setText(_formatCurrencyForExport(lease.amount));
        worksheet.getRangeByIndex(i + 2, 7).cellStyle.hAlign =
            syncXlsx.HAlignType.right;
        worksheet.getRangeByIndex(i + 2, 8).cellStyle.hAlign =
            syncXlsx.HAlignType.right;
      }

      for (int i = 1; i <= headers.length; i++) {
        worksheet.autoFitColumn(i);
      }

      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/Leases_Report_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}.xlsx';
      final file = File(path);
      await file.writeAsBytes(bytes);

      Fluttertoast.showToast(msg: 'Excel file saved');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error generating Excel: $e');
    }
  }

  Future<void> _generateCsv(
      List<Lease1> leases, DateProvider dateProvider) async {
    try {
      final headers = [
        'Rental Address',
        'Rental Owner',
        'Tenant Names',
        'End Date',
        'Rent Cycle',
        'Remaining Days',
        'Current Balance',
        'Rent',
      ];
      final csvBuffer = StringBuffer();
      csvBuffer.writeln(headers.join(','));

      for (final lease in leases) {
        final balanceStr = _formatCurrencyForExport(lease.totalBalance);
        final rentStr = _formatCurrencyForExport(lease.amount);
        final endDateStr = _formatDateSafely(lease.endDate, dateProvider);
        final row = [
          '"${(lease.rentalAddress ?? '').replaceAll('"', '""')}"',
          '"${(lease.rentalOwnerName ?? '').replaceAll('"', '""')}"',
          '"${(lease.tenantNames ?? '').replaceAll('"', '""')}"',
          '"${endDateStr.replaceAll('"', '""')}"',
          lease.rentCycle ?? '',
          lease.remainingDays ?? '',
          balanceStr,
          rentStr,
        ];
        csvBuffer.writeln(row.join(','));
      }

      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/Leases_Report_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}.csv';
      final file = File(path);
      await file.writeAsString(csvBuffer.toString(), flush: true);

      Fluttertoast.showToast(msg: 'CSV file saved');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error generating CSV: $e');
    }
  }
}
