import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../constant/constant.dart';
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
              const SizedBox(height: 70),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo.png"),
              ),
              const SizedBox(height: 20),
              buildListTile(
                  context,
                   Icon(
                    CupertinoIcons.circle_grid_3x3,
                    color:  widget.currentpage == "Dashboard" ?Colors.white:blueColor,
                  ),
                  "Dashboard",
                widget.currentpage == "Dashboard",),
              buildListTile(
                  context,
                   Icon(
                    CupertinoIcons.person,
                    color:widget.currentpage == "Profile" ?Colors.white:blueColor,
                  ),
                  "Profile",
                widget.currentpage == "Profile",),
             /* if(permissions!.propertyView!)
                buildListTile(
                  context,
                  Icon(
                    CupertinoIcons.home,
                    color: widget.currentpage == "Add Property Type" ?Colors.white:blueColor,
                  ),
                  "Add Property Type",
                  widget.currentpage == "Add Property Type",),*/
              if(permissions!.propertyView!)
              buildListTile(
                  context,
                   Icon(
                    CupertinoIcons.building_2_fill,
                    color: widget.currentpage == "Properties" ?Colors.white:blueColor,
                  ),
                  "Properties",
                widget.currentpage == "Properties",),
              if(permissions!.propertyView!)
                buildListTile(
                  context,
                  Icon(
                    CupertinoIcons.person_2,
                    color: widget.currentpage == "RentalOwner" ?Colors.white:blueColor,
                  ),
                  "Rental Owner",
                  widget.currentpage == "RentalOwner",),
              if(permissions!.tenantView!)
                buildListTile(
                  context,
                  Icon(
                    Icons.lock_person_outlined,
                    color: widget.currentpage == "Tenants" ?Colors.white:blueColor,
                  ),
                  "Tenants",
                  widget.currentpage == "Tenants",),
              if(permissions!.leaseView!)
              buildListTile(
                  context,
                   Icon(
                    Icons.wallet,
                    color: widget.currentpage == "Rent Roll" ?Colors.white:blueColor,
                  ),
                  "Rent Roll",
                widget.currentpage == "Rent Roll",),
             /* if(permissions!.leaseView!)
                buildListTile(
                  context,
                  FaIcon(
                    FontAwesomeIcons.addressCard,
                    color: widget.currentpage == "Applicants" ?Colors.white:blueColor,
                  ),
                  "Applicants",
                  widget.currentpage == "Applicants",),
              if(permissions!.workorderView!)
                buildListTile(
                  context,
                  FaIcon(
                    FontAwesomeIcons.circleUser,
                    color: widget.currentpage == "Vendor" ?Colors.white:blueColor,
                  ),
                  "Vendor",
                  widget.currentpage == "Vendor",),

              if(permissions!.workorderView!)
              buildListTile(
                  context,
                   Icon(
                    CupertinoIcons.square_list,
                    color: widget.currentpage == "Work Order" ?Colors.white:blueColor,
                  ),
                  "Work Order",
                widget.currentpage == "Work Order",),
*/
            ],
          ),
        ),
      ),
    );
  }
}
