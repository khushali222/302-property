import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import 'drawer_tiles.dart';


class CustomDrawer extends StatefulWidget {
  final String currentpage;
  final bool dropdown;

  CustomDrawer({required this.currentpage,required this.dropdown});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {

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
           ["Properties", "RentalOwner", "Tenants"],
           [
             FaIcon(FontAwesomeIcons.buildingUser, size: 20, color: widget.currentpage == "Properties"
                 ? Colors.white
                 : blueColor,), // Icon for Properties
             FaIcon(FontAwesomeIcons.houseChimneyUser, size: 20,  color: widget.currentpage == "RentalOwner"
                 ? Colors.white
                 : blueColor,), // Icon for RentalOwner
             FaIcon(FontAwesomeIcons.users, size: 20,  color: widget.currentpage == "Tenants"
                 ? Colors.white
                 : blueColor,), // Icon for Tenants
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
               ["Rent Roll", "Applicants"],
               [
                 FaIcon(FontAwesomeIcons.wallet, size: 20,  color: widget.currentpage == "Rent Roll"
                     ? Colors.white
                     : blueColor,), // Icon for Properties
                 FaIcon(FontAwesomeIcons.addressCard, size: 20,  color: widget.currentpage == "Applicants"
                     ? Colors.white
                     : blueColor,), // Icon for RentalOwner
               //  FaIcon(FontAwesomeIcons.users, size: 20, color: blueColor), // Icon for Tenants
               ],
               selectedSubtopic: !widget.dropdown ? null : widget.currentpage,
             ),
             buildDropdownListTile(
               context,
               FaIcon(FontAwesomeIcons.screwdriverWrench, size: 20,  color:  blueColor,),
               "Maintenance",
               ["Vendor", "Work Order"],
               [
                 FaIcon(FontAwesomeIcons.solidCircleUser, size: 20,  color: widget.currentpage == "Vendor"
                     ? Colors.white
                     : blueColor,), // Icon for Properties
                 FaIcon(FontAwesomeIcons.bookBookmark, size: 20, color: widget.currentpage == "Work Order"
                     ? Colors.white
                     : blueColor,), // Icon for RentalOwner
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
