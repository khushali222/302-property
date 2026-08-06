import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../constant/constant.dart';
import '../repository/permission_provider.dart';
import 'drawer_tiles.dart';

class CustomDrawer extends StatefulWidget {
  final String currentpage;
  CustomDrawer({required this.currentpage});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    // Permissions come from the provider and are null until the fetch resolves.
    // Watching (no listen: false) rebuilds this drawer once they arrive, so the
    // menu fills itself in; every entry below reads them null-safely and simply
    // stays hidden in the meantime.
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
              if (permissions?.propertyView == true)
                buildListTile(
                  context,
                  FaIcon(
                    FontAwesomeIcons.house,
                    size: 20,
                    color: widget.currentpage == "Property"
                        ? Colors.white
                        : blueColor,
                  ),
                  "Property",
                  widget.currentpage == "Property",
                ),
              if (permissions?.financialView == true)
                buildListTile(
                  context,
                  FaIcon(
                    FontAwesomeIcons.chartColumn,
                    size: 20,
                    color: widget.currentpage == "Ledger"
                        ? Colors.white
                        : blueColor,
                  ),
                  "Ledger",
                  widget.currentpage == "Ledger",
                ),
              if (permissions?.workorderView == true)
                buildListTile(
                  context,
                  widget.currentpage == "Work Orders"
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
                  "Work Orders",
                  widget.currentpage == "Work Orders",
                ),
              if (permissions?.documentsView == true)
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
