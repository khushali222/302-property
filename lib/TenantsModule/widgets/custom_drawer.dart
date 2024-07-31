import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

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
    return Drawer(
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
            if (permissions!.propertyView)
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
            if (permissions!.financialView)
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
            if (permissions!.workorderView)
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
            if (permissions!.documentsView)
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
    );
  }
}
