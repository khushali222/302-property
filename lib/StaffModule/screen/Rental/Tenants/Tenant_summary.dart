import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/AdminTenantInsuranceModel/adminTenantInsuranceModel.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/constant/constant.dart';
import '../../../repository/AdminTenantInsuranceService/adminTenantinsuranceService.dart';
import '../../../repository/tenants.dart';

import 'AdminTenantInsurance/addAdminTenantInsurance.dart';
import 'AdminTenantInsurance/editAdminTenantInsurance.dart';
import '../../../widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

import '../../../../Model/tenants.dart';
import '../../../model/rentalOwner.dart';

import '../../../repository/Rental_ownersData.dart';
import '../../../widgets/drawer_tiles.dart';
import '../../../widgets/custom_drawer.dart';

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

class _TenantSummaryMobileState extends State<TenantSummaryMobile> {
  late Future<List<TenantLeaseData>> futurePropertyLease;
  Future<List<TenantLeaseData>> fetchLeaseData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
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
      return allLeaseData;
    } else {
      throw Exception('Failed to load lease data');
    }
  }

  final TenantsRepository _tenantService = TenantsRepository();
  final TenantsRepository repo = TenantsRepository();

  int totalrecords = 0;
  late Future<List<AdminTenantInsuranceModel>> futurePropertyTypes;
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

  void sortData(List<AdminTenantInsuranceModel> data) {
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
                    Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: Text("Company",
                          style: TextStyle(color: Colors.white, fontSize: 14)),
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
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 5.0),
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

  Widget _buildHeaders_lease() {
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
                      padding: EdgeInsets.only(left: 30.0),
                      child: Text("Status",
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                    ),
                    const SizedBox(width: 3),
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
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 5.0),
                      child: Text("Start Date",
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                    ),
                    SizedBox(width: 5),
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
                child: const Row(
                  children: [
                    Text(
                      "End Date",
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
  @override
  void initState() {
    super.initState();
    futurePropertyTypes =
        AdminTenantInsuranceRepository().fetchTenantInsurance(widget.tenantId);
    futurePropertyLease = fetchLeaseData();
  }

  void handleEdit(AdminTenantInsuranceModel property) async {}

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
            var data = await AdminTenantInsuranceRepository()
                .deleteInsurancesProperties(id);
            // Add your delete logic here

            if (data == true)
              setState(() {
                futurePropertyTypes = AdminTenantInsuranceRepository()
                    .fetchTenantInsurance(widget.tenantId);
              });
            Navigator.pop(context);
          },
          color: Colors.red,
        )
      ],
    ).show();
  }

  List<AdminTenantInsuranceModel> _tableData = [];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<AdminTenantInsuranceModel> get _pagedData {
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

  void _sort<T>(Comparable<T> Function(AdminTenantInsuranceModel d) getField,
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

  void handleDelete(AdminTenantInsuranceModel property) {}

  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(AdminTenantInsuranceModel d)? getField) {
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

  Widget _buildActionsCell(AdminTenantInsuranceModel data) {
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
                :  blueColor


, // Change color based on availability
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
    return Scaffold(
      // appBar: widget302.,
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Tenants",
        dropdown: true,
      ),
      body: Center(
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 15,
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back_ios_new_sharp,
                      size: 30,
                    )),
                const SizedBox(
                  width: 15,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${widget.tenants?.tenantFirstName}',
                          style: TextStyle(
                              color: blueColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Tenant',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8A95A8)),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 30,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 10, bottom: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Container(
                  height: 50.0,
                  padding: const EdgeInsets.only(top: 8, left: 10),
                  width: MediaQuery.of(context).size.width * .91,
                  margin: const EdgeInsets.only(bottom: 6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color:blueColor,
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: const Text(
                    "Summery",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Material(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color:blueColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 20, bottom: 30),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 2,
                            ),
                            Text(
                              "Contact Information",
                              style: TextStyle(
                                  color:blueColor,
                                  fontWeight: FontWeight.bold,
                                  // fontSize: 18
                                  fontSize:
                                      MediaQuery.of(context).size.width * .045),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width:
                                  200, // Adjust this width to match the text width or desired length
                              child: Divider(
                                color: grey,
                                thickness:
                                    1, // Optional: Adjust the thickness of the divider
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Table(
                          children: [
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text(
                                  'Name : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Text(
                                '${(widget.tenants?.tenantFirstName ?? '').isEmpty ? 'N/A' : widget.tenants?.tenantFirstName}',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: grey),
                              )),
                            ]),
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text(
                                  'Phone Number : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Text(
                                '${(widget.tenants?.tenantPhoneNumber ?? '').isEmpty ? 'N/A' : widget.tenants?.tenantPhoneNumber}',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: grey),
                              )),
                            ]),
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text(
                                  'Email : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Text(
                                '${(widget.tenants?.tenantEmail ?? '').isEmpty ? 'N/A' : widget.tenants?.tenantEmail}',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: grey),
                              )),
                            ]),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 2,
                            ),
                            Text(
                              "Personal Information",
                              style: TextStyle(
                                  color:blueColor,
                                  fontWeight: FontWeight.bold,
                                  // fontSize: 18
                                  fontSize:
                                      MediaQuery.of(context).size.width * .045),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width:
                                  210, // Adjust this width to match the text width or desired length
                              child: Divider(
                                color: grey,
                                thickness:
                                    1, // Optional: Adjust the thickness of the divider
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        //first name
                        Table(
                          children: [
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text(
                                  'Birth Date : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: Text(
                                  '${(widget.tenants?.tenantBirthDate ?? '').isEmpty ? 'N/A' : widget.tenants?.tenantBirthDate}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: grey),
                                ),
                              )),
                            ]),
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text(
                                  'TaxPayer Id : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: Text(
                                  '${(widget.tenants?.taxPayerId ?? '').isEmpty ? 'N/A' : widget.tenants?.taxPayerId}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: grey),
                                ),
                              )),
                            ]),
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text(
                                  'Comments : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: Text(
                                  '${(widget.tenants?.comments ?? '').isEmpty ? 'N/A' : widget.tenants?.comments}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: grey),
                                ),
                              )),
                            ]),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 2,
                            ),
                            Text(
                              "Emergency Contact",
                              style: TextStyle(
                                  color:blueColor,
                                  fontWeight: FontWeight.bold,
                                  // fontSize: 18
                                  fontSize:
                                      MediaQuery.of(context).size.width * .045),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width:
                                  210, // Adjust this width to match the text width or desired length
                              child: Divider(
                                color: grey,
                                thickness:
                                    1, // Optional: Adjust the thickness of the divider
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Table(
                          children: [
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text(
                                  'Contact Name : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  '${(widget.tenants?.emergencyContact?.name ?? '').isEmpty ? 'N/A' : widget.tenants?.emergencyContact!.name}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: grey),
                                ),
                              )),
                            ]),
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text(
                                  'Relation With Tenant : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  '${(widget.tenants?.emergencyContact?.relation ?? '').isEmpty ? 'N/A' : widget.tenants?.emergencyContact!.relation}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: grey),
                                ),
                              )),
                            ]),
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text(
                                  'Emergency Email : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  '${(widget.tenants?.emergencyContact?.email ?? '').isEmpty ? 'N/A' : widget.tenants?.emergencyContact!.email}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: grey),
                                ),
                              )),
                            ]),
                            TableRow(children: [
                              TableCell(
                                  child: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text(
                                  'Emergency Phone : ',
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              )),
                              TableCell(
                                  child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  '${(widget.tenants?.emergencyContact?.phoneNumber ?? '').isEmpty ? 'N/A' : widget.tenants?.emergencyContact!.phoneNumber}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: grey),
                                ),
                              )),
                            ]),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Text(
                              'Rentals Insurance Policy',
                              style: TextStyle(
                                  color: blueColor,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () async {
                                final result = await Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AdminAddTenantInsurance(
                                              tenantid: widget.tenantId,
                                            )));
                                if (result == true) {
                                  setState(() {
                                    futurePropertyTypes =
                                        AdminTenantInsuranceRepository()
                                            .fetchTenantInsurance(
                                                widget.tenantId);
                                  });
                                }
                              },
                              child: Container(
                                height: (MediaQuery.of(context).size.width <
                                        500)
                                    ? 40
                                    : MediaQuery.of(context).size.width * 0.055,
                                width: (MediaQuery.of(context).size.width < 500)
                                    ? MediaQuery.of(context).size.width * 0.25
                                    : MediaQuery.of(context).size.width * 0.3,
                                decoration: BoxDecoration(
                                  color:blueColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Add Policy",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: (MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500)
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.034
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.025,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width:
                                  210, // Adjust this width to match the text width or desired length
                              child: Divider(
                                color: grey,
                                thickness:
                                    1, // Optional: Adjust the thickness of the divider
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // const SizedBox(height: 10),
                        if (MediaQuery.of(context).size.width > 500)
                          const SizedBox(height: 25),
                        if (MediaQuery.of(context).size.width < 500)
                          Container(
                            // padding: const EdgeInsets.symmetric(
                            //     horizontal: 10.0),
                            child:
                                FutureBuilder<List<AdminTenantInsuranceModel>>(
                              future: futurePropertyTypes,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: SpinKitFadingCircle(
                                    color: Colors.black,
                                    size: 40.0,
                                  ));
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Container(
                                      height: 80,
                                      child: const Center(
                                          child: Text('No data available')));
                                } else {
                                  var data = snapshot.data!;
                                  if (selectedValue == null &&
                                      searchvalue!.isEmpty) {
                                    data = snapshot.data!;
                                  } else if (selectedValue == "All") {
                                    data = snapshot.data!;
                                  } else if (searchvalue!.isNotEmpty) {
                                    data = snapshot.data!
                                        .where((property) => property.provider!
                                            .toLowerCase()
                                            .contains(
                                                searchvalue!.toLowerCase()))
                                        .toList();
                                  }
                                  if (data.length == 0) {
                                    return const Column(
                                      children: [
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Center(
                                          child: Text("No data Found"),
                                        ),
                                      ],
                                    );
                                  }
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
                                        const SizedBox(height: 15),
                                        _buildHeaders(),
                                        const SizedBox(height: 20),
                                        Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Color.fromRGBO(
                                                      152, 162, 179, .5))),
                                          // decoration: BoxDecoration(
                                          //     border: Border.all(
                                          //         color: blueColor)),
                                          child: Column(
                                            children: currentPageData
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              int index = entry.key;
                                              bool isExpanded =
                                                  expandedIndex == index;
                                              AdminTenantInsuranceModel
                                                  Propertytype = entry.value;
                                              //return CustomExpansionTile(data: Propertytype, index: index);
                                              return Container(
                                                decoration: BoxDecoration(
                                                  color: index % 2 != 0
                                                      ? Colors.white
                                                      : blueColor
                                                          .withOpacity(0.09),
                                                ),
                                                child: Column(
                                                  children: <Widget>[
                                                    ListTile(
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      title: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
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
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            5),
                                                                padding: !isExpanded
                                                                    ? const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10)
                                                                    : const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            10),
                                                                child: FaIcon(
                                                                  isExpanded
                                                                      ? FontAwesomeIcons
                                                                          .sortUp
                                                                      : FontAwesomeIcons
                                                                          .sortDown,
                                                                  size: 20,
                                                                  color: blueColor


,
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 4,
                                                              child: InkWell(
                                                                onTap: () {
                                                                  // Navigator.of(context)
                                                                  //     .push(MaterialPageRoute(builder: (context) => summery_page(lease_id: Propertytype.leaseId,)));
                                                                },
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              5.0),
                                                                  child: Text(
                                                                    '${Propertytype.provider}',
                                                                    style:
                                                                        TextStyle(
                                                                      color:
                                                                          blueColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          13,
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
                                                              flex: 2,
                                                              child: Text(
                                                                '${Propertytype.policyId}',
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      blueColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .08),
                                                            Expanded(
                                                              flex: 3,
                                                              child: Text(
                                                                // '${widget.data.createdAt}',
                                                                '${formatDate(Propertytype.expirationDate!)}',

                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      blueColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 12,
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
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    8.0),
                                                        margin: const EdgeInsets
                                                            .only(bottom: 20),
                                                        child:
                                                            SingleChildScrollView(
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
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
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
                                                                        Text.rich(
                                                                          TextSpan(
                                                                            children: [
                                                                              TextSpan(
                                                                                text: 'Status : ',
                                                                                style: TextStyle(fontWeight: FontWeight.bold, color: blueColor), // Bold and black
                                                                              ),
                                                                              TextSpan(
                                                                                text: '${Propertytype.status}',
                                                                                style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.grey), // Light and grey
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Text.rich(
                                                                          TextSpan(
                                                                            children: [
                                                                              TextSpan(
                                                                                text: 'Effective Date : ',
                                                                                style: TextStyle(fontWeight: FontWeight.bold, color: blueColor), // Bold and black
                                                                              ),
                                                                              TextSpan(
                                                                                text: '${formatDate(Propertytype.effectiveDate!)}',
                                                                                style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.grey), // Light and grey
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: 40,
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        IconButton(
                                                                          icon:
                                                                               FaIcon(
                                                                            FontAwesomeIcons.edit,
                                                                            size:
                                                                                20,
                                                                            color: blueColor


,
                                                                          ),
                                                                          onPressed:
                                                                              () async {
                                                                            // handleEdit(Propertytype);

                                                                            var check = await Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                    builder: (context) => editAdminInsurance(
                                                                                          data: Propertytype,
                                                                                        )));
                                                                            if (check ==
                                                                                true) {
                                                                              setState(() {
                                                                                futurePropertyTypes = AdminTenantInsuranceRepository().fetchTenantInsurance(widget.tenantId);
                                                                              });
                                                                            }
                                                                          },
                                                                        ),
                                                                        IconButton(
                                                                          icon:
                                                                               FaIcon(
                                                                            FontAwesomeIcons.trashCan,
                                                                            size:
                                                                                20,
                                                                            color: blueColor


,
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            //handleDelete(Propertytype);
                                                                            _showAlert(context,
                                                                                Propertytype.tenantInsuranceId!);
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
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        if (MediaQuery.of(context).size.width > 500)
                          FutureBuilder<List<AdminTenantInsuranceModel>>(
                            future: futurePropertyTypes,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: SpinKitFadingCircle(
                                    color: Colors.black,
                                    size: 55.0,
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Center(
                                    child: Text('No data available'));
                              } else {
                                _tableData = snapshot.data!;

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
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20),
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
                                                                  property
                                                                      .provider!),

                                                          _buildHeader(
                                                              'Policy Id',
                                                              2,
                                                              null),
                                                          _buildHeader(
                                                              'Liability Coverage',
                                                              2,
                                                              null),
                                                          _buildHeader('Status',
                                                              2, null),
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
                                                          border:
                                                              Border.symmetric(
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
                                                          i < _pagedData.length;
                                                          i++)
                                                        TableRow(
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border(
                                                              left: const BorderSide(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1)),
                                                              right: const BorderSide(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1)),
                                                              top: const BorderSide(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          21,
                                                                          43,
                                                                          81,
                                                                          1)),
                                                              bottom: i ==
                                                                      _pagedData
                                                                              .length -
                                                                          1
                                                                  ? const BorderSide(
                                                                      color: Color
                                                                          .fromRGBO(
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
                                                                    .provider!),
                                                            _buildDataCell(
                                                              _pagedData[i]
                                                                  .policyId!,
                                                            ),
                                                            _buildDataCell(
                                                              _pagedData[i]
                                                                  .liabilityCoverage
                                                                  .toString()!,
                                                            ),
                                                            _buildDataCell(
                                                              _pagedData[i]
                                                                  .status!,
                                                            ),
                                                            _buildDataCell(
                                                              _pagedData[i]
                                                                  .effectiveDate!,
                                                            ),
                                                            _buildDataCell(
                                                              _pagedData[i]
                                                                  .expirationDate!,
                                                            ),
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
                        const SizedBox(height: 20),
                         Row(
                          children: [
                            SizedBox(width: 2),
                            Text(
                              "Lease Details",
                              style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width:
                                  150, // Adjust this width to match the text width or desired length
                              child: Divider(
                                color: grey,
                                thickness:
                                    1, // Optional: Adjust the thickness of the divider
                              ),
                            ),
                          ],
                        ),
                        Container(
                          // padding: const EdgeInsets.symmetric(
                          //     horizontal: 10.0),
                          child: FutureBuilder<List<TenantLeaseData>>(
                            future: futurePropertyLease,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: SpinKitFadingCircle(
                                  color: Colors.black,
                                  size: 40.0,
                                ));
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Container(
                                    height: 80,
                                    child: const Center(
                                        child: Text('No data available')));
                              } else {
                                var data = snapshot.data!;
                                if (selectedValueTenantLease == null &&
                                    searchvalueTenantLease!.isEmpty) {
                                  data = snapshot.data!;
                                } else if (selectedValueTenantLease == "All") {
                                  data = snapshot.data!;
                                } else if (searchvalueTenantLease!.isNotEmpty) {
                                  data = snapshot.data!
                                      .where((property) => property.startDate!
                                          .toLowerCase()
                                          .contains(searchvalue!.toLowerCase()))
                                      .toList();
                                }
                                if (data.length == 0) {
                                  return const Column(
                                    children: [
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Center(
                                        child: Text("No data Found"),
                                      ),
                                    ],
                                  );
                                }
                                sortDataTenantLease(data);
                                final totalPages =
                                    (data.length / itemsPerPageTenantLease)
                                        .ceil();
                                final currentPageData = data
                                    .skip(currentPageTenantLease *
                                        itemsPerPageTenantLease)
                                    .take(itemsPerPageTenantLease)
                                    .toList();
                                return SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      _buildHeaders_lease(),
                                      const SizedBox(height: 20),
                                      Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Color.fromRGBO(
                                                    152, 162, 179, .5))),
                                        // decoration: BoxDecoration(
                                        //     border: Border.all(
                                        //         color: blueColor)),
                                        child: Column(
                                          children: currentPageData
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            int index = entry.key;
                                            bool isExpandedTenantLease =
                                                expandedTenantLeaseIndex ==
                                                    index;
                                            TenantLeaseData Propertytype =
                                                entry.value;
                                            //return CustomExpansionTile(data: Propertytype, index: index);
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: index % 2 != 0
                                                    ? Colors.white
                                                    : blueColor
                                                        .withOpacity(0.09),
                                              ),
                                              // decoration: BoxDecoration(
                                              //   border: Border.all(
                                              //       color: blueColor),
                                              // ),
                                              child: Column(
                                                children: <Widget>[
                                                  ListTile(
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    title: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
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
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  .02),
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
                                                                if (expandedTenantLeaseIndex ==
                                                                    index) {
                                                                  expandedTenantLeaseIndex =
                                                                      null;
                                                                } else {
                                                                  expandedTenantLeaseIndex =
                                                                      index;
                                                                }
                                                              });
                                                            },
                                                            child: Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 5),
                                                              padding: !isExpandedTenantLease
                                                                  ? const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          10)
                                                                  : const EdgeInsets
                                                                      .only(
                                                                      top: 10),
                                                              child: FaIcon(
                                                                isExpandedTenantLease
                                                                    ? FontAwesomeIcons
                                                                        .sortUp
                                                                    : FontAwesomeIcons
                                                                        .sortDown,
                                                                size: 20,
                                                                color: blueColor


,
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: InkWell(
                                                              onTap: () {
                                                                // Navigator.of(context)
                                                                //     .push(MaterialPageRoute(builder: (context) => summery_page(lease_id: Propertytype.leaseId,)));
                                                              },
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            5.0),
                                                                child: Text(
                                                                  '${determineStatus(Propertytype.startDate, Propertytype.endDate)}',
                                                                  style:
                                                                      TextStyle(
                                                                    color:
                                                                        blueColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        13,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              '${Propertytype.startDate}',
                                                              style: TextStyle(
                                                                color:
                                                                    blueColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
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
                                                            child: Text(
                                                              // '${widget.data.createdAt}',

                                                              '${Propertytype.endDate!}',

                                                              style: TextStyle(
                                                                color:
                                                                    blueColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
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
                                                  if (isExpandedTenantLease)
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8.0),
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 20),
                                                      child:
                                                          SingleChildScrollView(
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                FaIcon(
                                                                  isExpandedTenantLease
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
                                                                              text: 'Property : ',
                                                                              style: TextStyle(fontWeight: FontWeight.bold, color: blueColor), // Bold and black
                                                                            ),
                                                                            TextSpan(
                                                                              text: '${Propertytype.rentalAdress ?? ''}',
                                                                              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.grey), // Light and grey
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
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
                                                                      Text.rich(
                                                                        TextSpan(
                                                                          children: [
                                                                            TextSpan(
                                                                              text: 'Rent Amount : ',
                                                                              style: TextStyle(fontWeight: FontWeight.bold, color: blueColor), // Bold and black
                                                                            ),
                                                                            TextSpan(
                                                                              text: '${Propertytype.rentAmount!}',
                                                                              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.grey), // Light and grey
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: 40,
                                                                  child: Column(
                                                                    children: [
                                                                      IconButton(
                                                                        icon:
                                                                             FaIcon(
                                                                          FontAwesomeIcons
                                                                              .edit,
                                                                          size:
                                                                              20,
                                                                          color: blueColor


,
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          // handleEdit(Propertytype);

                                                                          // var check = await Navigator.push(
                                                                          //     context,
                                                                          //     MaterialPageRoute(
                                                                          //         builder: (context) => editAdminInsurance(
                                                                          //               data: Propertytype,
                                                                          //             )));
                                                                          // if (check == true) {
                                                                          //   setState(() {
                                                                          //     futurePropertyTypes = AdminTenantInsuranceRepository().fetchTenantInsurance(widget.tenantId);
                                                                          //   });
                                                                          // }
                                                                        },
                                                                      ),
                                                                      IconButton(
                                                                        icon:
                                                                             FaIcon(
                                                                          FontAwesomeIcons
                                                                              .trashCan,
                                                                          size:
                                                                              20,
                                                                          color: blueColor


,
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          //handleDelete(Propertytype);
                                                                          // _showAlert(context, Propertytype.tenantInsuranceId!);
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
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
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
      return allLeaseData;
    } else {
      throw Exception('Failed to load lease data');
    }
  }

  final TenantsRepository repo = TenantsRepository();

  int totalrecords = 0;
  late Future<List<AdminTenantInsuranceModel>> futurePropertyTypes;
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

  void sortData(List<AdminTenantInsuranceModel> data) {
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
  @override
  void initState() {
    super.initState();
    futurePropertyTypes =
        AdminTenantInsuranceRepository().fetchTenantInsurance(widget.tenantId);
  }

  void handleEdit(AdminTenantInsuranceModel property) async {}

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
            var data = await AdminTenantInsuranceRepository()
                .deleteInsurancesProperties(id);
            // Add your delete logic here

            if (data == true)
              setState(() {
                futurePropertyTypes = AdminTenantInsuranceRepository()
                    .fetchTenantInsurance(widget.tenantId);
              });
            Navigator.pop(context);
          },
          color: Colors.red,
        )
      ],
    ).show();
  }

  List<AdminTenantInsuranceModel> _tableData = [];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<AdminTenantInsuranceModel> get _pagedData {
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

  void _sort<T>(Comparable<T> Function(AdminTenantInsuranceModel d) getField,
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

  void handleDelete(AdminTenantInsuranceModel property) {}

  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(AdminTenantInsuranceModel d)? getField) {
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

  Widget _buildActionsCell(AdminTenantInsuranceModel data) {
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
                :  blueColor


, // Change color based on availability
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
          future: TenantsRepository().fetchTenantsummery(widget.tenantId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Center(
                    child: SpinKitFadingCircle(
                  color: Colors.black,
                  size: 40.0,
                )),
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
                                  color:blueColor,
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
                                  color:blueColor,
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
                          color:blueColor,
                          boxShadow: [
                            const BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: const Text(
                          "Summery",
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
                              border: Border.all(
                                  color:blueColor),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 25, top: 20, bottom: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   Row(
                                    children: [
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        "Contact Information",
                                        style: TextStyle(
                                            color:
                                                blueColor,
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
                                            '${(tenantsummery.first.tenantPhoneNumber ?? '').isEmpty ? 'N/A' : tenantsummery.first.tenantPhoneNumber}',
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
                                border: Border.all(
                                    color:blueColor),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 25, right: 25, top: 20, bottom: 30),
                                child: Column(
                                  children: [
                                     Row(
                                      children: [
                                        SizedBox(
                                          width: 2,
                                        ),
                                        Text(
                                          "Personal Information",
                                          style: TextStyle(
                                              color:
                                                  blueColor,
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
                                              '${(tenantsummery.first.tenantBirthDate ?? '').isEmpty ? 'N/A' : tenantsummery.first.tenantBirthDate}',
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
                          border: Border.all(
                              color:blueColor),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 25, right: 25, top: 20, bottom: 30),
                          child: Column(
                            children: [
                               Row(
                                children: [
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Emergency Contact",
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
                              const SizedBox(
                                height: 10,
                              ),
                              //first name
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Contact Name",
                                        style: TextStyle(
                                            color: Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        '${(tenantsummery.first.emergencyContact!.name ?? '').isEmpty ? 'N/A' : tenantsummery.first.emergencyContact!.name}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: blueColor),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 36,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Relation With Tenants",
                                        style: TextStyle(
                                            color: Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        '${(tenantsummery.first.emergencyContact!.relation ?? '').isEmpty ? 'N/A' : tenantsummery.first.emergencyContact!.relation}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: blueColor),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 36,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Emergency Email",
                                        style: TextStyle(
                                            color: Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        '${(tenantsummery.first.emergencyContact!.email ?? '').isEmpty ? 'N/A' : tenantsummery.first.emergencyContact!.email}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: blueColor),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 36,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Emergency Phone",
                                        style: TextStyle(
                                            color: Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        '${(tenantsummery.first.emergencyContact!.phoneNumber ?? '').isEmpty ? 'N/A' : tenantsummery.first.emergencyContact!.phoneNumber}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: blueColor),
                                      ),
                                    ],
                                  ),
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
                        border: Border.all(
                            color:blueColor),
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
                                                    AdminTenantInsuranceRepository()
                                                        .fetchTenantInsurance(
                                                            widget.tenantId);
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: blueColor


,
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
                                FutureBuilder<List<AdminTenantInsuranceModel>>(
                                  future: futurePropertyTypes,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: SpinKitFadingCircle(
                                          color: Colors.black,
                                          size: 55.0,
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text('Error: ${snapshot.error}'));
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return const Center(
                                          child: Text('No data available'));
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
                                                                            .provider!),

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
                                                                    left:  BorderSide(
                                                                        color: blueColor


),
                                                                    right:  BorderSide(
                                                                        color: blueColor


),
                                                                    top:  BorderSide(
                                                                        color: blueColor


),
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
                                                                      _pagedData[
                                                                              i]
                                                                          .provider!),
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
                                                                    _pagedData[
                                                                            i]
                                                                        .status!,
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
                    padding: const EdgeInsets.all(25.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color:blueColor),
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
                                    SizedBox(width: 2),
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
                                          child: Text('No data available'),
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
                                                    '${lease.startDate} to ${lease.endDate}',
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
                                                    '${lease.rentAmount}',
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
      //       return Text('No data available');
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

String determineStatus(String? startDate, String? endDate) {
  if (startDate == null || endDate == null) return 'Unknown';

  DateTime start = DateFormat('yyyy-MM-dd').parse(startDate);
  DateTime end = DateFormat('yyyy-MM-dd').parse(endDate);
  DateTime today = DateTime.now();

  if (today.isBefore(start)) {
    return 'Future';
  } else if (today.isAfter(end)) {
    return 'Expired';
  } else {
    return 'Active';
  }
}
