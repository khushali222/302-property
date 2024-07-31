import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/repository/AdminUser%20Permission/adminUserPermissionService.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';

class UserPermissionScreen extends StatefulWidget {
  const UserPermissionScreen({super.key});

  @override
  State<UserPermissionScreen> createState() => _UserPermissionScreenState();
}

class _UserPermissionScreenState extends State<UserPermissionScreen> {
  bool tenantPropertyView = false;
  bool tenantFinancialView = false;
  bool tenantFinancialAdd = false;
  bool tenantFinancialEdit = false;
  bool tenantDocumentsAdd = false;
  bool tenantWorkorderView = false;
  bool tenantWorkorderAdd = false;
  bool tenantWorkorderEdit = false;
  bool tenantWorkorderDelete = false;
  bool tenantDocumentsView = false;
  bool tenantDocumentsEdit = false;
  bool tenantDocumentsDelete = false;
  bool staffPropertydetailView = false;
  bool staffWorkorderdetailView = false;
  bool staffPaymentView = false;
  bool staffPaymentAdd = false;
  bool staffPaymentEdit = false;
  bool staffPaymentDelete = false;
  bool staffPropertyView = false;
  bool staffLeaseAdd = false;
  bool staffWorkorderEdit = false;
  bool staffPropertyAdd = false;
  bool staffPropertyEdit = false;
  bool staffPropertyDelete = false;
  bool staffTenantView = false;
  bool staffTenantAdd = false;
  bool staffTenantEdit = false;
  bool staffTenantDelete = false;
  bool staffLeaseView = false;
  bool staffLeaseEdit = false;
  bool staffLeaseDelete = false;
  bool staffLeasedetailView = false;
  bool staffWorkorderView = false;
  bool staffWorkorderAdd = false;
  bool staffWorkorderDelete = false;
  bool vendorWorkorderEdit = false;
  bool vendorWorkorderView = false;

  @override
  void initState() {
    super.initState();
    _fetchAndSetPermissions();
  }

  Future<void> _fetchAndSetPermissions() async {
    final service = PermissionService();
    try {
      final permissions = await service.fetchPermissions();
      if (permissions != null) {
        setState(() {
          // Tenant permissions
          tenantPropertyView =
              permissions.tenantPermission?.propertyView ?? false;
          tenantFinancialView =
              permissions.tenantPermission?.financialView ?? false;
          tenantFinancialAdd =
              permissions.tenantPermission?.financialAdd ?? false;
          tenantFinancialEdit =
              permissions.tenantPermission?.financialEdit ?? false;
          tenantDocumentsAdd =
              permissions.tenantPermission?.documentsAdd ?? false;
          tenantWorkorderView =
              permissions.tenantPermission?.workorderView ?? false;
          tenantWorkorderAdd =
              permissions.tenantPermission?.workorderAdd ?? false;
          tenantWorkorderEdit =
              permissions.tenantPermission?.workorderEdit ?? false;
          tenantWorkorderDelete =
              permissions.tenantPermission?.workorderDelete ?? false;
          tenantDocumentsView =
              permissions.tenantPermission?.documentsView ?? false;
          tenantDocumentsEdit =
              permissions.tenantPermission?.documentsEdit ?? false;
          tenantDocumentsDelete =
              permissions.tenantPermission?.documentsDelete ?? false;

          // Staff permissions
          staffPropertydetailView =
              permissions.staffPermission?.propertydetailView ?? false;
          staffWorkorderdetailView =
              permissions.staffPermission?.workorderdetailView ?? false;
          staffPaymentView = permissions.staffPermission?.paymentView ?? false;
          staffPaymentAdd = permissions.staffPermission?.paymentAdd ?? false;
          staffPaymentEdit = permissions.staffPermission?.paymentEdit ?? false;
          staffPaymentDelete =
              permissions.staffPermission?.paymentDelete ?? false;
          staffPropertyView =
              permissions.staffPermission?.propertyView ?? false;
          staffLeaseAdd = permissions.staffPermission?.leaseAdd ?? false;
          staffWorkorderEdit =
              permissions.staffPermission?.workorderEdit ?? false;
          staffPropertyAdd = permissions.staffPermission?.propertyAdd ?? false;
          staffPropertyEdit =
              permissions.staffPermission?.propertyEdit ?? false;
          staffPropertyDelete =
              permissions.staffPermission?.propertyDelete ?? false;
          staffTenantView = permissions.staffPermission?.tenantView ?? false;
          staffTenantAdd = permissions.staffPermission?.tenantAdd ?? false;
          staffTenantEdit = permissions.staffPermission?.tenantEdit ?? false;
          staffTenantDelete =
              permissions.staffPermission?.tenantDelete ?? false;
          staffLeaseView = permissions.staffPermission?.leaseView ?? false;
          staffLeaseEdit = permissions.staffPermission?.leaseEdit ?? false;
          staffLeaseDelete = permissions.staffPermission?.leaseDelete ?? false;
          staffLeasedetailView =
              permissions.staffPermission?.leasedetailView ?? false;
          staffWorkorderView =
              permissions.staffPermission?.workorderView ?? false;
          staffWorkorderAdd =
              permissions.staffPermission?.workorderAdd ?? false;
          staffWorkorderDelete =
              permissions.staffPermission?.workorderDelete ?? false;

          // Vendor permissions
          vendorWorkorderEdit =
              permissions.vendorPermission?.workorderEdit ?? false;
          vendorWorkorderView =
              permissions.vendorPermission?.workorderView ?? false;
        });
      }
    } catch (e) {
      print('Failed to fetch permissions: $e');
    }
  }

  bool selectedvalue = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
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
                    color: Colors.white,
                  ),
                  "Dashboard",
                  true),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.home,
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
              buildListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.letterboxd,
                    color: Colors.white,
                  ),
                  "Reports",
                  true),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromRGBO(21, 43, 83, 1),
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tenant Permissions',
                          style: TextStyle(
                              color: blueColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                      SizedBox(
                        height: 8,
                      ),
                      Center(
                        child: Table(
                          // border: TableBorder.all(),
                          columnWidths: const {
                            0: FlexColumnWidth(1.1),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                          },
                          children: [
                            TableRow(children: [
                              TableCell(
                                // verticalAlignment:
                                //     TableCellVerticalAlignment.middle,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      'Property',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: blueColor),
                                    ),
                                    // Text(''), // Add this line to repeat "Property"
                                  ],
                                ),
                              ),
                              TableCell(
                                child: Column(
                                  children: [
                                    Table(
                                      // border: TableBorder.all(),
                                      children: [
                                        TableRow(children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: TableCell(
                                                child: Row(
                                              children: [
                                                Checkbox(
                                                    value: tenantPropertyView,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        tenantPropertyView =
                                                            !tenantPropertyView;
                                                      });
                                                      print('');
                                                    }),
                                                Text(
                                                  'VIEW',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              ],
                                            )),
                                          ),
                                        ]),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                      Divider(
                        color: blueColor,
                      ),
                      Center(
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(1.1),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                          },
                          children: [
                            TableRow(children: [
                              TableCell(
                                // verticalAlignment:
                                //     TableCellVerticalAlignment.middle,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      'Financial',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: blueColor),
                                    ),
                                    // Text(''), // Add this line to repeat "Property"
                                  ],
                                ),
                              ),
                              TableCell(
                                child: Column(
                                  children: [
                                    Table(
                                      // border: TableBorder.all(),
                                      columnWidths: {
                                        0: FlexColumnWidth(1.4),
                                        1: FlexColumnWidth(2),
                                      },
                                      // border: TableBorder.all(),
                                      children: [
                                        TableRow(children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: TableCell(
                                                child: Row(
                                              children: [
                                                Checkbox(
                                                    value: tenantFinancialView,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        tenantFinancialView =
                                                            !tenantFinancialView;
                                                      });
                                                    }),
                                                Text(
                                                  'VIEW',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              ],
                                            )),
                                          ),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      Checkbox(
                                                          value:
                                                              tenantFinancialAdd,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              tenantFinancialAdd =
                                                                  !tenantFinancialAdd;
                                                            });
                                                            print('');
                                                          }),
                                                      Text(
                                                        'ADD',
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: blueColor),
                                                      ),
                                                    ],
                                                  ))),
                                        ]),
                                      ],
                                    ),
                                    Table(
                                      // border: TableBorder.all(),
                                      children: [
                                        TableRow(children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: TableCell(
                                                child: Row(
                                              children: [
                                                Checkbox(
                                                    value: tenantFinancialEdit,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        tenantFinancialEdit =
                                                            !tenantFinancialEdit;
                                                      });
                                                      print('');
                                                    }),
                                                Text(
                                                  'EDIT',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              ],
                                            )),
                                          ),
                                        ]),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                      Divider(
                        color: blueColor,
                      ),
                      Center(
                        child: Table(
                          // border: TableBorder.all(),
                          columnWidths: const {
                            0: FlexColumnWidth(1.1),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                          },
                          children: [
                            TableRow(children: [
                              TableCell(
                                // verticalAlignment:
                                //     TableCellVerticalAlignment.middle,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      'Work Order',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: blueColor),
                                    ),
                                    // Text(''), // Add this line to repeat "Property"
                                  ],
                                ),
                              ),
                              TableCell(
                                child: Column(
                                  children: [
                                    Table(
                                      columnWidths: {
                                        0: FlexColumnWidth(1.4),
                                        1: FlexColumnWidth(2),
                                      },
                                      // border: TableBorder.all(),
                                      children: [
                                        TableRow(children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: TableCell(
                                                child: Row(
                                              children: [
                                                Checkbox(
                                                    value: tenantWorkorderView,
                                                    onChanged: (value) {
                                                      print('');
                                                      setState(() {
                                                        tenantWorkorderView =
                                                            !tenantWorkorderView;
                                                      });
                                                    }),
                                                Text(
                                                  'VIEW',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              ],
                                            )),
                                          ),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      Checkbox(
                                                          value:
                                                              tenantWorkorderAdd,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              tenantWorkorderAdd =
                                                                  !tenantWorkorderAdd;
                                                            });
                                                            print('');
                                                          }),
                                                      Text(
                                                        'ADD',
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: blueColor),
                                                      ),
                                                    ],
                                                  ))),
                                        ]),
                                      ],
                                    ),
                                    Table(
                                      columnWidths: {
                                        0: FlexColumnWidth(1.4),
                                        1: FlexColumnWidth(2),
                                      },
                                      // border: TableBorder.all(),
                                      children: [
                                        TableRow(children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: TableCell(
                                                child: Row(
                                              children: [
                                                Checkbox(
                                                    value: tenantWorkorderEdit,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        tenantWorkorderEdit =
                                                            !tenantWorkorderEdit;
                                                      });
                                                      print('');
                                                    }),
                                                Text(
                                                  'EDIT',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              ],
                                            )),
                                          ),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      Checkbox(
                                                          value:
                                                              tenantWorkorderDelete,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              tenantWorkorderDelete =
                                                                  !tenantWorkorderDelete;
                                                            });
                                                            print('');
                                                          }),
                                                      Text(
                                                        'DELETE',
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: blueColor),
                                                      ),
                                                    ],
                                                  ))),
                                        ]),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                      Divider(
                        color: blueColor,
                      ),
                      Center(
                        child: Table(
                          // border: TableBorder.all(),
                          columnWidths: const {
                            0: FlexColumnWidth(1.1),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                          },
                          children: [
                            TableRow(children: [
                              TableCell(
                                // verticalAlignment:
                                //     TableCellVerticalAlignment.middle,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      'Documents',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: blueColor),
                                    ),
                                    // Text(''), // Add this line to repeat "Property"
                                  ],
                                ),
                              ),
                              TableCell(
                                child: Column(
                                  children: [
                                    Table(
                                      columnWidths: {
                                        0: FlexColumnWidth(1.4),
                                        1: FlexColumnWidth(2),
                                      },
                                      // border: TableBorder.all(),
                                      children: [
                                        TableRow(children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: TableCell(
                                                child: Row(
                                              children: [
                                                Checkbox(
                                                    value: tenantDocumentsView,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        tenantDocumentsView =
                                                            !tenantDocumentsView;
                                                      });
                                                      print('');
                                                    }),
                                                Text(
                                                  'VIEW',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              ],
                                            )),
                                          ),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      Checkbox(
                                                          value:
                                                              tenantDocumentsAdd,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              tenantDocumentsAdd =
                                                                  !tenantDocumentsAdd;
                                                            });
                                                            print('');
                                                          }),
                                                      Text(
                                                        'ADD',
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: blueColor),
                                                      ),
                                                    ],
                                                  ))),
                                        ]),
                                      ],
                                    ),
                                    Table(
                                      columnWidths: {
                                        0: FlexColumnWidth(1.4),
                                        1: FlexColumnWidth(2),
                                      },
                                      // border: TableBorder.all(),
                                      children: [
                                        TableRow(children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: TableCell(
                                                child: Row(
                                              children: [
                                                Checkbox(
                                                    value: tenantDocumentsEdit,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        tenantDocumentsEdit =
                                                            !tenantDocumentsEdit;
                                                      });
                                                      print('');
                                                    }),
                                                Text(
                                                  'EDIT',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              ],
                                            )),
                                          ),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      Checkbox(
                                                          value:
                                                              tenantDocumentsDelete,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              tenantDocumentsDelete =
                                                                  !tenantDocumentsDelete;
                                                            });
                                                            print('');
                                                          }),
                                                      Text(
                                                        'DELETE',
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: blueColor),
                                                      ),
                                                    ],
                                                  ))),
                                        ]),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromRGBO(21, 43, 83, 1),
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Staff Permissions',
                          style: TextStyle(
                              color: blueColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                      SizedBox(
                        height: 8,
                      ),
                      Center(
                        child: Table(
                          // border: TableBorder.all(),
                          columnWidths: const {
                            0: FlexColumnWidth(1.1),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                          },
                          children: [
                            TableRow(children: [
                              TableCell(
                                // verticalAlignment:
                                //     TableCellVerticalAlignment.middle,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      'Property',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: blueColor),
                                    ),
                                    // Text(''), // Add this line to repeat "Property"
                                  ],
                                ),
                              ),
                              TableCell(
                                child: Column(
                                  children: [
                                    Table(
                                      // border: TableBorder.all(),
                                      children: [
                                        TableRow(children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: TableCell(
                                                child: Row(
                                              children: [
                                                Checkbox(
                                                    value: staffPropertyView,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        staffPropertyView =
                                                            !staffPropertyView;
                                                      });
                                                      print('');
                                                    }),
                                                Text(
                                                  'VIEW',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              ],
                                            )),
                                          ),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      Checkbox(
                                                          value:
                                                              staffPropertyAdd,
                                                          onChanged: (value) {
                                                            print('');
                                                          }),
                                                      Text(
                                                        'ADD',
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: blueColor),
                                                      ),
                                                    ],
                                                  ))),
                                        ]),
                                      ],
                                    ),
                                    Table(
                                      // border: TableBorder.all(),
                                      children: [
                                        TableRow(children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: TableCell(
                                                child: Row(
                                              children: [
                                                Checkbox(
                                                    value: staffPropertyEdit,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        staffPropertyEdit =
                                                            !staffPropertyEdit;
                                                      });
                                                      print('');
                                                    }),
                                                Text(
                                                  'EDIT',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              ],
                                            )),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: TableCell(
                                                child: Row(
                                              children: [
                                                Checkbox(
                                                    value: staffPropertyDelete,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        staffPropertyDelete =
                                                            !staffPropertyDelete;
                                                      });
                                                      print('');
                                                    }),
                                                Text(
                                                  'DELETE',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              ],
                                            )),
                                          ),
                                        ]),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                      Divider(
                        color: blueColor,
                      ),
                      Center(
                        child: Table(
                          // border: TableBorder.all(),
                          columnWidths: const {
                            0: FlexColumnWidth(1.1),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                          },
                          children: [
                            TableRow(children: [
                              TableCell(
                                // verticalAlignment:
                                //     TableCellVerticalAlignment.middle,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      'Lease',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: blueColor),
                                    ),
                                    // Text(''), // Add this line to repeat "Property"
                                  ],
                                ),
                              ),
                              TableCell(
                                child: Column(
                                  children: [
                                    Table(
                                      // border: TableBorder.all(),
                                      children: [
                                        TableRow(children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: TableCell(
                                                child: Row(
                                              children: [
                                                Checkbox(
                                                    value: staffLeaseView,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        staffLeaseView =
                                                            !staffLeaseView;
                                                      });
                                                      print('');
                                                    }),
                                                Text(
                                                  'VIEW',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              ],
                                            )),
                                          ),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      Checkbox(
                                                          value: staffLeaseAdd,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              staffLeaseAdd =
                                                                  !staffLeaseAdd;
                                                            });
                                                            print('');
                                                          }),
                                                      Text(
                                                        'ADD',
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: blueColor),
                                                      ),
                                                    ],
                                                  ))),
                                        ]),
                                      ],
                                    ),
                                    Table(
                                      // border: TableBorder.all(),
                                      children: [
                                        TableRow(children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: TableCell(
                                                child: Row(
                                              children: [
                                                Checkbox(
                                                    value: staffLeaseEdit,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        staffLeaseEdit =
                                                            !staffLeaseEdit;
                                                      });
                                                      print('');
                                                    }),
                                                Text(
                                                  'EDIT',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              ],
                                            )),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: TableCell(
                                                child: Row(
                                              children: [
                                                Checkbox(
                                                    value: staffLeaseDelete,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        staffLeaseDelete =
                                                            !staffLeaseDelete;
                                                      });
                                                      print('');
                                                    }),
                                                Text(
                                                  'DELETE',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              ],
                                            )),
                                          ),
                                        ]),
                                      ],
                                    ),
                                    Table(
                                      // border: TableBorder.all(),
                                      children: [
                                        TableRow(children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: TableCell(
                                                child: Row(
                                              children: [
                                                Checkbox(
                                                    value: staffLeasedetailView,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        staffLeasedetailView =
                                                            !staffLeasedetailView;
                                                      });
                                                      print('');
                                                    }),
                                                Text(
                                                  'DETAIL VIEW',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              ],
                                            )),
                                          ),
                                        ]),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                      Divider(
                        color: blueColor,
                      ),
                      Center(
                        child: Table(
                          // border: TableBorder.all(),
                          columnWidths: const {
                            0: FlexColumnWidth(1.1),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                          },
                          children: [
                            TableRow(children: [
                              TableCell(
                                // verticalAlignment:
                                //     TableCellVerticalAlignment.middle,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      'Tenant',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: blueColor),
                                    ),
                                    // Text(''), // Add this line to repeat "Property"
                                  ],
                                ),
                              ),
                              TableCell(
                                child: Column(
                                  children: [
                                    Table(
                                      // border: TableBorder.all(),
                                      children: [
                                        TableRow(children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: TableCell(
                                                child: Row(
                                              children: [
                                                Checkbox(
                                                    value: staffTenantView,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        staffTenantView =
                                                            !staffTenantView;
                                                      });
                                                      print('');
                                                    }),
                                                Text(
                                                  'VIEW',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              ],
                                            )),
                                          ),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      Checkbox(
                                                          value: staffTenantAdd,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              staffTenantAdd =
                                                                  !staffTenantAdd;
                                                            });
                                                            print('');
                                                          }),
                                                      Text(
                                                        'ADD',
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: blueColor),
                                                      ),
                                                    ],
                                                  ))),
                                        ]),
                                      ],
                                    ),
                                    Table(
                                      // border: TableBorder.all(),
                                      children: [
                                        TableRow(children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: TableCell(
                                                child: Row(
                                              children: [
                                                Checkbox(
                                                    value: staffTenantEdit,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        staffTenantEdit =
                                                            !staffTenantEdit;
                                                      });
                                                      print('');
                                                    }),
                                                Text(
                                                  'EDIT',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              ],
                                            )),
                                          ),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      Checkbox(
                                                          value:
                                                              staffTenantDelete,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              staffTenantDelete =
                                                                  !staffTenantDelete;
                                                            });
                                                            print('');
                                                          }),
                                                      Text(
                                                        'DELETE',
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: blueColor),
                                                      ),
                                                    ],
                                                  ))),
                                        ]),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                      Divider(
                        color: blueColor,
                      ),
                      Center(
                        child: Table(
                          // border: TableBorder.all(),
                          columnWidths: const {
                            0: FlexColumnWidth(1.1),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                          },
                          children: [
                            TableRow(children: [
                              TableCell(
                                // verticalAlignment:
                                //     TableCellVerticalAlignment.middle,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      'Work Order',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: blueColor),
                                    ),
                                    // Text(''), // Add this line to repeat "Property"
                                  ],
                                ),
                              ),
                              TableCell(
                                child: Column(
                                  children: [
                                    Table(
                                      columnWidths: {
                                        0: FlexColumnWidth(1.4),
                                        1: FlexColumnWidth(2),
                                      },
                                      // border: TableBorder.all(),
                                      children: [
                                        TableRow(children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: TableCell(
                                                child: Row(
                                              children: [
                                                Checkbox(
                                                    value: staffWorkorderView,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        staffWorkorderView =
                                                            !staffWorkorderView;
                                                      });
                                                      print('');
                                                    }),
                                                Text(
                                                  'VIEW',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              ],
                                            )),
                                          ),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      Checkbox(
                                                          value:
                                                              staffWorkorderView,
                                                          onChanged: (value) {
                                                            print('');
                                                          }),
                                                      Text(
                                                        'VIEW',
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: blueColor),
                                                      ),
                                                    ],
                                                  ))),
                                        ]),
                                      ],
                                    ),
                                    Table(
                                      columnWidths: {
                                        0: FlexColumnWidth(1.4),
                                        1: FlexColumnWidth(2),
                                      },
                                      // border: TableBorder.all(),
                                      children: [
                                        TableRow(children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: TableCell(
                                                child: Row(
                                              children: [
                                                Checkbox(
                                                    value: staffWorkorderView,
                                                    onChanged: (value) {
                                                      print('');
                                                    }),
                                                Text(
                                                  'Edit',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              ],
                                            )),
                                          ),
                                          TableCell(
                                              child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      Checkbox(
                                                          value:
                                                              staffWorkorderDelete,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              staffWorkorderDelete =
                                                                  !staffWorkorderDelete;
                                                            });
                                                            print('');
                                                          }),
                                                      Text(
                                                        'DELETE',
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: blueColor),
                                                      ),
                                                    ],
                                                  ))),
                                        ]),
                                      ],
                                    ),
                                    Table(
                                      // border: TableBorder.all(),
                                      children: [
                                        TableRow(children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: TableCell(
                                                child: Row(
                                              children: [
                                                Checkbox(
                                                    value:
                                                        staffWorkorderdetailView,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        staffWorkorderdetailView =
                                                            !staffWorkorderdetailView;
                                                      });
                                                      print('');
                                                    }),
                                                Text(
                                                  'DETAIL VIEW',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              ],
                                            )),
                                          ),
                                        ]),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromRGBO(21, 43, 83, 1),
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vendor Permissions',
                          style: TextStyle(
                              color: blueColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                      SizedBox(
                        height: 8,
                      ),
                      Center(
                        child: Table(
                          // border: TableBorder.all(),
                          columnWidths: const {
                            0: FlexColumnWidth(1.1),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                          },
                          children: [
                            TableRow(children: [
                              TableCell(
                                // verticalAlignment:
                                //     TableCellVerticalAlignment.middle,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      'Work Order',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: blueColor),
                                    ),
                                    // Text(''), // Add this line to repeat "Property"
                                  ],
                                ),
                              ),
                              TableCell(
                                child: Column(
                                  children: [
                                    Table(
                                      columnWidths: {
                                        0: FlexColumnWidth(1.4),
                                        1: FlexColumnWidth(2),
                                      },
                                      // border: TableBorder.all(),
                                      children: [
                                        TableRow(children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: TableCell(
                                                child: Row(
                                              children: [
                                                Checkbox(
                                                    value: vendorWorkorderView,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        vendorWorkorderView =
                                                            !vendorWorkorderView;
                                                      });
                                                      print('');
                                                    }),
                                                Text(
                                                  'VIEW',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              ],
                                            )),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: TableCell(
                                                child: Row(
                                              children: [
                                                Checkbox(
                                                    value: vendorWorkorderEdit,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        vendorWorkorderEdit =
                                                            !vendorWorkorderEdit;
                                                      });
                                                      print('');
                                                    }),
                                                Text(
                                                  'EDIT',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: blueColor),
                                                ),
                                              ],
                                            )),
                                          ),
                                        ]),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
