import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import '../../widgets/drawer_tiles.dart';
class Applicants_table extends StatefulWidget {
  const Applicants_table({super.key});

  @override
  State<Applicants_table> createState() => _Applicants_tableState();
}

class _Applicants_tableState extends State<Applicants_table> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      drawer: Drawer(
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
              buildDropdownListTile(context, Icon(Icons.key), "Rental",
                  ["Properties", "RentalOwner", "Tenants"],selectedSubtopic: "Applicants"),
              buildDropdownListTile(context, Icon(Icons.thumb_up_alt_outlined),
                  "Leasing", ["Rent Roll", "Applicants"],selectedSubtopic: "Applicants"),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"],selectedSubtopic: "Applicants"),
            ],
          ),
        ),
      ),
      body: Center(child: Container(child: Text("Rental owner page"),)),
    );
  }
}