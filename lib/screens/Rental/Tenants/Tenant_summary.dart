import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/AdminTenantInsuranceModel/adminTenantInsuranceModel.dart';
import 'package:three_zero_two_property/Model/lease_renter_insurance.dart';
import 'package:three_zero_two_property/repository/lease_rental_insurance_repo.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/provider/dateProvider.dart';
import 'package:three_zero_two_property/repository/AdminTenantInsuranceService/adminTenantinsuranceService.dart';
import 'package:three_zero_two_property/repository/tenants.dart';
import 'package:three_zero_two_property/screens/Leasing/RentalRoll/SummeryPageLease.dart';

import 'package:three_zero_two_property/screens/Rental/Tenants/AdminTenantInsurance/addAdminTenantInsurance.dart';
import 'package:three_zero_two_property/screens/Rental/Tenants/AdminTenantInsurance/editAdminTenantInsurance.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

import 'package:email_validator/email_validator.dart';
import '../../../Model/tenants.dart';
import '../../../model/rentalOwner.dart';

import '../../../repository/Rental_ownersData.dart';
import '../../../widgets/drawer_tiles.dart';
import '../../../widgets/custom_drawer.dart';
import '../../../widgets/custom_history_table.dart';
import '../../../enums/history_type.dart';
import '../../Communications/Send E-mail/send_mail.dart';
import '../../Leasing/RentalRoll/Commnunication/communication.dart';
import 'Commnunication/communication.dart';
import 'Payments/Tenant_payments.dart';
import 'edit_tenants.dart';
import 'package:three_zero_two_property/screens/Maintenance/Workorder/Workorder_table.dart';
import 'package:three_zero_two_property/screens/Leasing/RentalRoll/addcard/AddCard.dart';

class ResponsiveTenantSummary extends StatefulWidget {
  Tenant? tenants;
  String tenantId;
  ResponsiveTenantSummary({super.key, required this.tenantId, this.tenants});
  @override
  State<ResponsiveTenantSummary> createState() =>
      _ResponsiveTenantSummaryState();
}

class _ResponsiveTenantSummaryState extends State<ResponsiveTenantSummary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 500) {
            return TenantSummaryTablet(
              tenants: widget.tenants,
              tenantId: widget.tenantId,
            );
          } else {
            return TenantSummaryMobile(
              tenants: widget.tenants,
              tenantId: widget.tenantId,
            );
          }
        },
      ),
    );
  }
}

class TenantSummaryMobile extends StatefulWidget {
  Tenant? tenants;
  String tenantId;
  TenantSummaryMobile({super.key, required this.tenantId, this.tenants});
  @override
  State<TenantSummaryMobile> createState() => _TenantSummaryMobileState();
}

class _TenantSummaryMobileState extends State<TenantSummaryMobile>
    with SingleTickerProviderStateMixin {
  late Future<List<TenantLeaseData>> futurePropertyLease;
  Future<List<TenantLeaseData>> fetchLeaseData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    String url = '$Api_url/api/tenant/tenant_details/${widget.tenantId}';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    if (response.statusCode == 200) {
      print(response.body);
      final jsonResponse = json.decode(response.body);
      final tenantResponse = TenantResponse.fromJson(jsonResponse);
      // Collect all lease data from all tenant data
      List<TenantLeaseData> allLeaseData = [];
      if (tenantResponse.data != null) {
        for (var tenant in tenantResponse.data!) {
          if (tenant.leaseData != null) {
            allLeaseData.addAll(tenant.leaseData!);
            print(allLeaseData);
          }
        }
      }
      final data = tenantResponse.data;
      final tenantDetails =
          (data != null && data.isNotEmpty) ? data.first : null;
      setState(() {
        _tenantDetails = tenantDetails;
        if (widget.tenants != null) {
          widget.tenants!.leaseData = allLeaseData;
        }
      });
      return allLeaseData;
    } else {
      throw Exception('Failed to load lease data');
    }
  }

  Tenant? _tenantDetails;
  int? expandedEmergencyIndex;
  bool expandedTenantInfo = false;

  Future<void> _refreshTenantDetails() async {
    try {
      final list = await _tenantService.fetchTenantsummery(widget.tenantId);
      if (mounted && list != null && list.isNotEmpty) {
        setState(() => _tenantDetails = list.first);
      }
    } catch (_) {}
  }

  final TenantsRepository _tenantService = TenantsRepository();
  final TenantsRepository repo = TenantsRepository();

  int totalrecords = 0;
  late Future<List<lease_renter_insurance>> futurePropertyTypes;
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

  void sortData(List<lease_renter_insurance> data) {
    /*  if (sorting1) {
      data.sort((a, b) => ascending1
          ? a.propertyType!.compareTo(b.propertyType!)
          : b.propertyType!.compareTo(a.propertyType!));
    } else if (sorting2) {
      data.sort((a, b) => ascending2
          ? a.propertysubType!.compareTo(b.propertysubType!)
          : b.propertysubType!.compareTo(a.propertysubType!));
    } else if (sorting3) {
      data.sort((a, b) => ascending3
          ? a.createdAt!.compareTo(b.createdAt!)
          : b.createdAt!.compareTo(a.createdAt!));
    }*/
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
          color: const Color(0xFFF4F8FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFDBE0E5))),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
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
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Text("Company",
                          style: TextStyle(
                              color: blueColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ),
                    // Text("Property", style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 3),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: Text("Policy Id",
                          style: TextStyle(
                              color: blueColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 5),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaders_lease() {
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
            SizedBox(width: MediaQuery.of(context).size.width * .02),
            Expanded(
              flex: 2,
              child: Text("     Status",
                  style: TextStyle(
                      color: blueColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ),
            Expanded(
              flex: 2,
              child: Text("    Property",
                  style: TextStyle(
                      color: blueColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 25),
          ],
        ),
      ),
    );
  }

  final List<String> items = ['Residential', "Commercial", "All"];
  String? selectedValue;
  String searchvalue = "";
  ConnectivityResult? _connectivityResult;
  int _tenantSummaryTabIndex = 0;
  int _historyRefreshKey = 0;

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
    futurePropertyTypes =
        RentersInsuranceService().fetchPoliciesByTenant(widget.tenantId);
    futurePropertyLease = fetchLeaseData();
  }

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
  }

  static const List<String> _tenantSummaryTabTitles = [
    'Summary',
    'Leases',
    'Communications',
    'Payments',
    'Work Orders',
  ];

  String _tenantSummaryTabIconAsset(String title) {
    switch (title) {
      case 'Summary':
        return 'assets/icons/summery.png';
      case 'Leases':
        return 'assets/icons/document.png';
      case 'Communications':
        return 'assets/icons/communication.png';
      case 'Payments':
        return 'assets/icons/financial.png';
      case 'Work Orders':
        return 'assets/icons/maintence.png';
      default:
        return 'assets/icons/summery.png';
    }
  }

  /// Property-summary style section tabs (dropdown), below the blue "Summary" title bar.
  Widget _buildTenantSummaryTabDropdown(BuildContext context) {
    final tabTitles = _tenantSummaryTabTitles;
    final safeIndex = _tenantSummaryTabIndex.clamp(0, tabTitles.length - 1);
    final selectedTitle = tabTitles[safeIndex];

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButton2<String>(
        isExpanded: true,
        underline: const SizedBox(),
        value: selectedTitle,
        selectedItemBuilder: (BuildContext context) {
          return tabTitles.map((String title) {
            final iconPath = _tenantSummaryTabIconAsset(title);
            return Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Image.asset(iconPath, width: 20, height: 20),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: blueColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList();
        },
        items: tabTitles.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          final iconPath = _tenantSummaryTabIconAsset(title);
          return DropdownMenuItem<String>(
            value: title,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: index < tabTitles.length - 1
                    ? Border(
                        bottom: BorderSide(
                          color: blueColor.withOpacity(0.2),
                          width: 0.5,
                        ),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Image.asset(iconPath,
                      width: 20, height: 20, color: blueColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: blueColor,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 25, color: blueColor),
                ],
              ),
            ),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            final idx = tabTitles.indexOf(value);
            if (idx >= 0) {
              setState(() => _tenantSummaryTabIndex = idx);
            }
          }
        },
        buttonStyleData: ButtonStyleData(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade400,
              width: 1,
            ),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          iconSize: 24,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: MediaQuery.of(context).size.height * 0.54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            border: Border.all(
              color: Colors.grey.shade500,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(10, 10),
              ),
            ],
          ),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: MaterialStateProperty.all(6),
            thumbVisibility: MaterialStateProperty.all(false),
          ),
        ),
        menuItemStyleData: MenuItemStyleData(
          height: 50,
          padding: EdgeInsets.zero,
          overlayColor: MaterialStateProperty.all(Colors.grey[100]),
        ),
      ),
    );
  }

  void handleEdit(lease_renter_insurance property) async {}

  void _showAlert(BuildContext context, String id) {
    TextEditingController reason = TextEditingController();
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this Insurance!",
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
        DialogButton(
          child: const Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            if (reason.text.isEmpty) {
              Fluttertoast.showToast(msg: "Please enter a reason for deletion");
            } else {
              await RentersInsuranceService()
                  .deleteInsurance(renters_insurance_id: id);
              setState(() {
                futurePropertyTypes = RentersInsuranceService()
                    .fetchPoliciesByTenant(widget.tenantId);
              });
              Navigator.pop(context);
            }
          },
          color: blueColor,
        )
      ],
    ).show();
  }

  void _showAddInsuranceAlert(BuildContext context, VoidCallback onConfirm) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Add New Insurance",
      desc:
          "If you add a new renter's insurance, the older one will get expired. Do you want to proceed?",
      style: const AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
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
        DialogButton(
          child: const Text(
            "Yes",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () {
            Navigator.pop(context); // Close the alert
            onConfirm(); // Execute the confirm action
          },
          color: Colors.red,
        ),
      ],
    ).show();
  }

  List<lease_renter_insurance> _tableData = [];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<lease_renter_insurance> get _pagedData {
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

  void _sort<T>(Comparable<T> Function(lease_renter_insurance d) getField,
      int columnIndex, bool ascending) {
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

  void handleDelete(lease_renter_insurance property) {}

  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(lease_renter_insurance d)? getField) {
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
      child: Container(
        height: 60,
        padding: const EdgeInsets.only(top: 20.0, left: 16),
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildActionsCell(lease_renter_insurance data) {
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

  //Tenant lease
  int totalrecordsTenantLease = 0;
  // late Future<List<TenantLeaseData>> futurePropertyTypes;
  int rowsPerPageTenantLease = 5;
  int sortColumnIndexTenantLease = 0;
  bool sortAscendingTenantLease = true;
  int currentPageTenantLease = 0;
  int itemsPerPageTenantLease = 10;
  List<int> itemsPerPageOptionsTenantLease = [
    10,
    25,
    50,
    100,
  ]; // Options for items per page

  void sortDataTenantLease(List<TenantLeaseData> data) {
    /*  if (sorting1) {
      data.sort((a, b) => ascending1
          ? a.propertyType!.compareTo(b.propertyType!)
          : b.propertyType!.compareTo(a.propertyType!));
    } else if (sorting2) {
      data.sort((a, b) => ascending2
          ? a.propertysubType!.compareTo(b.propertysubType!)
          : b.propertysubType!.compareTo(a.propertysubType!));
    } else if (sorting3) {
      data.sort((a, b) => ascending3
          ? a.createdAt!.compareTo(b.createdAt!)
          : b.createdAt!.compareTo(a.createdAt!));
    }*/
  }

  int? expandedTenantLeaseIndex;
  Set<int> expandedTenantLeaseIndices = {};
  late bool isExpandedTenantLease;
  bool sorting1TenantLease = false;
  bool sorting2TenantLease = false;
  bool sorting3TenantLease = false;
  bool ascending1TenantLease = false;
  bool ascending2TenantLease = false;
  bool ascending3TenantLease = false;
  Widget _buildHeadersTenantLease() {
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (sorting1TenantLease == true) {
                      sorting2TenantLease = false;
                      sorting3TenantLease = false;
                      ascending1TenantLease =
                          sorting1TenantLease ? !ascending1TenantLease : true;
                      ascending2TenantLease = false;
                      ascending3TenantLease = false;
                    } else {
                      sorting1TenantLease = !sorting1TenantLease;
                      sorting2TenantLease = false;
                      sorting3TenantLease = false;
                      ascending1TenantLease =
                          sorting1TenantLease ? !ascending1TenantLease : true;
                      ascending2TenantLease = false;
                      ascending3TenantLease = false;
                    }

                    // Sorting logic here
                  });
                },
                child: Row(
                  children: [
                    width < 400
                        ? const Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Text(
                              "Status",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : const Text("     Insurance Company",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                            textAlign: TextAlign.center),
                    // Text("Property", style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 3),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (sorting2TenantLease) {
                      sorting1TenantLease = false;
                      sorting2TenantLease = sorting2TenantLease;
                      sorting3TenantLease = false;
                      ascending2TenantLease = sorting2 ? !ascending2 : true;
                      ascending1TenantLease = false;
                      ascending3TenantLease = false;
                    } else {
                      sorting1TenantLease = false;
                      sorting2TenantLease = !sorting2TenantLease;
                      sorting3TenantLease = false;
                      ascending2TenantLease =
                          sorting2TenantLease ? !ascending2TenantLease : true;
                      ascending1TenantLease = false;
                      ascending3TenantLease = false;
                    }
                    // Sorting logic here
                  });
                },
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 0.0),
                      child: Text("Start Date",
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                    ),
                    SizedBox(width: 5),
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
                      sorting1TenantLease = false;
                      sorting2TenantLease = false;
                      sorting3TenantLease = sorting3TenantLease;
                      ascending3TenantLease =
                          sorting3TenantLease ? !ascending3TenantLease : true;
                      ascending2TenantLease = false;
                      ascending1TenantLease = false;
                    } else {
                      sorting1TenantLease = false;
                      sorting2TenantLease = false;
                      sorting3TenantLease = !sorting3TenantLease;
                      ascending3TenantLease =
                          sorting3TenantLease ? !ascending3TenantLease : true;
                      ascending2TenantLease = false;
                      ascending1TenantLease = false;
                    }

                    // Sorting logic here
                  });
                },
                child: const Row(
                  children: [
                    Text(
                      "End\nDate",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(width: 5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<String> itemsTenantLease = ['Residential', "Commercial", "All"];
  String? selectedValueTenantLease;
  String searchvalueTenantLease = "";

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    return Scaffold(
      // appBar: widget302.,
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Tenants",
        dropdown: true,
      ),
      body: _connectivityResult != ConnectivityResult.none
          ? Center(
              child: ListView(
                scrollDirection: Axis.vertical,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Icon(
                              Icons.arrow_back_ios_new_sharp,
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.tenants?.tenantFirstName ?? 'Loading...'} ${widget.tenants?.tenantLastName ?? ''}',
                                style: TextStyle(
                                  color: blueColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Tenant',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF8A95A8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    await Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => send_email(
                                                  lease: [widget.tenantId],
                                                  leaseID: null,
                                                )));
                                  },
                                  child: Container(
                                    height: (MediaQuery.of(context).size.width <
                                            500)
                                        ? 35
                                        : MediaQuery.of(context).size.width *
                                            0.063,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: blueColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Send Mail",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 14
                                              : 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () async {
                                    List<Tenant> tenantData =
                                        await TenantsRepository()
                                                .fetchTenantsummery(
                                                    widget.tenantId) ??
                                            [];
                                    if (tenantData.isNotEmpty && mounted) {
                                      await Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => EditTenants(
                                                    tenantId: widget.tenantId,
                                                    tenants: tenantData.first,
                                                  )));
                                    }
                                  },
                                  child: Container(
                                    height: (MediaQuery.of(context).size.width <
                                            500)
                                        ? 35
                                        : MediaQuery.of(context).size.width *
                                            0.063,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: blueColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Edit",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 14
                                              : 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15, right: 15, top: 4, bottom: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Container(
                        height: 50.0,
                        padding: const EdgeInsets.only(top: 10, left: 12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: blueColor,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 1.0),
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: const Text(
                          'Summary',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  _buildTenantSummaryTabDropdown(context),
                  // const SizedBox(
                  //   height: 20,
                  // ),
                  if (_tenantSummaryTabIndex == 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Material(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          // decoration: BoxDecoration(
                          //   color: Colors.white,
                          //   borderRadius: BorderRadius.circular(10),
                          //   border: Border.all(color: blueColor),
                          // ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 2, bottom: 30),
                            child: Column(
                              children: [
                                //tenant info table

                                // //Contact Information
                                // Container(
                                //   padding: const EdgeInsets.all(16.0),
                                //   decoration: BoxDecoration(
                                //     border:
                                //         Border.all(color: Colors.grey.shade300),
                                //     borderRadius: BorderRadius.circular(12.0),
                                //   ),
                                //   child: Column(
                                //     crossAxisAlignment:
                                //         CrossAxisAlignment.start,
                                //     children: [
                                //       Text(
                                //         'Contact Information',
                                //         style: TextStyle(
                                //             color: blueColor,
                                //             fontWeight: FontWeight.bold,
                                //             // fontSize: 18
                                //             fontSize: MediaQuery.of(context)
                                //                     .size
                                //                     .width *
                                //                 .045),
                                //       ),
                                //       const SizedBox(height: 16),
                                //       Row(
                                //         children: [
                                //           Expanded(
                                //             child: Column(
                                //               crossAxisAlignment:
                                //                   CrossAxisAlignment.start,
                                //               children: [
                                //                 const Text('Name',
                                //                     style: TextStyle(
                                //                         fontWeight:
                                //                             FontWeight.bold,
                                //                         color:
                                //                             Color(0xFF101828))),
                                //                 const SizedBox(height: 4),
                                //                 Text(
                                //                   '${(widget.tenants?.tenantFirstName ?? '').isEmpty ? 'N/A' : widget.tenants?.tenantFirstName}',
                                //                   style: TextStyle(
                                //                       color:
                                //                           Colors.grey.shade700),
                                //                 ),
                                //               ],
                                //             ),
                                //           ),
                                //           const Spacer(),
                                //           Expanded(
                                //             child: Column(
                                //               crossAxisAlignment:
                                //                   CrossAxisAlignment.start,
                                //               children: [
                                //                 const Text('Phone Number',
                                //                     style: TextStyle(
                                //                       fontWeight:
                                //                           FontWeight.bold,
                                //                       color: Color(0xFF101828),
                                //                     )),
                                //                 const SizedBox(height: 4),
                                //                 Text(
                                //                   formatPhoneNumber(
                                //                       '${widget.tenants?.tenantPhoneNumber ?? 'N/A'}'),
                                //                   style: TextStyle(
                                //                       color:
                                //                           Colors.grey.shade700),
                                //                 ),
                                //               ],
                                //             ),
                                //           ),
                                //         ],
                                //       ),
                                //       const SizedBox(height: 16),
                                //       Column(
                                //         crossAxisAlignment:
                                //             CrossAxisAlignment.start,
                                //         children: [
                                //           const Text('E-Mail Address',
                                //               style: TextStyle(
                                //                   fontWeight: FontWeight.bold,
                                //                   color: Color(0xFF101828))),
                                //           const SizedBox(height: 4),
                                //           Text(
                                //             '${(widget.tenants?.tenantEmail ?? '').isEmpty ? 'N/A' : widget.tenants?.tenantEmail}',
                                //             style: TextStyle(
                                //                 color: Colors.grey.shade700),
                                //           ),
                                //         ],
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                // const SizedBox(
                                //   height: 10,
                                // ),
                                // //Personal Information
                                // Container(
                                //   padding: const EdgeInsets.all(16),
                                //   decoration: BoxDecoration(
                                //     border:
                                //         Border.all(color: Colors.grey.shade300),
                                //     borderRadius: BorderRadius.circular(12),
                                //   ),
                                //   child: Column(
                                //     crossAxisAlignment:
                                //         CrossAxisAlignment.start,
                                //     children: [
                                //       Text(
                                //         "Personal Information",
                                //         style: TextStyle(
                                //             color: blueColor,
                                //             fontWeight: FontWeight.bold,
                                //             // fontSize: 18
                                //             fontSize: MediaQuery.of(context)
                                //                     .size
                                //                     .width *
                                //                 .045),
                                //       ),
                                //       const SizedBox(height: 20),

                                //       // Birth Date & TaxPayer ID side-by-side
                                //       Row(
                                //         children: [
                                //           Expanded(
                                //             child: Column(
                                //               crossAxisAlignment:
                                //                   CrossAxisAlignment.start,
                                //               children: [
                                //                 const Text('Birth Date',
                                //                     style: TextStyle(
                                //                         fontWeight:
                                //                             FontWeight.bold,
                                //                         color:
                                //                             Color(0xFF101828))),
                                //                 const SizedBox(height: 4),
                                //                 Text(
                                //                   '${(widget.tenants?.tenantBirthDate ?? '').isEmpty ? 'N/A' : dateProvider.formatCurrentDate('${widget.tenants?.tenantBirthDate}')}',
                                //                   style: const TextStyle(
                                //                       fontWeight:
                                //                           FontWeight.bold,
                                //                       color: Colors.grey),
                                //                 ),
                                //               ],
                                //             ),
                                //           ),
                                //           const Spacer(),
                                //           Expanded(
                                //             child: Column(
                                //               crossAxisAlignment:
                                //                   CrossAxisAlignment.start,
                                //               children: [
                                //                 const Text('TaxPayer Id',
                                //                     style: TextStyle(
                                //                         fontWeight:
                                //                             FontWeight.bold,
                                //                         color:
                                //                             Color(0xFF101828))),
                                //                 const SizedBox(height: 4),
                                //                 Text(
                                //                   '${(widget.tenants?.taxPayerId ?? '').isEmpty ? 'N/A' : widget.tenants?.taxPayerId}',
                                //                   style: const TextStyle(
                                //                       fontWeight:
                                //                           FontWeight.bold,
                                //                       color: Colors.grey),
                                //                 ),
                                //               ],
                                //             ),
                                //           ),
                                //         ],
                                //       ),

                                //       const SizedBox(height: 20),

                                //       // Comments field full width
                                //       Column(
                                //         crossAxisAlignment:
                                //             CrossAxisAlignment.start,
                                //         children: [
                                //           const Text('Comments',
                                //               style: TextStyle(
                                //                   fontWeight: FontWeight.bold,
                                //                   color: Color(0xFF101828))),
                                //           const SizedBox(height: 4),
                                //           Text(
                                //             '${(widget.tenants?.comments ?? '').isEmpty ? 'N/A' : widget.tenants?.comments}',
                                //             style: const TextStyle(
                                //                 fontWeight: FontWeight.bold,
                                //                 color: Colors.grey),
                                //           ),
                                //         ],
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                // const SizedBox(
                                //   height: 10,
                                // ),
                                // //Emergency Contact
                                // Container(
                                //   padding: const EdgeInsets.all(16),
                                //   decoration: BoxDecoration(
                                //     border:
                                //         Border.all(color: Colors.grey.shade300),
                                //     borderRadius: BorderRadius.circular(12),
                                //   ),
                                //   child: Column(
                                //     crossAxisAlignment:
                                //         CrossAxisAlignment.start,
                                //     children: [
                                //       Text(
                                //         'Emergency Contact',
                                //         style: TextStyle(
                                //             color: blueColor,
                                //             fontWeight: FontWeight.bold,
                                //             // fontSize: 18
                                //             fontSize: MediaQuery.of(context)
                                //                     .size
                                //                     .width *
                                //                 .045),
                                //       ),
                                //       const SizedBox(height: 20),
                                //       // Contact Name & Relation side-by-side
                                //       Row(
                                //         children: [
                                //           Expanded(
                                //             child: Column(
                                //               crossAxisAlignment:
                                //                   CrossAxisAlignment.start,
                                //               children: [
                                //                 const Text('Contact Name',
                                //                     style: TextStyle(
                                //                         fontWeight:
                                //                             FontWeight.bold,
                                //                         color:
                                //                             Color(0xFF101828))),
                                //                 const SizedBox(height: 4),
                                //                 Text(
                                //                   '${(widget.tenants?.emergencyContact?.name ?? '').isEmpty ? 'N/A' : widget.tenants?.emergencyContact!.name}',
                                //                   style: const TextStyle(
                                //                       fontWeight:
                                //                           FontWeight.bold,
                                //                       color: Colors.grey),
                                //                 ),
                                //               ],
                                //             ),
                                //           ),
                                //           const Spacer(),
                                //           Expanded(
                                //             child: Column(
                                //               crossAxisAlignment:
                                //                   CrossAxisAlignment.start,
                                //               children: [
                                //                 const Text(
                                //                     'Relation With Tenant',
                                //                     style: TextStyle(
                                //                         fontWeight:
                                //                             FontWeight.bold,
                                //                         color:
                                //                             Color(0xFF101828))),
                                //                 const SizedBox(height: 4),
                                //                 Text(
                                //                   '${(widget.tenants?.emergencyContact?.relation ?? '').isEmpty ? 'N/A' : widget.tenants?.emergencyContact!.relation}',
                                //                   style: const TextStyle(
                                //                       fontWeight:
                                //                           FontWeight.bold,
                                //                       color: Colors.grey),
                                //                 ),
                                //               ],
                                //             ),
                                //           ),
                                //         ],
                                //       ),
                                //       const SizedBox(height: 20),
                                //       // Email & Phone side-by-side
                                //       Row(
                                //         children: [
                                //           Expanded(
                                //             child: Column(
                                //               crossAxisAlignment:
                                //                   CrossAxisAlignment.start,
                                //               children: [
                                //                 const Text('Emergency Email',
                                //                     style: TextStyle(
                                //                         fontWeight:
                                //                             FontWeight.bold,
                                //                         color:
                                //                             Color(0xFF101828))),
                                //                 const SizedBox(height: 4),
                                //                 Text(
                                //                   '${(widget.tenants?.emergencyContact?.email ?? '').isEmpty ? 'N/A' : widget.tenants?.emergencyContact!.email}',
                                //                   style: const TextStyle(
                                //                       fontWeight:
                                //                           FontWeight.bold,
                                //                       color: Colors.grey),
                                //                 ),
                                //               ],
                                //             ),
                                //           ),
                                //           const Spacer(),
                                //           Expanded(
                                //             child: Column(
                                //               crossAxisAlignment:
                                //                   CrossAxisAlignment.start,
                                //               children: [
                                //                 const Text('Emergency Phone',
                                //                     style: TextStyle(
                                //                         fontWeight:
                                //                             FontWeight.bold,
                                //                         color:
                                //                             Color(0xFF101828))),
                                //                 const SizedBox(height: 4),
                                //                 Text(
                                //                   '${(widget.tenants?.emergencyContact?.phoneNumber ?? '').isEmpty ? 'N/A' : formatPhoneNumber(widget.tenants?.emergencyContact!.phoneNumber ?? "")}',
                                //                   style: const TextStyle(
                                //                       fontWeight:
                                //                           FontWeight.bold,
                                //                       color: Colors.grey),
                                //                 ),
                                //               ],
                                //             ),
                                //           ),
                                //         ],
                                //       ),
                                //     ],
                                //   ),
                                // ),

                                _buildTenantInfoSection(),
                                const SizedBox(
                                  height: 10,
                                ),

                                Builder(builder: (context) {
                                  final t = _tenantDetails ?? widget.tenants;
                                  // Default both on when API omits allow_ach / allow_card (null).
                                  final allowAch = t?.allowAch != false;
                                  final allowCard = t?.allowCard != false;
                                  final canEdit = t != null;
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            const SizedBox(width: 2),
                                            Text(
                                              "Payments Details",
                                              style: TextStyle(
                                                color: blueColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const SizedBox(width: 2),
                                            Text(
                                              "Allowed Payment Methods",
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 10,
                                                    child: Checkbox(
                                                      value: allowAch,
                                                      onChanged: canEdit
                                                          ? (v) =>
                                                              _onPaymentAllowAchChanged(
                                                                  v == true)
                                                          : null,
                                                      activeColor: blueColor,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    "ACH",
                                                    style: TextStyle(
                                                      color: allowAch
                                                          ? blueColor
                                                          : Colors
                                                              .grey.shade600,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 10,
                                                    child: Checkbox(
                                                      value: allowCard,
                                                      onChanged: canEdit
                                                          ? (v) =>
                                                              _onPaymentAllowCardChanged(
                                                                  v == true)
                                                          : null,
                                                      activeColor: blueColor,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    "Card",
                                                    style: TextStyle(
                                                      color: allowCard
                                                          ? blueColor
                                                          : Colors
                                                              .grey.shade600,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap:
                                                    _openManagePaymentMethods,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: blueColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: const Text(
                                                    "Manage Payment Methods",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }),

                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const SizedBox(width: 2),
                                          Text(
                                            "Lease Details",
                                            style: TextStyle(
                                              color: blueColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        // padding: const EdgeInsets.symmetric(
                                        //     horizontal: 10.0),
                                        child: FutureBuilder<
                                            List<TenantLeaseData>>(
                                          future: futurePropertyLease,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        minHeight: 140),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 24),
                                                child: Center(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      SpinKitFadingCircle(
                                                          color: blueColor,
                                                          size: 36.0),
                                                      const SizedBox(
                                                          height: 12),
                                                      Text(
                                                          'Loading lease details...',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.grey
                                                                  .shade600)),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            } else if (snapshot.hasError) {
                                              return Center(
                                                  child: Text(
                                                      'Error: ${snapshot.error}'));
                                            } else if (!snapshot.hasData ||
                                                snapshot.data!.isEmpty) {
                                              return Container(
                                                  height: 80,
                                                  child: const Center(
                                                      child: Text(
                                                          'No Data Available')));
                                            } else {
                                              var data = snapshot.data!;

                                              if (selectedValueTenantLease ==
                                                      null &&
                                                  searchvalueTenantLease!
                                                      .isEmpty) {
                                                data = snapshot.data!;
                                              } else if (selectedValueTenantLease ==
                                                  "All") {
                                                data = snapshot.data!;
                                              } else if (searchvalueTenantLease!
                                                  .isNotEmpty) {
                                                data = snapshot.data!
                                                    .where((property) => property
                                                        .startDate!
                                                        .toLowerCase()
                                                        .contains(
                                                            searchvalueTenantLease!
                                                                .toLowerCase()))
                                                    .toList();
                                              }
                                              if (data.length == 0) {
                                                return const Column(
                                                  children: [
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                    Center(
                                                      child:
                                                          Text('No Data Available'),
                                                    ),
                                                  ],
                                                );
                                              }
                                              sortDataTenantLease(data);
                                              final totalPages = (data.length /
                                                      itemsPerPageTenantLease)
                                                  .ceil();
                                              final currentPageData = data
                                                  .skip(currentPageTenantLease *
                                                      itemsPerPageTenantLease)
                                                  .take(itemsPerPageTenantLease)
                                                  .toList();
                                              return SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    const SizedBox(height: 5),
                                                    _buildHeaders_lease(),
                                                    const SizedBox(height: 10),
                                                    Container(
                                                      // decoration: BoxDecoration(
                                                      //     border: Border.all(
                                                      //         color: Color
                                                      //             .fromRGBO(
                                                      //                 152,
                                                      //                 162,
                                                      //                 179,
                                                      //                 .5))),
                                                      // decoration: BoxDecoration(
                                                      //     border: Border.all(
                                                      //         color: blueColor)),
                                                      child: Column(
                                                        children:
                                                            currentPageData
                                                                .asMap()
                                                                .entries
                                                                .map((entry) {
                                                          int index = entry.key;
                                                          bool
                                                              isExpandedTenantLease =
                                                              expandedTenantLeaseIndex ==
                                                                  index;
                                                          TenantLeaseData
                                                              Propertytype =
                                                              entry.value;
                                                          //return CustomExpansionTile(data: Propertytype, index: index);
                                                          return Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        5),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: index %
                                                                          2 !=
                                                                      0
                                                                  ? const Color(
                                                                      0xFFF4F8FF)
                                                                  : Colors
                                                                      .white,
                                                              border: Border.all(
                                                                  color: const Color(
                                                                      0xFFDBE0E5)),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            // decoration: BoxDecoration(
                                                            //   border: Border.all(
                                                            //       color: blueColor),
                                                            // ),
                                                            child: Column(
                                                              children: <Widget>[
                                                                ListTile(
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  title:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            2.0),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: <Widget>[
                                                                        SizedBox(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * .02),
                                                                        InkWell(
                                                                          onTap:
                                                                              () {
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
                                                                              if (expandedTenantLeaseIndex == index) {
                                                                                expandedTenantLeaseIndex = null;
                                                                              } else {
                                                                                expandedTenantLeaseIndex = index;
                                                                              }
                                                                            });
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            margin:
                                                                                const EdgeInsets.only(left: 5),
                                                                            padding: !isExpandedTenantLease
                                                                                ? const EdgeInsets.only(bottom: 10)
                                                                                : const EdgeInsets.only(top: 10),
                                                                            child:
                                                                                FaIcon(
                                                                              isExpandedTenantLease ? FontAwesomeIcons.sortUp : FontAwesomeIcons.sortDown,
                                                                              size: 20,
                                                                              color: blueColor,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          flex: 2,
                                                                          child:
                                                                              InkWell(
                                                                            onTap:
                                                                                () {
                                                                              setState(() {
                                                                                if (expandedTenantLeaseIndex == index) {
                                                                                  expandedTenantLeaseIndex = null;
                                                                                } else {
                                                                                  expandedTenantLeaseIndex = index;
                                                                                }
                                                                              });
                                                                            },
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.only(left: 5.0),
                                                                              child: Text(
                                                                                '${determineStatus(Propertytype.startDate, Propertytype.endDate)}',
                                                                                style: TextStyle(
                                                                                  color: blueColor,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontSize: 13,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(width: 10),
                                                                        Expanded(
                                                                          flex: 2,
                                                                          child: Text(
                                                                            '${Propertytype.rentalAdress ?? ''}',
                                                                            style: TextStyle(
                                                                              color: blueColor,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 12,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(width: 25),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                if (isExpandedTenantLease)
                                                                  Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            8.0),
                                                                    margin: const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            20),
                                                                    child:
                                                                        SingleChildScrollView(
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: [
                                                                              FaIcon(
                                                                                isExpandedTenantLease ? FontAwesomeIcons.sortUp : FontAwesomeIcons.sortDown,
                                                                                size: 20,
                                                                                color: Colors.transparent,
                                                                              ),
                                                                              Expanded(
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: <Widget>[
                                                                                    Text.rich(
                                                                                      TextSpan(
                                                                                        children: [
                                                                                          TextSpan(
                                                                                            text: 'Start Date : ',
                                                                                            style: TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                                                                                          ),
                                                                                          TextSpan(
                                                                                            text: dateProvider.formatCurrentDate(normalizeDateForDisplay(Propertytype.startDate)),
                                                                                            style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.grey),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(height: 10),
                                                                                    Text.rich(
                                                                                      TextSpan(
                                                                                        children: [
                                                                                          TextSpan(
                                                                                            text: 'End Date : ',
                                                                                            style: TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                                                                                          ),
                                                                                          TextSpan(
                                                                                            text: dateProvider.formatCurrentDate(normalizeDateForDisplay(Propertytype.endDate)),
                                                                                            style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.grey),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(height: 10),
                                                                                    Text.rich(
                                                                                      TextSpan(
                                                                                        children: [
                                                                                          TextSpan(
                                                                                            text: 'Type : ',
                                                                                            style: TextStyle(fontWeight: FontWeight.bold, color: blueColor), // Bold and black
                                                                                          ),
                                                                                          TextSpan(
                                                                                            text: '${Propertytype.leaseType}',
                                                                                            style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.grey), // Light and grey
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      height: 10,
                                                                                    ),
                                                                                    Text.rich(
                                                                                      TextSpan(
                                                                                        children: [
                                                                                          TextSpan(
                                                                                            text: 'Rent Amount : ',
                                                                                            style: TextStyle(fontWeight: FontWeight.bold, color: blueColor), // Bold and black
                                                                                          ),
                                                                                          TextSpan(
                                                                                            text: formatCurrency(Propertytype.rentAmount),
                                                                                            style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.grey), // Light and grey
                                                                                          ),
                                                                                        ],
                                                                                      ),
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

                                SizedBox(height: 10),
                                //Rentals Insurance Policy
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Renter’s Insurance Policy',
                                            style: TextStyle(
                                              color: blueColor,
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          GestureDetector(
                                            onTap: () async {
                                              final result =
                                                  await Navigator.of(context)
                                                      .push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AdminAddTenantInsurance(
                                                    tenantid: widget.tenantId,
                                                  ),
                                                ),
                                              );
                                              if (result == true) {
                                                setState(() {
                                                  futurePropertyTypes =
                                                      RentersInsuranceService()
                                                          .fetchPoliciesByTenant(
                                                              widget.tenantId);
                                                });
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                color: blueColor,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                  size: 22,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // if (MediaQuery.of(context).size.width < 500)
                                      //   const SizedBox(height: 5),
                                      if (MediaQuery.of(context).size.width >
                                          500)
                                        const SizedBox(height: 25),
                                      if (MediaQuery.of(context).size.width <
                                          500)
                                        Container(
                                          // padding: const EdgeInsets.symmetric(
                                          //     horizontal: 10.0),
                                          child: FutureBuilder<
                                              List<lease_renter_insurance>>(
                                            future: futurePropertyTypes,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Container(
                                                  constraints:
                                                      const BoxConstraints(
                                                          minHeight: 140),
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 24),
                                                  child: Center(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        SpinKitFadingCircle(
                                                            color: blueColor,
                                                            size: 36.0),
                                                        const SizedBox(
                                                            height: 12),
                                                        Text(
                                                            'Loading Renter\'s Insurance...',
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .grey
                                                                    .shade600)),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              } else if (snapshot.hasError) {
                                                return Center(
                                                    child: Text(
                                                        'Error: ${snapshot.error}'));
                                              } else if (!snapshot.hasData ||
                                                  snapshot.data!.isEmpty) {
                                                return Column(
                                                  children: [
                                                    const SizedBox(height: 10),
                                                    _buildHeaders(),
                                                    const SizedBox(height: 20),
                                                    const Center(child: Text('No Data Available')),
                                                  ],
                                                );
                                              } else {
                                                var data = snapshot.data!
                                                    .where((p) => p.policyStatus?.toUpperCase() == 'ACTIVE')
                                                    .toList();
                                                if (searchvalue!.isNotEmpty) {
                                                  data = data
                                                      .where((property) => (property
                                                                  .insuranceCompany ??
                                                              '')
                                                          .toLowerCase()
                                                          .contains(searchvalue!
                                                              .toLowerCase()))
                                                      .toList();
                                                }
                                                if (data.length == 0) {
                                                  return Column(
                                                    children: [
                                                      const SizedBox(height: 10),
                                                      _buildHeaders(),
                                                      const SizedBox(height: 20),
                                                      const Center(child: Text('No Data Available')),
                                                    ],
                                                  );
                                                }
                                                sortData(data);
                                                final totalPages =
                                                    (data.length / itemsPerPage)
                                                        .ceil();
                                                final currentPageData = data
                                                    .skip(currentPage *
                                                        itemsPerPage)
                                                    .take(itemsPerPage)
                                                    .toList();
                                                return SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(
                                                          height: 10),
                                                      _buildHeaders(),
                                                      const SizedBox(
                                                          height: 10),
                                                      Container(
                                                        // decoration: BoxDecoration(
                                                        //     border: Border.all(
                                                        //         color: Color
                                                        //             .fromRGBO(
                                                        //                 152,
                                                        //                 162,
                                                        //                 179,
                                                        //                 .5))),
                                                        // decoration: BoxDecoration(
                                                        //     border: Border.all(
                                                        //         color: blueColor)),
                                                        child: Column(
                                                          children:
                                                              currentPageData
                                                                  .asMap()
                                                                  .entries
                                                                  .map((entry) {
                                                            int index =
                                                                entry.key;
                                                            bool isExpanded =
                                                                expandedIndex ==
                                                                    index;
                                                            lease_renter_insurance
                                                                Propertytype =
                                                                entry.value;
                                                            //return CustomExpansionTile(data: Propertytype, index: index);
                                                            return Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          5),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: index %
                                                                            2 !=
                                                                        0
                                                                    ? const Color(
                                                                        0xFFF4F8FF)
                                                                    : Colors
                                                                        .white,
                                                                border: Border.all(
                                                                    color: const Color(
                                                                        0xFFDBE0E5)),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              child: Column(
                                                                children: <Widget>[
                                                                  ListTile(
                                                                    contentPadding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    title:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          2.0),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: <Widget>[
                                                                          InkWell(
                                                                            onTap:
                                                                                () {
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
                                                                                if (expandedIndex == index) {
                                                                                  expandedIndex = null;
                                                                                } else {
                                                                                  expandedIndex = index;
                                                                                }
                                                                              });
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              margin: const EdgeInsets.only(left: 5),
                                                                              padding: !isExpanded ? const EdgeInsets.only(bottom: 10) : const EdgeInsets.only(top: 10),
                                                                              child: FaIcon(
                                                                                isExpanded ? FontAwesomeIcons.sortUp : FontAwesomeIcons.sortDown,
                                                                                size: 20,
                                                                                color: blueColor,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            flex:
                                                                                2,
                                                                            child:
                                                                                InkWell(
                                                                              onTap: () {
                                                                                // Navigator.of(context)
                                                                                //     .push(MaterialPageRoute(builder: (context) => summery_page(lease_id: Propertytype.leaseId,)));
                                                                              },
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(left: 5.0),
                                                                                child: Text(
                                                                                  '${Propertytype.insuranceCompany ?? ''}',
                                                                                  style: TextStyle(
                                                                                    color: blueColor,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontSize: 13,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 20),
                                                                          Expanded(
                                                                            flex:
                                                                                2,
                                                                            child:
                                                                                Text(
                                                                              '${Propertytype.policyId ?? ''}',
                                                                              style: TextStyle(
                                                                                color: blueColor,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 12,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 25),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  if (isExpanded)
                                                                    Container(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              8.0),
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              5),
                                                                      child:
                                                                          SingleChildScrollView(
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                FaIcon(
                                                                                  isExpanded ? FontAwesomeIcons.sortUp : FontAwesomeIcons.sortDown,
                                                                                  size: 20,
                                                                                  color: Colors.transparent,
                                                                                ),
                                                                                Expanded(
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: <Widget>[
                                                                                      Text.rich(
                                                                                        TextSpan(
                                                                                          children: [
                                                                                            TextSpan(
                                                                                              text: 'Liability Coverage : ',
                                                                                              style: TextStyle(fontWeight: FontWeight.bold, color: blueColor), // Bold and black
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: '${Propertytype.liabilityCoverage ?? ''}',
                                                                                              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.grey), // Light and grey
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      const SizedBox(
                                                                                        height: 10,
                                                                                      ),
                                                                                      Text.rich(
                                                                                        TextSpan(
                                                                                          children: [
                                                                                            TextSpan(
                                                                                              text: 'Status : ',
                                                                                              style: TextStyle(fontWeight: FontWeight.bold, color: blueColor), // Bold and black
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: '${Propertytype.active == true ? 'Active' : 'Inactive'}',
                                                                                              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.grey), // Light and grey
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      const SizedBox(
                                                                                        height: 10,
                                                                                      ),
                                                                                      Text.rich(
                                                                                        TextSpan(
                                                                                          children: [
                                                                                            TextSpan(
                                                                                              text: 'Effective Date : ',
                                                                                              style: TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: dateProvider.formatCurrentDate('${Propertytype.effectiveDate}'),
                                                                                              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.grey),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      const SizedBox(height: 10),
                                                                                      Text.rich(
                                                                                        TextSpan(
                                                                                          children: [
                                                                                            TextSpan(
                                                                                              text: 'Expiration Date : ',
                                                                                              style: TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                                                                                            ),
                                                                                            TextSpan(
                                                                                              text: dateProvider.formatCurrentDate('${Propertytype.expirationDate}'),
                                                                                              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.grey),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 10,
                                                                            ),
                                                                            /* Container(
                                                                      width:
                                                                      40,
                                                                      child:
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child: IconButton(
                                                                              icon: FaIcon(
                                                                                FontAwesomeIcons.edit,
                                                                                size: 20,
                                                                                color: blueColor,
                                                                              ),
                                                                              onPressed: () async {
                                                                                // handleEdit(Propertytype);

                                                                                var check = await Navigator.push(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                        builder: (context) => editAdminInsurance(
                                                                                          data: Propertytype,
                                                                                        )));
                                                                                if (check == true) {
                                                                                  setState(() {
                                                                                    futurePropertyTypes = AdminTenantInsuranceRepository().fetchTenantInsurance(widget.tenantId);
                                                                                  });
                                                                                }
                                                                              },
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            child: IconButton(
                                                                              icon: FaIcon(
                                                                                FontAwesomeIcons.trashCan,
                                                                                size: 20,
                                                                                color: blueColor,
                                                                              ),
                                                                              onPressed: () {
                                                                                //handleDelete(Propertytype);
                                                                                _showAlert(context, Propertytype.sId ?? '');
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),*/
                                                                            const SizedBox(
                                                                              height: 10,
                                                                            ),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                                              children: [
                                                                                GestureDetector(
                                                                                  onTap: () async {
                                                                                    // handleEdit(Propertytype);

                                                                                    var check = await Navigator.push(
                                                                                        context,
                                                                                        MaterialPageRoute(
                                                                                            builder: (context) => editAdminInsurance(
                                                                                                  data: AdminTenantInsuranceModel(
                                                                                                    provider: Propertytype.insuranceCompany,
                                                                                                    policyId: Propertytype.policyId,
                                                                                                    effectiveDate: Propertytype.effectiveDate,
                                                                                                    expirationDate: Propertytype.expirationDate,
                                                                                                    liabilityCoverage: Propertytype.liabilityCoverage?.toString(),
                                                                                                    tenantInsuranceId: Propertytype.sId,
                                                                                                    status: Propertytype.active == true ? 'active' : 'expired',
                                                                                                  ),
                                                                                                )));
                                                                                    if (check == true) {
                                                                                      setState(() {
                                                                                        futurePropertyTypes = RentersInsuranceService().fetchPoliciesByTenant(widget.tenantId);
                                                                                      });
                                                                                    }
                                                                                  },
                                                                                  child: Container(
                                                                                    height: 35,
                                                                                    width: 35,
                                                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.green.shade50), // color:Colors.grey[100],
                                                                                    child: const Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      children: [
                                                                                        FaIcon(
                                                                                          FontAwesomeIcons.edit,
                                                                                          size: 15,
                                                                                          color: Colors.green,
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 10,
                                                                                ),
                                                                                GestureDetector(
                                                                                  onTap: () {
                                                                                    _showAlert(context, Propertytype.sId ?? '');
                                                                                  },
                                                                                  child: Container(
                                                                                    height: 35,
                                                                                    width: 35,
                                                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.red.shade50),
                                                                                    child: const Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      children: [
                                                                                        FaIcon(
                                                                                          FontAwesomeIcons.trashCan,
                                                                                          size: 15,
                                                                                          color: Colors.red,
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 5,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 5,
                                                                            ),
                                                                            // Row(
                                                                            //   //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            //   children: [
                                                                            //     // Expanded(
                                                                            //     //   child: GestureDetector(
                                                                            //     //     onTap: () async {
                                                                            //     //       var check = await Navigator.push(
                                                                            //     //           context,
                                                                            //     //           MaterialPageRoute(
                                                                            //     //               builder: (context) => editAdminInsurance(
                                                                            //     //                 data: Propertytype,
                                                                            //     //               )));
                                                                            //     //       if (check == true) {
                                                                            //     //         setState(() {
                                                                            //     //           futurePropertyTypes = AdminTenantInsuranceRepository().fetchTenantInsurance(widget.tenantId);
                                                                            //     //         });
                                                                            //     //       }
                                                                            //     //     },
                                                                            //     //     child: Container(
                                                                            //     //       height: 40,
                                                                            //     //       decoration: BoxDecoration(
                                                                            //     //           color: Colors
                                                                            //     //               .grey[
                                                                            //     //           350]), // color:Colors.grey[100],
                                                                            //     //       child: Row(
                                                                            //     //         mainAxisAlignment:
                                                                            //     //         MainAxisAlignment
                                                                            //     //             .center,
                                                                            //     //         crossAxisAlignment:
                                                                            //     //         CrossAxisAlignment
                                                                            //     //             .center,
                                                                            //     //         children: [
                                                                            //     //           FaIcon(
                                                                            //     //             FontAwesomeIcons
                                                                            //     //                 .edit,
                                                                            //     //             size: 15,
                                                                            //     //             color:
                                                                            //     //             blueColor,
                                                                            //     //           ),
                                                                            //     //           SizedBox(
                                                                            //     //             width: 10,
                                                                            //     //           ),
                                                                            //     //           Text(
                                                                            //     //             "Edit",
                                                                            //     //             style: TextStyle(
                                                                            //     //                 color:
                                                                            //     //                 blueColor,
                                                                            //     //                 fontWeight:
                                                                            //     //                 FontWeight
                                                                            //     //                     .bold),
                                                                            //     //           ),
                                                                            //     //         ],
                                                                            //     //       ),
                                                                            //     //     ),
                                                                            //     //   ),
                                                                            //     // ),
                                                                            //     // SizedBox(
                                                                            //     //   width: 5,
                                                                            //     // ),
                                                                            //
                                                                            //     Expanded(
                                                                            //       child: GestureDetector(
                                                                            //         onTap: () {
                                                                            //           _showAlert(context, Propertytype.tenantInsuranceId!);
                                                                            //         },
                                                                            //         child: Container(
                                                                            //           height: 40,
                                                                            //           decoration: BoxDecoration(color: Colors.grey[350]),
                                                                            //           child: Row(
                                                                            //             mainAxisAlignment: MainAxisAlignment.center,
                                                                            //             crossAxisAlignment: CrossAxisAlignment.center,
                                                                            //             children: [
                                                                            //               FaIcon(
                                                                            //                 FontAwesomeIcons.trashCan,
                                                                            //                 size: 15,
                                                                            //                 color: blueColor,
                                                                            //               ),
                                                                            //               SizedBox(
                                                                            //                 width: 10,
                                                                            //               ),
                                                                            //               Text(
                                                                            //                 "Delete",
                                                                            //                 style: TextStyle(color: blueColor, fontWeight: FontWeight.bold),
                                                                            //               )
                                                                            //             ],
                                                                            //           ),
                                                                            //         ),
                                                                            //       ),
                                                                            //     ),
                                                                            //   ],
                                                                            // ),
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
                                                    ],
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      if (MediaQuery.of(context).size.width >
                                          500)
                                        FutureBuilder<
                                            List<lease_renter_insurance>>(
                                          future: futurePropertyTypes,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        minHeight: 160),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 32),
                                                child: Center(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      SpinKitFadingCircle(
                                                          color: blueColor,
                                                          size: 40.0),
                                                      const SizedBox(
                                                          height: 14),
                                                      Text(
                                                          'Loading Renter\'s Insurance...',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.grey
                                                                  .shade600)),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            } else if (snapshot.hasError) {
                                              return Center(
                                                  child: Text(
                                                      'Error: ${snapshot.error}'));
                                            } else if (!snapshot.hasData ||
                                                snapshot.data!.isEmpty) {
                                              return const Center(
                                                  child: Text(
                                                      'No Data Available'));
                                            } else {
                                              _tableData = snapshot.data!
                                                  .where((p) => p.policyStatus?.toUpperCase() == 'ACTIVE')
                                                  .toList();

                                              totalrecords = _tableData.length;
                                              return SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    20.0,
                                                                vertical: 5),
                                                        child: Column(
                                                          children: [
                                                            SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            20),
                                                                child: Table(
                                                                  defaultColumnWidth:
                                                                      const IntrinsicColumnWidth(),
                                                                  children: [
                                                                    TableRow(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border: Border.all(
                                                                            // color: blueColor
                                                                            ),
                                                                      ),
                                                                      children: [
                                                                        _buildHeader(
                                                                            'Insurance Company',
                                                                            0,
                                                                            (property) =>
                                                                                property.insuranceCompany ??
                                                                                ''),

                                                                        _buildHeader(
                                                                            'Policy Id',
                                                                            2,
                                                                            null),
                                                                        _buildHeader(
                                                                            'Liability Coverage',
                                                                            2,
                                                                            null),
                                                                        _buildHeader(
                                                                            'Status',
                                                                            2,
                                                                            null),
                                                                        _buildHeader(
                                                                            'Effective Date',
                                                                            2,
                                                                            null),
                                                                        _buildHeader(
                                                                            'Expiration Date',
                                                                            3,
                                                                            null),
                                                                        _buildHeader(
                                                                            'Actions',
                                                                            3,
                                                                            null),
                                                                        // _buildHeader('Actions', 4, null),
                                                                      ],
                                                                    ),
                                                                    TableRow(
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        border: Border.symmetric(
                                                                            horizontal:
                                                                                BorderSide.none),
                                                                      ),
                                                                      children: List.generate(
                                                                          7,
                                                                          (index) =>
                                                                              TableCell(child: Container(height: 20))),
                                                                    ),
                                                                    for (var i =
                                                                            0;
                                                                        i < _pagedData.length;
                                                                        i++)
                                                                      TableRow(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border:
                                                                              Border(
                                                                            left:
                                                                                const BorderSide(color: Color.fromRGBO(21, 43, 81, 1)),
                                                                            right:
                                                                                const BorderSide(color: Color.fromRGBO(21, 43, 81, 1)),
                                                                            top:
                                                                                const BorderSide(color: Color.fromRGBO(21, 43, 81, 1)),
                                                                            bottom: i == _pagedData.length - 1
                                                                                ? const BorderSide(color: Color.fromRGBO(21, 43, 81, 1))
                                                                                : BorderSide.none,
                                                                          ),
                                                                        ),
                                                                        children: [
                                                                          _buildDataCell(_pagedData[i].insuranceCompany ??
                                                                              ''),
                                                                          _buildDataCell(
                                                                            _pagedData[i].policyId!,
                                                                          ),
                                                                          _buildDataCell(
                                                                            _pagedData[i].liabilityCoverage.toString()!,
                                                                          ),
                                                                          _buildDataCell(
                                                                            _pagedData[i].active == true
                                                                                ? 'Active'
                                                                                : 'Inactive',
                                                                          ),
                                                                          _buildDataCell(
                                                                            _pagedData[i].effectiveDate!,
                                                                          ),
                                                                          _buildDataCell(
                                                                            _pagedData[i].expirationDate!,
                                                                          ),
                                                                          _buildActionsCell(
                                                                              _pagedData[i]),
                                                                        ],
                                                                      ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 25),
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

                                const SizedBox(height: 10),
                                _buildEmergencyContactSection(),

                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 20),
                                  child: CustomHistoryTable(
                                    key: ValueKey(_historyRefreshKey),
                                    historyType: HistoryType.tenant,
                                    entityId: widget.tenantId,
                                    title: 'History',
                                    blueColor: blueColor,
                                    itemsPerPage: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_tenantSummaryTabIndex == 1) _buildLeaseTabContent(),
                  if (_tenantSummaryTabIndex == 2)
                    Tenant_communication(
                      lease_id: widget.tenantId,
                    ),
                  if (_tenantSummaryTabIndex == 3)
                    FinancialTable(
                      leaseId: widget.tenantId,
                    ),
                  if (_tenantSummaryTabIndex == 4) _buildTenantWorkOrdersTab(),
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

  /// Lease ID for API calls: use first lease's ID when available, else tenant ID as fallback.
  String get _effectiveLeaseId {
    final leaseId = widget.tenants?.leaseData?.isNotEmpty == true
        ? widget.tenants!.leaseData!.first.leaseId
        : null;
    return leaseId ?? widget.tenantId;
  }

  /// True if lease is active (today between start and end). Used for lease tab.
  bool _isLeaseActive(String? startDate, String? endDate) {
    if (startDate == null ||
        endDate == null ||
        startDate.isEmpty ||
        endDate.isEmpty) return false;
    try {
      final start = _parseLeaseDate(startDate);
      final end = _parseLeaseDate(endDate);
      final now = DateTime.now();
      return !now.isBefore(start) && !now.isAfter(end);
    } catch (_) {
      return false;
    }
  }

  DateTime _parseLeaseDate(String dateStr) {
    final formats = ['yyyy-MM-dd', 'dd-MM-yyyy', 'MM/dd/yyyy', 'M/d/yyyy'];
    for (final f in formats) {
      try {
        return DateFormat(f).parse(dateStr);
      } catch (_) {}
    }
    return DateTime.tryParse(dateStr) ?? DateTime.now();
  }

  List<TenantLeaseData>? get _leaseListForSummary {
    final td = _tenantDetails?.leaseData;
    if (td != null && td.isNotEmpty) return td;
    final wt = widget.tenants?.leaseData;
    if (wt != null && wt.isNotEmpty) return wt;
    return null;
  }

  /// First *active* lease's ID for lease summary. Null if no lease data or no active lease.
  String? get _firstActiveLeaseId {
    final list = _leaseListForSummary;
    if (list == null || list.isEmpty) return null;
    for (final lease in list) {
      if (_isLeaseActive(lease.startDate, lease.endDate) &&
          (lease.leaseId ?? '').isNotEmpty) {
        return lease.leaseId;
      }
    }
    return null;
  }

  String? get _leaseIdForAddCard {
    final active = _firstActiveLeaseId;
    if (active != null && active.isNotEmpty) return active;
    final list = _leaseListForSummary;
    if (list == null || list.isEmpty) return null;
    final id = list.first.leaseId;
    if (id == null || id.isEmpty) return null;
    return id;
  }

  Future<void> _onPaymentAllowAchChanged(bool value) async {
    final t = _tenantDetails ?? widget.tenants;
    if (t == null) return;
    final card = t.allowCard != false;
    final prevAch = t.allowAch;
    setState(() {
      if (_tenantDetails != null) _tenantDetails!.allowAch = value;
      if (widget.tenants != null) widget.tenants!.allowAch = value;
    });
    try {
      await repo.editTenantFromModel(
        _tenantDetails ?? widget.tenants!,
        allowAch: value,
        allowCard: card,
      );
      if (mounted) setState(() => _historyRefreshKey++);
    } catch (_) {
      if (mounted) {
        setState(() {
          if (_tenantDetails != null) _tenantDetails!.allowAch = prevAch;
          if (widget.tenants != null) widget.tenants!.allowAch = prevAch;
        });
      }
    }
  }

  Future<void> _onPaymentAllowCardChanged(bool value) async {
    final t = _tenantDetails ?? widget.tenants;
    if (t == null) return;
    final ach = t.allowAch != false;
    final prevCard = t.allowCard;
    setState(() {
      if (_tenantDetails != null) _tenantDetails!.allowCard = value;
      if (widget.tenants != null) widget.tenants!.allowCard = value;
    });
    try {
      await repo.editTenantFromModel(
        _tenantDetails ?? widget.tenants!,
        allowAch: ach,
        allowCard: value,
      );
      if (mounted) setState(() => _historyRefreshKey++);
    } catch (_) {
      if (mounted) {
        setState(() {
          if (_tenantDetails != null) _tenantDetails!.allowCard = prevCard;
          if (widget.tenants != null) widget.tenants!.allowCard = prevCard;
        });
      }
    }
  }

  void _openManagePaymentMethods() {
    final leaseId = _leaseIdForAddCard;
    if (leaseId == null || leaseId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No lease found to manage cards.')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCard(
          leaseId: leaseId,
          initialTenantId: widget.tenantId,
          useStaffIdHeader: false,
        ),
      ),
    );
  }

  List<MergedEmergencyContact> get _combinedEmergencyContacts =>
      getCombinedEmergencyContacts(_tenantDetails ?? widget.tenants);

  /// Rental id for work-order API (`rental_id` query), from lease data.
  String? get _tenantRentalId {
    final list = _leaseListForSummary;
    if (list == null || list.isEmpty) return null;
    final activeLeaseId = _firstActiveLeaseId;
    if (activeLeaseId != null) {
      for (final l in list) {
        if (l.leaseId == activeLeaseId) {
          final id = l.rentalId?.toString().trim();
          if (id != null && id.isNotEmpty) return id;
        }
      }
    }
    for (final l in list) {
      final id = l.rentalId?.toString().trim();
      if (id != null && id.isNotEmpty) return id;
    }
    return null;
  }

  Widget _buildTenantWorkOrdersTab() {
    final rid = _tenantRentalId;
    if (rid == null || rid.isEmpty) {
      return SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.45,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No Data Available',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ),
        ),
      );
    }
    final tabHeight =
        (MediaQuery.sizeOf(context).height - 220).clamp(320.0, 1200.0);
    return SizedBox(
      height: tabHeight,
      child: Workorder_table(
        embeddedMode: true,
        rentalIdFilter: rid,
        showAddButton: false,
      ),
    );
  }

  Widget _buildEmergencyContactSection() {
    final list = _combinedEmergencyContacts;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  "Emergency Contact (${list.length})",
                  style: TextStyle(
                    color: blueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
              Material(
                color: blueColor,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => _showEmergencyContactDialog(context, null),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Icon(Icons.add, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDBE0E5)),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width * .02),
                  Expanded(
                    flex: 2,
                    child: Text("     Contact Name",
                        style: TextStyle(
                            color: blueColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * .04),
                  Expanded(
                    flex: 2,
                    child: Text("Emergency Email",
                        style: TextStyle(
                            color: blueColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ),
                  // Expanded(
                  //   child: Text("Email",
                  //       style: TextStyle(
                  //           color: blueColor,
                  //           fontSize: 13,
                  //           fontWeight: FontWeight.bold)),
                  // ),
                  // Expanded(
                  //   child: Text("Phone",
                  //       style: TextStyle(
                  //           color: blueColor,
                  //           fontSize: 13,
                  //           fontWeight: FontWeight.bold)),
                  // ),

                  const SizedBox(width: 25),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                  child: Text('No Data Available',
                      style: TextStyle(color: Colors.grey.shade600))),
            )
          else
            ...list.asMap().entries.map(
                (entry) => _buildEmergencyContactRow(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactRow(int index, MergedEmergencyContact c) {
    final isExpanded = expandedEmergencyIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: index % 2 != 0 ? const Color(0xFFF4F8FF) : Colors.white,
        border: Border.all(color: const Color(0xFFDBE0E5)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      if (expandedEmergencyIndex == index) {
                        expandedEmergencyIndex = null;
                      } else {
                        expandedEmergencyIndex = index;
                      }
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 5),
                    padding: !isExpanded
                        ? const EdgeInsets.only(bottom: 10)
                        : const EdgeInsets.only(top: 10),
                    child: FaIcon(
                      isExpanded
                          ? FontAwesomeIcons.sortUp
                          : FontAwesomeIcons.sortDown,
                      size: 20,
                      color: blueColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (expandedEmergencyIndex == index) {
                          expandedEmergencyIndex = null;
                        } else {
                          expandedEmergencyIndex = index;
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        c.name.isEmpty ? '—' : c.name,
                        style: TextStyle(
                            color: blueColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * .01),
                Expanded(
                  flex: 2,
                  child: Text(
                    c.email.isEmpty ? '—' : c.email,
                    style: TextStyle(
                        color: blueColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
                const SizedBox(width: 25),
              ],
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * .02),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Relation : ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: blueColor,
                                  fontSize: 13), // Bold and black
                            ),
                            TextSpan(
                              text: '${c.relation.isEmpty ? '—' : c.relation}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey,
                                  fontSize: 13), // Light and grey
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * .02),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Phone : ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: blueColor,
                                  fontSize: 13), // Bold and black
                            ),
                            TextSpan(
                              text:
                                  '${c.phoneNumber.isEmpty ? '—' : formatPhoneNumber(c.phoneNumber)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey,
                                  fontSize: 13), // Light and grey
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => _showEmergencyContactDialog(context, c),
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors
                                  .green.shade50), // color:Colors.grey[100],
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.edit,
                                size: 15,
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () => _confirmDeleteEmergencyContact(c),
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.red.shade50),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.trashCan,
                                size: 15,
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTenantInfoSection() {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    final phone = formatPhoneNumber(widget.tenants?.tenantPhoneNumber ?? '');
    final email = (widget.tenants?.tenantEmail ?? '').isEmpty
        ? '—'
        : (widget.tenants?.tenantEmail ?? '');
    final birthDate = (widget.tenants?.tenantBirthDate ?? '').isEmpty
        ? 'N/A'
        : dateProvider.formatCurrentDate(widget.tenants?.tenantBirthDate ?? '');
    final notes = (widget.tenants?.comments ?? '').isEmpty
        ? 'N/A'
        : (widget.tenants?.comments ?? '');
    final isExpanded = expandedTenantInfo;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const SizedBox(width: 2),
            Expanded(
                child: Text("Tenant Information",
                    style: TextStyle(
                        color: blueColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 17)))
          ]),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
                color: const Color(0xFFF4F8FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFDBE0E5))),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Row(
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width * .02),
                  Expanded(
                      flex: 2,
                      child: Text("      Phone",
                          style: TextStyle(
                              color: blueColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold))),
                  SizedBox(width: MediaQuery.of(context).size.width * .07),
                  Expanded(
                      flex: 2,
                      child: Text("Email",
                          style: TextStyle(
                              color: blueColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold))),
                  const SizedBox(width: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFDBE0E5)),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    children: [
                      InkWell(
                        onTap: () => setState(
                            () => expandedTenantInfo = !expandedTenantInfo),
                        child: Container(
                          margin: const EdgeInsets.only(left: 5),
                          padding: !isExpanded
                              ? const EdgeInsets.only(bottom: 10)
                              : const EdgeInsets.only(top: 10),
                          child: FaIcon(
                              isExpanded
                                  ? FontAwesomeIcons.sortUp
                                  : FontAwesomeIcons.sortDown,
                              size: 20,
                              color: blueColor),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: InkWell(
                            onTap: () => setState(
                                () => expandedTenantInfo = !expandedTenantInfo),
                            child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(phone.isEmpty ? '—' : phone,
                                    style: TextStyle(
                                        color: blueColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)))),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * .02),
                      Expanded(
                          flex: 2,
                          child: Text(email,
                              style: TextStyle(
                                  color: blueColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12))),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
                if (isExpanded)
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          SizedBox(
                              width: MediaQuery.of(context).size.width * .02),
                          Text.rich(TextSpan(children: [
                            TextSpan(
                                text: 'Birth Date : ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: blueColor,
                                    fontSize: 13)),
                            TextSpan(
                                text: birthDate,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey,
                                    fontSize: 13))
                          ]))
                        ]),
                        const SizedBox(height: 10),
                        Row(children: [
                          SizedBox(
                              width: MediaQuery.of(context).size.width * .02),
                          Text.rich(TextSpan(children: [
                            TextSpan(
                                text: 'Notes : ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: blueColor,
                                    fontSize: 13)),
                            TextSpan(
                                text: notes,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey,
                                    fontSize: 13))
                          ]))
                        ]),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteEmergencyContact(MergedEmergencyContact c) {
    if (c.contactId == 'primary') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text("Primary emergency contact cannot be deleted from here.")));
      return;
    }
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Delete emergency contact?",
      desc: "This contact will be removed from the list.",
      style: const AlertStyle(backgroundColor: Colors.white),
      buttons: [
        DialogButton(
          child: Text("Cancel",
              style: TextStyle(
                  color: blueColor, fontSize: 18, fontWeight: FontWeight.bold)),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
          radius: BorderRadius.circular(8),
          border: Border.all(color: blueColor, width: 1.5),
        ),
        DialogButton(
          child: const Text("Delete",
              style: TextStyle(color: Colors.white, fontSize: 18)),
          onPressed: () async {
            Navigator.pop(context);
            try {
              await _tenantService.deleteEmergencyContact(
                  widget.tenantId, c.contactId);
              await _refreshTenantDetails();
              if (mounted) setState(() {});
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
          color: Colors.red,
        ),
      ],
    ).show();
  }

  void _showEmergencyContactDialog(
      BuildContext context, MergedEmergencyContact? editContact) {
    final isEdit = editContact != null;
    final initialName = editContact?.name.trim() ?? '';
    final initialRelation = editContact?.relation.trim() ?? '';
    final initialEmail = editContact?.email.trim() ?? '';
    final initialPhoneDigits =
        editContact?.phoneNumber.replaceAll(RegExp(r'\D'), '') ?? '';
    final nameController = TextEditingController(text: editContact?.name ?? '');
    final relationController =
        TextEditingController(text: editContact?.relation ?? '');
    final emailController =
        TextEditingController(text: editContact?.email ?? '');
    final phoneController = TextEditingController(
        text: isEdit ? formatPhoneNumberedit(editContact.phoneNumber) : '');
    final formKey = GlobalKey<FormState>();

    String? validateName(String? value) {
      if (value == null || value.toString().trim().isEmpty) {
        return "This field is required";
      }
      return null;
    }

    String? validateRelation(String? value) {
      if (value == null || value.toString().trim().isEmpty) {
        return "This field is required";
      }
      return null;
    }

    String? validateEmail(String? value) {
      if (value == null || value.toString().trim().isEmpty) {
        return "This field is required";
      }
      if (!EmailValidator.validate(value.trim())) {
        return "Enter a valid email";
      }
      return null;
    }

    String? validatePhone(String? value) {
      if (value == null || value.toString().trim().isEmpty) {
        return "This field is required";
      }
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.length != 10) return "Enter a valid 10-digit phone number";
      return null;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isEdit ? "Edit Emergency Contact" : "Add Emergency Contact",
          style: TextStyle(
              color: blueColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Contact Name",
                    style: TextStyle(
                        color: Color(0xFF8A95A8),
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: "Enter contact name",
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: validateName,
                ),
                const SizedBox(height: 16),
                const Text("Relationship to Tenant",
                    style: TextStyle(
                        color: Color(0xFF8A95A8),
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: relationController,
                  decoration: const InputDecoration(
                    hintText: "Enter relationship to tenant",
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  validator: validateRelation,
                ),
                const SizedBox(height: 16),
                const Text("Email",
                    style: TextStyle(
                        color: Color(0xFF8A95A8),
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: "Enter email",
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  validator: validateEmail,
                ),
                const SizedBox(height: 16),
                const Text("Phone Number",
                    style: TextStyle(
                        color: Color(0xFF8A95A8),
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [PhoneNumberFormatter()],
                  decoration: const InputDecoration(
                    hintText: "(xxx) xxx-xxxx",
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  validator: validatePhone,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("CANCEL",
                style:
                    TextStyle(color: blueColor, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: blueColor),
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) {
                if (!isEdit && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("All fields are required")),
                  );
                }
                return;
              }
              final name = nameController.text.trim();
              final relation = relationController.text.trim();
              final email = emailController.text.trim();
              final phoneDigits =
                  phoneController.text.replaceAll(RegExp(r'\D'), '');
              final phone = formatPhoneNumberedit(phoneDigits);
              if (isEdit) {
                if (name == initialName &&
                    relation == initialRelation &&
                    email == initialEmail &&
                    phoneDigits == initialPhoneDigits) {
                  Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No changes made")),
                    );
                  }
                  return;
                }
              }
              Navigator.pop(ctx);
              try {
                if (!isEdit) {
                  await _tenantService.addEmergencyContact(widget.tenantId,
                      name: name,
                      relation: relation,
                      email: email,
                      phoneNumber: phone);
                } else if (editContact.contactId == 'primary') {
                  await _tenantService.updateEmergencyContactPrimary(
                      widget.tenantId,
                      name: name,
                      relation: relation,
                      email: email,
                      phoneNumber: phone);
                } else {
                  await _tenantService.updateEmergencyContact(
                      widget.tenantId, editContact.contactId,
                      name: name,
                      relation: relation,
                      email: email,
                      phoneNumber: phone);
                }
                await _refreshTenantDetails();
                if (mounted) setState(() {});
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text("SAVE"),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaseTabContent() {
    final list = widget.tenants?.leaseData;
    if (list == null || list.isEmpty) {
      return SizedBox(
        height: MediaQuery.sizeOf(context).height - 300,
        child: const Center(
          child: Text(
            'No lease data available for this tenant.',
            style: TextStyle(fontSize: 13),
          ),
        ),
      );
    }
    final activeLeaseId = _firstActiveLeaseId;
    if (activeLeaseId == null || activeLeaseId.isEmpty) {
      return SizedBox(
        height: MediaQuery.sizeOf(context).height - 300,
        child: const Center(
          child: Text(
            'No active lease. All leases are expired or not yet started.',
            style: TextStyle(fontSize: 13),
          ),
        ),
      );
    }
    final activeLease = list.firstWhere((l) => l.leaseId == activeLeaseId);
    return SizedBox(
      height: MediaQuery.sizeOf(context).height - 300,
      child: SummeryPageLease(
        leaseId: activeLeaseId,
        enddate: activeLease.endDate,
        isredirectpayment: false,
        embeddedInTenantSummary: true,
      ),
    );
  }
}

class TenantSummaryTablet extends StatefulWidget {
  Tenant? tenants;
  String tenantId;
  TenantSummaryTablet({super.key, required this.tenantId, this.tenants});
  @override
  State<TenantSummaryTablet> createState() => _TenantSummaryTabletState();
}

class _TenantSummaryTabletState extends State<TenantSummaryTablet> {
  Future<List<TenantLeaseData>> fetchLeaseData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    String url = '$Api_url/api/tenant/tenant_details/${widget.tenantId}';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final tenantResponse = TenantResponse.fromJson(jsonResponse);

      // Collect all lease data from all tenant data
      List<TenantLeaseData> allLeaseData = [];
      if (tenantResponse.data != null) {
        for (var tenant in tenantResponse.data!) {
          if (tenant.leaseData != null) {
            allLeaseData.addAll(tenant.leaseData!);
            print(allLeaseData);
          }
        }
      }

      // Filter out entries with invalid dates
      List<TenantLeaseData> validLeaseData = allLeaseData.where((lease) {
        // Check if both startDate and endDate can be parsed
        DateTime? start = parseDateRobust(lease.startDate);
        DateTime? end = parseDateRobust(lease.endDate);
        return start != null && end != null;
      }).toList();

      return validLeaseData;
    } else {
      throw Exception('Failed to load lease data');
    }
  }

  final TenantsRepository repo = TenantsRepository();

  int totalrecords = 0;
  late Future<List<lease_renter_insurance>> futurePropertyTypes;
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

  void sortData(List<lease_renter_insurance> data) {
    /*  if (sorting1) {
      data.sort((a, b) => ascending1
          ? a.propertyType!.compareTo(b.propertyType!)
          : b.propertyType!.compareTo(a.propertyType!));
    } else if (sorting2) {
      data.sort((a, b) => ascending2
          ? a.propertysubType!.compareTo(b.propertysubType!)
          : b.propertysubType!.compareTo(a.propertysubType!));
    } else if (sorting3) {
      data.sort((a, b) => ascending3
          ? a.createdAt!.compareTo(b.createdAt!)
          : b.createdAt!.compareTo(a.createdAt!));
    }*/
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
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
                        ? const Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Text(
                              "Insurance \nCompany ",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : const Text("     Insurance Company",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                            textAlign: TextAlign.center),
                    // Text("Property", style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 3),
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
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Text("Policy Id",
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                    ),
                    SizedBox(width: 5),
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
                child: const Row(
                  children: [
                    Text(
                      "Expiration\nDate",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(width: 5),
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
  late Future<List<Tenant>> _futureTenantSummary;

  @override
  void initState() {
    super.initState();
    _futureTenantSummary =
        repo.fetchTenantsummery(widget.tenantId) ?? Future.value([]);
    futurePropertyTypes =
        RentersInsuranceService().fetchPoliciesByTenant(widget.tenantId);
  }

  void _refreshTabletTenantSummary() {
    setState(() {
      _futureTenantSummary =
          repo.fetchTenantsummery(widget.tenantId) ?? Future.value([]);
    });
  }

  bool _tabletLeaseCoversNow(String? startDate, String? endDate) {
    final start = parseDateRobust(startDate);
    final end = parseDateRobust(endDate);
    if (start == null || end == null) return false;
    final now = DateTime.now();
    return !now.isBefore(start) && !now.isAfter(end);
  }

  String? _tabletLeaseIdForAddCard(Tenant tenant) {
    final list = tenant.leaseData;
    if (list == null || list.isEmpty) return null;
    for (final l in list) {
      final id = l.leaseId;
      if (id != null &&
          id.isNotEmpty &&
          _tabletLeaseCoversNow(l.startDate, l.endDate)) {
        return id;
      }
    }
    final firstId = list.first.leaseId;
    if (firstId != null && firstId.isNotEmpty) return firstId;
    return null;
  }

  Future<void> _tabletOnPaymentAch(Tenant t, bool value) async {
    final prev = t.allowAch;
    final card = t.allowCard != false;
    setState(() => t.allowAch = value);
    try {
      await repo.editTenantFromModel(t, allowAch: value, allowCard: card);
    } catch (_) {
      if (mounted) setState(() => t.allowAch = prev);
    }
  }

  Future<void> _tabletOnPaymentCard(Tenant t, bool value) async {
    final prev = t.allowCard;
    final ach = t.allowAch != false;
    setState(() => t.allowCard = value);
    try {
      await repo.editTenantFromModel(t, allowAch: ach, allowCard: value);
    } catch (_) {
      if (mounted) setState(() => t.allowCard = prev);
    }
  }

  void _tabletOpenAddCard(Tenant tenant) {
    final leaseId = _tabletLeaseIdForAddCard(tenant);
    if (leaseId == null || leaseId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No lease found to manage cards.')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCard(
          leaseId: leaseId,
          initialTenantId: widget.tenantId,
          useStaffIdHeader: false,
        ),
      ),
    );
  }

  TableCell _tableCellLabel(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(text,
            style: const TextStyle(
                color: Color(0xFF8A95A8),
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ),
    );
  }

  TableCell _tableCellValue(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(text,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: blueColor)),
      ),
    );
  }

  void _confirmTabletDeleteEmergency(MergedEmergencyContact c) {
    if (c.contactId == 'primary') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text("Primary emergency contact cannot be deleted from here.")));
      return;
    }
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Delete emergency contact?",
      desc: "This contact will be removed from the list.",
      style: const AlertStyle(backgroundColor: Colors.white),
      buttons: [
        DialogButton(
          child: Text("Cancel",
              style: TextStyle(
                  color: blueColor, fontSize: 18, fontWeight: FontWeight.bold)),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
          radius: BorderRadius.circular(8),
          border: Border.all(color: blueColor, width: 1.5),
        ),
        DialogButton(
          child: const Text("Delete",
              style: TextStyle(color: Colors.white, fontSize: 18)),
          onPressed: () async {
            Navigator.pop(context);
            try {
              await repo.deleteEmergencyContact(widget.tenantId, c.contactId);
              _refreshTabletTenantSummary();
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
          color: Colors.red,
        ),
      ],
    ).show();
  }

  void _showTabletEmergencyDialog(
      BuildContext context, MergedEmergencyContact? editContact) {
    final isEdit = editContact != null;
    final initialName = editContact?.name.trim() ?? '';
    final initialRelation = editContact?.relation.trim() ?? '';
    final initialEmail = editContact?.email.trim() ?? '';
    final initialPhoneDigits =
        editContact?.phoneNumber.replaceAll(RegExp(r'\D'), '') ?? '';
    final nameController = TextEditingController(text: editContact?.name ?? '');
    final relationController =
        TextEditingController(text: editContact?.relation ?? '');
    final emailController =
        TextEditingController(text: editContact?.email ?? '');
    final phoneController = TextEditingController(
        text: isEdit ? formatPhoneNumberedit(editContact.phoneNumber) : '');
    final formKey = GlobalKey<FormState>();

    String? validateName(String? value) {
      if (value == null || value.toString().trim().isEmpty) {
        return "This field is required";
      }
      return null;
    }

    String? validateRelation(String? value) {
      if (value == null || value.toString().trim().isEmpty) {
        return "This field is required";
      }
      return null;
    }

    String? validateEmail(String? value) {
      if (value == null || value.toString().trim().isEmpty) {
        return "This field is required";
      }
      if (!EmailValidator.validate(value.trim())) return "Enter a valid email";
      return null;
    }

    String? validatePhone(String? value) {
      if (value == null || value.toString().trim().isEmpty) {
        return "This field is required";
      }
      if (value.replaceAll(RegExp(r'\D'), '').length != 10) {
        return "Enter a valid 10-digit phone number";
      }
      return null;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title:
            Text(isEdit ? "Edit Emergency Contact" : "Add Emergency Contact"),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Contact Name",
                    style: TextStyle(
                        color: Color(0xFF8A95A8),
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: "Enter contact name",
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: validateName,
                ),
                const SizedBox(height: 16),
                const Text("Relationship to Tenant",
                    style: TextStyle(
                        color: Color(0xFF8A95A8),
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: relationController,
                  decoration: const InputDecoration(
                    hintText: "Enter relationship to tenant",
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  validator: validateRelation,
                ),
                const SizedBox(height: 16),
                const Text("Email",
                    style: TextStyle(
                        color: Color(0xFF8A95A8),
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                  decoration: const InputDecoration(
                    hintText: "Enter email",
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Phone Number",
                    style: TextStyle(
                        color: Color(0xFF8A95A8),
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [PhoneNumberFormatter()],
                  validator: validatePhone,
                  decoration: const InputDecoration(
                    hintText: "(xxx) xxx-xxxx",
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("CANCEL",
                style:
                    TextStyle(color: blueColor, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: blueColor),
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) {
                if (!isEdit && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("All fields are required")),
                  );
                }
                return;
              }
              final name = nameController.text.trim();
              final relation = relationController.text.trim();
              final email = emailController.text.trim();
              final phoneDigits =
                  phoneController.text.replaceAll(RegExp(r'\D'), '');
              final phone = formatPhoneNumberedit(phoneDigits);
              if (isEdit) {
                if (name == initialName &&
                    relation == initialRelation &&
                    email == initialEmail &&
                    phoneDigits == initialPhoneDigits) {
                  Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No changes made")),
                    );
                  }
                  return;
                }
              }
              Navigator.pop(ctx);
              try {
                if (!isEdit) {
                  await repo.addEmergencyContact(widget.tenantId,
                      name: name,
                      relation: relation,
                      email: email,
                      phoneNumber: phone);
                } else if (editContact.contactId == 'primary') {
                  await repo.updateEmergencyContactPrimary(widget.tenantId,
                      name: name,
                      relation: relation,
                      email: email,
                      phoneNumber: phone);
                } else {
                  await repo.updateEmergencyContact(
                      widget.tenantId, editContact.contactId,
                      name: name,
                      relation: relation,
                      email: email,
                      phoneNumber: phone);
                }
                _refreshTabletTenantSummary();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text("SAVE"),
          ),
        ],
      ),
    );
  }

  void handleEdit(lease_renter_insurance property) async {}

  void _showAlert(BuildContext context, String id) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this Insurance!",
      style: const AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
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
        DialogButton(
          child: const Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            await RentersInsuranceService()
                .deleteInsurance(renters_insurance_id: id);
            setState(() {
              futurePropertyTypes = RentersInsuranceService()
                  .fetchPoliciesByTenant(widget.tenantId);
            });
            Navigator.pop(context);
          },
          color: Colors.red,
        )
      ],
    ).show();
  }

  List<lease_renter_insurance> _tableData = [];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<lease_renter_insurance> get _pagedData {
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

  void _sort<T>(Comparable<T> Function(lease_renter_insurance d) getField,
      int columnIndex, bool ascending) {
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

  void handleDelete(lease_renter_insurance property) {}

  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(lease_renter_insurance d)? getField) {
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
                  style: TextStyle(
                      color: blueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
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
      child: Container(
        height: 60,
        padding: const EdgeInsets.only(top: 20.0, left: 16),
        child: Text(text,
            style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF8A95A8),
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildActionsCell(lease_renter_insurance data) {
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

  final TenantsRepository _tenantService = TenantsRepository();

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      // appBar: widget302.,
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Tenants",
        dropdown: true,
      ),
      body: Center(
        child: FutureBuilder<List<Tenant>>(
          future: _futureTenantSummary,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SpinKitFadingCircle(
                  color: Colors.black,
                  size: 40.0,
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              List<Tenant> tenantsummery = snapshot.data ?? [];
              print("tenant${tenantsummery}");
              print("Leangth of the tenant${snapshot.data!.length}");
              //   Provider.of<Tenants_counts>(context).setOwnerDetails(tenants.length);
              return ListView(
                scrollDirection: Axis.vertical,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 30,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${tenantsummery.first.tenantFirstName}',
                            style: TextStyle(
                                fontSize: 18,
                                color: blueColor,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          const Text(
                            'Tenant',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8A95A8)),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.065),
                          GestureDetector(
                            onTap: () async {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => Edit_rentalowners(
                              //             rentalOwner:
                              //                 rentalownersummery.first)));
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: Container(
                                height: 42,
                                width: MediaQuery.of(context).size.width * .15,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: blueColor,
                                  boxShadow: [
                                    const BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 1.0), //(x,y)
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    "Edit",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () async {
                              Navigator.pop(context);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: Container(
                                height: 42,
                                width: MediaQuery.of(context).size.width * .15,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: blueColor,
                                  boxShadow: [
                                    const BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 1.0), //(x,y)
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    "Back",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Container(
                        height: 50.0,
                        padding: const EdgeInsets.only(top: 8, left: 10),
                        width: MediaQuery.of(context).size.width * .91,
                        margin: const EdgeInsets.only(bottom: 6.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: blueColor,
                          boxShadow: [
                            const BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: const Text(
                          "Summary",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 25, right: 25),
                        child: Material(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: screenWidth * 0.45,
                            height: 280,
                            // width: 350,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: blueColor),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 25, top: 20, bottom: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        "Contact Information",
                                        style: TextStyle(
                                            color: blueColor,
                                            fontWeight: FontWeight.bold,
                                            // fontSize: 18
                                            fontSize: 21),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Divider(
                                    color: blueColor,
                                  ),
                                  //phonenumber
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Table(
                                    children: [
                                      TableRow(children: [
                                        const TableCell(
                                            child: Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text(
                                            'Name',
                                            style: TextStyle(
                                                color: Color(0xFF8A95A8),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                        )),
                                        TableCell(
                                            child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12),
                                          child: Text(
                                            '${(tenantsummery.first.tenantFirstName ?? '').isEmpty ? 'N/A' : tenantsummery.first.tenantFirstName}',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: blueColor),
                                          ),
                                        )),
                                      ]),
                                      TableRow(children: [
                                        const TableCell(
                                            child: Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text(
                                            'Phone Number',
                                            style: TextStyle(
                                                color: Color(0xFF8A95A8),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                        )),
                                        TableCell(
                                            child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12),
                                          child: Text(
                                            formatPhoneNumber(
                                                '${tenantsummery.first.tenantPhoneNumber}'),
                                            // '${(tenantsummery.first.tenantPhoneNumber ?? '').isEmpty ? 'N/A' : tenantsummery.first.tenantPhoneNumber}',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: blueColor),
                                          ),
                                        )),
                                      ]),
                                      TableRow(children: [
                                        const TableCell(
                                            child: Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text(
                                            'Email',
                                            style: TextStyle(
                                                color: Color(0xFF8A95A8),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                        )),
                                        TableCell(
                                            child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12),
                                          child: Text(
                                            '${(tenantsummery.first.tenantEmail ?? '').isEmpty ? 'N/A' : tenantsummery.first.tenantEmail}',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: blueColor),
                                          ),
                                        )),
                                      ]),
                                    ],
                                  ),
                                  //primary email
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      //Personal information
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 25),
                          child: Material(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: screenWidth * 0.45,
                              //  height: 0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: blueColor),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 25, right: 25, top: 20, bottom: 30),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        Text(
                                          "Personal Information",
                                          style: TextStyle(
                                              color: blueColor,
                                              fontWeight: FontWeight.bold,
                                              // fontSize: 18
                                              fontSize: 21),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Divider(
                                      color: blueColor,
                                    ),
                                    //first name
                                    Table(
                                      children: [
                                        TableRow(children: [
                                          const TableCell(
                                              child: Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: Text(
                                              'Birth Date',
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          )),
                                          TableCell(
                                              child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: Text(
                                              dateProvider
                                                      .formatCurrentDate(
                                                          '${tenantsummery.first.tenantBirthDate}')
                                                      .isEmpty
                                                  ? 'N/A'
                                                  : dateProvider.formatCurrentDate(
                                                      '${tenantsummery.first.tenantBirthDate}'),
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: blueColor),
                                            ),
                                          )),
                                        ]),
                                        TableRow(children: [
                                          const TableCell(
                                              child: Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: Text(
                                              'TaxPayer Id',
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          )),
                                          TableCell(
                                              child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: Text(
                                              '${(tenantsummery.first.taxPayerId ?? '').isEmpty ? 'N/A' : tenantsummery.first.taxPayerId}',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: blueColor),
                                            ),
                                          )),
                                        ]),
                                        TableRow(children: [
                                          const TableCell(
                                              child: Padding(
                                            padding: EdgeInsets.all(12.0),
                                            child: Text(
                                              'Comments',
                                              style: TextStyle(
                                                  color: Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          )),
                                          TableCell(
                                              child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: Text(
                                              '${(tenantsummery.first.comments ?? '').isEmpty ? 'N/A' : tenantsummery.first.comments}',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: blueColor),
                                            ),
                                          )),
                                        ]),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Material(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: blueColor),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 25, right: 25, top: 20, bottom: 30),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Emergency Contact (${getCombinedEmergencyContacts(tenantsummery.first).length})",
                                    style: TextStyle(
                                        color: blueColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 21),
                                  ),
                                  Material(
                                    color: blueColor,
                                    borderRadius: BorderRadius.circular(8),
                                    child: InkWell(
                                      onTap: () => _showTabletEmergencyDialog(
                                          context, null),
                                      borderRadius: BorderRadius.circular(8),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        child: Icon(Icons.add,
                                            color: Colors.white, size: 22),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Divider(color: blueColor),
                              const SizedBox(height: 10),
                              Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(2),
                                  1: FlexColumnWidth(1),
                                  2: FlexColumnWidth(2),
                                  3: FlexColumnWidth(1),
                                  4: FlexColumnWidth(0.5),
                                },
                                children: [
                                  TableRow(
                                      decoration: BoxDecoration(
                                          color: blueColor.withOpacity(0.1)),
                                      children: [
                                        _tableCellLabel("Contact Name"),
                                        _tableCellLabel(
                                            "Relation With Tenants"),
                                        _tableCellLabel("Emergency Email"),
                                        _tableCellLabel("Emergency Phone"),
                                        _tableCellLabel("Action"),
                                      ]),
                                  ...getCombinedEmergencyContacts(
                                          tenantsummery.first)
                                      .map((c) => TableRow(
                                            children: [
                                              _tableCellValue(c.name.isEmpty
                                                  ? '—'
                                                  : c.name),
                                              _tableCellValue(c.relation.isEmpty
                                                  ? '—'
                                                  : c.relation),
                                              _tableCellValue(c.email.isEmpty
                                                  ? '—'
                                                  : c.email),
                                              _tableCellValue(
                                                  c.phoneNumber.isEmpty
                                                      ? '—'
                                                      : formatPhoneNumber(
                                                          c.phoneNumber)),
                                              TableCell(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      InkWell(
                                                        onTap: () =>
                                                            _showTabletEmergencyDialog(
                                                                context, c),
                                                        child: const FaIcon(
                                                            FontAwesomeIcons
                                                                .pen,
                                                            size: 18,
                                                            color:
                                                                Colors.green),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      InkWell(
                                                        onTap: () =>
                                                            _confirmTabletDeleteEmergency(
                                                                c),
                                                        child: const FaIcon(
                                                            FontAwesomeIcons
                                                                .trashCan,
                                                            size: 18,
                                                            color: Colors.red),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: blueColor),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.only(right: 10, bottom: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //add propertytype
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, top: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Renters Insurance Policy',
                                      style: TextStyle(
                                          color: blueColor,
                                          fontSize: 21,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            final result = await Navigator.of(
                                                    context)
                                                .push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        AdminAddTenantInsurance(
                                                          tenantid:
                                                              widget.tenantId,
                                                        )));
                                            if (result == true) {
                                              setState(() {
                                                futurePropertyTypes =
                                                    RentersInsuranceService()
                                                        .fetchPoliciesByTenant(
                                                            widget.tenantId);
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: blueColor,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: const Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Add Policy",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (MediaQuery.of(context).size.width <
                                            500)
                                          const SizedBox(width: 6),
                                        if (MediaQuery.of(context).size.width >
                                            500)
                                          const SizedBox(width: 16),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              // const SizedBox(height: 10),
                              const SizedBox(height: 10),
                              if (MediaQuery.of(context).size.width > 500)
                                FutureBuilder<List<lease_renter_insurance>>(
                                  future: futurePropertyTypes,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Container(
                                        constraints: const BoxConstraints(
                                            minHeight: 160),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 32),
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SpinKitFadingCircle(
                                                  color: blueColor, size: 40.0),
                                              const SizedBox(height: 14),
                                              Text(
                                                  'Loading Renter\'s Insurance...',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors
                                                          .grey.shade600)),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text('Error: ${snapshot.error}'));
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return const Center(
                                          child: Text('No Data Available'));
                                    } else {
                                      _tableData = snapshot.data!;

                                      totalrecords = _tableData.length;
                                      return SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Container(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 0.0,
                                                        vertical: 5),
                                                child: Column(
                                                  children: [
                                                    SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 20),
                                                        child: Table(
                                                          defaultColumnWidth:
                                                              const IntrinsicColumnWidth(),
                                                          children: [
                                                            TableRow(
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border.all(
                                                                    // color: blueColor
                                                                    color: blueColor),
                                                              ),
                                                              children: [
                                                                _buildHeader(
                                                                    'Insurance Company',
                                                                    0,
                                                                    (property) =>
                                                                        property
                                                                            .insuranceCompany!),

                                                                _buildHeader(
                                                                    'Policy Id',
                                                                    2,
                                                                    null),
                                                                _buildHeader(
                                                                    'Liability Coverage',
                                                                    2,
                                                                    null),
                                                                _buildHeader(
                                                                    'Status',
                                                                    2,
                                                                    null),
                                                                _buildHeader(
                                                                    'Effective Date',
                                                                    2,
                                                                    null),
                                                                _buildHeader(
                                                                    'Expiration Date',
                                                                    3,
                                                                    null),
                                                                _buildHeader(
                                                                    'Actions',
                                                                    3,
                                                                    null),
                                                                // _buildHeader('Actions', 4, null),
                                                              ],
                                                            ),
                                                            TableRow(
                                                              decoration:
                                                                  const BoxDecoration(
                                                                border: Border.symmetric(
                                                                    horizontal:
                                                                        BorderSide
                                                                            .none),
                                                              ),
                                                              children: List.generate(
                                                                  7,
                                                                  (index) => TableCell(
                                                                      child: Container(
                                                                          height:
                                                                              20))),
                                                            ),
                                                            for (var i = 0;
                                                                i <
                                                                    _pagedData
                                                                        .length;
                                                                i++)
                                                              TableRow(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border:
                                                                      Border(
                                                                    left: BorderSide(
                                                                        color:
                                                                            blueColor),
                                                                    right: BorderSide(
                                                                        color:
                                                                            blueColor),
                                                                    top: BorderSide(
                                                                        color:
                                                                            blueColor),
                                                                    bottom: i ==
                                                                            _pagedData.length -
                                                                                1
                                                                        ? const BorderSide(
                                                                            color: Color.fromRGBO(
                                                                                21,
                                                                                43,
                                                                                81,
                                                                                1))
                                                                        : BorderSide
                                                                            .none,
                                                                  ),
                                                                ),
                                                                children: [
                                                                  _buildDataCell(
                                                                      _pagedData[i]
                                                                              .insuranceCompany ??
                                                                          ''),
                                                                  _buildDataCell(
                                                                    _pagedData[
                                                                            i]
                                                                        .policyId!,
                                                                  ),
                                                                  _buildDataCell(
                                                                    _pagedData[
                                                                            i]
                                                                        .liabilityCoverage
                                                                        .toString()!,
                                                                  ),
                                                                  _buildDataCell(
                                                                    _pagedData[i].active ==
                                                                            true
                                                                        ? 'Active'
                                                                        : 'Inactive',
                                                                  ),
                                                                  _buildDataCell(
                                                                    _pagedData[
                                                                            i]
                                                                        .effectiveDate!,
                                                                  ),
                                                                  _buildDataCell(
                                                                    _pagedData[
                                                                            i]
                                                                        .expirationDate!,
                                                                  ),
                                                                  _buildActionsCell(
                                                                      _pagedData[
                                                                          i]),
                                                                ],
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    // const SizedBox(height: 25),
                                                    // _buildPaginationControls(),
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
                          )),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Builder(builder: (context) {
                      final tTab = tenantsummery.first;
                      final ach = tTab.allowAch != false;
                      final card = tTab.allowCard != false;
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Payments Details",
                                  style: TextStyle(
                                    color: blueColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 21,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Allowed Payment Methods",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Checkbox(
                                  value: ach,
                                  onChanged: (v) =>
                                      _tabletOnPaymentAch(tTab, v == true),
                                  activeColor: blueColor,
                                ),
                                Text(
                                  "ACH",
                                  style: TextStyle(
                                    color:
                                        ach ? blueColor : Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: card,
                                  onChanged: (v) =>
                                      _tabletOnPaymentCard(tTab, v == true),
                                  activeColor: blueColor,
                                ),
                                Text(
                                  "Card",
                                  style: TextStyle(
                                    color:
                                        card ? blueColor : Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () =>
                                    _tabletOpenAddCard(tenantsummery.first),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: blueColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "Manage Payment Methods",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: blueColor),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(width: 2),
                                    Text(
                                      "Lease Details",
                                      style: TextStyle(
                                        color: blueColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 21,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                FutureBuilder<List<TenantLeaseData>>(
                                  future: fetchLeaseData(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: SpinKitFadingCircle(
                                          color: Colors.black,
                                          size: 40.0,
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Center(
                                        child: Text('Error: ${snapshot.error}'),
                                      );
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return Container(
                                        height: 80,
                                        child: const Center(
                                          child: Text('No Data Available'),
                                        ),
                                      );
                                    } else {
                                      var data = snapshot.data!;

                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          dataRowHeight: 35,
                                          headingRowHeight: 35,
                                          border: TableBorder.all(
                                            width: 1,
                                            color: const Color.fromRGBO(
                                                21, 43, 83, 1),
                                          ),
                                          columns: [
                                            DataColumn(
                                                label: Text('Status',
                                                    style: TextStyle(
                                                        color: blueColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16))),
                                            DataColumn(
                                                label: Text('Start - End',
                                                    style: TextStyle(
                                                        color: blueColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16))),
                                            DataColumn(
                                                label: Text('Property',
                                                    style: TextStyle(
                                                        color: blueColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16))),
                                            DataColumn(
                                                label: Text('Type',
                                                    style: TextStyle(
                                                        color: blueColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16))),
                                            DataColumn(
                                                label: Text('Rent',
                                                    style: TextStyle(
                                                        color: blueColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16))),
                                          ],
                                          rows: data.map((lease) {
                                            return DataRow(
                                              cells: [
                                                DataCell(Text(
                                                    determineStatus(
                                                        lease.startDate,
                                                        lease.endDate),
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF8A95A8),
                                                        fontWeight:
                                                            FontWeight.w500))),
                                                DataCell(Text(
                                                    '${dateProvider.formatCurrentDate(normalizeDateForDisplay(lease.startDate))} to ${dateProvider.formatCurrentDate(normalizeDateForDisplay(lease.endDate))}',
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF8A95A8),
                                                        fontWeight:
                                                            FontWeight.w500))),
                                                DataCell(Text(
                                                    lease.rentalAdress ?? '',
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF8A95A8),
                                                        fontWeight:
                                                            FontWeight.w500))),
                                                DataCell(Text(
                                                    lease.leaseType ?? '',
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF8A95A8),
                                                        fontWeight:
                                                            FontWeight.w500))),
                                                DataCell(Text(
                                                    formatCurrency(
                                                        lease.rentAmount),
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF8A95A8),
                                                        fontWeight:
                                                            FontWeight.w500))),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              );
            }
          },
        ),
      ),
      // FutureBuilder<RentalOwnerSummey>(
      //   future: RentalOwnerService().fetchRentalOwnerSummary(rentalOwnerId),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return CircularProgressIndicator();
      //     } else if (snapshot.hasError) {
      //       return Text('Error: ${snapshot.error}');
      //     } else if (!snapshot.hasData || snapshot.data == null) {
      //       return Text('No Data Available');
      //     } else {
      //       RentalOwnerSummey rentalOwner = snapshot.data!;
      //       return ListView(
      //         children: [
      //           ListTile(
      //             title: Text(rentalOwner.rentalOwnerName ?? 'No Name'),
      //             subtitle: Text(rentalOwner.rentalOwnerPrimaryEmail ?? 'No Email'),
      //             trailing: Text(rentalOwner.rentalOwnerPhoneNumber ?? 'No Phone'),
      //           ),
      //           // Add more ListTile widgets or other UI elements as needed
      //         ],
      //       );
      //     }
      //   },
      // ),
    );
  }
}

/// Robust date parser that handles multiple date formats and malformed strings
DateTime? parseDateRobust(String? dateString) {
  if (dateString == null || dateString.isEmpty) return null;

  // Clean the date string - remove extra text that might be present
  String cleaned = dateString.trim();

  // Try to extract date from malformed strings like "Trying to read - from 08/01/2026 at 3"
  // Look for common date patterns
  RegExp datePattern =
      RegExp(r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})|(\d{4}-\d{1,2}-\d{1,2})');
  Match? match = datePattern.firstMatch(cleaned);
  if (match != null) {
    cleaned = match.group(0) ?? cleaned;
  }

  // List of date formats to try
  List<String> dateFormats = [
    'yyyy-MM-dd', // Standard format: 2028-01-01
    'yyyy-M-d', // Without leading zeros: 2028-1-1
    'MM/dd/yyyy', // US format: 08/01/2026
    'M/d/yyyy', // US format without leading zeros: 8/1/2026
    'dd-MM-yyyy', // European format: 01-08-2026
    'd-M-yyyy', // European format without leading zeros: 1-8-2026
    'MM-dd-yyyy', // US format with dashes: 08-01-2026
    'M-d-yyyy', // US format with dashes without leading zeros: 8-1-2026
  ];

  // Try each format
  for (String format in dateFormats) {
    try {
      return DateFormat(format).parse(cleaned);
    } catch (e) {
      continue;
    }
  }

  // If all formats fail, return null
  return null;
}

/// Normalizes a date string to yyyy-MM-dd format for display
/// Extracts date from malformed strings and converts to proper format
String normalizeDateForDisplay(String? dateString) {
  if (dateString == null || dateString.isEmpty) return '';

  // Try to parse the date
  DateTime? parsedDate = parseDateRobust(dateString);

  if (parsedDate != null) {
    // Convert to yyyy-MM-dd format so DateProvider can format it properly
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }

  // If parsing fails, return original string (will be handled by DateProvider)
  return dateString;
}

String determineStatus(String? startDate, String? endDate) {
  if (startDate == null || endDate == null) return 'UNKNOWN';

  // Use robust date parser
  DateTime? start = parseDateRobust(startDate);
  DateTime? end = parseDateRobust(endDate);

  // If parsing fails, return UNKNOWN
  if (start == null || end == null) return 'UNKNOWN';

  // Set today to start of day to ensure accurate comparison
  DateTime today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  // Set end to end of day (23:59:59) to keep lease active through the end date
  DateTime endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);

  if (today.isBefore(start)) {
    return 'FUTURE';
  } else if (today.isAfter(endOfDay)) {
    return 'PAST';
  } else {
    return 'ACTIVE';
  }
}

String formatCurrency(dynamic amount) {
  if (amount == null) return '\$0.00';
  try {
    // Handle both String and numeric types
    double value = amount is String ? double.parse(amount) : amount.toDouble();
    // Format with currency symbol and 2 decimal places
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(value);
  } catch (e) {
    return '\$0.00';
  }
}
