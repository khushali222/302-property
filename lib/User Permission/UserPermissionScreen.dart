import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/AdminUser%20Permission/adminUserPermissionModel.dart';
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
  bool _isLoading = false;

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
      appBar:
          widget_302.App_Bar(context: context, isUserPermitePageActive: true),
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
                    FontAwesomeIcons.folderOpen,
                    color: Colors.black,
                  ),
                  "Reports",
                  false),
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
                      Text(
                        'Tenant Permissions',
                        style: TextStyle(
                          color: blueColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildPermissionTable(
                        'Property',
                        [
                          _buildCheckboxRow(
                            'VIEW',
                            tenantPropertyView,
                            (value) {
                              setState(() {
                                tenantPropertyView = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      Divider(color: blueColor),
                      _buildPermissionTable(
                        'Financial',
                        [
                          _buildCheckboxRow(
                            'VIEW',
                            tenantFinancialView,
                            (value) {
                              setState(() {
                                tenantFinancialView = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'ADD',
                            tenantFinancialAdd,
                            (value) {
                              setState(() {
                                tenantFinancialAdd = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'EDIT',
                            tenantFinancialEdit,
                            (value) {
                              setState(() {
                                tenantFinancialEdit = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      Divider(color: blueColor),
                      _buildPermissionTable(
                        'Work Order',
                        [
                          _buildCheckboxRow(
                            'VIEW',
                            tenantWorkorderView,
                            (value) {
                              setState(() {
                                tenantWorkorderView = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'ADD',
                            tenantWorkorderAdd,
                            (value) {
                              setState(() {
                                tenantWorkorderAdd = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'EDIT',
                            tenantWorkorderEdit,
                            (value) {
                              setState(() {
                                tenantWorkorderEdit = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'DELETE',
                            tenantWorkorderDelete,
                            (value) {
                              setState(() {
                                tenantWorkorderDelete = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      Divider(color: blueColor),
                      _buildPermissionTable(
                        'Documents',
                        [
                          _buildCheckboxRow(
                            'VIEW',
                            tenantDocumentsView,
                            (value) {
                              setState(() {
                                tenantDocumentsView = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'ADD',
                            tenantDocumentsAdd,
                            (value) {
                              setState(() {
                                tenantDocumentsAdd = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'EDIT',
                            tenantDocumentsEdit,
                            (value) {
                              setState(() {
                                tenantDocumentsEdit = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'DELETE',
                            tenantDocumentsDelete,
                            (value) {
                              setState(() {
                                tenantDocumentsDelete = value!;
                              });
                            },
                          ),
                        ],
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
                      Text(
                        'Staff Permissions',
                        style: TextStyle(
                          color: blueColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildPermissionTable(
                        'Property',
                        [
                          _buildCheckboxRow(
                            'VIEW',
                            staffPropertyView,
                            (value) {
                              setState(() {
                                staffPropertyView = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'ADD',
                            staffPropertyAdd,
                            (value) {
                              setState(() {
                                staffPropertyAdd = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'EDIT',
                            staffPropertyEdit,
                            (value) {
                              setState(() {
                                staffPropertyEdit = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'DELETE',
                            staffPropertyDelete,
                            (value) {
                              setState(() {
                                staffPropertyDelete = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'DETAIL VIEW',
                            staffPropertydetailView,
                            (value) {
                              setState(() {
                                staffPropertydetailView = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      Divider(color: blueColor),
                      _buildPermissionTable(
                        'Lease',
                        [
                          _buildCheckboxRow(
                            'VIEW',
                            staffLeaseView,
                            (value) {
                              setState(() {
                                staffLeaseView = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'ADD',
                            staffLeaseAdd,
                            (value) {
                              setState(() {
                                staffLeaseAdd = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'EDIT',
                            staffLeaseEdit,
                            (value) {
                              setState(() {
                                staffLeaseEdit = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'DELETE',
                            staffLeaseDelete,
                            (value) {
                              setState(() {
                                staffLeaseDelete = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'DETAIL VIEW',
                            staffLeasedetailView,
                            (value) {
                              setState(() {
                                staffLeasedetailView = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      Divider(color: blueColor),
                      _buildPermissionTable(
                        'Payment',
                        [
                          _buildCheckboxRow(
                            'VIEW',
                            staffPaymentView,
                            (value) {
                              setState(() {
                                staffPaymentView = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'ADD',
                            staffPaymentAdd,
                            (value) {
                              setState(() {
                                staffPaymentAdd = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'EDIT',
                            staffPaymentEdit,
                            (value) {
                              setState(() {
                                staffPaymentEdit = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'DELETE',
                            staffPaymentDelete,
                            (value) {
                              setState(() {
                                staffPaymentDelete = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      Divider(color: blueColor),
                      _buildPermissionTable(
                        'Tenant',
                        [
                          _buildCheckboxRow(
                            'VIEW',
                            staffTenantView,
                            (value) {
                              setState(() {
                                staffTenantView = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'ADD',
                            staffTenantAdd,
                            (value) {
                              setState(() {
                                staffTenantAdd = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'EDIT',
                            staffTenantEdit,
                            (value) {
                              setState(() {
                                staffTenantEdit = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'DELETE',
                            staffTenantDelete,
                            (value) {
                              setState(() {
                                staffTenantDelete = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      Divider(color: blueColor),
                      _buildPermissionTable(
                        'Work Order',
                        [
                          _buildCheckboxRow(
                            'VIEW',
                            staffWorkorderView,
                            (value) {
                              setState(() {
                                staffWorkorderView = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'ADD',
                            staffWorkorderAdd,
                            (value) {
                              setState(() {
                                staffWorkorderAdd = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'EDIT',
                            staffWorkorderEdit,
                            (value) {
                              setState(() {
                                staffWorkorderEdit = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'DELETE',
                            staffWorkorderDelete,
                            (value) {
                              setState(() {
                                staffWorkorderDelete = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'DETAIL VIEW',
                            staffWorkorderdetailView,
                            (value) {
                              setState(() {
                                staffWorkorderdetailView = value!;
                              });
                            },
                          ),
                        ],
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
                      Text(
                        'Vendor Permissions',
                        style: TextStyle(
                          color: blueColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      _buildPermissionTable(
                        'Work Order',
                        [
                          _buildCheckboxRow('VIEW', vendorWorkorderView,
                              (value) {
                            setState(() {
                              vendorWorkorderView = value!;
                            });
                          }),
                          _buildCheckboxRow('EDIT', vendorWorkorderEdit,
                              (value) {
                            setState(() {
                              vendorWorkorderEdit = value!;
                            });
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              LayoutBuilder(
                builder: (context,contranit) {
                  if(contranit.maxWidth > 500){
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width:100,
                          height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                                String? adminId = prefs.getString("adminId");

                                UserPermissionData userPermissionData =
                                UserPermissionData(
                                  adminId: adminId,
                                  tenantPermission: TenantPermission(
                                    propertyView: tenantPropertyView,
                                    financialView: tenantFinancialView,
                                    financialAdd: tenantFinancialAdd,
                                    financialEdit: tenantFinancialEdit,
                                    documentsAdd: tenantDocumentsAdd,
                                    workorderView: tenantWorkorderView,
                                    workorderAdd: tenantWorkorderAdd,
                                    workorderEdit: tenantWorkorderEdit,
                                    workorderDelete: tenantWorkorderDelete,
                                    documentsView: tenantDocumentsView,
                                    documentsEdit: tenantDocumentsEdit,
                                    documentsDelete: tenantDocumentsDelete,
                                  ),
                                  staffPermission: StaffPermission(
                                    propertydetailView: staffPropertydetailView,
                                    workorderdetailView: staffWorkorderdetailView,
                                    paymentView: staffPaymentView,
                                    paymentAdd: staffPaymentAdd,
                                    paymentEdit: staffPaymentEdit,
                                    paymentDelete: staffPaymentDelete,
                                    propertyView: staffPropertyView,
                                    leaseAdd: staffLeaseAdd,
                                    workorderEdit: staffWorkorderEdit,
                                    propertyAdd: staffPropertyAdd,
                                    propertyEdit: staffPropertyEdit,
                                    propertyDelete: staffPropertyDelete,
                                    tenantView: staffTenantView,
                                    tenantAdd: staffTenantAdd,
                                    tenantEdit: staffTenantEdit,
                                    tenantDelete: staffTenantDelete,
                                    leaseView: staffLeaseView,
                                    leaseEdit: staffLeaseEdit,
                                    leaseDelete: staffLeaseDelete,
                                    leasedetailView: staffLeasedetailView,
                                    workorderView: staffWorkorderView,
                                    workorderAdd: staffWorkorderAdd,
                                    workorderDelete: staffWorkorderDelete,
                                  ),
                                  vendorPermission: VendorPermission(
                                    workorderEdit: vendorWorkorderEdit,
                                    workorderView: vendorWorkorderView,
                                  ),
                                );
                                print(userPermissionData.toJson());
                                PermissionService service = PermissionService();
                                int statusCode = await service
                                    .postUserPermissionData(userPermissionData);
                                if (statusCode == 200) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  Fluttertoast.showToast(
                                      msg: 'Permissions updated successfully');
                                  Navigator.pop(context);

                                  print('Permissions updated successfully.');
                                } else {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  Fluttertoast.showToast(
                                      msg:
                                      'Failed to update permissions. Try Again later');
                                  print(
                                      'Failed to update permissions. Status code: $statusCode');
                                }
                              },
                              child: _isLoading
                                  ? Center(
                                child: SpinKitFadingCircle(
                                  color: Colors.white,
                                  size: 20.0,
                                ),
                              )
                                  : Text('Save',style: TextStyle(
                                fontSize: 20
                              ),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blueColor,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: 120,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancel',style: TextStyle(
                                fontSize: 20
                              ),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blueColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String? adminId = prefs.getString("adminId");

                            UserPermissionData userPermissionData =
                                UserPermissionData(
                              adminId: adminId,
                              tenantPermission: TenantPermission(
                                propertyView: tenantPropertyView,
                                financialView: tenantFinancialView,
                                financialAdd: tenantFinancialAdd,
                                financialEdit: tenantFinancialEdit,
                                documentsAdd: tenantDocumentsAdd,
                                workorderView: tenantWorkorderView,
                                workorderAdd: tenantWorkorderAdd,
                                workorderEdit: tenantWorkorderEdit,
                                workorderDelete: tenantWorkorderDelete,
                                documentsView: tenantDocumentsView,
                                documentsEdit: tenantDocumentsEdit,
                                documentsDelete: tenantDocumentsDelete,
                              ),
                              staffPermission: StaffPermission(
                                propertydetailView: staffPropertydetailView,
                                workorderdetailView: staffWorkorderdetailView,
                                paymentView: staffPaymentView,
                                paymentAdd: staffPaymentAdd,
                                paymentEdit: staffPaymentEdit,
                                paymentDelete: staffPaymentDelete,
                                propertyView: staffPropertyView,
                                leaseAdd: staffLeaseAdd,
                                workorderEdit: staffWorkorderEdit,
                                propertyAdd: staffPropertyAdd,
                                propertyEdit: staffPropertyEdit,
                                propertyDelete: staffPropertyDelete,
                                tenantView: staffTenantView,
                                tenantAdd: staffTenantAdd,
                                tenantEdit: staffTenantEdit,
                                tenantDelete: staffTenantDelete,
                                leaseView: staffLeaseView,
                                leaseEdit: staffLeaseEdit,
                                leaseDelete: staffLeaseDelete,
                                leasedetailView: staffLeasedetailView,
                                workorderView: staffWorkorderView,
                                workorderAdd: staffWorkorderAdd,
                                workorderDelete: staffWorkorderDelete,
                              ),
                              vendorPermission: VendorPermission(
                                workorderEdit: vendorWorkorderEdit,
                                workorderView: vendorWorkorderView,
                              ),
                            );
                            print(userPermissionData.toJson());
                            PermissionService service = PermissionService();
                            int statusCode = await service
                                .postUserPermissionData(userPermissionData);
                            if (statusCode == 200) {
                              setState(() {
                                _isLoading = false;
                              });
                              Fluttertoast.showToast(
                                  msg: 'Permissions updated successfully');
                              Navigator.pop(context);

                              print('Permissions updated successfully.');
                            } else {
                              setState(() {
                                _isLoading = false;
                              });
                              Fluttertoast.showToast(
                                  msg:
                                      'Failed to update permissions. Try Again later');
                              print(
                                  'Failed to update permissions. Status code: $statusCode');
                            }
                          },
                          child: _isLoading
                              ? Center(
                                  child: SpinKitFadingCircle(
                                    color: Colors.white,
                                    size: 20.0,
                                  ),
                                )
                              : Text('Save'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blueColor,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blueColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionTable(String title, List<Widget> checkboxes) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        int columns = 2;

        if (screenWidth > 600) {
          columns = 5;
        }
        if (screenWidth > 900) {
          columns = 6;
        }

        List<TableRow> rows = [];
        for (int i = 0; i < checkboxes.length; i += columns) {
          List<Widget> cells = [];
          for (int j = 0; j < columns; j++) {
            cells.add(
              TableCell(
                child:
                    i + j < checkboxes.length ? checkboxes[i + j] : Container(),
              ),
            );
          }
          rows.add(TableRow(children: cells));
        }

        return Center(
          child: Table(
            columnWidths: {
              for (int i = 0; i < columns; i++) i: FlexColumnWidth(1.0),
            },
            children: [
              TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: blueColor,
                        ),
                      ),
                    ),
                  ),
                  for (int i = 1; i < columns; i++)
                    TableCell(child: Container()),
                ],
              ),
              ...rows,
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckboxRow(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Row(
        children: [
          Checkbox(value: value, onChanged: onChanged),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: blueColor,
            ),
          ),
        ],
      ),
    );
  }
}
