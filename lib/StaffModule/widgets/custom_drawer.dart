import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../repository/staffpermission_provider.dart';
import 'drawer_tiles.dart';

import '../model/staffpermission.dart';

class CustomDrawerStaff extends StatefulWidget {
  final String currentpage;
  final bool dropdown;

  CustomDrawerStaff({required this.currentpage, required this.dropdown});

  @override
  _CustomDrawerStaffState createState() => _CustomDrawerStaffState();
}

class _CustomDrawerStaffState extends State<CustomDrawerStaff> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // _loadPermissions();
  }

  @override
  Widget build(BuildContext context) {
    /*   if (isLoading) {
      return Center(child: Text(""));
    }

    if (permissions == null) {
      return Center(child: Text('Failed to load permissions'));
    }
*/
    final permissionProvider = Provider.of<StaffPermissionProvider>(context);
    StaffPermission? permissions = permissionProvider.permissions;
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(80),
        bottomRight: Radius.circular(80),
      ),
      child: Drawer(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo.png"),
              ),
              const SizedBox(height: 40),
              buildListTile(
                context,
                widget.currentpage == "Dashboard"
                    ? SvgPicture.asset(
                        "assets/images/tenants/dashboard1.svg",
                        fit: BoxFit.cover,
                        height: 20,
                        width: 20,
                      )
                    : SvgPicture.asset(
                        "assets/images/tenants/dashboard.svg",
                        fit: BoxFit.cover,
                        height: 20,
                        width: 20,
                        color: blueColor,
                      ),
                "Dashboard",
                widget.currentpage == "Dashboard",
              ),

              /*buildListTile(
                context,
                FaIcon(
                  FontAwesomeIcons.userClock,
                  size: 20,
                  color: widget.currentpage == "Add Staff Member"
                      ? Colors.white
                      : blueColor,
                ),
                "Staff Member",
                widget.currentpage == "Add Staff Member",
              ),*/
              buildDropdownListTile(
                context,
                FaIcon(
                  FontAwesomeIcons.key,
                  size: 20,
                  color: blueColor,
                ),
                "Rentals",
                // Filter the options based on permissions
                [
                  if (permissions!.propertyView == true) "Properties",
                  if (permissions!.rentalownerView == true) "Rental Owner",
                  if (permissions!.tenantView == true) "Tenants",
                  if (permissions!.propertytypeView == true) "Property Type",
                ],
                // Filter the icons based on permissions in the same order
                [
                  if (permissions.propertyView == true)
                    FaIcon(FontAwesomeIcons.buildingUser,
                        size: 20,
                        color: widget.currentpage == "Properties"
                            ? Colors.white
                            : blueColor), // Icon for Properties
                  if (permissions.rentalownerView == true)
                    FaIcon(FontAwesomeIcons.users,
                        size: 20,
                        color: widget.currentpage == "Rental Owner"
                            ? Colors.white
                            : blueColor), // Icon for RentalOwner

                  if (permissions.tenantView == true)
                    FaIcon(FontAwesomeIcons.houseChimneyUser,
                        size: 20,
                        color: widget.currentpage == "Tenants"
                            ? Colors.white
                            : blueColor), // Icon for Tenants
                  if (permissions!.propertytypeView == true)
                    FaIcon(
                      FontAwesomeIcons.house,
                      size: 20,
                      color: widget.currentpage == "Property Type"
                          ? Colors.white
                          : blueColor,
                    ),
                ],
                selectedSubtopic: !widget.dropdown ? null : widget.currentpage,
              ),
              buildDropdownListTile(
                context,
                FaIcon(
                  FontAwesomeIcons.thumbsUp,
                  size: 20,
                  color: blueColor,
                ),
                "Leasing",
                [
                  "Leases",
                  "Applicants",
                  "Upcoming renewal",
                  "Scheduled Payment"
                ],
                [
                  FaIcon(
                    FontAwesomeIcons.wallet,
                    size: 20,
                    color: widget.currentpage == "Leases"
                        ? Colors.white
                        : blueColor,
                  ), // Icon for Properties
                  FaIcon(
                    FontAwesomeIcons.addressCard,
                    size: 20,
                    color: widget.currentpage == "Applicants"
                        ? Colors.white
                        : blueColor,
                  ),

                  widget.currentpage == "Upcoming renewal"
                      ? SvgPicture.asset(
                          "assets/images/upcoming white.svg",
                          fit: BoxFit.cover,
                          height: 27,
                          width: 27,
                        )
                      : SvgPicture.asset(
                          "assets/images/upcoming renewal.svg",
                          fit: BoxFit.cover,
                          height: 27,
                          width: 27,
                          color: blueColor,
                        ),
                  FaIcon(
                    FontAwesomeIcons.clock,
                    size: 20,
                    color: widget.currentpage == "Scheduled Payment"
                        ? Colors.white
                        : blueColor,
                  ), // Icon for RentalOwner
                  //  FaIcon(FontAwesomeIcons.users, size: 20, color: blueColor), // Icon for Tenants
                ],
                selectedSubtopic: !widget.dropdown ? null : widget.currentpage,
              ),
              buildDropdownListTile(
                context,
                FaIcon(
                  FontAwesomeIcons.screwdriverWrench,
                  size: 20,
                  color: blueColor,
                ),
                "Maintenance",
                [
                  if (permissions.vendorView ?? false) "Vendor",
                  if (permissions.workorderView ?? false) "Work Order",
                ],
                [
                  if (permissions.vendorView ?? false)
                    FaIcon(
                      FontAwesomeIcons.solidCircleUser,
                      size: 20,
                      color: widget.currentpage == "Vendor"
                          ? Colors.white
                          : blueColor,
                    ), // Icon for Vendor
                  if (permissions.workorderView ?? false)
                    FaIcon(
                      FontAwesomeIcons.bookBookmark,
                      size: 20,
                      color: widget.currentpage == "Work Order"
                          ? Colors.white
                          : blueColor,
                    ), // Icon for RentalOwner
                  //  FaIcon(FontAwesomeIcons.users, size: 20, color: blueColor), // Icon for Tenants
                ],
                selectedSubtopic: !widget.dropdown ? null : widget.currentpage,
              ),
              buildDropdownListTile(
                context,
                FaIcon(
                  FontAwesomeIcons.comments,
                  size: 20,
                  color: blueColor,
                ),
                "Communication",
                [
                  "Send E-mail",
                  "E-mail Logs",
                  "Templates",
                ],
                [
                  FaIcon(
                    FontAwesomeIcons.envelopeCircleCheck,
                    size: 20,
                    color: widget.currentpage == "Send E-mail"
                        ? Colors.white
                        : blueColor,
                  ), // Icon for Properties
                  FaIcon(
                    FontAwesomeIcons.envelopeOpenText,
                    size: 20,
                    color: widget.currentpage == "E-mail Logs"
                        ? Colors.white
                        : blueColor,
                  ),

                  FaIcon(
                    FontAwesomeIcons.wallet,
                    size: 20,
                    color: widget.currentpage == "Templates"
                        ? Colors.white
                        : blueColor,
                  ), // Icon for RentalOwner
                  //  FaIcon(FontAwesomeIcons.users, size: 20, color: blueColor), // Icon for Tenants
                ],
                selectedSubtopic: !widget.dropdown ? null : widget.currentpage,
              ),
              buildListTile(
                context,
                FaIcon(
                  FontAwesomeIcons.folderOpen,
                  color: widget.currentpage == "Reports"
                      ? Colors.white
                      : blueColor,
                ),
                "Reports",
                widget.currentpage == "Reports",
              ),
              if (permissions.settingView == true)
                buildListTile(
                  context,
                  FaIcon(
                    FontAwesomeIcons.cog,
                    color: widget.currentpage == "Settings"
                        ? Colors.white
                        : blueColor,
                  ),
                  "Settings",
                  widget.currentpage == "Settings",
                ),
            ],
          ),
        ),
      ),
    );

    /*return Drawer(
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
              SvgPicture.asset(
                "assets/images/tenants/dashboard.svg",
                fit: BoxFit.cover,
                height: 20,
                width: 20,
              ),
              "Dashboard",
              widget.currentpage == "Dashboard",
            ),
            buildListTile(
              context,
              SvgPicture.asset(
                "assets/images/tenants/Admin.svg",
                fit: BoxFit.cover,
                height: 20,
                width: 20,
              ),
              "Profile",
              widget.currentpage == "Profile",
            ),

              buildListTile(
                context,
                SvgPicture.asset(
                  "assets/images/tenants/Property.svg",
                  fit: BoxFit.cover,
                  height: 20,
                  width: 20,
                ),
                "Properties",
                widget.currentpage == "Properties",
              ),

              buildListTile(
                context,
                SvgPicture.asset(
                  "assets/images/tenants/Financial.svg",
                  fit: BoxFit.cover,
                  height: 20,
                  width: 20,
                ),
                "Financial",
                widget.currentpage == "Financial",
              ),

              buildListTile(
                context,
                SvgPicture.asset(
                  "assets/images/tenants/Work.svg",
                  fit: BoxFit.cover,
                  height: 20,
                  width: 20,
                ),
                "Work Order",
                widget.currentpage == "Work Order",
              ),

              buildListTile(
                context,
                SvgPicture.asset(
                  "assets/images/tenants/tenantdoc1.svg",
                  fit: BoxFit.cover,
                  height: 20,
                  width: 20,
                ),
                "Documents",
                widget.currentpage == "Documents",
              ),
          ],
        ),
      ),
    );*/
  }
}
