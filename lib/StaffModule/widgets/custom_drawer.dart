import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../model/staffpermission.dart';
import '../repository/staffpermission_provider.dart';
import 'drawer_tiles.dart';


class CustomDrawer extends StatefulWidget {
  final String currentpage;
  CustomDrawer({required this.currentpage});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  StaffPermission? permissions;
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
                 Icon(
                  CupertinoIcons.circle_grid_3x3,
                  color:  widget.currentpage == "Dashboard" ?Colors.white:Colors.black,
                ),
                "Dashboard",
              widget.currentpage == "Dashboard",),
            buildListTile(
                context,
                 Icon(
                  CupertinoIcons.person,
                  color:widget.currentpage == "Profile" ?Colors.white:Colors.black,
                ),
                "Profile",
              widget.currentpage == "Profile",),
            if(permissions!.propertyView!)
            buildListTile(
                context,
                 Icon(
                  CupertinoIcons.home,
                  color: widget.currentpage == "Properties" ?Colors.white:Colors.black,
                ),
                "Properties",
              widget.currentpage == "Properties",),
           /* if(permissions!.leaseView!)
            buildListTile(
                context,
                 Icon(
                  Icons.wallet,
                  color: widget.currentpage == "Rent Roll" ?Colors.white:Colors.black,
                ),
                "Rent Roll",
              widget.currentpage == "Rent Roll",),
            if(permissions!.tenantView!)
            buildListTile(
                context,
                 Icon(
                  Icons.lock_person_outlined,
                  color: widget.currentpage == "Tenants" ?Colors.white:Colors.black,
                ),
                "Tenants",
              widget.currentpage == "Tenants",),
            if(permissions!.workorderView!)
            buildListTile(
                context,
                 Icon(
                  CupertinoIcons.square_list,
                  color: widget.currentpage == "Work Order" ?Colors.white:Colors.black,
                ),
                "Work Order",
              widget.currentpage == "Work Order",),*/

          ],
        ),
      ),
    );
  }
}
