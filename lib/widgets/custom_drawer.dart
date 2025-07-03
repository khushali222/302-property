import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
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
              buildListTile(
                context,
                FaIcon(
                  FontAwesomeIcons.house,
                  size: 20,
                  color: widget.currentpage == "Add Property Type"
                      ? Colors.white
                      : blueColor,
                ),
                "Property Type",
                widget.currentpage == "Add Property Type",
              ),
              buildListTile(
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
              ),
              buildDropdownListTile(
                context,
                FaIcon(
                  FontAwesomeIcons.key,
                  size: 20,
                  color: blueColor,
                ),
                "Rental",
                ["Properties", "Rental Owner", "Tenants"],
                [
                  FaIcon(
                    FontAwesomeIcons.buildingUser,
                    size: 20,
                    color: widget.currentpage == "Properties"
                        ? Colors.white
                        : blueColor,
                  ), // Icon for Properties
                  FaIcon(
                    FontAwesomeIcons.houseChimneyUser,
                    size: 20,
                    color: widget.currentpage == "Rental Owner"
                        ? Colors.white
                        : blueColor,
                  ), // Icon for RentalOwner
                  FaIcon(
                    FontAwesomeIcons.users,
                    size: 20,
                    color: widget.currentpage == "Tenants"
                        ? Colors.white
                        : blueColor,
                  ), // Icon for Tenants
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
                  "Rent Roll",
                  "Applicants",
                  "Upcoming renewal",
                  "Scheduled Payment",
                  "Scheduled Charges",
                ],
                [
                  FaIcon(
                    FontAwesomeIcons.wallet,
                    size: 20,
                    color: widget.currentpage == "Rent Roll"
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
                  ),
                  Icon(
                    Icons.calendar_month,
                    size: 25,
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
              buildDropdownListTile(
                context,
                FaIcon(
                  FontAwesomeIcons.screwdriverWrench,
                  size: 20,
                  color: blueColor,
                ),
                "Maintenance",
                ["Vendor", "Work Order"],
                [
                  FaIcon(
                    FontAwesomeIcons.solidCircleUser,
                    size: 20,
                    color: widget.currentpage == "Vendor"
                        ? Colors.white
                        : blueColor,
                  ), // Icon for Properties
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
