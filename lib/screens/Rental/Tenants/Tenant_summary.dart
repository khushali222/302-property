import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:three_zero_two_property/Model/AdminTenantInsuranceModel/adminTenantInsuranceModel.dart';

import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/repository/AdminTenantInsuranceService/adminTenantinsuranceService.dart';
import 'package:three_zero_two_property/repository/tenants.dart';
import 'package:three_zero_two_property/screens/Rental/Tenants/AdminTenantInsurance/AdminTenantInsuranceTable.dart';
import 'package:three_zero_two_property/screens/Rental/Tenants/AdminTenantInsurance/addAdminTenantInsurance.dart';
import 'package:three_zero_two_property/screens/Rental/Tenants/AdminTenantInsurance/editAdminTenantInsurance.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

import '../../../model/rentalOwner.dart';

import '../../../model/tenants.dart';
import '../../../repository/Rental_ownersData.dart';
import '../../../widgets/drawer_tiles.dart';

class Tenant_summary extends StatefulWidget {
  String tenantId;
  Tenant_summary({super.key, required this.tenantId});
  @override
  State<Tenant_summary> createState() => _Tenant_summaryState();
}

class _Tenant_summaryState extends State<Tenant_summary> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: widget302.,
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
                    color: Colors.black,
                  ),
                  "Add Property Type",
                  false),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.person_add,
                    color: Colors.black,
                  ),
                  "Add Staff Member",
                  false),
              buildDropdownListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.key,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Rental",
                  ["Properties", "RentalOwner", "Tenants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.thumbsUp,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Leasing",
                  ["Rent Roll", "Applicants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"],
                  selectedSubtopic: "Properties"),
            ],
          ),
        ),
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
                        children: [
                          Text(
                            '${tenantsummery.first.tenantFirstName}',
                            style: TextStyle(
                                color: blueColor, fontWeight: FontWeight.bold),
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
                                height:
                                    MediaQuery.of(context).size.height * .045,
                                width: MediaQuery.of(context).size.width * .15,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: const Color.fromRGBO(21, 43, 81, 1),
                                  boxShadow: [
                                    const BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 1.0), //(x,y)
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    "Edit",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .034),
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
                                height:
                                    MediaQuery.of(context).size.height * .045,
                                width: MediaQuery.of(context).size.width * .15,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: const Color.fromRGBO(21, 43, 81, 1),
                                  boxShadow: [
                                    const BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 1.0), //(x,y)
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    "Back",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .034),
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
                          color: const Color.fromRGBO(21, 43, 81, 1),
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
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color.fromRGBO(21, 43, 81, 1)),
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
                                    "Contact Information",
                                    style: TextStyle(
                                        color:
                                            const Color.fromRGBO(21, 43, 81, 1),
                                        fontWeight: FontWeight.bold,
                                        // fontSize: 18
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .045),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              //phonenumber
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Name",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: const Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 2),
                                  Text(
                                    '${tenantsummery.first.tenantFirstName}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  const SizedBox(width: 2),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              //homenumber
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Phone Number",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: const Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 2),
                                  Text(
                                    '${tenantsummery.first.tenantPhoneNumber}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  const SizedBox(width: 2),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              //office number
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Email",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: const Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 2),
                                  Text(
                                    '${tenantsummery.first.tenantEmail}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  const SizedBox(width: 2),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              //primary email

                              const SizedBox(
                                height: 12,
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
                  //Personal information
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color.fromRGBO(21, 43, 81, 1)),
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
                                        color:
                                            const Color.fromRGBO(21, 43, 81, 1),
                                        fontWeight: FontWeight.bold,
                                        // fontSize: 18
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .045),
                                  ),
                                ],
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
                                  Text(
                                    "Birth Date",
                                    style: TextStyle(
                                        color: const Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 2),
                                  // Text(
                                  //   '${rentalownersummery.isNotEmpty && rentalownersummery.first.rentalOwnerName != null ? rentalownersummery.first.rentalOwnerName : 'N/A'}',
                                  // ),
                                  Text(
                                    '${tenantsummery.first.tenantBirthDate}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  const SizedBox(width: 2),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              //company name
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "TaxPayer Id",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: const Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 2),
                                  Text(
                                    '${tenantsummery.first.taxPayerId}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  const SizedBox(width: 2),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              //street address
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Comments",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: const Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: Text(
                                      '${tenantsummery.first.comments}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor,
                                      ),
                                      overflow: TextOverflow.visible,
                                      softWrap: true,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              //enter city
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
//Emergency Contact
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color.fromRGBO(21, 43, 81, 1)),
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
                                    "Emergency Contact",
                                    style: TextStyle(
                                        color:
                                            const Color.fromRGBO(21, 43, 81, 1),
                                        fontWeight: FontWeight.bold,
                                        // fontSize: 18
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .045),
                                  ),
                                ],
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
                                  Text(
                                    "Contact Name",
                                    style: TextStyle(
                                        color: const Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 2),
                                  // Text(
                                  //   '${rentalownersummery.isNotEmpty && rentalownersummery.first.rentalOwnerName != null ? rentalownersummery.first.rentalOwnerName : 'N/A'}',
                                  // ),
                                  Text(
                                    '${tenantsummery.first.emergencyContact!.name}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  const SizedBox(width: 2),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              //company name
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Relation With Tenants",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: const Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 2),
                                  Text(
                                    '${tenantsummery.first.emergencyContact!.relation}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  const SizedBox(width: 2),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              //street address
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Emergency Email",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: const Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 2),
                                  Text(
                                    '${tenantsummery.first.emergencyContact!.email}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  const SizedBox(width: 2),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Emergency Phone",
                                    style: TextStyle(
                                        // color: Colors.grey,
                                        color: const Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .036),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 2),
                                  Text(
                                    '${tenantsummery.first.emergencyContact!.phoneNumber}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor),
                                  ),
                                  const SizedBox(width: 2),
                                ],
                              ),

                              //enter city
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
                            color: const Color.fromRGBO(21, 43, 81, 1)),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 15, bottom: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              //add propertytype
                              Text(
                                'Renters Insurance Policy',
                                style: TextStyle(
                                    color: blueColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 13, right: 13),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        final result =
                                            await Navigator.of(context).push(
                                                MaterialPageRoute(
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
                                        height:
                                            (MediaQuery.of(context).size.width <
                                                    500)
                                                ? 40
                                                : MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.055,
                                        width:
                                            (MediaQuery.of(context).size.width <
                                                    500)
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4
                                                : MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                        decoration: BoxDecoration(
                                          color: const Color.fromRGBO(
                                              21, 43, 81, 1),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Add Policy",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: (MediaQuery.of(
                                                                  context)
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
                                    if (MediaQuery.of(context).size.width < 500)
                                      const SizedBox(width: 6),
                                    if (MediaQuery.of(context).size.width > 500)
                                      const SizedBox(width: 22),
                                  ],
                                ),
                              ),
                              // const SizedBox(height: 10),

                              if (MediaQuery.of(context).size.width > 500)
                                const SizedBox(height: 25),
                              if (MediaQuery.of(context).size.width < 500)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: FutureBuilder<
                                      List<AdminTenantInsuranceModel>>(
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
                                            child: Text(
                                                'Error: ${snapshot.error}'));
                                      } else if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return Container(
                                            height: 80,
                                            child: const Center(
                                                child:
                                                    Text('No data available')));
                                      } else {
                                        var data = snapshot.data!;
                                        if (selectedValue == null &&
                                            searchvalue!.isEmpty) {
                                          data = snapshot.data!;
                                        } else if (selectedValue == "All") {
                                          data = snapshot.data!;
                                        } else if (searchvalue!.isNotEmpty) {
                                          data = snapshot.data!
                                              .where((property) => property
                                                  .provider!
                                                  .toLowerCase()
                                                  .contains(searchvalue!
                                                      .toLowerCase()))
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
                                              const SizedBox(height: 20),
                                              _buildHeaders(),
                                              const SizedBox(height: 20),
                                              Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: blueColor)),
                                                child: Column(
                                                  children: currentPageData
                                                      .asMap()
                                                      .entries
                                                      .map((entry) {
                                                    int index = entry.key;
                                                    bool isExpanded =
                                                        expandedIndex == index;
                                                    AdminTenantInsuranceModel
                                                        Propertytype =
                                                        entry.value;
                                                    //return CustomExpansionTile(data: Propertytype, index: index);
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: blueColor),
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
                                                                      setState(
                                                                          () {
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
                                                                    child:
                                                                        Container(
                                                                      margin: const EdgeInsets
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
                                                                              top: 10),
                                                                      child:
                                                                          FaIcon(
                                                                        isExpanded
                                                                            ? FontAwesomeIcons.sortUp
                                                                            : FontAwesomeIcons.sortDown,
                                                                        size:
                                                                            20,
                                                                        color: const Color
                                                                            .fromRGBO(
                                                                            21,
                                                                            43,
                                                                            83,
                                                                            1),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 4,
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        // Navigator.of(context)
                                                                        //     .push(MaterialPageRoute(builder: (context) => summery_page(lease_id: Propertytype.leaseId,)));
                                                                      },
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                5.0),
                                                                        child:
                                                                            Text(
                                                                          '${Propertytype.provider}',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                blueColor,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                13,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          .08),
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Text(
                                                                      '${Propertytype.policyId}',
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            blueColor,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width: MediaQuery.of(context)
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
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width: MediaQuery.of(context)
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
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          20),
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
                                                                              ? FontAwesomeIcons.sortUp
                                                                              : FontAwesomeIcons.sortDown,
                                                                          size:
                                                                              50,
                                                                          color:
                                                                              Colors.transparent,
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
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
                                                                          width:
                                                                              40,
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              IconButton(
                                                                                icon: const FaIcon(
                                                                                  FontAwesomeIcons.edit,
                                                                                  size: 20,
                                                                                  color: Color.fromRGBO(21, 43, 83, 1),
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
                                                                              IconButton(
                                                                                icon: const FaIcon(
                                                                                  FontAwesomeIcons.trashCan,
                                                                                  size: 20,
                                                                                  color: Color.fromRGBO(21, 43, 83, 1),
                                                                                ),
                                                                                onPressed: () {
                                                                                  //handleDelete(Propertytype);
                                                                                  _showAlert(context, Propertytype.tenantInsuranceId!);
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
                                                        horizontal: 20.0,
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
                                                                    left: const BorderSide(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1)),
                                                                    right: const BorderSide(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1)),
                                                                    top: const BorderSide(
                                                                        color: Color.fromRGBO(
                                                                            21,
                                                                            43,
                                                                            81,
                                                                            1)),
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
                          )),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color.fromRGBO(21, 43, 81, 1)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 15, bottom: 15),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "Lease Details",
                                    style: TextStyle(
                                        color:
                                            const Color.fromRGBO(21, 43, 81, 1),
                                        fontWeight: FontWeight.bold,
                                        // fontSize: 18
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .045),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Table(
                                  defaultColumnWidth:
                                      const IntrinsicColumnWidth(),
                                  border: TableBorder.all(color: Colors.black),
                                  children: [
                                    const TableRow(
                                      decoration: BoxDecoration(),
                                      children: [
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Status',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Start - End',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(
                                                      21, 43, 81, 1),
                                                )),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Property',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(
                                                      21, 43, 81, 1),
                                                )),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Type',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(
                                                      21, 43, 81, 1),
                                                )),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Rent',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromRGBO(
                                                      21, 43, 81, 1),
                                                )),
                                          ),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      decoration: const BoxDecoration(
                                        border: Border.symmetric(
                                            horizontal: BorderSide.none),
                                      ),
                                      children: [
                                        TableCell(
                                          child: Container(
                                            height: 40,
                                            child: const Center(
                                              child: Text(
                                                'asdjfakds',
                                                style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      21, 43, 81, 1),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            height: 40,
                                            child: const Center(
                                                child: Text(
                                              'asdfjhk',
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
                                              ),
                                            )),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            height: 40,
                                            child: const Center(
                                                child: Text(
                                              'adsfjhaksd',
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
                                              ),
                                            )),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            height: 40,
                                            child: const Center(
                                                child: Text(
                                              'skdfjha',
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
                                              ),
                                            )),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            height: 40,
                                            child: const Center(
                                                child: Text(
                                              'adsfkjha',
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1),
                                              ),
                                            )),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
