import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import '../../../widgets/drawer_tiles.dart';
class Vendor_table extends StatefulWidget {
  const Vendor_table({super.key});

  @override
  State<Vendor_table> createState() => _Vendor_tableState();
}

class _Vendor_tableState extends State<Vendor_table> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: Drawer(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo.png"),
              ),
              SizedBox(height: 40),
              buildListTile(
                  context,
                  Icon(
                    CupertinoIcons.circle_grid_3x3,
                    color: Colors.black,
                  ),
                  "Dashboard",
                  false),
              buildListTile(
                  context,
                  Icon(
                    CupertinoIcons.house,
                    color: Colors.black,
                  ),
                  "Add Property Type",
                  false),
              buildListTile(
                  context,
                  Icon(
                    CupertinoIcons.person_add,
                    color: Colors.black,
                  ),
                  "Add Staff Member",
                  false),
              buildDropdownListTile(context, FaIcon(
                FontAwesomeIcons.key,
                size: 20,
                color: Colors.black,
              ), "Rental",
                  ["Properties", "RentalOwner", "Tenants"],selectedSubtopic: "Vendor"),
              buildDropdownListTile(context, FaIcon(
                FontAwesomeIcons.thumbsUp,
                size: 20,
                color: Colors.black,
              ),
                  "Leasing", ["Rent Roll", "Applicants"],selectedSubtopic: "Vendor"),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"],selectedSubtopic: "Vendor"),
            ],
          ),
        ),
      ),
      body: Center(child: Container(child: Text("Vendor page"),)),
    );
  }
}
