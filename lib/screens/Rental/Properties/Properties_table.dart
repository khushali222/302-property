import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../widgets/drawer_tiles.dart';

class Properties_table extends StatefulWidget {
  const Properties_table({super.key});

  @override
  State<Properties_table> createState() => _Properties_tableState();
}

class _Properties_tableState extends State<Properties_table> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    color: Colors.white,
                  ),
                  "Add Staff Member",
                  true),
              buildDropdownListTile(context, FaIcon(
                FontAwesomeIcons.key,
                size: 20,
                color: Colors.black,
              ), "Rental",
                  ["Properties", "RentalOwner", "Tenants"]),
              buildDropdownListTile(context, FaIcon(
                FontAwesomeIcons.thumbsUp,
                size: 20,
                color: Colors.black,
              ),
                  "Leasing", ["Rent Roll", "Applicants"]),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"]),
            ],
          ),
        ),
      ),
    );
  }
}
