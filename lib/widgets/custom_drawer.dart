import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:provider/provider.dart'; // Unused import
// import 'package:cupertino_icons/cupertino_icons.dart'; // Unused import
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'drawer_tiles.dart';

class CustomDrawer extends StatefulWidget {
  final String currentpage;
  final bool dropdown;

  CustomDrawer({required this.currentpage, required this.dropdown});
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool isLoading = true;
  String? _brandLogoBase64;
  @override
  void initState() {
    super.initState();
    // _loadPermissions();
    _loadBrandLogo();
  }

  Future<void> _loadBrandLogo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? logo = prefs.getString('brand_logo');

    if (logo != null && logo.isNotEmpty && logo.startsWith('data:image')) {
      setState(() {
        _brandLogoBase64 = logo.split(',').last;
      });
    }
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

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: Drawer(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _brandLogoBase64 != null
                  ? const SizedBox(height: 10)
                  : const SizedBox(height: 80),
              // Padding(
              //   padding: const EdgeInsets.all(20.0),
              //   child: Image.asset("assets/images/logo.png"),
              // ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: _brandLogoBase64 != null
                    ? Container(
                        // color: Colors.blue,
                        child: Image.memory(
                          base64Decode(_brandLogoBase64!),
                          //  height: 100,
                          // width: 100,
                        ),
                      )
                    : Image.asset(
                        "assets/images/logo.png",
                        // height: 100,
                      ),
              ),
              // const SizedBox(height: 5),
              buildListTile(
                context,
                widget.currentpage == "Dashboard"
                    ? SvgPicture.asset(
                        "assets/images/tenants/dashboard1.svg",
                        fit: BoxFit.cover,
                        height: 18,
                        width: 18,
                      )
                    : SvgPicture.asset(
                        "assets/images/tenants/dashboard.svg",
                        fit: BoxFit.cover,
                        height: 18,
                        width: 18,
                        color: blueColor,
                      ),
                "Dashboard",
                widget.currentpage == "Dashboard",
              ),

              // Properties as top-level menu item
              buildListTile(
                context,
                FaIcon(
                  FontAwesomeIcons.buildingUser,
                  size: 18,
                  color: widget.currentpage == "Properties"
                      ? Colors.white
                      : blueColor,
                ),
                "Properties",
                widget.currentpage == "Properties",
              ),

              // Tenants as top-level menu item
              buildListTile(
                context,
                FaIcon(
                  FontAwesomeIcons.users,
                  size: 18,
                  color: widget.currentpage == "Tenants"
                      ? Colors.white
                      : blueColor,
                ),
                "Tenants",
                widget.currentpage == "Tenants",
              ),

              // Rentals dropdown removed - Rental Owner and Property Type moved to Settings
              // Mortgage commented out (not deleted)
              // buildDropdownListTile(
              //   context,
              //   FaIcon(
              //     FontAwesomeIcons.key,
              //     size: 20,
              //     color: blueColor,
              //   ),
              //   "Rentals",
              //   [
              //     "Properties",
              //     "Rental Owner",
              //     "Tenants",
              //     "Property Type",
              //     "Mortgage"
              //   ],
              //   [
              //     FaIcon(
              //       FontAwesomeIcons.buildingUser,
              //       size: 18,
              //       color: widget.currentpage == "Properties"
              //           ? Colors.white
              //           : blueColor,
              //     ), // Icon for Properties
              //     FaIcon(
              //       FontAwesomeIcons.houseChimneyUser,
              //       size: 18,
              //       color: widget.currentpage == "Rental Owner"
              //           ? Colors.white
              //           : blueColor,
              //     ), // Icon for RentalOwner
              //     FaIcon(
              //       FontAwesomeIcons.users,
              //       size: 18,
              //       color: widget.currentpage == "Tenants"
              //           ? Colors.white
              //           : blueColor,
              //     ),
              //     FaIcon(
              //       FontAwesomeIcons.house,
              //       size: 18,
              //       color: widget.currentpage == "Property Type"
              //           ? Colors.white
              //           : blueColor,
              //     ),
              //     FaIcon(
              //       FontAwesomeIcons.handHoldingDollar,
              //       size: 18,
              //       color: widget.currentpage == "Mortgage"
              //           ? Colors.white
              //           : blueColor,
              //     ),
              //     // Icon for Tenants
              //   ],
              //   selectedSubtopic: !widget.dropdown ? null : widget.currentpage,
              // ),
              buildDropdownListTile(
                context,
                FaIcon(
                  FontAwesomeIcons.thumbsUp,
                  size: 22,
                  color: blueColor,
                ),
                "Leasing",
                [
                  "Leases",
                  "Applicants",
                  "Upcoming Renewal",
                  "Scheduled Payment",
                  "Scheduled Charges",
                ],
                [
                  FaIcon(
                    FontAwesomeIcons.wallet,
                    size: 18,
                    color: widget.currentpage == "Leases"
                        ? Colors.white
                        : blueColor,
                  ), // Icon for Properties
                  FaIcon(
                    FontAwesomeIcons.addressCard,
                    size: 18,
                    color: widget.currentpage == "Applicants"
                        ? Colors.white
                        : blueColor,
                  ),

                  widget.currentpage == "Upcoming Renewal"
                      ? SvgPicture.asset(
                          "assets/images/upcoming white.svg",
                          fit: BoxFit.cover,
                          height: 23,
                          width: 23,
                        )
                      : SvgPicture.asset(
                          "assets/images/upcoming renewal.svg",
                          fit: BoxFit.cover,
                          height: 23,
                          width: 23,
                          color: blueColor,
                        ),
                  FaIcon(
                    FontAwesomeIcons.clock,
                    size: 18,
                    color: widget.currentpage == "Scheduled Payment"
                        ? Colors.white
                        : blueColor,
                  ),
                  Icon(
                    Icons.calendar_month,
                    size: 22,
                    color: widget.currentpage == "Scheduled Charges"
                        ? Colors.white
                        : blueColor,
                  ) // Icon for RentalOwner
                  // FaIcon(
                  //   FontAwesomeIcons.clock,
                  //   size: 20,
                  //   color: widget.currentpage == "Scheduled Charges"
                  //       ? Colors.white
                  //       : blueColor,
                  // ),
                  //  FaIcon(FontAwesomeIcons.users, size: 20, color: blueColor), // Icon for Tenants
                ],
                selectedSubtopic: !widget.dropdown ? null : widget.currentpage,
              ),
              // Commented out Maintenance dropdown - Vendor moved to Settings
              // buildDropdownListTile(
              //   context,
              //   FaIcon(
              //     FontAwesomeIcons.screwdriverWrench,
              //     size: 20,
              //     color: blueColor,
              //   ),
              //   "Maintenance",
              //   ["Vendor", "Work Order"],
              //   [
              //     FaIcon(
              //       FontAwesomeIcons.solidCircleUser,
              //       size: 20,
              //       color: widget.currentpage == "Vendor"
              //           ? Colors.white
              //           : blueColor,
              //     ), // Icon for Properties
              //     FaIcon(
              //       FontAwesomeIcons.bookBookmark,
              //       size: 20,
              //       color: widget.currentpage == "Work Order"
              //           ? Colors.white
              //           : blueColor,
              //     ), // Icon for RentalOwner
              //     //  FaIcon(FontAwesomeIcons.users, size: 20, color: blueColor), // Icon for Tenants
              //   ],
              //   selectedSubtopic: !widget.dropdown ? null : widget.currentpage,
              // ),
              // Work Order as direct item (Vendor moved to Settings)
              buildListTile(
                context,
                FaIcon(
                  FontAwesomeIcons.bookBookmark,
                  size: 20,
                  color: widget.currentpage == "Work Order"
                      ? Colors.white
                      : blueColor,
                ),
                "Work Order",
                widget.currentpage == "Work Order",
              ),
              buildDropdownListTile(
                context,
                FaIcon(
                  FontAwesomeIcons.comments,
                  size: 20,
                  color: blueColor,
                ),
                "Communications",
                [
                  "Send E-mail",
                  "E-mail Logs",
                  "Templates",
                ],
                [
                  FaIcon(
                    FontAwesomeIcons.envelopeCircleCheck,
                    size: 18,
                    color: widget.currentpage == "Send E-mail"
                        ? Colors.white
                        : blueColor,
                  ), // Icon for Properties
                  FaIcon(
                    FontAwesomeIcons.envelopeOpenText,
                    size: 18,
                    color: widget.currentpage == "E-mail Logs"
                        ? Colors.white
                        : blueColor,
                  ),

                  FaIcon(
                    FontAwesomeIcons.wallet,
                    size: 18,
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
                  size: 18,
                  color: widget.currentpage == "Reports"
                      ? Colors.white
                      : blueColor,
                ),
                "Reports",
                widget.currentpage == "Reports",
              ),
              buildListTile(
                context,
                FaIcon(
                  FontAwesomeIcons.userClock,
                  size: 18,
                  color:
                      widget.currentpage == "Staff" ? Colors.white : blueColor,
                ),
                "Staff",
                widget.currentpage == "Staff",
              ),
              buildListTile(
                context,
                FaIcon(
                  FontAwesomeIcons.cog,
                  size: 18,
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
  }
}
