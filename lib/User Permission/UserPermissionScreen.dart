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
import '../../widgets/custom_drawer.dart';
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

 /* bool staffPaymentView = false;
  bool staffPaymentAdd = false;
  bool staffPaymentEdit = false;
  bool staffPaymentDelete = false;*/
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
  bool staffSetting = false;

  bool staffWorkorderView = false;
  bool staffWorkorderAdd = false;
  bool staffWorkorderDelete = false;
  bool vendorWorkorderEdit = false;
  bool vendorWorkorderView = false;

// New variables for staffPropertyType
  bool staffPropertyTypeView = false;
  bool staffPropertyTypeAdd = false;
  bool staffPropertyTypeEdit = false;
  bool staffPropertyTypeDelete = false;

// New variables for staffApplicant
  bool staffApplicantView = false;
  bool staffApplicantAdd = false;
  bool staffApplicantEdit = false;
  bool staffApplicantDelete = false;

// New variables for staffVendor
  bool staffVendorView = false;
  bool staffVendorAdd = false;
  bool staffVendorEdit = false;
  bool staffVendorDelete = false;

// New variables for staffRentalOwner
  bool staffRentalOwnerView = false;
  bool staffRentalOwnerAdd = false;
  bool staffRentalOwnerEdit = false;
  bool staffRentalOwnerDelete = false;
  bool _isLoading = false;
  bool selectAll = false;
  @override
  void initState() {
    super.initState();
    _fetchAndSetPermissions();
  }
  void checkAllPermissions() {
    selectAll = tenantPropertyView &&
        tenantFinancialView &&
        tenantFinancialAdd &&
        tenantFinancialEdit &&
        tenantDocumentsAdd &&
        tenantWorkorderView &&
        tenantWorkorderAdd &&
        tenantWorkorderEdit &&
        tenantWorkorderDelete &&
        tenantDocumentsView &&
        tenantDocumentsEdit &&
        tenantDocumentsDelete &&
        staffPropertyView &&
        staffLeaseAdd &&
        staffWorkorderEdit &&
        staffPropertyAdd &&
        staffPropertyEdit &&
        staffPropertyDelete &&
        staffTenantView &&
        staffTenantAdd &&
        staffTenantEdit &&
        staffTenantDelete &&
        staffLeaseView &&
        staffLeaseEdit &&
        staffLeaseDelete &&
        staffWorkorderView &&
        staffWorkorderAdd &&
        staffWorkorderDelete &&
        vendorWorkorderEdit &&
        vendorWorkorderView &&
        staffPropertyTypeView &&
        staffPropertyTypeAdd &&
        staffPropertyTypeEdit &&
        staffPropertyTypeDelete &&
        staffApplicantView &&
        staffApplicantAdd &&
        staffApplicantEdit &&
        staffApplicantDelete &&
        staffVendorView &&
        staffVendorAdd &&
        staffVendorEdit &&
        staffVendorDelete &&
        staffRentalOwnerView &&
        staffRentalOwnerAdd &&
        staffRentalOwnerEdit &&
        staffSetting &&

        staffRentalOwnerDelete;
    setState(() {

    });
  }

// Function to update all permission variables based on 'selectAll'
  void updatePermissionsBasedOnSelectAll() {
    selectAll = !selectAll;
    tenantPropertyView = selectAll;
    tenantFinancialView = selectAll;
    tenantFinancialAdd = selectAll;
    tenantFinancialEdit = selectAll;
    tenantDocumentsAdd = selectAll;
    tenantWorkorderView = selectAll;
    tenantWorkorderAdd = selectAll;
    tenantWorkorderEdit = selectAll;
    tenantWorkorderDelete = selectAll;
    tenantDocumentsView = selectAll;
    tenantDocumentsEdit = selectAll;
    tenantDocumentsDelete = selectAll;

    staffPropertyView = selectAll;
    staffLeaseAdd = selectAll;
    staffWorkorderEdit = selectAll;
    staffPropertyAdd = selectAll;
    staffPropertyEdit = selectAll;
    staffPropertyDelete = selectAll;
    staffTenantView = selectAll;
    staffTenantAdd = selectAll;
    staffTenantEdit = selectAll;
    staffTenantDelete = selectAll;
    staffLeaseView = selectAll;
    staffLeaseEdit = selectAll;
    staffLeaseDelete = selectAll;
    staffSetting = selectAll;

    staffWorkorderView = selectAll;
    staffWorkorderAdd = selectAll;
    staffWorkorderDelete = selectAll;
    vendorWorkorderEdit = selectAll;
    vendorWorkorderView = selectAll;

    staffPropertyTypeView = selectAll;
    staffPropertyTypeAdd = selectAll;
    staffPropertyTypeEdit = selectAll;
    staffPropertyTypeDelete = selectAll;

    staffApplicantView = selectAll;
    staffApplicantAdd = selectAll;
    staffApplicantEdit = selectAll;
    staffApplicantDelete = selectAll;

    staffVendorView = selectAll;
    staffVendorAdd = selectAll;
    staffVendorEdit = selectAll;
    staffVendorDelete = selectAll;

    staffRentalOwnerView = selectAll;
    staffRentalOwnerAdd = selectAll;
    staffRentalOwnerEdit = selectAll;
    staffRentalOwnerDelete = selectAll;
    setState(() {
    });
  }
  Future<void> _fetchAndSetPermissions() async {
    final service = PermissionService();
    try {
      final permissions = await service.fetchPermissions();
      if (permissions != null) {
        setState(() {
          // Tenant permissions
          tenantPropertyView = permissions.tenantPermission?.propertyView ?? false;
          tenantFinancialView = permissions.tenantPermission?.financialView ?? false;
          tenantFinancialAdd = permissions.tenantPermission?.financialAdd ?? false;
          tenantFinancialEdit = permissions.tenantPermission?.financialEdit ?? false;
          tenantDocumentsAdd = permissions.tenantPermission?.documentsAdd ?? false;
          tenantWorkorderView = permissions.tenantPermission?.workorderView ?? false;
          tenantWorkorderAdd = permissions.tenantPermission?.workorderAdd ?? false;
          tenantWorkorderEdit = permissions.tenantPermission?.workorderEdit ?? false;
          tenantWorkorderDelete = permissions.tenantPermission?.workorderDelete ?? false;
          tenantDocumentsView = permissions.tenantPermission?.documentsView ?? false;
          tenantDocumentsEdit = permissions.tenantPermission?.documentsEdit ?? false;
          tenantDocumentsDelete = permissions.tenantPermission?.documentsDelete ?? false;

          // Staff permissions
        //  staffPropertydetailView = permissions.staffPermission?.propertydetailView ?? false;
      //    staffWorkorderdetailView = permissions.staffPermission?.workorderdetailView ?? false;
          staffPropertyView = permissions.staffPermission?.propertyView ?? false;
          staffLeaseAdd = permissions.staffPermission?.leaseAdd ?? false;
          staffWorkorderEdit = permissions.staffPermission?.workorderEdit ?? false;
          staffPropertyAdd = permissions.staffPermission?.propertyAdd ?? false;
          staffPropertyEdit = permissions.staffPermission?.propertyEdit ?? false;
          staffPropertyDelete = permissions.staffPermission?.propertyDelete ?? false;
          staffTenantView = permissions.staffPermission?.tenantView ?? false;
          staffTenantAdd = permissions.staffPermission?.tenantAdd ?? false;
          staffTenantEdit = permissions.staffPermission?.tenantEdit ?? false;
          staffTenantDelete = permissions.staffPermission?.tenantDelete ?? false;
          staffLeaseView = permissions.staffPermission?.leaseView ?? false;
          staffLeaseEdit = permissions.staffPermission?.leaseEdit ?? false;
          staffLeaseDelete = permissions.staffPermission?.leaseDelete ?? false;
          staffSetting = permissions.staffPermission?.setting ?? false;
       //   staffLeasedetailView = permissions.staffPermission?.leasedetailView ?? false;
          staffWorkorderView = permissions.staffPermission?.workorderView ?? false;
          staffWorkorderAdd = permissions.staffPermission?.workorderAdd ?? false;
          staffWorkorderDelete = permissions.staffPermission?.workorderDelete ?? false;

          // New Staff permissions
          staffPropertyTypeView = permissions.staffPermission?.propertytypeView ?? false;
          staffPropertyTypeAdd = permissions.staffPermission?.propertytypeAdd ?? false;
          staffPropertyTypeEdit = permissions.staffPermission?.propertytypeEdit ?? false;
          staffPropertyTypeDelete = permissions.staffPermission?.propertytypeDelete ?? false;
          staffRentalOwnerView = permissions.staffPermission?.rentalownerView ?? false;
          staffRentalOwnerAdd = permissions.staffPermission?.rentalownerAdd ?? false;
          staffRentalOwnerEdit = permissions.staffPermission?.rentalownerEdit ?? false;
          staffRentalOwnerDelete = permissions.staffPermission?.rentalownerDelete ?? false;
          staffApplicantView = permissions.staffPermission?.applicantView ?? false;
          staffApplicantAdd = permissions.staffPermission?.applicantAdd ?? false;
          staffApplicantEdit = permissions.staffPermission?.applicantEdit ?? false;
          staffApplicantDelete = permissions.staffPermission?.applicantDelete ?? false;
          staffVendorView = permissions.staffPermission?.vendorView ?? false;
          staffVendorAdd = permissions.staffPermission?.vendorAdd ?? false;
          staffVendorEdit = permissions.staffPermission?.vendorEdit ?? false;
          staffVendorDelete = permissions.staffPermission?.vendorDelete ?? false;

          // Vendor permissions
          vendorWorkorderEdit = permissions.vendorPermission?.workorderEdit ?? false;
          vendorWorkorderView = permissions.vendorPermission?.workorderView ?? false;
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
      backgroundColor: Colors.white,
      appBar:
          widget_302.App_Bar(context: context, isUserPermitePageActive: true),
      drawer:CustomDrawer(currentpage: "Dashboard",dropdown: false,),
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
                      color: blueColor,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Permissions',
                        style: TextStyle(
                          color: blueColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildPermissionTableselectall(
                        '',
                        [
                          _buildCheckboxRowselectall(
                            'Select All',
                            selectAll,
                                (value) {
                                  updatePermissionsBasedOnSelectAll();
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
                      color: blueColor,
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
                            'View Ledger',

                            tenantFinancialView,
                            (value) {
                              setState(() {
                                tenantFinancialView = value!;
                                tenantFinancialEdit = false;
                                tenantFinancialAdd = false;


                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'Make Payment',
                            isDisabled: tenantFinancialView ,
                            tenantFinancialAdd,
                            (value) {
                              setState(() {
                                tenantFinancialAdd = value!;
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
                                tenantWorkorderAdd = false;
                                tenantWorkorderEdit = false;
                                tenantWorkorderDelete  = false;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'ADD',
                            isDisabled: tenantWorkorderView ,
                            tenantWorkorderAdd,
                            (value) {
                              setState(() {
                                tenantWorkorderAdd = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'EDIT',
                            isDisabled: tenantWorkorderView ,
                            tenantWorkorderEdit,
                            (value) {
                              setState(() {
                                tenantWorkorderEdit = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'DELETE',
                            isDisabled: tenantWorkorderView ,
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
                                tenantDocumentsAdd = false;
                                tenantDocumentsDelete = false;
                                tenantDocumentsEdit = false;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'ADD',
                            isDisabled: tenantDocumentsView ,
                            tenantDocumentsAdd,
                            (value) {
                              setState(() {
                                tenantDocumentsAdd = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'EDIT',
                            isDisabled: tenantDocumentsView ,
                            tenantDocumentsEdit,
                            (value) {
                              setState(() {
                                tenantDocumentsEdit = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'DELETE',
                            isDisabled: tenantDocumentsView ,
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
                      color: blueColor,
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
                                 staffPropertyAdd = false;
                                 staffPropertyEdit = false;
                                 staffPropertyDelete = false;

                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'ADD',
                            staffPropertyAdd,
                            isDisabled:staffPropertyView ,
                            (value) {
                              setState(() {
                                staffPropertyAdd = value!;
                              });
                            },

                          ),
                          _buildCheckboxRow(
                            'EDIT',
                            staffPropertyEdit,
                            isDisabled:staffPropertyView ,
                            (value) {
                              setState(() {
                                staffPropertyEdit = value!;
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'DELETE',
                            staffPropertyDelete,
                            isDisabled:staffPropertyView ,
                            (value) {
                              setState(() {
                                staffPropertyDelete = value!;
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
                                 staffLeaseAdd = false;
                                 staffLeaseEdit = false;
                                 staffLeaseDelete = false;
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
                            isDisabled:staffLeaseView ,
                          ),
                          _buildCheckboxRow(
                            'EDIT',
                            staffLeaseEdit,
                            (value) {
                              setState(() {
                                staffLeaseEdit = value!;
                              });
                            },
                            isDisabled:staffLeaseView ,
                          ),
                          _buildCheckboxRow(
                            'DELETE',
                            staffLeaseDelete,
                            (value) {
                              setState(() {
                                staffLeaseDelete = value!;
                              });
                            },
                            isDisabled:staffLeaseView ,
                          ),

                        ],
                      ),
                     /* Divider(color: blueColor),
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
                      ),*/
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
                                 staffTenantAdd = false;
                                 staffTenantEdit = false;
                                 staffTenantDelete = false;
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
                            isDisabled:staffTenantView ,
                          ),
                          _buildCheckboxRow(
                            'EDIT',
                            staffTenantEdit,
                            (value) {
                              setState(() {
                                staffTenantEdit = value!;
                              });
                            },
                            isDisabled:staffTenantView ,
                          ),
                          _buildCheckboxRow(
                            'DELETE',
                            staffTenantDelete,
                            (value) {
                              setState(() {
                                staffTenantDelete = value!;
                              });
                            },
                            isDisabled:staffTenantView ,
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
                                 staffWorkorderEdit = false;
                                 staffWorkorderAdd = false;
                                 staffWorkorderDelete = false;
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
                            isDisabled:staffWorkorderView ,
                          ),
                          _buildCheckboxRow(
                            'EDIT',
                            staffWorkorderEdit,
                                (value) {
                              setState(() {
                                staffWorkorderEdit = value!;
                              });
                            },
                            isDisabled:staffWorkorderView ,
                          ),
                          _buildCheckboxRow(
                            'DELETE',
                            staffWorkorderDelete,
                                (value) {
                              setState(() {
                                staffWorkorderDelete = value!;
                              });
                            },
                            isDisabled:staffWorkorderView ,
                          ),

                        ],
                      ),

                      Divider(color: blueColor),

                      _buildPermissionTable(
                        'Property Type',
                        [
                          _buildCheckboxRow(
                            'VIEW',
                            staffPropertyTypeView,
                                (value) {
                              setState(() {
                                staffPropertyTypeView = value!;
                                if (!staffPropertyTypeView) {
                                  staffPropertyTypeAdd = false;
                                  staffPropertyTypeEdit = false;
                                  staffPropertyTypeDelete = false;
                                }
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'ADD',
                            staffPropertyTypeAdd,
                                (value) {
                              setState(() {
                                staffPropertyTypeAdd = value!;
                              });
                            },
                            isDisabled: staffPropertyTypeView,
                          ),
                          _buildCheckboxRow(
                            'EDIT',
                            staffPropertyTypeEdit,
                                (value) {
                              setState(() {
                                staffPropertyTypeEdit = value!;
                              });
                            },
                            isDisabled: staffPropertyTypeView,
                          ),
                          _buildCheckboxRow(
                            'DELETE',
                            staffPropertyTypeDelete,
                                (value) {
                              setState(() {
                                staffPropertyTypeDelete = value!;
                              });
                            },
                            isDisabled: staffPropertyTypeView,
                          ),
                        ],
                      ),

                      Divider(color: blueColor),

                      _buildPermissionTable(
                        'Rental Owner',
                        [
                          _buildCheckboxRow(
                            'VIEW',
                            staffRentalOwnerView,
                                (value) {
                              setState(() {
                                staffRentalOwnerView = value!;
                                if (!staffRentalOwnerView) {
                                  staffRentalOwnerAdd = false;
                                  staffRentalOwnerEdit = false;
                                  staffRentalOwnerDelete = false;
                                }
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'ADD',
                            staffRentalOwnerAdd,
                                (value) {
                              setState(() {
                                staffRentalOwnerAdd = value!;
                              });
                            },
                            isDisabled: staffRentalOwnerView,
                          ),
                          _buildCheckboxRow(
                            'EDIT',
                            staffRentalOwnerEdit,
                                (value) {
                              setState(() {
                                staffRentalOwnerEdit = value!;
                              });
                            },
                            isDisabled: staffRentalOwnerView,
                          ),
                          _buildCheckboxRow(
                            'DELETE',
                            staffRentalOwnerDelete,
                                (value) {
                              setState(() {
                                staffRentalOwnerDelete = value!;
                              });
                            },
                            isDisabled: staffRentalOwnerView,
                          ),
                        ],
                      ),

                      Divider(color: blueColor),

                      _buildPermissionTable(
                        'Applicant',
                        [
                          _buildCheckboxRow(
                            'VIEW',
                            staffApplicantView,
                                (value) {
                              setState(() {
                                staffApplicantView = value!;
                                if (!staffApplicantView) {
                                  staffApplicantAdd = false;
                                  staffApplicantEdit = false;
                                  staffApplicantDelete = false;
                                }
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'ADD',
                            staffApplicantAdd,
                                (value) {
                              setState(() {
                                staffApplicantAdd = value!;
                              });
                            },
                            isDisabled: staffApplicantView,
                          ),
                          _buildCheckboxRow(
                            'EDIT',
                            staffApplicantEdit,
                                (value) {
                              setState(() {
                                staffApplicantEdit = value!;
                              });
                            },
                            isDisabled: staffApplicantView,
                          ),
                          _buildCheckboxRow(
                            'DELETE',
                            staffApplicantDelete,
                                (value) {
                              setState(() {
                                staffApplicantDelete = value!;
                              });
                            },
                            isDisabled: staffApplicantView,
                          ),
                        ],
                      ),

                      Divider(color: blueColor),

                      _buildPermissionTable(
                        'Vendor',
                        [
                          _buildCheckboxRow(
                            'VIEW',
                            staffVendorView,
                                (value) {
                              setState(() {
                                staffVendorView = value!;
                                if (!staffVendorView) {
                                  staffVendorAdd = false;
                                  staffVendorEdit = false;
                                  staffVendorDelete = false;
                                }
                              });
                            },
                          ),
                          _buildCheckboxRow(
                            'ADD',
                            staffVendorAdd,
                                (value) {
                              setState(() {
                                staffVendorAdd = value!;
                              });
                            },
                            isDisabled: staffVendorView,
                          ),
                          _buildCheckboxRow(
                            'EDIT',
                            staffVendorEdit,
                                (value) {
                              setState(() {
                                staffVendorEdit = value!;
                              });
                            },
                            isDisabled: staffVendorView,
                          ),
                          _buildCheckboxRow(
                            'DELETE',
                            staffVendorDelete,
                                (value) {
                              setState(() {
                                staffVendorDelete = value!;
                              });
                            },
                            isDisabled: staffVendorView,
                          ),
                        ],
                      ),

                      Divider(color: blueColor),

                      _buildPermissionTable(
                        'Setting',
                        [
                          _buildCheckboxRow(
                            'VIEW',
                            staffSetting,
                                (value) {
                              setState(() {
                                staffSetting = value!;
                                if (!staffSetting) {

                                }
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
                      color: blueColor,
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
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 500) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 100,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                                  String? adminId = prefs.getString("adminId");

                                  UserPermissionData userPermissionData = UserPermissionData(
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
                                      setting: staffSetting,
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
                                     // leasedetailView: staffLeasedetailView,
                                      workorderView: staffWorkorderView,
                                      workorderAdd: staffWorkorderAdd,
                                      workorderDelete: staffWorkorderDelete,
                                      propertytypeView: staffPropertyTypeView,
                                      propertytypeAdd: staffPropertyTypeAdd,
                                      propertytypeEdit: staffPropertyTypeEdit,
                                      propertytypeDelete: staffPropertyTypeDelete,
                                      rentalownerView: staffRentalOwnerView,
                                      rentalownerAdd: staffRentalOwnerAdd,
                                      rentalownerEdit: staffRentalOwnerEdit,
                                      rentalownerDelete: staffRentalOwnerDelete,
                                      applicantView: staffApplicantView,
                                      applicantAdd: staffApplicantAdd,
                                      applicantEdit: staffApplicantEdit,
                                      applicantDelete: staffApplicantDelete,
                                      vendorView: staffVendorView,
                                      vendorAdd: staffVendorAdd,
                                      vendorEdit: staffVendorEdit,
                                      vendorDelete: staffVendorDelete,
                                    ),
                                    vendorPermission: VendorPermission(
                                      workorderEdit: vendorWorkorderEdit,
                                      workorderView: vendorWorkorderView,
                                      // Add other vendor permissions here if needed
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
                                        msg: 'Failed to update permissions. Try Again later');
                                    print('Failed to update permissions. Status code: $statusCode');
                                  }
                                },
                                child: _isLoading
                                    ? Center(
                                  child: SpinKitFadingCircle(
                                    color: Colors.white,
                                    size: 20.0,
                                  ),
                                )
                                    : Text('Save', style: TextStyle(fontSize: 20)),
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
                                child: Text('Cancel', style: TextStyle(fontSize: 20)),
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

                              UserPermissionData userPermissionData = UserPermissionData(
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
                              //    propertydetailView: staffPropertydetailView,
                              //    workorderdetailView: staffWorkorderdetailView,
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

                                  setting: staffSetting,



                            //      leasedetailView: staffLeasedetailView,
                                  workorderView: staffWorkorderView,
                                  workorderAdd: staffWorkorderAdd,
                                  workorderDelete: staffWorkorderDelete,
                                  propertytypeView: staffPropertyTypeView,
                                  propertytypeAdd: staffPropertyTypeAdd,
                                  propertytypeEdit: staffPropertyTypeEdit,
                                  propertytypeDelete: staffPropertyTypeDelete,
                                  rentalownerView: staffRentalOwnerView,
                                  rentalownerAdd: staffRentalOwnerAdd,
                                  rentalownerEdit: staffRentalOwnerEdit,
                                  rentalownerDelete: staffRentalOwnerDelete,
                                  applicantView: staffApplicantView,
                                  applicantAdd: staffApplicantAdd,
                                  applicantEdit: staffApplicantEdit,
                                  applicantDelete: staffApplicantDelete,
                                  vendorView: staffVendorView,
                                  vendorAdd: staffVendorAdd,
                                  vendorEdit: staffVendorEdit,
                                  vendorDelete: staffVendorDelete,
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
                                    msg: 'Failed to update permissions. Try Again later');
                                print('Failed to update permissions. Status code: $statusCode');
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
  Widget _buildPermissionTableselectall(String title, List<Widget> checkboxes) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        int columns = 1;

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
      {bool isDisabled = true}
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Row(
        children: [
          Checkbox(value: value, onChanged:!isDisabled ? null :  (value) {

           onChanged(value);
          // updatePermissionsBasedOnSelectAll();
           checkAllPermissions();
          },activeColor: blueColor,),
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
  Widget _buildCheckboxRowselectall(
      String label,
      bool value,
      ValueChanged<bool?> onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Row(
        children: [
          Checkbox(value: value, onChanged: onChanged,activeColor: blueColor,),
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
