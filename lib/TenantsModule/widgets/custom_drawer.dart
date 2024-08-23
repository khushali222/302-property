import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../constant/constant.dart';
import '../repository/permission_provider.dart';
import 'drawer_tiles.dart';
import '../model/permission.dart';
import '../repository/permission_repo.dart';

class CustomDrawer extends StatefulWidget {
  final String currentpage;
  CustomDrawer({required this.currentpage});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  UserPermissions? permissions;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
   // _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    try {
      UserPermissions fetchedPermissions = await PermissionService.fetchPermissions();
      setState(() {
        permissions = fetchedPermissions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error
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
    final permissionProvider = Provider.of<PermissionProvider>(context);
    final permissions = permissionProvider.permissions;
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
                ),
                "Dashboard",
                widget.currentpage == "Dashboard",
              ),
              buildListTile(
                context,
                FaIcon(
                  FontAwesomeIcons.user,
                  size: 20,
                  color: widget.currentpage == "Profile"
                      ? Colors.white
                      : blueColor,
                ),
                "Profile",
                widget.currentpage == "Profile",
              ),
              if (permissions!.propertyView)
                buildListTile(
                  context,
                  FaIcon(
                    FontAwesomeIcons.house,
                    size: 20,
                    color: widget.currentpage == "Properties"
                        ? Colors.white
                        : blueColor,
                  ),
                  "Properties",
                  widget.currentpage == "Properties",
                ),
              if (permissions!.financialView)
                buildListTile(
                  context,
                  FaIcon(
                    FontAwesomeIcons.chartColumn,
                    size: 20,
                    color: widget.currentpage == "Financial"
                        ? Colors.white
                        : blueColor,
                  ),
                  "Financial",
                  widget.currentpage == "Financial",
                ),
              if (permissions!.workorderView)
                buildListTile(
                  context,
                  widget.currentpage == "Work Order"
                      ? SvgPicture.asset(
                    "assets/images/tenants/Work Light.svg",
                    fit: BoxFit.cover,
                    height: 20,
                    width: 20,
                  )
                      : SvgPicture.asset(
                    "assets/images/tenants/workorder.svg",
                    fit: BoxFit.cover,
                    height: 20,
                    width: 20,
                  ),
                  "Work Order",
                  widget.currentpage == "Work Order",
                ),
              if (permissions!.documentsView)
                buildListTile(
                  context,
                  FaIcon(
                    FontAwesomeIcons.fileInvoice,
                    size: 20,
                    color: widget.currentpage == "Documents"
                        ? Colors.white
                        : blueColor,
                  ),
                  "Documents",
                  widget.currentpage == "Documents",
                ),
            ],
          ),
        ),
      ),
    );
  }
}